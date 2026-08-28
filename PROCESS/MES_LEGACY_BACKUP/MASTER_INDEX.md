# 🏠 MES_LEGACY_BACKUP — MASTER INDEX (Trang Chủ Tri Thức)

> **Cập nhật:** 2026-08-26
> **Mục đích:** Kho lưu trữ tri thức tổng hợp duy nhất cho toàn bộ hệ sinh thái Vinatech
> **Nguyên tắc:** KHÔNG XÓA bất kỳ file nào trong thư mục này — đây là BASE sống còn

---

## 📂 Cấu Trúc Thư Mục Tổng Thể

```
MES_LEGACY_BACKUP/
│
├── 📄 MASTER_INDEX.md                          ← BẠN ĐANG Ở ĐÂY
├── 📄 SYSTEM_INTEGRATION_MAP.md                ← 🌐 BẢN ĐỒ LIÊN HỆ 3 NỀN TẢNG + 15 DB
│
├── 📂 AI_AGENT_CONFIG/                         # Cấu hình AI Agent
│   ├── BOOTSTRAP.md                            # Quy trình khởi động Agent
│   ├── HOTFIX_LOG.md                           # Nhật ký hotfix
│   ├── KNOWLEDGE.md                            # Cheat sheet nén gọn
│   ├── LESSONS_LEARNED.md                      # Bài học kinh nghiệm
│   ├── README.md                               # Tổng quan Agent Config
│   ├── RULES.md                                # 10 Quy tắc vàng bất biến
│   └── SKILLS.md                               # Kỹ năng Agent
│
├── 📂 MES_MASTER_KNOWLEDGE_BASE/               # 📚 TRI THỨC MES (12+ KB files)
│   ├── KB_INDEX.md                             # ← Mục lục tra cứu MES
│   ├── KB_01_UI_AND_SCREENS.md                 # UI, Login, Phân quyền
│   ├── KB_02/ (WMS)                            # Kho, FIFO, Hạn dùng
│   ├── KB_03/ (Production)                     # Sản xuất, B530, B540
│   ├── KB_04/ (Packaging)                      # Đóng gói, Tem, Sanmina
│   ├── KB_05/ (QC & Electrode)                 # IQC/PQC/OQC, Điện cực
│   ├── KB_06_MASTER_DATA_TOOLS.md              # Master Data A410, A230
│   ├── KB_07/ (Hung Yen)                       # Nhà máy Hưng Yên
│   ├── KB_08_CORE_SP_ENGINE.md                 # Core SP phân tích line-by-line
│   ├── KB_09_SCREEN_BUG_FIXBOOK.md             # 🔥 Sổ cứu hộ 70+ bugs
│   ├── KB_10_FACTORY_WORKCENTER_MATRIX.md      # Factory Matrix
│   ├── KB_11_HANAM_FACTORY_SCREENS.md          # Nhà máy Hà Nam
│   └── MES_SCRIPT_GUIDE.md                     # Hướng dẫn Script Tools
│
├── 📂 DATABASE_KNOWLEDGE_BASE/                 # 🗄️ TRI THỨC 15 DATABASE (MỚI)
│   ├── DB_INDEX.md                             # ← Mục lục tra cứu Database
│   ├── DB_03_VINATECH_GROUP.md                 # Groupware DB chính
│   ├── DB_03_INTEGRATION_*.md (9 files)        # Tích hợp chi tiết GW
│   ├── DB_04_NEOE_ERP.md                       # ERP Douzone iU
│   ├── DB_05_DZICUBE.md                        # Bizbox Kế toán
│   ├── DB_06_VINATECH_POP.md                   # Kiosk POP
│   ├── DB_07_AndonDB.md                        # Andon cảnh báo
│   ├── DB_08_VINATECH_RESTFUL.md               # SSO Token
│   ├── DB_09_VINATECH_WEBSOCKET.md             # WebSocket Realtime
│   ├── DB_10_VINATECH_SPREADSHEET.md           # Excel Online
│   ├── DB_11_WCMS.md                           # CMS Ngân hàng
│   ├── DB_12_SmartFactoryIncubator.md          # R&D Sandbox
│   ├── DB_13_VINATECH_DATA_KSOX.md             # K-SOX tuân thủ
│   ├── DB_14_erpdb_Legacy.md                   # ERP cũ (Archive)
│   └── DB_15_streamdocs.md                     # PDF Viewer
│
├── 📂 GROUPWARE_KNOWLEDGE_BASE/                # 🏛️ TRI THỨC GROUPWARE (MỚI)
│   ├── GW_INDEX.md                             # ← Mục lục Groupware
│   ├── GW_01_DANG_NHAP.md                      # Đăng nhập
│   ├── GW_02_MUA_HANG.md                       # Mua hàng PO
│   ├── GW_03_KE_HOACH_SX.md                    # Kế hoạch SX
│   ├── GW_04_MASTER_DATA.md                    # Master Data
│   ├── GW_05_HANH_CHINH.md                     # Hành chính HR
│   ├── GW_06_THANH_TOAN.md                     # Thanh toán
│   ├── GW_07_KHO_THANH_PHAM.md                 # Kho thành phẩm
│   └── GW_08_BAN_HANG.md                       # Bán hàng
│
├── 📂 POP_KNOWLEDGE_BASE/                      # 🖥️ TRI THỨC POP KIOSK (MỚI)
│   └── POP_USER_MANUAL.md                      # Hướng dẫn vận hành POP
│
├── 📂 SYSTEM_ARCHITECTURE/                     # 🏛️ KIẾN TRÚC HỆ THỐNG (MỚI)
│   ├── SYSTEM_INDEX.md                         # ← Mục lục kiến trúc
│   ├── VOL_01_SYSTEM_ARCHITECTURE.md           # Tập 1: Kiến trúc & CSDL
│   ├── VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md  # Tập 2: Quy trình & 17 Form
│   ├── VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md  # Tập 3: Vận hành & Sửa lỗi
│   ├── MES_DAILY_PLAYBOOK.md                   # Giám sát hàng ngày
│   ├── MES_OPERATIONAL_LOG.md                  # Nhật ký sự cố
│   ├── EXTRACTED_MANUALS_ANALYSIS.md           # Phân tích sách hướng dẫn
│   └── GROUPWARE_MES_INTEGRATION_ANALYSIS.md   # Phân tích tích hợp GW-MES
│
├── 📂 sql/                                     # SQL scripts & procedures
│   ├── procedures/                             # Stored Procedures
│   └── template_hotfix.sql                     # Template Hotfix chuẩn UTF-8-BOM
│
├── 📄 mes.ps1                                  # ⚡ TRUNG TÂM ĐIỀU PHỐI LỆNH VẬN HÀNH (V2.0)
├── 📄 find_kb.ps1                              # 🔍 Tra cứu siêu tốc 12+ KB & 90+ Screens
├── 📄 health_check.ps1                         # 📊 Morning Health Check & Giám sát CSDL
├── 📄 check_db.ps1                             # Kiểm tra kết nối DB
├── 📄 check_sp_sync.ps1                        # Kiểm tra SP đồng bộ
├── 📄 db_config.json                           # Cấu hình kết nối 15 Database (Multi-Profile)
├── 📄 db_shared.ps1                            # Module PS dùng chung (Failover & Pre-flight)
├── 📄 db_sync_tool.ps1                         # Công cụ đồng bộ SP
├── 📄 debug_screen.ps1                         # Debug màn hình MES
├── 📄 deploy_tool.ps1                          # Deploy SQL an toàn (Auto Snapshot)
├── 📄 record_hotfix.ps1                        # Ghi nhận hotfix
├── 📄 run_query.ps1                            # Chạy SQL query an toàn (Multi-DB)
└── 📄 validate_sql.ps1                         # Validate SQL syntax
```

---

## 🧭 Hướng Dẫn Tra Cứu & Vận Hành Nhanh

| Bạn cần gì? | Lệnh hoặc Tài liệu |
|-------------|--------------------|
| **Truy vết 360° Lot/Barcode** | `.\mes.ps1 trace "<LotID>"` |
| **Debug màn hình MES** | `.\mes.ps1 screen "<ScreenID>"` (VD: `B530`) |
| **Tra cứu tri thức nhanh** | `.\mes.ps1 find "<Keyword>"` (VD: `.\mes.ps1 find "Sanmina"`) |
| **Kiểm tra sức khỏe hệ thống**| `.\mes.ps1 health -Detail` |
| **Sinh template Hotfix an toàn** | `.\mes.ps1 new-fix "<Tên_Lỗi>"` |
| **Tổng quan toàn hệ thống** | → [SYSTEM_INTEGRATION_MAP.md](SYSTEM_INTEGRATION_MAP.md) |
| **Debug lỗi MES chi tiết** | → [MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md](MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) |
| **Tra cứu Database** | → [DATABASE_KNOWLEDGE_BASE/DB_INDEX.md](DATABASE_KNOWLEDGE_BASE/DB_INDEX.md) |
| **Vận hành Groupware** | → [GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md](GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md) |
| **Hướng dẫn POP Kiosk** | → [POP_KNOWLEDGE_BASE/POP_USER_MANUAL.md](POP_KNOWLEDGE_BASE/POP_USER_MANUAL.md) |
| **Kiến trúc hệ thống** | → [SYSTEM_ARCHITECTURE/SYSTEM_INDEX.md](SYSTEM_ARCHITECTURE/SYSTEM_INDEX.md) |
| **Quy tắc Agent AI** | → [AI_AGENT_CONFIG/RULES.md](AI_AGENT_CONFIG/RULES.md) |
| **Hướng dẫn Script Tools** | → [MES_MASTER_KNOWLEDGE_BASE/MES_SCRIPT_GUIDE.md](MES_MASTER_KNOWLEDGE_BASE/MES_SCRIPT_GUIDE.md) |

---

*Tài liệu master được duy trì bởi đội ngũ IT & EA Vinatech Việt Nam.*
