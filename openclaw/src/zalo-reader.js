// src/zalo-reader.js - Đọc tin nhắn Zalo từ Chrome đang mở
import { chromium } from 'playwright';
import { config } from './config.js';

export class ZaloReader {
  constructor() {
    this.browser = null;
    this.page = null;
    this.connected = false;
  }

  async connect() {
    try {
      console.log(`[ZaloReader] Connecting to Chrome on port ${config.chrome.debugPort}...`);
      this.browser = await chromium.connectOverCDP(config.chrome.wsEndpoint);
      
      const contexts = this.browser.contexts();
      if (contexts.length === 0) throw new Error('No browser contexts found');
      
      const context = contexts[0];
      const pages = context.pages();
      
      // Tìm tab Zalo
      this.page = pages.find(p => p.url().includes('chat.zalo.me')) || null;
      
      if (!this.page) {
        // Mở Zalo nếu chưa mở
        console.log('[ZaloReader] Zalo tab not found, opening...');
        this.page = await context.newPage();
        await this.page.goto(config.zalo.url, { waitUntil: 'networkidle' });
        await this.page.waitForTimeout(3000);
      }

      this.connected = true;
      const title = await this.page.title();
      console.log(`[ZaloReader] ✅ Connected to Zalo. Page: "${title}"`);
      return true;
    } catch (err) {
      console.error(`[ZaloReader] ❌ Cannot connect to Chrome: ${err.message}`);
      console.error('[ZaloReader] Make sure Chrome is running with: --remote-debugging-port=9222');
      return false;
    }
  }

  async getConversationList() {
    if (!this.connected) throw new Error('Not connected');
    
    try {
      // Lấy danh sách hội thoại từ sidebar Zalo
      await this.page.waitForSelector('[class*="conv-list"], [class*="ConvList"], .list-conversation', 
        { timeout: 10000 }).catch(() => null);

      const conversations = await this.page.evaluate(() => {
        // Zalo web DOM selectors
        const items = document.querySelectorAll(
          '[class*="conv-item"], [class*="ConvItem"], [class*="conversation-item"], li[class*="conv"]'
        );
        
        return Array.from(items).slice(0, 20).map((item, index) => {
          const nameEl = item.querySelector(
            '[class*="DisplayName"], [class*="conv-name"], [class*="name"], h4, h3'
          );
          const previewEl = item.querySelector(
            '[class*="LastMessage"], [class*="preview"], [class*="last-msg"], p'
          );
          const timeEl = item.querySelector(
            '[class*="Time"], [class*="time"], time, [class*="timestamp"]'
          );
          const unreadEl = item.querySelector(
            '[class*="unread"], [class*="badge"], [class*="count"]'
          );

          return {
            index,
            name: nameEl?.textContent?.trim() || 'Unknown',
            preview: previewEl?.textContent?.trim() || '',
            time: timeEl?.textContent?.trim() || '',
            hasUnread: !!unreadEl && unreadEl.textContent?.trim() !== '0',
            unreadCount: unreadEl?.textContent?.trim() || '0',
          };
        }).filter(c => c.name !== 'Unknown');
      });

      return conversations;
    } catch (err) {
      console.error('[ZaloReader] Error getting conversations:', err.message);
      return [];
    }
  }

  async openConversation(index) {
    if (!this.connected) throw new Error('Not connected');

    const items = await this.page.$$(
      '[class*="conv-item"], [class*="ConvItem"], [class*="conversation-item"], li[class*="conv"]'
    );
    
    if (items[index]) {
      await items[index].click();
      await this.page.waitForTimeout(1500);
      return true;
    }
    return false;
  }

  async getMessagesFromCurrentConv(limit = 30) {
    if (!this.connected) throw new Error('Not connected');

    try {
      await this.page.waitForSelector(
        '[class*="message"], [class*="Message"], [class*="chat-item"]',
        { timeout: 8000 }
      ).catch(() => null);

      const messages = await this.page.evaluate((limit) => {
        const msgEls = document.querySelectorAll(
          '[class*="message-content"], [class*="MessageContent"], [class*="msg-content"], ' +
          '[class*="chat-content"], [class*="bubble"]'
        );

        return Array.from(msgEls).slice(-limit).map(el => {
          // Xác định sender
          const wrapper = el.closest('[class*="message"], [class*="Message"], [class*="chat-item"]');
          const isSelf = wrapper?.classList?.toString()?.includes('me') || 
                         wrapper?.classList?.toString()?.includes('self') ||
                         wrapper?.classList?.toString()?.includes('right') ||
                         wrapper?.getAttribute('data-owner') === 'me';
          
          const senderEl = wrapper?.querySelector('[class*="sender"], [class*="name"], [class*="author"]');
          
          return {
            text: el.textContent?.trim() || '',
            sender: isSelf ? 'Me' : (senderEl?.textContent?.trim() || 'Other'),
            isSelf,
            timestamp: new Date().toISOString(), // Zalo không expose timestamp dễ
          };
        }).filter(m => m.text.length > 0);
      }, limit);

      return messages;
    } catch (err) {
      console.error('[ZaloReader] Error getting messages:', err.message);
      return [];
    }
  }

  async takeScreenshot(path) {
    if (this.page) {
      await this.page.screenshot({ path, fullPage: false });
    }
  }

  async draftMessage(convName, text) {
    if (!this.connected) throw new Error('Not connected');
    
    try {
      console.log(`[ZaloReader] ✍️ Drafting message to "${convName}" (waiting for manual send)...`);
      // Lấy danh sách để tìm đúng Conversation
      const convs = await this.getConversationList();
      const target = convs.find(c => c.name.includes(convName));
      
      if (!target) {
        console.error(`[ZaloReader] Không tìm thấy hội thoại "${convName}"`);
        return false;
      }

      await this.openConversation(target.index);
      
      // Chờ ô input chat hien thi
      const inputSelector = '#richInput, [id*="chatInput"], div[contenteditable="true"]';
      await this.page.waitForSelector(inputSelector, { timeout: 5000 });
      
      // Gõ nội dung nháp vào ô chat
      await this.page.fill(inputSelector, text);
      await this.page.waitForTimeout(500);
      
      // Chú ý: BỎ qua thao tác Enter, để user tự quyết định có gửi hay không
      
      console.log(`[ZaloReader] ✅ Đã soạn sẵn nháp trên Zalo Web cho ${convName}`);
      return true;
    } catch (err) {
      console.error('[ZaloReader] Lỗi khi gõ nháp:', err.message);
      return false;
    }
  }

  async disconnect() {
    if (this.browser) {
      await this.browser.close();
      this.connected = false;
    }
  }
}
