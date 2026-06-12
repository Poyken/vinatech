# 🔍 NAIS MES — Screen ID Troubleshooting & Bug Reference

Tài liệu này tập hợp tất cả các sự cố, lỗi vận hành và cách khắc phục chi tiết theo từng mã màn hình (Screen ID). Giúp lập trình viên và kỹ sư vận hành tra cứu siêu tốc khi phát sinh lỗi trên một giao diện cụ thể.

> **Mẹo tìm kiếm:** Nhấn `Ctrl + Shift + F` và nhập `## Mã_Màn_Hình` (Ví dụ: `## C512` hoặc `## B597`) để chuyển trực tiếp đến phần tổng hợp lỗi của màn hình đó.
> ← [Về INDEX](KB_INDEX.md)

---

## A130 — Warehouse & Location (Khai báo kho & vị trí)

### Lỗi 1: Không hiển thị hoặc thiếu vị trí kho (Location) khi làm thủ tục nhập kho F330 hoặc chuyển kho
*   **Triệu chứng:** Khi thực hiện nhập kho tại **F330** hoặc điều chuyển kho, người dùng không thấy vị trí kho (Location) trong danh sách để chọn, hoặc hệ thống báo lỗi không tồn tại vị trí.
*   **Nguyên nhân gốc:** Chưa khai báo Location hoặc cờ sử dụng bị tắt (`IsUsed = 0`) trong bảng danh mục kho `STB_WarehouseLocation`.
*   **Cách khắc phục:** Vào màn hình **A130** (hoặc check trực tiếp bảng `STB_WarehouseLocation`), cấu hình thêm vị trí kho tương ứng cho mã kho và bật cờ hoạt động.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 8](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_25_VINAENESSOL_HUNG_YEN.md#8-a130-kholocation--đối-tác).

---

## A230 / A410 — Master Data Model (Đăng ký vật tư & Thông tin cơ bản)

### Lỗi 1: Model mới thêm không hiện Vol/Farad, QC C512 không tìm thấy Lot, B597 không quét được
*   **Triệu chứng:** Model mới đã được khai báo trên màn hình **A230** nhưng khi sản xuất công nhân không thấy hiện thông số Vol/Farad, QC không tìm thấy Lot hàng ở màn hình OQC **C512**, hoặc trạm quét NVL **B597** báo lỗi sai chủng loại.
*   **Nguyên nhân gốc:** Mã sản phẩm mới chỉ được tạo ở bảng danh mục chung `STB_MaterialMaster` nhưng chưa được khai báo các thông số cơ bản (Vol, Farad, kích thước...) trong bảng thuộc tính chi tiết `STB_ModelBasicInfo` (Màn hình **A410**).
*   **Cách khắc phục:**
    Khai báo bổ sung thuộc tính model bằng cách chạy script chèn dữ liệu trực tiếp:
    ```sql
    INSERT INTO STB_ModelBasicInfo (ModelCode, ModelName, MaterialTypeCode, ProductGroupCode, MBISizeH, MBISizeW, CreateDateTime, MBIExtText04, MBIExtText05)
    VALUES ('MÃ_MODEL_MỚI', 'TÊN_MODEL', 'MDL', 'HC-EDLC', 40, 18, GETDATE(), 'Vol_Ví_Dụ_9R0', 'Farad_Ví_Dụ_166');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 1.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#13-sửa-mã-vật-tư-mới-chưa-khai-báo-volfarad-stb_modelbasicinfo).

---

## A310 — BOM Registration (Đăng ký cấu trúc BOM sản phẩm)

### Lỗi 1: Trạm quét NVL B597 báo lỗi đỏ "Mã nguyên vật liệu không khớp với BOM"
*   **Triệu chứng:** Khi OP quét mã vạch NVL tại chuyền ở trạm **B597**, hệ thống báo lỗi đỏ chặn không cho lưu vì NVL không nằm trong BOM.
*   **Nguyên nhân gốc:** Cấu trúc định mức vật tư (BOM) của sản phẩm/model chưa được đăng ký hoặc đồng bộ thiếu trong các bảng `STB_BomHeader` và `STB_BomDetail` tại màn hình **A310**.
*   **Cách khắc phục:** Vào màn hình **A310**, kiểm tra cấu hình BOM của Model, gán bổ sung mã NVL bị thiếu hoặc yêu cầu bộ phận quản lý đồng bộ lại BOM từ Groupware.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_25_VINAENESSOL_HUNG_YEN.md#4-màn-hình-a310-thông-tin-bom).

---

## B210 / B220 / B230 / B240 — Production Routing Setup (Thiết lập định tuyến sản xuất)

### Lỗi 1: Màn hình B450 không tìm thấy Line sản xuất để tạo Lot
*   **Triệu chứng:** Khi lập kế hoạch ngày tại **B450** để sinh mã Lot cho PO, người dùng không thể chọn được Line sản xuất mong muốn trong dropdown.
*   **Nguyên nhân gốc:** Line sản xuất chưa được kích hoạt (`IsUsed = 0`) tại màn hình đăng ký Line **B210** (`STB_LineInfo`), hoặc cấu hình sai mã nhà máy (`WorkCenterCode`).
*   **Cách khắc phục:** Vào màn hình **B210**, tìm Line tương ứng, kiểm tra và tick chọn cờ `IsUsed`, đảm bảo `WorkCenterCode` khớp với khu vực sản xuất rồi Lưu lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#10-thiết-lập-line--route-b210b220b230b240).

### Lỗi 2: Giao diện B530 không hiển thị Máy khi OP scan chốt công đoạn
*   **Triệu chứng:** OP thực hiện quét chốt sản lượng tại **B530** nhưng không hiển thị danh sách thiết bị/máy chạy trong dropdown chọn máy.
*   **Nguyên nhân gốc:** Máy móc chưa được cấu hình phân bổ thuộc công đoạn (RouteCode) đang chạy trong bảng `STB_MachineMaster` (Màn hình **B240**).
*   **Cách khắc phục:** Vào màn hình **B240**, kiểm tra và gán máy móc đang chạy vào đúng công đoạn (RouteCode) tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#10-thiết-lập-line--route-b210b220b230b240).

---

## B250 / B270 — Cell / Machine Mapping (Đồng bộ chuyền & máy chạy mới)

### Lỗi 1: Popup gán máy B270 trống không hiển thị danh sách thiết bị
*   **Triệu chứng:** Khi bấm vào popup để gán máy chạy cho Route sản xuất ở màn hình **B270**, danh sách máy trống trơn không có bản ghi nào.
*   **Nguyên nhân gốc:** Do Stored Procedure `usp_Set_VVT_Info_get` bị hardcode kiểm tra Whitelist UserID của người thao tác, hoặc cấu hình sai thiết lập máy trong bảng `STB_ProductMachine`.
*   **Cách khắc phục:**
    Sửa đổi SP `usp_Set_VVT_Info_get` để bổ sung thêm UserID của người vận hành hiện tại vào Whitelist, hoặc cập nhật trực tiếp DB:
    ```sql
    -- Thêm điều kiện Whitelist User trong SP
    SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Set_VVT_Info_get'));
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md#13-lỗi-popup-b270-trống-không-hiện-danh-sách-máy).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#7-thêm-cellline-mới-b250-b270).

---

## B260 — Worker Management (Nhân sự sản xuất)

### Lỗi 1: Tên nhân viên mới không hiển thị trong dropdown chọn nhân viên tại B530 hoặc B540
*   **Triệu chứng:** Nhân viên đã đăng ký thành công trên MES nhưng OP không tìm thấy tên khi chốt sản lượng.
*   **Nguyên nhân gốc:** Khi khai báo nhân viên, cột mã nhóm nhân viên (`WorkerGroupCode`) bị điền sai (không phải nhóm `VE-01` của nhà máy).
*   **Cách khắc phục:** Vào màn hình **B260**, tìm mã nhân viên, cập nhật lại cột `WorkerGroupCode` chính xác thành `VE-01` rồi nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 12](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#12-b260---thông-tin-nhân-viên-sản-xuất).

---

## B310 / B450 — Production Orders & Day Plan (Kế hoạch tháng / ngày)

### Lỗi 1: Lỗi không đồng bộ được lệnh sản xuất (PO) từ Groupware sang MES
*   **Triệu chứng:** Kế hoạch sản xuất đã được lập trên Groupware nhưng thủ kho hoặc OP không thấy hiển thị thông tin PO tại màn hình **B310** hay **B450** trên MES để bắt đầu tạo Lot.
*   **Nguyên nhân gốc:** PO trên Groupware chưa được duyệt trạng thái "Arrival Confirmation", hoặc Windows Service đồng bộ trung gian (ESM Bridge) bị treo/chết, khiến dữ liệu không được đẩy vào bảng trung gian `ESM_DayProdPlan`.
*   **Cách khắc phục:**
    1. Yêu cầu quản lý duyệt PO trên Groupware.
    2. Nếu đã duyệt nhưng vẫn lệch, IT kiểm tra trạng thái Windows Service ESM, hoặc chạy query cưỡng bức đồng bộ thủ công qua ESM Bridge Tables.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_07_GROUPWARE_INTEGRATION.md § 6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07_GROUPWARE_INTEGRATION.md#6-lỗi-không-đồng-bộ-được-po-từ-groupware-sang-mes).

---

## B351 — Lot Transition (Chuyển đổi Lot)

### Lỗi 1: Barcode sinh ra bị chèn ký tự dấu chấm (`.`) sai định dạng
*   **Triệu chứng:** Sau khi thực hiện chuyển đổi Lot/vật tư tại màn hình **B351**, Barcode sản phẩm mới sinh ra xuất hiện dấu chấm (Ví dụ: `VVPR152.740601`) thay vì ký tự chữ `R` tiêu chuẩn (`VVPR152R740601`). Lỗi này chặn quét công đoạn tiếp theo.
*   **Nguyên nhân gốc:** Sai lệch logic cắt ghép chuỗi sinh barcode tự động trong SP xử lý transition.
*   **Cách khắc phục:**
    Chạy script SQL để sửa đồng loạt Barcode bị lỗi trong các bảng giao dịch:
    ```sql
    DECLARE @OldBC NVARCHAR(50) = 'VVPR152.740601';
    DECLARE @NewBC NVARCHAR(50) = 'VVPR152R740601';

    UPDATE STB_RawMaterialInputHist SET Barcode = @NewBC WHERE Barcode = @OldBC;
    UPDATE STB_SetInfo SET Barcode = @NewBC WHERE Barcode = @OldBC;
    UPDATE STB_LotChangeMaterialHistory SET NewBarcode = @NewBC WHERE NewBarcode = @OldBC;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#62-sửa-tên-lot-sau-b351-chuyển-đổi-lot--barcode-có-dấu-chấm).

---

## B418 — Packing Quantity Standards (Quy cách đóng gói theo Size)

### Lỗi 1: Popup gộp Box tại B523 báo lỗi "Chưa có tiêu chuẩn đóng gói" do sai lệch kích thước Size
*   **Triệu chứng:** Khi công nhân quét gộp Box tại B523, hệ thống báo lỗi chặn đứng quy trình: `"Chưa có tiêu chuẩn đóng gói"`.
*   **Nguyên nhân gốc:** Kích thước Size của Model (`MBISizeD` lấy từ **A410**) chưa được khai báo số lượng đóng gói định mức (`PackQty`) tương ứng trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:** Vào màn hình **A418**, đăng ký Size mới và thiết lập số lượng đóng gói định mức tương ứng (`PackQty`) rồi nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#11-a418---số-lượng-đóng-gói-theo-size).

---

## B442 — Electrode Production Plan (Kế hoạch & in tem điện cực)

### Lỗi 1: Không tạo được kế hoạch hoặc in tem điện cực cho Model mới
*   **Triệu chứng:** Khi lập kế hoạch và in tem điện cực tại **B442**, Model mới không hiển thị hoặc không cho phép in.
*   **Nguyên nhân gốc:** Model chưa được khai báo ở bảng thông tin Model master (**A230**) hoặc thiếu cấu hình công đoạn tương ứng.
*   **Cách khắc phục:** Đăng ký đầy đủ mã Model ở màn hình **A230** trước khi thao tác trên **B442**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 1 (Phần 1)](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#1-lập-kế-hoạch--in-tem-điện-cực-b310-b442-a230).

---

## B452 — Line Changing (Chuyển Line sản xuất)

### Lỗi 1: Không đổi được Line sản xuất cho Lot sản phẩm
*   **Triệu chứng:** Khi thực hiện đổi chuyền sản xuất cho Lot tại màn hình **B452**, hệ thống báo lỗi không có quyền hoặc chặn không cho lưu.
*   **Nguyên nhân gốc:** Stored Procedure `usp_Vietnam_ChangeProductionOrderRoutingLine_VNT` kiểm soát tính năng này chứa một danh sách Whitelist UserID được hardcode cứng.
*   **Cách khắc phục:**
    ALTER SP `usp_Vietnam_ChangeProductionOrderRoutingLine_VNT` để bổ sung UserID của nhân viên vận hành hiện tại vào danh sách được phép.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md#67-b452-không-đổi-được-line).

---

## B523 / B525 — Packaging & Box Matching (Đóng gói Cell & Module)

### Lỗi 1: Báo lỗi "Chưa có tiêu chuẩn đóng gói" khi gộp Box
*   **Triệu chứng:** Công nhân quét gộp Box tại màn hình **B523** hệ thống báo lỗi đỏ chặn đứng quy trình: `"Chưa có tiêu chuẩn đóng gói"`.
*   **Nguyên nhân gốc:** Model/Size mới chưa được khai báo số lượng đóng gói định mức trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:**
    Khai báo tiêu chuẩn đóng gói (dựa trên loại vật tư `FERT` và size model, không gán theo `MaterialCode`):
    ```sql
    INSERT INTO STB_PackingStandard (MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty, CreateDateTime, CreateUserID)
    VALUES ('FERT', 'KÍCH_THƯỚC_SIZE_4_CHỮ_SỐ', NULL, NULL, 500, 4000, 8000, GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#61-lỗi-chưa-có-tiêu-chuẩn-đóng-gói-b523).

### Lỗi 2: Không gộp được Box Cell/Module do chưa có Lot, thiếu QC hoặc cờ F110
*   **Triệu chứng:** Hệ thống từ chối gộp box cho Lot tại **B523** hoặc **B525**.
*   **Nguyên nhân gốc:** Lot chưa được đánh giá QC Pass (`LotDecisionResult` rỗng/FAIL), hoặc mã vật tư chưa được bật các cờ quản lý Lot (`IsLotUse=1`, `IsUseBarcode=1`) tại F110.
*   **Cách khắc phục:**
    Chạy query kiểm tra 4 bước và sửa cờ thuộc tính hoặc cập nhật kết quả QC:
    ```sql
    -- Bước 1: Kéo cờ thuộc tính nếu thiếu
    UPDATE STB_MaterialStockAttributeInfo SET IsLotUse = 1, IsUseBarcode = 1 WHERE MaterialCode = 'MÃ_VẬT_TƯ';
    -- Bước 2: Cập nhật kết quả QC Pass tạm thời nếu khẩn cấp
    UPDATE STB_SetInfo SET LotDecisionResult = 'PASS', IsDefect = 0 WHERE Barcode = 'MÃ_BARCODE';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#64-lỗi-không-gộp-box-được-b523--quy-trình-debug-chuẩn).

### Lỗi 3: Lỗi Packing Qty hiển thị số âm hoặc sai lệch số lượng thực tế
*   **Triệu chứng:** Màn hình hiển thị số lượng đóng gói bị âm hoặc sai lệch nghiêm trọng.
*   **Nguyên nhân gốc:** Sai lệch lượng trừ kho ảo `CurrentQty` trong bảng `STB_MaterialLotInfo` hoặc sai bản ghi `STB_SavePackingTime_VVT`.
*   **Cách khắc phục:**
    Chạy script reset số lượng thực tế của Lot về giá trị đúng:
    ```sql
    UPDATE STB_MaterialLotInfo SET CurrentQty = [SỐ_LƯỢNG_ĐÚNG] WHERE LotNo = 'MÃ_LOT';
    UPDATE STB_SavePackingTime_VVT SET PackQty = [SỐ_LƯỢNG_ĐÚNG] WHERE LotNo = 'MÃ_LOT' AND id = [ID_GIAO_DỊCH];
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#66-lỗi-packing-qty-âm-ở-b523--b789).

---

## B530 — Route Input / Production Qty Output (Nhập sản lượng công đoạn)

### Lỗi 1: Lỗi cấm Scan nhanh dưới 20 phút (Gate 20 phút) bị lỗi/không chặn được
*   **Triệu chứng:** Hệ thống không thực hiện chặn được việc OP scan chốt công đoạn quá nhanh (dưới 20 phút).
*   **Nguyên nhân gốc:** Lỗi logic so sánh Null trong SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` dòng 218: `IF @SIExtInt01 = Null` (Trong SQL phải dùng `IS NULL`).
*   **Cách khắc phục:**
    ALTER SP sửa lại cú pháp so sánh Null chuẩn: `IF @SIExtInt01 IS NULL`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 2.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md#bug-1-gate-20-phút-không-bao-giờ-hoạt-động).

### Lỗi 2: OP báo lỗi không chốt được công đoạn, báo "Routing không có trong PO" hoặc "Đã hoàn thành thực tế rồi"
*   **Triệu chứng:** OP scan chốt sản lượng tại **B530** hệ thống báo lỗi không chốt được.
*   **Nguyên nhân gốc:** Do bỏ qua công đoạn trước đó chưa scan chốt, hoặc PO cấu hình sai thứ tự RoutingIndex.
*   **Cách khắc phục:**
    IT kiểm tra lịch sử quét Routing của Barcode bằng Golden Query để phát hiện công đoạn bị bỏ qua. Cho OP quay lại scan trạm trước, hoặc chèn dòng Routing giả lập để thông luồng (Xem phương pháp trace tại [KB_14 § 4.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md#44-lỗi-không-chốt-được-công-đoạn-màn-hình-b530)).

---

## B552 — Slitting Configurations (Thiết lập chia cuộn điện cực)

### Lỗi 1: Cảnh báo chặn "Không tồn tại thiết lập Điện cực... Chưa CONFIG trong bảng STB_SLITTINGLOCATIONCONFIG_VVT"
*   **Triệu chứng:** Khi thực hiện chia cuộn điện cực tại **B552**, hệ thống báo lỗi chặn không cho thực hiện giao dịch chia cuộn.
*   **Nguyên nhân gốc:** Chưa cấu hình thông số chiều rộng, cực dương (BY) và cực âm (YP) của mã hàng (PartNo) tương ứng trong bảng cấu hình chia cuộn `stb_slittinglocationconfig_vvt`.
*   **Cách khắc phục:** Chạy SQL chèn bổ sung cấu hình cho mã PartNo bị thiếu (BY = Cực dương, YP = Cực âm):
    ```sql
    INSERT INTO stb_slittinglocationconfig_vvt (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
    VALUES ('MÃ_PART_NO', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),
           ('MÃ_PART_NO', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#82-lỗi-chưa-config-trong-stb_slittinglocationconfig_vvt).

---

## B560 — Hela OutBox List (In tem thùng Hela)

### Lỗi 1: Lỗi in thiếu tem nhỏ (chỉ in 73/80 tem)
*   **Triệu chứng:** Khi in tem thùng Hela có quy cách 80 hộp nhỏ, hệ thống chỉ hiển thị `InBoxLabelCount = 73` và in thiếu tem.
*   **Nguyên nhân gốc:** Biến cục bộ `@InBoxLabelList` và cột tương ứng trong bảng `STB_HelaBarcodeOutBoxHist` khai báo kiểu dữ liệu `VARCHAR(1000)` quá ngắn, khiến chuỗi tem bị cắt cụt (truncation).
*   **Cách khắc phục:**
    1. Chạy ALTER TABLE đổi cột `InBoxLabelList` thành `VARCHAR(MAX)`.
    2. ALTER Stored Procedure `usp_DoCreateHelaInBoxBarcodeList` đổi biến `@InBoxLabelList` thành `VARCHAR(MAX)`.
    3. Update khôi phục lại chuỗi tem đầy đủ cho các Lot bị lỗi.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.14](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#614-lỗi-cắt-chuỗi-danh-sách-tem-nhỏ-b560---truncation-in-inboxlabellist).

---

## B597 — Material Scanning & PQC Verification (Scan nguyên vật liệu đầu vào chuyền)

### Lỗi 1: Cảnh báo đỏ chặn không cho lưu Lot NVL đầu vào (HOLD, Hết hạn, Sai chủng loại)
*   **Triệu chứng:** Khi quét mã Lot nguyên liệu đầu vào tại **B597**, hệ thống báo lỗi đỏ cấm sử dụng.
*   **Nguyên nhân gốc:** Lot đang nằm ở kho ảo `HOLDING_WH` (chưa QC), hoặc ngày hết hạn sử dụng vượt quá ngày hiện tại (vi phạm FIFO/Expiry), hoặc mã nguyên liệu không nằm trong BOM cấu hình của PO.
*   **Cách khắc phục:**
    1. Check QC: Yêu cầu QC PASS hoặc chuyển kho Lot về kho chính `ROH_WH` bằng SQL.
    2. Bypass gia hạn dùng tạm thời (Ghi nhận biên bản audit): UPDATE ngày tạo `CreateDateTime` lùi lại hoặc chạy lệnh bỏ qua FIFO.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#7-lỗi-quét-nguyên-vật-liệu-b597--pqc-check).

### Lỗi 2: Lỗi quét vỏ nhôm (AluCase) mới báo sai chủng loại tại B597
*   **Triệu chứng:** Quét mã vỏ nhôm mới hệ thống báo lỗi chặn đứng sản xuất.
*   **Nguyên nhân gốc:** Logic kiểm tra vỏ nhôm không nằm trong DB cấu hình mà bị hardcode trực tiếp trong SP `usp_Vietnam_RawMaterialInputHist_uid`.
*   **Cách khắc phục:**
    ALTER SP `usp_Vietnam_RawMaterialInputHist_uid` để bổ sung mã vỏ nhôm mới vào khối điều kiện `IF / NOT IN`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#74-lỗi-vỏ-nhôm-alucase).

---

## B598 — Material Scrap Report (Báo phế nguyên vật liệu trên chuyền)

### Lỗi 1: Báo phế NVL bị lỗi không ghi nhận hệ thống
*   **Triệu chứng:** Báo phế NVL tại chuyền ở màn hình **B598** bị chặn hoặc không đồng bộ số lượng.
*   **Nguyên nhân gốc:** Lệch ngày `JobDate` giữa ca sản xuất thực tế và ngày khai báo kế hoạch trên MES.
*   **Cách khắc phục:**
    Chạy query cập nhật điều chỉnh `JobDate` của Lot kế hoạch ngày khớp với thực tế để mở luồng ghi nhận phế.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.12](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md#612-b598-báo-phế-nvl-sửa-jobdate-đặc-biệt).

---

## B618 — Rework (Làm lại sản phẩm)

### Lỗi 1: Không có quyền thao tác trên giao diện Rework B618
*   **Triệu chứng:** Công nhân không thể thực hiện quét/xác nhận làm lại sản phẩm lỗi tại chuyền.
*   **Nguyên nhân gốc:** SP `usp_Vietnam_GetLotInfoForRework_VNT` bị hardcode kiểm tra Whitelist UserID.
*   **Cách khắc phục:**
    Sửa SP để bổ sung thêm UserID của OP hiện hành vào danh sách Whitelist cho phép thao tác Rework.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md § 2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md#2-lỗi-phân-quyền-màn-hình-rework-b618).

---

## B717 — Bending & Tapping (Uốn chân & Dán băng keo Cell)

### Lỗi 1: Nhập sai thông số uốn/dán tại B717 không thể sửa hoặc xóa trực tiếp trên giao diện
*   **Triệu chứng:** OP nhập nhầm số lượng, sai kích thước hoặc thông số uốn dán tại **B717**, không thấy nút Edit hay Delete trên UI để chỉnh sửa lại.
*   **Nguyên nhân gốc:** Hệ thống chỉ được thiết kế để ghi nhận 1 lần (Insert hoặc Override) và không hỗ trợ tính năng sửa/xóa giao dịch trên client app.
*   **Cách khắc phục:** IT kiểm tra và chạy script SQL update trực tiếp sản lượng hoặc xóa bản ghi giao dịch sai trong bảng tương ứng để OP quét lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 5 (Mục 3)](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md#5-⚠️-5-điểm-nguy-hiểm-ẩn--developer-phải-biết).

---

## B682 / B781 / B786 / B789 / B791 — Stage Prices (Quản lý giá công đoạn)

### Lỗi 1: Đơn giá công đoạn sản xuất bị hiển thị trống (Null)
*   **Triệu chứng:** Lưới dữ liệu sản lượng hiển thị đơn giá bằng 0 hoặc trống, không tính được lương/hiệu suất.
*   **Nguyên nhân gốc:** Model sản phẩm chưa được khai báo đơn giá tương ứng với công đoạn và mã nhà máy (`WorkCenterCode`) trong bảng thiết lập Stage Prices.
*   **Cách khắc phục:**
    Khai báo bổ sung đơn giá cho Model sản phẩm vào bảng `STB_VVT_StagePrices` tương ứng:
    ```sql
    INSERT INTO STB_VVT_StagePrices (model, WorkCenterCode, RouteV22, PriceV22...)
    VALUES ('MÃ_MODEL', 'MÃ_NHÀ_MÁY', 'ROUTE_CODE', ĐƠN_GIÁ);
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#3-fix-giá-công-đoạn-stage-prices).

---

## B754 / B756 — PAC Customer Labels (In tem nhãn khách hàng PAC)

### Lỗi 1: Lỗi in tem thùng nhãn ngoài (Outer Label) không hiển thị đúng Serial hoặc cân nặng
*   **Triệu chứng:** In tem thùng lớn tại B756 báo lỗi thiếu Serial nhãn hoặc không hiển thị trọng lượng thực tế.
*   **Nguyên nhân gốc:** Không tích chọn cờ `IsOuter = 1` khi in nhãn ngoài (Outer) dẫn đến hệ thống hiểu nhầm là nhãn trong (Inner), hoặc chưa bật chế độ `IsWeightLabel`.
*   **Cách khắc phục:**
    1. Nhắc nhở công nhân tick chọn `IsOuter` khi in nhãn ngoài thùng (Outer) vì nhãn trong và nhãn ngoài chạy Serial độc lập.
    2. Khi in tem cân nặng, tick chọn `IsWeightLabel` trước khi nhấn nút.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.9.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#691-in-tem-khách-hàng-pac-b754--b755--b756).

---

## B757 / B758 — Digi-Key Customer Labels (In tem nhãn khách hàng Digi-Key)

### Lỗi 1: Lỗi in nhãn Logistic tại B757 bị chặn báo thiếu thông tin
*   **Triệu chứng:** Bấm "IN NHÃN LOGISTIC" hệ thống báo lỗi không in được.
*   **Nguyên nhân gốc:** Chưa nhập đủ các trường bắt buộc gồm: PO Number, PO Line Number, Pack List Number.
*   **Cách khắc phục:**
    1. Yêu cầu nhập đầy đủ thông số PO và số dòng PO tương ứng trước khi in.
    2. Nếu in cho thùng hàng hỗn hợp (Mixed Load), chuyển sang sử dụng màn hình **B758**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.9.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#692-in-tem-khách-hàng-digi-key-b757--b758).

---

## B790 — Phoenix Contact Labels (Thiết kế/In tem Phoenix Contact)

### Lỗi 1: Tem in ra Phoenix Contact bị sai định dạng ngày Datecode
*   **Triệu chứng:** Tem Phoenix Contact in ra tại màn hình **B790** hiển thị sai định dạng ngày (không phải định dạng YYMMDD yêu cầu).
*   **Nguyên nhân gốc:** Cột `InputJobDate` trong bảng `STB_SetInfo` bị null hoặc lưu sai định dạng ngày khiến SP `usp_Vietnam_PhoenixContactLabelPrint_get` trích xuất datecode bị lỗi.
*   **Cách khắc phục:**
    Chạy script kiểm tra `InputJobDate` và cập nhật lại ngày đúng cho Barcode bị lỗi:
    ```sql
    -- Sửa ngày bắt đầu sản xuất cho Lot
    UPDATE STB_SetInfo SET InputJobDate = '2026-06-12' WHERE Barcode = 'MÃ_BARCODE';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#610-thiết-kế-tem-phoenix-contact-yêu-cầu-đặc-biệt-tại-b790).

---

## B802 — Electrode Production History (Báo cáo & Đối soát điện cực)

### Lỗi 1: Sai lệch số lượng/mã cuộn điện cực thực tế so với báo cáo B802
*   **Triệu chứng:** Khi mở báo cáo lịch sử sản xuất điện cực trên **B802**, số lượng cuộn hoặc tổng số mét sản xuất thực tế bị lệch so với dữ liệu chốt công đoạn.
*   **Nguyên nhân gốc:** Bỏ qua việc quét/chốt các công đoạn bán thành phẩm điện cực (Coating/Slitting) hoặc do sai lệch giá trị `ProdQty` trong bảng `STB_ProdRouteHist` của điện cực.
*   **Cách khắc phục:** IT tiến hành đối soát thông tin qua bảng lịch sử điện cực `STB_ElectrodeProdRouteHist` và điều chỉnh lại sản lượng thực tế khớp với số mét cuộn.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md#611-b802---vietnam-electrode-prod-route-hist-lịch-sử-sx-điện-cực) và [KB_05_QC_ELECTRODE.md § 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#3-báo-cáo--đối-soát-điện-cực-b802).

---

## C121 / C122 — QC Inspections (Cấu hình QC đầu vào)

### Lỗi 1: Lot nguyên liệu nhập kho không tự động hiển thị các hạng mục kiểm tra QC
*   **Triệu chứng:** Lot nguyên liệu hiển thị trên lưới QC nhưng không có bất kỳ hạng mục nào để nhập kết quả đo.
*   **Nguyên nhân gốc:** Chưa gán mã nguyên vật liệu vào nhóm hạng mục kiểm tra IQC tại màn hình **C122** hoặc chưa cấu hình nhóm kiểm tra tại **C121**.
*   **Cách khắc phục:**
    1. Vào **C121** thêm nhóm kiểm tra và các hạng mục chi tiết.
    2. Vào **C122**, chọn mã nguyên vật liệu và click chọn nhóm kiểm tra tương ứng để map dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#91-iqc-incoming-quality-control--kiểm-tra-nvl-đầu-vào).

---

## C220 — IQC Incoming Quality Control (Xác nhận kết quả IQC)

### Lỗi 1: Lỗi bị chặn "Receiving Confirmation" khi gộp nhập kho tại F330
*   **Triệu chứng:** Thủ kho bấm nhận hàng tại **F330** hệ thống báo lỗi chặn giao dịch.
*   **Nguyên nhân gốc:** Kết quả kiểm tra mẫu IQC của Lot hàng tại màn hình **C220** vẫn ở trạng thái chờ đánh giá hoặc đã bị đánh giá FAIL.
*   **Cách khắc phục:**
    Yêu cầu bộ phận QC hoàn thành nhập kết quả đo và xác nhận cờ chất lượng PASS cho Lot hàng trên màn hình **C220**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.15](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md#415-luồng-nhập-kho-đầy-đủ-f330).

---

## C321 / HNC321 — Defect Repair & Scrap Management (Quản lý sửa chữa & báo phế sản phẩm)

### Lỗi 1: Lỗi chặn lưu "이전 공정에 실적처리 이력이 없습니다" (Không có lịch sử công đoạn trước) tại HNC321
*   **Triệu chứng:** Khi OP nhập số lượng phế cho Barcode tại trạm kiểm tra (Ví dụ: `VE08`), hệ thống chặn lại và báo lỗi tiếng Hàn.
*   **Nguyên nhân gốc:** Stored Procedure `usp_Vietnam_ScrapInput_HN` chặn giao dịch nếu sản phẩm chưa từng có lịch sử chốt sản lượng (Routing History) ở công đoạn ngay trước đó (Ví dụ: `VE07`).
*   **Cách khắc phục:** IT kiểm tra công đoạn trước và chèn một dòng Routing giả lập để thông luồng:
    ```sql
    BEGIN TRANSACTION;
    DECLARE @CtrlNo NVARCHAR(50) = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE');
    INSERT INTO STB_ProdRouteHist 
        (ControlNo, ProcSeq, RouteCode, LineCode, MachineCode, InQty, OutQty, JobDate, ShiftCode, CreateUserID, CreateDateTime)
    VALUES 
        (@CtrlNo, 
         (SELECT ISNULL(MAX(ProcSeq), 0) + 1 FROM STB_ProdRouteHist WHERE ControlNo = @CtrlNo), 
         'MÃ_CÔNG_ĐOẠN_TRƯỚC',  -- Ví dụ: VE07
         'MÃ_LINE_HIỆN_TẠI', 'MÃ_MÁY_HIỆN_TẠI', 20, 20, CAST(GETDATE() AS DATE), 'A', 'vinaadmin', GETDATE());
    COMMIT TRANSACTION;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md#4-lỗi-màn-hnc321-qc-nhập-ng-sản-phẩm-mang-đi-kiểm-tra--báo-lỗi-chữ-hàn-quốc) và [KB_14_TRACE_BUG_METHODOLOGY.md § 4.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md#46-lỗi-nhập-phế-màn-hnc321-báo-lỗi-tiếng-hàn-이전-공정에-실적처리-이력이-없습니다).

### Lỗi 2: Nhập phế/sửa chữa tại C321 báo lỗi hoặc không cập nhật được thông số sửa chữa
*   **Triệu chứng:** OP không lưu được thông tin sửa chữa/vật tư thay thế, hoặc bị sai lệch số lượng NG (`DefectQty`) ở các trạm tiếp theo.
*   **Nguyên nhân gốc:** Lỗi khi đồng bộ dữ liệu giữa bảng thông tin lỗi `STB_DefectRepairInfo` và số lượng chốt sản lượng của công đoạn.
*   **Cách khắc phục:** IT kiểm tra thông số và cập nhật đồng bộ lại cột `DefectQty` hoặc `ProdQty` bằng cách chỉnh sửa trực tiếp DB.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#95-c321---pqc-reliability-assy-sửa-chữa-lỗi-cell-line).

---

## C443 — PQC Quality Verification (Hủy/xác định lại kết quả QC)

### Lỗi 1: Cần hủy kết quả kiểm tra QC (nhập nhầm thông số hoặc load nhầm hạng mục đo)
*   **Triệu chứng:** Lot sản phẩm bị lock trạng thái FAIL do QC lưu sai thông số đo, cần mở ra đo lại từ đầu.
*   **Nguyên nhân gốc:** Dữ liệu QC đã được ghi nhận vào các bảng giao dịch `STB_CommInspDocHistory` và `STB_CommInspDocItem` nên không thể sửa đổi trên UI.
*   **Cách khắc phục:** Chạy SQL xóa tài liệu QC bị sai để QC có thể thực hiện kiểm định lại từ đầu trên giao diện:
    ```sql
    BEGIN TRANSACTION;
    DECLARE @DocNo NVARCHAR(50) = (SELECT CIDH.CommInspDocNo FROM STB_CommInspDocHistory CIDH JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo WHERE SI.Barcode = 'MÃ_BARCODE');
    DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = @DocNo;
    DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = @DocNo;
    COMMIT TRANSACTION;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.2 (Kịch bản B)](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md#42-kịch-bản-b-hủy-kết-quả-kiểm-tra-chất-lượng-qc-b597--c443).

---

## C486 — QC Measuring Items (Đo kích thước điện cực)

### Lỗi 1: Thừa cột Note1 trên lưới dữ liệu / thứ tự cột nhập liệu bị xáo trộn
*   **Triệu chứng:** Giao diện grid nhập liệu đo kích thước điện cực tại màn hình **C486** bị lỗi thừa cột rác hoặc các dòng nhập liệu không đúng thứ tự.
*   **Nguyên nhân gốc:** Lỗi cấu hình metadata của grid trong DB `SmartFramework`.
*   **Cách khắc phục:**
    Chạy lệnh SQL để rebuild lại cấu trúc grid của màn hình:
    ```sql
    -- Script reset metadata layout cho grid C486
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.8](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#78-cột-note1-thừa-trên-grid-c486-và-logic-rebuild-bảng).

---

## C512 / C530 / C546 — OQC Lot Management (Quản lý chất lượng đầu ra)

### Lỗi 1: Lỗi không tìm thấy Lot khi tạo hồ sơ kiểm tra OQC ở C512
*   **Triệu chứng:** Bấm tạo Lot OQC tại **C512** hệ thống báo không tìm thấy bản ghi Lot nào của sản phẩm.
*   **Nguyên nhân gốc:** Lot sản phẩm chưa hoàn thành công đoạn đóng gói cuối (chưa gộp Box tại B523) hoặc PO chưa cấu hình cờ đầu ra sản phẩm `IsOutputRoute = 1`.
*   **Cách khắc phục:**
    1. Kiểm tra Lot đã được quét gộp box tại B523 chưa.
    2. Sửa cờ `IsOutputRoute = 1` cho công đoạn cuối của PO trong `STB_ProductionOrderRouting` nếu cấu hình BOM/Routing bị thiếu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#72-không-tìm-thấy-lot-ở-màn-c512).

### Lỗi 2: Đo OQC OCV/ESR tại C546 chỉ hiển thị 20 dòng thay vì 50 dòng
*   **Triệu chứng:** Máy đo trả về kết quả cho 50 mẫu test nhưng trên giao diện C546 hệ thống chỉ load và hiển thị 20 dòng mẫu.
*   **Nguyên nhân gốc:** Số lượng dòng mẫu (`SampleQty`) cấu hình trong bảng `STB_MaterialQcDetail` bị lệch so với dữ liệu đo thực tế được upload ngầm từ máy đo vào bảng Monitor `Stb_ESRValueMonitor`.
*   **Cách khắc phục:**
    Chạy script rollback kết quả QC bị lỗi, đồng thời reset lại cờ upload để máy đo đẩy lại đầy đủ dữ liệu:
    ```sql
    -- 1. Xóa chi tiết QC bị lệch
    DELETE FROM STB_MaterialQcSampleResult WHERE MaterialQcNo = 'F_MÃ_BARCODE';
    -- 2. Reset trạng thái upload trong Monitor để đẩy lại dữ liệu
    UPDATE Stb_ESRValueMonitor SET UploadToMes = 0, UploadOCVToMess = 0 WHERE lotno = 'MÃ_BARCODE';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#96-c546-foqc-ocvsr-chỉ-hiển-thị-20ea-thay-vì-50ea-ocv-lệch-dữ-liệu).

---

## C561 / C562 / C563 / C564 — Bending/Cutting QC (Kiểm tra chất lượng uốn/cắt Cell)

### Lỗi 1: Quét Barcode tại C563 báo lỗi thiếu hạng mục đo hoặc không hiển thị thông số đo
*   **Triệu chứng:** Khi mở màn hình kiểm định uốn/cắt **C563** và quét barcode của mẫu uốn/cắt Cell, lưới đo trống trơn hoặc báo lỗi chặn.
*   **Nguyên nhân gốc:** Model sản phẩm chưa được cấu hình nhóm hạng mục kiểm tra QC tại **C561** hoặc chưa được tạo Lot kiểm định tại **C562**.
*   **Cách khắc phục:**
    1. Vào màn hình **C561**, tìm đúng `MaterialCode`, chọn nhóm kiểm tra và Lưu lại.
    2. Vào màn hình **C562**, quét barcode sản phẩm để sinh Lot kiểm định.
    3. Quay lại màn hình **C563** thực hiện nhập dữ liệu. Nếu đã cấu hình mà vẫn trống, nhấn nút `"Tổng hợp hạng mục"` để đồng bộ và làm mới danh sách đo.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#94-bendingcutting-qc-c561c564).

---

## F110 — Operating Properties (Cấu hình thuộc tính quản lý tồn kho)

### Lỗi 1: Vật tư mới không thực hiện gộp Box được tại B523 hoặc B525
*   **Triệu chứng:** Khi công nhân quét gộp Box tại chuyền sản xuất, hệ thống báo lỗi chặn giao dịch do thiếu Lot hoặc cờ Barcode của mã vật tư đó.
*   **Nguyên nhân gốc:** Bảng cấu hình thuộc tính quản lý kho `STB_MaterialStockAttributeInfo` chưa được tạo dòng cho mã vật tư mới, hoặc các cờ quản lý `IsLotUse`, `IsUseBarcode` đang bị tắt (bằng 0).
*   **Cách khắc phục:** Vào màn hình **F110**, tìm mã vật tư, tick chọn `IsLotUse` và `IsUseBarcode` rồi nhấn Lưu. Hoặc chạy SQL cập nhật trực tiếp:
    ```sql
    UPDATE STB_MaterialStockAttributeInfo SET IsLotUse = 1, IsUseBarcode = 1 WHERE MaterialCode = 'MÃ_VẬT_TƯ';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md#2-cấu-hình-vận-hành-f110).

---

## F130 / F140 / A210 — Supplier Mapping & Material Sync (Luồng tích hợp nhà cung cấp & đồng bộ vật tư)

### Lỗi 1: Popup chọn Nhà cung cấp trống không khi tạo phiếu nhập kho ở F312
*   **Triệu chứng:** Thủ kho tạo phiếu nhập kho tại **F312** nhưng khi mở popup chọn nhà cung cấp thì danh sách trống rỗng.
*   **Nguyên nhân gốc:** Nhà cung cấp chưa được mapping liên kết được phép cung cấp mã vật tư tương ứng trong bảng `STB_MaterialVendorMapping` (Màn hình **F130** hoặc **F140**).
*   **Cách khắc phục:** Vào màn hình **F130** (chọn NCC, tick chọn các vật tư được phép cung cấp) hoặc **F140** (chọn vật tư, tick chọn NCC được phép mua) rồi nhấn Lưu. Hoặc chạy SQL chèn trực tiếp:
    ```sql
    INSERT INTO STB_MaterialVendorMapping (MaterialCode, VendorCode, IsUsed, CreateDateTime, CreateUserID)
    VALUES ('MÃ_VẬT_TƯ', 'MÃ_NCC', 1, GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_07_GROUPWARE_INTEGRATION.md § 6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07_GROUPWARE_INTEGRATION.md#6-chỉ-định-ncc--nvl-f130--f140).

---

## F330 — Goods Receipt & Part Labels (Nhập kho nguyên vật liệu)

### Lỗi 1: Báo lỗi "Exception occurred" khi lưu phiếu nhập kho
*   **Triệu chứng:** Thủ kho nhập thông tin và click Lưu phiếu tại **F330** hệ thống văng popup báo lỗi Exception.
*   **Nguyên nhân gốc:** Trường `LotAttr10` (Đặc tính 10 / Ngày sản xuất Vendor) bị Null hoặc do định dạng quét mã Lot nhà cung cấp in quá dài vượt quá giới hạn thiết lập của trường.
*   **Cách khắc phục:**
    1. Cấu hình lại chiều dài quét cắt chuỗi mã Lot Vendor trên tab 3 giao diện F330.
    2. Sửa SQL Function parse ngày SX `fn_VVT_getdatebyVendorLot_MergeCode` nếu NCC thay đổi định dạng in Lot trên tem (Xem chi tiết tại [KB_02 § 4.11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md#411-lỗi-không-lưu-được-f330---cấu-hình-và-sửa-lỗi-đọc-đặc-tính-10-vendor-lot-no)).

### Lỗi 2: Cần hủy/xóa phiếu nhập kho F330 đã được Xác nhận (Confirmed)
*   **Triệu chứng:** Thủ kho click xác nhận nhập nhầm số lượng/mã hàng và cần hủy phiếu nhập kho.
*   **Nguyên nhân gốc:** Giao dịch đã Confirmed và sinh LotInfo nên không thể xóa trực tiếp trên giao diện UI.
*   **Cách khắc phục:**
    Chạy SQL Script xóa theo thứ tự ngược (xóa IQC trước nếu có, sau đó xóa LotInfo, DocLotInfo, DocDetail và cuối cùng là DocInfo) để tránh vi phạm khóa ngoại FK:
    ```sql
    -- Hủy phiếu nhập F330
    DELETE FROM STB_MaterialLotInfo WHERE LotID IN (SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'MÃ_PHIẾU');
    DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'MÃ_PHIẾU';
    DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = 'MÃ_PHIẾU';
    DELETE FROM STB_MaterialDocInfo WHERE MaterialDocNo = 'MÃ_PHIẾU';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.16](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md#416-hủy-phiếu-nhập-kho-f330-đã-confirmed).

---

## F430 — Goods Issue / Production Material Request (Xuất kho ra chuyền)

### Lỗi 1: Chặn quét xuất kho báo lỗi vi phạm nguyên tắc FIFO
*   **Triệu chứng:** Quét xuất Lot NVL ra chuyền tại **F430** hệ thống chặn và báo lỗi vi phạm FIFO (Lot nhập sau không được xuất trước).
*   **Nguyên nhân gốc:** Bật cờ `IsFIFO = 1` tại F110 và SP `usp_VVTMaterialWarehouse_validFIFO` phát hiện có Lot khác cùng mã có ngày nhập kho `CreateDateTime` cũ hơn đang tồn kho.
*   **Cách khắc phục:**
    1. Yêu cầu thủ kho tìm đúng Lot cũ nhất trong kho để xuất trước.
    2. Trường hợp khẩn cấp (hàng cũ bị hỏng hoặc thất lạc chưa kiểm kê), IT có thể bypass bằng cách lùi ngày tạo `CreateDateTime` của Lot hiện tại trên DB, hoặc tạm thời tắt check FIFO của mã vật tư đó bằng cách update cờ `IsFIFO = 0` tại bảng `STB_MaterialStockAttributeInfo`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.9](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md#49-fifo--validation-nvl-tắtbật-chặn).

### Lỗi 2: Cần thu hồi Lot nguyên liệu đã xuất nhầm lên chuyền (Revert xuất kho)
*   **Triệu chứng:** Lot hàng đã bấm xuất ra chuyền tại F430 nhưng công nhân không chạy và cần trả lại kho gốc ROH.
*   **Nguyên nhân gốc:** Giao dịch xuất kho đã chèn log lịch sử vào bảng `STB_MaterialWarehouseInOutHist` và cập nhật kho ảo trên chuyền.
*   **Cách khắc phục:**
    Sử dụng Transaction xóa dòng log giao dịch và cập nhật kéo Lot về kho vật lý ban đầu:
    ```sql
    BEGIN TRAN;
    DELETE FROM STB_MaterialWarehouseInOutHist WHERE LotID = 'MÃ_LOT' AND MaterialWarehouseInOutHistNo = 'MÃ_GIAO_DỊCH_XUẤT_SAI';
    UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode = 'ROH_HN_WH', MaterialLocationCode = 'ROH_HN_WH_01' WHERE LotID = 'MÃ_LOT';
    COMMIT TRAN;
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.17](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md#417-thu-hồi-lot-từ-f430-về-kho-revert-xuất-kho).

---

## F721 — WMS Material Stock (Tồn kho nguyên vật liệu)

### Lỗi 1: Tồn kho của Lot bị treo ở trạng thái HOLD (không xuất được sản xuất)
*   **Triệu chứng:** Lot hàng hiển thị tồn kho đầy đủ tại màn hình **F721** nhưng khi quét ở F430 báo lỗi HOLD cấm xuất.
*   **Nguyên nhân gốc:** Do Lot đang ở kho ảo `HOLDING_WH` (hoặc `HOLDING_VN_WH`, `HOLDING_HN_WH`) do QC chưa đánh giá hoặc do hệ thống tự động đưa vào vì thiếu Đặc tính 10 lúc nhập kho.
*   **Cách khắc phục:**
    Kiểm tra chất lượng mẫu đo. Nếu QC đã PASS thực tế, chạy script chuyển kho thủ công kéo Lot về kho chính ROH:
    ```sql
    UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode = 'ROH_HN_WH', MaterialLocationCode = 'ROH_HN_WH_01' WHERE LotID = 'MÃ_LOT';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md#47-chuyển-từ-kho-holding-sang-kho-chính).

---

## F741 — Lot Splitting (Quy trình tách Lot NVL)

### Lỗi 1: Lỗi không thực hiện tách được Lot NVL trên giao diện
*   **Triệu chứng:** OP thao tác chia nhỏ Lot NVL tại **F741** báo lỗi không in được tem hoặc sai số lượng chia.
*   **Nguyên nhân gốc:** Thiết lập quy cách đóng gói và cờ thuộc tính Lot tại F110 bị thiếu.
*   **Cách khắc phục:**
    Kiểm tra và thực hiện cấu hình đúng quy trình tách Lot trên UI, đảm bảo số lượng của các Lot con tổng cộng bằng Lot mẹ (Xem chi tiết tại [KB_02_KHO_WMS.md § 4.20](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md#420-f741--quy-trình-tách-lot-nguyên-vật-liệu-lot-splitting)).

---

## F742 / F746 — Slitting & Curling (Chia cuộn điện cực / Bo miệng)

### Lỗi 1: Cần hủy hoặc rollback giao dịch chia cuộn Slitting
*   **Triệu chứng:** Công nhân nhập sai thông số số lượng/chiều dài cuộn con sau chia cuộn Slitting tại **F742** và cần hoàn tác giao dịch.
*   **Nguyên nhân gốc:** Giao dịch đã sinh các Lot con liên kết khóa ngoại với Lot mẹ.
*   **Cách khắc phục:**
    Chạy script xóa ngược: bắt buộc phải tìm và xóa các bản ghi giao dịch của các Lot con trong bảng `STB_RawMaterialInputHist` (hoặc `STB_MaterialDocLotInfo` tùy trạm) trước, sau đó mới tiến hành xóa/revert Lot mẹ tại F742.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 10.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#101-hủyrollback-slitting-f742-và-f746).

---

## F743~F748 / C243 — Electrode Slitting & QC (Slitting & QC Điện cực Hà Nam)

### Lỗi 1: Cảnh báo "Trùng mã nguyên liệu" khi thiết lập chiều rộng cắt ở F744
*   **Triệu chứng:** Khai báo chiều rộng cắt cho Model mới tại **F744** bị hệ thống báo lỗi trùng mã và từ chối lưu.
*   **Nguyên nhân gốc:** Bản ghi cấu hình chiều rộng cho mã vật liệu tương ứng đã tồn tại trong bảng cấu hình master.
*   **Cách khắc phục:** Kiểm tra lại danh sách cấu hình hiện tại để chỉnh sửa trực tiếp thông số `Width` của bản ghi cũ thay vì tạo mới.

### Lỗi 2: Lỗi "Lot không tồn tại" khi quét xuất kho điện cực tại F430
*   **Triệu chứng:** Quét mã Lot cuộn điện cực sau khi slitting tại **F430** để xuất lên chuyền sản xuất bị báo lỗi Lot không tồn tại.
*   **Nguyên nhân gốc:** Lô hàng sau khi chốt slitting tại **F743** chưa được bộ phận QC tiến hành kiểm định và xác nhận PASS tại màn hình **C243**.
*   **Cách khắc phục:** QC truy cập màn hình **C243**, tìm Lot điện cực tương ứng, thực hiện kiểm định và xác nhận kết quả chất lượng PASS để Lot được kích hoạt tồn kho.

### Lỗi 3: Cần hủy hoặc rollback kết quả chia cuộn Slitting để cắt lại tại F743
*   **Triệu chứng:** OP nhập sai thông số chiều dài/số lượng cuộn con khi chia cuộn và cần rollback để thực hiện lại từ đầu.
*   **Nguyên nhân gốc:** Giao dịch chốt Slitting đã ghi nhận các Lot con vào bảng lịch sử.
*   **Cách khắc phục:** OP truy cập màn hình lịch sử slitting **F746**, tìm và xóa bỏ các dòng lịch sử của Lot con tương ứng trước, sau đó mới có thể thực hiện rollback/xóa Lot mẹ tại màn hình rollback **F742**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 10.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md#101-flow-slitting-hà-nam).

---

## F750 — Stocktaking (Kiểm kê kho vật tư)

### Lỗi 1: Cảnh báo "Nguyên liệu phải được xuất kho lên Line trước khi chia nhỏ..." khi tách lô giá đỡ / chất mang (Substrate)
*   **Triệu chứng:** Khi chạy tác vụ chia/tách lô vật liệu giá đỡ substrate, hệ thống hiển thị thông báo lỗi chặn giao dịch (bằng tiếng Hàn hoặc tiếng Việt).
*   **Nguyên nhân gốc:** Lô vật liệu gốc chưa được thực hiện xuất kho lên chuyền sản xuất (chưa nằm ở kho công đoạn có cờ `IsRouteWarehouse = 1` mà vẫn đang tồn ở kho chính ROH), vi phạm điều kiện kiểm tra của Stored Procedure `usp_DoMakeStocktakingPlanResultForSupport`.
*   **Cách khắc phục:** Thủ kho thực hiện xuất kho Lot vật liệu gốc lên chuyền sản xuất trước (qua màn hình **F430**), sau đó mới thực hiện thao tác chia tách lô trên giao diện UI.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md § 5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md#5-nghiên-cứu-điển-hình-tự-động-tách-lô-giá-đỡ-substrate-splitting-case-study).

---

## F761 — Material GR History (Lịch sử vật tư vào kho)

### Lỗi 1: Lệch số liệu báo cáo đối soát kho kế toán do hiểu nhầm giao dịch hiển thị chữ tiếng Hàn
*   **Triệu chứng:** Khi đối soát số liệu xuất nhập kho tại **F761**, kế toán phát hiện các dòng giao dịch có cột `DocTypeName` chứa ký tự chữ Hàn Quốc gây sai lệch số liệu nhập mới.
*   **Nguyên nhân gốc:** Ký tự tiếng Hàn đại diện cho loại giao dịch "hoàn trả vật tư thừa từ sản xuất về kho ROH" (Revert từ F430) chứ không phải nhập mới từ nhà cung cấp.
*   **Cách khắc phục:** Hướng dẫn bộ phận kế toán phân biệt loại giao dịch: Giao dịch có tên tiếng Hàn là giao dịch trả hàng ảo/revert từ sản xuất về, còn giao dịch nhập mới thực tế được sinh ra từ phiếu nhập **F312**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md#5-báo-cáo-tồn-kho--lịch-sử-kho-f721-f761-f740).

---

## H301~H305 — Spare Parts Management (Quản lý kho & tuổi thọ phụ tùng)

### Lỗi 1: Phụ tùng máy bị mòn/hỏng thực tế nhưng hệ thống không cảnh báo hoặc chặn không cho thay thế
*   **Triệu chứng:** Phụ tùng trên line bị mòn nhưng hệ thống MES không hiển thị cảnh báo đỏ hoặc không cho phép quét barcode để xuất phụ tùng thay mới.
*   **Nguyên nhân gốc:** Chưa thiết lập hoặc khai báo sai chu kỳ thay thế định mức (`CycleReplace` theo ngày) và tuổi thọ chạy Lot (`LifeLotQty`) của phụ tùng tại **H301** (`STB_VNSparePartInfo`), hoặc Lot phụ tùng chưa được nhập kho tại **H302**.
*   **Cách khắc phục:**
    1. Kiểm tra tồn kho phụ tùng tại màn hình **H304** / **H302**.
    2. Truy cập màn hình **H301**, cấu hình đầy đủ `CycleReplace` và `LifeLotQty` cho mã phụ tùng tương ứng.
    3. Thực hiện xuất phụ tùng lên chuyền tại **H303** và theo dõi lịch sử thay thế tại **H305**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.15](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md#615-spare-part--h301h302h303h305) và [KB_20_MAY_MOC_BAO_TRI.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_20_MAY_MOC_BAO_TRI.md).

---

## HN00 / HN101 — Hà Nam Accounting (Tồn kho & Đơn giá Hà Nam)

### Lỗi 1: Báo cáo tồn kho thành phẩm Hà Nam HN00 hiển thị Đơn giá bằng 0
*   **Triệu chứng:** Lưới báo cáo tồn kho HN00 hiển thị số lượng đúng nhưng cột Đơn giá và Thành tiền bị trống hoặc bằng 0.
*   **Nguyên nhân gốc:** Model sản phẩm mới chưa được khai báo đơn giá kế toán tương ứng tại màn hình **HN101** để mapping tính toán.
*   **Cách khắc phục:**
    Vào màn hình **HN101** thêm dòng thiết lập đơn giá mới cho Model, hoặc chạy script chèn trực tiếp:
    ```sql
    INSERT INTO STB_HN_AccountingPrice (MaterialCode, AccountingCode, Price, CreateDateTime, CreateUserID)
    VALUES ('MÃ_MODEL_MỚI', 'MÃ_KẾ_TOÁN', ĐƠN_GIÁ_USD, GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md#7-hn101--thiết-lập-đơn-giá-theo-mã-kế-toán).

---

## HN523 / HN544 — Custom Matching & Merge (Gộp box túi nilon / Gộp tùy chỉnh Hà Nam)

### Lỗi 1: Khi bấm gộp box tùy chỉnh ở HN544 báo lỗi "Column LotID is constrained to be unique"
*   **Triệu chứng:** OP nhập Packing ID tại màn hình **HN544** nhấn Tìm kiếm hệ thống crash báo lỗi trùng lặp khóa chính LotID: `Value '...' is already present`.
*   **Nguyên nhân gốc:** Stored Procedure `usp_GetMaterialLotInfo_Packing_VVT_F3` sử dụng `UNION ALL` gộp 3 truy vấn, trong đó truy vấn thứ 3 thực hiện JOIN với bảng chia tách `STB_DividePackaging` bị sai logic khi có mã cha chưa phân tách (PackingParentID = NULL), trả về dòng dummy có LotID bị null/duplicate.
*   **Cách khắc phục:**
    ALTER Stored Procedure `usp_GetMaterialLotInfo_Packing_VVT_F3` bổ sung thêm điều kiện lọc loại trừ mã cha chưa phân tách ở khối WHERE của UNION thứ 3:
    ```sql
    WHERE DP.PackingID = @pPackingID  
      AND ISNULL(DP.PackingParentID, '') <> '' -- Dòng sửa lỗi
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 2.1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md#21-lỗi-unique-constraint-khi-gộp-túi-bóng-hn544--pkqn2100175).

### Lỗi 2: Gộp túi bóng thành hộp nhỏ ở HN544 bị mất số lượng (CurrentQty = 0)
*   **Triệu chứng:** Sau khi thực hiện gộp nilon thành hộp nhỏ, số lượng tồn hiển thị bằng 0 và không in được tem nhãn.
*   **Nguyên nhân gốc:** Lệch dữ liệu khi dồn số lượng giữa các Lot phụ.
*   **Cách khắc phục:**
    Chạy script dồn tổng số lượng thực tế vào 1 Lot duy nhất và xóa các Lot phụ rác:
    ```sql
    UPDATE STB_MaterialLotInfo SET InitialQty = 20, CurrentQty = 20 WHERE MaterialLotNo = 'MÃ_LOT_CẦN_GIỮ';
    DELETE FROM STB_MaterialLotInfo WHERE MaterialLotNo IN ('MÃ_LOT_RÁC_1', 'MÃ_LOT_RÁC_2');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#65-lỗi-gộp-túi-bóng-bị-mất-số-lượng-qty--0--hn544).

### Lỗi 3: Báo lỗi tiếng Hàn "Bạn chưa nhập kết quả..." hoặc sản lượng hiển thị bằng 0 ở HN523
*   **Triệu chứng:** Nhập mã Lot để gộp box ở màn hình gộp tùy chỉnh **HN523**, hệ thống báo lỗi tiếng Hàn hoặc hiển thị sản lượng đầu ra (OutputQty) bằng 0.
*   **Nguyên nhân gốc:** Cấu hình Routing của PO thiếu cờ công đoạn cuối làm công đoạn đầu ra (`IsOutputRoute = 1`), khiến Stored Procedure `usp_Vietnam_GetProdPackingForBarcode_VVT` trả về sản lượng bằng 0.
*   **Cách khắc phục:** Cập nhật lại cấu hình Routing của PO trên DB để đặt công đoạn cuối làm công đoạn đầu ra:
    ```sql
    UPDATE STB_ProductionOrderRouting SET IsOutputRoute = 1 WHERE PONo = 'MÃ_PO' AND RouteCode = 'MÃ_CÔNG_ĐOẠN_CUỐI';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.13](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#613-phân-tích-nguyên-nhân-lỗi-gộp-box-tùy-chỉnh-trên-màn-hình-hn523-sản-lượng-hiển-thị--0--cảnh-báo-tiếng-hàn).

---

## HN551 / HN866 — FG Export & InStock (Xuất kho & Tồn kho thành phẩm Hà Nam)

### Lỗi 1: Hàng đã xuất kho ở HN551 nhưng tồn kho trên màn HN866 vẫn còn nguyên
*   **Triệu chứng:** Lịch sử xuất hàng đã ghi nhận thành công tại màn hình xuất **HN551** nhưng khi vào màn hình kiểm tra tồn kho **HN866** vẫn thấy hiện Packing ID cũ, gây lệch tồn kho thực tế.
*   **Nguyên nhân gốc:** SP xử lý xuất kho `ExportWarehouseFinshGoodInventory_uid` thực hiện ghi nhận vào bảng xuất `STB_VN_FINISHGOODS_HN_Export` nhưng bị lỗi/quên không cập nhật cột cờ xuất `QtyOutput` trong bảng tồn kho `FinishGoodMESInstock_HN`.
*   **Cách khắc phục:**
    Chạy script SQL đồng bộ cờ xuất kho cho Packing ID bị lỗi:
    ```sql
    -- Cập nhật cờ xuất kho bằng số lượng gốc của thùng
    UPDATE FinishGoodMESInstock_HN SET QtyOutput = Quantity WHERE PackingID = 'MÃ_PACKING_LỖI';
    UPDATE STB_VN_FINISHGOODS_HN_Export SET StatusExport = 1 WHERE PackingID = 'MÃ_PACKING_LỖI';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md#1-lỗi-hàng-xuất-ở-hn551-nhưng-tồn-kho-hn866-vẫn-còn).

---

## Mixing (electrode.weighing) — Electrode Mixing (Cân trộn điện cực)

### Lỗi 1: Các bước cân nhảy không đúng thứ tự quy trình sản xuất (electrode.weighing)
*   **Triệu chứng:** Trên giao diện phần mềm cân, thứ tự các bước cân bị xáo trộn (yêu cầu cân chất liên kết Binder trước bột Than), công nhân không cân được.
*   **Nguyên nhân gốc:** Do tick chọn checkbox "CA ĐÊM CHUẨN BỊ TRƯỚC" (`isnight` trên UI) khiến SP `usp_GetElectroMixPresentStep_vietnam` đổi thứ tự ưu tiên cân Binder trước.
*   **Cách khắc phục:**
    1. Yêu cầu công nhân bỏ chọn checkbox "CA ĐÊM CHUẨN BỊ TRƯỚC" trên UI, sau đó click "Làm mới màn hình" để khôi phục thứ tự chuẩn (cân bột Than trước).
    2. Nếu Lot trộn đã bị kẹt dữ liệu dở dang, IT chạy lệnh xóa dữ liệu cân tạm của Lot đó trong bảng `STB_ElectrodeMixStepInfo` để thực hiện cân lại từ đầu:
    ```sql
    DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'MÃ_LOT_BỊ_KẸT';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.7](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md#47-lỗi-nhảy-bước-cân-điện-cực-mixing-phần-mềm-electrodeweighing).

---

## K101 / K109 / K110 — BG2 Production Plan & Scan (Sản xuất và quét NVL nhà máy BG2)

### Lỗi 1: Không tạo được Lot hoặc không chốt được sản lượng tại nhà máy Bắc Giang 2 (BG2)
*   **Triệu chứng:** Công nhân tại nhà máy BG2 không thể thực hiện các thao tác lập kế hoạch ngày hay quét chốt sản lượng trên các màn hình chuẩn B450 hay B597.
*   **Nguyên nhân gốc:** Nhà máy BG2 chạy cơ sở dữ liệu và phân hệ riêng biệt, sử dụng màn hình đặc thù: **K101** (tương đương B450) và **K109** (tương đương B597) có lọc riêng cho `WorkCenterCode = 'VVT_BG2'`.
*   **Cách khắc phục:** Hướng dẫn công nhân mở đúng màn hình của BG2:
    1. Lập kế hoạch ngày tại **K101** thay vì B450.
    2. Để quét NVL, OP mở màn hình **B540** -> nhấn nút **"Việt Nam_Kiểm tra thường xuyên_BG2"** để kích hoạt giao diện **K109** (tích hợp logic chặn quét sai NVL theo BOM).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.9](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md#69-sự-khác-biệt-vận-hành-bg2).

---

## Z530 / A460 — Label Layout & Mapping (Thiết kế mẫu in và mapping tem)

### Lỗi 1: Bấm nút in tem nhãn nhưng máy in không chạy hoặc in ra tem trống/không đúng mẫu khách hàng
*   **Triệu chứng:** In tem Inner/Outer/PAC/Digi-Key không hoạt động hoặc tem in bị thiếu thông số Voltage/Farad/Serial.
*   **Nguyên nhân gốc:** Layout tem chưa được phê duyệt ở **Z530** (cờ `IsApproval = 0` trong `STB_LabelInfo`) hoặc chưa map mã Model với mẫu tem tương ứng ở **A460** (`STB_ModelLabelInfo`).
*   **Cách khắc phục:**
    1. Check trạng thái phê duyệt của layout tem:
       ```sql
       SELECT FormatName, IsApproval FROM SmartFramework.dbo.STB_LabelInfo WHERE FormatName = 'TÊN_LAYOUT_TEM';
       ```
    2. Check mapping mã vật tư:
       ```sql
       SELECT ModelCode, FormatName FROM STB_ModelLabelInfo WHERE ModelCode = 'MÃ_MODEL';
       ```
    3. Thực hiện map lại hoặc Approve layout tem trên giao diện UI cấu hình tem.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.16](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md#616-màn-hình--cấu-hình-thiết-kế-tem-z530a460).

---

## Z410 / Z220 / Z330 — User Accounts & Role Permissions (Quản lý tài khoản & phân quyền người dùng)

### Lỗi 1: User báo lỗi tài khoản bị khóa không đăng nhập được hệ thống MES
*   **Triệu chứng:** Người dùng đăng nhập hệ thống báo lỗi tài khoản bị khóa hoặc thông báo không thể truy cập.
*   **Nguyên nhân gốc:** Cờ kích hoạt hoạt động của tài khoản bị tắt (`AllowFlag = 0`) trong bảng quản lý người dùng `STB_UserInfo` (Màn hình cấu hình **Z410**).
*   **Cách khắc phục:** Vào màn hình **Z410**, tìm tài khoản tương ứng, tích chọn cờ kích hoạt hoạt động và nhấn Lưu. Hoặc chạy SQL cập nhật trực tiếp:
    ```sql
    UPDATE STB_UserInfo SET AllowFlag = 1 WHERE UserID = 'MÃ_USER';
    ```

### Lỗi 2: Người dùng báo không nhìn thấy hoặc bị chặn không vào được màn hình nghiệp vụ
*   **Triệu chứng:** Người dùng đăng nhập thành công vào MES nhưng không thấy màn hình chức năng trên menu, hoặc bị văng cảnh báo không có quyền truy cập.
*   **Nguyên nhân gốc:** Menu/Màn hình đó chưa được phân quyền cho Nhóm Role của User tại **Z220** (Role Screen Mapping) hoặc chưa được kích hoạt hiển thị tại màn hình cấu hình hệ thống **Z330** (Screen Config).
*   **Cách khắc phục:**
    1. Truy cập **Z220**, kiểm tra và gán quyền truy cập Screen ID cho Nhóm Role của người dùng.
    2. Truy cập **Z330**, kiểm tra xem Screen ID đã được publish hoạt động trên Production chưa.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.1 và § 1.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md#11-lỗi-không-đăng-nhập-được-mes-allowflag).

---
*Cập nhật: 2026-06-12 — Hoàn thiện cẩm nang tra cứu lỗi tập trung theo Screen ID phục vụ phím tắt Ctrl+Shift+F cho toàn bộ các màn.*
