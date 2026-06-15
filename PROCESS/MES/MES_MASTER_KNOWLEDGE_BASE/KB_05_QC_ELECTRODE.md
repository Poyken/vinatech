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

*   **Triệu chứng:** Khi quét gộp từ 5 mã barcode điện cực trở lên cho 1 Lot tại trạm B597, hệ thống báo lỗi đỏ `"String or binary data would be truncated"` và không cho lưu.
*   **Chi tiết & Giải pháp:** Xem chi tiết nguyên nhân gốc và SQL script khắc phục tại [Mục Lỗi 3](#lỗi-3-lỗi-string-or-binary-data-would-be-truncated-khi-quét-gộp-5-mã-điện-cực-1-lot-model-3510--35105) bên dưới.

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

👉 **Chi tiết Trace & Fix:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](KB_01_UI_PHAN_QUYEN.md)

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

*   **Mô tả:** Hệ thống hỗ trợ bắn nối tiếp nhiều cuộn nguyên vật liệu khác nhau (ngăn cách bởi dấu `;`) trên cùng một Lot sản phẩm để tránh trường hợp cuộn cũ hết giữa chừng nhưng Lot chưa chạy xong.
*   **Chi tiết & Giải pháp:** Xem chi tiết về logic kiểm tra và lưu trong SP `usp_Vietnam_RawMaterialInputHist_uid`, cũng như cách gộp hiển thị trên lưới tại [KB_03_SAN_XUAT.md#619-hỗ-trợ-lưu-nhiều-mã-vạch-nguyên-vật-liệu-multi-barcode-appending-cho-điện-cực-và-vỏ-case](KB_03_SAN_XUAT.md#619-hỗ-trợ-lưu-nhiều-mã-vạch-nguyên-vật-liệu-multi-barcode-appending-cho-điện-cực-và-vỏ-case).

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




---

## 🔴 Cẩm nang khắc phục lỗi theo Screen ID (Gộp từ KB_SCREEN_BUG_REF)

## B597 — Material Scanning & PQC Verification (Scan nguyên vật liệu đầu vào chuyền)

### Lỗi 1: Cảnh báo đỏ chặn không cho lưu Lot NVL đầu vào (HOLD, Hết hạn, Sai chủng loại)
*   **Triệu chứng:** Khi quét mã Lot nguyên liệu đầu vào tại **B597**, hệ thống báo lỗi đỏ cấm sử dụng.
*   **Nguyên nhân gốc:** Lot đang nằm ở kho ảo `HOLDING_WH` (chưa QC), hoặc ngày hết hạn sử dụng vượt quá ngày hiện tại (vi phạm FIFO/Expiry), hoặc mã nguyên liệu không nằm trong BOM cấu hình của PO.
*   **Cách khắc phục:**
    1. Check QC: Yêu cầu QC PASS hoặc chuyển kho Lot về kho chính `ROH_WH` bằng SQL.
    2. Bypass gia hạn dùng tạm thời (Ghi nhận biên bản audit): UPDATE ngày tạo `CreateDateTime` lùi lại hoặc chạy lệnh bỏ qua FIFO.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7](KB_05_QC_ELECTRODE.md#7-lỗi-quét-nguyên-vật-liệu-b597--pqc-check).

### Lỗi 2: Lỗi quét vỏ nhôm (AluCase) mới báo sai chủng loại tại B597
*   **Triệu chứng:** Quét mã vỏ nhôm mới hệ thống báo lỗi chặn đứng sản xuất.
*   **Nguyên nhân gốc:** Logic kiểm tra vỏ nhôm không nằm trong DB cấu hình mà bị hardcode trực tiếp trong SP `usp_Vietnam_RawMaterialInputHist_uid`.
*   **Cách khắc phục:**
    ALTER SP `usp_Vietnam_RawMaterialInputHist_uid` để bổ sung mã vỏ nhôm mới vào khối điều kiện `IF / NOT IN`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.4](KB_05_QC_ELECTRODE.md#74-lỗi-vỏ-nhôm-alucase).

### Lỗi 3: Lỗi "String or binary data would be truncated" khi quét gộp 5 mã điện cực 1 Lot (Model 3510 / 35105)
*   **Triệu chứng:** Khi quét gộp 5 mã barcode điện cực cho 1 Lot tại B597, hệ thống báo lỗi đỏ `"String or binary data would be truncated"` và không cho lưu.
*   **Nguyên nhân gốc:** Cột `RawMaterialBarcode` của bảng `STB_InputMaterialHistory` có giới hạn độ dài `NVARCHAR(100)`, trong khi chuỗi ghép từ 5 mã điện cực vượt quá giới hạn này (thường dài khoảng 102+ ký tự). Các tham số và biến nội bộ trong SP `usp_Vietnam_RawMaterialInputHist_uid` cũng bị giới hạn độ dài (`NVARCHAR(200)` hoặc `NVARCHAR(100)`).
*   **Cách khắc phục:**
    1. Cập nhật độ dài cột lên `NVARCHAR(1000)`:
       ```sql
       ALTER TABLE STB_InputMaterialHistory ALTER COLUMN RawMaterialBarcode NVARCHAR(1000) NULL;
       ```
    2. Sửa tham số `@pRawMaterialBarcode` và các biến nội bộ chứa chuỗi ghép barcode (ví dụ: `@RawMaterialBarcode`, `@LotMaterialBarcode`) trong stored procedure `usp_Vietnam_RawMaterialInputHist_uid` thành `NVARCHAR(1000)`.
*   **Chi tiết nghiệp vụ:** Xem file script [fix_multibarcode_3510.sql](../sql/scripts/fix_multibarcode_3510.sql).

---


## B598 — Material Scrap Report (Báo phế nguyên vật liệu trên chuyền)

### Lỗi 1: Báo phế NVL bị lỗi không ghi nhận hệ thống
*   **Triệu chứng:** Báo phế NVL tại chuyền ở màn hình **B598** bị chặn hoặc không đồng bộ số lượng.
*   **Nguyên nhân gốc:** Lệch ngày `JobDate` giữa ca sản xuất thực tế và ngày khai báo kế hoạch trên MES.
*   **Cách khắc phục:**
    Chạy query cập nhật điều chỉnh `JobDate` của Lot kế hoạch ngày khớp với thực tế để mở luồng ghi nhận phế.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.12](KB_03_SAN_XUAT.md#612-b598-báo-phế-nvl-sửa-jobdate-đặc-biệt).

---


## C121 / C122 — QC Inspections (Cấu hình QC đầu vào)

### Lỗi 1: Lot nguyên liệu nhập kho không tự động hiển thị các hạng mục kiểm tra QC
*   **Triệu chứng:** Lot nguyên liệu hiển thị trên lưới QC nhưng không có bất kỳ hạng mục nào để nhập kết quả đo.
*   **Nguyên nhân gốc:** Chưa gán mã nguyên vật liệu vào nhóm hạng mục kiểm tra IQC tại màn hình **C122** hoặc chưa cấu hình nhóm kiểm tra tại **C121**.
*   **Cách khắc phục:**
    1. Vào **C121** thêm nhóm kiểm tra và các hạng mục chi tiết.
    2. Vào **C122**, chọn mã nguyên vật liệu và click chọn nhóm kiểm tra tương ứng để map dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.1](KB_05_QC_ELECTRODE.md#91-iqc-incoming-quality-control--kiểm-tra-nvl-đầu-vào).

---


## C220 — IQC Incoming Quality Control (Xác nhận kết quả IQC)

### Lỗi 1: Lỗi bị chặn "Receiving Confirmation" khi gộp nhập kho tại F330
*   **Triệu chứng:** Thủ kho bấm nhận hàng tại **F330** hệ thống báo lỗi chặn giao dịch.
*   **Nguyên nhân gốc:** Kết quả kiểm tra mẫu IQC của Lot hàng tại màn hình **C220** vẫn ở trạng thái chờ đánh giá hoặc đã bị đánh giá FAIL.
*   **Cách khắc phục:**
    Yêu cầu bộ phận QC hoàn thành nhập kết quả đo và xác nhận cờ chất lượng PASS cho Lot hàng trên màn hình **C220**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.15](KB_02_KHO_WMS.md#415-luồng-nhập-kho-đầy-đủ-f330).

---


## C321 / HNC321 — Defect Repair & Scrap Management (Quản lý sửa chữa & báo phế sản phẩm)

### Lỗi 1: Lỗi chặn lưu "이전 공정에 실적처리 이력이 없습니다" (Không có lịch sử công đoạn trước) tại HNC321
*   **Triệu chứng:** Khi OP nhập số lượng phế cho Barcode tại trạm kiểm tra (Ví dụ: `VE08`), hệ thống chặn lại và báo lỗi tiếng Hàn.
*   **Nguyên nhân gốc:** Stored Procedure `usp_Vietnam_ScrapInput_HN` chặn giao dịch nếu sản phẩm chưa từng có lịch sử chốt sản lượng (Routing History) ở công đoạn ngay trước đó (Ví dụ: `VE07`).
*   **Cách khắc phục:** IT kiểm tra công đoạn trước và chèn một dòng Routing giả lập để thông luồng:
    ```sql
    BEGIN TRANSACTION;
    DECLARE @CtrlNo NVARCHAR(50) = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE');
    INSERT INTO STB_ProdRouteHist 
        (ControlNo, ProcSeq, RouteCode, LineCode, MachineCode, InQty, OutQty, JobDate, ShiftCode, CreateUserID, CreateDateTime)
    VALUES 
        (@CtrlNo, 
         (SELECT ISNULL(MAX(ProcSeq), 0) + 1 FROM STB_ProdRouteHist WHERE ControlNo = @CtrlNo), 
         'MÃ_CÔNG_ĐOẠN_TRƯỚC',  -- Ví dụ: VE07
         'MÃ_LINE_HIỆN_TẠI', 'MÃ_MÁY_HIỆN_TẠI', 20, 20, CAST(GETDATE() AS DATE), 'A', 'vinaadmin', GETDATE());
    COMMIT TRANSACTION;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4](KB_02_KHO_WMS.md#4-lỗi-màn-hnc321-qc-nhập-ng-sản-phẩm-mang-đi-kiểm-tra--báo-lỗi-chữ-hàn-quốc) và [Kịch bản 3](#kịch-bản-sự-cố-khẩn-cấp-3-lỗi-nhập-phế-hnc321-báo-lỗi-tiếng-hàn).

### Lỗi 2: Nhập phế/sửa chữa tại C321 báo lỗi hoặc không cập nhật được thông số sửa chữa
*   **Triệu chứng:** OP không lưu được thông tin sửa chữa/vật tư thay thế, hoặc bị sai lệch số lượng NG (`DefectQty`) ở các trạm tiếp theo.
*   **Nguyên nhân gốc:** Lỗi khi đồng bộ dữ liệu giữa bảng thông tin lỗi `STB_DefectRepairInfo` và số lượng chốt sản lượng của công đoạn.
*   **Cách khắc phục:** IT kiểm tra thông số và cập nhật đồng bộ lại cột `DefectQty` hoặc `ProdQty` bằng cách chỉnh sửa trực tiếp DB.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.5](KB_05_QC_ELECTRODE.md#95-c321---pqc-reliability-assy-sửa-chữa-lỗi-cell-line).

---


## C443 — PQC Quality Verification (Hủy/xác định lại kết quả QC)

### Lỗi 1: Cần hủy kết quả kiểm tra QC (nhập nhầm thông số hoặc load nhầm hạng mục đo)
*   **Triệu chứng:** Lot sản phẩm bị lock trạng thái FAIL do QC lưu sai thông số đo, cần mở ra đo lại từ đầu.
*   **Nguyên nhân gốc:** Dữ liệu QC đã được ghi nhận vào các bảng giao dịch `STB_CommInspDocHistory` và `STB_CommInspDocItem` nên không thể sửa đổi trên UI.
*   **Cách khắc phục:** Chạy SQL xóa tài liệu QC bị sai để QC có thể thực hiện kiểm định lại từ đầu trên giao diện:
    ```sql
    BEGIN TRANSACTION;
    DECLARE @DocNo NVARCHAR(50) = (SELECT CIDH.CommInspDocNo FROM STB_CommInspDocHistory CIDH JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo WHERE SI.Barcode = 'MÃ_BARCODE');
    DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = @DocNo;
    DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = @DocNo;
    COMMIT TRANSACTION;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [Kịch bản 1](#kịch-bản-sự-cố-khẩn-cấp-1-hủy-kết-quả-kiểm-tra-chất-lượng-qc-b597c443).

---


## C486 — QC Measuring Items (Đo kích thước điện cực)

### Lỗi 1: Thừa cột Note1 trên lưới dữ liệu / thứ tự cột nhập liệu bị xáo trộn
*   **Triệu chứng:** Giao diện grid nhập liệu đo kích thước điện cực tại màn hình **C486** bị lỗi thừa cột rác hoặc các dòng nhập liệu không đúng thứ tự.
*   **Nguyên nhân gốc:** Lỗi cấu hình metadata của grid trong DB `SmartFramework`.
*   **Cách khắc phục:**
    Chạy lệnh SQL để rebuild lại cấu trúc grid của màn hình:
    ```sql
    -- Script reset metadata layout cho grid C486
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.8](KB_05_QC_ELECTRODE.md#78-cột-note1-thừa-trên-grid-c486-và-logic-rebuild-bảng).

---


## C512 / C530 / C546 — OQC Lot Management (Quản lý chất lượng đầu ra)

### Lỗi 1: Lỗi không tìm thấy Lot khi tạo hồ sơ kiểm tra OQC ở C512
*   **Triệu chứng:** Bấm tạo Lot OQC tại **C512** hệ thống báo không tìm thấy bản ghi Lot nào của sản phẩm.
*   **Nguyên nhân gốc:** Lot sản phẩm chưa hoàn thành công đoạn đóng gói cuối (chưa gộp Box tại B523) hoặc PO chưa cấu hình cờ đầu ra sản phẩm `IsOutputRoute = 1`.
*   **Cách khắc phục:**
    1. Kiểm tra Lot đã được quét gộp box tại B523 chưa.
    2. Sửa cờ `IsOutputRoute = 1` cho công đoạn cuối của PO trong `STB_ProductionOrderRouting` nếu cấu hình BOM/Routing bị thiếu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.2](KB_05_QC_ELECTRODE.md#72-không-tìm-thấy-lot-ở-màn-c512).

### Lỗi 2: Đo OQC OCV/ESR tại C546 chỉ hiển thị 20 dòng thay vì 50 dòng
*   **Triệu chứng:** Máy đo trả về kết quả cho 50 mẫu test nhưng trên giao diện C546 hệ thống chỉ load và hiển thị 20 dòng mẫu đo (lưới OCV/ESR hiển thị không đủ 50 dòng trống để nhập/hiển thị).
*   **Nguyên nhân gốc:** 
    1. SP get kết quả mẫu `usp_MaterialQcSampleResult_get` bị thiếu pattern `'FOQC_V01_07/08'`.
    2. SP get chi tiết màn hình `usp_Vietnam_MaterialFOQcDetail_get` bị thiếu block khởi tạo dữ liệu cho hạng mục OCV (`DetailNo = 2`). Trong khi hạng mục ESR (`DetailNo = 3`) và các mục khác đều có block khởi tạo để tạo đủ 50 dòng trống, khiến lưới OCV chỉ hiển thị tối đa theo số dòng thực tế đo được từ máy đo (ví dụ: 20 dòng) thay vì 50 dòng chuẩn.
*   **Cách khắc phục:**
    1. Deploy SP `usp_Vietnam_MaterialFOQcDetail_get` và `usp_MaterialQcSampleResult_get` đã sửa đổi (bổ sung block khởi tạo cho OCV DetailNo = 2).
    2. Chạy SQL Script để xóa kết quả lỗi cũ và reset trạng thái upload trong monitor để máy đo đẩy lại dữ liệu:
       ```sql
       BEGIN TRANSACTION;
       -- B1: Xóa kết quả QC cũ bị lệch
       DELETE FROM STB_MaterialQcSampleResult WHERE MaterialQcNo = 'F_MÃ_BARCODE' AND MaterialQcDetailNo IN (2, 3);
       
       -- B2: Reset trạng thái upload trong bảng Monitor (Set NULL để SP chạy nạp lại từ đầu)
       UPDATE Stb_ESRValueMonitor SET UploadToMes = NULL, UploadOCVToMess = NULL WHERE lotno = 'MÃ_LOT';
       
       -- B3: Reset trạng thái đánh giá trong bảng Detail để QC load lại dữ liệu
       UPDATE STB_MaterialQcDetail SET DecisionResult = NULL, PassedSampleQty = 0 WHERE MaterialQcNo = 'F_MÃ_BARCODE' AND MaterialQcDetailNo IN (2, 3);
       COMMIT TRANSACTION;
       ```
    3. Yêu cầu QC tắt và mở lại màn hình C546, quét lại Barcode để hệ thống sinh đủ 50 dòng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.6](KB_05_QC_ELECTRODE.md#96-c546-foqc-ocvsr-chỉ-hiển-thị-20ea-thay-vì-50ea-ocv-lệch-dữ-liệu) và file script vá lỗi [fix_c546_ocv_lots.sql](../sql/scripts/fix_c546_ocv_lots.sql).

### Lỗi 3: Đo kiểm ESR tại C530 chỉ hiển thị 10 dòng kết quả thay vì 20 dòng mẫu đo
*   **Triệu chứng:** Khi mở màn hình [C530] để nhập kết quả đo cho hạng mục ESR với số lượng mẫu (Sample Qty) thiết lập là 20, lưới kết quả đo bên phải chỉ hiển thị đúng 10 dòng kết quả đo từ máy đo và không sinh ra thêm 10 dòng trống tiếp theo để điền cho đủ 20 dòng.
*   **Nguyên nhân gốc:** 
    1. **Nghiệp vụ:** Số lượng mẫu đo từ máy bị thiếu (Máy đo ESR chỉ thực hiện đo và đẩy về 10 giá trị vào bảng `Stb_ESRValueMonitor` với trạng thái `UploadToMes IS NULL`). Hoặc Lot QC này chưa được nhấn nút "Tạo danh sách mẫu" (Create Sample List) sau khi cấu hình số lượng mẫu ESR tăng lên 20, nên danh sách mẫu trống chưa được sinh ra đầy đủ trước khi đồng bộ.
    2. **Logic Stored Procedure (`usp_MaterialQcSampleResult_get`):** Khi màn hình load kết quả đo, logic xử lý đồng bộ từ máy đo gặp vấn đề như sau:
        *   **Bước A (Xóa dòng trống cũ để chuẩn bị ghi đè):** tại dòng L155-L161:
            ```sql
            select @value7=count(*) from Stb_ESRValueMonitor where lotno=@value3 and UploadToMes is null
            if(@value7 > 0)
            begin
                  delete top(@value7) from STB_MaterialQcSampleResult where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
            end
            ```
            Nếu máy đo đẩy về 10 giá trị (`@value7 = 10`), SP sẽ xóa đi 10 dòng trống (`TestValue IS NULL`) đang có trong bảng kết quả mẫu `STB_MaterialQcSampleResult`.
        *   **Bước B (Vòng lặp bù dòng bị lệch chỉ số / Index Offset Bug):** tại dòng L225, SP đếm số dòng còn lại sau khi xóa:
            ```sql
            select @cnt= count(*) from STB_MaterialQcSampleResult where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo
            ```
            Giả sử ban đầu hệ thống có sẵn 20 dòng trống, sau khi xóa 10 dòng ở Bước A, `@cnt` còn lại là 10. SP chạy vòng lặp từ `@cnt` đến `@SampleQty` (từ 10 đến 19) để chèn kết quả đo hoặc bù dòng trống tại dòng L300:
            ```sql
            select top(1) @value = Val, @value1 = MonitorID from @TempESR where RowID = (@cnt + 1)
            ```
            Khi `@cnt` bắt đầu từ 10, chỉ số lấy dữ liệu sẽ là `RowID = 11`. Tuy nhiên, bảng tạm `@TempESR` (chứa dữ liệu từ máy đo) chỉ có 10 dòng (RowID từ 1 đến 10). Do đó, lượt truy vấn `RowID = 11` đến 20 sẽ trả về giá trị `@value = NULL`, nhảy vào nhánh `else` và chèn thêm 10 dòng trống.
            **Hậu quả:** 10 giá trị đo thực tế trong `@TempESR` bị bỏ qua không được lưu, thay vào đó hệ thống chỉ tạo thêm 10 dòng trống (NULL).
        *   **Bước C (Khi dữ liệu đã upload xong):** Ở lần load tiếp theo (hoặc trạng thái upload trong `Stb_ESRValueMonitor` đã là `'OK'`), biến `@cntexit1` = 0 khiến SP bỏ qua toàn bộ block xử lý đồng bộ và chỉ `SELECT` trực tiếp các bản ghi đang có sẵn trong `STB_MaterialQcSampleResult`. Nếu trước đó bảng này chỉ lưu đúng 10 dòng có giá trị, lưới bên phải sẽ chỉ hiển thị đúng 10 dòng đó mà không tự động sinh thêm 10 dòng trống cho đủ 20 dòng mẫu tiêu chuẩn.
*   **Cách khắc phục:**
    1. **QC thao tác nhanh:** Chọn hạng mục **ESR** ở lưới bên trái của màn hình [C530] và bấm nút **"Tạo danh sách mẫu"** (Nút màu xanh có icon danh sách và dấu tích ở góc trái phía trên của lưới bên trái - Create IQC Item Sample List) để kích hoạt SP `usp_DoMakeMaterialQcSampleResult.sql` quét lại thiết lập `SampleQty = 20` và tự động sinh thêm 10 dòng trống tiếp theo (từ dòng 11 đến 20) vào bảng kết quả đo.
    2. **Khắc phục logic trong SP:** Đồng bộ/sửa đổi logic khởi tạo của SP `usp_MaterialQcSampleResult_get` để tránh lệch chỉ số khi số lượng mẫu đo từ máy truyền về ít hơn số lượng mẫu thiết lập trong tiêu chuẩn.

### Lỗi 4: Lỗi "검사항목이 등록되어있지 않습니다" (Chưa đăng ký hạng mục kiểm tra) khi tạo Lot OQC tại C512
*   **Triệu chứng:** Khi bấm tạo Lot OQC tại màn hình **C512**, hệ thống báo lỗi tiếng Hàn `"검사항목이 등록되어있지 않습니다"` và chặn không cho tiến hành.
*   **Nguyên nhân gốc:** Model sản phẩm mới (ví dụ: `LIVT38-037`) chưa được cấu hình thuộc tính OQC trong bảng `STB_ModelBasicInfo` (bị trống các cột `OqcType`, `InspectionType`, `OqcInspectionRuleType`) và không có bản ghi hạng mục đo kiểm tiêu chuẩn nào trong bảng `STB_MaterialQcInspectionItem`.
*   **Cách khắc phục:**
    *   **Bằng SQL:**
        1. Cập nhật thuộc tính kiểm định trong `STB_ModelBasicInfo`:
           ```sql
           UPDATE STB_ModelBasicInfo SET OqcType = 'MANUAL', OqcInspectionRuleType = 'BY_MODEL' WHERE ModelCode = 'LIVT38-037';
           ```
        2. Copy các hạng mục kiểm tra chuẩn (ví dụ từ model cùng loại `LIVT38-010`) sang cho model mới trong bảng `STB_MaterialQcInspectionItem`.
    *   **Bằng UI (Dành cho User):**
        1. Mở màn hình **A410**, tìm model `LIVT38-037` và cập nhật: `OqcType` = `MANUAL`, `OqcInspectionRuleType` = `BY_MODEL`, `InspectionType` = `SAMPLE`. Nhấn **Lưu**.
        2. Tắt và mở lại màn hình **C151**, chọn model `LIVT38-037` rồi gán và Lưu spec cho 5 hạng mục QC chính (`IQC_GPD_22`, `PQC_V01_06`, `PQC_V01_07`, `PQC_V01_08`, `PQC_V01_09`) tương tự `LIVT38-010`.
*   **Chi tiết nghiệp vụ:** Xem file script [fix_qc_items_LIVT38-037.sql](../sql/scripts/fix_qc_items_LIVT38-037.sql).

---


## C561 / C562 / C563 / C564 — Bending/Cutting QC (Kiểm tra chất lượng uốn/cắt Cell)

### Lỗi 1: Quét Barcode tại C563 báo lỗi thiếu hạng mục đo hoặc không hiển thị thông số đo
*   **Triệu chứng:** Khi mở màn hình kiểm định uốn/cắt **C563** và quét barcode của mẫu uốn/cắt Cell, lưới đo trống trơn hoặc báo lỗi chặn.
*   **Nguyên nhân gốc:** Model sản phẩm chưa được cấu hình nhóm hạng mục kiểm tra QC tại **C561** hoặc chưa được tạo Lot kiểm định tại **C562**.
*   **Cách khắc phục:**
    1. Vào màn hình **C561**, tìm đúng `MaterialCode`, chọn nhóm kiểm tra và Lưu lại.
    2. Vào màn hình **C562**, quét barcode sản phẩm để sinh Lot kiểm định.
    3. Quay lại màn hình **C563** thực hiện nhập dữ liệu. Nếu đã cấu hình mà vẫn trống, nhấn nút `"Tổng hợp hạng mục"` để đồng bộ và làm mới danh sách đo.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](KB_05_QC_ELECTRODE.md#94-bendingcutting-qc-c561c564).

---


## C112 — AQL Basic Rules (Quy tắc AQL cơ bản)

### Lỗi 1: Cấu hình mẫu kiểm tra AQL không áp dụng đúng cho OQC
*   **Triệu chứng:** Khi tạo hồ sơ OQC tại C512, số lượng mẫu lấy kiểm tra không đúng với quy tắc AQL.
*   **Nguyên nhân gốc:** Bảng quy tắc AQL chưa được cấu hình cho kích thước lô hàng tương ứng.
*   **Cách khắc phục:** Vào C112, kiểm tra và bổ sung quy tắc AQL cho size lô hàng (Lot Size) phù hợp.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_19_ALL_DATABASES_MAP.md](KB_19_ALL_DATABASES_MAP.md).

---


## C122 — IQC Material Inspection Setup (Thiết lập hạng mục kiểm tra NVL)

> 🔗 **Xem thêm:** Mục [C121 / C122](#c121--c122--qc-inspections) phía trên đã có chi tiết cấu hình QC đầu vào.

### Lỗi 1: Lot NVL nhập kho không tự động hiện hạng mục kiểm tra
*   **Triệu chứng:** Lot nguyên liệu hiển thị trên lưới QC nhưng không có hạng mục để nhập kết quả đo.
*   **Nguyên nhân gốc:** Mã NVL chưa được gán nhóm hạng mục kiểm tra IQC tại C122.
*   **Cách khắc phục:** Vào C122, chọn mã NVL, click chọn nhóm kiểm tra tương ứng để map dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.1](KB_05_QC_ELECTRODE.md).

---


## C131 — Inspection Item Master (Danh mục hạng mục kiểm tra)

### Lỗi 1: Thêm hạng mục kiểm tra mới không hiển thị tại C143
*   **Triệu chứng:** Hạng mục đo mới tạo tại C131 không xuất hiện khi cấu hình kiểm tra tại C143.
*   **Nguyên nhân gốc:** Cờ `IsUsed = 0` hoặc loại dữ liệu nhập (`DataType`) chưa được thiết lập đúng (1=số, 2=checkbox).
*   **Cách khắc phục:** Vào C131 kiểm tra cờ `IsUsed=1` và chọn DataType phù hợp.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 14](KB_06_MASTER_DATA_TOOLS.md).

---


## C132 — Inspection Group Setup (Thiết lập nhóm kiểm tra)

### Lỗi 1: Nhóm kiểm tra QC không hiển thị khi gán cho NVL tại C122 hoặc sản phẩm tại C143
*   **Triệu chứng:** Khi mở popup chọn nhóm kiểm tra, danh sách trống hoặc thiếu nhóm mới tạo.
*   **Nguyên nhân gốc:** Nhóm kiểm tra chưa được kích hoạt (`IsUsed = 0`) hoặc chưa được gán MaterialTypeCode phù hợp.
*   **Cách khắc phục:** Vào C132 kiểm tra nhóm mới, tick `IsUsed=1`, chọn đúng MaterialTypeCode.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md) và [KB_10_KIEN_TRUC_VA_DATAFLOW.md § 0](KB_10_KIEN_TRUC_VA_DATAFLOW.md#0-bản-dịch-bình-dân-hiểu-sơ-đồ-luồng-dữ-liệu-mes-trong-5-phút).

---


## C141 — Inspection Type Setup (Thiết lập loại hình kiểm tra chung)

### Lỗi 1: Sai loại dữ liệu nhập liệu (số thay vì checkbox hoặc ngược lại)
*   **Triệu chứng:** Grid nhập liệu kiểm tra QC hiển thị ô nhập số nhưng yêu cầu là checkbox, hoặc ngược lại.
*   **Nguyên nhân gốc:** Cột "Loại dữ liệu nhập vào" tại C141 bị thiết lập sai (`1`=số, `2`=tích checkbox).
*   **Cách khắc phục:** Vào C141, sửa lại cột DataType cho hạng mục tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## C143 — Inspection Item Configuration (Thiết lập hạng mục kiểm tra chi tiết)

### Lỗi 1: Mã NVL quét tại B597 không đi đến đúng hạng mục kiểm tra
*   **Triệu chứng:** NVL quét tại B597 bị map sai nhóm kiểm tra, hiện ra các hạng mục đo không liên quan.
*   **Nguyên nhân gốc:** Cấu hình tại C143 map sai mã NVL vào nhóm hạng mục không phù hợp.
*   **Cách khắc phục:** Vào C143, tìm mã NVL, chỉnh lại nhóm hạng mục kiểm tra tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## C151 — Material QC Detail Setup (Thiết lập chi tiết QC vật tư)

### Lỗi 1: Sau khi set A410 xong phải tắt C151 rồi mở lại mới hiển thị đúng
*   **Triệu chứng:** Cấu hình tại A410 đã lưu nhưng C151 vẫn hiện dữ liệu cũ.
*   **Nguyên nhân gốc:** Cache dữ liệu trên client. C151 không tự refresh sau khi A410 thay đổi.
*   **Cách khắc phục:** Đóng tab C151, mở lại từ menu. Dữ liệu sẽ load lại từ DB.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## C153 — QC Sample Config (Cấu hình mẫu kiểm tra QC)

### Lỗi 1: Số lượng mẫu kiểm tra (SampleQty) không khớp với thực tế đo
*   **Triệu chứng:** Máy đo trả về 50 mẫu nhưng C546 chỉ hiện 20 dòng.
*   **Nguyên nhân gốc:** `SampleQty` cấu hình trong bảng `STB_MaterialQcDetail` bị thiết lập sai.
*   **Cách khắc phục:** Vào C153 hoặc chỉnh trực tiếp `STB_MaterialQcDetail` để SampleQty khớp số lượng mẫu thực tế.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md).

---


## C243 — Electrode QC Measurement (Đo lường QC điện cực)

> 🔗 **Xem thêm:** Mục [F743~F748 / C243](#f743f748--c243--electrode-slitting--qc) phía trên đã có chi tiết Slitting & QC điện cực.

### Lỗi 1: Kết quả đo QC điện cực bị lệch hoặc không hiển thị
*   **Triệu chứng:** Grid đo QC điện cực trống hoặc giá trị đo bị sai.
*   **Nguyên nhân gốc:** Dữ liệu đo chưa được upload từ máy đo hoặc mapping giữa Lot điện cực và hạng mục đo bị sai.
*   **Cách khắc phục:** Kiểm tra kết nối máy đo và trạng thái upload trong `Stb_ESRValueMonitor`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md).

---


## C430 — QC Receiving Inspection (Kiểm tra chất lượng nhận hàng)

### Lỗi 1: Không tìm thấy Lot NVL để kiểm tra tại C430
*   **Triệu chứng:** QC mở C430 nhưng không thấy Lot NVL mới nhập kho để kiểm tra.
*   **Nguyên nhân gốc:** Lot NVL chưa được nhập kho tại F330 hoặc chưa được chuyển trạng thái từ `HOLDING_WH`.
*   **Cách khắc phục:** Kiểm tra F330 đã hoàn thành nhập kho, kiểm tra `STB_MaterialLotInfo` xem WarehouseCode.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.15](KB_02_KHO_WMS.md) và [KB_05_QC_ELECTRODE.md](KB_05_QC_ELECTRODE.md).

---


## C451 — OQC Schedule (Lịch kiểm tra OQC)

### Lỗi 1: Lịch OQC không hiển thị Lot cần kiểm tra
*   **Triệu chứng:** Mở C451 nhưng danh sách Lot chờ OQC trống.
*   **Nguyên nhân gốc:** Lot chưa hoàn thành đóng gói tại B523 hoặc cờ `IsOutputRoute` chưa được bật.
*   **Cách khắc phục:** Kiểm tra Lot đã gộp Box xong tại B523. Kiểm tra `IsOutputRoute = 1` trong `STB_ProductionOrderRouting`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 14](KB_06_MASTER_DATA_TOOLS.md).

---


## C460 — Electrode QC Report (Báo cáo QC điện cực)

### Lỗi 1: Báo cáo QC điện cực hiển thị trống hoặc thiếu dữ liệu
*   **Triệu chứng:** Mở C460 không thấy kết quả QC điện cực.
*   **Nguyên nhân gốc:** Chưa thực hiện QC điện cực hoặc dữ liệu QC chưa được đồng bộ.
*   **Cách khắc phục:** Kiểm tra các bảng `STB_CommInspDocHistory`, `STB_CommInspDocItem` xem dữ liệu QC điện cực đã được ghi nhận chưa.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 3](KB_05_QC_ELECTRODE.md) và [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md).

---


## C510 — OQC Lot Search (Tìm kiếm Lot OQC)

> 🔗 **Xem thêm:** Mục [C512 / C530 / C546](#c512--c530--c546--oqc-lot-management) phía trên đã có chi tiết lỗi OQC.

### Lỗi 1: Không tìm thấy Lot tại C510 để tạo hồ sơ OQC
*   **Triệu chứng:** Tìm kiếm Lot tại C510 trả về kết quả trống.
*   **Nguyên nhân gốc:** 3 nguyên nhân chính: (1) Lot chưa được tạo/gộp box, (2) Chưa set A410, (3) Nhà máy HN dùng Route VE02 riêng.
*   **Cách khắc phục:** Áp dụng checklist 3 bước debug giống C512 (xem mục C512 phía trên).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.2](KB_05_QC_ELECTRODE.md).

---


## C522 — Aging ESR SD (Dữ liệu Aging & ESR)

### Lỗi 1: Dữ liệu Aging/ESR không đồng bộ hoặc hiển thị sai
*   **Triệu chứng:** Kết quả Aging/ESR tại C522 bị thiếu hoặc không khớp với máy đo.
*   **Nguyên nhân gốc:** Phần mềm ESR chưa upload dữ liệu vào bảng `Stb_ESRValueMonitor` hoặc cờ `UploadToMes` chưa được set.
*   **Cách khắc phục:** Kiểm tra phần mềm đo ESR trên máy, reset cờ upload nếu cần.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_19_ALL_DATABASES_MAP.md](KB_19_ALL_DATABASES_MAP.md).

---


## C530 — QC Audit (Kiểm tra chất lượng trước xuất hàng)

> 🔗 **Xem thêm:** Mục [C512 / C530 / C546](#c512--c530--c546--oqc-lot-management) phía trên đã có chi tiết lỗi OQC.

### Lỗi 1: Không đổi được trạng thái Reject sang Pass ở QC Audit
*   **Triệu chứng:** Lot đã bị FAIL/Reject tại QC Audit C530 nhưng sau kiểm tra lại cần chuyển sang PASS.
*   **Nguyên nhân gốc:** UI không cho phép đổi ngược trạng thái. Cần can thiệp DB.
*   **Cách khắc phục:** Xóa kết quả QC cũ trong `STB_CommInspDocHistory` và `STB_CommInspDocItem`, sau đó QC kiểm tra lại từ đầu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md § 3.2](KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md).

---


## C540 — QC Result Report (Báo cáo kết quả QC)

### Lỗi 1: Báo cáo kết quả QC hiển thị thiếu hoặc sai thông tin
*   **Triệu chứng:** Báo cáo C540 thiếu kết quả đo hoặc hiện sai trạng thái PASS/FAIL.
*   **Nguyên nhân gốc:** Lệch dữ liệu giữa `STB_CommInspDocHistory` và `STB_MaterialQcSampleResult`.
*   **Cách khắc phục:** Kiểm tra trực tiếp DB, đối chiếu kết quả QC trong 2 bảng và sửa lại nếu lệch.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## C541 — QC Detail Result (Chi tiết kết quả QC)

### Lỗi 1: Chi tiết kết quả QC không load được dữ liệu
*   **Triệu chứng:** Mở C541 nhưng grid chi tiết kết quả trống trơn.
*   **Nguyên nhân gốc:** Chưa thực hiện QC hoặc `CommInspDocNo` bị NULL trong bảng `STB_CommInspDocItem`.
*   **Cách khắc phục:** Kiểm tra Lot đã hoàn thành QC chưa. Nếu đã QC mà vẫn trống, kiểm tra liên kết giữa `STB_CommInspDocHistory` và `STB_CommInspDocItem`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md).

---


## C546 — FOQC OCV/ESR (Kiểm tra OCV & ESR đầu ra)

> 🔗 **Xem thêm:** Mục [C512 / C530 / C546](#c512--c530--c546--oqc-lot-management) phía trên đã có chi tiết lỗi OCV/ESR hiển thị 20ea thay vì 50ea.

### Lỗi 1: C546 chỉ hiển thị 20 dòng mẫu thay vì 50 dòng
*   **Triệu chứng:** Máy đo trả về 50 mẫu nhưng C546 chỉ load 20 dòng.
*   **Nguyên nhân gốc:** `SampleQty` trong `STB_MaterialQcDetail` bị lệch so với dữ liệu máy đo.
*   **Cách khắc phục:** Xóa kết quả QC lỗi, reset cờ upload:
    ```sql
    DELETE FROM STB_MaterialQcSampleResult WHERE MaterialQcNo = 'F_MÃ_BARCODE';
    UPDATE Stb_ESRValueMonitor SET UploadToMes = 0, UploadOCVToMess = 0 WHERE lotno = 'MÃ_BARCODE';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.6](KB_05_QC_ELECTRODE.md) và [KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md](KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md).

---


## C560 — Material Lot QC (Kiểm tra chất lượng Lot vật tư)

### Lỗi 1: Lot vật tư không hiển thị để kiểm tra QC
*   **Triệu chứng:** Mở C560 nhưng danh sách Lot vật tư cần QC bị trống.
*   **Nguyên nhân gốc:** Lot vật tư chưa được nhập kho hoặc chưa chuyển trạng thái sang chờ QC.
*   **Cách khắc phục:** Kiểm tra F330 đã nhập kho, kiểm tra bảng `STB_MaterialLotInfo` xem `WarehouseCode` và `QcStatus`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md).

---


## C562 — Bending/Cutting Lot Creation (Tạo Lot kiểm định uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên đã có chi tiết quy trình QC Bending/Cutting.

### Lỗi 1: Không tạo được Lot kiểm định tại C562
*   **Triệu chứng:** Quét barcode sản phẩm tại C562 nhưng không sinh được Lot kiểm định.
*   **Nguyên nhân gốc:** Model chưa được cấu hình nhóm kiểm tra tại C561.
*   **Cách khắc phục:** Vào C561 trước, gán nhóm kiểm tra cho MaterialCode, sau đó quay lại C562.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](KB_05_QC_ELECTRODE.md).

---


## C563 — Bending/Cutting Measurement (Nhập dữ liệu đo uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên.

### Lỗi 1: Lưới đo trống hoặc thiếu hạng mục đo
*   **Triệu chứng:** Quét barcode mẫu tại C563, grid trống không có hạng mục.
*   **Nguyên nhân gốc:** Chưa cấu hình C561 hoặc chưa tạo Lot kiểm định C562.
*   **Cách khắc phục:** Cấu hình C561 → Tạo Lot C562 → Quay lại C563. Nếu vẫn trống, nhấn "Tổng hợp hạng mục".
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](KB_05_QC_ELECTRODE.md).

---


## C564 — Bending/Cutting Report (Báo cáo kết quả uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên.

### Lỗi 1: Báo cáo kết quả C564 không hiện dữ liệu sau khi đo
*   **Triệu chứng:** Đã nhập kết quả đo tại C563 nhưng C564 báo cáo trống.
*   **Nguyên nhân gốc:** Kết quả đo chưa được submit/confirm tại C563 (chưa nhấn Save).
*   **Cách khắc phục:** Quay lại C563, đảm bảo nhấn Save/Confirm để kết quả được ghi nhận vào DB.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](KB_05_QC_ELECTRODE.md).

---


## F744 — Electrode Slitting Result (Kết quả chia cuộn điện cực)

### Lỗi 1: Kết quả Slitting điện cực bị thiếu hoặc sai chiều rộng
*   **Triệu chứng:** Kết quả chia cuộn tại F744 hiển thị sai chiều rộng hoặc thiếu cuộn.
*   **Nguyên nhân gốc:** Cấu hình Slitting tại B552 (bảng `stb_slittinglocationconfig_vvt`) bị sai Width.
*   **Cách khắc phục:** Kiểm tra cấu hình B552 và sửa lại Width cho PartNo tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## F746 — Slitting Curling (Bo miệng điện cực)

> 🔗 **Xem thêm:** Mục [F742 / F746](#f742--f746--slitting--curling) phía trên.

### Lỗi 1: Hủy/Rollback Slitting F742 phải xóa F746 trước
*   **Triệu chứng:** Cần rollback kết quả Slitting nhưng hệ thống báo lỗi ràng buộc dữ liệu.
*   **Nguyên nhân gốc:** Bảng F746 (Curling) có FK reference đến F742 (Slitting). Phải xóa F746 trước.
*   **Cách khắc phục:** Xóa kết quả Curling (F746) trước, sau đó mới xóa kết quả Slitting (F742).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 10.1](KB_05_QC_ELECTRODE.md).

---


## F747 — Electrode Coating (Tráng điện cực)

### Lỗi 1: Kết quả tráng điện cực không được ghi nhận
*   **Triệu chứng:** Công đoạn tráng điện cực tại F747 không lưu được kết quả.
*   **Nguyên nhân gốc:** Lot điện cực chưa hoàn thành công đoạn trước (Mixing) hoặc cấu hình Route điện cực sai.
*   **Cách khắc phục:** Kiểm tra Lot đã hoàn thành Mixing, kiểm tra Route điện cực tại B220.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md).

---


## F748 — Electrode Process History (Lịch sử công đoạn điện cực)

> 🔗 **Xem thêm:** Mục [F743~F748 / C243](#f743f748--c243--electrode-slitting--qc) phía trên.

### Lỗi 1: Lịch sử công đoạn điện cực hiển thị thiếu
*   **Triệu chứng:** F748 không hiện đầy đủ các công đoạn của cuộn điện cực.
*   **Nguyên nhân gốc:** Một số công đoạn bị bỏ qua khi scan hoặc bảng `STB_ElectrodeProdRouteHist` thiếu dữ liệu.
*   **Cách khắc phục:** Kiểm tra bảng `STB_ElectrodeProdRouteHist` xem có đủ công đoạn không, chèn bổ sung nếu thiếu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md).

---


## Các Màn Hình Cô Lập Xưởng Hưng Yên (TCode kết thúc bằng `_HY`)

> 🔗 **Xem thêm:** Chi tiết UAT và danh sách đối soát các màn hình cô lập Hưng Yên tại [hy_screens_audit.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/fdbffebe-1907-405f-80d2-5bc839ff4434/hy_screens_audit.md). Các màn hình gồm: `C121_HY`, `C122_HY`, `C220_HY`, `B310_HY`, `B442_HY`, `B470_HY`, `B552_HY`, `B802_HY`, `C460_HY`.

### Lỗi 1: Lỗi nhân bản Stored Procedure bị hậu tố kép `_HY_HY` trong layout XML
*   **Triệu chứng:** Màn hình Hưng Yên load lên báo lỗi Runtime do không tìm thấy Stored Procedure tương ứng (Ví dụ: `usp_ProductionOrderInfo_HY_HY_get`).
*   **Nguyên nhân gốc:** Quá trình chạy script nhân bản layout XML (`clone_screen_layouts.sql`) thực hiện replace chuỗi `_get` và `_iud` thành Stored Procedure Hưng Yên bị lặp lại hoặc chạy chéo, dẫn đến Stored Procedure bị đổi tên sai thành `_HY_HY`.
*   **Cách khắc phục:** Chạy script SQL cập nhật cột `XmlLayout` trong bảng `SmartFramework.dbo.STB_ScreenLayoutInfo` để sửa các chuỗi `_HY_HY` trở về `_HY`.

### Lỗi 2: Màn hình C121_HY (QcInspectionGroup_HY) bị mở thành nhiều Tab (mở nhiều cửa sổ)
*   **Triệu chứng:** Khi người dùng mở màn hình `C121_HY` trên client MES, mỗi lần click menu hệ thống lại mở thêm một tab mới thay vì chỉ mở và focus vào tab duy nhất đã mở (như màn hình gốc C121).
*   **Nguyên nhân gốc:** Cột `IsDialog` của màn hình `QcInspectionGroup_HY` trong bảng `SmartFramework.dbo.STB_ScreenInfo` bị để giá trị **NULL** hoặc `True` thay vì `0` (False).
*   **Cách khắc phục:** Chạy SQL cập nhật thuộc tính `IsDialog = 0` cho màn hình `QcInspectionGroup_HY`:
    ```sql
    UPDATE SmartFramework.dbo.STB_ScreenInfo 
    SET IsDialog = 0
    WHERE Name = 'QcInspectionGroup_HY';
    ```

### Lỗi 3: Màn hình C121_HY vẫn gọi Stored Procedure gốc không có hậu tố Hưng Yên
*   **Triệu chứng:** Khi thực hiện thao tác Thêm/Sửa/Xóa hạng mục kiểm tra QC tại `C121_HY`, hệ thống vẫn gọi SP gốc `usp_QcInspectionItem_iud` thay vì bản cô lập Hưng Yên, làm thay đổi chéo dữ liệu của các xưởng khác.
*   **Nguyên nhân gốc:** Quá trình clone Stored Procedure bị bỏ sót, chưa tạo SP `usp_QcInspectionItem_HY_iud` trên DB chính và chưa đăng ký/ánh xạ vào `STB_ScreenObjects` cho màn hình `C121_HY`.
*   **Cách khắc phục:** 
    1. Nhân bản SP `usp_QcInspectionItem_iud` thành `usp_QcInspectionItem_HY_iud` trên DB `SmartFactoryV2`.
    2. Đăng ký hàm thực thi `usp_QcInspectionItem_HY_iud` (ExecuteFunction) vào bảng `STB_ScreenObjects` cho ScreenName `QcInspectionGroup_HY`.
    3. Cập nhật `XmlLayout` của màn hình `QcInspectionGroup_HY` để thay thế `usp_QcInspectionItem_iud` bằng `usp_QcInspectionItem_HY_iud`.

### Lỗi 4: Object Panel (F5) hoặc giao diện hiển thị Stored Procedure cũ không có hậu tố `_HY`
*   **Triệu chứng:** DB đã cập nhật Stored Procedure `_HY` đầy đủ nhưng trên phần mềm MES (Object Panel hoặc lúc chạy thực tế) vẫn hiển thị và gọi SP cũ.
*   **Nguyên nhân gốc:** Client MES NAIS đang lưu cache layout cũ trên máy tính local của người dùng, chưa cập nhật cấu hình mới từ DB.
*   **Cách khắc phục:** Tắt hoàn toàn phần mềm MES NAIS (đóng chương trình) rồi mở lại để client xóa cache và tải lại layout mới từ database.

---
*Cập nhật: 2026-06-13 — Hoàn thiện cẩm nang tra cứu lỗi cho **125+ màn hình** theo Screen ID riêng biệt và bổ sung phần gỡ lỗi các màn hình cô lập Hưng Yên (_HY). Mỗi màn hình có header ## ScreenID riêng, hỗ trợ tìm kiếm Ctrl+Shift+F trực tiếp.*



---

### Kịch bản sự cố khẩn cấp 1: Hủy kết quả kiểm tra chất lượng QC (B597/C443)

#### 🔬 KỊCH BẢN B: Hủy kết quả kiểm tra chất lượng QC (B597 / C443)
*   **Triệu chứng:** QC đánh giá nhầm Lot hàng sang FAIL hoặc load nhầm hạng mục kiểm tra cũ, muốn hủy kết quả để đo lại từ đầu.
*   **Ví dụ Demo:** Hủy tài liệu QC bị sai cho Barcode `VVPP163R072732`.
*   **Quy trình xử lý bằng Transaction:**
    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Tìm CommInspDocNo (Mã tài liệu QC) đang liên kết với Barcode
        DECLARE @DocNo NVARCHAR(50);
        SELECT @DocNo = CIDH.CommInspDocNo
        FROM STB_CommInspDocHistory CIDH
        JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
        WHERE SI.Barcode = 'VVPP163R072732';

        IF @DocNo IS NOT NULL
        BEGIN
            PRINT 'Tìm thấy tài liệu QC: ' + @DocNo;

            -- 2. Xóa các hạng mục kiểm tra chi tiết trước (STB_CommInspDocItem)
            DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = @DocNo;

            -- 3. Xóa lịch sử tài liệu QC (STB_CommInspDocHistory)
            DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = @DocNo;
            
            PRINT 'Đã xóa hoàn toàn kết quả QC cũ.';
        END
        ELSE
        BEGIN
            PRINT 'Không tìm thấy kết quả QC nào cho Barcode này.';
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH;
    ```
    > ⚠️ **Lưu ý:** Sau khi chạy script, yêu cầu QC **tắt hoàn toàn màn hình B597/C443 và mở lại** để hệ thống xóa bộ nhớ đệm (cache) và tải lại spec mới từ đầu.


---

### Kịch bản sự cố khẩn cấp 2: Hủy/Sửa kết quả OQC thành phẩm (C512/C530)

#### 📦 KỊCH BẢN C: Hủy/Sửa kết quả OQC Thành phẩm (C512 / C530)
*   **Triệu chứng:** Lô thành phẩm bị đánh giá nhầm trạng thái FAIL khiến thủ kho không thể nhập kho ở F110.
*   **Quy trình xử lý nhanh (Bypass sang PASS):**
    ```sql
    -- Cập nhật trực tiếp kết quả OQC sang PASS để thông luồng nhập kho
    UPDATE STB_CommInspDocHistory
    SET CommInspResult = 'PASS',
        FinishDateTime = GETDATE(),
        ChangeUserID = 'admin_fix'
    WHERE CommInspDocNo = (
        SELECT TOP 1 CIDH.CommInspDocNo 
        FROM STB_CommInspDocHistory CIDH
        JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
        WHERE SI.Barcode = 'Mã_Barcode_Thành_Phẩm'
        ORDER BY CIDH.CreateDateTime DESC
    );
    ```


---

### Kịch bản sự cố khẩn cấp 3: Lỗi nhập phế HNC321 báo lỗi tiếng Hàn

### 4.6 LỖI NHẬP PHẾ MÀN HNC321 BÁO LỖI TIẾNG HÀN (이전 공정에 실적처리 이력이 없습니다)

#### 🔴 Triệu chứng hiện trường:
Tại màn hình **HNC321** *(Qc nhập NG sản phẩm mang đi kiểm tra)*, khi nhập số lượng phế cho Barcode `ve260509-001` tại công đoạn `VE08` (Mã lỗi `VE08_34` - Taping khác...), hệ thống báo lỗi đỏ:
`Failed to save: 이전 공정에 실적처리 이력이 없습니다.`
*(Dịch nghĩa: Không có lịch sử xử lý sản lượng ở công đoạn trước).*

#### 🔍 Nguyên nhân gốc rễ:
Stored Procedure xử lý nghiệp vụ nhập phế (`usp_Vietnam_ScrapInput_HN` — ⚠️ SP nội bộ Hà Nam, có thể là alias hoặc được gọi gián tiếp) chặn không cho phép nhập phế liệu tại công đoạn `VE08` nếu sản phẩm này chưa từng có dữ liệu chốt sản lượng (Routing History) ở công đoạn ngay trước đó (Ví dụ: `VE07` hoặc trạm trước của `VE08` trong cấu hình Routing của PO).

#### 🛠️ Kịch bản xử lý từng bước (Bypass bằng SQL):
Khi công đoạn trước bị bỏ qua không quét chốt và hàng thực tế đã phế, IT tiến hành chèn một dòng lịch sử sản lượng giả lập cho trạm trước để thông luồng:

*   **Step 1:** Truy vấn mã `ControlNo` của Barcode bị lỗi:
    ```sql
    SELECT ControlNo, Barcode, PONo, MaterialCode FROM STB_SetInfo WHERE Barcode = 've260509-001';
    ```
*   **Step 2:** Truy vấn xem công đoạn ngay trước `VE08` trong cấu hình Route của PO đó là gì:
    ```sql
    SELECT RouteCode, RouteIndex 
    FROM STB_ProductionOrderRouting 
    WHERE PONo = (SELECT PONo FROM STB_SetInfo WHERE Barcode = 've260509-001')
    ORDER BY RouteIndex ASC;
    -- Kết quả xác định được công đoạn trước là 'VE07'
    ```
*   **Step 3:** Thực hiện chèn bản ghi lịch sử Routing giả lập cho trạm `VE07` bằng Transaction an toàn:
    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @CtrlNo NVARCHAR(50) = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 've260509-001');

        INSERT INTO STB_ProdRouteHist 
            (ControlNo, ProcSeq, RouteCode, LineCode, MachineCode, InQty, OutQty, JobDate, ShiftCode, CreateUserID, CreateDateTime)
        VALUES 
            (@CtrlNo, 
             (SELECT ISNULL(MAX(ProcSeq), 0) + 1 FROM STB_ProdRouteHist WHERE ControlNo = @CtrlNo), 
             'VE07',            -- Mã công đoạn trước VE08
             'MCVC20220',       -- Mã Line phát sinh
             'MCVC20220',       -- Mã máy
             20, 20,            -- Số lượng phế
             CAST(GETDATE() AS DATE), 'A', 
             'vinaadmin', GETDATE());

        COMMIT TRANSACTION;
        PRINT 'Đã chèn lịch sử giả lập thành công! Hãy bảo công nhân bấm Lưu (Save) lại trên giao diện HNC321.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
    ```
---

---

### Kịch bản sự cố khẩn cấp 4: Lỗi nhảy bước cân điện cực Mixing

### 4.7 LỖI NHẢY BƯỚC CÂN ĐIỆN CỰC MIXING (PHẦN MỀM electrode.weighing)

#### 🔴 Triệu chứng hiện trường:
"Các bước cân cứ nhảy không đúng thứ tự process nên không cân được", "Mã điện cực HCE đang lỗi chưa thao tác được, sản xuất ra mà không được ghi nhận trên hệ thống".

#### 🔍 Nguyên nhân gốc rễ:
*   Phần mềm có checkbox **"CA ĐÊM CHUẨN BỊ TRƯỚC"** (`isnight` trên UI). Khi tích vào ô này, phần mềm gọi SP `usp_GetElectroMixPresentStep_vietnam` và `usp_ElectrodeStep_get` (⚠️ tên thực tế trong DB) với tham số `@pOrder = 'kdem'` để đẩy Binder lên cân trước (vì cần thời gian khuấy sấy lâu).
*   Nếu ca ngày làm việc hoặc ca bình thường **quên bỏ tích checkbox này**, thứ tự process sẽ bị xáo trộn, bắt cân Binder trước rồi mới đến bột Than. Công nhân không thể cân lần lượt từ trên xuống theo quy trình chuẩn và bị báo lỗi nhảy bước.
*   Khi bước cân bị treo/chặn, mẻ trộn Mixing không thể chốt hoàn thành trên MES, dẫn đến bán thành phẩm (Slurry) sản xuất ra **không được ghi nhận trên hệ thống** (thiếu bản ghi trong `STB_ElectrodeMixInfo`). Khi sang công đoạn tiếp theo (Coating), quét mã Lot điện cực sẽ bị báo lỗi.

#### 🛠️ Kịch bản xử lý từng bước:

*   **Step 1 (Bypass vận hành):**
    Yêu cầu công nhân ca ngày **bỏ tích checkbox "CA ĐÊM CHUẨN BỊ TRƯỚC"** trên giao diện chính của phần mềm, sau đó bấm nút **"Làm mới màn hình"** để hệ thống sắp xếp lại thứ tự cân than trước.
*   **Step 2 (IT reset Lot bị kẹt):**
    Nếu Lot điện cực (Ví dụ: Lot của mã `HCE-202`) đã bị ghi nhận sai thứ tự và kẹt nửa chừng, IT chạy lệnh xóa dữ liệu cân tạm của Lot đó trong bảng `STB_ElectrodeMixStepInfo` để công nhân cân lại đúng thứ tự từ đầu:
    ```sql
    BEGIN TRANSACTION;
    DELETE FROM STB_ElectrodeMixStepInfo 
    WHERE ElectrodeLotNumber = 'Mã_Lot_Điện_Cực_HCE_Bị_Kẹt';
    COMMIT TRANSACTION;
    ```
    Sau đó chốt mẻ trộn bình thường để hệ thống tự động ghi nhận sản lượng Slurry, thông luồng cho Coating/Slitting tiếp theo.

---

---

### Kịch bản sự cố khẩn cấp 5: Điện cực 3582-600F CY không tạo được tem

### 4.8 ĐIỆN CỰC MÃ LIỆU 3582-600F CY KHÔNG TẠO ĐƯỢC TEM

#### 🔴 Triệu chứng hiện trường:
Khi sản xuất điện cực mã liệu `3582-600F CY`, hệ thống không cho tạo hoặc in tem điện cực.

#### 🔍 Nguyên nhân gốc rễ:
*   Mã điện cực `3582-600F CY` là mã model/sản phẩm mới chưa được khai báo đầy đủ cấu hình trong Master Data.
*   Đặc biệt, trạm cắt điện cực Slitting (B552) yêu cầu phải có cấu hình quy cách Slitting trong bảng **`stb_slittinglocationconfig_vvt`** mới cho phép in tem.

#### 🛠️ Kịch bản xử lý từng bước:

*   **Step 1:** Thêm cấu hình quy cách Slitting cho model `3582` (cả cực dương `BY` và cực âm `YP`):
    ```sql
    BEGIN TRANSACTION;
    INSERT INTO stb_slittinglocationconfig_vvt
        (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse, RollQty, PositiveLocation, NegativeLocation)
    VALUES
        ('3582', 'BY', '200', '600', '39.34', 'VVT_F2', 'kho2', 20, 'A6-T3', 'B6-T3'),
        ('3582', 'YP', '180', '600', '39.34', 'VVT_F2', 'kho2', 20, 'A6-T3', 'B6-T3');
    COMMIT TRANSACTION;
    ```
*   **Step 2:** Kiểm tra và đảm bảo đã khai báo model `3582-600F CY` vào bảng `STB_ModelBasicInfo` (A410) đầy đủ thông số Vol/Farad (Vol = '3R0', Farad = '600.0') để các trạm QC và kho nhận diện được đúng:
    ```sql
    SELECT * FROM STB_ModelBasicInfo WHERE ModelCode = '3582-600F CY';
    -- Nếu thiếu, thực hiện chèn dữ liệu (Xem chi tiết tại KB_06 § 1.1)
    ```

---