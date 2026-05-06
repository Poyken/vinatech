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
