<!--
AI-READY METADATA
Purpose: Tổng quan luồng sản xuất (B310-B882), SetInfo & ProdRouteHist Data Schemas, JobDate update scripts & Barcode traceability
Scope: Production System Overview & Core Data Schemas
Single Source of Truth: file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md (Production Overview & Core Schemas)
Target Screens: B310, B450, B452, B523, B528, B530, B540, B597, B598, B682, B717, B726, B781, B782, B791, B802, B882
Target Tables: STB_SetInfo, STB_ProdRouteHist, STB_DayProdPlan, STB_ProductionOrderInfo
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_03 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/INDEX.md)
  - [KB_03_02_CELL_LINE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md)
-->

# KB_03 — Sản Xuất & Lịch Sử Routing

> **Màn hình:** B310, B450, B452, B523, B528, B530, B540, B597, B598, B682, B717, B726, B781, B782, B791, B802, B882
> **Bảng chính:** `STB_SetInfo` (76 cols), `STB_ProdRouteHist` (23 cols), `STB_DayProdPlan`, `STB_ProductionOrderInfo`
> **🔑 Keywords:** sản xuất, routing, barcode, scan, công đoạn, chốt sản lượng, line, chuyền, PO, kế hoạch, JobDate, NG, defect, module, cell, electrode, ANDON
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)


---

## 5. 🏭 Sản xuất & Lịch Sử Routing

### 5.1 Luồng Sản Xuất Đầy Đủ & Kiến Trúc POP (Tham chiếu nhanh)

```
[B310] Tạo PO (Lệnh sản xuất tháng)
    ↓
[B450] Lập kế hoạch ngày + Tạo Lot + In tem
    ↓
┌───────────────────────────────────────────────────────────────────┐
│ 🏭 POP SẢN XUẤT HỢP NHẤT: B530 = B540 + B523 + C321               │
│                                                                   │
│ 1. [B540] Nhập thẻ công đoạn (Scan NVL & Thẻ từng bước V22→V28)   │
│ 2. [B530] Nhập số lượng sản xuất & Chốt công đoạn (Set "Making")  │
│ 3. [B523] Đóng gói & In tem label thùng hàng / khách hàng         │
│ 4. [C321] Nhập kho thành phẩm (Finish Good Stock In)              │
└───────────────────────────────────────────────────────────────────┘
```

> 🏭 **Cơ sở:** Luồng trên là chuẩn **VVT_F1 (Bắc Ninh)**. Hà Nam dùng HN523 thay B523. BG2 dùng K101 thay B450, K109 thay B597. Xem [KB_INDEX § Mapping](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md).

> ⚠️ **Quy tắc POP Sản xuất:** `POP sản xuất = B530 = B540 + B523 + C321`. Dữ liệu chốt sản lượng tại B530 phản ánh tổng hợp trực tiếp từ việc nhập thẻ B540, đóng gói B523 và nhập kho C321.
> ⚠️ **Cột IsFixed ở B450 phải được tích** mới tạo được Lot.
> ⚠️ **B530 bắt buộc nhập chữ "Making"** (chọn ở cột Status) nếu không công đoạn V25 sẽ bị chặn không cho lưu. Đây là điều kiện tiên quyết để hệ thống ghi nhận đang sản xuất.
> ⚠️ **Màn B540:** Không thể tích chọn trực tiếp vào checkbox `ProdQtyFinishYN` vì công đoạn đó đang sản xuất. Hệ thống sẽ tự động tích chọn checkbox này khi chốt sản lượng ở màn B530.
> ⚠️ **Màn B530:** Không thể hoàn thành kết quả sản xuất nếu chưa cập nhật `NULL` cho công đoạn trước đó để chốt lại, sau đó mới mở ra công đoạn tiếp theo.

---

### 5.2 [B782] — Sửa JobDate màn (Lịch sử Routing)

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

### 5.3 [B781] — Sửa JobDate màn (Packing History)

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

### 5.4 [B598] — Sửa JobDate màn (Production Error)

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

### 5.5 [B726] — Sửa ngày màn (Scrap After Production)

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

👉 **Chi tiết Script Fix:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 8](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md)

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

### 5.8 [B791] — Sửa số lượng NG DefectQty (Màn )

**Triệu chứng:** Số lượng lỗi (NG) bị ghi nhận sai, cần sửa lại.

```sql
-- Bước 1: Tìm bản ghi
SELECT * FROM STB_DefectRepairInfo WHERE ControlNo = '20250314000351'

-- Bước 2: Sửa DefectQty (⚠️ Lọc theo công đoạn dùng cột FindRouteCode)
UPDATE STB_DefectRepairInfo
SET DefectQty = 4
WHERE ControlNo = '20250314000351' AND FindRouteCode = 'MV-04'

-- Bước 3: Sửa số lượng input công đoạn sau
-- ProdQty tại công đoạn tiếp theo = TotalQty - DefectQty
UPDATE STB_ProdRouteHist
SET ProdQty = 3996
WHERE ControlNo = '20250314000351' AND RouteCode = 'MV-05'
```

---

### 5.9 [B452] — Chuyển Line sản xuất ()

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

### 5.11 [B450] — Lỗi kế hoạch ngày chọn nhầm Line ()

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

### 5.12 [B882] — Mở dữ liệu Andon theo tháng ()

**SP:** `usp_Vietnam_AndonDetail_get`
→ Vào SP → Tìm điều kiện lọc theo tháng → Chỉnh lại khoảng thời gian user yêu cầu.

---

### 5.13 Truy vết lịch sử 1 Barcode từ A→Z

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

### 5.14 Logic bóc tách Part No từ Model Name

**Mục đích:** Khi cần lấy mã Part No rút gọn (VD: `VEC3R0606QG`) từ chuỗi Model Name đầy đủ (VD: `HY-CAP VEC3R0606QG (1840)`).

👉 **SQL lấy PartNo/Size:** Xem tại [KB_06_MASTER_DATA_TOOLS.md](file:///c:/Users/User Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#L209) (§ 5.2 Lấy PartNo & Size từ tên Model).


---

### 5.15 [B597] — Tra cứu Model Code và Size tại màn

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

### 5.16 Quy trình 3 bước "Thám tử" truy vết và Hủy công đoạn / NG nhầm (Ví dụ: Lot VE260506-001)

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
   SELECT ProdRouteHistNo, RouteCode, ProdQty, CompleteRoute, CreateDateTime 
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
   -- Kết quả: Tìm được các dòng lỗi với mã DefectSummaryNo (Cột mã công đoạn lỗi là FindRouteCode).
   ```

**Kịch bản xử lý chuẩn (Rollback / Revert):**
```sql
BEGIN TRANSACTION;

-- 1. Xóa các bản ghi lỗi (NG) nhập nhầm ở các công đoạn quét nhầm (⚠️ Cột là FindRouteCode)
DELETE FROM STB_DefectRepairInfo 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
  AND FindRouteCode IN ('VE08', 'VE09');

-- 2. Xóa Routing các bước quét nhầm (VE08, VE09) trong STB_ProdRouteHist (⚠️ Cột là RouteCode)
DELETE FROM STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
  AND RouteCode IN ('VE08', 'VE09');

-- 3. Reset cờ hoàn thành công đoạn trước đó (VE07): Set CompleteRoute = NULL để mở lại chốt
UPDATE STB_ProdRouteHist
SET CompleteRoute = NULL
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
  AND RouteCode = 'VE07';

-- 4. ⚠️ QUY TẮC CẬP NHẬT BẢNG MASTER STB_SetInfo:
-- - Chỉ UPDATE DefectQty = 0, IsDefect = 0 khi xóa TOÀN BỘ tất cả các công đoạn hoặc khi các công đoạn trước CHƯA TỪNG CÓ LỖI.
-- - Nếu các công đoạn trước (VE01->VE07) ĐÃ CÓ phế lỗi, KHÔNG ĐƯỢC set DefectQty = 0 (tránh làm mất dữ liệu phế hợp lệ cũ).
-- Tùy chọn: Tự động tính lại tổng DefectQty thực tế từ STB_DefectRepairInfo:
UPDATE STB_SetInfo
SET DefectQty = ISNULL((SELECT SUM(DefectQty) FROM STB_DefectRepairInfo WHERE ControlNo = STB_SetInfo.ControlNo AND IsDelete = '0'), 0),
    IsDefect = CASE WHEN ISNULL((SELECT SUM(DefectQty) FROM STB_DefectRepairInfo WHERE ControlNo = STB_SetInfo.ControlNo AND IsDelete = '0'), 0) > 0 THEN 1 ELSE 0 END
WHERE Barcode = 'VE260506-001';

-- 5. Kiểm tra lại: Lot phải khôi phục về trạng thái cuối cùng ở VE07 với CompleteRoute = NULL
SELECT RouteCode, ProdQty, CompleteRoute, CreateDateTime 
FROM STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260506-001')
ORDER BY CreateDateTime ASC;

-- COMMIT; -- Chạy dòng này khi thấy kết quả đã đúng
-- ROLLBACK; -- Chạy dòng này để hủy nếu sai
```

---

### 5.17 Kiểm tra và truy vết nguồn gốc thay đổi Ký hiệu in phun (Marking Letter / MarkingCode)

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



