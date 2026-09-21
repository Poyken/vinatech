# 🏛️ VINATECH GROUPWARE — MASTER INDEX (Trang Chủ Tri Thức)

> **Cập nhật:** 2026-09-21 | **Mục đích:** Kho lưu trữ tri thức, cẩm nang vận hành và trung tâm điều phối cho hệ sinh thái Groupware Vinatech.
> **Nguyên tắc cốt lõi:** Groupware là Cổng Phê Duyệt Thượng Nguồn (Upstream Authority) kích hoạt mọi giao dịch nghiệp vụ sang ERP và MES.

---

## 📂 Cấu Trúc Thư Mục Tổng Thể

```
PROCESS/GROUPWARE/
│
├── 📄 MASTER_INDEX.md                          ← BẠN ĐANG Ở ĐÂY (Navigation Portal)
├── 📄 SYSTEM_INTEGRATION_MAP.md                ← 🌐 BẢN ĐỒ TÍCH HỢP 4 CHIỀU (GW ↔ ERP ↔ MES ↔ POP)
├── 📄 GEMINI.md                                ← Quy tắc cốt lõi & CLI Hub cho AI Agent
├── 📄 db_config.json                           ← Cấu hình kết nối 15 Database (Mặc định: VINATECH_GROUP)
├── 📄 gw.ps1                                   ← ⚡ TRUNG TÂM ĐIỀU PHỐI LỆNH VẬN HÀNH GROUPWARE
│
├── 📂 .agents/                                 # Hệ sinh thái AI Agent Groupware
│   ├── 📄 AGENTS.md                            # Danh mục Agent & vai trò
│   ├── 📄 hooks.json                           # Lifecycle Hooks kiểm soát an toàn
│   ├── 📂 rules/                               # Quy tắc vàng: 00_groupware_rules.md, 01_sql_safety_rules.md
│   ├── 📂 skills/                              # groupware-form-trace, groupware-erp-sync, groupware-db-operations
│   └── 📂 agents/                              # form-auditor, sync-investigator, masterdata-coordinator
│
├── 📂 AI_AGENT_CONFIG/                         # Cấu hình AI & Bộ nhớ đệm L1
│   ├── 📄 GW_FORM_MATRIX.json                  # 🔥 Bộ nhớ đệm L1 (17 Forms, Tables, Columns, Errors, Fixes)
│   ├── 📄 APPROVAL_LINE_MATRIX.json            # Bản đồ tuyến duyệt theo phòng ban, hạn mức & pháp nhân
│   ├── 📄 RULES.md                             # 10 Quy tắc vàng vận hành Groupware
│   ├── 📄 KNOWLEDGE.md                         # Cheat sheet nén gọn ngữ cảnh
│   └── 📄 LESSONS_LEARNED.md                   # Nhật ký bài học kinh nghiệm & sự cố thực tế
│
├── 📂 GROUPWARE_KNOWLEDGE_BASE/                # 📚 TRI THỨC NGHIỆP VỤ & KỸ THUẬT (12+ KB Files)
│   ├── 📄 GW_INDEX.md                          # Mục lục điều hướng & tra cứu nhanh
│   ├── 📄 GW_01_DANG_NHAP.md                   # Đăng nhập, mật khẩu, phân quyền, SSO
│   ├── 📄 GW_02_MUA_HANG.md                    # Luồng PO, Arrival, IQC, Receiving, Đóng sổ
│   ├── 📄 GW_03_KE_HOACH_SX.md                 # Kế hoạch tháng, ngày, tạo Lot, sync MES B310/B450
│   ├── 📄 GW_04_MASTER_DATA.md                 # Đăng ký Item, BOM version 2001, Partner/Vendor
│   ├── 📄 GW_05_HANH_CHINH.md                  # Nghỉ phép, công tác, tăng ca ngày nghỉ, tuyển dụng
│   ├── 📄 GW_06_THANH_TOAN.md                  # Đề nghị thanh toán, cước Logistics, tài khoản chi phí
│   ├── 📄 GW_07_KHO_THANH_PHAM.md              # Kho thành phẩm FG01, B750, B752, mã kho VN
│   ├── 📄 GW_08_BAN_HANG.md                    # Suju, Shipment Request, Confirm, Doanh thu ERP
│   ├── 📄 GW_09_DATABASE_ARCHITECTURE_AND_SCHEMA.md # Lược đồ CSDL Generic Document & 20+ bảng cốt lõi
│   ├── 📄 GW_10_APPROVAL_ENGINE_AND_LIFECYCLE.md # State Machine (001→002→008), phân quyền, ký số PDF
│   ├── 📄 GW_11_TROUBLESHOOTING_AND_ERROR_SOLUTIONS.md # Sổ tay 20+ sự cố thường gặp & giải pháp khắc phục
│   ├── 📄 GW_12_CROSS_SYSTEM_INTEGRATION_GUIDE.md # Cẩm nang tích hợp khép kín đa hệ thống
│   ├── 📄 GW_13_BIZBOX_AI_AGENT_ENGINE.md        # Kiến trúc AI Agent & Dynamic APIs của Bizbox Alpha
│   ├── 📄 GW_14_GROUPWARE_DATABASE_ROUTINES_AND_VIEWS.md # Sổ tay Stored Procedures, Functions & Views
│   ├── 📄 GW_15_GROUPWARE_ECOSYSTEM_DATABASES.md # Hệ sinh thái 5 CSDL thành phần (RESTFUL, streamdocs, SPREADSHEET, WEBSOCKET, NEOE)
│   │
│   ├── 📂 integrations/                        # 🗄️ Bộ 10 tài liệu phân tích kỹ thuật tích hợp CSDL
│   │   ├── PURCHASE_INTEGRATION.md             # Tích hợp mua hàng chi tiết
│   │   ├── SALES_AND_SHIPMENT_INTEGRATION.md   # Tích hợp bán hàng & xuất khẩu
│   │   ├── PRODUCTION_PLANNING.md              # Tích hợp kế hoạch sản xuất
│   │   ├── MASTER_DATA_INTEGRATION.md          # Tích hợp dữ liệu gốc
│   │   ├── HR_AND_ADMIN_INTEGRATION.md         # Tích hợp nhân sự & hành chính
│   │   ├── DISBURSEMENT_INTEGRATION.md         # Tích hợp đề nghị thanh toán
│   │   ├── WAREHOUSE_AND_INVENTORY_INTEGRATION.md # Tích hợp kho & tồn kho
│   │   ├── SSO_AND_SECURITY_INTEGRATION.md     # Tích hợp xác thực một lần
│   │   └── ORGANIZATION_AND_WORKFLOW.md        # Tích hợp sơ đồ tổ chức & luồng duyệt
│   │
│   └── 📂 attachments/                         # Tài liệu đính kèm, Excel mã kho, ngôn ngữ, phê duyệt
│       ├── Code_Warehouse_In_VietNam.xlsx
│       ├── GroupwareMultiLangInformation_250714.xlsx
│       ├── Vietnam Corporation Approval Setting List.xlsx
│       ├── Accounting/                         # Biểu mẫu tài sản cố định
│       └── Logistic/                           # Biểu mẫu chi phí vận chuyển
│
├── 📂 tools/                                   # ⚡ BỘ CÔNG CỤ CLI POWERSHELL
│   ├── 📄 db_shared.ps1                        # Module kết nối CSDL, failover, query an toàn
│   ├── 📄 find_kb.ps1                          # Tra cứu 2 tầng: L1 In-Memory Cache + 15 KB files
│   ├── 📄 gw_trace.ps1                         # 🔍 Golden Query 360° truy vết đa CSDL (GW-ERP-MES)
│   ├── 📄 health_check.ps1                     # Morning check phiếu chờ duyệt, kẹt >48h, thống kê
│   ├── 📄 inspect_form.ps1                     # Soi chi tiết 1 biểu mẫu (bảng, tuyến duyệt, lỗi)
│   ├── 📄 export_routines.ps1                  # Trích xuất Stored Procedures, Functions & Views từ DB
│   └── 📄 run_query.ps1                        # Thực thi SELECT an toàn kèm NOLOCK tự động
│
└── 📂 sql/                                     # 🗄️ SQL SCRIPTS, PROCEDURES & VIEWS
    ├── 📄 template_gw_hotfix.sql               # Template hotfix chuẩn UTF-8-BOM có BEGIN TRAN
    ├── 📂 routines/                            # Mã nguồn 6 Stored Procedures & 1 Function từ DB Live
    ├── 📂 views/                               # Mã nguồn 4 Views quan trọng (ERP Docu, Chain Stuff, Approval)
    └── 📂 queries/                             # Các truy vấn mẫu chẩn đoán thường dùng
```

---

## ⚡ Tra Cứu Nhanh Theo Tình Huống Vận Hành

| Tình Huống Cần Xử Lý | File Hướng Dẫn | Lệnh CLI Đề Xuất |
| :--- | :--- | :--- |
| **Không đăng nhập được Groupware / Quên pass** | `GW_01` § 1, 3 | `.\gw.ps1 find "login"` |
| **Tạo đơn mua hàng (PO) mới** | `GW_02` § 2 | `.\gw.ps1 form FORM_PO` |
| **PO duyệt xong nhưng ERP không thấy** | `GW_11` § 2.2 | `.\gw.ps1 trace "<NO_PO>"` |
| **Hàng về cổng xưởng, MES F330 không hiện** | `GW_02` § 3, `GW_11` § 2.3 | `.\gw.ps1 trace "<NO_PO>"` |
| **QC đã PASS C220 nhưng không cho làm Receiving** | `GW_02` § 4, `GW_11` § 2.4 | `.\gw.ps1 form FORM_RECEIVING` |
| **Tạo PO kế hoạch sản xuất tháng** | `GW_03` § 1 | `.\gw.ps1 form FORM_MONTH_PLAN` |
| **PO sản xuất không hiện trên MES B310/B450** | `GW_03` § 6 | `.\gw.ps1 find "B310"` |
| **Đăng ký mã vật tư mới / Cập nhật BOM 2001** | `GW_04` § 1, 3 | `.\gw.ps1 form FORM_ITEM_REG` |
| **Làm đơn xin nghỉ phép / Đi công tác** | `GW_05` § 1, 4 | `.\gw.ps1 form FORM_LEAVE` |
| **Làm đề nghị thanh toán tiền hàng (Disbursement)** | `GW_06` § 1 | `.\gw.ps1 form FORM_DISBURSEMENT` |
| **Xuất kho thành phẩm trên MES FG01 / Tem B750** | `GW_07` § 1, 2 | `.\gw.ps1 form FORM_SHIPMENT_REQ` |
| **Tra cứu mã kho tại Việt Nam** | `GW_07` | `.\gw.ps1 find "kho"` |
| **Tra cứu lược đồ CSDL & bảng quan hệ** | `GW_09` | `.\gw.ps1 audit` |
| **Kiểm tra sức khỏe đầu ngày & phiếu kẹt duyệt** | `GW_10`, `GW_11` | `.\gw.ps1 health -Detail` |
| **Soi mã nguồn Stored Procedures, Functions, Views** | `GW_14` | `.\gw.ps1 routine [<RoutineName>]` |
| **Kiểm tra hệ thống Bizbox Alpha AI Agent & Dynamic APIs**| `GW_13` | `.\gw.ps1 agent` |
| **Truy vết toàn bộ chuỗi phả hệ văn bản liên đới** | `GW_09`, `GW_14` | `.\gw.ps1 chain "<DocCode>"` |
