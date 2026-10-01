# 🛡️ VINATECH GROUPWARE WORKSPACE RULES (GROUPWARE)

> **Single Source of Truth:** `..\.agents\rules\00_vinatech_master_rules.md` & `.agents/rules/00_groupware_rules.md`
> **Master Command Hub:** `.\ops.ps1` (Toàn hệ thống) & `.\gw.ps1` (Phân hệ Groupware)

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
- **RULE 0 (ZERO SELECT WITHOUT PRIOR KB):** CẤM chạy `SELECT` trước khi tra cứu `.\gw.ps1 find "<Keyword>"` hoặc L1 `GW_FORM_MATRIX.json`.
- **RULE 1 (SELECT-ONLY ON PRODUCTION):** Tuyệt đối chỉ đọc dữ liệu trên CSDL `VINATECH_GROUP` và `NEOE`. Mọi can thiệp phải qua Transaction và `Author='vanduc'`.
- **RULE 2 (STATE INTEGRITY):** CẤM tự ý UPDATE `DOCUMENT_SAVE_STATE = '008'` trên SQL vì sẽ làm hỏng cỗ máy tự động đồng bộ sang ERP Douzone (NEOE).
- **RULE 14 (TỐC ĐỘ PHẢN HỒI <5-10s):** Tối đa 1-2 tool calls trúng đích/câu hỏi. Lấy xong data DỪNG NGAY và trả lời.
- **RULE 15 (TRÚNG ĐÍCH):** CẤM tự ý tạo script hotfix khi User chỉ yêu cầu kiểm tra hoặc hỏi nguyên nhân.
- **RULE 18 (ĐỊNH DANH IT):** Mọi can thiệp CSDL hoặc script bắt buộc ghi `Author = 'vanduc'` và `ChangeUserID = 'vanduc'`.
- **RULE 21 (TOOL CHUYÊN DỤNG - 0 BLIND SQL LOOPING):** Bắt buộc dùng `.\gw.ps1 [trace|form|find]` hoặc `.\ops.ps1`. Cấm SELECT dò dẫm.
- **RULE 22 (ĐỊNH DANH SỰ CỐ):** Tách bạch rõ ràng sự cố Groupware (GW) vs POP vs MES.

## ⚡ CLI HUBS LIÊN KẾT
- `.\ops.ps1 health` — Morning 360 Patrol quét toàn bộ 5 hệ thống
- `.\gw.ps1 trace "<Target>"` — Golden Query 360° truy vết PO/Mã văn bản/Nhân sự xuyên GW-ERP-MES
- `.\gw.ps1 form "<FormID>"` — Soi chi tiết biểu mẫu (FORM_PO, FORM_ARRIVAL, FORM_DAILY_PLAN...)
- `.\gw.ps1 find "<Keyword>"` — Tra cứu L1 Quick Matrix (<0.001s) & 12+ file KB
- `.\gw.ps1 health [-Detail]` — Quét phiếu chờ duyệt, kẹt >48h
