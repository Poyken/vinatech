# 🛡️ VINATECH ENTERPRISE PROCESS WORKSPACE (MASTER RULES)

> **Single Source of Truth:** `.agents/rules/00_vinatech_master_rules.md`
> **Primary Command Hubs:** `.\mes.ps1` (MES & POP), `.\gw.ps1` (Groupware), `.\db.ps1` (15 Databases)

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
1. **RULE 0 (ZERO SELECT WITHOUT PRIOR KB):** CẤM chạy `SELECT` trước khi tra cứu L1 Cache (`.\mes.ps1 find`, `.\gw.ps1 find`, `.\db.ps1 find`) hoặc tài liệu KB tương ứng.
2. **RULE 1 (SELECT-ONLY ON PRODUCTION):** Tuyệt đối chỉ đọc dữ liệu trên Production CSDL. Cấm chạy `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE` trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK` và được triển khai qua `deploy_tool.ps1`.
3. **RULE 6 (GOLDEN QUERY 360° FIRST):** Dùng Golden Query trong lần kiểm tra đầu tiên:
   - Truy vết Lot / Thiết bị / Thùng: `.\mes.ps1 trace "<LotID>"`
   - Truy vết POP Kiosk: `.\mes.ps1 pop-trace "<Keyword>"`
   - Truy vết PO / Chứng từ: `.\gw.ps1 trace "<PO/DocCode>"`
   - Truy vết huyết mạch dữ liệu: `.\db.ps1 lineage -Type <T> -Value <V>`
4. **RULE 4 (SURGICAL RETRIEVAL):** Ưu tiên L1 Cache JSON (<0.001s, ~150 tokens) trước khi đọc cả file Markdown lớn.
5. **RULE 14 (TỐC ĐỘ PHẢN HỒI):** Tối đa 1-2 tool calls trúng đích/câu hỏi. Lấy xong thông tin cốt lõi DỪNG NGAY và trả lời (<5-10s).
6. **RULE 15 (TRÚNG ĐÍCH):** CẤM tự ý tạo script hotfix hay plan khi User chỉ yêu cầu kiểm tra/tra cứu.

## ⚡ 3 CLI HUBS TẠI WORKSPACE ROOT
- `.\mes.ps1 [trace|pop-trace|screen|find|health|pop-readiness|release-machines|new-fix|deploy]`
- `.\gw.ps1 [trace|form|find|routine|chain|health|check|query|audit]`
- `.\db.ps1 [list|health|stats|sp|schema|query|find|jobs|triggers|index|crossdb|lineage|auditkb]`
