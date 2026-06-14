# 🌐 VINATECH - CORE SYSTEMS ARCHITECTURE & OPERATION INDEX

> **Cập nhật:** 14/06/2026
> **Bối cảnh vận hành:** Hệ thống quản trị của Vinatech liên kết chặt chẽ giữa 3 nền tảng chính:
> 1. **Groupware (gw.vinatech.com):** Cổng phê duyệt tờ trình hành chính, nhân sự, mua sắm và kế hoạch ở thượng nguồn.
> 2. **ERP Douzone (NEOE):** Hệ thống quản trị tài chính, nhân sự gốc và lưu trữ Master Data trung tâm.
> 3. **NAIS MES (http://mes.hycap.co.kr:9952):** Hệ thống thực thi sản xuất tại hiện trường nhà xưởng (quét barcode, routing, QC và kho vật lý).

---

## 🗂️ THƯ VIỆN TRI THỨC VẬN HÀNH TRUNG TÂM (SYSTEM MASTER KNOWLEDGE BASE)

Toàn bộ hệ thống tri thức, quy trình nghiệp vụ và cẩm nang sửa lỗi tích hợp giữa Groupware và MES đã được dọn dẹp và hợp nhất thành một cấu trúc 3 Volumes tinh gọn:

*   ### 🗂️ [MỤC LỤC TRUNG TÂM TRA CỨU HỆ THỐNG](SYSTEM_MASTER_KNOWLEDGE_BASE/README.md)

Vui lòng bấm vào liên kết trên để vào trang điều hướng chính.

---

## 📁 BẢN ĐỒ CẤU TRÚC THƯ MỤC DỰ ÁN (WORKSPACE STRUCTURE)

Sau khi tái cấu trúc và tối ưu hóa hệ thống, thư mục dự án được tổ chức như sau:

```
PROCESS/ (Thư mục gốc)
│
├── 📂 SYSTEM_MASTER_KNOWLEDGE_BASE/             # HỆ THỐNG TRI THỨC VẬN HÀNH TÍCH HỢP
│   ├── README.md                                 # ← BẮT ĐẦU TRA CỨU TỪ ĐÂY (Master Index)
│   ├── VOL_01_SYSTEM_ARCHITECTURE.md             # Tập 1: Kiến trúc, Schema CSDL, Matrix & Golden Queries
│   ├── VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md     # Tập 2: Quy trình Nghiệp vụ & Cẩm nang 17 Form Groupware
│   ├── VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md # Tập 3: Quy trình Trace Bug, Screen Catalog & Hotfixes
│   ├── MES_DAILY_PLAYBOOK.md                     # Sổ tay giám sát hệ thống hàng ngày
│   ├── MES_OPERATIONAL_LOG.md                    # Nhật ký sự cố vận hành
│   ├── 📂 attachments/                           # Tài liệu đính kèm gốc (.xlsx, .pdf, .docx)
│   └── 📂 scripts/                               # Các script PowerShell tự phát triển
│
├── 📂 DATABASE/                                  # Cơ sở dữ liệu của hệ thống
│   └── 📂 VINATECH_GROUP/
│       └── README.md                             # Hướng dẫn chuyển hướng CSDL Groupware
│
├── 📂 GROUPWARE/                                 # Phân hệ Groupware (Chỉ chứa tài liệu phụ)
│
└── 📂 MES/                                       # Phân hệ sản xuất hiện trường
    ├── README.md                                 # Hướng dẫn chuyển hướng MES
    ├── 📂 AI_AGENT_CONFIG/                       # Cấu hình tối ưu cho AI Agent
    └── 📂 sql/                                   # Mã nguồn SQL và Hotfixes
```

---

## 🔒 NGUYÊN TẮC AN TOÀN HỆ THỐNG (SECURITY RULES)
*   **Không trực tiếp can thiệp CSDL thực:** Mọi hoạt động cập nhật/sửa lỗi phải được viết dưới dạng kịch bản SQL an toàn (`BEGIN TRANSACTION ... ROLLBACK`), bàn giao cho đội ngũ vận hành hệ thống chạy kiểm tra trước trên môi trường Staging/Dev.
*   **Tuyệt đối không sử dụng tài khoản cứng (Hardcoded User ID):** Tuân thủ quy định phân quyền tự động từ màn hình **Z410** liên kết với nhân sự ERP qua thuộc tính `Appendix8`.
