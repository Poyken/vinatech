# 🛠️ NAIS MES — Knowledge Base: Lỗi Thường Gặp & Cách Xử Lý

> **Tổng hợp từ:** `Lỗi trên NAIS System_Tái bản.docx` & `Một số lỗi Nais System.docx`
> **Cập nhật:** 2026-04-20
> **Cách dùng:** Nhấn `Ctrl + F` để tìm kiếm theo mã màn hình (VD: B597), tên lỗi, hoặc tên bảng DB.

---

## 📋 Mục Lục Nhanh

| # | Nhóm | Màn hình liên quan |
|---|------|--------------------|
| 1 | [🖥️ UI / Đăng nhập / Cài đặt](#1-ui--đăng-nhập--cài-đặt) | Login, A460, A419 |
| 2 | [👤 Quản lý User & Phân quyền](#2-quản-lý-user--phân-quyền) | B260, Z410, Z220, Z330 |
| 3 | [💰 Giá & Module (Stage Prices)](#3-giá--module-stage-prices) | B682, B781, B789, B791 |
| 4 | [📦 Kho Nguyên Vật Liệu (WMS)](#4-kho-nguyên-vật-liệu-wms) | F330, F312, F430, F110, F721 |
| 5 | [🏭 Sản xuất & Lịch sử Routing](#5-sản-xuất--lịch-sử-routing) | B570, B782, B781, B598, B726, B791 |
| 6 | [📦 Đóng gói & In tem](#6-đóng-gói--in-tem) | B523, B789, B781, B450, B351 |
| 7 | [🔬 Kiểm tra Chất lượng (QC)](#7-kiểm-tra-chất-lượng-qc) | B597, C443, C512, B270, B540 |
| 8 | [⚡ Điện cực (Electrode)](#8-điện-cực-electrode) | B552 (Slitting) |
| 9 | [📐 Master Data & Model](#9-master-data--model) | A410, STB_ModelBasicInfo |
| 10| [🔎 Công cụ & Truy vấn Hỗ trợ](#10-công-cụ--truy-vấn-hỗ-trợ) | SQL Utilities |

---

## 1. 🖥️ UI / Đăng nhập / Cài đặt

### 1.1 Lỗi không đăng nhập được vào MES

**Triệu chứng:** Màn hình login bị lỗi, không vào được hệ thống NAIS.

**Cách xử lý:**
1. **C1:** Chạy file Update và vào lại hệ thống NAIS.
2. **C2:** Nếu update không được → Xóa **tất cả** các thư mục trong `C:\AwooSystem` rồi cài lại:
   - Link cài: `http://mes.hycap.co.kr:9952/`
   - Setting lại **New System**: `Alias: nais`, `Url: http://mes.hycap.co.kr:9952`

---

### 1.2 Lỗi không in được tem ở màn B450

**Triệu chứng:** Màn B450 báo lỗi không in tem.

**Cách xử lý:** Vào màn **A460** → Tìm đúng loại tem:
- **In tem cho Sản xuất:** `AssembleLabel` (dòng 2)
- **In tem cho Kho:** `PartLabel`

---

### 1.3 Lỗi popup không hiện trên B270

**Cách xử lý:** Sang màn **B230** để xử lý thay thế.

---

## 2. 👤 Quản lý User & Phân quyền

| Tác vụ | Màn hình |
|--------|----------|
| Thêm danh sách công nhân | **B260** |
| Thêm tài khoản MES cho người mới | **Z410** |
| Phân quyền người dùng | **Z220** |
| Thêm màn hình mới cho người dùng | **Z330** |

---

## 3. 💰 Giá & Module (Stage Prices)

### 3.1 Add giá lên màn B682 & B781

```sql
-- Template INSERT giá theo từng Route cho 1 model
INSERT INTO STB_VVT_StagePrices (
    model, RouteV22, PriceV22, RouteV23, PriceV23,
    RouteV24, PriceV24, RouteV25, PriceV25, RouteV26, PriceV26,
    RouteV27, PriceV27, RouteV28, PriceV28, CreateDate
)
VALUES (
    'ECVT27-399',  -- Điền mã Model
    'V-22', [Giá],
    'V-23', [Giá],
    'V-24', [Giá],
    'V-25', [Giá],
    'V-26', [Giá],
    'V-27', [Giá],
    'V-28', [Giá],
    GETDATE()
);
```

---

### 3.2 Add giá Module lên màn B789 & B791

**Vị trí xử lý:** Function `fn_VVT_StagePricesMODULE`

```sql
-- Ví dụ thêm giá MODULE
select 'EDVTMD-214', '0.254127629071929', '0.257442076659429', '0.258507610420299'
union all
-- ... thêm các dòng tiếp theo
```

---

### 3.3 Xóa / Sửa số lượng Packing ở màn B789

```sql
-- 1. Tìm record sai số lượng
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = '[Điền LotNo]'

-- 2. Sửa số lượng
UPDATE STB_SavePackingTime_VVT
SET PackQty = [Số lượng mới]
WHERE LotNo = '[LotNo]' AND id = '[ID]'

-- 3. Xóa nếu cần
DELETE FROM STB_SavePackingTime_VVT
WHERE LotNo = '[LotNo]' AND id = '[ID]'
```

---

### 3.4 Lỗi Stored Procedure - Đổi đầu mã (B789)

- **SP liên quan:** `usp_Vietnam_GetBoxIDForLotNo_VVT`
- **Lỗi lưu nhưng không hiện (Packing Qty âm ở B523):** SP `usp_savePackingLabelQty_VVT`

---

### 3.5 Bỏ in VV thành VJ theo Code NVL

```sql
UPDATE STB_Vietnam_PackingPrinting
SET PrintVJ = 0
WHERE MaterialCode = '[Điền mã NVL]'
```

---

## 4. 📦 Kho Nguyên Vật Liệu (WMS)

### 4.1 Tìm kiếm theo mã nguyên liệu ra cả danh sách (F721)

**Nguyên nhân:** Điều kiện tìm kiếm trong SP bị sai.

**Cách xử lý:** Vào `usp_vvt_MaterialLotInfo_get` → Kiểm tra lại điều kiện tìm kiếm.

---

### 4.2 Không tìm thấy mã lot khi tìm kiếm ở C512

- **TH1:** Liên hệ anh Huy để anh thêm thông tin model ở màn **B410**.
- **TH2 (Hà Nam):** Các mã test tháng 12 bắt đầu từ Route `VE02` nên không hiện.

---

### 4.3 Chỉnh lại Kho bị nhập sai ở màn F330

> ⚠️ Phải update đồng thời **3 bảng**: `STB_MaterialDocInfo`, `STB_MaterialDocDetail`, `STB_MaterialDocLotInfo` và `STB_MaterialLotInfo`.

```sql
-- B1: Xem và sửa Header
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = '250221000220'
UPDATE STB_MaterialDocInfo
SET TargetMaterialWarehouseCode = 'ROH_HN_WH'
WHERE MaterialDocNo = '250221000220'

-- B2: Tìm các LotID trong phiếu
SELECT * FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '250221000220'

-- B3: Update tất cả các LotID (thay các LotID vào IN)
UPDATE STB_MaterialDocLotInfo
SET MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN (...)

UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_HN_WH', MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN (...)
```

---

### 4.4 Chỉnh Code NVL nhập sai ở màn F312

> **Cột "Số tài liệu"** = `MaterialDocNo`. Sửa ở 2 bảng: `STB_MaterialDocDetail` và `STB_MaterialDocLotInfo`.

```sql
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = '250806000399'
SELECT * FROM STB_MaterialDocDetail WHERE MaterialDocNo = '250806000399'
SELECT * FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '250806000399'

-- Sau khi xác định → UPDATE MaterialCode tại STB_MaterialDocDetail và STB_MaterialDocLotInfo
```

---

### 4.5 Sửa số lượng màn F312 (Kho chị Xuân)

```sql
UPDATE STB_MaterialDocDetail
SET RequestQty = 200000, AllowQty = 200000, PickingAssignQty = 200000
WHERE MaterialDocNo = '250213000154' AND MaterialCode = '122507G1PT0'
```

---

### 4.6 Sửa ngày xuất màn F430

```sql
-- Xem trước
SELECT * FROM STB_MaterialWarehouseInOutHist
WHERE LotID IN ('ML20250620000036', 'ML20250520000061', 'ML20250527000412')

-- Cập nhật ngày xuất (SP: usp_MaterialWarehouseInOutHist_get)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2025-06-30' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE LotID IN ('ML20250620000036', 'ML20250520000061', 'ML20250527000412')
```

---

### 4.7 Chỉnh sửa từ kho Holding ra kho chính (Theo yêu cầu chị Phượng)

> Không cần xóa lịch sử xuất nhập — chỉ cần chuyển mã kho.

```sql
-- Xem dữ liệu
SELECT * FROM STB_MaterialWarehouseInOutHist WHERE LotID = 'ML20250430000174'
SELECT * FROM STB_MaterialLotInfo WHERE LotID = 'ML20250430000174'

-- Cập nhật lịch sử xuất
UPDATE STB_MaterialWarehouseInOutHist
SET TargetMaterialWarehouseCode = 'ROH_VN_WH'
WHERE LotID = 'ML20250430000174'

-- Cập nhật trạng thái hiện tại
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_VN_WH', MaterialLocationCode = 'ROH_VN_WH_01'
WHERE LotID = 'ML20250430000174'
```

---

### 4.8 Chỉnh sửa Location (Thuộc tính LotAttr09)

- **Xem ở màn F721**
- **Xem tại bảng:** `STB_MaterialDocLotInfo`
- **Xem tại màn hình Location:** `192.168.1.234:9000/tv`
- **Xem tại bảng:** `STB_MaterialLotInfo`

---

### 4.9 FIFO NVL

- **Tắt FIFO cho toàn bộ:** Tìm SP `usp_MaterialWarehouseInOutHist_iud`
- **Tắt FIFO cho NVL cụ thể:** SP `usp_VVTMaterialWarehouse_validFIFO`

---

### 4.10 Lỗi không lưu được Lot màn F330 (Hà Nam)

**Xử lý:**
1. **Hỏi user** về công thức, Lot No, và cách đọc.
2. Vào SP `usp_DoChangeMaterialDocLotInfo` (BG2).
3. Tìm kiếm trong function `fn_VVT_getdatebyVendorLot_MergeCode`.

---

### 4.11 Xóa mã Sparepart thừa (H131)

```sql
-- Tìm tới store: STB_VNSparePartInfo
DELETE FROM STB_VNSparePartInfo
WHERE sparepartcode = '[Mã sparepart cần xóa]'
```

---

## 5. 🏭 Sản xuất & Lịch Sử Routing

### 5.1 Chuyển JobDate màn B782 (Lịch sử Routing)

```sql
-- B1: Tìm ControlNo theo Barcode
SELECT * FROM STB_ProdRouteHist
WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo
    WHERE Barcode IN ('VVPO273R010713', 'VVPO123R010711')
)
AND RouteCode IN ('V-26_BG')

-- B2: Chỉnh ngày (thay đổi ngày trong CAST)
UPDATE STB_ProdRouteHist
SET ProdDateTime = CAST('2025-02-17' AS DATETIME) + CAST(ProdDateTime AS TIME),
    JobDate = '2025-02-17'
WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo
    WHERE Barcode IN ('VVPK173R010710', 'VVPK173R010711')
)
AND RouteCode IN ('V-22_BG')
```

> **SP dùng để xác minh:** `usp_LotTrackingInfo_VVT2_get`

---

### 5.2 Chuyển JobDate màn B781 (Packing History)

```sql
-- B1: Xem dữ liệu trước (SP: usp_Vietnam_PackPrintTime_get)
SELECT SPT.* FROM STB_SavePackingTime_VVT SPT
LEFT JOIN STB_SetInfo SI ON SPT.LotNo = SI.Barcode
WHERE SPT.LotNo IN ('VVPK173R015603', 'VVPK173R015606')
AND SI.InputLineCode = 'VVBGC-02'

-- B2: Chỉnh ngày
UPDATE STB_SavePackingTime_VVT
SET PrintTime = CAST('2025-02-17' AS DATETIME) + CAST(PrintTime AS TIME)
WHERE LotNo IN ('VVPK173R015603', 'VVPK173R015606')
AND ID IN ('1217734', '1217736')
```

---

### 5.3 Chuyển JobDate màn B598 (Production Error)

> **Lưu ý:** `JobDate` tự động gen theo `CreateDateTime`. Ví dụ: muốn JobDate về ngày 17 → chuyển `CreateDateTime` về ngày **18**.

```sql
UPDATE STB_VN_PRODUCTION_ERROR
SET CreateDateTime = CAST('2025-02-18' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE IDPE IN (...)
```

---

### 5.4 Chuyển JobDate màn B726 (Scrap After Production)

```sql
-- Tìm dữ liệu: Ấn "Xem thông tin chi tiết" để tìm kiếm theo ngày

-- Chỉnh ngày
UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS
SET CreateDateTime = CAST('2025-03-01' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE ID = 4962

-- Xóa mềm (soft delete)
UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS
SET IsDeleted = 1
WHERE ID IN ('6030', '6032', '6027', '6025', '6026', '6031')
```

---

### 5.5 Chuyển tháng màn FG00 (Kho Thành Phẩm BG)

> **Ngày nhập:** `CreateDate` | **Ngày xuất:** `DateExport`

```sql
-- Chuyển về tháng 1
UPDATE STB_VN_FINISHGOODS_BG
SET CreateDate = DATEADD(MONTH, -DATEPART(MONTH, CreateDate) + 1, CreateDate),
    DateExport = DATEADD(MONTH, -DATEPART(MONTH, DateExport) + 1, DateExport)
WHERE IDCODE = 'FGVN_BG20250211054041195484931'
```

---

### 5.6 Xóa PO (Production Order)

> ⚠️ **Phải xóa ở cả 2 màn hình: B450 và B310 cùng lúc** (xóa đủ các bảng liên quan).

```sql
-- === B450 ===
DELETE FROM STB_DayProdPlan WHERE DayPlanNo IN ('2025030300011', '2025030400202', ...)
DELETE FROM STB_SetInfo WHERE DayPlanNo IN ('2025030300011', '2025030400202', ...)

-- === B310 ===
DELETE FROM STB_ProductionOrderInfo WHERE PONo IN ('250303000008', '250304000011', ...)
DELETE FROM STB_ProductionOrderBom WHERE PONo IN ('250303000008', '250304000011', ...)
DELETE FROM STB_ProductionOrderRouting WHERE PONo IN ('250303000008', '250304000011', ...)
```

---

### 5.7 Sửa số lượng NG (DefectQty) màn B791

```sql
-- Tìm kiếm
SELECT * FROM STB_DefectRepairInfo WHERE ControlNo = '20250314000351'

-- Sửa DefectQty
UPDATE STB_DefectRepairInfo
SET DefectQty = 4
WHERE ControlNo = '20250314000351'

-- Sửa số lượng input công đoạn sau (ProdQty phải = TotalQty - DefectQty)
UPDATE STB_ProdRouteHist
SET ProdQty = '3996'
WHERE ControlNo = '20250314000351' AND RouteCode = 'MV-05'
```

---

### 5.8 Chuyển Line sản xuất

```sql
-- Ví dụ chuyển Line 11 sang Line 12:
UPDATE STB_SetInfo
SET InputLineCode = 'VVBGC-12'
WHERE Barcode = 'VVOR163R010713'

UPDATE STB_ProdRouteHist
SET LineCode = 'VVBGC-12'
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVOR163R010713')
```

---

### 5.9 Chuyển các mã từ VV sang VJ

```sql
UPDATE STB_SetInfo SET Barcode = 'VJOQ062R725633' WHERE Barcode = 'VVOQ062R725633';
UPDATE STB_LotChangeMaterialHistory SET NewBarcode = 'VJOQ062R725633' WHERE NewBarcode = 'VVOQ062R725633';
UPDATE STB_SavePackingTime_VVT SET LotNo = 'VJOQ062R725633' WHERE LotNo = 'VVOQ062R725633';    -- B781
UPDATE STB_MaterialLotInfo SET LotNo = 'VJOQ062R725633' WHERE LotNo = 'VVOQ062R725633';        -- B523 in tem
```

---

### 5.10 Chuyển dữ liệu về ngày (B781 & B782)

```sql
-- === B781: STB_SavePackingTime_VVT ===
UPDATE STB_SavePackingTime_VVT
SET PrintTime = REPLACE(CONVERT(VARCHAR, PrintTime, 120), '2024-11-11', '2024-11-08')
WHERE LotNo IN ('VVOT083R033556', 'VVOT083R033557', ...)

-- === B782: STB_ProdRouteHist ===
UPDATE STB_ProdRouteHist
SET ProdDateTime = REPLACE(CONVERT(VARCHAR, ProdDateTime, 120), '2024-11-11', '2024-11-08')
WHERE ControlNo IN (
    SELECT ControlNo FROM STB_SetInfo
    WHERE Barcode IN ('VVOT083R033556', 'VVOT083R033557', ...)
)
```

---

### 5.11 Mở dữ liệu Andon theo tháng cho Sản xuất

**SP:** `usp_Vietnam_AndonDetail_get`

→ Vào SP → Chỉnh lại điều kiện tìm kiếm theo tháng user yêu cầu.

---

## 6. 📦 Đóng gói & In tem

### 6.1 Lỗi chưa có tiêu chuẩn đóng gói (màn B523 và phần mềm cân)

- **Thêm số lượng đóng gói:** Thêm ở màn **A419**.
- **Thêm tiêu chuẩn cân:** SP `usp_Vvt_TieuChuanPacking_Vvt`.

---

### 6.2 Sửa tên Lot sau khi update thông số Model ở A410 (trường hợp chuyển Lot ở B351)

```sql
-- Tìm kiếm Barcode bị sai định dạng (dấu chấm thay vì R)
SELECT * FROM STB_RawMaterialInputHist WHERE Barcode = 'VVPR152.740601'
SELECT * FROM STB_SetInfo WHERE Barcode = 'VVPR152.740601'
SELECT * FROM STB_LotChangeMaterialHistory WHERE NewBarcode = 'VVPR152.740601'

-- Cập nhật format chuẩn
UPDATE STB_RawMaterialInputHist SET Barcode = 'VVPR152R740601' WHERE Barcode = 'VVPR152.740601'
UPDATE STB_SetInfo SET Barcode = 'VVPR152R740601' WHERE Barcode = 'VVPR152.740601'
UPDATE STB_LotChangeMaterialHistory SET NewBarcode = 'VVPR152R740601' WHERE NewBarcode = 'VVPR152.740601'
```

---

### 6.3 Sửa mã in lại tem B523

```sql
-- Tìm kiếm MaterialLotNo
SELECT * FROM STB_MaterialLotInfo MLI
LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
WHERE SI.Barcode = 'VVOO053R825706'

-- Sửa MaterialCode
UPDATE STB_MaterialLotInfo
SET MaterialCode = 'LIVT38-025'
WHERE MaterialLotNo = 20240612000524
```

---

### 6.4 FIFO Kho thành phẩm

→ Vào **F110** → Tick chọn option FIFO.

→ **SP:** `usp_VN_Update_ExportExcel` (VVT) | `usp_VN_Update_ExportExcel_BG` (Bắc Giang)

---

## 7. 🔬 Kiểm tra Chất lượng (QC)

### 7.1 Sửa hạng mục loại hình kiểm tra ở B597 & C443

**Nguyên nhân:** Nếu Barcode đã được kiểm tra lần trước → hệ thống sẽ load lại các hạng mục kiểm tra cũ.

**Cách kiểm tra trước:**
1. Vào **B540** → Dán mã barcode vào tìm kiếm → Ấn nút **"Việt Nam_Kiểm tra thường xuyên"**.

**Cách sửa:**

*Với C443:* Vào SP `usp_GetCommInspection_HistoryForBarcode_Vietnam`

*Với B597:* Vào SP `usp_GetCommInspectionHistoryForBarcode`

```sql
-- Tìm CommInspDocNo theo Barcode
SELECT * FROM STB_CommInspDocHistory CIDH
LEFT JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
WHERE SI.Barcode = 'VVPO093R010707'

-- Xem chi tiết hạng mục
SELECT * FROM STB_CommInspDocItem
WHERE CommInspDocNo IN (
    SELECT CommInspDocNo FROM STB_CommInspDocHistory CIDH
    LEFT JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
    WHERE SI.Barcode = 'VVPO093R010707'
)

-- Tìm theo ControlNo trực tiếp
SELECT * FROM STB_CommInspDocHistory
WHERE ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVPP163R072732')

-- Xóa hạng mục để tạo lại
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = '...'
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = '...'
```

---

### 7.2 Không tìm thấy ở màn C512

**Nguyên nhân có 3 trường hợp:**
- **TH1:** Đã tạo Lot rồi → không cần tạo lại.
- **TH2:** Phải thiết lập các hạng mục "Loại kiểm tra" và "Loại OQC" tại màn **A410**.
  - Sau khi thiết lập xong → Tắt màn C151 → Vào lại.
- **TH3 (Hà Nam):** Các mã test tháng 12 bắt đầu từ Route `VE02` nên không hiện.

> Mã Barcode ở C512 phải do bên **Sản xuất** cung cấp cho QC (không tự nhập).

---

## 8. ⚡ Điện cực (Electrode)

### 8.1 Chỉnh chiều rộng Slitting màn B552

```sql
-- Xem cấu hình master
SELECT * FROM STB_CoatingToSlittingMaster
-- WHERE CoatingMaterialCode = 'CRYPK0-011'

-- Cập nhật chiều rộng
UPDATE stb_slittinglocationconfig_vvt
SET Width = 16
WHERE SlittingCode = 'YP' AND SlittingSize = 200 AND PartNo = '1625' AND id = 12
```

---

### 8.2 Update Location Slitting (thêm cấu hình mới)

> ⚠️ `WarehouseLocation`, `LocationWarehouse` phải match với bảng `STB_ElectrodeSlittingResult`.

```sql
-- Template thêm cấu hình (ví dụ 3 model: 1025-10F, 1325-15F, 1030-10F)
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),  -- Cực dương 1025
    ('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2'),  -- Cực âm 1025
    ('1325', 'BY', '200', '15', '18.7', 'VVT_F2', 'kho2'),  -- Cực dương 1325
    ('1325', 'YP', '180', '15', '18.7', 'VVT_F2', 'kho2'),  -- Cực âm 1325
    ('1030', 'BY', '200', '10', '23.7', 'VVT_F2', 'kho2'),  -- Cực dương 1030
    ('1030', 'YP', '180', '10', '23.7', 'VVT_F2', 'kho2')   -- Cực âm 1030

-- Xác nhận dữ liệu đã insert (thay ID thực tế)
SELECT * FROM stb_slittinglocationconfig_vvt WHERE id IN (179, 180, 181, 182, 183, 184)

-- Cập nhật số cuộn và vị trí kho
UPDATE stb_slittinglocationconfig_vvt
SET RollQty = 20, PositiveLocation = 'A6-T3', NegativeLocation = 'B6-T3'
WHERE id IN (183, 184)
```

---

### 8.3 Lỗi không lưu được NVL trên B597 (Lỗi chuỗi điện cực)

**Nguyên nhân:**
- NVL điện cực mới đăng ký thiếu/sai **Độ dày (MaterialThickness)**.
- Hệ thống so sánh chuỗi bị lỗi khi độ dày dạng `200` != `200.000000`.

**Cách sửa:**
1. **Sửa tại SP:** Vào `usp_Vietnam_RawMaterialInputHist_uid` → Thêm exception cho trường hợp đặc biệt.
2. **Sửa dữ liệu Master:**
   - `STB_MaterialMaster`: Sửa `MaterialThickness` thành **số nguyên** (không có `.00000`).
   - `STB_SetInfo`: Nếu công nhân đã tạo Lot → sửa cột `SIExtReal03` (dạng `.00000`).
3. **Nếu bị lỗi rõ ràng hơn:** Sửa cột `ElectrodeThickness` ở 2 bảng:
   - `STB_ElectrodeWastePriceNew`
   - `STB_ElectrodeWasteInfoNew`

---

## 9. 📐 Master Data & Model

### 9.1 Thêm Model mới vào STB_ModelBasicInfo

> ⚠️ Chú ý: Một số Model có trong `STB_MaterialMaster` nhưng **không có** trong `STB_ModelBasicInfo` → Phải thêm tay.

```sql
-- Kiểm tra xem model đã có trong MaterialMaster chưa
SELECT * FROM STB_MaterialMaster WHERE MaterialCode = 'RDMD00-358'

-- Thêm Model mới vào ModelBasicInfo
INSERT INTO STB_ModelBasicInfo (
    ModelCode, ModelName, MaterialTypeCode, ProductGroupCode,
    MBISizeH, MBISizeW, IsClosed, OqcType, OqcInspectionRuleType,
    InspectionType, InspectionLevel,
    MBIExtText01, MBIExtText02, MBIExtText03, MBIExtText04, MBIExtText05,
    CreateDateTime
)
VALUES (
    'EDVTMD-247',       -- ModelCode
    'HY-CAP WEC9R0335QG-LG', -- ModelName
    'MDL', 'HC-EDLC',  -- MaterialTypeCode, ProductGroupCode
    30, 10,             -- H, W (size)
    0,                  -- IsClosed
    'MANUAL', 'BY_MODEL', 'SAMPLE', 'SAMPLE',
    '9R0', '335', 'WEC', '9.0', '3.3',  -- Vol, Farad, Type, VolNum, FaradNum
    GETDATE()
)
```

---

### 9.2 Lỗi không hiển thị Vol, Farad khi tạo Lot/In tem

**Nguyên nhân:** Do Views `VW_ModelBasicInfo` không hiển thị được.

**Cần sửa:** `MaterialTypeCode` ở bảng `STB_MaterialMaster` hoặc `STB_ModelBasicInfo`.

---

### 9.3 Lỗi NVL mới không gộp Box được

**Xử lý:** Vào **F110** → Tick chọn option gộp box.

---

### 9.4 Chỉnh số LotNo, Vol, Farad khi tạo Lot / In tem

Xem và sửa trong bảng `STB_ModelBasicInfo`.

---

### 9.5 Sửa giá lên B781 (ví dụ thực tế)

```sql
INSERT INTO STB_VVT_StagePrices (
    model, RouteV22, PriceV22, RouteV23, PriceV23,
    RouteV24, PriceV24, RouteV25, PriceV25,
    RouteV26, PriceV26, RouteV27, PriceV27, RouteV28, PriceV28, CreateDate
)
VALUES (
    'ECVT27-399',
    'V-22', 0.0657356,
    'V-23', 0.0718827,
    'V-24', 0.0897135,
    'V-25', 0.0945566,
    'V-26', 0.0945566,
    'V-27', 0.1100989,
    'V-28', 0.1183676,
    GETDATE()
);
```

---

## 10. 🔎 Công cụ & Truy vấn Hỗ trợ

### 10.1 Lấy Part No từ tên Model

```sql
-- Lấy mã model (bỏ prefix HY-CAP)
SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    'HY-CAP VEC3R0606QG (1840)', 'HY-CAP ', ''), 'HY-CAP', ''),
    '-C', ''), '-M', ''), 'MSP', ''), '(CY)', '') AS model

-- Lấy PartNo (12 ký tự sau dấu cách đầu)
SELECT RTRIM(LTRIM(SUBSTRING('HY-CAP VEC3R0606QG (1840)',
    CHARINDEX(' ', 'HY-CAP VEC3R0606QG (1840)'), 12))) AS partno
```

---

### 10.2 Tra tên Model và Size (B597)

```sql
DECLARE @ModelSize VARCHAR(10) = '';
DECLARE @ModelName NVARCHAR(200) = '';

-- Lấy size
SELECT @ModelSize = RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2)
    + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
FROM STB_ModelBasicInfo WITH (NOLOCK)
WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WITH (NOLOCK) WHERE Barcode IN ('VVPR293R018602'))

-- Lấy tên model đã clean
SELECT @ModelName = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    ModelName, @ModelSize, ''), '(', ''), ')', ''), ' ', ''), 'HY-CAP ', ''), 'HY-CAP', ''), '-', '%')
FROM STB_ModelBasicInfo WITH (NOLOCK)
WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WITH (NOLOCK) WHERE Barcode IN ('VVPR293R018602'))

PRINT(@ModelName + ' ' + @ModelSize)
```

---

### 10.3 Tra cứu SP theo màn hình

```sql
-- Tìm SP của 1 màn hình cụ thể
SELECT ScreenName, ObjectName, ObjectType, Description
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName = '[Tên màn hình]'
-- SearchFunction = SP đọc dữ liệu
-- ExecuteFunction = SP khi bấm Save/Delete
```

---

### 10.4 Kiểm tra lịch sử toàn bộ 1 Barcode (Golden Query)

```sql
SELECT
    PRH.ControlNo AS [Mã vạch SP],
    PRH.PONo AS [Lệnh SX],
    RI.RouteName AS [Công đoạn],
    PRH.CreateDateTime AS [Giờ quét],
    DP.PackingID AS [Mã Thùng],
    DP.ParentPackingID AS [Mã BigBox]
FROM STB_ProdRouteHist PRH WITH(NOLOCK)
LEFT JOIN STB_RouteInfo RI WITH(NOLOCK) ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_DividePackaging DP WITH(NOLOCK) ON PRH.ControlNo = DP.LotNo
WHERE PRH.ControlNo = '[Barcode cần tra]'
ORDER BY PRH.CreateDateTime ASC
```

---

*Tài liệu được tổng hợp và cập nhật bởi Antigravity AI — Vinatech MES Knowledge Base.*
