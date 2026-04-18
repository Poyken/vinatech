// src/orchestrator.js - Điều phối toàn bộ hệ thống multi-agent
import { ZaloReader } from './zalo-reader.js';
import { noteManager } from './note-manager.js';
import { taskExtractor } from './task-extractor.js';
import { WorkerAgent } from './worker-agent.js';
import { gemini } from './gemini-client.js';
import { config } from './config.js';
import cron from 'node-cron';
import chalk from 'chalk';
import dayjs from 'dayjs';

export class Orchestrator {
  constructor() {
    this.reader = new ZaloReader();
    this.activeWorkers = new Map(); // taskId -> WorkerAgent
    this.pendingQuestions = []; // Tasks đang chờ user trả lời
    this.isRunning = false;
    this.stats = {
      totalTasksCreated: 0,
      totalTasksDone: 0,
      totalTasksFailed: 0,
      sessionsProcessed: 0,
    };
  }

  async initialize() {
    console.log(chalk.cyan('\n🦞 Zalo AI Task System - Khởi động...'));
    console.log(chalk.gray(`  Gemini keys: ${config.gemini.keys.length}`));
    console.log(chalk.gray(`  Max workers: ${config.workers.maxConcurrent}`));
    console.log(chalk.gray(`  Check interval: ${config.intervals.checkMinutes} phút`));

    // Connect Zalo
    const connected = await this.reader.connect();
    if (!connected) {
      console.log(chalk.yellow('\n⚠️  Chạy ở chế độ OFFLINE (không có Zalo Chrome)'));
      console.log(chalk.yellow('   Restart Chrome với: --remote-debugging-port=9222'));
    }

    this.isRunning = true;
    return connected;
  }

  // === VÒNG LẶP CHÍNH ===
  async runCycle() {
    if (!this.isRunning) return;
    
    const timestamp = dayjs().format('HH:mm:ss');
    console.log(chalk.gray(`\n[${timestamp}] ⏰ Bắt đầu chu kỳ kiểm tra...`));

    try {
      // 1. Đọc Zalo
      const newMessages = await this.fetchZaloMessages();
      
      if (newMessages.length === 0) {
        console.log(chalk.gray('  Không có tin nhắn mới.'));
        return;
      }

      // 2. Takenote
      const notesPath = await this.takenoteAll(newMessages);
      
      // 3. Extract tasks
      const notes = await noteManager.getTodayNotes();
      const extracted = await taskExtractor.extractTasksFromNotes(notes);
      
      if (extracted.length === 0) {
        console.log(chalk.gray('  Không có task mới trong tin nhắn.'));
        return;
      }

      // 4. Tạo tasks trong hệ thống
      const tasks = await taskExtractor.createTasksFromExtracted(extracted);
      this.stats.totalTasksCreated += tasks.length;

      // 5. Hiển thị task list
      await this.displayTaskList(tasks);

      // 6. Quét file xem có task nào Antigravity đã làm xong ([DONE]) để nháp tin nhắn Zalo
      await this.scanMasterTasksAndDraftZalo();

    } catch (err) {
      console.error(chalk.red(`[Orchestrator] Cycle error: ${err.message}`));
    }
  }

  async scanMasterTasksAndDraftZalo() {
    const fs = await import('fs-extra');
    const { join } = await import('path');
    const masterFilePath = 'C:\\Users\\User Vinatech.DESKTOP-RJJSEQU\\Desktop\\database\\ZALO_MES_MASTER_TASKS.md';
    
    if (!await fs.pathExists(masterFilePath)) return;

    let content = await fs.readFile(masterFilePath, 'utf8');
    let hasChanges = false;

    // Regex quét cấu trúc task có nhãn [DONE] và lấy đoạn blockquote ở mục Zalo Draft
    // ### 4. Kết quả & Tin nhắn Zalo Draft:
    // > (tin nháp)
    const regex = /## \[DONE\] (.*) \(ID: (.*)\)\n\*\*Ngày nhận\*\*: .*\n\*\*Nguồn\*\*: (.*) \|.*\n[\s\S]*?### 4\. Kết quả & Tin nhắn Zalo Draft:\n[\s\S]*?> ([\s\S]*?)\n\n---/g;
    
    let match;
    while ((match = regex.exec(content)) !== null) {
      const title = match[1];
      const taskId = match[2];
      const source = match[3];
      const draftText = match[4].trim();

      // Rút trích tên group/người gửi từ chuỗi "(Test Group)"
      const senderName = source.includes('(') ? source.substring(source.indexOf('(')+1, source.indexOf(')')) : source.trim();
      
      console.log(chalk.cyan(`\n[Orchestrator] ✍️ Thấy task [DONE] từ IDE! Lấy draft message để soạn lên Zalo cho: ${senderName}`));
      
      // Gọi hàm nháp tin (nhập văn bản nhưng KHÔNG bấm nút Gửi)
      const drafted = await this.reader.draftMessage(senderName, draftText);
      
      if (drafted) {
        // Đổi [DONE] thành [REPORTED] để lần quét sau bỏ qua
        content = content.replace(`## [DONE] ${title} (ID: ${taskId})`, `## [REPORTED] ${title} (ID: ${taskId})`);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await fs.writeFile(masterFilePath, content);
      console.log(chalk.green(`[Orchestrator] ✅ Cập nhật file Master: Chuyển [DONE] thành [REPORTED]`));
    }
  }

  async fetchZaloMessages() {
    if (!this.reader.connected) return [];
    
    const conversations = await this.reader.getConversationList();
    const newMessages = [];

    // Chỉ lấy conversations có tin nhắn mới
    const unread = conversations.filter(c => c.hasUnread);
    console.log(chalk.blue(`  📱 Zalo: ${conversations.length} hội thoại, ${unread.length} có tin mới`));

    // Load state để biết tin nào đã đọc
    const lastProcessed = await noteManager.loadState('lastProcessedConversations') || {};

    for (const conv of conversations.slice(0, 5)) { // Check 5 conv đầu
      await this.reader.openConversation(conv.index);
      const messages = await this.reader.getMessagesFromCurrentConv(20);
      
      // Filter tin nhắn mới (chưa xử lý)
      const lastCount = lastProcessed[conv.name] || 0;
      if (messages.length > lastCount) {
        const newMsgs = messages.slice(lastCount);
        if (newMsgs.length > 0) {
          newMessages.push({ conversation: conv, messages: newMsgs });
          lastProcessed[conv.name] = messages.length;
        }
      }
    }

    await noteManager.saveState('lastProcessedConversations', lastProcessed);
    return newMessages;
  }

  async takenoteAll(newMessages) {
    for (const { conversation, messages } of newMessages) {
      await noteManager.takenote(conversation.name, messages);
    }
    console.log(chalk.green(`  📝 Ghi chú ${newMessages.length} cuộc trò chuyện`));
  }

  async displayTaskList(tasks) {
    console.log(chalk.yellow(`\n  📋 ${tasks.length} TASK MỚI:`));
    tasks.forEach((t, i) => {
      const priority = {
        urgent: chalk.red('🔴 URGENT'),
        high: chalk.yellow('🟡 HIGH'),
        medium: chalk.blue('🔵 MEDIUM'),
        low: chalk.gray('⚪ LOW'),
      }[t.priority] || t.priority;
      
      console.log(`  ${i+1}. ${priority} ${t.title}`);
      if (t.needsMoreInfo) {
        console.log(chalk.yellow(`     ⚠️  Thiếu thông tin: ${t.missingInfo}`));
      }
    });
  }

  async spawnWorkers(tasks) {
    // Chỉ xử lý tasks không cần thêm info
    const readyTasks = tasks.filter(t => !t.needsMoreInfo);
    const waitingTasks = tasks.filter(t => t.needsMoreInfo);

    if (waitingTasks.length > 0) {
      console.log(chalk.yellow(`\n  ❓ ${waitingTasks.length} task cần bạn cung cấp thêm thông tin:`));
      waitingTasks.forEach((t, i) => {
        console.log(chalk.yellow(`  ${i+1}. "${t.title}": ${t.missingInfo}`));
        this.pendingQuestions.push(t);
      });
    }

    if (readyTasks.length === 0) return;

    console.log(chalk.cyan(`\n  🚀 Spawn ${readyTasks.length} worker agents...`));

    // Giới hạn concurrent workers
    const chunks = this.chunkArray(readyTasks, config.workers.maxConcurrent);
    
    for (const chunk of chunks) {
      const promises = chunk.map((task, i) => {
        const keyIndex = i % config.gemini.keys.length;
        const worker = new WorkerAgent(task, keyIndex);
        this.activeWorkers.set(task.id, worker);

        // Event listeners
        worker.on('completed', (data) => {
          this.stats.totalTasksDone++;
          this.activeWorkers.delete(data.taskId);
          console.log(chalk.green(`\n  ✅ XONG: ${data.title} (${data.duration}s)`));
          console.log(chalk.gray(`     ${data.report?.slice(0, 200)}...`));
        });

        worker.on('needs_input', (data) => {
          console.log(chalk.yellow(`\n  ❓ CẦN BẠN TRẢ LỜI: ${data.title}`));
          console.log(chalk.yellow(`     → ${data.question}`));
          console.log(chalk.yellow(`     (Gõ: answer ${data.taskId} [câu trả lời])`));
        });

        worker.on('failed', (data) => {
          this.stats.totalTasksFailed++;
          this.activeWorkers.delete(data.taskId);
          console.log(chalk.red(`\n  ❌ THẤT BẠI: ${data.title} - ${data.error}`));
        });

        return worker.run();
      });

      // Chạy song song tất cả trong chunk
      await Promise.allSettled(promises);
    }
  }

  // User trả lời câu hỏi của AI
  async answerQuestion(taskId, answer) {
    const worker = this.activeWorkers.get(taskId);
    if (worker) {
      return await worker.continueWithUserInput(answer);
    }

    // Worker đã stop, tạo lại
    const tasks = await noteManager.getAllTasks();
    const task = tasks.find(t => t.id === taskId);
    if (!task) throw new Error(`Task ${taskId} not found`);

    const newWorker = new WorkerAgent(task, 0);
    this.activeWorkers.set(taskId, newWorker);
    return await newWorker.continueWithUserInput(answer);
  }

  // Tạo báo cáo tổng hợp
  async generateReport() {
    const tasks = await noteManager.getAllTasks();
    const today = dayjs().format('YYYY-MM-DD');
    const todayTasks = tasks.filter(t => t.createdAt?.startsWith(today));

    const stats = {
      total: todayTasks.length,
      done: todayTasks.filter(t => t.status === 'done').length,
      inProgress: todayTasks.filter(t => t.status === 'in_progress').length,
      waitingInput: todayTasks.filter(t => t.status === 'waiting_input').length,
      failed: todayTasks.filter(t => t.status === 'failed').length,
    };

    const reportContent = `# Báo Cáo Hệ Thống AI - ${today}

## Thống Kê
- Tổng tasks: **${stats.total}**
- ✅ Hoàn thành: **${stats.done}**
- 🔄 Đang xử lý: **${stats.inProgress}**
- ❓ Chờ thông tin: **${stats.waitingInput}**
- ❌ Thất bại: **${stats.failed}**
- Sessions xử lý: **${this.stats.sessionsProcessed}**

## Chi Tiết Tasks

${todayTasks.map(t => `### ${t.status === 'done' ? '✅' : t.status === 'failed' ? '❌' : '🔄'} ${t.title}
- **ID**: ${t.id}
- **Priority**: ${t.priority}
- **Status**: ${t.status}
- **Source**: ${t.source}
${t.result ? `- **Kết quả**: ${t.result?.slice(0, 300)}` : ''}
${t.error ? `- **Lỗi**: ${t.error}` : ''}
`).join('\n')}

## Gemini API Stats
${gemini.getStats().map(s => `- Key ${s.keyIndex}: ${s.requests} requests (${s.keyPreview})`).join('\n')}
`;

    return await noteManager.saveReport(reportContent);
  }

  // Bắt đầu cron job tự động
  startScheduler() {
    const interval = config.intervals.checkMinutes;
    const cronExpr = `*/${interval} * * * *`;
    
    console.log(chalk.cyan(`\n⏰ Tự động check mỗi ${interval} phút`));
    
    cron.schedule(cronExpr, async () => {
      await this.runCycle();
    });
  }

  chunkArray(arr, size) {
    const chunks = [];
    for (let i = 0; i < arr.length; i += size) {
      chunks.push(arr.slice(i, i + size));
    }
    return chunks;
  }

  printStatus() {
    console.log(chalk.cyan('\n📊 STATUS:'));
    console.log(`  Tasks created: ${this.stats.totalTasksCreated}`);
    console.log(`  Tasks done: ${this.stats.totalTasksDone}`);
    console.log(`  Tasks failed: ${this.stats.totalTasksFailed}`);
    console.log(`  Active workers: ${this.activeWorkers.size}`);
    console.log(`  Pending questions: ${this.pendingQuestions.length}`);
    console.log(`  Gemini keys: ${config.gemini.keys.length}`);
  }
}
