# 🌐 VINATECH - CORE SYSTEMS ARCHITECTURE & OPERATION PORTAL

> **Cập nhật:** 2026-09-21
> **Bối cảnh vận hành:** Hệ sinh thái quản trị và điều hành sản xuất Vinatech liên kết chặt chẽ giữa 3 nền tảng chính:
> 1. **Groupware (`https://gw.vinatech.com`):** Cổng phê duyệt tờ trình hành chính, nhân sự, mua sắm (PO) và kế hoạch sản xuất ở thượng nguồn.
> 2. **ERP Douzone iU (`NEOE`):** Sổ cái trung tâm lưu trữ dữ liệu tài chính, hạch toán kế toán và Master Data gốc.
> 3. **NAIS MES (`http://mes.hycap.co.kr:9952`) & POP (`https://pop.vinatech.com`):** Hệ thống thực thi sản xuất tại hiện trường nhà xưởng (quét barcode, routing, QC, Kiosk và kho vật lý).

---

## 🗂️ TRANG CHỦ TRA CỨU TRI THỨC HỆ THỐNG

Toàn bộ hệ thống tri thức, quy trình nghiệp vụ, cẩm nang sửa lỗi và tài liệu CSDL được phân chia thành các phân hệ điều hành chuyên biệt ngang hàng:

👉 **[PHÂN HỆ MES & POP (MES_POP/MASTER_INDEX.md)](MES_POP/MASTER_INDEX.md)** — Vận hành sản xuất, Routing, Kiosk POP, Cẩm nang 70+ bugs & CLI `mes.ps1`.  
👉 **[PHÂN HỆ GROUPWARE (GROUPWARE/MASTER_INDEX.md)](GROUPWARE/MASTER_INDEX.md)** — Cổng phê duyệt 17 biểu mẫu, Mua hàng PO, Kế hoạch SX, Bán hàng Suju, Master Data & CLI `gw.ps1`.  
👉 **[BẢN ĐỒ LIÊN KẾT 4 NỀN TẢNG (GROUPWARE/SYSTEM_INTEGRATION_MAP.md)](GROUPWARE/SYSTEM_INTEGRATION_MAP.md)** — Luồng tích hợp khép kín GW ↔ ERP ↔ MES ↔ POP.  

---

## 📁 CẤU TRÚC CÁC PHÂN HỆ ĐIỀU HÀNH NGANG HÀNG

```
PROCESS/
│
├── 📂 MES_POP/                                  # 🏭 PHÂN HỆ VẬN HÀNH SẢN XUẤT HIỆN TRƯỜNG
│   ├── 📄 mes.ps1                              # CLI Điều phối sản xuất & Hotfix (trace, screen, health)
│   ├── 📄 MASTER_INDEX.md                      # Mục lục điều hành MES & POP
│   ├── 📂 .agents/                             # Agent Workspace (auditor, investigator, deployer)
│   ├── 📂 AI_AGENT_CONFIG/                     # L1 Quick Matrix, Rules, Hotfix logs
│   ├── 📂 MES_MASTER_KNOWLEDGE_BASE/           # Tri thức MES, Routing, 70+ bug fixes
│   ├── 📂 POP_KNOWLEDGE_BASE/                  # Tri thức POP Kiosk, PLC, API, Rollback
│   └── 📂 sql/, tools/                         # Stored Procedures, Scripts kiểm tra hiện trường
│
└── 📂 GROUPWARE/                                # 🏛️ PHÂN HỆ PHÊ DUYỆT & ĐIỀU HÀNH THƯỢNG NGUỒN
    ├── 📄 gw.ps1                               # CLI Điều phối Groupware (trace, form, routine, agent, chain, health, find)
    ├── 📄 MASTER_INDEX.md                      # Mục lục điều hành Groupware & 25+ Form nghiệp vụ
    ├── 📄 SYSTEM_INTEGRATION_MAP.md            # Bản đồ tích hợp 4 chiều (GW-ERP-MES-SSO)
    ├── 📂 .agents/                             # Agent Workspace (form-auditor, sync-investigator, masterdata-coordinator)
    ├── 📂 AI_AGENT_CONFIG/                     # L1 GW_FORM_MATRIX.json (25+ forms), Rules, Approval lines
    ├── 📂 GROUPWARE_KNOWLEDGE_BASE/            # 15 KB chuyên sâu, 10 tài liệu CSDL, AI Agent Engine, attachments
    └── 📂 sql/, tools/                         # 6 Stored Procedures, 4 Views, PowerShell tools & SQL hotfix
```

> 🔒 **Ghi chú an toàn:** Các file gốc và tài liệu tham khảo bổ trợ đã được lưu trữ an toàn tại `C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS_ARCHIVE_BACKUP`.
