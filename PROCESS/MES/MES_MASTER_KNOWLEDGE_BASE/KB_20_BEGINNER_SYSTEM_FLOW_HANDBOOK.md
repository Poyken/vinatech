# 📖 CẨM NANG NHẬP MÔN HỆ THỐNG LIÊN THÔNG (VINATECH INTEGRATION HANDBOOK FOR NEWCOMERS)

> **Dành cho:** Kỹ sư thiết kế hệ thống, lập trình viên, nhân viên vận hành và AI mới tiếp cận hệ sinh thái phần mềm Vinatech.
>
> **Mục tiêu:** Giúp người mới bắt đầu (chưa từng biết về hệ thống) có thể hiểu rõ từng bước đi của dữ liệu, cách mà các nền tảng **Groupware (Văn phòng)**, **ERP (Kế toán)** và **MES (Nhà xưởng)** giao tiếp với nhau qua các bảng cơ sở dữ liệu vật lý.
>
> ← [Quay lại Mục Lục chính](KB_INDEX.md) | 🗄️ [Tra cứu cấu trúc CSDL chi tiết (KB_19)](KB_19_ALL_DATABASES_MAP.md)

---

## 🏰 1. Phép Ẩn Dụ "Bốn Vương Quốc" (Understanding the Systems)

Để dễ hình dung hệ thống lớn này, hãy tưởng tượng toàn bộ Vinatech là một đế chế gồm **Bốn Vương Quốc** làm việc với nhau thông qua những "sứ giả" cơ sở dữ liệu:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    VƯƠNG QUỐC GROUPWARE (GW)                            │
│                 "Văn phòng ký duyệt & Hành chính"                       │
│  - Nơi con người đưa ra quyết định, đề xuất và ký duyệt giấy tờ.        │
│  - Bảng trung tâm: VINA_DOCUMENT_SAVE (Phiếu lưu), VINA_EMP (Nhân sự)   │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     │ (Sứ giả: Sync PO / Plan / Items)
                                     v
┌────────────────────────────────────┴────────────────────────────────────┐
│                       VƯƠNG QUỐC ERP (DOUZONE)                          │
│                    "Hầm vàng kế toán & Master Data"                     │
│  - Nơi quản lý tiền bạc, công nợ, định giá vật tư gốc và sổ cái.        │
│  - Bảng trung tâm: MA_ITEM (Vật tư), PU_POH (Đơn mua), FI_DOCU (Sổ cái)  │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     │ (Sứ giả: Sync Lệnh ngày / Tồn thực)
                                     v
┌─────────────────────────────────────────────────────────────────────────┐
│                        VƯƠNG QUỐC MES (NAIS)                            │
│                   "Đốc công & Vận hành nhà xưởng"                       │
│  - Nơi trực tiếp quét barcode, in tem, QC hàng hóa, chạy máy vật lý.    │
│  - Bảng trung tâm: STB_MaterialLotInfo (Lô), STB_ProdRouteHist (Chạy máy)│
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     │ (Sứ giả: Mạng lưới an ninh & Còi báo)
                                     v
┌─────────────────────────────────────────────────────────────────────────┐
│                   VƯƠNG QUỐC PHỤ TRỢ (HELPERS)                          │
│            "Hệ thống đường ống, cảm biến và bảo vệ"                     │
│  - SSO (RESTFUL): Bảo vệ soát vé.   - POP (MAC): Máy trạm hiện trường.  │
│  - Andon (Alerts): Chuông báo lỗi.  - WebSocket: Mạng lưới truyền tin.  │
│  - WCMS (Cash): Chuyển tiền NH.     - streamdocs: Kính xem PDF an toàn. │
└─────────────────────────────────────────────────────────────────────────┘
```

*   **Tại sao cần cả 3 vương quốc chính?**
    *   **Groupware** giúp các phòng ban ngồi bàn giấy duyệt đề xuất từ xa.
    *   **ERP** giúp ban giám đốc nhìn thấy bức tranh tài chính và công nợ pháp lý.
    *   **MES** giúp công nhân ở xưởng chạy máy, quét mã vạch và kiểm QC mà không bị nhầm lẫn.

---

## 🔄 2. Ba Dòng Đời Nghiệp Vụ Cốt Lõi (The 3 Master Lifecycles)

Mọi hoạt động tại Vinatech đều là sự phối hợp nhịp nhàng giữa các hệ thống thông qua 3 quy trình chính dưới đây:

### 2.1 Quy trình Mua hàng & Nhập kho (Procure-to-Pay)
*Quy trình này theo dấu từ lúc nhà máy cần mua nguyên vật liệu cho đến lúc vật tư nằm trên kệ kho xưởng và nhà cung cấp nhận được tiền.*

```mermaid
sequenceDiagram
    autonumber
    actor Nhân viên Mua hàng
    participant GW as Groupware (VINATECH_GROUP)
    participant ERP as ERP (NEOE)
    participant MES as MES (SmartFactoryV2)
    actor Thủ kho & QC

    Nhân viên Mua hàng->>GW: 1. Tạo phiếu yêu cầu mua sắm (PR)
    GW->>GW: Duyệt tờ trình qua các cấp sếp
    GW->>ERP: 2. Khi duyệt xong, tự động tạo Đơn mua hàng (PO)
    Note over ERP: Lưu vào bảng PU_POH và PU_POL
    Nhà cung cấp giao hàng->>GW: 3. Bảo vệ/Kho lập phiếu Xác nhận hàng về (Arrival)
    GW->>MES: 4. Đồng bộ thông tin xe hàng về MES
    Note over MES: Kích hoạt màn hình MES F330
    Thủ kho & QC->>MES: 5. Thủ kho quét mã, in tem lô tạm (Lot ID) tại F330
    Thủ kho & QC->>MES: 6. QC đo chất lượng đầu vào (IQC) tại C220
    Note over MES: Ghi nhận trạng thái 'PASS' (P) hoặc 'FAIL' (F)
    Nhân viên Mua hàng->>GW: 7. Lập phiếu Nhập kho chính thức (Receiving)
    Note over GW: Hệ thống chỉ cho phép chọn các Lot đã PASS QC
    GW->>MES: 8. Cộng tồn kho thực tế ở xưởng
    GW->>ERP: 9. Tăng tồn kho sổ sách & Tạo công nợ (FI_DOCU)
    Note over ERP: Duyệt tiếp Purchase Resolution để chi trả ngân hàng
```

---

### 2.2 Quy trình Chỉ thị & Vận hành Sản xuất (Production Execution)
*Quy trình này biến các con số kế hoạch sản xuất trên bàn giấy thành sản phẩm thực tế ra lò từ máy móc.*

```mermaid
sequenceDiagram
    autonumber
    actor Kế hoạch (PPC)
    participant GW as Groupware (VINATECH_GROUP)
    participant MES as MES (SmartFactoryV2)
    participant POP as POP (VINATECH_POP)
    actor Công nhân xưởng

    Kế hoạch (PPC)->>GW: 1. Duyệt Kế hoạch tháng (BOM phiên bản VN 2001)
    GW->>MES: 2. Đồng bộ kế hoạch sang MES B310 (PO Lệnh chạy)
    Kế hoạch (PPC)->>GW: 3. Lập lệnh chạy ngày chi tiết (Line nào, ca nào)
    GW->>MES: 4. Đồng bộ xuống MES B450 để in tem Lot thành phẩm
    Công nhân xưởng->>POP: 5. Khởi động máy trạm POP (Quét thẻ nhân viên, MAC mạng)
    Note over POP: Kiểm tra VINA_PC_MAC để gán đúng Line máy vật lý
    Công nhân xưởng->>POP: 6. Ép quét nguyên vật liệu phụ đầu vào (VINA_BOM_INPUT_ROUTE)
    Note over POP: Chống quên nạp phụ gia, keo, tem bảo hành
    Công nhân xưởng->>MES: 7. Quét chạy máy sản xuất tại MES B530
    Note over MES: PLC gửi sản lượng thực tế, nhiệt độ lò sấy
    POP-->>MES: 8. Nếu máy hỏng / quá nhiệt -> Ghi lỗi vào AndonDB
    Note over MES: TV Andon đầu Line đổi màu đỏ rực & Báo động WebSocket
    Công nhân xưởng->>GW: 9. Cuối ca, chốt số lượng thực tế làm Báo cáo ngày
```

---

### 2.3 Quy trình Bán hàng & Xuất khẩu Container (Order-to-Cash)
*Quy trình xuất thành phẩm tụ điện ra cảng giao cho khách hàng quốc tế.*

```mermaid
sequenceDiagram
    autonumber
    actor Kinh doanh & Logistics
    participant GW as Groupware (VINATECH_GROUP)
    participant ERP as ERP (NEOE)
    participant MES as MES (SmartFactoryV2)
    actor Thủ kho FG

    Kinh doanh & Logistics->>GW: 1. Duyệt đơn bán hàng (Suju)
    GW->>ERP: 2. Tự động tạo đơn hàng bán chính thức (SA_SOH)
    Logistics->>GW: 3. Lập phiếu Yêu cầu xuất kho (Shipment Request)
    GW->>MES: 4. Chuyển tiếp lệnh xuất xuống PDA của kho thành phẩm
    Thủ kho FG->>MES: 5. Quét Box Packing ID tại MES FG01 (Chuyển ra kho đệm)
    Thủ kho FG->>MES: 6. Gom các hộp lên Pallet lớn, in tem dán tại MES B750
    Thủ kho FG->>MES: 7. Xe cont đến, quét Pallet bốc lên cont tại MES B752
    Note over MES: Đối chiếu chéo để tránh xuất nhầm lô/thừa thiếu số lượng
    Logistics->>GW: 8. Lập phiếu Xác nhận thực xuất (Shipment Confirm)
    Note over GW: Điền số tờ khai hải quan và số vận đơn Bill of Lading (B/L)
    GW->>ERP: 9. Trừ tồn kho hạch toán & ghi nhận doanh thu (SA_GIRH / MM_GI_LINE)
```

---

## 📋 3. Ma Trận Biểu Mẫu Hành Chính Tích Hợp (Form-to-DB-to-MES Summary)

Để tránh trùng lặp tài liệu kỹ thuật, chi tiết các bước nghiệp vụ và các câu truy vấn SQL mẫu (Golden Queries) đối soát của từng biểu mẫu đã được hợp nhất tại Mục 9 của **[Bản đồ cơ sở dữ liệu toàn hệ thống (KB_19)](KB_19_ALL_DATABASES_MAP.md)**. 

Dưới đây là bảng tra cứu nhanh 17 biểu mẫu cốt lõi dành cho người mới:

| # | Tên Biểu Mẫu (Hành Chính) | Mã Form ID | Vai Trò Nghiệp Vụ Cốt Lõi | Liên Kết Tra Cứu Kỹ Thuật (SQL & DB) |
|---|---|---|---|---|
| 3.1 | Đơn Yêu Cầu Mua Sắm (PR) | `expenseReportDocument` / `purchaseRequestDocument` | Soạn và duyệt xin ngân sách mua sắm vật tư thiết bị. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#91-đơn-yêu-cầu-mua-sắm-pr--expense-report) |
| 3.2 | Đơn Đặt Hàng (PO) | `purchaseOrderDocument` | Tạo đơn PO chính thức gửi cho nhà cung cấp xác nhận số lượng, giá. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#92-đơn-đặt-hàng-purchase-order---po) |
| 3.3 | Xác Nhận Hàng Về (Arrival) | `arrivalConfirmationDocument` | Khai báo xe hàng về đến cổng nhà máy để in tem lô tạm. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#93-xác-nhận-hàng-về-arrival-confirmation) |
| 3.4 | Xác Nhận Nhập Kho (GR) | `receivingConfirmationDocument` | Nhập kho chính thức các Lot đã PASS QC để cộng tồn kho. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#94-xác-nhận-nhập-kho-receiving-confirmation) |
| 3.5 | Sổ Quyết Toán Mua Hàng | `purchaseResolutionDocument` | Quyết toán chi phí, hạch toán công nợ và chuẩn bị chi tiền. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#95-sổ-quyết-toán-mua-hàng-purchase-resolution) |
| 3.6 | Đơn Xin Nghỉ Việc | `empRetireDocument` | Khóa tài khoản nhân sự thôi việc trên GW, ERP, MES để bảo mật. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#96-đơn-xin-nghỉ-việc-employee-retire-document) |
| 3.7 | Đi Làm Ngày Nghỉ / Lễ | `holidayWorkRequest` | Đăng ký tăng ca ngoài giờ, đối chiếu với giờ quẹt vân tay MES. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#97-đi-làm-ngày-nghỉ--lễ-holiday-work-request) |
| 3.8 | Đăng Ký Đơn Bán Hàng | `salesOrderDocument` | Đăng ký đơn Suju bán tụ điện cho khách hàng quốc tế. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#98-đăng-ký-đơn-bán-hàng-sales-order--suju) |
| 3.9 | Yêu Cầu Xuất Hàng | `deliverOutDocument` | Tạo lệnh xuất kho thành phẩm và chuyển tiếp xuống PDA MES. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#99-yêu-cầu-xuất-hàng-shipment-request) |
| 3.10 | Xác Nhận Thực Xuất | `deliverOutConfirmationDocument` | Xác nhận xe cont rời bánh, trừ tồn kho và ghi nhận doanh thu. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#910-xác-nhận-thực-xuất-shipment-confirmation) |
| 3.11 | Chỉ Thị Sản Xuất Ngày | `dailyProductionOrderDocument` | Giao chỉ tiêu mẻ/lô cho từng chuyền để sinh mã Lot in tem. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#911-chỉ-thị-sản-xuất-ngày-daily-production-order) |
| 3.12 | Báo Cáo Sản Xuất Ngày | `dailyProductionReportDocument` | Báo cáo sản lượng mẻ thực tế cuối ca để chấm điểm KPI. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#912-báo-cáo-sản-xuất-ngày-daily-production-report) |
| 3.13 | Yêu Cầu Tuyển Dụng | `empRequestDocument` | Đăng ký xin tuyển thêm nhân sự mới cho phòng ban. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#913-yêu-cầu-tuyển-dụng-recruitment--emp-request) |
| 3.14 | Yêu Cầu Đi Công Tác | `businessTripDocument` | Đăng ký công tác để tạm ứng và hạch toán chi phí công tác. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#914-yêu-cầu-đi-công-tác-business-trip-request) |
| 3.15 | Đăng Ký Nhà Thầu / Khách | `partnerRegistrationDocument` | Khai báo mã đối tác mới và đồng bộ sang ERP và CMS ngân hàng. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#915-đăng-ký-nhà-thầu--khách-hàng-partner--contractor-registration) |
| 3.16 | Yêu Cầu Thay Đổi BOM | `bomRevisionDocument` | Cập nhật định mức linh kiện sản xuất và sync sang POP Kiosk. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#916-yêu-cầu-thay-đổi-định-mức-bom-revision-request) |
| 3.17 | Đăng Ký Các Loại Code | `itemRegistrationDocument` | Tạo mã vật tư mới để bắt đầu thực hiện mua bán hoặc sản xuất. | [Chi tiết & SQL (KB_19)](KB_19_ALL_DATABASES_MAP.md#917-đăng-ký-các-loại-code-item--code-registration) |

---

## 🛠️ 4. Cẩm Nang Gỡ Lỗi Nhanh Cho Lập Trình Viên Mới (Onboarding Troubleshooting)

Khi vận hành hệ thống liên thông, lỗi phát sinh thường nằm ở các "khớp nối" dữ liệu. Dưới đây là cách chẩn đoán nhanh:

### 4.1 Tại sao đơn mua hàng (PO) đã duyệt trên GW nhưng không sync sang ERP?
*   **Khớp nối bị lỗi:** Trạng thái văn bản trên GW chưa chuyển sang duyệt hoàn toàn.
*   **Cách kiểm tra:** Chạy câu lệnh SQL kiểm tra trạng thái phê duyệt:
    ```sql
    SELECT DOCUMENT_SAVE_STATE 
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE WITH(NOLOCK)
    WHERE DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_CỦA_BẠN';
    ```
    *Nếu kết quả trả về là `'APPROVING'` (đang duyệt) hoặc `'REJECTED'` (bị từ chối) thay vì `'APPROVED'` (đã duyệt), đơn PO sẽ không bao giờ được sync.*

### 4.2 Tại sao màn hình MES F330 không nhìn thấy phiếu hàng về (Arrival)?
*   **Khớp nối bị lỗi:** Cờ trạng thái tiếp nhận ở MES chưa kích hoạt hoặc phiếu Arrival chưa được ký duyệt bởi kho/bảo vệ trên GW.
*   **Cách kiểm tra:** Đảm bảo bản ghi trong bảng `VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H` có trạng thái duyệt bằng `'APPROVED'`.

### 4.3 Tại sao cờ `ERP_FLAG` trong CMS báo lỗi `'E'` (Error)?
*   **Khớp nối bị lỗi:** Khi đồng bộ dòng tiền ngân hàng sang ERP, mã ngân hàng/đối tác hoặc tài khoản định khoản không khớp giữa hai hệ thống (lệch Master Data).
*   **Cách kiểm tra:**
    ```sql
    SELECT ERP_TX_MSG 
    FROM WCMS_STANDARD_NEW.dbo.WCMS_ACCOUNT_TRNX_LOG WITH(NOLOCK)
    WHERE ERP_FLAG = 'E';
    ```
    *Đọc nội dung thông báo lỗi trong cột `ERP_TX_MSG` để biết chính xác mã đối tác nào đang bị thiếu trên danh mục ERP.*

### 4.4 Tại sao Kiosk POP tại chuyền sản xuất báo lỗi không nhận diện được Line máy?
*   **Khớp nối bị lỗi:** Máy tính Kiosk mới được thay thế card mạng hoặc cài lại Windows dẫn đến địa chỉ MAC mạng thay đổi, không còn khớp với cấu hình trong cơ sở dữ liệu.
*   **Cách kiểm tra:**
    1. Lấy địa chỉ MAC mạng thực tế trên máy tính trạm (chạy lệnh `getmac` ở cmd).
    2. Chạy câu lệnh đối chiếu xem MAC này đã được đăng ký đúng máy trạm chưa:
       ```sql
       SELECT PC_MAC_ADDRESS, PC_IPV4_ADDRESS, EQUIPMENT_SETTING_IDS 
       FROM VINATECH_POP.dbo.VINA_PC_MAC WITH(NOLOCK)
       WHERE PC_MAC_ADDRESS = 'ĐỊA_CHỈ_MAC_MỚI';
       ```
    3. Nếu không tìm thấy dòng nào, IT cần cập nhật địa chỉ MAC mới vào bảng `VINA_PC_MAC` để ứng dụng POP load được cấu hình.

---

## 📚 5. Giải Nghĩa Từ Vựng Viết Tắt (Onboarding Glossary)

| Thuật ngữ | Tên đầy đủ | Giải thích đơn giản | vương quốc sở tại |
| :--- | :--- | :--- | :--- |
| **PR** | Purchase Request | Tờ trình đề xuất xin mua hàng. | Groupware |
| **PO** | Purchase Order | Đơn đặt hàng chính thức gửi cho nhà cung cấp. | ERP & Groupware |
| **Suju** | Sales Order | Đơn đặt bán hàng của khách hàng mua tụ điện. | ERP & Groupware |
| **IQC** | Incoming Quality Control | Đo kiểm chất lượng nguyên vật liệu đầu vào (đạt mới cho nhập kho). | MES (C220) |
| **OQC** | Outgoing Quality Control | Đo kiểm chất lượng thành phẩm đầu ra (đạt mới cho bốc cont xuất khẩu). | MES (C530) |
| **Lot ID** | Lot Identification | Mã lô hàng (ví dụ: cuộn màng nhôm, mẻ điện dịch). Dùng để truy vết chất lượng. | MES |
| **Packing ID**| Packing Identification| Mã hộp/thùng chứa sản phẩm sau khi đóng gói. | MES |
| **Pallet ID** | Pallet Identification | Mã đế gỗ gom nhiều hộp hàng để xe nâng bốc xếp. | MES (B750) |
| **BOM 2001** | Bill of Materials 2001 | Định mức nguyên vật liệu lắp ráp sản phẩm (chuẩn riêng cho nhà máy Việt Nam). | ERP & MES |
| **Collation** | Database Collation | Bộ mã hóa ký tự (ví dụ: erpdb dùng mã Hàn Quốc, MES dùng UTF-8). Lệch Collation sẽ gây lỗi khi JOIN. | Database |
| **SSO** | Single Sign-On | Cổng đăng nhập tập trung (chỉ cần đăng nhập 1 lần đi được tất cả các web). | RESTFUL SSO |

---

*Tài liệu được biên soạn và chuẩn hóa trực quan hóa nhằm hỗ trợ tối đa cho kỹ sư mới gia nhập đội ngũ Vinatech Việt Nam.*
