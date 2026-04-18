// src/gemini-client.js - Gemini AI client với key rotation
import { GoogleGenerativeAI } from '@google/generative-ai';
import { config } from './config.js';

class GeminiClient {
  constructor() {
    this.clients = config.gemini.keys.map(key => new GoogleGenerativeAI(key));
    this.currentIndex = 0;
    this.requestCounts = new Array(this.clients.length).fill(0);
  }

  // Round-robin key rotation cho multi-instance
  getNextClient() {
    const client = this.clients[this.currentIndex];
    this.requestCounts[this.currentIndex]++;
    this.currentIndex = (this.currentIndex + 1) % this.clients.length;
    return client;
  }

  // Lấy client theo index cụ thể (cho parallel agents)
  getClientByIndex(index) {
    return this.clients[index % this.clients.length];
  }

  async chat(prompt, options = {}) {
    const { keyIndex = null, systemPrompt = null, retries = 2 } = options;
    const client = keyIndex !== null 
      ? this.getClientByIndex(keyIndex) 
      : this.getNextClient();

    const model = client.getGenerativeModel({ 
      model: options.model || config.gemini.model,
      systemInstruction: systemPrompt,
    });

    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        const result = await model.generateContent(prompt);
        return result.response.text();
      } catch (err) {
        if (attempt === retries) throw err;
        console.warn(`[Gemini] Retry ${attempt + 1}/${retries}: ${err.message}`);
        await new Promise(r => setTimeout(r, 2000 * (attempt + 1)));
      }
    }
  }

  getStats() {
    return this.requestCounts.map((count, i) => ({
      keyIndex: i,
      requests: count,
      keyPreview: config.gemini.keys[i]?.slice(0, 10) + '...',
    }));
  }
}

export const gemini = new GeminiClient();
