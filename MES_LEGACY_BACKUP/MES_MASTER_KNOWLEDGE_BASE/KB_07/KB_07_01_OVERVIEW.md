<!--
AI-READY METADATA
Purpose: Kiến trúc tổng thể & Cẩm nang vận hành Master nhà máy Hưng Yên (VVT_F5) & VinaEnesol Ecosystem
Scope: Hung Yen VVT_F5 Architecture, 17 HY Screens, VinaEnesol Box Matching & Master Data
Single Source of Truth: KB_07_01_OVERVIEW.md (Hung Yen Architecture & Master Data)
Target Screens: HY103, HY141, HY143, HY151, HY220, HY311, HY312, HY330, HY430, HY431, HY443, HY530, HY540, HY541, HY620, HY740, HYFG01, D000, D051, D100, D110
Target Tables: STB_CustomerInfoEnesol, STB_MaterialCodeByCustomer, STB_VINAEnesolBoxLabelPrintHist, STB_VINAEnesolBoxMatchingHist, STB_DetailAgingHY, STB_LineInfo, STB_VN_FINISHGOODS_HY
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)
  - [KB_07_02_DEPLOY_HY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md)
  - [KB_07_03_SCREEN_BUGS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md)
  - [KB_07_04_HUNG_YEN_WBS_MAPPING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_04_HUNG_YEN_WBS_MAPPING.md)
-->

# KB_07 — VinaEnesol & Hưng Yên Factory Master Knowledge Base

> **Mã nhà máy (WorkCenterCode):** `VVT_F5` (Hưng Yên Factory)  
> **Mã Công Ty (CompanyCode):** `VVT` / `VNT` (Legacy: `VNT_F5`)  
> **Màn hình chính:** `D000` Menu (`D051`, `D100`, `D110`), `HY103` $\rightarrow$ `HYFG01` (17 màn hình tùy biến Hưng Yên)  
> **🔑 Keywords:** Hưng Yên, VinaEnesol, VVT_F5, D-series, HY-series, Box Matching, Inner Box, Outer Box, Enesol Vendor P/N, STB_DetailAgingHY  
> ← [Về Master Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)

---

## 1. 🏭 Tổng Quan Kiến Trúc Nhà Máy Hưng Yên (`VVT_F5`)

Hệ thống Vinatech MES điều hành toàn bộ quy trình sản xuất, kho bãi và chất lượng tại nhà máy **Hưng Yên (WorkCenterCode: `VVT_F5`)** thông qua 2 khối chức năng cốt lõi:

### 1.1 Môi Trường Vận Hành Sản Xuất Hưng Yên (`VVT_F5` / `HY` Prefix)
- **Mã Line sản xuất Cell (Chuyền Tụ Cell):** `VVHYC-01` $\rightarrow$ `VVHYC-06`.
- **Mã Line sản xuất Module (Chuyền Module Tụ):** `VVHYMD-01` $\rightarrow$ `VVHYMD-04`.
- **Hệ thống Kho vật lý Hưng Yên:**
  - `ROH_HY_WH`: Kho Nguyên vật liệu Hưng Yên.
  - `FGT_HY_WH`: Kho Thành phẩm Hưng Yên (`STB_VN_FINISHGOODS_HY`).
  - `VNE_PRODUCT_WH`: Kho Thành phẩm VinaEnesol chuyên biệt.
  - `HOLDING_HY_WH`: Kho Hold kiểm định chất lượng Hưng Yên.
  - Kho công đoạn sản xuất: `ROUTE_HY_WH`, `SLITTING_HY_WH`, `REWORK_HY_WH`, `REJECT_HY_WH`, `SCRAP_HY_WH`, `DOPING_HY_WH`, `OVEN_HY_WH`, `MIXING_HY_WH`, `COATING_HY_WH`, `PRESSING_HY_WH`.

---

## 2. 📱 Bản Đồ 17 Màn Hình Chuyên Biệt Nhà Máy Hưng Yên (`HY` Series)

Hệ thống nhân bản 17 màn hình tùy biến giao diện khép kín (`HY` Prefix) dành riêng cho công nhân và quản lý Hưng Yên:

| TCode | Tên Kỹ Thuật (Caption) | Phân Hệ | Chức Năng Nghiệp Vụ & SP Chính | Bảng DB Tác Động |
| :--- | :--- | :--- | :--- | :--- |
| `HY103` | PricesAndMaterialHY | Kho NVL | Quản lý tồn kho real-time kho `ROH_HY_WH`, giá và mã hàng tại Hưng Yên | `STB_MaterialLotInfo`, `STB_MaterialMaster` |
| `HY121` | QCInspectionGroupCode_HY | QC | Tạo nhóm hạng mục kiểm tra IQC Hưng Yên | `STB_MaterialQcInspectionGroup_HY` |
| `HY141` | HY_CommonInspTypeInfo | QC | Khai báo loại kiểm tra chung và Spec đo kiểm IQC | `STB_CommInspTypeInfo`, `STB_CommInspIndividualSpec` |
| `HY143` | HY_CommInspIndividualSpec | QC | Quản lý chỉ tiêu kỹ thuật đo kiểm PQC Hưng Yên | `STB_CommInspIndividualSpec` |
| `HY151` | HY_MaterialQcInspectionItem | QC | Thiết lập hạng mục kiểm tra QC cho từng mã vật tư NVL Hưng Yên | `STB_MaterialQcInspectionItem_HY` |
| `HY220` | Process Setup HY | Master | Cấu hình danh mục các bước công đoạn sản xuất Hưng Yên | `STB_RouteInfo` |
| `HY311` | PO_Electrode_HY | Sản xuất | Lập lệnh sản xuất PO cho công đoạn Điện cực Hưng Yên (`PO_Electrode_HY`) | `STB_ProductionOrderInfo`, `STB_ProductionOrderRouting` |
| `HY312` | HY_MaterialGrFromOrder | Sản xuất | Tra cứu thông tin chi tiết PO sản xuất Hưng Yên và nhập hàng từ đơn hàng | `STB_ProductionOrderInfo` |
| `HY330` | Material Dispatch HY | Kho NVL | Cấp phát NVL ra chuyền sản xuất Hưng Yên | `STB_MaterialDocInfo`, `STB_MaterialDocDetail` |
| `HY430` | HY_MaterialWarehouseInOutHist | Kho NVL | Quản lý xuất kho NVL cấp ra chuyền `VVHYC-*` / `VVHYMD-*` | `STB_MaterialDocInfo`, `STB_MaterialLotInfo` |
| `HY431` | RouteInspectionMeasureFullHist_HY | Sản xuất | Công nhân chuyền xác nhận nhận NVL thực tế và tra cứu lịch sử đo | `STB_RawMaterialInputHist` |
| `HY443` | HY_InspectionPQC | QC | Báo cáo chi tiết đo kiểm PQC công đoạn Hưng Yên | `STB_CommInspDocHistory`, `STB_CommInspMeasureHist` |
| `HY530` | HY_MaterialOqcInfoSampleManagement | Sản xuất | Chốt sản lượng công đoạn (Kiểm soát Gate time Aging `STB_DetailAgingHY`) | `STB_ProdRouteHist`, `STB_DetailAgingHY` |
| `HY540` | HY_AssyCardInfo | Sản xuất | Quét mã Lot NVL thô đầu vào công đoạn Hưng Yên (Assy Card) | `STB_RawMaterialInputHist` |
| `HY541` | HY_ProdInspectionHist | Sản xuất | Báo cáo tiêu hao nguyên vật liệu thực tế công đoạn Hưng Yên | `STB_ProductionOrderBom` |
| `HY620` | HY_MaterialReturnAndPrintLabel | QC | Tạo Lot kiểm tra OQC xuất xưởng, trả hàng và in tem Hưng Yên | `STB_CommInspDocHistory`, `STB_ModelBasicInfo` |
| `HY740` | HY_SplitLot | Sản xuất | Tách Lot sản xuất và báo cáo tổng hợp sản lượng & phế lỗi Hưng Yên | `STB_SetInfo`, `STB_ProdRouteHist` |
| `HYFG01` | Finished Goods WH HY | Kho TP | Nhập kho thành phẩm `FGT_HY_WH` và quản lý phiếu xuất kho giao hàng Hưng Yên | `STB_VN_FINISHGOODS_HY` |

---

## 3. 📦 Phân Hệ Đóng Gói VinaEnesol (`D000` Menu)

### 3.1 Cấu trúc màn hình Enesol
* **`D051` (`VNE_CustomerPartNoInfo`):** Thiết lập ánh xạ mã sản phẩm nội bộ Vinatech sang mã của khách hàng (`STB_MaterialCodeByCustomer`).
* **`D100` (`VNE_BoxLabelPrint` / `VNE_OutBoxLabelPrint`):** In nhãn hộp nhỏ (Inner Box - `LabelClassCode = '1'`) và nhãn hộp lớn (Outer Box - `LabelClassCode = '2'`).
* **`D110` (`VNE_BoxLabelPrintHist`):** Lịch sử in tem hộp Enesol (`STB_VINAEnesolBoxLabelPrintHist`).
* **`VNE_VINAEnesolBoxMatchingHist`:** Màn hình và bảng trung gian quản lý khớp/gộp các hộp nhỏ (Inner) vào hộp lớn (Outer) (`STB_VINAEnesolBoxMatchingHist`).

### 3.2 Thuật toán sinh mã LotNo & Barcode tự động Enesol
SP `usp_VINAEnesolBoxLabelPrint_iud` tự động sinh mã LotNo khi in tem nhãn:
$$\text{LotNo} = \text{Năm (1 chữ số cuối)} + \text{Ký tự Tháng (A-M, bỏ 'I')} + \text{Tuần sản xuất} + \text{LastLotNo}$$

* **Bảng Mã Hóa Tháng:**
  - Tháng 1-8: `A` $\rightarrow$ `H` (ASCII = Tháng + 64).
  - Tháng 9-12: `J` $\rightarrow$ `M` (ASCII = Tháng + 65, *bỏ qua ký tự `I` để tránh nhầm với số `1`*).

* **Cấu trúc Barcode Enesol:**
  $$\text{Barcode} = \text{LabelClassCode (1/2)} + \text{YYMMDD} + \text{MaterialCode} + \text{SerialNo (3 chữ số)}$$
  *Ví dụ:* `125042330VHV330ME12XXVC01001` (Inner Box (1) - Ngày 23/04/2025 - Mã sản phẩm - Serial `001`).

### 3.3 Quy trình Khớp Box (Box Matching)
Khi in tem hộp lớn (`LabelClassCode = '2'`), SP `usp_VINAEnesolBoxLabelPrint_iud` nhận chuỗi `SmallBoxList` (chứa các ID hộp nhỏ ngăn cách bằng dấu phẩy) và tự động insert vào bảng matching:
```sql
IF @SmallBoxList <> '' BEGIN
    INSERT INTO STB_VINAEnesolBoxMatchingHist (LargeBoxLabelPrintHistNo, SmallBoxLabelPrintHistNo, CreateDateTime, CreateUserID)
        SELECT @VINAEnesolBoxLabelPrintHistNo, value, GETDATE(), 'eai'
        FROM dbo.fn_split_string(@SmallBoxList, ',')
END
```

---

## 4. 🗄️ Cấu Trúc Bảng DB Chi Tiết Hưng Yên & Enesol

### 4.1 `STB_CustomerInfoEnesol` — Danh mục khách hàng Enesol
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `CustomerCode` | `varchar(20)` | Mã khách hàng (PK) |
| `CustomerName` | `nvarchar(100)` | Tên khách hàng |
| `CreateDateTime` | `datetime` | Thời gian tạo |

### 4.2 `STB_MaterialCodeByCustomer` — Ánh xạ mã Vendor P/N
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `ID` | `int` | ID tự tăng (PK) |
| `CustomerCode` | `varchar(20)` | FK -> `STB_CustomerInfoEnesol` |
| `MaterialCodeCustomer` | `varchar(50)` | Mã Vendor P/N phía khách hàng |
| `MaterialCode` | `varchar(50)` | Mã vật tư nội bộ MES |
| `ShortMaterialCode` | `varchar(50)` | Mã vật tư rút gọn |

### 4.3 `STB_VINAEnesolBoxLabelPrintHist` — Lịch sử in tem Box Enesol
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `VINAEnesolBoxLabelPrintHistNo` | `varchar(20)` | Mã lịch sử in (PK sinh bằng `usp_DoCreateSerial`) |
| `MaterialCode` | `varchar(20)` | Mã sản phẩm nội bộ |
| `ProdDate` | `date` | Ngày sản xuất |
| `ProdWeek` | `varchar(50)` | Tuần sản xuất |
| `PackingQty` | `int` | Số lượng đóng gói trong box |
| `LabelClassCode` | `varchar(20)` | Phân loại nhãn (1: Inner Box, 2: Outer Box) |
| `ModelSpec` | `varchar(50)` | Quy cách sản phẩm (ví dụ: `30V 330 Ø10.0*12.6L`) |
| `SerialNo` | `varchar(3)` | Số serial tự tăng trong ngày |
| `Barcode` | `varchar(50)` | Mã vạch in trên tem |

### 4.4 `STB_VN_FINISHGOODS_HY` — Kho thành phẩm Hưng Yên
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `ID` | `int` | ID tự tăng (PK) |
| `Barcode` | `varchar(50)` | Barcode thùng/box thành phẩm |
| `MaterialCode` | `varchar(50)` | Mã vật tư |
| `Quantity` | `numeric(13)` | Số lượng tồn kho |
| `LocationCode` | `varchar(50)` | Vị trí ô kệ kho `FGT_HY_WH` |
| `CreateDateTime` | `datetime` | Thời gian nhập kho |

---

## 5. 🔍 SQL Queries Tra Cứu Chuẩn Cho Nhà Máy Hưng Yên

```sql
-- 1. Tra cứu tồn kho NVL real-time tại kho Hưng Yên (ROH_HY_WH)
SELECT MaterialCode, LotNo, CurrentQty, LocationCode, MaterialWarehouseCode
FROM STB_MaterialLotInfo WITH(NOLOCK)
WHERE MaterialWarehouseCode = 'ROH_HY_WH' AND CurrentQty > 0
ORDER BY MaterialCode, CreateDateTime DESC;

-- 2. Kiểm tra danh sách Chuyền sản xuất Hưng Yên (VVT_F5)
SELECT LineCode, LineName, WorkCenterCode, IsUsed
FROM STB_LineInfo WITH(NOLOCK)
WHERE WorkCenterCode = 'VVT_F5'
ORDER BY LineCode;

-- 3. Tra cứu lịch sử gộp Box Enesol (Hộp Nhỏ -> Hộp Lớn)
SELECT Large.Barcode AS OuterBarcode, Small.Barcode AS InnerBarcode, Small.PackingQty, M.CreateDateTime
FROM STB_VINAEnesolBoxMatchingHist M WITH(NOLOCK)
JOIN STB_VINAEnesolBoxLabelPrintHist Large ON M.LargeBoxLabelPrintHistNo = Large.VINAEnesolBoxLabelPrintHistNo
JOIN STB_VINAEnesolBoxLabelPrintHist Small ON M.SmallBoxLabelPrintHistNo = Small.VINAEnesolBoxLabelPrintHistNo
WHERE Large.Barcode = 'BARCODE_OUTER_BOX';
```
