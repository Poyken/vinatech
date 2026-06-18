# KB_05 — Kiểm tra Chất lượng (QC) & Điện cực

> **Màn hình:** B597, C443, C512, C486, C530, C546, B552, B270, B540, C121-C564, F743-F748
> **Bảng chính:** `STB_MaterialQcInfo` (35 cols), `STB_MaterialQcInspectionItem` (USL/LSL), `STB_CommInspDocHistory`
> **🔑 Keywords:** QC, chất lượng, kiểm tra, IQC, PQC, OQC, FOQC, electrode, điện cực, slitting, aging, hạng mục, spec, USL, LSL, Pass, Fail, Hold, mẫu, sample
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

→ Xem [KB_02 Mục 4.10](../KB_02/KB_02_01_NVL_WMS.md#410-kiểm-tra-hạn-sử-dụng-nvl-expiry-date) để tra cứu công thức tính.

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

