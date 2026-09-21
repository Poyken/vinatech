# 🛡️ VINATECH GROUPWARE WORKSPACE RULES (GROUPWARE)

> **Single Source of Truth:** `.agents/rules/00_groupware_rules.md`

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
- **RULE 0:** CẤM chạy `SELECT` trước khi tra cứu `.\gw.ps1 find "<Keyword>"` hoặc KB modules.
- **RULE 2 (STATE INTEGRITY):** CẤM tự ý UPDATE `DOCUMENT_SAVE_STATE = '008'` trên SQL vì sẽ làm hỏng cỗ máy tự động đồng bộ sang ERP Douzone (NEOE).
- **RULE 9 (TỐC ĐỘ):** Tối đa 1-2 tool calls/câu hỏi. Lấy xong thông tin cốt lõi là DỪNG NGAY và trả lời (<5-10s).
- **RULE 10 (TRÚNG ĐÍCH):** CẤM tự ý tạo script hotfix hay can thiệp CSDL khi User chỉ yêu cầu kiểm tra hoặc hỏi nguyên nhân.

## ⚡ CLI HUB: `.\gw.ps1`
- `find "<Keyword>"` — Tra cứu L1 Form Matrix (<0.001s) & 12+ file KB
- `trace "<Target>"` — Golden Query 360° truy vết PO/Mã văn bản/Nhân sự xuyên GW-ERP-MES
- `form "<FormID>"` — Soi cấu trúc chi tiết biểu mẫu (Bảng, tuyến duyệt, ERP mapping, lỗi thường gặp)
- `health [-Detail]` — Morning Health Check quét phiếu chờ duyệt, kẹt >48h, thống kê trạng thái
- `check [-Target <Profile>]` — Kiểm tra kết nối CSDL Groupware, ERP, MES, SSO
- `query "<SELECT>"` — Chạy câu SELECT an toàn trên CSDL Groupware (NOLOCK)
- `audit` — Kiểm toán danh mục bảng và thực trạng CSDL
