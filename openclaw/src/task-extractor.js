// src/task-extractor.js - AI phân tích tin nhắn và extract tasks
import { gemini } from './gemini-client.js';
import { noteManager } from './note-manager.js';
import fs from 'fs-extra';
import { join } from 'path';

const SYSTEM_PROMPT = `Bạn là AI assistant chuyên phân tích tin nhắn và trích xuất các task cần làm.
Luôn trả lời bằng tiếng Việt.
Khi trích xuất task, hãy:
- Xác định rõ ràng từng task cụ thể
- Đánh giá mức độ ưu tiên (urgent/high/medium/low)
- Ước tính độ phức tạp (simple/moderate/complex)
- Xác định xem task có đủ thông tin để thực hiện không
- Nếu thiếu thông tin, ghi rõ cần hỏi thêm gì`;

export class TaskExtractor {
  
  // Phân tích notes và list ra tasks
  async extractTasksFromNotes(notesContent) {
    const prompt = `Phân tích nội dung tin nhắn sau và trích xuất TẤT CẢ các task, yêu cầu, công việc cần làm:

${notesContent}

Trả về JSON array với format sau (CHỈ JSON, không có text khác):
[
  {
    "title": "Tên ngắn gọn của task",
    "description": "Mô tả chi tiết task cần làm",
    "priority": "urgent|high|medium|low",
    "complexity": "simple|moderate|complex",
    "needsMoreInfo": true/false,
    "missingInfo": "Thông tin còn thiếu (nếu needsMoreInfo=true)",
    "suggestedActions": ["Hành động 1", "Hành động 2"],
    "source": "Tên người/group gửi"
  }
]

Nếu không có task nào, trả về: []`;

    try {
      const response = await gemini.chat(prompt, { 
        systemPrompt: SYSTEM_PROMPT,
        keyIndex: 0  // Orchestrator dùng key 0
      });
      
      // Parse JSON từ response
      const jsonMatch = response.match(/\[[\s\S]*\]/);
      if (!jsonMatch) {
        console.warn('[TaskExtractor] No JSON found in response');
        return [];
      }

      const tasks = JSON.parse(jsonMatch[0]);
      console.log(`[TaskExtractor] 🎯 Extracted ${tasks.length} tasks from notes`);
      return tasks;
    } catch (err) {
      console.error('[TaskExtractor] Error extracting tasks:', err.message);
      return [];
    }
  }

  // Tạo tasks trong hệ thống từ data đã extract
  async createTasksFromExtracted(extractedTasks) {
    const created = [];
    
    for (const taskData of extractedTasks) {
      const task = await noteManager.createTask({
        title: taskData.title,
        description: taskData.description,
        priority: taskData.priority || 'medium',
        complexity: taskData.complexity || 'moderate',
        needsMoreInfo: taskData.needsMoreInfo || false,
        missingInfo: taskData.missingInfo || null,
        suggestedActions: taskData.suggestedActions || [],
        source: taskData.source || 'Zalo',
        status: taskData.needsMoreInfo ? 'waiting_input' : 'pending',
      });
      created.push(task);

      // Bắn task sang file master cho Antigravity xử lý
      const targetFolder = 'C:\\Users\\User Vinatech.DESKTOP-RJJSEQU\\Desktop\\database';
      const mdPath = join(targetFolder, 'ZALO_MES_MASTER_TASKS.md');
      
      const timestamp = new Date().toLocaleString('vi-VN');
      const mdContent = `\n## [NEW] ${task.title} (ID: ${task.id})
**Ngày nhận**: ${timestamp}
**Nguồn**: ${task.source} | **Ưu tiên**: ${task.priority.toUpperCase()}

### 1. Yêu cầu từ Zalo:
${task.description}

### 2. Phương hướng giải pháp (Antigravity phân tích):
<!-- Antigravity: Lúc nhận được lệnh, hãy khảo sát hệ thống, điền plan giải quyết vào đây và đổi nhãn trên tiêu đề thành [WAITING_APPROVAL] -->
> (Chờ phân tích...)

### 3. Phê duyệt của Sếp:
- [ ] Duyệt làm (Approve)
- [ ] Từ chối (Reject)

### 4. Kết quả & Tin nhắn Zalo Draft:
<!-- Antigravity: Khi sếp tick vào [x] Duyệt làm, hãy thực hiện fix / tạo SQL. Sau đó viết lại quá trình làm và ĐẶC BIỆT soạn sẵn 1 đoạn tin nhắn Zalo phản hồi thật lịch sự, chuyên nghiệp dưới dạng Blockquote để sếp copy & paste nhấp gửi. Sau đó đổi nhãn thành [DONE] -->
> 

---
`;
      await fs.appendFile(mdPath, mdContent);
      console.log(`[TaskExtractor] 📤 Đã ghim thêm task [NEW] vào Master File tại Database`);
    }

    return created;
  }

  // Tóm tắt danh sách tasks để hiển thị cho user
  async summarizeTasks(tasks) {
    if (tasks.length === 0) return 'Không có task mới.';

    const taskList = tasks.map((t, i) => 
      `${i+1}. [${t.priority?.toUpperCase()}] ${t.title} - ${t.description?.slice(0,100)}`
    ).join('\n');

    const prompt = `Tóm tắt ngắn gọn danh sách ${tasks.length} task sau và đề xuất thứ tự xử lý:

${taskList}

Trả lời ngắn gọn, súc tích, dễ đọc.`;

    return await gemini.chat(prompt, { keyIndex: 0 });
  }
}

export const taskExtractor = new TaskExtractor();
