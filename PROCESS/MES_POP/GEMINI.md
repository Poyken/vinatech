# 🛡️ VINATECH MES WORKSPACE RULES (MES_POP)

> **Single Source of Truth:** `.agents/rules/00_vinatech_rules.md`

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
- **RULE 0:** CẤM chạy `SELECT` trước khi tra cứu `.\mes.ps1 find "<Keyword>"` hoặc KB modules.
- **RULE 14 (TỐC ĐỘ PHẢN HỒI THẦN TỐC < 3-5s):** 
  - Khi User gửi mã Lot: Gọi DUY NHẤT 1 tool `.\mes.ps1 trace "<LotID>"` ➔ Có kết quả là DỪNG NGAY và trả lời.
  - Khi User hỏi về mã lỗi / màn hình: Tra cứu L1 Cache `QUICK_MATRIX.json` (Zero Tool Call hoặc tối đa 1 tool `.\mes.ps1 find`) ➔ Trả lời ngay tức thì.
  - TUYỆT ĐỐI CẤM chạy chuỗi 2-5 tool gọi dò dẫm, cấm viết văn dài dòng lý thuyết sách giáo khoa.
- **RULE 15 (TRÚNG ĐÍCH):** CẤM tự ý tạo script hotfix hay lập plan khi User chỉ yêu cầu kiểm tra/hỏi nguyên nhân.
- **RULE 16 (KHÔNG DÙNG TRÌNH DUYỆT / KHÔNG HTML):** Môi trường vận hành không thể mở file `.html` hay trình duyệt. Tuyệt đối KHÔNG tạo web app, KHÔNG dùng `Start-Process http://...`, 100% vận hành qua Console CLI, REPL Shell, Terminal, Python và Telegram Bot.

## ⚡ KHUÔN MẪU PHẢN HỒI LỖI CHUẨN MỰC ("4 DÒNG VÀNG"):
Mọi câu trả lời khi nhận báo lỗi sự cố BẮT BUỘC theo 4 phần ngắn gọn, dứt khoát:
1. 🎯 **Nguyên nhân gốc rễ (Root Cause):** Tên màn hình, Stored Procedure, cơ chế gây lỗi.
2. 📍 **Hiện trạng thực tế:** Lot đang ở đâu, kẹt cái gì, bảng nào.
3. 🛠️ **Cách OP tự xử lý trên giao diện (Workaround):** Các bước 1-2-3 cho công nhân/tổ trưởng tại xưởng.
4. ⚡ **SQL Hotfix chuẩn (Nếu IT phải can thiệp):** Đã bọc `BEGIN TRAN...ROLLBACK`, có NOLOCK, ChangeUserID='vanduc'.

## ⚡ CLI HUB: `.\mes.ps1`
- `shell` — Bật Persistent REPL Shell tức thời (<0.05s response, nạp sẵn L1 Cache & DB conn trong RAM)
- `diagnose "<Text/Lot>"` — Master Auto-Diagnostic tức thời 1-Shot (<1s) xuất đúng 4 Dòng Vàng
- `trace "<LotID>"` — Golden Query 360° (Single Round-Trip)
- `pop-trace "<Keyword>"` — Truy vết chuyên sâu Kiosk POP (Sync, Phế, Máy kẹt)
- `find "<Keyword>"` — Tra cứu L1 Cache (<0.001s)
- `health` — Morning Health Check quét Lot HOLD, WIP 24h
- `watchdog-hidden` / `watchdog-status` — Auto-Pilot tuần tra 24/7 & tự động bắn alert Telegram
- `release-machines [-Force]` — Giải phóng máy POP kẹt lock
- `pop-readiness` / `pop-audit` — Kiểm toán & đối soát Kiosk POP
