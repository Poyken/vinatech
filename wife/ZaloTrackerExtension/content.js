chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === "SYNC_CHAT") {
        try {
            let chatWindow = document.querySelector('.message-view__blur__inside, .message-view, .chat__content') || document.body;
            let windowRect = chatWindow.getBoundingClientRect();
            let textContainers = document.querySelectorAll('.text, .msg-text, .chat-message-content, span[dir="auto"]');

            if (textContainers.length === 0) {
                sendResponse({success: false, error: "Không tìm thấy tin nhắn trên màn hình. Hãy cuộn chuột để Zalo hiển thị chữ."});
                return true;
            }

            let domList = [];
            textContainers.forEach(container => {
                if (container.children.length > 0 && Array.from(container.children).some(c => c.classList && c.classList.contains('text'))) return; 
                let rect = container.getBoundingClientRect();
                if (rect.width === 0) return;

                let distLeft = rect.left - windowRect.left;
                let distRight = windowRect.right - rect.right;
                let senderName = (distLeft > distRight) ? "Đức" : "Thảo";

                let msgRow = container.closest('.chat-message, .message-view__item, [data-id]');
                let time = "";
                let dateStr = ""; 
                
                let timeEl = msgRow ? msgRow.querySelector('.card-time, .time-text, .time, .time-message') : null;
                if (timeEl) time = timeEl.innerText.trim();
                
                let prevEl = msgRow ? msgRow.previousElementSibling : null;
                while(prevEl) {
                    if (prevEl.classList.contains('chat-date') || prevEl.querySelector('.chat-date')) {
                        dateStr = prevEl.innerText.trim();
                        break;
                    }
                    prevEl = prevEl.previousElementSibling;
                }

                let content = container.innerText.trim();
                if (content && !content.match(/^(\d{2}:\d{2})$/)) {
                    domList.push({
                        date: dateStr,
                        time: time,
                        sender: senderName,
                        content: content
                    });
                }
            });

            chrome.storage.local.get(['zaloCache'], (result) => {
                let cache = result.zaloCache || [];
                
                let newMessages = [];
                let matchIndex = -1;

                if (cache.length > 0) {
                    /* THUẬT TOÁN KẾT NỐI (OVERLAP ALGORITHM) 
                     * So sánh điểm cuối của Móng Mái (Cache) với dữ liệu đạng có trên màn hình (DOM).
                     * Giúp bỏ qua các lỗi thời gian [] mà file Perfect gặp phải.
                     */
                    for (let i = cache.length - 1; i >= Math.max(0, cache.length - 200); i--) {
                        let cacheMsg = cache[i];
                        for (let j = domList.length - 1; j >= 0; j--) {
                            let domMsg = domList[j];
                            // Chỉ dùng tên người gửi và nội dung để dò điểm nối tiếp
                            if (cacheMsg.sender === domMsg.sender && cacheMsg.content === domMsg.content) {
                                matchIndex = j;
                                break;
                            }
                        }
                        if (matchIndex !== -1) break;
                    }
                    
                    if (matchIndex !== -1) {
                        // Cắt những tin nhắn xuất hiện sau điểm trùng để nối vào sau cùng
                        newMessages = domList.slice(matchIndex + 1);
                    } else {
                        // Không tìm thấy điểm giao thoa (tức là 100% trên màn hình đều là tin mới chạy quá xa)
                        newMessages = domList;
                    }
                } else {
                    newMessages = domList; 
                }

                // Gộp mảng tin mới vào Móng Mái
                for (let msg of newMessages) {
                    cache.push(msg);
                }

                // Xuất lại File
                let finalLog = "=== ZALO MASTER SYNC LOG ===\n\n";
                let lastPrintedDate = "";
                for (let msg of cache) {
                    if (msg.date && msg.date !== "" && msg.date !== lastPrintedDate) {
                        finalLog += `\n--- 📅 ${msg.date} ---\n`;
                        lastPrintedDate = msg.date;
                    }
                    // Đồng bộ giữ nguyên format [Giờ] Tên: Nội dung
                    finalLog += `[${msg.time}] ${msg.sender}: ${msg.content}\n`;
                }

                chrome.storage.local.set({zaloCache: cache}, () => {
                    sendResponse({success: true, newCount: newMessages.length});
                });
            });

        } catch (e) {
            sendResponse({success: false, error: e.toString()});
        }
        return true; 
    }
});
