// Zalo Web Chat Crawler - content.js

let isCrawling = false;
let config = null;
let allCrawledMessages = [];
let processedChatRooms = new Set();

// Lắng nghe sự kiện từ popup.js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'START_CRAWL') {
    if (isCrawling) {
      sendResponse({ status: 'already_running' });
      return;
    }
    config = request.config;
    isCrawling = true;
    allCrawledMessages = [];
    processedChatRooms.clear();
    
    // Bắt đầu tiến trình chạy nền
    runCrawlerLoop();
    sendResponse({ status: 'started' });
  } else if (request.action === 'STOP_CRAWL') {
    isCrawling = false;
    logToPopup("[Hệ thống] Đã nhận lệnh dừng cào từ người dùng.");
    sendResponse({ status: 'stopped' });
  }
});

// Hàm log thông điệp gửi về popup
function logToPopup(text, isError = false) {
  chrome.runtime.sendMessage({
    action: isError ? 'CRAWL_ERROR' : 'CRAWL_LOG',
    text: text
  });
}

// Gửi cập nhật tiến trình về popup
function updateProgress(percent, currentChat, totalMsgs) {
  chrome.runtime.sendMessage({
    action: 'CRAWL_PROGRESS',
    data: {
      progressPercent: percent,
      currentChatName: currentChat,
      totalMessages: totalMsgs
    }
  });
}

// Trì hoãn thực thi (helper delay)
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Chuyển đổi chuỗi ngày Việt Nam sang đối tượng Date
function parseZaloDate(text) {
  if (!text) return null;
  
  // Chuẩn hóa chuỗi
  let cleanText = text.trim().toLowerCase();
  
  // Loại bỏ các tiền tố thứ ngày trong tiếng Việt (ví dụ: "thứ hai,", "chủ nhật,", "t2,", etc.)
  const dayOfWeekRegex = /^(chủ nhật|cn|thứ\s+\S+|t[2-7])[,\s]*/gi;
  cleanText = cleanText.replace(dayOfWeekRegex, '').trim();
  
  // Giới hạn chiều dài chuỗi tối đa của nhãn ngày để tránh parse nhầm hội thoại/tin nhắn chứa từ khóa ngày tháng
  if (cleanText.length > 30) {
    return null;
  }
  
  const today = new Date();
  let parsedDate = null;
  
  // Khớp chính xác các từ tương đối
  if (cleanText === 'hôm nay' || cleanText === 'today') {
    parsedDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  } else if (cleanText === 'hôm qua' || cleanText === 'yesterday') {
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    parsedDate = new Date(yesterday.getFullYear(), yesterday.getMonth(), yesterday.getDate());
  } else {
    // Định dạng: "20/06/2026" hoặc "20/06"
    const dmyRegex = /^(\d{1,2})[\/\- ](\d{1,2})(?:[\/\- ](\d{4}))?$/;
    let match = cleanText.match(dmyRegex);
    if (match) {
      const day = parseInt(match[1]);
      const month = parseInt(match[2]) - 1;
      const year = match[3] ? parseInt(match[3]) : today.getFullYear();
      parsedDate = new Date(year, month, day);
    } else {
      // Định dạng: "20 tháng 06, 2026" hoặc "20 tháng 6" hoặc "20 thg 6"
      const textMonthRegex = /^(\d{1,2})\s+(?:tháng|thg)\s+(\d{1,2})(?:[,\s]+(\d{4}))?$/;
      match = cleanText.match(textMonthRegex);
      if (match) {
        const day = parseInt(match[1]);
        const month = parseInt(match[2]) - 1;
        const year = match[3] ? parseInt(match[3]) : today.getFullYear();
        parsedDate = new Date(year, month, day);
      }
    }
  }
  
  if (parsedDate && !isNaN(parsedDate.getTime())) {
    return parsedDate;
  }
  
  return null;
}

// Hàm click giả lập hành vi chuột
function simulateClick(element) {
  if (!element) return;
  element.scrollIntoView({ block: 'center' });
  
  const mousedownEvent = new MouseEvent('mousedown', { bubbles: true, cancelable: true, view: window });
  element.dispatchEvent(mousedownEvent);
  
  const clickEvent = new MouseEvent('click', { bubbles: true, cancelable: true, view: window });
  element.dispatchEvent(clickEvent);
  
  const mouseupEvent = new MouseEvent('mouseup', { bubbles: true, cancelable: true, view: window });
  element.dispatchEvent(mouseupEvent);
}

// Tự động tìm khung cuộn chứa danh sách chat ở sidebar trái
function findSidebarScrollContainer(selector) {
  let el = document.querySelector(selector);
  if (el) return el;
  
  // Dự phòng: Tìm div có chiều rộng < 380px và scrollable ở bên trái màn hình
  const divs = document.querySelectorAll('div');
  for (const d of divs) {
    const rect = d.getBoundingClientRect();
    if (rect.width > 150 && rect.width < 380 && rect.left < 100) {
      const style = window.getComputedStyle(d);
      if ((style.overflowY === 'auto' || style.overflowY === 'scroll') && d.scrollHeight > d.clientHeight) {
        return d;
      }
    }
  }
  return null;
}

// Tự động tìm khung cuộn chứa tin nhắn ở màn hình chat phải
function findMessageScrollContainer(selector) {
  let el = document.querySelector(selector);
  if (el) return el;
  
  // Dò tìm ưu tiên các class scroll quen thuộc của Zalo
  const prioritySelectors = ['.message-view__scroll', '#chat-message-list', '.chat-view__container__message-list'];
  for (const sel of prioritySelectors) {
    const found = document.querySelector(sel);
    if (found) return found;
  }
  
  // Dự phòng: Tìm div scrollable nằm ở trung tâm/bên phải màn hình
  const divs = document.querySelectorAll('div');
  for (const d of divs) {
    const rect = d.getBoundingClientRect();
    if (rect.width > 300 && rect.left > 150) {
      const style = window.getComputedStyle(d);
      if ((style.overflowY === 'auto' || style.overflowY === 'scroll') && d.scrollHeight > d.clientHeight) {
        return d;
      }
    }
  }
  return null;
}

// Vòng lặp chính điều phối Crawler
async function runCrawlerLoop() {
  logToPopup("[Hệ thống] Khởi động vòng lặp cào dữ liệu...");
  
  const targetDate = new Date(config.startDate);
  logToPopup(`[Cấu hình] Ngày bắt đầu quét: ${targetDate.toLocaleDateString('vi-VN')}`);
  logToPopup(`[Cấu hình] Giới hạn số phòng chat: ${config.maxChats}`);
  
  let chatCount = 0;
  let noNewChatsCount = 0;
  
  while (isCrawling && chatCount < config.maxChats) {
    // 1. Tìm container cuộn sidebar
    const sidebar = findSidebarScrollContainer(config.selectors.selSidebar);
    if (!sidebar) {
      logToPopup("[LỖI] Không tìm thấy sidebar chứa danh sách chat. Hãy chắc chắn bạn đang ở màn hình chat của Zalo.", true);
      isCrawling = false;
      break;
    }
    
    // 2. Tìm danh sách các chat items hiện tại trong DOM
    const chatItems = Array.from(sidebar.querySelectorAll(config.selectors.selChatItem));
    if (chatItems.length === 0) {
      logToPopup("[LỖI] Không tìm thấy cuộc trò chuyện nào trong danh sách. Vui lòng kiểm tra lại CSS selector.", true);
      isCrawling = false;
      break;
    }
    
    let processedAnyInThisIteration = false;
    
    for (const item of chatItems) {
      if (!isCrawling) break;
      if (chatCount >= config.maxChats) break;
      
      // Lấy tên/tiêu đề cuộc trò chuyện
      // Zalo Web thường lưu tiêu đề trong các class chứa text đậm, title hoặc thẻ span có class title
      let chatName = "";
      const titleEl = item.querySelector(config.selectors.selChatHeader) || item.querySelector('.name, [class*="title"], [class*="name"]');
      if (titleEl) {
        chatName = titleEl.textContent.trim();
      } else {
        // Dự phòng: Lấy từ attribute title của phần tử cha
        chatName = item.getAttribute('title') || item.innerText.split('\n')[0] || `Phòng Chat #${chatCount + 1}`;
      }
      
      chatName = chatName.replace(/\s+/g, ' '); // Clean space
      
      if (processedChatRooms.has(chatName) || chatName === "" || chatName.includes("Truyền File") || chatName.includes("Cloud của tôi")) {
        continue;
      }
      
      logToPopup(`[Tiến trình] Đang mở cuộc trò chuyện: "${chatName}"`);
      updateProgress(Math.round((chatCount / config.maxChats) * 100), chatName, allCrawledMessages.length);
      
      // Click để mở chat
      simulateClick(item);
      processedChatRooms.add(chatName);
      processedAnyInThisIteration = true;
      noNewChatsCount = 0;
      
      // Chờ chat load xong
      await sleep(2000);
      
      // Tiến hành cào tin nhắn của phòng chat này
      const roomMessages = await crawlSingleChatRoom(chatName, targetDate);
      if (roomMessages && roomMessages.length > 0) {
        allCrawledMessages = allCrawledMessages.concat(roomMessages);
        logToPopup(`[Kết quả] Cào thành công ${roomMessages.length} tin nhắn từ "${chatName}".`);
      } else {
        logToPopup(`[Thông tin] Không tìm thấy tin nhắn mới từ ngày yêu cầu trong "${chatName}".`);
      }
      
      chatCount++;
      updateProgress(Math.round((chatCount / config.maxChats) * 100), chatName, allCrawledMessages.length);
      
      // Chờ delay giãn cách giữa các phòng chat để tránh bị quét
      await sleep(config.delayTime);
    }
    
    if (!processedAnyInThisIteration) {
      // Nếu không xử lý được thêm chat nào mới, tiến hành cuộn sidebar xuống dưới để load thêm chat cũ
      const beforeScrollHeight = sidebar.scrollTop;
      sidebar.scrollTop += 300;
      await sleep(1500);
      
      if (sidebar.scrollTop === beforeScrollHeight) {
        noNewChatsCount++;
        if (noNewChatsCount > 3) {
          logToPopup("[Hệ thống] Đã cuộn hết danh sách cuộc trò chuyện bên trái.");
          break;
        }
      }
    }
  }
  
  if (isCrawling) {
    isCrawling = false;
    chrome.runtime.sendMessage({
      action: 'CRAWL_FINISHED',
      data: allCrawledMessages,
      chatsCount: chatCount
    });
  }
}

// Cào tin nhắn trong một cuộc trò chuyện cụ thể
async function crawlSingleChatRoom(chatRoomName, targetDate) {
  // Debug tìm cấu trúc DOM của tin nhắn chứa chữ trong khung chat
  try {
    const allEls = Array.from(document.querySelectorAll('*'));
    logToPopup(`[Debug SingleChat] Tổng số element trên trang: ${allEls.length}`);
    
    // Tìm phần tử chứa tin nhắn mẫu
    let foundMsgCount = 0;
    for (const el of allEls) {
      if (el.children.length === 0 && (el.textContent.includes('chị') || el.textContent.includes('oke') || el.textContent.includes('nhờ') || el.textContent.includes('em'))) {
        let path = [];
        let curr = el;
        while (curr && curr !== document.body) {
          const classStr = Array.from(curr.classList).join('.');
          path.push(`${curr.tagName.toLowerCase()}${classStr ? '.' + classStr : ''}`);
          curr = curr.parentElement;
        }
        logToPopup(`[Debug DOM Tin Nhắn Trong Khung Chat] Path: ${path.reverse().join(' > ')}`);
        foundMsgCount++;
        if (foundMsgCount >= 5) break;
      }
    }

    // Tìm các container cuộn
    const divs = Array.from(document.querySelectorAll('div'));
    let scrollCount = 0;
    for (const d of divs) {
      const rect = d.getBoundingClientRect();
      const style = window.getComputedStyle(d);
      const isScroll = (style.overflowY === 'auto' || style.overflowY === 'scroll') && d.scrollHeight > d.clientHeight;
      if (isScroll && rect.width > 200) {
        scrollCount++;
        logToPopup(`[Debug Scrollable #${scrollCount}] Tag: ${d.tagName}, ID: "${d.id}", Class: "${d.className}", Width: ${rect.width}, Height: ${rect.height}, Children: ${d.children.length}`);
        if (d.children.length > 0) {
          const firstChild = d.children[0];
          logToPopup(`   -> Con đầu tiên: <${firstChild.tagName} class="${firstChild.className}"> text="${firstChild.textContent.trim().substring(0, 30)}"`);
        }
      }
    }
  } catch (e) {
    logToPopup(`[Debug DOM Error] ${e.message}`, true);
  }

  const msgContainer = findMessageScrollContainer(config.selectors.selMsgList);
  if (!msgContainer) {
    logToPopup(`[Cảnh báo] Không tìm thấy khung tin nhắn cho "${chatRoomName}". Bỏ qua phòng này.`, true);
    return [];
  }
  
  // Tự động tối ưu hóa/sửa đổi Selectors nếu cần
  if (msgContainer) {
    if (!msgContainer.querySelector(config.selectors.selMsgItem)) {
      const fbSelectors = ['.message-frame', '.message-content-render', '.chat-message'];
      for (const fb of fbSelectors) {
        if (msgContainer.querySelector(fb)) {
          logToPopup(`[Tự động sửa] Chuyển đổi selector tin nhắn thành "${fb}" do selector cũ không khớp.`);
          config.selectors.selMsgItem = fb;
          break;
        }
      }
    }
  }
  
  logToPopup(`[Debug] Container ID: "${msgContainer.id}", Class: "${msgContainer.className}", Con: ${msgContainer.children.length}`);
  const hasMsgItem = msgContainer.querySelector(config.selectors.selMsgItem) !== null;
  logToPopup(`[Debug] Tìm thấy msgItem (${config.selectors.selMsgItem}): ${hasMsgItem}`);
  if (msgContainer.children.length > 0) {
    const firstChild = msgContainer.children[0];
    logToPopup(`[Debug] Con đầu tiên: <${firstChild.tagName} class="${firstChild.className}"> text="${firstChild.textContent.trim().substring(0, 40)}"`);
  }
  
  logToPopup(`[Cuộn trang] Đang cuộn ngược dòng thời gian để tải tin nhắn...`);
  
  let scrollAttempts = 0;
  let lastScrollHeight = msgContainer.scrollHeight;
  let reachedLimit = false;
  let noNewMessagesLoadAttempts = 0;
  
  while (isCrawling && !reachedLimit && noNewMessagesLoadAttempts < 5) {
    // Cuộn lên đỉnh
    msgContainer.scrollTop = 0;
    await sleep(config.delayTime / 2); // Chờ tin nhắn load
    
    // Kiểm tra xem có load thêm tin nhắn mới không
    if (msgContainer.scrollHeight === lastScrollHeight) {
      noNewMessagesLoadAttempts++;
    } else {
      noNewMessagesLoadAttempts = 0;
      lastScrollHeight = msgContainer.scrollHeight;
    }
    
    // Kiểm tra thời gian của tin nhắn ở trên cùng
    const topDate = getTopMessageDate(msgContainer);
    if (topDate) {
      logToPopup(`[Thông số] Đã cuộn tới ngày: ${topDate.toLocaleDateString('vi-VN')}`);
      if (topDate < targetDate) {
        logToPopup(`[Thông báo] Đã đạt mốc thời gian yêu cầu (${targetDate.toLocaleDateString('vi-VN')}). Dừng cuộn.`);
        reachedLimit = true;
        break;
      }
    }
    
    scrollAttempts++;
    if (scrollAttempts > 50) { // Giới hạn cuộn tối đa tránh tràn bộ nhớ
      logToPopup(`[Cảnh báo] Đạt giới hạn cuộn tối đa (50 lần) cho phòng "${chatRoomName}".`);
      break;
    }
  }
  
  // Tiến hành quét và lưu lại toàn bộ tin nhắn đã hiển thị
  return extractVisibleMessages(msgContainer, chatRoomName, targetDate);
}

// Trích xuất ngày từ một khối date-block
function getDateOfBlock(block) {
  // Quét các thẻ con trực tiếp hoặc gián tiếp để tìm ngày
  const elements = Array.from(block.querySelectorAll('*'));
  for (const el of elements) {
    // Để tránh lấy nhầm ngày trong tin nhắn, el phải không nằm trong và không chứa bong bóng tin nhắn
    if (el.closest(config.selectors.selMsgItem) || el.querySelector(config.selectors.selMsgItem)) {
      continue;
    }
    const txt = el.textContent.trim();
    if (txt.length > 0 && txt.length < 30) {
      if (txt.includes('tháng') || txt.includes('thg') || txt.includes('/') || txt.toLowerCase().includes('hôm nay') || txt.toLowerCase().includes('hôm qua')) {
        const parsed = parseZaloDate(txt);
        if (parsed) {
          return parsed;
        }
      }
    }
  }
  return null;
}

// Lấy ngày của tin nhắn hoặc vạch chia ngày đầu tiên từ trên xuống
function getTopMessageDate(container) {
  // Tìm các block-date trước
  const dateBlocks = Array.from(container.querySelectorAll('.block-date, [class*="block-date"]'));
  for (const block of dateBlocks) {
    const parsed = getDateOfBlock(block);
    if (parsed) {
      return parsed;
    }
  }
  
  // Fallback nếu không có block-date
  const elements = Array.from(container.querySelectorAll('*'));
  for (const el of elements) {
    if (el.closest(config.selectors.selMsgItem) || el.querySelector(config.selectors.selMsgItem)) {
      continue;
    }
    
    const txt = el.textContent.trim();
    if (txt.length > 0 && txt.length < 30) {
      if (txt.includes('tháng') || txt.includes('thg') || txt.includes('/') || txt.toLowerCase().includes('hôm nay') || txt.toLowerCase().includes('hôm qua')) {
        const parsed = parseZaloDate(txt);
        if (parsed) {
          return parsed;
        }
      }
    }
  }
  return null;
}

// Trích xuất tin nhắn hiển thị trong container
function extractVisibleMessages(container, chatRoomName, targetDate) {
  const results = [];
  
  // Tìm tất cả các block-date trong container
  const dateBlocks = Array.from(container.querySelectorAll('.block-date, [class*="block-date"]'));
  
  // Nếu không tìm thấy bất kỳ block-date nào, sử dụng chế độ fallback duyệt trực tiếp như cũ
  if (dateBlocks.length === 0) {
    return extractVisibleMessagesFallback(container, chatRoomName, targetDate);
  }
  
  dateBlocks.forEach(block => {
    // Xác định ngày của block này
    const blockDate = getDateOfBlock(block) || new Date();
    
    // Chỉ xử lý nếu ngày của block lớn hơn hoặc bằng ngày yêu cầu
    if (blockDate < targetDate) {
      return;
    }
    
    // Lấy tất cả các tin nhắn trong block này
    const msgBubbles = block.querySelectorAll(config.selectors.selMsgItem);
    msgBubbles.forEach(bubble => {
      const bubbleText = bubble.innerText || bubble.textContent || "";
      if (bubbleText.includes("Tin nhắn đã được thu hồi") || bubbleText.trim() === "") {
        return;
      }
      
      // Lấy thời gian gửi
      let msgTime = "";
      const timeEl = bubble.querySelector('[class*="time"], [class*="clock"]');
      if (timeEl) {
        msgTime = timeEl.textContent.trim();
      } else {
        const timeRegex = /\b([01]?\d|2[0-3]):([0-5]\d)\b/;
        const match = bubbleText.match(timeRegex);
        if (match) msgTime = match[0];
      }
      
      // Lấy tên người gửi
      let senderName = "";
      const chatItem = bubble.closest('.chat-item, [class*="chat-item"]');
      if (chatItem) {
        const senderEl = chatItem.querySelector('[class*="sender-name"], [class*="author"], [class*="name"]');
        if (senderEl && !senderEl.textContent.trim().includes(':') && senderEl !== timeEl) {
          senderName = senderEl.textContent.trim();
        }
      }
      
      if (!senderName) {
        // Phân biệt Tôi vs Người kia
        const isOwner = bubble.closest('.me') || bubble.closest('[class*="owner"]') || bubble.closest('[class*="right"]') || bubble.classList.contains('msg-item--owner');
        if (isOwner) {
          senderName = "Tôi";
        } else {
          senderName = chatRoomName;
        }
      }
      
      // Lấy nội dung tin nhắn
      let textMsg = "";
      const textEl = bubble.querySelector('[class*="text"], span[class*="message"], .text');
      if (textEl) {
        textMsg = textEl.textContent.trim();
      } else {
        textMsg = bubbleText.trim();
        if (msgTime && textMsg.endsWith(msgTime)) {
          textMsg = textMsg.substring(0, textMsg.length - msgTime.length).trim();
        }
      }
      
      if (textMsg) {
        results.push({
          chatRoom: chatRoomName,
          sender: senderName,
          time: msgTime,
          date: blockDate.toLocaleDateString('vi-VN'),
          text: textMsg
        });
      }
    });
  });
  
  return results;
}

// Chế độ fallback nếu không có cấu trúc block-date
function extractVisibleMessagesFallback(container, chatRoomName, targetDate) {
  const results = [];
  const children = Array.from(container.children);
  let currentDateContext = new Date();
  
  children.forEach(child => {
    const textContent = child.textContent.trim();
    if (!textContent) return;
    
    const parsedDate = parseZaloDate(textContent);
    if (parsedDate && !child.querySelector(config.selectors.selMsgItem)) {
      currentDateContext = parsedDate;
      return;
    }
    
    const msgBubbles = child.querySelectorAll(config.selectors.selMsgItem);
    if (msgBubbles.length === 0) return;
    
    msgBubbles.forEach(bubble => {
      const bubbleText = bubble.innerText || bubble.textContent || "";
      if (bubbleText.includes("Tin nhắn đã được thu hồi") || bubbleText.trim() === "") {
        return;
      }
      
      if (currentDateContext < targetDate) {
        return;
      }
      
      let msgTime = "";
      const timeEl = bubble.querySelector('[class*="time"], [class*="clock"]');
      if (timeEl) {
        msgTime = timeEl.textContent.trim();
      } else {
        const timeRegex = /\b([01]?\d|2[0-3]):([0-5]\d)\b/;
        const match = bubbleText.match(timeRegex);
        if (match) msgTime = match[0];
      }
      
      let senderName = "";
      const senderEl = bubble.querySelector('[class*="sender-name"], [class*="author"], [class*="name"]');
      if (senderEl) {
        senderName = senderEl.textContent.trim();
      } else {
        const isOwner = bubble.closest('.me') || bubble.closest('[class*="owner"]') || bubble.closest('[class*="right"]') || bubble.classList.contains('msg-item--owner');
        if (isOwner) {
          senderName = "Tôi";
        } else {
          senderName = chatRoomName;
        }
      }
      
      let textMsg = "";
      const textEl = bubble.querySelector('[class*="text"], span[class*="message"], .text');
      if (textEl) {
        textMsg = textEl.textContent.trim();
      } else {
        textMsg = bubbleText.trim();
        if (msgTime && textMsg.endsWith(msgTime)) {
          textMsg = textMsg.substring(0, textMsg.length - msgTime.length).trim();
        }
      }
      
      if (textMsg) {
        results.push({
          chatRoom: chatRoomName,
          sender: senderName,
          time: msgTime,
          date: currentDateContext.toLocaleDateString('vi-VN'),
          text: textMsg
        });
      }
    });
  });
  
  return results;
}
