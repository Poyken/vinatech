# 🌐 VINATECH - CORE SYSTEMS ARCHITECTURE & OPERATION PORTAL

> **Cập nhật:** 2026-09-21  
> **Bối cảnh vận hành:** Hệ sinh thái quản trị và điều hành sản xuất Vinatech liên kết chặt chẽ giữa 4 nền tảng chính:  
> 1. **Groupware (`https://gw.vinatech.com`):** Cổng phê duyệt tờ trình hành chính, nhân sự, mua sắm (PO) và kế hoạch sản xuất ở thượng nguồn.  
> 2. **ERP Douzone iU (`NEOE`):** Sổ cái trung tâm lưu trữ dữ liệu tài chính, hạch toán kế toán và Master Data gốc.  
> 3. **NAIS MES (`http://mes.hycap.co.kr:9952`) & POP (`https://pop.vinatech.com`):** Hệ thống thực thi sản xuất tại hiện trường nhà xưởng (quét barcode, routing, QC, Kiosk và kho vật lý).  
> 4. **YoungLimWon K-System Ace Web ERP (`https://evn.vinatech.com`):** Web ERP thế hệ mới cho Vinatech Việt Nam (17 phân hệ, 213 quy trình).

---

## 🗂️ TRANG CHỦ TRA CỨU TRI THỨC 3 TRỤ CỘT

Toàn bộ hệ thống tri thức, quy trình nghiệp vụ, cẩm nang sửa lỗi và tài liệu CSDL được tổ chức thành 3 phân hệ trụ cột ngang hàng:

👉 **[PHÂN HỆ MES & POP (MES_POP/MASTER_INDEX.md)](MES_POP/MASTER_INDEX.md)** — Vận hành sản xuất hiện trường, Routing, Kiosk POP, Cẩm nang 70+ bugs & CLI `.\mes.ps1`.  
👉 **[PHÂN HỆ GROUPWARE (GROUPWARE/MASTER_INDEX.md)](GROUPWARE/MASTER_INDEX.md)** — Cổng phê duyệt 17 biểu mẫu, Mua hàng PO, Kế hoạch SX, Bán hàng Suju, Master Data & CLI `.\gw.ps1`.  
👉 **[PHÂN HỆ DATABASE (DATABASE/MASTER_INDEX.md)](DATABASE/MASTER_INDEX.md)** — Tri thức 15 Cơ sở Dữ liệu, 3 Tập Đặc tả Hệ thống (Vol 1-3), Lineage 360° & CLI `.\db.ps1`.  
👉 **[BẢN ĐỒ LIÊN KẾT 4 NỀN TẢNG (DATABASE/SYSTEM_INTEGRATION_MAP.md)](DATABASE/SYSTEM_INTEGRATION_MAP.md)** — Luồng tích hợp khép kín GW ↔ ERP ↔ MES ↔ POP ↔ K-System Ace.

---

## 📁 CẤU TRÚC 3 TRỤ CỘT HỆ THỐNG (PROCESS ARCHITECTURE)

```
PROCESS/
│
├── 📄 mes.ps1                                  # ⚡ PROXY ĐIỀU PHỐI MES & POP (trace, screen, health, find)
├── 📄 gw.ps1                                   # ⚡ PROXY ĐIỀU PHỐI GROUPWARE (trace, form, health, find)
├── 📄 db.ps1                                   # ⚡ PROXY ĐIỀU PHỐI CSDL (list, health, query, schema, find)
├── 📄 README.md                                # ← BẠN ĐANG Ở ĐÂY (Cổng thông tin chung)
├── 📄 GEMINI.md                                # 🛡️ Quy tắc tổng thể Antigravity Agent
├── 📂 .agents/                                 # Cấu hình Master Agent Workspace
│
├── 📂 MES_POP/                                  # 🏭 [TRỤ CỘT 1] VẬN HÀNH SẢN XUẤT HIỆN TRƯỜNG
│   ├── 📄 mes.ps1                              # CLI Điều phối sản xuất & Hotfix
│   ├── 📄 MASTER_INDEX.md                      # Mục lục điều hành MES & POP
│   ├── 📄 GEMINI.md                            # Quy tắc agent phân hệ MES_POP
│   ├── 📄 db_config.json                       # Cấu hình kết nối DB (SmartFactoryV2)
│   ├── 📂 .agents/                             # Agent Workspace (investigator, auditor, deployer)
│   ├── 📂 AI_AGENT_CONFIG/                     # L1 Quick Matrix (95 screens), POP Matrix, Rules, Hotfix logs
│   ├── 📂 MES_MASTER_KNOWLEDGE_BASE/           # Tri thức MES WinForms, Routing, 70+ bug fixes (KB_01 - KB_11)
│   ├── 📂 POP_KNOWLEDGE_BASE/                  # Tri thức POP Kiosk, PLC, API, Rollback, Migration (POP_KB_01 - 06)
│   ├── 📂 tools/                               # Bộ công cụ: trace, screen, readiness, release_machines, bot
│   ├── 📂 sql/                                 # Stored Procedures, Hotfix templates bọc BEGIN TRAN...ROLLBACK
│   └── 📂 docs/                                # Hướng dẫn Telegram Bot, Báo cáo kiểm toán
│
├── 📂 GROUPWARE/                                # 🏛️ [TRỤ CỘT 2] PHÊ DUYỆT & ĐIỀU HÀNH THƯỢNG NGUỒN
│   ├── 📄 gw.ps1                               # CLI Điều phối Groupware (trace, form, routine, health, find)
│   ├── 📄 MASTER_INDEX.md                      # Mục lục điều hành Groupware & 25+ Form nghiệp vụ
│   ├── 📄 SYSTEM_INTEGRATION_MAP.md            # Bản đồ tích hợp 4 chiều (GW-ERP-MES-SSO)
│   ├── 📄 GEMINI.md                            # Quy tắc agent phân hệ GROUPWARE
│   ├── 📄 db_config.json                       # Cấu hình kết nối DB (VINATECH_GROUP)
│   ├── 📂 .agents/                             # Agent Workspace (form-auditor, sync-investigator)
│   ├── 📂 AI_AGENT_CONFIG/                     # L1 GW_FORM_MATRIX.json (25+ forms), Approval lines, Rules
│   ├── 📂 GROUPWARE_KNOWLEDGE_BASE/            # 15 KB chuyên sâu, 10 tài liệu CSDL integrations, attachments
│   ├── 📂 tools/                               # Bộ công cụ: gw_trace, inspect_form, health_check, run_query
│   └── 📂 sql/                                 # Stored Procedures, Views & Hotfix SQL Groupware
│
└── 📂 DATABASE/                                 # 🗄️ [TRỤ CỘT 3] TỔNG KHO DỮ LIỆU & ĐẶC TẢ KIẾN TRÚC
    ├── 📄 db.ps1                               # CLI Điều phối 15 CSDL (stats, jobs, triggers, lineage, audit)
    ├── 📄 MASTER_INDEX.md                      # Mục lục tổng quan 15 CSDL & 3 Tập Đặc tả
    ├── 📄 SYSTEM_INTEGRATION_MAP.md            # Bản đồ luồng dữ liệu 360° xuyên suốt 15 CSDL
    ├── 📄 GEMINI.md                            # Quy tắc agent phân hệ DATABASE
    ├── 📄 db_config.json                       # Cấu hình 15 Database Profiles (NEOE, SmartFactoryV2, DZICUBE...)
    ├── 📂 .agents/                             # Agent Workspace (db-auditor, schema-inspector)
    ├── 📂 AI_AGENT_CONFIG/                     # L1 DATABASE_MATRIX.json (15 CSDL, 11.509 Tables, 66.540 SPs)
    ├── 📂 SYSTEM_ARCHITECTURE/                 # 🏛️ 3 Tập Đặc tả Hệ thống (Vol 1-3), K-System Ace ERP, Playbook
    ├── 📂 DATABASE_KNOWLEDGE_BASE/             # Tri thức chi tiết 15 CSDL, 5 Báo cáo Deep-Dive, Topology
    ├── 📂 tools/                               # Bộ công cụ: inspect_schema, inspect_sp, lineage, db_stats
    ├── 📂 sql/                                 # 75 SP definitions, Cross-DB queries, Data dictionary
    └── 📂 docs/                                # SOP quy trình điều chỉnh BOM, báo cáo trình sếp gốc
```

---

## ⚡ BẢNG LỆNH ĐIỀU HÀNH TOÀN HỆ THỐNG (ROOT CLI PROXIES)

Tại thư mục gốc `PROCESS/`, bạn có thể thực thi ngay toàn bộ các lệnh của 3 phân hệ:

| Phân Hệ | Cú Pháp Lệnh | Mục Đích Sử Dụng |
| :--- | :--- | :--- |
| **MES & POP** | `.\mes.ps1 trace "<LotID>"` | Golden Query 360° truy vết Lot, Routing, NVL, Tồn kho (Single Round-Trip) |
| **MES & POP** | `.\mes.ps1 pop-trace "<Keyword>"` | Truy vết Kiosk POP: Sync status, Phế, Máy kẹt, Kiosk logs |
| **MES & POP** | `.\mes.ps1 screen "<ScreenID>"` | Debug màn hình MES (`B530`, `B540`, `S510`...) |
| **MES & POP** | `.\mes.ps1 find "<Keyword>"` | Tra cứu nhanh 95 màn hình & 78+ file Markdown MES/POP |
| **MES & POP** | `.\mes.ps1 health [-Detail]` | Morning Health Check quét Lot HOLD, WIP 24h, DB Lock |
| **GROUPWARE** | `.\gw.ps1 trace "<PO/DocCode>"` | Golden Query 360° truy vết văn bản xuyên suốt GW ↔ ERP ↔ MES |
| **GROUPWARE** | `.\gw.ps1 form "<FormID>"` | Soi chi tiết biểu mẫu (`FORM_PO`, `FORM_ARRIVAL`, `FORM_DAILY_PLAN`...) |
| **GROUPWARE** | `.\gw.ps1 health [-Detail]` | Morning Health Check quét phiếu chờ duyệt, kẹt >48h |
| **DATABASE** | `.\db.ps1 list` | Liệt kê danh mục và trạng thái 15 Cơ sở Dữ liệu Vinatech |
| **DATABASE** | `.\db.ps1 health [-Detail]` | Quét độ trễ và trạng thái Online 15 CSDL |
| **DATABASE** | `.\db.ps1 find "<Keyword>"` | Tra cứu bảng, khóa chính, cột trong L1 Cache 15 CSDL |
| **DATABASE** | `.\db.ps1 lineage -Type <T> -Value <V>` | Truy vết huyết mạch dữ liệu 360° xuyên suốt 5 hệ thống |

---

> 🔒 **Ghi chú an toàn & lưu trữ:**  
> - Các file gốc và tài liệu tham khảo bổ trợ đã được lưu trữ an toàn tại `C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS_ARCHIVE_BACKUP`.  
> - Mọi thao tác trên Production DB tuân thủ tuyệt đối quy tắc **SELECT-ONLY & NOLOCK**.
