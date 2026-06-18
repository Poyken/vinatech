
Kiến thức cốt lõi về sự tương tác và tích hợp giữa các hệ thống (System Thinking) được thể hiện qua các luồng đi của dữ liệu liên phòng ban và liên hệ thống dưới đây:

### 3.1. Luồng Nghiệp Vụ Mua Sắm & Quyết Toán Thanh Toán (Procure-to-Pay Pipeline)

```
[Groupware: Tạo PO] ──► [ERP: Tạo PU_POH] ──► [Groupware: Tạo Arrival] 
                                                    │
[ERP: Nhập kho PU_RCVH] ◄── [Groupware: Duyệt Receiving] ◄── [MES: Kiểm QC F330/C220 PASS] 
          │
[Groupware: Tạo Đề nghị Thanh toán] ──► [ERP: Hạch toán công nợ FI_DOCU] ──► [CMS: Chi trả ngân hàng]
```

1.  **Khởi tạo đơn đặt hàng:** Nhân viên mua hàng tạo đơn đề xuất mua hàng trên Groupware. Sau khi ban giám đốc duyệt thông qua tuyến duyệt tĩnh (`VINA_WORKFLOW_STEP`), hệ thống đẩy dữ liệu sang ERP `NEOE` để tạo đơn mua hàng chính thức (`PU_POH`/`PU_POL`) và cấp mã đơn hàng `NO_PO`.
2.  **Xác nhận hàng về (Arrival):** Khi nhà cung cấp giao hàng đến cổng bảo vệ, nhân viên kho lập phiếu **Arrival Confirmation** trên Groupware (`VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H`). Luồng thông tin tự động ghi nhận vào MES `STB_MaterialDocInfo` để kích hoạt giao diện **MES F330**.
3.  **In tem nhãn & Kiểm QC:** Thủ kho Vinatech quét nhận hàng tại màn hình **MES F330**, in tem mã vạch chứa thông tin lô (`STB_MaterialLotInfo`). Đội ngũ QC tiến hành đo kiểm chất lượng tại **MES C220**. Kết quả ghi nhận vào `STB_CommInspDocHistory`.
4.  **Nhập kho chính thức (Receiving):** Nếu kết quả QC báo **PASS** (ký hiệu `'P'`), Groupware hiển thị danh sách các Lot hợp lệ để nhân viên lập phiếu **Receiving Confirmation** (`VINA_DOCUMENT_PU_RCVH`). Sau khi duyệt, hệ thống tự động cộng số dư tồn kho tại MES (`STB_MaterialLotInfo.CurrentQty`) và đẩy nghiệp vụ nhập kho chính thức sang ERP (`PU_RCVH`/`PU_RCVL`).
5.  **Quyết toán & Thanh toán:** Nhân viên kế toán lập **Purchase Resolution** trên Groupware (`VINA_DOCUMENT_PURCHAE_RESOLUTION`) đối chiếu với số lượng thực nhập và đơn giá thỏa thuận. Duyệt hoàn tất sẽ tự động định khoản tài khoản chi phí (`FI_DOCU`/`FI_DOCU_D`) trên ERP `NEOE`. Hệ thống Cash Management System (`WCMS_STANDARD_NEW`) truy xuất số dư tài khoản ngân hàng, tạo lệnh chuyển tiền Firm Banking trả tiền cho nhà cung cấp.

---

### 3.2. Luồng Nghiệp Vụ Chỉ Thị & Vận Hành Sản Xuất (Production Scheduling & Execution)

```
[Groupware: Month Plan] ──► [MES: Order B310] ──► [Groupware: Daily Plan & Lot Split] 
                                                               │
[MES: Quét chạy máy B530] ◄── [POP: Quét NVL phụ & Map máy] ◄── [MES: In nhãn Lot B450]
          │
[Andon: Ghi lỗi dừng máy] ──► [WebSocket Server] ──► [TV Andon hiển thị tức thời]
```

1.  **Duyệt Kế hoạch tháng:** Phòng Kế hoạch sản xuất lập kế hoạch tháng trên Groupware (`VINA_PROD_MONTH_PRODPLAN`), áp dụng BOM phiên bản Việt Nam **2001**. Khi trạng thái chuyển sang `'Sản xuất'`, dữ liệu tự động đồng bộ sang màn hình chỉ thị sản xuất **MES B310** (PO Info).
2.  **Lập Lệnh chạy ngày:** Groupware lập tiếp Kế hoạch ngày (`VINA_DOCUMENT_DAILY_PRODUCTION_ORDER`) phân bổ chi tiết số lượng sản xuất theo từng Line, Ca làm việc (`SHIFT_CODE`) và thực hiện chia Lot (`VINA_DOCUMENT_DAILY_PRODUCTION_ORDER_LOT`). Dữ liệu được đồng bộ xuống màn hình **MES B450** để in tem nhãn lô thành phẩm và chèn sẵn trạng thái hàng chờ chạy chuyền vào `STB_SetInfo` của MES.
3.  **Vận hành đầu line (Shop Floor POP):** Công nhân tại Line khởi động PC trạm Kiosk POP. Ứng dụng `VINATECH_POP` xác thực địa chỉ MAC card mạng (`VINA_PC_MAC`), tự động liên kết máy trạm với Line sản xuất tương ứng. Khi chạy máy:
    *   POP đối chiếu `VINA_BOM_INPUT_ROUTE` để yêu cầu công nhân phải quét mã vật tư phụ bắt buộc tại đầu công đoạn (tránh việc công nhân quên nạp vật tư phụ).
    *   POP gán mã máy vật lý đang hoạt động vào Kế hoạch ngày của MES thông qua `VINA_EQUIPMENT_MAPPING`.
4.  **Báo cáo dừng máy (Andon Alerting):** Nếu máy móc xảy ra sự cố đột ngột hoặc PLC trả tín hiệu quá nhiệt/dừng máy, sự kiện dừng máy được ghi ngay vào `AndonDB.dbo.STB_LineSituation_VVT` với cột `status` = `1`. WebSocket Server (`VINATECH_WEBSOCKET`) bắt sự kiện thay đổi dữ liệu này và phát tín hiệu TCP thời gian thực đẩy màu nền TV Andon đầu line sang đỏ rực, đồng thời bắn Toast Alert lên màn hình duyệt của quản đốc xưởng trên Groupware.

---

### 3.3. Luồng Nghiệp Vụ Bán Hàng & Xuất Hàng Container (Order-to-Cash Pipeline)

```
[Groupware: Duyệt Suju] ──► [ERP: Tạo SO SA_SOH] ──► [Groupware: Shipment Request]
                                                                │
[ERP: Giảm tồn hạch toán] ◄── [MES: Quét bốc cont B752] ◄── [MES: Xuét kho tạm FG01]
          │
[Groupware: Shipment Confirm] ──► [ERP: Ghi doanh thu] ──► [Cảng: ASN Cargo Sync]
```

1.  **Ký duyệt Suju:** Nhân viên kinh doanh đăng ký đơn hàng của khách hàng trên Groupware (`VINA_DOCUMENT_SALES_ORDER`). Khi được phê duyệt, hệ thống tự động đẩy dữ liệu sang ERP `NEOE` tạo đơn bán hàng SO (`SA_SOH`/`SA_SOL`) và sinh mã Suju `NO_SO`.
2.  **Yêu cầu xuất kho:** Khi đến hạn giao hàng, nhân viên lập phiếu duyệt **Shipment Request** trên Groupware (`VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION_IV`). Luồng dữ liệu kích hoạt lệnh xuất kho trên hệ thống MES.
3.  **Hiện trường kho thành phẩm:** 
    *   Thủ kho quét mã các hộp hàng thành phẩm **Packing ID** trên thiết bị PDA chạy màn hình **MES FG01** để xuất kho tạm trung chuyển.
    *   Thực hiện gộp các Packing ID lên một Pallet và in tem Pallet lớn trên màn hình **MES B750** (`Pallet ID`).
    *   Khi xe Container cập bến, thủ kho chạy màn hình **MES B752** để quét bốc xếp các Pallet lên lòng xe Container, hệ thống tự động kiểm tra đối soát chéo số lượng quét thực tế có khớp với Shipment Request đã được duyệt trên Groupware hay không để ngăn chặn xuất thừa/thiếu hàng.
4.  **Xác nhận xuất hàng & Khai báo hải quan:** Sau khi Container rời cảng, nhân viên cập nhật Số tờ khai hải quan (`NO_CUSTOMS`) và số vận đơn (`NO_BL`) trên phiếu **Shipment Confirmation** của Groupware (`VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION`). Duyệt hoàn tất sẽ tự động kích hoạt ERP hạch toán giảm tồn kho thành phẩm chính thức, ghi nhận doanh thu xuất khẩu (`SA_GIRH`/`SA_GIRL`) và đồng bộ kết quả ASN sang cổng thông tin Cargo của cảng.

---

## 🔍 4. Bộ Câu Hỏi SQL Tra Cứu & Đối Chiếu Siêu Cấp (Golden Audit Queries)

Dưới đây là 4 câu truy vấn SQL mẫu (SELECT-ONLY) chuyên dụng giúp Kỹ sư hệ thống và AI dễ dàng đối chiếu dữ liệu chéo giữa các hệ thống cơ sở dữ liệu để tìm ra nguồn gốc lỗi logic:

### Mẫu 4.1: Đối chiếu đơn mua hàng (PO) liên thông Groupware ↔ ERP ↔ MES
Giúp kiểm tra xem một đơn mua hàng đã được duyệt trên Groupware đã đồng bộ thành công sang ERP và có Lot nào đã được quét nhập kho ở MES chưa.
```sql
SELECT 
    GW_H.DOCUMENT_SAVE_CODE AS [GW Doc Code],
    GW_H.NO_PO AS [PO Number],
    GW_L.CD_ITEM AS [Item Code],
    GW_L.QT_PO AS [Qty Ordered (GW)],
    GW_L.DOCUMENT_POL_REMAIN_QT_PO AS [Qty Remaining (GW)],
    -- Đối chiếu thông tin ERP
    ERP_L.QT_PO AS [Qty Registered (ERP)],
    -- Đối chiếu số liệu nhập kho thực tế tại MES
    (SELECT SUM(ML.CurrentQty) 
     FROM SmartFactoryV2.dbo.STB_MaterialLotInfo ML WITH(NOLOCK) 
     WHERE ML.PurchaseOrderNo = GW_H.NO_PO AND ML.MaterialCode = GW_L.CD_ITEM) AS [Actual Qty in MES WH]
FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_POH GW_H WITH(NOLOCK)
INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_POL GW_L WITH(NOLOCK) 
    ON GW_H.DOCUMENT_SAVE_CODE = GW_L.DOCUMENT_SAVE_CODE
-- Join sang ERP NEOE
LEFT JOIN NEOE.dbo.PU_POL ERP_L WITH(NOLOCK) 
    ON GW_H.NO_PO = ERP_L.NO_PO AND GW_L.CD_ITEM = ERP_L.CD_ITEM
WHERE GW_H.NO_PO = 'PO20260612001' -- Thay bằng mã PO thực tế cần đối soát
   OR GW_H.DOCUMENT_SAVE_CODE = 'DOC-PO-99882';
```

### Mẫu 4.2: Đối soát dòng tiền ngân hàng và cờ đồng bộ ERP của Cash Management System
Kiểm tra danh sách sao kê ngân hàng có lượng tiền biến động lớn nhưng chưa đồng bộ được sang sổ cái ERP hoặc đồng bộ bị lỗi.
```sql
SELECT 
    LOG.ACCOUNT_NO AS [Bank Account],
    LOG.TRNX_DATE AS [Transaction Date],
    LOG.IN_AMOUNT AS [Amount In],
    LOG.OUT_AMOUNT AS [Amount Out],
    LOG.BOOK_DESC AS [Statement Description],
    LOG.ERP_FLAG AS [Sync State], -- 'Y' = Success, 'N' = Pending, 'E' = Error
    LOG.ERP_TX_DATE AS [Sync Date],
    LOG.ERP_TX_MSG AS [Error Message from ERP],
    -- Tra cứu xem đã tạo chứng từ kế toán nào trên ERP tương ứng chưa
    ERP.NO_DOCU AS [ERP Voucher No]
FROM WCMS_STANDARD_NEW.dbo.WCMS_ACCOUNT_TRNX_LOG LOG WITH(NOLOCK)
LEFT JOIN NEOE.dbo.FI_DOCU_D ERP WITH(NOLOCK) 
    ON LOG.ACCOUNT_TRNX_LOG_UUID = ERP.NO_IS -- Giả định UUID được gán vào cột NO_IS tham chiếu ERP
WHERE LOG.ERP_FLAG <> 'Y' -- Lọc các giao dịch chưa sync thành công
  AND (LOG.IN_AMOUNT > 100000000 OR LOG.OUT_AMOUNT > 100000000) -- Lọc giao dịch trên 100 triệu VND
ORDER BY LOG.TRNX_DATE DESC;
```

### Mẫu 4.3: Kiểm toán an ninh - Phát hiện Token SSO đang hoạt động của nhân viên đã thôi việc
Đối chiếu trạng thái tài khoản trên Groupware để phát hiện các Token SSO trong cache chưa bị thu hồi (revoke) của nhân viên đã ký đơn nghỉ việc.
```sql
SELECT 
    SSO.ID_USER AS [Active Username],
    SSO.SSO_TOKEN_CLIENT_IP AS [Client IP],
    SSO.SSO_TOKEN_DIVICE AS [Device],
    SSO.SSO_TOKEN_REG_DATE AS [Session Created Time],
    E.EMP_STOP AS [GW Status], -- 'Y' = Đã khóa tài khoản trên Groupware
    E.DT_ENTER_LEAVE AS [Resignation Date],
    -- Lấy tên nhân viên từ sơ đồ tổ chức
    O.ORG_CHART_NODE_NAME AS [Employee Name]
FROM VINATECH_RESTFUL.dbo.VINA_SSO_TOKEN SSO WITH(NOLOCK)
INNER JOIN VINATECH_GROUP.dbo.VINA_EMP E WITH(NOLOCK) 
    ON SSO.ID_USER = E.NO_EMP AND SSO.CD_COMPANY = E.CD_COMPANY
LEFT JOIN VINATECH_GROUP.dbo.VINA_ORG_CHART_NODE O WITH(NOLOCK) 
    ON E.NO_EMP = O.NO_EMP AND E.CD_COMPANY = O.CD_COMPANY
WHERE E.EMP_STOP = 'Y' -- Chỉ lọc những tài khoản đã bị khóa/nghỉ việc
   OR E.DT_ENTER_LEAVE <= CAST(GETDATE() AS DATE)
ORDER BY SSO.SSO_TOKEN_REG_DATE DESC;
```

### Mẫu 4.4: Đối soát hiệu suất Line - Kết hợp POP quét NVL, MES chạy máy và Andon cảnh báo lỗi
Hệ thống hóa lịch sử chạy máy của một Lot cụ thể: kiểm tra xem Lot đó được quét chạy máy ở Line nào, máy trạm nào, có bị lỗi dừng máy Andon nào phát sinh trong ca sản xuất đó hay không.
```sql
SELECT 
    SI.Barcode AS [Lot/Box No],
    SI.MaterialCode AS [Product Model],
    SI.InputLineCode AS [Line Code],
    -- Lịch sử quét chạy máy trên MES
    PRH.RouteCode AS [Operation Step],
    PRH.ProdDateTime AS [MES Scan Time],
    PRH.MachineCode AS [Machine Code],
    -- Tra cứu cấu hình máy trạm POP tương ứng qua MAC
    POP.PC_MAC_ADDRESS AS [POP Kiosk MAC],
    POP.PC_IPV4_ADDRESS AS [POP IP],
    -- Tra cứu xem có phát sinh dừng máy Andon tại Line này trong khoảng thời gian chạy Lot không
    (SELECT TOP 1 ANDON.errorname 
     FROM AndonDB.dbo.STB_LineSituation_VVT ANDON WITH(NOLOCK) 
     WHERE ANDON.linecode = SI.InputLineCode 
       AND ANDON.status = 1 -- Trạng thái dừng máy
       AND ANDON.createdatetime BETWEEN DATEADD(HOUR, -1, PRH.ProdDateTime) AND DATEADD(HOUR, 1, PRH.ProdDateTime)) AS [Coinciding Andon Error]
FROM SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_ProdRouteHist PRH WITH(NOLOCK) 
    ON SI.ControlNo = PRH.ControlNo
LEFT JOIN VINATECH_POP.dbo.VINA_PC_MAC POP WITH(NOLOCK) 
    ON POP.EQUIPMENT_SETTING_IDS LIKE '%' + PRH.MachineCode + '%'
WHERE SI.Barcode = 'VVPO273R010713' -- Mã Lot cần đối soát lịch sử chạy chuyền
ORDER BY PRH.ProdDateTime ASC;
```

---

## 🧬 5. Tư Duy Hệ Thống & Phân Tầng Kiến Trúc (System Thinking & Architectural Layering)

Để vận hành hệ thống Vinatech ở mức tốt nhất, chúng ta cần tư duy về 13 cơ sở dữ liệu này dưới dạng các phân tầng kiến trúc logic thay vì các DB độc lập. Sự liên kết này được chia làm 5 tầng chức năng:

| Phân Tầng | Các Cơ Sở Dữ Liệu | Vai Trò Trong Chuỗi Giá Trị Vận Hành |
| :--- | :--- | :--- |
| **1. Lớp Giao Dịch Cốt Lõi (Core Transaction Layer)** | `NEOE` (ERP), `SmartFactoryV2` (MES), `VINATECH_GROUP` (Groupware) | Lưu dữ liệu gốc (Master Data), kế hoạch sản xuất chính, lệnh sản xuất và hạch toán kế toán tổng hợp. Đây là "xương sống" của Vinatech. |
| **2. Lớp Tích Hợp Văn Phòng & Cộng Tác (Office Collaboration Layer)** | `DZICUBE` (Bizbox Alpha), `streamdocs` (PDF Viewer), `VINATECH_SPREADSHEET` (Excel Online) | Hỗ trợ phê duyệt hành chính từ xa, đính kèm bảng tính cộng tác động và bảo mật hiển thị tài liệu thiết kế sản phẩm. |
| **3. Lớp IoT Nhà Xưởng & Thời Gian Thực (Shop Floor IoT Layer)** | `VINATECH_POP` (POP Kiosk), `AndonDB` (Alerts), `VINATECH_WEBSOCKET` (WS Server) | Kết nối máy móc vật lý (PLC), bắt sự kiện dừng máy đầu line và chuyển tiếp tín hiệu thời gian thực lên bảng giám sát. |
| **4. Lớp An Ninh & Tuân Thủ (Security & Compliance Layer)** | `WCMS_STANDARD_NEW` (CMS), `VINATECH_RESTFUL` (SSO), `VINATECH_DATA_KSOX` (K-SOX) | Bảo mật xác thực một lần, whitelist IP API Gateway, quản lý dòng tiền tự động với ngân hàng và kiểm toán chốt kiểm soát nội bộ. |
| **5. Lớp Thử Nghiệm & Lưu Trữ Lịch Sử (Dev & Archive Layer)** | `SmartFactoryIncubator` (R&D), `erpdb` (Legacy ERP) | Môi trường Sandbox thử nghiệm sản phẩm mới (R&D) và kho dữ liệu ERP cũ trước khi chuyển đổi hệ thống. |

---

## 🛠️ 6. Các Kịch Bản Lỗi Vận Hành Thực Tế & Cách Khắc Phục (Troubleshooting Scenarios)

Dưới đây là cẩm nang hướng dẫn xử lý các sự cố đồng bộ dữ liệu chéo giữa các cơ sở dữ liệu thường gặp trong thực tế vận hành:

### Kịch Bản 6.1: Cờ đồng bộ `ERP_FLAG` của sao kê ngân hàng bị kẹt trong `WCMS_STANDARD_NEW`
*   **Triệu chứng:** Sao kê ngân hàng đã cào về CMS thành công nhưng không đẩy được bút toán kế toán sang ERP `NEOE`. Cột `ERP_FLAG` trong bảng `WCMS_ACCOUNT_TRNX_LOG` ở trạng thái `'E'` (Error) hoặc giữ nguyên `'N'` (Pending) không chuyển sang `'Y'`.
*   **Nguyên nhân:** Lỗi kết nối API Gateway giữa CMS và ERP, hoặc mã đối tác/tài khoản kế toán định khoản bị trống/lỗi cấu trúc trên ERP.
*   **Phương án xử lý (SELECT-only & Hướng dẫn phục hồi):**
    1. *Tìm kiếm các giao dịch bị kẹt:*
       ```sql
       SELECT ACCOUNT_TRNX_LOG_UUID, ACCOUNT_NO, TRNX_DATE, IN_AMOUNT, OUT_AMOUNT, ERP_TX_MSG 
       FROM WCMS_STANDARD_NEW.dbo.WCMS_ACCOUNT_TRNX_LOG WITH(NOLOCK)
       WHERE ERP_FLAG IN ('N', 'E');
       ```
    2. *Hướng dẫn khắc phục:* Nếu lỗi do mã đối tác sai, cập nhật thông tin tài khoản đối tác trong `WCMS_BIZ_PARTNER_ACCOUNT` khớp với mã vendor ERP. Sau đó, DBA cần cập nhật cờ `ERP_FLAG = 'N'` và xóa log lỗi `ERP_TX_MSG = NULL` để Agent Job quét và đẩy lại chứng từ trong chu kỳ tiếp theo.

### Kịch Bản 6.2: Khóa Concurrency trong `VINATECH_SPREADSHEET` bị treo
*   **Triệu chứng:** Người dùng mở bảng tính cộng tác trên Groupware báo lỗi: *"Tài liệu đang được chỉnh sửa bởi người dùng khác"* mặc dù người dùng kia đã tắt trình duyệt từ lâu.
*   **Nguyên nhân:** Khi người dùng đóng tab trình duyệt đột ngột hoặc mất mạng, sự kiện ngắt kết nối WebSocket không kích hoạt được lệnh xóa bản ghi khóa phiên trong bảng `VINA_SPREAD_SHEET_OPEN`.
*   **Phương án xử lý (SELECT-only & Hướng dẫn phục hồi):**
    1. *Tra cứu phiên khóa đang bị treo:*
       ```sql
       SELECT SPREAD_SHEET_CHANNEL, NO_EMP, CD_COMPANY, SPREAD_SHEET_OPEN_REG_DATE 
       FROM VINATECH_SPREADSHEET.dbo.VINA_SPREAD_SHEET_OPEN WITH(NOLOCK)
       WHERE SPREAD_SHEET_CHANNEL = 'ID_BANG_TINH_BI_KHOA';
       ```
    2. *Hướng dẫn khắc phục:* Xác nhận với nhân viên có `NO_EMP` tương ứng xem họ có đang mở file thực tế không. Nếu không, DBA thực hiện lệnh `DELETE FROM VINATECH_SPREADSHEET.dbo.VINA_SPREAD_SHEET_OPEN WHERE SPREAD_SHEET_CHANNEL = 'ID_BANG_TINH_BI_KHOA' AND NO_EMP = 'MA_NHAN_VIEN'` để giải phóng khóa ghi lập tức.

### Kịch Bản 6.3: Lỗi Collation Conflict khi đối chiếu dữ liệu lịch sử từ `erpdb`
*   **Triệu chứng:** Khi chạy câu lệnh SQL JOIN đối chiếu danh mục vật tư cũ từ `erpdb` với danh mục vật tư hiện tại của MES `SmartFactoryV2` hoặc ERP `NEOE` báo lỗi:
    `"Cannot resolve the collation conflict between 'Korean_Wansung_Unicode' and 'SQL_Latin1_General_CP1_CI_AS' in the JOIN operation."`
*   **Nguyên nhân:** Database `erpdb` sử dụng collation Hàn Quốc (`Korean_Wansung_Unicode`) trong khi các database mới sử dụng collation chuẩn quốc tế/Việt Nam.
*   **Phương án xử lý (SELECT-only):**
    *   *Câu truy vấn đối chiếu chuẩn hóa Collation:*
        ```sql
        SELECT 
            MES.MaterialCode AS [MES Code], 
            MES.MaterialName AS [MES Name],
            OLD.품목명 AS [Legacy Name]
        FROM SmartFactoryV2.dbo.STB_MaterialMaster MES WITH(NOLOCK)
        INNER JOIN erpdb.dbo.품목마스타 OLD WITH(NOLOCK) 
            -- Ép kiểu collation về DATABASE_DEFAULT ở mệnh đề JOIN
            ON MES.MaterialCode COLLATE DATABASE_DEFAULT = OLD.품목코드 COLLATE DATABASE_DEFAULT;
        ```

### Kịch Bản 6.4: Máy trạm POP không load được cấu hình thiết bị từ `VINATECH_POP`
*   **Triệu chứng:** Màn hình Kiosk đầu chuyền hiển thị thông báo lỗi thiết bị hoặc không hiển thị thông số lò sấy/nhiệt độ hơi nước.
*   **Nguyên nhân:** Địa chỉ MAC của PC trạm bị thay đổi (thay card mạng mới) dẫn đến bảng `VINA_PC_MAC` không ánh xạ được thiết bị, hoặc chuỗi JSON cấu hình `EQUIPMENT_SETTING_JSON` bị lỗi cú pháp.
*   **Phương án xử lý (SELECT-only & Hướng dẫn phục hồi):**
    1. *Kiểm tra địa chỉ IP và MAC hiện tại của trạm:*
       ```sql
       SELECT PC_MAC_ADDRESS, PC_IPV4_ADDRESS, EQUIPMENT_SETTING_IDS, SYSTEM_VERSION 
       FROM VINATECH_POP.dbo.VINA_PC_MAC WITH(NOLOCK)
       WHERE PC_IPV4_ADDRESS = 'IP_MAY_TRAM_DANG_LOI';
       ```
    2. *Hướng dẫn khắc phục:* Nếu địa chỉ MAC thực tế của máy trạm không trùng khớp với `PC_MAC_ADDRESS` trong DB, DBA cần cập nhật lại địa chỉ MAC mới vào bảng. Nếu do JSON lỗi, copy chuỗi `EQUIPMENT_SETTING_JSON` ra công cụ Lint để chuẩn hóa lại cú pháp JSON trước khi lưu lại.

---

## 🛡️ 7. Tiêu Chuẩn Bảo Mật & Phân Quyền Giữa Các Cơ Sở Dữ Liệu (Security & Authentication Matrix)

Để đảm bảo an toàn thông tin, các cơ sở dữ liệu của Vinatech áp dụng 3 cơ chế xác thực chéo chặt chẽ:

1.  **Xác thực thiết bị vật lý (Kiosk):** `VINATECH_POP` dùng `VINA_PC_MAC` để khóa chặt quyền điều khiển PLC của máy trạm theo đúng địa chỉ MAC mạng. Ngăn chặn việc cắm nhầm máy tính từ line này sang line khác điều khiển sai thông số.
2.  **Bảo mật tài liệu PDF:** `streamdocs` dùng `pdf_auth` cấp khóa token thời gian thực (`session_token`) giới hạn IP và số lần mở tài liệu. Tuyệt đối không lưu link tĩnh của file bản vẽ thiết kế sản phẩm.
3.  **Thu hồi quyền lập tức (Resignation Revoke):** `VINATECH_RESTFUL` chạy job liên tục đối chiếu tài khoản SSO `VINA_SSO_TOKEN` với danh sách nhân viên đã nghỉ việc (`EMP_STOP = 'Y'`) tại `VINATECH_GROUP.dbo.VINA_EMP`. Nếu phát hiện có Token hoạt động của nhân viên đã thôi việc, hệ thống tự động xóa Token đó để logout tài khoản trên tất cả các nền tảng (MES, Groupware, Portal, App) ngay lập tức.

---

## 🔄 8. Cơ Chế Kỹ Thuật Đồng Bộ & Liên Thông (Under-The-Hood Sync Mechanisms)

Sự tương tác thực tế giữa 13 cơ sở dữ liệu trên không diễn ra qua các tệp tin thủ công mà được tự động hóa qua 4 phương thức kỹ thuật chính:

### 8.1. Liên kết trực tiếp cùng Instance (Same-Instance Direct Query)
*   **Nguyên lý:** Tất cả 13 databases (bao gồm cả ERP `NEOE`) đều nằm chung trên một thực thể SQL Server (`dbserver.hycap.co.kr,5398`). Do đó, các Stored Procedure của MES hoặc Groupware có thể thực hiện truy vấn JOIN trực tiếp qua cú pháp ba phần: `[DatabaseName].[dbo].[TableName]`.
*   **Ví dụ:** Khi quét IQC đạt `PASS` tại MES, màn hình Groupware chạy truy vấn đọc trực tiếp trạng thái từ `SmartFactoryV2.dbo.STB_CommInspDocHistory` mà không cần gọi qua Web API trung gian.

### 8.2. ESM Collector & Daemon Service (Tiến trình đồng bộ ngầm)
*   **Nguyên lý:** Đồng bộ khối lượng lớn (Batch synchronization) giữa MES `SmartFactoryV2` và ERP `NEOE` được đảm nhận bởi tiến trình dịch vụ chạy ngầm **ESM Collector** và Stored Procedure `usp_ERPInterface_daemon`.
*   **Luồng hoạt động:**
    1. MES ghi nhận sản lượng/tiêu hao vào các bảng cầu nối `ESM_ProdRouteHist`, `ESM_RawMaterialInputHist` với cờ `ErpUpdate = 'N'`.
    2. ESM Collector quét định kỳ (chu kỳ 1000ms theo cấu hình `ESM_ProdCollectionSetting`) để pick-up các bản ghi chưa sync.
    3. Gọi SP `usp_ERPInterface_daemon` để chèn dữ liệu vào bảng giao tiếp `STB_ERP_INTERFACE`, từ đó hạch toán trực tiếp vào các ledger sản phẩm/tiêu hao của ERP.

### 8.3. RESTful API Gateway (Xác thực SSO và Gọi API)
*   **Nguyên lý:** Đối với các ứng dụng Client như Web Groupware, Mobile App hay Kiosk POP, việc tương tác dữ liệu được thực hiện qua RESTful API Gateway kết nối với database `VINATECH_RESTFUL`.
*   **Luồng hoạt động:**
    1. Client gửi request kèm JWT token trong header.
    2. API Gateway thực hiện so khớp token với bảng `VINA_SSO_TOKEN` để xác thực danh tính người dùng và kiểm tra dải IP trong `VINA_ALLOWED_IP`.
    3. Nếu hợp lệ, Gateway thực thi gọi các stored procedure tương ứng trong `SmartFactoryV2` hoặc `VINATECH_GROUP` để trả dữ liệu cho Client.

### 8.4. WebSocket Broadcast Loop (Đẩy sự kiện thời gian thực)
*   **Nguyên lý:** Hệ thống WebSocket Server duy trì kết nối TCP liên tục với các trạm Kiosk POP và TV Andon. Dữ liệu trạng thái lỗi dừng máy trong `AndonDB.dbo.STB_LineSituation_VVT` được WebSocket Server theo dõi (sử dụng SqlDependency hoặc Trigger Event).
*   **Luồng hoạt động:**
    1. Khi có thay đổi trạng thái lỗi đầu line, record `STB_LineSituation_VVT` được cập nhật.
    2. Một Event Trigger bắn tín hiệu đến WebSocket Server.
    3. WebSocket Server broadcast gói tin JSON chứa trạng thái lỗi tới các client đang subscribe kênh `WS_ANDON` để lập tức đổi màu nền hiển thị trên Tivi Andon xưởng mà không cần tải lại trang.

---

## 🔄 9. Ma Trận Ánh Xạ Biểu Mẫu Groupware ↔ Cấu Trúc CSDL ↔ Màn Hình MES (Comprehensive Form-to-DB-to-MES Mapping Guide)
