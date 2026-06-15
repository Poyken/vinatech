# KB_04 — Đóng Gói & In Tem (Packaging & Label Printing)

> **Màn hình liên quan:** B523, B525, B453, B789, B781, B450, B351, A419, A460, B754~B758, B767, B790, Z530
> ← [Về INDEX](KB_INDEX.md)

---

## 6. 📦 Đóng gói & In tem nhãn

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

## 🔴 Cẩm nang khắc phục lỗi theo Screen ID (Gộp từ KB_SCREEN_BUG_REF)

## B351 — Lot Transition (Chuyển đổi Lot)

### Lỗi 1: Barcode sinh ra bị chèn ký tự dấu chấm (`.`) sai định dạng
*   **Triệu chứng:** Sau khi thực hiện chuyển đổi Lot/vật tư tại màn hình **B351**, Barcode sản phẩm mới sinh ra xuất hiện dấu chấm (Ví dụ: `VVPR152.740601`) thay vì ký tự chữ `R` tiêu chuẩn (`VVPR152R740601`). Lỗi này chặn quét công đoạn tiếp theo.
*   **Nguyên nhân gốc:** Sai lệch logic cắt ghép chuỗi sinh barcode tự động trong SP xử lý transition.
*   **Cách khắc phục:**
    Chạy script SQL để sửa đồng loạt Barcode bị lỗi trong các bảng giao dịch:
    ```sql
    DECLARE @OldBC NVARCHAR(50) = 'VVPR152.740601';
    DECLARE @NewBC NVARCHAR(50) = 'VVPR152R740601';

    UPDATE STB_RawMaterialInputHist SET Barcode = @NewBC WHERE Barcode = @OldBC;
    UPDATE STB_SetInfo SET Barcode = @NewBC WHERE Barcode = @OldBC;
    UPDATE STB_LotChangeMaterialHistory SET NewBarcode = @NewBC WHERE NewBarcode = @OldBC;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.2](KB_04_DONG_GOI_IN_TEM.md#62-sửa-tên-lot-sau-b351-chuyển-đổi-lot--barcode-có-dấu-chấm).

---


## B523 / B525 — Packaging & Box Matching (Đóng gói Cell & Module)

### Lỗi 1: Báo lỗi "Chưa có tiêu chuẩn đóng gói" khi gộp Box
*   **Triệu chứng:** Công nhân quét gộp Box tại màn hình **B523** hệ thống báo lỗi đỏ chặn đứng quy trình: `"Chưa có tiêu chuẩn đóng gói"`.
*   **Nguyên nhân gốc:** Model/Size mới chưa được khai báo số lượng đóng gói định mức trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:**
    Khai báo tiêu chuẩn đóng gói (dựa trên loại vật tư `FERT` và size model, không gán theo `MaterialCode`):
    ```sql
    INSERT INTO STB_PackingStandard (MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty, CreateDateTime, CreateUserID)
    VALUES ('FERT', 'KÍCH_THƯỚC_SIZE_4_CHỮ_SỐ', NULL, NULL, 500, 4000, 8000, GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.1](KB_04_DONG_GOI_IN_TEM.md#61-lỗi-chưa-có-tiêu-chuẩn-đóng-gói-b523).

### Lỗi 2: Không gộp được Box Cell/Module do chưa có Lot, thiếu QC hoặc cờ F110
*   **Triệu chứng:** Hệ thống từ chối gộp box cho Lot tại **B523** hoặc **B525**.
*   **Nguyên nhân gốc:** Lot chưa được đánh giá QC Pass (`LotDecisionResult` rỗng/FAIL), hoặc mã vật tư chưa được bật các cờ quản lý Lot (`IsLotUse=1`, `IsUseBarcode=1`) tại F110.
*   **Cách khắc phục:**
    Chạy query kiểm tra 4 bước và sửa cờ thuộc tính hoặc cập nhật kết quả QC:
    ```sql
    -- Bước 1: Kéo cờ thuộc tính nếu thiếu
    UPDATE STB_MaterialStockAttributeInfo SET IsLotUse = 1, IsUseBarcode = 1 WHERE MaterialCode = 'MÃ_VẬT_TƯ';
    -- Bước 2: Cập nhật kết quả QC Pass tạm thời nếu khẩn cấp
    UPDATE STB_SetInfo SET LotDecisionResult = 'PASS', IsDefect = 0 WHERE Barcode = 'MÃ_BARCODE';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.4](KB_04_DONG_GOI_IN_TEM.md#64-lỗi-không-gộp-box-được-b523--quy-trình-debug-chuẩn).

### Lỗi 3: Lỗi Packing Qty hiển thị số âm hoặc sai lệch số lượng thực tế
*   **Triệu chứng:** Màn hình hiển thị số lượng đóng gói bị âm hoặc sai lệch nghiêm trọng.
*   **Nguyên nhân gốc:** Sai lệch lượng trừ kho ảo `CurrentQty` trong bảng `STB_MaterialLotInfo` hoặc sai bản ghi `STB_SavePackingTime_VVT`.
*   **Cách khắc phục:**
    Chạy script reset số lượng thực tế của Lot về giá trị đúng:
    ```sql
    UPDATE STB_MaterialLotInfo SET CurrentQty = [SỐ_LƯỢNG_ĐÚNG] WHERE LotNo = 'MÃ_LOT';
    UPDATE STB_SavePackingTime_VVT SET PackQty = [SỐ_LƯỢNG_ĐÚNG] WHERE LotNo = 'MÃ_LOT' AND id = [ID_GIAO_DỊCH];
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.6](KB_04_DONG_GOI_IN_TEM.md#66-lỗi-packing-qty-âm-ở-b523--b789).

### Lỗi 4: Lỗi "Chưa có tiêu chuẩn đóng gói" cho Model/Size 1840 khi quét gộp Box
*   **Triệu chứng:** Khi công nhân quét gộp Box cho các Model có kích thước size `1840` tại màn hình B523, hệ thống báo lỗi đỏ chặn không cho thao tác.
*   **Nguyên nhân gốc:** Thiếu cấu hình định mức đóng gói cho kích thước size `1840` trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:**
    Chạy SQL chèn bổ sung cấu hình đóng gói chuẩn (InnerBoxQty = 500, OutBoxQty = 1000) vào bảng `STB_PackingStandard`:
    ```sql
    INSERT INTO STB_PackingStandard (MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty, CreateDateTime, CreateUserID)
    VALUES ('FERT', '1840', 0, 0, 0, 500, 1000, GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_19_PHAN_TICH_LOT_SIZE_VÀ_MÃ_LỖI_B530.md § 2.1](KB_19_PHAN_TICH_LOT_SIZE_VÀ_MÃ_LỖI_B530.md#21-file-thay-đổi-số-lượng-lot-noxlsx-sự-cố-chưa-được-cover-đầy-đủ).

---


## B717 — Bending & Tapping (Uốn chân & Dán băng keo Cell)

### Lỗi 1: Nhập sai thông số uốn/dán tại B717 không thể sửa hoặc xóa trực tiếp trên giao diện
*   **Triệu chứng:** OP nhập nhầm số lượng, sai kích thước hoặc thông số uốn dán tại **B717**, không thấy nút Edit hay Delete trên UI để chỉnh sửa lại.
*   **Nguyên nhân gốc:** Hệ thống chỉ được thiết kế để ghi nhận 1 lần (Insert hoặc Override) và không hỗ trợ tính năng sửa/xóa giao dịch trên client app.
*   **Cách khắc phục:** IT kiểm tra và chạy script SQL update trực tiếp sản lượng hoặc xóa bản ghi giao dịch sai trong bảng tương ứng để OP quét lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 5 (Mục 3)](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md#5-⚠️-5-điểm-nguy-hiểm-ẩn--developer-phải-biết).

---


## B525 — Warehouse Packing (Đóng gói kho)

> 🔗 **Xem thêm:** Mục [B523 / B525](#b523--b525--packaging--box-matching) phía trên đã có chi tiết lỗi đóng gói.

### Lỗi 1: Không gộp được Box tại kho (khác B523 dành cho sản xuất)
*   **Triệu chứng:** Thủ kho thao tác đóng gói tại B525 bị chặn tương tự B523.
*   **Nguyên nhân gốc:** B525 là phiên bản dành cho kho, cùng logic với B523 nhưng lọc theo WarehouseCode. Thiếu cờ `IsLotUse` hoặc `IsUseBarcode` tại F110.
*   **Cách khắc phục:** Áp dụng cùng quy trình debug 4 bước như B523 (xem mục B523 phía trên).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.4](KB_04_DONG_GOI_IN_TEM.md).

---


## B781 — Packing Print Time Report (Tra sản lượng đóng gói nhập tay)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên đã có chi tiết lỗi đơn giá.

### Lỗi 1: Sai ngày in tem đóng gói tại B781
*   **Triệu chứng:** Báo cáo B781 hiển thị sai ngày in/đóng gói so với thực tế.
*   **Nguyên nhân gốc:** Cột `PrintTime` trong `STB_SavePackingTime_VVT` bị ghi sai khi nhập tay tại B523.
*   **Cách khắc phục:** Chạy SQL sửa trực tiếp: `UPDATE STB_SavePackingTime_VVT SET PrintTime = 'NGÀY_ĐÚNG' WHERE LotNo = 'MÃ_LOT'`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 5.3](KB_03_SAN_XUAT.md).

---


## B789 — Packing Qty Edit (Sửa số lượng đóng gói)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên.

### Lỗi 1: Cần xóa hoặc sửa số lượng Packing đã lưu
*   **Triệu chứng:** Số lượng đóng gói bị ghi nhận sai, cần sửa lại.
*   **Nguyên nhân gốc:** OP nhập nhầm số lượng khi gộp Box tại B523. B789 sử dụng SP `usp_Vietnam_GetBoxIDForLotNo_VVT` để tra cứu.
*   **Cách khắc phục:** Sửa trực tiếp trong bảng `STB_SavePackingTime_VVT` theo LotNo và ID giao dịch.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.6](KB_04_DONG_GOI_IN_TEM.md).

---
