# KB_03 — Sản Xuất & Lịch Sử Routing

> **Màn hình liên quan:** B310, B450, B530, B540, B597, B598, B682, B726, B781, B782, B791
> ← [Về INDEX](KB_INDEX.md)

---

## 5. 🏭 Sản xuất & Lịch Sử Routing

### 5.1 Luồng Sản Xuất Đầy Đủ — Tham chiếu nhanh

```
B310 → Tạo PO (Lệnh Sản Xuất)
    ↓
B450 → Lập kế hoạch ngày + Tạo Lot + In tem
    ↓
B540 → Nhập nguyên liệu theo từng công đoạn (V22→V28)
    ↓
B597 → Kiểm tra thường xuyên (QC inline)
    ↓
B530 → Nhập số lượng sản xuất (bắt buộc nhập "Making")
    ↓
B523 → Đóng gói & In label thùng hàng
```

> ⚠️ **Cột IsFixed ở B450 phải được tích** mới tạo được Lot.
> ⚠️ **B530 bắt buộc nhập chữ "Making"** (chọn ở cột Status) nếu không công đoạn V25 sẽ bị chặn không cho lưu. Đây là điều kiện tiên quyết để hệ thống ghi nhận đang sản xuất.

---

### 5.2 Sửa JobDate màn B782 (Lịch sử Routing)

**Triệu chứng:** Barcode bị ghi nhận sai ngày sản xuất ở công đoạn nào đó.

```sql
-- Bước 1: Tìm ControlNo từ Barcode
SELECT ControlNo FROM STB_SetInfo WHERE Barcode IN ('VVPO273R010713', 'VVPO123R010711')

-- Bước 2: Xem lịch sử routing hiện tại của Barcode đó
SELECT * FROM STB_ProdRouteHist
WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVPO273R010713'
)
ORDER BY ProdDateTime

-- Bước 3: Sửa ngày (giữ nguyên giờ phút giây)
UPDATE STB_ProdRouteHist
SET ProdDateTime = CAST('2025-02-17' AS DATETIME) + CAST(ProdDateTime AS TIME),
    JobDate = '20250217'  -- Format: YYYYMMDD
WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo WHERE Barcode IN ('VVPO273R010713', 'VVPO123R010711')
)
AND RouteCode = 'V-22_BG'  -- Chỉ sửa công đoạn cụ thể, không sửa hết
```

> **SP dùng để xác minh:** `usp_LotTrackingInfo_VVT2_get`

---

### 5.3 Sửa JobDate màn B781 (Packing History)

**Triệu chứng:** Lịch sử đóng gói bị ghi nhầm ngày.

```sql
-- Bước 1: Xem dữ liệu hiện tại (SP: usp_Vietnam_PackPrintTime_get)
SELECT SPT.*, SI.InputLineCode
FROM STB_SavePackingTime_VVT SPT
LEFT JOIN STB_SetInfo SI ON SPT.LotNo = SI.Barcode
WHERE SPT.LotNo IN ('VVPK173R015603', 'VVPK173R015606')

-- Bước 2: Sửa ngày (ghi lại ID cụ thể trước khi sửa)
UPDATE STB_SavePackingTime_VVT
SET PrintTime = CAST('2025-02-17' AS DATETIME) + CAST(PrintTime AS TIME)
WHERE LotNo IN ('VVPK173R015603', 'VVPK173R015606')
AND ID IN ('1217734', '1217736')  -- Dùng ID cụ thể, an toàn hơn
```

---

### 5.4 Sửa JobDate màn B598 (Production Error)

> ⚠️ **Cơ chế đặc biệt:** `JobDate` được tự động tạo từ `CreateDateTime`. Muốn JobDate về ngày **17** thì phải set `CreateDateTime` về ngày **18** (cộng 1 ngày so với ngày muốn).

```sql
-- Tìm bản ghi cần sửa
SELECT * FROM STB_VN_PRODUCTION_ERROR
WHERE CAST(CreateDateTime AS DATE) = '2025-02-18'

-- Sửa (chú ý cộng thêm 1 ngày)
UPDATE STB_VN_PRODUCTION_ERROR
SET CreateDateTime = CAST('2025-02-18' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE IDPE IN ('ID1', 'ID2', ...)
```

---

### 5.5 Sửa ngày màn B726 (Scrap After Production)

```sql
-- Tìm dữ liệu: Ấn "Xem thông tin chi tiết" trên màn B726 để lấy ID
SELECT * FROM STB_VN_SCRAP_AFTERPRODUCTIONS WHERE ID = 4962

-- Sửa ngày
UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS
SET CreateDateTime = CAST('2025-03-01' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE ID = 4962

-- Xóa mềm (soft delete - không xóa hẳn)
UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS
SET IsDeleted = 1
WHERE ID IN (6030, 6032, 6027, 6025, 6026, 6031)
```

---

### 5.6 Sửa ngày màn FG00 (Kho Thành Phẩm BG)

> **Ngày nhập:** `CreateDate` | **Ngày xuất:** `DateExport`

```sql
-- Xem trước
SELECT IDCODE, CreateDate, DateExport FROM STB_VN_FINISHGOODS_BG
WHERE IDCODE = 'FGVN_BG20250211054041195484931'

-- Sửa cả 2 cột ngày
UPDATE STB_VN_FINISHGOODS_BG
SET CreateDate = CAST('2025-01-11' AS DATE),
    DateExport = CAST('2025-01-11' AS DATE)
WHERE IDCODE = 'FGVN_BG20250211054041195484931'
```

---

### 5.7 Xóa PO (Production Order)

> ⚠️ **BẮT BUỘC xóa ở cả 2 màn hình: B450 và B310** và đủ tất cả bảng liên quan. Thiếu bảng nào sẽ gây inconsistent data.

```sql
-- === XÓA Ở B450 (kế hoạch ngày và lot) ===
-- Bước 1: Tìm DayPlanNo liên quan đến PO
SELECT DayPlanNo FROM STB_DayProdPlan WHERE PONo IN ('250303000008', '250304000011')

-- Bước 2: Xóa lot đã tạo (SetInfo)
DELETE FROM STB_SetInfo WHERE DayPlanNo IN ('2025030300011', '2025030400202')

-- Bước 3: Xóa kế hoạch ngày
DELETE FROM STB_DayProdPlan WHERE DayPlanNo IN ('2025030300011', '2025030400202')

-- === XÓA Ở B310 (PO gốc) ===
-- Phải xóa 3 bảng theo thứ tự này (tránh lỗi FK)
DELETE FROM STB_ProductionOrderRouting WHERE PONo IN ('250303000008', '250304000011')
DELETE FROM STB_ProductionOrderBom WHERE PONo IN ('250303000008', '250304000011')
DELETE FROM STB_ProductionOrderInfo WHERE PONo IN ('250303000008', '250304000011')
```

---

### 5.8 Sửa số lượng NG DefectQty (Màn B791)

**Triệu chứng:** Số lượng lỗi (NG) bị ghi nhận sai, cần sửa lại.

```sql
-- Bước 1: Tìm bản ghi
SELECT * FROM STB_DefectRepairInfo WHERE ControlNo = '20250314000351'

-- Bước 2: Sửa DefectQty
UPDATE STB_DefectRepairInfo
SET DefectQty = 4
WHERE ControlNo = '20250314000351'

-- Bước 3: Sửa số lượng input công đoạn sau
-- ProdQty tại công đoạn tiếp theo = TotalQty - DefectQty
UPDATE STB_ProdRouteHist
SET ProdQty = 3996
WHERE ControlNo = '20250314000351' AND RouteCode = 'MV-05'
```

---

### 5.9 Chuyển Line sản xuất (B452)

**Khi nào dùng:** Công nhân lập kế hoạch chọn nhầm Line ở B450, nhưng đã có sản lượng thực tế rồi.

```sql
-- Bước 1: Xác định Barcode bị sai Line
SELECT Barcode, InputLineCode FROM STB_SetInfo WHERE Barcode = 'VVOR163R010713'

-- Bước 2: Sửa Line trong SetInfo (trạng thái lot)
UPDATE STB_SetInfo
SET InputLineCode = 'VVBGC-12'
WHERE Barcode = 'VVOR163R010713'

-- Bước 3: Sửa Line trong ProdRouteHist (lịch sử routing)
UPDATE STB_ProdRouteHist
SET LineCode = 'VVBGC-12'
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVOR163R010713')

-- Bước 4: Kiểm tra lại
SELECT SI.Barcode, SI.InputLineCode, PRH.LineCode, PRH.RouteCode
FROM STB_SetInfo SI
JOIN STB_ProdRouteHist PRH ON SI.ControlNo = PRH.ControlNo
WHERE SI.Barcode = 'VVOR163R010713'
```

---

### 5.10 Chuyển mã Barcode VV → VJ

**Khi nào dùng:** Cần đổi đầu mã từ VV sang VJ cho tem hàng xuất khẩu hoặc theo yêu cầu khách hàng.

> ⚠️ Phải cập nhật đồng bộ TẤT CẢ bảng có lưu Barcode này.

```sql
-- Khai báo biến để dễ thay đổi
DECLARE @OldBarcode NVARCHAR(50) = 'VVOQ062R725633'
DECLARE @NewBarcode NVARCHAR(50) = 'VJOQ062R725633'

-- Cập nhật đồng bộ tất cả bảng
UPDATE STB_SetInfo SET Barcode = @NewBarcode WHERE Barcode = @OldBarcode
UPDATE STB_LotChangeMaterialHistory SET NewBarcode = @NewBarcode WHERE NewBarcode = @OldBarcode
UPDATE STB_SavePackingTime_VVT SET LotNo = @NewBarcode WHERE LotNo = @OldBarcode    -- B781
UPDATE STB_MaterialLotInfo SET LotNo = @NewBarcode WHERE LotNo = @OldBarcode         -- B523 in tem
UPDATE STB_ProdRouteHist SET ControlNo = @NewBarcode WHERE ControlNo = @OldBarcode   -- nếu cần

-- Xác nhận sau khi đổi
SELECT Barcode FROM STB_SetInfo WHERE Barcode = @NewBarcode
```

---

### 5.11 Lỗi kế hoạch ngày chọn nhầm Line (B450)

**Triệu chứng:** 2 Model khác nhau xuất hiện trên cùng 1 Line trong báo cáo Excel/Pivot.

**Truy vết:**
```sql
-- Tìm các DayPlan bị xung đột trên Line đó
SELECT DayPlanNo, PlanDate, MaterialCode, LineCode, CreateUserID, CreateDateTime
FROM STB_DayProdPlan
WHERE LineCode = 'VVBNTC-01' AND PlanDate = '20260516'
ORDER BY CreateDateTime

-- Dùng "Time Window" để tìm các kế hoạch bị tạo nhầm (trong 10 giây)
SELECT DayPlanNo, LineCode, MaterialCode, CreateDateTime
FROM STB_DayProdPlan
WHERE CreateUserID = 'ID_Người_Lập'
AND CreateDateTime BETWEEN '2026-05-16 08:00:00' AND '2026-05-16 08:00:10'
ORDER BY DayPlanNo ASC
```

**Xử lý:**
- **Chưa có sản lượng:** Hủy kế hoạch sai tại B450 → Tạo lại đúng Line
- **Đã có sản lượng:** Dùng script "Chuyển Line sản xuất" (Mục 5.9 trên)

---

### 5.12 Sửa giá công đoạn Stage Prices (B682, B781)

> Xem chi tiết tại [KB_06 Mục 3](KB_06_MASTER_DATA_TOOLS.md#3-fix-giá-công-đoạn-stage-prices)

---

### 5.13 Sửa/Xóa số lượng đóng gói (B789)

```sql
-- Tìm ID bản ghi sai
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = 'Barcode_Cần_Sửa'

-- Cập nhật PackQty
UPDATE STB_SavePackingTime_VVT SET PackQty = 500
WHERE LotNo = 'Barcode_Cần_Sửa' AND id = [ID_Cụ_Thể]

-- Xóa bản ghi thừa
DELETE FROM STB_SavePackingTime_VVT WHERE id = [ID_Thừa]
```

---

### 5.14 Mở dữ liệu Andon theo tháng (B882)

**SP:** `usp_Vietnam_AndonDetail_get`
→ Vào SP → Tìm điều kiện lọc theo tháng → Chỉnh lại khoảng thời gian user yêu cầu.

---

### 5.15 Truy vết lịch sử 1 Barcode từ A→Z

```sql
-- Query tổng hợp toàn bộ hành trình của 1 Barcode
SELECT
    SI.Barcode,
    SI.MaterialCode,
    MM.MaterialName,
    SI.ProdQty,
    SI.InputLineCode,
    SI.PONo,
    SI.LotDecisionResult AS [KQ_QC],
    SI.IsProdFinish AS [HoanThanh],
    PRH.RouteCode,
    PRH.ProdDateTime AS [Thoi_Gian_Quet],
    PRH.LineCode AS [Line_Cong_Doan]
FROM STB_SetInfo SI
JOIN STB_MaterialMaster MM ON SI.MaterialCode = MM.MaterialCode
LEFT JOIN STB_ProdRouteHist PRH ON SI.ControlNo = PRH.ControlNo
WHERE SI.Barcode = 'VVPO273R010713'
ORDER BY PRH.ProdDateTime ASC
```

### 5.16 Logic bóc tách Part No từ Model Name

**Mục đích:** Khi cần lấy mã Part No rút gọn (VD: `VEC3R0606QG`) từ chuỗi Model Name đầy đủ (VD: `HY-CAP VEC3R0606QG (1840)`).

```sql
-- Cách 1: Dùng chuỗi REPLACE lồng nhau (loại bỏ prefix/suffix)
SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE('HY-CAP VEC3R0606QG (1840)','HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)','') AS model

-- Cách 2: Dùng SUBSTRING (lấy 12 ký tự sau dấu cách đầu tiên)
SELECT (RTRIM(LTRIM(SUBSTRING('HY-CAP VEC3R0606QG (1840)', CHARINDEX(' ', 'HY-CAP VEC3R0606QG (1840)'), 12)))) AS partno
```

---

### 5.17 Tra cứu Model Code và Size tại màn B597

**Mục đích:** Khi cần kiểm tra nhanh Size của Barcode tại công đoạn QC inline.

```sql
DECLARE @ModelSize VARCHAR(10) = '';
DECLARE @ModelName NVARCHAR(200) = '';

-- Bước 1: Lấy Size từ ModelBasicInfo (W x H)
SELECT @ModelSize = RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
FROM STB_ModelBasicInfo WITH(NOLOCK)
WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'VVPR293R018602')

-- Bước 2: Lấy ModelName rút gọn
SELECT @ModelName = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ModelName,@ModelSize,''),'(',''),')',''),' ',''),'HY-CAP ',''),'HY-CAP',''),'-','%')
FROM STB_ModelBasicInfo WITH(NOLOCK)
WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'VVPR293R018602')

PRINT (@ModelName + ' ' + @ModelSize)
```

*Cập nhật: 2026-05-17*
