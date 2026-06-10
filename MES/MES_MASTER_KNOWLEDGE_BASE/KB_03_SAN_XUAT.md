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
> ⚠️ **Màn B540:** Không thể tích chọn trực tiếp vào checkbox `ProdQtyFinishYN` vì công đoạn đó đang sản xuất. Hệ thống sẽ tự động tích chọn checkbox này khi chốt sản lượng ở màn B530.
> ⚠️ **Màn B530:** Không thể hoàn thành kết quả sản xuất nếu chưa cập nhật `NULL` cho công đoạn trước đó để chốt lại, sau đó mới mở ra công đoạn tiếp theo.

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

👉 **Chi tiết Script Fix:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 8](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md)

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

👉 **Chi tiết Script Fix:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md)

---

### 5.14 Mở dữ liệu Andon theo tháng (B882)

**SP:** `usp_Vietnam_AndonDetail_get`
→ Vào SP → Tìm điều kiện lọc theo tháng → Chỉnh lại khoảng thời gian user yêu cầu.

---

### 5.15 Truy vết lịch sử 1 Barcode từ A→Z

```sql
-- 1. Query tổng hợp toàn bộ hành trình của 1 Barcode (Trực quan nhất)
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
ORDER BY PRH.ProdDateTime ASC;

-- 2. Đối soát Công đoạn thực tế đã qua vs Công đoạn chuẩn theo PO:
-- B1: Lấy thông tin PONo và ControlNo từ Barcode
SELECT Barcode, ControlNo, PONo, MaterialCode FROM STB_SetInfo WHERE Barcode = 'VE260509-001';

-- B2: Tra cứu công đoạn đã thực hiện trong thực tế (dùng ControlNo tìm được ở B1)
SELECT RouteCode, ProdQty, CreateDateTime 
FROM STB_ProdRouteHist 
WHERE ControlNo = '20260507000467' 
ORDER BY CreateDateTime ASC;

-- B3: Tra cứu cấu hình định tuyến (Routing) chuẩn của PO (dùng PONo tìm được ở B1)
SELECT RouteCode, RouteIndex, IsOutputRoute, IsRequireMachine 
FROM STB_ProductionOrderRouting 
WHERE PONo = '260506000015' 
ORDER BY RouteIndex ASC;
```

---

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

---

### 5.18 Quy trình 3 bước "Thám tử" truy vết và Hủy công đoạn / NG nhầm (Ví dụ: Lot VE260506-001)

Khi cần thực hiện rollback một Lot sản phẩm (ví dụ: `VE260506-001`) quay lại công đoạn trước (ví dụ: từ `VE09` về `VE07`) do công nhân nhập nhầm số lượng phế (NG) hoặc scan sai công đoạn, thực hiện theo 3 bước điều tra dữ liệu để đưa ra script xử lý chuẩn xác:

1. **Bước 1: Tìm mã định danh nội bộ (ControlNo) của Lot**
   ```sql
   SELECT Barcode, ControlNo, PONo 
   FROM STB_SetInfo 
   WHERE Barcode = 'VE260506-001';
   -- Kết quả: ControlNo là 20260428000408.
   ```
2. **Bước 2: Tra cứu lịch sử di chuyển (Routing History)**
   ```sql
   SELECT ProdRouteHistNo, RouteCode, ProdQty, CreateDateTime 
   FROM STB_ProdRouteHist 
   WHERE ControlNo = '20260428000408' 
   ORDER BY CreateDateTime ASC;
   -- Kết quả: Thấy danh sách các công đoạn quét. Ta xác định được VE08 và VE09 mới được quét nhầm chiều nay. Cần xóa hai bản ghi này.
   ```
3. **Bước 3: Tìm các bản ghi lỗi (NG) liên quan phát sinh**
   ```sql
   SELECT DefectSummaryNo, FindRouteCode, DefectQty, CreateDateTime 
   FROM STB_DefectRepairInfo 
   WHERE ControlNo = '20260428000408' 
     AND CreateDateTime >= '2026-05-11 16:00:00'; -- Lọc các lỗi nhập nhầm
   -- Kết quả: Tìm được các dòng lỗi với mã DefectSummaryNo.
   ```

**Kịch bản xử lý (Rollback / Revert):**
```sql
BEGIN TRANSACTION;

-- 1. Xóa Routing các bước quét nhầm (VE08, VE09)
DELETE FROM STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
  AND RouteCode IN ('VE08', 'VE09');

-- 2. Xóa các bản ghi lỗi (NG) nhập nhầm ở công đoạn sau và trạm trước lúc quét chuyển
-- Giải thích: Việc thêm trạm VE07 với mốc thời gian chèn nhầm là để xóa đi lượng phế
-- nhập nhầm cho trạm VE07 lúc khai báo chuyển tiếp VE08. Nếu giữ nguyên lượng phế này,
-- sản lượng của Lot khi chốt sang VE08 sẽ luôn bị hệ thống tự động trừ đi, không thể 
-- đưa về sản lượng gốc 5883 để công nhân nhập lại.
DELETE FROM STB_DefectRepairInfo 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
  AND (
    FindRouteCode IN ('VE08', 'VE09')
    OR 
    (FindRouteCode = 'VE07' AND CreateDateTime >= '2026-05-11 16:00:00')
  );

-- 3. Kiểm tra lại: Lot phải khôi phục về trạng thái cuối cùng ở VE07 với ProdQty = 5883
SELECT RouteCode, ProdQty, CreateDateTime 
FROM STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
ORDER BY CreateDateTime ASC;

-- COMMIT; -- Chạy dòng này khi thấy kết quả đã đúng
-- ROLLBACK; -- Chạy dòng này để hủy nếu sai
```

---

### 5.19 Kiểm tra và truy vết nguồn gốc thay đổi Ký hiệu in phun (Marking Letter / MarkingCode)

Khi cần kiểm tra ký hiệu in phun dán nhãn của Lot sản phẩm (ví dụ: `VE251120-002`) và truy tìm ai đã thiết lập hoặc thay đổi ký hiệu này:

```sql
-- 1. Tra cứu MarkingCode của mã Lot
SELECT MarkingCode, LotNo, MaterialCode FROM STB_MaterialLotInfo WHERE LotNo = 'VE251120-002';
-- Kết quả: Lấy được MarkingCode = 'MK00000974'

-- 2. Đi ngược từ MarkingCode về bảng Master để xem người tạo/người thay đổi và thời gian thay đổi
SELECT MarkingCode, MarkingName, Barcode, 
       CreateUserID, CreateDateTime, 
       ChangeUserID, ChangeDateTime 
FROM STB_CreateMarkingLetterAndQtyForBarcode 
WHERE MarkingCode = 'MK00000974';
```

*Cập nhật: 2026-05-27*

---

## 6. 🏭 Cell Line — Vận Hành Chi Tiết Từng Màn Hình

> **Nguồn:** Phân tích 41 SP + ảnh màn hình (2026-04-13)

### 6.1 Bản đồ tổng quan Cell Line (V22 → V28)

```
[B310] Tạo PO
    ↓
[B450] Kế hoạch SX ngày — tạo Lot (DayPlanNo → STB_DayProdPlan)
    ↓  IsFixed=1 → sinh Barcode → in tem (B460/A460)
[B540] Assy Card Info — nhập NVL điện cực + sấy
    ↓  V-22: Cuốn | V-23: Lắp cao su (PHẢI scan NVL trước) | V-24: Curling | V-25: Bọc vỏ
[B530] Nhập sản lượng theo công đoạn
    ↓  usp_DoProcessProdRouteHistForCalc_SmartApp_VNT
[B597] Kiểm tra thường xuyên — nhập mã Lot NVL kho (ML...)
    ↓  Chặn: HOLD / Hết hạn / Sai chủng loại
[B523] Đóng gói — Gộp Box (VV→VJ)
    ↓
[B717] Bending & Tapping — bẻ chân, dán băng keo
```

---

### 6.2 B450 — Kế Hoạch Sản Xuất Theo Ngày

**Vận hành:**
1. Chọn ngày, Line, nhập PO → Điền `LineCode`, `PlanDate`, `PlanQty`, `RouteCode`, `BomVersion`
2. **Tích `IsFixed=1`** → Tab bên dưới mới xuất hiện nút **Tạo Lot**
3. Bấm **Tạo Lot** → sinh `ControlNo` → lưu vào `STB_SetInfo`
4. Bấm **In Tem** → in barcode ra nhãn

| SP | Chức năng |
|----|-----------|
| `usp_DayProdPlan_get` | Lấy danh sách kế hoạch ngày |
| `usp_SetInfo_get` | Lấy danh sách barcode/Lot đã tạo |
| `usp_DayProdPlan_iud` | Lưu/Sửa/Xóa kế hoạch ngày |
| `usp_DoFixDayProdPlan` | Đánh dấu kế hoạch đã Fixed |
| `usp_DoCancelDayProdPlan` | Hủy kế hoạch |

**Lỗi thường gặp:**

| Lỗi | Nguyên nhân |
|-----|-------------|
| Không tạo được Lot | `IsFixed` chưa tích → SP không cho sinh serial |
| Đã tạo Lot rồi không tạo thêm | `usp_DayProdPlan_iud` check `StartSerial` đã có → duplicate (thiết kế có chủ ý) |
| In tem lỗi | Sang A460 → Assembly Label → chọn số 2 của cột Định dạng |
| Lot tạo xong nhưng B540 không thấy | `DayPlanNo` không được link vào `STB_SetInfo.DayPlanNo` |

---

### 6.3 B530 — Nhập Số Lượng Sản Xuất (Chi Tiết SP)

**SP đầy đủ từ màn hình:**

| SP | Loại | Chức năng |
|----|------|-----------|
| `usp_GetProdRouteHistForBarcode_VNT` | Search | Thông tin Route History theo Barcode |
| `usp_GetProdRouteBarcodeForDefect_VNT` | Search | Danh sách lỗi theo Barcode |
| `usp_WasteWeight_get` | Search | Thông tin cân phế |
| `usp_DoProcessProdRouteHistByBarcode_SmartApp` | Execute | Submit sản lượng |
| `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | Execute | Tính toán & validate (cổng chính) |
| `usp_DoUpdateRouteHistMarkingLetter` | Execute | Cập nhật ký hiệu đánh dấu |
| `usp_DoSplitLotAgingPV` | Execute | Tách Lot trước Aging |

**7 cổng chặn trong `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`:**

```
[GATE 1] Điện cực (V-22, VVT_F1/F2): usp_CheckInputElectrodeInputForCodeProduct
[GATE 2] NVL V-23/V-24 (VVT_F1/F2): usp_CheckInputRawMaterialCodeForProduct
[GATE 3] PQC Hà Nam (VE01/VE03/VE04/VE08): usp_CheckPQCInputForProductHistForBarcode
[GATE 4] Lot bị đóng: DPPExtText01 = '1' → RAISERROR 'Đã chốt'
[GATE 5] 20 phút (VNT, RouteIndex > 1): DATEDIFF(minute) <= 20 → RAISERROR
         ⚠️ BUG: Điều kiện @SIExtInt01 = Null (phải IS NULL) → Gate KHÔNG BAO GIỜ kích hoạt
[GATE 6] Bắt buộc mã máy: IsRequireMachine=1 AND MachineCode='' → RAISERROR
[GATE 7] PO không có Route: PONo IS NULL → RAISERROR 'Routing này không có trong PO'
```

**Cột IsRawMaterialInputFinish — Gate quan trọng nhất:**
```sql
-- Kiểm tra trạng thái scan NVL
SELECT ControlNo, Barcode, IsRawMaterialInputFinish
FROM STB_ProdRouteHist
WHERE Barcode = 'VV...' AND RouteCode = 'V-23'
-- 0 = Chưa scan đủ → B530 BLOCK | 1 = Đã scan đủ → cho phép

-- Bypass khẩn cấp (chỉ khi được phê duyệt)
UPDATE STB_ProdRouteHist
SET IsRawMaterialInputFinish = 1
WHERE Barcode = 'VV...' AND RouteCode = 'V-23'
```

**Lỗi thường gặp tại B530:**

| Lỗi | Nguyên nhân |
|-----|-------------|
| "Chưa nhập NVL cho Lắp Cao Su" | GATE 2: không tìm thấy record trong `STB_RawMaterialInputHist` cho V-23/V-24 |
| "Chưa nhập điện cực âm/dương" | GATE 1: `usp_CheckInputElectrodeInputForCodeProduct` — check `tbl_SlittingStock` |
| "Routing không có trong PO" | Barcode thuộc PONo không có RouteCode trong `STB_ProductionOrderRouting` |
| "Đã hoàn thành thực tế rồi" | `AftProdQty <> 0` → công đoạn kế tiếp đã có dữ liệu → scan trùng |
| Chữ "Making" chưa nhập ở V-25 | `MarkingLetter` rỗng → `usp_DoUpdateProdRouteHistMarkingLetter` không có data |

---

### 6.4 B540 — Assy Card Info

**Các tab chính:**

| Tab | Chức năng |
|-----|-----------|
| Common | Thông tin chung: MaterialCode, Barcode, InputDateTime, ProdQty |
| RawMaterialInputHist | Lịch sử NVL đã scan vào (điện cực âm/dương) |
| Prod Qty Input | Số lượng sản xuất theo công đoạn |
| Assy Card Info Oven | Thông tin lò sấy |

**Sấy hàng (Oven):** 4 cột bôi đậm BẮT BUỘC nhập → mới được in barcode. Dữ liệu lưu vào `STB_SetInfo` cột `SIExtText01..05`.

**Lỗi: 1 con hàng Module nhưng hiển thị thông số Cell:**
```sql
-- Nguyên nhân: POType sai trong STB_ProductionOrderInfo
-- Fix:
UPDATE STB_ProductionOrderInfo
SET POType = 'MODULE'
WHERE MaterialCode = 'mã_hàng'
```

---

### 6.5 B523 — Đóng Gói (Gộp Box) — Quy Trình Mới

**Quy trình mới (thay đổi so với cũ):**

| Bước | Quy trình cũ | Quy trình MỚI |
|------|-------------|---------------|
| 1 | Gộp box → In tem | Gộp box → **In tem Box To trước** |
| 2 | Chia box (tùy chọn) | **In tem Box To xong** → mới được Chia box |

**Quy tắc bắt buộc:**
```
⚠️ CHỈ ĐƯỢC IN TEM 1 LẦN DUY NHẤT
   → Muốn in lần 2 phải liên hệ EA Team

⚠️ PHẢI IN TEM BOX TO TRƯỚC KHI CHIA BOX

⚠️ SAU KHI CHIA BOX, PHẢI IN TEM BOX NHỎ TRƯỚC KHI CHIA TIẾP
```

**Logic VV → VJ (`usp_Vietnam_GetBoxIDForLotNo_VVT`):**
```sql
-- Cắt đuôi PartNo tự động (hàng Cell):
WHEN CHARINDEX('-', MM.MaterialName, 12) >= 12
THEN substring(MM.MaterialName, CHARINDEX('-', MM.MaterialName, 12), ...)
-- Mr.Tung add 2023-Feb-13: TỰ ĐỘNG LẤY ĐUÔI TRONG TÊN HÀNG của hàng CELL line
```

**Cổng chặn tại B523:**
```sql
-- Chặn nếu chưa cân → không cho in label
IF @pProcessUserID NOT IN ('vvt_worker','vvtworker',...)
    RAISERROR('Chưa cân — không được in label')
```

---

### 6.6 B717 — Bending & Tapping

> ⚠️ **Chỉ lưu được 1 lần đầu tiên** — nếu nhập sai phải UPDATE thủ công SQL

```sql
-- Sửa số lượng Bending/Tapping sai
UPDATE STB_VN_BENDING_TAPPING
SET QTYLOTNO = [số_đúng], QTYERROR = [lỗi_đúng]
WHERE LOTNO = 'mã_lot'

-- Xóa và nhập lại
DELETE FROM STB_VN_BENDING_TAPPING WHERE LOTNO = 'mã_lot'
```

---

### 6.7 B452 — Đổi Line Sai (Vietnam Print Lot Changed)

**Phân quyền đặc biệt:** Chỉ UserID trong whitelist hardcode trong SP mới được đổi Line.

```sql
-- Nếu UserID không có quyền → RAISERROR('Ban khong duoc phep thay doi ma Line')
-- Fix: IT thêm UserID vào SP usp_Set_VVT_Info_get
```

**Chức năng đặc biệt trong SP này:**
- Đổi PONo (chuyển PO khác cùng model trong tháng)
- Cập nhật RouteCode: đổi E- thành V-
- In tem Foxcon Label (cho user `sieusao`, `transao`, `daohuong`...)

---

### 6.8 Module Line — Quy Trình Đầy Đủ & Liên Kết Single Cell

**Khác biệt Cell vs Module:**

| Tiêu chí | Cell Line | Module Line |
|----------|-----------|-------------|
| RouteCode prefix | `V-01`, `V-23`... | `MV-01`, `MV-xx`... |
| POType | CELL | MODULE |
| Đóng gói | B523 → PackingID = VJ... | B525 → BoxID Module (Lưu bảng `STB_VN_MASTERMODULES`, `STB_VN_DETAILMODULES`) |
| Lịch sử | B782, B786, B791 | B789, B791 |
| Gate V-23/V-24 | ✅ Có check NVL | ❌ Không check |

**Flow Module Line:**
```
B310 (POType=MODULE) → B450 (Module Line Code) → B540 (Không check điện cực)
→ B530 (RouteCode = MV-xx) → B525 (Gộp Box Module) → B789 (Lịch sử) → B791 (Tracking)
```

#### 6.8.1 Các Bảng Cơ Sở Dữ Liệu Module & Cấu Trúc Schema
Hệ thống quản lý Module sử dụng một tập hợp các bảng cơ sở dữ liệu chuyên biệt để liên kết, theo dõi chất lượng, và lưu trữ lịch sử cấu hình lắp ráp:

1. **[STB_SingleCellModuleMappingHist](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) (Lịch sử mapping Single Cell ↔ Module Lot):**
   * Lưu thông tin mapping giữa Single Cell và Module Lot.
   * *Schema:* `ModuleLotNo` (varchar(20)), `Seq` (int), `SingleCellLotNo` (varchar(20)), `CreateDateTime` (datetime), `CreateUserID` (varchar(20)).

2. **[STB_ModuleProductionInfo](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) & [STB_ModuleProductionHist](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) (Thông tin & Lịch sử sản xuất module):**
   * Theo dõi tiến độ sản xuất, lượng pinhole, thay cell lỗi, thông số kiểm đo ESR/Farad của module.
   * *Schema chính:* `ModuleProductionNo` (varchar(20)), `JobStartDate` (date), `SemiProdLotNo1` (varchar(20)), `SemiProdLotNo2` (varchar(20)), `PinHoleQty` (numeric), `ChangeCellQty` (numeric), `Farad` (numeric), `ESR` (numeric), `FinishedProdLotNo` (varchar(20)), `ShipmentDate` (date), `ShipmentQty` (numeric).

3. **[STB_ModuleSemiProductionInfo](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) (Thông tin bán thành phẩm Module):**
   * Liên kết bản mạch PCB và các Single Cell cấu thành bán thành phẩm.
   * *Schema:* `ModuleSemiProductionNo` (varchar(20)), `ProdDate` (date), `Grade` (varchar(10)), `PCBLotNo` (varchar(20)), `SemiProdLotNo` (varchar(20)), `SingleCellLotNo1` (varchar(20)), `SingleCellLotNo2` (varchar(20)), `SingleCellLotNo3` (varchar(20)).

4. **[STB_SubAssemblyInfoForBE](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) (Mapping bán thành phẩm BE):**
   * Bản ghi liên kết thùng và mạch PCB cho công đoạn lắp ráp BE.
   * *Schema:* `SubAssemblyNo` (varchar(20)), `BoxBarcode` (varchar(20)), `PcbBarcode` (varchar(20)).

5. **[STB_ModuleLabelInfo](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) (Thông tin Serial Label Module):**
   * Liên kết mã serial nhãn in với Single Cell tương ứng.
   * *Schema:* `ModuleSerialNo` (varchar(20)), `ProductNo` (varchar(20)), `RevisionNo` (varchar(20)), `SingleLotNo` (varchar(20)).

6. **[STB_ModuleAssemblyLabelInfo](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) (Lịch sử tách/phát hành Lot con cho ráp Module):**
   * Lưu thông tin quan hệ giữa Lot ráp con (Assembly Lot) và Lot mẹ (Parent Lot).
   * *Schema:* `ModuleAssemblyLotNo` (varchar(20)), `ModuleParentLotNo` (varchar(20)), `IsPacking` (bit), `IsShipment` (bit).

7. **[STB_AssemblyCellWeightInfo](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) (Cân nặng Cell lắp ráp):**
   * Lưu dữ liệu cân nặng ghi nhận tại công đoạn lắp ráp.
   * *Schema:* `LineCode` (varchar(20)), `CellWeight` (numeric), `CreateDateTime` (datetime).

8. **[STB_VN_MASTERMODULES](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) & [STB_VN_DETAILMODULES](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) (Đóng gói gộp box module Việt Nam):**
   * *Master:* Lưu thông tin thùng (`GROUPID`, `LOTNO`, `QTY`, `TOTALQTY`, `VOL`, `FWAR`, `PARTNO`, `SIZE`, `PackingID` dạng `MVKQ[Month]...`).
   * *Detail:* Lưu chi tiết của từng Lot trong thùng (`GROUPID`, `LOTNO`, `QTYACT`, `LineCode`, `RouteCode`, `ProdQty`).

#### 6.8.2 Chi Tiết Các Logic Báo Cáo & Xử Lý Stored Procedures

##### 1. Logic Liên kết Cell vào Module Lot (`usp_DoCreateModuleLot`)
Khi thực hiện binding giữa Single Cell Barcode và Module Barcode:
* Hệ thống kiểm tra xem mã Module Barcode tồn tại trong `STB_SetInfo` hay không. Nếu không, raise lỗi: `'Mã Module Lot không tồn tại'`.
* Tiến hành update cột `ModuleBarcode` trong bảng `STB_SetInfo` cho Single Cell tương ứng:
  ```sql
  UPDATE STB_SetInfo SET ModuleBarcode = @ModuleBarcode WHERE Barcode = @Barcode;
  ```
* Tính toán số `Seq` tiếp theo và insert lịch sử vào bảng mapping:
  ```sql
  SELECT @NextSeq = ISNULL(MAX(seq), 0) + 1 FROM STB_SingleCellModuleMappingHist WHERE ModuleLotNo = @ModuleBarcode;
  INSERT INTO STB_SingleCellModuleMappingHist (ModuleLotNo, Seq, SingleCellLotNo, CreateUserID)
  VALUES (@ModuleBarcode, @NextSeq, @Barcode, @pProcessUserID);
  ```

##### 2. Logic Sinh Lot Ráp Module Từ Lot Mẹ (`usp_DoCreateModuleAssemblyLotNo`)
Khi chia Lot Module mẹ (Parent Lot) thành nhiều Lot con (mỗi Lot con có số lượng = 1) để dán nhãn lắp ráp:
* Hệ thống truy vấn thông tin `ProdQty`, `MaterialCode`, `PONo`, `DayPlanNo` từ `STB_SetInfo` của Lot mẹ.
* Kiểm tra xem Lot mẹ đã được tách trước đó chưa (bằng cách check `STB_ModuleAssemblyLabelInfo`). Nếu có, raise lỗi: `'Mã Lot đã tồn tại'`.
* Reset Serial Số trong `STB_SerialInfo` cho `@Header` về `0` để các Lot con bắt đầu từ `001`:
  ```sql
  UPDATE STB_SerialInfo SET SerialNo = 0 WHERE MaterialCode = '' AND Header = @Header;
  ```
* Lặp qua số lượng `ProdQty` lần, mỗi lần:
  * Gọi `usp_GetNewSerialNoForBarcode` để sinh `@SerialNo`.
  * Định dạng `@Barcode = @Header + RIGHT('000' + CONVERT(VARCHAR, @SerialNo), 3)`.
  * Insert vào `STB_ModuleAssemblyLabelInfo` và gọi `usp_DoCreateSetInfo` tạo thông tin Lot mới.
* Cuối cùng, thực hiện xóa Lot mẹ ra khỏi danh sách `STB_SetInfo` để tránh trùng lặp dữ liệu:
  ```sql
  DELETE FROM STB_SetInfo WHERE Barcode = @ModuleParentLotNo;
  ```

##### 3. Logic Tạo Số Serial Cho Nhãn Module (`usp_DoCreateModuleLabelInfo`)
* Sinh mã nhãn module định dạng: `PLS` + `[Ký tự cuối của RevisionNo]` + `[YY]` + `[Tuần trong năm]` + `V` + `[4 số serial tự tăng]`.
* Lấy số Index lớn nhất hiện tại:
  ```sql
  SELECT @StartIndex = ISNULL(MAX(RIGHT(ModuleSerialNo, 4)), 0) + 1 FROM STB_ModuleLabelInfo WHERE ModuleSerialNo LIKE @SerialHeader + '%';
  ```
* Insert danh sách serial tương ứng vào `STB_ModuleLabelInfo`.

##### 4. Tra cứu thông số Phân cấp Module Việt Nam (`usp_VN_PartNoModule`)
Cung cấp bảng ánh xạ cứng các dải thông số Điện áp (`VOL`) và Điện dung (`FARD`) theo Part No (NAMES) của Module để phục vụ kiểm tra ngoại quan và QC:
* Ví dụ:
  * `VEC2R7105QG(0813)`: `45~130` V, `≥2.50V`
  * `WEC3R0335QG(0820)`: `22~85` V, `≥2.55V`

**Giá thành Module:**
```sql
-- Kiểm tra giá thành Module
SELECT * FROM STB_VVT_StagePrices WHERE MaterialCode LIKE '%MDL%'

-- Thêm giá thành khi có model Module mới
INSERT INTO STB_VVT_StagePrices (MaterialCode, RouteCode, Price, IsUsed, CreateDateTime)
VALUES
    ('RDMD00-368', 'MV-01', 0.254127629071929, 1, GETDATE()),
    ('RDMD00-368', 'MV-02', 0.257442076659429, 1, GETDATE()),
    ('RDMD00-368', 'MV-03', 0.258507610420299, 1, GETDATE())
```

---

### 6.9 B351 — Lot Chuyển Đổi Nguyên Liệu

**Khi nào dùng:** Cần đổi mã hàng cho Lot đã sản xuất (sản xuất nhầm model, đổi PO).

| SP | Chức năng |
|----|-----------|
| `usp_GetDayProdPlanForChangeMaterial` | Lấy danh sách kế hoạch có thể đổi sang |
| `usp_GetSetInfoForChangeMaterial` | Lấy danh sách barcode đủ điều kiện đổi |
| `usp_DoChangeMaterialForSetInfo` | Thực hiện đổi — cập nhật MaterialCode, DayPlanNo |

```sql
-- Kiểm tra Lot sau khi đổi
SELECT OldBarcode, NewBarcode, ChangeDateTime, ChangeUserID
FROM STB_LotChangeMaterialHistory
WHERE OldBarcode = 'VV...' OR NewBarcode = 'VV...'

-- Sửa lại Barcode nếu định dạng sai sau khi đổi
UPDATE STB_RawMaterialInputHist SET Barcode = 'VVPR152R740601' WHERE Barcode = 'VVPR152.740601'
UPDATE STB_SetInfo SET Barcode = 'VVPR152R740601' WHERE Barcode = 'VVPR152.740601'
UPDATE STB_LotChangeMaterialHistory SET NewBarcode = 'VVPR152R740601' WHERE Newbarcode = 'VVPR152.740601'
```

---

### 6.10 B528 — Barrel Barcode (Gộp Thùng Xuất Hàng)

**Chức năng:** Tra cứu thùng Barrel/Carton khi xuất hàng.

| SP | Chức năng |
|----|-----------|
| `usp_BarrelBarcodeCartonInfo_get` | Lấy thông tin thùng Carton lớn |
| `usp_BarrelBarcodeSmallInfo_get` | Lấy thông tin thùng nhỏ bên trong |

```sql
-- Tìm thùng Barrel theo PartNo và ngày
SELECT * FROM STB_BarrelBarcodeInfo
WHERE PartNo = 'mã_hàng'
  AND CreateDateTime BETWEEN '2026-04-01' AND '2026-04-30'

-- Sửa số lượng thùng sai
UPDATE STB_BarrelBarcodeInfo
SET Quantity = [số_đúng]
WHERE ID = [id] AND LotNo = 'mã_lot'

-- Xóa thùng tạo nhầm (kiểm tra Detail trước)
DELETE FROM STB_BarrelBarcodeDetail WHERE BarrelBarcodeID = [id]
DELETE FROM STB_BarrelBarcodeInfo WHERE ID = [id]
```

---

### 6.11 B802 — Vietnam Electrode Prod Route Hist (Lịch Sử SX Điện Cực)

**Chức năng:** Báo cáo lịch sử sản xuất và phế điện cực theo từng công đoạn (Mixing → Coating → Rollpress → Slitting).

| SP | Chức năng |
|----|-----------|
| `usp_Vietnam_ElectrodeProdRouteHist_get` | Lịch sử SX + giá thành điện cực |
| `usp_Vietnam_ElectrodeDefectHist_get` | Lịch sử phế điện cực theo công đoạn |

```sql
-- Tìm Lot điện cực theo ngày + công đoạn
SELECT ElectrodeLotNumber, ElectrodeRouteCode, PriceGood, PriceNG, WorkerName
FROM STB_ElectrodeProdRouteHist
WHERE CompanyCode = 'VVT'
  AND CreateDateTime BETWEEN '2026-04-01' AND '2026-04-13'
  AND ElectrodeRouteCode = 'SL'  -- SL = Slitting

-- Sửa ngày Coating/Rollpress/Slitting bị sai
UPDATE STB_ElectrodeWasteInfoNew
SET CoatingDate = '2026-04-12', RollpressDate = '2026-04-12'
WHERE ElectrodeWasteNo IN (...)

-- Kiểm tra điện cực chưa cắt (Slitting_Date is NULL)
SELECT * FROM V_ElectrodeDefectHist
WHERE Slitting_Date IS NULL AND Coating_Date >= '2026-04-01'
```

**Mối quan hệ B802 ↔ B552:**
```
B552 (Electrode Measure Result) — NHẬP dữ liệu:
  → Mixing → Coating → Rollpress → Slitting
  → Mỗi bước: usp_ElectrodeXxxInfo_iud → ghi vào STB_ElectrodeXxxInfo

B802 (Electrode Prod Route Hist) — XEM TỔNG HỢP:
  → usp_Vietnam_ElectrodeProdRouteHist_get → đọc từ nhiều bảng
  → Hiển thị giá thành + phế tổng hợp theo Lot
  → Có thể "Making-Stop" để dừng sản xuất
```

---

### 6.12 B598 — Báo Phế Sản Xuất (Production Error/Scrap)

> **Phân biệt:** B598 = phế **nguyên vật liệu** (kg/g). B530 DefectQty = phế **sản phẩm** (pcs).
> → Xem SQL sửa JobDate và hủy phế tại [Mục 5.4](#54-sửa-jobdate-màn-b598-production-error) (cùng file này).

| SP | Chức năng |
|----|-----------|
| `usp_vn_showproductionerror` | Lấy danh sách phế đã báo cáo |
| `usp_Add_ProductionError` | Thêm mới bản ghi phế NVL |
| `usp_VN_update_ProductionError` | Sửa bản ghi phế đã có |
| `usp_VN_update_CancelScrap` | Hủy/Cancel bản ghi phế |

```sql
-- Xem tất cả phế theo Line và ngày
SELECT * FROM STB_VN_PRODUCTION_ERROR
WHERE LineCode = 'VVBNC-01' AND JobDate = '2026-04-13'

-- Sửa cân nặng phế sai
UPDATE STB_VN_PRODUCTION_ERROR
SET WasteWeight = [cân_nặng_đúng], CanNangMoi = [cân_nặng_đúng]
WHERE ID = [id]

-- Hủy bản ghi phế
UPDATE STB_VN_PRODUCTION_ERROR
SET Status = 'CANCEL', CancelDateTime = GETDATE(), CancelUserID = 'admin'
WHERE ID = [id]

-- Kiểm tra tổng phế theo tháng
SELECT LineCode, SUM(WasteWeight) AS TongPhe, COUNT(*) AS SoBanGhi
FROM STB_VN_PRODUCTION_ERROR
WHERE JobDate BETWEEN '2026-04-01' AND '2026-04-30'
GROUP BY LineCode ORDER BY TongPhe DESC
```

---

### 6.13 Màn Hình Báo Cáo Phụ — Navigator Nhanh

| Màn hình | Chức năng | Liên kết |
|----------|-----------|---------|
| **B790** | Lịch sử nhập NVL theo thời gian | B597 |
| **B618** | Lịch sử hàng sản xuất lại (Rework) | Độc lập |
| **B682** | Báo cáo chi tiết lỗi Cell | DefectInfo |
| **B782** | Số lượng lỗi theo Lot/PO | ProdRouteHist |
| **B781** | Sản lượng đóng gói (lần lưu cuối B523) | B523 |
| **B733** | Check Box/Carton — troubleshoot B453/F110 | B523 |
| **B786** | ESR Monitoring Online | Máy ESR |
| **B882** | ANDON — theo dõi lỗi dây chuyền | `usp_getAndon_v1` |

---

### 6.14 Nhà Máy BG2 — K101 & K109

**K101** = tương đương B450 nhưng cho nhà máy BG2.
**K109** = tương đương B597 nhưng cho BG2 (`WorkCenterCode = 'VVT_BG2'`).

Truy cập K109 qua: B540 → Ấn nút **"Việt Nam_Kiểm tra thường xuyên_BG2"**

---

### 6.15 Spare Part — H301/H302/H303/H305

| Màn hình | Chức năng |
|----------|-----------|
| **H301** | Cấu hình loại Spare Part (UsingQty, CycleReplace, LifeLotQty) |
| **H302** | Tồn kho / Nhập / Xuất kho Spare Part |
| **H303** | Lịch sử Lot Spare Part đã xuất + Barcode đã dùng qua |
| **H305** | Spare Part đang dùng (bôi đỏ nếu vượt CycleReplace) / Đã thay thế |

> ⚠️ Nếu số Lot trên Line chưa đủ điều kiện thay thế mà cố tình xuất → **lỗi**

---

### 6.16 In Tem Khách Hàng Đặc Biệt (B754~B758)

| Màn hình | Khách hàng | Chức năng |
|----------|-----------|-----------|
| **B754** | PAC | In tem Inner/Outer (SN riêng biệt) |
| **B755** | PAC | Lịch sử in tem từ B754 |
| **B756** | PAC | In tem thùng Carton + Cân nặng (tick `IsWeightLabel`) |
| **B757** | Digi-Key | In nhãn sản phẩm + nhãn Logistic (cần PO, PO Line, Pack List) |
| **B758** | Digi-Key | In tem thùng MIXED LOAD (Pack List, Weight, PackageCount) |

**Lưu ý B754:** Tem Inner và Outer tính Serial Number riêng biệt. Khi in OUTER phải **tick `IsOuter`**.

---

### 6.17 Root Cause Tổng Hợp — Cell Line

```
1. HOLDING → MaterialWarehouseCode LIKE 'HOLDING_%' trong STB_MaterialLotInfo
2. HẾT HẠN → LotAttr10 + (MMExtInt01 * 30 ngày) < GETDATE()
3. SAI CHỦNG LOẠI NVL → ProductGroupCode không match model
4. CHƯA SCAN NVL V-23/V-24 → STB_RawMaterialInputHist không có record
5. POType SAI → STB_ProductionOrderInfo.POType ghi sai lúc tạo PO
6. BENDING/TAPPING CHỈ LƯU 1 LẦN → check duplicate ID trong SP
7. KHÔNG ĐỔI ĐƯỢC LINE (B452) → UserID không trong whitelist hardcode SP
8. HẠNG MỤC CAO/THẤP SAI (B597) → SP cache biến lần đầu; C143 mapping sai
9. MÃ LOT VENDOR DÀI QUÁ → fn_VVT_getdatebyVendorLot parse fail
10. CHƯA NHẬP "MAKING" ĐẾN V-25 BỊ CHẶN → MarkingLetter rỗng tại bước trước
```

### 6.18 Cấu hình danh mục mã lỗi B530 nhà máy Bắc Giang (BG)

**Yêu cầu:** Đồng bộ danh mục mã lỗi trên màn hình B530 tại nhà máy Bắc Giang để tránh trùng lặp và phản ánh chính xác các lỗi phát sinh trong thực tế.

**1. Vô hiệu hóa (Disable) 28 mã lỗi trùng lặp/dư thừa:**
Set `IsUsed = 0` trong bảng `STB_DefectInfo` cho các mã lỗi sau:
- **Winding (V-22_BG):** `V-22_CC_BG`, `V-22_X12_BG`, `V-22_Z03_BG`, `V-22_Z04_BG`
- **Rubber/Riveting (V-23_BG):** `V-23_02_BG`, `V-23_2DR_BG`, `V-23_NE1_BG`, `V-23_NE2_BG`, `V-23_QQ_BG`, `V-23_XZ2_BG`, `V-23_X12_BG`, `V-24_2RY_BG`
- **Curling (V-24_BG):** `V-24_NE4_BG`, `V-24_22CT_BG`, `V-24_2CT_BG`, `V-24_2DR_BG`, `V-24_5VV_BG`, `V-24_NE22_BG`
- **Sleeving (V-25_BG):** `V-25_01_BG`, `V-25_2CT_BG`, `V-25_X03_BG`, `V-25_X12_BG`
- **Ngoại quan (V-27_BG):** `V-27_ZC_BG`, `V-27_ZD_BG`, `V-27_4GV_BG`, `V-27_5VI_BG`, `V-27_XP1_BG`, `V-27_RELY_BG`

*Chi tiết SQL tham khảo file script [fix_b530_disable_defects_BG.sql](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/sql/scripts/fix_b530_disable_defects_BG.sql)*

**2. Thêm mới 7 mã lỗi thực tế vận hành:**
INSERT vào bảng `STB_DefectInfo` các mã lỗi sau:
- **Winding:** `V-22_BM_BG` (Winding_Xocha đen đầu đáy)
- **Rubber:** `V-23_DV_BG` (Rubber/riveting_Dập vỡ Tancha pan)
- **Rubber:** `V-23_RD_BG` (Rubber/riveting_Rách đáy xocha khi đưa vào vỏ nhôm)
- **Riveting:** `V-23_XZ3_BG` (Riveting_Thiếu thừa vòng đệm)
- **Curling:** `V-24_NE6_BG` (Curling_NG thừa thiếu cân nặng)
- **Curling:** `V-24_NE7_BG` (Curling_Xước chân tancha)
- **Curling:** `V-24_NE8_BG` (Curling_Lỗi mẻ miệng curling)

*Chi tiết SQL tham khảo file script [fix_b530_add_defects_BG.sql](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/sql/scripts/fix_b530_add_defects_BG.sql)*

---

### 6.19 Hỗ trợ lưu nhiều mã vạch nguyên vật liệu (Multi-barcode Appending) cho Điện cực và Vỏ Case

**Mô tả:** Hệ thống hỗ trợ bắn nối tiếp nhiều cuộn nguyên vật liệu khác nhau (ngăn cách bởi dấu `;`) trên cùng một Lot sản phẩm để tránh trường hợp cuộn cũ hết giữa chừng nhưng Lot chưa chạy xong.

**1. Logic kiểm tra và Lưu trong `usp_Vietnam_RawMaterialInputHist_uid`:**
- **Kiểm tra trạng thái HOLD:** Nếu chuỗi `@pRawMaterialBarcode` chứa dấu `;`, hệ thống sử dụng một vòng lặp `WHILE` tách từng barcode con ra để kiểm tra trạng thái HOLD qua SP `usp_VVT_checkHOLD_Material`. Nếu có bất kỳ barcode con nào bị HOLD, hệ thống sẽ chặn không cho lưu.
- **Tính toán số lượng hợp lệ (`@count`):** Thay vì chỉ kiểm tra đơn lẻ, hệ thống lặp qua danh sách barcode ngăn cách bởi dấu `;`, đếm số lượng bản ghi tồn tại trong `stb_materialdoclotinfo` (hoặc `STB_MaterialLotInfo` đối với điện cực mới) và cộng dồn lại để validate.
- **Giới hạn điều kiện nối chuỗi (Append):**
  - **Điện cực (`ELECTRODEP`, `ELECTRODEM`):** Luôn cho phép nối chuỗi cho tất cả các size.
  - **Vỏ Case (`Case`):** Chỉ cho phép nối chuỗi đối với các size model đặc thù: `3562`, `3582`, `35105`.
  - Cấu trúc nối chuỗi: `RawMaterialBarcode = existingRawBarcode + ' ; ' + newRawBarcode`.
  - Hệ thống ghi nhận lịch sử vào bảng lịch sử phụ đối với Điện cực và Case (3562/3582/35105).

*Chi tiết mã nguồn tham khảo file [usp_Vietnam_RawMaterialInputHist_uid.sql](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/sql/procedures/usp_Vietnam_RawMaterialInputHist_uid.sql)*

**2. Gộp hiển thị trên lưới trong `usp_RawMaterialInputHist_get`:**
Khi load danh sách nguyên vật liệu đã bắn của Lot, hệ thống sử dụng `FOR XML PATH('')` gộp các dòng barcode có cùng `ProductGroupCode` và `Barcode` lại thành một chuỗi ngăn cách bởi `; ` hiển thị trong cột `RawBacodeList` đối với `ELECTRODEP`, `ELECTRODEM`, và `Case`.

*Chi tiết mã nguồn tham khảo file [usp_RawMaterialInputHist_get.sql](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/sql/procedures/usp_RawMaterialInputHist_get.sql)*

---

*Cập nhật: 2026-06-04*
