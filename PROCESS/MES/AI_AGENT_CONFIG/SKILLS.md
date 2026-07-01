# ⚡ SKILLS — Vinatech MES Agent (PowerShell & SQL Templates)

> **Mục đích:** Các script template sẵn sàng dùng, chỉ cần thay params
> **Cập nhật:** 2026-06-19

---

## 1. 🔌 KẾT NỐI DB & CHẠY QUERY NHANH

Dùng trực tiếp công cụ `run_query.ps1` ở thư mục gốc để truy vấn nhanh mà không cần viết boilerplate code:

```powershell
# Truy vấn dạng bảng (Mặc định)
.\run_query.ps1 -Query "SELECT TOP 10 Barcode, MaterialCode FROM STB_SetInfo WITH(NOLOCK)"

# Truy vấn ra JSON (Cho các cấu trúc phức tạp cần AI parse)
.\run_query.ps1 -Query "SELECT TOP 10 * FROM STB_SetInfo WITH(NOLOCK)" -Format JSON

# Truy vấn từ file sql có sẵn
.\run_query.ps1 -SqlPath "sql/scripts/my_query.sql" -Format CSV
```

---

## 2. 🔍 DEBUG BARCODE (SQL)

```sql
-- Step 1: Trạng thái Barcode
SELECT Barcode, ControlNo, MaterialCode, ProdQty, 
       LotDecisionResult, IsDefect, DefectQty, IsProdFinish, InputLineCode
FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '@BARCODE'

-- Step 2: Routing History  
SELECT ProcSeq, RouteCode, ProdQty, JobDate, CreateDateTime, CreateUserID
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '@BARCODE')
ORDER BY CreateDateTime ASC

-- Step 3: Packing Info
SELECT MaterialLotNo, LotNo, MaterialCode, CurrentQty, PackingID
FROM STB_MaterialLotInfo WITH(NOLOCK)
WHERE LotNo = '@BARCODE'

-- Step 4: NVL Input (V-23/V-24)
SELECT Barcode, RouteCode, MaterialCode, RawMaterialBarcode, CreateDateTime
FROM STB_RawMaterialInputHist WITH(NOLOCK)
WHERE Barcode = '@BARCODE'
```

---

## 3. 🏭 TÌM SP ĐẰNG SAU MÀN HÌNH

```sql
-- Step 1: Tìm ScreenName từ TCode
SELECT Name AS ScreenName, Caption, TCode 
FROM SmartFramework.dbo.STB_ScreenInfo
WHERE TCode = '@TCODE'

-- Step 2: Tìm SP tương ứng
SELECT ObjectName, Caption, ObjectType, Description
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName = '@SCREEN_NAME'
-- SearchFunction = SP load data | ExecuteFunction = SP khi Save/Delete
```

---

## 4. 📦 CHECK GỘP BOX (B523)

```sql
-- 1. F110 — IsLotUse?
SELECT MaterialCode, IsUseBarcode, IsLotUse
FROM STB_MaterialStockAttributeInfo WHERE MaterialCode = '@MAT_CODE'

-- 2. QC Pass?
SELECT Barcode, LotDecisionResult, IsDefect
FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '@BARCODE'

-- 3. Đã gộp chưa?
SELECT LotNo, PackingID, CurrentQty
FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = '@BARCODE'

-- 4. Tiêu chuẩn đóng gói?
SELECT * FROM STB_PackingStandard WHERE MaterialTypeCode = 'FERT'
```

---

## 5. 🔐 ĐỌC SP SOURCE

```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_TenSP'))
-- Hoặc:
SELECT definition FROM sys.sql_modules 
WHERE object_id = OBJECT_ID('usp_TenSP')
```

---

## 6. 🏭 CHECK QC STATUS

```sql
SELECT CIDH.CommInspDocNo, CIDH.CommInspResult, CIDH.CreateDateTime
FROM STB_CommInspDocHistory CIDH WITH(NOLOCK)
JOIN STB_SetInfo SI WITH(NOLOCK) ON CIDH.ProdNo = SI.ControlNo
WHERE SI.Barcode = '@BARCODE'
ORDER BY CIDH.CreateDateTime DESC
```

---

## 7. 📋 CHECK BLOCK SESSION

```sql
SELECT blocking_session_id AS [Blocker], session_id AS [Blocked],
       wait_time/1000 AS [WaitSec], wait_type
FROM sys.dm_exec_requests WHERE blocking_session_id <> 0
```

---

## 8. 💡 LESSONS LEARNED (Từ các cuộc trò chuyện)

1. **Gate 20 phút KHÔNG hoạt động** — Bug trong `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`: dùng `= Null` thay vì `IS NULL`
2. **STB_MaterialHoldInfo KHÔNG tồn tại** — HOLD dùng `MaterialWarehouseCode = 'HOLDING_*'`
3. **CompleteRoute='1' set cho MỌI route** — Không dùng để xác định route cuối, dùng `IsOutputRoute`
4. **STB_BarrelBarcodeInfo KHÔNG tồn tại** — Bảng thực: `STB_VietNam_CheckBarcode_2624`
5. **STB_AluCaseMapping_VVT KHÔNG tồn tại** — Logic vỏ nhôm hardcode trong SP
6. **Git root là Desktop** — Luôn scope git commands vào `MES/`
7. **Electrode SP naming** — `usp_ElectrodeStep_get` (không phải `usp_ElectrodeStep_Vietnam`)
8. **Packing SP** — `usp_Vietnam_DoProcessProdPacking_VVT` (không phải `usp_DeProcessProdPacking_VVT`)
9. **WarehouseCode ≠ MaterialWarehouseCode** — Cột đúng là `MaterialWarehouseCode` trong `STB_MaterialLotInfo`
10. **usp_DoCreateSerial = 470 callers** — KHÔNG sửa SP này trừ khi hiểu rõ impact
11. **STB_VVT_ESRDATA = 398M rows / 61GB** — Luôn WHERE cụ thể + WITH(NOLOCK)
12. **STB_MaterialMaster = 874 SPs đọc** — Sửa cột = impact rất rộng
13. **CRLF warning** — Không mass-edit KB .md files bằng replace_file_content (risk corruption). Chỉ sửa 1 dòng tại 1 thời điểm.

---

## 9. 📊 SP IMPACT CHECK (Trước khi sửa)

```sql
-- Bao nhiêu SP khác gọi SP này?
SELECT COUNT(DISTINCT referencing_id) AS CallerCount
FROM sys.sql_expression_dependencies 
WHERE referenced_entity_name = 'TÊN_SP'
  AND referencing_id IN (SELECT object_id FROM sys.procedures)

-- SP này đọc/ghi những bảng nào?
SELECT referenced_entity_name, referenced_class_desc
FROM sys.sql_expression_dependencies 
WHERE referencing_id = OBJECT_ID('TÊN_SP')
ORDER BY referenced_entity_name
```

---

## 10. 📦 ĐỌC KB CHUNKED (Tiết kiệm token)

7 KB files lớn đã tách thành chunks: KB_02, KB_03, KB_04, KB_05, KB_07, KB_10, KB_19.

**Quy trình đọc KB chunked:**
```
1. Đọc INDEX.md trước:
   → MES_MASTER_KNOWLEDGE_BASE/KB_03/INDEX.md  (1.5KB)

2. Chọn chunk phù hợp từ Quick Routing table trong INDEX

3. Đọc chunk cụ thể:
   → MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md  (64KB)

4. KHÔNG đọc file gốc KB_03_SAN_XUAT.md (150KB) → lãng phí token
```

**Map nhanh:**
| Cần | KB | Chunk |
|-----|-----|-------|
| Debug B530/B523/B597 | KB_03/ | 02_CELL_LINE |
| Bugs SX theo screen | KB_03/ | 03_SCREEN_BUGS_B |
| Đóng gói core | KB_04/ | 01_CORE_PACKAGING |
| QC overview | KB_05/ | 01_QC_OVERVIEW |
| IQC→OQC flow | KB_05/ | 03_QC_FLOW |
| Kho NVL | KB_02/ | 01_NVL_WMS |
| Kho TP Hà Nam | KB_02/ | 02_FG_WMS |
| Kiến trúc MES | KB_10/ | 01_ARCHITECTURE |
| DB Map | KB_19/ | 01_ARCHITECTURE |
| ESM/Groupware | KB_07/ | 02_ESM_FORMS |

---

## 11. AUTOMATED TOOLS FOR DOCUMENTATION (CÔNG CỤ TỰ ĐỘNG HÓA TÀI LIỆU)

Dưới đây là các script Node.js dùng để tự động hóa trích xuất, gộp, sắp xếp và chuẩn hóa dữ liệu màn hình từ database SmartFramework và ghi vào tài liệu tổng hợp:

### A. Script Trích Xuất & Sắp Xếp Luồng Vận Hành (`merge_and_sort_by_flow.js`)
Script này đọc danh sách TCode, tự động lấy cấu hình Object từ DB và phân nhóm vào 9 bước luồng vận hành thực tế của nhà máy, sau đó tạo lại Mục Lục tự động:
```javascript
// Xem chi tiết code mẫu tại: scratch/merge_and_sort_by_flow.js
// Script hoạt động theo luồng:
// 1. Phân tích nội dung cũ và trích xuất danh sách màn hình theo TCode.
// 2. Định nghĩa mảng flowSteps chứa thứ tự TCode của 9 bước vận hành nhà máy.
// 3. Đọc dữ liệu missing screens vừa trích xuất từ database.
// 4. Tạo lại Mục Lục (Table of Contents) với liên kết dạng slug chuẩn Markdown.
// 5. Kết hợp và lưu đè lên file ALL_SCREENS_DOCUMENTATION.md.
```

### B. Script Cập Nhật Bảng Thống Kê Tổng Hợp Realtime (`update_statistics.js`)
Script này phân tích cú pháp của file Markdown tổng hợp, đếm số lượng màn hình và đếm tổng các loại đối tượng (Views, Search, Execute, Actions) thực tế trong mỗi bước, sau đó tự động ghi đè lại bảng thống kê ở cuối trang:
```javascript
// Xem chi tiết code mẫu tại: scratch/update_statistics.js
// Script hoạt động theo luồng:
// 1. Định vị phần "# THỐNG KÊ TỔNG HỢP" trong file.
// 2. Dùng Regex quét dòng: "| **Tổng Objects** | **X** (Y View + Z SearchFunction...)" của từng màn hình.
// 3. Cộng dồn số lượng theo từng bước vận hành từ 1 đến 9.
// 4. Định dạng và ghi đè bảng thống kê mới cùng tổng cộng toàn hệ thống.
```

### C. Script Dọn Dẹp & Chuẩn Hóa Định Dạng (`clean_dividers.js`)
Script này tự động rà soát, dọn dẹp các ghi chú, dòng ngăn cách tạm thời, hoặc các tiêu đề nhóm cũ bị thừa trong quá trình gộp file để đảm bảo tính toàn vẹn và sạch sẽ của tài liệu:
```javascript
// Xem chi tiết code mẫu tại: scratch/clean_dividers.js
// Script tự động Replace các mẫu lỗi như:
// - "> **Tài liệu tiếp tục ở phần sau..."
// - "> Tổng cộng 100+ màn hình..."
// - "# CÁC MÀN HÌNH ... CHƯA CÓ BODY"
// - Các khoảng trắng trống liên tiếp (> 3 dòng) hoặc separator đôi.


## 12. TEMPLATE CHO ACTIVE SPS (IN TEM & EMAIL CẢNH BÁO)

### A. Kiểm Tra In Tem Nhãn (usp_DoCheckLabelPrintCount)
Sử dụng khi cần kiểm tra/kiểm soát số lần in tem của một mã sản phẩm cụ thể nhằm ngăn chặn in lậu/in trùng:
```sql
-- 1. Kiểm tra số lần in tem thực tế của ControlNo
SELECT COUNT(*) AS PrintedCount 
FROM STB_LabelPrintCountInfo WITH(NOLOCK) 
WHERE ControlNo = '@ControlNo';

-- 2. Kiểm tra mã vật tư từ SetInfo
SELECT MaterialCode 
FROM STB_SetInfo WITH(NOLOCK) 
WHERE ControlNo = '@ControlNo';
```

### B. Kiểm Tra Log Nhiệt Độ Độ Ẩm Vượt Ngưỡng (usp_DoAddTempAndHumRemindMail_VVTF3)
Sử dụng khi kiểm tra dữ liệu từ thiết bị IoT giám sát kho Hà Nam F3 vượt Spec (Nhiệt độ: 18-25°C, Độ ẩm: 0-70%):
```sql
-- 1. Check số lượng bản ghi vượt Spec nhiệt độ trong 10 phút gần đây
SELECT COUNT(*) AS TempAlertCount 
FROM STB_IoTMeasureHist WITH(NOLOCK)
WHERE DeviceID IN ('Vina-Enesol-Material', 'Vina-Enesol-Finish-G')
  AND ChangeUserID IS NULL
  AND MeasureItemCode = 'Temperature'
  AND MeasureValue NOT BETWEEN 18 AND 25
  AND CreateDateTime >= DATEADD(MINUTE, -10, GETDATE());

-- 2. Check chi tiết các bản ghi vượt Spec
SELECT DeviceID, MeasureItemCode, MeasureValue, LSL = 18, USL = 25, CreateDateTime
FROM STB_IoTMeasureHist WITH(NOLOCK)
WHERE DeviceID IN ('Vina-Enesol-Material', 'Vina-Enesol-Finish-G')
  AND ChangeUserID IS NULL
  AND ((MeasureItemCode = 'Temperature' AND MeasureValue NOT BETWEEN 18 AND 25)
       OR (MeasureItemCode = 'Humidity' AND MeasureValue NOT BETWEEN 0 AND 70))
  AND CreateDateTime >= DATEADD(MINUTE, -10, GETDATE())
ORDER BY CreateDateTime ASC;
```
```

