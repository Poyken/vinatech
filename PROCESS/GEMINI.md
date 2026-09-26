# 🛡️ VINATECH ENTERPRISE PROCESS WORKSPACE (MASTER RULES)

> **Single Source of Truth:** `.agents/rules/00_vinatech_master_rules.md`
> **Primary Command Hubs:** `.\pop.ps1` (POP Kiosk), `.\mes.ps1` (Core MES), `.\gw.ps1` (Groupware), `.\db.ps1` (15 Databases), `.\ksys.ps1` (K-System)

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
1. **RULE 0 (ZERO SELECT WITHOUT PRIOR KB):** CẤM chạy `SELECT` trước khi tra cứu L1 Cache (`.\pop.ps1 find`, `.\mes.ps1 find`, `.\gw.ps1 find`, `.\db.ps1 find`) hoặc tài liệu KB tương ứng.
2. **RULE 1 (SELECT-ONLY ON PRODUCTION):** Tuyệt đối chỉ đọc dữ liệu trên Production CSDL. Cấm chạy `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE` trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK` và được triển khai qua `deploy_tool.ps1` hoặc `.\mes.ps1 deploy`.
3. **RULE 6 (GOLDEN QUERY 360° FIRST):** Dùng Golden Query trong lần kiểm tra đầu tiên:
   - Truy vết POP Kiosk & NVL BOM: `.\pop.ps1 trace "<Keyword>"` hoặc `.\pop.ps1 nvl "<Lot/PO>"`
   - Truy vết Sản xuất MES & Vòng đời Lot: `.\mes.ps1 trace "<LotID>"`
   - Truy vết PO / Chứng từ Groupware: `.\gw.ps1 trace "<PO/DocCode>"`
   - Truy vết huyết mạch dữ liệu liên hệ thống: `.\mes.ps1 lineage "<Lot/PO>"` hoặc `.\db.ps1 lineage -Type <T> -Value <V>`
4. **RULE 4 (SURGICAL RETRIEVAL):** Ưu tiên L1 Cache JSON (<0.001s, ~150 tokens) trước khi đọc cả file Markdown lớn.
5. **RULE 14 (TỐC ĐỘ PHẢN HỒI):** Tối đa 1-2 tool calls trúng đích/câu hỏi. Lấy xong thông tin cốt lõi DỪNG NGAY và trả lời (<5-10s).
6. **RULE 15 (TRÚNG ĐÍCH):** CẤM tự ý tạo script hotfix hay plan khi User chỉ yêu cầu kiểm tra/tra cứu.
7. **RULE 20 (POP BẤT BIẾN - EA PLAYBOOK):** Đổi máy nhầm Kiosk BẮT BUỘC UPDATE CẢ 2 BẢNG (`STB_ProdRouteHist` VÀ `MongoToMesPerformance`). Lỗi "Already completed" xóa dòng thừa trong `STB_ProdRouteHist` & `STB_ProdRouteWorkerHist`. Nút Cắt điện cực mờ do độ dày `< 100`. Cuộn BTP tối đa 3 LOTNO. Máy kẹt ACTIVE giải phóng qua `.\pop.ps1 unlock <Machine> -Deploy` hoặc `.\pop.ps1 release-machines -Force`.
8. **RULE 21 (BẮT BUỘC LUÔN DÙNG TOOL CHUYÊN DỤNG - TUYỆT ĐỐI CẤM QUERY DÒ DẪM):** BẮT BUỘC dùng Tool CLI Hubs (`.\mes.ps1`, `.\pop.ps1`, `.\gw.ps1`, `.\ksys.ps1`) cho mọi tác vụ tra cứu, phân tích, truy vết. Tuyệt đối CẤM dùng `.\db.ps1 query` để mò mẫm cấu trúc bảng, tên menu hay thử sai liên tục (0 blind SQL looping). Muốn biết bảng/menu/trường ➔ Tra cứu L1 Cache (`POP_MATRIX.json`, `QUICK_MATRIX.json`, `KSYSTEM_MATRIX.json`, `GW_FORM_MATRIX.json`) hoặc `find`. Giới hạn cứng tối đa 1-2 tool calls.



## ⚡ HỆ THỐNG CLI HUBS TẠI WORKSPACE ROOT
- `.\mes.ps1` ➔ 🌟 **ALL-IN-ONE MASTER CLI HUB (CÔNG CỤ TOÀN NĂNG)**: Tích hợp đầy đủ mọi phân hệ:
  * Smart Auto-Router tự nhận diện Lot/PO/Screen/Machine/Lỗi (<0.01s)
  * Trace 360° siêu tốc tích hợp tiến độ đóng gói POP (`VINA_PACKING_REMAIN_QTY`), BOM NVL, Tồn kho xưởng, Thiết bị, PQC (<2s)
  * Kiểm toán Pre-flight file Excel `.\mes.ps1 validate-excel <File.xlsx> -Route <F330|B598>` chống lệch cột (E04/E05 vào StartPeriod) (<1s)
  * Tra cứu nhanh đơn giá & tỷ lệ cân hardcode B598 `.\mes.ps1 b598-price [-Target <Code>]` (<1s)
  * Soi real-time khóa blocking & deadlock trên 15 CSDL `.\mes.ps1 locks [-Profile <Name>]` (<2s)
  * Dọn dẹp & tiêu diệt zombie process ngầm chống quá tải CPU / rú quạt `.\mes.ps1 clean`
  * Chẩn đoán 4 Dòng Vàng, BOM NVL & Tồn kho, Groupware & ERP, Toàn bộ Hotfixes bọc Transaction.
- `.\pop.ps1 [trace|nvl|unlock|release-machines|sync|readiness|audit|find]` ➔ **Kiosk POP tại xưởng (NVL BOM, Tồn kho ROUTE_VN_WH, Mở khóa máy, Sync)**
- `.\gw.ps1 [trace|form|find|routine|chain|health|check|query|audit]` ➔ **Groupware Bizbox & Duyệt Chứng Từ ERP NEOE**
- `.\db.ps1 [list|health|stats|sp|schema|query|find|jobs|triggers|index|crossdb|lineage|auditkb]` ➔ **Quản Trị 15 CSDL Multi-DB Engine**
- `.\ksys.ps1 [trace|find|module|schema|bridge|health]` ➔ **Hợp Nhất ERP K-System Ace**
