# 🏭 VINATECH MES & POP — MASTER INDEX (Trang Chủ Tri Thức & Điều Hành Sản Xuất)

> **Cập nhật:** 2026-09-21  
> **Phân hệ:** Điều hành sản xuất hiện trường (Shop Floor Manufacturing Execution) — NAIS MES WinForms + Kiosk POP Web + PLC Telemetry  
> **Máy chủ CSDL trung tâm:** `dbserver.hycap.co.kr,5398` (Database: `SmartFactoryV2`, `SmartFramework`, `VINATECH_POP`, `AndonDB`)  
> **Nguyên tắc cốt lõi:** SELECT-ONLY trên Production, Golden Query 360° Trace First, L1 Cache First (<0.001s).

---

## 🌐 Liên Kết Xuyên Suốt 3 Phân Hệ Doanh Nghiệp

- 👉 **[PHÂN HỆ GROUPWARE](../GROUPWARE/MASTER_INDEX.md)** — Cổng phê duyệt 17 biểu mẫu, Mua hàng PO, Kế hoạch SX, Bán hàng Suju, Master Data & CLI `gw.ps1`.
- 👉 **[PHÂN HỆ DATABASE](../DATABASE/MASTER_INDEX.md)** — 15 Cơ sở dữ liệu, 3 Tập Đặc tả Hệ thống (Vol 1-3), Lineage 360° & CLI `db.ps1`.
- 👉 **[BẢN ĐỒ LIÊN KẾT 4 NỀN TẢNG](../DATABASE/SYSTEM_INTEGRATION_MAP.md)** — Luồng tích hợp khép kín GW ↔ ERP ↔ MES ↔ POP ↔ K-System Ace.

---

## 📂 Cấu Trúc Thư Mục Phân Hệ `MES_POP/`

```
PROCESS/MES_POP/
│
├── 📄 mes.ps1                                  # ⚡ TRUNG TÂM ĐIỀU PHỐI LỆNH VẬN HÀNH (v2.1)
├── 📄 MASTER_INDEX.md                          # ← BẠN ĐANG Ở ĐÂY
├── 📄 GEMINI.md                                # 🛡️ Quy tắc cốt lõi & CLI Hub cho AI Agent
├── 📄 db_config.json                           # Cấu hình kết nối 15 Database (Mặc định: SmartFactoryV2)
├── 📄 start_telegram_bot.bat                   # Khởi động Telegram Assistant Bot (Console)
├── 📄 start_telegram_bot_hidden.vbs            # Khởi động ngầm Telegram Assistant Bot
│
├── 📂 .agents/                                 # Cấu hình Antigravity Agent Workspace
│   ├── 📄 AGENTS.md                            # Danh mục Agent: investigator, auditor, deployer
│   ├── 📄 hooks.json                           # Lifecycle Safety Hooks
│   ├── 📂 rules/                               # 00_vinatech_rules.md, 01_sql_safety_rules.md
│   ├── 📂 skills/                              # vinatech-mes-troubleshoot, vinatech-db-operations, vinatech-new-model-setup
│   └── 📂 agents/                              # investigator-agent, auditor-agent, hotfix-deployer
│
├── 📂 AI_AGENT_CONFIG/                         # Cấu hình AI & Bộ nhớ đệm L1
│   ├── 📄 QUICK_MATRIX.json                    # 🔥 L1 Cache siêu tốc (95 màn hình, SP, bảng, bugs, fixes)
│   ├── 📄 POP_MATRIX.json                      # 🔥 L1 Cache Kiosk POP (Chuyền, Mode nạp, 20 mã lỗi)
│   ├── 📄 RULES.md                             # 10 Quy tắc vàng bất biến vận hành MES
│   ├── 📄 KNOWLEDGE.md                         # Cheat sheet nén gọn ngữ cảnh
│   ├── 📄 LESSONS_LEARNED.md                   # Bài học kinh nghiệm & cạm bẫy truy vết
│   ├── 📄 HOTFIX_LOG.md                        # Nhật ký 50+ Hotfix sản xuất
│   └── 📄 HOTFIX_LOG_2026_JUL_AUG.md           # Nhật ký hotfix lịch sử 07-08/2026
│
├── 📂 MES_MASTER_KNOWLEDGE_BASE/               # 📚 TRI THỨC NAIS MES WINFORMS (12+ KB Modules)
│   ├── 📄 KB_INDEX.md                          # Mục lục điều hướng & routing tra cứu
│   ├── 📄 KB_01_UI_AND_SCREENS.md              # UI, Login, Phân quyền & Navigation
│   ├── 📂 KB_02/                               # Quản lý kho WMS, FIFO, Hạn dùng, BTP
│   ├── 📂 KB_03/                               # Sản xuất Cell Line, B530, B540, Chốt sản lượng
│   ├── 📂 KB_04/                               # Đóng gói Packing, In tem, Sanmina Label, Rã box
│   ├── 📂 KB_05/                               # QC Chất lượng, IQC/PQC/OQC, Điện cực Slitting
│   ├── 📄 KB_06_MASTER_DATA_TOOLS.md           # Master Data A410, A230, BOM, Model mới
│   ├── 📂 KB_07/                               # Nhà máy Hưng Yên (HY Deploy, WBS Mapping, Bugs)
│   ├── 📄 KB_08_CORE_SP_ENGINE.md              # 4 Stored Procedure cốt lõi (usp_DoProcessProdRouteHist)
│   ├── 📄 KB_09_SCREEN_BUG_FIXBOOK.md          # 🔥 Sổ tay cứu hộ 70+ bug màn hình thường gặp
│   ├── 📄 KB_10_FACTORY_WORKCENTER_MATRIX.md   # Ma trận Workcenter & Nhà máy
│   ├── 📄 KB_11_HANAM_FACTORY_SCREENS.md       # Cụm màn hình đặc thù nhà máy Hà Nam
│   ├── 📄 MES_SCRIPT_GUIDE.md                  # Hướng dẫn bộ công cụ script vận hành
│   ├── 📂 architecture/                        # Bản đồ công đoạn sản xuất chi tiết & Pipeline
│   └── 📂 legacy_docs/                         # Tài liệu tham khảo lưu trữ
│
├── 📂 POP_KNOWLEDGE_BASE/                      # 🖥️ TRI THỨC KIOSK POP WEB & API
│   ├── 📄 POP_KB_INDEX.md                      # Mục lục tra cứu POP Kiosk
│   ├── 📄 POP_KB_01_ARCHITECTURE_AND_API.md    # Kiến trúc POP Web, REST API, MongoToMes*, Bảng đệm
│   ├── 📄 POP_KB_02_SCREEN_OPERATIONS.md       # Thao tác từng màn hình Kiosk & Modal chọn máy
│   ├── 📄 POP_KB_03_TROUBLESHOOTING.md         # Sổ tay cứu hộ 20 mã lỗi POP (POP-ERR-01 → 20)
│   ├── 📄 POP_KB_04_ROLLBACK_AND_SAFETY.md     # Cơ chế hủy đóng gói Box, Rollback & An toàn dữ liệu
│   ├── 📄 POP_KB_05_DB_VERIFICATION_AUDIT.md   # Báo cáo kiểm toán UI Kiosk vs Live DB
│   ├── 📄 POP_KB_06_MIGRATION_SPEC.md          # Đặc tả chuyển đổi 100% POP Web (Cutover WinForms)
│   └── 📂 legacy_manuals/                      # Sổ tay hướng dẫn sử dụng POP gốc
│
├── 📂 tools/                                   # ⚡ BỘ CÔNG CỤ POWERSHELL & PYTHON VẬN HÀNH
│   ├── 📄 db_shared.ps1                        # Module kết nối CSDL, failover, query an toàn
│   ├── 📄 find_kb.ps1                          # Tra cứu 2 tầng: L1 Quick Matrix + 78 Markdown KB
│   ├── 📄 health_check.ps1                     # Morning Health Check quét Lot HOLD, WIP 24h
│   ├── 📄 debug_screen.ps1                     # Debug thông tin màn hình MES
│   ├── 📄 get_sp.ps1                           # Tải Stored Procedure từ Live DB về local
│   ├── 📄 pop_trace.ps1                        # Single Round-Trip 360° truy vết hệ sinh thái POP
│   ├── 📄 pop_readiness.ps1                    # Kiểm toán 8 bước sẵn sàng chuyển 100% POP Web
│   ├── 📄 release_orphan_machines.ps1          # Giải phóng máy bị kẹt khóa ACTIVE ở DayPlan cũ
│   ├── 📄 db_sync_tool.ps1                     # So sánh và đồng bộ SP local vs DB
│   ├── 📄 deploy_tool.ps1                      # Triển khai SQL an toàn kèm snapshot backup
│   ├── 📄 record_hotfix.ps1                    # Ghi nhật ký hotfix
│   ├── 📄 run_query.ps1                        # Chạy câu lệnh SELECT an toàn có NOLOCK
│   ├── 📄 validate_sql.ps1                     # Kiểm tra cú pháp SQL trước deploy
│   ├── 📄 mes_telegram_bot.py                  # Trợ lý AI Senior Tech Lead qua Telegram
│   ├── 📂 barcode_tools/                       # Bộ công cụ phân tích & giải mã barcode Code 128
│   ├── 📂 mes_v2_core/                         # Kiến trúc Engine hướng đối tượng (ConnectionManager, QueryEngine)
│   └── 📂 mes_v2_cli/                          # CLI Controller V2
│
├── 📂 sql/                                     # THƯ VIỆN SQL PROCEDURES & HOTFIX TEMPLATES
│   ├── 📂 procedures/                          # 25+ Stored Procedure definitions trích xuất
│   ├── 📄 template_hotfix.sql                  # Template hotfix bọc BEGIN TRAN...ROLLBACK
│   ├── 📄 template_B552_ELECTRODE_CLEANUP.sql   # Template dọn dẹp điện cực B552
│   ├── 📄 template_B782_B530_ROLLBACK_CHOT.sql  # Template rollback chốt sản lượng B530/B782
│   ├── 📄 template_B782_MOVE_JOBDATE.sql       # Template chuyển ngày sản xuất
│   ├── 📄 template_GENERATE_POP_PACKING_ID.sql # Template sinh mã thùng đóng gói POP
│   ├── 📄 template_SWITCH_FIFO_TO_DAY.sql      # Template chuyển FIFO sang theo ngày
│   ├── 📄 template_SWITCH_FIFO_TO_MONTH.sql    # Template chuyển FIFO sang theo tháng
│   └── 📄 routine_RELEASE_ORPHAN_MACHINE_LOCKS.sql # Routine giải phóng thiết bị treo Kiosk
│
└── 📂 docs/                                    # TÀI LIỆU VẬN HÀNH BỔ TRỢ
    ├── 📄 HUONG_DAN_TRIEN_KHAI_TELEGRAM_BOT.md # Cẩm nang 4 bước thiết lập Bot Telegram
    └── 📄 KB_RELIABILITY_REPORT.md             # Báo cáo đối soát tri thức KB vs CSDL
```

---

## ⚡ Bảng Lệnh CLI Hub `.\mes.ps1` (Phiên Bản v2.1)

| Lệnh | Cú Pháp Mẫu | Mục Đích Nghiệp Vụ |
| :--- | :--- | :--- |
| **Truy vết 360° Siêu Tốc** | `.\mes.ps1 trace "<LotID>"` | Golden Query 360° quét Lot, Routing, NVL, Tồn kho (Single Round-Trip) |
| **Truy vết Huyết Mạch 3 Trụ Cột** | `.\mes.ps1 lineage "<Lot/PO>"` | Truy vết liên hệ thống: PO Master ➔ Kho NVL ➔ Tiến độ MES ➔ Kiosk POP (<1s) |
| **Truy vết POP Kiosk** | `.\mes.ps1 pop-trace "<Keyword>"` | Truy vết chuyên sâu Kiosk: Sync status, Phế, Máy kẹt, Kiosk logs |
| **Debug Màn Hình MES** | `.\mes.ps1 screen "<ScreenID>"` | Debug SP, Bảng, Lưới dữ liệu màn hình MES (`B530`, `B540`, `S510`...) |
| **Tra cứu tri thức nhanh** | `.\mes.ps1 find "<Keyword>"` | Tra cứu L1 Quick Matrix (<0.001s) và 78+ file Markdown KB |
| **Sức Khỏe Hệ Thống** | `.\mes.ps1 health [-Detail]` | Morning Health Check quét Lot HOLD, WIP 24h, DB Lock |
| **Kiểm toán Chuyển Đổi POP** | `.\mes.ps1 pop-readiness [-Target <Line>]` | Kiểm toán 8 bước sẵn sàng cắt WinForms & chạy 100% POP Web |
| **Giải phóng Thiết Bị Treo** | `.\mes.ps1 release-machines [-Target <Line>] [-Force]` | Giải phóng máy bị kẹt trạng thái ACTIVE ở DayPlan cũ trên Kiosk POP |
| **Hotfix Chuyển Ngày B782** | `.\mes.ps1 fix-movedate -Lots "..." -TargetDate "..."` | Sinh Hotfix chuyển ngày chốt B782 chuẩn 10h00 AM (Author vanduc) |
| **Hotfix Xử Lý Điện Cực B552** | `.\mes.ps1 fix-electrode -Lots "..." [-Type Slitting\|Mixing]` | Sinh Hotfix xóa cuộn/mẻ trộn B552 & reset IsLineInput cuộn mẹ |
| **Hotfix Rollback Chốt B530** | `.\mes.ps1 fix-rollback -Lots "..." [-Route "..."]` | Sinh Hotfix rollback lượt chốt B530 / POP Kiosk |
| **Tự Động Báo Cáo Tuần IT** | `.\mes.ps1 weekly-report [-StartDate "..." -EndDate "..."]` | Tự động tạo file CSV báo cáo tuần chuẩn tại Desktop/thanks_and_ojt_reports |
| **Tải Stored Procedure** | `.\mes.ps1 sp "<SP_Name>"` | Tải mã nguồn SP mới nhất từ DB về local để phân tích |
| **Truy vấn an toàn** | `.\mes.ps1 query "<SELECT_SQL>"` | Chạy câu lệnh SELECT an toàn có kiểm tra từ khóa cấm & NOLOCK |
| **Sinh Template Hotfix** | `.\mes.ps1 new-fix "<Tên_Lỗi>" [-Template <b552\|b782\|rollback>]` | Sinh template SQL Hotfix chuẩn UTF-8-BOM có snapshot backup |
| **Triển khai Hotfix SQL** | `.\mes.ps1 deploy "<File.sql>" [-Force]` | Deploy script SQL an toàn (Tự động Snapshot Pre-flight & Auto-Learn Log) |
| **Trợ Lý Telegram** | `.\mes.ps1 bot` | Khởi động Trợ lý AI Telegram phục vụ điều khiển từ xa qua điện thoại |
