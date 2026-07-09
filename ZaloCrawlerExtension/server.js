// Zalo Crawler Extension - Local Backend Server (server.js)
const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const https = require('https');

const PORT = 3000;
const ISSUES_FILE = path.join(__dirname, 'zalo_issues.json');
const CONFIG_FILE = path.join(__dirname, 'config.json');

// Paths to local MES knowledge
const KB_PATHS = [
  'C:\\Users\\User Vinatech.DESKTOP-RJJSEQU\\Desktop\\PROCESS\\MES\\MES_MASTER_KNOWLEDGE_BASE',
  'C:\\Users\\User Vinatech.DESKTOP-RJJSEQU\\Desktop\\PROCESS\\SYSTEM_MASTER_KNOWLEDGE_BASE'
];

// Initialize configuration
let config = { GEMINI_API_KEY: "" };
if (fs.existsSync(CONFIG_FILE)) {
  try {
    config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
  } catch (e) {
    console.error('Error reading config.json, using default template:', e.message);
  }
} else {
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2), 'utf8');
}

// Initialize issues file
if (!fs.existsSync(ISSUES_FILE)) {
  fs.writeFileSync(ISSUES_FILE, JSON.stringify([], null, 2), 'utf8');
}

// CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Content-Type': 'application/json'
};

// Help helper to recursively scan directories for files
function getFilesRecursively(dir) {
  let results = [];
  if (!fs.existsSync(dir)) return results;
  
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat && stat.isDirectory()) {
      results = results.concat(getFilesRecursively(fullPath));
    } else if (file.endsWith('.md')) {
      results.push(fullPath);
    }
  });
  return results;
}

// Search local knowledge base for relevant terms
function searchKnowledgeBase(queryText) {
  console.log(`[Search] Searching local MES files for query: "${queryText}"`);
  const keywords = queryText.toLowerCase()
    .replace(/[.,\/#!$%\^&\*;:{}=\-_`~()?"']/g, " ")
    .split(/\s+/)
    .filter(word => word.length > 2 && !['cho', 'của', 'với', 'trong', 'trên', 'dưới', 'làm', 'bị', 'lỗi', 'giúp'].includes(word));

  if (keywords.length === 0) return "Không tìm thấy từ khóa tìm kiếm phù hợp.";

  let matchedFiles = [];
  
  KB_PATHS.forEach(kbPath => {
    if (!fs.existsSync(kbPath)) return;
    const files = getFilesRecursively(kbPath);
    files.forEach(file => {
      try {
        const content = fs.readFileSync(file, 'utf8');
        const contentLower = content.toLowerCase();
        let matchCount = 0;
        
        keywords.forEach(word => {
          if (contentLower.includes(word)) {
            matchCount++;
          }
        });
        
        if (matchCount > 0) {
          matchedFiles.push({
            filePath: file,
            fileName: path.basename(file),
            content: content,
            score: matchCount
          });
        }
      } catch (err) {
        // Ignore file read errors
      }
    });
  });

  // Sort by match score desc
  matchedFiles.sort((a, b) => b.score - a.score);

  if (matchedFiles.length === 0) {
    return "Không tìm thấy tài liệu phù hợp trong cơ sở tri thức cục bộ.";
  }

  // Combine content from top 3 matched files, truncating if necessary to avoid token overflow
  let context = "";
  matchedFiles.slice(0, 3).forEach((match, index) => {
    context += `--- TÀI LIỆU THAM KHẢO ${index + 1}: ${match.fileName} ---\n`;
    // Take the whole file if short, or look for relevant paragraphs around keywords
    if (match.content.length < 3000) {
      context += match.content + "\n\n";
    } else {
      // Extract matches surrounding keywords
      const lines = match.content.split('\n');
      let capturedLines = new Set();
      lines.forEach((line, lineIndex) => {
        keywords.forEach(word => {
          if (line.toLowerCase().includes(word)) {
            // Grab some context lines around the match
            for (let i = Math.max(0, lineIndex - 3); i <= Math.min(lines.length - 1, lineIndex + 5); i++) {
              capturedLines.add(i);
            }
          }
        });
      });
      
      const sortedLineIndices = Array.from(capturedLines).sort((a, b) => a - b);
      let lastIndex = -2;
      sortedLineIndices.forEach(idx => {
        if (idx > lastIndex + 1) {
          context += "... \n";
        }
        context += lines[idx] + "\n";
        lastIndex = idx;
      });
      context += "\n";
    }
  });

  return context.substring(0, 8000); // limit to 8k chars
}

// Call Gemini API to solve the issue
function askGeminiToSolve(issue, context, callback) {
  if (!config.GEMINI_API_KEY) {
    console.log('[Server] No GEMINI_API_KEY configured. Fallback to Agent-Assisted mode.');
    callback(null);
    return;
  }

  console.log('[Gemini] Requesting solution from Gemini API...');
  
  const prompt = `Bạn là trợ lý ảo hỗ trợ vận hành hệ thống MES tại nhà máy Vinatech. Dưới đây là thông tin lỗi của người dùng báo cáo trong Zalo chat:
- Phòng chat: ${issue.chatRoom}
- Người báo cáo: ${issue.sender}
- Nội dung tin nhắn: "${issue.text}"
- Thời gian: ${issue.time} ngày ${issue.date}

Dưới đây là tài liệu tri thức liên quan thu thập được từ máy tính của bạn:
${context}

Nhiệm vụ của bạn:
1. Phân tích lỗi người dùng báo cáo dựa trên tài liệu tri thức.
2. Đề xuất phương án giải quyết cụ thể, ngắn gọn, chính xác bằng tiếng Việt.
3. Nếu cần chạy SQL để kiểm tra hoặc fix lỗi, hãy cung cấp mã SQL cụ thể và bọc trong khối giao dịch BEGIN TRAN ... ROLLBACK/COMMIT như quy định. Luôn thêm WITH(NOLOCK) khi query bảng lớn.
4. Chỉ cung cấp giải pháp kỹ thuật cụ thể trực tiếp hỗ trợ giải quyết vấn đề của người dùng, không trả lời lan man hay chào hỏi dài dòng. Định dạng câu trả lời bằng Markdown đẹp mắt.`;

  const requestBody = JSON.stringify({
    contents: [{
      parts: [{ text: prompt }]
    }]
  });

  // Call gemini-1.5-flash
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${config.GEMINI_API_KEY}`;
  
  const req = https.request(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(requestBody)
    }
  }, (res) => {
    let responseData = '';
    res.on('data', chunk => responseData += chunk);
    res.on('end', () => {
      try {
        const parsed = JSON.parse(responseData);
        if (parsed.candidates && parsed.candidates[0] && parsed.candidates[0].content && parsed.candidates[0].content.parts[0]) {
          const solution = parsed.candidates[0].content.parts[0].text;
          console.log('[Gemini] Solution successfully generated.');
          callback(solution);
        } else {
          console.error('[Gemini] Unexpected response structure:', responseData);
          callback(null);
        }
      } catch (e) {
        console.error('[Gemini] Error parsing response:', e.message);
        callback(null);
      }
    });
  });

  req.on('error', (e) => {
    console.error('[Gemini] HTTPS request error:', e.message);
    callback(null);
  });

  req.write(requestBody);
  req.end();
}

// Read issues list from file
function readIssues() {
  try {
    const data = fs.readFileSync(ISSUES_FILE, 'utf8');
    return JSON.parse(data);
  } catch (e) {
    return [];
  }
}

// Write issues list to file
function writeIssues(issues) {
  fs.writeFileSync(ISSUES_FILE, JSON.stringify(issues, null, 2), 'utf8');
}

// Start HTTP Server
const server = http.createServer((req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, corsHeaders);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);
  
  // API: GET /api/issues
  if (req.method === 'GET' && url.pathname === '/api/issues') {
    res.writeHead(200, corsHeaders);
    res.end(JSON.stringify(readIssues()));
    return;
  }

  // API: POST /api/issues (Submit crawled issues)
  if (req.method === 'POST' && url.pathname === '/api/issues') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const newIssues = JSON.parse(body);
        if (!Array.isArray(newIssues)) {
          res.writeHead(400, corsHeaders);
          res.end(JSON.stringify({ error: 'Body must be an array of issues' }));
          return;
        }

        let issues = readIssues();
        let addedCount = 0;

        newIssues.forEach(issue => {
          // Generate a unique ID for the issue based on content
          const uniqueString = `${issue.chatRoom}_${issue.sender}_${issue.text}_${issue.time}_${issue.date}`;
          const id = crypto.createHash('md5').update(uniqueString).digest('hex');

          // Check if it already exists
          const exists = issues.some(existing => existing.id === id);
          if (!exists) {
            const issueObject = {
              id: id,
              chatRoom: issue.chatRoom,
              sender: issue.sender,
              text: issue.text,
              time: issue.time,
              date: issue.date,
              status: 'crawled',
              solution: undefined,
              createdAt: new Date().toISOString()
            };
            
            issues.push(issueObject);
            addedCount++;

            // Standalone mode: Try to search KBs and call Gemini API immediately
            const kbContext = searchKnowledgeBase(issue.text);
            askGeminiToSolve(issueObject, kbContext, (solution) => {
              // Reload issues list in case it changed in the meantime
              let currentIssues = readIssues();
              const idx = currentIssues.findIndex(i => i.id === id);
              if (idx !== -1) {
                if (solution) {
                  currentIssues[idx].solution = solution;
                  currentIssues[idx].status = 'pending_approval';
                } else {
                  // If standalone Gemini fails, save context so that the Agent in IDE can use it
                  currentIssues[idx].kbContext = kbContext;
                }
                writeIssues(currentIssues);
              }
            });
          }
        });

        if (addedCount > 0) {
          writeIssues(issues);
        }

        res.writeHead(200, corsHeaders);
        res.end(JSON.stringify({ status: 'ok', addedCount }));
      } catch (err) {
        res.writeHead(400, corsHeaders);
        res.end(JSON.stringify({ error: 'Invalid JSON body', details: err.message }));
      }
    });
    return;
  }

  // API: POST /api/approve (Approve an issue)
  if (req.method === 'POST' && url.pathname === '/api/approve') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { id } = JSON.parse(body);
        let issues = readIssues();
        const idx = issues.findIndex(i => i.id === id);
        if (idx !== -1) {
          issues[idx].status = 'approved';
          writeIssues(issues);
          res.writeHead(200, corsHeaders);
          res.end(JSON.stringify({ status: 'ok', issue: issues[idx] }));
        } else {
          res.writeHead(404, corsHeaders);
          res.end(JSON.stringify({ error: 'Issue not found' }));
        }
      } catch (err) {
        res.writeHead(400, corsHeaders);
        res.end(JSON.stringify({ error: 'Invalid body' }));
      }
    });
    return;
  }

  // API: POST /api/sent (Mark issue as sent/resolved)
  if (req.method === 'POST' && url.pathname === '/api/sent') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { id } = JSON.parse(body);
        let issues = readIssues();
        const idx = issues.findIndex(i => i.id === id);
        if (idx !== -1) {
          issues[idx].status = 'resolved';
          writeIssues(issues);
          res.writeHead(200, corsHeaders);
          res.end(JSON.stringify({ status: 'ok', issue: issues[idx] }));
        } else {
          res.writeHead(404, corsHeaders);
          res.end(JSON.stringify({ error: 'Issue not found' }));
        }
      } catch (err) {
        res.writeHead(400, corsHeaders);
        res.end(JSON.stringify({ error: 'Invalid body' }));
      }
    });
    return;
  }

  // API: POST /api/reject (Reject / delete an issue)
  if (req.method === 'POST' && url.pathname === '/api/reject') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { id } = JSON.parse(body);
        let issues = readIssues();
        const idx = issues.findIndex(i => i.id === id);
        if (idx !== -1) {
          issues[idx].status = 'rejected';
          writeIssues(issues);
          res.writeHead(200, corsHeaders);
          res.end(JSON.stringify({ status: 'ok', issue: issues[idx] }));
        } else {
          res.writeHead(404, corsHeaders);
          res.end(JSON.stringify({ error: 'Issue not found' }));
        }
      } catch (err) {
        res.writeHead(400, corsHeaders);
        res.end(JSON.stringify({ error: 'Invalid body' }));
      }
    });
    return;
  }

  // Default Route: 404
  res.writeHead(404, corsHeaders);
  res.end(JSON.stringify({ error: 'Endpoint not found' }));
});

server.listen(PORT, () => {
  console.log(`[Server] Local server running at http://localhost:${PORT}`);
  console.log(`[Server] Issues data stored at ${ISSUES_FILE}`);
  console.log(`[Server] Configuration stored at ${CONFIG_FILE}`);
});
