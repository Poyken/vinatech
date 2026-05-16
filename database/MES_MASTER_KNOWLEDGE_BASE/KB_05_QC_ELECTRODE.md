# KB_05 — Kiểm tra Chất lượng (QC) & Điện cực

> **Màn hình liên quan:** B597, C443, C512, B270, B540, B552
> ← [Về INDEX](KB_INDEX.md)

---

## 7. 🔬 Kiểm tra Chất lượng (QC)

### 7.1 B597 báo lỗi "Hạng mục kiểm tra cũ / sai"

**Triệu chứng:** Vào B597 hoặc C443, hệ thống load lại hạng mục cũ của lần trước, không cho sửa.

**Nguyên nhân:** `STB_CommInspDocHistory` đã có bản ghi cũ cho Barcode này.

**Debug và Fix:**
```sql
-- Bước 1: Tìm CommInspDocNo từ Barcode
SELECT CIDH.CommInspDocNo, CIDH.ProdNo, CIDH.CreateDateTime
FROM STB_CommInspDocHistory CIDH
JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
WHERE SI.Barcode = 'VVPO093R010707'

-- Hoặc tìm trực tiếp bằng ControlNo
SELECT * FROM STB_CommInspDocHistory
WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVPP163R072732')

-- Bước 2: Xem hạng mục kiểm tra đang có
SELECT * FROM STB_CommInspDocItem
WHERE CommInspDocNo = 'CommInspDocNo_Tìm_Được'

-- Bước 3: Xóa để hệ thống khởi tạo lại (xóa Item trước, rồi xóa History)
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = 'CommInspDocNo_Cần_Xóa'
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = 'CommInspDocNo_Cần_Xóa'
```

> ⚠️ Sau khi xóa, QC cần **tắt màn hình và mở lại** để hệ thống load bộ tiêu chuẩn mới.

**SP liên quan:**
- C443: `usp_GetCommInspection_HistoryForBarcode_Vietnam`
- B597: `usp_GetCommInspectionHistoryForBarcode`

---

### 7.2 Không tìm thấy Lot ở màn C512

**3 nguyên nhân — Debug theo thứ tự:**

```sql
-- Bước 1: Kiểm tra Lot đã tồn tại chưa
SELECT Barcode, MaterialCode, InputLineCode, CurrentRouteCode, LotDecisionResult
FROM STB_SetInfo WHERE Barcode = 'Mã_Barcode'
-- Nếu có kết quả → Lot đã tồn tại → Báo QC tìm lại đúng barcode
-- Nếu không có → Lot chưa được tạo → Quay lại B450 tạo Lot

-- Bước 2: Kiểm tra A410 đã setup OQC chưa
SELECT ModelCode, OqcType, InspectionType, OqcInspectionRuleType
FROM STB_ModelBasicInfo
WHERE ModelCode = 'Mã_Model'
-- Nếu OqcType NULL hoặc InspectionType NULL → Chưa setup → Liên hệ anh Huy
-- Sau khi anh Huy setup xong → tắt C151, vào lại C512

-- Bước 3 (Hà Nam): Kiểm tra Route bắt đầu
SELECT CurrentRouteCode FROM STB_SetInfo WHERE Barcode = 'Mã_Barcode'
-- Nếu bắt đầu từ VE02 → Không hiện ở C512 → Đây là thiết kế của hệ thống
```

---

### 7.3 B597 báo lỗi "Hết hạn sử dụng"

→ Xem [KB_02 Mục 4.10](KB_02_KHO_WMS.md#410-kiểm-tra-hạn-sử-dụng-nvl-expiry-date) để tra cứu công thức tính.

---

### 7.4 B597 báo lỗi "Không tồn tại thiết lập Vỏ Nhôm"

**Triệu chứng:** `"Không tồn tại thiết lập Vỏ Nhôm của LotNo... với mã Vỏ Nhôm: GBDYAC-004 <> ECVT30-367"`

**Debug:**
```sql
-- Kiểm tra mapping hiện tại
SELECT * FROM STB_AluCaseMapping_VVT WHERE ModelCode = 'ECVT30-367'
```

**Fix (chọn 1 trong 2 cách):**

**Cách 1 - Thêm vào bảng mapping:**
```sql
INSERT INTO STB_AluCaseMapping_VVT (AluCaseCode, ModelCode, CreateUserID, CreateDateTime)
VALUES ('GBDYAC-004', 'ECVT30-367', 'vinaadmin', GETDATE())
```

**Cách 2 - Sửa trong SP (khi bảng mapping không đủ):**
```sql
-- Tìm đoạn code chặn trong SP
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))
-- Ctrl+F tìm từ khóa 'ECVT30-367' hoặc 'AluCase'
-- Tìm đến điều kiện IF/CASE → Thêm mã mới vào NOT IN list
-- VD: IF (@MaterialCode = 'ECVT30-367' AND @pRawMaterialBarcode NOT IN ('GBRLAC-004', 'GBDYAC-004'))
```

---

### 7.5 B597 báo lỗi "Mã Electrolyte không khớp với BOM"

**Triệu chứng:** `"Mã Electrolyte/DUNG DỊCH được thiết lập, khác với mã QRCODE nhập vào B597"`

**Nguyên nhân:** Công nhân đang dùng mã NVL thay thế (VD: `GBEC00-011`) nhưng BOM vẫn cấu hình mã cũ (`GBCP00-001`).

**Debug:**
```sql
-- Kiểm tra BOM của Model đang sản xuất
SELECT BD.MaterialCode AS [Mã_NVL_BOM], BD.MaterialName
FROM STB_BomDetail BD
JOIN STB_BomHeader BH ON BD.BomHeaderNo = BH.BomHeaderNo
WHERE BH.MaterialCode = 'Mã_Model_SX'
AND BD.MaterialCode LIKE 'GBE%'  -- Lọc các mã electrolyte
```

**Xử lý:**
1. **Đúng chuyên môn:** Báo EA/R&D kiểm tra BOM có cần cập nhật không
2. **IT fix tạm (chờ BOM update):** Vào SP `usp_Vietnam_RawMaterialInputHist_uid` → Tìm CTE `eleclyte1` → Thêm ngoại lệ:
```sql
-- Thêm vào CTE eleclyte1 trong SP:
UNION ALL
SELECT 'GBEC00-011' AS electrolyte, 'WEC3R0606QG' AS model, '1840' AS size
```

---

### 7.6 B597 báo lỗi "Chuỗi điện cực không khớp" (Electrode Thickness)

**Nguyên nhân:** NVL điện cực mới đăng ký thiếu hoặc sai Độ dày (`MaterialThickness`). Hệ thống so sánh chuỗi bị lỗi khi độ dày `200` != `200.000000`.

**Debug:**
```sql
-- Kiểm tra MaterialThickness trong Master
SELECT MaterialCode, MaterialThickness FROM STB_MaterialMaster
WHERE MaterialCode = 'Mã_Điện_Cực'

-- Kiểm tra độ dày đã nhập trong Lot (SIExtReal03)
SELECT Barcode, SIExtReal03 AS [Do_Day_Da_Nhap] FROM STB_SetInfo
WHERE Barcode = 'Mã_Barcode_Bị_Lỗi'
```

**Fix theo thứ tự:**
```sql
-- Fix 1: Sửa MaterialMaster thành số nguyên (không có .000)
UPDATE STB_MaterialMaster
SET MaterialThickness = '200'  -- Không phải '200.000000'
WHERE MaterialCode = 'Mã_Điện_Cực'

-- Fix 2: Nếu công nhân đã tạo Lot rồi → Sửa cả SIExtReal03
UPDATE STB_SetInfo
SET SIExtReal03 = 200  -- Số nguyên, không có thập phân
WHERE Barcode = 'Mã_Barcode'

-- Fix 3: Nếu lỗi liên quan đến bảng điện cực
UPDATE STB_ElectrodeWastePriceNew SET ElectrodeThickness = 200 WHERE [Điều_Kiện]
UPDATE STB_ElectrodeWasteInfoNew SET ElectrodeThickness = 200 WHERE [Điều_Kiện]
```

---

### 7.7 B597 báo lỗi HOLDING

**Nguyên nhân:** Lô NVL đang ở trạng thái HOLD do chưa qua IQC hoặc bị hold thủ công.

```sql
-- Kiểm tra trạng thái IQC của Lot NVL
SELECT LotID, InspectionStatus, HoldReason
FROM STB_MaterialQcInfo
WHERE LotID = 'ML...'
-- InspectionStatus = 'HOLD' → Hàng đang bị giữ

-- Muốn bỏ HOLD (cần có sự đồng ý của QC)
UPDATE STB_MaterialQcInfo
SET InspectionStatus = 'PASS'
WHERE LotID = 'ML...'
```

---

## 8. ⚡ Điện cực (Electrode)

### 8.1 Chỉnh chiều rộng Slitting (B552)

```sql
-- Xem cấu hình master slitting
SELECT * FROM STB_CoatingToSlittingMaster
-- WHERE CoatingMaterialCode = 'Mã_Coating'

-- Cập nhật chiều rộng slitting
UPDATE stb_slittinglocationconfig_vvt
SET Width = 16
WHERE SlittingCode = 'YP' AND SlittingSize = 200 AND PartNo = '1625' AND id = 12
```

---

### 8.2 Lỗi "Chưa CONFIG trong STB_SLITTINGLOCATIONCONFIG_VVT"

**Triệu chứng:** `"Không tồn tại thiết lập Điện cực của LotNo... Chưa CONFIG trong bảng: STB_SLITTINGLOCATIONCONFIG_VVT"`

**Debug:**
```sql
-- Xem thông số lỗi trong thông báo (VD: PartNo=1025, Farad=10, Width=17.7)
-- Kiểm tra bảng đã có chưa
SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'
```

**Fix — Thêm cấu hình mới:**
```sql
-- Template: BY = Cực dương (+), YP = Cực âm (-)
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),  -- Cực dương
    ('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2')   -- Cực âm

-- Xác nhận đã thêm
SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'
```

**Template thêm nhiều model cùng lúc:**
```sql
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),
    ('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2'),
    ('1325', 'BY', '200', '15', '18.7', 'VVT_F2', 'kho2'),
    ('1325', 'YP', '180', '15', '18.7', 'VVT_F2', 'kho2'),
    ('1030', 'BY', '200', '10', '23.7', 'VVT_F2', 'kho2'),
    ('1030', 'YP', '180', '10', '23.7', 'VVT_F2', 'kho2')

-- Sau đó cập nhật số cuộn và vị trí kho
UPDATE stb_slittinglocationconfig_vvt
SET RollQty = 20, PositiveLocation = 'A6-T3', NegativeLocation = 'B6-T3'
WHERE PartNo IN ('1025', '1325', '1030')
```

---

### 8.3 Checklist khi B597 báo lỗi khi lưu NVL

```
Theo thứ tự SP usp_Vietnam_RawMaterialInputHist_uid kiểm tra:
□ 1. HOLDING? → Kiểm tra STB_MaterialQcInfo.InspectionStatus
□ 2. Hết hạn? → Kiểm tra LotAttr10 + MMExtInt01 (xem KB_02 Mục 4.10)
□ 3. Sai chủng loại? → Kiểm tra BOM có mã NVL đó không (STB_BomDetail)
□ 4. Sai độ dày điện cực? → Kiểm tra MaterialThickness (số nguyên vs thập phân)
□ 5. Sai mã Electrolyte? → Kiểm tra CTE eleclyte1 trong SP
□ 6. Thiếu cấu hình Vỏ Nhôm? → Kiểm tra STB_AluCaseMapping_VVT
□ 7. Thiếu cấu hình Slitting? → Kiểm tra STB_SLITTINGLOCATIONCONFIG_VVT
```

---

### 8.4 Logic kho điện cực

```
Mã lot điện cực Slitting: VV... hoặc VJ...
Mã lot kho nguyên liệu: ML...

P (BY) = Cực Dương (+)
M (YP) = Cực Âm (-)

Kiểm tra tồn kho điện cực → tbl_SlittingStock
```

> Điện cực phải dùng mã Lot kho (prefix `ML`) khi nhập kho nguyên liệu.

*Cập nhật: 2026-05-17*
