// Zalo Web Chat Crawler - popup.js

let crawledData = null; // Lưu trữ dữ liệu sau khi cào thành công



document.addEventListener('DOMContentLoaded', async () => {
  // Thiết lập ngày mặc định là hôm qua
  const startDateInput = document.getElementById('startDate');
  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  startDateInput.value = yesterday.toISOString().split('T')[0];

  // Load cấu hình đã lưu từ storage
  chrome.storage.local.get(['startDate', 'delayTime', 'maxChats', 'selectors', 'lastCrawledData', 'isMonitoring', 'monitorInterval'], (res) => {
    if (res.startDate) startDateInput.value = res.startDate;
    if (res.delayTime) document.getElementById('delayTime').value = res.delayTime;
    if (res.maxChats) document.getElementById('maxChats').value = res.maxChats;
    if (res.monitorInterval) document.getElementById('monitorInterval').value = res.monitorInterval;
    
    if (res.isMonitoring !== undefined) {
      document.getElementById('chkMonitor').checked = res.isMonitoring;
      toggleMonitorInputs(res.isMonitoring);
    }
    
    // Load selectors nâng cao
    if (res.selectors) {
      if (res.selectors.selSidebar) document.getElementById('selSidebar').value = res.selectors.selSidebar;
      if (res.selectors.selChatItem) document.getElementById('selChatItem').value = res.selectors.selChatItem;
      if (res.selectors.selChatHeader) document.getElementById('selChatHeader').value = res.selectors.selChatHeader;
      if (res.selectors.selMsgList) document.getElementById('selMsgList').value = res.selectors.selMsgList;
      if (res.selectors.selMsgItem) document.getElementById('selMsgItem').value = res.selectors.selMsgItem;
    }

    if (res.lastCrawledData) {
      crawledData = res.lastCrawledData;
      enableExportButtons();
      addLog(`[Hệ thống] Đã khôi phục dữ liệu lần cào trước (${crawledData.length} tin nhắn). Bạn có thể tải xuống ngay.`);
    }
  });

  // Kiểm tra xem tab hiện tại có phải Zalo Web không
  const activeTab = await getActiveTab();
  if (!activeTab || !activeTab.url.includes('chat.zalo.me')) {
    addLog('[LỖI] Bạn phải mở và đứng ở trang chat.zalo.me để sử dụng extension này!', true);
    document.getElementById('btnStart').disabled = true;
    document.getElementById('chkMonitor').disabled = true;
    updateStatus('Không khả dụng', 'stopped');
  }

  // Lắng nghe sự kiện click nút
  document.getElementById('btnStart').addEventListener('click', startCrawl);
  document.getElementById('btnStop').addEventListener('click', stopCrawl);
  document.getElementById('btnExportJSON').addEventListener('click', exportToJSON);
  document.getElementById('btnExportCSV').addEventListener('click', exportToCSV);

  // Lắng nghe sự kiện giám sát
  document.getElementById('chkMonitor').addEventListener('change', toggleMonitoring);
  document.getElementById('monitorInterval').addEventListener('change', saveMonitorConfig);

  // Kiểm tra trạng thái server ngay lúc đầu và lặp lại
  checkServerStatus();
  setInterval(checkServerStatus, 5000);
});

// Lắng nghe thông điệp từ content.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === 'CRAWL_PROGRESS') {
    updateProgressUI(message.data);
  } else if (message.action === 'CRAWL_LOG') {
    addLog(message.text);
  } else if (message.action === 'CRAWL_FINISHED') {
    crawledData = message.data;
    chrome.storage.local.set({ lastCrawledData: crawledData });
    enableExportButtons();
    resetButtons();
    updateStatus('Hoàn thành', 'finished');
    addLog(`[Hệ thống] HOÀN THÀNH CÀO! Tổng cộng cào được ${crawledData.length} tin nhắn từ ${message.chatsCount} cuộc hội thoại.`);
  } else if (message.action === 'CRAWL_ERROR') {
    addLog(`[LỖI] ${message.text}`, true);
    resetButtons();
    updateStatus('Lỗi', 'stopped');
  }
});

// Lấy tab đang hoạt động
async function getActiveTab() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  return tab;
}

// Bắt đầu cào
async function startCrawl() {
  const activeTab = await getActiveTab();
  if (!activeTab || !activeTab.url.includes('chat.zalo.me')) {
    addLog('[LỖI] Vui lòng chuyển sang tab chat.zalo.me!', true);
    return;
  }

  const startDate = document.getElementById('startDate').value;
  const delayTime = parseInt(document.getElementById('delayTime').value) || 3000;
  const maxChats = parseInt(document.getElementById('maxChats').value) || 20;

  // Lấy danh sách Selectors nâng cao
  const selectors = {
    selSidebar: document.getElementById('selSidebar').value,
    selChatItem: document.getElementById('selChatItem').value,
    selChatHeader: document.getElementById('selChatHeader').value,
    selMsgList: document.getElementById('selMsgList').value,
    selMsgItem: document.getElementById('selMsgItem').value
  };

  // Lưu cấu hình
  chrome.storage.local.set({ startDate, delayTime, maxChats, selectors });

  // Cập nhật UI nút bấm
  document.getElementById('btnStart').disabled = true;
  document.getElementById('btnStop').disabled = false;
  document.getElementById('startDate').disabled = true;
  document.getElementById('delayTime').disabled = true;
  document.getElementById('maxChats').disabled = true;
  document.getElementById('btnExportJSON').disabled = true;
  document.getElementById('btnExportCSV').disabled = true;

  updateStatus('Đang cào...', 'crawling');
  addLog('[Hệ thống] Đang gửi lệnh bắt đầu cào tin nhắn sang Zalo Web...');

  // Gửi lệnh đến content script
  try {
    chrome.tabs.sendMessage(activeTab.id, {
      action: 'START_CRAWL',
      config: { startDate, delayTime, maxChats, selectors }
    }, (response) => {
      if (chrome.runtime.lastError) {
        addLog('[LỖI] Không thể kết nối với trang Zalo Web. Hãy F5 lại trang Zalo Web và thử lại.', true);
        resetButtons();
        updateStatus('Lỗi', 'stopped');
      } else {
        addLog('[Hệ thống] Đã kích hoạt tập lệnh cào dữ liệu thành công!');
      }
    });
  } catch (err) {
    addLog(`[LỖI] Lỗi kết nối: ${err.message}`, true);
    resetButtons();
  }
}

// Dừng cào
async function stopCrawl() {
  const activeTab = await getActiveTab();
  if (activeTab) {
    chrome.tabs.sendMessage(activeTab.id, { action: 'STOP_CRAWL' });
  }
  addLog('[Hệ thống] Đang yêu cầu dừng cào...');
  resetButtons();
  updateStatus('Đã dừng', 'stopped');
}

// Reset trạng thái các nút
function resetButtons() {
  document.getElementById('btnStart').disabled = false;
  document.getElementById('btnStop').disabled = true;
  document.getElementById('startDate').disabled = false;
  document.getElementById('delayTime').disabled = false;
  document.getElementById('maxChats').disabled = false;
}

// Mở khóa các nút tải file
function enableExportButtons() {
  document.getElementById('btnExportJSON').disabled = false;
  document.getElementById('btnExportCSV').disabled = false;
}

// Cập nhật trạng thái
function updateStatus(text, className) {
  const el = document.getElementById('statusText');
  el.textContent = text;
  el.className = `status-indicator ${className}`;
}

// Cập nhật thông số tiến trình
function updateProgressUI(data) {
  // data: { progressPercent, currentChatName, totalMessages }
  document.getElementById('progressBar').style.width = `${data.progressPercent}%`;
  document.getElementById('currentChatName').textContent = data.currentChatName || '-';
  document.getElementById('messageCount').textContent = data.totalMessages || 0;
}

// Thêm dòng log vào console
function addLog(text, isError = false) {
  const consoleEl = document.getElementById('logConsole');
  const logItem = document.createElement('div');
  const now = new Date().toLocaleTimeString();
  
  logItem.textContent = `[${now}] ${text}`;
  if (isError) {
    logItem.style.color = '#f87171';
  }
  
  consoleEl.appendChild(logItem);
  consoleEl.scrollTop = consoleEl.scrollHeight;
}

// Xuất file JSON
function exportToJSON() {
  if (!crawledData || crawledData.length === 0) return;
  const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(crawledData, null, 2));
  const downloadAnchor = document.createElement('a');
  
  const todayStr = new Date().toISOString().slice(0,10);
  downloadAnchor.setAttribute("href", dataStr);
  downloadAnchor.setAttribute("download", `zalo_crawl_${todayStr}.json`);
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  downloadAnchor.remove();
  addLog('[Hệ thống] Đã tải về file JSON chứa tin nhắn.');
}

// Xuất file CSV (Hỗ trợ tốt tiếng Việt Excel)
function exportToCSV() {
  if (!crawledData || crawledData.length === 0) return;
  
  // Header của CSV
  let csvContent = "\uFEFF"; // Thêm BOM để Excel hiển thị đúng tiếng Việt có dấu
  csvContent += "ChatRoom,Sender,Time,Date,Message\n";
  
  crawledData.forEach(row => {
    // Escape dấu ngoặc kép để tránh lỗi định dạng CSV
    const cleanRoom = `"${(row.chatRoom || '').replace(/"/g, '""')}"`;
    const cleanSender = `"${(row.sender || '').replace(/"/g, '""')}"`;
    const cleanTime = `"${row.time || ''}"`;
    const cleanDate = `"${row.date || ''}"`;
    const cleanMsg = `"${(row.text || '').replace(/"/g, '""')}"`;
    
    csvContent += `${cleanRoom},${cleanSender},${cleanTime},${cleanDate},${cleanMsg}\n`;
  });
  
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const downloadAnchor = document.createElement('a');
  
  const todayStr = new Date().toISOString().slice(0,10);
  downloadAnchor.setAttribute("href", url);
  downloadAnchor.setAttribute("download", `zalo_crawl_${todayStr}.csv`);
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  downloadAnchor.remove();
  addLog('[Hệ thống] Đã tải về file CSV chứa tin nhắn.');
}

// Kiểm tra trạng thái kết nối tới server cục bộ
function checkServerStatus() {
  chrome.runtime.sendMessage({
    action: 'API_REQUEST',
    method: 'GET',
    path: '/api/issues'
  }, (response) => {
    const indicator = document.getElementById('serverStatus');
    if (!indicator) return;
    
    if (response && response.success) {
      indicator.textContent = 'Server: Online';
      indicator.className = 'status-indicator finished'; // màu xanh lá
    } else {
      indicator.textContent = 'Server: Offline';
      indicator.className = 'status-indicator stopped';  // màu đỏ
    }
  });
}

// Bật/tắt input khoảng thời gian
function toggleMonitorInputs(isMonitoring) {
  document.getElementById('monitorInterval').disabled = isMonitoring;
}

// Lưu cấu hình chu kỳ quét
function saveMonitorConfig() {
  const monitorInterval = parseInt(document.getElementById('monitorInterval').value) || 5;
  chrome.storage.local.set({ monitorInterval });
}

// Kích hoạt hoặc Dừng Giám sát tự động
async function toggleMonitoring(e) {
  const isMonitoring = e.target.checked;
  const monitorInterval = parseInt(document.getElementById('monitorInterval').value) || 5;
  
  toggleMonitorInputs(isMonitoring);
  chrome.storage.local.set({ isMonitoring, monitorInterval });
  
  const activeTab = await getActiveTab();
  if (!activeTab || !activeTab.url.includes('chat.zalo.me')) return;
  
  const selectors = {
    selSidebar: document.getElementById('selSidebar').value,
    selChatItem: document.getElementById('selChatItem').value,
    selChatHeader: document.getElementById('selChatHeader').value,
    selMsgList: document.getElementById('selMsgList').value,
    selMsgItem: document.getElementById('selMsgItem').value
  };

  const action = isMonitoring ? 'START_MONITOR' : 'STOP_MONITOR';
  addLog(`[Hệ thống] Đang gửi yêu cầu ${isMonitoring ? 'BẬT' : 'TẮT'} giám sát tự động...`);
  
  try {
    chrome.tabs.sendMessage(activeTab.id, {
      action,
      config: {
        monitorInterval,
        selectors
      }
    }, (response) => {
      if (chrome.runtime.lastError) {
        addLog('[LỖI] Không thể kết nối với tab Zalo Web. Vui lòng tải lại trang Zalo Web.', true);
        document.getElementById('chkMonitor').checked = !isMonitoring;
        toggleMonitorInputs(!isMonitoring);
      } else {
        addLog(`[Hệ thống] Chế độ giám sát tự động đã ${isMonitoring ? 'BẮT ĐẦU' : 'DỪNG'}.`);
      }
    });
  } catch (err) {
    addLog(`[LỖI] Lỗi kết nối: ${err.message}`, true);
    document.getElementById('chkMonitor').checked = !isMonitoring;
    toggleMonitorInputs(!isMonitoring);
  }
}
