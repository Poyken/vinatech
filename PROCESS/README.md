# 🌐 VINATECH - CORE SYSTEMS ARCHITECTURE & OPERATION PORTAL

> **Cập nhật:** 2026-08-26
> **Bối cảnh vận hành:** Hệ sinh thái quản trị và điều hành sản xuất Vinatech liên kết chặt chẽ giữa 3 nền tảng chính:
> 1. **Groupware (`https://gw.vinatech.com`):** Cổng phê duyệt tờ trình hành chính, nhân sự, mua sắm (PO) và kế hoạch sản xuất ở thượng nguồn.
> 2. **ERP Douzone iU (`NEOE`):** Sổ cái trung tâm lưu trữ dữ liệu tài chính, hạch toán kế toán và Master Data gốc.
> 3. **NAIS MES (`http://mes.hycap.co.kr:9952`) & POP (`https://pop.vinatech.com`):** Hệ thống thực thi sản xuất tại hiện trường nhà xưởng (quét barcode, routing, QC, Kiosk và kho vật lý).

---

## 🗂️ TRANG CHỦ TRA CỨU TRI THỨC HỆ THỐNG

Toàn bộ hệ thống tri thức, quy trình nghiệp vụ, cẩm nang sửa lỗi 70+ bugs và tài liệu 15 cơ sở dữ liệu đã được hợp nhất và chuẩn hóa tại:

👉 **[MỤC LỤC TRUNG TÂM TRA CỨU HỆ THỐNG (MASTER_INDEX.md)](MES_LEGACY_BACKUP/MASTER_INDEX.md)**
👉 **[BẢN ĐỒ LIÊN KẾT 3 NỀN TẢNG & 15 CƠ SỞ DỮ LIỆU (SYSTEM_INTEGRATION_MAP.md)](MES_LEGACY_BACKUP/SYSTEM_INTEGRATION_MAP.md)**

---

## 📁 CẤU TRÚC THƯ MỤC CHUẨN HÓA (`MES_LEGACY_BACKUP/`)

```
MES_LEGACY_BACKUP/
│
├── 📄 MASTER_INDEX.md                          # Mục lục tra cứu toàn hệ thống (Navigation Portal)
├── 📄 SYSTEM_INTEGRATION_MAP.md                # Bản đồ liên kết 3 nền tảng (GW - ERP - MES) & 15 CSDL
│
├── 📂 AI_AGENT_CONFIG/                         # Cấu hình & Quy tắc vàng vận hành AI Agent (RULES.md, KNOWLEDGE.md)
├── 📂 MES_MASTER_KNOWLEDGE_BASE/               # Tri thức MES, Routing, Core SP Engine, Sổ tay 70+ bugs (KB_09)
├── 📂 DATABASE_KNOWLEDGE_BASE/                 # Cẩm nang chi tiết 15 Cơ sở Dữ liệu & 9 chuyên đề tích hợp
├── 📂 GROUPWARE_KNOWLEDGE_BASE/                # Quy trình 17 biểu mẫu & Hướng dẫn Groupware (GW_01 → GW_08)
├── 📂 POP_KNOWLEDGE_BASE/                      # Hướng dẫn vận hành trạm Kiosk POP & Cấu hình PLC
├── 📂 SYSTEM_ARCHITECTURE/                     # Bộ 3 Volumes Kiến trúc & Sổ tay vận hành hàng ngày
├── 📂 sql/                                     # Mã nguồn Stored Procedures & Scripts
└── 📄 *.ps1, db_config.json                    # Bộ công cụ PowerShell chẩn đoán & truy vấn DB
```

> 🔒 **Ghi chú an toàn:** Các file gốc và tài liệu tham khảo bổ trợ đã được lưu trữ an toàn tại `C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS_ARCHIVE_BACKUP`.
