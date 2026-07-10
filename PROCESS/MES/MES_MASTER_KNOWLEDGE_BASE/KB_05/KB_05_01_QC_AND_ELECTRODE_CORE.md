# KB_05 � Ki?m tra Ch?t lu?ng (QC) & �i?n c?c

> **M�n h�nh:** B597, C443, C512, C486, C530, C546, B552, B270, B540, C121-C564, F743-F748
> **B?ng ch�nh:** `STB_MaterialQcInfo` (35 cols), `STB_MaterialQcInspectionItem` (USL/LSL), `STB_CommInspDocHistory`
> **?? Keywords:** QC, ch?t lu?ng, ki?m tra, IQC, PQC, OQC, FOQC, electrode, di?n c?c, slitting, aging, h?ng m?c, spec, USL, LSL, Pass, Fail, Hold, m?u, sample
> ? [V? INDEX](../KB_INDEX.md)

---


## 7. Quy Trình Kiểm Kiểm Chất Lượng & Điện Cực (Core Processes Only)

> [!NOTE]
> **Khắc phục sự cố & Lỗi màn hình QC / Điện cực (B597, C443, C512, C486, C530, C546, B552, F743-F748, etc.):**
> Toàn bộ danh sách lỗi chi tiết, nguyên nhân gốc, các kịch bản sự cố khẩn cấp và SQL hotfixes đã được chuyển sang tài liệu chuyên biệt:
> 👉 [KB_05_02_SCREEN_BUGS_QC.md](KB_05_02_SCREEN_BUGS_QC.md) để tránh trùng lặp thông tin và dễ dàng tra cứu.

---
### 8.7 Tổng Quan Quy Trình Sản Xuất & Kiểm Tra Chất Lượng Điện Cực (Electrode Flow)

Quy trình quản lý sản xuất và kiểm định chất lượng đối với công đoạn Điện cực được vận hành khép kín qua các bước sau:

#### [B310]/[B442]/[A230] — 1. Lập Kế Hoạch & In Tem Điện Cực (, , )
*   **Tạo PO (B310):** Bộ phận kế hoạch khởi tạo đơn đặt hàng sản xuất PO làm căn cứ chạy chuyền.
*   **Tạo Kế hoạch ngày (B442):** Dựa trên PO tháng đã duyệt, kế hoạch ngày được lập trên B442. Khi kế hoạch được xác nhận lưu, hệ thống sẽ tự động sinh mã Lot điện cực và bắt đầu cho phép in tem nhãn.
*   **Liên kết độ dày vật liệu (A230):** Màn hình B442 liên kết trực tiếp với dữ liệu độ dày khai báo tại màn hình **A230 (Thông tin vật liệu)**. Tại tab "Mã nguyên liệu", nếu mã vạch barcode tương ứng đã được cài đặt thông số độ dày hoặc người dùng điền độ dày bên A230, hệ thống sẽ tự động liên kết và điền thông số này vào cột độ dày của B442. Nếu chưa được cấu hình, OP buộc phải nhập thủ công bằng tay (thao tác này dễ gây sai sót và chậm trễ).


*   **Cấu hình in tem Electrode (A460 → STB_ModelLabelInfo):** Để in tem từ B442, model Electrode phải có record trong bảng `STB_ModelLabelInfo`. Nếu thiếu → lỗi **"Not found label type"** khi bấm LabelPrint.

    ```sql
    -- Kiểm tra: SELECT ModelCode, LabelType FROM STB_ModelLabelInfo WHERE ModelCode = 'MÃ_MODEL';
    -- Nếu thiếu → copy từ model cũ cùng loại. Xem KB_04 §6.20 cho SQL chi tiết.
    ```

    > **LabelType phổ biến cho Electrode:** `ElectLabel` (tem điện cực B442), `AssembleLabel` (tem SX B450/B540), `PartLabel` (tem vật tư F330), `BoxLabel2` (tem box đặc biệt).

*   **Checklist thêm model Electrode mới (CRF%):**
    1. A230 → `MaterialThickness` (VD: 120, 180, 200)
    2. A460 → `STB_ModelLabelInfo` (ElectLabel + các label type cần thiết)
    3. B442 → Tạo lot test → kiểm tra cột "Độ dày" + in tem

    > 🔗 Xem thêm: KB_04 §6.20, KB_14 §7.2

#### [B552] — 2. Vận Hành 4 Công Đoạn Điện Cực & Nhập Liệu trên
Quy trình sản xuất điện cực gồm 4 công đoạn chính và mỗi công đoạn tương ứng với một tab dữ liệu trên màn hình **B552**:
1.  **Mixing (Pha trộn):** 
    *   Sử dụng cấu hình cân điện cực thiết lập trên màn **B470** (Thẻ công đoạn do bên Kỹ thuật sản xuất - KTSP thiết lập và ban hành). 
    *   Hệ thống máy CMC sẽ thực hiện cân trộn theo công thức. Tab Mixing trên B552 sẽ tự động lấy dữ liệu từ hệ thống cân CMC sang. OP chỉ cần kiểm tra và nhập số lượng NG phát sinh (nếu có) lên hệ thống.
2.  **Coating (Phủ):** Tráng phủ hỗn hợp dung dịch điện cực lên foil. OP thực hiện nhập lượng phế NG phát sinh.
3.  **Rollpress (Ép):** Ép nén cuộn foil để đạt độ dày tiêu chuẩn và đảm bảo lớp phủ bám đều. OP nhập thông số NG.
4.  **Slitting (Cắt):** Cắt cuộn điện cực lớn thành các cuộn nhỏ theo kích thước spec yêu cầu để chuyển sang chuyền Cell lắp ráp. Tại tab Slitting trên B552, OP sẽ tiến hành tạo tem nhãn và in tem barcode dán lên từng cuộn điện cực sau khi cắt.

#### [B802] — 3. Báo Cáo & Đối Soát Điện Cực ()
*   **B802 (Tra cứu lịch sử sản xuất điện cực):** Tra cứu toàn bộ thông tin sản lượng, phế thải (NG), chi phí sản xuất, và chi phí phế phẩm.
*   **⚠️ Lưu ý lỗi thiếu công đoạn:** Một mã Lot điện cực bắt buộc phải đi qua đầy đủ cả 4 công đoạn (Mixing, Coating, Rollpress, Slitting). Nếu trên báo cáo B802 hiển thị thiếu bất kỳ công đoạn nào, nguyên nhân chắc chắn là do OP quên hoặc chưa nhập đầy đủ dữ liệu công đoạn đó tại màn hình **B552**. Khi tra cứu trên B802, OP click vào một mã Lot cụ thể để hiển thị chi tiết thông số từng công đoạn ở tab phía dưới.
*   **Quy tắc nhập cột số liệu:**
    *   Cột `Defect (KG)`: Do OP nhập thủ công số kg phế thải thực tế cân được.
    *   Cột `Số lượng OK`: Số lượng cuộn/mét điện cực đạt chất lượng được OP nhập vào.
    *   Cột `Số lượng NG`: Số lượng cuộn/mét điện cực lỗi được OP nhập vào. Các cột chỉ số chi phí và tỷ lệ lỗi còn lại sẽ do hệ thống tự động tính theo công thức.

#### [C460]/[C141]/[C143] — 4. Quy Trình Kiểm Tra Chất Lượng QC Điện Cực (, , )
*   Bên cạnh hệ thống cân CMC tự động, bộ phận QC thực hiện kiểm tra ngoại quan và đo đạc kích thước cơ lý của cuộn điện cực.
*   **C460 (Nhập kết quả kiểm tra QC):** Công nhân QC trực tiếp nhập các kết quả đo đạc kiểm tra cuộn điện cực tại đây.
*   **C141 & C143 (Thiết lập hạng mục kiểm tra):** Các hạng mục kiểm tra chung và spec dung sai riêng biệt cho từng model điện cực được định nghĩa trước tại màn hình **C141 (Hạng mục chung)** và **C143 (Spec theo Model)** để làm căn cứ cho C460 validate tự động.

---

### 8.8 Hỗ trợ lưu nhiều mã vạch nguyên vật liệu (Multi-barcode Appending) cho Điện cực và Vỏ Case

*   **Mô tả:** Hệ thống hỗ trợ bắn nối tiếp nhiều cuộn nguyên vật liệu khác nhau (ngăn cách bởi dấu `;`) trên cùng một Lot sản phẩm để tránh trường hợp cuộn cũ hết giữa chừng nhưng Lot chưa chạy xong.
*   **Chi tiết & Giải pháp:** Xem chi tiết về logic kiểm tra và lưu trong SP `usp_Vietnam_RawMaterialInputHist_uid`, cũng như cách gộp hiển thị trên lưới tại [../KB_03/KB_03_02_CELL_LINE.md#619-hỗ-trợ-lưu-nhiều-mã-vạch-nguyên-vật-liệu-multi-barcode-appending-cho-điện-cực-và-vỏ-case](../KB_03/KB_03_02_CELL_LINE.md#619-hỗ-trợ-lưu-nhiều-mã-vạch-nguyên-vật-liệu-multi-barcode-appending-cho-điện-cực-và-vỏ-case).

---

### 8.9 [A301] — 🔴 Lỗi Mất Sản Lượng Đầu Vào (Mixing Input = 0) BY/YP 120/180 1.5B

> **Phát hiện:** 2026-06-19 | **Ảnh hưởng:** ~1 tháng sản xuất (từ ~26/05/2026)

#### Triệu chứng:
*   Sản xuất gần 1 tháng nhưng trên MES **không có sản lượng đầu vào** (cột "Trọng lượng vật liệu 1/2" = 0).
*   **Có sản lượng đầu ra** (Coating output) → gây sai lệch kiểm kê.
*   Bảng `STB_ElectrodeMixStepInfo` có **0 records** cho các lot prefix `VVQO1812xxx`.
*   Bảng `STB_ElectrodeCoatingInfo` **CÓ records** (VD: E22=270kg, E25=420kg).

#### Models bị ảnh hưởng:

| Model | MaterialCode | Mức độ |
|-------|-------------|--------|
| BY 120 A301 1.5B (+) | `CREBL85L` | 🔴 100% thiếu |
| YP 120 A301 1.5B (-) | `CRFYL85-01` | 🔴 100% thiếu |
| YP 180 A301 1.5B (-) | `CRFYN85L-01` | 🔴 100% thiếu |
| YP 200 1.5B (+) | `CREYO85-03` | ⚠️ Gián đoạn |

#### Nguyên nhân đã loại trừ (DB + SP đều OK):
*   ✅ `STB_ElectrodeStep` — cấu hình bước cân **ĐẦY ĐỦ** (9 bước D/G/K/S) cho cả `CREBL85L` và `CRFYL85-01`.
*   ✅ `usp_DoCreateElectrodeMixStepInfo_electron` — SP ghi data không có validation chặn.
*   ✅ `usp_GetElectroMixPresentStep_vietnam` — trả về đúng bước hiện tại.
*   ✅ `usp_Vietnam_ElectrodeMixingConfig_get` — trả về 5 config giống model hoạt động bình thường.

#### Nguyên nhân gốc — Phần mềm cân NVL Mixing (electrode.weighing):
*   Ứng dụng Electron cài trên **máy CMC nhà máy Bắc Ninh** (KHÔNG phải app `4.8.Warehouse Weight` — đó là cân thành phẩm B523).
*   App cân mixing không gọi hoặc gọi thất bại SP `usp_DoCreateElectrodeMixStepInfo_electron`.

#### Query kiểm tra:
```sql
-- Kiểm tra Lot có mixing data không
SELECT SI.Barcode, SI.MaterialCode,
    CASE WHEN EXISTS (SELECT 1 FROM STB_ElectrodeMixStepInfo M WITH(NOLOCK)
        WHERE M.ElectrodeLotNumber = SI.Barcode) THEN 'YES' ELSE 'NO' END AS HasMixing,
    CASE WHEN EXISTS (SELECT 1 FROM STB_ElectrodeCoatingInfo C WITH(NOLOCK)
        WHERE C.ElectrodeLotNumber = SI.Barcode) THEN 'YES' ELSE 'NO' END AS HasCoating
FROM STB_SetInfo SI WITH(NOLOCK)
WHERE SI.MaterialCode IN ('CREBL85L', 'CRFYL85-01', 'CRFYN85L-01')
    AND SI.CreateDateTime >= '2026-05-20'
ORDER BY SI.CreateDateTime DESC
```

---



## 9. ?? QC Flow �?y �? � IQC ? PQC ? OQC ? Bending/Cutting

### 9.1 IQC (Incoming Quality Control � Ki?m tra NVL d?u v�o)

```
C121 (Nh�m h?ng m?c ki?m tra)
    ? Th�m nh�m ki?m tra IQC ? T�ch "S? d?ng" ? Luu
    ? Th�m h?ng m?c trong t?ng nh�m
    ?
C122 (Ch? d?nh h?ng m?c cho t?ng NVL)
    ? T�m NVL ? ?n "Ch?n trong nh�m/H?ng m?c" ? Tick ? OK ? Luu
    ?
C220 (Ki?m tra NVL d?u v�o)
    ? Khi NVL v? kho ? IQC v�o C220 d? nh?p k?t qu? ki?m tra
```

```sql
-- Ki?m tra h?ng m?c IQC c?a NVL
SELECT cit.CommInspTypeName, ci.CommInspItemName, ci.CommInspUpperLimit, ci.CommInspLowerLimit
FROM STB_CommInspItem ci
JOIN STB_CommInspTypeInfo cit ON cit.CommInspTypeCode = ci.CommInspTypeCode
JOIN STB_CommInspIndividualSpec cs ON cs.CommInspItemCode = ci.CommInspItemCode
WHERE cs.MaterialCode = 'm�_nvl'

-- Xem l?ch s? ki?m tra IQC theo NVL
SELECT * FROM STB_CommInspDocHistory
WHERE MaterialCode = 'm�_nvl' AND CreateDateTime >= '2026-04-01'
```

---

### 9.2 PQC (Process Quality Control � Ki?m tra trong qu� tr�nh SX)

```
C141 (Thi?t l?p chung PQC cho t?t c? model)
    ? H?ng m?c, lo?i input (1=s?, 2=checkbox)
    ?
C143 (H?ng m?c ki?m tra ri�ng theo t?ng model)
    ? Mapping MaterialCode ? h?ng m?c c? th?
    ?
C443 (Ki?m tra c�ng do?n ngo�i cell line)
    ? Scan Barcode ? Nh?p gi� tr? ? Ho�n th�nh
    ? SP: usp_GetCommInspection_HistoryForBarcode_Vietnam
    ?
C430 (L?ch s? ki?m tra c�ng do?n Cell Line)
C321 (S?a ch?a l?i � Reliability Assy)
```

**C443 � SP d?y d?:**

| SP | Lo?i | Ch?c nang |
|----|------|-----------|
| `usp_GetCommInspection_HistoryForBarcode_Vietnam` | Search | L?y l?ch s? + template h?ng m?c |
| `usp_DoAddCommInspMeasureHistForBarcode` | Execute | Th�m k?t qu? do t?ng h?ng m?c |
| `usp_DoFinishCommInspDoc` | Execute | Ho�n th�nh t�i li?u ki?m tra |
| `usp_DoFinishCommInspDoc_VNT` | Execute | Ho�n th�nh t�i li?u ki?m tra VNT |

```sql
-- S?a h?ng m?c ki?m tra t?i C443 (x�a CommInspDoc cu r?i t?o l?i)
-- Bu?c 1: T�m CommInspDocNo theo Barcode
SELECT * FROM STB_CommInspDocHistory
WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVPP163R072732')

-- Bu?c 2: X�a d? t?o l?i
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = '...'
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = '...'
```

---

### 9.3 OQC (Outgoing Quality Control � Ki?m tra th�nh ph?m)

```
C121 (Nh�m h?ng m?c � d�ng chung v?i IQC)
    ?
C151 (H?ng m?c ki?m tra OQC theo t?ng s?n ph?m)
    ? T�m MaterialCode ? Ch?n trong nh�m ? Tick ? OK ? Luu
    ? N?u Model kh�ng c� trong popup: V�o A410 ? Thi?t l?p OQCType/InspectionLevel ? T?t C151 v� v�o l?i
    ?
C512 (Qu?n l� Lot ki?m tra s?n ph?m)
    ? D�n Barcode ? T�m ki?m ? T?o Lot
    ? TH1 kh�ng th?y: �� t?o Lot r?i ? sang C530
    ? TH2 kh�ng th?y: Chua thi?t l?p h?ng m?c t?i A410
    ? TH3 (HN): M� test th�ng 12 b?t d?u Route VE02 ? kh�ng hi?n (thi?t k? h? th?ng)
    ?
C530 (Ki?m tra s?n ph?m theo t?ng m?u)
    ? Nh?p Barcode + M� NV ? T�m ki?m
    ? Ch?n h?ng m?c ? Nh?p gi� tr? b�n ph?i ? Save b�n ph?i
    ? Ch?n Pass ? b�n tr�i ? Save b�n tr�i ? ��nh gi� OK ? Luu
    ? N?u th�m/s?a h?ng m?c ? C151 ? ?n "T?ng h?p h?ng m?c" d? reset
    ?
C540 (L?ch s? ki?m tra t? C530)
    ?
C510 ? C546 ? C541 (Ki?m tra ESR xu?t kho)
```

```sql
-- Model d� config OQC chua
SELECT ModelCode, OqcType, OqcInspectionRuleType, InspectionType, InspectionLevel
FROM STB_ModelBasicInfo WHERE ModelCode = 'm�_model'

-- N?u NULL ? update:
UPDATE STB_ModelBasicInfo
SET OqcType = 'MANUAL', OqcInspectionRuleType = 'BY_MODEL',
    InspectionType = 'SAMPLE', InspectionLevel = 'SAMPLE'
WHERE ModelCode = 'm�_model'

-- X�a CommInspDoc b? sai ? t?o l?i t? C512
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = '...'
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = '...'

-- S?a k?t qu? OQC
UPDATE STB_CommInspDocHistory
SET CommInspResult = 'PASS', FinishDateTime = GETDATE()
WHERE CommInspDocNo = '...'
```

---

### 9.4 [C561]/[C564] — Bending/Cutting QC (~)

```
C561 (H?ng m?c ki?m tra Bending/Cutting theo t?ng model)
    ? T�m MaterialCode ? Ch?n nh�m ? Tick ? OK ? Luu
    ?
C562 (T?o Lot ki?m tra Bending/Cutting)
    ? D�n Barcode ? T�m ki?m ? T?o Lot
    ?
C563 (Ki?m tra Lot Bending/Cutting)
    ? Gi?ng C530: Nh?p barcode ? Ch?n h?ng m?c ? Nh?p gi� tr? ? Save ? ��nh gi� OK
    ? N?u s?a C561 ? ?n "T?ng h?p h?ng m?c" d? reset gi� tr?
    ?
C564 (L?ch s? ki?m tra Bending/Cutting)
```

---


---

> [!NOTE]
> **Khắc phục sự cố & Sửa chữa lỗi Cell / FOQC OCV (C321, C546):**
> Chi tiết lỗi, nguyên nhân và SQL script sửa đổi đã được chuyển sang tài liệu chuyên biệt:
> 👉 [KB_05_02_SCREEN_BUGS_QC.md](KB_05_02_SCREEN_BUGS_QC.md).

---
### 9.7 QC N�ng Cao � Quy tr�nh ESR, Vision, X-Ray & Aging

#### 9.7.1 Gi�m s�t ch?t lu?ng di?n tr? ESR (ESR Inspection)
H? th?ng MES ghi nh?n d? li?u do ki?m ESR t? d?ng v� th? c�ng qua c�c b?ng v� Stored Procedure:
* **B?ng d? li?u:** `STB_VVT_ESRDATA` (Luu th�ng s? do ki?m th?c t? t? m�y).
* **Stored Procedure:** `usp_VVT_ESRdata_uid`
  * Ch?c nang: Luu th? c�ng ho?c t? d?ng k?t qu? ki?m tra di?n tr? ESR bao g?m: `@pinspectvalue` (ESR do du?c), `@pinspectvalue1`, `@pinspectvalue2`, `@pinspectime` (th?i gian do), `@plinecode` (m� line), `@pmaterialcode` (m� model).
  * Quy t?c: N?u gi� tr? do ho?c m� line truy?n v�o b? r?ng, SP s? t? d?ng d?ng. N?u m� m�y b? tr?ng, h? th?ng g�n m?c d?nh b?ng m� s? Line.

#### 9.7.2 Quy tr�nh ki?m tra ngo?i quan b?ng ?? (Vision Inspection)
D�y chuy?n s?n xu?t s? d?ng 3 nh�m h? th?ng ?? (Vision Camera) tuong ?ng v?i 3 c�ng do?n ki?m tra ngo?i quan kh�c nhau:
* **C�c b?ng d? li?u:**
  1. `STB_VisionGroup1InspectionInfo`: Ki?m tra cu?n di?n c?c (Winding).
  2. `STB_VisionGroup2InspectionInfo`: Ki?m tra d?p cao su & l?p tancha (Rubber / Riveting).
  3. `STB_VisionGroup3InspectionInfo`: Ki?m tra b?c v? nh?a & d?nh h�nh mi?ng (Sleeving / Curling).
* **Stored Procedure:** `usp_VisionGroupInspectionInfo_get`
  * Ch?c nang: Truy v?n g?p (`UNION ALL`) d? li?u h�nh ?nh v� l?i ph�t hi?n t? c? 3 nh�m Vision tr�n.
  * C?u tr�c d? li?u ghi nh?n: M� thi?t b? (`MachineID`), m� Lot (`LotNo`), barcode chi ti?t (`Barcode`), s? th? t? Camera (`CameraNo`), lo?i l?i ngo?i quan (`DefectType`), t?a d? l?i (`XAxis`, `YAxis`), k�ch thu?c l?i (`LongSize`, `ShortSize`, `Size`), di?n t�ch (`Area`), d? d�y (`Thickness`), kho?ng c�ch ch�n (`Distance`), thu?t to�n ph�t hi?n (`AlgType`), v� d? li?u nh? ph�n c?a h�nh ?nh ch?p l?i (`Image`).

#### 9.7.3 �o ki?m X-Ray & XRF (X-Ray & XRF Inspection)
C�ng do?n ki?m tra c?u tr�c b�n trong cu?n cell (X-Ray) v� do d? d�y l?p m?/th�nh ph?n nguy�n t? b?ng quang ph? hu?nh quang tia X (XRF):
* **Ki?m tra ch?p X-Ray:**
  * B?ng DB: `STB_XRayImageUploadHist` (Luu l?ch s? upload) li�n k?t v?i `SmartFramework_File.dbo.STB_AttachedFileMaster` (Luu tr? file v?t l� � ?? b?ng n�y n?m trong DB `SmartFramework_File`, kh�ng n?m trong `SmartFactoryV2`).
  * Stored Procedure: `usp_XRayImageUploadHist_get`
    * Ch?c nang: L?y th�ng tin l?ch s? ch?p X-Ray c?a Barcode s?n ph?m, tr? v? t�n file h�nh ?nh (`FileName`), k�ch thu?c file (`FileSize`), v� d? li?u nh? ph�n file ?nh ch?p c?u h�nh l�i (`FileData`).
* **�o ph? XRF:**
  * B?ng DB: `STB_XRFInspectionInfo`
  * Stored Procedure: `usp_XRFInspectionInfo_get`
    * Ch?c nang: L?y k?t qu? ph�n t�ch nguy�n t? chi ti?t c?a barcode, ghi nh?n: detector (`Detector`), th?i gian do (`RunTime`), v� 3 k?t qu? do ki?m hu?nh quang tuong ?ng (`Result1`, `Result2`, `Result3`).

#### 9.7.4 Quy tr�nh l�o h�a & do ki?m OCV sau Aging (Aging Sorting & OCV)
Sau khi ho�n th�nh c�ng do?n l�o h�a nhi?t (Aging), s?n ph?m du?c do ki?m di?n �p h? m?ch (OCV) v� ph�n lo?i ch?t lu?ng:
* **C�c b?ng d? li?u:**
  * `STB_MaterialQcInfo` & `STB_MaterialQcDetail` (Ch?a th�ng tin c?u h�nh l� ki?m d?nh).
  * `STB_QC_LOTNO_MODULE` (B?ng luu k?t qu? ki?m d?nh cho h�ng Module).
  * `STB_MaterialQcSampleResult` (Luu gi� tr? OCV/ESR chi ti?t t?ng m?u).
* **Stored Procedure:**
  1. `usp_VVT_AgingInspectionHist_vvt_get`
     * Ch?c nang: T�m ki?m l?ch s? ki?m do OCV/ESR sau Aging (v?i m� t�i li?u `InspectionDocType = 'AOQC'`).
     * Quy t?c d?nh danh: H? th?ng t? d?ng t?o m� QC d?ng `A` + `Barcode` (V� d?: Barcode `VVLR133R010603` s? tuong ?ng v?i `MaterialQcNo = 'AVVLR133R010603'`).
     * SP h? tr? t? d?ng truy v?t l?ch s? d?i m� barcode cu/m?i qua b?ng `STB_LotChangeMaterialHistory`.
  2. `usp_Vietnam_GetMaterialAgingInfo`
     * Ch?c nang: Ph?c v? m�n h�nh xu?t xu?ng v� ki?m d?nh FOQC. Th?c hi?n g?p d? li?u gi?a h�ng Cell (th�ng tin OQC Pass trong `STB_MaterialQcInfo`) v� h�ng Module (th�ng tin Pass trong `STB_QC_LOTNO_MODULE`).

---




## [F743]/[F748]/[C243] — 10. ? �i?n C?c � Slitting H� Nam (~, )

### 10.1 Flow Slitting H� Nam

```
F744 (Thi?t l?p chi?u r?ng)
    ? Th�m MaterialCode + Width + �on v? (M2 ho?c KG)
    ? NG_ConPaper + NG_Poil: 2 m� d?c bi?t KH�NG du?c x�a/s?a
    ?
F743 (Th?c hi?n Slitting)
    ? Ch?n MaterialCode ? T�m ki?m ? Xem foil ban d?u (tr�i) + d� c?t (ph?i)
    ? Th�m foil d� c?t: (+) ? Ch?n m� NVL con ? Nh?p Length ? Save
    ? Sau khi xong: ?n "Ch?t Slitting" ? Chuy?n sang C243
    ? In tem: Tick ch?n ? ?n "Ph�t h�nh tem" ? Ch?n m�y in
    ?
C243 (QC Ki?m tra Lot Slitting)
    ? QC check sau khi Slitting d� ch?t
    ? ��nh gi� OK: T? d?ng Pass + Chuy?n NG_ConPaper/NG_Poil ? kho NG
    ? ��nh gi� NG: Lot b? Reject ? kho NG
    ?
F746 (L?ch s? Slitting) ? F747 (L?ch s? check NG/Pass) ? F748 (Chuy?n v? kho NVL)
```

#### [F742] — ?? H?y/Rollback Slitting ()
*   **Quy t?c:** �? th?c hi?n rollback c?t di?n c?c v� cho ph�p c?t l?i ? m�n h�nh **F742**, b?t bu?c ph?i x�a l?ch s? ghi nh?n ? m�n h�nh **F746** tru?c.

**L?i thu?ng g?p Slitting:**

| L?i | Nguy�n nh�n | Gi?i ph�p |
|-----|-------------|-----------|
| "Tr�ng m� nguy�n li?u" | M� NVL d� thi?t l?p trong F744 r?i | Ki?m tra v� s?a b?n ghi cu |
| Lot kh�ng t?n t?i khi chuy?n F430 | Lot chua du?c QC check ? C243 | V�o C243 check tru?c |
| Kh�ng chuy?n v? kho du?c | Lot b? QC d�nh Reject | Kh�ng th? chuy?n � x? l� theo quy tr�nh NG |

👉 **Chi tiết Script Fix (Thiết lập & Cấu hình Slitting):** Xem tại [../KB_05/KB_05_02_SCREEN_BUGS_QC.md#82-lỗi-chưa-config-trong-stb_slittinglocationconfig_vvt](../KB_05/KB_05_02_SCREEN_BUGS_QC.md#82-lỗi-chưa-config-trong-stb_slittinglocationconfig_vvt).

---

## 11. ?? 4M Change, CAPA & Ph�n Lo?i M� L?i (G?p t? KB_23)

H? th?ng qu?n l� bi?n d?ng ch?t lu?ng hi?n tru?ng v� quy tr�nh x? l� h�nh d?ng kh?c ph?c/ph�ng ng?a.

### 11.1 Qu?n L� Thay �?i 4M (Man, Machine, Material, Method)
Ghi nh?n m?i bi?n d?ng li�n quan d?n con ngu?i, m�y m�c, nguy�n v?t li?u ho?c phuong ph�p s?n xu?t qua b?ng `STB_QC4MChangeDataRecord`.
M�n h�nh: `VVT_DoCreateQC4MChange` (T?o m?i), `VVT_ViewDetailQC4MChange` (Ph� duy?t), `VVT_View4MChange` (Xem l?ch s?).

```sql
-- Xem c�c b?n ghi 4M Change g?n d�y
SELECT QC4MNo, ChangeType4M, Model, LineCode, RouteCode,
       ReasonForChange, Status, ApprovalDate, EffectiveDate
FROM STB_QC4MChangeDataRecord
WHERE CreateDateTime >= DATEADD(MONTH, -1, GETDATE())
ORDER BY CreateDateTime DESC;

-- L?c theo thay d?i Nguy�n v?t li?u (Material)
SELECT * FROM STB_QC4MChangeDataRecord
```

### 11.2 CAPA (Corrective And Preventive Action)
Khi phát hiện lỗi hệ thống hoặc lỗi nghiêm trọng từ khách hàng, Lot hàng bị ảnh hưởng sẽ được tách riêng tại màn hình `VVT_CAPAInputSeparateLot` để kiểm tra đánh giá trước khi thực hiện hành động khắc phục.

### 11.3 S?a Ch?a S?n Ph?m L?i (Defect Repair)
S?n ph?m l?i du?c ti ch?/s?a ch?a v ghi nh?n t?i cc b?ng:
*   `STB_DefectRepairInfo`: Thng tin chung v? s?a ch?a s?n ph?m l?i.
*   `STB_DefectRepairDetailInfo`: Chi ti?t cng do?n/h?ng m?c s?a ch?a.
*   `STB_DefectRepairPartInfo`: Ph? tng ho?c v?t tu tiu hao dng cho s?a ch?a.

```sql
-- Xem l?ch s? s?a ch?a s?n ph?m l?i trong tu?n
SELECT * FROM STB_DefectRepairInfo
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
ORDER BY CreateDateTime DESC;
```

### 11.4 Phn Lo?i Nhm L?i & Nguyn Nhn (Defect Master)
Danh sch m l?i nghi?p v? du?c luu tr? t?p trung d? ph?c v? th?ng k:
*   `STB_DefectGroup`: Nhm l?i l?n (Major, Minor, Critical).
*   `STB_DefectInfo`: Danh m?c m l?i chi ti?t hi?n th? trn cc mn hnh scan.
*   `STB_DefectCauseGroup`: Nhm nguyn nhn l?i.
*   `STB_DefectCauseInfo`: Chi ti?t nguyn nhn l?i.

```sql
-- Xem danh sch m l?i dang ho?t d?ng (IsUsed=1)
SELECT DefectCode, DefectName, DefectGroupCode
FROM STB_DefectInfo
WHERE IsUsed = 1
ORDER BY DefectGroupCode, DefectCode;
```

### 11.5 B�o C�o Ch?t Lu?ng QC (QC Defect Reports)
C�c b?ng ghi nh?n chi ti?t l?i IQC/PQC/OQC:
*   `STB_QcDefectReport`: B�o c�o l?i QC chung.
*   `STB_IOQCDefectInfo` & `STB_IOQCDefectDetail`: Th�ng tin chi ti?t l?i IQC v� OQC.
*   `STB_QCDefectDetailsRecord`: Nh?t k� record l?i chi ti?t.

---

## 12. ?? Reliability Test � Ki?m Tra �? Tin C?y (G?p t? KB_24)

Quy tr�nh th? nghi?m s?n ph?m t? di?n trong m�i tru?ng kh?c nghi?t (nhi?t d? cao, di?n �p cao, d? ?m cao) d? d�nh gi� tu?i th? v� d? ?n d?nh.

### 12.1 Quy Tr�nh V?n H�nh
1.  **T?o Request (`STB_ReliabilityTestRequestInfo`):** B? ph?n QC ho?c R&D g?i y�u c?u ki?m tra, x�c d?nh Lot s?n xu?t h�ng lo?t c?n test v� di?u ki?n ki?m tra (ESR, dung lu?ng, d�ng r�).
2.  **L?y M?u (`STB_ReliabilityTestSampleInfo`):** Ti?p nh?n y�u c?u, t�ch Lot m?u, khai b�o di?u ki?n test (�i?n �p, Nhi?t d?, �? ?m) v� s? lu?ng m?u ki?m tra.
3.  **�o Lu?ng �?nh K? (`STB_ReliabilityTestMeasureInfo`):** Ti?n h�nh do th�ng s? t? di?n theo chu k? (Cycle 1, 2, 3...) v� ghi nh?n k?t qu? OCV, ESR, dung lu?ng.
4.  **K?t lu?n & ��ng y�u c?u.**

### 12.2 Truy V?n D? Li?u Ki?m Th?
```sql
-- Xem c�c y�u c?u ki?m tra d? tin c?y g?n d�y
SELECT RTRequestNo, RequestDate, MassProductionLotNo,
       TestPurposeComment, RequesterID, TestClassCode
FROM STB_ReliabilityTestRequestInfo
ORDER BY RequestDate DESC;

-- Xem th�ng tin m?u dang ki?m tra
SELECT RTSampleNo, RTRequestNo, SampleLotNo, SampleQty,
       VoltCondition, TemperatureCondition, HumidityCondition
FROM STB_ReliabilityTestSampleInfo
ORDER BY CreateDateTime DESC;

-- Xem k?t qu? do ki?m chi ti?t theo chu k? c?a m?t Lot
SELECT RTDate, MeasureCycle, SampleLotNo, SampleSeqNo,
       TestName, MeasureValue, CharacterizationCode
FROM STB_ReliabilityTestMeasureInfo
WHERE SampleLotNo = 'LOT_C?N_TRA'
ORDER BY MeasureCycle, SampleSeqNo;
```

---

> [!NOTE]
> **Phân tích Kiến trúc DB & SP:** Chi tiết sơ đồ quan hệ và phân tích stored procedure cốt lõi có sẵn tại [../KB_08_CORE_SP_ENGINE.md](../KB_08_CORE_SP_ENGINE.md).

*Cập nhật: 2026-06-14 | Gộp nội dung từ KB_23 và KB_24 để dễ dàng bộ hóa tri thức quản lý chất lượng (QC)*
> **Phân tích Kiến trúc DB & SP:** Chi tiết sơ đồ quan hệ và phân tích stored procedure cốt lõi có sẵn tại [../KB_08_CORE_SP_ENGINE.md](../KB_08_CORE_SP_ENGINE.md).




---


