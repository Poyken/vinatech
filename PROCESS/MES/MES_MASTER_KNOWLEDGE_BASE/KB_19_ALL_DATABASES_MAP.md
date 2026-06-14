# 🗄️ BẢN ĐỒ CƠ SỞ DỮ LIỆU TOÀN HỆ THỐNG (VINATECH MASTER DATABASE ARCHITECTURE)

> **Mục đích:** Hướng dẫn toàn diện về kiến trúc và cấu trúc dữ liệu của 13 hệ thống cơ sở dữ liệu vận hành tại Vinatech Việt Nam. Tài liệu này đóng vai trò là cẩm nang kỹ thuật giúp kỹ sư hệ thống, lập trình viên và AI hiểu rõ vai trò, cấu trúc bảng cốt lõi, cơ chế liên thông nghiệp vụ liên hệ thống (Data Pipelines) và cách viết các truy vấn đối soát dữ liệu (Golden Audit Queries).
>
> *Quy tắc vận hành tối thượng: Chỉ thực hiện truy vấn đọc dữ liệu (`SELECT` kết hợp `WITH(NOLOCK)`). Tuyệt đối KHÔNG chạy các câu lệnh thay đổi dữ liệu (`INSERT`, `UPDATE`, `DELETE`, `DROP`) trên các database production.*

---

## 🗺️ 1. Sơ Đồ Kiến Trúc Liên Thông Cơ Sở Dữ Liệu (Database Integration Map)

Hệ thống vận hành của Vinatech được cấu thành từ 13 cơ sở dữ liệu chuyên biệt, liên kết chặt chẽ với nhau để tạo thành một hệ thống thông tin nhất quán từ văn phòng (Groupware) đến nhà xưởng (MES) và tài chính kế toán (ERP):

```mermaid
graph TD
    %% Định nghĩa các node cơ sở dữ liệu
    NEOE[(1. ERP Core: NEOE)]
    GW[(2. Groupware: VINATECH_GROUP)]
    MES[(3. Production MES: SmartFactoryV2)]
    DZICUBE[(4. Bizbox Alpha: DZICUBE)]
    WCMS[(5. Cash Management: WCMS_STANDARD_NEW)]
    POP[(6. Shop Floor: VINATECH_POP)]
    Andon[(7. Alerts: AndonDB)]
    WS[(8. WebSocket: VINATECH_WEBSOCKET)]
    SSO[(9. Identity: VINATECH_RESTFUL)]
    Spreadsheet[(10. Excel Online: VINATECH_SPREADSHEET)]
    Streamdocs[(11. PDF View: streamdocs)]
    Ksox[(12. Compliance: VINATECH_DATA_KSOX)]
    Incubator[(13. R&D Sandbox: SmartFactoryIncubator)]

    %% Các mối quan hệ liên thông dữ liệu
    GW -->|Sync PO & Suju & BOM| NEOE
    GW -->|Sync Lệnh SX & BOM 2001| MES
    MES -->|Sync Sản lượng & Tồn kho thực| NEOE
    
    GW -.->|Đính kèm bảng tính| Spreadsheet
    GW -.->|Xem PDF an toàn| Streamdocs
    
    SSO -->|Token & Refresh Session| GW
    SSO -->|Token Auth Kiosk| POP
    SSO -->|SSO Gate| MES
    
    POP -->|MAC Auth & PLC Settings| MES
    POP -->|Đẩy sản lượng trạm| MES
    
    MES -->|Kích hoạt cảnh báo dừng máy| Andon
    Andon -->|Push Event tức thời| WS
    WS -->|Đổi màu trạng thái hiển thị| TV[Tivi Andon đầu Line]
    WS -->|Toast Alert trình duyệt| GW
    
    GW -->|Liên kết chi phí/Thẻ| WCMS
    WCMS -->|Sao kê ngân hàng & check ERP_FLAG| NEOE
    
    GW -->|Phê duyệt chi phí| DZICUBE
    DZICUBE -->|Bút toán nháp ABDOCU| NEOE
    
    Ksox -->|Kiểm soát đối chiếu số liệu| NEOE
    Incubator -->|Sandbox thử nghiệm trước khi lên| MES

    %% Styling các node để phân biệt vai trò
    style NEOE fill:#0d47a1,stroke:#333,stroke-width:2px,color:#fff
    style MES fill:#2e7d32,stroke:#333,stroke-width:2px,color:#fff
    style GW fill:#e65100,stroke:#333,stroke-width:2px,color:#fff
    style WCMS fill:#006064,stroke:#333,stroke-width:1px,color:#fff
    style DZICUBE fill:#311b92,stroke:#333,stroke-width:1px,color:#fff
    style Andon fill:#b71c1c,stroke:#333,stroke-width:1px,color:#fff
```

---

## 🗂️ 2. Vai Trò & Cấu Trúc Chi Tiết Của 13 Hệ Thống Cơ Sở Dữ Liệu

### 2.1. AndonDB — Giám Sát Cảnh Báo & Dừng Máy
*   **Vai trò nghiệp vụ:** Giám sát trạng thái hoạt động vật lý của các line sản xuất thời gian thực, phát hiện sự cố dừng máy (Line Downtime), tự động gửi thông báo (App/Email) tới tổ trưởng và đội bảo trì thiết bị để giảm thiểu tổn thất năng suất.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `STB_LineSituation_VVT`: Ghi nhận tình huống lỗi đầu line.
        *   `linecode` (`varchar(20)`): Mã line xảy ra sự cố.
        *   `routecode` (`varchar(20)`): Mã công đoạn xảy ra sự cố (ví dụ: `V-23`, `B540`).
        *   `status` (`int`): `0` = Đang chạy bình thường, `1` = Sự cố dừng máy, `2` = Chờ (Idle).
        *   `statusApp` / `statusEmail` (`int`): Cờ kiểm soát gửi tin (`0` = Chưa gửi, `1` = Đã gửi thành công).
        *   `errorcode` / `errorname` (`nvarchar(1000)`): Mã lỗi và mô tả lỗi dừng máy.
    *   `STB_LineInfo`: Danh mục master các dây chuyền sản xuất.
        *   `LineCode` (`varchar(20)`): Mã dây chuyền định danh.
        *   `MonitoringGroup` (`nvarchar(50)`): Nhóm gom cụm các line để hiển thị chung trên một màn hình TV Andon giám sát.
    *   `STB_VVT_UserWarning`: Quản lý tài khoản nhận tin cảnh báo.
        *   `username` / `password` (`varchar(50)`): Tài khoản đăng nhập app nhận tin cảnh báo.
        *   `groupid` (`varchar(50)`): Phân nhóm nhận tin (ví dụ: `MAINTENANCE` - Kỹ thuật bảo trì).

---

### 2.2. DZICUBE — Douzone Bizbox Alpha Groupware & Accounting Core
*   **Vai trò nghiệp vụ:** Lưu trữ cấu hình hệ thống Groupware đóng gói Douzone Bizbox Alpha, quản lý định mức phê duyệt chi phí, tài sản cố định, tích hợp đối chiếu thẻ doanh nghiệp và chuyển chứng từ hạch toán kế toán nháp sang ERP.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `ABDOCU` (Header chứng từ nháp) / `ABDOCU_D` (Line chứng từ nháp):
        *   `NO_DOCU` (`varchar(20)`): Số chứng từ kế toán nháp phát sinh từ phê duyệt Groupware.
        *   `CD_ACCT` (`varchar(10)`): Mã tài khoản kế toán định khoản (Nợ/Có).
        *   `AM_DR` / `AM_CR` (`numeric`): Số tiền phát sinh Nợ / Có.
        *   `CD_PARTNER` (`varchar(20)`): Mã nhà cung cấp/khách hàng liên quan.
        *   `CD_CC` (`varchar(10)`): Mã trung tâm chi phí chịu phí (Cost Center).
    *   `ABASSET`: Quản lý tài sản cố định.
        *   `CD_ASSET` (`varchar(20)`): Mã tài sản cố định.
        *   `AM_ACQ` (`numeric`): Nguyên giá mua tài sản.
        *   `CD_DEPT` (`varchar(10)`): Phòng ban chịu trách nhiệm quản lý tài sản.
    *   `A_TAXBILL`: Quản lý hóa đơn thuế VAT điện tử.
        *   `NO_TAX` (`varchar(30)`): Số hóa đơn thuế GTGT.
        *   `AM_SUPPLY` / `AM_VAT` (`numeric`): Tiền hàng trước thuế / Tiền thuế GTGT.

---

### 2.3. erpdb — Cơ Sở Dữ Liệu ERP Cũ (Legacy Archive)
*   **Vai trò nghiệp vụ:** Lưu trữ dữ liệu lịch sử của hệ thống ERP cũ (Douzone NeoPlus / Smart A) phục vụ cho kế toán đối chiếu số liệu các năm trước. Database ở trạng thái đóng băng (Read-only).
*   **Đặc điểm kỹ thuật đặc thù:**
    *   **Tên bảng bằng tiếng Hàn (Korean Collation):** Hệ thống sử dụng bộ font và mã hóa ký tự đặc thù Hàn Quốc. Các bảng chính được đặt tên trực tiếp bằng tiếng Hàn:
        *   `사원마스타` (Sawon Master): Danh mục Nhân sự cũ.
        *   `거래처마스타` (Georaecheo Master): Danh mục Đối tác cũ.
        *   `전표H` (Jeonpyo Header) / `전표D` (Jeonpyo Detail): Chứng từ kế toán cũ.
        *   `품목마스타` (Pummok Master): Danh mục Vật tư cũ.
    *   **Lưu ý:** Lập trình viên/AI không cần kết nối hoặc đồng bộ dữ liệu với database tĩnh này trong các tác vụ nghiệp vụ hiện tại.

---

### 2.4. NEOE — ERP Douzone iU (Central General Ledger)
*   **Vai trò nghiệp vụ:** Hệ thống hoạch định tài nguyên doanh nghiệp trung tâm (ERP), quản lý Ledger tài chính kế toán chính thức, Master dữ liệu vật tư/đối tác, quản lý đơn mua hàng (PO), đơn bán hàng (Suju), định mức BOM sản xuất và xuất nhập kho hạch toán.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `MA_ITEM`: Master danh mục vật tư sản phẩm.
        *   `CD_ITEM` (`nvarchar(20)`): Mã vật tư duy nhất.
        *   `NM_ITEM` / `STND_ITEM` (`nvarchar(100)`): Tên và quy cách thông số vật tư.
    *   `MA_PARTNER`: Master danh mục khách hàng, nhà cung cấp.
        *   `CD_PARTNER` (`nvarchar(20)`): Mã đối tác.
        *   `NO_BIZ` (`nvarchar(20)`): Mã số thuế đối tác (bắt buộc).
    *   `PU_POH` (Header PO) / `PU_POL` (Line PO):
        *   `NO_PO` (`nvarchar(20)`): Số đơn đặt mua hàng.
        *   `QT_PO` / `UM` / `AM` (`numeric`): Số lượng, đơn giá và thành tiền nội tệ VND.
    *   `PU_RCVH` (Header nhập kho mua) / `PU_RCVL` (Line nhập kho mua):
        *   `NO_RCV` (`nvarchar(20)`): Số phiếu nhập kho mua hàng (kết quả của Receiving trên GW).
    *   `SA_SOH` (SO Header) / `SA_SOL` (SO Line):
        *   `NO_SO` (`nvarchar(20)`): Số đơn bán hàng từ khách hàng (Suju).
    *   `FI_DOCU` (Header bút toán) / `FI_DOCU_D` (Line bút toán):
        *   `NO_DOCU` (`nvarchar(20)`): Mã chứng từ kế toán chính thức ghi sổ.
    *   `PR_BOM`: Định mức nguyên vật liệu sản xuất.
        *   `CD_BOM` / `CD_ITEM` / `CD_MATL` / `QT_BOM`: Liên kết cấu trúc lắp ráp.

---

### 2.5. SmartFactoryIncubator — Sandbox Thử Nghiệm R&D
*   **Vai trò nghiệp vụ:** Môi trường Sandbox cô lập hoàn toàn phục vụ đội R&D nghiên cứu sản phẩm mới (Tụ điện siêu hóa Supercapacitors), thử nghiệm thiết bị kiểm tra cell tự động và thử nghiệm cấu hình SCM/ASN trước khi triển khai lên hệ thống chính thức.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `STB_CellTestResult`: Kết quả đo kiểm thông số cell.
        *   `ProdNo` (`varchar(50)`): Mã Lot/ControlNo của cell tụ được đo kiểm.
        *   `Voltage` / `Capacitance` / `ESR` / `LeakageCurrent` (`numeric`): Kết quả đo điện thế, điện dung (Farad), nội trở và dòng rò rỉ.
    *   `STB_CellTestResultRT`: Kết quả đo thời gian thực liên tục (Real-time telemetry).
    *   `RCV_ASN` (Nhận) / `OUT_ASN` (Xuất): Thử nghiệm khai báo trước thông tin giao hàng (Advanced Shipping Notice).
    *   `LUNAR_TO_SOLAR`: Bảng chuyển đổi lịch Âm - Dương phục vụ lập lịch nghỉ ca ngày lễ Tết cho nhà máy Việt Nam & Hàn Quốc.

---

### 2.6. streamdocs — Forcs PDF Document Web-Stream Server
*   **Vai trò nghiệp vụ:** Quản lý metadata và an ninh cho tệp PDF đính kèm biểu mẫu Groupware. Máy chủ StreamDocs chuyển đổi tệp PDF thành dữ liệu luồng để hiển thị trực tiếp trên Web Viewer của Groupware, ngăn ngừa hành vi tải file trực tiếp về máy cá nhân để bảo mật thông tin.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `pdf_resource`: Lưu trữ định danh tệp PDF vật lý.
        *   `resource_id` (`varchar(50)`): Mã băm MD5 định danh duy nhất của tệp.
        *   `file_size` / `file_path` (`varchar`): Kích thước và đường dẫn vật lý trên máy chủ.
    *   `pdf_resource_owner`: Liên kết chủ sở hữu tệp.
        *   `document_save_code` (`varchar(50)`): Mã văn bản trên Groupware sở hữu tệp PDF này.
    *   `pdf_auth`: Quản lý khóa phiên truy cập tệp.
        *   `session_token` (`varchar(500)`): Token được cấp phép để render luồng dữ liệu PDF lên trình duyệt.
    *   `sd_document_usage_history`: Nhật ký xem tài liệu (Audit Trail).
        *   `user_id` / `client_ip` / `view_timestamp`: Ai, IP nào đã xem tài liệu vào lúc nào.

---

### 2.7. VINATECH_DATA_KSOX — ICFR Compliance & Internal Control
*   **Vai trò nghiệp vụ:** Quản lý quy trình tuân thủ kiểm soát nội bộ báo cáo tài chính (Internal Control over Financial Reporting - ICFR) theo tiêu chuẩn luật K-SOX (Hàn Quốc) dành cho công ty niêm yết.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `ICM_CTRLMATRIX_MT` (Master ma trận kiểm soát) / `ICM_CTRLMATRIX_TERM` (Kỳ đánh giá):
        *   `CONTROL_UUID` (`varchar(50)`): ID duy nhất của chốt kiểm soát quy trình (ví dụ: Chốt kiểm soát PO cần 3 báo giá).
        *   `PROCESS_CODE` (`varchar(20)`): Mã quy trình nghiệp vụ (Mua hàng, bán hàng, kho, kế toán...).
    *   `ICM_CTRLMATRIX_TERM_DESIGNTEST`: Lưu kết quả kiểm thử thiết kế kiểm soát.
        *   `TEST_UUID` (`varchar(50)`): ID bản ghi kiểm thử.
        *   `SAMPLE_SIZE` (`int`): Số lượng mẫu chứng từ được kiểm toán rút ngẫu nhiên.
        *   `TEST_RESULT` (`nvarchar(20)`): Kết quả đánh giá (`PASS`/`FAIL`).
        *   `ATTACH_FILE_ID` (`varchar(50)`): Đường dẫn đính kèm bằng chứng kiểm toán (chụp màn hình chứng từ).
    *   `COM_APPROVAL_LINE` / `COM_APPROVAL_HIST`: Tuyến ký duyệt và nhật ký ký duyệt kết quả kiểm soát nội bộ của CEO/CFO.

---

### 2.8. VINATECH_GROUP — Groupware Core Portal & Electronic Approval
*   **Vai trò nghiệp vụ:** Cổng thông tin nội bộ (Groupware), quản lý sơ đồ tổ chức, tài khoản nhân viên, luồng phê duyệt văn bản điện tử (Electronic Approval) và lập kế hoạch sản xuất tháng/ngày đầu vào.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `VINA_DOCUMENT_SAVE`: Header chung lưu trữ mọi biểu mẫu trình duyệt.
        *   `DOCUMENT_SAVE_CODE` (`varchar(50)`): Mã định danh duy nhất của tài liệu (Khóa ngoại chính liên kết tất cả các bảng form nghiệp vụ).
        *   `DOCUMENT_SAVE_STATE` (`varchar(50)`): Trạng thái phiếu duyệt (`DRAFT`, `APPROVING`, `APPROVED`, `REJECTED`).
        *   `DOCUMENT_SAVE_CONTENT` (`ntext`): Nội dung Rich-text HTML hiển thị trên web.
    *   `VINA_DOCUMENT_POH` (Header PO) / `VINA_DOCUMENT_POL` (Line PO): Biểu mẫu đơn mua hàng.
        *   `NO_PO` (`nvarchar(20)`): Số PO đồng bộ sang ERP sau khi duyệt.
        *   `DOCUMENT_POL_REMAIN_QT_PO` (`numeric`): Số lượng PO còn lại chưa nhập kho thực tế.
    *   `VINA_EMP`: Danh mục tài khoản người dùng.
        *   `NO_EMP` (`nvarchar(10)`): Mã nhân viên (khóa liên kết tài khoản).
        *   `EMP_STOP` (`char(1)`): Cờ khóa tài khoản/Nghỉ việc (`Y` = Đã nghỉ, `N` = Hoạt động).
    *   `VINA_ORG_CHART_NODE`: Cây sơ đồ tổ chức phòng ban.
        *   `ORG_CHART_NODE_TYPE` (`nvarchar(50)`): Loại nút (`DEPT` = Phòng ban, `EMP` = Nhân viên).
        *   `ORG_CHART_NODE_NAME` (`nvarchar(100)`): Tên hiển thị của phòng ban hoặc nhân viên.
    *   `VINA_WORKFLOW_RELATION`: Nhật ký phê duyệt thực tế của biểu mẫu.
        *   `NO_EMP_APPROVER` (`nvarchar(10)`): Mã nhân viên sếp ký duyệt.
        *   `APPROVAL_STATE` (`varchar(20)`): Kết quả duyệt bước (`APPROVED`, `REJECTED`, `PENDING`).
    *   `VINA_PROD_MONTH_PRODPLAN`: Kế hoạch sản xuất tháng.
        *   `BOM_VERSION` (`nvarchar(10)`): Phiên bản BOM chạy (bắt buộc cấu hình = `2001` cho nhà máy VN).

---

### 2.9. VINATECH_POP — Point Of Production Terminal Gateway
*   **Vai trò nghiệp vụ:** Cơ sở dữ liệu kiosk đầu cuối tại xưởng, quản lý cấu hình card mạng MAC xác thực trạm, cấu hình file log PLC máy móc, định tuyến ép buộc quét vật tư phụ theo công đoạn và map thiết bị với lệnh ngày.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `VINA_PC_MAC`: Ánh xạ MAC card mạng máy trạm xưởng.
        *   `PC_MAC_ADDRESS` (`varchar(50)`): Địa chỉ MAC vật lý của kiosk.
        *   `EQUIPMENT_SETTING_IDS` (`varchar(1000)`): Danh sách mã máy được PC này điều khiển (cách nhau bằng dấu phẩy).
        *   `EQUIPMENT_SETTING_JSON` (`varchar(max)`): Cấu hình thiết bị chi tiết dạng JSON nạp trực tiếp vào ứng dụng POP Client.
    *   `VINA_EQUIPMENT_SETTING`: Thông số giao tiếp thu thập dữ liệu PLC.
        *   `EQUIPMENT_SETTING_FILENAME_DATA_PATTERN` (`varchar(200)`): Biểu thức Regex lọc file log PLC (ví dụ: `^OCV_.*\.log$`).
        *   `EQUIPMENT_SETTING_TEMPERATURE` / `_STEAM_TEMPERATURE` (`varchar(50)`): Ngưỡng giới hạn nhiệt độ cảnh báo.
    *   `VINA_BOM_INPUT_ROUTE`: Ràng buộc quét nguyên vật liệu đầu công đoạn.
        *   `MATERIAL_CODE` (`nvarchar(50)`): Mã thành phẩm chính.
        *   `SUB_MATERIAL_CODE` (`nvarchar(50)`): Mã vật tư phụ cần quét chặn lỗi.
        *   `INPUT_ROUTE_CODE` (`nvarchar(20)`): Công đoạn (Route) ép buộc công nhân phải quét mã vật tư phụ này.
    *   `VINA_EQUIPMENT_MAPPING`: Gán máy móc vật lý chạy cho Lệnh ngày.
        *   `DAY_PLAN_NO` (`nvarchar(50)`): Mã kế hoạch ngày từ MES.
        *   `MAPPING_STATUS` (`nvarchar(20)`): Trạng thái máy (`ACTIVE` = Đang chạy, `RELEASED` = Đã giải phóng).

---

### 2.10. VINATECH_RESTFUL — Single Sign-On (SSO) & RESTful API Gateway
*   **Vai trò nghiệp vụ:** Cổng xác thực tập trung một lần (SSO) cho toàn bộ hệ sinh thái phần mềm nội bộ Vinatech. Lưu trữ và kiểm tra hiệu lực Token của client, thống kê lượt truy cập và whitelist IP.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `VINA_SSO_TOKEN`: Quản lý Access Token hoạt động.
        *   `SSO_TOKEN_CODE` (`varchar(400)`): Chuỗi JWT Access Token gửi kèm header các request.
        *   `ID_USER` / `CD_COMPANY` (`nvarchar`): Tài khoản và công ty được cấp phiên làm việc.
        *   `SSO_TOKEN_CLIENT_IP` (`nvarchar(50)`): Địa chỉ IP máy trạm gửi request.
    *   `VINA_SSO_LOGIN`: Thống kê tần suất đăng nhập hàng ngày.
        *   `SSO_LOGIN_COUNT` (`int`): Số lần đăng nhập trong ngày của tài khoản.
        *   `SSO_LOGIN_REG_DATE` (`datetime`): Thời điểm đăng nhập lần đầu trong ngày.
    *   `VINA_ALLOWED_IP`: Whitelist IP máy chủ được gọi dịch vụ RESTful API bảo mật.

---

### 2.11. VINATECH_SPREADSHEET — Web Collaborative Spreadsheet
*   **Vai trò nghiệp vụ:** Cơ sở dữ liệu bảng tính Excel trực tuyến tích hợp trong Groupware, phục vụ cộng tác thời gian thực. Lưu dữ liệu dưới dạng JSON cấu trúc lớn để tối ưu tài nguyên lưu trữ và hiển thị.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `VINA_SPREAD_SHEET`: Metadata bảng tính.
        *   `SPREAD_SHEET_CHANNEL` (`varchar(500)`): ID/Kênh định danh duy nhất của bảng tính.
        *   `SPREAD_SHEET_FILE_NAME` (`nvarchar(500)`): Tên file hiển thị (ví dụ: `Ke_hoach_tuan_BG.xlsx`).
    *   `VINA_SPREAD_SHEET_JSON`: Nội dung ô dữ liệu vật lý.
        *   `SPREAD_SHEET_JSON` (`nvarchar(max)`): Toàn bộ cấu trúc ô, giá trị, công thức, màu sắc định dạng được lưu trữ dưới dạng một chuỗi văn bản JSON khổng lồ.
    *   `VINA_SPREAD_SHEET_PERMISSIONS`: Phân quyền thao tác chi tiết.
        *   `SPREAD_SHEET_PERMISSIONS_READ` / `_WRITE` / `_APPROVAL` / `_EXPORT` (`char(1)`): Cờ phân quyền Đọc, Ghi, Phê duyệt, và Xuất file Excel (`Y`/`N`).
    *   `VINA_SPREAD_SHEET_OPEN`: Khóa Concurrency chống ghi đè dữ liệu.
        *   `NO_EMP` / `CD_COMPANY` / `SPREAD_SHEET_OPEN_REG_DATE`: Ai đang mở chỉnh sửa bảng tính lúc nào để hệ thống khóa quyền ghi của người thứ hai.

---

### 2.12. VINATECH_WEBSOCKET — WebSocket Real-time Alert Router
*   **Vai trò nghiệp vụ:** Cấu hình cổng kết nối và các module dịch vụ truyền thông thời gian thực song song TCP, phục vụ đẩy thông báo Toast báo động hoặc Andon tức thời xuống nhà xưởng.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `VINA_MODULE`: Khai báo các module WebSocket dịch vụ hoạt động.
        *   `MODULE_CODE` (ví dụ: `WS_ANDON` cho Tivi Andon, `WS_NOTICE` cho thông báo đẩy Groupware).
    *   `VINA_STATIC_DATA`: Lưu cấu hình tham số mạng của WebSocket Server.
        *   `CODE` / `VALUE` (ví dụ: `WS_PORT` = `8085`, `HEARTBEAT_TIMEOUT` = `30`).

---

### 2.13. WCMS_STANDARD_NEW — Cash Management System (CMS)
*   **Vai trò nghiệp vụ:** Tự động hóa kết nối tài chính với các ngân hàng liên kết, cào sao kê số dư giao dịch thời gian thực và tự động tạo bút toán nợ/có đồng bộ sang ERP `NEOE`.
*   **Bảng nghiệp vụ cốt lõi:**
    *   `WCMS_ACCOUNT_TRNX_LOG`: Lịch sử sao kê chi tiết tiền vào/ra từ ngân hàng.
        *   `ACCOUNT_TRNX_LOG_UUID` (`nvarchar(40)`): ID duy nhất của bản ghi sao kê.
        *   `ACCOUNT_NO` (`nvarchar(100)`): Số tài khoản ngân hàng phát sinh giao dịch.
        *   `IN_AMOUNT` / `OUT_AMOUNT` (`numeric`): Số tiền ghi Có (vào) / Số tiền ghi Nợ (ra).
        *   `BALANCE` (`numeric`): Số dư tài khoản sau giao dịch.
        *   `ERP_FLAG` (`nchar(1)`): Cờ đồng bộ sang ERP (`Y` = Đã đồng bộ, `N` = Chưa đồng bộ).
        *   `ERP_TX_MSG` (`nvarchar(200)`): Kết quả đồng bộ hoặc thông báo lỗi từ ERP.
    *   `WCMS_CARD`: Danh mục quản lý thẻ tín dụng doanh nghiệp cấp cho nhân sự.
        *   `CARD_NO` (`nvarchar(100)`): Số thẻ (được mã hóa/che ký tự).
        *   `USER_UUID` (`nvarchar(40)`): Nhân viên được giao sử dụng thẻ.
        *   `ERP_CODE` (`nvarchar(20)`): Mã thẻ tương ứng khai báo trong ERP.
    *   `WCMS_BIZ_PARTNER_ACCOUNT`: Tài khoản ngân hàng thụ hưởng của nhà cung cấp phục vụ chuyển khoản Firm Banking tự động.
        *   `BIZ_PARTNER_UUID` (`nvarchar(40)`): Mã liên kết đối tác (Vendor Code trên ERP).
        *   `ACCOUNT_NO` / `OWNER_NAME` (`nvarchar`): Số tài khoản và tên chủ tài khoản thụ hưởng.

---

## 🔗 3. Các Luồng Nghiệp Vụ Liên Thông Nghiệp Vụ Cốt Lõi (Multi-DB Workflows)

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

Dưới đây là cẩm nang tích hợp tối thượng giải thích cách từng biểu mẫu (Form) trên Groupware vận hành, tác động đến cơ sở dữ liệu nào, ánh xạ xuống màn hình MES nào và cung cấp câu lệnh SQL truy vấn đối soát thực tế:

### 9.1. Đơn Yêu Cầu Mua Sắm (PR / Expense Report)
*   **Mã Form ID:** `expenseReportDocument` hoặc `purchaseRequestDocument`
*   **Vận hành của User:** Người dùng đề xuất mua sắm nguyên vật liệu, thiết bị hoặc thanh toán dịch vụ. Chọn đồng tiền giao dịch, nhập tổng số tiền và đính kèm báo giá.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE` (Header chung, trạng thái duyệt).
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHASE_REQUEST` (Chi tiết danh mục yêu cầu mua).
    *   `NEOE.dbo.PU_PRH` (Header yêu cầu mua trên ERP) & `PU_PRL` (Line chi tiết).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình:* Mua hàng trên Groupware không có màn hình MES trực tiếp ở giai đoạn này.
    *   *Stored Procedure:* `usp_SyncPurchaseRequest` (đồng bộ PR từ Groupware sang ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        GW_S.DOCUMENT_SAVE_CODE AS [GW Code],
        GW_S.DOCUMENT_SAVE_SUBJECT AS [Subject],
        GW_S.DOCUMENT_SAVE_STATE AS [State],
        ERP_H.NO_PR AS [ERP PR No],
        ERP_L.CD_ITEM AS [Item Code],
        ERP_L.QT_PR AS [Qty Requested]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE GW_S WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHASE_REQUEST GW_R WITH(NOLOCK)
        ON GW_S.DOCUMENT_SAVE_CODE = GW_R.DOCUMENT_SAVE_CODE
    LEFT JOIN NEOE.dbo.PU_PRH ERP_H WITH(NOLOCK)
        ON GW_S.DOCUMENT_SAVE_CODE = ERP_H.NO_PR -- Mã document map sang số phiếu PR ERP
    LEFT JOIN NEOE.dbo.PU_PRL ERP_L WITH(NOLOCK)
        ON ERP_H.NO_PR = ERP_L.NO_PR
    WHERE GW_S.DOCUMENT_SAVE_CODE = 'MÃ_YÊU_CẦU_MUA_GW';
    ```

---

### 9.2. Đơn Đặt Hàng (Purchase Order - PO)
*   **Mã Form ID:** `purchaseOrderDocument`
*   **Vận hành của User:** Nhân viên thu mua tạo đơn PO với nhà cung cấp, liên kết với PR đã duyệt, chọn đơn giá, thuế VAT, BOM phiên bản 2001 và kho nhận dự kiến.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_POH` (PO Header) & `VINA_DOCUMENT_POL` (PO Lines).
    *   `NEOE.dbo.PU_POH` (ERP PO Header) & `PU_POL` (ERP PO Lines).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **B310** (PO Info - Giám sát tiến độ đơn hàng sản xuất).
    *   *Stored Procedure:* `usp_GetPurchaseOrderList` (load PO lên màn hình MES B310).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        POH.NO_PO AS [PO No],
        POL.CD_ITEM AS [Item Code],
        POL.QT_PO AS [Qty Ordered],
        POL.DOCUMENT_POL_REMAIN_QT_PO AS [Qty Remaining],
        -- Kiểm tra xem MES B310 có truy vấn được PO này không
        (SELECT COUNT(*) FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK) WHERE PONo = POH.NO_PO) AS [MES PO Record Count]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_POH POH WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_POL POL WITH(NOLOCK)
        ON POH.DOCUMENT_SAVE_CODE = POL.DOCUMENT_SAVE_CODE
    WHERE POH.NO_PO = 'MÃ_PO_CẦN_TRA';
    ```

---

### 9.3. Xác Nhận Hàng Về (Arrival Confirmation)
*   **Mã Form ID:** `arrivalConfirmationDocument`
*   **Vận hành của User:** Khi xe chở nguyên vật liệu về đến nhà máy, thủ kho lập phiếu báo hàng về, ghi nhận số lượng thực tế giao, số thông quan, số lượng in tem nhãn và đẩy thông báo cho QC.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H` & `_L`.
    *   `SmartFactoryV2.dbo.STB_MaterialDocInfo` (Tài liệu tiếp nhận kho) & `STB_MaterialDocDetail`.
    *   `SmartFactoryV2.dbo.STB_MaterialLotInfo` (Sinh mã Lot tạm dạng `ML...`).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **F330** (Goods Receipt - Nhận hàng hiện trường và in tem).
    *   *Stored Procedure:* `usp_WarehouseDelivery_get` (lấy dữ liệu Arrival lên lưới F330), `usp_DoCreateMaterialLot` (sinh tem nhãn Lot ID).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        ARR_H.DOCUMENT_SAVE_CODE AS [Arrival Doc],
        ARR_L.CD_ITEM AS [Item Code],
        ARR_L.QT_RECEIVING_PHYSICAL AS [Arrival Qty],
        -- Kiểm tra chứng từ tiếp nhận tương ứng dưới MES
        MDI.MaterialDocNo AS [MES Doc No],
        MDI.InOutType AS [Doc Type], -- Thường là 'In'
        MLI.LotID AS [Generated LotID],
        MLI.InitialQty AS [Lot Qty]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H ARR_H WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_L ARR_L WITH(NOLOCK)
        ON ARR_H.DOCUMENT_SAVE_CODE = ARR_L.DOCUMENT_SAVE_CODE
    LEFT JOIN SmartFactoryV2.dbo.STB_MaterialDocInfo MDI WITH(NOLOCK)
        ON ARR_H.DOCUMENT_SAVE_CODE = MDI.MaterialDocNo
    LEFT JOIN SmartFactoryV2.dbo.STB_MaterialLotInfo MLI WITH(NOLOCK)
        ON MDI.MaterialDocNo = MLI.MaterialDocNo AND ARR_L.CD_ITEM = MLI.MaterialCode
    WHERE ARR_H.DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_ARR_GW';
    ```

---

### 9.4. Xác Nhận Nhập Kho (Receiving Confirmation)
*   **Mã Form ID:** `receivingConfirmationDocument`
*   **Vận hành của User:** Sau khi QC kiểm tra chất lượng và đánh giá đạt (**PASS**), nhân viên mua hàng lập phiếu nhập kho chính thức trên Groupware, chỉ chọn những Lot đã PASS QC để cộng tồn kho chính thức.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_PU_RCVH` (GR Header) & `VINA_DOCUMENT_PU_RCVL` (GR Lines).
    *   `SmartFactoryV2.dbo.STB_MaterialLotInfo` (Cập nhật cột `CurrentQty` chính thức).
    *   `NEOE.dbo.PU_RCVH` & `PU_RCVL` (Chứng từ nhập kho hạch toán ERP).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* Kho vật lý MES cập nhật số lượng tồn kho tự động.
    *   *Stored Procedure:* `usp_DoApplyIncomingQty` (cộng tồn kho MES và trigger đồng bộ sang ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        RCV.DOCUMENT_SAVE_CODE AS [GW GR Code],
        RCVL.CD_ITEM AS [Item Code],
        RCVL.QTY_RCV AS [Qty Received],
        -- Đối chiếu tồn kho thực tế trong MES
        (SELECT SUM(CurrentQty) FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) 
         WHERE MaterialDocNo = RCV.DOCUMENT_SAVE_CODE AND MaterialCode = RCVL.CD_ITEM) AS [MES Current Stock],
        -- Đối chiếu ERP nhập kho hạch toán
        (SELECT SUM(QT_RCV) FROM NEOE.dbo.PU_RCVL WITH(NOLOCK) 
         WHERE NO_RCV = RCV.DOCUMENT_SAVE_CODE AND CD_ITEM = RCVL.CD_ITEM) AS [ERP Stock Added]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_PU_RCVH RCV WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_PU_RCVL RCVL WITH(NOLOCK)
        ON RCV.DOCUMENT_SAVE_CODE = RCVL.DOCUMENT_SAVE_CODE
    WHERE RCV.DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_RCV_GW';
    ```

---

### 9.5. Sổ Quyết Toán Mua Hàng (Purchase Resolution)
*   **Mã Form ID:** `purchaseResolutionDocument`
*   **Vận hành của User:** Kế toán viên lập quyết toán chi phí mua hàng, phân bổ tài khoản chi phí định khoản, gán mã thuế suất và quyết toán cước vận tải logistics đi kèm.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION` & `_LINE`.
    *   `NEOE.dbo.FI_DOCU` (ERP Slip Header) & `FI_DOCU_D` (ERP Slip Lines).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình:* Đây là nghiệp vụ tài chính thuần túy, không tác động màn hình MES.
    *   *Stored Procedure:* `usp_DoCreateAccountingSlip` (sinh bút toán sang sổ cái ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        PR.DOCUMENT_SAVE_CODE AS [GW Resolution Code],
        PR.PAYMENT_DATE AS [Scheduled Payment],
        PRL.CD_ACCT AS [Expense Account],
        PRL.AM AS [Amount VND],
        -- Tra cứu bút toán tương ứng trong ERP
        FD.NO_DOCU AS [ERP Slip No],
        FD.CD_ACCT AS [ERP Account Code],
        FD.AM_DR AS [ERP Debit],
        FD.AM_CR AS [ERP Credit]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION PR WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION_LINE PRL WITH(NOLOCK)
        ON PR.DOCUMENT_SAVE_CODE = PRL.DOCUMENT_SAVE_CODE
    LEFT JOIN NEOE.dbo.FI_DOCU_D FD WITH(NOLOCK)
        ON PR.DOCUMENT_SAVE_CODE = FD.NO_IS -- Link qua cột Interface
    WHERE PR.DOCUMENT_SAVE_CODE = 'MÃ_QUYẾT_TOÁN_GW';
    ```

---

### 9.6. Đơn Xin Nghỉ Việc (Employee Retire Document)
*   **Mã Form ID:** `empRetireDocument`
*   **Vận hành của User:** Nhân viên lập đơn xin thôi việc, xác định ngày làm việc cuối cùng, đăng ký bàn giao tài sản thiết bị và tài liệu công việc.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_EMP_RETIRE` & `_CHECKLIST`.
    *   `NEOE.dbo.MA_EMP` (Cập nhật cột trạng thái `CD_INCOM = '099'`).
    *   `SmartFramework.dbo.STB_UserInfo` (Cập nhật `AllowFlag = 'Deny'`).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **Z410** (User Configuration - Phân quyền và trạng thái người dùng).
    *   *Stored Procedure:* `usp_DoGUILogin` (tự động kiểm tra trạng thái và chặn đăng nhập).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        R.DOCUMENT_SAVE_CODE AS [GW Doc],
        R.NO_EMP AS [Employee ID],
        R.DT_RETIRE AS [Retire Date],
        -- Kiểm tra trạng thái tài khoản trên ERP
        E.CD_INCOM AS [ERP Incom Code], -- '099' đại diện cho nghỉ việc
        -- Kiểm tra trạng thái trên MES SmartFramework
        U.UserID AS [MES UserID],
        U.AllowFlag AS [MES Allow Status] -- 'Deny' đại diện cho bị khóa
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_EMP_RETIRE R WITH(NOLOCK)
    LEFT JOIN NEOE.dbo.MA_EMP E WITH(NOLOCK)
        ON R.NO_EMP = E.NO_EMP
    LEFT JOIN SmartFramework.dbo.STB_UserInfo U WITH(NOLOCK)
        ON R.NO_EMP = U.Appendix8 -- Appendix8 chứa mã nhân viên ERP
    WHERE R.NO_EMP = 'MÃ_NHÂN_VIÊN_NGHỈ';
    ```

---

### 9.7. Đi Làm Ngày Nghỉ / Lễ (Holiday Work Request)
*   **Mã Form ID:** `holidayWorkRequest`
*   **Vận hành của User:** Đăng ký tăng ca ngày chủ nhật hoặc ngày lễ. Sau khi hoàn thành, nhân viên cập nhật số giờ thực tế làm việc để gửi duyệt ngày công.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_HOLIDAY_WORK`.
    *   `SmartFactoryV2.dbo.STB_VN_ATTENDANCE_TIME` (Ghi nhận giờ công tích lũy).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* Chấm công tự động qua máy quét vân tay.
    *   *Stored Procedure:* `usp_SyncFingerData` (quét chấm công và đồng bộ giờ làm việc).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        HW.DOCUMENT_SAVE_CODE AS [GW Doc],
        HW.NO_EMP AS [Employee ID],
        HW.WORK_DATE AS [Date],
        HW.ACTUAL_WORK_HOURS AS [GW Overtime Hours],
        -- Kiểm tra bảng chấm công thực tế của MES
        AT.WorkHours AS [MES Work Hours],
        AT.OvertimeHours AS [MES Overtime Hours],
        AT.CreateDateTime AS [Log Time]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_HOLIDAY_WORK HW WITH(NOLOCK)
    LEFT JOIN SmartFactoryV2.dbo.STB_VN_ATTENDANCE_TIME AT WITH(NOLOCK)
        ON HW.NO_EMP = AT.WorkerCode AND HW.WORK_DATE = AT.JobDate
    WHERE HW.NO_EMP = 'MÃ_NHÂN_VIÊN' AND HW.WORK_DATE = '2026-06-12';
    ```

---

### 9.8. Đăng Ký Đơn Bán Hàng (Sales Order / Suju)
*   **Mã Form ID:** `salesOrderDocument`
*   **Vận hành của User:** Nhân viên kinh doanh đăng ký đơn hàng chính thức từ đối tác, điền thông tin Incoterms, đồng tiền, đơn giá bán và số lượng đặt hàng.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_SALES_ORDER` & `_LINE`.
    *   `NEOE.dbo.SA_SOH` (ERP Suju Header) & `SA_SOL` (ERP Suju Lines).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình:* Đơn hàng được đẩy sang ERP và tự động khởi tạo Month Production Plan.
    *   *Stored Procedure:* `usp_SyncSalesOrder` (đồng bộ đơn hàng Suju sang ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        SO.NO_SO AS [ERP SO No],
        SOL.CD_ITEM AS [Product Code],
        SOL.QT_SO AS [Qty Ordered],
        -- Kiểm tra đơn hàng bán tương ứng trên ERP
        ERP_H.NO_SO AS [ERP Voucher SO],
        ERP_L.QT_SO AS [ERP SO Qty]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SALES_ORDER SO WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_SALES_ORDER_LINE SOL WITH(NOLOCK)
        ON SO.DOCUMENT_SAVE_CODE = SOL.DOCUMENT_SAVE_CODE
    LEFT JOIN NEOE.dbo.SA_SOH ERP_H WITH(NOLOCK)
        ON SO.NO_SO = ERP_H.NO_SO
    LEFT JOIN NEOE.dbo.SA_SOL ERP_L WITH(NOLOCK)
        ON ERP_H.NO_SO = ERP_L.NO_SO AND SOL.CD_ITEM = ERP_L.CD_ITEM
    WHERE SO.NO_SO = 'MÃ_SUJU_CẦN_TRA';
    ```

---

### 9.9. Yêu Cầu Xuất Hàng (Shipment Request)
*   **Mã Form ID:** `deliverOutDocument`
*   **Vận hành của User:** Khi hàng thành phẩm OQC đạt chất lượng, nhân viên logistics lập phiếu yêu cầu xuất hàng, ghi nhận số lượng và chọn hóa đơn xuất khẩu đính kèm.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION_IV` & `_LINE`.
    *   `NEOE.dbo.SA_GIRH` (ERP Issue Header) & `SA_GIRL` (ERP Issue Lines).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **FG01** (PDA Xuất kho thành phẩm - Quét mã thùng Box Packing ID).
    *   *Stored Procedure:* `usp_GetShipmentRequestList` (load danh sách yêu cầu xuất hàng lên PDA).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        SR.DOCUMENT_SAVE_CODE AS [GW Request Code],
        SR.CD_PARTNER AS [Customer Code],
        SRL.CD_ITEM AS [Item Code],
        SRL.QT_REQUEST AS [Qty Requested],
        -- Kiểm tra phiếu yêu cầu xuất kho hạch toán tương ứng ở ERP
        GIR.NO_GIR AS [ERP GIR No],
        GIR.CD_PARTNER AS [ERP Customer],
        GIL.QT_GIR AS [ERP GIR Qty]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION_IV SR WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION_IV_LINE SRL WITH(NOLOCK)
        ON SR.DOCUMENT_SAVE_CODE = SRL.DOCUMENT_SAVE_CODE
    LEFT JOIN NEOE.dbo.SA_GIRH GIR WITH(NOLOCK)
        ON SR.DOCUMENT_SAVE_CODE = GIR.NO_GIR
    LEFT JOIN NEOE.dbo.SA_GIRL GIL WITH(NOLOCK)
        ON GIR.NO_GIR = GIL.NO_GIR AND SRL.CD_ITEM = GIL.CD_ITEM
    WHERE SR.DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_YÊU_CẦU_XUẤT';
    ```

---

### 9.10. Xác Nhận Thực Xuất (Shipment Confirmation)
*   **Mã Form ID:** `deliverOutConfirmationDocument`
*   **Vận hành của User:** Bốc xếp hàng lên Container thực tế, in tem Pallet và quét dán nhãn pallet xe, nhập số tờ khai hải quan và số vận đơn Bill of Lading để kế toán ghi nhận doanh thu.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION`.
    *   `SmartFactoryV2.dbo.STB_SetInfo` (Ghi nhận gộp Pallet và trừ tồn kho vật lý).
    *   `NEOE.dbo.MM_GI_LINE` (Trừ tồn kho thành phẩm thực tế hạch toán ERP).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **B750** (Pallet Label - In tem nhãn Pallet), **B752** (Container Monitor - Giám sát bốc cont).
    *   *Stored Procedure:* `usp_DoApplyRealShipment` (trừ tồn kho MES và trigger xuất hàng thực tế lên ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        SC.DOCUMENT_SAVE_CODE AS [GW Confirm Code],
        SC.NO_CUSTOMS AS [Customs Declaration],
        SC.NO_BL AS [B/L Number],
        -- Kiểm tra Pallet đã được quét đóng niêm phong trong MES chưa
        (SELECT COUNT(DISTINCT Barcode) FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
         WHERE PONo = SC.DOCUMENT_SAVE_CODE) AS [Pallets Loaded in MES],
        -- Kiểm tra trừ kho hạch toán trên ERP
        (SELECT SUM(QT_GI) FROM NEOE.dbo.MM_GI_LINE WITH(NOLOCK) 
         WHERE NO_IS = SC.DOCUMENT_SAVE_CODE) AS [ERP Outbound Qty]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION SC WITH(NOLOCK)
    WHERE SC.DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_XÁC_NHẬN_XUẤT';
    ```

---

### 9.11. Chỉ Thị Sản Xuất Ngày (Daily Production Order)
*   **Mã Form ID:** `dailyProductionOrderDocument`
*   **Vận hành của User:** Lập lịch ngày sản xuất, phân bổ Line máy chạy, Ca làm việc, ngày bắt đầu chạy và số lượng chỉ thị chi tiết.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PRODUCTION_ORDER` & `_LOT`.
    *   `SmartFactoryV2.dbo.STB_DayProdPlan` (Mở ca sản xuất ngày trên MES).
    *   `SmartFactoryV2.dbo.STB_SetInfo` (Sinh cấu trúc Lot hàng sản xuất).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **B450** (Daily Production Plan - Thiết lập kế hoạch ngày, chia Lot, in tem Lot).
    *   *Stored Procedure:* `usp_SyncDailyProductionPlan` (đồng bộ kế hoạch ngày từ Groupware xuống MES).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        GW_D.DAY_PLAN_NO AS [GW Plan No],
        GW_D.LINE_CODE AS [Line],
        GW_D.WORK_DATE AS [Date],
        GW_D.PLAN_QTY AS [GW Qty],
        -- Đối chiếu kế hoạch sản xuất ngày dưới MES
        MES_D.DayProdPlanNo AS [MES Plan No],
        MES_D.ProdOrderQty AS [MES Qty],
        MES_D.JobState AS [MES State], -- '0' = Đang chốt, '1' = Chạy máy
        -- Kiểm tra số lượng Lot con đã được chia ở MES B450
        (SELECT COUNT(*) FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE DayPlanNo = GW_D.DAY_PLAN_NO) AS [Lots Split Count]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PRODUCTION_ORDER GW_D WITH(NOLOCK)
    LEFT JOIN SmartFactoryV2.dbo.STB_DayProdPlan MES_D WITH(NOLOCK)
        ON GW_D.DAY_PLAN_NO = MES_D.DayProdPlanNo
    WHERE GW_D.DAY_PLAN_NO = 'MÃ_KẾ_HOẠCH_NGÀY_GW';
    ```

---

### 9.12. Báo Cáo Sản Xuất Ngày (Daily Production Report)
*   **Mã Form ID:** `dailyProductionReportDocument`
*   **Vận hành của User:** Báo cáo sản lượng ca kết quả của Line máy, ghi nhận số lượng đầu vào, số lượng lỗi phế, thực tế sản xuất và link với Lot sản phẩm đã in tem.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PRODUCTION_ORDER_LOT` (Cập nhật sản lượng thực tế Lot).
    *   `SmartFactoryV2.dbo.STB_ProdRouteHist` (Lịch sử công đoạn chạy máy).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **B530** (Prod Route Input - Quét ghi nhận sản lượng hoàn thành công đoạn).
    *   *Stored Procedure:* `usp_DoFinishRouteOperation` (chốt công đoạn, cộng sản lượng tốt và ghi nhận lỗi).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        GW_L.LOT_NO AS [Lot/Box No],
        GW_L.PLAN_QTY AS [GW Target Qty],
        GW_L.PROD_QTY AS [GW Actual Qty],
        -- Kiểm tra lịch sử quét máy thực tế tại MES B530
        (SELECT SUM(ProdQty) FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) 
         WHERE ControlNo = SI.ControlNo AND RouteCode = 'GATE_NAME') AS [MES Route Qty],
        SI.IsProdFinish AS [Is MES Lot Finished] -- 1 = Đã chốt sản xuất xong
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PRODUCTION_ORDER_LOT GW_L WITH(NOLOCK)
    LEFT JOIN SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK)
        ON GW_L.LOT_NO = SI.Barcode
    WHERE GW_L.LOT_NO = 'MÃ_LOT_CẦN_TRA';
    ```

---

*Tài liệu được biên soạn và chuẩn hóa dựa trên phân tích trực tiếp cấu trúc của toàn bộ 13 hệ thống cơ sở dữ liệu vật lý tại Vinatech Việt Nam.*



