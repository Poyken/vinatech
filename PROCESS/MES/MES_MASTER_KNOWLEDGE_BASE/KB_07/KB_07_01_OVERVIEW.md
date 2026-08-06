<!--
AI-READY METADATA
Purpose: Master Architecture & Operating Guide for Hưng Yên Factory (VVT_F5) & VinaEnesol Ecosystem
Scope: Hung Yen VVT_F5 Architecture, 17 HY Screens, VinaEnesol Box Matching & Master Data
Single Source of Truth: KB_07_01_OVERVIEW.md (Hung Yen Architecture & Master Data)
Target Screens: HY103, HY141, HY143, HY151, HY220, HY311, HY312, HY330, HY430, HY431, HY443, HY530, HY540, HY541, HY620, HY740, HYFG01, D000, D051, D100, D110
Target Tables: STB_CustomerInfoEnesol, STB_MaterialCodeByCustomer, STB_VINAEnesolBoxLabelPrintHist, STB_VINAEnesolBoxMatchingHist, STB_DetailAgingHY, STB_LineInfo
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)
  - [KB_07_02_DEPLOY_HY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md)
  - [KB_07_03_SCREEN_BUGS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md)
-->

# KB_07 — VinaEnesol & Hưng Yên Factory Master Knowledge Base

> **Mã nhà máy (WorkCenterCode):** `VVT_F5` (Hưng Yên Factory)  
> **Màn hình chính:** `D000`, `D051`, `D100`, `D110`, `HY103` $\rightarrow$ `HYFG01` (17 màn hình tùy biến Hưng Yên)  
> **🔑 Keywords:** Hưng Yên, VinaEnesol, VVT_F5, D-series, HY-series, Box Matching, Inner Box, Outer Box, Enesol Vendor P/N  
> ← [Về Master Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)

---

## 1. 🏭 Tổng Quan Kiến Trúc Nhà Máy Hưng Yên (`VVT_F5`)

Hệ thống Vinatech MES điều hành toàn bộ quy trình sản xuất và kho bãi tại nhà máy **Hưng Yên (WorkCenterCode: `VVT_F5`)** thông qua 2 khối chức năng cốt lõi:

1. **Vận hành sản xuất & Kho tiêu chuẩn Hưng Yên (`HY00000`):**
   - **Mã Line sản xuất:** `VVHYC-01` $\rightarrow$ `VVHYC-06` (Chuyền Cell Tụ), `VVHYMD-01` $\rightarrow$ `VVHYMD-04` (Chuyền Module Tụ).
   - **Mã Kho vật lý:** `ROH_HY_WH` (Kho Nguyên vật liệu Hưng Yên), `FG_HY_WH` (Kho Thành phẩm Hưng Yên), `HOLDING_HY` (Kho Hold kiểm định).
   - **Hệ thống 17 Màn hình tùy biến (`HY` Prefix):** Được phân quyền tối ưu cho công nhân và quản lý nhà máy Hưng Yên.

2. **Phân hệ Đóng gói & Quản lý Khách hàng VinaEnesol (`D000` Menu):**
   - Quản lý mã sản phẩm phía khách hàng (Vendor P/N), in tem hộp nhỏ (Inner Box - `LabelClassCode = '1'`), tem hộp lớn (Outer Box - `LabelClassCode = '2'`), và quản lý khớp/gộp box (Box Matching).

---

## 2. 📱 Bảng Tra Cứu 17 Màn Hình Chuyên Biệt Nhà Máy Hưng Yên (`HY` Series)

| Screen ID | Tên Màn Hình | Phân Hệ | Chức Năng Chính & SP Liên Quan |
| :--- | :--- | :--- | :--- |
| `HY103` | Material Stock HY | Kho NVL | Quản lý tồn kho real-time kho `ROH_HY_WH` |
| `HY141` | IQC Inspection Item HY | Chất lượng | Thiết lập hạng mục đo kiểm IQC nguyên vật liệu Hưng Yên |
| `HY143` | PQC Inline Check HY | Chất lượng | Kiểm tra PQC trên chuyền sản xuất Hưng Yên |
| `HY151` | OQC Model Master HY | Chất lượng | Khai báo loại OQC và chỉ tiêu kiểm tra xuất xưởng |
| `HY220` | Process Setup HY | Master Data | Khai báo danh mục công đoạn nhà máy Hưng Yên |
| `HY311` | PO Electrode HY | Sản xuất | Lập lệnh sản xuất PO cho công đoạn Điện cực Hưng Yên (`PO_Electrode_HY`) |
| `HY312` | PO Detail HY | Sản xuất | Tra cứu thông tin chi tiết lệnh sản xuất PO Hưng Yên |
| `HY330` | Material Dispatch HY | Kho NVL | Quản lý yêu cầu và cấp phát NVL ra chuyền sản xuất |
| `HY430` | Material Issue HY | Kho NVL | Xuất kho NVL cấp ra chuyền `VVHYC-*` / `VVHYMD-*` |
| `HY431` | Material Receive Confirm | Sản xuất | Công nhân chuyền xác nhận nhận NVL thực tế |
| `HY443` | PQC Inline Report HY | Chất lượng | Báo cáo chi tiết đo kiểm PQC công đoạn |
| `HY530` | Route Process Input HY | Sản xuất | Chốt sản lượng công đoạn (Kiểm soát Gate time Aging `STB_DetailAgingHY`) |
| `HY540` | Process Material Scan | Sản xuất | Quét mã Lot NVL thô đầu vào công đoạn (Assy Card) |
| `HY541` | Material Consumption HY | Sản xuất | Báo cáo tiêu hao nguyên vật liệu thực tế |
| `HY620` | OQC Inspection HY | Chất lượng | Tạo Lot kiểm tra OQC xuất xưởng và ghi nhận kết quả Pass/Fail |
| `HY740` | Production Summary HY | Báo cáo | Báo cáo tổng hợp sản lượng & tỷ lệ phế lỗi Hưng Yên |
| `HYFG01` | Finished Goods WH HY | Kho TP | Nhập kho thành phẩm `FG_HY_WH` và quản lý phiếu xuất kho giao hàng |

---

## 3. 📦 Phân Hệ Đóng Gói VinaEnesol (`D000` Menu)

### 3.1 Cấu trúc màn hình Enesol
* **`D051` (`VNE_CustomerPartNoInfo`):** Ánh xạ mã sản phẩm nội bộ Vinatech sang mã của khách hàng (`STB_MaterialCodeByCustomer`).
* **`D100` (`VNE_BoxLabelPrint` / `VNE_OutBoxLabelPrint`):** Màn hình in tem hộp nhỏ (Inner Box) và hộp lớn (Outer Box).
* **`D110` (`VNE_BoxLabelPrintHist`):** Lịch sử in tem hộp Enesol (`STB_VINAEnesolBoxLabelPrintHist`).
* **`VNE_VINAEnesolBoxMatchingHist`:** Quản lý gộp Hộp Nhỏ $\rightarrow$ Hộp Lớn (`STB_VINAEnesolBoxMatchingHist`).

### 3.2 Thuật toán sinh mã LotNo & Barcode tự động
SP `usp_VINAEnesolBoxLabelPrint_iud` tự động sinh mã LotNo khi in tem:
$$\text{LotNo} = \text{Năm (1 chữ số cuối)} + \text{Ký tự Tháng (A-M, bỏ 'I')} + \text{Tuần sản xuất} + \text{LastLotNo}$$

* **Bảng Mã Hóa Tháng:**
  - Tháng 1-8: `A` $\rightarrow$ `H`
  - Tháng 9-12: `J` $\rightarrow$ `M` *(Bỏ qua ký tự `I` để tránh nhầm với số `1`)*.

* **Cấu trúc Barcode Enesol:**
  $$\text{Barcode} = \text{LabelClassCode (1/2)} + \text{YYMMDD} + \text{MaterialCode} + \text{SerialNo (3 chữ số)}$$

---

## 4. 🗄️ Cấu Trúc Bảng DB Phân Hệ Hưng Yên & Enesol

### 4.1 `STB_CustomerInfoEnesol` — Danh mục khách hàng Enesol
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `CustomerCode` | `varchar(20)` | Mã khách hàng (PK) |
| `CustomerName` | `nvarchar(100)` | Tên khách hàng |
| `CreateDateTime` | `datetime` | Thời gian tạo |

### 4.2 `STB_MaterialCodeByCustomer` — Mapping mã sản phẩm phía khách hàng
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `ID` | `int` | ID tự tăng (PK) |
| `CustomerCode` | `varchar(20)` | FK -> `STB_CustomerInfoEnesol` |
| `MaterialCodeCustomer` | `varchar(50)` | Mã Vendor P/N phía khách hàng |
| `MaterialCode` | `varchar(50)` | Mã vật tư nội bộ MES |
| `ShortMaterialCode` | `varchar(50)` | Mã vật tư rút gọn |

### 4.3 `STB_VINAEnesolBoxLabelPrintHist` — Lịch sử in tem Enesol
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `VINAEnesolBoxLabelPrintHistNo` | `varchar(20)` | Mã lịch sử in (PK sinh bằng `usp_DoCreateSerial`) |
| `MaterialCode` | `varchar(20)` | Mã sản phẩm nội bộ |
| `ProdDate` | `date` | Ngày sản xuất |
| `ProdWeek` | `varchar(50)` | Tuần sản xuất |
| `PackingQty` | `int` | Số lượng đóng gói trong box |
| `LabelClassCode` | `varchar(20)` | Loại tem (1: Inner Box, 2: Outer Box) |
| `Barcode` | `varchar(50)` | Mã vạch in trên tem |

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

-- 3. Tra cứu lịch sử khớp Box Enesol (Hộp Nhỏ -> Hộp Lớn)
SELECT Large.Barcode AS OuterBarcode, Small.Barcode AS InnerBarcode, Small.PackingQty, M.CreateDateTime
FROM STB_VINAEnesolBoxMatchingHist M WITH(NOLOCK)
JOIN STB_VINAEnesolBoxLabelPrintHist Large ON M.LargeBoxLabelPrintHistNo = Large.VINAEnesolBoxLabelPrintHistNo
JOIN STB_VINAEnesolBoxLabelPrintHist Small ON M.SmallBoxLabelPrintHistNo = Small.VINAEnesolBoxLabelPrintHistNo
WHERE Large.Barcode = 'BARCODE_OUTER_BOX';
```
