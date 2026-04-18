// src/main.js - Entry point với interactive CLI
import { Orchestrator } from './orchestrator.js';
import { config } from './config.js';
import chalk from 'chalk';
import readline from 'readline';

const orchestrator = new Orchestrator();

// Interactive CLI để user trả lời AI
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function printBanner() {
  console.log(chalk.cyan(`
╔═══════════════════════════════════════════╗
║     🦞 ZALO AI TASK SYSTEM v1.0           ║
║     Multi-Agent · Gemini Flash            ║
╚═══════════════════════════════════════════╝
  `));
  console.log(chalk.gray('Commands:'));
  console.log(chalk.gray('  check           - Kiểm tra Zalo ngay'));
  console.log(chalk.gray('  status          - Xem trạng thái'));
  console.log(chalk.gray('  tasks           - Danh sách tasks'));
  console.log(chalk.gray('  report          - Tạo báo cáo'));
  console.log(chalk.gray('  answer <id> <text> - Trả lời câu hỏi của AI'));
  console.log(chalk.gray('  test            - Test với mock data'));
  console.log(chalk.gray('  quit            - Thoát\n'));
}

async function processCommand(input) {
  const parts = input.trim().split(' ');
  const cmd = parts[0]?.toLowerCase();

  switch(cmd) {
    case 'check':
      await orchestrator.runCycle();
      break;

    case 'status':
      orchestrator.printStatus();
      break;

    case 'tasks': {
      const { noteManager } = await import('./note-manager.js');
      const tasks = await noteManager.getAllTasks();
      if (tasks.length === 0) {
        console.log(chalk.gray('Chưa có task nào.'));
      } else {
        console.log(chalk.yellow(`\n📋 Tất cả tasks (${tasks.length}):`));
        tasks.forEach(t => {
          const icon = { done:'✅', failed:'❌', in_progress:'🔄', waiting_input:'❓', pending:'⏳' }[t.status] || '•';
          console.log(`  ${icon} [${t.priority}] ${t.title} (${t.status})`);
          if (t.status === 'waiting_input') {
            console.log(chalk.yellow(`     ❓ ${t.question || t.missingInfo}`));
            console.log(chalk.yellow(`     → answer ${t.id} [câu trả lời]`));
          }
        });
      }
      break;
    }

    case 'report':
      await orchestrator.generateReport();
      console.log(chalk.green('✅ Báo cáo đã được lưu vào workspace/reports/'));
      break;

    case 'answer': {
      const taskId = parts[1];
      const answer = parts.slice(2).join(' ');
      if (!taskId || !answer) {
        console.log(chalk.red('Usage: answer <task-id> <câu trả lời>'));
        break;
      }
      console.log(chalk.cyan(`📨 Gửi câu trả lời đến task ${taskId}...`));
      const result = await orchestrator.answerQuestion(taskId, answer);
      console.log(chalk.green('\n✅ AI đã xử lý xong:'));
      console.log(result);
      break;
    }

    case 'test':
      await runTest();
      break;

    case 'quit':
    case 'exit':
      console.log(chalk.yellow('👋 Đang tắt hệ thống...'));
      await orchestrator.generateReport();
      process.exit(0);

    case '':
      break;

    default:
      console.log(chalk.red(`❓ Không hiểu lệnh: ${cmd}. Gõ 'status' để bắt đầu.`));
  }
}

async function runTest() {
  console.log(chalk.cyan('\n🧪 Chạy test với dữ liệu mẫu...\n'));
  
  const { noteManager } = await import('./note-manager.js');
  const { taskExtractor } = await import('./task-extractor.js');

  // Mock data tin nhắn Zalo
  const mockMessages = [
    { sender: 'Nguyễn Văn A', text: 'Anh ơi, check giúp em máy tính phòng B203 bị mất mạng từ sáng', isSelf: false },
    { sender: 'Nguyễn Văn A', text: 'Và laptop của chị Hoa cũng cần cài lại driver', isSelf: false },
    { sender: 'Me', text: 'Ok để anh check', isSelf: true },
    { sender: 'Trần Thị B', text: 'Nhờ anh update phần mềm MES trên máy chủ lên version mới nhé', isSelf: false },
    { sender: 'Trần Thị B', text: 'Và backup database trước khi update', isSelf: false },
  ];

  console.log(chalk.gray('1. Takenote tin nhắn mẫu...'));
  await noteManager.takenote('Test Group', mockMessages);

  console.log(chalk.gray('2. Extract tasks bằng AI...'));
  const notes = await noteManager.getTodayNotes();
  const extracted = await taskExtractor.extractTasksFromNotes(notes);
  
  console.log(chalk.green(`\n✅ AI trích xuất được ${extracted.length} tasks:`));
  extracted.forEach((t, i) => {
    console.log(chalk.yellow(`  ${i+1}. [${t.priority}] ${t.title}`));
    console.log(chalk.gray(`     ${t.description}`));
    if (t.needsMoreInfo) console.log(chalk.red(`     ⚠️  Cần: ${t.missingInfo}`));
  });

  console.log(chalk.gray('\n3. Tạo tasks trong hệ thống...'));
  const tasks = await taskExtractor.createTasksFromExtracted(extracted);
  console.log(chalk.green(`✅ Đã tạo ${tasks.length} tasks`));

  // Spawn worker cho 1 task đơn giản để demo
  const readyTask = tasks.find(t => !t.needsMoreInfo);
  if (readyTask) {
    const { WorkerAgent } = await import('./worker-agent.js');
    console.log(chalk.cyan(`\n🚀 Demo worker xử lý task: "${readyTask.title}"...`));
    
    const worker = new WorkerAgent(readyTask, 0);
    worker.on('completed', d => {
      console.log(chalk.green(`\n✅ Worker done! Kết quả:`));
      console.log(d.report);
    });
    worker.on('needs_input', d => {
      console.log(chalk.yellow(`\n❓ Worker cần thêm info: ${d.question}`));
    });
    
    await worker.run();
  }

  console.log(chalk.cyan('\n✅ Test hoàn tất! Gõ "tasks" để xem danh sách.'));
}

// === MAIN ===
async function main() {
  printBanner();

  // Khởi động
  await orchestrator.initialize();

  // Bắt đầu scheduler tự động
  orchestrator.startScheduler();

  // Chạy 1 lần ngay khi khởi động
  console.log(chalk.cyan('🔍 Kiểm tra Zalo lần đầu...'));
  await orchestrator.runCycle().catch(err => {
    console.log(chalk.yellow(`⚠️  Bỏ qua lỗi khởi động: ${err.message}`));
  });

  // Interactive prompt
  const prompt = () => {
    rl.question(chalk.cyan('\n> '), async (input) => {
      await processCommand(input).catch(err => {
        console.error(chalk.red(`Lỗi: ${err.message}`));
      });
      prompt(); // Tiếp tục
    });
  };

  prompt();

  // Graceful shutdown
  process.on('SIGINT', async () => {
    console.log(chalk.yellow('\n\n👋 Đang tắt...'));
    await orchestrator.generateReport();
    process.exit(0);
  });
}

main().catch(err => {
  console.error(chalk.red('Fatal error:'), err);
  process.exit(1);
});
