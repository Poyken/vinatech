# 🛡️ VINATECH DATABASE WORKSPACE RULES (DATABASE)

> **Single Source of Truth:** `.agents/rules/00_vinatech_database_rules.md`  
> **Master Index:** `MASTER_INDEX.md`  
> **Topology Map:** `SYSTEM_INTEGRATION_MAP.md`

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
- **RULE 0:** CẤM chạy `SELECT` trước khi tra cứu `.\db.ps1 find "<Keyword>"` hoặc L1 `DATABASE_MATRIX.json`.
- **RULE 1:** SELECT-ONLY TRÊN TẤT CẢ 15 CƠ SỞ DỮ LIỆU. Cấm DML/DDL trực tiếp.
- **RULE 2:** Luôn chỉ định đúng `-Profile` khi truy vấn để tránh nhầm môi trường.
- **RULE 5:** Bắt buộc gắn `WITH(NOLOCK)` và giới hạn `TOP 50` trên mọi câu SELECT.
- **RULE 14 (TỐC ĐỘ):** Tối đa 1-2 tool calls/câu hỏi. Lấy xong data là DỪNG NGAY (<5-10s).

## ⚡ CLI HUB: `.\db.ps1`
- `list` — Liệt kê 15 CSDL và Profiles
- `health` — Kiểm tra kết nối & độ trễ 15 CSDL
- `query <Profile> "<SQL>"` — SELECT an toàn (tự động NOLOCK, TOP 50)
- `schema <Profile> <Table>` — Tra cứu cấu trúc bảng & kiểu dữ liệu
- `find "<Keyword>"` — Tra cứu siêu tốc L1 Cache + 20+ file KB
- `trace <KeyType> <Value>` — Truy vết mã liên CSDL (PO, Lot, Accounting)
