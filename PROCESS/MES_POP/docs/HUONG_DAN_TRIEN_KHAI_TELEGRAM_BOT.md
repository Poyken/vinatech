# 📱 HƯỚNG DẪN TRIỂN KHAI VINATECH MES TELEGRAM ASSISTANT BOT

> **Mục tiêu:** Cho phép kỹ sư MES gửi yêu cầu tra cứu từ điện thoại qua Telegram, nhận phản hồi ngay lập tức mà không cần ngồi trực tiếp hay mở laptop.
> **Trạng thái chuẩn bị:** Hệ thống code, file chạy, và cấu hình đã được tạo sẵn 100% trong Workspace. Khi nào cần triển khai, bạn chỉ việc làm theo 4 bước dưới đây.

---

## 🏛️ 1. Kiến Trúc & Cơ Chế Hoạt Động

```text
[Điện thoại (Telegram App)]
         │  (Nhắn tin qua 4G/WiFi: /trace, /health, /screen...)
         ▼
[Telegram Cloud Server]
         │  (Long Polling - Kéo dữ liệu tự động, KHÔNG CẦN MỞ PORT MẠNG CÔNG TY)
         ▼
[Laptop cá nhân / Server nội bộ] ──(mes_telegram_bot.py)
         │
         ├── Gọi [mes.ps1 trace <Lot>] ──> [Live DB: SmartFactoryV2 / MES]
         ├── Gọi [mes.ps1 health]      ──> [Quét Lot kẹt, WIP 24h, Box dở dang]
         ├── Gọi [mes.ps1 screen]      ──> [Tra cứu SP & Bảng màn hình]
         └── Gọi [find_kb.ps1]         ──> [Tra cứu 78+ file tài liệu KB]
         │
         ▼  (Định dạng Markdown đẹp mắt)
[Bắn kết quả ngược về Telegram trên điện thoại của bạn]
```

- **Zero Third-party Dependencies:** Sử dụng 100% thư viện chuẩn của Python 3.12 (urllib, json, subprocess), không cần `pip install`.
- **Bảo mật Whitelist:** Chỉ phản hồi duy nhất tài khoản Telegram của bạn (`allowed_chat_ids`), người lạ gửi tin nhắn bot sẽ tự động bỏ qua.
- **Vượt Firewall:** Cơ chế kéo (Outbound HTTPs Polling) nên chạy được ở mọi mạng WiFi/LAN công ty mà không bị chặn.

---

## 📋 2. Quy Trình 4 Bước Triển Khai (Chỉ Mất 3 Phút)

### 🔹 BƯỚC 1: Lấy Token Bot & Chat ID từ Telegram (Trên điện thoại)

#### 1.1 Tạo Bot và lấy HTTP API Token:
1. Mở ứng dụng **Telegram** trên điện thoại.
2. Tìm kiếm người dùng: **`@BotFather`** (chọn tài khoản có dấu tích xanh chính chủ).
3. Nhấn **Start** (hoặc gửi tin nhắn `/newbot`).
4. Nhập tên hiển thị cho Bot (Ví dụ: `Vinatech MES Assistant`).
5. Nhập username cho Bot (bắt buộc kết thúc bằng chữ `bot`, ví dụ: `vinatech_mes_helper_bot`).
6. `@BotFather` sẽ gửi lại một thông điệp chúc mừng kèm mã **HTTP API Token**, có dạng:
   ```text
   7123456789:AAHk123456789abcdefghiklmnop-qrstuv
   ```
   👉 **Copy và lưu chuỗi Token này.**

#### 1.2 Lấy Chat ID tài khoản cá nhân để cài bảo mật:
1. Trên thanh tìm kiếm Telegram, gõ tìm: **`@userinfobot`**.
2. Nhấn **Start**.
3. Bot sẽ gửi lại thông tin tài khoản của bạn, hãy tìm dòng:
   ```text
   Id: 123456789
   ```
   👉 **Copy dãy số ID này.**

---

### 🔹 BƯỚC 2: Cập Nhật File Cấu Hình Trên Laptop

1. Mở file cấu hình: [`tools\telegram_config.json`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/tools/telegram_config.json)
2. Điền thông tin gồm Token, Chat ID và **Gemini API Key** (để kích hoạt Não AI trả lời tự nhiên):

```json
{
    "bot_token": "8876322501:AAFjKlblHAzEJj_GnFK2fkxKMNlewQnmIcs",
    "allowed_chat_ids": [
        "8876615407"
    ],
    "gemini_api_key": "AIzaSy...",
    "poll_interval_seconds": 2
}
```

> 🔑 **Cách lấy Gemini API Key miễn phí trong 1 phút:**
> 1. Truy cập [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey).
> 2. Bấm nút **"Create API key"**.
> 3. Copy chuỗi khóa và dán vào mục `"gemini_api_key"` ở trên.
> *(Bot có tính năng tự động nạp cấu hình mới ngay lập tức mà không cần khởi động lại!)*

---

### 🔹 BƯỚC 3: Khởi Động Bot

Bạn có 3 cách để khởi động Bot:

| Cách thực hiện | Thao tác | Mô tả |
| :--- | :--- | :--- |
| **Cách 1 (Nhanh nhất)** | Nhấp đúp chuột vào file [**`start_telegram_bot.bat`**](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/start_telegram_bot.bat) | Mở cửa sổ Console theo dõi trực tiếp nhật ký gửi/nhận lệnh. |
| **Cách 2 (Từ PowerShell)** | Chạy lệnh: `.\mes.ps1 bot` | Khởi động thông qua CLI Hub trung tâm của MES. |
| **Cách 3 (Chạy ngầm ẩn)** | Nhấp đúp chuột vào file [**`start_telegram_bot_hidden.vbs`**](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/start_telegram_bot_hidden.vbs) | Bot chạy hoàn toàn dưới nền, không hiện bất kỳ cửa sổ nào. |

---

### 🔹 BƯỚC 4: Thiết Lập Laptop Không Bị Ngủ Khi Gập Màn Hình

Để bạn có thể gập màn hình laptop lại và mang máy để ở bàn làm việc hoặc cất vào ba lô (khi có cắm sạc/wifi) mà bot vẫn nhận lệnh:

1. Nhấn phím `Windows` ➔ Gõ **Control Panel** ➔ Chọn **Power Options**.
2. Ở cột bên trái, bấm vào **"Choose what closing the lid does"** (Chọn thao tác khi gập nắp máy).
3. Tại dòng **When I close the lid**:
   - Cột **On battery** (Dùng pin): Đổi sang **`Do nothing`**.
   - Cột **Plugged in** (Cắm sạc): Đổi sang **`Do nothing`**.
4. Bấm nút **Save changes** để hoàn tất.

---

## 📖 3. Bảng Tra Cứu Lệnh Điều Khiển Từ Điện Thoại (Cheat Sheet)

Khi mở Telegram và nhắn tin cho Bot của bạn, bạn có thể sử dụng các cú pháp sau:

| Lệnh gửi từ điện thoại | Hành động của Hệ thống MES | Mục đích sử dụng thực tế |
| :--- | :--- | :--- |
| `/help` hoặc `/start` | Hiển thị menu hướng dẫn | Xem lại các lệnh khi quên |
| `/trace <Mã_Lot>` | Chạy **Golden Query 360°** (`.\mes.ps1 trace`) | Quét sạch lịch sử Lot, công đoạn Routing hiện tại, tồn kho, thùng box |
| `/health` | Chạy **Morning Health Check** (`.\mes.ps1 health`) | Quét nhanh danh sách Lot bị HOLD, WIP quá 24h, Box dở dang |
| `/screen <Mã_Màn_Hình>` | Debug màn hình (`.\mes.ps1 screen`) | Tra cứu Stored Procedure chính, các bảng DB và logic của màn hình B530, B540... |
| `/find <Từ_Khóa>` | Tra cứu tài liệu (`.\mes.ps1 find`) | Tra cứu nhanh nghiệp vụ trong 78+ file Markdown nội bộ |
| `/check` | Kiểm tra kết nối DB (`.\mes.ps1 check`) | Kiểm tra tình trạng thông mạng tới `dbserver.hycap.co.kr` |
| `<Gửi text bất kỳ>` | Tự động tìm kiếm tài liệu KB | Dành cho việc tra cứu nhanh các lỗi hoặc thuật ngữ sản xuất |

---

## 🛠️ 4. Xử Lý Sự Cố & Câu Hỏi Thường Gặp (FAQs)

### Q1: Bot không trả lời tin nhắn trên điện thoại?
- **Nguyên nhân 1:** Chưa điền đúng `bot_token` hoặc file cấu hình `tools\telegram_config.json` bị lỗi cú pháp JSON.
- **Nguyên nhân 2:** Chat ID trên điện thoại khác với số đã điền trong `allowed_chat_ids` (hãy kiểm tra lại bằng bot `@userinfobot`).
- **Nguyên nhân 3:** Laptop bị mất mạng Internet hoặc máy bị rơi vào chế độ Sleep do chưa chỉnh mục Power Options.

### Q2: Muốn dừng bot đang chạy ngầm thì làm sao?
- Mở **Task Manager** (nhấn `Ctrl + Shift + Esc`).
- Tìm tiến trình **Python** (hoặc `python.exe`) và bấm **End Task**.
- Hoặc trong PowerShell gõ: `Stop-Process -Name "python" -Force`.

### Q3: Muốn cho bot tự động chạy mỗi khi bật máy tính?
- Nhấn tổ hợp phím `Windows + R`, gõ: `shell:startup` rồi nhấn Enter.
- Tạo một Shortcut (phím tắt) của file [`start_telegram_bot_hidden.vbs`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/start_telegram_bot_hidden.vbs) và dán vào thư mục này.
- Kể từ lần khởi động máy tiếp theo, Bot sẽ tự động chạy ngầm mà không cần bạn làm thêm gì.

---

## 📂 5. Danh Sách Các File Đã Được Tạo Trong Hệ Thống

1. [**`tools\mes_telegram_bot.py`**](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/tools/mes_telegram_bot.py): Script điều phối chính kết nối Telegram API và CLI Hub.
2. [**`tools\telegram_config.json`**](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/tools/telegram_config.json): File lưu trữ Bot Token và Chat ID bảo mật.
3. [**`start_telegram_bot.bat`**](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/start_telegram_bot.bat): File khởi động nhanh có hiển thị cửa sổ theo dõi log.
4. [**`start_telegram_bot_hidden.vbs`**](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/start_telegram_bot_hidden.vbs): File khởi động ngầm hoàn toàn không hiện cửa sổ.
5. [**`mes.ps1`**](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/mes.ps1): Đã tích hợp sẵn lệnh `.\mes.ps1 bot`.
