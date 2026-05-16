# 📘 NAIS SYSTEM MASTER TUTORIAL & TROUBLESHOOTING

Tài liệu này được thiết kế để bạn có thể **tự Trace và tự Fix** lỗi hệ thống NAIS dựa trên phương pháp bài bản.

---

## 1. LỖI THIẾU THIẾT LẬP VỎ NHÔM (SCREEN B597 - QC)

### 🔴 Triệu chứng
Thông báo lỗi: *"Không tồn tại thiết lập Vỏ Nhôm của LotNo... với mã Vỏ Nhôm: GBDYAC-004 <<>> ECVT30-367"*.

### 🔍 Cách Trace (Phương pháp)
1. **Đọc mã lỗi:** Xác định cặp giá trị gây lỗi (Ví dụ: Vỏ `GBDYAC-004` và Model `ECVT30-367`).
2. **Tìm điểm chặn trong Code:** Mở Stored Procedure `usp_Vietnam_RawMaterialInputHist_uid`. 
3. **Search từ khóa:** Tìm đoạn code xử lý `@MaterialCode = 'ECVT30-367'`. Bạn sẽ thấy một đoạn `IF` đang chặn (Hard-code) chỉ cho phép một mã vỏ nhất định.

### 🛠️ Logic xử lý & Script
Chúng ta cần "nới lỏng" điều kiện `IF` để cho phép cả mã vỏ mới.
**Mẫu script sửa:**
```sql
-- Tìm đến dòng có MaterialCode bị lỗi
IF (@MaterialCode = 'ECVT30-367' AND @pRawMaterialBarcode NOT IN ('GBRLAC-004', 'GBDYAC-004')) 
BEGIN
    SET @count = 0; -- Nếu không nằm trong danh sách cho phép thì báo lỗi
END
```
*Lưu ý: Luôn dùng `NOT IN` để có thể thêm nhiều mã vỏ hợp lệ vào danh sách.*

---

## 2. LỖI GỘP TÚI BÓNG QTY = 0 (SCREEN HN544 - PACKING)

### 🔴 Triệu chứng
Màn hình HN544 hiển thị Qty = 0 cho các túi vừa gộp, dẫn đến không in được tem.

### 🔍 Cách Trace (Phương pháp)
Kiểm tra "Sức khỏe" của Lot trong bảng Material Info.
```sql
SELECT MaterialLotNo, CurrentQty, InitialQty, CreateUserID 
FROM STB_MaterialLotInfo 
WHERE MaterialLotNo = 'Mã_Lot_Bị_Lỗi';
```
Nếu `CurrentQty = 0` nhưng thực tế hàng vẫn còn, nghĩa là logic gộp của SP đã Reset nhầm số lượng về 0.

### 🛠️ Logic xử lý & Script
Phải khôi phục lại số lượng dựa trên tổng số lượng của các túi con đã gộp vào.
```sql
UPDATE STB_MaterialLotInfo 
SET CurrentQty = [Số_Lượng_Thực_Tế],
    InitialQty = [Số_Lượng_Thực_Tế]
WHERE MaterialLotNo = 'Mã_Lot_Cần_Sửa';
```

---

## 3. LỖI VENDOR LOT (SCREEN F330 - NHẬP KHO NVL)

### 🔴 Triệu chứng
Lỗi: *"Không thể chuyển đổi mã Vendor Lot thành ngày tháng"*.

### 🔍 Cách Trace (Phương pháp)
Hệ thống NAIS thường đọc ngày sản xuất từ mã Vendor Lot (Ví dụ: Lot `250620...` -> Ngày 20/06/2025). Nếu nhà cung cấp đổi định dạng mã Lot, hệ thống sẽ không đọc được.
**Hàm cần kiểm tra:** `fn_VVT_getdatebyVendorLot_MergeCode`.

### 🛠️ Logic xử lý & Script
Cần cập nhật Function để nó biết cách "cắt chuỗi" mới.
**Ví dụ logic:**
- Nếu 2 ký tự đầu là '25' -> Năm 2025.
- Nếu 2 ký tự tiếp là '06' -> Tháng 6.
- Nếu 2 ký tự tiếp là '20' -> Ngày 20.

---

## 4. LỖI TRACE KẾ HOẠCH SAI LINE (SCREEN B450)

### 🔴 Triệu chứng
2 Model khác nhau nhảy chung vào 1 Line trên báo cáo.

### 🔍 Cách Trace (Phương pháp - CỰC KỲ QUAN TRỌNG)
Sử dụng **"Kỹ thuật Quét cửa sổ thời gian (Time Window)"**.
1. Tìm 1 mã `DayPlanNo` bị sai.
2. Xem `CreateUserID` và `CreateDateTime` (chú ý cả phần nghìn giây).
3. Quét tất cả kế hoạch của User đó trong vòng 5-10 giây xung quanh.

**Script Trace mẫu:**
```sql
SELECT DayPlanNo, PlanDate, LineCode, CreateDateTime 
FROM STB_DayProdPlan 
WHERE CreateUserID = 'ID_Người_Lập'
AND CreateDateTime BETWEEN 'Giờ_Sai - 5 giây' AND 'Giờ_Sai + 5 giây'
ORDER BY DayPlanNo ASC;
```

---

## 5. LỖI POPUP TRỐNG (SCREEN B270)

### 🔴 Triệu chứng
Nhấn vào nút chọn (Popup) nhưng không hiện ra dữ liệu để chọn.

### 🔍 Cách Trace (Phương pháp)
Lỗi này 90% là do thiếu **Master Data Mapping**. 
- B270 là màn hình Máy (Machine).
- Nếu không hiện Route để chọn -> Nghĩa là Máy chưa được gán vào Line/Route đó.

### 🛠️ Logic xử lý
Vào màn hình **B230** (Cấu trúc công đoạn) để thực hiện map Máy vào đúng Line và Công đoạn (Route) tương ứng.

---

## 💡 NGUYÊN TẮC VÀNG KHI TỰ SỬA (RULES)
1. **Luôn SELECT trước khi UPDATE:** Để đảm bảo điều kiện WHERE của bạn chỉ tác động đúng dòng cần sửa.
2. **Kiểm tra Transaction:** Nếu sửa dữ liệu lớn, hãy dùng `BEGIN TRAN ... ROLLBACK/COMMIT`.
3. **Bám sát Docx:** File `Lỗi trên NAIS System_Tái bản.docx` là "sách giáo khoa", luôn tra cứu từ khóa trong đó trước khi hỏi mentor.
