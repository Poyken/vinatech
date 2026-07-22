<!--
AI-READY METADATA
Purpose: Sổ tay khắc phục lỗi theo Screen ID phân hệ Sản Xuất (B210-B802, H301-H305, HN523-HN866, K101-K110) - Phần 1
Scope: Production Execution Bug Fixbook Part 1
Single Source of Truth: KB_03_03_SCREEN_BUGS_B.md (Production Bug Fixes Part 1)
Target Screens: B210-B270, B310, B442, B452, B523, B528, B530, B540, B552, B560, B597, B598, B618, B682, B717, B754, B757, B790, B802, B882, H301-H305, HN523, HN544, HN551, HN866, K101, K109, K110
Target Tables: STB_SetInfo, STB_ProdRouteHist, STB_DayProdPlan, STB_DefectInfo, STB_DefectRepairInfo
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_03 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/INDEX.md)
  - [KB_03_02_CELL_LINE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md)
-->

# KB_03_03 — Production Screen Bugs (B-Series Part 1)

> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_03 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/INDEX.md)

---


## [B210] / [B220] / [B230] / [B240] — Production Routing Setup (Thiết lập định tuyến sản xuất)

### [B450] — Lỗi 1: Màn hình không tìm thấy Line sản xuất để tạo Lot
*   **Triệu chứng:** Khi lập kế hoạch ngày tại **B450** để sinh mã Lot cho PO, người dùng không thể chọn được Line sản xuất mong muốn trong dropdown.
*   **Nguyên nhân gốc:** Line sản xuất chưa được kích hoạt (`IsUsed = 0`) tại màn hình đăng ký Line **B210** (`STB_LineInfo`), hoặc cấu hình sai mã nhà máy (`WorkCenterCode`).
*   **Cách khắc phục:** Vào màn hình **B210**, tìm Line tương ứng, kiểm tra và tick chọn cờ `IsUsed`, đảm bảo `WorkCenterCode` khớp với khu vực sản xuất rồi Lưu lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#10-thiết-lập-line--route-b210b220b230b240).

### [B530] — Lỗi 2: Giao diện không hiển thị Máy khi OP scan chốt công đoạn
*   **Triệu chứng:** OP thực hiện quét chốt sản lượng tại **B530** nhưng không hiển thị danh sách thiết bị/máy chạy trong dropdown chọn máy.
*   **Nguyên nhân gốc:** Máy móc chưa được cấu hình phân bổ thuộc công đoạn (RouteCode) đang chạy trong bảng `STB_MachineMaster` (Màn hình **B240**).
*   **Cách khắc phục:** Vào màn hình **B240**, kiểm tra và gán máy móc đang chạy vào đúng công đoạn (RouteCode) tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#10-thiết-lập-line--route-b210b220b230b240).

---


## [B250] / [B270] — Cell / Machine Mapping (Đồng bộ chuyền & máy chạy mới)

### [B270] — Lỗi 1: Popup gán máy trống không hiển thị danh sách thiết bị
*   **Triệu chứng:** Khi bấm vào popup để gán máy chạy cho Route sản xuất ở màn hình **B270**, danh sách máy trống trơn không có bản ghi nào.
*   **Nguyên nhân gốc:** Do Stored Procedure `usp_Set_VVT_Info_get` bị hardcode kiểm tra Whitelist UserID của người thao tác, hoặc cấu hình sai thiết lập máy trong bảng `STB_ProductMachine`.
*   **Cách khắc phục:**
    Sửa đổi SP `usp_Set_VVT_Info_get` để bổ sung thêm UserID của người vận hành hiện tại vào Whitelist, hoặc cập nhật trực tiếp DB:
    ```sql
    -- Thêm điều kiện Whitelist User trong SP
    SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Set_VVT_Info_get'));
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_AND_SCREENS.md § 1.3](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md#13-lỗi-popup-b270-trống-không-hiện-danh-sách-máy).

### Lỗi 2: Cell hoặc Line sản xuất mới thêm không hiển thị hoặc không quét được trên hệ thống
*   **Triệu chứng:** Khi có yêu cầu thêm Cell/Line mới (Ví dụ: `VVBNTC-05`), OP không thể thực hiện các thao tác gán máy hay quét sản lượng ở các công đoạn.
*   **Nguyên nhân gốc:** Cell mới chưa được khai báo đồng bộ đồng thời ở cả 3 bảng master: `STB_LineInfo`, `STB_MachineMaster` (Màn hình **B250**) và `STB_ProductMachine` (Màn hình **B270**).
*   **Cách khắc phục:**
    Chạy SQL đồng bộ trong một Transaction để chèn Line, Machine và liên kết tự động tất cả các Route từ `V-22` đến `V-28`:
    ```sql
    BEGIN TRANSACTION;
    -- 1. Thêm LineInfo
    INSERT INTO STB_LineInfo (LineCode, CompanyCode, WorkCenterCode, LineName, LineDesc, LineType, IsUsed, CreateDateTime, CreateUserID)
    VALUES ('VVBNTC-05', 'VVT', 'VVT_F2', 'BN Manual (P20)', 'Thủ công Bắc Ninh', 'Medium', 1, GETDATE(), 'vinaadmin');
    -- 2. Thêm MachineMaster (B250)
    INSERT INTO STB_MachineMaster (MachineCode, CompanyCode, WorkCenterCode, MachineName, IsProdMachine, MachineTypeCode, IsUsed, CreateDateTime, CreateUserID)
    VALUES ('VVBNTC-05', 'VVT', 'VVT_F2', 'BN Manual (P20)', 1, 'M00001', 1, GETDATE(), 'vinaadmin');
    -- 3. Gán máy vào Route (B270)
    INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode, CreateDateTime, CreateUserID)
    SELECT 'VVBNTC-05', 'VVBNTC-05', r.RouteCode, GETDATE(), 'vinaadmin'
    FROM (
        SELECT 'V-22_BG' AS RouteCode UNION ALL SELECT 'V-23_BG' UNION ALL SELECT 'V-24_BG' UNION ALL
        SELECT 'V-25_BG' UNION ALL SELECT 'V-26_BG' UNION ALL SELECT 'V-27_BG' UNION ALL SELECT 'V-28_BG'
    ) r;
    COMMIT;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 7](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#7-thêm-cellline-mới-b250-b270).

---


## [B260] — Worker Management (Nhân sự sản xuất)

### [B530]/[B540] — Lỗi 1: Tên nhân viên mới không hiển thị trong dropdown chọn nhân viên tại hoặc
*   **Triệu chứng:** Nhân viên đã đăng ký thành công trên MES nhưng OP không tìm thấy tên khi chốt sản lượng.
*   **Nguyên nhân gốc:** Khi khai báo nhân viên, cột mã nhóm nhân viên (`WorkerGroupCode`) bị điền sai (không phải nhóm `VE-01` của nhà máy).
*   **Cách khắc phục:** Vào màn hình **B260**, tìm mã nhân viên, cập nhật lại cột `WorkerGroupCode` chính xác thành `VE-01` rồi nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 12](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#12-b260---thông-tin-nhân-viên-sản-xuất).

---


## [B310] / [B450] — Production Orders & Day Plan (Kế hoạch tháng / ngày)

### Lỗi 1: Lỗi không đồng bộ được lệnh sản xuất (PO) từ Groupware sang MES
*   **Triệu chứng:** Kế hoạch sản xuất đã được lập trên Groupware nhưng thủ kho hoặc OP không thấy hiển thị thông tin PO tại màn hình **B310** hay **B450** trên MES để bắt đầu tạo Lot.
*   **Nguyên nhân gốc:** PO trên Groupware chưa được duyệt trạng thái "Arrival Confirmation", hoặc Windows Service đồng bộ trung gian (ESM Bridge) bị treo/chết, khiến dữ liệu không được đẩy vào bảng trung gian `ESM_DayProdPlan`.
*   **Cách khắc phục:**
    1. Yêu cầu quản lý duyệt PO trên Groupware.
    2. Nếu đã duyệt nhưng vẫn lệch, IT kiểm tra trạng thái Windows Service ESM, hoặc chạy query cưỡng bức đồng bộ thủ công qua ESM Bridge Tables.
*   **Chi tiết nghiệp vụ:** Xem tại ../KB_07/KB_07_01_OVERVIEW_FLOWS.md § 6.

---


## [B418] — Packing Quantity Standards (Quy cách đóng gói theo Size)

### [B523] — Lỗi 1: Popup gộp Box tại báo lỗi "Chưa có tiêu chuẩn đóng gói" do sai lệch kích thước Size
*   **Triệu chứng:** Khi công nhân quét gộp Box tại B523, hệ thống báo lỗi chặn đứng quy trình: `"Chưa có tiêu chuẩn đóng gói"`.
*   **Nguyên nhân gốc:** Kích thước Size của Model (`MBISizeD` lấy từ **A410**) chưa được khai báo số lượng đóng gói định mức (`PackQty`) tương ứng trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:** Vào màn hình **A418**, đăng ký Size mới và thiết lập số lượng đóng gói định mức tương ứng (`PackQty`) rồi nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 11](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#11-a418---số-lượng-đóng-gói-theo-size).

---


## [B442] — Electrode Production Plan (Kế hoạch & in tem điện cực)

### Lỗi 1: Không tạo được kế hoạch hoặc in tem điện cực cho Model mới
*   **Triệu chứng:** Khi lập kế hoạch và in tem điện cực tại **B442**, Model mới không hiển thị hoặc không cho phép in.
*   **Nguyên nhân gốc:** Model chưa được khai báo ở bảng thông tin Model master (**A230**) hoặc thiếu cấu hình công đoạn tương ứng.
*   **Cách khắc phục:** Đăng ký đầy đủ mã Model ở màn hình **A230** trước khi thao tác trên **B442**.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md § 1 (Phần 1)](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#1-lập-kế-hoạch--in-tem-điện-cực-b310-b442-a230).

---


## [B452] — Line Changing (Chuyển Line sản xuất)

### Lỗi 1: Không đổi được Line sản xuất cho Lot sản phẩm
*   **Triệu chứng:** Khi thực hiện đổi chuyền sản xuất cho Lot tại màn hình **B452**, hệ thống báo lỗi không có quyền hoặc chặn không cho lưu.
*   **Nguyên nhân gốc:** Stored Procedure `usp_Vietnam_ChangeProductionOrderRoutingLine_VNT` kiểm soát tính năng này chứa một danh sách Whitelist UserID được hardcode cứng.
*   **Cách khắc phục:**
    ALTER SP `usp_Vietnam_ChangeProductionOrderRoutingLine_VNT` để bổ sung UserID của nhân viên vận hành hiện tại vào danh sách được phép.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.7](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#67-b452-không-đổi-được-line).

---


## [B530] — Route Input / Production Qty Output (Nhập sản lượng công đoạn)

### Lỗi 1: Lỗi cấm Scan nhanh dưới 20 phút (Gate 20 phút) bị lỗi/không chặn được
*   **Triệu chứng:** Hệ thống không thực hiện chặn được việc OP scan chốt công đoạn quá nhanh (dưới 20 phút).
*   **Nguyên nhân gốc:** Lỗi logic so sánh Null trong SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` dòng 218: `IF @SIExtInt01 = Null` (Trong SQL phải dùng `IS NULL`).
*   **Cách khắc phục:**
    ALTER SP sửa lại cú pháp so sánh Null chuẩn: `IF @SIExtInt01 IS NULL`.
*   **Chi tiết nghiệp vụ:** Xem phân tích chi tiết stored procedure tại [../KB_08_CORE_SP_ENGINE.md#gate-20-phút](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md#gate-20-phút).

### Lỗi 2: OP báo lỗi không chốt được công đoạn, báo "Routing không có trong PO" hoặc "Đã hoàn thành thực tế rồi"
*   **Triệu chứng:** OP scan chốt sản lượng tại **B530** hệ thống báo lỗi không chốt được.
*   **Nguyên nhân gốc:** Do bỏ qua công đoạn trước đó chưa scan chốt, hoặc PO cấu hình sai thứ tự RoutingIndex.
*   **Cách khắc phục:**
    IT kiểm tra lịch sử quét Routing của Barcode bằng Golden Query để phát hiện công đoạn bị bỏ qua. Cho OP quay lại scan trạm trước, hoặc chèn dòng Routing giả lập để thông luồng (Xem phương pháp trace tại [Kịch bản 2](#kịch-bản-sự-cố-khẩn-cấp-2-lỗi-không-chốt-được-công-đoạn-b530)).

### [BG1] — Lỗi 3: Thiếu hoặc dư thừa danh mục lỗi (Defect Code) hiển thị tại lưới nhập lỗi của xưởng BN &
*   **Triệu chứng:** Giao diện nhập lỗi của tổ sản xuất Bắc Ninh và Bắc Giang 1 hiển thị các danh mục lỗi cũ đã bãi bỏ (gây nhầm lẫn cho công nhân), hoặc thiếu các mã lỗi mới phát sinh cần theo dõi để quản lý chất lượng tốt hơn.
*   **Nguyên nhân gốc:** Bảng master data danh mục lỗi `STB_DefectInfo` chưa được cập nhật kịp thời theo rà soát thực tế của tổ sản xuất.
*   **Cách khắc phục:**
    1. Vô hiệu hóa 28 lỗi dư thừa bằng cách chạy script update cờ sử dụng về `IsUsed = 0` trên bảng `STB_DefectInfo`:
       ```sql
       UPDATE STB_DefectInfo
       SET IsUsed = 0,
           ChangeDateTime = GETDATE(),
           ChangeUserID = 'vanduc'
       WHERE DefectCode IN ('MÃ_LỖI_1', 'MÃ_LỖI_2', ...);
       ```
    2. Khai báo bổ sung 7 mã lỗi mới bằng cách chạy script `INSERT` vào bảng `STB_DefectInfo` (cho các công đoạn Winding `V-22_BG`, Rubber/riveting `V-23_BG`, Curling `V-24_BG`):
       - `V-22_BM_BG`: Winding_Xocha đen đầu đáy (Winding_Xocha black marks top bottom)
       - `V-23_DV_BG`: Rubber/riveting_Dập vỡ Tancha pan (Rubber/riveting_ATL bent or broke when stamped)
       - `V-23_RD_BG`: Rubber/riveting_Rách đáy xocha khi đưa vào vỏ nhôm (Rubber/riveting_Xocha bottom paper tear)
       - `V-23_XZ3_BG`: Riveting_Thiếu thừa vòng đệm (Riveting_Insufficient or excessive gasket)
       - `V-24_NE6_BG`: Curling_NG thừa thiếu cân nặng (Curling_Overweight or underweight)
       - `V-24_NE7_BG`: Curling_Xước chân tancha (Curling_Lead terminal scrash)
       - `V-24_NE8_BG`: Curling_Lỗi mẻ miệng curling (Curling_Deformation around mouth)
*   **Chi tiết nghiệp vụ:** Xem tại **fix_b530_disable_defects_BG.sql** và **fix_b530_add_defects_BG.sql**.

### 🔬 Phân Tích Core Engine: `usp_DoProcessProdRouteHist` (406 dòng)

> **Đây là SP "tim đập" của toàn bộ hệ thống MES.** Mỗi lần OP quét barcode tại bất kỳ công đoạn nào → SP này được gọi.

#### Tham số đầu vào (20 params)

| Param | Kiểu | Ý nghĩa |
|---|---|---|
| `@pPONo` | VARCHAR(20) | Mã lệnh sản xuất |
| `@pLineCode` | VARCHAR(20) | Mã Line (Cell-01, Module-03...) |
| `@pRouteCode` | VARCHAR(20) | Mã công đoạn (V-22, V-28...) |
| `@pControlNo` | VARCHAR(20) | Mã kiểm soát (= Barcode mapping) |
| `@pProdQty` | NUMERIC(20,5) | Số lượng (default = 1) |
| `@pProcessDateTime` | DATETIME | Thời điểm quét |
| `@pWorkerCode` | VARCHAR(20) | Mã nhân viên |
| `@pMachineCode` | VARCHAR(20) | Mã máy |
| `@pIsCheckBefRouteProdQty` | BIT | Có check SL công đoạn trước không |
| `@pProdRouteHistNo` | VARCHAR(20) **OUTPUT** | Mã lịch sử routing (trả về) |

#### Luồng xử lý 11 bước

```
Bước 1: Đọc PO info (CompanyCode, WorkCenterCode, MaterialCode, RouteIndex)
         FROM STB_ProductionOrderRouting + STB_ProductionOrderInfo
                    ↓
Bước 2: Tính Ca/Ngày tự động
         fnGetJobDateShiftTime(@ProcessDateTime) → @JobDate, @ShiftCode, @TimeCode
                    ↓
Bước 3: GATE — Check Barcode đã nhập chưa (IsLineInput)
         IF IsInputRoute=0 AND IsLineInput=0 → ERROR "Barcode chưa được đưa vào"
                    ↓
Bước 4: GATE — Check SL công đoạn trước (nếu IsCheckBefRouteProdQty=1)
         CurrentRouteQty + ProdQty > BefRouteQty → ERROR "Vượt SL công đoạn trước"
         ⚠️ BYPASS: Route E-28, V-28, V-28_BG, VE10, E-33, E-34, E-29, EM-03, M-06
                    ↓
Bước 5: Kiểm tra trùng lặp (ProdRouteHistNo đã tồn tại?)
         Tìm theo: PONo + LineCode + RouteCode + ControlNo + JobDate + ShiftCode + TimeCode
                    ↓
Bước 6A (INSERT mới): Tạo Serial → Log → Update LineRouteMapping → INSERT ProdRouteHist
         EXEC SmartFramework.dbo.usp_DoCreateSerial → @ProdRouteHistNo
         INSERT INTO STB_ProcedureLog (ghi camera giám sát)
         UPDATE STB_LineRouteMapping (cập nhật Line đang chạy Route nào)
         INSERT INTO STB_ProdRouteHist (18 columns)
                    ↓
Bước 6B (UPDATE cộng dồn): ProdQty = ProdQty + @ProdQty
                    ↓
Bước 7: Tổng hợp sản lượng → EXEC usp_DoProcessProdRouteSummary
                    ↓
Bước 8: ★ BACKFLUSH — Trừ kho NVL theo BOM
         EXEC usp_DoProcessProdGIMaterialByBOM (truyền PONo, MaterialCode, ProdQty)
                    ↓
Bước 9: Nếu IsInputRoute=1 (công đoạn đầu):
         UPDATE STB_SetInfo SET IsLineInput=1, InputDateTime, InputLineCode
         + EXEC usp_VN_UpdateSpecialSparePartLot (DinhManh 2025-06-12)
                    ↓
Bước 10: Nếu IsOutputRoute=1 (công đoạn cuối):
         UPDATE STB_ProductionOrderInfo SET ProdFinishQty += @ProdQty
         UPDATE STB_SetInfo SET IsProdFinish=1, ProdFinishDateTime
                    ↓
Bước 11: Nhập kho tự động khi hoàn thành
         EXEC usp_DoProcessProdGRMaterialByOne (tạo Lot nhập kho)
         EXEC usp_DoFinishMaterialDoc (đóng phiếu nhập)
         EXEC usp_DoFixMaterialDoc (xác nhận phiếu)
```

#### Call Chain — 6 Sub-SPs được gọi

| Sub-SP | Khi nào gọi | Tác động |
|---|---|---|
| `usp_DoAddProdRouteHistByWorkerList` | WorkerCode ≠ '' | Ghi nhân viên vào lịch sử |
| `usp_DoProcessProdRouteSummary` | Luôn gọi | Tổng hợp SL theo Line/Route/Ca/Ngày |
| `usp_DoProcessProdGIMaterialByBOM` | Luôn gọi | **BACKFLUSH** — trừ kho NVL tự động theo BOM |
| `usp_VN_UpdateSpecialSparePartLot` | IsInputRoute + chưa nhập | Cập nhật Lot phụ tùng đặc biệt |
| `usp_DoProcessProdGRMaterialByOne` | IsOutputRoute=1 (cuối) | Tạo phiếu nhập kho thành phẩm |
| `usp_DoFinishMaterialDoc` + `usp_DoFixMaterialDoc` | IsOutputRoute=1 (cuối) | Đóng + xác nhận phiếu nhập |

> ⚠️ **Rủi ro:** SP này KHÔNG có `BEGIN TRANSACTION`. Nếu crash giữa chừng (ví dụ sau Bước 8 nhưng trước Bước 10), NVL đã bị trừ nhưng thành phẩm chưa được ghi nhận → data lệch.

### 🔬 Backflush Engine: `usp_DoProcessProdGIMaterialByBOM` (268 dòng)

> **Backflush = Trừ kho NVL tự động theo BOM khi chốt sản lượng.** Đây là cơ chế cốt lõi liên kết SX ↔ Kho.

#### Luồng xử lý 7 bước

```
Bước 1: Đọc BOM → lọc NVL cần trừ
         FROM STB_ProductionOrderBom WHERE PONo + MaterialCode + RouteCode
         FILTER: IsUseProduction=1 AND IsUseFlush=1 AND IsBackFlush=0
         Chuyển đổi đơn vị: fnConvertUnit(BomUnit → MaterialUnit) * ProdQty
                    ↓
Bước 2: Kiểm tra đủ tồn kho
         JOIN @Items ← STB_MaterialStock
         IF UseQty > StockQty → ERROR "부족한 자재" (NVL không đủ)
                    ↓
Bước 3: Lấy WarehouseCode từ LineRouteMapping
         STB_LineRouteMapping → @GIWarehouseCode, @GILocationCode
                    ↓
Bước 4: Tạo phiếu xuất kho (MaterialDoc type = GI_PRODUCTION)
         INSERT STB_MaterialDocInfo (DocStatus='CREATE', Type='GI')
                    ↓
Bước 5: WHILE loop — INSERT từng dòng NVL vào MaterialDocDetail
         INSERT STB_MaterialDocDetail (RequestQty = AllowQty = PickingQty = UsedQty)
         → EXEC usp_DoCreateMaterialDocLotInfoNotUsedBarcode (chọn Lot tự động)
                    ↓
Bước 6: Đóng phiếu → EXEC usp_DoFinishMaterialDoc
                    ↓
Bước 7: Xác nhận phiếu → EXEC usp_DoFixMaterialDoc
```

#### Bảng liên quan

| Bảng | Vai trò |
|---|---|
| `STB_ProductionOrderBom` | BOM nguồn — NVL nào cần trừ |
| `STB_MaterialMaster` | Master NVL — đơn vị, cờ IsUseFlush |
| `STB_MaterialStock` | Tồn kho hiện tại |
| `STB_LineRouteMapping` | Map Line→Warehouse (biết trừ kho nào) |
| `STB_MaterialDocInfo` | Phiếu xuất kho (Header) |
| `STB_MaterialDocDetail` | Chi tiết phiếu (từng NVL) |

> 💡 **Tại sao `IsUseFlush=1 AND IsBackFlush=0`?** Flush = trừ ngay khi SX. BackFlush = trừ sau. SP này xử lý Flush (trừ ngay). BackFlush có SP riêng.

---

## [B552] — Slitting Configurations (Thiết lập chia cuộn điện cực)

### Lỗi 1: Cảnh báo chặn "Không tồn tại thiết lập Điện cực... Chưa CONFIG trong bảng STB_SLITTINGLOCATIONCONFIG_VVT"
*   **Triệu chứng:** Khi thực hiện chia cuộn điện cực tại **B552**, hệ thống báo lỗi chặn không cho thực hiện giao dịch chia cuộn.
*   **Nguyên nhân gốc:** Chưa cấu hình thông số chiều rộng, cực dương (BY) và cực âm (YP) của mã hàng (PartNo) tương ứng trong bảng cấu hình chia cuộn `stb_slittinglocationconfig_vvt`.
*   **Cách khắc phục:** Chạy SQL chèn bổ sung cấu hình cho mã PartNo bị thiếu (BY = Cực dương, YP = Cực âm):
    ```sql
    INSERT INTO stb_slittinglocationconfig_vvt (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
    VALUES ('MÃ_PART_NO', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),
           ('MÃ_PART_NO', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md § 8.2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#82-lỗi-chưa-config-trong-stb_slittinglocationconfig_vvt).

---


## [B560] — Hela OutBox List (In tem thùng Hela)

### Lỗi 1: Lỗi in thiếu tem nhỏ (chỉ in 73/80 tem)
*   **Triệu chứng:** Khi in tem thùng Hela có quy cách 80 hộp nhỏ, hệ thống chỉ hiển thị `InBoxLabelCount = 73` và in thiếu tem.
*   **Nguyên nhân gốc:** Biến cục bộ `@InBoxLabelList` và cột tương ứng trong bảng `STB_HelaBarcodeOutBoxHist` khai báo kiểu dữ liệu `VARCHAR(1000)` quá ngắn, khiến chuỗi tem bị cắt cụt (truncation).
*   **Cách khắc phục:**
    1. Chạy ALTER TABLE đổi cột `InBoxLabelList` thành `VARCHAR(MAX)`.
    2. ALTER Stored Procedure `usp_DoCreateHelaInBoxBarcodeList` đổi biến `@InBoxLabelList` thành `VARCHAR(MAX)`.
    3. Update khôi phục lại chuỗi tem đầy đủ cho các Lot bị lỗi.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.14](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#614-lỗi-cắt-chuỗi-danh-sách-tem-nhỏ-b560---truncation-in-inboxlabellist).

---


## [B618] — Rework (Làm lại sản phẩm)

### [B618] — Lỗi 1: Không có quyền thao tác trên giao diện Rework
*   **Triệu chứng:** Công nhân không thể thực hiện quét/xác nhận làm lại sản phẩm lỗi tại chuyền.
*   **Nguyên nhân gốc:** SP `usp_Vietnam_GetLotInfoForRework_VNT` bị hardcode kiểm tra Whitelist UserID.
*   **Cách khắc phục:**
    Sửa SP để bổ sung thêm UserID của OP hiện hành vào danh sách Whitelist cho phép thao tác Rework.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_09_SCREEN_BUG_FIXBOOK.md#b618](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#b618).

---


## [B682] / [B781] / [B786] / [B789] / [B791] — Stage Prices & Defect Reports (Giá công đoạn & Báo cáo lỗi)

### Lỗi 1: Đơn giá công đoạn sản xuất bị hiển thị trống (Null)
*   **Triệu chứng:** Lưới dữ liệu sản lượng hiển thị đơn giá bằng 0 hoặc trống, không tính được lương/hiệu suất.
*   **Nguyên nhân gốc:** Model sản phẩm chưa được khai báo đơn giá tương ứng với công đoạn và mã nhà máy (`WorkCenterCode`) trong bảng thiết lập Stage Prices.
*   **Cách khắc phục:**
    Khai báo bổ sung đơn giá cho Model sản phẩm vào bảng `STB_VVT_StagePrices` tương ứng:
    ```sql
    INSERT INTO STB_VVT_StagePrices (model, WorkCenterCode, RouteV22, PriceV22...)
    VALUES ('MÃ_MODEL', 'MÃ_NHÀ_MÁY', 'ROUTE_CODE', ĐƠN_GIÁ);
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 3](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#3-fix-giá-công-đoạn-stage-prices).

### [B682] — Lỗi 2: Báo cáo lỗi chi tiết Cell bị lẫn lộn các lỗi không thuộc bộ phận sản xuất (VE%, VP%)
*   **Triệu chứng:** Báo cáo chi tiết lỗi sản phẩm Cell Line Bắc Giang/Bắc Ninh hiển thị lẫn lộn cả các lỗi thuộc bộ phận Điện cực (Electrode - mã `VE%`) và bộ phận Module (mã `VP%`).
*   **Nguyên nhân gốc:** Stored Procedure `usp_Get_VVT_Prod_Bad_Status` khi truy vấn lịch sử công đoạn và bảng lỗi `STB_DefectRepairInfo` chỉ lọc `RouteCode LIKE 'V%'`. Do công đoạn của Điện cực Hà Nam bắt đầu bằng `VE` (Ví dụ: `VE01`) và Module bắt đầu bằng `VP` (Ví dụ: `VP01`), chúng đều bị lọc nhầm vào kết quả Cell Line Bắc Giang/Bắc Ninh.
*   **Cách khắc phục:** Sửa SP `usp_Get_VVT_Prod_Bad_Status` tại khối CTE `ViewBarcode` và `RawView` để thêm logic lọc loại trừ:
    ```sql
    -- Thêm logic lọc loại trừ VE và VP tại các xưởng khác Hà Nam
    AND b.RouteCode LIKE 'V%'
    AND (@WorkCenterCode = 'VVT_F3' OR (b.RouteCode NOT LIKE 'VE%' AND b.RouteCode NOT LIKE 'VP%'))
    ```
*   **Chi tiết nghiệp vụ:** Xem tại mã nguồn Stored Procedure **usp_Get_VVT_Prod_Bad_Status.sql**.

---


## [B754] / [B756] — PAC Customer Labels (In tem nhãn khách hàng PAC)

### Lỗi 1: Lỗi in tem thùng nhãn ngoài (Outer Label) không hiển thị đúng Serial hoặc cân nặng
*   **Triệu chứng:** In tem thùng lớn tại B756 báo lỗi thiếu Serial nhãn hoặc không hiển thị trọng lượng thực tế.
*   **Nguyên nhân gốc:** Không tích chọn cờ `IsOuter = 1` khi in nhãn ngoài (Outer) dẫn đến hệ thống hiểu nhầm là nhãn trong (Inner), hoặc chưa bật chế độ `IsWeightLabel`.
*   **Cách khắc phục:**
    1. Nhắc nhở công nhân tick chọn `IsOuter` khi in nhãn ngoài thùng (Outer) vì nhãn trong và nhãn ngoài chạy Serial độc lập.
    2. Khi in tem cân nặng, tick chọn `IsWeightLabel` trước khi nhấn nút.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.9.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#691-in-tem-khách-hàng-pac-b754--b755--b756).

---


## [B757] / [B758] — Digi-Key Customer Labels (In tem nhãn khách hàng Digi-Key)

### [B757] — Lỗi 1: Lỗi in nhãn Logistic tại bị chặn báo thiếu thông tin
*   **Triệu chứng:** Bấm "IN NHÃN LOGISTIC" hệ thống báo lỗi không in được.
*   **Nguyên nhân gốc:** Chưa nhập đủ các trường bắt buộc gồm: PO Number, PO Line Number, Pack List Number.
*   **Cách khắc phục:**
    1. Yêu cầu nhập đầy đủ thông số PO và số dòng PO tương ứng trước khi in.
    2. Nếu in cho thùng hàng hỗn hợp (Mixed Load), chuyển sang sử dụng màn hình **B758**.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.9.2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#692-in-tem-khách-hàng-digi-key-b757--b758).

---


## [B790] — Phoenix Contact Labels (Thiết kế/In tem Phoenix Contact)

### Lỗi 1: Tem in ra Phoenix Contact bị sai định dạng ngày Datecode
*   **Triệu chứng:** Tem Phoenix Contact in ra tại màn hình **B790** hiển thị sai định dạng ngày (không phải định dạng YYMMDD yêu cầu).
*   **Nguyên nhân gốc:** Cột `InputJobDate` trong bảng `STB_SetInfo` bị null hoặc lưu sai định dạng ngày khiến SP `usp_Vietnam_PhoenixContactLabelPrint_get` trích xuất datecode bị lỗi.
*   **Cách khắc phục:**
    Chạy script kiểm tra `InputJobDate` và cập nhật lại ngày đúng cho Barcode bị lỗi:
    ```sql
    -- Sửa ngày bắt đầu sản xuất cho Lot
    UPDATE STB_SetInfo SET InputJobDate = '2026-06-12' WHERE Barcode = 'MÃ_BARCODE';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.10](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#610-thiết-kế-tem-phoenix-contact-yêu-cầu-đặc-biệt-tại-b790).

---


## [B802] — Electrode Production History (Báo cáo & Đối soát điện cực)

### [B802] — Lỗi 1: Sai lệch số lượng/mã cuộn điện cực thực tế so với báo cáo
*   **Triệu chứng:** Khi mở báo cáo lịch sử sản xuất điện cực trên **B802**, số lượng cuộn hoặc tổng số mét sản xuất thực tế bị lệch so với dữ liệu chốt công đoạn.
*   **Nguyên nhân gốc:** Bỏ qua việc quét/chốt các công đoạn bán thành phẩm điện cực (Coating/Slitting) hoặc do sai lệch giá trị `ProdQty` trong bảng `STB_ProdRouteHist` của điện cực.
*   **Cách khắc phục:** IT tiến hành đối soát thông tin qua bảng lịch sử điện cực `STB_ElectrodeProdRouteHist` và điều chỉnh lại sản lượng thực tế khớp với số mét cuộn.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.11](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#611-b802---vietnam-electrode-prod-route-hist-lịch-sử-sx-điện-cực) và [../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md § 3](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#3-báo-cáo--đối-soát-điện-cực-b802).

---


## [H301]~[H305] — Spare Parts Management (Quản lý kho & tuổi thọ phụ tùng)

### Lỗi 1: Phụ tùng máy bị mòn/hỏng thực tế nhưng hệ thống không cảnh báo hoặc chặn không cho thay thế
*   **Triệu chứng:** Phụ tùng trên line bị mòn nhưng hệ thống MES không hiển thị cảnh báo đỏ hoặc không cho phép quét barcode để xuất phụ tùng thay mới.
*   **Nguyên nhân gốc:** Chưa thiết lập hoặc khai báo sai chu kỳ thay thế định mức (`CycleReplace` theo ngày) và tuổi thọ chạy Lot (`LifeLotQty`) của phụ tùng tại **H301** (`STB_VNSparePartInfo`), hoặc Lot phụ tùng chưa được nhập kho tại **H302**.
*   **Cách khắc phục:**
    1. Kiểm tra tồn kho phụ tùng tại màn hình **H304** / **H302**.
    2. Truy cập màn hình **H301**, cấu hình đầy đủ `CycleReplace` và `LifeLotQty` cho mã phụ tùng tương ứng.
    3. Thực hiện xuất phụ tùng lên chuyền tại **H303** và theo dõi lịch sử thay thế tại **H305**.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.15](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#615-spare-part--h301h302h303h305) và [../KB_03/KB_03_02_CELL_LINE.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md).

---


## [HN523] / [HN544] — Custom Matching & Merge (Gộp box túi nilon / Gộp tùy chỉnh Hà Nam)

### [HN544] — Lỗi 1: Khi bấm gộp box tùy chỉnh ở báo lỗi "Column LotID is constrained to be unique"
*   **Triệu chứng:** OP nhập Packing ID tại màn hình **HN544** nhấn Tìm kiếm hệ thống crash báo lỗi trùng lặp khóa chính LotID: `Value '...' is already present`.
*   **Nguyên nhân gốc:** Stored Procedure `usp_GetMaterialLotInfo_Packing_VVT_F3` sử dụng `UNION ALL` gộp 3 truy vấn, trong đó truy vấn thứ 3 thực hiện JOIN với bảng chia tách `STB_DividePackaging` bị sai logic khi có mã cha chưa phân tách (PackingParentID = NULL), trả về dòng dummy có LotID bị null/duplicate.
*   **Cách khắc phục:**
    ALTER Stored Procedure `usp_GetMaterialLotInfo_Packing_VVT_F3` bổ sung thêm điều kiện lọc loại trừ mã cha chưa phân tách ở khối WHERE của UNION thứ 3:
    ```sql
    WHERE DP.PackingID = @pPackingID  
      AND ISNULL(DP.PackingParentID, '') <> '' -- Dòng sửa lỗi
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 2.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#21-lỗi-unique-constraint-khi-gộp-túi-bóng-hn544--pkqn2100175).

### [HN544] — Lỗi 2: Gộp túi bóng thành hộp nhỏ ở bị mất số lượng (CurrentQty = 0)
*   **Triệu chứng:** Sau khi thực hiện gộp nilon thành hộp nhỏ, số lượng tồn hiển thị bằng 0 và không in được tem nhãn.
*   **Nguyên nhân gốc:** Lệch dữ liệu khi dồn số lượng giữa các Lot phụ.
*   **Cách khắc phục:**
    Chạy script dồn tổng số lượng thực tế vào 1 Lot duy nhất và xóa các Lot phụ rác:
    ```sql
    UPDATE STB_MaterialLotInfo SET InitialQty = 20, CurrentQty = 20 WHERE MaterialLotNo = 'MÃ_LOT_CẦN_GIỮ';
    DELETE FROM STB_MaterialLotInfo WHERE MaterialLotNo IN ('MÃ_LOT_RÁC_1', 'MÃ_LOT_RÁC_2');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#65-lỗi-gộp-túi-bóng-bị-mất-số-lượng-qty--0--hn544).

### [HN523] — Lỗi 3: Báo lỗi tiếng Hàn "Bạn chưa nhập kết quả..." hoặc sản lượng hiển thị bằng 0 ở
*   **Triệu chứng:** Nhập mã Lot để gộp box ở màn hình gộp tùy chỉnh **HN523**, hệ thống báo lỗi tiếng Hàn hoặc hiển thị sản lượng đầu ra (OutputQty) bằng 0.
*   **Nguyên nhân gốc:** Cấu hình Routing của PO thiếu cờ công đoạn cuối làm công đoạn đầu ra (`IsOutputRoute = 1`), khiến Stored Procedure `usp_Vietnam_GetProdPackingForBarcode_VVT` trả về sản lượng bằng 0.
*   **Cách khắc phục:** Cập nhật lại cấu hình Routing của PO trên DB để đặt công đoạn cuối làm công đoạn đầu ra:
    ```sql
    UPDATE STB_ProductionOrderRouting SET IsOutputRoute = 1 WHERE PONo = 'MÃ_PO' AND RouteCode = 'MÃ_CÔNG_ĐOẠN_CUỐI';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.13](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#613-phân-tích-nguyên-nhân-lỗi-gộp-box-tùy-chỉnh-trên-màn-hình-hn523-sản-lượng-hiển-thị--0--cảnh-báo-tiếng-hàn).

---


## [HN551] / [HN866] — FG Export & InStock (Xuất kho & Tồn kho thành phẩm Hà Nam)

### [HN551]/[HN866] — Lỗi 1: Hàng đã xuất kho ở nhưng tồn kho trên màn vẫn còn nguyên
*   **Triệu chứng:** Lịch sử xuất hàng đã ghi nhận thành công tại màn hình xuất **HN551** nhưng khi vào màn hình kiểm tra tồn kho **HN866** vẫn thấy hiện Packing ID cũ, gây lệch tồn kho thực tế.
*   **Nguyên nhân gốc:** SP xử lý xuất kho `ExportWarehouseFinshGoodInventory_uid` thực hiện ghi nhận vào bảng xuất `STB_VN_FINISHGOODS_HN_Export` nhưng bị lỗi/quên không cập nhật cột cờ xuất `QtyOutput` trong bảng tồn kho `FinishGoodMESInstock_HN`.
*   **Cách khắc phục:**
    Chạy script SQL đồng bộ cờ xuất kho cho Packing ID bị lỗi:
    ```sql
    -- Cập nhật cờ xuất kho bằng số lượng gốc của thùng
    UPDATE FinishGoodMESInstock_HN SET QtyOutput = Quantity WHERE PackingID = 'MÃ_PACKING_LỖI';
    UPDATE STB_VN_FINISHGOODS_HN_Export SET StatusExport = 1 WHERE PackingID = 'MÃ_PACKING_LỖI';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md § 1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#1-lỗi-hàng-xuất-ở-hn551-nhưng-tồn-kho-hn866-vẫn-còn).

---


## [K101] / [K109] / [K110] — [BG2] Production Plan & Scan (Sản xuất và quét NVL nhà máy [BG2])

### [BG2] — Lỗi 1: Không tạo được Lot hoặc không chốt được sản lượng tại nhà máy Bắc Giang 2 ()
*   **Triệu chứng:** Công nhân tại nhà máy BG2 không thể thực hiện các thao tác lập kế hoạch ngày hay quét chốt sản lượng trên các màn hình chuẩn B450 hay B597.
*   **Nguyên nhân gốc:** Nhà máy BG2 chạy cơ sở dữ liệu và phân hệ riêng biệt, sử dụng màn hình đặc thù: **K101** (tương đương B450) và **K109** (tương đương B597) có lọc riêng cho `WorkCenterCode = 'VVT_BG2'`.
*   **Cách khắc phục:** Hướng dẫn công nhân mở đúng màn hình của BG2:
    1. Lập kế hoạch ngày tại **K101** thay vì B450.
    2. Để quét NVL, OP mở màn hình **B540** -> nhấn nút **"Việt Nam_Kiểm tra thường xuyên_BG2"** để kích hoạt giao diện **K109** (tích hợp logic chặn quét sai NVL theo BOM).
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.9](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#69-sự-khác-biệt-vận-hành-bg2).

### Lỗi 2: Bấm "Tạo Lot" báo lỗi duplicate key trên index `XS_Barcode` của `STB_SetInfo`

> 🐛 **Phát hiện:** 2026-06-16 | Màn hình: **K101** (VVT_F4) | SP: `usp_DoCreateSetInfoForProdQty_VNT` → `usp_DoCreateSetInfo`

*   **Triệu chứng:** Khi bấm nút **"Tạo Lot"** trên màn hình K101, hệ thống báo lỗi SQL:
    ```
    위반한 중복 키 값은 (0)입니다.
    Cannot insert duplicate key row in object 'dbo.STB_SetInfo' with unique index 'XS_Barcode'.
    ```
    (Bản dịch: "Không thể chèn hàng trùng khóa vào bảng `dbo.STB_SetInfo` do unique index `XS_Barcode`. Giá trị khóa trùng là (0).")

*   **Nguyên nhân gốc (3 tầng):**
    1.  **Thiếu mapping trong `STB_BomRevision_Map`:** SP `usp_DoCreateSetInfo` truy vấn bảng `STB_BomRevision_Map` để lấy `BloomEnergyBOMRevision` (ví dụ: `'26'`) dùng khi tạo Barcode cho Lot. Nếu `MaterialCode` của sản phẩm chưa có trong bảng này → biến `@BloomEnergyBOMRevision = NULL`.
    2.  **`CONCAT_NULL_YIELDS_NULL = ON` (mặc định SQL Server — chuẩn ISO):** Đây là hành vi **mặc định** của SQL Server. Khi ghép chuỗi có bất kỳ thành phần `NULL` nào, **toàn bộ kết quả trả về `NULL`**. Ví dụ: `'K164181' + NULL + '26'` → `NULL`. Không cần `SET` thủ công, SQL Server đã bật sẵn.
    3.  **`ISNULL(NULL, '')` → chuỗi rỗng `''`:** SP dùng `ISNULL(@Barcode, '')` như một fallback, nhưng kết quả là Barcode trở thành `''` (rỗng). Khi tạo nhiều Lot, tất cả đều có Barcode = `''` → vi phạm unique index `XS_Barcode`.

*   **Cách kiểm tra nhanh:**
    ```sql
    -- Bước 1: Xác nhận MaterialCode bị thiếu mapping
    SELECT MaterialCode FROM STB_BomRevision_Map
    WHERE MaterialCode = '[Mã Model bị lỗi]'
    -- Nếu 0 rows → đây là nguyên nhân

    -- Bước 2: Xem các bản ghi mẫu để biết format cần insert
    SELECT TOP 5 * FROM STB_BomRevision_Map ORDER BY CreateDateTime DESC
    ```

*   **Cách khắc phục:** Thêm bản ghi cho sản phẩm bị thiếu vào `STB_BomRevision_Map`:
    ```sql
    -- Lấy BOMRevision hiện tại của sản phẩm từ BOM master
    SELECT TOP 1 BomVersion FROM STB_BomInfo
    WHERE MaterialCode = '[Mã Model]' AND IsDeleted = 0
    ORDER BY CreateDateTime DESC

    -- Insert vào mapping table
    INSERT INTO STB_BomRevision_Map (MaterialCode, BloomEnergyBOMRevision, CreateDateTime)
    VALUES ('[Mã Model]', '[BomVersion lấy được]', GETDATE())
    ```

*   **⚠️ Lưu ý quan trọng về `CONCAT_NULL_YIELDS_NULL`:**
    -   Giá trị `ON` là **mặc định của SQL Server** (ISO standard), **không phải lỗi cấu hình**.
    -   Không nên tắt (`SET CONCAT_NULL_YIELDS_NULL OFF`) vì sẽ gây ra hành vi không chuẩn và có thể tạo ra barcode sai thay vì lỗi — khó debug hơn.
    -   **Bước xử lý đúng:** Luôn đảm bảo `STB_BomRevision_Map` có đầy đủ dữ liệu khi thêm model mới (xem Checklist thêm model mới).

*   **Phòng ngừa:** Thêm bước kiểm tra `STB_BomRevision_Map` vào quy trình thêm model mới (xem `new_model_checklist.md` Bước 3b).

---





