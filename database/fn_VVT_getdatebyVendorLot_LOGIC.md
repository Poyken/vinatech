# 📅 Logic Parsing Ngày Sản Xuất (Vendor Lot)

> **Vị trí:** `fn_VVT_getdatebyVendorLot_MergeCode` (SQL Scalar Function)
> **Mục tiêu:** Parse ngày sản xuất từ mã Lot của nhà cung cấp (Vendor Lot) để tính Hạn sử dụng.

## 1. Các Vendor Thường Gặp & Cấu Trúc Mã

| Nhà Cung Cấp | Logic Parsing (Tạm tính) | Ghi chú |
|--------------|-------------------------|---------|
| **Vinatech (VVT)** | Thường theo format chuẩn `YYMMDD...` | Dễ nhất. |
| **Samwha** | Sử dụng bảng tra cứu chữ cái cho Năm/Tháng. | Cần tra `ABCDEFGHIJKLMNOPQRSTUVWXYZ`. |
| **Kemet** | Có thể dùng format Julian date hoặc Year-Week. | Cần cẩn thận. |
| **Cap-XX** | Thường có cấu trúc phức tạp hơn. | Xem thêm `KB_02`. |

## 2. Các Biến Quan Trọng Trong Function

- `@materialcode`: Mã nguyên vật liệu (dùng để xác định logic theo ProductGroup).
- `@vendorcode`: Mã nhà cung cấp.
- `@YEARstr`: Chuỗi ký tự đại diện cho năm (ví dụ: `ABC...` -> 2021, 2022...).
- `@dayStrPBDM00`: Chuỗi ký tự đại diện cho ngày (1-31).

## 3. Quy Trình Debug Khi Lỗi "Hết hạn" hoặc "Sai format Lot"

1. **Lấy mã Lot NCC thực tế:** Hỏi user mã họ đang nhập là gì.
2. **Xác định Product Group:** Chạy `SELECT ProductGroupCode FROM STB_MaterialMaster WHERE MaterialCode = ...`
3. **Test Logic Offline:** Dùng script `test_GBSN00_002.sql` để chạy thử function với mã Lot đó.
4. **Kiểm tra DB:** Nếu logic function đúng nhưng MES vẫn báo lỗi -> Kiểm tra `MMExtInt01` (Shelf Life) trong `STB_MaterialMaster`.

---

## ⚡ SQL Test Nhanh
```sql
DECLARE @vendorLot VARCHAR(50) = 'TRAY1030_DC050'; -- Thay mã Lot cần test
DECLARE @materialCode VARCHAR(50) = '...';

SELECT dbo.fn_VVT_getdatebyVendorLot_MergeCode(@vendorLot, @materialCode) AS ParsedDate;
```
