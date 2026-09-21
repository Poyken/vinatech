# 🏠 DATABASE WORKSPACE — MASTER INDEX (Trang Chủ Tri Thức 15 CSDL)

> **Cập nhật:** 2026-09-21  
> **Mục đích:** Kho lưu trữ tri thức, kiến trúc, từ điển dữ liệu và công cụ điều phối cho toàn bộ 15 Cơ sở Dữ liệu Vinatech  
> **Máy chủ trung tâm:** `dbserver.hycap.co.kr,5398`  
> **Nguyên tắc cốt lõi:** SELECT-ONLY & ANTI-LOCK WITH(NOLOCK)

---

## 📂 Cấu Trúc Thư Mục Phân Hệ `DATABASE/`

```
DATABASE/
│
├── 📄 MASTER_INDEX.md                          ← BẠN ĐANG Ở ĐÂY
├── 📄 SYSTEM_INTEGRATION_MAP.md                ← 🌐 BẢN ĐỒ LIÊN KẾT 3 NỀN TẢNG & 15 CSDL
├── 📄 GEMINI.md                                ← 🛡️ QUY TẮC CỐT LÕI AGENT
├── 📄 db_config.json                           # Cấu hình 15 Database Profiles
├── 📄 db.ps1                                   # ⚡ CLI COMMAND HUB ĐIỀU PHỐI CSDL
│
├── 📂 .agents/                                 # Cấu hình Antigravity Agent Workspace
│   ├── AGENTS.md                               # Danh mục Agent chuyên môn
│   ├── hooks.json                              # Safety Hooks
│   ├── rules/                                  # 00_vinatech_database_rules.md, 01_sql_safety_rules.md
│   ├── skills/                                 # vinatech-database-operations, vinatech-cross-system-query
│   └── agents/                                 # db-auditor, schema-inspector
│
├── 📂 AI_AGENT_CONFIG/                         # Cấu hình tri thức nén & L1 Cache
│   ├── README.md                               # Hướng dẫn nạp tri thức
│   ├── RULES.md                                # 10 Quy tắc vàng bất biến
│   ├── KNOWLEDGE.md                            # Cheat sheet 15 CSDL nén gọn
│   ├── LESSONS_LEARNED.md                      # Bài học kinh nghiệm & cạm bẫy truy vấn
│   └── DATABASE_MATRIX.json                    # L1 Cache JSON: 15 CSDL, bảng chính, PK, quan hệ
│
├── 📂 DATABASE_KNOWLEDGE_BASE/                 # 📚 TRI THỨC CHI TIẾT 15 CSDL
│   ├── DB_INDEX.md                             # ← Mục lục tra cứu 15 CSDL
│   ├── DEEP_DIVE_01_PHYSICAL_TOPOLOGY_AND_LINKED_SERVERS.md # 🌐 Mạng lưới Linked Servers & Topology
│   ├── DEEP_DIVE_02_SQL_AGENT_JOBS_AND_DATA_PUMPS.md        # ⏱️ 40 SQL Agent Jobs & Bơm dữ liệu
│   ├── DEEP_DIVE_03_END_TO_END_DATA_LINEAGE_ATLAS.md        # 🗺️ Huyết mạch dữ liệu 360° từ PO -> Ship
│   ├── DEEP_DIVE_04_HIGH_VOLUME_PERFORMANCE_AND_INDEXES.md  # ⚡ Bảng 423M rows, Index & Cạm bẫy
│   ├── DEEP_DIVE_05_TRIGGER_AND_EVENT_DRIVEN_ARCHITECTURE.md# ⚡ 31 Triggers MES & 900+ Triggers ERP
│   ├── DB_01_SmartFactoryV2_MES.md             # MES Production Core
│   ├── DB_02_SmartFramework.md                 # MES Authentication & Permissions
│   ├── 📂 VINATECH_GROUP/                      # Groupware Core & 9 Chuyên đề tích hợp
│   │   ├── README.md                           # Tổng quan Groupware DB
│   │   ├── PURCHASE_INTEGRATION.md             # Mua hàng PO -> Arrival -> IQC -> Nhập kho
│   │   ├── PRODUCTION_PLANNING.md              # Kế hoạch tháng & lệnh ngày -> MES
│   │   ├── MASTER_DATA_INTEGRATION.md          # Đăng ký Item, BOM 2001, giá đối tác
│   │   ├── DISBURSEMENT_INTEGRATION.md         # Quyết toán thanh toán & cước Logistics
│   │   ├── HR_AND_ADMIN_INTEGRATION.md         # Nghỉ phép, tăng ca, công tác, bàn giao
│   │   ├── SALES_AND_SHIPMENT_INTEGRATION.md   # Suju đơn hàng, xuất kho, thông quan
│   │   ├── WAREHOUSE_AND_INVENTORY_INTEGRATION.md # Kho MES FG01, B750, B752
│   │   ├── SSO_AND_SECURITY_INTEGRATION.md     # Single Sign-On qua API Token
│   │   └── ORGANIZATION_AND_WORKFLOW_INTEGRATION.md # Sơ đồ tổ chức & luồng ký
│   ├── NEOE/README.md                          # ERP Douzone iU (4,883 bảng)
│   ├── DZICUBE/README.md                       # Bizbox Alpha Kế toán (>3,300 bảng)
│   ├── VINATECH_POP/README.md                  # Kiosk POP & Cấu hình PLC
│   ├── AndonDB/README.md                       # Giám sát dừng chuyền Andon
│   ├── VINATECH_RESTFUL/README.md              # Single Sign-On (SSO)
│   ├── VINATECH_WEBSOCKET/README.md            # IoT Realtime Telemetry
│   ├── VINATECH_SPREADSHEET/README.md          # Excel Online JSON Grid
│   ├── WCMS_STANDARD_NEW/README.md             # Cash Management Firm Banking
│   ├── SmartFactoryIncubator/README.md         # R&D Sandbox Testing
│   ├── VINATECH_DATA_KSOX/README.md            # K-SOX Tuân thủ kiểm soát nội bộ
│   ├── erpdb/README.md                         # Legacy ERP Archive (Tiếng Hàn)
│   └── streamdocs/README.md                    # StreamDocs PDF Engine
│
├── 📂 tools/                                   # Bộ công cụ PowerShell vận hành v3.0
│   ├── db_shared.ps1                           # Module kết nối SQL, Failover, Regex-safe check
│   ├── health_check.ps1                        # Morning Health Check 15 CSDL
│   ├── find_kb.ps1                             # Tra cứu L1 Cache & KB files
│   ├── run_query.ps1                           # SELECT an toàn (NOLOCK, Timeout, MaxRows)
│   ├── inspect_schema.ps1                      # Tra cứu cấu trúc cột, kiểu dữ liệu, PK & Comments
│   ├── inspect_sp.ps1                          # Tra cứu và đọc mã nguồn SQL Stored Procedure
│   ├── db_stats.ps1                            # Thống kê chuyên sâu Tables, Views, SPs, Top Rows
│   ├── audit_jobs.ps1                          # Kiểm toán 40 SQL Agent Jobs, bước chạy & lịch trình
│   ├── audit_triggers.ps1                      # Kiểm toán DML/DDL Triggers và mã nguồn kích hoạt
│   ├── audit_indexes.ps1                       # Kiểm toán Index, Space Used & DMV Missing Indexes
│   ├── audit_cross_db.ps1                      # Quét phụ thuộc gọi chéo CSDL & Linked Servers
│   └── trace_lineage.ps1                       # Truy vết huyết mạch 360° xuyên suốt 5 hệ thống
│
└── 📂 sql/                                     # Thư viện câu lệnh mẫu
    ├── cross_db_queries.sql                    # Các mẫu JOIN liên CSDL
    ├── data_dictionary.sql                     # Script trích xuất từ điển dữ liệu
    └── templates/                              # Template chuẩn UTF-8-BOM
```

---

## ⚡ Bảng Lệnh CLI Hub `.\db.ps1` (Phiên Bản v3.0)

| Lệnh | Cú Pháp Mẫu | Mục Đích Nghiệp Vụ |
| :--- | :--- | :--- |
| **Liệt kê CSDL** | `.\db.ps1 list` | Liệt kê 15 CSDL, profile tương ứng và mô tả ngắn |
| **Kiểm tra sức khỏe** | `.\db.ps1 health [-Detail]` | Quét latency và trạng thái Online của 15 CSDL |
| **Thống kê đối tượng** | `.\db.ps1 stats [-Profile <P>]` | Thống kê Tables, Views, SPs, Top 10 bảng lớn nhất |
| **Tra cứu Stored Procedure** | `.\db.ps1 sp -Profile <P> -Search <Word>` | Tra cứu Stored Procedure (trong 66,540 SPs) |
| **Đọc mã nguồn SP** | `.\db.ps1 sp -Profile <P> -Name <N> -Def` | Đọc mã nguồn SQL của Stored Procedure (hỗ trợ đa Schema) |
| **Tra cứu cấu trúc bảng** | `.\db.ps1 schema -Profile <P> -Table <T>` | Xem cột, kiểu dữ liệu, PK, và mô tả `MS_Description` |
| **Truy vấn an toàn** | `.\db.ps1 query -Profile <P> "<SQL>"` | Chạy SELECT an toàn (NOLOCK, TOP 50, Timeout an toàn) |
| **Tra cứu tri thức nhanh** | `.\db.ps1 find "<Keyword>"` | Tìm nhanh bảng, cột, khóa chính trong L1 Matrix & KB |
| **Kiểm toán Agent Jobs** | `.\db.ps1 jobs [-ActiveOnly] [-Name <N> -Detail]` | Kiểm toán 40 SQL Agent Jobs và câu lệnh từng bước |
| **Kiểm toán Triggers** | `.\db.ps1 triggers -Profile <P> [-Def]` | Xem danh sách Triggers hoặc đọc mã nguồn Trigger |
| **Kiểm toán Index & DMV** | `.\db.ps1 index -Profile <P> -Table <T>` | Kiểm tra Index, dung lượng đĩa MB và đề xuất DMV |
| **Quét phụ thuộc liên CSDL**| `.\db.ps1 crossdb [-Profile <P>]` | Quét mã nguồn SP/View tìm các lệnh gọi liên CSDL |
| **Truy vết huyết mạch 360°**| `.\db.ps1 lineage -Type <T> -Value <V>` | Truy vết xuyên suốt Groupware -> ERP -> MES -> POP -> Andon |
