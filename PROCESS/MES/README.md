# 🚀 VINATECH MES - SYSTEM INDEX

> [!IMPORTANT]
> **CẬP NHẬT QUAN TRỌNG:** Toàn bộ hệ thống tri thức, quy trình nghiệp vụ và hướng dẫn sửa lỗi tích hợp giữa Groupware và MES đã được hợp nhất thành một thư viện duy nhất để tránh trùng lặp dữ liệu và phân mảnh:
> 
> *   ### 🗂️ [MỤC LỤC TRUNG TÂM TRA CỨU HỆ THỐNG](../SYSTEM_MASTER_KNOWLEDGE_BASE/README.md)
> 
> Vui lòng bấm vào liên kết trên để chuyển hướng tới trang mục lục chính điều hướng 3 Volumes tri thức cốt lõi.

---

## 📁 Cấu Trúc Thư Mục MES Thực Tế
```
MES/
├── README.md                              # File này - Hướng dẫn chuyển hướng
├── AI_AGENT_CONFIG/                       # Cấu hình tối ưu dành cho AI Agent
│   ├── BOOTSTRAP.md                       # Khởi động (đọc đầu tiên mỗi phiên)
│   ├── RULES.md                           # Quy tắc an toàn bắt buộc (SELECT-only)
│   ├── KNOWLEDGE.md                       # Cheat sheet tra cứu nhanh bảng/SP
│   └── SKILLS.md                          # SQL/PS templates & lessons learned
├── db_sync_tool.ps1                       # PowerShell tải SP tạm từ DB (không commit Git)
├── deploy_tool.ps1                        # PowerShell để triển khai SQL lên DB
├── run_query.ps1                          # PowerShell truy vấn DB an toàn (SELECT-only)
└── validate_sql.ps1                       # PowerShell kiểm tra cú pháp SQL trước khi chạy
```
