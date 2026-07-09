// Zalo Web Chat Crawler - content.js

let isCrawling = false;
let isMonitoring = false;
let monitorIntervalId = null;
let config = null;
let allCrawledMessages = [];
let processedChatRooms = new Set();

// Lắng nghe sự kiện từ popup.js hoặc background.js
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
  } else if (request.action === 'START_MONITOR') {
    config = request.config;
    startMonitoring();
    sendResponse({ status: 'monitoring_started' });
  } else if (request.action === 'STOP_MONITOR') {
    stopMonitoring();
    sendResponse({ status: 'monitoring_stopped' });
  } else if (request.action === 'GET_MONITOR_STATUS') {
    sendResponse({ isMonitoring: isMonitoring });
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

// ==========================================
// AUTO MONITOR & MES INTELLIGENCE SIDEBAR
// ==========================================

let lastUserActivityTime = Date.now();
let isScanningNow = false;
let sidebarPollInterval = null;

// Theo dõi hoạt động của người dùng để tránh làm phiền khi đang gõ
window.addEventListener('mousemove', () => lastUserActivityTime = Date.now());
window.addEventListener('keydown', () => lastUserActivityTime = Date.now());
window.addEventListener('click', () => lastUserActivityTime = Date.now());
window.addEventListener('scroll', () => lastUserActivityTime = Date.now());

function startMonitoring() {
  if (isMonitoring) return;
  isMonitoring = true;
  console.log("[Monitor] Chế độ giám sát tự động bắt đầu.");
  
  createSidebarUI();
  
  // Quét lần đầu tiên sau 5 giây
  setTimeout(runMonitorIteration, 5000);
  
  // Lên lịch quét định kỳ
  const minutes = (config && config.monitorInterval) ? parseInt(config.monitorInterval) : 5;
  monitorIntervalId = setInterval(runMonitorIteration, minutes * 60 * 1000);
}

function stopMonitoring() {
  if (!isMonitoring) return;
  isMonitoring = false;
  
  if (monitorIntervalId) {
    clearInterval(monitorIntervalId);
    monitorIntervalId = null;
  }
  
  console.log("[Monitor] Chế độ giám sát tự động kết thúc.");
  removeSidebarUI();
}

async function runMonitorIteration() {
  if (!isMonitoring || isScanningNow || isCrawling) return;
  
  // Kiểm tra trạng thái Idle (30 giây)
  const idleTime = Date.now() - lastUserActivityTime;
  if (idleTime < 30 * 1000) {
    console.log(`[Monitor] Người dùng đang hoạt động (Idle: ${Math.round(idleTime/1000)}s). Hoãn quét 30 giây...`);
    setTimeout(runMonitorIteration, 30 * 1000);
    return;
  }
  
  isScanningNow = true;
  updateSidebarStatus("Đang quét tin nhắn...");
  
  try {
    await scanForMentions();
  } catch (error) {
    console.error("[Monitor] Lỗi khi quét:", error);
  } finally {
    isScanningNow = false;
    updateSidebarStatus("Đang giám sát (mỗi 5 phút)");
  }
}

// Lấy tên phòng chat hiện tại đang mở
function getActiveChatName() {
  const headerEl = document.querySelector('div.header-title, span.chat-title, div[class*="header-title"], .chat-title');
  if (headerEl) {
    return headerEl.textContent.trim().replace(/\s+/g, ' ');
  }
  return "";
}

// Quét toàn bộ cuộc trò chuyện hôm nay xem có nhắc tên
async function scanForMentions() {
  const sidebar = findSidebarScrollContainer(config.selectors.selSidebar);
  if (!sidebar) {
    console.log("[Monitor] Không tìm thấy sidebar.");
    return;
  }
  
  const chatItems = Array.from(sidebar.querySelectorAll(config.selectors.selChatItem));
  if (chatItems.length === 0) return;
  
  // Lưu lại phòng chat hiện tại để khôi phục sau khi quét
  const originalActiveChat = getActiveChatName();
  console.log(`[Monitor] Phòng chat hiện tại: "${originalActiveChat}"`);
  
  // Tải cache từ bộ nhớ
  const cacheData = await new Promise(resolve => {
    chrome.storage.local.get(['scannedChatsCache'], (res) => {
      resolve(res.scannedChatsCache || {});
    });
  });
  
  const newCache = { ...cacheData };
  let foundIssues = [];
  let scannedCount = 0;
  
  for (const item of chatItems) {
    if (!isMonitoring || isCrawling) break;
    
    // Tìm tiêu đề
    let chatName = "";
    const titleEl = item.querySelector(config.selectors.selChatHeader) || item.querySelector('.name, [class*="title"], [class*="name"]');
    if (titleEl) {
      chatName = titleEl.textContent.trim();
    } else {
      chatName = item.getAttribute('title') || item.innerText.split('\n')[0] || "";
    }
    chatName = chatName.replace(/\s+/g, ' ');
    
    if (chatName === "" || chatName.includes("Truyền File") || chatName.includes("Cloud của tôi")) {
      continue;
    }
    
    // Tìm thời gian tin nhắn cuối cùng ở sidebar
    let lastMsgTimeText = "";
    const timeEl = item.querySelector('[class*="time"], [class*="clock"], .time');
    if (timeEl) {
      lastMsgTimeText = timeEl.textContent.trim();
    }
    
    // Tìm nội dung tin nhắn cuối cùng (preview)
    let lastMsgPreview = "";
    const previewEl = item.querySelector('[class*="message"], [class*="preview"], .message, .snippet');
    if (previewEl) {
      lastMsgPreview = previewEl.textContent.trim();
    }
    
    // Chỉ quét các phòng chat có hoạt động hôm nay (chứa ":" biểu thị giờ, ví dụ "10:30")
    if (!lastMsgTimeText.includes(':')) {
      continue;
    }
    
    // Kiểm tra xem phòng này có thay đổi gì từ lần quét trước không
    const cacheKey = chatName;
    const cacheVal = newCache[cacheKey];
    if (cacheVal && cacheVal.time === lastMsgTimeText && cacheVal.preview === lastMsgPreview) {
      // Không có gì thay đổi, bỏ qua không cần click vào để quét lại
      continue;
    }
    
    console.log(`[Monitor] Phát hiện thay đổi trong phòng "${chatName}", tiến hành quét...`);
    
    // Click vào phòng để mở chat
    simulateClick(item);
    await sleep(1500);
    
    // Cào tin nhắn hôm nay
    const targetDate = new Date();
    targetDate.setHours(0, 0, 0, 0); // Chỉ lấy tin nhắn hôm nay
    
    const roomMessages = await crawlSingleChatRoom(chatName, targetDate);
    
    // Quét tìm @nguyễn văn đức
    const mentionPattern = /@nguyễn văn đức/gi;
    if (roomMessages && roomMessages.length > 0) {
      roomMessages.forEach(msg => {
        if (mentionPattern.test(msg.text)) {
          // Lưu lại các issue
          foundIssues.push(msg);
        }
      });
    }
    
    // Lưu vào cache
    newCache[cacheKey] = {
      time: lastMsgTimeText,
      preview: lastMsgPreview
    };
    
    scannedCount++;
    if (scannedCount >= 10) break; // Giới hạn quét tối đa 10 phòng mới mỗi lần để tránh quá tải
  }
  
  // Lưu cache mới
  chrome.storage.local.set({ scannedChatsCache: newCache });
  
  // Trở về phòng chat cũ
  if (originalActiveChat && getActiveChatName() !== originalActiveChat) {
    console.log(`[Monitor] Đang khôi phục lại phòng chat: "${originalActiveChat}"`);
    openChatRoomByName(originalActiveChat);
    await sleep(1000);
  }
  
  // Đẩy issues lên server
  if (foundIssues.length > 0) {
    console.log(`[Monitor] Phát hiện ${foundIssues.length} tin nhắn nhắc tên. Gửi lên server...`);
    chrome.runtime.sendMessage({
      action: 'API_REQUEST',
      method: 'POST',
      path: '/api/issues',
      body: foundIssues
    }, (res) => {
      if (res && res.success) {
        console.log("[Monitor] Đã lưu issues thành công lên server.");
        refreshSidebarIssues();
      }
    });
  }
}

// Mở chat room theo tên
function openChatRoomByName(name) {
  const sidebar = findSidebarScrollContainer(config.selectors.selSidebar);
  if (!sidebar) return false;
  const items = Array.from(sidebar.querySelectorAll(config.selectors.selChatItem));
  for (const item of items) {
    let chatName = "";
    const titleEl = item.querySelector(config.selectors.selChatHeader) || item.querySelector('.name, [class*="title"], [class*="name"]');
    if (titleEl) {
      chatName = titleEl.textContent.trim();
    } else {
      chatName = item.getAttribute('title') || item.innerText.split('\n')[0] || "";
    }
    chatName = chatName.replace(/\s+/g, ' ');
    if (chatName === name) {
      simulateClick(item);
      return true;
    }
  }
  return false;
}

// Tự động gõ và gửi tin nhắn trong Zalo Web
async function sendZaloMessage(text) {
  const inputEl = document.getElementById('rich-input') || document.querySelector('[contenteditable="true"]');
  if (!inputEl) {
    console.error("[Monitor] Không tìm thấy khung soạn thảo tin nhắn.");
    return false;
  }
  
  inputEl.focus();
  inputEl.innerHTML = ''; // Clear text cũ
  
  // Insert text bằng command insertText để Zalo nhận dạng sự thay đổi dữ liệu trong Draft.js
  document.execCommand('insertText', false, text);
  await sleep(500);
  
  // Click nút gửi
  const sendBtn = document.querySelector('[class*="btn-send"]') || document.querySelector('[data-testid="chat-input-send-btn"]');
  if (sendBtn) {
    simulateClick(sendBtn);
    return true;
  } else {
    // Nhấn Enter
    const enterEvent = new KeyboardEvent('keydown', {
      key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true
    });
    inputEl.dispatchEvent(enterEvent);
    return true;
  }
}

// ==========================================
// SIDEBAR INTERFACE INJECTION
// ==========================================

function createSidebarUI() {
  if (document.getElementById('mes-assistant-sidebar-container')) return;
  
  // Container chính
  const container = document.createElement('div');
  container.id = 'mes-assistant-sidebar-container';
  container.className = 'mes-sidebar-collapsed';
  
  // Floating Button
  const button = document.createElement('div');
  button.id = 'mes-sidebar-toggle-btn';
  button.innerHTML = `
    <div class="mes-bot-icon">🤖</div>
    <div class="mes-btn-label">MES Assistant</div>
  `;
  button.addEventListener('click', toggleSidebar);
  
  // Sidebar Panel
  const panel = document.createElement('div');
  panel.id = 'mes-sidebar-panel';
  panel.innerHTML = `
    <div class="mes-sidebar-header">
      <h3>Trợ lý MES Vinatech</h3>
      <span class="mes-close-btn">&times;</span>
    </div>
    <div class="mes-sidebar-status">
      <span class="mes-status-dot"></span>
      <span id="mes-sidebar-status-text">Đang kết nối...</span>
    </div>
    <div class="mes-sidebar-content">
      <div id="mes-issues-list" class="mes-issues-list">
        <div class="mes-empty-state">Chưa phát hiện lỗi nào cần giải quyết hôm nay.</div>
      </div>
    </div>
    <div class="mes-sidebar-footer">
      <small>Dữ liệu cục bộ được kiểm duyệt 100%</small>
    </div>
  `;
  
  container.appendChild(button);
  container.appendChild(panel);
  document.body.appendChild(container);
  
  panel.querySelector('.mes-close-btn').addEventListener('click', toggleSidebar);
  
  // Khởi động vòng lặp lấy dữ liệu (polling) mỗi 10 giây
  refreshSidebarIssues();
  sidebarPollInterval = setInterval(refreshSidebarIssues, 10000);
}

function removeSidebarUI() {
  const container = document.getElementById('mes-assistant-sidebar-container');
  if (container) {
    container.remove();
  }
  if (sidebarPollInterval) {
    clearInterval(sidebarPollInterval);
    sidebarPollInterval = null;
  }
}

function toggleSidebar() {
  const container = document.getElementById('mes-assistant-sidebar-container');
  if (!container) return;
  if (container.classList.contains('mes-sidebar-collapsed')) {
    container.classList.remove('mes-sidebar-collapsed');
    container.classList.add('mes-sidebar-expanded');
    refreshSidebarIssues();
  } else {
    container.classList.remove('mes-sidebar-expanded');
    container.classList.add('mes-sidebar-collapsed');
  }
}

function updateSidebarStatus(text) {
  const statusText = document.getElementById('mes-sidebar-status-text');
  if (statusText) {
    statusText.textContent = text;
  }
}

function refreshSidebarIssues() {
  if (!isMonitoring) return;
  
  chrome.runtime.sendMessage({
    action: 'API_REQUEST',
    method: 'GET',
    path: '/api/issues'
  }, (res) => {
    if (res && res.success) {
      updateSidebarStatus(isScanningNow ? "Đang quét tin nhắn..." : "Đang giám sát (mỗi 5 phút)");
      renderIssues(res.data);
    } else {
      updateSidebarStatus("Lỗi kết nối Local Server");
    }
  });
}

function renderIssues(issues) {
  const listEl = document.getElementById('mes-issues-list');
  if (!listEl) return;
  
  // Lọc chỉ lấy các issue hôm nay có status là crawled, pending_approval, hoặc approved
  const activeIssues = issues.filter(i => i.status !== 'resolved' && i.status !== 'rejected');
  
  if (activeIssues.length === 0) {
    listEl.innerHTML = '<div class="mes-empty-state">Chưa phát hiện lỗi nào cần giải quyết hôm nay.</div>';
    return;
  }
  
  listEl.innerHTML = '';
  activeIssues.forEach(issue => {
    const card = document.createElement('div');
    card.className = `mes-issue-card status-${issue.status}`;
    
    let statusText = "Đang tìm phương án...";
    if (issue.status === 'pending_approval') statusText = "Chờ duyệt phương án";
    if (issue.status === 'approved') statusText = "Đã duyệt - Đang gửi...";
    
    let solutionHtml = '';
    if (issue.status === 'pending_approval') {
      // Escape HTML in solution for safety
      const escapedSol = issue.solution
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;");
        
      solutionHtml = `
        <div class="mes-solution-box">
          <strong>Phương án đề xuất:</strong>
          <pre class="mes-solution-content">${escapedSol}</pre>
        </div>
        <div class="mes-action-buttons">
          <button class="mes-btn mes-btn-approve" data-id="${issue.id}">Phê duyệt & Gửi</button>
          <button class="mes-btn mes-btn-reject" data-id="${issue.id}">Từ chối</button>
        </div>
      `;
    } else {
      solutionHtml = `
        <div class="mes-loading-box">
          <div class="mes-spinner"></div>
          <span>Hệ thống đang phân tích lỗi và đề xuất SQL...</span>
        </div>
      `;
    }
    
    card.innerHTML = `
      <div class="mes-card-header">
        <span class="mes-room-name">${issue.chatRoom}</span>
        <span class="mes-msg-time">${issue.time}</span>
      </div>
      <div class="mes-card-sender">Người gửi: <strong>${issue.sender}</strong></div>
      <div class="mes-card-body">"${issue.text}"</div>
      <div class="mes-card-status">${statusText}</div>
      ${solutionHtml}
    `;
    
    listEl.appendChild(card);
    
    // Add Event Listeners
    if (issue.status === 'pending_approval') {
      card.querySelector('.mes-btn-approve').addEventListener('click', () => {
        approveAndSendIssue(issue.id, issue.chatRoom, issue.solution);
      });
      card.querySelector('.mes-btn-reject').addEventListener('click', () => {
        rejectIssue(issue.id);
      });
    }
  });
}

// Xử lý khi bấm nút Duyệt
async function approveAndSendIssue(id, chatRoom, solution) {
  console.log(`[Monitor] Phê duyệt issue ${id}. Đang chuẩn bị gửi...`);
  updateSidebarStatus("Đang gửi câu trả lời...");
  
  // 1. Gửi lệnh approve lên server
  chrome.runtime.sendMessage({
    action: 'API_REQUEST',
    method: 'POST',
    path: '/api/approve',
    body: { id }
  }, async (res) => {
    if (res && res.success) {
      const originalChat = getActiveChatName();
      
      // 2. Chuyển sang phòng chat chứa lỗi
      const opened = openChatRoomByName(chatRoom);
      if (!opened) {
        console.error(`[Monitor] Không thể chuyển tới phòng chat "${chatRoom}".`);
        updateSidebarStatus("Lỗi chuyển phòng chat");
        return;
      }
      
      await sleep(1500);
      
      // 3. Gửi tin nhắn
      const sent = await sendZaloMessage(solution);
      if (sent) {
        console.log(`[Monitor] Đã gửi giải pháp thành công tới "${chatRoom}".`);
        
        // 4. Báo cho server biết đã gửi xong
        chrome.runtime.sendMessage({
          action: 'API_REQUEST',
          method: 'POST',
          path: '/api/sent',
          body: { id }
        }, (sentRes) => {
          refreshSidebarIssues();
        });
      } else {
        console.error("[Monitor] Lỗi khi gửi tin nhắn.");
      }
      
      // 5. Quay về phòng chat cũ
      if (originalChat && getActiveChatName() !== originalChat) {
        openChatRoomByName(originalChat);
      }
    } else {
      console.error("[Monitor] Phê duyệt thất bại trên server.");
    }
  });
}

// Xử lý khi từ chối
function rejectIssue(id) {
  console.log(`[Monitor] Từ chối issue ${id}`);
  chrome.runtime.sendMessage({
    action: 'API_REQUEST',
    method: 'POST',
    path: '/api/reject',
    body: { id }
  }, (res) => {
    if (res && res.success) {
      refreshSidebarIssues();
    }
  });
}

// Tự động khôi phục trạng thái giám sát khi load trang Zalo Web
chrome.storage.local.get(['isMonitoring', 'monitorInterval', 'selectors'], (res) => {
  if (res.isMonitoring) {
    config = {
      monitorInterval: res.monitorInterval || 5,
      selectors: res.selectors
    };
    startMonitoring();
  }
});
