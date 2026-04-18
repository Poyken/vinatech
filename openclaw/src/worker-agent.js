// src/worker-agent.js - Worker AI agent xử lý task độc lập
import { gemini } from './gemini-client.js';
import { noteManager } from './note-manager.js';
import { EventEmitter } from 'events';

const WORKER_SYSTEM_PROMPT = `Bạn là AI worker chuyên xử lý các task được giao.
Hãy:
1. Phân tích task
2. Lên kế hoạch từng bước
3. Thực hiện từng bước
4. Nếu cần thêm thông tin từ user, báo rõ cần gì
5. Khi xong, báo cáo kết quả chi tiết

Luôn trả lời bằng tiếng Việt. Trả lời súc tích, đúng trọng tâm.`;

export class WorkerAgent extends EventEmitter {
  constructor(task, keyIndex = 0) {
    super();
    this.task = task;
    this.keyIndex = keyIndex; // Dùng key khác nhau cho parallel agents
    this.status = 'idle';
    this.messages = []; // Chat history với AI
    this.startTime = null;
  }

  async run() {
    this.status = 'running';
    this.startTime = Date.now();
    
    await noteManager.updateTask(this.task.id, { status: 'in_progress' });
    this.emit('started', { taskId: this.task.id, title: this.task.title });
    
    console.log(`[Worker:${this.keyIndex}] 🔄 Starting task: ${this.task.title}`);

    try {
      // Bước 1: Phân tích task và lên kế hoạch
      const plan = await this.analyzAndPlan();
      
      if (plan.needsUserInput) {
        // AI cần thêm thông tin từ user
        await noteManager.updateTask(this.task.id, { 
          status: 'waiting_input',
          question: plan.question,
          partialPlan: plan.steps,
        });
        
        this.emit('needs_input', {
          taskId: this.task.id,
          title: this.task.title,
          question: plan.question,
        });
        
        console.log(`[Worker:${this.keyIndex}] ❓ Task needs user input: ${plan.question}`);
        return { status: 'waiting_input', question: plan.question };
      }

      // Bước 2: Thực hiện từng bước
      const results = [];
      for (const step of plan.steps) {
        console.log(`[Worker:${this.keyIndex}]   → Step: ${step}`);
        const stepResult = await this.executeStep(step, results);
        results.push({ step, result: stepResult });
        
        // Cập nhật progress
        await noteManager.updateTask(this.task.id, { 
          progress: `${results.length}/${plan.steps.length} steps`,
          lastStep: step,
        });
      }

      // Bước 3: Tổng hợp kết quả
      const finalReport = await this.synthesizeResults(results);
      const duration = Math.round((Date.now() - this.startTime) / 1000);

      await noteManager.updateTask(this.task.id, { 
        status: 'done',
        result: finalReport,
        duration: `${duration}s`,
      });

      this.emit('completed', {
        taskId: this.task.id,
        title: this.task.title,
        report: finalReport,
        duration,
      });

      console.log(`[Worker:${this.keyIndex}] ✅ Task done in ${duration}s: ${this.task.title}`);
      return { status: 'done', report: finalReport };

    } catch (err) {
      await noteManager.updateTask(this.task.id, { 
        status: 'failed',
        error: err.message,
      });

      this.emit('failed', {
        taskId: this.task.id,
        title: this.task.title,
        error: err.message,
      });

      console.error(`[Worker:${this.keyIndex}] ❌ Task failed: ${err.message}`);
      return { status: 'failed', error: err.message };
    }
  }

  async analyzAndPlan() {
    const prompt = `Task được giao:
**Tiêu đề**: ${this.task.title}
**Mô tả**: ${this.task.description}
**Độ ưu tiên**: ${this.task.priority}
**Độ phức tạp**: ${this.task.complexity}
**Nguồn**: ${this.task.source}
${this.task.suggestedActions?.length ? `**Gợi ý**: ${this.task.suggestedActions.join(', ')}` : ''}

Hãy phân tích task này và trả về JSON:
{
  "canProceed": true/false,
  "needsUserInput": true/false,
  "question": "Câu hỏi cần hỏi user (nếu needsUserInput=true)",
  "steps": ["Bước 1", "Bước 2", "Bước 3"],
  "estimatedTime": "X phút"
}`;

    const response = await gemini.chat(prompt, { 
      systemPrompt: WORKER_SYSTEM_PROMPT,
      keyIndex: this.keyIndex,
    });

    try {
      const jsonMatch = response.match(/\{[\s\S]*\}/);
      return JSON.parse(jsonMatch[0]);
    } catch {
      // Fallback nếu không parse được JSON
      return {
        canProceed: true,
        needsUserInput: false,
        steps: ['Phân tích task', 'Thực hiện task', 'Báo cáo kết quả'],
      };
    }
  }

  async executeStep(step, previousResults) {
    const context = previousResults.length > 0 
      ? `Kết quả các bước trước:\n${previousResults.map(r => `- ${r.step}: ${r.result}`).join('\n')}\n\n`
      : '';

    const prompt = `${context}Thực hiện bước sau cho task "${this.task.title}":

**Bước cần làm**: ${step}
**Context task**: ${this.task.description}

Thực hiện bước này và trả lời kết quả cụ thể, ngắn gọn.`;

    return await gemini.chat(prompt, { 
      systemPrompt: WORKER_SYSTEM_PROMPT,
      keyIndex: this.keyIndex,
    });
  }

  async synthesizeResults(results) {
    const stepsText = results.map((r, i) => 
      `**Bước ${i+1}**: ${r.step}\n${r.result}`
    ).join('\n\n');

    const prompt = `Task "${this.task.title}" đã hoàn thành.

Các bước đã thực hiện:
${stepsText}

Hãy tổng hợp thành báo cáo kết quả ngắn gọn, rõ ràng cho user.`;

    return await gemini.chat(prompt, { 
      systemPrompt: WORKER_SYSTEM_PROMPT,
      keyIndex: this.keyIndex,
    });
  }

  // Nhận thêm thông tin từ user và tiếp tục
  async continueWithUserInput(userAnswer) {
    this.task.userAnswer = userAnswer;
    console.log(`[Worker:${this.keyIndex}] 📨 Got user answer, continuing task...`);
    
    await noteManager.updateTask(this.task.id, { 
      userAnswer,
      status: 'in_progress',
    });

    // Tiếp tục xử lý với câu trả lời của user
    const prompt = `Task: ${this.task.title}
Câu hỏi đã hỏi user: ${this.task.question}
Câu trả lời của user: ${userAnswer}

Bây giờ hãy tiếp tục và hoàn thành task với thông tin này.`;

    const result = await gemini.chat(prompt, { 
      systemPrompt: WORKER_SYSTEM_PROMPT,
      keyIndex: this.keyIndex,
    });

    await noteManager.updateTask(this.task.id, { 
      status: 'done',
      result,
    });

    this.emit('completed', {
      taskId: this.task.id,
      title: this.task.title,
      report: result,
    });

    return result;
  }
}
