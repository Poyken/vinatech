# KB_25 — VinaEnesol & Hưng Yên Factory Specifics

> **Màn hình liên quan:** HungYenFactory (HY00000), VinaEnesol_Management_MENU (D000)
> **Verified against DB:** 2026-06-10
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Tổng Quan

Hệ thống MES Vinatech quản lý vận hành của nhà máy **Hưng Yên (WorkCenterCode: VVT_F5)** và các dòng sản phẩm đặc thù **VinaEnesol** thông qua 2 cơ chế:
1. **Môi trường vận hành Hưng Yên:** Sử dụng các màn hình tiêu chuẩn (B310, B450, B530...) lọc theo các Line sản xuất Hưng Yên (`VVHYC-*` và `VVHYMD-*`).
2. **Quy trình đóng gói & In tem VinaEnesol:** Sử dụng bộ màn hình chuyên biệt (Menu `D000`) để thiết lập mã sản phẩm theo khách hàng, in tem Inner/Outer Box và thực hiện gộp/khớp Box (Box Matching).

---

## 2. 🏗️ Cấu Trúc Menu & Màn Hình

### 2.1 HungYenFactory (`HY00000`)
Đây là khu vực Menu dành riêng cho việc phân nhóm vận hành tại nhà máy Hưng Yên. Các thư mục chính bao gồm:
*   **QC Hung Yên (`HY00001`):** Quản lý chất lượng.
*   **Production Hung Yên (`HY00002`):** Quản lý sản xuất.
*   **Material Warehouse HY (`HY00003`):** Quản lý kho nguyên vật liệu Hưng Yên.
*   **Electrode Hung Yên (`HY00004`):** Quản lý sản xuất điện cực Hưng Yên.
*   *Ghi chú:* Các thư mục này chủ yếu chứa các màn hình tiêu chuẩn của hệ thống được phân quyền cho nhân sự Hưng Yên, không tạo các màn hình tùy biến riêng ngoại trừ màn hình `PO_Electrode_HY` (`HY311`).

### 2.2 VinaEnesol Management (`D000`)
Bộ màn hình custom riêng phục vụ nghiệp vụ đóng gói và in ấn tem nhãn của VinaEnesol:
*   **VNE_CustomerPartNoInfo (`D051`):** Thiết lập thông tin mã vật tư của khách hàng tương ứng với mã nội bộ của Vinatech.
*   **VNE_BoxLabelPrint:** Màn hình in nhãn hộp nhỏ (Inner Box / Small Box - `LabelClassCode = '1'`).
*   **VNE_OutBoxLabelPrint:** Màn hình in nhãn hộp lớn (Outer Box / Large Box - `LabelClassCode = '2'`).
*   **VNE_BoxLabelPrintHist (`D110`):** Lịch sử in nhãn hộp.
*   **VNE_VINAEnesolBoxMatchingHist:** Quản lý lịch sử khớp/gộp các hộp nhỏ vào hộp lớn.

---

## 3. 🗄️ Cấu Trúc Bảng DB

### 3.1 `STB_CustomerInfoEnesol` — Danh mục khách hàng Enesol
Lưu trữ danh sách khách hàng thuộc phân hệ Enesol.

| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `CustomerCode` | `varchar(20)` | Mã khách hàng (PK) |
| `CustomerName` | `nvarchar(100)` | Tên khách hàng |
| `CreateDateTime` | `datetime` | Thời gian tạo |

### 3.2 `STB_MaterialCodeByCustomer` — Mapping mã sản phẩm
Ánh xạ mã sản phẩm nội bộ Vinatech sang mã của khách hàng.

| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `ID` | `int` | ID tự tăng (PK) |
| `CustomerCode` | `varchar(20)` | FK -> `STB_CustomerInfoEnesol` |
| `MaterialCodeCustomer` | `varchar(50)` | Mã sản phẩm phía khách hàng (Vendor P/N) |
| `MaterialCode` | `varchar(50)` | Mã vật tư nội bộ MES |
| `ShortMaterialCode` | `varchar(50)` | Mã vật tư rút gọn |

### 3.3 `STB_VINAEnesolBoxLabelPrintHist` — Lịch sử in tem Box Enesol
Lưu trữ toàn bộ thông tin nhãn hộp nhỏ và hộp lớn đã in.

| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `VINAEnesolBoxLabelPrintHistNo` | `varchar(20)` | Số lịch sử in (PK - Sinh tự động bằng `usp_DoCreateSerial`) |
| `MaterialCode` | `varchar(20)` | Mã sản phẩm nội bộ |
| `ProdDate` | `date` | Ngày sản xuất |
| `ProdWeek` | `varchar(50)` | Tuần sản xuất (FK -> `STB_BaseCode`) |
| `LastLotNo` | `varchar(50)` | Cấu hình Lot chẵn/lẻ (1: Lẻ, 2: Chẵn, 3: Không dùng) |
| `ProdMachineCode` | `varchar(50)` | Mã máy sản xuất (1-6) |
| `ProdLocationCode` | `varchar(50)` | Mã nơi sản xuất (A, B, C, D, E... trong đó `E` là Vietnam-HY) |
| `PackingQty` | `int` | Số lượng đóng gói trong box |
| `LabelQty` | `int` | Số lượng nhãn |
| `CustomerPartNo` | `varchar(50)` | Mã sản phẩm phía khách hàng |
| `LotNo` | `varchar(20)` | Lot number của box |
| `LabelClassCode` | `varchar(20)` | Phân loại nhãn (1: Inner Box, 2: Outer Box) |
| `ModelSpec` | `varchar(50)` | Quy cách sản phẩm (ví dụ: `30V 330 Ø10.0*12.6L`) |
| `SerialNo` | `varchar(3)` | Số serial tự tăng trong ngày |
| `Barcode` | `varchar(50)` | Mã vạch in trên tem nhãn |

### 3.4 `STB_VINAEnesolBoxMatchingHist` — Mapping Hộp Nhỏ ↔ Hộp Lớn
Bảng trung gian lưu vết việc đóng gói nhiều hộp nhỏ (Inner) vào một hộp lớn (Outer).

| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `LargeBoxLabelPrintHistNo` | `varchar(20)` | FK -> `STB_VINAEnesolBoxLabelPrintHist` (Outer Box) |
| `SmallBoxLabelPrintHistNo` | `varchar(20)` | FK -> `STB_VINAEnesolBoxLabelPrintHist` (Inner Box) |
| `CreateDateTime` | `datetime` | Thời gian ghép |
| `CreateUserID` | `varchar(20)` | User thực hiện (thường là `eai` nếu đồng bộ tự động) |

---

## 4. ⚙️ Logic Nghiệp Vụ & Stored Procedures

### 4.1 Quy tắc sinh LotNo tự động (`usp_VINAEnesolBoxLabelPrint_iud`)
Nếu khi in tem nhãn, người dùng không nhập thủ công `@LotNo`, hệ thống sẽ tự sinh theo công thức:
$$\text{LotNo} = \text{Năm} + \text{Tháng (Ký tự)} + \text{Tuần sản xuất} + \text{LastLotNo}$$
*   **Năm:** Lấy số cuối của năm sản xuất (ví dụ: `2025` -> `5`).
*   **Tháng (Ký tự):** Tháng được map thành ký tự từ `A` đến `M` (bỏ qua ký tự `I` để tránh nhầm lẫn với số `1`):
    *   *Jan-Aug (Tháng 1-8):* Map sang `A` đến `H` (ASCII = Tháng + 64).
    *   *Sep-Dec (Tháng 9-12):* Map sang `J` đến `M` (ASCII = Tháng + 65).
*   **Tuần sản xuất (`ProdWeek`):** `1` đến `5`.
*   **LastLotNo:** Nếu giá trị khác `3`, sẽ nối thêm mã `LastLotNo`.

### 4.2 Sinh Barcode tem nhãn
Barcode được sinh tự động theo định dạng:
$$\text{Barcode} = \text{LabelClassCode} + \text{Ngày dạng YYMMDD} + \text{MaterialCode} + \text{SerialNo (3 chữ số)}$$
*   *Ví dụ:* `125042330VHV330ME12XXVC01001` (Inner Box (1) - Ngày 23/04/2025 - Mã sản phẩm - Serial `001`).

### 4.3 Khớp Box (Box Matching)
Khi thực hiện in tem hộp lớn (`LabelClassCode = 2`), giao diện cho phép truyền lên danh sách các ID hộp nhỏ (`SmallBoxList` ngăn cách bằng dấu phẩy).
SP `usp_VINAEnesolBoxLabelPrint_iud` sẽ gọi hàm cắt chuỗi `dbo.fn_split_string` để insert đồng loạt vào bảng matching:
```sql
IF @SmallBoxList <> '' BEGIN
    INSERT INTO STB_VINAEnesolBoxMatchingHist 
        SELECT @VINAEnesolBoxLabelPrintHistNo, value, GETDATE(), 'eai'
        FROM dbo.fn_split_string(@SmallBoxList, ',')
END
```

---

## 5. 🔍 Các Câu SQL Tra Cứu Nhanh

### 5.1 Tra cứu danh sách khách hàng và mã mapping tương ứng
```sql
SELECT T1.CustomerCode, T1.CustomerName, T2.MaterialCode AS VendorPN, T2.MaterialCode, T2.ShortMaterialCode
FROM STB_CustomerInfoEnesol T1
LEFT JOIN STB_MaterialCodeByCustomer T2 ON T1.CustomerCode = T2.CustomerCode
WHERE T1.CustomerCode LIKE '%1125%'
```

### 5.2 Kiểm tra lịch sử in ấn hộp lớn và danh sách hộp nhỏ tương ứng
```sql
-- Lấy thông tin Outer Box (Hộp lớn)
SELECT Barcode, MaterialCode, ProdDate, PackingQty, LotNo, CreateDateTime
FROM STB_VINAEnesolBoxLabelPrintHist
WHERE LabelClassCode = '2' AND Barcode = 'BARCODE_HỘP_LỚN';

-- Lấy danh sách Inner Boxes (Hộp nhỏ) được map vào Hộp lớn trên
SELECT BH.Barcode, BH.MaterialCode, BH.PackingQty, BH.LotNo, M.CreateDateTime
FROM STB_VINAEnesolBoxMatchingHist M
INNER JOIN STB_VINAEnesolBoxLabelPrintHist BH ON M.SmallBoxLabelPrintHistNo = BH.VINAEnesolBoxLabelPrintHistNo
WHERE M.LargeBoxLabelPrintHistNo = (
    SELECT VINAEnesolBoxLabelPrintHistNo 
    FROM STB_VINAEnesolBoxLabelPrintHist 
    WHERE Barcode = 'BARCODE_HỘP_LỚN'
);
```

### 5.3 Danh sách các Line sản xuất của nhà máy Hưng Yên
```sql
SELECT LineCode, LineName, WorkCenterCode, IsUsed
FROM STB_LineInfo
WHERE WorkCenterCode = 'VVT_F5' -- Nhà máy Hưng Yên
ORDER BY LineCode;
```

---

*Cập nhật: 2026-06-10 — Khám phá cấu trúc thực tế của phân hệ VinaEnesol và nhà máy Hưng Yên trong DB.*
