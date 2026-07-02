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
├── README.md                              # File này - Hướng dẫn chuyển hướng & Cấu trúc thư mục
├── GEMINI.md                              # Auto-context tối thiểu cho AI Agent
├── db_config.json                         # File cấu hình kết nối Database (SoT)
├── AI_AGENT_CONFIG/                       # Cấu hình tối ưu dành cho AI Agent
│   ├── BOOTSTRAP.md                       # Khởi động (đọc đầu tiên mỗi phiên)
│   ├── RULES.md                           # Quy tắc an toàn bắt buộc (SELECT-only)
│   ├── KNOWLEDGE.md                       # Cheat sheet tra cứu nhanh bảng/SP
│   ├── SKILLS.md                          # SQL/PS templates & lessons learned
│   └── HOTFIX_LOG.md                      # Nhật ký các lỗi đã được xử lý (Hotfix logs)
├── MES_MASTER_KNOWLEDGE_BASE/             # Cơ sở tri thức chuyên sâu
│   ├── KB_INDEX.md                        # Chỉ mục định tuyến KB
│   └── KB_01 ... KB_36                    # Hướng dẫn chi tiết các màn hình/nghiệp vụ
├── db_shared.ps1                          # Module chia sẻ logic DB và safety checks
├── db_sync_tool.ps1                       # PowerShell tải SP tạm từ DB (không commit Git)
├── deploy_tool.ps1                        # PowerShell để triển khai SQL lên DB
├── run_query.ps1                          # PowerShell truy vấn DB an toàn (SELECT-only)
├── validate_sql.ps1                       # PowerShell kiểm tra cú pháp SQL trước khi chạy
├── debug_screen.ps1                       # PowerShell chẩn đoán lỗi màn hình theo TCode/ErrorMsg
├── record_hotfix.ps1                      # PowerShell ghi nhận lỗi và tự động vá vào KB_31
├── search_kb.ps1                          # PowerShell tìm kiếm tri thức nhanh cục bộ
└── self_improve.ps1                       # PowerShell tự đánh giá, audit tuân thủ quy tắc
```
