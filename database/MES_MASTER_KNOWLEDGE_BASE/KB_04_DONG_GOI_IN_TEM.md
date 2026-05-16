# KB_04 — Đóng Gói & In Tem

> **Màn hình liên quan:** B523, B789, B781, B450, B351, A419
> ← [Về INDEX](KB_INDEX.md)

---

## 6. 📦 Đóng gói & In tem

### 6.1 Lỗi chưa có tiêu chuẩn đóng gói (màn B523 và phần mềm cân)

- **Thêm số lượng đóng gói:** Thêm ở màn **A419**.
- **Thêm tiêu chuẩn cân:** SP `usp_Vvt_TieuChuanPacking_Vvt`.

---

### 6.2 Sửa tên Lot sau khi update thông số Model ở A410 (trường hợp chuyển Lot ở B351)

```sql
-- Tìm kiếm Barcode bị sai định dạng (dấu chấm thay vì R)
SELECT * FROM STB_RawMaterialInputHist WHERE Barcode = 'VVPR152.740601'
SELECT * FROM STB_SetInfo WHERE Barcode = 'VVPR152.740601'
SELECT * FROM STB_LotChangeMaterialHistory WHERE NewBarcode = 'VVPR152.740601'

-- Cập nhật format chuẩn
UPDATE STB_RawMaterialInputHist SET Barcode = 'VVPR152R740601' WHERE Barcode = 'VVPR152.740601'
UPDATE STB_SetInfo SET Barcode = 'VVPR152R740601' WHERE Barcode = 'VVPR152.740601'
UPDATE STB_LotChangeMaterialHistory SET NewBarcode = 'VVPR152R740601' WHERE NewBarcode = 'VVPR152.740601'
```

---

### 6.3 Sửa mã in lại tem B523

```sql
-- Tìm kiếm MaterialLotNo
SELECT * FROM STB_MaterialLotInfo MLI
LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
WHERE SI.Barcode = 'VVOO053R825706'

-- Sửa MaterialCode
UPDATE STB_MaterialLotInfo
SET MaterialCode = 'LIVT38-025'
WHERE MaterialLotNo = 20240612000524
```
---

### 6.4 Thiết kế tem Phoenix Contact (Yêu cầu Sale 05/2026)

- **Đặc điểm:** Tem 5x8 cm, lấy Datecode (YYMMDD) từ công đoạn Winding (`InputJobDate` trong `STB_SetInfo`).
- **Màn hình in:** Đề xuất **B790** (Giao diện kiểu B756 có ô nhập số lượng `Number Label`).
- **Stored Procedure:** `usp_Vietnam_PhoenixContactLabelPrint_get`.
- **Logic lấy Datecode:**
```sql
-- Chuyển đổi InputJobDate sang YYMMDD
CONVERT(VARCHAR(6), SI.InputJobDate, 12) AS [DateCode]
```
- **Mapping Model (Z530):**
```sql
-- Map cho cả mã cũ và mã mới của dự án 3562
INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
VALUES ('ECVT30-197', 'Phoenix_Label', 'Phoenix_Contact_V1', GETDATE(), 'Antigravity'),
       ('ECVT30-098', 'Phoenix_Label', 'Phoenix_Contact_V1', GETDATE(), 'Antigravity')
```

---

### 6.5 Danh sách các mã vật tư đã mở in tem (Support History)

| Dự án / Nhà máy | Model / Material Code | Màn hình | Stored Procedure / Logic | Ghi chú |
| :--- | :--- | :--- | :--- | :--- |
| Phoenix (VVT) | ECVT30-197 / ECVT30-098 | B790 | `usp_Vietnam_PhoenixContactLabelPrint_get` | In tem Phoenix (Datecode YYMMDD) |
| Ha Nam (VVT_F3) | 10140105055 (Anode Foil) | F721 / Kho | `STB_ModelLabelInfo` (PartLabel) | Mở in tem 자재라벨 cho chị Hoàng Xuân (13/05/2026) |

---

### 6.6 Lỗi gộp túi bóng/box bị mất số lượng (Qty = 0) - Màn HN544
- **Triệu chứng:** Sau khi gộp túi bóng thành hộp nhỏ, số lượng trong grid hiển thị bằng 0, không cho in tem.
- **Nguyên nhân:** Cột `CurrentQty` và `InitialQty` trong bảng `STB_MaterialLotInfo` bị reset về 0 do lỗi logic khi thực hiện gộp (thường gặp ở Hà Nam).
- **Cách xử lý:**
    1. Kiểm tra sản lượng gốc của Lot tại `STB_SetInfo` (cột `ProdQty`).
    2. Nếu gộp nhiều túi vào 1, dồn tổng sản lượng vào 1 `LotID` duy nhất và xóa các `LotID` thừa.
    3. Nếu chia đều, cập nhật `UPDATE` lại số lượng cho từng `LotID` trong `STB_MaterialLotInfo`.
- **SQL mẫu:**
```sql
-- Kiểm tra số lượng hiện tại
SELECT LotID, LotNo, CurrentQty, PackingID FROM STB_MaterialLotInfo WHERE LotNo = 'SP260516-003'

-- Fix số lượng (Ví dụ dồn 20 cái vào 1 túi)
UPDATE STB_MaterialLotInfo SET InitialQty = 20, CurrentQty = 20 WHERE LotID = 'Mã_Túi_Cần_Giữ'
```
