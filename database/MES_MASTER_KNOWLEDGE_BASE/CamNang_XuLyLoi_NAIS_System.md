# Cẩm Nang Xử Lý Lỗi Toàn Tập NAIS System (Troubleshooting Guide)

> **Mục đích:** Tài liệu này được tổng hợp chi tiết từ tất cả các bản ghi chép lỗi thực tế ("Một số lỗi Nais System", "Bật tắt thành phẩm", "Lỗi trên NAIS System Tái bản"). Tài liệu giải thích rõ bản chất, nguyên nhân sâu xa và cung cấp chính xác các kịch bản SQL cũng như thao tác xử lý cho từng case lỗi trên hệ thống MES (NAIS).

---

## 📑 Mục Lục

1. [Phần 1: Quản Trị Hệ Thống & Phân Quyền Cơ Bản (System & Z-series)](#phan-1)
2. [Phần 2: Quản Lý Dữ Liệu Lõi - Master Data (A-series & Data Kích Thước)](#phan-2)
3. [Phần 3: Quản Lý Sản Xuất & Lịch Sử Công Đoạn (B-series)](#phan-3)
4. [Phần 4: Quy Trình Kiểm Tra Chất Lượng - QC (C-series & B597)](#phan-4)
5. [Phần 5: Quản Lý Kho NVL & Thành Phẩm (F-series)](#phan-5)
6. [Phần 6: Quản Lý Kế Hoạch Lệnh Sản Xuất (PO - B310, B450)](#phan-6)
7. [Phần 7: Quy Trình Slitting & Lỗi Điện Cực (B552)](#phan-7)
8. [Phần 8: Báo Cáo Andon, Giá & SQL Report Khác](#phan-8)

---

<a id="phan-1"></a>
## 1️⃣ Phần 1: Quản Trị Hệ Thống & Phân Quyền Cơ Bản (System & Z-series)

### 1.1 Lỗi không đăng nhập được vào MES (NAIS System)
- **Nguyên nhân / Bản chất:** Client ứng dụng MES của người dùng (tải qua giao thức ClickOnce) bị kẹt cache phiên bản cũ, hoặc file cấu hình trỏ sai địa chỉ Server.
- **Cách xử lý:**
  1. **Thử update tự động:** Chạy file update MES trên Desktop.
  2. **Clear Cache:** Xóa toàn bộ thư mục `C:\AwooSystem` để ép hệ thống tải mới.
  3. **Cài đặt lại & Cấu hình:** Vào `http://mes.hycap.co.kr:9952/` để tải. Trong màn hình cấu hình ban đầu:
     - **Alias:** `nais`
     - **Url:** `http://mes.hycap.co.kr:9952`

### 1.2 Nhắc nhở danh sách màn hình Phân quyền & Nhân sự
Hệ thống NAIS quản lý qua các mã màn hình:
- **B260:** Thêm danh sách công nhân sản xuất.
- **Z410:** Thêm tài khoản đăng nhập MES cho người mới (Account).
- **Z220:** Phân quyền người dùng (Role).
- **Z330:** Gắn/thêm quyền truy cập màn hình mới cho nhóm người dùng.
- **B230:** Nơi xử lý khi lỗi "Popup không hiện trên B270" (liên quan đến thiết lập popup).

---

<a id="phan-2"></a>
## 2️⃣ Phần 2: Quản Lý Dữ Liệu Lõi - Master Data (A-series & Data Kích Thước)

### 2.1 Lỗi NVL mới không gộp Box được (Không hiển thị Vol, Farad)
- **Nguyên nhân:** Mã Nguyên vật liệu mới được bộ phận đăng ký tạo ở kho (`STB_MaterialMaster`) nhưng **quên khai báo** thông số kỹ thuật (Kích thước, Vol, Farad) bên màn quản lý Model (`STB_ModelBasicInfo`). Dẫn đến View `VW_ModelBasicInfo` không load được giá trị (ExtText01->05 bị NULL).
- **Cách xử lý:**
  1. Thêm thủ công vào `STB_ModelBasicInfo` (chú ý `MaterialTypeCode`, `MBIExtText...` cho Volt và Farad):
  ```sql
  INSERT INTO STB_ModelBasicInfo (ModelCode, ModelName, MaterialTypeCode, ProductGroupCode, MBISizeH, MBISizeW, IsClosed, OqcType, OqcInspectionRuleType, InspectionType, InspectionLevel, MBIExtText01, MBIExtText02, MBIExtText03, MBIExtText04, MBIExtText05, CreateDateTime)
  VALUES ('RDMD00-368', 'HY-CAP WEC9R0166QG-WC(130)', 'MDL', 'HC-EDLC', 40, 18, 0, 'MANUAL', 'BY_MODEL', 'SAMPLE', 'SAMPLE', '9R0', '166', 'WEC', '9.0', '16.6', GETDATE())
  ```
  2. Để giải quyết việc "không gộp box được", vào màn **F110** và tích chọn thuộc tính ghép lô.

### 2.2 Sửa tên Lot sau khi cập nhật thông số Model ở A410 / Chuyển đổi Lot ở B351
- **Nguyên nhân:** Khi model có sự thay đổi quy cách, mã Barcode của Lot cần cập nhật lại (chấm phẩy bị sai, VD `VVPR152.740601` -> `VVPR152R740601`).
- **Cách xử lý:** Cập nhật đồng bộ các bảng lưu trữ Barcode:
  ```sql
  UPDATE STB_RawMaterialInputHist SET Barcode = 'VVPR152R740601' WHERE Barcode = 'VVPR152.740601';
  UPDATE STB_SetInfo SET Barcode = 'VVPR152R740601' WHERE Barcode = 'VVPR152.740601';
  UPDATE STB_LotChangeMaterialHistory SET NewBarcode = 'VVPR152R740601' WHERE Newbarcode = 'VVPR152.740601';
  ```

### 2.3 Lỗi không in được tem ở màn B450
- **Cách xử lý:** Cần thiết lập lại ở màn **A460**.
  - In tem cho sản xuất chọn: `AssembleLabel` (dòng 2).
  - In tem cho kho chọn: `PartLabel`.

### 2.4 Lỗi In sai mã VV thành VJ theo Code NVL
- **Nguyên nhân:** NAIS đôi khi mặc định in mã VV. Cần đổi đầu mã trong bảng setting in tem.
- **Cách xử lý:** 
  ```sql
  UPDATE STB_Vietnam_PackingPrinting SET PrintVJ = 0 WHERE MaterialCode = 'MÃ_NVL_CẦN_IN';
  ```
  *Nếu cần update lại Lịch sử Barcode Lot (VVO -> VJO):*
  ```sql
  UPDATE STB_SetInfo SET Barcode = 'VJOQ062R725633' WHERE Barcode = 'VVOQ062R725633';
  UPDATE STB_LotChangeMaterialHistory SET NewBarcode = 'VJOQ062R725633' WHERE NewBarcode = 'VVOQ062R725633';
  UPDATE STB_SavePackingTime_VVT SET lotno = 'VJOQ062R725633' WHERE lotno = 'VVOQ062R725633';  -- Màn 781
  UPDATE STB_MaterialLotInfo SET lotno = 'VJOQ062R725633' WHERE lotno = 'VVOQ062R725633'; -- Màn B523
  ```

---

<a id="phan-3"></a>
## 3️⃣ Phần 3: Quản Lý Sản Xuất & Lịch Sử Công Đoạn (B-series)

### 3.1 Lỗi sai lệch ngày tháng công đoạn (JobDate / ProdDateTime / CreateDateTime)
> **Bản chất:** Lỗi này xảy ra nhiều nhất khi công nhân chuyển ca đêm (qua 00:00) nhưng quên chuyển ngày, hoặc đóng gói sai ngày. Hệ thống thường lưu 2 trường: `CreateDateTime` (giờ thực tế bấm) và `JobDate`/`ProdDateTime` (giờ hành chính tính công).

- **Sửa JobDate Lịch sử Màn B782:**
  ```sql
  -- Lấy ControlNo theo Barcode từ STB_SetInfo
  UPDATE STB_ProdRouteHist
  SET ProdDateTime = CAST('2025-02-17' AS DATETIME) + CAST(ProdDateTime AS TIME),
      JobDate = '2025-02-17'
  WHERE ControlNo IN (SELECT ControlNo FROM STB_SetInfo WHERE Barcode IN ('VVPK173R010710'))
    AND RouteCode IN ('V-22_BG');
  ```
- **Sửa PrintTime Màn B781 (Đóng gói):**
  ```sql
  UPDATE STB_SavePackingTime_VVT
  SET PrintTime = CAST('2025-02-17' AS DATETIME) + CAST(PrintTime AS TIME)
  WHERE LotNo IN ('VVPK173R015603') AND ID IN ('1217734');
  -- (Có thể sử dụng hàm REPLACE nếu chỉ cần thay đổi text ngày: REPLACE(CONVERT(VARCHAR, PrintTime, 120), '2024-11-11', '2024-11-08') )
  ```
- **Sửa JobDate màn B598 (Lỗi sản xuất) và màn B726 (Scrap):**
  - Màn này gen JobDate dựa theo `CreateDateTime`. 
  ```sql
  -- Màn B598
  UPDATE STB_VN_PRODUCTION_ERROR SET CreateDateTime = CAST('2025-02-18' AS DATETIME) + CAST(CreateDateTime AS TIME) WHERE IDPE IN (...);
  -- Màn B726
  UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS SET CreateDateTime = CAST('2025-03-01' AS DATETIME) + CAST(CreateDateTime AS TIME) WHERE ID = 4962;
  ```

### 3.2 Lỗi Chuyển Line Sản Xuất (Line 11 -> 12)
- Cập nhật Line trong thông tin Lot và Lịch sử Route:
  ```sql
  UPDATE STB_SetInfo SET inputlinecode ='VVBGC-12' WHERE barcode ='VVOR163R010713';
  UPDATE STB_ProdRouteHist SET linecode ='VVBGC-12' WHERE controlNo = (SELECT controlNo FROM STB_SetInfo WHERE barcode ='VVOR163R010713');
  ```

### 3.3 Chỉnh Sửa Số Lượng Đóng Gói (B789) & Hàng Lỗi NG (B791)
- **Màn B789 (Đóng gói):**
  ```sql
  SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = ''; -- Lấy ID
  UPDATE STB_SavePackingTime_VVT SET PackQty = 1000 WHERE LotNo = '' AND id = '';
  -- Lưu ý: Nếu lưu nhưng ko hiện bên B789 (Qty âm ở B523), check SP `usp_savePackingLabelQty_VVT` và `usp_Vietnam_GetBoxIDForLotNo_VVT` (Lỗi do đổi đầu mã).
  ```
- **Màn B791 (Sửa DefectQty):** Phải sửa cả trong bảng Defect và Qty vào của công đoạn tiếp theo.
  ```sql
  UPDATE STB_DefectRepairInfo SET DefectQty = 4 WHERE ControlNo = '20250314000351';
  UPDATE STB_ProdRouteHist SET ProdQty = '3996' WHERE ControlNo = '20250314000351' AND RouteCode = 'MV-05';
  ```

### 3.4 Bật tắt Lỗi/Lưu dữ liệu NVL (B597, B523)
- Lỗi chưa có tiêu chuẩn đóng gói (B523/cân): Thêm thông số màn **A419**, check logic `usp_Vvt_TieuChuanPacking_Vvt`.
- Lỗi không lưu được NVL trên B597: Update/check logic trong SP `usp_Vietnam_RawMaterialInputHist_uid`.

---

<a id="phan-4"></a>
## 4️⃣ Phần 4: Quy Trình Kiểm Tra Chất Lượng - QC (C-series & B597)

### 4.1 Không tìm thấy mã Lot khi tìm kiếm ở màn C512
- **Nguyên nhân:**
  1. Chưa được tạo Lot.
  2. Mã chưa khai báo "Loại kiểm tra" và "Loại OQC" trong mục quản lý NVL / Model. (C512 INNER JOIN sẽ bị loại).
  3. (Dành cho cơ sở Hà Nam): Lot có công đoạn Route bắt đầu từ `VE02` sẽ không hiện nếu query C512 chưa xử lý Route này.
- **Cách xử lý:** 
  - Admin/IT (Huy Anh) khai báo thêm thiết lập ở **A410 / B410**. 
  - **Quan trọng:** Sau khi A410 được setup, QC phải **tắt màn hình C151 đi và mở lại** để reload lại dữ liệu cache thì popup C512 mới xuất hiện.

### 4.2 Lỗi lưu thuộc tính hạng mục kiểm tra bị "dính" kết quả của Lot cũ (B597 & C443)
- **Nguyên nhân:** Khi kiểm tra thường xuyên, nếu một Barcode đã được kiểm tra trước đó, hệ thống (theo logic SP cũ) sẽ tự động load lại kết quả (CommInspDocItem) đã lưu thay vì tạo mới.
- **Cách xử lý:** Cần tìm và xóa Doc cũ của lô đó.
  1. Tìm `CommInspDocNo` (Mã biên bản):
  ```sql
  SELECT CommInspDocNo FROM STB_CommInspDocHistory CIDH
  LEFT JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
  WHERE SI.Barcode = 'VVPO093R010707';
  ```
  2. Xóa dữ liệu để QC nhập lại từ đầu:
  ```sql
  DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = '20250717000019';
  DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = '20250717000019';
  ```
  3. SP Liên quan: `usp_GetCommInspection_HistoryForBarcode_Vietnam` (C443) và `usp_GetCommInspectionHistoryForBarcode` (B597). Màn hình config Hạng mục kiểm tra chung: **C141**, Test: **B540**.

---

<a id="phan-5"></a>
## 5️⃣ Phần 5: Quản Lý Kho NVL & Thành Phẩm (F-series)

### 5.1 Lỗi Kho bị nhập sai Warehouse/Location (Màn F330)
- **Bản chất:** Khi thủ kho nhập sai vị trí kho (Warehouse) hoặc Location, không cần xóa toàn bộ chứng từ (MaterialDocNo) mà chỉ cần UPDATE trực tiếp 3 bảng Master và Log.
- **Cách xử lý:**
  ```sql
  -- 1. Chỉnh Doc Header
  UPDATE STB_MaterialDocInfo SET TargetMaterialWarehouseCode = 'ROH_HN_WH' WHERE MaterialDocNo = '250221000220';
  
  -- 2. Chỉnh Doc Lot (Log từng tem)
  UPDATE STB_MaterialDocLotInfo SET MaterialLocationCode = 'ROH_HN_WH_01' WHERE MaterialDocNo = '250221000220';
  
  -- 3. Chỉnh Master Lot (Trạng thái tồn kho hiện tại)
  UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode = 'ROH_HN_WH', MaterialLocationCode = 'ROH_HN_WH_01' 
  WHERE LotID IN ('...');
  ```

### 5.2 Xử lý xuất hàng từ kho Holding (Chuyển sang ROH)
- Yêu cầu từ kho: Không cần xóa lịch sử xuất/nhập, chỉ cần chuyển mã kho hiện tại.
  ```sql
  -- Cập nhật lịch sử xuất sang ROH
  UPDATE STB_MaterialWarehouseInOutHist SET TargetMaterialWarehouseCode = 'ROH_VN_WH' WHERE LotID = 'ML20250430000174';
  -- Cập nhật Master
  UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode = 'ROH_VN_WH', MaterialLocationCode = 'ROH_VN_WH_01' WHERE LotID = 'ML20250430000174';
  ```

### 5.3 Lỗi sai Số lượng trong Kho (Màn F312)
- **Cập nhật số lượng Request, Allow, Picking:**
  ```sql
  UPDATE STB_MaterialDocDetail
  SET RequestQty = 200000, AllowQty = 200000, PickingAssignQty = 200000
  WHERE MaterialDocNo = '250213000154' AND MaterialCode = '122507G1PT0';
  ```

### 5.4 Chuyển tháng màn FG00 (Thành phẩm) và Ngày xuất F430
- Đưa Thành phẩm (FG) về đúng tháng kỳ kế toán:
  ```sql
  UPDATE STB_VN_FINISHGOODS_BG  SET 
      CreateDate = DATEADD(MONTH, -DATEPART(MONTH, CreateDate) + 1, CreateDate),
      DateExport = DATEADD(MONTH, -DATEPART(MONTH, DateExport) + 1, DateExport)
  WHERE IDCODE = 'FGVN_BG20250211054041195484931';
  ```
- Sửa ngày xuất F430:
  ```sql
  UPDATE STB_MaterialWarehouseInOutHist SET CreateDateTime = CAST('2025-06-30' AS DATETIME) + CAST(CreateDateTime AS TIME) WHERE LotID in ('ML2025...');
  ```

### 5.5 Một số vấn đề Kho khác
- **Tìm kiếm NVL ra cả danh sách (F721):** Kiểm tra SP `usp_vvt_MaterialLotInfo_get`. Lỗi do không handle tham số rỗng (thiếu IF/WHERE).
- **Lỗi không lưu được Lot màn F330 Đặc tính 10:** Liên quan tới format mã Lot nhà cung cấp. Kiểm tra SP `usp_DoChangeMaterialDocLotInfo` (BG2) và Function `fn_VVT_getdatebyVendorLot_MergeCode`.
- **Logic FIFO NVL/TP:** `usp_MaterialWarehouseInOutHist_iud` (NVL), Tắt FIFO (`usp_VVTMaterialWarehouse_validFIFO`). TP dùng (`usp_VN_Update_ExportExcel`).
- **Chỉnh Code NVL nhập sai màn F312:** Cập nhật ở `STB_MaterialDocDetail` và `STB_MaterialDocLotInfo` theo MaterialDocNo (Ví dụ: 250806000399).

---

<a id="phan-6"></a>
## 6️⃣ Phần 6: Quản Lý Kế Hoạch Lệnh Sản Xuất (PO - B310, B450)

### 6.1 Xóa bỏ PO / Kế hoạch sai
- **Bản chất:** Hệ thống liên kết chặt chẽ giữa Kế hoạch sản xuất Ngày (B450) và Lệnh Sản xuất (PO - B310). Cần xóa đồng bộ.
- **Cách xử lý:**
  ```sql
  -- Xóa dữ liệu Lịch Sản Xuất (B450)
  DELETE FROM STB_DayProdPlan WHERE DayPlanNo IN ('2025030300011');
  DELETE FROM STB_SetInfo WHERE DayPlanNo IN ('2025030300011');
  
  -- Xóa Lệnh Sản Xuất PO (B310)
  DELETE FROM STB_ProductionOrderInfo WHERE PONo IN ('250303000008');
  DELETE FROM STB_ProductionOrderBom WHERE PONo IN ('250303000008');
  DELETE FROM STB_ProductionOrderRouting WHERE PONo IN ('250303000008');
  ```

### 6.2 Xóa Mã Phế Liệu Lỗi (Scrap)
Nên dùng cờ `IsDeleted` thay vì lệnh DELETE vật lý để giữ vết data.
```sql
UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS SET IsDeleted = 1 WHERE ID IN ('6030', '6032');
```

---

<a id="phan-7"></a>
## 7️⃣ Phần 7: Quy Trình Slitting & Lỗi Điện Cực (B552)

### 7.1 Lỗi "Chuỗi của điện cực" (Lỗi format Độ Dày)
- **Nguyên nhân:** Khi tạo mã NVL điện cực mới, R&D cấu hình độ dày dư số 0 thập phân (ví dụ `16.00000` thay vì `16`). Hệ thống NAIS xử lý so sánh với kiểu Số nguyên (Int) gây ra lỗi.
- **Cách xử lý:** Phải sửa data về định dạng số nguyên ở nhiều bảng:
  1. Ban đầu chưa tạo Lot: Sửa `MaterialThickness` trong `STB_MaterialMaster`.
  2. Công nhân đã lỡ tạo Lot: Sửa `SIExtReal03` trong bảng `STB_SetInfo`.
  3. Giá rác điện cực: Sửa `ElectrodeThickness` ở 2 bảng `STB_ElectrodeWastePriceNew` và `STB_ElectrodeWasteInfoNew`.

### 7.2 Cập nhật Chiều rộng và Vị trí (Location) màn Slitting (B552)
Cần config khớp với bảng `STB_ElectrodeSlittingResult`.
```sql
UPDATE stb_slittinglocationconfig_vvt
SET width = 16, 
    RollQty = 20, 
    PositiveLocation = 'A6-T3', 
    NegativeLocation = 'B6-T3'
WHERE SlittingCode = 'YP' AND SlittingSize = 200 AND PartNo = '1625' AND id = 12;

-- Nếu thiếu, tiến hành INSERT (VD: 1025-10F Khổ 17.7mm)
INSERT INTO stb_slittinglocationconfig_vvt (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES 
('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),
('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2'),
('1325', 'BY', '200', '15', '18.7', 'VVT_F2', 'kho2'),
('1325', 'YP', '180', '15', '18.7', 'VVT_F2', 'kho2'),
('1030', 'BY', '200', '10', '23.7', 'VVT_F2', 'kho2'),
('1030', 'YP', '180', '10', '23.7', 'VVT_F2', 'kho2');
```

---

<a id="phan-8"></a>
## 8️⃣ Phần 8: Báo Cáo Andon, Giá & SQL Report Khác

### 8.1 Up giá tính lương công đoạn (B682, B781)
Thêm giá (`Price`) tương ứng với từng Công đoạn (`Route`) vào `STB_VVT_StagePrices`. Cho B789/B791 thì kiểm tra trong function `fn_VVT_StagePricesMODULE`.
```sql
INSERT INTO STB_VVT_StagePrices (model, RouteV22, PriceV22, RouteV23, PriceV23, CreateDate)
VALUES ('ECVT27-399', 'V-22', 0.0657356, 'V-23', 0.0718827, GETDATE());
```

### 8.2 Bảng Màn hình Andon (Hiển thị cho xưởng)
- **Mở dữ liệu theo tháng / số dòng hiển thị:** Điều chỉnh tham số/logic phân trang bên trong Stored Procedure `usp_Vietnam_AndonDetail_get`.

### 8.3 Query trích xuất PartNo & Model nhanh từ chuỗi tên
```sql
-- Lấy Model từ chuỗi dài
SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE('HY-CAP VEC3R0606QG (1840)','HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)','') AS model

-- Lấy PartNo (12 ký tự)
SELECT (RTRIM(LTRIM(SUBSTRING('HY-CAP VEC3R0606QG (1840)', CHARINDEX(' ', 'HY-CAP VEC3R0606QG (1840)'), 12)))) AS partno
```

### 8.4 SQL Lấy Tên Model & Kích thước tự động (Cho màn B597)
Sử dụng script truy vấn `STB_ModelBasicInfo` và xử lý chuỗi:
```sql
DECLARE @ModelSize VARCHAR(10) = '';
DECLARE @ModelName NVARCHAR(200) = '';

-- Lấy Size
SELECT @ModelSize = RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
FROM STB_ModelBasicInfo WITH(NOLOCK)
WHERE modelcode  = (SELECT MaterialCode FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode in ('VVPR293R018602'));

-- Lấy ModelName
SELECT @ModelName = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ModelName,@ModelSize,''),'(',''),')',''),' ',''),'HY-CAP ',''),'HY-CAP',''),'-','%')
FROM STB_ModelBasicInfo WITH(NOLOCK)
WHERE modelcode  = (SELECT MaterialCode FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode in ('VVPR293R018602'));

PRINT (@ModelName + ' ' + @ModelSize);
```

### 8.5 Xóa Mã Sparepart Thừa (H131)
- Xóa theo `sparepartcode` trong bảng `STB_VNSparePartInfo`:
```sql
DELETE FROM STB_VNSparePartInfo WHERE sparepartcode = 'ma sparepart';
```
