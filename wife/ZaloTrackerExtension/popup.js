document.getElementById('importFile').addEventListener('change', function(e) {
    let file = e.target.files[0];
    if (!file) return;

    let reader = new FileReader();
    reader.onload = function(e) {
        let text = e.target.result;
        let lines = text.split('\n');
        let cache = [];
        let regex = /\[([^\]]*)\]\s+(Đức|Thảo):\s*(.*)$/;
        
        let count = 0;
        for (let line of lines) {
            line = line.trim();
            if (!line) continue;
            
            let match = line.match(regex);
            if (match) {
                let time = match[1].trim();
                let sender = match[2].trim();
                let content = match[3].trim();
                cache.push({
                    date: "", 
                    time: time,
                    sender: sender,
                    content: content
                });
                count++;
            }
        }

        chrome.storage.local.set({zaloCache: cache}, () => {
            let status = document.getElementById('status');
            status.innerText = `✅ Nạp gốc thành công!\nĐã lưu: ${count} tin nhắn chuẩn vào bộ nhớ.\nTất cả tin nhắn rác đã bị xóa.`;
            status.style.color = "green";
        });
    };
    reader.readAsText(file);
});

document.getElementById('syncBtn').addEventListener('click', () => {
    let status = document.getElementById('status');
    status.innerText = "Đang quét Zalo Web...";
    status.style.color = "blue";
    
    chrome.tabs.query({active: true, currentWindow: true}, (tabs) => {
        let activeTab = tabs[0];
        if (activeTab.url && activeTab.url.includes("chat.zalo.me")) {
            chrome.tabs.sendMessage(activeTab.id, {action: "SYNC_CHAT"}, (response) => {
                if(response && response.success) {
                    status.innerText = `Lọc thành công!\nPhát hiện ${response.newCount} tin nhắn mới.\nĐang lưu...`;
                    status.style.color = "green";
                    
                    downloadCache();
                } else {
                    status.innerText = "Lỗi: " + (response ? response.error : "Bạn tải lại trang Zalo (F5) rồi thử lại nhé!");
                    status.style.color = "red";
                }
            });
        } else {
            status.innerText = "Chưa mở Zalo Web ở Tab này!";
            status.style.color = "red";
        }
    });
});

document.getElementById('exportBtn').addEventListener('click', downloadCache);

function downloadCache() {
    chrome.storage.local.get(['zaloCache'], (result) => {
        let cache = result.zaloCache || [];
        if (cache.length === 0) {
            document.getElementById('status').innerText = "Bộ nhớ trống!\nHãy Nạp File Gốc hoặc Đồng Bộ.";
            document.getElementById('status').style.color = "red";
            return;
        }

        let finalLog = "=== ZALO MASTER SYNC LOG ===\n\n";
        let lastPrintedDate = "";
        
        for (let msg of cache) {
            if (msg.date && msg.date !== "" && msg.date !== lastPrintedDate) {
                finalLog += `\n--- 📅 ${msg.date} ---\n`;
                lastPrintedDate = msg.date;
            }
            finalLog += `[${msg.time}] ${msg.sender}: ${msg.content}\n`;
        }

        let blob = new Blob([finalLog], { type: 'text/plain;charset=utf-8' });
        let url = URL.createObjectURL(blob);
        chrome.downloads.download({
            url: url,
            filename: 'Zalo_Chat_Thao_Perfect.txt', // Giữ nguyên tên file xuất ra theo yêu cầu
            saveAs: false
        });
    });
}

document.getElementById('clearBtn').addEventListener('click', () => {
    if(confirm("CẢNH BÁO: Thao tác này sẽ xóa trắng bộ nhớ đệm Tracking của Extension. Lịch sử của bạn sẽ bay màu. Chắc chưa?")) {
        chrome.storage.local.remove(['zaloCache'], () => {
            document.getElementById('status').innerText = "Đã dọn dẹp trắng rác và xóa bộ nhớ gốc!";
            document.getElementById('status').style.color = "red";
            document.getElementById('importFile').value = ''; 
        });
    }
});
