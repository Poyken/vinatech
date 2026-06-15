# KB_05 — Kiểm tra Chất lượng (QC) & Điện cực

> **Màn hình liên quan:** B597, C443, C512, C530, C546, B270, B540, B552
> ← [Về INDEX](KB_INDEX.md)

---

## 7. 🔬 Kiểm tra Chất lượng (QC)

### 7.1 B597 báo lỗi "Hạng mục kiểm tra cũ / sai"

**Triệu chứng:** Vào B597 hoặc C443, hệ thống load lại hạng mục cũ của lần trước, không cho sửa.

**Nguyên nhân:** `STB_CommInspDocHistory` đã có bản ghi cũ cho Barcode này.

**Debug và Fix:**
```sql
-- Bước 1: Tìm CommInspDocNo từ Barcode
SELECT CIDH.CommInspDocNo, CIDH.ProdNo, CIDH.CreateDateTime
FROM STB_CommInspDocHistory CIDH
JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
WHERE SI.Barcode = 'VVPO093R010707'

-- Hoặc tìm trực tiếp bằng ControlNo
SELECT * FROM STB_CommInspDocHistory
WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVPP163R072732')

-- Bước 2: Xem hạng mục kiểm tra đang có
SELECT * FROM STB_CommInspDocItem
WHERE CommInspDocNo = 'CommInspDocNo_Tìm_Được'

-- Bước 3: Xóa để hệ thống khởi tạo lại (xóa Item trước, rồi xóa History)
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = 'CommInspDocNo_Cần_Xóa'
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = 'CommInspDocNo_Cần_Xóa'
```

> ⚠️ Sau khi xóa, QC cần **tắt màn hình và mở lại** để hệ thống load bộ tiêu chuẩn mới.

**SP liên quan:**
- C443: `usp_GetCommInspection_HistoryForBarcode_Vietnam`
- B597: `usp_GetCommInspectionHistoryForBarcode`

---

### 7.2 Không tìm thấy Lot ở màn C512

**3 nguyên nhân — Debug theo thứ tự:**

```sql
-- Bước 1: Kiểm tra Lot đã tồn tại chưa
SELECT Barcode, MaterialCode, InputLineCode, CurrentRouteCode, LotDecisionResult
FROM STB_SetInfo WHERE Barcode = 'Mã_Barcode'
-- Nếu có kết quả → Lot đã tồn tại → Báo QC tìm lại đúng barcode
-- Nếu không có → Lot chưa được tạo → Quay lại B450 tạo Lot

-- Bước 2: Kiểm tra A410 đã setup OQC chưa
SELECT ModelCode, OqcType, InspectionType, OqcInspectionRuleType
FROM STB_ModelBasicInfo
WHERE ModelCode = 'Mã_Model'
-- Nếu OqcType NULL hoặc InspectionType NULL → Chưa setup → Mở màn hình A410 để cấu hình OQC (hoặc chạy SQL set MANUAL / SAMPLE / BY_MODEL)
-- Sau khi setup xong → Tắt và mở lại C151, vào lại C512

-- Bước 3: Kiểm tra đã đăng ký hạng mục kiểm tra cho model chưa (Tránh lỗi tiếng Hàn "검사항목이 등록되어있지 않습니다")
SELECT * FROM STB_MaterialQcInspectionItem WHERE MaterialCode = 'Mã_Model'
-- Nếu không có dòng nào → Chưa đăng ký hạng mục kiểm tra → Cần sao chép từ model chị em trong DB hoặc cấu hình trên màn hình C151

-- Bước 4 (Hà Nam): Kiểm tra Route bắt đầu
SELECT CurrentRouteCode FROM STB_SetInfo WHERE Barcode = 'Mã_Barcode'
-- Nếu bắt đầu từ VE02 → Không hiện ở C512 → Đây là thiết kế của hệ thống
```

---

### 7.3 B597 báo lỗi "Hết hạn sử dụng"

→ Xem [KB_02 Mục 4.10](KB_02_KHO_WMS.md#410-kiểm-tra-hạn-sử-dụng-nvl-expiry-date) để tra cứu công thức tính.

---

### 7.4 B597 báo lỗi "Không tồn tại thiết lập Vỏ Nhôm"

**Triệu chứng:** `"Không tồn tại thiết lập Vỏ Nhôm của LotNo... với mã Vỏ Nhôm: GBDYAC-004 <> ECVT30-367"`

> ⚠️ **Đã xác minh (2026-05-17):** Bảng `STB_AluCaseMapping_VVT` **KHÔNG TỒN TẠI** trong `SmartFactoryV2`. Logic kiểm tra vỏ nhôm được **hardcode hoàn toàn** bên trong SP `usp_Vietnam_RawMaterialInputHist_uid` (bằng IF/NOT IN). Không có bảng mapping rười!

**Debug:**
```sql
-- Không có bảng để query -- phải đọc thẳng vào SP:
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))
-- Ctrl+F tìm từ khóa 'Vỏ Nhôm' hoặc 'AluCase' hoặc 'GBDYAC'
-- Tìm đến khối IF chặn → Thêm mã vỏ mới vào danh sách NOT IN
```

**Fix (chỉ có 1 cách duy nhất) - Sửa trong SP:**
```sql
-- Tìm đoạn code chặn trong SP
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))
-- VD tìm tới dòng:
-- IF (@MaterialCode = 'ECVT30-367' AND @pRawMaterialBarcode NOT IN ('GBRLAC-004', 'GBDYAC-004'))
-- → Thêm mã vỏ mới vào NOT IN list rồi deploy lại SP
```


---

### 7.5 B597 báo lỗi "Mã Electrolyte không khớp với BOM"

**Triệu chứng:** `"Mã Electrolyte/DUNG DỊCH được thiết lập, khác với mã QRCODE nhập vào B597"`

**Nguyên nhân:** Công nhân đang dùng mã NVL thay thế (VD: `GBEC00-011`) nhưng BOM vẫn cấu hình mã cũ (`GBCP00-001`).

**Debug:**
```sql
-- Kiểm tra BOM của Model đang sản xuất
SELECT BD.MaterialCode AS [Mã_NVL_BOM], BD.MaterialName
FROM STB_BomDetail BD
JOIN STB_BomHeader BH ON BD.BomHeaderNo = BH.BomHeaderNo
WHERE BH.MaterialCode = 'Mã_Model_SX'
AND BD.MaterialCode LIKE 'GBE%'  -- Lọc các mã electrolyte
```

**Xử lý:**
1. **Đúng chuyên môn:** Báo EA/R&D kiểm tra BOM có cần cập nhật không
2. **IT fix tạm (chờ BOM update):** Vào SP `usp_Vietnam_RawMaterialInputHist_uid` → Tìm CTE `eleclyte1` → Thêm ngoại lệ:
```sql
-- Thêm vào CTE eleclyte1 trong SP:
UNION ALL
SELECT 'GBEC00-011' AS electrolyte, 'WEC3R0606QG' AS model, '1840' AS size
```

---

### 7.6 B597 báo lỗi "Chuỗi điện cực không khớp" (Electrode Thickness)

**Nguyên nhân:** NVL điện cực mới đăng ký thiếu hoặc sai Độ dày (`MaterialThickness`). Hệ thống so sánh chuỗi bị lỗi khi độ dày `200` != `200.000000`.

**Debug:**
```sql
-- Kiểm tra MaterialThickness trong Master
SELECT MaterialCode, MaterialThickness FROM STB_MaterialMaster
WHERE MaterialCode = 'Mã_Điện_Cực'

-- Kiểm tra độ dày đã nhập trong Lot (SIExtReal03)
SELECT Barcode, SIExtReal03 AS [Do_Day_Da_Nhap] FROM STB_SetInfo
WHERE Barcode = 'Mã_Barcode_Bị_Lỗi'
```

**Fix theo thứ tự:**
```sql
-- Fix 1: Sửa MaterialMaster thành số nguyên (không có .000)
UPDATE STB_MaterialMaster
SET MaterialThickness = '200'  -- Không phải '200.000000'
WHERE MaterialCode = 'Mã_Điện_Cực'

-- Fix 2: Nếu công nhân đã tạo Lot rồi → Sửa cả SIExtReal03
UPDATE STB_SetInfo
SET SIExtReal03 = 200  -- Số nguyên, không có thập phân
WHERE Barcode = 'Mã_Barcode'

-- Fix 3: Nếu lỗi liên quan đến bảng điện cực
UPDATE STB_ElectrodeWastePriceNew SET ElectrodeThickness = 200 WHERE [Điều_Kiện]
UPDATE STB_ElectrodeWasteInfoNew SET ElectrodeThickness = 200 WHERE [Điều_Kiện]
```

---

### 7.7 B597 báo lỗi HOLDING

**Nguyên nhân:** Lô NVL đang ở trạng thái HOLD do chưa qua IQC hoặc bị hold thủ công.

> ⚠️ **Xác minh DB (2026-05-17):** `STB_MaterialQcInfo` KHÔNG có cột `InspectionStatus` hay `HoldReason`. HOLD được xác định qua `MaterialWarehouseCode` trong `STB_MaterialLotInfo` (giá trị: `HOLDING_VN_WH`, `HOLDING_BG_WH`, `HOLDING_HN_WH`).

```sql
-- Kiểm tra Lot NVL có đang HOLD không
SELECT LotID, MaterialWarehouseCode, MaterialCode, CurrentQty
FROM STB_MaterialLotInfo
WHERE LotID = 'ML...'
-- Nếu MaterialWarehouseCode LIKE 'HOLDING_%' → Hàng đang bị giữ

-- Muốn bỏ HOLD (cần có sự đồng ý của QC) → Chuyển sang kho chính:
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_VN_WH',  -- Thay bằng kho đúng
    MaterialLocationCode = 'ROH_VN_WH_01'
WHERE LotID = 'ML...'
```

> Các giá trị HOLDING thực tế: `HOLDING_VN_WH` (Bắc Ninh), `HOLDING_BG_WH` (Bắc Giang), `HOLDING_HN_WH` (Hà Nam)

---

### 7.9 B597 báo lỗi "String or binary data would be truncated" khi quét gộp nhiều mã điện cực (Model 3510 / 35105)

**Nguyên nhân:** Khi quét gộp từ 5 mã barcode điện cực trở lên cho 1 Lot tại trạm B597, chuỗi ghép các barcode vượt quá giới hạn độ dài của cột `RawMaterialBarcode` trong bảng `STB_InputMaterialHistory` (được set là `NVARCHAR(100)`), dẫn đến lỗi truncation khi lưu. Đồng thời các biến tham số trong SP `usp_Vietnam_RawMaterialInputHist_uid` cũng bị giới hạn độ dài.

**Cách khắc phục:**
1. Tăng độ dài cột dữ liệu lên `NVARCHAR(1000)`:
   ```sql
   ALTER TABLE STB_InputMaterialHistory
   ALTER COLUMN RawMaterialBarcode NVARCHAR(1000) NULL;
   ```
2. Cập nhật stored procedure `usp_Vietnam_RawMaterialInputHist_uid` để đổi kiểu dữ liệu của tham số `@pRawMaterialBarcode` và các biến nội bộ (như `@RawMaterialBarcode`, `@LotMaterialBarcode`) thành `NVARCHAR(1000)`.

---

### 7.8 Màn hình C486 (Error Data Sorting): Nâng cấp giao diện (Thêm cột, Rebuild bảng & Fix layout grid)

**Yêu cầu:** Thêm 2 cột mới cho màn hình C486: `Invoice` (nằm trước `LotNo`) và `Note` (nằm sau `Total`) cho cả 2 nguyên vật liệu **ALCase** và **Plate**, giữ nguyên dữ liệu lịch sử và đúng thứ tự cột khi `SELECT *`.

#### 1. Phương pháp Rebuild bảng để giữ đúng thứ tự cột vật lý:
Do SQL Server không có lệnh `ALTER TABLE ADD COLUMN ... BEFORE/AFTER` giống MySQL, giải pháp là tạo bảng tạm `_NEW` đúng thứ tự -> Copy dữ liệu -> Drop bảng cũ -> Rename bảng mới:
```sql
BEGIN TRANSACTION;
BEGIN TRY
    -- B1. Tạo bảng tạm với đúng thứ tự cột mong muốn
    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] (
        [ID] INT IDENTITY(1,1) NOT NULL,
        ...
        [MaterialCode] NVARCHAR(50) NULL,
        [Invoice] NVARCHAR(100) NULL, -- << Cột mới đặt trước LotNo
        [LotNo] NVARCHAR(50) NULL,
        ...
        [Total] INT NULL,
        [Note] NVARCHAR(500) NULL, -- << Cột mới đặt sau Total
        [CreateUserID] VARCHAR(20) NULL, ...
    );

    -- B2. Bật IDENTITY_INSERT để copy dữ liệu lịch sử (cột mới để NULL)
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] ON;
    INSERT INTO [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] (ID, [Date], ..., Invoice, LotNo, ..., Total, Note, ...)
    SELECT ID, [Date], ..., NULL AS Invoice, LotNo, ..., Total, NULL AS Note, ...
    FROM [dbo].[STB_VVT_SortingErrorData_ALCase];
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] OFF;

    -- B3. Drop bảng cũ và đổi tên bảng mới
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

#### 2. Cập nhật các Stored Procedure:
* **SP GET (`usp_VVT_SortingErrorData_ALCase_get` / `usp_VVT_SortingErrorData_Plate_get`):** 
  Thêm cột mới vào đúng vị trí trong danh sách SELECT. Tránh lặp alias vô ích như `Note, Note AS [Note]`. Giữ nguyên ép kiểu `CAST(Qty AS VARCHAR(10))` để tránh lỗi định dạng khi người dùng copy-paste từ Excel vào Grid trên giao diện.
* **SP IUD (`usp_VVT_SortingErrorData_ALCase_iud` / `usp_VVT_SortingErrorData_Plate_iud`):** 
  Do SmartFramework đẩy dữ liệu lưu dưới dạng `@pXml`, cần thêm map các cột mới (`Invoice`, `Note`) ở 3 vị trí trong SP: phần `UPDATE T SET ...`, cấu trúc `WITH` của `OPENXML` (cho cả Update và Insert) và lệnh `INSERT INTO ... SELECT ...`.

#### 3. Xử lý lỗi layout grid (Ví dụ: Dư cột `Note1` trên giao diện):
* **Triệu chứng:** Cột `Note1` hiện ra trên Grid dù trong cấu trúc bảng DB không có cột này.
* **Nguyên nhân:** Khi người dùng thiết kế giao diện và nhấn **Save Layout**, SmartFramework chụp lại cấu hình lưới và lưu dưới dạng XML vào bảng `SmartFramework.dbo.STB_ScreenLayoutInfo`. Nếu trước đó có cột `Note1` (do gõ nhầm hoặc test), grid sẽ tự khôi phục cột này lên giao diện.
* **Cách check nhanh bằng SQL:**
  ```sql
  SELECT Name, DATALENGTH(XmlLayout) AS XmlLength, CHARINDEX('Note1', XmlLayout) AS Note1Position
  FROM SmartFramework.dbo.STB_ScreenLayoutInfo WITH (NOLOCK)
  WHERE Name = 'ErrorDataSorting'
  ```
* **Cách sửa triệt để:** Mở màn hình **C486**, kéo bỏ cột `Note1` ra khỏi lưới (hoặc ẩn đi trong Column Chooser), sau đó chuột phải chọn **Save Layout** để cập nhật đè cấu hình XML sạch lên database.

---

## 8. ⚡ Điện cực (Electrode)

### 8.1 Chỉnh chiều rộng Slitting (B552)

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

### 8.3 Checklist khi B597 báo lỗi khi lưu NVL

```
Theo thứ tự SP usp_Vietnam_RawMaterialInputHist_uid kiểm tra:
□ 1. HOLDING? → SELECT MaterialWarehouseCode FROM STB_MaterialLotInfo (Check 'HOLDING_%')
□ 2. Hết hạn? → Kiểm tra LotAttr10 + MMExtInt01 (xem KB_02 Mục 4.10)
□ 3. Sai chủng loại? → Kiểm tra BOM có mã NVL đó không (STB_BomDetail)
□ 4. Sai độ dày điện cực? → Kiểm tra MaterialThickness (phải là số nguyên)
□ 5. Sai mã Electrolyte? → Kiểm tra CTE eleclyte1 trong SP
□ 6. Thiếu cấu hình Vỏ Nhôm? → Sửa hardcode trong SP (Bảng AluCaseMapping không tồn tại)
□ 7. Thiếu cấu hình Slitting? → Kiểm tra STB_SLITTINGLOCATIONCONFIG_VVT
```

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

### 8.5 Lỗi popup không hiện dữ liệu ở B270

👉 **Chi tiết Trace & Fix:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md)

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
*   **Nguyên nhân:** Đây là model mới hoặc chưa được cấu hình Slitting trong Master Data. Hệ thống yêu cầu phải có cấu hình quy cách Slitting trong bảng `stb_slittinglocationconfig_vvt` (Màn hình B552) thì mới cho in tem.
*   **Cách khắc phục:**
    *   *Bước 1:* Thêm cấu hình Slitting cho model `3582` (cả cực dương `BY` và cực âm `YP`):
        ```sql
        BEGIN TRANSACTION;
        INSERT INTO stb_slittinglocationconfig_vvt
            (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse, RollQty, PositiveLocation, NegativeLocation)
        VALUES
            ('3582', 'BY', '200', '600', '39.34', 'VVT_F2', 'kho2', 20, 'A6-T3', 'B6-T3'),
            ('3582', 'YP', '180', '600', '39.34', 'VVT_F2', 'kho2', 20, 'A6-T3', 'B6-T3');
        COMMIT TRANSACTION;
        ```
    *   *Bước 2:* Đảm bảo đã khai báo model `3582-600F CY` vào bảng `STB_ModelBasicInfo` (A410) đầy đủ thông số Vol/Farad (Vol = '3R0', Farad = '600.0').

---

*Cập nhật: 2026-05-26*

---

### 8.7 Tổng Quan Quy Trình Sản Xuất & Kiểm Tra Chất Lượng Điện Cực (Electrode Flow)

Quy trình quản lý sản xuất và kiểm định chất lượng đối với công đoạn Điện cực được vận hành khép kín qua các bước sau:

#### 1. Lập Kế Hoạch & In Tem Điện Cực (B310, B442, A230)
*   **Tạo PO (B310):** Bộ phận kế hoạch khởi tạo đơn đặt hàng sản xuất PO làm căn cứ chạy chuyền.
*   **Tạo Kế hoạch ngày (B442):** Dựa trên PO tháng đã duyệt, kế hoạch ngày được lập trên B442. Khi kế hoạch được xác nhận lưu, hệ thống sẽ tự động sinh mã Lot điện cực và bắt đầu cho phép in tem nhãn.
*   **Liên kết độ dày vật liệu (A230):** Màn hình B442 liên kết trực tiếp với dữ liệu độ dày khai báo tại màn hình **A230 (Thông tin vật liệu)**. Tại tab "Mã nguyên liệu", nếu mã vạch barcode tương ứng đã được cài đặt thông số độ dày hoặc người dùng điền độ dày bên A230, hệ thống sẽ tự động liên kết và điền thông số này vào cột độ dày của B442. Nếu chưa được cấu hình, OP buộc phải nhập thủ công bằng tay (thao tác này dễ gây sai sót và chậm trễ).

#### 2. Vận Hành 4 Công Đoạn Điện Cực & Nhập Liệu trên B552
Quy trình sản xuất điện cực gồm 4 công đoạn chính và mỗi công đoạn tương ứng với một tab dữ liệu trên màn hình **B552**:
1.  **Mixing (Pha trộn):** 
    *   Sử dụng cấu hình cân điện cực thiết lập trên màn **B470** (Thẻ công đoạn do bên Kỹ thuật sản xuất - KTSP thiết lập và ban hành). 
    *   Hệ thống máy CMC sẽ thực hiện cân trộn theo công thức. Tab Mixing trên B552 sẽ tự động lấy dữ liệu từ hệ thống cân CMC sang. OP chỉ cần kiểm tra và nhập số lượng NG phát sinh (nếu có) lên hệ thống.
2.  **Coating (Phủ):** Tráng phủ hỗn hợp dung dịch điện cực lên foil. OP thực hiện nhập lượng phế NG phát sinh.
3.  **Rollpress (Ép):** Ép nén cuộn foil để đạt độ dày tiêu chuẩn và đảm bảo lớp phủ bám đều. OP nhập thông số NG.
4.  **Slitting (Cắt):** Cắt cuộn điện cực lớn thành các cuộn nhỏ theo kích thước spec yêu cầu để chuyển sang chuyền Cell lắp ráp. Tại tab Slitting trên B552, OP sẽ tiến hành tạo tem nhãn và in tem barcode dán lên từng cuộn điện cực sau khi cắt.

#### 3. Báo Cáo & Đối Soát Điện Cực (B802)
*   **B802 (Tra cứu lịch sử sản xuất điện cực):** Tra cứu toàn bộ thông tin sản lượng, phế thải (NG), chi phí sản xuất, và chi phí phế phẩm.
*   **⚠️ Lưu ý lỗi thiếu công đoạn:** Một mã Lot điện cực bắt buộc phải đi qua đầy đủ cả 4 công đoạn (Mixing, Coating, Rollpress, Slitting). Nếu trên báo cáo B802 hiển thị thiếu bất kỳ công đoạn nào, nguyên nhân chắc chắn là do OP quên hoặc chưa nhập đầy đủ dữ liệu công đoạn đó tại màn hình **B552**. Khi tra cứu trên B802, OP click vào một mã Lot cụ thể để hiển thị chi tiết thông số từng công đoạn ở tab phía dưới.
*   **Quy tắc nhập cột số liệu:**
    *   Cột `Defect (KG)`: Do OP nhập thủ công số kg phế thải thực tế cân được.
    *   Cột `Số lượng OK`: Số lượng cuộn/mét điện cực đạt chất lượng được OP nhập vào.
    *   Cột `Số lượng NG`: Số lượng cuộn/mét điện cực lỗi được OP nhập vào. Các cột chỉ số chi phí và tỷ lệ lỗi còn lại sẽ do hệ thống tự động tính theo công thức.

#### 4. Quy Trình Kiểm Tra Chất Lượng QC Điện Cực (C460, C141, C143)
*   Bên cạnh hệ thống cân CMC tự động, bộ phận QC thực hiện kiểm tra ngoại quan và đo đạc kích thước cơ lý của cuộn điện cực.
*   **C460 (Nhập kết quả kiểm tra QC):** Công nhân QC trực tiếp nhập các kết quả đo đạc kiểm tra cuộn điện cực tại đây.
*   **C141 & C143 (Thiết lập hạng mục kiểm tra):** Các hạng mục kiểm tra chung và spec dung sai riêng biệt cho từng model điện cực được định nghĩa trước tại màn hình **C141 (Hạng mục chung)** và **C143 (Spec theo Model)** để làm căn cứ cho C460 validate tự động.

---

### 8.8 Hỗ trợ lưu nhiều mã vạch nguyên vật liệu (Multi-barcode Appending) cho Điện cực và Vỏ Case

**Triệu chứng:** Khi sản xuất, một số Lot nguyên liệu (đặc biệt là điện cực hoặc vỏ Case) bị hết giữa chừng và cần bắn nối tiếp cuộn mới. Trước đây, hệ thống chỉ hỗ trợ tính năng này cho Điện cực, dẫn đến vỏ Case bị chặn hoặc ghi đè dữ liệu.

**Cách khắc phục:**
1. Cập nhật `usp_Vietnam_RawMaterialInputHist_uid` để:
   - Tách chuỗi barcode chứa dấu `;` khi kiểm tra trạng thái HOLD bằng hàm `usp_VVT_checkHOLD_Material`.
   - Tính toán `@count` hợp lệ bằng cách đếm và cộng dồn tất cả các barcode con trong danh sách.
   - Bật tính năng tự động nối chuỗi (`RawMaterialBarcode = existingRawBarcode + ' ; ' + newRawBarcode`) cho nhóm vật liệu `Case` thuộc các dòng máy size `3562`, `3582`, `35105` (bên cạnh nhóm `ELECTRODEP` và `ELECTRODEM` dùng cho mọi size).
   - Ghi nhận lịch sử cho cả hai nhóm này.
2. Cập nhật `usp_RawMaterialInputHist_get` sử dụng `FOR XML PATH('')` để gộp các barcode đã bắn thành chuỗi `; ` hiển thị lên lưới của màn hình.

*Chi tiết mã nguồn tham khảo các file:*
- SP UID: [usp_Vietnam_RawMaterialInputHist_uid.sql](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/sql/procedures/usp_Vietnam_RawMaterialInputHist_uid.sql)
- SP GET: [usp_RawMaterialInputHist_get.sql](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/sql/procedures/usp_RawMaterialInputHist_get.sql)

---

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
*Xem chi tiết các bước chạy rollback và reset dữ liệu tại file script [fix_c546_ocv_lots.sql](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/sql/scripts/fix_c546_ocv_lots.sql)*

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


## 10. ⚡ Điện Cực — Slitting Hà Nam (F743~F748, C243)

### 10.1 Flow Slitting Hà Nam

```
F744 (Thiết lập chiều rộng)
    → Thêm MaterialCode + Width + Đơn vị (M2 hoặc KG)
    → NG_ConPaper + NG_Poil: 2 mã đặc biệt KHÔNG được xóa/sửa
    ↓
F743 (Thực hiện Slitting)
    → Chọn MaterialCode → Tìm kiếm → Xem foil ban đầu (trái) + đã cắt (phải)
    → Thêm foil đã cắt: (+) → Chọn mã NVL con → Nhập Length → Save
    → Sau khi xong: Ấn "Chốt Slitting" → Chuyển sang C243
    → In tem: Tick chọn → Ấn "Phát hành tem" → Chọn máy in
    ↓
C243 (QC Kiểm tra Lot Slitting)
    → QC check sau khi Slitting đã chốt
    → Đánh giá OK: Tự động Pass + Chuyển NG_ConPaper/NG_Poil → kho NG
    → Đánh giá NG: Lot bị Reject → kho NG
    ↓
F746 (Lịch sử Slitting) → F747 (Lịch sử check NG/Pass) → F748 (Chuyển về kho NVL)
```

#### ⚠️ Hủy/Rollback Slitting (F742)
*   **Quy tắc:** Để thực hiện rollback cắt điện cực và cho phép cắt lại ở màn hình **F742**, bắt buộc phải xóa lịch sử ghi nhận ở màn hình **F746** trước.

**Lỗi thường gặp Slitting:**

| Lỗi | Nguyên nhân | Giải pháp |
|-----|-------------|-----------|
| "Trùng mã nguyên liệu" | Mã NVL đã thiết lập trong F744 rồi | Kiểm tra và sửa bản ghi cũ |
| Lot không tồn tại khi chuyển F430 | Lot chưa được QC check ở C243 | Vào C243 check trước |
| Không chuyển về kho được | Lot bị QC đánh Reject | Không thể chuyển — xử lý theo quy trình NG |

👉 **Chi tiết Script Fix (Thiết lập & Cấu hình Slitting):** Xem tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 4](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md).

---

## 11. 🔄 4M Change, CAPA & Phân Loại Mã Lỗi (Gộp từ KB_23)

Hệ thống quản lý biến động chất lượng hiện trường và quy trình xử lý hành động khắc phục/phòng ngừa.

### 11.1 Quản Lý Thay Đổi 4M (Man, Machine, Material, Method)
Ghi nhận mọi biến động liên quan đến con người, máy móc, nguyên vật liệu hoặc phương pháp sản xuất qua bảng `STB_QC4MChangeDataRecord`.
Màn hình: `VVT_DoCreateQC4MChange` (Tạo mới), `VVT_ViewDetailQC4MChange` (Phê duyệt), `VVT_View4MChange` (Xem lịch sử).

```sql
-- Xem các bản ghi 4M Change gần đây
SELECT QC4MNo, ChangeType4M, Model, LineCode, RouteCode,
       ReasonForChange, Status, ApprovalDate, EffectiveDate
FROM STB_QC4MChangeDataRecord
WHERE CreateDateTime >= DATEADD(MONTH, -1, GETDATE())
ORDER BY CreateDateTime DESC;

-- Lọc theo thay đổi Nguyên vật liệu (Material)
SELECT * FROM STB_QC4MChangeDataRecord
WHERE ChangeType4M = 'Material'
ORDER BY CreateDateTime DESC;
```

### 11.2 CAPA (Corrective And Preventive Action)
Khi phát hiện lỗi hệ thống hoặc lỗi nghiêm trọng từ khách hàng, Lot hàng bị ảnh hưởng sẽ được tách riêng tại màn hình `VVT_CAPAInputSeparateLot` để kiểm tra đánh giá trước khi thực hiện hành động khắc phục.

### 11.3 Sửa Chữa Sản Phẩm Lỗi (Defect Repair)
Sản phẩm lỗi được tái chế/sửa chữa và ghi nhận tại các bảng:
*   `STB_DefectRepairInfo`: Thông tin chung về sửa chữa sản phẩm lỗi.
*   `STB_DefectRepairDetailInfo`: Chi tiết công đoạn/hạng mục sửa chữa.
*   `STB_DefectRepairPartInfo`: Phụ tùng hoặc vật tư tiêu hao dùng cho sửa chữa.

```sql
-- Xem lịch sử sửa chữa sản phẩm lỗi trong tuần
SELECT * FROM STB_DefectRepairInfo
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
ORDER BY CreateDateTime DESC;
```

### 11.4 Phân Loại Nhóm Lỗi & Nguyên Nhân (Defect Master)
Danh sách mã lỗi nghiệp vụ được lưu trữ tập trung để phục vụ thống kê:
*   `STB_DefectGroup`: Nhóm lỗi lớn (Major, Minor, Critical).
*   `STB_DefectInfo`: Danh mục mã lỗi chi tiết hiển thị trên các màn hình scan.
*   `STB_DefectCauseGroup`: Nhóm nguyên nhân lỗi.
*   `STB_DefectCauseInfo`: Chi tiết nguyên nhân lỗi.

```sql
-- Xem danh sách mã lỗi đang hoạt động (IsUsed=1)
SELECT DefectCode, DefectName, DefectGroupCode
FROM STB_DefectInfo
WHERE IsUsed = 1
ORDER BY DefectGroupCode, DefectCode;
```

### 11.5 Báo Cáo Chất Lượng QC (QC Defect Reports)
Các bảng ghi nhận chi tiết lỗi IQC/PQC/OQC:
*   `STB_QcDefectReport`: Báo cáo lỗi QC chung.
*   `STB_IOQCDefectInfo` & `STB_IOQCDefectDetail`: Thông tin chi tiết lỗi IQC và OQC.
*   `STB_QCDefectDetailsRecord`: Nhật ký record lỗi chi tiết.

---

## 12. 🔬 Reliability Test — Kiểm Tra Độ Tin Cậy (Gộp từ KB_24)

Quy trình thử nghiệm sản phẩm tụ điện trong môi trường khắc nghiệt (nhiệt độ cao, điện áp cao, độ ẩm cao) để đánh giá tuổi thọ và độ ổn định.

### 12.1 Quy Trình Vận Hành
1.  **Tạo Request (`STB_ReliabilityTestRequestInfo`):** Bộ phận QC hoặc R&D gửi yêu cầu kiểm tra, xác định Lot sản xuất hàng loạt cần test và điều kiện kiểm tra (ESR, dung lượng, dòng rò).
2.  **Lấy Mẫu (`STB_ReliabilityTestSampleInfo`):** Tiếp nhận yêu cầu, tách Lot mẫu, khai báo điều kiện test (Điện áp, Nhiệt độ, Độ ẩm) và số lượng mẫu kiểm tra.
3.  **Đo Lường Định Kỳ (`STB_ReliabilityTestMeasureInfo`):** Tiến hành đo thông số tụ điện theo chu kỳ (Cycle 1, 2, 3...) và ghi nhận kết quả OCV, ESR, dung lượng.
4.  **Kết luận & Đóng yêu cầu.**

### 12.2 Truy Vấn Dữ Liệu Kiểm Thử
```sql
-- Xem các yêu cầu kiểm tra độ tin cậy gần đây
SELECT RTRequestNo, RequestDate, MassProductionLotNo,
       TestPurposeComment, RequesterID, TestClassCode
FROM STB_ReliabilityTestRequestInfo
ORDER BY RequestDate DESC;

-- Xem thông tin mẫu đang kiểm tra
SELECT RTSampleNo, RTRequestNo, SampleLotNo, SampleQty,
       VoltCondition, TemperatureCondition, HumidityCondition
FROM STB_ReliabilityTestSampleInfo
ORDER BY CreateDateTime DESC;

-- Xem kết quả đo kiểm chi tiết theo chu kỳ của một Lot
SELECT RTDate, MeasureCycle, SampleLotNo, SampleSeqNo,
       TestName, MeasureValue, CharacterizationCode
FROM STB_ReliabilityTestMeasureInfo
WHERE SampleLotNo = 'LOT_CẦN_TRA'
ORDER BY MeasureCycle, SampleSeqNo;
```

---

> 📌 **Phân tích sâu & DB Audit:** Xem chi tiết phân tích kiến trúc database, DNA hệ thống và kết quả Audit tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md).

*Cập nhật: 2026-06-14 | Gộp nội dung từ KB_23 và KB_24 để đồng bộ hoá tri thức quản lý chất lượng (QC)*


