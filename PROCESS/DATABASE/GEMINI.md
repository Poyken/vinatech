# 🛡️ VINATECH DATABASE WORKSPACE RULES (DATABASE)

> **Single Source of Truth:** `..\.agents\rules\00_vinatech_master_rules.md` & `.agents/rules/00_vinatech_database_rules.md`  
> **Master Command Hub:** `.\ops.ps1` (Toàn hệ thống) & `.\db.ps1` (15 CSDL)

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)
- **RULE 0 (ZERO SELECT WITHOUT PRIOR KB):** CẤM chạy `SELECT` trước khi tra cứu `.\db.ps1 find "<Keyword>"` hoặc L1 `DATABASE_MATRIX.json`.
- **RULE 1 (SELECT-ONLY ON PRODUCTION):** SELECT-ONLY TRÊN TẤT CẢ 15 CƠ SỞ DỮ LIỆU. Cấm DML/DDL trực tiếp.
- **RULE 2 (PROFILE ISOLATION):** Luôn chỉ định đúng `-Profile` khi truy vấn để tránh nhầm môi trường.
- **RULE 5 (NOLOCK ENFORCEMENT):** Bắt buộc gắn `WITH(NOLOCK)` và giới hạn `TOP 50` trên mọi câu SELECT.
- **RULE 14 (TỐC ĐỘ PHẢN HỒI <5-10s):** Tối đa 1-2 tool calls/câu hỏi. Lấy xong data DỪNG NGAY.
- **RULE 18 (ĐỊNH DANH IT):** Mọi can thiệp hoặc script bắt buộc ghi `Author = 'vanduc'` và `ChangeUserID = 'vanduc'`.
- **RULE 21 (TOOL CHUYÊN DỤNG - 0 BLIND SQL LOOPING):** Bắt buộc dùng `.\db.ps1 [schema|sp|find|list]` hoặc `.\ops.ps1`. Cấm SELECT dò dẫm.

## ⚡ CLI HUBS LIÊN KẾT
- `.\ops.ps1 health` — Morning 360 Patrol quét toàn bộ 5 hệ thống
- `.\db.ps1 list` — Liệt kê 15 CSDL và Profiles
- `.\db.ps1 health [-Detail]` — Kiểm tra kết nối & độ trễ 15 CSDL
- `.\db.ps1 schema -Profile <P> -Table <T>` — Tra cứu cấu trúc bảng & kiểu dữ liệu
- `.\db.ps1 sp -Profile <P> -Name <N> -Def` — Đọc mã nguồn Stored Procedure
- `.\db.ps1 find "<Keyword>"` — Tra cứu siêu tốc L1 Cache (11.509 Tables, 66.540 SPs)
