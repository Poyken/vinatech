# KB_25 — VinaEnesol & Hưng Yên Factory Specifics

> **Màn hình:** D000, D051, D100, D110, HY screens
> **🔑 Keywords:** Enesol, Hưng Yên, VVT_F4, pin, battery, D-series, box matching, inner box, outer box, 93 SPs
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
| `LotNo` | `varchar(10)` | Lot number của box |
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

---

## 6. Hướng Dẫn Cấu Hình & Triển Khai Hệ Thống MES Nhà Máy Hưng Yên

Dưới đây là tài liệu tổng hợp đầy đủ hướng dẫn cấu hình thiết lập, luồng quy trình nghiệp vụ và tiến độ triển khai hệ thống MES tại nhà máy Hưng Yên (WorkCenterCode: `VVT_F5`), được quản lý bởi Project Leader Mr. Kevin và triển khai thực tế bởi Mr. Triều:

### 6.1 Sơ Đồ Quy Trình Nghiệp Vụ Chính (Các Phân Hệ)

#### 1. Quy trình Kho nguyên vật liệu (Raw Material Warehouse Process)
```
Hàng về cty → Đưa vào kho → Kho kiểm tra thực tế 
  → Nhập lên MES (F312/F330) 
  → Bộ phận IQC kiểm tra chất lượng (C220) → Đánh giá PASS
  → Xuất kho NVL cấp ra CellLine sản xuất (F430) 
  → Xác nhận nhập kho thực tế chuyền sản xuất
```

#### 2. Quy trình Sản xuất (Production Process)
```
Tạo kế hoạch PO tháng (B310) → Đăng ký BOM cho sản phẩm (A310)
  → Tạo kế hoạch sản xuất ngày (B450) & Bấm "Tạo Lot" để chia Lot No
  → In tem nhãn Barcode Lot (B460/A460)
  → Nhập NVL thô đầu vào cho công đoạn (K109 / B530 Popup)
  → Báo cáo sản lượng & chốt hoàn thành công đoạn (B530)
  → Kiểm tra chất lượng QC Inline (PQC Check C443 / OQC Check C530)
  → Đóng gói gộp box (B523) & Xác nhận số lượng chốt PackingQty
  → Nhập kho thành phẩm và xuất kho giao hàng
```

#### 3. Quy trình Kho thành phẩm (Finished Goods Warehouse Process)
```
Công nhân đóng gói (B523) → Nhập dữ liệu lên MES → Nhập kho thành phẩm
  → Nhập hoá đơn (Invoice) đầu vào → Cấu hình vị trí (Location) lưu trữ
  → Lập kế hoạch giao hàng (Shipping plan) → Xuất kho thành phẩm trên MES
  → Xuất hoá đơn đầu ra → Xác nhận lại số lượng → Kẹp chì kiểm định (Seal)
```

#### 4. Quy trình kiểm tra chất lượng đầu vào (IQC Process)
```
Hàng về nhà máy → Đưa vào kho → Đăng ký số mẫu kiểm tra phá hủy
  → Đăng ký hạng mục kiểm tra theo sản phẩm (C121/C122)
  → Thực hiện đo đạc, kiểm tra IQC (C220) → Xác nhận PASS hoặc REJECT
```

#### 5. Quy trình kiểm tra chất lượng công đoạn (PQC Process)
```
Tạo PO → Đăng ký BOM → Kế hoạch ngày → In tem → Tạo Lot
  → Nhập sản lượng & quét NVL thô → Thiết lập hạng mục đo kiểm PQC (C141/C143)
  → Thực hiện đo kiểm PQC công đoạn (C443)
```

#### 6. Quy trình kiểm tra xuất xưởng (OQC Process)
```
Tạo PO → Đăng ký BOM → Kế hoạch ngày → In tem → Tạo Lot
  → Nhập sản lượng & quét NVL thô → Thiết lập hạng mục OQC theo Model (C151)
  → Tạo Lot kiểm tra OQC (C512) → Đo kiểm OQC mẫu (C530)
```

---

### 6.2 Hướng Dẫn Cấu Hình Hệ Thống Master Data & Giao Diện

#### 1. Đăng nhập & Điều hướng
*   **Đăng nhập:** Sử dụng tài khoản worker Hưng Yên được cấp riêng để đăng nhập vào hệ thống MES của công ty, chọn ngôn ngữ làm việc và tích chọn *Remember* để lưu lại phiên đăng nhập sau.
*   **Tìm kiếm màn hình:** Ấn vào icon kính lúp trên góc trái giao diện chính, điền mã Screen ID (ví dụ: B230, A230...) vào ô tìm kiếm rồi ấn OK để mở nhanh màn hình tương ứng.

#### 2. Màn hình A230 (Thông tin vật liệu Master)
Thiết lập toàn bộ thông tin cơ bản cho nguyên vật liệu, bán thành phẩm và thành phẩm.
*   **Cột "Mã loại NVL" (Material Type):** Chọn đúng loại để tránh lỗi hiển thị nhầm lẫn giữa Cell và Module ngoài sản xuất:
    *   `EROH`: Mã vật tư điện cực (cấp cho công đoạn Mixing).
    *   `HALB`: Bán thành phẩm điện cực (Coating/Rollpress).
    *   `FERT`: Thành phẩm Cell (Bắc Giang/Bắc Ninh).
    *   `MODULE`: Thành phẩm Module (sử dụng bản mạch ráp PCB).
    *   `ROH`: Tất cả nguyên vật liệu thô mua ngoài lưu kho.
    *   `HIBE`: Nguyên phụ liệu tiêu hao sản xuất.
*   **Cột "Đang đóng" (Deactivated):** Nếu tích chọn, mã vật tư này sẽ bị ẩn hoàn toàn trên mọi màn hình chức năng của hệ thống.
*   **Cột "Đang mua" / "Đang đặt hàng" (Buying/Ordering):** Tích chọn đối với hàng hoá mua từ đối tác bên ngoài (không tự sản xuất).
*   **Cột "Sản xuất nội bộ" / "Kế hoạch sản xuất" (Internal Production):** Tích chọn đối với các sản phẩm do chính nhà máy Hưng Yên tự làm ra.
*   **Cột "IsUseFlush" / "IsUseBackFlush":** Nếu tích chọn, hệ thống sẽ tự động trừ lượng tồn kho NVL tương ứng khi chốt sản lượng sản xuất.
*   **Cột "Nguồn NVL" & "Độ dày NVL":** Dùng cho điện cực. Phải khai báo đầy đủ 2 trường này thì ở màn hình tạo kế hoạch ngày điện cực **B442** mới hiển thị được dữ liệu.
*   **Cột "BasicRoutingCode":** Chọn quy trình định tuyến sản xuất mặc định của mã hàng.
*   **Cột "MMEXtIN1" (Shelf Life):** Số tháng hạn dùng trước khi hết hạn sử dụng.

#### 3. Màn hình A410 (Thông tin Model)
*   Các thông số kích thước và tính chất tự động đồng bộ từ màn hình A230 sang (chỉ áp dụng cho hàng Cell và Module).
*   **Cột "Đường kính" (Diameter):** Quyết định chủng loại và kích thước bao của con hàng.
*   **⚠️ Lưu ý lỗi QC không tìm thấy Lot:** Nếu bên QC không tìm thấy Lot hàng để tạo phiếu kiểm tra trên giao diện, IT cần vào màn hình A410 này kiểm tra xem model tương ứng đã được thiết lập loại OQC (OqcType, InspectionType...) hay chưa.

#### 4. Màn hình A310 (Thông tin BOM)
*   Khai báo định mức cấu thành sản phẩm (BOM) bao gồm Điện cực, Cell và Module.
*   **BOM Version:** Quy chuẩn version từ `51` đến `999` là của Việt Nam (phổ biến đang sử dụng là Bom `99` hoặc `99.100`), còn version `1000` là dữ liệu đồng bộ tự động từ hệ thống ERP.
*   Chú ý khai báo chuẩn `ChildMaterialCode` và `ChildBomversion`. Hàng Cell chạy từ V-22 (công đoạn cuốn). Hàng Module liên kết các công đoạn MV-01, MV-03, MV-04, MV-05. Riêng dòng sản phẩm khách hàng JIANG-HAI chạy logic định mức đặc biệt.

#### 5. Cấu hình Line & Công đoạn (B210, B220, B230, B240)
*   **B210 (Thông tin Line):** Thêm, sửa, xóa thông tin line sản xuất ngoài nhà máy. Chú ý cấu hình trường **"Mã kho Nguyên liệu"** để liên kết đúng kho cấp liệu cho chuyền.
*   **B220 (Thông tin công đoạn):** Khai báo danh mục các công đoạn sản xuất.
*   **B230 (Thông tin cấu trúc công đoạn trên Line):** Chọn mã Line ở cột bên trái. Ở bảng bên phải hiển thị danh sách công đoạn, OP tích chọn vào cột **"Sử dụng"** và **"Sử dụng trong Line"** đối với những công đoạn có trên Line đó. Cột **"Thông số Route"** dùng để đánh số thứ tự sản xuất (Routing Index).
*   **B240 (Thông tin Routing):** Thiết lập cấu hình quy trình định tuyến chi tiết của sản phẩm. Khi cấu hình bắt buộc phải khai báo rõ công đoạn nào là **Input** (Đầu vào nhận Lot), công đoạn nào là **Output** (Đầu ra thành phẩm), và đánh số chỉ mục Index tuần tự.

#### 6. Thiết bị & Nhân viên (B250, B260, B270, Z210)
*   **B250 (Thông tin thiết bị):** Khai báo danh mục toàn bộ máy móc, thiết bị của nhà máy Hưng Yên.
*   **B270 (Thông tin thiết bị sản xuất):** Mapping thiết bị cụ thể vào từng Line và công đoạn sản xuất tương ứng.
*   **B260 / B220 (Nhân viên sản xuất):** Khai báo danh sách và mã số thẻ của công nhân.
*   **Z210 (Phân quyền tài khoản):** Cấp quyền truy cập menu chức năng và phân quyền thao tác cho từng nhóm tài khoản worker Hưng Yên.

#### 7. F110 (Thuộc tính quản lý tồn kho)
*   Quản lý thuộc tính tồn kho của NVL (EROH, FERT, HALB, ROH...).
*   **⚠️ Lưu ý lỗi gộp Box:** Trong F110 có cột cờ **`IsLotUse`**. Thủ kho bắt buộc phải tích chọn cờ này cho mã vật tư thì ngoài sản xuất công nhân mới có thể thực hiện quét gộp Box thành công tại màn hình **B523**.

#### 8. A130 (Kho/Location & Đối tác)
*   **Tab Kho/Location:** Thêm, sửa, xóa thông tin kho vật lý và tọa độ Location trong kho tại Hưng Yên.
*   **Tab Đối tác giao dịch:** Quản lý danh mục nhà cung cấp nguyên vật liệu. Liên kết với **F140/F130** để chỉ định nhà cung cấp cấp phát những mã NVL nào.

---

### 6.3 Hướng Dẫn Vận Hành Các Phân Hệ IQC & Sản Xuất

#### 1. Nghiệp vụ kiểm tra chất lượng đầu vào (IQC)
*   **C121 (Nhóm hạng mục kiểm tra):** Tạo nhóm kiểm tra IQC. Nhấn nút `(+)` để thêm mới, điền các trường bắt buộc (tiêu đề bôi đậm, nếu bỏ trống hệ thống sẽ báo lỗi) và nhấn Lưu.
*   **C122 (Thiết lập hạng mục cho từng NVL):** Tìm mã NVL cần gán -> Nhấn nút tìm kiếm -> Ấn nút *"Chọn trong nhóm / Hạng mục kiểm tra"* -> Tích chọn các hạng mục cần đo kiểm -> Nhấn OK -> Nhấn Lưu để hoàn thành.
*   **C220 (Kiểm tra IQC thực tế):** Khi có lô hàng NVL về kho, hệ thống tự động gọi các hạng mục đã cấu hình ở C122 lên C220 để QC nhập kết quả đo kiểm. Bắt buộc phải đánh giá tất cả hạng mục là OK/NG và cho kết luận cuối cùng (Pass/Fail) thì phiếu nhập kho mới được duyệt hoàn thành.
*   **C132 (Hiện trạng lỗi):** Dùng để thiết lập cấu hình danh mục mã lỗi phục vụ cho việc nhập báo phế công đoạn của QC hoặc sản xuất.

#### 2. Nghiệp vụ sản xuất (Production Module)
*   **Tạo PO (B310):** Tạo lệnh sản xuất PO tháng. Tab Routing trên màn hình này cho phép thêm, sửa, xóa linh động các công đoạn tùy theo yêu cầu của đơn hàng.
*   **Tạo kế hoạch ngày & Chia Lot (B450):**
    *   Tạo kế hoạch ngày theo model và PO.
    *   **Logic chia Lot tự động:** Khi bấm tạo Lot, hệ thống yêu cầu nhập quy mô Lot Size tiêu chuẩn (Lot size phụ thuộc vào kế hoạch sản xuất và quy cách của từng Size sản phẩm). Ví dụ: Kế hoạch ngày yêu cầu sản xuất Model 0820 là 9000 sản phẩm, OP nhập Lot size tiêu chuẩn là 2000 -> Hệ thống tự động chia đều và tạo ra 4 Lot chẵn có số lượng 2000ea và 1 Lot lẻ có số lượng 1000ea.
*   **Chốt sản lượng công đoạn (B530):** OP thực hiện chốt số lượng hoàn thành của Lot tại từng công đoạn.
*   **Sấy hàng (Dry Oven) tại B530:**
    *   Tại màn hình B530, OP click vào nút **"Sấy hàng"** để hiển thị popup sấy.
    *   Chọn mã máy sấy thích hợp sấy Lot hàng -> Nhấn nút Tìm kiếm -> Nhấn nút Lưu lại để khóa dữ liệu sấy (Lưu ý: Đã nhấn Lưu thì không thể thay đổi thông tin lò sấy được nữa).
    *   **⚠️ Lỗi không in được Barcode sau sấy:** Trong popup sấy hàng có 4 cột thuộc tính quan trọng được bôi đậm có màu khác biệt (liên quan đến thông số nhiệt độ, thời gian sấy). OP bắt buộc phải nhập đầy đủ giá trị vào 4 cột này thì hệ thống mới cho phép in Barcode. Nếu cố tình in khi chưa nhập đủ, hệ thống sẽ chặn và báo lỗi Exception.
*   **Nhập NVL thô đầu vào (B530 Popup):**
    *   **Khung bên trái (Khung A):** Nhập các thông số kiểm tra chất lượng đo đạc thực tế sau khi sấy (liên quan ngoại quan, kích thước). Nhập xong nhấn Lưu.
    *   **Khung bên phải (Khung B):** Nhập/quét mã Lot NVL (mã ML...) sử dụng để sản xuất ra sản phẩm đó. Nhập xong nhấn Lưu. Lưu ý: Các mã Lot NVL thô này phải được thủ kho thực hiện xuất trên hệ thống (F430) ra chuyền trước thì công nhân mới có thể quét ghi nhận lên hệ thống được.
*   **Báo cáo lỗi (B782, B682):**
    *   **B782 (Tổng số lỗi theo LotNo):** Hệ thống phân tách rõ ràng lỗi do PQC phát hiện và lỗi do sản xuất làm hỏng. Phương pháp tính tiền phế thải (Scrap Cost) của 2 nhóm này hoàn toàn khác nhau.
    *   **B682 (Chi tiết lỗi con hàng):** Tra cứu nhanh mã lỗi chi tiết của từng barcode sản phẩm.
*   **Đóng gói gộp Box (B523):**
    *   Sau khi gộp các Lot nhỏ vào Box, OP cần chú ý 2 nút chức năng ở lưới dưới:
        1.  **Nút "In tem":** Chỉ dùng để in nhãn tạm dán ngoài vỏ hộp cho QC kiểm tra nội bộ tại xưởng sản xuất (kho thành phẩm có màn hình in tem nhãn giao hàng chuyên biệt riêng).
        2.  **Nút "Lưu PackingQty" (Bắt buộc):** Dùng để chốt số lượng đóng gói thực tế của Lot No đó. Đây là thao tác **BẮT BUỘC** phải thực hiện thì hệ thống mới kết xuất dữ liệu sản lượng lên báo cáo **B781**.
*   **B781 (Kiểm tra sản lượng ngày):** Thống kê sản lượng hoàn thành thực tế trong ngày, dữ liệu chỉ hiển thị khi OP đã bấm nút "Lưu PackingQty" tại B523.
*   **B598 (Báo phế NVL):** Dùng để công nhân trực tiếp khai báo lượng phế thải nguyên vật liệu hao hụt (tính bằng kg/g) phát sinh trực tiếp trên CellLine.

---

### 6.4 Bảng Theo Dõi Tiến Độ Triển Khai Hệ Thống (Configuration Checklist)

Dưới đây là bảng đối soát tiến độ triển khai cấu hình các phân hệ MES cho nhà máy Hưng Yên thực tế:

| Nhóm chức năng | Tên tác vụ cấu hình hệ thống | Nhân sự thực hiện | Tiến độ | Hiện trạng vận hành |
| :--- | :--- | :--- | :--- | :--- |
| **Cấu hình chung** | Thông tin cấu trúc công đoạn trên Line (**B230**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Thông tin công đoạn sản xuất (**B220**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Thông tin các Line sản xuất (**B210**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Thông tin quy trình định tuyến (**B240**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Phân quyền tài khoản người dùng (**Z210**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Khai báo kho và vị trí Location (**A130**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Khai báo thông tin nhân viên sản xuất (**B260**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Thiết lập tài khoản đăng nhập Worker Hưng Yên | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Thông tin thiết bị sản xuất trên line (**B270**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |
| | Thông tin thiết bị máy móc (**B250**) | Mr. Triều | **100%** | Đã cấu hình hoạt động |

---

## 7. 🛠️ Triển Khai & Cấu Hình 9 Màn Hình Mới Hưng Yên (VVT_F5)

Nhằm đảm bảo tính độc lập vận hành cho xưởng Hưng Yên (`VVT_F5`) mà không làm ảnh hưởng tới logic của các nhà máy Bắc Ninh, Bắc Giang, và Hà Nam, hệ thống thực hiện nhân bản khép kín **78 Stored Procedures** và **9 màn hình chức năng** tương ứng.

> VERIFIED 2026-06-18: 8/9 HY TCodes below (HY122, HY220, HY310, HY442, HY470, HY552, HY802, HY460) DO NOT EXIST in STB_ScreenInfo. Actual HY screens: HY141, HY143, HY151, HY311, HY312, HY330, HY430, HY431, HY443, HY530, HY540, HY541, HY620, HY740, HYFG01, HY103 (17 functional screens).

### 7.1 Danh Sách 9 Màn Hình Được Nhân Bản (HY TCodes)

| STT | ScreenName | TCode | Phân hệ | Màn hình gốc | SP Chính Liên Quan |
|---|---|---|---|---|---|
| 1 | `QcInspectionGroup_HY` | `HY121` | Quality Control (QC) | `C121` | `usp_QcInspectionGroup_HY_get`/`_iud` |
| 2 | `MaterialQcInspectionItemByMaterial_HY` | `HY122` | Quality Control (QC) | `C122` | `usp_MaterialQcInspectionItem_ByMaterial_HY_get`/`_iud` |
| 3 | `MaterialIqcInfoSampleManagement_HY` | `HY220` | Quality Control (QC) | `C220` | Bộ SP IQC đầu `_HY` (Detail, SampleResult...) |
| 4 | `ProductionOrderInfo_HY` | `HY310` | Production (PO) | `B310` | `usp_ProductionOrderInfo_HY_get`, `usp_DoFixProductionOrder_HY` |
| 5 | `ElectrodePlan_HY` | `HY442` | Electrode (Điện cực) | `B442` | `usp_DayProdPlan_HY_get`, `usp_SetInfo_HY_get` |
| 6 | `ElectrodePrcsCard_HY` | `HY470` | Electrode (Điện cực) | `B470` | `usp_ElectrodeStep_HY_get`/`_iud`, `_Oven_HY_get` |
| 7 | `ElectrodeMeasureResult_HY` | `HY552` | Electrode (Điện cực) | `B552` | Bộ SP kết quả công đoạn điện cực (Coating, Rollpress...) |
| 8 | `ElectrodeProdRouteHist_HY` | `HY802` | Electrode (Điện cực) | `B802` | `usp_Vietnam_ElectrodeProdRouteHist_HY_get` |
| 9 | `ElectrodeInspectionHistoryForBarcode_HY` | `HY460` | Electrode (Điện cực) | `C460` | `usp_GetElectrodeInspectionHistoryForBarcode_HY` |

### 7.2 Quy Tắc Đặt Tên & Logic Của SP Nhân Bản
*   **Quy tắc đặt tên:**
    *   Hàm lấy dữ liệu: `[Tên SP Gốc]_get` $\rightarrow$ `[Tên SP Gốc]_HY_get` (Ví dụ: `usp_QcInspectionGroup_HY_get`).
    *   Hàm ghi/sửa dữ liệu: `[Tên SP Gốc]_iud` $\rightarrow$ `[Tên SP Gốc]_HY_iud` (Ví dụ: `usp_QcInspectionGroup_HY_iud`).
    *   Các SP nghiệp vụ khác: Thêm hậu tố `_HY` (Ví dụ: `usp_GetMaterialGIForPO_HY`).
*   **Logic độc lập:** Các SP được tự động quét và sửa các lời gọi chéo nhau bên trong thân hàm. Nếu SP A gọi SP B, phiên bản SP A_HY sẽ tự động gọi sang SP B_HY để đảm bảo cô lập dữ liệu hoàn toàn.

### 7.3 Bẫy Mã Hóa Tiếng Hàn (Encoding Trap)
*   **Vấn đề:** Các Stored Procedure tiêu chuẩn chứa rất nhiều bình luận (comment) bằng tiếng Hàn và tiếng Việt có dấu, cũng như các biến logic có ký tự Hàn (Ví dụ: `@sumSampleQty공정`).
*   **Giải pháp:** Khi xuất bản hoặc ghi đè file SQL bằng PowerShell, bắt buộc phải dùng thuộc tính `-Encoding UTF8` (hoặc định dạng UTF-8 with BOM). Nếu ghi bằng mã ANSI/ASCII mặc định, các ký tự tiếng Hàn sẽ bị biến đổi thành dấu hỏi chấm (`??`), gây lỗi biên dịch nghiêm trọng trên SQL Server.

### 7.4 Tự Động Nhân Bản Layout Màn Hình (Server-Side Cloning)
*   **Vấn đề WAN:** File thiết kế màn hình (`XmlLayout` - nvarchar và `Layout` - varbinary) lưu trong bảng `STB_ScreenLayoutInfo` (DB `SmartFramework`) có dung lượng rất lớn. Việc tải các tệp nhị phân này về máy trạm local rồi đẩy ngược lên DB server qua đường truyền WAN quốc tế (đi Hàn Quốc) rất dễ bị nghẽn (hang/timeout).
*   **Giải pháp T-SQL:** Thực hiện sao chép và cập nhật trực tiếp trên server bằng câu lệnh T-SQL để tận dụng bộ nhớ trong của DB Server:
    1.  Thực hiện `INSERT INTO ... SELECT` để clone nguyên trạng bản ghi của màn hình gốc sang màn hình `_HY` (giữ nguyên cột nhị phân `Layout` và `Snapshot` mà không cần truyền tải qua mạng).
    2.  Dùng hàm `REPLACE` trong SQL để cập nhật lại toàn bộ các thẻ tham chiếu SP gốc thành SP `_HY` bên trong cột văn bản `XmlLayout` (Ví dụ: thay thế `usp_ProductionOrderInfo_get` thành `usp_ProductionOrderInfo_HY_get`).

*Các script hỗ trợ đã được tạo sẵn trong thư mục `sql/scripts/`:*
*   `generated_hy_sps.sql` — Script tạo 78 SPs Hưng Yên mới.
*   `register_hy_screens.sql` — Script đăng ký ScreenInfo & ScreenObjects trên DB `SmartFramework`.
*   `clone_screen_layouts.sql` — Script T-SQL chạy trực tiếp trên `SmartFramework` để nhân bản giao diện và cập nhật mapping.

### 7.5 Tổng Hợp Bài Học Kinh Nghiệm & Khắc Phục Sự Cố

#### 7.5.1 Lỗi Khởi Động Client (Menu Initialization Failed)
*   **Hiện tượng:** Khi chạy script đăng ký màn hình `register_hy_screens.sql` nhưng chưa nhân bản hoặc nhân bản thiếu layout tương ứng trong bảng `STB_ScreenLayoutInfo` (ví dụ do timeout đường truyền WAN khi clone layout), Client MES khi khởi động sẽ lập tức báo lỗi nghiêm trọng: **"Menu initialization failed. Internal Server Error. Please contact your administrator."**
*   **Nguyên nhân gốc rễ:** WCF Web Service của NAIS MES khi boot sẽ tải danh mục toàn bộ menu dựa trên bảng `STB_ScreenInfo` rồi thực hiện đối chiếu/khởi tạo với dữ liệu giao diện layout trong `STB_ScreenLayoutInfo`. Việc có bản ghi đăng ký màn hình trong `STB_ScreenInfo` nhưng bị thiếu/NULL layout XML trong `STB_ScreenLayoutInfo` khiến hàm `MenuManager.Initialize` ở phía WCF Service bị crash lỗi 500 NullReferenceException, dẫn đến toàn bộ Client không thể đăng nhập.
*   **Khắc phục & Phòng ngừa:**
    1.  **Quy trình rollback:** Phải thực hiện xóa đồng bộ các bản ghi của màn hình lỗi ở cả 6 bảng cấu hình hệ thống: `STB_ScreenInfo`, `STB_ScreenObjects`, `STB_ScreenLayoutInfo`, `STB_UserTypeBasicPermission`, `STB_UserTypeViewPermission`, và `STB_UserTypeFunctionPermission`.
    2.  **Nguyên tắc nguyên tử (Atomicity):** Khi thêm màn hình mới, tuyệt đối không được để trạng thái "màn hình đã đăng ký nhưng chưa có layout". Cần chạy script chèn đồng thời cả ScreenInfo và ScreenLayoutInfo dưới dạng một Transaction duy nhất.

#### 7.5.2 Lỗi Nghẽn/Timeout Kết Nối Mạng WAN (Database Connection Timeout)
*   **Hiện tượng:** Quá trình clone layout giao diện bị treo hoặc trả về lỗi Timeout từ SQL Server (mặc định 30s) khi thực hiện cập nhật/thay thế các thẻ XML Layout trực tiếp bằng các vòng lặp SQL.
*   **Nguyên nhân gốc rễ:** Bản ghi layout trong bảng `STB_ScreenLayoutInfo` chứa dữ liệu XML dung lượng rất lớn (`XmlLayout` dưới dạng text XML và `Layout` dưới dạng nhị phân `varbinary`). Đường truyền WAN kết nối đến DB Server đặt tại Hàn Quốc có độ trễ lớn và băng thông giới hạn. Việc thực hiện hàng trăm lệnh UPDATE lớn qua mạng hoặc xử lý XML trực tiếp trên SQL Server thông qua các lệnh query lặp đi lặp lại rất dễ vượt ngưỡng Command Timeout 30 giây.
*   **Giải pháp xử lý tối ưu:**
    1.  Tận dụng lệnh `INSERT INTO ... SELECT` trực tiếp trên server để copy cột nhị phân `Layout` và `Snapshot` mà không truyền dữ liệu nhị phân qua WAN.
    2.  Thực hiện thay thế chuỗi XML (Replace tên SP cũ thành SP `_HY`) trong bộ nhớ phía Client (ví dụ sử dụng script PowerShell local) trước khi insert để tránh thực hiện các câu lệnh UPDATE XML nặng nề trên SQL Server.

#### 7.5.3 Vấn Đề Mã Hóa Tiếng Hàn (Korean Encoding Trap)
*   **Hiện tượng:** Các stored procedure sau khi nhân bản bị báo lỗi cú pháp hoặc bị lỗi hiển thị ký tự (dấu chấm hỏi `??`) tại các phần bình luận tiếng Hàn hoặc các biến logic tiếng Hàn (Ví dụ: `@sumSampleQty공정`).
*   **Nguyên nhân gốc rễ:** SQL Server và các script mặc định lưu ở mã hóa ANSI/ASCII sẽ làm hỏng các ký tự Unicode tiếng Hàn.
*   **Giải pháp:** Bắt buộc phải lưu và thực thi toàn bộ các file script SQL bằng mã hóa **UTF-8 với BOM** (`UTF-8 with Signature`) bằng cách sử dụng tham số `-Encoding UTF8` trong PowerShell hoặc lưu đúng định dạng trong editor, giúp bảo toàn tính toàn vẹn của mã nguồn tiếng Hàn.

---



---

## Appendix — HY Isolated SPs & VPC Tables (DB Verified 2026-06-18)

> **Tổng: 93 SPs** có hậu tố `_HY` — tách biệt hoàn toàn khỏi logic BN/BG/HN

### A.1 HY SP theo nhóm chức năng

#### Electrode (24 SPs):
| SP | Chức năng |
|---|---|
| `usp_ElectrodeMixInfo_HY_get/_iud` | Trộn nguyên liệu HY |
| `usp_ElectrodeMixStepInfo_HY_get/_iud` | Bước trộn chi tiết |
| `usp_ElectrodeCoatingInfo_HY_get/_iud` | Phủ Coating |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_*` | Kiểm tra Coating |
| `usp_ElectrodeOven_HY_get/_iud` | Sấy lò |
| `usp_ElectrodeRollPressingInfo_HY_*` | Ép cuộn |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_*` | Kiểm tra ép cuộn |
| `usp_ElectrodeSlittingInfo_HY_*` / `Result_HY_*` | Cắt cuộn |
| `usp_ElectrodeStep_HY_get/_iud` | Quản lý công đoạn |
| `usp_ElectrodeCommon_HY_get/_iud` | Common |
| `usp_ElectrodeWasteInfoNew_HY_iud` | Phế liệu electrode |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | Viscosity |

#### QC / IQC (18 SPs):
| SP | Chức năng |
|---|---|
| `usp_MaterialQcInfo_HY_get/_iud` | Thông tin QC NVL |
| `usp_MaterialQcDetail_HY_get/_iud` | Chi tiết QC |
| `usp_MaterialQcSampleResult_HY_get/_iud` | Kết quả mẫu |
| `usp_DoMakeMaterialIQCDetailList_HY` | Tạo danh sách IQC |
| `usp_DoMakeMaterialQcSampleResult_HY` | Tạo kết quả mẫu |
| `usp_DoChangeMaterialQcToPass_HY` | Đổi QC → Pass |
| `usp_DoUpdateMaterialQcInfo_Fail/Success_HY` | Cập nhật Fail/Pass |
| `usp_IQcDefectReport_HY_iud` | Báo lỗi IQC |
| `usp_DoSendEmailForDefectReportIQC_HY` | Email báo lỗi IQC |
| `usp_QcInspectionGroup/Item_HY_*` | Nhóm/Hạng mục QC |

#### Production (13 SPs):
| SP | Chức năng |
|---|---|
| `usp_DayProdPlan_HY_get/_iud` | Kế hoạch SX ngày |
| `usp_DoCancelDayProdPlan_HY` | Hủy kế hoạch |
| `usp_DoFixDayProdPlan_HY` | Sửa kế hoạch |
| `usp_ProductionOrderInfo_HY_get` | Lệnh SX |
| `usp_ProductionOrderBom_HY_get` | BOM theo PO |
| `usp_ProductionOrderRouting_HY_get/_iud` | Routing |
| `usp_DoCancelPO_HY` | Hủy PO |
| `usp_DoFixProductionOrder_HY` | Sửa PO |
| `usp_SetInfo_HY_get/_iud_VNT` | Set Info |

#### Finished Goods (10 SPs):
| SP | Chức năng |
|---|---|
| `ups_Add_Fg_HY` | Thêm TP (⚠️ typo: `ups_` không phải `usp_`) |
| `usp_VN_ShowAllFinishGoodMES_HY` | Hiển thị tất cả TP |
| `usp_VN_ShowGoodFinisedExport_HY` | Export TP |
| `usp_VN_Add_FinishGood_HY_New` | Thêm TP mới |
| `usp_VN_IMPORTFINISHEDGOOD_HY_New` | Import TP |
| `usp_VN_Update_GoodFinish_HY_New` | Cập nhật TP |

#### Misc:
`usp_DoAddCommInspMeasureHistForBarcode_HY`, `usp_DoFinishCommInspDoc_HY/_VNT_HY`, `usp_HYStagePrices_iud`, `usp_LocationElectric_HY`, `usp_NCR_Report_HY_iud`, `usp_MainAssemblePartWeight_HY_get`, `usp_GetMaterialGIForPO_HY`, `usp_ModifyRevisionsVerFromC220_VVTF4_HY`

### A.2 HY FG Tables

| Table | Mô tả |
|---|---|
| `STB_VN_FINISHGOODS_HY` | **★ Finished Goods** Hưng Yên (chính) |
| `STB_VN_FINISHGOODS_HY_NEW` | Version mới |

### A.3 VPC Tables (VinaEnesol PCBA — 3 tables)

| Table | Mô tả |
|---|---|
| `STB_VPCLinePlan` | Kế hoạch Line VPC |
| `STB_VPCLinePlan_two` | Version 2 |
| `VPC_Performance` | Hiệu suất PCBA |

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: 93 HY-isolated SPs (phân loại theo chức năng) + HY FG Tables + VPC Tables. DB verified.*

## 🔴 Cẩm nang khắc phục lỗi theo Screen ID (Gộp từ KB_SCREEN_BUG_REF)

## Dry Oven — Lò sấy điện cực (Quy trình sấy V-22)

### Lỗi 1: Lỗi toán tử SQL bypass kiểm tra công đoạn sấy V-22 bắt buộc
*   **Triệu chứng:** Công nhân có thể quét đưa Lot nguyên vật liệu vào lò sấy tự do dù Lot chưa được nhập thông tin hoàn thành công đoạn `V-22` (hoặc `V-22_BG`), phá vỡ luồng tuần tự sản xuất.
*   **Nguyên nhân gốc:** Lỗi độ ưu tiên của toán tử logic `AND` và `OR` trong SP `usp_VN_DryOver` khiến điều kiện kiểm tra luôn đúng với mọi Lot nếu có bất kỳ Lot nào khác đã từng chạy V-22 trong lịch sử.
*   **Cách khắc phục:** 
    Cập nhật SP `usp_VN_DryOver`, thêm dấu ngoặc đơn để gom cụm điều kiện `OR` chính xác:
    ```sql
    SELECT @Stg = routecode FROM STB_ProdRouteHist WITH(NOLOCK)
    WHERE 1=1 
      AND (routecode='V-22' OR routecode='V-22_BG') -- Thêm ngoặc đơn
      AND controlno = (select controlno from stb_setinfo WITH(NOLOCK) where barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6))
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 5](KB_03_SAN_XUAT.md#5-danh-sách-lỗi-logic-điểm-yếu--giải-pháp-bugs--troubleshooting).

---


## Doping JIG — Gá nạp Doping (Quy trình lão hóa)

### Lỗi 1: Lỗi thời gian ghi nhận lịch sử JIG khiến mất dữ liệu log khi tự động ngắt
*   **Triệu chứng:** Khi gá JIG chạy hết 6 giờ và tự động chuyển trạng thái thành `autoend`, thông tin lịch sử của lượt chạy biến mất hoàn toàn, không được lưu vào bảng lịch sử `Stb_VVT_DopingJIG_History`.
*   **Nguyên nhân gốc:** Lỗi logic so sánh thời gian tương lai trong SP `usp_Vietnam_DopingJIG_uid`: điều kiện `ChangeDateTime > dateadd(second,5,getdate())` không bao giờ xảy ra vì `ChangeDateTime` vừa được gán bằng `getdate()`.
*   **Cách khắc phục:** 
    Sửa điều kiện thời gian thành `dateadd(second,-5,getdate())` để lấy các bản ghi vừa được cập nhật:
    ```sql
    insert into Stb_VVT_DopingJIG_History
    select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
    from Stb_VVT_DopingJIG
    where status like '%autoend%'
      and ChangeDateTime > dateadd(second,-5,getdate()) -- Sửa dấu + thành -5 giây
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 5](KB_03_SAN_XUAT.md#5-danh-sách-lỗi-logic-điểm-yếu--giải-pháp-bugs--troubleshooting).

---


## D000 — VinaEnesol Management Menu (Menu quản lý VinaEnesol)

### Lỗi 1: Không truy cập được menu VinaEnesol D000
*   **Triệu chứng:** Người dùng không thấy menu VinaEnesol trên giao diện MES.
*   **Nguyên nhân gốc:** Menu D000 chưa được phân quyền cho Role của người dùng tại Z220/Z330.
*   **Cách khắc phục:** Vào Z220 gán Screen D000 cho Role tương ứng, vào Z330 kiểm tra đã publish.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 2](KB_25_VINAENESSOL_HUNG_YEN.md) và [KB_19_ALL_DATABASES_MAP.md § 4](KB_19_ALL_DATABASES_MAP.md#4-kiến-trúc-màn-hình-động-dynamic-ui-registry-của-smartframework).

---


## D051 — Customer Part No Info (Mã vật tư khách hàng Enesol)

### Lỗi 1: Mã sản phẩm khách hàng không mapping được với mã nội bộ
*   **Triệu chứng:** Khi in tem Enesol, mã khách hàng (CustomerPartNo) hiện trống hoặc sai.
*   **Nguyên nhân gốc:** Bảng `STB_MaterialCodeByCustomer` chưa có mapping giữa `MaterialCode` nội bộ và `MaterialCodeCustomer`.
*   **Cách khắc phục:** Vào D051 thêm mapping mã vật tư nội bộ ↔ mã khách hàng Enesol.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 2.2](KB_25_VINAENESSOL_HUNG_YEN.md).

---


## D100 — Enesol Box Label Print (In tem hộp Enesol)

### Lỗi 1: Không in được tem hộp Enesol (Inner/Outer Box)
*   **Triệu chứng:** Bấm in tem tại D100 nhưng máy in không chạy hoặc tem trống.
*   **Nguyên nhân gốc:** Chưa thiết lập D051 (mapping mã khách hàng) hoặc chưa chọn đúng LabelClassCode (1=Inner, 2=Outer).
*   **Cách khắc phục:** Kiểm tra D051 đã mapping, chọn đúng loại tem (Inner/Outer) và đảm bảo máy in kết nối.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 4](KB_25_VINAENESSOL_HUNG_YEN.md).

---


## D110 — Enesol Box Label History (Lịch sử in tem Enesol)

### Lỗi 1: Lịch sử in tem Enesol hiện thiếu hoặc trùng dữ liệu
*   **Triệu chứng:** Bảng lịch sử D110 hiển thị thiếu bản ghi hoặc có bản ghi trùng lặp.
*   **Nguyên nhân gốc:** Bảng `STB_VINAEnesolBoxLabelPrintHist` bị lỗi khi tạo SerialNo tự tăng hoặc trùng LotNo.
*   **Cách khắc phục:** Kiểm tra trực tiếp DB, xóa bản ghi trùng nếu có.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 4](KB_25_VINAENESSOL_HUNG_YEN.md).

---
