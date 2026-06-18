# KB_30: Core SP Engine — Trái Tim Hệ Thống MES

> **File này chứa phân tích chi tiết các Stored Procedure cốt lõi nhất của hệ thống MES.**
> Hiểu được các SP này = hiểu được 80% logic vận hành toàn bộ nhà máy.

---

## 1. Tổng Quan — 4 SP Cốt Lõi

| # | SP Name | Lines | Chức năng | Gọi bởi |
|---|---|---|---|---|
| 1 | `usp_DoProcessProdRouteHist` | 406 | **Tim đập** — ghi nhận sản lượng mỗi lần quét barcode | B530, B802, SmartApp |
| 2 | `usp_DoProcessProdGIMaterialByBOM` | 268 | **Backflush** — trừ kho NVL tự động theo BOM | SP #1 gọi |
| 3 | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | 22,047 chars | **Variant** — version mở rộng cho SmartApp (Gate 20 phút, Takt, V-33 cascade) | SmartApp mobile |
| 4 | `usp_Vietnam_DoProcessProdPacking_VVT` | 217 | **Đóng gói** — xử lý gộp box/đóng thùng | B523, HN523 |

### Sơ đồ quan hệ

```
                    UI (B530/SmartApp)
                          │
                          ▼
    ┌─────────────────────────────────────────┐
    │  usp_DoProcessProdRouteHistForCalc_VNT  │ ← SmartApp variant (22K chars)
    │  hoặc usp_DoProcessProdRouteHist        │ ← PC variant (406 dòng)
    └───────────────┬─────────────────────────┘
                    │ Gọi lần lượt:
        ┌───────────┼───────────────┐
        ▼           ▼               ▼
   Summary    Backflush BOM    GR Material
   (Tổng hợp)  (Trừ NVL)      (Nhập kho TP)
        │           │               │
        ▼           ▼               ▼
   STB_ProdRoute  STB_Material   STB_Material
   Summary        DocInfo+Detail  DocInfo+Detail
                                  (GI→GR→Fix)
```

---

## 2. SP #1: `usp_DoProcessProdRouteHist` (406 dòng)

> **Mỗi lần OP quét barcode tại bất kỳ công đoạn nào → SP này được gọi.**
> File SQL: [usp_DoProcessProdRouteHist.sql](../sql/procedures/usp_DoProcessProdRouteHist.sql)

### 2.1 Tham Số (20 params)

| # | Param | Kiểu | Default | Ý nghĩa |
|---|---|---|---|---|
| 1 | `@pProcessUserID` | VARCHAR(20) | Required | User đang thao tác |
| 2 | `@pProcessLanguage` | VARCHAR(20) | Required | Ngôn ngữ hiển thị lỗi |
| 3 | `@pPONo` | VARCHAR(20) | Required | Mã lệnh sản xuất |
| 4 | `@pLineCode` | VARCHAR(20) | Required | Mã Line (Cell-01, Module-03...) |
| 5 | `@pRouteCode` | VARCHAR(20) | Required | Mã công đoạn (V-22, V-28...) |
| 6 | `@pProcessDateTime` | DATETIME | Required | Thời điểm quét |
| 7 | `@pDayPlanNo` | VARCHAR(20) | NULL→'' | Mã kế hoạch ngày |
| 8 | `@pControlNo` | VARCHAR(20) | NULL→'' | Mã kiểm soát (= Barcode) |
| 9 | `@pWorkerCode` | VARCHAR(20) | NULL→'' | Mã nhân viên |
| 10 | `@pMachineCode` | VARCHAR(20) | NULL→'' | Mã máy |
| 11 | `@pProdQty` | NUMERIC(20,5) | NULL→1 | Số lượng (default = 1) |
| 12 | `@pLotID` | VARCHAR(50) | NULL→'' | Mã Lot |
| 13 | `@pLotNo` | VARCHAR(50) | NULL→'' | Số Lot |
| 14-16 | `@pStockAttrib1/2/3` | VARCHAR(20) | NULL→'' | Thuộc tính kho |
| 17 | `@pPackingID` | VARCHAR(50) | NULL→'' | Mã đóng gói |
| 18 | `@pMarkingCode` | VARCHAR(20) | NULL→'' | Mã đánh dấu (Hà Nam) |
| 19 | `@pIsCheckBefRouteProdQty` | BIT | NULL→0 | Có check SL trước không |
| 20 | `@pProdRouteHistNo` | VARCHAR(20) | **OUTPUT** | Mã lịch sử (trả về) |

### 2.2 Luồng Xử Lý 11 Bước (Line-by-Line)

#### Bước 1: Đọc PO Info (line 70-84)
```sql
SELECT @CompanyCode, @WorkCenterCode, @MaterialCode, @BomVersion,
       @IsInputRoute, @IsOutputRoute, @RouteIndex
FROM STB_ProductionOrderRouting POR
JOIN STB_ProductionOrderInfo POI ON POI.PONo = POR.PONo
WHERE POR.PONo = @PONo AND POR.RouteCode = @RouteCode
```
> Lấy thông tin PO + xác định vị trí công đoạn (đầu/cuối/giữa).

#### Bước 2: Tính Ca/Ngày tự động (line 86-89)
```sql
DECLARE @ShiftTime = dbo.fnGetJobDateShiftTime(@ProcessDateTime, @CompanyCode, ...)
-- Trả về: YYYYMMDD + ShiftCode(1 char) + TimeCode(2 chars)
DECLARE @JobDate = SUBSTRING(@ShiftTime,1,8)    -- '20260618'
DECLARE @ShiftCode = SUBSTRING(@ShiftTime,9,1)  -- 'A' hoặc 'B'
DECLARE @TimeCode = SUBSTRING(@ShiftTime,10,2)  -- '08'
```
> **OP không chọn ca** — hệ thống tự tính dựa trên `STB_VN_Shift`:
> - CS01 (Ca ngày): 10:29→22:30
> - CS02 (Ca đêm): 22:31→10:30

#### Bước 3: GATE — Barcode đã nhập chưa? (line 91-108)
```sql
IF @ControlNo <> '' BEGIN  -- Nếu sử dụng SetInfo
    SELECT @IsLineInput = SI.IsLineInput FROM STB_SetInfo WHERE ControlNo = @ControlNo
    IF @IsInputRoute = 0 AND @IsLineInput = 0 BEGIN
        RAISERROR('투입처리 되지 않은 바코드입니다 [%s]')  -- "Barcode chưa nhập tuyến"
        RETURN
    END
END
```
> **Chặn:** Nếu barcode chưa đi qua công đoạn đầu (IsLineInput=0) mà đang cố quét ở công đoạn giữa/cuối → lỗi.

#### Bước 4: GATE — SL công đoạn trước (line 111-162)
```sql
IF @IsCheckBefRouteProdQty = 1 AND @IsInputRoute <> 1 BEGIN
    -- Tìm công đoạn ngay trước
    SELECT TOP 1 @BefRouteCode = RouteCode FROM STB_ProductionOrderRouting
    WHERE PONo=@PONo AND RouteIndex < @RouteIndex ORDER BY RouteIndex DESC
    
    -- So sánh SL
    IF CurrentRouteQty + ProdQty > BefRouteQty → ERROR "Vượt SL trước"
END
```
> ⚠️ **BYPASS list** (line 146): `E-28, V-28, V-28_BG, VE10, E-33, E-34, E-29, EM-03, M-06`
> → Đóng gói + cắt uốn được phép vượt SL công đoạn trước.

#### Bước 5: Kiểm tra trùng (line 165-188)
```sql
-- Tìm chính xác: PONo + Line + Route + ControlNo + DateTime
SELECT @ProdRouteHistNo FROM STB_ProdRouteHist WHERE ... ProdDateTime = @ProcessDateTime
-- Nếu không tìm thấy → tìm theo: PONo + Line + Route + ControlNo + JobDate + Shift + Time
```

#### Bước 6A: INSERT mới (line 190-267)
```sql
-- 1. Tạo Serial ID
EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteHist', @ProdRouteHistNo OUTPUT
-- 2. Ghi audit log
INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue)
-- 3. Update Line đang chạy Route nào
UPDATE STB_LineRouteMapping SET DayPlanNo=@DayPlanNo, ProdRouteHistNo=@ProdRouteHistNo
-- 4. INSERT chính (18 columns)
INSERT INTO STB_ProdRouteHist (ProdRouteHistNo, CompanyCode, ..., ProdQty, ProdDateTime, ...)
-- 5. Ghi nhân viên (nếu có)
IF @WorkerCode <> '' EXEC usp_DoAddProdRouteHistByWorkerList
```

#### Bước 6B: UPDATE cộng dồn (line 268-288)
```sql
UPDATE STB_ProdRouteHist SET ProdQty = ProdQty + @ProdQty WHERE ProdRouteHistNo = @ProdRouteHistNo
```

#### Bước 7: Tổng hợp sản lượng (line 290-298)
```sql
EXEC usp_DoProcessProdRouteSummary
    @pCompanyCode, @pWorkCenterCode, @pLineCode, @pRouteCode,
    @pPONo, @pJobDate, @pShiftCode, @pTimeCode, @pProdQty
```

#### Bước 8: ★ BACKFLUSH — Trừ NVL (line 302-317)
```sql
EXEC usp_DoProcessProdGIMaterialByBOM
    @pProcessUserID, @pProcessLanguage, @pCompanyCode, @pWorkCenterCode,
    @pPONo, @pLineCode, @pRouteCode, @pMaterialCode,
    @pLotID, @pLotNo, @pProdQty, @pStockAttrib1/2/3, @pFPItemWorkNo
```
> **Xem chi tiết SP #2 bên dưới.**

#### Bước 9: Công đoạn ĐẦU (line 319-343)
```sql
IF @IsInputRoute = 1 BEGIN
    IF @IsLineInput = 0 BEGIN
        UPDATE STB_SetInfo SET IsLineInput=1, InputDateTime, InputJobDate, InputLineCode, InputShiftCode
        EXEC usp_VN_UpdateSpecialSparePartLot  -- Cập nhật Lot phụ tùng
    END
END
```

#### Bước 10: Công đoạn CUỐI (line 345-388)
```sql
IF @IsOutputRoute = 1 BEGIN
    -- Cộng SL hoàn thành vào PO
    UPDATE STB_ProductionOrderInfo SET ProdFinishQty += @ProdQty
    -- Đánh dấu sản phẩm hoàn thành
    UPDATE STB_SetInfo SET IsProdFinish=1, ProdFinishDateTime, ProdFinishJobDate
    -- Tạo phiếu nhập kho thành phẩm
    EXEC usp_DoProcessProdGRMaterialByOne → @MaterialDocNo OUTPUT
    -- Đóng phiếu
    EXEC usp_DoFinishMaterialDoc
    -- Xác nhận phiếu
    EXEC usp_DoFixMaterialDoc
END
```

#### Bước 11: Trả về (line 403)
```sql
SET @pProdRouteHistNo = @ProdRouteHistNo
```

### 2.3 Bảng DB Liên Quan

| Bảng | Đọc/Ghi | Vai trò |
|---|---|---|
| `STB_ProductionOrderRouting` | READ | Lấy IsInputRoute, IsOutputRoute, RouteIndex |
| `STB_ProductionOrderInfo` | READ+WRITE | CompanyCode, ProdFinishQty |
| `STB_SetInfo` | READ+WRITE | IsLineInput, IsProdFinish, Barcode |
| `STB_ProdRouteHist` | READ+WRITE | **Bảng chính** — lịch sử routing |
| `STB_ProcedureLog` | WRITE | Audit log |
| `STB_LineRouteMapping` | WRITE | Line→Route hiện tại |

### 2.4 Rủi Ro & Cảnh Báo

> ⚠️ **KHÔNG CÓ TRANSACTION!** SP 406 dòng không có `BEGIN TRANSACTION`.
> Nếu crash sau Bước 8 (đã trừ NVL) nhưng trước Bước 10 (chưa ghi TP):
> → NVL bị trừ, thành phẩm chưa ghi nhận → **DATA LỆCH**.

> ⚠️ **ERP Interface bị comment out** (line 249-259, 277-287): Logic đẩy dữ liệu lên ERP (`usp_ProdRouteHist_itf`) đã bị disable. Có thể do ERP integration chưa hoàn thiện hoặc đã chuyển sang Agent Job.

---

## 3. SP #2: `usp_DoProcessProdGIMaterialByBOM` (268 dòng)

> **Backflush = Tự động trừ kho NVL theo BOM khi chốt sản lượng.**
> File SQL: [usp_DoProcessProdGIMaterialByBOM.sql](../sql/procedures/usp_DoProcessProdGIMaterialByBOM.sql)

### 3.1 Luồng Xử Lý 7 Bước

#### Bước 1: Đọc BOM → Lọc NVL cần trừ (line 60-78)
```sql
INSERT INTO @Items (IDX, MaterialCode, UseQty)
SELECT ROW_NUMBER() OVER (...), POB.ChildMaterialCode,
       SmartFramework.dbo.fnConvertUnit(POB.BomUnit, MM.MaterialUnit, POB.UsedQty * @ProdQty)
FROM STB_ProductionOrderBom POB
JOIN STB_MaterialMaster MM ON MM.MaterialCode = POB.ChildMaterialCode
WHERE POB.PONo=@PONo AND POB.MaterialCode=@MaterialCode AND POB.RouteCode=@RouteCode
  AND POB.IsUseProduction = 1
  AND MM.IsUseFlush = 1
  AND MM.IsUseBackFlush = 0    -- ← Chỉ trừ Flush, không trừ BackFlush
```

> 💡 **3 cờ quan trọng:**
> - `IsUseProduction=1` → NVL này dùng trong SX
> - `IsUseFlush=1` → Trừ kho ngay khi SX (không đợi)
> - `IsUseBackFlush=0` → KHÔNG phải BackFlush (trừ sau)

#### Bước 2: Kiểm tra tồn kho đủ không (line 86-105)
```sql
SELECT @NotEnoughMaterial = IT.MaterialCode
FROM @Items IT LEFT JOIN STB_MaterialStock MS ON ...
WHERE IT.UseQty > ISNULL(MS.StockQty, 0)

IF @NotEnoughMaterial IS NOT NULL
    RAISERROR('부족한 자재가 있습니다 [%s]')  -- "NVL không đủ"
```

#### Bước 3: Lấy Warehouse từ Line (line 110-117)
```sql
SELECT @GIWarehouseCode, @GILocationCode
FROM STB_LineRouteMapping WHERE LineCode=@LineCode AND RouteCode=@RouteCode
```

#### Bước 4: Tạo phiếu xuất kho header (line 120-196)
```sql
INSERT INTO STB_MaterialDocInfo (MaterialDocNo, MaterialDocType='GI', MaterialDocTypeCode='GI_PRODUCTION',
    DocStatus='CREATE', RequestUserID='system', ...)
```

#### Bước 5: WHILE loop — từng NVL (line 199-257)
```sql
WHILE @Count >= @Row BEGIN
    -- INSERT STB_MaterialDocDetail (RequestQty = AllowQty = PickingQty = UsedQty)
    -- EXEC usp_DoCreateMaterialDocLotInfoNotUsedBarcode (chọn Lot FIFO tự động)
    SET @Row = @Row + 1
END
```

#### Bước 6-7: Đóng + Xác nhận (line 260-266)
```sql
EXEC usp_DoFinishMaterialDoc @MaterialDocNo
EXEC usp_DoFixMaterialDoc @MaterialDocNo
```

### 3.2 Bảng DB Liên Quan

| Bảng | Vai trò |
|---|---|
| `STB_ProductionOrderBom` | BOM nguồn — NVL nào cần trừ cho Route nào |
| `STB_MaterialMaster` | Cờ IsUseFlush, đơn vị, tên NVL |
| `STB_MaterialStock` | Tồn kho hiện tại (StockQty) |
| `STB_LineRouteMapping` | Map Line→Warehouse (biết trừ kho nào) |
| `STB_MaterialDocInfo` | Phiếu xuất kho (Header) |
| `STB_MaterialDocDetail` | Chi tiết phiếu (từng dòng NVL) |
| `STB_MaterialDocLotInfo` | Chi tiết Lot (FIFO chọn Lot cũ nhất) |

---

## 4. SP #3: `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` (22,047 chars)

> **Version mở rộng cho SmartApp mobile — thêm nhiều logic Vinatech custom.**

### 4.1 Khác biệt so với SP #1

| Logic | SP #1 (PC) | SP #3 (SmartApp) |
|---|---|---|
| Gate 20 phút | ❌ Không có | ✅ Check `@SIExtInt01` — nhưng BUG `= Null` |
| Takt time tracking | ❌ | ✅ Ghi `STB_SavePackingTime_VVT` |
| V-33 cascade | ❌ | ✅ Tự động chốt V-33 khi V-28 hoàn thành |
| ESR integration | ❌ | ✅ Ghi `STB_VVT_ESRDATA` |
| Packing count | ❌ | ✅ Ghi `STB_PackingQtyPrintB523_VVT` |

### 4.2 BUG đã phát hiện

> ⚠️ **Gate 20 phút KHÔNG BAO GIỜ HOẠT ĐỘNG** (line 218):
> ```sql
> IF @SIExtInt01 = Null  -- ← BUG! SQL không bao giờ TRUE khi so sánh = Null
> -- Phải sửa thành: IF @SIExtInt01 IS NULL
> ```
> → Xem chi tiết tại KB_12 §2.2.

---

## 5. SP #4: `usp_Vietnam_DoProcessProdPacking_VVT` (217 dòng)

> **Đóng gói — xử lý gộp box/đóng thùng tại B523.**
> File SQL: [usp_Vietnam_DoProcessProdPacking_VVT.sql](../sql/procedures/usp_Vietnam_DoProcessProdPacking_VVT.sql)

### 5.1 Pattern: OPENXML + CURSOR

```
UI (B523) gửi XML chứa danh sách barcode
    ↓
sp_xml_preparedocument → parse XML
    ↓
CURSOR SourceData → loop qua từng barcode
    ↓
MergeQty logic: đếm tổng → nếu đủ thì break
    ↓
EXEC usp_DoProcessProdPackingByOne_VNT → xử lý từng cái
    ↓
sp_xml_removedocument → dọn dẹp
```

### 5.2 MergeQty Logic (Gộp Box)

```sql
-- Nếu tổng SL > MergeQty → chia đôi: lấy phần còn thiếu
IF @pMergeQty < @total + @InProdQty THEN
    @InProdQty = @pMergeQty - @total   -- Chỉ lấy phần còn thiếu
    @checkBreak = 1                      -- Dừng sau lần này
ELSE
    @total = @total + @InProdQty        -- Cộng dồn

-- Mỗi vòng: gọi usp_DoProcessProdPackingByOne_VNT
-- Khi @checkBreak > 0 → BREAK ra khỏi CURSOR
```

> ⚠️ **CURSOR chạy trong TRY/CATCH** nhưng CLOSE/DEALLOCATE nằm NGOÀI CATCH → nếu crash trong loop, cursor có thể bị leak.

### 5.3 29 Bảng Packing-Related

| Nhóm | Bảng | Chức năng |
|---|---|---|
| **Core** | `STB_DividePackaging` | Phân chia đóng gói |
| **Tracking** | `STB_SavePackingTime_VVT` | Thời gian đóng gói (Takt) |
| **Per Level** | `STB_SavePackingQtyByLevel_VVT` | SL đóng gói theo Level |
| **Per Factory** | `STB_SavePackingQty_VVT_F2` | SL riêng nhà máy F2 (BG1) |
| **Standard** | `STB_PackingQtyPerSize` | SL đóng gói theo Size |
| **Standard** | `STB_PackingStandard` | Tiêu chuẩn đóng gói |
| **Label** | `STB_Vietnam_PackingPrinting` | Lịch sử in tem đóng gói |
| **Label** | `STB_PackingLabelPrintHist` | Lịch sử in tem |
| **Label** | `STB_PackingLabelSpec` | Spec tem đóng gói |
| **HN** | `STB_PackingNilonToBoxSmall_HN` | Đóng gói nilon→box nhỏ (Hà Nam) |
| **HN** | `STB_PackingOutPutFinishGoods_HN` | Xuất kho TP (Hà Nam) |
| **HN** | `STB_PackingHN710_HN` | Đóng gói đặc biệt HN710 |
| **Hela** | `STB_HelaPackingCheckHist` | Kiểm tra đóng gói Hela |
| **Nordex** | `STB_NordexPackingLabelPrintingHist` | In tem Nordex |
| **PS** | `STB_PackingLabelHistForPS` | In tem PS |
| **Remaining** | `STB_PackingRemainingQtyInfo` | SL còn lại chưa đóng gói |
| **B523** | `STB_PackingQtyPrintB523_VVT` | SL in tại B523 |
| **Change** | `STB_PackingBoxChangeHist` | Lịch sử đổi box |
| **Manual** | `STB_ManualPacking` | Đóng gói thủ công |
| **Warehouse** | `STB_PackingQtyWarehouse` | SL đóng gói theo kho |

---

## 6. Hàm Hỗ Trợ Quan Trọng

### 6.1 `fnGetJobDateShiftTime` — Tính Ca Tự Động

```
Input:  @ProcessDateTime, @CompanyCode, @WorkCenterCode, @LineCode, @RouteCode, NULL
Output: 'YYYYMMDD' + ShiftCode(1) + TimeCode(2)
        Ví dụ: '20260618A08' → Ngày 18/06/2026, Ca A (ngày), Giờ 08
```

### 6.2 `usp_DoCreateSerial` — Tạo Serial ID

```sql
EXEC SmartFramework.dbo.usp_DoCreateSerial 'TÊN_BẢNG', @SerialNo OUTPUT
-- Đọc STB_SerialRules → tạo ID theo pattern + increment
-- Ví dụ: STB_ProdRouteHist → 'PRH000000001'
```

### 6.3 `usp_RaiseLocalizedError` — Lỗi Đa Ngôn Ngữ

```sql
EXEC SmartFramework.dbo.usp_GetAddonStringResource @ProcessLanguage,
    '^메시지 키^',   -- Key tiếng Hàn
    @ErrorMessage OUTPUT  -- Trả về bản dịch VN/EN
RAISERROR(@ErrorMessage, 16, 1)
```

---

## 7. Sơ Đồ Tổng — Khi OP Quét 1 Barcode

```
OP quét barcode tại trạm V-24 (Curling)
    │
    ▼
SmartApp gọi usp_DoProcessProdRouteHistForCalc_SmartApp_VNT
    │
    ├─ Bước 1: Đọc PO → "Đây là công đoạn giữa, không phải đầu/cuối"
    ├─ Bước 2: fnGetJobDateShiftTime → "Ca ngày, 14:30"
    ├─ Bước 3: Check IsLineInput=1 → "OK, đã nhập tuyến"
    ├─ Bước 4: Check BefRouteQty → "V-23 đã chốt 500, V-24 mới 499 → OK"
    ├─ Bước 5: Chưa có ProdRouteHistNo → INSERT mới
    ├─ Bước 6: INSERT STB_ProdRouteHist + Log + Worker
    ├─ Bước 7: Summary → cập nhật tổng SL V-24 = 500
    ├─ Bước 8: Backflush → trừ vỏ nhôm, cao su, tancha theo BOM
    ├─ Bước 9: Không phải InputRoute → skip
    └─ Bước 10: Không phải OutputRoute → skip
    │
    ▼
Kết quả: 1 dòng mới trong STB_ProdRouteHist, NVL bị trừ, tổng hợp cập nhật
```

---

## 8. SP #5: `usp_DoCreateSetInfoForProdQty_VNT` (477 dòng)

> **Tạo Barcode / Lot cho sản phẩm** — gọi khi xác nhận kế hoạch ngày (B450, K101).
> File SQL: [usp_DoCreateSetInfoForProdQty_VNT.sql](../sql/procedures/usp_DoCreateSetInfoForProdQty_VNT.sql)

### 8.1 Format Barcode

```
[Prefix][ModelHeader][YearCode][MonthCode][DayCode][Serial]
   VV      PP         1        6          3       R072701
```

**Quy tắc Prefix:**

| Điều kiện | Prefix | Ví dụ |
|---|---|---|
| CompanyCode = 'VNT' (Bắc Ninh) | `VJ` | VJPP163R072701 |
| CompanyCode khác (BG/HN) | `VV` | VVPP163R072701 |
| MaterialTypeCode = 'MDL' (Module) | `M` + VJ/VV | MVJPP163R072701 |
| WorkCenter = VNT_F2 (MEA soát) | `MEA` | MEA2606180001 |

**Quy tắc Month Code:**
```
MonthCode = CHAR(Month + 73)
→ Jan=J(74), Feb=K(75), Mar=L(76), Apr=M(77), May=N(78), Jun=O(79)
   Jul=P(80), Aug=Q(81), Sep=R(82), Oct=S(83), Nov=T(84), Dec=U(85)
```

**Quy tắc Year Code:**
```sql
SELECT YearCode FROM STB_YearInfo WHERE Year = 2026
-- Ví dụ: 2026 → '6', 2025 → '5'
```

### 8.2 Gate Logic

| # | Check | Lỗi nếu vi phạm |
|---|---|---|
| 1 | DayPlan đã tạo Lot chưa | "이미 Lot를 생성하였습니다" (Lot đã tạo rồi) |
| 2 | Volt có giá trị không (trừ F2/F3/F4/F5) | "전압 기준정보가 입력되지 않았습니다" (Chưa nhập Vol) |
| 3 | Capacity có giá trị không (trừ F2/F3/F4/F5) | "용량 기준정보가 입력되지 않았습니다" (Chưa nhập Farad) |

### 8.3 Logic Đặc Biệt

- **Bloom Energy:** Model `EDVTSY-001` → lấy `CustomerRevision` từ `STB_BomRevision_Map`
- **Nordex (EDVTMD-246):** Hardcode `@BloomEnergyPartNumber = '35335'`
- **Remainder:** Nếu PlanQty / LotCount dư → Lot cuối nhỏ hơn (`@LotCount = @RemainQty`)

### 8.4 Bảng DB Liên Quan

| Bảng | Vai trò |
|---|---|
| `STB_SetInfo` | **INSERT barcode mới** (ControlNo, Barcode, PONo, DayPlanNo, ProdQty) |
| `STB_DayProdPlan` | Đọc PlanQty, MaterialCode, PlanDate |
| `STB_ModelBasicInfo` | Đọc Vol (MBIExtText01), Farad (MBIExtText02) |
| `STB_YearInfo` | Map Year → YearCode |
| `STB_MaterialMaster` | MaterialTypeCode (MDL/FPM/...) |
| `STB_BomRevision_Map` | Bloom Energy BOM Revision |

---

*Cập nhật: 2026-06-18*
*Nguồn: Phân tích trực tiếp từ code SQL Server*
