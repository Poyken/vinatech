
# KB_04 — Đóng Gói & In Tem (Packaging & Label Printing)

> **Màn hình:** B523, B525, B453, B560, B789, B781, B353, B442, A419, A460, B754~B758, B790, Z530, C531
> **Bảng chính:** `STB_PackingStandard`, `STB_DividePackaging`, `STB_ModelLabelInfo`, `STB_SavePackingTime_VVT`
> **🔑 Keywords:** đóng gói, packing, in tem, label, gộp box, rã box, tiêu chuẩn, PackingID, BoxID, VJ, VV, Hela, PAC, DigiKey
> ← [Về INDEX](KB_INDEX.md)

---

## 6. 📦 Đóng gói & In tem nhãn

> 🚦 **Tham chiếu mở rộng:** Toàn bộ cơ chế cổng chặn (Validation Gates) liên quan đến đóng gói B523, in tem nhãn, phân quyền người dùng, và checklist thêm gate mới được tổng hợp tại **[KB_14 §6.3 Nhóm 3 — Đóng Gói](../KB_14/KB_14_01_METHODOLOGY.md#nhóm-3-b523--chặn-đóng-gói-sp-usp_vietnam_doprocessprodpacking_vvt)**.
>
> 🏭 **Cơ sở gốc:** VVT_F1 (Bắc Ninh) | **Biến thể theo cơ sở:**
> - **Hà Nam (VVT_F3):** HN523 (đóng gói), HN542/HN543 (chia tem), HN544 (gộp túi bóng), HN553/HN711 (tem Solum)
> - **BG2 (VVT_F4):** K130 (tem Module), K160 (lịch sử tem), K198 (tem Bloom Energy SL-7), K199 (tem Nordex) → [KB_03 §6.14](../KB_03/KB_03_02_CELL_LINE.md#614-nhà-máy-bg2--cấu-hình-triển-khai-hệ-thống-mes)
> - **Hưng Yên (VVT_F5):** D051, D100, D110 → [KB_25](../KB_25/KB_25_01_OVERVIEW.md)

### 6.0 Tổng Quan Kiến Trúc In Tem Nhãn (Mô hình Giá sách ➔ Danh mục ➔ Người đọc)
Để dễ hình dung luồng xử lý in tem trong hệ thống NAIS MES, hãy tưởng tượng:
1. **Z530 (Label Info) — "Giá sách" (Thư viện mẫu):**
   * Là nơi cất giữ thiết kế mẫu tem (Design layout) dưới dạng XML trong bảng `SmartFramework.dbo.STB_LabelInfo.XmlLayout`.
   * Mẫu tem mới thiết kế xong chỉ nằm ở đây, chưa được chỉ định cho sản phẩm nào.
2. **A460 (STB_ModelLabelInfo) — "Cuốn danh mục" (Bản đồ Mapping):**
   * Chỉ định: *"Nếu sản xuất mã hàng (ModelCode) A, hãy dùng mẫu thiết kế B ở Z530"*.
   * Giúp tái sử dụng: 10 sản phẩm cùng khách hàng chỉ cần map vào 1 mẫu tem duy nhất ở Z530, không cần vẽ lại tem 10 lần.
3. **Màn hình in tem (B790, B523...) — "Người đọc":**
   * Khi quét mã Lot, hệ thống hỏi: *"Lot này thuộc Model nào?"* (ví dụ: `ECVT30-197`).
   * Hệ thống tra "Cuốn danh mục" (`STB_ModelLabelInfo`): *"Mã `ECVT30-197` dùng tem gì?"* ➔ Trả về `'Phoenix_Contact_V1'`.
   * Hệ thống ra "Giá sách" (`Z530`) tải XML thiết kế và bắn lệnh ra máy in.

---

### 6.0.1 Phân loại tem trong hệ thống

| Loại tem | Màn hình | Stored Procedure / Table | Ghi chú |
|----------|----------|--------------------------|---------|
| **AssembleLabel** (Tem Sản Xuất) | B450, B540 | Gọi qua A460 | Tem chính cho Cell/Module sau khi tạo Lot |
| **PartLabel** (Tem Vật Tư Kho) | F330 | Gọi qua A460 | Tem dán trên NVL nhập kho |
| **자재라벨** (Tem kho Hà Nam) | F721 | `STB_ModelLabelInfo` | Đặc biệt cho Hà Nam (chị Hoàng Xuân) |
| **Phoenix Contact** | B790 | `usp_Vietnam_PhoenixContactLabelPrint_get` | Tem 5x8cm, Datecode YYMMDD |
| **PAC Inner/Outer** | B754, B755, B756 | — | SN riêng biệt cho Inner và Outer |
| **Digi-Key** | B757, B758 | — | Nhãn SP + Nhãn Logistic |

---

### 6.0.2 Tìm mẫu tem đang dùng cho 1 Barcode/LotNo
```sql
SELECT
    SI.Barcode,
    SI.MaterialCode,
    LI.FormatName AS [Ten_Mau_Tem],
    LI.IsApproval,
    LI.ApplyDate
FROM STB_SetInfo SI WITH(NOLOCK)
JOIN STB_MaterialMaster MM WITH(NOLOCK) ON SI.MaterialCode = MM.MaterialCode
LEFT JOIN SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
    ON LI.FormatName LIKE '%' + RIGHT(MM.MaterialCode, 5) + '%'
    AND LI.IsApproval = 1
WHERE SI.Barcode = 'VVQL033R07279S'
```

---

### 6.0.3 Hướng dẫn Trace Debug In Tem (UI + SQL)

Khi gặp lỗi in tem ở **bất kỳ màn hình nào** (B442, B450, B523, B790...), trace theo 2 hướng song song:

#### A. Trace trên UI (NAIS client)

```
Bước 1: Mở Object Explorer
   → Bấm F5 (hoặc Menu → Object(F5))
   → Thấy cây đối tượng: Search Function, Execute Function, Layout, View, Popup, Action...

Bước 2: Tìm action in tem
   → Mở nhánh "Action" → tìm action có Caption = "LabelPrint" hoặc "^LabelPrint^"

Bước 3: Xem Property
   → Chọn action LabelPrint → bấm F4 (Property)
   → Đọc:
      • ActionType = "PrintLabel"      ← xác nhận đây là action in tem
      • Name = "LabelPrint"

Bước 4: Mở Print Label options (quan trọng nhất!)
   → Cuộn xuống phần Options → tìm "라벨인쇄" (Print Label options) → bấm mở
   → Đọc các config:
      • 라벨유형 필드 (Label Type Field)    = tên CỘT chứa LabelType (VD: "LabelType")
      • 참조뷰 이름 (Reference View Name)   = grid/view nào cung cấp data (VD: "SetInfo")
      • 포맷형 필드 (Format Name Field)     = cột chứa FormatName (VD: "FormatName")
      • 참조본 범위 (Reference Scope)       = "SelectedRows" (in dòng đang chọn)
      • 프린터명 (Printer Name)             = tên máy in
```

> **Từ bước 4** ta biết:
> - Data in tem lấy từ grid nào (VD: `SetInfo`)
> - Cột nào quyết định loại tem (VD: `LabelType`)
> - Cột nào quyết định template (VD: `FormatName`)

#### B. Trace trong SQL (SP chain)

Khi biết grid `SetInfo` cung cấp data → tìm SP Search Function tương ứng (VD: `usp_SetInfo_get`).

**Chuỗi JOIN 3 bảng quyết định in tem** (đã xác nhận trong `usp_SetInfo_get`):

```sql
-- Bảng 1: STB_MaterialMaster → NỘI DUNG trên tem (MaterialName)
LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK)
    ON MM.MaterialCode = SI.MaterialCode
-- → MM.MaterialName = text hiển thị trên tem (VD: "Coating-Roll Forming-YP 85 120 (A301)...")
-- → Sửa MaterialName tại A230 = sửa nội dung trên tem

-- Bảng 2: STB_ModelLabelInfo → MAPPING model dùng template nào (A460)
LEFT JOIN STB_ModelLabelInfo MLI WITH(NOLOCK)
    ON MLI.ModelCode = SI.MaterialCode
    AND MLI.LabelType = @LabelType
-- → MLI.FormatName = tên template (VD: "전극라벨")
-- → NẾU THIẾU RECORD → lỗi "Not found label type" ❌

-- Bảng 3: STB_LabelInfo → TEMPLATE thiết kế tem (Z530)
LEFT JOIN LabelInfo LBI    -- CTE từ SmartFramework.dbo.STB_LabelInfo
    ON LBI.LabelType = @LabelType
    AND LBI.FormatName = MLI.FormatName    -- Nối với kết quả bảng 2
    AND LBI.RankIndex = 1                  -- Lấy version mới nhất
-- → LBI.Format = XML layout (thiết kế tem)
```

#### C. Sơ đồ flow tổng thể

```
┌─────────────────────── UI TRACE ───────────────────────┐
│                                                         │
│  F5 (Object) → Action → LabelPrint                     │
│       ↓                                                 │
│  F4 (Property) → ActionType = PrintLabel                │
│       ↓                                                 │
│  Options → Print Label options                          │
│       ├── 참조뷰 이름 = SetInfo       ← grid nào?       │
│       ├── 라벨유형 필드 = LabelType   ← cột nào?        │
│       └── 포맷형 필드 = FormatName   ← template nào?    │
│                                                         │
└──────────────────────────┬──────────────────────────────┘
                           ↓
┌─────────────────────── SQL TRACE ──────────────────────┐
│                                                         │
│  usp_SetInfo_get (@pLabelType = 'ElectLabel')           │
│       │                                                 │
│  ┌────┼── STB_MaterialMaster MM                         │
│  │    │      ON MM.MaterialCode = SI.MaterialCode       │
│  │    │      → MM.MaterialName = NỘI DUNG trên tem     │
│  │    │                                                 │
│  │  ┌─┼── STB_ModelLabelInfo MLI (A460)                 │
│  │  │ │      ON MLI.ModelCode = SI.MaterialCode         │
│  │  │ │      AND MLI.LabelType = @LabelType             │
│  │  │ │      → Thiếu record = "Not found label type" ❌ │
│  │  │ │                                                 │
│  │  │ └── STB_LabelInfo LBI (Z530)                      │
│  │  │        ON LBI.FormatName = MLI.FormatName         │
│  │  │        → XML template = THIẾT KẾ mẫu tem         │
│  │  │                                                   │
│  └──┴───────────────────────────────────────────────────│
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### D. Checklist debug nhanh khi lỗi in tem

| # | Kiểm tra | Query | Lỗi nếu thiếu |
|---|----------|-------|----------------|
| 1 | Model có mapping label? | `SELECT * FROM STB_ModelLabelInfo WITH(NOLOCK) WHERE ModelCode = 'MÃ'` | "Not found label type" |
| 2 | Label template tồn tại? | `SELECT * FROM SmartFramework.dbo.STB_LabelInfo WITH(NOLOCK) WHERE LabelType = 'ElectLabel' AND IsApproval = 1` | In trắng / không ra tem |
| 3 | MaterialName đúng chưa? | `SELECT MaterialCode, MaterialName FROM STB_MaterialMaster WITH(NOLOCK) WHERE MaterialCode = 'MÃ'` | Tem in sai nội dung |
| 4 | Hardcode exception? | Kiểm tra CASE WHEN trong SP (VD: `usp_SetInfo_get` override MaterialName cho ControlNo cụ thể) | Tem in tên khác master |

> [!TIP]
> **Stack trace chứa `Awoo.SmartFramework.WinForm.Controls.ScreenControl.PrintLabel`** → 100% lỗi ở bước 1 (thiếu `STB_ModelLabelInfo`).
> **Tem in ra nhưng sai nội dung** → lỗi ở bước 3 (MaterialName sai) hoặc bước 4 (hardcode override).

---

### 6.1 Lỗi "Chưa có tiêu chuẩn đóng gói" (B523)

**Triệu chứng:** B523 báo lỗi "Chưa có tiêu chuẩn đóng gói" khi thử gộp box.

**Nguyên nhân:** Model mới chưa được khai báo số lượng tiêu chuẩn mỗi thùng.

```sql
-- Kiểm tra tiêu chuẩn đóng gói hiện có
SELECT * FROM STB_PackingStandard WITH(NOLOCK) WHERE MaterialTypeCode = 'FERT'

-- Thêm tiêu chuẩn mới (theo MaterialTypeCode + Size, không theo MaterialCode)
INSERT INTO STB_PackingStandard
    (MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty, CreateDateTime, CreateUserID)
VALUES ('FERT', '0813', NULL, NULL, 500, 4000, 8000, GETDATE(), 'vinaadmin')
```

> ⚠️ **Xác minh DB:** Bảng `STB_PackingStandard` KHÔNG có cột `MaterialCode` hay `PackQty`. Tra theo `MaterialTypeCode` (FERT) + `Size` (0813=8x13mm). Quản lý số lượng đóng gói chủ yếu qua **màn A419**.
>
> **Tiêu chuẩn cân:** Vào SP `usp_Vvt_TieuChuanPacking_Vvt` → Thêm dòng cho Model mới.

---

### 6.2 Sửa tên Lot sau B351 (Chuyển đổi Lot — Barcode có dấu chấm)

**Triệu chứng:** Sau khi B351 chuyển đổi Lot, Barcode xuất hiện dấu chấm (`.`) thay vì chữ `R`.

**VD:** `VVPR152.740601` → phải là `VVPR152R740601`

```sql
DECLARE @OldBC NVARCHAR(50) = 'VVPR152.740601'
DECLARE @NewBC NVARCHAR(50) = 'VVPR152R740601'

UPDATE STB_RawMaterialInputHist SET Barcode = @NewBC WHERE Barcode = @OldBC
UPDATE STB_SetInfo SET Barcode = @NewBC WHERE Barcode = @OldBC
UPDATE STB_LotChangeMaterialHistory SET NewBarcode = @NewBC WHERE NewBarcode = @OldBC

-- Xác nhận
SELECT Barcode FROM STB_SetInfo WHERE Barcode = @NewBC
```

---

### 6.3 Sửa mã NVL in lại tem B523 (in sai MaterialCode - Lỗi tem in 5H1 nhưng hệ thống là 6D1)

**Nguyên nhân:** Có sự lệch mã sản phẩm giữa `STB_MaterialLotInfo.MaterialCode` và `STB_SetInfo.MaterialCode` dẫn đến việc in ra sai mẫu tem.

```sql
-- Debug: So sánh MaterialCode giữa 2 bảng để tìm điểm lệch
SELECT
    SI.Barcode,
    SI.MaterialCode AS [MaterialCode_SetInfo],
    MLI.MaterialCode AS [MaterialCode_LotInfo],
    CASE WHEN SI.MaterialCode = MLI.MaterialCode THEN 'ĐỒNG NHẤT' ELSE 'KHÁC NHAU ← LỖI' END AS [Trang_Thai]
FROM STB_SetInfo SI WITH(NOLOCK)
LEFT JOIN STB_MaterialLotInfo MLI WITH(NOLOCK) ON SI.Barcode = MLI.LotNo OR SI.Barcode = MLI.LotID
WHERE SI.Barcode = 'Mã_Barcode';

-- Khắc phục Phương án 1 (Sửa nhanh theo Barcode):
UPDATE STB_MaterialLotInfo
SET MaterialCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = 'Mã_Barcode')
WHERE LotNo = 'Mã_Barcode' OR LotID = 'Mã_Barcode';

-- Khắc phục Phương án 2 (Sửa chi tiết theo MaterialLotNo - PK cụ thể):
-- Bước 1: Tìm MaterialLotNo
SELECT MLI.MaterialLotNo, MLI.LotNo, MLI.MaterialCode
FROM STB_MaterialLotInfo MLI WITH(NOLOCK)
LEFT JOIN STB_SetInfo SI WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
WHERE SI.Barcode = 'Mã_Barcode';

-- Bước 2: Update theo PK
UPDATE STB_MaterialLotInfo
SET MaterialCode = 'MÃ_MATERIAL_ĐÚNG'
WHERE MaterialLotNo = 20240612000524; -- Thay thế bằng PK thực tế
```

---

### 6.4 Lỗi không gộp Box được (B523 — Quy trình debug chuẩn)

**Debug theo thứ tự 4 bước:**

```sql
-- Bước 1: Kiểm tra F110 — Vật tư có được phép dùng Lot không?
SELECT MaterialCode, IsUseBarcode, IsLotUse
FROM STB_MaterialStockAttributeInfo WITH(NOLOCK) WHERE MaterialCode = 'Mã_VLieu'
-- Nếu trống hoặc IsLotUse = 0 -> Vào F110 cấu hình lại trên UI hoặc UPDATE:
UPDATE STB_MaterialStockAttributeInfo
SET IsLotUse = 1, IsUseBarcode = 1 WHERE MaterialCode = 'Mã_VLieu'

-- Bước 2: Kiểm tra QC đã Pass chưa?
SELECT Barcode, LotDecisionResult, IsDefect, DefectQty, IsProdFinish
FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'Mã_Barcode'
-- LotDecisionResult NULL hoặc 'FAIL' → Chưa QC → Yêu cầu QC đánh giá

-- Bước 3: Kiểm tra đã gộp vào Box khác chưa?
SELECT LotID, LotNo, PackingID, CurrentQty
FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = 'Mã_Barcode'
-- PackingID khác NULL → Đã gộp vào box khác rồi

-- Bước 4: Kiểm tra tiêu chuẩn đóng gói
SELECT * FROM STB_PackingStandard WITH(NOLOCK) WHERE MaterialTypeCode = 'FERT'
-- Trống → Vào A419 thêm tiêu chuẩn (xem §6.1)
```

---

### 6.5 Lỗi gộp túi bóng bị mất số lượng (Qty = 0) — HN544

**Triệu chứng:** Sau khi gộp túi bóng thành hộp nhỏ, số lượng hiển thị = 0, không in được tem.

```sql
-- Kiểm tra số lượng trong DB
SELECT MaterialLotNo, LotNo, CurrentQty, InitialQty, PackingID
FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = 'SP260516-003'

-- Nếu CurrentQty = 0 nhưng hàng còn thực tế -> Dồn tổng vào 1 LotID duy nhất
UPDATE STB_MaterialLotInfo
SET InitialQty = 20, CurrentQty = 20
WHERE MaterialLotNo = 'Mã_LotNo_Cần_Giữ'

-- Xóa các LotID thừa
DELETE FROM STB_MaterialLotInfo WHERE MaterialLotNo IN ('LotID_Thừa_1', 'LotID_Thừa_2')
```

---

### 6.6 Lỗi Packing Qty âm ở B523 / B789

**SP liên quan:** `usp_savePackingLabelQty_VVT`

**Triệu chứng:** Số lượng hiển thị âm hoặc sai lệch so với thực tế.

**Trace:**
```sql
-- Kiểm tra số lượng hiện tại
SELECT CurrentQty, InitialQty FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = 'Mã_Lot'
SELECT PackQty FROM STB_SavePackingTime_VVT WITH(NOLOCK) WHERE LotNo = 'Mã_Lot'

-- Kiểm tra lịch sử gộp box
SELECT * FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE PackingID = 'Mã_Packing'
```

**Fix:**
```sql
-- Nếu CurrentQty âm → Reset về số lượng đúng
UPDATE STB_MaterialLotInfo SET CurrentQty = [Số_Lượng_Thực] WHERE LotNo = 'Mã_Lot'

-- Nếu B789 hiển thị sai → Sửa bảng SavePackingTime
SELECT * FROM STB_SavePackingTime_VVT WITH(NOLOCK) WHERE LotNo = 'Mã_Lot'
-- Tìm id bị sai → UPDATE theo id cụ thể
UPDATE STB_SavePackingTime_VVT SET PackQty = [Số_Đúng] WHERE LotNo = 'Mã_Lot' AND id = [ID_Cụ_Thể]
```

---

### 6.7 Lỗi VV → VJ (Đổi đầu mã tem)

```
Case 1: In label thẳng (không đổi) → PrintVJ = 0 trong STB_Vietnam_PackingPrinting
Case 2: Đổi VV→VJ theo PartNo → PrintVJ = 1 trong STB_Vietnam_PackingPrinting
Case 3: Ngoại lệ không đổi hoặc lệch khớp mã vạch khi quét BoxID → Fix cứng (Hardcode) trong SP [usp_Vietnam_GetBoxIDForLotNo_VVT](../sql/procedures/usp_Vietnam_GetBoxIDForLotNo_VVT.sql)
```

> ⚠️ Sau khi đổi → kiểm tra tên model không trùng với bên Hàn Quốc → Nếu trùng thì không đổi được.

#### 💡 Chi tiết Case 3: Tiền lệ Hardcode map barcode trong SP `usp_Vietnam_GetBoxIDForLotNo_VVT`
Khi quét đóng gói tại màn hình **B523** hoặc kiểm tra xuất hàng, nếu Lot đã gộp/đóng gói dưới đầu mã gốc `VVQN...` nhưng tem nhãn hoặc thao tác quét PDA sử dụng mã Lot chuyển đổi dạng `VJPL...` (hoặc ngược lại), hệ thống sẽ không tìm thấy `BoxID` / `PackingID` do lệch khớp mã vạch.

* **Tiền lệ khắc phục (Cập nhật 28/05/2026 bởi `ducnv` theo yêu cầu của chị Trần Lan):**
  Thêm các câu lệnh điều kiện `WHEN ... THEN ...` vào khối `CASE` của biến `@LotNo` trong SP `usp_Vietnam_GetBoxIDForLotNo_VVT` để ép hệ thống hiểu mã `VJ` tương ứng với mã `VV`:
  ```sql
  -- ducnv edited by Mrs.Tran Lan 20260528
  -- start
  WHEN @LotNo = 'VJPL073R025604' THEN 'VVQN073R025604'
  WHEN @LotNo = 'VJPL153R025601' THEN 'VVQN153R025601'
  WHEN @LotNo = 'VJPK253R025605' THEN 'VVQN253R025605'
  WHEN @LotNo = 'VJPK203R025602' THEN 'VVQN203R025602'
  WHEN @LotNo = 'VJPK263R025603' THEN 'VVQN263R025603'
  WHEN @LotNo = 'VJPK253R025601' THEN 'VVQN253R025601'
  WHEN @LotNo = 'VJPL053R025606' THEN 'VVQN053R025606'
  WHEN @LotNo = 'VJPK063R025603' THEN 'VVQN063R025603'
  WHEN @LotNo = 'VJPK213R025604' THEN 'VVQN213R025604'
  WHEN @LotNo = 'VJPK273R025602' THEN 'VVQN273R025602'
  -- end
  ```

```sql
-- Kiểm tra cấu hình in VJ của model
SELECT * FROM STB_Vietnam_PackingPrinting WITH(NOLOCK) WHERE MaterialCode = 'Mã_NVL'

-- Tắt đổi VV→VJ
UPDATE STB_Vietnam_PackingPrinting SET PrintVJ = 0 WHERE MaterialCode = 'Mã_NVL'
```


---

### 6.8 B525 — Gộp Box Module

**Chức năng:** Đóng gói dành riêng cho **hàng Module** (khác với B523 là Cell).

**Luồng đóng gói Module Line:**
```
Module Line (B528/B598/B717/B802) → Nhập sản lượng → Tạo Lot → QC Pass → B525 — Gộp Box Module → B453 — In tem INNER/OUTER
```

| SP | Chức năng |
|----|-----------|
| `usp_Vietnam_GetProdPackingForBarcode_VVT` | Lấy thông tin đóng gói theo Barcode |
| `usp_Vietnam_DoProcessProdPacking_VVT` | Gộp Box Module |
| `usp_DoCancelProdPacking_LotNo` | Hủy đóng gói Lot |
| `usp_SplitPackingBox` | Chia Box (tách 1 box lớn thành nhiều box nhỏ) |
| `usp_savePackingLabelQty_VVT` | Lưu số lượng trên tem |

```sql
-- Thêm model mới vào ModelBasicInfo nếu thiếu Vol/Farad
SELECT * FROM STB_ModelBasicInfo WITH(NOLOCK) WHERE ModelCode = 'RDMD00-368'
INSERT INTO STB_ModelBasicInfo (ModelCode, ModelName, MaterialTypeCode, ProductGroupCode,
    MBISizeH, MBISizeW, IsClosed, OqcType, OqcInspectionRuleType, InspectionType, InspectionLevel,
    MBIExtText01, MBIExtText02, MBIExtText03, MBIExtText04, MBIExtText05, CreateDateTime)
VALUES ('RDMD00-368', 'HY-CAP WEC9R0166QG-WC(130)', 'MDL', 'HC-EDLC', 40, 18, 0, 'MANUAL', 'BY_MODEL', 'SAMPLE', 'SAMPLE', '9R0', '166', 'WEC', '9.0', '16.6', GETDATE())
```

---

### 6.9 B453 — In Tem INNER / OUTER (Customer Label)

**Chức năng:** In tem khách hàng cho hàng Module (PAC, Digi-Key...).

**Thông tin cần nhập:**

| Thông tin | INNER | OUTER |
|-----------|-------|-------|
| Custom Part No | ✅ | ✅ |
| INVOICE NO | ✅ | ✅ |
| INVOICE Date | ✅ | ✅ |
| Packet Qty | ✅ (số lượng mỗi gói) | — |
| BoxQTY | — | ✅ |
| Number Of Total | — | ✅ (mặc định=1) |
| IsOuter | ❌ **Không tick** | ✅ **Phải tick** |

> ⚠️ Tem Inner và Outer tính Serial Number **riêng biệt**.

**Quy trình in tem PAC đầy đủ:**
```
B525 — Gộp Box Module ➔ B453 — In tem INNER (không tick IsOuter) ➔ B453 — In tem OUTER (tick IsOuter) ➔ B754/B755/B756 — In tem thùng Carton + Cân nặng
```

---

### 6.9.1 In Tem Khách Hàng PAC (B754 / B755 / B756)

*   **B754 — In nhãn Inner/Outer:** Sử dụng để in nhãn sản phẩm theo thiết kế của khách hàng PAC. Inner và Outer có Serial Number độc lập (xem quy tắc in tại mục §6.9).
*   **B755 — Xem lịch sử:** Tra cứu tất cả các nhãn PAC đã được in từ màn hình B754.
*   **B756 — In nhãn thùng Carton + Cân nặng:**
    *   *In nhãn thùng:* Nhập số lượng tem cần thiết $\rightarrow$ Ấn Tìm kiếm $\rightarrow$ Nhấn nút **"Tem thùng Carton"**.
    *   *In nhãn cân nặng:* Tích chọn `IsWeightLabel` $\rightarrow$ Nhấn Tìm kiếm $\rightarrow$ Nhấn nút **"Tem Cân Nặng"** và nhập trọng lượng thực tế.

---

### 6.9.2 In Tem Khách Hàng Digi-Key (B757 / B758)

*   **B757 — In nhãn sản phẩm và nhãn Logistic:**
    *   *Nhãn sản phẩm:* Nhập/quét mã Lot hàng $\rightarrow$ Click **"IN NHÃN SP"**.
    *   *Nhãn Logistic:* Cần điền đầy đủ các thông tin: Lot, Số PO, Số dòng PO (PO Line Number), Số danh sách đóng gói (Pack List Number), và Số lượng tem $\rightarrow$ Click **"IN NHÃN LOGISTIC"**.
*   **B758 — In tem thùng MIXED LOAD:**
    *   Dùng để dán cho các pallet/thùng chứa nhiều loại sản phẩm trộn lẫn. Cần khai báo: `Pack List Number` (Số Invoice), `Weight` (Trọng lượng tổng), và `PackageCount` (Số lượng kiện).

---

### 6.9.3 Tra cứu SP in tem khách hàng Sanmina (Ví dụ khi setup mới)
Khi cần cấu hình hoặc debug mẫu in tem nhãn cho khách hàng mới như Sanmina, chạy các truy vấn sau để tìm Stored Procedure và metadata thiết kế:
```sql
-- 1. Tìm các SP in tem nhãn có chứa từ khóa 'Sanmina'
SELECT OBJECT_NAME(id) AS SP_Name, text
FROM syscomments WITH(NOLOCK)
WHERE text LIKE '%Sanmina%' AND text LIKE '%Label%'
ORDER BY SP_Name;

-- 2. Kiểm tra template thiết kế của tem Sanmina trong hệ thống Z530
SELECT LabelType, FormatName, LabelRemark, DataSourceViewName, CreateUserID, ChangeDateTime
FROM SmartFramework.dbo.STB_LabelInfo WITH(NOLOCK)
WHERE LabelType LIKE '%Sanmina%' OR FormatName LIKE '%Sanmina%';
```

---

### 6.9.4 Lỗi đúp dòng dữ liệu khi tìm kiếm lần 2 trên màn hình B767 (Sanmina India Label)

*   **Triệu chứng:** Khi người dùng click Tìm kiếm (Search) lần đầu, lưới (grid) hiển thị đúng 3 dòng (1 Outer, 2 Inners). Nhưng khi click Tìm kiếm lần thứ 2, lưới bị đúp thành 6 dòng dữ liệu (lần lượt lặp lại các dòng Outer, Inner).
*   **Nguyên nhân gốc:**
    *   Hàm tìm kiếm `usp_SanminaLabelPrint_get_Vietnam` được cấu hình trên lưới màn hình **B767** có thuộc tính **`데이터 추가` (Append Data)** đặt là **`True`** (tương ứng thẻ XML `<Append>true</Append>` trong `STB_ScreenLayoutInfo`).
    *   Đối với các màn hình thông thường (như Phoenix Contact - B790), dữ liệu tìm kiếm lần trước và lần sau hoàn toàn trùng khớp nên lưới tự động loại bỏ trùng lặp.
    *   Tuy nhiên, tem Sanmina có sinh số Serial tự tăng (`BoxSerialNo`, `PrintSerialNo` dựa trên `@MaxSerial` trong bảng lịch sử in). Lần tìm kiếm thứ 2 sinh ra dãy số Serial mới khác với lần tìm kiếm thứ nhất. Lưới NAIS phát hiện các dòng dữ liệu mới có sự khác biệt (ở cột số Serial) nên tự động append tiếp vào cuối grid thay vì làm sạch lưới.
*   **Cách khắc phục:**
    1. Mở màn hình thiết kế **B767** trong NAIS System screen creator.
    2. Chọn đối tượng **`usp_SanminaLabelPrint_get_Vietnam`** dưới nhánh `Search Function`.
    3. Tại bảng thuộc tính **Property (F4)** bên phải, tìm nhóm **Group** $\rightarrow$ thuộc tính **`데이터 추가`** (Append Data).
    4. Thay đổi giá trị từ **`True`** sang **`False`** (lưu dưới dạng `<Append>false</Append>`).
    5. Thực hiện **Save Layout** và **Approve** lại màn hình.

---

### 6.10 Thiết kế tem Phoenix Contact (Yêu cầu đặc biệt tại B790)

*   **Kích thước vật lý:** Tem kích thước 80mm x 50mm (5x8 cm).
*   **Loại tem (Label Type):** `Phoenix_Label` | **Tên mẫu (Format Name):** `Phoenix_Contact_V1`.
*   **Quy tắc Datecode:** Sử dụng định dạng `YYMMDD` lấy từ cột `InputJobDate` trong bảng `STB_SetInfo`.
*   **Số thứ tự hiển thị:** Định dạng `@CurrentIndex / @TotalQty`. Mã vạch (barcode) in ra chứa mã `PackingID`.

```sql
-- Chạy thử nghiệm Stored Procedure in tem Phoenix Contact
EXEC [dbo].[usp_Vietnam_PhoenixContactLabelPrint_get]
     @pPackingID = 'PK202606040001', -- Thay thế bằng PackingID thực tế
     @pNumberLabel = 2; -- Số lượng nhãn in test
-- Kết quả trả về phải chứa cột DateCode có định dạng YYMMDD (Ví dụ: '260612')

-- Logic trích xuất Datecode từ InputJobDate
SELECT Barcode, InputJobDate, CONVERT(VARCHAR(6), InputJobDate, 12) AS [DateCode_YYMMDD]
FROM STB_SetInfo WITH(NOLOCK)
WHERE Barcode = 'VVPR292R710617';
```

---

### 6.11 Danh sách mã vật tư đã mở in tem (Support History)

| Dự án | MaterialCode | Màn hình | SP / Logic | Ghi chú |
|-------|-------------|----------|-----------|---------|
| Phoenix (VVT) | ECVT30-197, ECVT30-098 | B790 | `usp_Vietnam_PhoenixContactLabelPrint_get` | Tem Phoenix Datecode YYMMDD |
| Ha Nam (VVT_F3) | 10140105055 (Anode Foil) | F721/Kho | `STB_ModelLabelInfo` (PartLabel) | Mở in tem 자재라벨 |

---

### 6.12 Checklist khi user báo "không in được tem" (B450/B523)

```
□ 1. A460 — Format tem có tồn tại không? Đúng loại (AssembleLabel vs PartLabel)?
□ 2. A419 — Tiêu chuẩn đóng gói đã khai báo chưa?
□ 3. STB_MaterialLotInfo — MaterialCode đúng chưa?
□ 4. F110 — IsLotUse = 1, IsUseBarcode = 1 chưa?
□ 5. STB_SetInfo — LotDecisionResult = 'PASS' chưa?
□ 6. STB_MaterialStockAttributeInfo — Có dòng cho mã VL chưa?
□ 7. STB_ModelBasicInfo — Model đã có MBIExtText04/05 (Vol/Farad) chưa?
```

---

### 6.13 Phân tích nguyên nhân lỗi "Gộp box tùy chỉnh" trên màn hình HN523 (Sản lượng hiển thị = 0 / Cảnh báo tiếng Hàn)

**Triệu chứng:** Khi nhấn nút "Gộp box tùy chỉnh" cho một mã Lot, hệ thống báo lỗi tiếng Hàn: `"Bạn chưa nhập kết quả sản xuất cho công đoạn này"` (hoặc sản lượng OutputQty hiển thị bằng 0), mặc dù thực tế công nhân đã hoàn thành đầy đủ các công đoạn sản xuất.

**Cơ chế hoạt động:**
- Màn hình sử dụng Stored Procedure `usp_Vietnam_GetProdPackingForBarcode_VVT` để load dữ liệu lên Grid `ProdPackingForBarcode`.
- Trong SP này, hệ thống thực hiện phép `JOIN` giữa mã Lot với bảng Cấu hình Quy trình (`STB_ProductionOrderRouting` map từ PONo).
- Điều kiện tính toán `OutputQty` bắt buộc là: Chỉ lấy sản lượng từ công đoạn nào được đánh dấu là `IsOutputRoute = 1` (Công đoạn đầu ra). Nếu không có công đoạn nào được đánh dấu `IsOutputRoute = 1`, hệ thống mặc định sản lượng đầu ra là `0` và chặn không cho gộp box.

**Quy trình debug & khắc phục:**
1. **Kiểm tra Lịch sử quét của công nhân:**
   ```sql
   SELECT RouteCode, ProdQty, CreateDateTime 
   FROM STB_ProdRouteHist WITH(NOLOCK)
   WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'Mã_Barcode')
   ORDER BY CreateDateTime ASC;
   ```
2. **Kiểm tra cấu hình quy trình sản xuất (Routing):**
   ```sql
   SELECT RouteCode, RouteIndex, IsOutputRoute 
   FROM STB_ProductionOrderRouting WITH(NOLOCK)
   WHERE PONo = (SELECT PONo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'Mã_Barcode')
   ORDER BY RouteIndex;
   ```
3. **Cách xử lý:**
   - **Vận hành:** Báo bộ phận Quản lý sản xuất cập nhật lại BOM/Routing trên Groupware và đồng bộ sang MES để tích chọn đúng công đoạn đầu ra.
   - **Sửa nhanh DB (Bypass tạm thời):** Update trực tiếp quy trình của PO hiện tại để đặt công đoạn cuối làm công đoạn đầu ra:
     ```sql
     BEGIN TRANSACTION;
     UPDATE STB_ProductionOrderRouting
     SET IsOutputRoute = 1
     WHERE PONo = 'Mã_PO_Tìm_Được' AND RouteCode = 'Mã_Công_Đoạn_Cuối'; -- Ví dụ: VE10
     COMMIT TRANSACTION;
     ```

### 6.13.2 Lỗi "포장 (Dong goi) 공정에서 실적을 입력하지 않았습니다" khi gộp box (B523)

**Triệu chứng:** Khi công nhân nhấn nút "Box합치기" (Gộp box) tại màn hình **B523** (đối với các dòng sản phẩm có bước hậu đóng gói như `V-34_BG` - Re-inspection), hệ thống báo lỗi tiếng Hàn: `"포장 (Dong goi) 공정에서 실적을 입력하지 않았습니다"` mặc dù Lot đã chốt đầy đủ các công đoạn sản xuất trước đó.

**Nguyên nhân gốc:** 
- PO được cấu hình công đoạn hậu đóng gói (ví dụ: `V-34_BG` - SX Kiểm tra lại, `V-29_BG` - Doping) làm công đoạn cuối cùng và có cờ `IsOutputRoute = 1`.
- Do đó, SP `usp_Vietnam_GetProdPackingForBarcode_VVT` trả về `@RouteCode = 'V-34_BG'` cho B523.
- Khi gộp box, SP `usp_DoProcessProdPackingByOne_VNT` kiểm tra công đoạn đứng trước `V-34_BG` trong quy trình của PO hiện tại (là công đoạn `V-28_BG` - Đóng gói) xem đã có lịch sử quét sản xuất trong bảng `STB_ProdRouteHist` chưa.
- Do công nhân chưa quét chốt sản lượng cho công đoạn đóng gói `V-28_BG` (trên PDA/màn hình B530), nên bảng `STB_ProdRouteHist` của barcode chưa có bản ghi này $\rightarrow$ Hệ thống báo lỗi chặn gộp.

**Cách khắc phục:**
- **Cách 1 (Vận hành chuẩn):** Công nhân sử dụng PDA/Terminal hoặc màn hình **B530** quét chốt sản lượng công đoạn `V-28_BG` trước, sau đó mới quay lại B523 thực hiện gộp box (B523 sẽ đóng vai trò chốt công đoạn cuối `V-34_BG` và sinh BoxID).
- **Cách 2 (Sửa DB bypass tạm thời):** Chuyển cờ `IsOutputRoute = 1` từ `V-34_BG` về công đoạn đóng gói `V-28_BG` trên quy trình PO để B523 tự chốt sản lượng:
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_ProductionOrderRouting SET IsOutputRoute = 0 WHERE PONo = 'MÃ_PO' AND RouteCode = 'V-34_BG';
  UPDATE STB_ProductionOrderRouting SET IsOutputRoute = 1 WHERE PONo = 'MÃ_PO' AND RouteCode = 'V-28_BG';
  COMMIT TRANSACTION;
  ```
- **Cách 3 (Chèn lịch sử quét ảo):** Chạy script chèn thủ công bản ghi lịch sử quét ảo cho công đoạn đóng gói `V-28_BG` vào bảng `STB_ProdRouteHist`:
  ```sql
  BEGIN TRANSACTION;
  BEGIN TRY
      INSERT INTO STB_ProdRouteHist (
          CompanyCode, WorkCenterCode, PONo, DayPlanNo, ControlNo, 
          MaterialCode, BomVersion, JobDate, ShiftCode, TimeCode, 
          LineCode, RouteCode, WorkerCode, MachineCode, ProdQty, 
          ProdDateTime, CreateDateTime, CreateUserID
      )
      VALUES (
          'VVT', 'VVT_F2', 'MÃ_PO', 'MÃ_DAYPLANNO', 'MÃ_CONTROLNO', 
          'MÃ_MODEL', '1', 'NGÀY_JOBDATE', 'A', '*', 
          'MÃ_LINE', 'V-28_BG', 'vinaadmin', 'MÃ_LINE', SỐ_LƯỢNG_LOT, 
          GETDATE(), GETDATE(), 'vinaadmin'
      );
      COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
      ROLLBACK TRANSACTION;
      PRINT ERROR_MESSAGE();
  END CATCH;
  ```

---

### 6.14 Lỗi cắt chuỗi danh sách tem nhỏ (B560 - Truncation in InBoxLabelList)

**Triệu chứng:** Khi in tem thùng Hela trên màn hình B560, nếu số lượng tem hộp nhỏ (InBoxLabel) vượt quá khoảng 73 tem, hệ thống sẽ tự động cắt ngắn chuỗi `InBoxLabelList` khiến màn hình B560 chỉ hiển thị `InBoxLabelCount = 73` thay vì 80 tem như thực tế.

**Nguyên nhân gốc:** 
1. Stored Procedure `usp_DoCreateHelaInBoxBarcodeList` khai báo biến cục bộ `@InBoxLabelList VARCHAR(1000)` quá ngắn. Khi có 80 tem, độ dài chuỗi vượt quá giới hạn 1000 ký tự.
2. Cột `InBoxLabelList` trong bảng `STB_HelaBarcodeOutBoxHist` chỉ được thiết lập là `VARCHAR(1000)` hoặc `VARCHAR(4000)` tùy phiên bản, dẫn đến việc cắt chuỗi khi lưu dữ liệu.

**Cách khắc phục:**
1. Thay đổi kiểu dữ liệu cột `InBoxLabelList` trong bảng `STB_HelaBarcodeOutBoxHist` thành `VARCHAR(MAX)`.
2. Thay đổi khai báo biến `@InBoxLabelList` trong stored procedure `usp_DoCreateHelaInBoxBarcodeList` thành `VARCHAR(MAX)`.
3. Thay đổi khai báo biến `@InQClList` trong stored procedure `usp_DoCreateReport` thành `VARCHAR(MAX)`.
4. Chạy script khôi phục lại chuỗi dữ liệu đã bị cắt cho các Lot bị lỗi (ví dụ lô `VVQO032R750613` có 80 tem):
   ```sql
   UPDATE STB_HelaBarcodeOutBoxHist 
   SET InBoxLabelList = 'S026060400161,S026060400162,...,S026060400240' -- Ghi đầy đủ chuỗi tem
   WHERE LotNo = 'VVQO032R750613';
   ```

---

### 6.15 Lỗi không in được tem vì không có Lot trên hệ thống (Bypass thủ công)

**Khi nào dùng:** Tình huống khẩn cấp cần in tem nhãn đóng gói gấp cho lô hàng thực tế đã đóng xong nhưng trên hệ thống MES bị lỗi không sinh được Lot (ví dụ: do sự cố đồng bộ PO ở B450).

**Quy trình 3 bước cứu hộ:**

*   **Bước 1 — Khai báo Lot mới vào SetInfo:**
    ```sql
    INSERT INTO STB_SetInfo (Barcode, MaterialCode, PONo, DayPlanNo, ProdQty, InputLineCode, InputJobDate, CreateDateTime, CreateUserID)
    VALUES ('VVXX123R000001', 'MÃ_MODEL', 'MÃ_PO', 'MÃ_KHOA_NGAY', 1000, 'MÃ_LINE', CONVERT(CHAR(8), GETDATE(), 112), GETDATE(), 'vinaadmin');
    ```
*   **Bước 2 — Cập nhật cờ chất lượng QC Pass:**
    ```sql
    UPDATE STB_SetInfo SET LotDecisionResult = 'PASS', IsDefect = 0 WHERE Barcode = 'VVXX123R000001';
    ```
*   **Bước 3 — Tạo tồn kho ảo liên kết Lot để in tem tại B523:**
    ```sql
    INSERT INTO STB_MaterialLotInfo (LotID, LotNo, MaterialCode, InitialQty, CurrentQty, CreateDateTime, CreateUserID)
    VALUES ('VVXX123R000001', 'VVXX123R000001', 'MÃ_MODEL', 1000, 1000, GETDATE(), 'vinaadmin');
    ```

---

### 6.16 Màn hình & Cấu hình Thiết Kế Tem (Z530/A460)

*   **Z530 (Label Layout Design):** Thiết kế mẫu in tem nhãn (phần mềm client dùng template dạng XML).
*   **A460 (Label Format Mapping):** Mapping mã sản phẩm (ModelCode) với định dạng tem in cụ thể.
*   **B756 / B767 / B790:** Các giao diện in tem nhãn theo khách hàng hoặc in hàng loạt.

```sql
-- Tra cứu thiết kế layout tem trong SmartFramework
SELECT FormatName, LabelType, IsApproval, ApplyDate, Description
FROM SmartFramework.dbo.STB_LabelInfo WITH(NOLOCK)
WHERE FormatName LIKE '%Phoenix%' AND IsApproval = 1;

-- Kiểm tra ánh xạ mã vật tư và tem in
SELECT ModelCode, LabelType, FormatName
FROM STB_ModelLabelInfo WITH(NOLOCK)
WHERE ModelCode = 'ECVT30-197';
```

---

### 6.17 Quy trình setup tem mới cho một mã vật tư
Khi có sản phẩm/model mới cần triển khai in tem nhãn, thực hiện cấu hình theo 4 bước:
```
1. Thiết kế tem (Z530) ➔ Khai báo mẫu tem trong STB_LabelInfo (IsApproval = 1).
2. Ánh xạ (A460)       ➔ Map ModelCode với tên mẫu tem vừa tạo trong STB_ModelLabelInfo.
3. Thuộc tính (F110)   ➔ Tích chọn IsLotUse = 1 và IsUseBarcode = 1 cho mã vật liệu mới.
4. Chạy in thử nghiệm  ➔ In thử tem mẫu tại B523/B790 để kiểm tra thực tế.
```

```sql
-- Script chèn nhanh mapping A460 cho sản phẩm mới
INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
VALUES ('NEW_MODEL_CODE', 'AssembleLabel', 'Phoenix_Contact_V1', GETDATE(), 'vinaadmin');
```

---
*Cập nhật: 2026-06-12 — Hợp nhất hoàn chỉnh từ KB_04 và KB_09, loại bỏ trùng lặp*


---

