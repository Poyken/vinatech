// src/config.js - Cấu hình trung tâm
import 'dotenv/config';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');

export const config = {
  gemini: {
    keys: [
      process.env.GEMINI_API_KEY_1,
      process.env.GEMINI_API_KEY_2,
    ].filter(Boolean),
    model: process.env.GEMINI_MODEL || 'gemini-2.0-flash',
  },
  chrome: {
    debugPort: parseInt(process.env.CHROME_DEBUG_PORT || '9222'),
    wsEndpoint: `http://localhost:${process.env.CHROME_DEBUG_PORT || '9222'}`,
  },
  zalo: {
    url: process.env.ZALO_URL || 'https://chat.zalo.me',
  },
  intervals: {
    checkMinutes: parseInt(process.env.CHECK_INTERVAL_MINUTES || '5'),
  },
  paths: {
    root: ROOT,
    notes: join(ROOT, process.env.NOTES_DIR || 'workspace/notes'),
    tasks: join(ROOT, process.env.TASKS_DIR || 'workspace/tasks'),
    reports: join(ROOT, process.env.REPORTS_DIR || 'workspace/reports'),
    state: join(ROOT, 'workspace/.state'),
  },
  gateway: {
    port: parseInt(process.env.GATEWAY_PORT || '3099'),
  },
  workers: {
    maxConcurrent: parseInt(process.env.MAX_WORKERS || '3'),
  },
};
