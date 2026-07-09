# KB_05 � Ki?m tra Ch?t lu?ng (QC) & �i?n c?c

> **M�n h�nh:** B597, C443, C512, C486, C530, C546, B552, B270, B540, C121-C564, F743-F748
> **B?ng ch�nh:** `STB_MaterialQcInfo` (35 cols), `STB_MaterialQcInspectionItem` (USL/LSL), `STB_CommInspDocHistory`
> **?? Keywords:** QC, ch?t lu?ng, ki?m tra, IQC, PQC, OQC, FOQC, electrode, di?n c?c, slitting, aging, h?ng m?c, spec, USL, LSL, Pass, Fail, Hold, m?u, sample
> ? [V? INDEX](../KB_INDEX.md)

---

## 7. ?? Ki?m tra Ch?t lu?ng (QC)

### 7.1 [B597] b�o l?i "H?ng m?c ki?m tra cu / sai"

**Tri?u ch?ng:** V�o B597 ho?c C443, h? th?ng load l?i h?ng m?c cu c?a l?n tru?c, kh�ng cho s?a.

**Nguy�n nh�n:** `STB_CommInspDocHistory` d� c� b?n ghi cu cho Barcode n�y.

**Debug v� Fix:**
```sql
-- Bu?c 1: T�m CommInspDocNo t? Barcode
SELECT CIDH.CommInspDocNo, CIDH.ProdNo, CIDH.CreateDateTime
FROM STB_CommInspDocHistory CIDH
JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
WHERE SI.Barcode = 'VVPO093R010707'

-- Ho?c t�m tr?c ti?p b?ng ControlNo
SELECT * FROM STB_CommInspDocHistory
WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVPP163R072732')

-- Bu?c 2: Xem h?ng m?c ki?m tra dang c�
SELECT * FROM STB_CommInspDocItem
WHERE CommInspDocNo = 'CommInspDocNo_T�m_�u?c'

-- Bu?c 3: X�a d? h? th?ng kh?i t?o l?i (x�a Item tru?c, r?i x�a History)
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = 'CommInspDocNo_C?n_X�a'
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = 'CommInspDocNo_C?n_X�a'
```

> ?? Sau khi x�a, QC c?n **t?t m�n h�nh v� m? l?i** d? h? th?ng load b? ti�u chu?n m?i.

**SP li�n quan:**
- C443: `usp_GetCommInspection_HistoryForBarcode_Vietnam`
- B597: `usp_GetCommInspectionHistoryForBarcode`

---

### 7.2 [C512] — Kh�ng t�m th?y Lot ? m�n

**3 nguy�n nh�n � Debug theo th? t?:**

```sql
-- Bu?c 1: Ki?m tra Lot d� t?n t?i chua
SELECT Barcode, MaterialCode, InputLineCode, CurrentRouteCode, LotDecisionResult
FROM STB_SetInfo WHERE Barcode = 'M�_Barcode'
-- N?u c� k?t qu? ? Lot d� t?n t?i ? B�o QC t�m l?i d�ng barcode
-- N?u kh�ng c� ? Lot chua du?c t?o ? Quay l?i B450 t?o Lot

-- Bu?c 2: Ki?m tra A410 d� setup OQC chua
SELECT ModelCode, OqcType, InspectionType, OqcInspectionRuleType
FROM STB_ModelBasicInfo
WHERE ModelCode = 'M�_Model'
-- N?u OqcType NULL ho?c InspectionType NULL ? Chua setup ? M? m�n h�nh A410 d? c?u h�nh OQC (ho?c ch?y SQL set MANUAL / SAMPLE / BY_MODEL)
-- Sau khi setup xong ? T?t v� m? l?i C151, v�o l?i C512

-- Bu?c 3: Ki?m tra d� dang k� h?ng m?c ki?m tra cho model chua (Tr�nh l?i ti?ng H�n "????? ?????? ????")
SELECT * FROM STB_MaterialQcInspectionItem WHERE MaterialCode = 'M�_Model'
-- N?u kh�ng c� d�ng n�o ? Chua dang k� h?ng m?c ki?m tra ? C?n sao ch�p t? model ch? em trong DB ho?c c?u h�nh tr�n m�n h�nh C151

-- Bu?c 4 (H� Nam): Ki?m tra Route b?t d?u
SELECT CurrentRouteCode FROM STB_SetInfo WHERE Barcode = 'M�_Barcode'
-- N?u b?t d?u t? VE02 ? Kh�ng hi?n ? C512 ? ��y l� thi?t k? c?a h? th?ng
```

---

### 7.3 [B597] b�o l?i "H?t h?n s? d?ng"

? Xem [KB_02 M?c 4.10](../KB_02/KB_02_01_WMS_CORE.md#410-ki?m-tra-h?n-s?-d?ng-nvl-expiry-date) d? tra c?u c�ng th?c t�nh.

---

### 7.4 [B597] b�o l?i "Kh�ng t?n t?i thi?t l?p V? Nh�m"

**Tri?u ch?ng:** `"Kh�ng t?n t?i thi?t l?p V? Nh�m c?a LotNo... v?i m� V? Nh�m: GBDYAC-004 <> ECVT30-367"`

> ?? **�� x�c minh (2026-05-17):** B?ng `STB_AluCaseMapping_VVT` **KH�NG T?N T?I** trong `SmartFactoryV2`. Logic ki?m tra v? nh�m du?c **hardcode ho�n to�n** b�n trong SP `usp_Vietnam_RawMaterialInputHist_uid` (b?ng IF/NOT IN). Kh�ng c� b?ng mapping ru?i!

**Debug:**
```sql
-- Kh�ng c� b?ng d? query -- ph?i d?c th?ng v�o SP:
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))
-- Ctrl+F t�m t? kh�a 'V? Nh�m' ho?c 'AluCase' ho?c 'GBDYAC'
-- T�m d?n kh?i IF ch?n ? Th�m m� v? m?i v�o danh s�ch NOT IN
```

**Fix (ch? c� 1 c�ch duy nh?t) - S?a trong SP:**
```sql
-- T�m do?n code ch?n trong SP
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))
-- VD t�m t?i d�ng:
-- IF (@MaterialCode = 'ECVT30-367' AND @pRawMaterialBarcode NOT IN ('GBRLAC-004', 'GBDYAC-004'))
-- ? Th�m m� v? m?i v�o NOT IN list r?i deploy l?i SP
```


---

### 7.5 [B597] b�o l?i "M� Electrolyte kh�ng kh?p v?i BOM"

**Tri?u ch?ng:** `"M� Electrolyte/DUNG D?CH du?c thi?t l?p, kh�c v?i m� QRCODE nh?p v�o B597"`

**Nguy�n nh�n:** C�ng nh�n dang d�ng m� NVL thay th? (VD: `GBEC00-011`) nhung BOM v?n c?u h�nh m� cu (`GBCP00-001`).

**Debug:**
```sql
-- Ki?m tra BOM c?a Model dang s?n xu?t
SELECT BD.MaterialCode AS [M�_NVL_BOM], BD.MaterialName
FROM STB_BomDetail BD
JOIN STB_BomHeader BH ON BD.BomHeaderNo = BH.BomHeaderNo
WHERE BH.MaterialCode = 'M�_Model_SX'
AND BD.MaterialCode LIKE 'GBE%'  -- L?c c�c m� electrolyte
```

**X? l�:**
1. **��ng chuy�n m�n:** B�o EA/R&D ki?m tra BOM c� c?n c?p nh?t kh�ng
2. **IT fix t?m (ch? BOM update):** V�o SP `usp_Vietnam_RawMaterialInputHist_uid` ? T�m CTE `eleclyte1` ? Th�m ngo?i l?:
```sql
-- Th�m v�o CTE eleclyte1 trong SP:
UNION ALL
SELECT 'GBEC00-011' AS electrolyte, 'WEC3R0606QG' AS model, '1840' AS size
```

---

### 7.6 [B597] b�o l?i "Chu?i di?n c?c kh�ng kh?p" (Electrode Thickness)

**Nguy�n nh�n:** NVL di?n c?c m?i dang k� thi?u ho?c sai �? d�y (`MaterialThickness`). H? th?ng so s�nh chu?i b? l?i khi d? d�y `200` != `200.000000`.

**Debug:**
```sql
-- Ki?m tra MaterialThickness trong Master
SELECT MaterialCode, MaterialThickness FROM STB_MaterialMaster
WHERE MaterialCode = 'M�_�i?n_C?c'

-- Ki?m tra d? d�y d� nh?p trong Lot (SIExtReal03)
SELECT Barcode, SIExtReal03 AS [Do_Day_Da_Nhap] FROM STB_SetInfo
WHERE Barcode = 'M�_Barcode_B?_L?i'
```

**Fix theo th? t?:**
```sql
-- Fix 1: S?a MaterialMaster th�nh s? nguy�n (kh�ng c� .000)
UPDATE STB_MaterialMaster
SET MaterialThickness = '200'  -- Kh�ng ph?i '200.000000'
WHERE MaterialCode = 'M�_�i?n_C?c'

-- Fix 2: N?u c�ng nh�n d� t?o Lot r?i ? S?a c? SIExtReal03
UPDATE STB_SetInfo
SET SIExtReal03 = 200  -- S? nguy�n, kh�ng c� th?p ph�n
WHERE Barcode = 'M�_Barcode'

-- Fix 3: N?u l?i li�n quan d?n b?ng di?n c?c
UPDATE STB_ElectrodeWastePriceNew SET ElectrodeThickness = 200 WHERE [�i?u_Ki?n]
UPDATE STB_ElectrodeWasteInfoNew SET ElectrodeThickness = 200 WHERE [�i?u_Ki?n]
```

---

### 7.7 [B597] b�o l?i HOLDING

**Nguy�n nh�n:** L� NVL dang ? tr?ng th�i HOLD do chua qua IQC ho?c b? hold th? c�ng.

> ?? **X�c minh DB (2026-05-17):** `STB_MaterialQcInfo` KH�NG c� c?t `InspectionStatus` hay `HoldReason`. HOLD du?c x�c d?nh qua `MaterialWarehouseCode` trong `STB_MaterialLotInfo` (gi� tr?: `HOLDING_VN_WH`, `HOLDING_BG_WH`, `HOLDING_HN_WH`).

```sql
-- Ki?m tra Lot NVL c� dang HOLD kh�ng
SELECT LotID, MaterialWarehouseCode, MaterialCode, CurrentQty
FROM STB_MaterialLotInfo
WHERE LotID = 'ML...'
-- N?u MaterialWarehouseCode LIKE 'HOLDING_%' ? H�ng dang b? gi?

-- Mu?n b? HOLD (c?n c� s? d?ng � c?a QC) ? Chuy?n sang kho ch�nh:
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_VN_WH',  -- Thay b?ng kho d�ng
    MaterialLocationCode = 'ROH_VN_WH_01'
WHERE LotID = 'ML...'
```

> C�c gi� tr? HOLDING th?c t?: `HOLDING_VN_WH` (B?c Ninh), `HOLDING_BG_WH` (B?c Giang), `HOLDING_HN_WH` (H� Nam)

---

### 7.9 [B597] b�o l?i "String or binary data would be truncated" khi qu�t g?p nhi?u m� di?n c?c (Model 3510 / 35105)

*   **Tri?u ch?ng:** Khi qu�t g?p t? 5 m� barcode di?n c?c tr? l�n cho 1 Lot t?i tr?m B597, h? th?ng b�o l?i d? `"String or binary data would be truncated"` v� kh�ng cho luu.
*   **Chi ti?t & Gi?i ph�p:** Xem chi ti?t nguy�n nh�n g?c v� SQL script kh?c ph?c t?i [M?c L?i 3](#l?i-3-l?i-string-or-binary-data-would-be-truncated-khi-qu�t-g?p-5-m�-di?n-c?c-1-lot-model-3510--35105) b�n du?i.

---

### 7.8 [C486] — M�n h�nh (Error Data Sorting): N�ng c?p giao di?n (Th�m c?t, Rebuild b?ng & Fix layout grid)

**Y�u c?u:** Th�m 2 c?t m?i cho m�n h�nh C486: `Invoice` (n?m tru?c `LotNo`) v� `Note` (n?m sau `Total`) cho c? 2 nguy�n v?t li?u **ALCase** v� **Plate**, gi? nguy�n d? li?u l?ch s? v� d�ng th? t? c?t khi `SELECT *`.

#### 1. Phuong ph�p Rebuild b?ng d? gi? d�ng th? t? c?t v?t l�:
Do SQL Server kh�ng c� l?nh `ALTER TABLE ADD COLUMN ... BEFORE/AFTER` gi?ng MySQL, gi?i ph�p l� t?o b?ng t?m `_NEW` d�ng th? t? -> Copy d? li?u -> Drop b?ng cu -> Rename b?ng m?i:
```sql
BEGIN TRANSACTION;
BEGIN TRY
    -- B1. T?o b?ng t?m v?i d�ng th? t? c?t mong mu?n
    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] (
        [ID] INT IDENTITY(1,1) NOT NULL,
        ...
        [MaterialCode] NVARCHAR(50) NULL,
        [Invoice] NVARCHAR(100) NULL, -- << C?t m?i d?t tru?c LotNo
        [LotNo] NVARCHAR(50) NULL,
        ...
        [Total] INT NULL,
        [Note] NVARCHAR(500) NULL, -- << C?t m?i d?t sau Total
        [CreateUserID] VARCHAR(20) NULL, ...
    );

    -- B2. B?t IDENTITY_INSERT d? copy d? li?u l?ch s? (c?t m?i d? NULL)
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] ON;
    INSERT INTO [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] (ID, [Date], ..., Invoice, LotNo, ..., Total, Note, ...)
    SELECT ID, [Date], ..., NULL AS Invoice, LotNo, ..., Total, NULL AS Note, ...
    FROM [dbo].[STB_VVT_SortingErrorData_ALCase];
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] OFF;

    -- B3. Drop b?ng cu v� d?i t�n b?ng m?i
    DROP TABLE [dbo].[STB_VVT_SortingErrorData_ALCase];
    EXEC sp_rename 'STB_VVT_SortingErrorData_ALCase_NEW', 'STB_VVT_SortingErrorData_ALCase';
    EXEC sp_rename 'PK_STB_VVT_SortingErrorData_ALCase_NEW', 'PK_STB_VVT_SortingErrorData_ALCase';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
```

#### 2. C?p nh?t c�c Stored Procedure:
* **SP GET (`usp_VVT_SortingErrorData_ALCase_get` / `usp_VVT_SortingErrorData_Plate_get`):** 
  Th�m c?t m?i v�o d�ng v? tr� trong danh s�ch SELECT. Tr�nh l?p alias v� �ch nhu `Note, Note AS [Note]`. Gi? nguy�n �p ki?u `CAST(Qty AS VARCHAR(10))` d? tr�nh l?i d?nh d?ng khi ngu?i d�ng copy-paste t? Excel v�o Grid tr�n giao di?n.
* **SP IUD (`usp_VVT_SortingErrorData_ALCase_iud` / `usp_VVT_SortingErrorData_Plate_iud`):** 
  Do SmartFramework d?y d? li?u luu du?i d?ng `@pXml`, c?n th�m map c�c c?t m?i (`Invoice`, `Note`) ? 3 v? tr� trong SP: ph?n `UPDATE T SET ...`, c?u tr�c `WITH` c?a `OPENXML` (cho c? Update v� Insert) v� l?nh `INSERT INTO ... SELECT ...`.

#### 3. X? l� l?i layout grid (V� d?: Du c?t `Note1` tr�n giao di?n):
* **Tri?u ch?ng:** C?t `Note1` hi?n ra tr�n Grid d� trong c?u tr�c b?ng DB kh�ng c� c?t n�y.
* **Nguy�n nh�n:** Khi ngu?i d�ng thi?t k? giao di?n v� nh?n **Save Layout**, SmartFramework ch?p l?i c?u h�nh lu?i v� luu du?i d?ng XML v�o b?ng `SmartFramework.dbo.STB_ScreenLayoutInfo`. N?u tru?c d� c� c?t `Note1` (do g� nh?m ho?c test), grid s? t? kh�i ph?c c?t n�y l�n giao di?n.
* **C�ch check nhanh b?ng SQL:**
  ```sql
  SELECT Name, DATALENGTH(XmlLayout) AS XmlLength, CHARINDEX('Note1', XmlLayout) AS Note1Position
  FROM SmartFramework.dbo.STB_ScreenLayoutInfo WITH (NOLOCK)
  WHERE Name = 'ErrorDataSorting'
  ```
* **C�ch s?a tri?t d?:** M? m�n h�nh **C486**, k�o b? c?t `Note1` ra kh?i lu?i (ho?c ?n di trong Column Chooser), sau d� chu?t ph?i ch?n **Save Layout** d? c?p nh?t d� c?u h�nh XML s?ch l�n database.

---



## 8. ⚡ Điện cực (Electrode)

### 8.1 [B552] — Chỉnh chiều rộng Slitting ()

```sql
-- Xem cấu hình master slitting
SELECT * FROM STB_CoatingToSlittingMaster
-- WHERE CoatingMaterialCode = 'Mã_Coating'

-- Cập nhật chiều rộng slitting
UPDATE stb_slittinglocationconfig_vvt
SET Width = 16
WHERE SlittingCode = 'YP' AND SlittingSize = 200 AND PartNo = '1625' AND id = 12
```

---

### 8.2 Lỗi "Chưa CONFIG trong STB_SLITTINGLOCATIONCONFIG_VVT"

**Triệu chứng:** `"Không tồn tại thiết lập Điện cực của LotNo... Chưa CONFIG trong bảng: STB_SLITTINGLOCATIONCONFIG_VVT"`

**Debug:**
```sql
-- Xem thông số lỗi trong thông báo (VD: PartNo=1025, Farad=10, Width=17.7)
-- Kiểm tra bảng đã có chưa
SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'
```

**Fix — Thêm cấu hình mới:**
```sql
-- Template: BY = Cực dương (+), YP = Cực âm (-)
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),  -- Cực dương
    ('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2')   -- Cực âm

-- Xác nhận đã thêm
SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'
```

**Template thêm nhiều model cùng lúc:**
```sql
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),
    ('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2'),
    ('1325', 'BY', '200', '15', '18.7', 'VVT_F2', 'kho2'),
    ('1325', 'YP', '180', '15', '18.7', 'VVT_F2', 'kho2'),
    ('1030', 'BY', '200', '10', '23.7', 'VVT_F2', 'kho2'),
    ('1030', 'YP', '180', '10', '23.7', 'VVT_F2', 'kho2')

-- Sau đó cập nhật số cuộn và vị trí kho
UPDATE stb_slittinglocationconfig_vvt
SET RollQty = 20, PositiveLocation = 'A6-T3', NegativeLocation = 'B6-T3'
WHERE PartNo IN ('1025', '1325', '1030')
```

---

### 8.3 [B597] — Checklist khi báo lỗi khi lưu NVL

```
Theo thứ tự SP usp_Vietnam_RawMaterialInputHist_uid kiểm tra:
□ 1. HOLDING? → SELECT MaterialWarehouseCode FROM STB_MaterialLotInfo (Check 'HOLDING_%')
□ 2. Hết hạn? → Truy vấn LotAttr10 từ STB_MaterialDocLotInfo (nếu rỗng và là Lot tách %SP%/%SL%/%SM% thì check trong STB_MaterialLotInfo) + MMExtInt01 (xem KB_02 Mục 4.10)
□ 3. Sai chủng loại? → Kiểm tra BOM có mã NVL đó không (STB_BomDetail)
□ 4. Sai độ dày điện cực? → Kiểm tra MaterialThickness (phải là số nguyên)
□ 5. Sai mã Electrolyte? → Kiểm tra CTE eleclyte1 trong SP
□ 6. Thiếu cấu hình Vỏ Nhôm? → Sửa hardcode trong SP (Bảng AluCaseMapping không tồn tại)
□ 7. Thiếu cấu hình Slitting? → Kiểm tra STB_SLITTINGLOCATIONCONFIG_VVT
```

> 🚦 **Tham chiếu mở rộng:** Toàn bộ 7 gates trên đã được tổng hợp cùng 11 nhóm chặn tương tự (B530, B523, B452, B618, QC Audit, Returns, Lò Sấy, Slitting Knife...) tại **KB_14 §6 — Tổng Hợp Pattern Validation Gates**. Xem đó để biết cách mở rộng/thêm gate mới theo 4 Pattern thiết kế (A/B/C/D).

---

### 8.4 Logic kho điện cực

```
Mã lot điện cực Slitting: VV... hoặc VJ...
Mã lot kho nguyên liệu: ML...

P (BY) = Cực Dương (+)
M (YP) = Cực Âm (-)

Kiểm tra tồn kho điện cực → **Stb_SlittingStock_VVT**
```

> Điện cực phải dùng mã Lot kho (prefix `ML`) khi nhập kho nguyên liệu.

### 8.5 [B270] — Lỗi popup không hiện dữ liệu ở

👉 **Chi tiết Trace & Fix:** Xem tại [KB_01_UI_AND_SCREENS.md § 1.3](../KB_01_UI_AND_SCREENS.md)

---

### 8.6 Quy trình cân điện cực Mixing & Phần mềm Cân điện cực (electrode.weighing)

#### A. Giới thiệu phần mềm Cân điện cực (`electrode.weighing`):
*   **Mục đích:** Ứng dụng Electron Desktop App dùng để quản lý quá trình cân nguyên liệu (Than hoạt tính, chất dẫn điện, chất kết dính, nước cất...) trước khi cho vào máy trộn (Mixing) để tạo dung dịch Slurry.
*   **Kết nối phần cứng:** Kết nối cổng COM (RS232) đọc số cân trực tiếp từ cân điện tử, chống công nhân nhập tay sai số.
*   **Kết nối Database:** Kết nối trực tiếp đến database `SmartFactoryV2` của Vinatech qua tài khoản `vinaadmin`.
*   **Logic xử lý:** Khi scan mã Lot điện cực, ứng dụng gọi SP `usp_ElectrodeStep_get` (đọc cấu hình bước cân) và `usp_GetElectroMixPresentStep_vietnam` (đọc bước hiện tại) để load công thức và thứ tự bước cân (`Seq`). Khi cân đúng khoảng spec (`StdMinVal` - `StdMaxVal`), phần mềm lưu dữ liệu qua SP `usp_DoCreateElectrodeMixStepInfo_electron` và chốt mẻ trộn để chuyển sang công đoạn tráng phủ (Coating).

#### B. Các lỗi thường gặp và cách khắc phục:

##### 1. Lỗi nhảy bước cân, không cân lần lượt từ trên xuống (Than hoạt tính bị đẩy xuống dưới)
*   **Triệu chứng:** "Các bước cân cứ nhảy không đúng thứ tự process nên không cân được", "Mã điện cực HCE đang lỗi chưa thao tác được, sản xuất ra mà không được ghi nhận trên hệ thống".
*   **Nguyên nhân:** 
    *   Trên giao diện phần mềm có checkbox **"CA ĐÊM CHUẨN BỊ TRƯỚC"** (`isnight`). Ở ca đêm, Binder/CMC cần khuấy trước (20-40 phút) nên hệ thống cung cấp tùy chọn này để đảo thứ tự cân, đưa Binder lên trước Than hoạt tính (SP sẽ nhận tham số `@pOrder = 'kdem'`).
    *   Nếu ca ngày làm việc mà **quên bỏ tích checkbox này**, thứ tự cân sẽ bị nhảy lộn xộn khiến công nhân không thể cân lần lượt từ trên xuống và bị hệ thống chặn. Mẻ trộn bị kẹt không thể chốt hoàn thành, dẫn đến sản phẩm sản xuất ra không được ghi nhận trên MES.
*   **Cách khắc phục:**
    *   *Bước 1 (Vận hành):* Công nhân ca ngày **bỏ tích checkbox "CA ĐÊM CHUẨN BỊ TRƯỚC"** trên giao diện chính của phần mềm, sau đó bấm nút **"Làm mới màn hình"** để quay lại thứ tự cân than trước.
    *   *Bước 2 (IT reset Lot bị kẹt):* Nếu Lot điện cực (Ví dụ: Lot của mã `HCE-202`) đã bị ghi nhận sai thứ tự và kẹt giữa chừng, IT chạy lệnh xóa dữ liệu cân tạm của Lot đó để cân lại đúng từ đầu:
        ```sql
        BEGIN TRANSACTION;
        DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'Mã_Lot_Điện_Cực_HCE';
        COMMIT TRANSACTION;
        ```
        *Mẹo:* Có thể dùng 2 Stored Procedures sau để kiểm tra cấu hình và bước cân hiện tại của bến điện cực CMC (kết hợp đọc code JavaScript trong phần mềm):
        ```sql
        -- Kiểm tra bước hiện tại (tham số thứ 2 truyền 'kdem' nếu là ca đêm)
        EXEC usp_GetElectroMixPresentStep_vietnam 'VVQN1620001E28', '';
        
        -- Lấy chi tiết cấu hình bước cân trộn
        EXEC usp_Vietnam_ElectrodeMixingConfig_get 'VVQN1620001E28', '', 'ML20260124000020', '';
        ```

##### 2. Điện cực mã liệu `3582-600F CY` không tạo/in được tem
*   **Triệu chứng:** Khi sản xuất điện cực mã liệu `3582-600F CY`, hệ thống không cho in tem điện cực.
*   **Chi tiết & Giải pháp:** Đây là model mới thiếu cấu hình Slitting. Xem hướng dẫn chi tiết từng bước xử lý và SQL script thêm cấu hình tại [Kịch bản 5](#kịch-bản-sự-cố-khẩn-cấp-5-điện-cực-3582-600f-cy-không-tạo-được-tem).

---

*Cập nhật: 2026-05-26*

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

### 9.5 [C321] � PQC Reliability Assy (S?a Ch?a L?i Cell Line)

**Ch?c nang:** PQC qu?n l� h�ng ph�t sinh l?i c?n s?a ch?a trong qu� tr�nh s?n xu?t.

| SP | Ch?c nang |
|----|-----------|
| `usp_Vietnam_GetDefectRepairInfo_ForRepair` | L?y th�ng tin l?i c?n s?a ch?a |
| `usp_GetDefectRepairDetailInfo_ForRepair` | L?y chi ti?t nguy�n nh�n l?i |
| `usp_GetDefectRepairPartInfo` | L?y th�ng tin v?t tu thay th? |
| `usp_DoProcessLossForBarcode_VNT` | X? l� t?n th?t � ghi nh?n l?i |

```sql
-- Ki?m tra l?i theo barcode
SELECT * FROM STB_DefectRepairInfo WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VV...'
)
```

> ?? SQL s?a DefectQty v� ProdQty c�ng do?n sau ? xem [KB_03 M?c 5.8](../KB_03/KB_03_02_CELL_LINE.md#58-s?a-s?-lu?ng-ng-defectqty-m�n-b791) d? tr�nh tr�ng l?p.

---

### 9.6 [C546] (FOQC) � OCV/ESR ch? hi?n th? 20ea thay v� 50ea

**Tri?u ch?ng:** Tr�n tab C546 (FOQC_???????), h?ng m?c OCV (`FOQC_V01_07`) ch? hi?n th? t?i da 20 d�ng do th?c t? t? m�y (ho?c 0 d�ng n?u chua do) thay v� hi?n th? d? 50 d�ng theo ti�u chu?n m?u (SampleQty=50). 

**Nguy�n nh�n g?c (Root Causes):**
1. **L?i trong SP l?y k?t qu? do (`usp_MaterialQcSampleResult_get`):** Phi�n b?n cu kh�ng h? tr? pattern `FOQC_V01_07` (ch? h? tr? `PQC_V01_07`) n�n b? nh?y sang logic m?c d?nh `SampleQty=20` v� g�n tr�ng gi� tr? OCV. (�� s?a).
2. **Thi?u Block OCV trong SP kh?i t?o d�ng tr?ng (`usp_Vietnam_MaterialFOQcDetail_get`):** 
   - Khi QC m? m�n h�nh C546, h? th?ng g?i SP `usp_Vietnam_MaterialFOQcDetail_get` d? kh?i t?o c�c d�ng m?u tr?ng trong b?ng `STB_MaterialQcSampleResult` cho d? s? lu?ng `SampleQty=50`.
   - Trong SP n�y, l?p tr�nh vi�n d� vi?t c�c kh?i loop `WHILE` d? t?o d�ng tr?ng cho `DetailNo = 19` (20ea), `DetailNo = 3` (ESR - 50ea), v� `DetailNo = 4` (10ea), nhung **ho�n to�n b? qu�n h?ng m?c OCV (DetailNo = 2)**!
   - V� kh�ng du?c kh?i t?o d�ng tr?ng, lu?i OCV tr�n giao di?n ch? c� th? hi?n th? t?i da s? d�ng th?c t? do du?c t? m�y (20 d�ng) m� kh�ng th? l?p d?y d? 50 d�ng.

**Gi?i ph�p s?a d?i:**
1. **Deploy l?i Stored Procedure `usp_Vietnam_MaterialFOQcDetail_get`:**
   - Th�m kh?i loop `WHILE` cho `DetailNo = 2` d? t? d?ng t?o d? 50 d�ng tr?ng cho OCV.
   - N?i dung block th�m m?i:
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

**Debug & Ki?m tra d? li?u (SSMS):**
```sql
-- 1. Ki?m tra SampleQty v� Pattern hi?n t?i c?a Lot FOQC
SELECT MaterialQcNo, MaterialQcDetailNo, QcInspectionItemCode, SampleQty, PassedSampleQty, DecisionResult
FROM STB_MaterialQcDetail WHERE MaterialQcNo = 'F' + 'M�_Barcode'

-- 2. Ki?m tra s? d�ng th?c t? d� ghi nh?n trong b?ng SampleResult
SELECT MaterialQcDetailNo, COUNT(*) AS Total,
       SUM(CASE WHEN TestValue IS NOT NULL THEN 1 ELSE 0 END) AS WithValue,
       SUM(CASE WHEN TestValue IS NULL THEN 1 ELSE 0 END) AS EmptyRows
FROM STB_MaterialQcSampleResult 
WHERE MaterialQcNo = 'F' + 'M�_Barcode'
GROUP BY MaterialQcDetailNo

-- 3. Ki?m tra d? li?u th� t? m�y do trong Monitor
SELECT ID, lotno, value AS ESR, valueocv AS OCV, UploadToMes, UploadOCVToMess
FROM Stb_ESRValueMonitor WHERE lotno = 'M�_Barcode' ORDER BY ID
```

**Fix data khi b? l?ch s? d�ng:**
*Xem chi ti?t c�c bu?c ch?y rollback v� reset d? li?u t?i file script **fix_c546_ocv_lots.sql***

**C�c Stored Procedure li�n quan (C546):**

| SP | Lo?i | Ch?c nang |
|----|------|-----------|
| `usp_GetMaterialOQcInfo` | Search | L?y th�ng tin Lot QC |
| `usp_MaterialQcDetail_get` | Search | L?y danh s�ch h?ng m?c ki?m tra |
| `usp_MaterialQcSampleResult_get` | Search | **L?y gi� tr? do t? Stb_ESRValueMonitor** |
| `usp_MaterialQcSampleResult_iud` | Execute | Luu gi� tr? do th? c�ng |
| `usp_DoMakeMaterialQcSampleResult` | Execute | T?o sample result |
| `usp_DoUpdateMaterialQcInfo_Success` | Execute | ��nh gi� OK |
| `usp_DoUpdateMaterialQcInfo_Fail` | Execute | ��nh gi� NG |

**B?ng DB li�n quan:**

| B?ng | Vai tr� |
|------|---------|
| `STB_MaterialQcInfo` | Lot QC header (ch?a CompanyCode) |
| `STB_MaterialQcDetail` | H?ng m?c ki?m tra (SampleQty, LSL, USL, Pattern) |
| `STB_MaterialQcSampleResult` | K?t qu? do t?ng m?u (TestValue) |
| `Stb_ESRValueMonitor` | D? li?u ngu?n t? m�y do ESR/OCV |
| `STB_LotChangeMaterialHistory` | L?ch s? d?i barcode (SP tra ngu?c OldBarcode) |

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

?? **Chi ti?t Script Fix (Thi?t l?p & C?u h�nh Slitting):** Xem t?i KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md � 4.

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
WHERE ChangeType4M = 'Material'
ORDER BY CreateDateTime DESC;
```

### 11.2 CAPA (Corrective And Preventive Action)
Khi ph�t hi?n l?i h? th?ng ho?c l?i nghi�m tr?ng t? kh�ch h�ng, Lot h�ng b? ?nh hu?ng s? du?c t�ch ri�ng t?i m�n h�nh `VVT_CAPAInputSeparateLot` d? ki?m tra d�nh gi� tru?c khi th?c hi?n h�nh d?ng kh?c ph?c.

### 11.3 S?a Ch?a S?n Ph?m L?i (Defect Repair)
S?n ph?m l?i du?c t�i ch?/s?a ch?a v� ghi nh?n t?i c�c b?ng:
*   `STB_DefectRepairInfo`: Th�ng tin chung v? s?a ch?a s?n ph?m l?i.
*   `STB_DefectRepairDetailInfo`: Chi ti?t c�ng do?n/h?ng m?c s?a ch?a.
*   `STB_DefectRepairPartInfo`: Ph? t�ng ho?c v?t tu ti�u hao d�ng cho s?a ch?a.

```sql
-- Xem l?ch s? s?a ch?a s?n ph?m l?i trong tu?n
SELECT * FROM STB_DefectRepairInfo
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
ORDER BY CreateDateTime DESC;
```

### 11.4 Ph�n Lo?i Nh�m L?i & Nguy�n Nh�n (Defect Master)
Danh s�ch m� l?i nghi?p v? du?c luu tr? t?p trung d? ph?c v? th?ng k�:
*   `STB_DefectGroup`: Nh�m l?i l?n (Major, Minor, Critical).
*   `STB_DefectInfo`: Danh m?c m� l?i chi ti?t hi?n th? tr�n c�c m�n h�nh scan.
*   `STB_DefectCauseGroup`: Nh�m nguy�n nh�n l?i.
*   `STB_DefectCauseInfo`: Chi ti?t nguy�n nh�n l?i.

```sql
-- Xem danh s�ch m� l?i dang ho?t d?ng (IsUsed=1)
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

> ?? **Ph�n t�ch s�u & DB Audit:** Xem chi ti?t ph�n t�ch ki?n tr�c database, DNA h? th?ng v� k?t qu? Audit t?i KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md.

*C?p nh?t: 2026-06-14 | G?p n?i dung t? KB_23 v� KB_24 d? d?ng b? ho� tri th?c qu?n l� ch?t lu?ng (QC)*




---

