# 🏷️ 03 — Packaging & Label Printing Architecture

> **Mô hình in tem 3 lớp:** **Z530 (Giá sách layout)** $\rightarrow$ **A460 (Danh mục map)** $\rightarrow$ **Màn hình in B767/B523 (Người đọc)**.

---

## 1. 📐 Kiến Trúc In Tem 3 Lớp

1. **Lớp Thiết Kế (Z530):** Thiết kế layout XML (DevExpress XtraReports) lưu trong trường `SmartFramework.dbo.STB_LabelInfo.Format`.
2. **Lớp Ánh Xạ (A460):** Map `ModelCode` với `FormatName` và `LabelType` (`AssembleLabel`, `PartLabel`, `ElectLabel`).
3. **Lớp Thực Thi (B523, B767, B790):** Đọc data từ SP `_get`, load XML từ Z530, bind tham số và xuất lệnh ZPL ra máy in Zebra.

---

## 2. 🔍 Quy Chuẩn In Tem Khách Hàng Sanmina (B767 & KB_04_03)

### 2.1 Cấu Trúc Mã QR Code 2D (Sanmina Format)
QR Code định dạng nối chuỗi ngăn cách bằng `||` chứa đầy đủ 23 trường:
```
SupplierName||SanminaPartNumber||PartDesc||MFR||MPN||Quantity||PONumber||LotCode2||PackingDate||InspEmpName||CartonBoxNo||SerialListForQR
```

* **Quy tắc Outer vs Inner:**
  * **Outer Box (Thùng to):** Số lượng bằng tổng (`@pQuantity`), Serial hiển thị dạng danh sách gộp `Inner1Serial, Inner2Serial`.
  * **Inner Box (Hộp nhỏ):** Số lượng chia đôi (`@pQuantity / 2`), Serial hiển thị mã riêng từng hộp.

### 2.2 Các Bẫy Kỹ Thuật Khi In Tem Sanmina
1. **Bẫy NAIS Designer:** Thuộc tính `데이터 추가` (`Append Data`) của hàm tìm kiếm `usp_SanminaLabelPrint_get_Vietnam` bắt buộc đặt là `False`. Nếu để `True`, mỗi lần bấm Search sẽ bị nhân đôi số dòng trên lưới.
2. **Bẫy Cột BoxSerialNo:** Khi gộp chuỗi Serial cho tem Outer, cột `BoxSerialNo` trong `STB_SanminaIndiaLabelPrintHist` bắt buộc phải là `VARCHAR(50)` để không bị lỗi cắt cụt chuỗi (Truncation Error).

### 2.3 🛡️ Kiến Trúc Poka-Yoke In Tem Sanmina (B767_M + B767)
Hệ thống hỗ trợ 2 chế độ song song, đảm bảo tương thích 100% logic cũ và tự động hóa chống lỗi theo Lô xuất:

1. **Chế độ Tự Động (Poka-Yoke Lô Xuất):**
   * **Màn hình [B767_M] (Dành cho Leader/Kế hoạch):** Thiết lập Lô xuất gồm `PONumber`, `PartNumber` (user input tùy biến linh hoạt), `TotalBox`, `QtyPerBox`. Bấm nút **Kích Hoạt (ACTIVE)**.
   * **Màn hình [B767] (Dành cho OP tại xưởng):** OP chỉ cần quét duy nhất mã `Lot No` (Barcode). SP `usp_SanminaLabelPrint_get_Vietnam` tự động nạp `PONumber`, `PartNumber`, và tự nhảy `CartonBoxNo` (`01/Total`, `02/Total`...) theo tiến độ in thực tế.
   * **Tự động chuyển COMPLETED:** Khi OP in thùng cuối cùng (`PrintedBoxCount >= TotalBox`), hệ thống tự động đánh dấu Lô xuất hoàn tất (`Status = 'COMPLETED'`).
2. **Chế độ Nhập Thủ Công (Legacy / Manual Mode):**
   * Nếu không có Lô xuất nào đang `ACTIVE` hoặc OP tự nhập tay các ô PO Number, Part Number, Total Box $\rightarrow$ Hệ thống tự động chuyển sang chế độ manual, nhận trực tiếp tham số người dùng nhập mà không khóa cố định.

---

## 3. 📦 Hủy Gộp Box Thành Phẩm (B523 / HN544)

Khi cần rã thùng giải phóng Lot con:
```sql
BEGIN TRANSACTION;
-- 1. Xóa liên kết thùng trong STB_MaterialLotInfo
UPDATE STB_MaterialLotInfo SET PackingID = NULL WHERE PackingID = 'MÃ_THÙNG';
-- 2. Xóa bản ghi gộp thùng trong STB_DividePackaging
DELETE FROM STB_DividePackaging WHERE PackingID = 'MÃ_THÙNG';
COMMIT TRANSACTION;
```
