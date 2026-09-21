# 🛡️ VINATECH DATABASE AGENT WORKSPACE RULES (V1.0)

> **Single Source of Truth:** `DATABASE/AI_AGENT_CONFIG/RULES.md` & `GEMINI.md`  
> **CLI Hub:** `.\db.ps1`

## CÁC QUY TẮC BẤT BIẾN:

### 1. RULE 0 - ZERO SELECT WITHOUT PRIOR KB (BẤT BIẾN)
- Luôn tra cứu L1 Cache `DATABASE_MATRIX.json` qua `.\db.ps1 find "<Keyword>"` hoặc đọc tài liệu `DATABASE_KNOWLEDGE_BASE/` trước khi chạy bất kỳ câu lệnh SQL `SELECT` nào trên máy chủ Production.

### 2. RULE 1 - SELECT-ONLY TRÊN TẤT CẢ 15 CƠ SỞ DỮ LIỆU
- Nghiêm cấm chạy bất kỳ câu lệnh DML (`INSERT`, `UPDATE`, `DELETE`, `MERGE`) hoặc DDL (`DROP`, `ALTER`, `TRUNCATE`) trực tiếp.
- Chỉ được phép thực thi các câu lệnh đọc dữ liệu (`SELECT`) có giới hạn số dòng (`TOP 50`) và có khóa chống nghẽn `WITH(NOLOCK)`.

### 3. RULE 2 - ĐÚNG PROFILE CƠ SỞ DỮ LIỆU
- Luôn chỉ định rõ tham số `-Profile` khi truy vấn để tránh chạy nhầm CSDL:
  - `SmartFactoryV2`: Sản xuất MES
  - `SmartFramework`: Phân quyền MES
  - `Groupware`: CSDL VINATECH_GROUP
  - `ERP`: CSDL Douzone iU (NEOE)
  - `Bizbox`: CSDL DZICUBE
  - `POP`: CSDL VINATECH_POP
  - `Andon`: CSDL AndonDB
  - `SSO`: CSDL VINATECH_RESTFUL
  - `WebSocket`: CSDL VINATECH_WEBSOCKET
  - `Spreadsheet`: CSDL VINATECH_SPREADSHEET
  - `WCMS`: CSDL WCMS_STANDARD_NEW
  - `Incubator`: CSDL SmartFactoryIncubator
  - `KSOX`: CSDL VINATECH_DATA_KSOX
  - `LegacyERP`: CSDL erpdb (Archive)
  - `StreamDocs`: CSDL streamdocs

### 4. RULE 4 - SURGICAL RETRIEVAL & L1 CACHE FIRST
- Ưu tiên đọc `AI_AGENT_CONFIG/DATABASE_MATRIX.json` (<0.001s, ~150 tokens) thay vì đọc tràn lan toàn bộ các file Markdown lớn.

### 5. RULE 5 - ANTI-LOCK CROSS-DATABASE QUERIES
- Khi thực hiện JOIN giữa 2 cơ sở dữ liệu (ví dụ `SmartFactoryV2` và `NEOE`), BẮT BUỘC phải đặt `WITH(NOLOCK)` trên từng bảng trong câu query để tránh Distributed Deadlock.

### 6. RULE 10 - ZERO JUNK SCRIPTS & WORKSPACE CLEANLINESS
- Không tạo các file `.ps1` rời rạc ở thư mục gốc. Tất cả các thao tác đều chạy qua CLI Hub `.\db.ps1`. Mọi script tạm bắt buộc đặt trong `tools/scratch/` và phải dọn dẹp sau ca làm việc.

### 7. RULE 14 - TỐC ĐỘ PHẢN HỒI CAO (<5-10s)
- Tối đa 1-2 tool calls cho mỗi yêu cầu tra cứu/kiểm tra. Lấy xong data là DỪNG NGAY LẬP TỨC và tổng hợp báo cáo cho người dùng.
