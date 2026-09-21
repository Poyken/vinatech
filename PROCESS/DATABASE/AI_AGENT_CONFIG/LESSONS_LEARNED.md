# 🎓 LESSONS LEARNED — BÀI HỌC KINH NGHIỆM TRUY VẤN CSDL VINATECH

## 1. Cạm Bẫy Three-Valued Logic (3VL) Với Giá Trị NULL
- **Hiện tượng:** Trong SQL Server, biểu thức `WHERE IsDelete = '0'` sẽ **bỏ qua tất cả các dòng có `IsDelete IS NULL`**!
- **Thực tế:** Trên bảng `STB_DefectRepairInfo` hoặc `MongoToMesPerformance`, nhiều dòng được tạo ra có `IsDelete IS NULL`. Nếu viết `WHERE IsDelete = '0'`, dữ liệu bị thiếu nghiêm trọng.
- **Giải pháp:** Luôn viết: `WHERE ISNULL(IsDelete, '0') = '0'`.

## 2. Cạm Bẫy Phép Trừ Với Giá Trị NULL
- **Hiện tượng:** `DefectQty - RepairQty` trả về `NULL` nếu `RepairQty IS NULL`.
- **Hậu quả:** Giao diện WinForms/Web hiển thị ô trống hoặc sai số lượng phế tồn.
- **Giải pháp:** Bắt buộc viết: `ISNULL(DefectQty, 0) - ISNULL(RepairQty, 0)`.

## 3. Cạm Bẫy Collation Tiếng Hàn Trên `erpdb`
- CSDL `erpdb` sử dụng Collation Hàn Quốc (`Korean_Wansung_Unicode_CS_AS`). Nếu viết JOIN trực tiếp với chuỗi từ `NEOE` hoặc `VINATECH_GROUP` mà không chỉ định Collation sẽ báo lỗi: `Cannot resolve the collation conflict between ...`.
- Luôn chỉ định: `ON a.Col1 COLLATE Korean_Wansung_Unicode_CS_AS = b.Col2 COLLATE Korean_Wansung_Unicode_CS_AS`.

## 4. Cạm Bẫy Khóa Bảng (Deadlock) Khi JOIN Giữa Groupware Và MES
- `VINATECH_GROUP` có nhiều giao dịch phê duyệt liên tục, trong khi `SmartFactoryV2` có hàng trăm trạm Kiosk quét barcode mỗi phút.
- Nếu chạy câu SELECT liên CSDL mà quên `WITH(NOLOCK)` ở bất kỳ bảng nào, truy vấn có thể bị giữ Intent Shared (IS) lock gây nghẽn toàn bộ dây chuyền quét xuất hàng.
- **Luôn kiểm tra kỹ cú pháp `WITH(NOLOCK)` sau mọi tên bảng.**
