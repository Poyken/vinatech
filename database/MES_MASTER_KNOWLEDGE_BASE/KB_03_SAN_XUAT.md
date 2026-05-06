# KB_03 — Sản Xuất & Lịch Sử Routing

> **Màn hình liên quan:** B782, B781, B598, B726, B791, B310, B450
> ← [Về INDEX](KB_INDEX.md)

---

## 5. 🏭 Sản xuất & Lịch Sử Routing

### 5.1 Chuyển JobDate màn B782 (Lịch sử Routing)

```sql
-- B1: Tìm ControlNo theo Barcode
SELECT * FROM STB_ProdRouteHist
WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo
    WHERE Barcode IN ('VVPO273R010713', 'VVPO123R010711')
)
AND RouteCode IN ('V-26_BG')

-- B2: Chỉnh ngày (thay đổi ngày trong CAST)
UPDATE STB_ProdRouteHist
SET ProdDateTime = CAST('2025-02-17' AS DATETIME) + CAST(ProdDateTime AS TIME),
    JobDate = '2025-02-17'
WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo
    WHERE Barcode IN ('VVPK173R010710', 'VVPK173R010711')
)
AND RouteCode IN ('V-22_BG')
```

> **SP dùng để xác minh:** `usp_LotTrackingInfo_VVT2_get`

---

### 5.2 Chuyển JobDate màn B781 (Packing History)

```sql
-- B1: Xem dữ liệu trước (SP: usp_Vietnam_PackPrintTime_get)
SELECT SPT.* FROM STB_SavePackingTime_VVT SPT
LEFT JOIN STB_SetInfo SI ON SPT.LotNo = SI.Barcode
WHERE SPT.LotNo IN ('VVPK173R015603', 'VVPK173R015606')
AND SI.InputLineCode = 'VVBGC-02'

-- B2: Chỉnh ngày
UPDATE STB_SavePackingTime_VVT
SET PrintTime = CAST('2025-02-17' AS DATETIME) + CAST(PrintTime AS TIME)
WHERE LotNo IN ('VVPK173R015603', 'VVPK173R015606')
AND ID IN ('1217734', '1217736')
```

---

### 5.3 Chuyển JobDate màn B598 (Production Error)

> **Lưu ý:** `JobDate` tự động gen theo `CreateDateTime`. Ví dụ: muốn JobDate về ngày 17 → chuyển `CreateDateTime` về ngày **18**.

```sql
UPDATE STB_VN_PRODUCTION_ERROR
SET CreateDateTime = CAST('2025-02-18' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE IDPE IN (...)
```

---

### 5.4 Chuyển JobDate màn B726 (Scrap After Production)

```sql
-- Tìm dữ liệu: Ấn "Xem thông tin chi tiết" để tìm kiếm theo ngày

-- Chỉnh ngày
UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS
SET CreateDateTime = CAST('2025-03-01' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE ID = 4962

-- Xóa mềm (soft delete)
UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS
SET IsDeleted = 1
WHERE ID IN ('6030', '6032', '6027', '6025', '6026', '6031')
```

---

### 5.5 Chuyển tháng màn FG00 (Kho Thành Phẩm BG)

> **Ngày nhập:** `CreateDate` | **Ngày xuất:** `DateExport`

```sql
-- Chuyển về tháng 1
UPDATE STB_VN_FINISHGOODS_BG
SET CreateDate = DATEADD(MONTH, -DATEPART(MONTH, CreateDate) + 1, CreateDate),
    DateExport = DATEADD(MONTH, -DATEPART(MONTH, DateExport) + 1, DateExport)
WHERE IDCODE = 'FGVN_BG20250211054041195484931'
```

---

### 5.6 Xóa PO (Production Order)

> ⚠️ **Phải xóa ở cả 2 màn hình: B450 và B310 cùng lúc** (xóa đủ các bảng liên quan).

```sql
-- === B450 ===
DELETE FROM STB_DayProdPlan WHERE DayPlanNo IN ('2025030300011', '2025030400202', ...)
DELETE FROM STB_SetInfo WHERE DayPlanNo IN ('2025030300011', '2025030400202', ...)

-- === B310 ===
DELETE FROM STB_ProductionOrderInfo WHERE PONo IN ('250303000008', '250304000011', ...)
DELETE FROM STB_ProductionOrderBom WHERE PONo IN ('250303000008', '250304000011', ...)
DELETE FROM STB_ProductionOrderRouting WHERE PONo IN ('250303000008', '250304000011', ...)
```

---

### 5.7 Sửa số lượng NG (DefectQty) màn B791

```sql
-- Tìm kiếm
SELECT * FROM STB_DefectRepairInfo WHERE ControlNo = '20250314000351'

-- Sửa DefectQty
UPDATE STB_DefectRepairInfo
SET DefectQty = 4
WHERE ControlNo = '20250314000351'

-- Sửa số lượng input công đoạn sau (ProdQty phải = TotalQty - DefectQty)
UPDATE STB_ProdRouteHist
SET ProdQty = '3996'
WHERE ControlNo = '20250314000351' AND RouteCode = 'MV-05'
```

---

### 5.8 Chuyển Line sản xuất

```sql
-- Ví dụ chuyển Line 11 sang Line 12:
UPDATE STB_SetInfo
SET InputLineCode = 'VVBGC-12'
WHERE Barcode = 'VVOR163R010713'

UPDATE STB_ProdRouteHist
SET LineCode = 'VVBGC-12'
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVOR163R010713')
```

---

### 5.9 Chuyển các mã từ VV sang VJ

```sql
UPDATE STB_SetInfo SET Barcode = 'VJOQ062R725633' WHERE Barcode = 'VVOQ062R725633';
UPDATE STB_LotChangeMaterialHistory SET NewBarcode = 'VJOQ062R725633' WHERE NewBarcode = 'VVOQ062R725633';
UPDATE STB_SavePackingTime_VVT SET LotNo = 'VJOQ062R725633' WHERE LotNo = 'VVOQ062R725633';    -- B781
UPDATE STB_MaterialLotInfo SET LotNo = 'VJOQ062R725633' WHERE LotNo = 'VVOQ062R725633';        -- B523 in tem
```

---

### 5.10 Chuyển dữ liệu về ngày (B781 & B782)

```sql
-- === B781: STB_SavePackingTime_VVT ===
UPDATE STB_SavePackingTime_VVT
SET PrintTime = REPLACE(CONVERT(VARCHAR, PrintTime, 120), '2024-11-11', '2024-11-08')
WHERE LotNo IN ('VVOT083R033556', 'VVOT083R033557', ...)

-- === B782: STB_ProdRouteHist ===
UPDATE STB_ProdRouteHist
SET ProdDateTime = REPLACE(CONVERT(VARCHAR, ProdDateTime, 120), '2024-11-11', '2024-11-08')
WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo
    WHERE Barcode IN ('VVOT083R033556', 'VVOT083R033557', ...)
)
```

---

### 5.11 Mở dữ liệu Andon theo tháng cho Sản xuất

**SP:** `usp_Vietnam_AndonDetail_get`

→ Vào SP → Chỉnh lại điều kiện tìm kiếm theo tháng user yêu cầu.
