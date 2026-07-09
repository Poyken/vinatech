// Zalo Crawler Extension - Background Script (background.js)
const LOCAL_SERVER = 'http://localhost:3000';

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.action === 'API_REQUEST') {
    const url = `${LOCAL_SERVER}${message.path}`;
    const options = {
      method: message.method || 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };
    
    if (message.body) {
      options.body = JSON.stringify(message.body);
    }
    
    fetch(url, options)
      .then(response => {
        if (!response.ok) {
          throw new Error(`Server returned HTTP ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        sendResponse({ success: true, data });
      })
      .catch(error => {
        console.error('[Background] Fetch error:', error);
        sendResponse({ success: false, error: error.message });
      });
      
    return true; // Keep the message channel open for async response
  }
});
