# KB_04 — Đóng Gói & In Tem

> **Màn hình liên quan:** B523, B789, B781, B450, B351, A419, A460
> ← [Về INDEX](KB_INDEX.md)

---

## 6. 📦 Đóng gói & In tem

### 6.1 Lỗi "Chưa có tiêu chuẩn đóng gói" (B523 & Phần mềm cân)

**Triệu chứng:** B523 báo lỗi "Chưa có tiêu chuẩn đóng gói" khi thử gộp box.

**Nguyên nhân:** Model mới chưa được khai báo số lượng tiêu chuẩn mỗi thùng.

**Xử lý:**
1. Vào màn **A419** → Thêm số lượng đóng gói cho Model đó
2. Hoặc INSERT trực tiếp bằng SQL:
```sql
-- Kiểm tra tiêu chuẩn đóng gói hiện có
SELECT * FROM STB_PackingStandard WHERE MaterialTypeCode = 'FERT'

-- Thêm tiêu chuẩn mới (theo MaterialTypeCode + Size, không theo MaterialCode)
-- Cấu trúc bảng: MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty
INSERT INTO STB_PackingStandard (MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty, CreateDateTime, CreateUserID)
VALUES ('FERT', '0813', NULL, NULL, 500, 4000, 8000, GETDATE(), 'vinaadmin')
```

> ⚠️ **Xác minh DB (2026-05-17):** Bảng `STB_PackingStandard` KHÔNG có cột `MaterialCode` hay `PackQty`. Tra theo `MaterialTypeCode` (FERT) + `Size` (0813=8x13mm). Quản lý số lượng đóng gói chủ yếu qua **màn A419**.

**Tiêu chuẩn cân:** Vào SP `usp_Vvt_TieuChuanPacking_Vvt` → Thêm dòng cho Model mới.

---

### 6.2 Sửa tên Lot sau B351 (Chuyển đổi Lot)

**Triệu chứng:** Sau khi B351 chuyển đổi Lot, Barcode xuất hiện dấu chấm (`.`) thay vì chữ `R`.

**VD:** `VVPR152.740601` → phải là `VVPR152R740601`

```sql
-- Bước 1: Tìm Barcode sai định dạng
SELECT * FROM STB_SetInfo WHERE Barcode LIKE 'VVPR152.%'

-- Bước 2: Sửa đồng bộ tất cả bảng (phải sửa cả 3)
DECLARE @OldBC NVARCHAR(50) = 'VVPR152.740601'
DECLARE @NewBC NVARCHAR(50) = 'VVPR152R740601'

UPDATE STB_RawMaterialInputHist SET Barcode = @NewBC WHERE Barcode = @OldBC
UPDATE STB_SetInfo SET Barcode = @NewBC WHERE Barcode = @OldBC
UPDATE STB_LotChangeMaterialHistory SET NewBarcode = @NewBC WHERE NewBarcode = @OldBC

-- Bước 3: Xác nhận
SELECT Barcode FROM STB_SetInfo WHERE Barcode = @NewBC
```

---

### 6.3 Sửa mã NVL in lại tem B523 (in sai MaterialCode)

**Triệu chứng:** Tem in ra có mã sản phẩm sai, cần in lại với mã đúng.

**Nguyên nhân:** Bảng `STB_MaterialLotInfo` đang lưu sai MaterialCode.

```sql
-- Bước 1: Tìm MaterialLotNo của Barcode cần sửa
SELECT MLI.MaterialLotNo, MLI.LotNo, MLI.MaterialCode
FROM STB_MaterialLotInfo MLI
LEFT JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
WHERE SI.Barcode = 'VVOO053R825706'

-- Bước 2: Sửa MaterialCode (dùng MaterialLotNo - PK cụ thể)
UPDATE STB_MaterialLotInfo
SET MaterialCode = 'LIVT38-025'  -- Mã đúng
WHERE MaterialLotNo = 20240612000524

-- Bước 3: In lại tem ở B523
```

---

### 6.4 Lỗi không gộp Box được (B523 — Quy trình debug chuẩn)

**Triệu chứng:** Quét barcode vào B523 nhưng không gộp được, không có thông báo lỗi rõ.

**Debug theo thứ tự 4 bước:**

```sql
-- Bước 1: Kiểm tra F110 — Vật tư có được phép dùng Lot không?
SELECT MaterialCode, IsUseBarcode, IsLotUse
FROM STB_MaterialStockAttributeInfo
WHERE MaterialCode = 'Mã_VLieu'
-- Nếu trống → Vào F110 nhập và Save
-- Nếu IsLotUse = 0 → Vào F110 tích và Save

-- Bước 2: Kiểm tra QC đã Pass chưa?
SELECT Barcode, LotDecisionResult, IsDefect, DefectQty, IsProdFinish
FROM STB_SetInfo
WHERE Barcode = 'Mã_Barcode'
-- LotDecisionResult NULL hoặc 'FAIL' → Chưa QC → Yêu cầu QC đánh giá

-- Bước 3: Kiểm tra đã gộp vào Box khác chưa?
SELECT LotID, LotNo, PackingID, CurrentQty
FROM STB_MaterialLotInfo
WHERE LotNo = 'Mã_Barcode'
-- PackingID khác NULL → Đã gộp vào box khác rồi

-- Bước 4: Kiểm tra tiêu chuẩn đóng gói
SELECT * FROM STB_PackingStandard WHERE MaterialCode = 'Mã_Model'
-- Trống → Vào A419 thêm tiêu chuẩn
```

---

### 6.5 Lỗi gộp túi bóng bị mất số lượng (Qty = 0) — HN544

**Triệu chứng:** Sau khi gộp túi bóng thành hộp nhỏ, số lượng hiển thị = 0, không in được tem.

**Debug:**
```sql
-- Kiểm tra số lượng trong DB
SELECT MaterialLotNo, LotNo, CurrentQty, InitialQty, PackingID
FROM STB_MaterialLotInfo
WHERE LotNo = 'SP260516-003'
```

**Nếu CurrentQty = 0 nhưng hàng còn thực tế:**
```sql
-- Gộp 1 túi: Dồn tổng vào 1 LotID duy nhất
UPDATE STB_MaterialLotInfo
SET InitialQty = 20, CurrentQty = 20
WHERE MaterialLotNo = 'Mã_LotNo_Cần_Giữ'

-- Xóa các LotID thừa (đã dồn số lượng vào 1 rồi)
DELETE FROM STB_MaterialLotInfo WHERE MaterialLotNo IN ('LotID_Thừa_1', 'LotID_Thừa_2')
```

---

### 6.6 Lỗi Packing Qty âm ở B523

**Triệu chứng:** B523 báo số lượng âm khi thực hiện đóng gói.

**SP liên quan:** `usp_savePackingLabelQty_VVT`

```sql
-- Kiểm tra số lượng hiện tại trong từng bảng
SELECT CurrentQty, InitialQty FROM STB_MaterialLotInfo WHERE LotNo = 'Mã_Lot'
SELECT PackQty FROM STB_SavePackingTime_VVT WHERE LotNo = 'Mã_Lot'

-- Nếu CurrentQty âm → Reset về số lượng đúng
UPDATE STB_MaterialLotInfo
SET CurrentQty = [Số_Lượng_Thực]
WHERE LotNo = 'Mã_Lot'
```

---

### 6.7 Lỗi VV → VJ (Đổi đầu mã tem)

**Logic hoạt động:**
```
Case 1: In label thẳng (không đổi) → PrintVJ = 0 trong STB_Vietnam_PackingPrinting
Case 2: Đổi VV→VJ theo PartNo → PrintVJ = 1 trong STB_Vietnam_PackingPrinting
Case 3: Ngoại lệ không đổi → Fix cứng trong SP usp_Vietnam_GetBoxIDForLotNo_VVT
```

> ⚠️ Sau khi đổi → kiểm tra tên model không trùng với bên Hàn Quốc → Nếu trùng thì không đổi được.

```sql
-- Kiểm tra cấu hình in VJ của model
SELECT * FROM STB_Vietnam_PackingPrinting WHERE MaterialCode = 'Mã_NVL'

-- Tắt đổi VV→VJ
UPDATE STB_Vietnam_PackingPrinting SET PrintVJ = 0 WHERE MaterialCode = 'Mã_NVL'
```

---

### 6.8 Thiết kế tem Phoenix Contact (Yêu cầu đặc biệt)

- **Kích thước:** Tem 5x8 cm
- **Datecode:** Lấy từ công đoạn Winding (`InputJobDate` trong `STB_SetInfo`), format YYMMDD
- **Màn hình in:** **B790** (có ô nhập `Number Label`)
- **SP:** `usp_Vietnam_PhoenixContactLabelPrint_get`

```sql
-- Logic lấy Datecode
CONVERT(VARCHAR(6), SI.InputJobDate, 12) AS [DateCode]
```

---

### 6.9 Danh sách mã vật tư đã mở in tem (Support History)

| Dự án | MaterialCode | Màn hình | SP / Logic | Ghi chú |
|-------|-------------|----------|-----------|---------|
| Phoenix (VVT) | ECVT30-197, ECVT30-098 | B790 | `usp_Vietnam_PhoenixContactLabelPrint_get` | Tem Phoenix Datecode YYMMDD |
| Ha Nam (VVT_F3) | 10140105055 (Anode Foil) | F721/Kho | `STB_ModelLabelInfo` (PartLabel) | Mở in tem 자재라벨 |

---

### 6.10 Checklist khi user báo "không in được tem" (B450/B523)

```
□ 1. A460 — Format tem có tồn tại không? Đúng loại (AssembleLabel vs PartLabel)?
□ 2. A419 — Tiêu chuẩn đóng gói đã khai báo chưa?
□ 3. STB_MaterialLotInfo — MaterialCode đúng chưa?
□ 4. F110 — IsLotUse = 1, IsUseBarcode = 1 chưa?
□ 5. STB_SetInfo — LotDecisionResult = 'PASS' chưa?
□ 6. STB_MaterialStockAttributeInfo — Có dòng cho mã VL chưa?
```

*Cập nhật: 2026-05-17*
