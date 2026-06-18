## 9. 🔬 QC Flow Đầy Đủ — IQC → PQC → OQC → Bending/Cutting

### 9.1 IQC (Incoming Quality Control — Kiểm tra NVL đầu vào)

```
C121 (Nhóm hạng mục kiểm tra)
    → Thêm nhóm kiểm tra IQC → Tích "Sử dụng" → Lưu
    → Thêm hạng mục trong từng nhóm
    ↓
C122 (Chỉ định hạng mục cho từng NVL)
    → Tìm NVL → Ấn "Chọn trong nhóm/Hạng mục" → Tick → OK → Lưu
    ↓
C220 (Kiểm tra NVL đầu vào)
    → Khi NVL về kho → IQC vào C220 để nhập kết quả kiểm tra
```

```sql
-- Kiểm tra hạng mục IQC của NVL
SELECT cit.CommInspTypeName, ci.CommInspItemName, ci.CommInspUpperLimit, ci.CommInspLowerLimit
FROM STB_CommInspItem ci
JOIN STB_CommInspTypeInfo cit ON cit.CommInspTypeCode = ci.CommInspTypeCode
JOIN STB_CommInspIndividualSpec cs ON cs.CommInspItemCode = ci.CommInspItemCode
WHERE cs.MaterialCode = 'mã_nvl'

-- Xem lịch sử kiểm tra IQC theo NVL
SELECT * FROM STB_CommInspDocHistory
WHERE MaterialCode = 'mã_nvl' AND CreateDateTime >= '2026-04-01'
```

---

### 9.2 PQC (Process Quality Control — Kiểm tra trong quá trình SX)

```
C141 (Thiết lập chung PQC cho tất cả model)
    → Hạng mục, loại input (1=số, 2=checkbox)
    ↓
C143 (Hạng mục kiểm tra riêng theo từng model)
    → Mapping MaterialCode → hạng mục cụ thể
    ↓
C443 (Kiểm tra công đoạn ngoài cell line)
    → Scan Barcode → Nhập giá trị → Hoàn thành
    → SP: usp_GetCommInspection_HistoryForBarcode_Vietnam
    ↓
C430 (Lịch sử kiểm tra công đoạn Cell Line)
C321 (Sửa chữa lỗi — Reliability Assy)
```

**C443 — SP đầy đủ:**

| SP | Loại | Chức năng |
|----|------|-----------|
| `usp_GetCommInspection_HistoryForBarcode_Vietnam` | Search | Lấy lịch sử + template hạng mục |
| `usp_DoAddCommInspMeasureHistForBarcode` | Execute | Thêm kết quả đo từng hạng mục |
| `usp_DoFinishCommInspDoc` | Execute | Hoàn thành tài liệu kiểm tra |
| `usp_DoFinishCommInspDoc_VNT` | Execute | Hoàn thành tài liệu kiểm tra VNT |

```sql
-- Sửa hạng mục kiểm tra tại C443 (xóa CommInspDoc cũ rồi tạo lại)
-- Bước 1: Tìm CommInspDocNo theo Barcode
SELECT * FROM STB_CommInspDocHistory
WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVPP163R072732')

-- Bước 2: Xóa để tạo lại
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = '...'
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = '...'
```

---

### 9.3 OQC (Outgoing Quality Control — Kiểm tra thành phẩm)

```
C121 (Nhóm hạng mục — dùng chung với IQC)
    ↓
C151 (Hạng mục kiểm tra OQC theo từng sản phẩm)
    → Tìm MaterialCode → Chọn trong nhóm → Tick → OK → Lưu
    → Nếu Model không có trong popup: Vào A410 → Thiết lập OQCType/InspectionLevel → Tắt C151 và vào lại
    ↓
C512 (Quản lý Lot kiểm tra sản phẩm)
    → Dán Barcode → Tìm kiếm → Tạo Lot
    → TH1 không thấy: Đã tạo Lot rồi → sang C530
    → TH2 không thấy: Chưa thiết lập hạng mục tại A410
    → TH3 (HN): Mã test tháng 12 bắt đầu Route VE02 → không hiện (thiết kế hệ thống)
    ↓
C530 (Kiểm tra sản phẩm theo từng mẫu)
    → Nhập Barcode + Mã NV → Tìm kiếm
    → Chọn hạng mục → Nhập giá trị bên phải → Save bên phải
    → Chọn Pass ở bên trái → Save bên trái → Đánh giá OK → Lưu
    → Nếu thêm/sửa hạng mục ở C151 → Ấn "Tổng hợp hạng mục" để reset
    ↓
C540 (Lịch sử kiểm tra từ C530)
    ↓
C510 → C546 → C541 (Kiểm tra ESR xuất kho)
```

```sql
-- Model đã config OQC chưa
SELECT ModelCode, OqcType, OqcInspectionRuleType, InspectionType, InspectionLevel
FROM STB_ModelBasicInfo WHERE ModelCode = 'mã_model'

-- Nếu NULL → update:
UPDATE STB_ModelBasicInfo
SET OqcType = 'MANUAL', OqcInspectionRuleType = 'BY_MODEL',
    InspectionType = 'SAMPLE', InspectionLevel = 'SAMPLE'
WHERE ModelCode = 'mã_model'

-- Xóa CommInspDoc bị sai → tạo lại từ C512
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = '...'
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = '...'

-- Sửa kết quả OQC
UPDATE STB_CommInspDocHistory
SET CommInspResult = 'PASS', FinishDateTime = GETDATE()
WHERE CommInspDocNo = '...'
```

---

### 9.4 Bending/Cutting QC (C561~C564)

```
C561 (Hạng mục kiểm tra Bending/Cutting theo từng model)
    → Tìm MaterialCode → Chọn nhóm → Tick → OK → Lưu
    ↓
C562 (Tạo Lot kiểm tra Bending/Cutting)
    → Dán Barcode → Tìm kiếm → Tạo Lot
    ↓
C563 (Kiểm tra Lot Bending/Cutting)
    → Giống C530: Nhập barcode → Chọn hạng mục → Nhập giá trị → Save → Đánh giá OK
    → Nếu sửa C561 → Ấn "Tổng hợp hạng mục" để reset giá trị
    ↓
C564 (Lịch sử kiểm tra Bending/Cutting)
```

---

### 9.5 C321 — PQC Reliability Assy (Sửa Chữa Lỗi Cell Line)

**Chức năng:** PQC quản lý hàng phát sinh lỗi cần sửa chữa trong quá trình sản xuất.

| SP | Chức năng |
|----|-----------|
| `usp_Vietnam_GetDefectRepairInfo_ForRepair` | Lấy thông tin lỗi cần sửa chữa |
| `usp_GetDefectRepairDetailInfo_ForRepair` | Lấy chi tiết nguyên nhân lỗi |
| `usp_GetDefectRepairPartInfo` | Lấy thông tin vật tư thay thế |
| `usp_DoProcessLossForBarcode_VNT` | Xử lý tổn thất — ghi nhận lỗi |

```sql
-- Kiểm tra lỗi theo barcode
SELECT * FROM STB_DefectRepairInfo WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VV...'
)
```

> ⚠️ SQL sửa DefectQty và ProdQty công đoạn sau → xem [KB_03 Mục 5.8](KB_03_SAN_XUAT.md#58-sửa-số-lượng-ng-defectqty-màn-b791) để tránh trùng lặp.

---

### 9.6 C546 (FOQC) — OCV/ESR chỉ hiển thị 20ea thay vì 50ea

**Triệu chứng:** Trên tab C546 (FOQC_시료별제품검사), hạng mục OCV (`FOQC_V01_07`) chỉ hiển thị tối đa 20 dòng đo thực tế từ máy (hoặc 0 dòng nếu chưa đo) thay vì hiển thị đủ 50 dòng theo tiêu chuẩn mẫu (SampleQty=50). 

**Nguyên nhân gốc (Root Causes):**
1. **Lỗi trong SP lấy kết quả đo (`usp_MaterialQcSampleResult_get`):** Phiên bản cũ không hỗ trợ pattern `FOQC_V01_07` (chỉ hỗ trợ `PQC_V01_07`) nên bị nhảy sang logic mặc định `SampleQty=20` và gán trùng giá trị OCV. (Đã sửa).
2. **Thiếu Block OCV trong SP khởi tạo dòng trống (`usp_Vietnam_MaterialFOQcDetail_get`):** 
   - Khi QC mở màn hình C546, hệ thống gọi SP `usp_Vietnam_MaterialFOQcDetail_get` để khởi tạo các dòng mẫu trống trong bảng `STB_MaterialQcSampleResult` cho đủ số lượng `SampleQty=50`.
   - Trong SP này, lập trình viên đã viết các khối loop `WHILE` để tạo dòng trống cho `DetailNo = 19` (20ea), `DetailNo = 3` (ESR - 50ea), và `DetailNo = 4` (10ea), nhưng **hoàn toàn bỏ quên hạng mục OCV (DetailNo = 2)**!
   - Vì không được khởi tạo dòng trống, lưới OCV trên giao diện chỉ có thể hiển thị tối đa số dòng thực tế đo được từ máy (20 dòng) mà không thể lấp đầy đủ 50 dòng.

**Giải pháp sửa đổi:**
1. **Deploy lại Stored Procedure `usp_Vietnam_MaterialFOQcDetail_get`:**
   - Thêm khối loop `WHILE` cho `DetailNo = 2` để tự động tạo đủ 50 dòng trống cho OCV.
   - Nội dung block thêm mới:
     ```sql
     -- OCV Block (DetailNo = 2)
     set @MaterialQcSampleNo1  = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult WITH(NOLOCK) where MaterialQcDetailNo=2 and MaterialQcNo=@FoqcMaterialQcNo) + 1
     set @sampleqty  = (select sampleqty from STB_MaterialQcDetail where MaterialQcDetailNo=2 and MaterialQcNo=@FoqcMaterialQcNo)

     WHILE @MaterialQcSampleNo1 <= @sampleqty
     BEGIN						
         select @tung= @tung +'.3'	
         insert into STB_MaterialQcSampleResult (MaterialQcNo, MaterialQcDetailNo, MaterialQcSampleNo, SampleSerialNo, TestUserID, TestDateTime, TestValue, TestResult, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
         values (@FoqcMaterialQcNo, 2, (select isnull(MAX(MaterialQcSampleNo),0) from STB_MaterialQcSampleResult WITH(NOLOCK) where MaterialQcDetailNo=2 and MaterialQcNo=@FoqcMaterialQcNo) + 1 , NULL, NULL, NULL, NULL, NULL, getdate(), @pProcessUserID, NULL, NULL)
         SELECT @MaterialQcSampleNo1 = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult WITH(NOLOCK) where MaterialQcDetailNo=2 and MaterialQcNo=@FoqcMaterialQcNo) + 1
     END
     ```

**Debug & Kiểm tra dữ liệu (SSMS):**
```sql
-- 1. Kiểm tra SampleQty và Pattern hiện tại của Lot FOQC
SELECT MaterialQcNo, MaterialQcDetailNo, QcInspectionItemCode, SampleQty, PassedSampleQty, DecisionResult
FROM STB_MaterialQcDetail WHERE MaterialQcNo = 'F' + 'Mã_Barcode'

-- 2. Kiểm tra số dòng thực tế đã ghi nhận trong bảng SampleResult
SELECT MaterialQcDetailNo, COUNT(*) AS Total,
       SUM(CASE WHEN TestValue IS NOT NULL THEN 1 ELSE 0 END) AS WithValue,
       SUM(CASE WHEN TestValue IS NULL THEN 1 ELSE 0 END) AS EmptyRows
FROM STB_MaterialQcSampleResult 
WHERE MaterialQcNo = 'F' + 'Mã_Barcode'
GROUP BY MaterialQcDetailNo

-- 3. Kiểm tra dữ liệu thô từ máy đo trong Monitor
SELECT ID, lotno, value AS ESR, valueocv AS OCV, UploadToMes, UploadOCVToMess
FROM Stb_ESRValueMonitor WHERE lotno = 'Mã_Barcode' ORDER BY ID
```

**Fix data khi bị lệch số dòng:**
*Xem chi tiết các bước chạy rollback và reset dữ liệu tại file script [fix_c546_ocv_lots.sql](../sql/scripts/fix_c546_ocv_lots.sql)*

**Các Stored Procedure liên quan (C546):**

| SP | Loại | Chức năng |
|----|------|-----------|
| `usp_GetMaterialOQcInfo` | Search | Lấy thông tin Lot QC |
| `usp_MaterialQcDetail_get` | Search | Lấy danh sách hạng mục kiểm tra |
| `usp_MaterialQcSampleResult_get` | Search | **Lấy giá trị đo từ Stb_ESRValueMonitor** |
| `usp_MaterialQcSampleResult_iud` | Execute | Lưu giá trị đo thủ công |
| `usp_DoMakeMaterialQcSampleResult` | Execute | Tạo sample result |
| `usp_DoUpdateMaterialQcInfo_Success` | Execute | Đánh giá OK |
| `usp_DoUpdateMaterialQcInfo_Fail` | Execute | Đánh giá NG |

**Bảng DB liên quan:**

| Bảng | Vai trò |
|------|---------|
| `STB_MaterialQcInfo` | Lot QC header (chứa CompanyCode) |
| `STB_MaterialQcDetail` | Hạng mục kiểm tra (SampleQty, LSL, USL, Pattern) |
| `STB_MaterialQcSampleResult` | Kết quả đo từng mẫu (TestValue) |
| `Stb_ESRValueMonitor` | Dữ liệu nguồn từ máy đo ESR/OCV |
| `STB_LotChangeMaterialHistory` | Lịch sử đổi barcode (SP tra ngược OldBarcode) |

---

### 9.7 QC Nâng Cao — Quy trình ESR, Vision, X-Ray & Aging

#### 9.7.1 Giám sát chất lượng điện trở ESR (ESR Inspection)
Hệ thống MES ghi nhận dữ liệu đo kiểm ESR tự động và thủ công qua các bảng và Stored Procedure:
* **Bảng dữ liệu:** `STB_VVT_ESRDATA` (Lưu thông số đo kiểm thực tế từ máy).
* **Stored Procedure:** `usp_VVT_ESRdata_uid`
  * Chức năng: Lưu thủ công hoặc tự động kết quả kiểm tra điện trở ESR bao gồm: `@pinspectvalue` (ESR đo được), `@pinspectvalue1`, `@pinspectvalue2`, `@pinspectime` (thời gian đo), `@plinecode` (mã line), `@pmaterialcode` (mã model).
  * Quy tắc: Nếu giá trị đo hoặc mã line truyền vào bị rỗng, SP sẽ tự động dừng. Nếu mã máy bị trống, hệ thống gán mặc định bằng mã số Line.

#### 9.7.2 Quy trình kiểm tra ngoại quan bằng 비전 (Vision Inspection)
Dây chuyền sản xuất sử dụng 3 nhóm hệ thống 비전 (Vision Camera) tương ứng với 3 công đoạn kiểm tra ngoại quan khác nhau:
* **Các bảng dữ liệu:**
  1. `STB_VisionGroup1InspectionInfo`: Kiểm tra cuốn điện cực (Winding).
  2. `STB_VisionGroup2InspectionInfo`: Kiểm tra dập cao su & lắp tancha (Rubber / Riveting).
  3. `STB_VisionGroup3InspectionInfo`: Kiểm tra bọc vỏ nhựa & định hình miệng (Sleeving / Curling).
* **Stored Procedure:** `usp_VisionGroupInspectionInfo_get`
  * Chức năng: Truy vấn gộp (`UNION ALL`) dữ liệu hình ảnh và lỗi phát hiện từ cả 3 nhóm Vision trên.
  * Cấu trúc dữ liệu ghi nhận: Mã thiết bị (`MachineID`), mã Lot (`LotNo`), barcode chi tiết (`Barcode`), số thứ tự Camera (`CameraNo`), loại lỗi ngoại quan (`DefectType`), tọa độ lỗi (`XAxis`, `YAxis`), kích thước lỗi (`LongSize`, `ShortSize`, `Size`), diện tích (`Area`), độ dày (`Thickness`), khoảng cách chân (`Distance`), thuật toán phát hiện (`AlgType`), và dữ liệu nhị phân của hình ảnh chụp lỗi (`Image`).

#### 9.7.3 Đo kiểm X-Ray & XRF (X-Ray & XRF Inspection)
Công đoạn kiểm tra cấu trúc bên trong cuộn cell (X-Ray) và đo độ dày lớp mạ/thành phần nguyên tố bằng quang phổ huỳnh quang tia X (XRF):
* **Kiểm tra chụp X-Ray:**
  * Bảng DB: `STB_XRayImageUploadHist` (Lưu lịch sử upload) liên kết với `SmartFramework_File.dbo.STB_AttachedFileMaster` (Lưu trữ file vật lý — ⚠️ bảng này nằm trong DB `SmartFramework_File`, không nằm trong `SmartFactoryV2`).
  * Stored Procedure: `usp_XRayImageUploadHist_get`
    * Chức năng: Lấy thông tin lịch sử chụp X-Ray của Barcode sản phẩm, trả về tên file hình ảnh (`FileName`), kích thước file (`FileSize`), và dữ liệu nhị phân file ảnh chụp cấu hình lõi (`FileData`).
* **Đo phổ XRF:**
  * Bảng DB: `STB_XRFInspectionInfo`
  * Stored Procedure: `usp_XRFInspectionInfo_get`
    * Chức năng: Lấy kết quả phân tích nguyên tố chi tiết của barcode, ghi nhận: detector (`Detector`), thời gian đo (`RunTime`), và 3 kết quả đo kiểm huỳnh quang tương ứng (`Result1`, `Result2`, `Result3`).

#### 9.7.4 Quy trình lão hóa & đo kiểm OCV sau Aging (Aging Sorting & OCV)
Sau khi hoàn thành công đoạn lão hóa nhiệt (Aging), sản phẩm được đo kiểm điện áp hở mạch (OCV) và phân loại chất lượng:
* **Các bảng dữ liệu:**
  * `STB_MaterialQcInfo` & `STB_MaterialQcDetail` (Chứa thông tin cấu hình lô kiểm định).
  * `STB_QC_LOTNO_MODULE` (Bảng lưu kết quả kiểm định cho hàng Module).
  * `STB_MaterialQcSampleResult` (Lưu giá trị OCV/ESR chi tiết từng mẫu).
* **Stored Procedure:**
  1. `usp_VVT_AgingInspectionHist_vvt_get`
     * Chức năng: Tìm kiếm lịch sử kiểm đo OCV/ESR sau Aging (với mã tài liệu `InspectionDocType = 'AOQC'`).
     * Quy tắc định danh: Hệ thống tự động tạo mã QC dạng `A` + `Barcode` (Ví dụ: Barcode `VVLR133R010603` sẽ tương ứng với `MaterialQcNo = 'AVVLR133R010603'`).
     * SP hỗ trợ tự động truy vết lịch sử đổi mã barcode cũ/mới qua bảng `STB_LotChangeMaterialHistory`.
  2. `usp_Vietnam_GetMaterialAgingInfo`
     * Chức năng: Phục vụ màn hình xuất xưởng và kiểm định FOQC. Thực hiện gộp dữ liệu giữa hàng Cell (thông tin OQC Pass trong `STB_MaterialQcInfo`) và hàng Module (thông tin Pass trong `STB_QC_LOTNO_MODULE`).

---


