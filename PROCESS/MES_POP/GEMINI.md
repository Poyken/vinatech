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
- **RULE 17 (CẤM OVER-ENGINEERING / LÀM ĐÚNG PHẠM VI):** Tuyệt đối chỉ làm đúng nội dung được yêu cầu. CẤM tự ý sửa file ngoài phạm vi hoặc làm thừa.
- **RULE 18 (ĐỊNH DANH IT & CHUẨN AUTHOR/CHANGEUSERID):** Người dùng là Kỹ sư IT (Nguyen Van Duc - EA Team). Mọi can thiệp CSDL, Hotfix, Stored Procedure, Script hay comment BẮT BUỘC dùng `Author = 'vanduc'` và `ChangeUserID = 'vanduc'`. CẤM dùng `Antigravity` hay `it_hotfix`.
- **RULE 19 (TRIỆT TIÊU LỖI FONT TIẾNG VIỆT & MA TRẬN TIỀN LỆ):** File `.ps1`, `.sql`, `.json` phải có UTF-8-BOM. Tuyệt đối không để lỗi font. Luôn tra cứu tiền lệ trong L1 Cache (`historical_precedents` & `RULE_CATALOG`) trước khi chẩn đoán.
- **RULE 20 (5 NGUYÊN TẮC BẤT BIẾN VẬN HÀNH POP - EA PLAYBOOK):**
  1. *Đổi máy nhầm Kiosk:* BẮT BUỘC UPDATE đồng thời CẢ 2 BẢNG `STB_ProdRouteHist` VÀ `MongoToMesPerformance`.
  2. *Lỗi "Already completed in MES":* Do WinForm sinh sẵn dòng kế tiếp (`CompleteRoute = 1`), xóa dòng thừa trong `STB_ProdRouteHist` & `STB_ProdRouteWorkerHist`.
  3. *Nút Cắt điện cực mờ:* Do logic khóa nếu `MaterialThickness < 100` trong `STB_MaterialMaster`.
  4. *Nạp cuộn BTP:* Tối đa 2 LOTNO cho 1 mã cắt.
  5. *Kẹt máy ACTIVE POP:* Giải phóng qua `VINA_EQUIPMENT_MAPPING.MAPPING_STATUS = 'RELEASED'` (`.\mes.ps1 release-machines -Force`).


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
- `lineage "<Lot/PO>"` — Truy vết huyết mạch 3 trụ cột (PO Master ➔ Kho NVL ➔ Tiến độ MES ➔ Kiosk POP)
- `pop-trace "<Keyword>"` — Truy vết chuyên sâu Kiosk POP (Sync, Phế, Máy kẹt)
- `fix-movedate -Lots "..." -TargetDate "yyyy-MM-dd"` — Sinh Hotfix chuyển ngày chốt B782 chuẩn 10h00 AM (Author vanduc)
- `fix-electrode -Lots "..." [-Type Slitting|Mixing]` — Sinh Hotfix xóa cuộn/mẻ trộn B552 & reset IsLineInput
- `fix-rollback -Lots "..." [-Route "..."]` — Sinh Hotfix rollback lượt chốt B530 / POP Kiosk
- `weekly-report [-StartDate "..." -EndDate "..."]` — Tự động soạn Báo Cáo Tuần IT (CSV tại Desktop/thanks_and_ojt_reports)
- `find "<Keyword>"` — Tra cứu L1 Cache (<0.001s)
- `health` — Morning Health Check quét Lot HOLD, WIP 24h
- `watchdog-hidden` / `watchdog-status` — Auto-Pilot tuần tra 24/7 & tự động bắn alert Telegram
- `release-machines [-Force]` — Giải phóng máy POP kẹt lock hàng loạt theo Line
- `unlock "<Machine>" [-Deploy]` — Mở khóa giải phóng máy POP Kiosk cụ thể tức thời 1-Shot (<0.5s)
- `pop-readiness` / `pop-audit` — Kiểm toán & đối soát Kiosk POP
