// src/note-manager.js - Quản lý ghi chú và tasks
import fs from 'fs-extra';
import { join } from 'path';
import dayjs from 'dayjs';
import { config } from './config.js';
import { v4 as uuidv4 } from 'uuid';

export class NoteManager {
  constructor() {
    this.init();
  }

  async init() {
    await fs.ensureDir(config.paths.notes);
    await fs.ensureDir(config.paths.tasks);
    await fs.ensureDir(config.paths.reports);
    await fs.ensureDir(config.paths.state);
  }

  // Ghi chú tin nhắn Zalo vào file markdown theo ngày
  async takenote(conversationName, messages, source = 'zalo') {
    const today = dayjs().format('YYYY-MM-DD');
    const notePath = join(config.paths.notes, `${today}.md`);
    
    const timestamp = dayjs().format('HH:mm:ss');
    const header = `\n## [${timestamp}] Từ: ${conversationName} (${source})\n\n`;
    const content = messages
      .map(m => `**${m.sender}**: ${m.text}`)
      .join('\n') + '\n';

    await fs.appendFile(notePath, header + content + '\n---\n');
    console.log(`[NoteManager] 📝 Noted ${messages.length} messages from "${conversationName}"`);
    return notePath;
  }

  // Lấy notes của ngày hôm nay
  async getTodayNotes() {
    const today = dayjs().format('YYYY-MM-DD');
    const notePath = join(config.paths.notes, `${today}.md`);
    
    if (await fs.pathExists(notePath)) {
      return await fs.readFile(notePath, 'utf8');
    }
    return '';
  }

  // Tạo task mới
  async createTask(taskData) {
    const id = `task-${Date.now()}-${uuidv4().slice(0, 6)}`;
    const task = {
      id,
      createdAt: new Date().toISOString(),
      status: 'pending', // pending | in_progress | waiting_input | done | failed
      priority: 'medium', // low | medium | high | urgent
      ...taskData,
      history: [],
    };

    const taskPath = join(config.paths.tasks, `${id}.json`);
    await fs.writeJson(taskPath, task, { spaces: 2 });
    console.log(`[NoteManager] 📋 Task created: ${id} - ${task.title}`);
    return task;
  }

  // Cập nhật trạng thái task
  async updateTask(taskId, updates) {
    const taskPath = join(config.paths.tasks, `${taskId}.json`);
    
    if (!await fs.pathExists(taskPath)) {
      throw new Error(`Task ${taskId} not found`);
    }

    const task = await fs.readJson(taskPath);
    const updated = {
      ...task,
      ...updates,
      updatedAt: new Date().toISOString(),
      history: [
        ...(task.history || []),
        { 
          timestamp: new Date().toISOString(), 
          change: JSON.stringify(updates).slice(0, 200) 
        }
      ],
    };

    await fs.writeJson(taskPath, updated, { spaces: 2 });
    return updated;
  }

  // Lấy tất cả tasks
  async getAllTasks() {
    const files = await fs.readdir(config.paths.tasks);
    const tasks = [];
    
    for (const file of files.filter(f => f.endsWith('.json'))) {
      try {
        const task = await fs.readJson(join(config.paths.tasks, file));
        tasks.push(task);
      } catch (e) {
        // Skip corrupt files
      }
    }

    return tasks.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  }

  // Lấy tasks theo status
  async getTasksByStatus(status) {
    const all = await this.getAllTasks();
    return all.filter(t => t.status === status);
  }

  // Lưu báo cáo
  async saveReport(content, name = null) {
    const timestamp = dayjs().format('YYYY-MM-DD_HH-mm');
    const reportName = name || `report-${timestamp}.md`;
    const reportPath = join(config.paths.reports, reportName);
    await fs.writeFile(reportPath, content);
    console.log(`[NoteManager] 📊 Report saved: ${reportPath}`);
    return reportPath;
  }

  // Lưu state (để resume sau khi restart)
  async saveState(key, value) {
    const statePath = join(config.paths.state, `${key}.json`);
    await fs.writeJson(statePath, { key, value, updatedAt: new Date().toISOString() });
  }

  async loadState(key) {
    const statePath = join(config.paths.state, `${key}.json`);
    if (await fs.pathExists(statePath)) {
      const data = await fs.readJson(statePath);
      return data.value;
    }
    return null;
  }
}

export const noteManager = new NoteManager();
