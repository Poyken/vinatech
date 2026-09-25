# 🛡️ VINATECH MES WORKSPACE RULES (MES_POP)

> **Single Source of Truth:** `.agents/rules/00_vinatech_rules.md`
> **Primary Command Hubs:** `.\pop.ps1` (POP Kiosk) & `.\mes.ps1` (Core MES Production)

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
- **RULE 0:** CẤM chạy `SELECT` trước khi tra cứu `.\pop.ps1 find` / `.\mes.ps1 find` hoặc KB modules.
- **RULE 14 (TỐC ĐỘ PHẢN HỒI THẦN TỐC < 3-5s):** 
  - Khi User hỏi về Kiosk POP / Nạp NVL: Gọi `.\pop.ps1 nvl "<Lot/PO>"` hoặc `.\pop.ps1 trace "<Target>"` ➔ Có data là DỪNG NGAY.
  - Khi User hỏi về Sản xuất MES / Chốt công đoạn: Gọi DUY NHẤT 1 tool `.\mes.ps1 trace "<LotID>"` ➔ Có kết quả là DỪNG NGAY.
  - Khi User hỏi về mã lỗi / màn hình: Tra cứu L1 Cache `QUICK_MATRIX.json` / `POP_MATRIX.json` ➔ Trả lời ngay tức thì.
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
  4. *Nạp cuộn BTP:* Tối đa 3 LOTNO cho 1 mã cắt (Đã nâng cấp từ định mức cũ 2 LOTNO).
  5. *Kẹt máy ACTIVE POP:* Giải phóng qua `.\pop.ps1 unlock <Machine> -Deploy` hoặc `.\pop.ps1 release-machines -Force`.


## ⚡ KHUÔN MẪU PHẢN HỒI LỖI CHUẨN MỰC ("4 DÒNG VÀNG"):
Mọi câu trả lời khi nhận báo lỗi sự cố BẮT BUỘC theo 4 phần ngắn gọn, dứt khoát:
1. 🎯 **Nguyên nhân gốc rễ (Root Cause):** Tên màn hình, Stored Procedure, cơ chế gây lỗi.
2. 📍 **Hiện trạng thực tế:** Lot đang ở đâu, kẹt cái gì, bảng nào.
3. 🛠️ **Cách OP tự xử lý trên giao diện (Workaround):** Các bước 1-2-3 cho công nhân/tổ trưởng tại xưởng.
4. ⚡ **SQL Hotfix chuẩn (Nếu IT phải can thiệp):** Đã bọc `BEGIN TRAN...ROLLBACK`, có NOLOCK, ChangeUserID='vanduc'.

## ⚡ 1. ALL-IN-ONE MASTER CLI HUB: `.\mes.ps1` (CÔNG CỤ TOÀN NĂNG HỢP NHẤT)
- `trace "<LotID>"` — Golden Query 360° toàn diện (Lot, Line, Thiết bị, Thùng)
- `diagnose "<Text/Lot/Screen>"` — Master Auto-Diagnostic tức thời 1-Shot (<1s) xuất đúng 4 Dòng Vàng
- `lineage "<Lot/PO>"` — Truy vết huyết mạch 3 trụ cột (PO Master ➔ Kho NVL ➔ Tiến độ MES ➔ Kiosk POP)
- `nvl <Lot/PO>` / `bom <Lot/PO>` — Soi định mức BOM NVL, AltCode và tồn khả dụng `ROUTE_VN_WH` vs `MAIN_VN_WH` (<1s)
- `gw <PO/DocCode>` — Truy vết tờ trình thay thế vật tư Groupware, phê duyệt & ERP NEOE (<2.5s)
- `unlock "<Machine>" [-Deploy]` — Mở khóa giải phóng máy POP Kiosk cụ thể tức thời 1-Shot (<0.5s)
- `release-machines [-Force]` — Giải phóng toàn bộ máy POP kẹt lock hàng loạt theo Line
- `sync [-Line <Line>]` — Quét phát hiện các Lot bị kẹt pipeline đồng bộ POP -> MES (`IsDone=1, IsTransferred=0`)
- `swap-machine -Lots "..." -Machine "..."` — Sinh Hotfix đổi máy Kiosk chuẩn Rule 20.1 (Atomic 2 bảng)
- `fix-solution -Lots "..."` — Cấp cứu khôi phục thùng dung dịch điện giải 150kg
- `fix-movedate -Lots "..." -TargetDate "yyyy-MM-dd"` — Sinh Hotfix chuyển ngày chốt B782 chuẩn 10h00 AM (Author vanduc)
- `fix-electrode -Lots "..." [-Type Slitting|Mixing]` — Sinh Hotfix xóa cuộn/mẻ trộn B552 & reset IsLineInput
- `fix-rollback -Lots "..." [-Route "..."]` — Sinh Hotfix rollback lượt chốt B530 / POP Kiosk
- `fix-pop-clone -Lots "..."` — Sinh Hotfix xóa dòng tự sinh `CompleteRoute IS NULL` để mở chốt POP Kiosk
- `fix-cancel-pack -Target "<Lot>" [-BoxId "..."]` — Sinh Hotfix hủy lẻ từng Box/Pack đóng gói (B523/HN523)
- `fix-defect-null -Lots "..."` — Sinh Hotfix chuẩn hóa RepairQty = 0 sửa mất cột NG trên B782
- `fix-lineinput -Lots "..."` — Sinh Hotfix kích hoạt lại IsLineInput = 1 cho Lot
- `deploy <file.sql> [-Force]` — Triển khai Hotfix qua Transaction an toàn có Pre-flight backup
- `screen <ScreenID>` — Debug màn hình MES WinForm (Grid, SP, Bảng liên quan: B530, B540, B552, B781, B782...)
- `sp <SP_Name>` — Tải SP gốc mới nhất từ DB về local để phân tích
- `health` — Morning Health Check quét Lot HOLD, WIP 24h
- `locks [-Profile <Name>]` — Soi real-time cac khoa blocking, page U-locks va deadlocks tren 15 CSDL (<2s)
- `b598-price [-Target <Code>]` — Soi nhanh don gia USD & ty le can hardcode trong SP usp_vn_showproductionerror (<1s)
- `validate-excel <File.xlsx> [-Route F330|B598]` — Kiem toan pre-flight file Excel, bat loi lech cot (Ma khay E04, E05 vao StartPeriod) (<1s)
- `clean` — Don dep scratch workspace, quet & tieu diet zombie background process bao ve CPU chong ru quat
- `weekly-report [-StartDate "..." -EndDate "..."]` — Tự động soạn Báo Cáo Tuần IT (CSV tại Desktop/thanks_and_ojt_reports)
- `find "<Keyword>"` — Tra cứu L1 Quick Matrix 95 màn hình MES (<0.001s) và toàn bộ KB

## ⚡ 2. POP KIOSK CHUYÊN DỤNG: `.\pop.ps1` (Mặt Trận Xưởng & Kiosk)
- `nvl <Lot/PO>` / `bom <Lot/PO>` — Soi nhanh BOM NVL và tồn kho
- `trace <Target>` — Golden Query 360 Kiosk
- `unlock "<Machine>"` / `release-machines` — Mở khóa thiết bị Kiosk
- `sync` / `readiness` / `audit` — Đồng bộ & kiểm toán Kiosk POP Web

