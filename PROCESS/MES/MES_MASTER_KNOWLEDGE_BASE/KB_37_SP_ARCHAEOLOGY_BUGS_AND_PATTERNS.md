# KB_37 — SP Archaeology: Phân Tích Comment, Edit History & Bug Patterns

> **Cập nhật:** 2026-06-18 | **Nguồn:** Đọc source code trực tiếp từ DB
> **🔑 Keywords:** SP archaeology, comment, edit history, bug pattern, hardcode, UNION ALL, NOT IN, whitelist, bypass, CASE WHEN, exception lot, CTE mapping, legacy
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 📊 Bảng Xếp Hạng SP Theo Mức Độ Phức Tạp & Tần Suất Sửa

| # | SP Name | Size | Comments | Days Modified | Tác giả gốc | Sửa bởi |
|---|---------|------|----------|---------------|-------------|---------|
| 1 | `usp_Vietnam_RawMaterialInputHist_uid` | **175K** | 619 | 1,826 | Mr.Tung | vanduc, DuongPham, Duy, DinhManh, Triều, Back, Bach |
| 2 | `usp_Vietnam_GetBoxIDForLotNo_VVT` | 38K | ~200 | 1,896 | Jeon Gyeong Ho (Awoo) | Mr.Tung, Duy, DinhManh, vanduc, Tinh, Triều, Phuong |
| 3 | `usp_MaterialWarehouseInOutHist_iud` | 31K | 662 | - | Korean team | VN team |
| 4 | `usp_DoCheckSlittingLot` | 38K | 769 | - | Korean team | VN team |
| 5 | `usp_Vietnam_DoProcessProdPacking_VVT` | 5.8K | ~50 | - | VN team | vanduc |
| 6 | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | 22K | ~100 | - | Korean team | VN team |

---

## 2. 🔍 CÁC PATTERN SỬA CODE ĐÃ PHÁT HIỆN

### Pattern 1: HARDCODE EXCEPTION LOT — "Thuốc đặc trị"

**Mô tả:** Khi 1 lot cụ thể gặp lỗi, thay vì fix logic gốc → người tiền nhiệm thêm lot đó vào danh sách `NOT IN` hoặc `WHEN @LotNo = '...' THEN '...'` để bypass.

**Ví dụ thực tế trong SP:**

```sql
-- File: usp_Vietnam_RawMaterialInputHist_uid, dòng 135-146
-- Bypass validation cho 11 lot cụ thể
@pBarcode not in ('VVPL072R7106051','VVNP313R015602','MVVOS236R035501',
'VVPS283R010704','VE241102-001','VE250210-005','VE250221-004',
'VE250114-008','VE250304-006','VE250205-007')

-- File: usp_Vietnam_GetBoxIDForLotNo_VVT, dòng 351-420
-- 70+ lot bị tắt VJ printing
if ( @LotNo in ('VVOS093R825703','VVOS103R825708',...)) set @allowVJ = 0

-- File: usp_Vietnam_GetBoxIDForLotNo_VVT, dòng 624-763
-- 100+ WHEN CASE để đổi lot number khi in tem
when @LotNo='VVPM153R825714' then 'VVPM153R825714'
when @LotNo='VVQM263R033504' then 'VVQM253R033545'
```

> ⚠️ **RỦI RO:** Danh sách `NOT IN` ngày càng dài → SP chậm lại do phải compare từng giá trị. Mỗi lần sửa lỗi cho 1 lot = thêm 1 dòng vĩnh viễn.

**Cách nhận biết:** Tìm `NOT IN (` hoặc `when @LotNo = '` hoặc `@pBarcode not in` trong SP.

**Ý nghĩa nghiệp vụ:**
- Lot bị thêm vào `NOT IN` = lot đó đã gặp lỗi validation, được bypass thủ công
- `WHEN @LotNo = 'X' THEN 'Y'` = lot X cần in tem với mã Y (sai mã gốc trong DB)
- `set @allowVJ = 0` cho lot cụ thể = lot đó khách hàng yêu cầu KHÔNG in prefix VJ

---

### Pattern 2: CTE HARDCODE MAPPING — "Bản đồ ngầm"

**Mô tả:** Thay vì tạo bảng config, mapping NVL ↔ Model được hardcode bằng CTE `UNION ALL`.

**Ví dụ:**

```sql
-- usp_Vietnam_RawMaterialInputHist_uid: Terminal mapping (dòng 479-526)
;with Termi1 as (
  select 'GBHB00-042' as Terminal, 'VEC2R7506QG' as model, '1840' as size UNION ALL
  select 'GBHB00-042' as Terminal, 'VEC3R0606QG' as model, '1840' as size UNION ALL
  select 'GBHB00-036' as Terminal, 'WEC3R0205QA' as model, '0816' as size UNION ALL -- update 2026-01-05
  -- ... 40+ dòng
)

-- Electrolyte mapping (dòng 606-711)
;with eleclyte1 as (
  select 'GBCP00-004' as electrolyte, 'VEC2R7505QG' as model, '1020' as size --2025-05-13
  -- ... 80+ dòng, thêm mới mỗi tuần
)

-- Sleeve/Vỏ nhôm mapping (dòng 829-1160)
;with Sleev1 as (
  -- ... 250+ dòng mapping vỏ nhôm → model
)
```

> ⚠️ **RỦI RO:** Mỗi khi thêm model MỚI → phải sửa SP ở 3 chỗ (Terminal + Electrolyte + Sleeve). Quên 1 chỗ = B597 báo lỗi.

**Cách nhận biết:** Tìm `;with` hoặc `UNION ALL` + `as model` trong SP.

**Ý nghĩa nghiệp vụ:**
- Comment `--2025-05-13` hoặc `--update 2026-01-05` = ngày được thêm mapping cho model mới
- `GBCP00-004` = Mã electrolyte phổ biến nhất (dung dịch tiêu chuẩn)
- `GBEC00-011` = Mã electrolyte mới (xuất hiện từ 2026-01-13)
- `GCMDPT-XXX` = Mã vỏ nhôm (sleeve)

---

### Pattern 3: COMMENT ĐỔI NHÀ PHÁT TRIỂN — "Lịch sử giao ca"

**Mô tả:** Comment cho biết ai yêu cầu sửa, ai thực hiện, và ngày sửa.

**Format phổ biến:**
```sql
--vanduc edited by Mr.DuongPham 20260615 START
...code thay đổi...
--END

--DinhManh update 2025-06-26 tancha
--DinhManh update 2025-09-22 tancha

--Mr.Duy add
--Mr.Back yeu cau 20 thang 10
--back Sơ bổ sung data ngày 24 tháng 1
--Duy Add to Huyen 2023-12-21

--ducnv edited by Mr.Tran Tuyen 20260613 START
--END

--vanduc edited by Mrs.Tran Lan 20260528
--start
/*...code cũ bị comment out...*/
--end

-- Mr.Triều chuẩn bị audit chặn không cho OP nhập nhầm vỏ nhôm

--Md.Diep request pass condition for this Lot 2023-07-31
```

**Quy tắc đọc:**
| Pattern | Ý nghĩa |
|---------|---------|
| `--vanduc edited by Mr.X START...END` | `vanduc` là người code, `Mr.X` là người yêu cầu |
| `--Mr.Duy add` | Mr.Duy tự thêm (không ghi ai yêu cầu) |
| `--DinhManh update YYYY-MM-DD tancha` | DinhManh thêm mapping Tancha (terminal) vào ngày đó |
| `--update 2025-MM-DD` | Ngày thêm dòng UNION ALL mới (không ghi ai) |
| `--Md.Diep request pass...` | Chị Diệp (QC/SX) yêu cầu bỏ qua validation cho lot cụ thể |
| `/*...code cũ...*/` | Code bị comment out = logic cũ đã bỏ nhưng giữ để tham khảo |

---

### Pattern 4: COMMENT OUT THAY VÌ XÓA — "Nghĩa địa code"

**Mô tả:** Code cũ bị bọc trong `/* */` hoặc `--` thay vì xóa. Đây là "kho báu" cho việc hiểu lịch sử.

**Ví dụ:**
```sql
-- usp_Vietnam_GetBoxIDForLotNo_VVT, dòng 631-647
--vanduc edited by Mrs.Tran Lan 20260528
--start
/*
When @LotNo='VJPL073R025604' then 'VVQN073R025604'
When @LotNo='VJPL153R025601' then 'VVQN153R025601'
When @LotNo='VJPK253R025605' then 'VVQN253R025605'
...12 dòng...
*/
--end

-- Ý nghĩa: Những lot này TRƯỚC ĐÂY cần chuyển đổi VJ→VV,
-- nhưng đã được fix bằng cách khác (có thể fix trực tiếp trong DB)
-- nên code chuyển đổi bị comment out.
```

```sql
-- usp_Vietnam_RawMaterialInputHist_uid, dòng 93-107
/*
if(@pCompanyCode = 'VVT' and UPPER(isnull(@pProductGroupCode,''))
   not in ('ELECTRODEP','ELECTRODEM') and @pRawMaterialBarcode <> '')
begin
    exec usp_checkExportWarehouseCodeInRouteWh @pWorkCenterCode,@pRawMaterialBarcode,@Linecode output
end

-- Ý nghĩa: Logic CHECK NVL đã xuất ra đúng line HAY CHƯA
-- đã từng tồn tại nhưng bị TẮT (comment out).
-- LÝ DO: Có thể gây chậm hoặc false positive khi NVL
-- được chuyển kho nội bộ trước khi xuất.
```

---

### Pattern 5: BYPASS QUA RAISERROR DEBUG — "Debug thủ công"

**Mô tả:** Khi debug, developer dùng `RAISERROR` để in giá trị biến. Sau khi fix, các dòng debug bị comment out nhưng không xóa.

```sql
--raiserror(@pRawMaterialBarcode,16,1)
--RAISERROR(@MaterialCode,16,1)
--RAISERROR(@pLotID_Warehouse_Created,16,1)
--raiserror ( @ext_partno ,16,1)
--RAISERROR(@PartNo,16,1)
--raiserror(@lotweight111,16,1)
--RAISERROR('fds',16,1)  -- debug marker "fds" = garbage text
```

> 💡 **Mẹo:** Khi cần debug SP, UN-COMMENT các dòng RAISERROR này, chạy SP với test data, xem giá trị nào sai.

---

### Pattern 6: NVARCHAR SIZE UPGRADE — "Mở rộng buffer"

**Mô tả:** Khi gặp lỗi "String or binary data would be truncated", fix = tăng size.

```sql
-- usp_Vietnam_RawMaterialInputHist_uid, dòng 13-38
--@pRawMaterialBarcode NVARCHAR(200)= NULL, vanduc edited by Mr.DuongPham 20260615 START
@pRawMaterialBarcode NVARCHAR(1000)= NULL,
--END

-- TRƯỚC: NVARCHAR(200) → Khi scan >5 mã điện cực, chuỗi vượt 200 ký tự → crash
-- SAU:   NVARCHAR(1000) → Chứa được ~15 mã điện cực nối nhau bằng ";"
```

**Ý nghĩa:** Lỗi `String or binary data would be truncated` thường fix bằng cách tăng size biến/parameter.

---

## 3. 🐛 BUG ĐÃ PHÁT HIỆN TỪ CODE ARCHAEOLOGY

### Bug 1: Factory Isolation thiếu — B597 (Severity: Medium)

**Vị trí:** `usp_Vietnam_RawMaterialInputHist_uid`, dòng 111
```sql
IF @checkWorkCenterCode NOT IN ('VVT_F4')  -- Chỉ tách BG2 (Hưng Yên)
BEGIN
    -- Toàn bộ logic validation Terminal/Electrolyte/Sleeve chạy ở đây
END
```
**Vấn đề:** Logic validation NVL (**3000+ dòng**) chỉ chạy cho VVT_F1 (Bắc Ninh) + VVT_F3 (Hà Nam). **VVT_F4 (Hưng Yên)** bị SKIP HOÀN TOÀN = không check Terminal/Electrolyte/Sleeve.
**Rủi ro:** Hưng Yên có thể nhập NVL sai loại vào dây chuyền mà không bị chặn.

---

### Bug 2: Hardcode barcode bypass nguy hiểm — B597 (Severity: High)

**Vị trí:** `usp_Vietnam_RawMaterialInputHist_uid`, dòng 120-126
```sql
if(@MaterialCode in ('EDVTMD-082')
   and @pRawMaterialBarcode in ('0000000000')
   and @pProductGroupCode in ('SLEEVE','MODULESLEEVE'))
begin
    set @check ='a'  -- bypass toàn bộ validation
end
```
**Vấn đề:** Nếu nhập mã barcode `0000000000` với model `EDVTMD-082` và loại `SLEEVE` → **bỏ qua tất cả validation**. Đây là bypass được thiết kế có chủ đích (cho trường hợp không có mã vỏ nhôm), nhưng có thể bị lợi dụng.

---

### Bug 3: CTE mapping ngày càng phình — B597 (Severity: Medium)

**Vị trí:** `usp_Vietnam_RawMaterialInputHist_uid`
- Terminal CTE: **40+ dòng** (dòng 479-526)
- Electrolyte CTE: **80+ dòng** (dòng 606-711)
- Sleeve CTE: **250+ dòng** (dòng 829-1160)

**Vấn đề:** Mỗi model mới = thêm 3 dòng `UNION ALL`. SP đã có **175K chars** — gần giới hạn SQL Server (256K).
**Giải pháp đề xuất:** Tạo bảng config `STB_VVT_MaterialBOMapping` để thay thế CTE hardcode.

---

### Bug 4: Duplicate exception lot entries — B523 (Severity: Low)

**Vị trí:** `usp_Vietnam_GetBoxIDForLotNo_VVT`, dòng 729-742
```sql
when @LotNo='VVQK273R010628' then 'VVQK273R012628'
when @LotNo='VVQK273R010629' then 'VVQK273R012629'
-- ... 7 dòng
-- SAU ĐÓ LẶP LẠI CHÍNH XÁC 7 DÒNG NÀY (dòng 737-743)
WHEN @LotNo='VVQK273R010628' then 'VVQK273R012628'
WHEN @LotNo='VVQK273R010629' then 'VVQK273R012629'
```
**Vấn đề:** 7 entries bị duplicate — 2 người sửa khác nhau thêm cùng dữ liệu.

---

### Bug 5: User whitelist cân nặng quá rộng — B523 (Severity: Medium)

**Vị trí:** `usp_Vietnam_GetBoxIDForLotNo_VVT`, dòng 540
```sql
if(@pProcessUserID in (
    'vvt_worker','vvtworker','huyen','mrchien','mrdiep','trantrung',
    'msphuong','phuongnt','dangchinh','nguyennha','nguyentha',
    'anhduy157','dinhmanh','vvtworker_bg','hoangxuan','worker_hn',
    'ngocanh','HaiTrieu'
)) set @lotweight = 1;
```
**Vấn đề:** 18 user được bypass check cân nặng. Bao gồm cả `vvt_worker` (tài khoản chung) → nghĩa là **hầu hết mọi người đều bypass**.
**Rủi ro:** Mục đích chặn "chưa cân nặng" bị vô hiệu hóa trên thực tế.

---

### Bug 6: Exception lot tăng không kiểm soát — B523 (Severity: Low)

**Vị trí:** `usp_Vietnam_GetBoxIDForLotNo_VVT`
- Danh sách tắt VJ: **70+ lot** (dòng 351-419)
- Danh sách bật VJ: **8 lot** (dòng 445-454)
- Danh sách đổi lot number: **100+ WHEN CASE** (dòng 624-763)
- Danh sách ngoại lệ ext_partno: **33 lot** (dòng 296-331)

**Tổng:** ~200+ lot ngoại lệ hardcode. SP sẽ ngày càng chậm.

---

## 4. 📋 CHECKLIST KHI THÊM MODEL MỚI (Dựa trên code archaeology)

Khi thêm model mới vào hệ thống, phải sửa **ít nhất 3 CTE** trong `usp_Vietnam_RawMaterialInputHist_uid`:

| # | CTE | Mục đích | Ví dụ thêm |
|---|-----|---------|-----------|
| 1 | `Termi1` (Terminal) | Mapping mã Tancha → Model | `select 'GBHB00-042' as Terminal, 'MODEL_MỚI' as model, 'SIZE' as size` |
| 2 | `eleclyte1` (Electrolyte) | Mapping mã dung dịch → Model | `select 'GBCP00-004' as electrolyte, 'MODEL_MỚI' as model, 'SIZE' as size` |
| 3 | `Sleev1` (Sleeve/Vỏ) | Mapping mã vỏ nhôm → Model | `select 'GCMDPT-XXX' as Sleeving, 'MODEL_MỚI' as model, 'SIZE' as size` |

Ngoài ra, trong `usp_Vietnam_GetBoxIDForLotNo_VVT`:
| 4 | `@ext_partno` | Đuôi PartNo cho tem | Thêm WHEN CASE nếu model có đuôi đặc biệt (-L, -I, -H...) |
| 5 | `STB_Vietnam_PackingPrinting` | Cho phép in VJ? | INSERT vào bảng nếu model cần in prefix VJ |

---

## 5. 🔧 "SỔ TAY PHIÊN DỊCH" COMMENT TIỀN NHIỆM

### Từ điển người (trong comment SP)

| Tên trong comment | Vai trò | Ghi chú |
|-------------------|---------|---------|
| Mr.Tung | Dev gốc Vietnam SP | Tác giả `usp_Vietnam_RawMaterialInputHist_uid` (2021-06-15) |
| Jeon Gyeong Ho | Dev Awoo (Hàn Quốc) | Tác giả `usp_Vietnam_GetBoxIDForLotNo_VVT` (2018-08-17) |
| vanduc / ducnv | IT Admin hiện tại | Người sửa nhiều nhất (15+ mentions trong SP #1) |
| Mr.Duy / DinhManh | IT/Dev | Thêm mapping NVL, fix Tancha |
| Mr.Back / back Sơ | Trưởng kỹ thuật? | Yêu cầu thêm mapping Sleeve/model mới |
| Mr.Bach | Quản lý kỹ thuật? | Yêu cầu bổ sung data |
| Mr.Triều | QC/Audit | Chuẩn bị audit → thêm validation chặn NVL |
| Md.Diep / Mr.Diep | QC/SX BG | Yêu cầu bypass lot cụ thể |
| Mrs.Tran Lan | Kế hoạch? | Yêu cầu chuyển đổi lot number (VJ→VV) |
| Mr.Tinh | Dev | Fix B353→B523 lot conversion bug |
| Ms.Phuong / phuongnt | SX/Audit | Yêu cầu đổi ext_partno cho lot cụ thể |
| Mr.Trung | SX | Yêu cầu bỏ in VJ cho lot cụ thể |
| Mr.Long | SX BG | Yêu cầu sửa ext_partno model VPC |

### Từ điển comment (trong SP)

| Comment | Ý nghĩa |
|---------|---------|
| `-- update YYYY-MM-DD` | Ngày thêm dòng UNION ALL cho model mới |
| `--Mr.X add` | Mr.X tự thêm (không ai yêu cầu rõ ràng) |
| `--Mr.X request...` | Mr.X yêu cầu → dev khác thực hiện |
| `--vanduc edited by Mr.X START...END` | vanduc code, Mr.X review/yêu cầu |
| `--Duy remote` | Mr.Duy sửa remote (không ở nhà máy) |
| `--hela 1840` | Mapping cho dòng sản phẩm Hela size 1840 |
| `--tancha` | Mapping Tancha (Terminal component) |
| `--pass qua...` | Bypass validation cho item cụ thể |
| `--DinhManh update YYYY-MM-DD tancha` | DinhManh thêm Terminal mapping |
| `/*...*/` | Code cũ bị vô hiệu hóa, giữ để tham khảo |
| `--RAISERROR('fds',16,1)` | Debug marker đã bị tắt |

---

## 6. 📈 TIMELINE SỬA ĐỔI (Trích từ comment dates)

### usp_Vietnam_RawMaterialInputHist_uid
```
2021-06-15  Mr.Tung tạo SP gốc
2022-10-xx  Mr.Back yêu cầu thêm Sleeve 1359
2022-11-10  Mr.Back bổ sung Sleeve 1359
2023-07-31  Md.Diep request bypass lot VVNU013R060614
2023-12-21  Duy thêm Sleeve cho Huyen
2025-01-13  Mr.Duy check Hà Nam factory
2025-05-13  Thêm Electrolyte VEC2R7505QG (1020)
2025-05-17  Thêm Electrolyte WEC2R7335QG (0820)
2025-06-02  Thêm Electrolyte VEC3R0505QG (1020)
2025-06-09  Thêm Sleeve WEC3R0335QG (0820)
2025-06-17  Thêm Electrolyte WEC3R0205QA (0816)
2025-07-26  Thêm Electrolyte VEP3R0367QG (3562)
2025-08-01  Thêm Electrolyte VEC3R0105QG (0813)
2025-09-22  DinhManh thêm Terminal + Electrolyte
2026-01-05  Thêm Terminal WEC3R0205QA (0816)
2026-01-13  Thêm Electrolyte GBEC00-011 cho 3 model 35105, 3562, 2245
2026-01-15  Thêm Electrolyte GBEC00-011 cho 1840, 1346
2026-02-13  Thêm 5 Electrolyte GBEC00-011
2026-03-06  Thêm Sleeve VEL08203R8306G (0820)
2026-04-11  vanduc thêm Electrolyte 1346-40F
2026-04-25  Thêm Electrolyte WEC3R0256QG (1625)
2026-06-13  ducnv edited by Mr.Tran Tuyen — Sleeve 1030
2026-06-15  vanduc edited by Mr.DuongPham — Tăng NVARCHAR(200)→(1000)
```

### usp_Vietnam_GetBoxIDForLotNo_VVT
```
2018-08-17  Jeon Gyeong Ho (Awoo) tạo SP gốc
2021-03-27  Mr.Tung edit cho Vietnam VJ label
2022-01-12  Mr.Tung thêm WCI(17mm) module
2022-11-xx  Mr.Back thêm nhiều Sleeve mapping
2023-02-13  Mr.Tung auto lấy đuôi PartNo từ MaterialName
2024-12-10  Thêm 10 lot tắt VJ
2025-04-14  DinhManh sửa theo Ms.Phuong
2025-04-16  DinhManh sửa theo Mr.Long (VPC 1335)
2025-05-05  Thêm Module lot MVVPM256R015508
2025-06-18  DinhManh remove VJ cho VPC 1335
2025-06-20  Thêm ext_partno OT-L(L&G) cho 3 module lot
2026-05-28  vanduc edited by Mrs.Tran Lan (chuyển đổi 12 lot VJ→VV)
2026-06-05  vanduc edited by Mrs.Tran Lan (thêm 1 lot)
2026-06-18  vanduc edited by Mr.Tinh — Fix B353→B523 VJ/VV prefix bug
```

---

## 7. 🆕 PHÂN TÍCH SP ĐÓNG GÓI: `usp_DoProcessProdPackingByOne_VNT` (319 mentions)

**Tác giả:** Jeon Gyeong Ho (Awoo, 2018-08-29) | **Size:** 11K chars | **Màn hình:** B520

### Chức năng chính
Tạo BoxID (PackingID) cho 1 lot → ghi vào `STB_ProdRouteHist` thông qua `usp_DoProcessTerminalData`.

### Bugs & Edit Patterns phát hiện

**Bug 7: Hardcode MaterialCode cho BG2 — B520 (Severity: Medium)**
```sql
-- Ha add 10/08/2024 (dòng 125-162)
if(@MaterialCot in ('LIVT38-009','VIVT38-018','VIVT38-007',
   'LIVT38-018','LIVT38-026','LIVT38-007'))
begin
    -- Lọc bỏ route V-34_BG, V-29_BG, V-30_BG khi lấy previous route
    POR.Routecode not in ('V-34_BG','V-29_BG','V-30_BG')
end
```
**Ý nghĩa:** 6 MaterialCode được hardcode riêng cho BG2. Khi thêm model BG2 mới → phải thêm vào danh sách này, nếu quên → lỗi gộp box.

**Bug 8: Chặn OQC chỉ cho Vietnamese language — B520 (Severity: Low)**
```sql
-- dòng 214
IF @LotDecisionResult <> 'Pass' and @Barcode not like 'MV%'
   and (upper(@ProcessLanguage)='VIETNAMESE') BEGIN
    -- Chỉ chặn khi language = VIETNAMESE
```
**Ý nghĩa:** Check OQC Pass chỉ apply cho user đặt ngôn ngữ Vietnamese. User Hàn (`ProcessLanguage = 'KOREAN'`) bypass được check này. Đây có thể là **cố ý** (để HQ debug) hoặc **bug thiếu sót**.

**Bug 9: LIKE thay vì = cho RouteCode — B520 (Severity: Low)**
```sql
-- dòng 174
PRH.RouteCode like '%'+@BefRouteCode+'%'
-- Comment: "chỉ khi nào lot từ bắc giang chuyển sang bắc ninh..."
```
**Ý nghĩa:** Dùng `LIKE '%V-28%'` thay vì `= 'V-28'` → có thể match sai route. Fix tạm cho lot BG→BN nhưng gây side effect.

**Edit pattern: `--Mr.Duy change` (dòng 317)**
```sql
LEFT(CONVERT(VARCHAR(10),CAST(@InProdQty AS INT)) + REPLICATE(' ',10),10) --Mr.Duy change
-- TRƯỚC: CONVERT(VARCHAR(10),@InProdQty) → in ra số thập phân (VD: 100.00000)
-- SAU: CAST AS INT → in ra số nguyên (VD: 100)
```

---

## 8. 🆕 PHÂN TÍCH SP SCAN BARCODE: `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` (299 mentions)

**Tác giả:** Jeon Gyeong Ho (Awoo, 2018-09-07) | **Size:** 22K chars | **Màn hình:** B530

### Chức năng chính
Xử lý hoàn thành công đoạn sản xuất: tính số lượng → trừ NG → ghi thực tích công đoạn tiếp.

### MR.TRIỀU VALIDATION LAYER (Code archaeology quan trọng)

**Phát hiện:** Mr.Triều (QC/Audit) đã thêm **5 lớp validation mới** cho VVT_F4 (BG2) và VVT_F3 (Hà Nam):

| # | Check | WorkCenter | Route | Exec SP |
|---|-------|-----------|-------|---------|
| 1 | Check nhập mã điện cực ± | VVT_F1/F2 | V-22, V-22_BG | `usp_CheckInputElectrodeInputForCodeProduct` |
| 2 | Check Pass/Fail trước hoàn thành | VVT_F4 | All | `usp_CancelCompleteRouteForBG2WithConditionPassOrFail` |
| 3 | Check Fail → chặn hoàn thành | VVT_F4 | All | `usp_HandleCancelOPInputProcess` |
| 4 | Check NVL đã bắn đủ | VVT_F4 | All | `usp_ChecRawMaterialWhenFinishProd` |
| 5 | Check sửa chữa repair xong | VVT_F4 | Has defect | Direct query `STB_DefectRepairInfo` |
| 6 | Check PQC nhập NG | VVT_F3 | VE01,VE03,VE04,VE08 | Direct query `STB_DefectRepairInfo` |
| 7 | Check NVL cho Lắp Cao Su/Curling | VVT_F1/F2 | V-23, V-24 | `usp_CheckInputRawMaterialCodeForProduct` |
| 8 | Check NVL cho HN VE06 | VVT_F3 | VE06 | `usp_CheckInputRawMaterialCodeForProduct` |

> 💡 **Kết luận:** Mr.Triều là "guardian" — người thêm hầu hết validation gates. Khi user báo lỗi "không chốt được công đoạn" → **check 8 validation layer trên**.

**Bug 10: MEA Aging check trừ sai timezone — B530 (Severity: Medium)**
```sql
-- dòng 655
IF DATEDIFF(hour, @PrevProdDateTime, DATEADD(hour, -3, GETDATE())) < 12 BEGIN
-- Trừ 3 giờ cho timezone KR→VN, nhưng hardcode = nếu đổi timezone sẽ sai
```

**Bug 11: VVT_F4 NVL check bị comment out — B530 (Severity: Info)**
```sql
-- dòng 697-700 (by Jackaroe 2026.05.10)
--IF @RawMaterialListCnt <> @RawMaterialInputCnt BEGIN
--    EXEC usp_RaiseLocalizedError @pProcessLanguage,'원자재 투입 입력이 완료되지 않았습니다.'
--    RETURN
--END
```
**Ý nghĩa:** Check NVL cho BG2 đã được code nhưng **bị TẮT** (comment out). Có thể đang test hoặc chờ phê duyệt.

**Bug 12: 20-phút chặn batch scan — Electrode only (Severity: Info)**
```sql
-- dòng 277 — BUG TIỀM ẨN
IF @CompanyCode = 'VNT' AND @SIExtInt01 = Null  -- ← BUG: nên dùng IS NULL
```
**Vấn đề:** `@SIExtInt01 = Null` LUÔN FALSE trong SQL Server. Nên viết `@SIExtInt01 IS NULL`. Kết quả: **logic chặn 20 phút KHÔNG BAO GIỜ chạy cho VVT** (VVT CompanyCode = 'VVT', not 'VNT').

---

## 9. 📊 TOP 40 SP THEO TẦN SUẤT NHẮC ĐẾN (Conversations + KB)

| # | SP Name | Mentions | Chức năng | KB chính |
|---|---------|----------|-----------|---------|
| 1 | `usp_Vietnam_RawMaterialInputHist_uid` | **657** | Nhập NVL B597 | KB_37 §2-6 |
| 2 | `usp_DoProcessProdPackingByOne_VNT` | **319** | Tạo BoxID B520 | KB_37 §7 |
| 3 | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | **299** | Hoàn thành CĐ B530 | KB_37 §8 |
| 4 | `usp_Vietnam_GetBoxIDForLotNo_VVT` | **298** | Load box B523 | KB_37 §2-6 |
| 5 | `usp_DoChangeMaterialDocLotInfo` | **291** | Thay đổi lot NVL | KB_02 |
| 6 | `usp_MaterialQcSampleResult_get` | **255** | QC lấy mẫu | KB_05 |
| 7 | `usp_QcInspectionGroup_HY_get` | **234** | QC HY inspection | KB_05, KB_25 |
| 8 | `usp_Vietnam_DoProcessProdPacking_VVT` | **220** | Core gộp box B523 | KB_04, KB_30 |
| 9 | `usp_DoProcessProdRouteHist` | **213** | Core routing | KB_03 |
| 10 | `usp_QcInspectionItem_iud` | **202** | QC item CRUD | KB_05 |
| 11 | `usp_RawMaterialInputHist_get` | **196** | Lấy data NVL | KB_02 |
| 12 | `usp_QcInspectionItem_HY_iud` | **190** | QC HY CRUD | KB_05, KB_25 |
| 13 | `usp_vvt_MaterialLotInfo_get` | **188** | Lấy lot info | KB_02 |
| 14 | `usp_ProductionOrderInfo_HY_get` | **174** | PO info HY | KB_25 |
| 15 | `usp_QcInspectionGroup_get` | **166** | QC group get | KB_05 |
| 16 | `usp_DoFinishCommInspDoc_VNT` | **156** | Kết thúc QC | KB_05 |
| 17 | `usp_Vietnam_MaterialFOQcDetail_get` | **147** | FOQC detail | KB_05 |
| 18 | `usp_GetProdRouteHistForBarcode_VNT` | **143** | Lấy history route | KB_03 |
| 19 | `usp_Vietnam_GetProdPackingForBarcode_VVT` | **133** | Lấy packing info | KB_04 |
| 20 | `usp_DoFinishCommInspDoc` | **128** | Kết thúc QC (gốc) | KB_05 |

---

## 10. 💡 KHUYẾN NGHỊ CHO TƯƠNG LAI

### 10.1 Ngắn hạn (Làm ngay)
1. **Xóa duplicate entries** trong `usp_Vietnam_GetBoxIDForLotNo_VVT` (7 dòng lặp)
2. **Review whitelist cân nặng** — cân nhắc bỏ `vvt_worker` khỏi bypass list
3. **Kiểm tra VVT_F4** có cần validation NVL Terminal/Electrolyte/Sleeve không

### 10.2 Trung hạn (1-3 tháng)
1. **Tạo bảng `STB_VVT_NVLMapping`** thay thế 3 CTE hardcode (Terminal/Electrolyte/Sleeve)
2. **Tạo bảng `STB_VVT_LotException`** thay thế danh sách `NOT IN` và `WHEN CASE`
3. **Tạo UI admin** để thêm mapping NVL mà không cần ALTER SP
4. **Fix Bug 12:** `@SIExtInt01 = Null` → `@SIExtInt01 IS NULL`

### 10.3 Dài hạn
1. **Tách SP** `usp_Vietnam_RawMaterialInputHist_uid` thành nhiều sub-SP nhỏ hơn
2. **Migrate** exception lot list vào bảng config
3. **Audit** toàn bộ 200+ exception lot xem còn cần thiết không (nhiều lot đã xuất hàng từ lâu)

---

*Cập nhật: 2026-06-18 | Code archaeology từ 4 SP top mentions bởi Antigravity AI.*
*Nguồn: Đọc trực tiếp source code SP từ database SmartFactoryV2.*
*SP đã export tại: `SP_EXPORTS/` folder để tham khảo offline.*
