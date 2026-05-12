# 📋 REQUEST TEMPLATES - CHO CÁC LOẠI YÊU CẦU KHÁC NHAU

> **Mục đích:** Template chuẩn cho các loại yêu cầu thường gặp
> **Cập nhật:** 2026-05-12

---

## 🐛 TEMPLATE 1: BUG MES REPORT

```
📝 THÔNG TIN CƠ BẢN
- Ngày báo lỗi: [2026-05-12]
- Tên người báo: [Tên]
- Màn hình lỗi: [B597/B523/F330...]
- Barcode/PO: [VE260506-001]

📸 THÔNG TIN LỖI
- Mã lỗi (nếu có): [Error code]
- Thông báo lỗi: [Copy text chính xác]
- Screenshot path: [Path đến ảnh]
- Thời gian xảy ra: [Ngày/giờ]

📊 DỮ LIỆU LIÊN QUAN
- MaterialCode: [7R5RL470MB9XXXT101]
- PONo: [260428000011]
- ControlNo/Barcode: [VE260506-001]
- RouteCode: [VE08]
- WorkerCode: [VES-253]
- MachineCode: [MCTP202012004]

🔍 KIỂM TRA TRƯỚC KHI BÁO
- [ ] Đã restart ứng dụng
- [ ] Đã kiểm tra network
- [ ] Đã thử với barcode khác
- [ ] Đã kiểm tra quyền user

📝 MÔ TẢ CHI TIẾT
1. Bước thực hiện: [Mô tả chi tiết]
2. Kết quả mong muốn: [Kết quả kỳ vọng]
3. Kết quả thực tế: [Kết quả thực tế]
4. Tần suất lỗi: [Luôn/Thỉnh thoảng/Lần đầu]
5. Ảnh hưởng: [Mức độ ảnh hưởng]

🎯 MỤC TIÊU YÊU CẦU
- [ ] Sửa ngay
- [ ] Tìm nguyên nhân
- [ ] Cải tiến quy trình
- [ ] Training user
```

---

## 🔍 TEMPLATE 2: SQL QUERY REQUEST

```
📝 THÔNG TIN CƠ BẢN
- Ngày yêu cầu: [2026-05-12]
- Người yêu cầu: [Tên]
- Mục tiêu: [Cần truy vấn gì]

📊 THÔNG TIN QUERY
- Bảng liên quan: [STB_SetInfo, STB_ProdRouteHist...]
- Điều kiện lọc: [WHERE clause]
- Kết quả mong muốn: [Format output]
- Sắp xếp: [ORDER BY]

🎯 VÍ DỤ DỮ LIỆU
- Barcode mẫu: [VE260506-001]
- PONo mẫu: [260428000011]
- MaterialCode mẫu: [7R5RL470MB9XXXT101]

📝 MÔ TẢ CHI TIẾT
1. Mục đích query: [Mô tả chi tiết]
2. Cột cần hiển thị: [Danh sách cột]
3. Điều kiện lọc: [Chi tiết]
4. Kết quả mong muốn: [Format]
```

---

## 📚 TEMPLATE 3: DOCUMENTATION REQUEST

```
📝 THÔNG TIN CƠ BẢN
- Ngày yêu cầu: [2026-05-12]
- Người yêu cầu: [Tên]
- Chủ đề: [Chủ đề cần tài liệu]

📚 THÔNG TIN TÀI LIỆU
- Loại tài liệu: [Hướng dẫn/Kiến thức/Quy trình]
- Màn hình liên quan: [B597/B523...]
- Đối tượng sử dụng: [User/Operator/Admin]
- Mức độ chi tiết: [Cơ bản/Chi tiết/Chuyên sâu]

🎯 NỘI DUNG CẦN
1. Quy trình: [Mô tả quy trình]
2. Bước thực hiện: [Các bước chi tiết]
3. Lưu ý quan trọng: [Lưu ý]
4. Ví dụ: [Ví dụ minh họa]

📝 MÔ TẢ CHI TIẾT
1. Mục đích tài liệu: [Mô tả]
2. Người đọc: [Đối tượng]
3. Bối cảnh sử dụng: [Khi nào dùng]
4. Yêu cầu đặc biệt: [Nếu có]
```

---

## 🔄 TEMPLATE 4: GROUPWARE REQUEST

```
📝 THÔNG TIN CƠ BẢN
- Ngày yêu cầu: [2026-05-12]
- Người yêu cầu: [Tên]
- Loại quy trình: [Purchase/HR/Admin]

📋 THÔNG TIN QUY TRÌNH
- Tên quy trình: [Draft Document/Business Trip...]
- Màn hình Groupware: [Tên màn hình]
- Trạng thái hiện tại: [Đang chờ/Đã duyệt/Đã từ chối]

🎯 THÔNG TIN CHI TIẾT
- Số tài liệu: [Document number]
- Người phê duyệt: [Danh sách]
- Nội dung: [Tóm tắt]
- File đính kèm: [Path]

📝 MÔ TẢ CHI TIẾT
1. Vấn đề gặp phải: [Mô tả]
2. Bước đã thực hiện: [Các bước]
3. Kết quả mong muốn: [Kỳ vọng]
4. Cần hỗ trợ: [Cụ thể]
```

---

## 🔧 TEMPLATE 5: DATA FIX REQUEST

```
📝 THÔNG TIN CƠ BẢN
- Ngày yêu cầu: [2026-05-12]
- Người yêu cầu: [Tên]
- Loại fix: [Update/Insert/Delete]

⚠️ CẢNH BÁO QUAN TRỌNG
- [ ] Đã backup dữ liệu
- [ ] Đã kiểm tra impact
- [ ] Đã có approval từ quản lý
- [ ] Thời gian thực hiện: [Thời điểm]

📊 THÔNG TIN DATA
- Bảng cần sửa: [Tên bảng]
- Điều kiện lọc: [WHERE clause]
- Giá trị hiện tại: [Giá trị cũ]
- Giá trị mới: [Giá trị mới]
- Số dòng ảnh hưởng: [Ước tính]

🎯 SQL SCRIPT
```sql
-- Backup trước khi sửa
SELECT * FROM [Tên bảng] WHERE [Điều kiện]

-- Script fix
UPDATE [Tên bảng]
SET [Cột] = [Giá trị mới]
WHERE [Điều kiện]
```

📝 MÔ TẢ CHI TIẾT
1. Lý do cần fix: [Mô tả]
2. Impact analysis: [Ảnh hưởng]
3. Rollback plan: [Cách rollback]
4. Test plan: [Cách test]
```

---

## 🎯 HƯỚNG DẪN SỬ DỤNG

### Khi user gửi yêu cầu:
1. **Xác định loại yêu cầu** → Chọn template tương ứng
2. **Gửi template cho user** → User điền thông tin
3. **Thu thập đủ thông tin** → Đảm bảo đầy đủ
4. **Xử lý theo quy trình** → Theo MES_QUICK_START_GUIDE.md

### Khi thông tin không đầy đủ:
1. **Gửi template tương ứng**
2. **Yêu cầu user điền các trường bắt buộc**
3. **Đợi user trả lời trước khi xử lý**

### Khi xử lý xong:
1. **Cập nhật KB** nếu là bug mới
2. **Lưu lại script** nếu là SQL query hữu ích
3. **Ghi chú** cho lần sau

---

**Sử dụng template chuẩn để giảm thời gian back-and-forth!**
