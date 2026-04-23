# Vinatech NAIS MES - Core Debug & Deploy Process

Đây là cẩm nang tóm tắt quy trình 5 bước chuẩn hóa để xử lý mọi bug lắt léo và thao tác cấu hình dưới tầng Database của hệ thống Vinatech MES.

## 1. Nhận diện & Mapping (Identify & Map)
- **Xác định Screen ID:** Lấy mã màn hình từ tiêu đề giao diện (VD: `B597`, `F721`).
- **Tra cứu Knowledge Base:** Dùng `Vinatech_MES_Complete_DataFlow` và `screen_id_reference` để map từ Screen ID ngược ra **Bảng DB gốc (Master Table)** và **Stored Procedure (SP)** xử lý chính.
- **Bắt chuỗi lỗi:** Lấy chính xác text lỗi tiếng Việt (VD: "Mã Electrolyte... khác với mã QRCODE") làm key search.

## 2. Truy vết tầng Database (Trace back)
- **Truy xuất trực tiếp:** Chạy script PowerShell chọc vào Database (`SmartFactoryV2` / `SmartFramework`) query sys.sql_modules tìm SP chứa key lỗi.
- **Tải Source Code LIVE:** Fetch mã nguồn mới nhất dướng dạng file `.sql` để phân tích cục bộ.
- **Phân tích Data Thực tế:** Query các Master Tables (`STB_BomDetail`, `STB_ModelBasicInfo`) để mô phỏng lại luồng chạy của SP và tìm nguyên nhân sai logic giữa hệ thống và sản xuất thực tế.

## 3. Sửa đổi Code & Dev logic (Fixing/Dev)
- **Nguyên tắc an toàn:** Hạn chế tối đa sửa đổi gốc rễ Master Data làm lệch kế hoạch của EA/R&D.
- **Bypass logic mềm:** Ưu tiên bổ sung các mệnh đề ngoại lệ (Exception mapping, UNION ALL) thẳng vào cấu trúc CTE của Stored Procedure để giải quyết triệt để sự cố mà không làm hỏng form.

## 4. Triển khai (Deploy)
Lưu ý đặc biệt quan trọng về **Lỗi Font Tiếng Việt**:
- KHÔNG copy-paste script SP trực tiếp qua cmd/sqlcmd thường.
- LUÔN chạy file deploy bọc chuẩn **UTF-8** qua ADO.NET (như `deploy_sp_utf8.ps1`) để ghi đè Stored Procedure lên SQL Server gốc nhằm đảm bảo không bị lỗi `?` hoặc vỡ dấu.

## 5. Đóng gói Kế thừa (Documentation)
- Rút tỉa nguyên nhân root-cause của từng Bug và bổ sung thành từng tiểu mục vào `MES_COMMON_ERRORS_KNOWLEDGE.md`. 
- Để những lần sau gặp sự cố tương tự với mã vật tư khác có thể tái sử dụng ngay bộ giải pháp mà không cần cày lại Database từ đầu.

> **Toàn bộ cẩm nang (docx) và checklist (md) đều đã được lưu trữ trong thư mục này làm mỏ neo kiến thức chung của Team IT Vinatech.**
