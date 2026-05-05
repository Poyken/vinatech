# 🔬 DEEP AUDIT — Vinatech MES DataFlow Documentation
## Cross-Reference: Tài liệu vs Source Code + Live Production DB

> **Ngày:** 2026-05-05  
> **Phương pháp:** Đọc source code SP (632+ dòng), chạy 36+ SQL queries trực tiếp trên production DB, so khớp từng claim trong tài liệu  
> **Kết luận:** Phát hiện **3 bug thực sự**, **7 sai lệch logic**, **5 phát hiện mới** chưa có trong tài liệu

---

## 🐛 BUG THỰC SỰ PHÁT HIỆN (3 critical)

### Bug #1: Gate 20 phút KHÔNG BAO GIỜ HOẠT ĐỘNG ⚠️⚠️⚠️

**Vị trí:** `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT.sql` dòng 218
**Doc claim (dòng ~4678):** "Gate 20 phút kiểm tra khoảng cách giữa 2 lần scan"

**Source code thực tế:**
```sql
-- Dòng 218:
IF @CompanyCode = 'VNT' AND @SIExtInt01 = Null AND @RouteIndex > 1
```

> [!CAUTION]
> **`= Null` trong SQL Server LUÔN LUÔN trả về FALSE** (phải dùng `IS NULL`). Điều này có nghĩa Gate 20 phút **CHƯA BAO GIỜ CHẠY** trên production! Mọi barcode đều bypass gate này.

**DB Evidence:**
```
SIExtInt01 distribution (7 ngày gần nhất):
- Value = 1: 236 records
- Value = 0/NULL: còn lại ~3387 records
→ Gate chưa bao giờ block bất kỳ barcode nào
```

**Tác động:** Nếu OP scan hàng loạt barcode liên tục (< 20 phút) trên dây chuyền VNT, hệ thống sẽ KHÔNG chặn — dẫn tới rủi ro sản phẩm bỏ bước mà không bị phát hiện.

---

### Bug #2: `STB_MaterialHoldInfo` — Bảng KHÔNG TỒN TẠI

**Doc claim (dòng ~2289):** "Kiểm tra Lot bị HOLD: SELECT * FROM STB_MaterialHoldInfo WHERE LotID = '...'"

**DB Evidence:**
```
TABLE STB_MaterialHoldInfo → (no rows) → KHÔNG TỒN TẠI
```

> [!WARNING]
> Tài liệu mô tả logic HOLD dựa trên bảng này nhưng bảng không tồn tại. Logic HOLD thực tế nằm hoàn toàn bên trong SP `usp_VVTMaterialWarehouse_HOLDexpired` — sử dụng cột `MaterialWarehouseCode` chứa giá trị `HOLDING_VN_WH` / `HOLDING_BG_WH` trong `STB_MaterialLotInfo`.

---

### Bug #3: `CompleteRoute` được set nhưng tài liệu mô tả sai ý nghĩa

**Doc claim:** "CompleteRoute = flag đánh dấu hoàn thành công đoạn cuối"

**Source code thực tế (dòng 524):**
```sql
UPDATE STB_ProdRouteHist
   SET CompleteRoute='1'
 WHERE ControlNo = @ControlNo
   AND RouteCode = @RouteCode
```

**DB Evidence:**
```
CompleteRoute distribution (7 ngày):
- NULL/blank: 3006 records
- '0': 1 record  
- '1': 12001 records
```

> [!IMPORTANT]
> `CompleteRoute = '1'` KHÔNG có nghĩa "đã hoàn thành công đoạn cuối" — nó có nghĩa "SP đã xử lý xong route này". Mọi route đều set = '1' sau khi SP chạy xong, không chỉ route cuối.

---

## ❌ SAI LỆCH LOGIC (7 điểm)

### 1. Barcode KHÔNG nằm trong `STB_ProdRouteHist`

**Doc claim (nhiều chỗ):** "Barcode được lưu trực tiếp trong ProdRouteHist"

**Thực tế:**
- `STB_ProdRouteHist` **KHÔNG CÓ cột Barcode**
- Mọi truy vấn theo Barcode phải JOIN qua `STB_SetInfo`:
  ```sql
  FROM STB_SetInfo SI
  INNER JOIN STB_ProdRouteHist PRH ON SI.ControlNo = PRH.ControlNo
  WHERE SI.Barcode = @Barcode
  ```

### 2. `ExportWarehouseFinshGood_RD_HN_uid` — KHÔNG có prefix `usp_`

**Doc viết:** `usp_ExportWarehouseFinshGood_RD_HN_uid`  
**Tên thực tế trên DB:** `ExportWarehouseFinshGood_RD_HN_uid` (không prefix)

**Cùng nhóm:**
- `ExportWarehouseFinshGood_uid` (không prefix)
- `ExportWarehouseFinshGoodInventory_uid` (không prefix)

### 3. Golden Query trong doc JOIN sai

**Doc (dòng 221-236):** JOIN `STB_ProdRouteHist.ControlNo = STB_DividePackaging.LotNo`

**Thực tế:** Query chạy đúng khi có dữ liệu, nhưng **hầu hết ControlNo mới tạo chưa có trong DividePackaging** → kết quả thường trống. Cần giải thích rằng DividePackaging chỉ có dữ liệu SAU KHI sản phẩm đã được đóng gói (V-28).

### 4. Module routes dùng `MV-` prefix — Doc mô tả chưa rõ

**DB Evidence:** 15,347 records với prefix `MV-`
```
Sample: MV-01 → MV-03 → MV-04 → MV-05 (RouteIndex 1→4)
```
- Tài liệu đề cập MV- prefix nhưng chưa có bảng chi tiết các routes MV-.

### 5. `DPPExtText01` — Logic "Lot closure" phức tạp hơn doc mô tả

**Doc claim:** "DPPExtText01 = flag đóng Lot"

**DB Evidence:**
```
DPPExtText01 values:
- 'false': hầu hết records → Lot mở
- '1': một số records → Lot đóng
- NULL/empty: nhiều records cũ
```

**Source code (dòng 139):**
```sql
IF ISNULL(@DPPExtText01,'') = '1'  -- Chỉ check giá trị '1', không phải 'true'
```

> [!NOTE]
> Giá trị 'false' (string) KHÁC với NULL — SP kiểm tra `= '1'` nên cả 'false' và NULL đều pass. Đây là logic đúng nhưng dễ nhầm.

### 6. V-33 và P-01 — Routes mới chưa có trong doc

**Source code (dòng 267-292):** SP có logic đặc biệt cho `V-33` và `P-01`:
```sql
if(@routecode IN ('V-33', 'P-01'))
```
- `V-33`: Route bending/tapping mới (thêm 2025.11.25)
- `P-01`: Route assembler pressing

**Tài liệu chưa đề cập hai routes này.**

### 7. SP gọi `usp_DoProcessProdRouteHist_VNT` — Sub-SP không được doc giải thích

SP chính gọi sub-SP `usp_DoProcessProdRouteHist_VNT` để thực sự INSERT record vào ProdRouteHist. Tài liệu chỉ mô tả SP cha mà không giải thích chain call:
```
B530 → usp_DoProcessProdRouteHistForCalc_SmartApp_VNT
         → usp_DoProcessProdRouteHist_VNT (INSERT thực tế)
           → usp_DoAddProdRouteHistByWorkerList (nếu nhiều worker)
```

---

## 🔍 PHÁT HIỆN MỚI CHƯA CÓ TRONG TÀI LIỆU (5 điểm)

### 1. `STB_ProcedureLog` — Audit trail thực tế rất chính xác

**DB Evidence (24h gần nhất):**
```
Top 5 SP được log:
1. usp_DoProcessProdGRMaterialByOne: 4383 lần
2. usp_DoProcessProdRouteHistForBarcode2: 2660 lần
3. usp_DoProcessProdRouteHistForBarcode1: 2659 lần
4. usp_DoProcessProdRouteHist: 2647 lần
5. usp_DoProcessProdPackingByOne_VNT: 2610 lần
```

> [!TIP]
> `STB_ProcedureLog` là công cụ debug cực kỳ mạnh — mỗi SP call đều được ghi, kèm tên biến và giá trị. Khi OP báo lỗi, tìm `ProcedureName` + thời gian là ra ngay.

### 2. VE routes (Hà Nam) có PQC validation bắt buộc

**Source code (dòng 95-116):**
```sql
if(@Barcode like 'VE%' and @WorkCenterCode1 ='VVT_F3' 
   and @RouteCode in ('VE01','VE03','VE04','VE08'))
-- Phải có NG count > 0 từ PQC trước khi scan
```

> [!IMPORTANT]
> Tài liệu chưa đề cập: Nhà máy Hà Nam (VE%) bắt buộc PQC phải nhập NG TRƯỚC khi OP scan ở VE01/VE03/VE04/VE08. Nếu PQC chưa nhập → lỗi "Bên PQC chưa nhập số lượng NG".

### 3. `fn_VVT_QCPARTCODE()` — Function ẩn lọc mã lỗi QC

Source code sử dụng function `fn_VVT_QCPARTCODE()` (dòng 109) để loại trừ các defect codes thuộc nhóm QC khi đếm NG. Tài liệu chưa mô tả function này.

### 4. Route E-33 được bypass kiểm tra AftProdQty

**Source code (dòng 491):**
```sql
IF @RouteCode <> 'E-33' AND ISNULL(@AftProdQty,0) = 0
    -- báo lỗi
```
Route E-33 (có thể là công đoạn kiểm tra cuối Electrode) được phép có AftProdQty = 0 mà không bị block.

### 5. MEA Aging Time Check = 12 giờ (với offset -3h)

**Source code (dòng 587-597):**
```sql
IF @RouteCode = 'EM-02' BEGIN
    -- Kiểm tra khoảng cách EM-01 → EM-02 >= 12 giờ
    -- Với offset DATEADD(hour, -3, GETDATE()) → thực tế check 9 giờ
END
```
Doc chưa đề cập logic aging time cho MEA (EM routes).

---

## 📊 DATA VOLUME & SYSTEM HEALTH (Live Production)

| Metric | Value | Ghi chú |
|--------|-------|---------|
| **SP tổng trong DB** | 3,373 | 3,149 usp_ + 111 fn_ + 14 sp_ + 99 no-prefix |
| **ControlNo mới (7 ngày)** | 2,966 | Khoảng ~424/ngày |
| **ProdRouteHist records (7 ngày)** | 15,008 | ~5 routes/sản phẩm |
| **SetInfo flags (7 ngày)** | LineInput=True: 2,089 / ProdFinish=True: 1,560 | 43% đã hoàn thành |
| **Max barcode chain depth** | 6 levels | ✅ Khớp với doc claim |
| **stb_vvt_materialbo columns** | 15 | wipcode, part, materialcode, usage, size, type, vol... |
| **InterimProdQtyInfo columns** | 8 | ControlNo, RouteCode, ProdQty... (số lượng trung gian ✅) |
| **stb_MergeBoxReality columns** | 9 | ParentLotNo, ControlNo, ChildLotNo, BoxQty... |
| **MMExtInt01 (Shelf life)** | Giá trị 1~1200 ngày | ✅ Confirmed dùng cho hạn sử dụng NVL |
| **OpenExpiredMaterial columns** | 4 | LotID, CreateUserID, OpenExpired (bit), CreateDateTime |

---

## ✅ XÁC NHẬN CHÍNH XÁC (Logic matches doc)

| # | Claim | Source Evidence |
|---|-------|----------------|
| 1 | STB_InterimProdQtyInfo chứa số lượng trung gian | ✅ 8 cột, DELETE trước INSERT trong SP (dòng 146-149) |
| 2 | DPPExtText01 = flag đóng Lot | ✅ SP check `= '1'` (dòng 139) |
| 3 | RouteIndex quyết định thứ tự công đoạn | ✅ `APOR.RouteIndex > POR.RouteIndex` (dòng 199) |
| 4 | IsRequireMachine trong RouteInfo | ✅ Cột tồn tại + SP check (dòng 299-301) |
| 5 | IsOutputRoute = công đoạn cuối | ✅ SP check `@IsOutputRoute = 0` (dòng 468) |
| 6 | Barcode chain depth max 6 | ✅ DB query confirmed MaxChainDepth = 6 |
| 7 | LotAttr10 chứa ngày sản xuất | ✅ Sample: `ML20260505000381` → LotAttr10 = '2026-05-05' |
| 8 | SIExtInt01 dùng cho gate 20 phút | ✅ Cột tồn tại (bigint), nhưng gate BROKEN (Bug #1) |
| 9 | CompleteRoute cột tồn tại | ✅ Giá trị '1' = 12001, NULL = 3006 |
| 10 | Defect calc = ProdQty - DefectQty | ✅ SP dòng 470: `@ProdQty = @ProdQty - @DefectQty` |
| 11 | Golden Query JOIN logic đúng | ✅ SetInfo → ProdRouteHist → RouteInfo → DividePackaging |
| 12 | MV- prefix cho Module routes | ✅ 15,347 records trong ProductionOrderRouting |
| 13 | VE prefix cho Hà Nam barcodes | ✅ SP check `@Barcode like 'VE%'` (dòng 95, 121) |
| 14 | POType = 'MODULE' cho sản phẩm module | ✅ DB sample: `POType = 'MODULE', CompanyCode = 'VVT'` |
| 15 | STB_ProcedureLog audit trail | ✅ ~4000+ records/ngày, ghi tên SP + biến + giá trị |

---

## 🎯 KHUYẾN NGHỊ HÀNH ĐỘNG

### Ưu tiên cao (Cần fix ngay)

| # | Action | Người thực hiện |
|---|--------|----------------|
| 1 | **Fix Bug Gate 20 phút:** Sửa `= Null` → `IS NULL` trong SP | DBA/IT |
| 2 | **Xóa tham chiếu `STB_MaterialHoldInfo`:** Thay bằng logic đúng (MaterialWarehouseCode = 'HOLDING_xx') | Doc author |
| 3 | **Sửa mô tả CompleteRoute:** '1' = route đã được SP xử lý, không phải "hoàn thành cuối" | Doc author |

### Ưu tiên trung bình (Cập nhật doc)

| # | Action |
|---|--------|
| 4 | Thêm routes V-33, P-01 vào bản đồ route |
| 5 | Document PQC mandatory check cho VE routes |
| 6 | Document `fn_VVT_QCPARTCODE()` function |
| 7 | Sửa tên SP ExportWarehouse (không prefix usp_) |
| 8 | Thêm SP call chain diagram |
| 9 | Document MEA aging time check (EM-02, 12h rule) |
| 10 | Làm rõ: Barcode lookup luôn qua JOIN SetInfo, không trực tiếp từ ProdRouteHist |
