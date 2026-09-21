# GW_14 — Groupware Database Stored Procedures, Functions & Views Reference

> **Mục tiêu:** Cung cấp tài liệu kỹ thuật chuyên sâu về các Stored Procedure, Hàm (Function) và Khung nhìn (View) thực tế chạy trực tiếp trong CSDL `VINATECH_GROUP`.
> **Cơ sở dữ liệu:** `VINATECH_GROUP` trên máy chủ `dbserver.hycap.co.kr,5398`
> **Mã nguồn đã trích xuất:** Thư mục `PROCESS/GROUPWARE/sql/routines/` và `PROCESS/GROUPWARE/sql/views/`

---

## 🗄️ 1. Danh Mục Stored Procedures & Functions

| Tên Routine | Phân Loại | Mục Đích Nghiệp Vụ | CSDL & Bảng Liên Quan |
| :--- | :--- | :--- | :--- |
| **`usp_DoSyncMaterialUnit_itf_TF`** | Procedure | Đồng bộ thay đổi đơn vị tính vật tư xuyên suốt 4 database khi tỷ lệ quy đổi (`ConvertRate`) thay đổi. | `NEOE.NEOE.MA_PITEM`<br>`SmartFactoryV2.dbo.STB_MaterialMaster`<br>`SmartFactoryV2.dbo.STB_StocktakingDoc`<br>`SmartFramework.dbo.usp_DoCreateSerial` |
| **`usp_DoCreateEmployeeSalary`** | Procedure | Khởi tạo bảng tính lương hàng tháng, lấy dữ liệu nhân viên từ ERP và gọi thủ tục tính lương. | `NEOE.NEOE.HR_PCALCPAY`<br>`VINATECH_GROUP.dbo.VINA_SALARY_INFO`<br>`NEOE.NEOE.VinatechPayment_GW` |
| **`UP_HR_WTMCALC_TIME_CALC`** | Procedure | Động cơ tính toán giờ làm việc thực tế (WTM - Working Time Management): ca kíp, đi muộn, về sớm, tăng ca, làm đêm, làm ngày nghỉ. (Dài 468 dòng) | `VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE`<br>`NEOE.NEOE.HR_WTM_*` |
| **`UP_HR_WTMCALC_TIME_CALC1`** | Procedure | Biến thể tính toán giờ công ca đặc thù 1. | `VINATECH_GROUP`, `NEOE` |
| **`UP_HR_WTMCALC_TIME_CALC2`** | Procedure | Biến thể tính toán giờ công ca đặc thù 2. | `VINATECH_GROUP`, `NEOE` |
| **`UP_HR_WTMCALC_TIME_CALC3`** | Procedure | Biến thể tính toán giờ công ca đặc thù 3. | `VINATECH_GROUP`, `NEOE` |
| **`GETTABLEFROMSPLIT`** | Function | Phân tách chuỗi ký tự phân cách (delimiter) thành bảng dữ liệu tạm phục vụ xử lý chuỗi ID/Mã. | Dùng nội bộ trong các báo cáo Groupware |

---

## 🔬 2. Chi Tiết Kỹ Thuật Các Stored Procedure Lõi

### 2.1 Cầu Nối Thay Đổi Đơn Vị Vật Tư: `usp_DoSyncMaterialUnit_itf_TF`
- **Mã nguồn:** `sql/routines/usp_DoSyncMaterialUnit_itf_TF.sql`
- **Tham số đầu vào:**
  - `@pProcessLanguage`: Mã ngôn ngữ (`KR`/`VN`/`EN`)
  - `@pProcessUserID`: Tài khoản thực thi
  - `@pERPCompanyCode`: Mã công ty ERP (`1000` HQ / `2000` VN)
  - `@pMaterialCodeStr`: Mã vật tư cần đồng bộ
  - `@pConvertRate`: Tỷ lệ chuyển đổi số lượng (Kiểu `NUMERIC(38,19)`)
  - `@pMaterialUnit`: Đơn vị tính mới
  - `@pMaterialTypeCode`: Phân loại vật tư mới
- **Luồng logic đột phá:**
  1. Nếu `@ConvertRate = 1`: Trực tiếp `UPDATE SmartFactoryV2.dbo.STB_MaterialMaster` với đơn vị và loại vật tư mới.
  2. Nếu `@ConvertRate <> 1`:
     - Cập nhật đơn vị trên `STB_MaterialMaster`.
     - Quét toàn bộ các kho và WorkCenter đang có tồn kho của mã vật tư đó qua `STB_MaterialLotInfo`.
     - Tự động sinh số kiểm kê vật tư mới: `EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_StocktakingDoc', @StocktakingDocNo OUTPUT`.
     - Chèn chứng từ kiểm kê: `INSERT INTO SmartFactoryV2.dbo.STB_StocktakingDoc`.
     - Sinh kế hoạch kiểm kê: `EXEC SmartFactoryV2.dbo.usp_DoMakeStocktakingPlanResult`.
     - Tự động nhân lại số lượng tồn kho theo tỷ lệ quy đổi: `StocktakingQty = BasicQty * @ConvertRate`.
     - Áp dụng kiểm kê điều chỉnh tồn kho vật lý tức thì: `EXEC SmartFactoryV2.dbo.usp_DoApplyStocktakingToStock`.

### 2.2 Động Cơ Tính Giờ Công WTM: `UP_HR_WTMCALC_TIME_CALC`
- **Mã nguồn:** `sql/routines/UP_HR_WTMCALC_TIME_CALC.sql`
- **Tham số chính:** `@P_DOCUMENT_SAVE_CODE`, `@P_CD_COMPANY`, `@P_YM`, `@P_DT_FROM`, `@P_DT_TO`, `@P_MULTI_EMP`, `@P_MODE`.
- **Cơ chế hoạt động:**
  - Quét từng dòng quẹt thẻ và thời gian vào ra (`@V_출근시간`, `@V_퇴근시간`).
  - Áp dụng dung sai trễ (`TM_TMLIMIT1` đến `TM_TMLIMIT6`) và đơn vị làm tròn giờ (`CD_WTIME1` đến `CD_WTIME6`).
  - Phân tách chính xác thời gian:
    - `@V_정상`: Giờ hành chính chuẩn.
    - `@V_연장조`: Tăng ca trước giờ làm việc.
    - `@V_연장석`: Tăng ca sau giờ làm việc.
    - `@V_야간`: Làm việc ban đêm (22:00 - 06:00).
    - `@V_심야`: Làm việc ca sâu đêm.
    - `@V_지각` & `@V_조퇴`: Số phút đi muộn và về sớm.
  - Kết quả được gắn trực tiếp với mã tờ trình Groupware `@P_DOCUMENT_SAVE_CODE` để phục vụ ký duyệt bảng lương.

---

## 👁️ 3. Chi Tiết Kỹ Thuật 4 Khung Nhìn (Views)

### 3.1 Cầu Nối Chứng Từ Groupware ↔ ERP: `VINA_DOCUMENT_ERP_DOCU_INFO_VIEW`
- **Mã nguồn:** `sql/views/VINA_DOCUMENT_ERP_DOCU_INFO_VIEW.sql`
- **Bản chất kỹ thuật:** Đây là View mấu chốt để hệ thống Groupware tra cứu ngược xem một tờ trình đã sinh số chứng từ kế toán ERP nào:
  ```sql
  -- Nhánh 1: Chi phí nhập khẩu
  SELECT TI.CD_COMPANY, NULL AS NO_DOCU, -1 AS NO_DOLINE, TI.NO_COST, NULL AS NO_IV, 
         PRL.DOCUMENT_SAVE_CODE, DS.RECORD_INCREASE_CODE, DS.DOCUMENT_TYPE_ID
  FROM VINA_DOCUMENT_TR_IMCOSTH TI ...

  -- Nhánh 2: Hóa đơn quyết toán mua hàng
  SELECT PRH.CD_COMPANY, NULL AS NO_DOCU, -1 AS NO_DOLINE, NULL AS NO_COST, PRH.NO_IV, ...
  FROM VINA_DOCUMENT_PURCHAE_RESOLUTION PRH ...

  -- Nhánh 3: Khớp chứng từ kế toán FI_DOCU qua chuỗi (ED-...)
  SELECT DS.CD_COMPANY_WRITER AS CD_COMPANY, 
         ISNULL(DCD.NO_DOCU, DC.NO_DOCU) AS NO_DOCU,
         ISNULL(DCD.NO_DOLINE, DC.NO_DOLINE) AS NO_DOLINE, ...
  FROM VINA_DOCUMENT_SAVE DS
  LEFT JOIN NEOE.NEOE.FI_DOCU DC ON 
       DC.NM_PUMM IS NOT NULL AND CHARINDEX('(ED-', DC.NM_PUMM) > 0
       AND REPLACE(SUBSTRING(DC.NM_PUMM, LEN(DC.NM_PUMM) - 18, LEN(DC.NM_PUMM)), ')', '') = DS.RECORD_INCREASE_CODE
  ```
- **Ý nghĩa vận hành:** Khi kế toán hoặc quản trị viên mở một tờ trình trên Groupware, view này tự động quét `NEOE.NEOE.FI_DOCU` tìm mã ghi chú `(ED-XXXXXXXXXXXXXX)` để hiển thị số chứng từ ERP (`NO_DOCU`) và dòng chi tiết (`NO_DOLINE`) ngay trên màn hình.

### 3.2 Chuỗi Phả Hệ Văn Bản Liên Kết: `VINA_DOCUMENT_RELATION_STUFF_VIEW`
- **Mã nguồn:** `sql/views/VINA_DOCUMENT_RELATION_STUFF_VIEW.sql`
- **Bản chất kỹ thuật:** Sử dụng hàm gộp chuỗi XML `STUFF((... FOR XML PATH('')), 1, 1, '')`:
  ```sql
  STUFF((
      SELECT DISTINCT ',' + DSS.DOCUMENT_SAVE_CODE + '#'+ DSS.DOCUMENT_TYPE_ID + '#' + DSS.RECORD_INCREASE_CODE
      FROM VINA_DOCUMENT_SAVE_RELATION AS DSR WITH(NOLOCK)
      INNER JOIN VINA_DOCUMENT_SAVE AS DSS WITH(NOLOCK)
          ON DSS.DOCUMENT_SAVE_CODE = DSR.DOCUMENT_SAVE_RELATION_CODE 
          AND DSR.DOCUMENT_SAVE_CODE = DSRM.DOCUMENT_SAVE_CODE 
      FOR XML PATH('')
  ), 1, 1, '') AS RELATION_RECORD_INCREASE_CODE
  ```
- **Ý nghĩa:** Trả về toàn bộ danh sách các tờ trình cha/con theo chuỗi liên kết phân tách bằng dấu phẩy, giúp truy vết tức thì: `Expense Report # PO # Arrival # Receiving # Purchase Resolution`.

### 3.3 Động Cơ Trạng Thái Phê Duyệt Tuyến: `VINA_DOCUMENT_APPROVAL_SAVE_VIEW`
- **Mã nguồn:** `sql/views/VINA_DOCUMENT_APPROVAL_SAVE_VIEW.sql`
- **Bản chất kỹ thuật:** View tổng hợp động trạng thái tuyến phê duyệt:
  - Tính thứ tự người duyệt tiếp theo (`NEXT_APPROVAL_ORDER`): Nếu có bất kỳ ai từ chối (`REJECTED_COUNT > 0`), thứ tự lập tức trả về `-1`.
  - Tự động thay thế người duyệt bằng Người duyệt ủy quyền (Proxy Approver) nếu thời điểm hiện tại nằm trong khoảng `DOCUMENT_PROXY_APPROVAL_START_DATE` đến `DOCUMENT_PROXY_APPROVAL_END_DATE`.
  - Phân loại bước xử lý: Phê duyệt (`STATIC_DATA_000036`), Thỏa thuận/Đồng thuận (`STATIC_DATA_000037`), Tiếp nhận/Tham chiếu (`STATIC_DATA_000038`/`39`), Ký chốt hoàn tất (`STATIC_DATA_000054`).

---

## 🛠️ 4. Hướng Dẫn Truy Vấn Thực Tế

1. **Truy vết chứng từ ERP sinh ra từ một mã tờ trình Groupware:**
   ```sql
   SELECT * FROM VINA_DOCUMENT_ERP_DOCU_INFO_VIEW WITH (NOLOCK)
   WHERE RECORD_INCREASE_CODE = 'ED-VJPMTR000000021' OR DOCUMENT_SAVE_CODE = 'DOCUMENT_SAVE_...';
   ```
2. **Lấy toàn bộ chuỗi văn bản liên đới:**
   ```sql
   SELECT DOCUMENT_SAVE_CODE, RECORD_INCREASE_CODE, RELATION_RECORD_INCREASE_CODE
   FROM VINA_DOCUMENT_RELATION_STUFF_VIEW WITH (NOLOCK)
   WHERE RECORD_INCREASE_CODE = 'ED-VJPMTR000000021';
   ```
3. **Kiểm tra ai đang kẹt duyệt một văn bản:**
   ```sql
   SELECT DOCUMENT_SAVE_CODE, NEXT_APPROVAL_ORDER, NO_EMP, NO_EMP_PROXY
   FROM VINA_DOCUMENT_APPROVAL_SAVE_VIEW WITH (NOLOCK)
   WHERE DOCUMENT_SAVE_CODE = 'DOCUMENT_SAVE_...';
   ```
