# 🗺️ GW_16 — Bản Thiết Kế Toàn Cảnh: 100% Tính Năng Groupware & Ánh Xạ Cơ Sở Dữ Liệu Chi Tiết

> **Phạm vi tài liệu:** Toàn bộ tính năng Groupware Bizbox Alpha, luồng liên thông dữ liệu và ánh xạ bảng CSDL chi tiết  
> **Cơ sở dữ liệu trung tâm:** `VINATECH_GROUP`  
> **Các CSDL liên kết:** `NEOE` (ERP Douzone iU), `SmartFactoryV2` & `SmartFramework` (MES), `streamdocs`, `VINATECH_RESTFUL`, `VINATECH_SPREADSHEET`, `VINATECH_WEBSOCKET`  
> **Phiên bản:** 1.0 (Master Architectural Blueprint)

---

## 🧭 I. BẢN ĐỒ TỔNG THỂ KIẾN TRÚC MỎ NEO (UNIVERSAL ANCHOR PATTERN)

Mọi hoạt động trên Groupware đều tuân theo mô hình **Generic Document Pattern**:
1. Bảng cha tối cao: `VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE` chứa mỏ neo `DOCUMENT_SAVE_CODE`.
2. Hơn 17 phân hệ biểu mẫu chuyên biệt kế thừa bằng quan hệ `1:1` (Header) và `1:N` (Lines/Detail).
3. Mọi mối quan hệ cha-con giữa các biểu mẫu kế nhiệm (ví dụ: Yêu cầu mua hàng ➔ Đơn PO ➔ Xác nhận hàng về ➔ Nhập kho ➔ Quyết toán) được lưu trữ tại bảng mỏ neo chuỗi: `VINA_DOCUMENT_SAVE_RELATION`.

```
                               ┌────────────────────────────────────────────────────────┐
                               │           VINA_DOCUMENT_SAVE (Bảng Cha Chung)          │
                               │  PK: DOCUMENT_SAVE_CODE                                │
                               │  Trạng thái: DOCUMENT_SAVE_STATE (001, 002, 008, 004)  │
                               │  Mã lưu trữ: RECORD_INCREASE_CODE (ED-...)             │
                               │  Người tạo: NO_EMP_WRITER | Người dùng: NO_EMP_USE     │
                               └───────────────────────────┬────────────────────────────┘
                                                           │
        ┌───────────────────┬──────────────────────────────┼──────────────────────────────┬───────────────────┐
        ▼                   ▼                              ▼                              ▼                   ▼
┌───────────────┐   ┌───────────────┐              ┌───────────────┐              ┌───────────────┐   ┌───────────────┐
│  MUA HÀNG     │   │   BÁN HÀNG    │              │   SẢN XUẤT    │              │   NHÂN SỰ     │   │  TÀI CHÍNH    │
│ VINA_DOCUMENT │   │ VINA_SALES_   │              │ VINA_PROD_    │              │ VINA_DOCUMENT │   │ VINA_DOCUMENT │
│ _POH / POL    │   │ SELLPLAN      │              │ MONTH_PRODPLAN│              │ _LEAVE_REQUEST│   │ _PURCHASE_    │
│ VINA_DOCUMENT │   │ VINA_SALES_   │              │ dailyProduct- │              │ businessTrip  │   │ RESOLUTION    │
│ _RECEIVING_H/L│   │ PROD_HAND     │              │ ionDocument   │              │ empRetire     │   │ disbursement  │
└───────┬───────┘   └───────┬───────┘              └───────┬───────┘              └───────┬───────┘   └───────┬───────┘
        │                   │                              │                              │                   │
        ▼                   ▼                              ▼                              ▼                   ▼
┌───────────────┐   ┌───────────────┐              ┌───────────────┐              ┌───────────────┐   ┌───────────────┐
│   ERP PU_PO   │   │   ERP SA_SO   │              │   ERP PR_WO   │              │ ERP MA_EMP    │   │ ERP FI_DOCU   │
│   MES F330    │   │   MES FG01    │              │ MES B310/B450 │              │ MES Z410      │   │ (Khớp ED-...) │
└───────────────┘   └───────────────┘              └───────────────┘              └───────────────┘   └───────────────┘
```

---

## 🗄️ II. CHI TIẾT 100% CÁC PHÂN HỆ TÍNH NĂNG & ÁNH XẠ DATABASE (FIELD-LEVEL MAPPING)

---

### PHÂN HỆ 1: MUA HÀNG & TIẾP NHẬN NGUYÊN VẬT LIỆU (PURCHASING & INBOUND LOGISTICS)

#### 1.1 Đơn Đề Xuất Chi Phí / Yêu Cầu Mua Hàng (`expenseReportDocument` / `purchaseRequestDocument`)
- **Mục đích:** Khởi tạo nhu cầu mua sắm vật tư, trang thiết bị hoặc chi phí hành chính.
- **Bảng CSDL Groupware:**
  - Header: `VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE` (`DOCUMENT_TYPE_ID = 'expenseReportDocument'`)
  - Detail: `VINATECH_GROUP.dbo.VINA_EXPENSE_REPORT` (`DOCUMENT_SAVE_CODE`, `AM_EXPENSE`, `CD_EXCH`, `RT_EXCH`, `DC_PURPOSE`)
- **Liên kết chuỗi:** Khi được duyệt `008`, mã `DOCUMENT_SAVE_CODE` trở thành cha trong `VINA_DOCUMENT_SAVE_RELATION` để nối vào đơn PO.

#### 1.2 Đơn Đặt Hàng Mua Sắm (`purchaseOrderDocument`)
- **Mục đích:** Phát hành hợp đồng đặt mua nguyên vật liệu gửi nhà cung cấp.
- **Bảng CSDL Groupware:**
  - Header: `VINATECH_GROUP.dbo.VINA_DOCUMENT_POH` (`DOCUMENT_SAVE_CODE`, `CD_COMPANY`, `CD_PARTNER`, `NO_PO`, `DT_PO`, `CD_EXCH`, `RT_EXCH`, `RT_VAT`)
  - Detail: `VINATECH_GROUP.dbo.VINA_DOCUMENT_POL` (`DOCUMENT_SAVE_CODE`, `NO_LINE`, `CD_ITEM`, `QT_PO`, `UM_EX_PO`, `AM_EX_PO`, `CD_SL`, `CD_CC`)
- **Ánh xạ sang ERP Douzone (`NEOE`):**
  - Bảng Header: `NEOE.dbo.PU_POH` (Ánh xạ `NO_PO`, `CD_PARTNER`, `DT_PO`, `CD_EXCH`, `RT_EXCH`)
  - Bảng Detail: `NEOE.dbo.PU_POL` (Ánh xạ `NO_PO`, `NO_LINE`, `CD_ITEM`, `QT_PO`, `UM_EX_PO`, `AM_EX_PO`, `CD_SL`)
- **Ràng buộc:** Cấm hủy nếu đã phát sinh phiếu hàng về hoặc nhập kho.

#### 1.3 Xác Nhận Hàng Về Đến Cổng Xưởng (`arrivalConfirmationDocument`)
- **Mục đích:** Khai báo xe hàng đã về tới nhà máy, nhập số vận đơn B/L và tờ khai hải quan.
- **Bảng CSDL Groupware:**
  - Header: `VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H` (`DOCUMENT_SAVE_CODE`, `NO_PO`, `CD_SL`, `DT_ARRIVAL`, `NO_BL`, `DT_BL`, `NO_CUSTOMS`)
  - Lines: `VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_L` (`DOCUMENT_SAVE_CODE`, `NO_LINE`, `CD_ITEM`, `QT_ARRIVAL`, `BARCODE_LABEL_QTY`, `QTY_PER_LABEL`)
- **Ánh xạ sang MES (`SmartFactoryV2`):**
  - Bảng nhận: `SmartFactoryV2.dbo.STB_MaterialDocInfo` & `STB_MaterialDocDetailInfo` (`MaterialDocNo` = mã phiếu hàng về).
  - Trạm tiếp nhận: Mở khóa màn hình **MES F330**. Thủ kho kiểm đếm và in tem `PartLabel` dán lên thùng.
  - Sinh Lot: Hệ thống MES tự động sinh các bản ghi Lot trong `STB_MaterialLotInfo`.
- **Ánh xạ sang ERP (`NEOE`):**
  - Ghi nhận thông tin vận đơn hải quan vào `NEOE.dbo.PU_BL`.

#### 1.4 Chốt Chặn Kiểm Định Chất Lượng IQC (MES Gatekeeper)
- **Mục đích:** Kiểm tra ngoại quan, kích thước và lý hóa của nguyên vật liệu trước khi nhập kho.
- **Bảng CSDL MES (`SmartFactoryV2`):**
  - Màn hình thao tác: **MES C220** (hoặc `C220_SPS`).
  - Bảng ghi nhận: `SmartFactoryV2.dbo.STB_MaterialQcInfo` & `STB_CommInspDocHistory`.
  - Cột điều khiển: `QcResult` (`'PASS'` hoặc `'REJECT'`).
- **Liên kết sang Groupware:** Groupware không có bảng lưu kết quả này mà gọi API hoặc truy vấn trực tiếp view liên kết. **Chỉ khi `QcResult = 'PASS'`, Groupware mới cho phép hiển thị Lot hàng lên form `Receiving Confirmation`.**

#### 1.5 Xác Nhận Nhập Kho Chính Thức (`receivingConfirmationDocument`)
- **Mục đích:** Ghi nhận nguyên vật liệu chính thức vào kho tài sản công ty sau khi đã PASS IQC.
- **Bảng CSDL Groupware:**
  - Header: `VINATECH_GROUP.dbo.VINA_DOCUMENT_PU_RCVH` (`DOCUMENT_SAVE_CODE`, `NO_PO`, `DT_RCV`, `CD_SL`)
  - Detail: `VINATECH_GROUP.dbo.VINA_DOCUMENT_PU_RCVL` (`DOCUMENT_SAVE_CODE`, `NO_LINE`, `CD_ITEM`, `LOT_NO`, `QT_RCV`, `UM_EX`)
- **Ánh xạ sang ERP & MES:**
  - ERP: Ghi bảng `NEOE.dbo.PU_RCVH` và `PU_RCVL` (tăng tồn kho kế toán).
  - MES: Cập nhật trường `CurrentQty` trong `STB_MaterialLotInfo` (tăng tồn kho vật lý).

#### 1.6 Sổ Quyết Toán Mua Hàng & Phí Logistics (`purchaseResolutionDocument`)
- **Mục đích:** Chốt thanh toán tiền hàng và các phụ phí vận tải (THC, CFS, cước tàu) cho nhà cung cấp.
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION` (`DOCUMENT_SAVE_CODE`, `NO_PO`, `DT_PAYMENT`, `AM_TOTAL`, `CD_ACCT`)
  - `VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION_LINE` (`DOCUMENT_SAVE_CODE`, `NO_LINE`, `CD_ACCT`, `AM_ITEM`, `AM_VAT`)
- **Ánh xạ sang ERP (`NEOE`):**
  - Ghi nhận bút toán kế toán `NEOE.dbo.FI_DOCU` (Header) và `FI_DOCU_D` (Detail).
  - Trường liên kết: Mã hồ sơ `RECORD_INCREASE_CODE` (chuỗi `ED-...`) được tự động chèn vào cột `NM_PUMM` của `FI_DOCU`.
  - View đối chiếu: `VINA_DOCUMENT_ERP_DOCU_INFO_VIEW`.

---

### PHÂN HỆ 2: BÁN HÀNG & XUẤT KHẨU (SALES & OUTBOUND LOGISTICS)

#### 2.1 Đơn Bán Hàng / Suju (`salesOrderDocument`)
- **Mục đích:** Tiếp nhận đơn đặt hàng từ khách hàng trong nước hoặc quốc tế.
- **Bảng CSDL Groupware:**
  - Header: `VINATECH_GROUP.dbo.VINA_SALES_SELLPLAN` (`DOCUMENT_SAVE_CODE`, `NO_SO`, `CD_COMPANY`, `CD_PARTNER`, `DT_SO`, `CD_EXCH`, `RT_EXCH`, `TP_INCOTERMS`)
  - Detail: `VINATECH_GROUP.dbo.VINA_SALES_SELLPLAN_LINE` (`DOCUMENT_SAVE_CODE`, `NO_LINE`, `CD_ITEM`, `QT_SO`, `UM_SO`, `AM_SO`, `DT_DELIVERY`, `CD_SL`)
- **Ánh xạ sang ERP Douzone (`NEOE`):**
  - Ghi nhận đơn hàng vào `NEOE.dbo.SA_SOH` và `SA_SOL`.
- **Tự động hóa ngầm:** Tự động sinh một dòng Kế hoạch sản xuất tháng trên Groupware (`VINA_PROD_MONTH_PRODPLAN`) để chuẩn bị nguồn lực.

#### 2.2 Đề Nghị Xuất Hàng (`deliverOutDocument`)
- **Mục đích:** Ra lệnh cho kho thành phẩm đóng gói và bốc hàng theo Suju.
- **Bảng CSDL Groupware:**
  - Header: `VINATECH_GROUP.dbo.VINA_SALES_PROD_HAND` (`DOCUMENT_SAVE_CODE`, `NO_SO`, `DT_OUT_REQ`)
  - Lines: `VINATECH_GROUP.dbo.VINA_SALES_PROD_HAND_LINE` (`DOCUMENT_SAVE_CODE`, `CD_ITEM`, `QT_OUT_REQ`, `CD_SL`)
- **Ánh xạ sang MES & ERP:**
  - ERP: Ghi bảng đề nghị xuất kho `NEOE.dbo.SA_GIRH` và `SA_GIRL`.
  - MES: Mở màn hình **MES FG01**. Thủ kho dùng PDA quét mã vạch **Packing ID (Box/Carton)**.
  - Chốt chặn OQC: Hệ thống đối chiếu bảng `STB_VN_FINISHGOODS_forQCAudit` (được thẩm định qua màn hình **MES C530/C546**). Chỉ Box đạt **PASS OQC** mới được quét thành công.

#### 2.3 Xác Nhận Thực Xuất & Niêm Phong Container (`deliverOutConfirmationDocument`)
- **Mục đích:** Xác nhận hàng đã xếp lên xe/container, xuất hóa đơn xuất xưởng.
- **Vận hành hạ nguồn tại MES:**
  - Trạm **MES B750**: Gom các Box đạt chuẩn thành Pallet, in tem Pallet dán niêm phong.
  - Trạm **MES B752**: Quét mã Pallet đối chiếu danh sách xếp xe container trước khi lăn bánh.
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.VINA_TRADE_ALL_INVOICE` & `VINA_DOCUMENT_TR_INV` (`DOCUMENT_SAVE_CODE`, `NO_INV`, `DT_INV`, `NO_CONTAINER`, `NO_SEAL`)
- **Ánh xạ sang ERP Douzone (`NEOE`):**
  - Ghi nhận xuất kho thực tế `NEOE.dbo.SA_IVH` và `SA_IVL`.
  - Tự động sinh form Quyết toán doanh thu (`salesResolutionDocument`) gửi phòng Kế toán.

---

### PHÂN HỆ 3: KẾ HOẠCH & ĐIỀU HÀNH SẢN XUẤT (MANUFACTURING PLANNING & EXECUTION)

#### 3.1 Kế Hoạch Sản Xuất Tháng (`productionPlanRequestDocument`)
- **Mục đích:** Phân bổ sản lượng mục tiêu trong tháng cho từng nhà máy (`VVT_F1`, `VVT_F2`, `VVT_F3`).
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.VINA_PROD_MONTH_PRODPLAN` (`DOCUMENT_SAVE_CODE`, `CD_FACTORY`, `YY_PLAN`, `MM_PLAN`, `CD_ITEM`, `QT_PLAN`, `BOM_VER`)
- **Ánh xạ sang MES & ERP:**
  - ERP: Ghi nhận lệnh sản xuất `NEOE.dbo.PR_WO`.
  - MES: Khi chuyển trạng thái "Sản xuất", PO tự động nạp vào `SmartFactoryV2.dbo.STB_ProductionOrderInfo` và hiển thị trên màn hình **MES B310**.
  - **Khóa BOM 2001/2002:** Cột `BOM_VER` bắt buộc là `2001` hoặc `2002`. Nếu lệch, MES từ chối tiếp nhận.

#### 3.2 Chỉ Thị Sản Xuất Ngày & Phát Hành Lot (`dailyProductionOrderDocument`)
- **Mục đích:** Chia nhỏ kế hoạch tháng xuống từng ca làm việc, từng line sản xuất.
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.dailyProductionOrderDocument` (Lưu JSON/XML cấu trúc form).
  - Tương đương bảng: `VINATECH_GROUP.dbo.VINA_PROD_DAY_PRODPLAN` (`DAY_PLAN_NO`, `CD_FACTORY`, `CD_LINE`, `CD_SHIFT`, `CD_ITEM`, `QT_DAY_PLAN`, `STATE_CONFIRM`)
- **Ánh xạ sang MES (`SmartFactoryV2`):**
  - Bảng nhận: `SmartFactoryV2.dbo.STB_DayProdPlan`.
  - Màn hình thao tác: **MES B450**. Tổ trưởng nhấn nút **"Tạo lô (LOT)"** chia sản lượng và in tem mã vạch lô `Assemble Label` (format cấu hình tại **A460**).

#### 3.3 Theo Dõi Hiện Trường & Báo Cáo Sản Xuất Ngày (`dailyProductionReportDocument`)
- **Mục đích:** Chốt sản lượng thực tế, số lượng hoàn thành và phế phẩm trong ca.
- **Bảng CSDL MES Hiện Trường:**
  - Cấp NVL vào máy: `SmartFactoryV2.dbo.STB_RawMaterialInputHist` (Trạm **B540/B597**).
  - Đo kiểm PQC: `SmartFactoryV2.dbo.STB_CommInspDocHistory` (Trạm **C443**).
  - Chốt sản lượng: `SmartFactoryV2.dbo.STB_ProdRouteHist` (Trạm **B530**).
  - POP Kiosk: `VINATECH_POP.dbo.MongoToMesPerformance` (Bảng đệm đồng bộ real-time máy tự động).
- **Ánh xạ về Groupware:** Dữ liệu sản lượng thực tế được nạp vào form `dailyProductionReportDocument` để quản đốc ký duyệt báo cáo hàng ngày.

---

### PHÂN HỆ 4: HÀNH CHÍNH, NHÂN SỰ & CHẤM CÔNG (HR & TIME ATTENDANCE)

#### 4.1 Quản Lý Nghỉ Phép (`leaveDocument` / `leaveCancelDocument`)
- **Mục đích:** Đăng ký nghỉ phép năm, nghỉ việc riêng, nghỉ thai sản, nghỉ ốm.
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.VINA_DOCUMENT_LEAVE_REQUEST` (`DOCUMENT_SAVE_CODE`, `NO_EMP`, `CD_WCODE`, `DT_START`, `DT_END`, `QT_DAYS`, `PROXY_APPROVAL_YN`, `NO_EMP_PROXY`)
  - Mã nghỉ phép `CD_WCODE`: `G05` (Phép năm), `G14` (Nửa ngày), `G15` (Nghỉ bù), `G16` (Việc gia đình), `G17` (Có lương), `G18` (Không lương).
- **Ánh xạ sang ERP & Chấm công MES:**
  - ERP: Ghi nhận giảm ngày phép tồn trong `NEOE.dbo.HR_WTM_*` thông qua Stored Procedure `UP_HR_WTMCALC_TIME_CALC`.
  - MES: Đối chiếu với bảng quét vân tay `STB_VN_ATTENDANCE_TIME`.

#### 4.2 Nghỉ Việc & Khóa Quyền Hệ Thống (`empRetireDocument`)
- **Mục đích:** Phê chuẩn cho nhân sự thôi việc và thu hồi tài nguyên số.
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.empRetireDocument` (`NO_EMP`, `DT_RETIRE`, `DT_LAST_WORK`, `NO_EMP_HANDOVER`)
- **Cơ chế Khóa Đăng Nhập Đa Hệ Thống:**
  - ERP: Cập nhật `NEOE.dbo.MA_EMP.CD_INCOM = '099'` (Thôi việc) và khóa `MA_USER`.
  - MES Hàn Quốc: Stored Procedure `SmartFramework.dbo.usp_DoGUILogin` chặn đăng nhập khi thấy `CD_INCOM = '099'`.
  - MES Việt Nam: HR truy cập màn hình **MES Z410** cập nhật `SmartFramework.dbo.STB_UserInfo.AllowFlag = 'Deny'` để khóa tài khoản hiện trường.

#### 4.3 Quản Lý Chấm Công Hiện Trường & Điều Chỉnh Giờ Công (`attendanceModifyDocument`)
- **Mục đích:** Xử lý các trường hợp quên quét vân tay, lỗi đầu đọc hoặc quét sai cửa.
- **Bảng CSDL MES Hiện Trường:**
  - Đầu đọc vân tay: Ghi nhận log thô vào `SmartFactoryV2.dbo.Stb_fingerUserInfo`.
  - SQL Job ngầm: Job `SyncFingerData` chạy định kỳ gọi `usp_SyncFingerData` để tính toán giờ vào/ra, ghi vào bảng `SmartFactoryV2.dbo.STB_VN_ATTENDANCE_TIME`.
- **Ánh xạ khi duyệt form `attendanceModifyDocument`:**
  - Cập nhật trực tiếp các cột `TimeIn`, `TimeOut`, `TotalTime` trong `STB_VN_ATTENDANCE_TIME` tương ứng với mã nhân viên `NO_EMP`.

---

### PHÂN HỆ 5: TÀI CHÍNH & ĐỀ NGHỊ THANH TOÁN (FINANCIAL DISBURSEMENTS)

#### 5.1 Đề Nghị Thanh Toán Chi Phí (`disbursementDocument`)
- **Mục đích:** Trình duyệt chi trả tiền hàng, công nợ dịch vụ hoặc chi phí hành chính.
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION` hoặc bảng động Form Builder.
  - Quản lý định tuyến tài khoản kế toán:
    - **Tài khoản Nợ:** Đầu `627` (Chi phí sản xuất), đầu `642` (Chi phí quản lý), đầu `241` (Mua sắm tài sản >= 30 triệu VNĐ), đầu `133` (Thuế VAT đầu vào).
    - **Tài khoản Có:** `33111` (Phải trả NCC nội địa bằng VND), `33112` (Phải trả NCC nước ngoài bằng USD).
- **Ánh xạ sang ERP Douzone (`NEOE`):**
  - Sinh chứng từ kế toán chính thức trong `NEOE.dbo.FI_DOCU` (Header) và `FI_DOCU_D` (Lines).
  - Cột `NM_PUMM` nhận chuỗi `RECORD_INCREASE_CODE` (ví dụ `ED-VJPMTR000000021`).

---

### PHÂN HỆ 6: QUẢN TRỊ DỮ LIỆU GỐC (MASTER DATA MANAGEMENT)

#### 6.1 Đăng Ký Mã Vật Tư Mới (`itemRegistrationDocument`) & Cập Nhật Mã (`itemChangeDocument`)
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.VINA_ITEM_REG_DOCU` (`CD_ITEM`, `CLS_ITEM`, `NM_ITEM`, `NM_ITEM_ENG`, `SPEC`, `CD_UNIT`, `CD_SL_IN`, `CD_SL_OUT`, `CD_CC`)
- **Ánh xạ sang ERP & MES:**
  - ERP: Đăng ký mã vật tư gốc vào `NEOE.dbo.MA_PITEM`.
  - MES: Tự động đồng bộ xuống màn hình thiết lập thiết bị **MES A230** để dây chuyền nhận diện mã hàng.

#### 6.2 Phê Duyệt Cấu Hình BOM Định Mức (`bomAdditionDocument`)
- **Bảng CSDL ERP & MES:**
  - ERP: `NEOE.dbo.PR_BOM` (Header & Details).
  - MES: `SmartFactoryV2.dbo.STB_BomHeader` và `STB_BomDetail`.
  - **Quy tắc phiên bản:** Phiên bản BOM bắt buộc phải là **`2001`** (Việt Nam thông thường) hoặc **`2002`** (Cell line mới). Màn hình kiểm tra BOM trên MES là **A310**, áp dụng vào lệnh sản xuất tại **B310**.

#### 6.3 Đăng Ký Nhà Thầu / Khách Hàng (`partnerManagementDocument`)
- **Bảng CSDL Groupware:**
  - `VINATECH_GROUP.dbo.VINA_PARTNER_REG_DOCU` (`CD_PARTNER`, `LN_PARTNER`, `NO_COMPANY` (Mã số thuế), `CD_BANK`, `NO_DEPOSIT`, `YN_CREDIT`)
- **Ánh xạ sang ERP:**
  - Ghi nhận đối tác chính thức vào `NEOE.dbo.MA_PARTNER`. Nếu đối tác chưa active (`YN_USE = 'Y'`), ERP sẽ khóa mọi giao dịch mua bán liên quan.

---

### PHÂN HỆ 7: HỆ THỐNG AI AGENT NGUYÊN BẢN (NATIVE BIZBOX AI AGENT ENGINE)

#### 7.1 Lược Đồ 12 Bảng AI Agent Trong `VINATECH_GROUP`:
1. `VINA_AGENT_TYPE`: Cấu hình Universal Agent (`STATIC_DATA_000762`) và Prompt Maker Agent (`STATIC_DATA_000770`).
2. `VINA_AGENT_TOOL`: Gán quyền gọi tool (Gmail, Google Drive, ECM, E-Approval).
3. `VINA_AGENT_DYNAMIC_API`: Khai báo API Spring Beans (`vinatechDocumentSaveService`, `vinatechEmpService`).
4. `VINA_AGENT_CHAT_ROOM`: Quản lý phiên đàm thoại giữa nhân viên (`NO_EMP`) và AI.
5. `VINA_AGENT_CHAT_CONTENT`: Nội dung từng prompt và phản hồi của LLM.
6. `VINA_AGENT_MEMORY`: Ghi nhớ ngữ cảnh làm việc và sở thích cá nhân.
7. `VINA_AGENT_WORKFLOW` & `VINA_AGENT_WORKFLOW_STEP`: Chuỗi tác vụ AI tự động nhiều bước.
8. `VINA_AGENT_TOKEN_LOG`: Kiểm soát chi phí tiêu thụ Token theo từng nhân viên và công ty.
9. `VINA_AGENT_SCHEDULE_LOG`: Nhật ký các tác vụ AI chạy ngầm theo lịch trình.
10. `VINA_AGENT_VOLATILITY_CHAT_ROOM`: Phiên hội thoại tạm thời (Incognito).
11. `VINA_AGENT_WORKFLOW_LOG`: Lịch sử thực thi quy trình workflow AI.
12. `VINA_AGENT_CONFIG`: Tham số cấu hình endpoint và API key kết nối mô hình.

---

## 🔗 III. HỆ SINH THÁI CSDL VỆ TINH PHỤ TRỢ (SATELLITE DATABASES)

| Tên Database | Máy Chủ / Cổng | Vai Trò Nghiệp Vụ Cốt Lõi | Bảng Quan Trọng |
| :--- | :--- | :--- | :--- |
| **`VINATECH_GROUP`** | `dbserver.hycap.co.kr,5398` | Trung tâm điều phối, 17 biểu mẫu, quy trình duyệt, sơ đồ tổ chức, AI Agent | `VINA_DOCUMENT_SAVE`, `VINA_DOCUMENT_POH`, `VINA_EMP`, `VINA_AGENT_*` |
| **`VINATECH_RESTFUL`**| `dbserver.hycap.co.kr,5398` | Cổng xác thực một lần (SSO Mesh) cho Web Portal, MES, Mobile App | `VINA_SSO_TOKEN` (quản lý Access Token, Client IP, Hạn phiên) |
| **`streamdocs`** | `dbserver.hycap.co.kr,5398` | Cỗ máy render PDF và lưu trữ số hóa văn bản kèm chữ ký điện tử chuẩn K-SOX | `pdf_resource` (Lưu binary PDF, chuỗi Hash SHA-256) |
| **`VINATECH_SPREADSHEET`**| `dbserver.hycap.co.kr,5398` | Quản lý bảng tính Excel trực tuyến nhúng trong biểu mẫu | `VINA_SPREAD_SHEET_JSON` (Lưu cấu trúc ma trận cell dữ liệu) |
| **`VINATECH_WEBSOCKET`**| `dbserver.hycap.co.kr,5398` | Phát thông báo đẩy thời gian thực, đồng bộ TV Andon xưởng | `VINA_MODULE` (Quản lý các kênh topic socket thời gian thực) |
| **`NEOE`** | `dbserver.hycap.co.kr,5398` | Sổ cái tài chính, mua bán hàng, BOM và hồ sơ nhân sự gốc của ERP Douzone iU | `PU_PO`, `SA_SO`, `FI_DOCU`, `PR_BOM`, `MA_EMP` |
| **`SmartFactoryV2`** | `dbserver.hycap.co.kr,5398` | Điều hành sản xuất hiện trường, kho NVL, QC và đóng gói thành phẩm | `STB_MaterialDocInfo`, `STB_MaterialLotInfo`, `STB_DayProdPlan`, `STB_ProdRouteHist` |
| **`SmartFramework`** | `dbserver.hycap.co.kr,5398` | Quản lý tài khoản đăng nhập người dùng MES và phân quyền GUI | `STB_UserInfo` (`Appendix8` nối `NO_EMP`) |

---

## ⚡ IV. DANH MỤC THỦ TỤC (STORED PROCEDURES) & VIEWS CẦU NỐI CỐT LÕI

1. **`VINA_DOCUMENT_ERP_DOCU_INFO_VIEW` (Groupware DB):**
   - Ánh xạ tức thì giữa mã văn bản Groupware (`DOCUMENT_SAVE_CODE`), mã hồ sơ (`RECORD_INCREASE_CODE` `ED-...`) và mã chứng từ kế toán ERP (`NO_DOCU`).
2. **`VINA_DOCUMENT_APPROVAL_SAVE_VIEW` (Groupware DB):**
   - Tổng hợp trạng thái duyệt của từng cấp phê duyệt trên biểu mẫu, phát hiện người đang giữ phiếu.
3. **`usp_DoSyncMaterialUnit_itf_TF` (Groupware DB):**
   - Thủ tục đồng bộ đơn vị tính và quy cách vật tư giữa Groupware và ERP.
4. **`UP_HR_WTMCALC_TIME_CALC` (ERP DB):**
   - Thủ tục tính toán ngày công và phép năm từ đơn xin nghỉ phép Groupware.
5. **`usp_DoGUILogin` (SmartFramework DB):**
   - Thủ tục xác thực đăng nhập người dùng MES, kiểm tra trạng thái thôi việc `CD_INCOM = '099'` và mật khẩu ERP.
6. **`usp_ERPInterface_daemon` (MES DB):**
   - Tiến trình daemon quét và đồng bộ xuất/nhập/tiêu hao nguyên vật liệu giữa MES và ERP.
7. **`usp_SyncFingerData` (MES DB):**
   - Thủ tục đồng bộ dữ liệu máy chấm công vân tay vào bảng giờ công `STB_VN_ATTENDANCE_TIME`.
