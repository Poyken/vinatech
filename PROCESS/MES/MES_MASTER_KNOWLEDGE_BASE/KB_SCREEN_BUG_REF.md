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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 8](KB_25_VINAENESSOL_HUNG_YEN.md#8-a130-kholocation--đối-tác).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 1.3](KB_06_MASTER_DATA_TOOLS.md#13-sửa-mã-vật-tư-mới-chưa-khai-báo-volfarad-stb_modelbasicinfo).

---

## A310 — BOM Registration (Đăng ký cấu trúc BOM sản phẩm)

### Lỗi 1: Trạm quét NVL B597 báo lỗi đỏ "Mã nguyên vật liệu không khớp với BOM"
*   **Triệu chứng:** Khi OP quét mã vạch NVL tại chuyền ở trạm **B597**, hệ thống báo lỗi đỏ chặn không cho lưu vì NVL không nằm trong BOM.
*   **Nguyên nhân gốc:** Cấu trúc định mức vật tư (BOM) của sản phẩm/model chưa được đăng ký hoặc đồng bộ thiếu trong các bảng `STB_BomHeader` và `STB_BomDetail` tại màn hình **A310**.
*   **Cách khắc phục:** Vào màn hình **A310**, kiểm tra cấu hình BOM của Model, gán bổ sung mã NVL bị thiếu hoặc yêu cầu bộ phận quản lý đồng bộ lại BOM từ Groupware.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 4](KB_25_VINAENESSOL_HUNG_YEN.md#4-màn-hình-a310-thông-tin-bom).

---

## B210 / B220 / B230 / B240 — Production Routing Setup (Thiết lập định tuyến sản xuất)

### Lỗi 1: Màn hình B450 không tìm thấy Line sản xuất để tạo Lot
*   **Triệu chứng:** Khi lập kế hoạch ngày tại **B450** để sinh mã Lot cho PO, người dùng không thể chọn được Line sản xuất mong muốn trong dropdown.
*   **Nguyên nhân gốc:** Line sản xuất chưa được kích hoạt (`IsUsed = 0`) tại màn hình đăng ký Line **B210** (`STB_LineInfo`), hoặc cấu hình sai mã nhà máy (`WorkCenterCode`).
*   **Cách khắc phục:** Vào màn hình **B210**, tìm Line tương ứng, kiểm tra và tick chọn cờ `IsUsed`, đảm bảo `WorkCenterCode` khớp với khu vực sản xuất rồi Lưu lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](KB_06_MASTER_DATA_TOOLS.md#10-thiết-lập-line--route-b210b220b230b240).

### Lỗi 2: Giao diện B530 không hiển thị Máy khi OP scan chốt công đoạn
*   **Triệu chứng:** OP thực hiện quét chốt sản lượng tại **B530** nhưng không hiển thị danh sách thiết bị/máy chạy trong dropdown chọn máy.
*   **Nguyên nhân gốc:** Máy móc chưa được cấu hình phân bổ thuộc công đoạn (RouteCode) đang chạy trong bảng `STB_MachineMaster` (Màn hình **B240**).
*   **Cách khắc phục:** Vào màn hình **B240**, kiểm tra và gán máy móc đang chạy vào đúng công đoạn (RouteCode) tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](KB_06_MASTER_DATA_TOOLS.md#10-thiết-lập-line--route-b210b220b230b240).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](KB_01_UI_PHAN_QUYEN.md#13-lỗi-popup-b270-trống-không-hiện-danh-sách-máy).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 7](KB_06_MASTER_DATA_TOOLS.md#7-thêm-cellline-mới-b250-b270).

---

## B260 — Worker Management (Nhân sự sản xuất)

### Lỗi 1: Tên nhân viên mới không hiển thị trong dropdown chọn nhân viên tại B530 hoặc B540
*   **Triệu chứng:** Nhân viên đã đăng ký thành công trên MES nhưng OP không tìm thấy tên khi chốt sản lượng.
*   **Nguyên nhân gốc:** Khi khai báo nhân viên, cột mã nhóm nhân viên (`WorkerGroupCode`) bị điền sai (không phải nhóm `VE-01` của nhà máy).
*   **Cách khắc phục:** Vào màn hình **B260**, tìm mã nhân viên, cập nhật lại cột `WorkerGroupCode` chính xác thành `VE-01` rồi nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 12](KB_06_MASTER_DATA_TOOLS.md#12-b260---thông-tin-nhân-viên-sản-xuất).

---

## B310 / B450 — Production Orders & Day Plan (Kế hoạch tháng / ngày)

### Lỗi 1: Lỗi không đồng bộ được lệnh sản xuất (PO) từ Groupware sang MES
*   **Triệu chứng:** Kế hoạch sản xuất đã được lập trên Groupware nhưng thủ kho hoặc OP không thấy hiển thị thông tin PO tại màn hình **B310** hay **B450** trên MES để bắt đầu tạo Lot.
*   **Nguyên nhân gốc:** PO trên Groupware chưa được duyệt trạng thái "Arrival Confirmation", hoặc Windows Service đồng bộ trung gian (ESM Bridge) bị treo/chết, khiến dữ liệu không được đẩy vào bảng trung gian `ESM_DayProdPlan`.
*   **Cách khắc phục:**
    1. Yêu cầu quản lý duyệt PO trên Groupware.
    2. Nếu đã duyệt nhưng vẫn lệch, IT kiểm tra trạng thái Windows Service ESM, hoặc chạy query cưỡng bức đồng bộ thủ công qua ESM Bridge Tables.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_07_GROUPWARE_INTEGRATION.md § 6](KB_07_GROUPWARE_INTEGRATION.md#6-lỗi-không-đồng-bộ-được-po-từ-groupware-sang-mes).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.2](KB_04_DONG_GOI_IN_TEM.md#62-sửa-tên-lot-sau-b351-chuyển-đổi-lot--barcode-có-dấu-chấm).

---

## B418 — Packing Quantity Standards (Quy cách đóng gói theo Size)

### Lỗi 1: Popup gộp Box tại B523 báo lỗi "Chưa có tiêu chuẩn đóng gói" do sai lệch kích thước Size
*   **Triệu chứng:** Khi công nhân quét gộp Box tại B523, hệ thống báo lỗi chặn đứng quy trình: `"Chưa có tiêu chuẩn đóng gói"`.
*   **Nguyên nhân gốc:** Kích thước Size của Model (`MBISizeD` lấy từ **A410**) chưa được khai báo số lượng đóng gói định mức (`PackQty`) tương ứng trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:** Vào màn hình **A418**, đăng ký Size mới và thiết lập số lượng đóng gói định mức tương ứng (`PackQty`) rồi nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 11](KB_06_MASTER_DATA_TOOLS.md#11-a418---số-lượng-đóng-gói-theo-size).

---

## B442 — Electrode Production Plan (Kế hoạch & in tem điện cực)

### Lỗi 1: Không tạo được kế hoạch hoặc in tem điện cực cho Model mới
*   **Triệu chứng:** Khi lập kế hoạch và in tem điện cực tại **B442**, Model mới không hiển thị hoặc không cho phép in.
*   **Nguyên nhân gốc:** Model chưa được khai báo ở bảng thông tin Model master (**A230**) hoặc thiếu cấu hình công đoạn tương ứng.
*   **Cách khắc phục:** Đăng ký đầy đủ mã Model ở màn hình **A230** trước khi thao tác trên **B442**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 1 (Phần 1)](KB_05_QC_ELECTRODE.md#1-lập-kế-hoạch--in-tem-điện-cực-b310-b442-a230).

---

## B452 — Line Changing (Chuyển Line sản xuất)

### Lỗi 1: Không đổi được Line sản xuất cho Lot sản phẩm
*   **Triệu chứng:** Khi thực hiện đổi chuyền sản xuất cho Lot tại màn hình **B452**, hệ thống báo lỗi không có quyền hoặc chặn không cho lưu.
*   **Nguyên nhân gốc:** Stored Procedure `usp_Vietnam_ChangeProductionOrderRoutingLine_VNT` kiểm soát tính năng này chứa một danh sách Whitelist UserID được hardcode cứng.
*   **Cách khắc phục:**
    ALTER SP `usp_Vietnam_ChangeProductionOrderRoutingLine_VNT` để bổ sung UserID của nhân viên vận hành hiện tại vào danh sách được phép.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.7](KB_03_SAN_XUAT.md#67-b452-không-đổi-được-line).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.1](KB_04_DONG_GOI_IN_TEM.md#61-lỗi-chưa-có-tiêu-chuẩn-đóng-gói-b523).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.4](KB_04_DONG_GOI_IN_TEM.md#64-lỗi-không-gộp-box-được-b523--quy-trình-debug-chuẩn).

### Lỗi 3: Lỗi Packing Qty hiển thị số âm hoặc sai lệch số lượng thực tế
*   **Triệu chứng:** Màn hình hiển thị số lượng đóng gói bị âm hoặc sai lệch nghiêm trọng.
*   **Nguyên nhân gốc:** Sai lệch lượng trừ kho ảo `CurrentQty` trong bảng `STB_MaterialLotInfo` hoặc sai bản ghi `STB_SavePackingTime_VVT`.
*   **Cách khắc phục:**
    Chạy script reset số lượng thực tế của Lot về giá trị đúng:
    ```sql
    UPDATE STB_MaterialLotInfo SET CurrentQty = [SỐ_LƯỢNG_ĐÚNG] WHERE LotNo = 'MÃ_LOT';
    UPDATE STB_SavePackingTime_VVT SET PackQty = [SỐ_LƯỢNG_ĐÚNG] WHERE LotNo = 'MÃ_LOT' AND id = [ID_GIAO_DỊCH];
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.6](KB_04_DONG_GOI_IN_TEM.md#66-lỗi-packing-qty-âm-ở-b523--b789).

### Lỗi 4: Lỗi "Chưa có tiêu chuẩn đóng gói" cho Model/Size 1840 khi quét gộp Box
*   **Triệu chứng:** Khi công nhân quét gộp Box cho các Model có kích thước size `1840` tại màn hình B523, hệ thống báo lỗi đỏ chặn không cho thao tác.
*   **Nguyên nhân gốc:** Thiếu cấu hình định mức đóng gói cho kích thước size `1840` trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:**
    Chạy SQL chèn bổ sung cấu hình đóng gói chuẩn (InnerBoxQty = 500, OutBoxQty = 1000) vào bảng `STB_PackingStandard`:
    ```sql
    INSERT INTO STB_PackingStandard (MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty, CreateDateTime, CreateUserID)
    VALUES ('FERT', '1840', 0, 0, 0, 500, 1000, GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_19_PHAN_TICH_LOT_SIZE_VÀ_MÃ_LỖI_B530.md § 2.1](KB_19_PHAN_TICH_LOT_SIZE_VÀ_MÃ_LỖI_B530.md#21-file-thay-đổi-số-lượng-lot-noxlsx-sự-cố-chưa-được-cover-đầy-đủ).

---

## B530 — Route Input / Production Qty Output (Nhập sản lượng công đoạn)

### Lỗi 1: Lỗi cấm Scan nhanh dưới 20 phút (Gate 20 phút) bị lỗi/không chặn được
*   **Triệu chứng:** Hệ thống không thực hiện chặn được việc OP scan chốt công đoạn quá nhanh (dưới 20 phút).
*   **Nguyên nhân gốc:** Lỗi logic so sánh Null trong SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` dòng 218: `IF @SIExtInt01 = Null` (Trong SQL phải dùng `IS NULL`).
*   **Cách khắc phục:**
    ALTER SP sửa lại cú pháp so sánh Null chuẩn: `IF @SIExtInt01 IS NULL`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 2.2](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md#bug-1-gate-20-phút-không-bao-giờ-hoạt-động).

### Lỗi 2: OP báo lỗi không chốt được công đoạn, báo "Routing không có trong PO" hoặc "Đã hoàn thành thực tế rồi"
*   **Triệu chứng:** OP scan chốt sản lượng tại **B530** hệ thống báo lỗi không chốt được.
*   **Nguyên nhân gốc:** Do bỏ qua công đoạn trước đó chưa scan chốt, hoặc PO cấu hình sai thứ tự RoutingIndex.
*   **Cách khắc phục:**
    IT kiểm tra lịch sử quét Routing của Barcode bằng Golden Query để phát hiện công đoạn bị bỏ qua. Cho OP quay lại scan trạm trước, hoặc chèn dòng Routing giả lập để thông luồng (Xem phương pháp trace tại [KB_14 § 4.4](KB_14_TRACE_BUG_METHODOLOGY.md#44-lỗi-không-chốt-được-công-đoạn-màn-hình-b530)).

### Lỗi 3: Thiếu hoặc dư thừa danh mục lỗi (Defect Code) hiển thị tại lưới nhập lỗi của xưởng BN & BG1
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
*   **Chi tiết nghiệp vụ:** Xem tại [fix_b530_disable_defects_BG.sql](../sql/scripts/fix_b530_disable_defects_BG.sql) và [fix_b530_add_defects_BG.sql](../sql/scripts/fix_b530_add_defects_BG.sql).

---

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8.2](KB_05_QC_ELECTRODE.md#82-lỗi-chưa-config-trong-stb_slittinglocationconfig_vvt).

---

## B560 — Hela OutBox List (In tem thùng Hela)

### Lỗi 1: Lỗi in thiếu tem nhỏ (chỉ in 73/80 tem)
*   **Triệu chứng:** Khi in tem thùng Hela có quy cách 80 hộp nhỏ, hệ thống chỉ hiển thị `InBoxLabelCount = 73` và in thiếu tem.
*   **Nguyên nhân gốc:** Biến cục bộ `@InBoxLabelList` và cột tương ứng trong bảng `STB_HelaBarcodeOutBoxHist` khai báo kiểu dữ liệu `VARCHAR(1000)` quá ngắn, khiến chuỗi tem bị cắt cụt (truncation).
*   **Cách khắc phục:**
    1. Chạy ALTER TABLE đổi cột `InBoxLabelList` thành `VARCHAR(MAX)`.
    2. ALTER Stored Procedure `usp_DoCreateHelaInBoxBarcodeList` đổi biến `@InBoxLabelList` thành `VARCHAR(MAX)`.
    3. Update khôi phục lại chuỗi tem đầy đủ cho các Lot bị lỗi.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.14](KB_04_DONG_GOI_IN_TEM.md#614-lỗi-cắt-chuỗi-danh-sách-tem-nhỏ-b560---truncation-in-inboxlabellist).

---

## B597 — Material Scanning & PQC Verification (Scan nguyên vật liệu đầu vào chuyền)

### Lỗi 1: Cảnh báo đỏ chặn không cho lưu Lot NVL đầu vào (HOLD, Hết hạn, Sai chủng loại)
*   **Triệu chứng:** Khi quét mã Lot nguyên liệu đầu vào tại **B597**, hệ thống báo lỗi đỏ cấm sử dụng.
*   **Nguyên nhân gốc:** Lot đang nằm ở kho ảo `HOLDING_WH` (chưa QC), hoặc ngày hết hạn sử dụng vượt quá ngày hiện tại (vi phạm FIFO/Expiry), hoặc mã nguyên liệu không nằm trong BOM cấu hình của PO.
*   **Cách khắc phục:**
    1. Check QC: Yêu cầu QC PASS hoặc chuyển kho Lot về kho chính `ROH_WH` bằng SQL.
    2. Bypass gia hạn dùng tạm thời (Ghi nhận biên bản audit): UPDATE ngày tạo `CreateDateTime` lùi lại hoặc chạy lệnh bỏ qua FIFO.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7](KB_05_QC_ELECTRODE.md#7-lỗi-quét-nguyên-vật-liệu-b597--pqc-check).

### Lỗi 2: Lỗi quét vỏ nhôm (AluCase) mới báo sai chủng loại tại B597
*   **Triệu chứng:** Quét mã vỏ nhôm mới hệ thống báo lỗi chặn đứng sản xuất.
*   **Nguyên nhân gốc:** Logic kiểm tra vỏ nhôm không nằm trong DB cấu hình mà bị hardcode trực tiếp trong SP `usp_Vietnam_RawMaterialInputHist_uid`.
*   **Cách khắc phục:**
    ALTER SP `usp_Vietnam_RawMaterialInputHist_uid` để bổ sung mã vỏ nhôm mới vào khối điều kiện `IF / NOT IN`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.4](KB_05_QC_ELECTRODE.md#74-lỗi-vỏ-nhôm-alucase).

### Lỗi 3: Lỗi "String or binary data would be truncated" khi quét gộp 5 mã điện cực 1 Lot (Model 3510 / 35105)
*   **Triệu chứng:** Khi quét gộp 5 mã barcode điện cực cho 1 Lot tại B597, hệ thống báo lỗi đỏ `"String or binary data would be truncated"` và không cho lưu.
*   **Nguyên nhân gốc:** Cột `RawMaterialBarcode` của bảng `STB_InputMaterialHistory` có giới hạn độ dài `NVARCHAR(100)`, trong khi chuỗi ghép từ 5 mã điện cực vượt quá giới hạn này (thường dài khoảng 102+ ký tự). Các tham số và biến nội bộ trong SP `usp_Vietnam_RawMaterialInputHist_uid` cũng bị giới hạn độ dài (`NVARCHAR(200)` hoặc `NVARCHAR(100)`).
*   **Cách khắc phục:**
    1. Cập nhật độ dài cột lên `NVARCHAR(1000)`:
       ```sql
       ALTER TABLE STB_InputMaterialHistory ALTER COLUMN RawMaterialBarcode NVARCHAR(1000) NULL;
       ```
    2. Sửa tham số `@pRawMaterialBarcode` và các biến nội bộ chứa chuỗi ghép barcode (ví dụ: `@RawMaterialBarcode`, `@LotMaterialBarcode`) trong stored procedure `usp_Vietnam_RawMaterialInputHist_uid` thành `NVARCHAR(1000)`.
*   **Chi tiết nghiệp vụ:** Xem file script [fix_multibarcode_3510.sql](../sql/scripts/fix_multibarcode_3510.sql).

---

## B598 — Material Scrap Report (Báo phế nguyên vật liệu trên chuyền)

### Lỗi 1: Báo phế NVL bị lỗi không ghi nhận hệ thống
*   **Triệu chứng:** Báo phế NVL tại chuyền ở màn hình **B598** bị chặn hoặc không đồng bộ số lượng.
*   **Nguyên nhân gốc:** Lệch ngày `JobDate` giữa ca sản xuất thực tế và ngày khai báo kế hoạch trên MES.
*   **Cách khắc phục:**
    Chạy query cập nhật điều chỉnh `JobDate` của Lot kế hoạch ngày khớp với thực tế để mở luồng ghi nhận phế.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.12](KB_03_SAN_XUAT.md#612-b598-báo-phế-nvl-sửa-jobdate-đặc-biệt).

---

## B618 — Rework (Làm lại sản phẩm)

### Lỗi 1: Không có quyền thao tác trên giao diện Rework B618
*   **Triệu chứng:** Công nhân không thể thực hiện quét/xác nhận làm lại sản phẩm lỗi tại chuyền.
*   **Nguyên nhân gốc:** SP `usp_Vietnam_GetLotInfoForRework_VNT` bị hardcode kiểm tra Whitelist UserID.
*   **Cách khắc phục:**
    Sửa SP để bổ sung thêm UserID của OP hiện hành vào danh sách Whitelist cho phép thao tác Rework.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md § 2](KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md#2-lỗi-phân-quyền-màn-hình-rework-b618).

---

## B717 — Bending & Tapping (Uốn chân & Dán băng keo Cell)

### Lỗi 1: Nhập sai thông số uốn/dán tại B717 không thể sửa hoặc xóa trực tiếp trên giao diện
*   **Triệu chứng:** OP nhập nhầm số lượng, sai kích thước hoặc thông số uốn dán tại **B717**, không thấy nút Edit hay Delete trên UI để chỉnh sửa lại.
*   **Nguyên nhân gốc:** Hệ thống chỉ được thiết kế để ghi nhận 1 lần (Insert hoặc Override) và không hỗ trợ tính năng sửa/xóa giao dịch trên client app.
*   **Cách khắc phục:** IT kiểm tra và chạy script SQL update trực tiếp sản lượng hoặc xóa bản ghi giao dịch sai trong bảng tương ứng để OP quét lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 5 (Mục 3)](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md#5-⚠️-5-điểm-nguy-hiểm-ẩn--developer-phải-biết).

---

## B682 / B781 / B786 / B789 / B791 — Stage Prices & Defect Reports (Giá công đoạn & Báo cáo lỗi)

### Lỗi 1: Đơn giá công đoạn sản xuất bị hiển thị trống (Null)
*   **Triệu chứng:** Lưới dữ liệu sản lượng hiển thị đơn giá bằng 0 hoặc trống, không tính được lương/hiệu suất.
*   **Nguyên nhân gốc:** Model sản phẩm chưa được khai báo đơn giá tương ứng với công đoạn và mã nhà máy (`WorkCenterCode`) trong bảng thiết lập Stage Prices.
*   **Cách khắc phục:**
    Khai báo bổ sung đơn giá cho Model sản phẩm vào bảng `STB_VVT_StagePrices` tương ứng:
    ```sql
    INSERT INTO STB_VVT_StagePrices (model, WorkCenterCode, RouteV22, PriceV22...)
    VALUES ('MÃ_MODEL', 'MÃ_NHÀ_MÁY', 'ROUTE_CODE', ĐƠN_GIÁ);
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 3](KB_06_MASTER_DATA_TOOLS.md#3-fix-giá-công-đoạn-stage-prices).

### Lỗi 2: Báo cáo lỗi chi tiết Cell B682 bị lẫn lộn các lỗi không thuộc bộ phận sản xuất (VE%, VP%)
*   **Triệu chứng:** Báo cáo chi tiết lỗi sản phẩm Cell Line Bắc Giang/Bắc Ninh hiển thị lẫn lộn cả các lỗi thuộc bộ phận Điện cực (Electrode - mã `VE%`) và bộ phận Module (mã `VP%`).
*   **Nguyên nhân gốc:** Stored Procedure `usp_Get_VVT_Prod_Bad_Status` khi truy vấn lịch sử công đoạn và bảng lỗi `STB_DefectRepairInfo` chỉ lọc `RouteCode LIKE 'V%'`. Do công đoạn của Điện cực Hà Nam bắt đầu bằng `VE` (Ví dụ: `VE01`) và Module bắt đầu bằng `VP` (Ví dụ: `VP01`), chúng đều bị lọc nhầm vào kết quả Cell Line Bắc Giang/Bắc Ninh.
*   **Cách khắc phục:** Sửa SP `usp_Get_VVT_Prod_Bad_Status` tại khối CTE `ViewBarcode` và `RawView` để thêm logic lọc loại trừ:
    ```sql
    -- Thêm logic lọc loại trừ VE và VP tại các xưởng khác Hà Nam
    AND b.RouteCode LIKE 'V%'
    AND (@WorkCenterCode = 'VVT_F3' OR (b.RouteCode NOT LIKE 'VE%' AND b.RouteCode NOT LIKE 'VP%'))
    ```
*   **Chi tiết nghiệp vụ:** Xem tại mã nguồn Stored Procedure [usp_Get_VVT_Prod_Bad_Status.sql](../sql/procedures/usp_Get_VVT_Prod_Bad_Status.sql#L53).

---

---

## B754 / B756 — PAC Customer Labels (In tem nhãn khách hàng PAC)

### Lỗi 1: Lỗi in tem thùng nhãn ngoài (Outer Label) không hiển thị đúng Serial hoặc cân nặng
*   **Triệu chứng:** In tem thùng lớn tại B756 báo lỗi thiếu Serial nhãn hoặc không hiển thị trọng lượng thực tế.
*   **Nguyên nhân gốc:** Không tích chọn cờ `IsOuter = 1` khi in nhãn ngoài (Outer) dẫn đến hệ thống hiểu nhầm là nhãn trong (Inner), hoặc chưa bật chế độ `IsWeightLabel`.
*   **Cách khắc phục:**
    1. Nhắc nhở công nhân tick chọn `IsOuter` khi in nhãn ngoài thùng (Outer) vì nhãn trong và nhãn ngoài chạy Serial độc lập.
    2. Khi in tem cân nặng, tick chọn `IsWeightLabel` trước khi nhấn nút.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.9.1](KB_04_DONG_GOI_IN_TEM.md#691-in-tem-khách-hàng-pac-b754--b755--b756).

---

## B757 / B758 — Digi-Key Customer Labels (In tem nhãn khách hàng Digi-Key)

### Lỗi 1: Lỗi in nhãn Logistic tại B757 bị chặn báo thiếu thông tin
*   **Triệu chứng:** Bấm "IN NHÃN LOGISTIC" hệ thống báo lỗi không in được.
*   **Nguyên nhân gốc:** Chưa nhập đủ các trường bắt buộc gồm: PO Number, PO Line Number, Pack List Number.
*   **Cách khắc phục:**
    1. Yêu cầu nhập đầy đủ thông số PO và số dòng PO tương ứng trước khi in.
    2. Nếu in cho thùng hàng hỗn hợp (Mixed Load), chuyển sang sử dụng màn hình **B758**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.9.2](KB_04_DONG_GOI_IN_TEM.md#692-in-tem-khách-hàng-digi-key-b757--b758).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.10](KB_04_DONG_GOI_IN_TEM.md#610-thiết-kế-tem-phoenix-contact-yêu-cầu-đặc-biệt-tại-b790).

---

## B802 — Electrode Production History (Báo cáo & Đối soát điện cực)

### Lỗi 1: Sai lệch số lượng/mã cuộn điện cực thực tế so với báo cáo B802
*   **Triệu chứng:** Khi mở báo cáo lịch sử sản xuất điện cực trên **B802**, số lượng cuộn hoặc tổng số mét sản xuất thực tế bị lệch so với dữ liệu chốt công đoạn.
*   **Nguyên nhân gốc:** Bỏ qua việc quét/chốt các công đoạn bán thành phẩm điện cực (Coating/Slitting) hoặc do sai lệch giá trị `ProdQty` trong bảng `STB_ProdRouteHist` của điện cực.
*   **Cách khắc phục:** IT tiến hành đối soát thông tin qua bảng lịch sử điện cực `STB_ElectrodeProdRouteHist` và điều chỉnh lại sản lượng thực tế khớp với số mét cuộn.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.11](KB_03_SAN_XUAT.md#611-b802---vietnam-electrode-prod-route-hist-lịch-sử-sx-điện-cực) và [KB_05_QC_ELECTRODE.md § 3](KB_05_QC_ELECTRODE.md#3-báo-cáo--đối-soát-điện-cực-b802).

---

## C121 / C122 — QC Inspections (Cấu hình QC đầu vào)

### Lỗi 1: Lot nguyên liệu nhập kho không tự động hiển thị các hạng mục kiểm tra QC
*   **Triệu chứng:** Lot nguyên liệu hiển thị trên lưới QC nhưng không có bất kỳ hạng mục nào để nhập kết quả đo.
*   **Nguyên nhân gốc:** Chưa gán mã nguyên vật liệu vào nhóm hạng mục kiểm tra IQC tại màn hình **C122** hoặc chưa cấu hình nhóm kiểm tra tại **C121**.
*   **Cách khắc phục:**
    1. Vào **C121** thêm nhóm kiểm tra và các hạng mục chi tiết.
    2. Vào **C122**, chọn mã nguyên vật liệu và click chọn nhóm kiểm tra tương ứng để map dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.1](KB_05_QC_ELECTRODE.md#91-iqc-incoming-quality-control--kiểm-tra-nvl-đầu-vào).

---

## C220 — IQC Incoming Quality Control (Xác nhận kết quả IQC)

### Lỗi 1: Lỗi bị chặn "Receiving Confirmation" khi gộp nhập kho tại F330
*   **Triệu chứng:** Thủ kho bấm nhận hàng tại **F330** hệ thống báo lỗi chặn giao dịch.
*   **Nguyên nhân gốc:** Kết quả kiểm tra mẫu IQC của Lot hàng tại màn hình **C220** vẫn ở trạng thái chờ đánh giá hoặc đã bị đánh giá FAIL.
*   **Cách khắc phục:**
    Yêu cầu bộ phận QC hoàn thành nhập kết quả đo và xác nhận cờ chất lượng PASS cho Lot hàng trên màn hình **C220**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.15](KB_02_KHO_WMS.md#415-luồng-nhập-kho-đầy-đủ-f330).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 4](KB_08_KHO_THANH_PHAM_HN.md#4-lỗi-màn-hnc321-qc-nhập-ng-sản-phẩm-mang-đi-kiểm-tra--báo-lỗi-chữ-hàn-quốc) và [KB_14_TRACE_BUG_METHODOLOGY.md § 4.6](KB_14_TRACE_BUG_METHODOLOGY.md#46-lỗi-nhập-phế-màn-hnc321-báo-lỗi-tiếng-hàn-이전-공정에-실적처리-이력이-없습니다).

### Lỗi 2: Nhập phế/sửa chữa tại C321 báo lỗi hoặc không cập nhật được thông số sửa chữa
*   **Triệu chứng:** OP không lưu được thông tin sửa chữa/vật tư thay thế, hoặc bị sai lệch số lượng NG (`DefectQty`) ở các trạm tiếp theo.
*   **Nguyên nhân gốc:** Lỗi khi đồng bộ dữ liệu giữa bảng thông tin lỗi `STB_DefectRepairInfo` và số lượng chốt sản lượng của công đoạn.
*   **Cách khắc phục:** IT kiểm tra thông số và cập nhật đồng bộ lại cột `DefectQty` hoặc `ProdQty` bằng cách chỉnh sửa trực tiếp DB.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.5](KB_05_QC_ELECTRODE.md#95-c321---pqc-reliability-assy-sửa-chữa-lỗi-cell-line).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.2 (Kịch bản B)](KB_14_TRACE_BUG_METHODOLOGY.md#42-kịch-bản-b-hủy-kết-quả-kiểm-tra-chất-lượng-qc-b597--c443).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.8](KB_05_QC_ELECTRODE.md#78-cột-note1-thừa-trên-grid-c486-và-logic-rebuild-bảng).

---

## C512 / C530 / C546 — OQC Lot Management (Quản lý chất lượng đầu ra)

### Lỗi 1: Lỗi không tìm thấy Lot khi tạo hồ sơ kiểm tra OQC ở C512
*   **Triệu chứng:** Bấm tạo Lot OQC tại **C512** hệ thống báo không tìm thấy bản ghi Lot nào của sản phẩm.
*   **Nguyên nhân gốc:** Lot sản phẩm chưa hoàn thành công đoạn đóng gói cuối (chưa gộp Box tại B523) hoặc PO chưa cấu hình cờ đầu ra sản phẩm `IsOutputRoute = 1`.
*   **Cách khắc phục:**
    1. Kiểm tra Lot đã được quét gộp box tại B523 chưa.
    2. Sửa cờ `IsOutputRoute = 1` cho công đoạn cuối của PO trong `STB_ProductionOrderRouting` nếu cấu hình BOM/Routing bị thiếu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.2](KB_05_QC_ELECTRODE.md#72-không-tìm-thấy-lot-ở-màn-c512).

### Lỗi 2: Đo OQC OCV/ESR tại C546 chỉ hiển thị 20 dòng thay vì 50 dòng
*   **Triệu chứng:** Máy đo trả về kết quả cho 50 mẫu test nhưng trên giao diện C546 hệ thống chỉ load và hiển thị 20 dòng mẫu đo (lưới OCV/ESR hiển thị không đủ 50 dòng trống để nhập/hiển thị).
*   **Nguyên nhân gốc:** 
    1. SP get kết quả mẫu `usp_MaterialQcSampleResult_get` bị thiếu pattern `'FOQC_V01_07/08'`.
    2. SP get chi tiết màn hình `usp_Vietnam_MaterialFOQcDetail_get` bị thiếu block khởi tạo dữ liệu cho hạng mục OCV (`DetailNo = 2`). Trong khi hạng mục ESR (`DetailNo = 3`) và các mục khác đều có block khởi tạo để tạo đủ 50 dòng trống, khiến lưới OCV chỉ hiển thị tối đa theo số dòng thực tế đo được từ máy đo (ví dụ: 20 dòng) thay vì 50 dòng chuẩn.
*   **Cách khắc phục:**
    1. Deploy SP `usp_Vietnam_MaterialFOQcDetail_get` và `usp_MaterialQcSampleResult_get` đã sửa đổi (bổ sung block khởi tạo cho OCV DetailNo = 2).
    2. Chạy SQL Script để xóa kết quả lỗi cũ và reset trạng thái upload trong monitor để máy đo đẩy lại dữ liệu:
       ```sql
       BEGIN TRANSACTION;
       -- B1: Xóa kết quả QC cũ bị lệch
       DELETE FROM STB_MaterialQcSampleResult WHERE MaterialQcNo = 'F_MÃ_BARCODE' AND MaterialQcDetailNo IN (2, 3);
       
       -- B2: Reset trạng thái upload trong bảng Monitor (Set NULL để SP chạy nạp lại từ đầu)
       UPDATE Stb_ESRValueMonitor SET UploadToMes = NULL, UploadOCVToMess = NULL WHERE lotno = 'MÃ_LOT';
       
       -- B3: Reset trạng thái đánh giá trong bảng Detail để QC load lại dữ liệu
       UPDATE STB_MaterialQcDetail SET DecisionResult = NULL, PassedSampleQty = 0 WHERE MaterialQcNo = 'F_MÃ_BARCODE' AND MaterialQcDetailNo IN (2, 3);
       COMMIT TRANSACTION;
       ```
    3. Yêu cầu QC tắt và mở lại màn hình C546, quét lại Barcode để hệ thống sinh đủ 50 dòng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.6](KB_05_QC_ELECTRODE.md#96-c546-foqc-ocvsr-chỉ-hiển-thị-20ea-thay-vì-50ea-ocv-lệch-dữ-liệu) và file script vá lỗi [fix_c546_ocv_lots.sql](../sql/scripts/fix_c546_ocv_lots.sql).

### Lỗi 3: Đo kiểm ESR tại C530 chỉ hiển thị 10 dòng kết quả thay vì 20 dòng mẫu đo
*   **Triệu chứng:** Khi mở màn hình [C530] để nhập kết quả đo cho hạng mục ESR với số lượng mẫu (Sample Qty) thiết lập là 20, lưới kết quả đo bên phải chỉ hiển thị đúng 10 dòng kết quả đo từ máy đo và không sinh ra thêm 10 dòng trống tiếp theo để điền cho đủ 20 dòng.
*   **Nguyên nhân gốc:** 
    1. **Nghiệp vụ:** Số lượng mẫu đo từ máy bị thiếu (Máy đo ESR chỉ thực hiện đo và đẩy về 10 giá trị vào bảng `Stb_ESRValueMonitor` với trạng thái `UploadToMes IS NULL`). Hoặc Lot QC này chưa được nhấn nút "Tạo danh sách mẫu" (Create Sample List) sau khi cấu hình số lượng mẫu ESR tăng lên 20, nên danh sách mẫu trống chưa được sinh ra đầy đủ trước khi đồng bộ.
    2. **Logic Stored Procedure (`usp_MaterialQcSampleResult_get`):** Khi màn hình load kết quả đo, logic xử lý đồng bộ từ máy đo gặp vấn đề như sau:
        *   **Bước A (Xóa dòng trống cũ để chuẩn bị ghi đè):** tại dòng L155-L161:
            ```sql
            select @value7=count(*) from Stb_ESRValueMonitor where lotno=@value3 and UploadToMes is null
            if(@value7 > 0)
            begin
                  delete top(@value7) from STB_MaterialQcSampleResult where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
            end
            ```
            Nếu máy đo đẩy về 10 giá trị (`@value7 = 10`), SP sẽ xóa đi 10 dòng trống (`TestValue IS NULL`) đang có trong bảng kết quả mẫu `STB_MaterialQcSampleResult`.
        *   **Bước B (Vòng lặp bù dòng bị lệch chỉ số / Index Offset Bug):** tại dòng L225, SP đếm số dòng còn lại sau khi xóa:
            ```sql
            select @cnt= count(*) from STB_MaterialQcSampleResult where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo
            ```
            Giả sử ban đầu hệ thống có sẵn 20 dòng trống, sau khi xóa 10 dòng ở Bước A, `@cnt` còn lại là 10. SP chạy vòng lặp từ `@cnt` đến `@SampleQty` (từ 10 đến 19) để chèn kết quả đo hoặc bù dòng trống tại dòng L300:
            ```sql
            select top(1) @value = Val, @value1 = MonitorID from @TempESR where RowID = (@cnt + 1)
            ```
            Khi `@cnt` bắt đầu từ 10, chỉ số lấy dữ liệu sẽ là `RowID = 11`. Tuy nhiên, bảng tạm `@TempESR` (chứa dữ liệu từ máy đo) chỉ có 10 dòng (RowID từ 1 đến 10). Do đó, lượt truy vấn `RowID = 11` đến 20 sẽ trả về giá trị `@value = NULL`, nhảy vào nhánh `else` và chèn thêm 10 dòng trống.
            **Hậu quả:** 10 giá trị đo thực tế trong `@TempESR` bị bỏ qua không được lưu, thay vào đó hệ thống chỉ tạo thêm 10 dòng trống (NULL).
        *   **Bước C (Khi dữ liệu đã upload xong):** Ở lần load tiếp theo (hoặc trạng thái upload trong `Stb_ESRValueMonitor` đã là `'OK'`), biến `@cntexit1` = 0 khiến SP bỏ qua toàn bộ block xử lý đồng bộ và chỉ `SELECT` trực tiếp các bản ghi đang có sẵn trong `STB_MaterialQcSampleResult`. Nếu trước đó bảng này chỉ lưu đúng 10 dòng có giá trị, lưới bên phải sẽ chỉ hiển thị đúng 10 dòng đó mà không tự động sinh thêm 10 dòng trống cho đủ 20 dòng mẫu tiêu chuẩn.
*   **Cách khắc phục:**
    1. **QC thao tác nhanh:** Chọn hạng mục **ESR** ở lưới bên trái của màn hình [C530] và bấm nút **"Tạo danh sách mẫu"** (Nút màu xanh có icon danh sách và dấu tích ở góc trái phía trên của lưới bên trái - Create IQC Item Sample List) để kích hoạt SP `usp_DoMakeMaterialQcSampleResult.sql` quét lại thiết lập `SampleQty = 20` và tự động sinh thêm 10 dòng trống tiếp theo (từ dòng 11 đến 20) vào bảng kết quả đo.
    2. **Khắc phục logic trong SP:** Đồng bộ/sửa đổi logic khởi tạo của SP `usp_MaterialQcSampleResult_get` để tránh lệch chỉ số khi số lượng mẫu đo từ máy truyền về ít hơn số lượng mẫu thiết lập trong tiêu chuẩn.

### Lỗi 4: Lỗi "검사항목이 등록되어있지 않습니다" (Chưa đăng ký hạng mục kiểm tra) khi tạo Lot OQC tại C512
*   **Triệu chứng:** Khi bấm tạo Lot OQC tại màn hình **C512**, hệ thống báo lỗi tiếng Hàn `"검사항목이 등록되어있지 않습니다"` và chặn không cho tiến hành.
*   **Nguyên nhân gốc:** Model sản phẩm mới (ví dụ: `LIVT38-037`) chưa được cấu hình thuộc tính OQC trong bảng `STB_ModelBasicInfo` (bị trống các cột `OqcType`, `InspectionType`, `OqcInspectionRuleType`) và không có bản ghi hạng mục đo kiểm tiêu chuẩn nào trong bảng `STB_MaterialQcInspectionItem`.
*   **Cách khắc phục:**
    *   **Bằng SQL:**
        1. Cập nhật thuộc tính kiểm định trong `STB_ModelBasicInfo`:
           ```sql
           UPDATE STB_ModelBasicInfo SET OqcType = 'MANUAL', OqcInspectionRuleType = 'BY_MODEL' WHERE ModelCode = 'LIVT38-037';
           ```
        2. Copy các hạng mục kiểm tra chuẩn (ví dụ từ model cùng loại `LIVT38-010`) sang cho model mới trong bảng `STB_MaterialQcInspectionItem`.
    *   **Bằng UI (Dành cho User):**
        1. Mở màn hình **A410**, tìm model `LIVT38-037` và cập nhật: `OqcType` = `MANUAL`, `OqcInspectionRuleType` = `BY_MODEL`, `InspectionType` = `SAMPLE`. Nhấn **Lưu**.
        2. Tắt và mở lại màn hình **C151**, chọn model `LIVT38-037` rồi gán và Lưu spec cho 5 hạng mục QC chính (`IQC_GPD_22`, `PQC_V01_06`, `PQC_V01_07`, `PQC_V01_08`, `PQC_V01_09`) tương tự `LIVT38-010`.
*   **Chi tiết nghiệp vụ:** Xem file script [fix_qc_items_LIVT38-037.sql](../sql/scripts/fix_qc_items_LIVT38-037.sql).

---

## C561 / C562 / C563 / C564 — Bending/Cutting QC (Kiểm tra chất lượng uốn/cắt Cell)

### Lỗi 1: Quét Barcode tại C563 báo lỗi thiếu hạng mục đo hoặc không hiển thị thông số đo
*   **Triệu chứng:** Khi mở màn hình kiểm định uốn/cắt **C563** và quét barcode của mẫu uốn/cắt Cell, lưới đo trống trơn hoặc báo lỗi chặn.
*   **Nguyên nhân gốc:** Model sản phẩm chưa được cấu hình nhóm hạng mục kiểm tra QC tại **C561** hoặc chưa được tạo Lot kiểm định tại **C562**.
*   **Cách khắc phục:**
    1. Vào màn hình **C561**, tìm đúng `MaterialCode`, chọn nhóm kiểm tra và Lưu lại.
    2. Vào màn hình **C562**, quét barcode sản phẩm để sinh Lot kiểm định.
    3. Quay lại màn hình **C563** thực hiện nhập dữ liệu. Nếu đã cấu hình mà vẫn trống, nhấn nút `"Tổng hợp hạng mục"` để đồng bộ và làm mới danh sách đo.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](KB_05_QC_ELECTRODE.md#94-bendingcutting-qc-c561c564).

---

## F110 — Operating Properties (Cấu hình thuộc tính quản lý tồn kho)

### Lỗi 1: Vật tư mới không thực hiện gộp Box được tại B523 hoặc B525
*   **Triệu chứng:** Khi công nhân quét gộp Box tại chuyền sản xuất, hệ thống báo lỗi chặn giao dịch do thiếu Lot hoặc cờ Barcode của mã vật tư đó.
*   **Nguyên nhân gốc:** Bảng cấu hình thuộc tính quản lý kho `STB_MaterialStockAttributeInfo` chưa được tạo dòng cho mã vật tư mới, hoặc các cờ quản lý `IsLotUse`, `IsUseBarcode` đang bị tắt (bằng 0).
*   **Cách khắc phục:** Vào màn hình **F110**, tìm mã vật tư, tick chọn `IsLotUse` và `IsUseBarcode` rồi nhấn Lưu. Hoặc chạy SQL cập nhật trực tiếp:
    ```sql
    UPDATE STB_MaterialStockAttributeInfo SET IsLotUse = 1, IsUseBarcode = 1 WHERE MaterialCode = 'MÃ_VẬT_TƯ';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 2](KB_06_MASTER_DATA_TOOLS.md#2-cấu-hình-vận-hành-f110).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_07_GROUPWARE_INTEGRATION.md § 6](KB_07_GROUPWARE_INTEGRATION.md#6-chỉ-định-ncc--nvl-f130--f140).

---

## F330 — Goods Receipt & Part Labels (Nhập kho nguyên vật liệu)

### Lỗi 1: Báo lỗi "Exception occurred" khi lưu phiếu nhập kho
*   **Triệu chứng:** Thủ kho nhập thông tin và click Lưu phiếu tại **F330** hệ thống văng popup báo lỗi Exception.
*   **Nguyên nhân gốc:** Trường `LotAttr10` (Đặc tính 10 / Ngày sản xuất Vendor) bị Null hoặc do định dạng quét mã Lot nhà cung cấp in quá dài vượt quá giới hạn thiết lập của trường.
*   **Cách khắc phục:**
    1. Cấu hình lại chiều dài quét cắt chuỗi mã Lot Vendor trên tab 3 giao diện F330.
    2. Sửa SQL Function parse ngày SX `fn_VVT_getdatebyVendorLot_MergeCode` nếu NCC thay đổi định dạng in Lot trên tem (Xem chi tiết tại [KB_02 § 4.11](KB_02_KHO_WMS.md#411-lỗi-không-lưu-được-f330---cấu-hình-và-sửa-lỗi-đọc-đặc-tính-10-vendor-lot-no)).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.16](KB_02_KHO_WMS.md#416-hủy-phiếu-nhập-kho-f330-đã-confirmed).

### Lỗi 3: Không đọc được ngày sản xuất cho nguyên vật liệu PCB/dây điện (không tự động nhảy hạn dùng, tự động vào kho HOLDING)
*   **Triệu chứng:** Khi quét mã Lot nhà cung cấp cho các mã PCB (`BEPCBA-%`) và dây điện (`BEMC00-%`) tại F330, nếu mã Lot không bắt đầu bằng ký tự `'2'` (không theo format date-based lot thông thường), hệ thống không parse được ngày sản xuất, lưu `1900-01-01` vào DB, gây lỗi hạn sử dụng hoặc tự động đưa Lot vào kho `HOLDING`. Ngoài ra, khi người dùng sửa ngày sản xuất trên lưới F330 và nhấn nút "Lot 변경" (Lot Change), hệ thống không cập nhật ngày sản xuất thực tế (`LotAttr10`) trong bảng tồn kho `STB_MaterialLotInfo`.
*   **Nguyên nhân gốc:** 
    1. Hàm SQL `fn_VVT_getdatebyVendorLot_MergeCode` không có nhánh xử lý fallback cho mã PCB/dây điện khi Vendor Lot không bắt đầu bằng `'2'`.
    2. SP `usp_DoChangeMaterialDocLotInfo` khi update tồn kho `STB_MaterialLotInfo` chỉ cập nhật cột `LotNo` mà bỏ quên cột `LotAttr10` (ngày sản xuất / MFG Date).
*   **Cách khắc phục:**
    1. Cập nhật SQL Function `fn_VVT_getdatebyVendorLot_MergeCode` (dòng 712) để tự động fallback về ngày hiện tại (`GETDATE()` / ngày về) cho các mã PCB (`BEPCBA-%`), dây điện (`BEMC00-%`) và phụ kiện liên quan nếu Vendor Lot không đúng định dạng:
       ```sql
       when (
           @materialcode like 'BEPCBA-%'
           or @materialcode like 'BEMC00-%'
           -- ... các mã liên quan ...
       ) then
           case 
               when LEFT(@vendorlot, 1) = '2' and len(@vendorlot) >= 8 and ISDATE(substring(@vendorlot,1,4)+'-'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)) = 1
                   then substring(@vendorlot,1,4)+'-'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)
               else CONVERT(VARCHAR(10), GETDATE(), 120)
           end
       ```
    2. Cập nhật SP `usp_DoChangeMaterialDocLotInfo` (dòng 235) để đồng bộ ngày sản xuất thực tế sang bảng tồn kho chính khi người dùng click Lot Change sửa trên UI:
       ```sql
       UPDATE STB_MaterialLotInfo
       SET LotNo = @LotNo,
           LotAttr10 = @PackDate  -- Bổ sung cập nhật MFG Date
       WHERE Lotid = @LotId;
       ```
*   **Chi tiết nghiệp vụ:** Xem tại [fn_VVT_getdatebyVendorLot_MergeCode.sql](../sql/procedures/fn_VVT_getdatebyVendorLot_MergeCode.sql#L712) và [usp_DoChangeMaterialDocLotInfo.sql](../sql/procedures/usp_DoChangeMaterialDocLotInfo.sql#L235).

---

## F430 — Goods Issue / Production Material Request (Xuất kho ra chuyền)

### Lỗi 1: Chặn quét xuất kho báo lỗi vi phạm nguyên tắc FIFO
*   **Triệu chứng:** Quét xuất Lot NVL ra chuyền tại **F430** hệ thống chặn và báo lỗi vi phạm FIFO (Lot nhập sau không được xuất trước).
*   **Nguyên nhân gốc:** Bật cờ `IsFIFO = 1` tại F110 và SP `usp_VVTMaterialWarehouse_validFIFO` phát hiện có Lot khác cùng mã có ngày nhập kho `CreateDateTime` cũ hơn đang tồn kho.
*   **Cách khắc phục:**
    1. Yêu cầu thủ kho tìm đúng Lot cũ nhất trong kho để xuất trước.
    2. Trường hợp khẩn cấp (hàng cũ bị hỏng hoặc thất lạc chưa kiểm kê), IT có thể bypass bằng cách lùi ngày tạo `CreateDateTime` của Lot hiện tại trên DB, hoặc tạm thời tắt check FIFO của mã vật tư đó bằng cách update cờ `IsFIFO = 0` tại bảng `STB_MaterialStockAttributeInfo`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.9](KB_02_KHO_WMS.md#49-fifo--validation-nvl-tắtbật-chặn).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.17](KB_02_KHO_WMS.md#417-thu-hồi-lot-từ-f430-về-kho-revert-xuất-kho).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.7](KB_02_KHO_WMS.md#47-chuyển-từ-kho-holding-sang-kho-chính).

---

## F741 — Lot Splitting (Quy trình tách Lot NVL)

### Lỗi 1: Lỗi không thực hiện tách được Lot NVL trên giao diện
*   **Triệu chứng:** OP thao tác chia nhỏ Lot NVL tại **F741** báo lỗi không in được tem hoặc sai số lượng chia.
*   **Nguyên nhân gốc:** Thiết lập quy cách đóng gói và cờ thuộc tính Lot tại F110 bị thiếu.
*   **Cách khắc phục:**
    Kiểm tra và thực hiện cấu hình đúng quy trình tách Lot trên UI, đảm bảo số lượng của các Lot con tổng cộng bằng Lot mẹ (Xem chi tiết tại [KB_02_KHO_WMS.md § 4.20](KB_02_KHO_WMS.md#420-f741--quy-trình-tách-lot-nguyên-vật-liệu-lot-splitting)).

---

## F742 / F746 — Slitting & Curling (Chia cuộn điện cực / Bo miệng)

### Lỗi 1: Cần hủy hoặc rollback giao dịch chia cuộn Slitting
*   **Triệu chứng:** Công nhân nhập sai thông số số lượng/chiều dài cuộn con sau chia cuộn Slitting tại **F742** và cần hoàn tác giao dịch.
*   **Nguyên nhân gốc:** Giao dịch đã sinh các Lot con liên kết khóa ngoại với Lot mẹ.
*   **Cách khắc phục:**
    Chạy script xóa ngược: bắt buộc phải tìm và xóa các bản ghi giao dịch của các Lot con trong bảng `STB_RawMaterialInputHist` (hoặc `STB_MaterialDocLotInfo` tùy trạm) trước, sau đó mới tiến hành xóa/revert Lot mẹ tại F742.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 10.1](KB_05_QC_ELECTRODE.md#101-hủyrollback-slitting-f742-và-f746).

### Lỗi 2: Mismatch logic tính tuổi thọ dao Slitting và Hardcode địa lý Bắc Giang
*   **Triệu chứng:** Máy chia cuộn điện cực tại nhà máy Hà Nam hoặc Hưng Yên bị bypass hoàn toàn việc kiểm tra dao cắt (không cảnh báo thay dao), hoặc báo lỗi không tìm thấy máy nếu cố cấu hình dao. Hoặc dao slitting bị khóa thay dao quá sớm do tính sai hao mòn.
*   **Nguyên nhân gốc:** 
    1. SP `usp_DoCreateSlittingResult` bị hardcode lọc cứng nhà máy Bắc Giang (`RouteCode = 'V-11_BG'`).
    2. Hệ thống đếm số lần cắt (số cuộn con) thay vì tổng số mét cắt thực tế (`GoodQtyLength`) để so sánh với tuổi thọ thiết kế (`StandardQty`), dẫn đến dao bị khóa sớm.
*   **Cách khắc phục:** 
    Cập nhật SP `usp_DoCreateSlittingResult`: sửa điều kiện lọc `RouteCode LIKE 'V-11%'` để hỗ trợ toàn hệ thống và đổi cơ chế tính tuổi thọ sang dùng `SUM(GoodQtyLength)`:
    ```sql
    -- 1. Sửa RouteCode check hỗ trợ toàn hệ thống
    IF @MachineCode IN (select MachineCode from STB_ProductMachine where RouteCode LIKE 'V-11%') and @KnifeCheck > 0
    
    -- 2. Đo tuổi thọ thực tế bằng tổng số mét cắt
    SELECT @ProdQtyCheck = ISNULL(SUM(GoodQtyLength), 0) from STB_ElectrodeSlittingResult where SlittingKnifeLotID = @SlittingKnifeLotID
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_30_THIET_BI_PHU_TRO_SAY_GA_DAO.md § 5](KB_30_THIET_BI_PHU_TRO_SAY_GA_DAO.md#5-danh-sách-lỗi-logic-điểm-yếu--giải-pháp-bugs--troubleshooting).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 10.1](KB_05_QC_ELECTRODE.md#101-flow-slitting-hà-nam).

---

## F750 — Stocktaking (Kiểm kê kho vật tư)

### Lỗi 1: Cảnh báo "Nguyên liệu phải được xuất kho lên Line trước khi chia nhỏ..." khi tách lô giá đỡ / chất mang (Substrate)
*   **Triệu chứng:** Khi chạy tác vụ chia/tách lô vật liệu giá đỡ substrate, hệ thống hiển thị thông báo lỗi chặn giao dịch (bằng tiếng Hàn hoặc tiếng Việt).
*   **Nguyên nhân gốc:** Lô vật liệu gốc chưa được thực hiện xuất kho lên chuyền sản xuất (chưa nằm ở kho công đoạn có cờ `IsRouteWarehouse = 1` mà vẫn đang tồn ở kho chính ROH), vi phạm điều kiện kiểm tra của Stored Procedure `usp_DoMakeStocktakingPlanResultForSupport`.
*   **Cách khắc phục:** Thủ kho thực hiện xuất kho Lot vật liệu gốc lên chuyền sản xuất trước (qua màn hình **F430**), sau đó mới thực hiện thao tác chia tách lô trên giao diện UI.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md § 5](KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md#5-nghiên-cứu-điển-hình-tự-động-tách-lô-giá-đỡ-substrate-splitting-case-study).

---

## F761 — Material GR History (Lịch sử vật tư vào kho)

### Lỗi 1: Lệch số liệu báo cáo đối soát kho kế toán do hiểu nhầm giao dịch hiển thị chữ tiếng Hàn
*   **Triệu chứng:** Khi đối soát số liệu xuất nhập kho tại **F761**, kế toán phát hiện các dòng giao dịch có cột `DocTypeName` chứa ký tự chữ Hàn Quốc gây sai lệch số liệu nhập mới.
*   **Nguyên nhân gốc:** Ký tự tiếng Hàn đại diện cho loại giao dịch "hoàn trả vật tư thừa từ sản xuất về kho ROH" (Revert từ F430) chứ không phải nhập mới từ nhà cung cấp.
*   **Cách khắc phục:** Hướng dẫn bộ phận kế toán phân biệt loại giao dịch: Giao dịch có tên tiếng Hàn là giao dịch trả hàng ảo/revert từ sản xuất về, còn giao dịch nhập mới thực tế được sinh ra từ phiếu nhập **F312**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 5](KB_02_KHO_WMS.md#5-báo-cáo-tồn-kho--lịch-sử-kho-f721-f761-f740).

---

## H301~H305 — Spare Parts Management (Quản lý kho & tuổi thọ phụ tùng)

### Lỗi 1: Phụ tùng máy bị mòn/hỏng thực tế nhưng hệ thống không cảnh báo hoặc chặn không cho thay thế
*   **Triệu chứng:** Phụ tùng trên line bị mòn nhưng hệ thống MES không hiển thị cảnh báo đỏ hoặc không cho phép quét barcode để xuất phụ tùng thay mới.
*   **Nguyên nhân gốc:** Chưa thiết lập hoặc khai báo sai chu kỳ thay thế định mức (`CycleReplace` theo ngày) và tuổi thọ chạy Lot (`LifeLotQty`) của phụ tùng tại **H301** (`STB_VNSparePartInfo`), hoặc Lot phụ tùng chưa được nhập kho tại **H302**.
*   **Cách khắc phục:**
    1. Kiểm tra tồn kho phụ tùng tại màn hình **H304** / **H302**.
    2. Truy cập màn hình **H301**, cấu hình đầy đủ `CycleReplace` và `LifeLotQty` cho mã phụ tùng tương ứng.
    3. Thực hiện xuất phụ tùng lên chuyền tại **H303** và theo dõi lịch sử thay thế tại **H305**.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.15](KB_03_SAN_XUAT.md#615-spare-part--h301h302h303h305) và [KB_20_MAY_MOC_BAO_TRI.md](KB_20_MAY_MOC_BAO_TRI.md).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 7](KB_08_KHO_THANH_PHAM_HN.md#7-hn101--thiết-lập-đơn-giá-theo-mã-kế-toán).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 2.1](KB_08_KHO_THANH_PHAM_HN.md#21-lỗi-unique-constraint-khi-gộp-túi-bóng-hn544--pkqn2100175).

### Lỗi 2: Gộp túi bóng thành hộp nhỏ ở HN544 bị mất số lượng (CurrentQty = 0)
*   **Triệu chứng:** Sau khi thực hiện gộp nilon thành hộp nhỏ, số lượng tồn hiển thị bằng 0 và không in được tem nhãn.
*   **Nguyên nhân gốc:** Lệch dữ liệu khi dồn số lượng giữa các Lot phụ.
*   **Cách khắc phục:**
    Chạy script dồn tổng số lượng thực tế vào 1 Lot duy nhất và xóa các Lot phụ rác:
    ```sql
    UPDATE STB_MaterialLotInfo SET InitialQty = 20, CurrentQty = 20 WHERE MaterialLotNo = 'MÃ_LOT_CẦN_GIỮ';
    DELETE FROM STB_MaterialLotInfo WHERE MaterialLotNo IN ('MÃ_LOT_RÁC_1', 'MÃ_LOT_RÁC_2');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.5](KB_04_DONG_GOI_IN_TEM.md#65-lỗi-gộp-túi-bóng-bị-mất-số-lượng-qty--0--hn544).

### Lỗi 3: Báo lỗi tiếng Hàn "Bạn chưa nhập kết quả..." hoặc sản lượng hiển thị bằng 0 ở HN523
*   **Triệu chứng:** Nhập mã Lot để gộp box ở màn hình gộp tùy chỉnh **HN523**, hệ thống báo lỗi tiếng Hàn hoặc hiển thị sản lượng đầu ra (OutputQty) bằng 0.
*   **Nguyên nhân gốc:** Cấu hình Routing của PO thiếu cờ công đoạn cuối làm công đoạn đầu ra (`IsOutputRoute = 1`), khiến Stored Procedure `usp_Vietnam_GetProdPackingForBarcode_VVT` trả về sản lượng bằng 0.
*   **Cách khắc phục:** Cập nhật lại cấu hình Routing của PO trên DB để đặt công đoạn cuối làm công đoạn đầu ra:
    ```sql
    UPDATE STB_ProductionOrderRouting SET IsOutputRoute = 1 WHERE PONo = 'MÃ_PO' AND RouteCode = 'MÃ_CÔNG_ĐOẠN_CUỐI';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.13](KB_04_DONG_GOI_IN_TEM.md#613-phân-tích-nguyên-nhân-lỗi-gộp-box-tùy-chỉnh-trên-màn-hình-hn523-sản-lượng-hiển-thị--0--cảnh-báo-tiếng-hàn).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_08_KHO_THANH_PHAM_HN.md § 1](KB_08_KHO_THANH_PHAM_HN.md#1-lỗi-hàng-xuất-ở-hn551-nhưng-tồn-kho-hn866-vẫn-còn).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_14_TRACE_BUG_METHODOLOGY.md § 4.7](KB_14_TRACE_BUG_METHODOLOGY.md#47-lỗi-nhảy-bước-cân-điện-cực-mixing-phần-mềm-electrodeweighing).

---

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_30_THIET_BI_PHU_TRO_SAY_GA_DAO.md § 5](KB_30_THIET_BI_PHU_TRO_SAY_GA_DAO.md#5-danh-sách-lỗi-logic-điểm-yếu--giải-pháp-bugs--troubleshooting).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_30_THIET_BI_PHU_TRO_SAY_GA_DAO.md § 5](KB_30_THIET_BI_PHU_TRO_SAY_GA_DAO.md#5-danh-sách-lỗi-logic-điểm-yếu--giải-pháp-bugs--troubleshooting).

---

## K101 / K109 / K110 — BG2 Production Plan & Scan (Sản xuất và quét NVL nhà máy BG2)

### Lỗi 1: Không tạo được Lot hoặc không chốt được sản lượng tại nhà máy Bắc Giang 2 (BG2)
*   **Triệu chứng:** Công nhân tại nhà máy BG2 không thể thực hiện các thao tác lập kế hoạch ngày hay quét chốt sản lượng trên các màn hình chuẩn B450 hay B597.
*   **Nguyên nhân gốc:** Nhà máy BG2 chạy cơ sở dữ liệu và phân hệ riêng biệt, sử dụng màn hình đặc thù: **K101** (tương đương B450) và **K109** (tương đương B597) có lọc riêng cho `WorkCenterCode = 'VVT_BG2'`.
*   **Cách khắc phục:** Hướng dẫn công nhân mở đúng màn hình của BG2:
    1. Lập kế hoạch ngày tại **K101** thay vì B450.
    2. Để quét NVL, OP mở màn hình **B540** -> nhấn nút **"Việt Nam_Kiểm tra thường xuyên_BG2"** để kích hoạt giao diện **K109** (tích hợp logic chặn quét sai NVL theo BOM).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.9](KB_03_SAN_XUAT.md#69-sự-khác-biệt-vận-hành-bg2).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.16](KB_04_DONG_GOI_IN_TEM.md#616-màn-hình--cấu-hình-thiết-kế-tem-z530a460).

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
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.1 và § 1.4](KB_01_UI_PHAN_QUYEN.md#11-lỗi-không-đăng-nhập-được-mes-allowflag).

---

## A210 — Material Master Registration (Đăng ký mã vật tư mới)

> 🔗 **Xem thêm:** Mục [F130 / F140 / A210](#f130--f140--a210--supplier-mapping--material-sync) phía trên đã có chi tiết luồng tích hợp NCC & đồng bộ vật tư.

### Lỗi 1: Mã vật tư mới đăng ký trên A210 nhưng không hiển thị khi nhập kho F330
*   **Triệu chứng:** Thủ kho tạo phiếu nhập kho mới, nhập mã vật tư mà không tìm thấy trong popup chọn MaterialCode.
*   **Nguyên nhân gốc:** Mã vật tư được tạo trong `STB_MaterialMaster` nhưng chưa được mapping nhà cung cấp trong `STB_MaterialVendorMapping` (F130/F140) và chưa khai báo thuộc tính kho `STB_MaterialStockAttributeInfo` (F110).
*   **Cách khắc phục:** Chạy checklist 3 bước: (1) Đăng ký A210, (2) Map NCC tại F130/F140, (3) Bật cờ F110.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_07_GROUPWARE_INTEGRATION.md § 6](KB_07_GROUPWARE_INTEGRATION.md) và [KB_06_MASTER_DATA_TOOLS.md § 1.3](KB_06_MASTER_DATA_TOOLS.md).

---

## A320 — Route Configuration (Cấu hình Route sản xuất)

### Lỗi 1: Thêm Route mới trong A320 nhưng không hiển thị tại B530 khi chốt sản lượng
*   **Triệu chứng:** OP không thấy công đoạn mới trong danh sách chọn Route để chốt sản lượng.
*   **Nguyên nhân gốc:** Route mới chỉ được khai báo ở bảng `STB_RouteInfo` nhưng chưa được gán vào Production Order Routing (`STB_ProductionOrderRouting`) của PO hiện tại.
*   **Cách khắc phục:** Vào A320 kiểm tra Route đã active (`IsUsed=1`), sau đó gán Route mới vào PO tại B310.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_10_KIEN_TRUC_VA_DATAFLOW.md § 2.1](KB_10_KIEN_TRUC_VA_DATAFLOW.md) và [KB_06_MASTER_DATA_TOOLS.md § 10](KB_06_MASTER_DATA_TOOLS.md).

---

## A410 — Model Basic Info (Thông tin cơ bản Model)

> 🔗 **Xem thêm:** Mục [A230 / A410](#a230--a410--master-data-model) phía trên đã có chi tiết lỗi thiếu Vol/Farad khi thêm model mới.

### Lỗi 1: Model mới không hiện Vol/Farad, C512 không tìm Lot, B597 lỗi sai chủng loại
*   **Triệu chứng:** Các thông số Vol/Farad trống, QC không tìm thấy Lot ở C512, B597 chặn quét NVL.
*   **Nguyên nhân gốc:** Chưa khai báo `STB_ModelBasicInfo` cho model mới.
*   **Cách khắc phục:**
    ```sql
    INSERT INTO STB_ModelBasicInfo (ModelCode, ModelName, MaterialTypeCode, ProductGroupCode, MBISizeH, MBISizeW, CreateDateTime, MBIExtText04, MBIExtText05)
    VALUES ('MÃ_MODEL', 'TÊN', 'MDL', 'HC-EDLC', 40, 18, GETDATE(), 'Vol', 'Farad');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 1.3](KB_06_MASTER_DATA_TOOLS.md).

### Lỗi 2: Thiếu cấu hình OqcType/InspectionType dẫn đến lỗi QC OQC
*   **Triệu chứng:** Khi tạo hồ sơ OQC tại C512, hệ thống không biết loại kiểm tra nào áp dụng.
*   **Nguyên nhân gốc:** Cột `OqcType` và `InspectionType` trong `STB_ModelBasicInfo` bị NULL.
*   **Cách khắc phục:** Cập nhật giá trị OqcType và InspectionType cho model tại A410.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.2](KB_05_QC_ELECTRODE.md).

---

## A418 — Packing Standard by Size (Tiêu chuẩn đóng gói theo kích thước)

> 🔗 **Xem thêm:** Mục [B418](#b418--packing-quantity-standards) phía trên đã có chi tiết lỗi tiêu chuẩn đóng gói.

### Lỗi 1: B523 báo "Chưa có tiêu chuẩn đóng gói" do Size mới chưa khai báo A418
*   **Triệu chứng:** Gộp Box tại B523 bị chặn với thông báo lỗi.
*   **Nguyên nhân gốc:** `STB_PackingStandard` chưa có dòng cho `MBISizeD` của Model mới.
*   **Cách khắc phục:** Vào A418, đăng ký Size mới và thiết lập PackQty.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 11](KB_06_MASTER_DATA_TOOLS.md).

---

## A419 — Packing Standard Configuration (Cấu hình số lượng đóng gói)

### Lỗi 1: Thêm model mới nhưng không đóng gói được tại B523
*   **Triệu chứng:** B523 không cho gộp Box, báo lỗi chưa có tiêu chuẩn đóng gói.
*   **Nguyên nhân gốc:** Chưa khai báo quy cách đóng gói (VinylBagQty, InnerBoxQty, OutBoxQty) cho model mới trong `STB_PackingStandard` tại A419.
*   **Cách khắc phục:** Vào A419, chọn MaterialTypeCode = `FERT`, nhập Size và các thông số đóng gói, nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.1](KB_04_DONG_GOI_IN_TEM.md) và [KB_14_TRACE_BUG_METHODOLOGY.md](KB_14_TRACE_BUG_METHODOLOGY.md).

---

## A460 — Label Mapping (Mapping mẫu tem cho Model)

> 🔗 **Xem thêm:** Mục [Z530 / A460](#z530--a460--label-layout--mapping) phía trên đã có chi tiết lỗi in tem.

### Lỗi 1: In tem ra mẫu không đúng hoặc tem trống do chưa map mẫu tem cho Model
*   **Triệu chứng:** In tem tại B523/B754/B757 hiện ra mẫu tem sai hoặc trống thông tin.
*   **Nguyên nhân gốc:** Model chưa được map với mẫu tem tương ứng trong `STB_ModelLabelInfo` tại A460.
*   **Cách khắc phục:**
    ```sql
    SELECT ModelCode, FormatName FROM STB_ModelLabelInfo WHERE ModelCode = 'MÃ_MODEL';
    -- Nếu trống → Vào A460 chọn Model, chọn mẫu tem AssembleLabel (dòng 2) cho SX, PartLabel cho kho.
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.16](KB_04_DONG_GOI_IN_TEM.md).

---

## B220 — Route Group Setup (Thiết lập nhóm Route)

> 🔗 **Xem thêm:** Mục [B210 / B220 / B230 / B240](#b210--b220--b230--b240--production-routing-setup) phía trên đã có chi tiết lỗi thiết lập Line/Route.

### Lỗi 1: Nhóm Route không hiển thị đúng công đoạn khi cấu hình sản xuất
*   **Triệu chứng:** Khi lập PO tại B310, danh sách công đoạn bị thiếu hoặc sai thứ tự.
*   **Nguyên nhân gốc:** Nhóm Route chưa được cấu hình đúng tại B220.
*   **Cách khắc phục:** Vào B220 kiểm tra Route Group, đảm bảo các RouteCode được gán đúng thứ tự.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](KB_06_MASTER_DATA_TOOLS.md) và [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md).

---

## B230 — Machine Route Mapping (Ánh xạ máy - Route)

> 🔗 **Xem thêm:** Mục [B210 / B220 / B230 / B240](#b210--b220--b230--b240--production-routing-setup) phía trên.

### Lỗi 1: Dùng B230 thay thế khi B270 bị lỗi popup
*   **Triệu chứng:** B270 bị lỗi popup trống không hiển thị danh sách máy. Cần cách thay thế.
*   **Nguyên nhân gốc:** SP `usp_Set_VVT_Info_get` bị hardcode Whitelist UserID tại B270.
*   **Cách khắc phục:** Sử dụng B230 để gán máy vào Route khi B270 gặp sự cố. B230 có giao diện tương tự nhưng không qua SP bị whitelist.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](KB_01_UI_PHAN_QUYEN.md) và [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md).

---

## B240 — Machine Master Setup (Thiết lập máy theo công đoạn)

> 🔗 **Xem thêm:** Mục [B210 / B220 / B230 / B240](#b210--b220--b230--b240--production-routing-setup) phía trên.

### Lỗi 1: B530 không hiển thị máy trong dropdown khi chốt sản lượng
*   **Triệu chứng:** OP quét chốt sản lượng tại B530 nhưng không thấy máy trong danh sách chọn.
*   **Nguyên nhân gốc:** Máy chưa được gán vào Route đang chạy tại B240.
*   **Cách khắc phục:** Vào B240, chọn máy và gán vào RouteCode tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](KB_06_MASTER_DATA_TOOLS.md).

---

## B270 — Product Machine Mapping (Ánh xạ máy - sản phẩm)

> 🔗 **Xem thêm:** Mục [B250 / B270](#b250--b270--cell--machine-mapping) phía trên đã có chi tiết lỗi popup trống và thêm Cell/Line mới.

### Lỗi 1: Popup gán máy B270 trống không hiển thị danh sách thiết bị
*   **Triệu chứng:** Danh sách máy trống khi mở popup tại B270.
*   **Nguyên nhân gốc:** SP `usp_Set_VVT_Info_get` hardcode Whitelist UserID.
*   **Cách khắc phục:** ALTER SP bổ sung UserID, hoặc dùng B230 thay thế.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](KB_01_UI_PHAN_QUYEN.md).

---

## B301 — Production Order Info (Thông tin lệnh sản xuất chi tiết)

### Lỗi 1: Dữ liệu PO bị lệch giữa B301 và B310
*   **Triệu chứng:** Thông tin chi tiết PO tại B301 không khớp với tổng quan tại B310.
*   **Nguyên nhân gốc:** Bảng `STB_ProductionOrderInfo` có dữ liệu không nhất quán do đồng bộ lỗi từ Groupware.
*   **Cách khắc phục:** Kiểm tra dữ liệu trực tiếp trong DB và đồng bộ lại từ Groupware ESM Bridge.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_28_SYSTEM_OBJECTS_MAP.md](KB_28_SYSTEM_OBJECTS_MAP.md).

---

## B450 — Day Production Plan (Kế hoạch sản xuất ngày)

> 🔗 **Xem thêm:** Mục [B310 / B450](#b310--b450--production-orders--day-plan) phía trên đã có chi tiết lỗi đồng bộ PO.

### Lỗi 1: Không tạo được Lot do chưa tích cờ IsFixed
*   **Triệu chứng:** OP lập kế hoạch ngày tại B450, bấm tạo Lot nhưng hệ thống không sinh được Lot.
*   **Nguyên nhân gốc:** Cột `IsFixed` trong `STB_DayProdPlan` chưa được tích chọn (= 0).
*   **Cách khắc phục:** Vào B450, tìm dòng kế hoạch ngày tương ứng, tick chọn cột `IsFixed` rồi nhấn Lưu. Sau đó bấm tạo Lot.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 2](KB_03_SAN_XUAT.md).

### Lỗi 2: Xóa PO phải xóa đồng thời ở B310 và B450
*   **Triệu chứng:** Xóa PO tại B310 nhưng dữ liệu kế hoạch ngày vẫn còn tại B450 gây lỗi trùng.
*   **Nguyên nhân gốc:** Xóa PO cần xóa cả 3 bảng: `STB_ProductionOrderInfo`, `STB_ProductionOrderBom`, `STB_ProductionOrderRouting` (B310) VÀ `STB_DayProdPlan`, `STB_SetInfo` (B450).
*   **Cách khắc phục:** Xóa PO theo quy trình đầy đủ 5 bảng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 5.7](KB_03_SAN_XUAT.md).

---

## B453 — Production Schedule (Lịch trình sản xuất)

### Lỗi 1: Lịch trình sản xuất không hiển thị dữ liệu sau khi tạo Lot
*   **Triệu chứng:** Sau khi tạo Lot tại B450, mở B453 nhưng không thấy lịch trình sản xuất tương ứng.
*   **Nguyên nhân gốc:** B453 hiển thị dựa trên dữ liệu `STB_SetInfo` kết hợp `STB_DayProdPlan`. Nếu `InputJobDate` bị NULL hoặc `IsFixed = 0` thì lịch trình không hiển thị.
*   **Cách khắc phục:** Kiểm tra B450 đã tích `IsFixed` và Lot đã được tạo thành công.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 2](KB_03_SAN_XUAT.md) và [KB_04_DONG_GOI_IN_TEM.md](KB_04_DONG_GOI_IN_TEM.md).

---

## B460 — Production Line Status (Trạng thái Line sản xuất)

### Lỗi 1: Trạng thái Line không cập nhật real-time
*   **Triệu chứng:** Màn hình B460 hiển thị trạng thái Line sản xuất bị delay hoặc không chính xác.
*   **Nguyên nhân gốc:** Dữ liệu lấy từ bảng `STB_SetInfo` kết hợp `STB_ProdRouteHist` có thể bị delay do cache hoặc lỗi refresh.
*   **Cách khắc phục:** Nhấn nút Refresh/Tìm kiếm lại. Nếu vẫn sai, kiểm tra trực tiếp bảng `STB_ProdRouteHist` xem công đoạn đã được ghi nhận chưa.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6](KB_03_SAN_XUAT.md) và [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md).

---

## B470 — Electrode Line Status (Trạng thái Line điện cực)

### Lỗi 1: Trạng thái Line điện cực không hiển thị hoặc không chính xác
*   **Triệu chứng:** B470 không hiện dữ liệu Line điện cực hoặc hiện sai công đoạn đang chạy.
*   **Nguyên nhân gốc:** Dữ liệu điện cực lưu ở bảng riêng (`STB_ElectrodeCoatingInfo`, `STB_ElectrodeSlittingResult`). Nếu Line điện cực chưa được cấu hình Route tương ứng thì B470 sẽ trống.
*   **Cách khắc phục:** Kiểm tra cấu hình Route điện cực tại B220 và mapping máy tại B270.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md) và [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md).

---

## B525 — Warehouse Packing (Đóng gói kho)

> 🔗 **Xem thêm:** Mục [B523 / B525](#b523--b525--packaging--box-matching) phía trên đã có chi tiết lỗi đóng gói.

### Lỗi 1: Không gộp được Box tại kho (khác B523 dành cho sản xuất)
*   **Triệu chứng:** Thủ kho thao tác đóng gói tại B525 bị chặn tương tự B523.
*   **Nguyên nhân gốc:** B525 là phiên bản dành cho kho, cùng logic với B523 nhưng lọc theo WarehouseCode. Thiếu cờ `IsLotUse` hoặc `IsUseBarcode` tại F110.
*   **Cách khắc phục:** Áp dụng cùng quy trình debug 4 bước như B523 (xem mục B523 phía trên).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.4](KB_04_DONG_GOI_IN_TEM.md).

---

## B528 — Barrel Barcode (In tem thùng phuy/Barrel)

### Lỗi 1: Lỗi in tem Barrel hoặc không sinh được mã Barcode Barrel
*   **Triệu chứng:** Bấm in tem thùng Barrel tại B528 bị lỗi hoặc barcode không hiển thị.
*   **Nguyên nhân gốc:** Cấu hình Barrel chưa được khai báo trong bảng cấu hình sản phẩm, hoặc chưa có template tem Barrel tại Z530/A460.
*   **Cách khắc phục:** Kiểm tra cấu hình template tem Barrel tại Z530, mapping tại A460, và đảm bảo Lot đã hoàn thành đóng gói tại B523.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.10](KB_03_SAN_XUAT.md).

---

## B540 — Process Input V22→V28 (Nhập NVL theo công đoạn)

### Lỗi 1: Không nhập được NVL do thiếu 4 cột màu bắt buộc
*   **Triệu chứng:** OP quét nhập NVL tại B540 nhưng hệ thống không cho lưu, báo thiếu thông tin bắt buộc.
*   **Nguyên nhân gốc:** 4 cột màu đặc biệt trên lưới B540 phải được nhập đầy đủ trước khi in barcode. Đây là requirement cứng trong SP `usp_Vietnam_RawMaterialInputHist_uid`.
*   **Cách khắc phục:** Hướng dẫn OP nhập đầy đủ 4 cột màu (hiển thị nền vàng/cam trên grid). Nếu vẫn lỗi, kiểm tra `STB_MaterialLotInfo` xem Lot NVL có tồn tại không.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.4](KB_03_SAN_XUAT.md) và [KB_14_TRACE_BUG_METHODOLOGY.md](KB_14_TRACE_BUG_METHODOLOGY.md).

### Lỗi 2: Checkbox ProdQtyFinishYN không tích được
*   **Triệu chứng:** OP muốn hoàn thành công đoạn nhưng không tích được checkbox `ProdQtyFinishYN`.
*   **Nguyên nhân gốc:** Hệ thống tự động tích `ProdQtyFinishYN` khi chốt sản lượng ở B530, không cho tích trực tiếp.
*   **Cách khắc phục:** OP cần chốt sản lượng tại B530 trước, hệ thống sẽ tự tích checkbox.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 2](KB_03_SAN_XUAT.md).

---

## B726 — Scrap After Production (Báo phế sau sản xuất)

### Lỗi 1: Báo phế không thành công hoặc bản ghi phế không hiển thị
*   **Triệu chứng:** OP thực hiện báo phế sản phẩm sau sản xuất tại B726 nhưng hệ thống không ghi nhận hoặc dữ liệu không hiển thị.
*   **Nguyên nhân gốc:** SP `usp_vn_scrapafterproduction` thực hiện xóa mềm (`IsDeleted = 1`), nếu Lot đã bị đánh dấu xóa trước đó thì không tạo được bản ghi phế mới.
*   **Cách khắc phục:** Kiểm tra bảng `STB_VN_SCRAP_AFTERPRODUCTIONS` xem Lot đã tồn tại chưa. Nếu cần xóa lại: `UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS SET IsDeleted = 0 WHERE LotNo = 'MÃ_LOT'`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6](KB_03_SAN_XUAT.md).

---

## B733 — Box Matching Report (Báo cáo gộp Box)

### Lỗi 1: Báo cáo B733 hiển thị trống không có dữ liệu
*   **Triệu chứng:** Mở B733 tìm kiếm Lot nhưng không hiện kết quả gộp Box nào.
*   **Nguyên nhân gốc:** Lot đó chưa được gộp Box tại B523 (chưa hoàn thành đóng gói).
*   **Cách khắc phục:** Kiểm tra B523 xem Lot đã được gộp Box chưa. Nếu chưa, thực hiện gộp Box trước rồi quay lại B733.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.5](KB_03_SAN_XUAT.md).

---

## B755 — PAC Inner Label (In tem nhãn trong PAC)

> 🔗 **Xem thêm:** Mục [B754 / B756](#b754--b756--pac-customer-labels) phía trên đã có chi tiết lỗi in tem PAC.

### Lỗi 1: In tem Inner Label PAC bị thiếu Serial hoặc thông tin sai
*   **Triệu chứng:** Tem trong (Inner Label) PAC in ra thiếu Serial hoặc trọng lượng không đúng.
*   **Nguyên nhân gốc:** Nhầm lẫn giữa nhãn trong (Inner) và nhãn ngoài (Outer). Serial nhãn trong và ngoài chạy độc lập.
*   **Cách khắc phục:** Đảm bảo chọn đúng loại tem (Inner). Không tick `IsOuter` khi in nhãn trong.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.9.1](KB_04_DONG_GOI_IN_TEM.md).

---

## B756 — PAC Outer Label (In tem nhãn ngoài PAC)

> 🔗 **Xem thêm:** Mục [B754 / B756](#b754--b756--pac-customer-labels) phía trên đã có chi tiết lỗi in tem PAC Outer.

### Lỗi 1: Tem thùng Outer Label PAC không hiển thị Serial hoặc cân nặng
*   **Triệu chứng:** In tem thùng lớn B756 thiếu Serial nhãn hoặc không hiện trọng lượng.
*   **Nguyên nhân gốc:** Chưa tick `IsOuter = 1` khi in nhãn ngoài, hoặc chưa bật `IsWeightLabel`.
*   **Cách khắc phục:** Tick `IsOuter` cho nhãn ngoài. Tick `IsWeightLabel` cho tem cân nặng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.9.1](KB_04_DONG_GOI_IN_TEM.md) và [KB_14_TRACE_BUG_METHODOLOGY.md](KB_14_TRACE_BUG_METHODOLOGY.md).

---

## B758 — Digi-Key Mixed Load Label (In tem hàng hỗn hợp Digi-Key)

> 🔗 **Xem thêm:** Mục [B757 / B758](#b757--b758--digi-key-customer-labels) phía trên đã có chi tiết lỗi in tem Digi-Key.

### Lỗi 1: Không in được tem Mixed Load tại B758
*   **Triệu chứng:** In tem thùng hàng hỗn hợp (Mixed Load) Digi-Key bị lỗi.
*   **Nguyên nhân gốc:** Thùng chứa nhiều model/size khác nhau, SP cần kiểm tra tất cả barcode trong thùng khớp.
*   **Cách khắc phục:** Đảm bảo tất cả barcode trong thùng đã được gộp box tại B523 và thông tin PO đầy đủ.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.9.2](KB_04_DONG_GOI_IN_TEM.md).

---

## B767 — Customer Label Print (In tem nhãn khách hàng chung)

### Lỗi 1: Không in được tem cho khách hàng mới
*   **Triệu chứng:** Khi in tem cho khách hàng mới tại B767, hệ thống báo lỗi không tìm thấy mẫu tem.
*   **Nguyên nhân gốc:** Chưa tạo mẫu tem tại Z530 và chưa mapping tại A460.
*   **Cách khắc phục:** Tạo mẫu tem mới tại Z530, approve layout, sau đó mapping model vào mẫu tem tại A460.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.16](KB_04_DONG_GOI_IN_TEM.md).

---

## B781 — Packing Print Time Report (Tra sản lượng đóng gói nhập tay)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên đã có chi tiết lỗi đơn giá.

### Lỗi 1: Sai ngày in tem đóng gói tại B781
*   **Triệu chứng:** Báo cáo B781 hiển thị sai ngày in/đóng gói so với thực tế.
*   **Nguyên nhân gốc:** Cột `PrintTime` trong `STB_SavePackingTime_VVT` bị ghi sai khi nhập tay tại B523.
*   **Cách khắc phục:** Chạy SQL sửa trực tiếp: `UPDATE STB_SavePackingTime_VVT SET PrintTime = 'NGÀY_ĐÚNG' WHERE LotNo = 'MÃ_LOT'`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 5.3](KB_03_SAN_XUAT.md).

---

## B782 — Lot Routing History (Lịch sử Routing theo Lot)

### Lỗi 1: Sai ngày sản xuất (JobDate) trên báo cáo B782
*   **Triệu chứng:** Barcode hiển thị sai ngày sản xuất trên lịch sử Routing.
*   **Nguyên nhân gốc:** Cột `JobDate` trong `STB_ProdRouteHist` bị ghi nhận sai do OP chốt sản lượng không đúng ca.
*   **Cách khắc phục:**
    ```sql
    UPDATE STB_ProdRouteHist SET JobDate = 'NGÀY_ĐÚNG'
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE')
    AND RouteCode = 'MÃ_CÔNG_ĐOẠN';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 5.2](KB_03_SAN_XUAT.md).

---

## B786 — ESR History (Lịch sử ESR toàn nhà máy)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên.

### Lỗi 1: Tab Online báo Status khác OK hoặc không lấy được data ESR
*   **Triệu chứng:** Tab Online tại B786 hiển thị Status Error, dữ liệu ESR không cập nhật.
*   **Nguyên nhân gốc:** Phần mềm đo ESR tại máy bị mất kết nối hoặc chưa upload kết quả vào bảng `Stb_ESRValueMonitor`.
*   **Cách khắc phục:** Kiểm tra phần mềm đo ESR trên máy tính chuyền. Cột "Mã công ty" trên B786 = version phần mềm đo.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6](KB_03_SAN_XUAT.md).

---

## B789 — Packing Qty Edit (Sửa số lượng đóng gói)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên.

### Lỗi 1: Cần xóa hoặc sửa số lượng Packing đã lưu
*   **Triệu chứng:** Số lượng đóng gói bị ghi nhận sai, cần sửa lại.
*   **Nguyên nhân gốc:** OP nhập nhầm số lượng khi gộp Box tại B523. B789 sử dụng SP `usp_Vietnam_GetBoxIDForLotNo_VVT` để tra cứu.
*   **Cách khắc phục:** Sửa trực tiếp trong bảng `STB_SavePackingTime_VVT` theo LotNo và ID giao dịch.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.6](KB_04_DONG_GOI_IN_TEM.md).

---

## B791 — NG Defect Repair (Sửa chữa lỗi NG)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên.

### Lỗi 1: Lệch DefectQty và ProdQty khi sửa lỗi NG
*   **Triệu chứng:** Sau khi sửa chữa lỗi NG, số lượng hàng lỗi và hàng tốt bị lệch tổng.
*   **Nguyên nhân gốc:** SP `usp_ModuleLotTrackingInfo_VVT2_get` đọc từ cả `STB_DefectRepairInfo` và `STB_ProdRouteHist`. Khi sửa phải cập nhật đồng bộ cả 2 bảng.
*   **Cách khắc phục:** Cập nhật đồng thời `DefectQty` trong `STB_DefectRepairInfo` và `ProdQty` trong `STB_ProdRouteHist`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 5.8](KB_03_SAN_XUAT.md) và [KB_05_QC_ELECTRODE.md § 9.5](KB_05_QC_ELECTRODE.md).

---

## B882 — ANDON Display (Màn hình ANDON trên MES)

### Lỗi 1: Dữ liệu ANDON không cập nhật hoặc hiển thị trống
*   **Triệu chứng:** Dashboard ANDON tại B882 không hiển thị sản lượng real-time.
*   **Nguyên nhân gốc:** SP `usp_Vietnam_AndonDetail_get` lấy dữ liệu từ `STB_ProdRouteHist` lọc theo `WorkCenterCode`. Nếu WorkCenterCode sai hoặc không khớp sẽ trống.
*   **Cách khắc phục:** Kiểm tra tham số filter WorkCenterCode trên ANDON display khớp với mã nhà máy đang chạy.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6](KB_03_SAN_XUAT.md) và [KB_28_SYSTEM_OBJECTS_MAP.md](KB_28_SYSTEM_OBJECTS_MAP.md).

---

## B934 — User Permission Config (Cấu hình quyền người dùng SX)

### Lỗi 1: Người dùng không có quyền thao tác trên màn hình sản xuất
*   **Triệu chứng:** OP đăng nhập MES nhưng các nút Save/Delete trên màn hình sản xuất bị disable.
*   **Nguyên nhân gốc:** UserID chưa được cấp quyền Execute cho các Button trên ScreenObject.
*   **Cách khắc phục:** Vào B934 hoặc Z220 gán quyền Execute cho Role tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 2](KB_01_UI_PHAN_QUYEN.md).

---

## B935 — Role Screen Mapping (Gán màn hình cho vai trò SX)

### Lỗi 1: Nhóm vai trò sản xuất không thấy màn hình mới trên menu
*   **Triệu chứng:** Sau khi tạo màn hình mới, nhóm SX không nhìn thấy trên menu MES.
*   **Nguyên nhân gốc:** Màn hình mới chưa được gán vào Role của nhóm SX tại B935/Z220.
*   **Cách khắc phục:** Vào B935 hoặc Z220, chọn Role Group tương ứng, tick chọn Screen ID mới, Lưu lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.4](KB_01_UI_PHAN_QUYEN.md).

---

## C112 — AQL Basic Rules (Quy tắc AQL cơ bản)

### Lỗi 1: Cấu hình mẫu kiểm tra AQL không áp dụng đúng cho OQC
*   **Triệu chứng:** Khi tạo hồ sơ OQC tại C512, số lượng mẫu lấy kiểm tra không đúng với quy tắc AQL.
*   **Nguyên nhân gốc:** Bảng quy tắc AQL chưa được cấu hình cho kích thước lô hàng tương ứng.
*   **Cách khắc phục:** Vào C112, kiểm tra và bổ sung quy tắc AQL cho size lô hàng (Lot Size) phù hợp.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_28_SYSTEM_OBJECTS_MAP.md](KB_28_SYSTEM_OBJECTS_MAP.md).

---

## C122 — IQC Material Inspection Setup (Thiết lập hạng mục kiểm tra NVL)

> 🔗 **Xem thêm:** Mục [C121 / C122](#c121--c122--qc-inspections) phía trên đã có chi tiết cấu hình QC đầu vào.

### Lỗi 1: Lot NVL nhập kho không tự động hiện hạng mục kiểm tra
*   **Triệu chứng:** Lot nguyên liệu hiển thị trên lưới QC nhưng không có hạng mục để nhập kết quả đo.
*   **Nguyên nhân gốc:** Mã NVL chưa được gán nhóm hạng mục kiểm tra IQC tại C122.
*   **Cách khắc phục:** Vào C122, chọn mã NVL, click chọn nhóm kiểm tra tương ứng để map dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.1](KB_05_QC_ELECTRODE.md).

---

## C131 — Inspection Item Master (Danh mục hạng mục kiểm tra)

### Lỗi 1: Thêm hạng mục kiểm tra mới không hiển thị tại C143
*   **Triệu chứng:** Hạng mục đo mới tạo tại C131 không xuất hiện khi cấu hình kiểm tra tại C143.
*   **Nguyên nhân gốc:** Cờ `IsUsed = 0` hoặc loại dữ liệu nhập (`DataType`) chưa được thiết lập đúng (1=số, 2=checkbox).
*   **Cách khắc phục:** Vào C131 kiểm tra cờ `IsUsed=1` và chọn DataType phù hợp.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 14](KB_06_MASTER_DATA_TOOLS.md).

---

## C132 — Inspection Group Setup (Thiết lập nhóm kiểm tra)

### Lỗi 1: Nhóm kiểm tra QC không hiển thị khi gán cho NVL tại C122 hoặc sản phẩm tại C143
*   **Triệu chứng:** Khi mở popup chọn nhóm kiểm tra, danh sách trống hoặc thiếu nhóm mới tạo.
*   **Nguyên nhân gốc:** Nhóm kiểm tra chưa được kích hoạt (`IsUsed = 0`) hoặc chưa được gán MaterialTypeCode phù hợp.
*   **Cách khắc phục:** Vào C132 kiểm tra nhóm mới, tick `IsUsed=1`, chọn đúng MaterialTypeCode.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md) và [KB_16_GIAI_THICH_DON_GIAN_LUONG_MES.md](KB_16_GIAI_THICH_DON_GIAN_LUONG_MES.md).

---

## C141 — Inspection Type Setup (Thiết lập loại hình kiểm tra chung)

### Lỗi 1: Sai loại dữ liệu nhập liệu (số thay vì checkbox hoặc ngược lại)
*   **Triệu chứng:** Grid nhập liệu kiểm tra QC hiển thị ô nhập số nhưng yêu cầu là checkbox, hoặc ngược lại.
*   **Nguyên nhân gốc:** Cột "Loại dữ liệu nhập vào" tại C141 bị thiết lập sai (`1`=số, `2`=tích checkbox).
*   **Cách khắc phục:** Vào C141, sửa lại cột DataType cho hạng mục tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---

## C143 — Inspection Item Configuration (Thiết lập hạng mục kiểm tra chi tiết)

### Lỗi 1: Mã NVL quét tại B597 không đi đến đúng hạng mục kiểm tra
*   **Triệu chứng:** NVL quét tại B597 bị map sai nhóm kiểm tra, hiện ra các hạng mục đo không liên quan.
*   **Nguyên nhân gốc:** Cấu hình tại C143 map sai mã NVL vào nhóm hạng mục không phù hợp.
*   **Cách khắc phục:** Vào C143, tìm mã NVL, chỉnh lại nhóm hạng mục kiểm tra tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---

## C151 — Material QC Detail Setup (Thiết lập chi tiết QC vật tư)

### Lỗi 1: Sau khi set A410 xong phải tắt C151 rồi mở lại mới hiển thị đúng
*   **Triệu chứng:** Cấu hình tại A410 đã lưu nhưng C151 vẫn hiện dữ liệu cũ.
*   **Nguyên nhân gốc:** Cache dữ liệu trên client. C151 không tự refresh sau khi A410 thay đổi.
*   **Cách khắc phục:** Đóng tab C151, mở lại từ menu. Dữ liệu sẽ load lại từ DB.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---

## C153 — QC Sample Config (Cấu hình mẫu kiểm tra QC)

### Lỗi 1: Số lượng mẫu kiểm tra (SampleQty) không khớp với thực tế đo
*   **Triệu chứng:** Máy đo trả về 50 mẫu nhưng C546 chỉ hiện 20 dòng.
*   **Nguyên nhân gốc:** `SampleQty` cấu hình trong bảng `STB_MaterialQcDetail` bị thiết lập sai.
*   **Cách khắc phục:** Vào C153 hoặc chỉnh trực tiếp `STB_MaterialQcDetail` để SampleQty khớp số lượng mẫu thực tế.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md).

---

## C243 — Electrode QC Measurement (Đo lường QC điện cực)

> 🔗 **Xem thêm:** Mục [F743~F748 / C243](#f743f748--c243--electrode-slitting--qc) phía trên đã có chi tiết Slitting & QC điện cực.

### Lỗi 1: Kết quả đo QC điện cực bị lệch hoặc không hiển thị
*   **Triệu chứng:** Grid đo QC điện cực trống hoặc giá trị đo bị sai.
*   **Nguyên nhân gốc:** Dữ liệu đo chưa được upload từ máy đo hoặc mapping giữa Lot điện cực và hạng mục đo bị sai.
*   **Cách khắc phục:** Kiểm tra kết nối máy đo và trạng thái upload trong `Stb_ESRValueMonitor`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md).

---

## C430 — QC Receiving Inspection (Kiểm tra chất lượng nhận hàng)

### Lỗi 1: Không tìm thấy Lot NVL để kiểm tra tại C430
*   **Triệu chứng:** QC mở C430 nhưng không thấy Lot NVL mới nhập kho để kiểm tra.
*   **Nguyên nhân gốc:** Lot NVL chưa được nhập kho tại F330 hoặc chưa được chuyển trạng thái từ `HOLDING_WH`.
*   **Cách khắc phục:** Kiểm tra F330 đã hoàn thành nhập kho, kiểm tra `STB_MaterialLotInfo` xem WarehouseCode.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.15](KB_02_KHO_WMS.md) và [KB_05_QC_ELECTRODE.md](KB_05_QC_ELECTRODE.md).

---

## C451 — OQC Schedule (Lịch kiểm tra OQC)

### Lỗi 1: Lịch OQC không hiển thị Lot cần kiểm tra
*   **Triệu chứng:** Mở C451 nhưng danh sách Lot chờ OQC trống.
*   **Nguyên nhân gốc:** Lot chưa hoàn thành đóng gói tại B523 hoặc cờ `IsOutputRoute` chưa được bật.
*   **Cách khắc phục:** Kiểm tra Lot đã gộp Box xong tại B523. Kiểm tra `IsOutputRoute = 1` trong `STB_ProductionOrderRouting`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 14](KB_06_MASTER_DATA_TOOLS.md).

---

## C460 — Electrode QC Report (Báo cáo QC điện cực)

### Lỗi 1: Báo cáo QC điện cực hiển thị trống hoặc thiếu dữ liệu
*   **Triệu chứng:** Mở C460 không thấy kết quả QC điện cực.
*   **Nguyên nhân gốc:** Chưa thực hiện QC điện cực hoặc dữ liệu QC chưa được đồng bộ.
*   **Cách khắc phục:** Kiểm tra các bảng `STB_CommInspDocHistory`, `STB_CommInspDocItem` xem dữ liệu QC điện cực đã được ghi nhận chưa.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 3](KB_05_QC_ELECTRODE.md) và [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md).

---

## C510 — OQC Lot Search (Tìm kiếm Lot OQC)

> 🔗 **Xem thêm:** Mục [C512 / C530 / C546](#c512--c530--c546--oqc-lot-management) phía trên đã có chi tiết lỗi OQC.

### Lỗi 1: Không tìm thấy Lot tại C510 để tạo hồ sơ OQC
*   **Triệu chứng:** Tìm kiếm Lot tại C510 trả về kết quả trống.
*   **Nguyên nhân gốc:** 3 nguyên nhân chính: (1) Lot chưa được tạo/gộp box, (2) Chưa set A410, (3) Nhà máy HN dùng Route VE02 riêng.
*   **Cách khắc phục:** Áp dụng checklist 3 bước debug giống C512 (xem mục C512 phía trên).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.2](KB_05_QC_ELECTRODE.md).

---

## C522 — Aging ESR SD (Dữ liệu Aging & ESR)

### Lỗi 1: Dữ liệu Aging/ESR không đồng bộ hoặc hiển thị sai
*   **Triệu chứng:** Kết quả Aging/ESR tại C522 bị thiếu hoặc không khớp với máy đo.
*   **Nguyên nhân gốc:** Phần mềm ESR chưa upload dữ liệu vào bảng `Stb_ESRValueMonitor` hoặc cờ `UploadToMes` chưa được set.
*   **Cách khắc phục:** Kiểm tra phần mềm đo ESR trên máy, reset cờ upload nếu cần.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_28_SYSTEM_OBJECTS_MAP.md](KB_28_SYSTEM_OBJECTS_MAP.md).

---

## C530 — QC Audit (Kiểm tra chất lượng trước xuất hàng)

> 🔗 **Xem thêm:** Mục [C512 / C530 / C546](#c512--c530--c546--oqc-lot-management) phía trên đã có chi tiết lỗi OQC.

### Lỗi 1: Không đổi được trạng thái Reject sang Pass ở QC Audit
*   **Triệu chứng:** Lot đã bị FAIL/Reject tại QC Audit C530 nhưng sau kiểm tra lại cần chuyển sang PASS.
*   **Nguyên nhân gốc:** UI không cho phép đổi ngược trạng thái. Cần can thiệp DB.
*   **Cách khắc phục:** Xóa kết quả QC cũ trong `STB_CommInspDocHistory` và `STB_CommInspDocItem`, sau đó QC kiểm tra lại từ đầu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md § 3.2](KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md).

---

## C540 — QC Result Report (Báo cáo kết quả QC)

### Lỗi 1: Báo cáo kết quả QC hiển thị thiếu hoặc sai thông tin
*   **Triệu chứng:** Báo cáo C540 thiếu kết quả đo hoặc hiện sai trạng thái PASS/FAIL.
*   **Nguyên nhân gốc:** Lệch dữ liệu giữa `STB_CommInspDocHistory` và `STB_MaterialQcSampleResult`.
*   **Cách khắc phục:** Kiểm tra trực tiếp DB, đối chiếu kết quả QC trong 2 bảng và sửa lại nếu lệch.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---

## C541 — QC Detail Result (Chi tiết kết quả QC)

### Lỗi 1: Chi tiết kết quả QC không load được dữ liệu
*   **Triệu chứng:** Mở C541 nhưng grid chi tiết kết quả trống trơn.
*   **Nguyên nhân gốc:** Chưa thực hiện QC hoặc `CommInspDocNo` bị NULL trong bảng `STB_CommInspDocItem`.
*   **Cách khắc phục:** Kiểm tra Lot đã hoàn thành QC chưa. Nếu đã QC mà vẫn trống, kiểm tra liên kết giữa `STB_CommInspDocHistory` và `STB_CommInspDocItem`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9](KB_05_QC_ELECTRODE.md).

---

## C546 — FOQC OCV/ESR (Kiểm tra OCV & ESR đầu ra)

> 🔗 **Xem thêm:** Mục [C512 / C530 / C546](#c512--c530--c546--oqc-lot-management) phía trên đã có chi tiết lỗi OCV/ESR hiển thị 20ea thay vì 50ea.

### Lỗi 1: C546 chỉ hiển thị 20 dòng mẫu thay vì 50 dòng
*   **Triệu chứng:** Máy đo trả về 50 mẫu nhưng C546 chỉ load 20 dòng.
*   **Nguyên nhân gốc:** `SampleQty` trong `STB_MaterialQcDetail` bị lệch so với dữ liệu máy đo.
*   **Cách khắc phục:** Xóa kết quả QC lỗi, reset cờ upload:
    ```sql
    DELETE FROM STB_MaterialQcSampleResult WHERE MaterialQcNo = 'F_MÃ_BARCODE';
    UPDATE Stb_ESRValueMonitor SET UploadToMes = 0, UploadOCVToMess = 0 WHERE lotno = 'MÃ_BARCODE';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.6](KB_05_QC_ELECTRODE.md) và [KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md](KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md).

---

## C560 — Material Lot QC (Kiểm tra chất lượng Lot vật tư)

### Lỗi 1: Lot vật tư không hiển thị để kiểm tra QC
*   **Triệu chứng:** Mở C560 nhưng danh sách Lot vật tư cần QC bị trống.
*   **Nguyên nhân gốc:** Lot vật tư chưa được nhập kho hoặc chưa chuyển trạng thái sang chờ QC.
*   **Cách khắc phục:** Kiểm tra F330 đã nhập kho, kiểm tra bảng `STB_MaterialLotInfo` xem `WarehouseCode` và `QcStatus`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md).

---

## C562 — Bending/Cutting Lot Creation (Tạo Lot kiểm định uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên đã có chi tiết quy trình QC Bending/Cutting.

### Lỗi 1: Không tạo được Lot kiểm định tại C562
*   **Triệu chứng:** Quét barcode sản phẩm tại C562 nhưng không sinh được Lot kiểm định.
*   **Nguyên nhân gốc:** Model chưa được cấu hình nhóm kiểm tra tại C561.
*   **Cách khắc phục:** Vào C561 trước, gán nhóm kiểm tra cho MaterialCode, sau đó quay lại C562.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](KB_05_QC_ELECTRODE.md).

---

## C563 — Bending/Cutting Measurement (Nhập dữ liệu đo uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên.

### Lỗi 1: Lưới đo trống hoặc thiếu hạng mục đo
*   **Triệu chứng:** Quét barcode mẫu tại C563, grid trống không có hạng mục.
*   **Nguyên nhân gốc:** Chưa cấu hình C561 hoặc chưa tạo Lot kiểm định C562.
*   **Cách khắc phục:** Cấu hình C561 → Tạo Lot C562 → Quay lại C563. Nếu vẫn trống, nhấn "Tổng hợp hạng mục".
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](KB_05_QC_ELECTRODE.md).

---

## C564 — Bending/Cutting Report (Báo cáo kết quả uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên.

### Lỗi 1: Báo cáo kết quả C564 không hiện dữ liệu sau khi đo
*   **Triệu chứng:** Đã nhập kết quả đo tại C563 nhưng C564 báo cáo trống.
*   **Nguyên nhân gốc:** Kết quả đo chưa được submit/confirm tại C563 (chưa nhấn Save).
*   **Cách khắc phục:** Quay lại C563, đảm bảo nhấn Save/Confirm để kết quả được ghi nhận vào DB.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 9.4](KB_05_QC_ELECTRODE.md).

---

## D000 — VinaEnesol Management Menu (Menu quản lý VinaEnesol)

### Lỗi 1: Không truy cập được menu VinaEnesol D000
*   **Triệu chứng:** Người dùng không thấy menu VinaEnesol trên giao diện MES.
*   **Nguyên nhân gốc:** Menu D000 chưa được phân quyền cho Role của người dùng tại Z220/Z330.
*   **Cách khắc phục:** Vào Z220 gán Screen D000 cho Role tương ứng, vào Z330 kiểm tra đã publish.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 2](KB_25_VINAENESSOL_HUNG_YEN.md) và [KB_28_SYSTEM_OBJECTS_MAP.md](KB_28_SYSTEM_OBJECTS_MAP.md).

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

## F140 — Vendor-Material Mapping (Ánh xạ NCC - Vật tư)

> 🔗 **Xem thêm:** Mục [F130 / F140 / A210](#f130--f140--a210--supplier-mapping--material-sync) phía trên đã có chi tiết.

### Lỗi 1: Popup chọn NCC trống khi tạo phiếu nhập kho F312/F330
*   **Triệu chứng:** Thủ kho không tìm thấy NCC trong popup.
*   **Nguyên nhân gốc:** Chưa mapping NCC với vật tư trong `STB_MaterialVendorMapping`.
*   **Cách khắc phục:** Vào F140, chọn vật tư, tick chọn NCC được phép mua, nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_07_GROUPWARE_INTEGRATION.md § 6](KB_07_GROUPWARE_INTEGRATION.md).

---

## F312 — Material Doc Edit (Sửa số lượng tài liệu nhập kho NVL)

### Lỗi 1: Cần sửa số lượng NVL đã nhập kho (MaterialDocNo)
*   **Triệu chứng:** Thủ kho nhập sai số lượng vào phiếu nhập kho, cần sửa lại.
*   **Nguyên nhân gốc:** Cột "Số tài liệu" = `MaterialDocNo` trong `STB_MaterialDocDetail`.
*   **Cách khắc phục:** Vào F312, tìm phiếu nhập kho theo MaterialDocNo, sửa số lượng. Kho chị Xuân phụ trách.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md § 4.5](KB_02_KHO_WMS.md) và [KB_07_GROUPWARE_INTEGRATION.md](KB_07_GROUPWARE_INTEGRATION.md).

---

## F320 — Material Transfer (Chuyển kho NVL)

### Lỗi 1: Chuyển kho NVL bị lỗi hoặc không cập nhật tồn kho
*   **Triệu chứng:** Thực hiện chuyển NVL giữa các kho tại F320 nhưng số lượng tồn kho không giảm/tăng tương ứng.
*   **Nguyên nhân gốc:** Trigger `tgMaterialLotInfoForUpdate` trên `STB_MaterialLotInfo` tự động đồng bộ tồn kho. Nếu Trigger bị disable hoặc lỗi thì tồn kho không cập nhật.
*   **Cách khắc phục:** Kiểm tra trạng thái Trigger, kiểm tra bảng `STB_MaterialStock` xem số lượng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md).

---

## F610 — Delivery Order (Đơn giao hàng)

### Lỗi 1: Không tạo được đơn giao hàng tại F610
*   **Triệu chứng:** Tạo đơn giao hàng tại F610 bị lỗi hoặc không hiện sản phẩm.
*   **Nguyên nhân gốc:** Sản phẩm chưa qua QC Audit (C530) hoặc chưa nhập kho thành phẩm.
*   **Cách khắc phục:** Kiểm tra sản phẩm đã PASS QC Audit và đã nhập kho FG.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md).

---

## F620 — Delivery History (Lịch sử giao hàng)

### Lỗi 1: Lịch sử giao hàng F620 hiển thị thiếu phiếu giao
*   **Triệu chứng:** Phiếu giao đã tạo tại F610 nhưng không hiện tại F620.
*   **Nguyên nhân gốc:** Phiếu chưa được confirm/approve hoặc bộ lọc ngày bị sai.
*   **Cách khắc phục:** Kiểm tra lại bộ lọc ngày tìm kiếm, mở rộng khoảng thời gian.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md).

---

## F710 — Warehouse Inventory (Tồn kho tổng hợp)

### Lỗi 1: Tồn kho F710 không khớp với thực tế
*   **Triệu chứng:** Số lượng tồn kho hiển thị tại F710 bị lệch so với kiểm kê thực tế.
*   **Nguyên nhân gốc:** Trigger `tgMaterialLotInfoForUpdate` bị lỗi hoặc tồn tại phiếu nhập/xuất chưa confirm.
*   **Cách khắc phục:** Chạy kiểm kê bằng F750 để điều chỉnh, hoặc kiểm tra trực tiếp `STB_MaterialStock`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md).

---

## F740 — Lot Splitting & Merge (Tách/Gộp Lot NVL)

### Lỗi 1: Tách Lot NVL bị lỗi không tạo được Lot con
*   **Triệu chứng:** Thực hiện tách Lot tại F740 nhưng hệ thống không sinh Lot con.
*   **Nguyên nhân gốc:** Số lượng tách vượt quá `CurrentQty` còn lại của Lot gốc.
*   **Cách khắc phục:** Kiểm tra `CurrentQty` trong `STB_MaterialLotInfo` của Lot gốc, đảm bảo số lượng tách hợp lệ.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md) và [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md).

---

## F744 — Electrode Slitting Result (Kết quả chia cuộn điện cực)

### Lỗi 1: Kết quả Slitting điện cực bị thiếu hoặc sai chiều rộng
*   **Triệu chứng:** Kết quả chia cuộn tại F744 hiển thị sai chiều rộng hoặc thiếu cuộn.
*   **Nguyên nhân gốc:** Cấu hình Slitting tại B552 (bảng `stb_slittinglocationconfig_vvt`) bị sai Width.
*   **Cách khắc phục:** Kiểm tra cấu hình B552 và sửa lại Width cho PartNo tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---

## F746 — Slitting Curling (Bo miệng điện cực)

> 🔗 **Xem thêm:** Mục [F742 / F746](#f742--f746--slitting--curling) phía trên.

### Lỗi 1: Hủy/Rollback Slitting F742 phải xóa F746 trước
*   **Triệu chứng:** Cần rollback kết quả Slitting nhưng hệ thống báo lỗi ràng buộc dữ liệu.
*   **Nguyên nhân gốc:** Bảng F746 (Curling) có FK reference đến F742 (Slitting). Phải xóa F746 trước.
*   **Cách khắc phục:** Xóa kết quả Curling (F746) trước, sau đó mới xóa kết quả Slitting (F742).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 10.1](KB_05_QC_ELECTRODE.md).

---

## F747 — Electrode Coating (Tráng điện cực)

### Lỗi 1: Kết quả tráng điện cực không được ghi nhận
*   **Triệu chứng:** Công đoạn tráng điện cực tại F747 không lưu được kết quả.
*   **Nguyên nhân gốc:** Lot điện cực chưa hoàn thành công đoạn trước (Mixing) hoặc cấu hình Route điện cực sai.
*   **Cách khắc phục:** Kiểm tra Lot đã hoàn thành Mixing, kiểm tra Route điện cực tại B220.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md).

---

## F748 — Electrode Process History (Lịch sử công đoạn điện cực)

> 🔗 **Xem thêm:** Mục [F743~F748 / C243](#f743f748--c243--electrode-slitting--qc) phía trên.

### Lỗi 1: Lịch sử công đoạn điện cực hiển thị thiếu
*   **Triệu chứng:** F748 không hiện đầy đủ các công đoạn của cuộn điện cực.
*   **Nguyên nhân gốc:** Một số công đoạn bị bỏ qua khi scan hoặc bảng `STB_ElectrodeProdRouteHist` thiếu dữ liệu.
*   **Cách khắc phục:** Kiểm tra bảng `STB_ElectrodeProdRouteHist` xem có đủ công đoạn không, chèn bổ sung nếu thiếu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 8](KB_05_QC_ELECTRODE.md).

---

## H302 — Machine Repair History (Lịch sử sửa chữa máy)

> 🔗 **Xem thêm:** Mục [H301~H305](#h301h305--spare-parts-management) phía trên đã có tổng quan Spare Parts.

### Lỗi 1: Không ghi nhận được lịch sử sửa chữa máy
*   **Triệu chứng:** OP nhập thông tin sửa chữa tại H302 nhưng không lưu được.
*   **Nguyên nhân gốc:** Thiếu thông tin bắt buộc (MachineCode, TroublePoint, RepairText) hoặc máy chưa đăng ký tại B250.
*   **Cách khắc phục:** Đảm bảo máy đã đăng ký B250 và nhập đủ các trường bắt buộc.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_20_MAY_MOC_BAO_TRI.md § 3](KB_20_MAY_MOC_BAO_TRI.md).

---

## H303 — Machine Calibration (Hiệu chuẩn thiết bị đo)

### Lỗi 1: Thiết bị đo hết hạn hiệu chuẩn nhưng hệ thống không cảnh báo
*   **Triệu chứng:** Thiết bị đo vượt quá hạn hiệu chuẩn mà H303 không cảnh báo.
*   **Nguyên nhân gốc:** Lịch hiệu chuẩn chưa được thiết lập hoặc ngày hiệu chuẩn tiếp theo bị NULL.
*   **Cách khắc phục:** Vào H303, cập nhật lịch hiệu chuẩn (NextCalibrationDate) cho thiết bị.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_20_MAY_MOC_BAO_TRI.md § 4](KB_20_MAY_MOC_BAO_TRI.md).

---

## H304 — Spare Part Inventory (Tồn kho phụ tùng)

### Lỗi 1: Tồn kho phụ tùng bị lệch so với thực tế
*   **Triệu chứng:** H304 hiển thị số lượng phụ tùng tồn kho khác với kiểm kê thực tế.
*   **Nguyên nhân gốc:** Phiếu xuất/nhập phụ tùng chưa được xác nhận hoặc dữ liệu bị trùng.
*   **Cách khắc phục:** Kiểm tra lịch sử xuất/nhập phụ tùng tại H305, đối chiếu và điều chỉnh.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_20_MAY_MOC_BAO_TRI.md § 5](KB_20_MAY_MOC_BAO_TRI.md).

---

## H305 — Spare Part In/Out History (Lịch sử xuất nhập phụ tùng)

> 🔗 **Xem thêm:** Mục [H301~H305](#h301h305--spare-parts-management) phía trên đã có tổng quan Spare Parts.

### Lỗi 1: Lịch sử xuất nhập phụ tùng không đồng bộ
*   **Triệu chứng:** Phiếu xuất/nhập ghi nhận tại H305 nhưng tồn kho H304 không cập nhật.
*   **Nguyên nhân gốc:** Phiếu chưa được confirm hoặc SP đồng bộ tồn kho bị lỗi.
*   **Cách khắc phục:** Kiểm tra trạng thái confirm của phiếu, chạy đồng bộ lại nếu cần.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_20_MAY_MOC_BAO_TRI.md § 5](KB_20_MAY_MOC_BAO_TRI.md) và [KB_03_SAN_XUAT.md § 6.15](KB_03_SAN_XUAT.md).

---

## K109 — BG2 Material Scanning (Quét NVL nhà máy BG2)

> 🔗 **Xem thêm:** Mục [K101 / K109 / K110](#k101--k109--k110--bg2-production-plan--scan) phía trên đã có chi tiết BG2.

### Lỗi 1: Quét NVL tại BG2 bị chặn sai chủng loại
*   **Triệu chứng:** OP BG2 quét NVL bị lỗi tương tự B597 nhưng trên giao diện K109.
*   **Nguyên nhân gốc:** Logic K109 tương đương B597, lọc riêng cho `WorkCenterCode = 'VVT_BG2'`. Cùng nguyên nhân HOLD/Hết hạn/Sai BOM.
*   **Cách khắc phục:** Áp dụng cùng quy trình debug B597 (xem mục B597 phía trên).
*   **Chi tiết nghiệp vụ:** Xem tại [KB_03_SAN_XUAT.md § 6.9](KB_03_SAN_XUAT.md).

### Lỗi 2: Quét mã vạch nhà cung cấp (Vendor Lot) báo lỗi "Vật liệu [KđV] chưa thiết lập trong BOM, khác với mã QRCODE nhập vào"
*   **Triệu chứng:** Khi quét mã barcode nguyên vật liệu nhà cung cấp (LotNo của Vendor, ví dụ: `K164181062623000609`), hệ thống báo lỗi không tìm thấy vật liệu trong BOM, đồng thời hiển thị tên vật liệu là `[KđV]` (Không định vị/Chưa xác định).
*   **Nguyên nhân gốc:** 
    1. Trong stored procedure `usp_RawMaterialInputHist_CheckLabelBOM`, logic so khớp `@MaterialCurrent` từ `STB_MaterialLotInfo` chỉ sử dụng điều kiện `LotID = @pRawMaterialBarcode`. Do mã vạch quét là Vendor Lot (`LotNo`), lookup trả về `NULL`, dẫn đến tên vật liệu bị gán mặc định là `[KđV]`.
    2. Nhóm mã vật tư `164181` bị comment (`--,'164181'`) trong SP, không được áp dụng thiết lập hoặc kiểm tra đúng BOM.
*   **Cách khắc phục:** 
    Sửa lại logic stored procedure `usp_RawMaterialInputHist_CheckLabelBOM` để fallback tìm theo `LotNo` nếu `LotID` không tìm thấy:
    ```sql
    -- Tìm kiếm theo LotID trước
    SELECT @MaterialCurrent = MaterialCode 
    FROM STB_MaterialLotInfo WITH(NOLOCK) 
    WHERE LotID = @pRawMaterialBarcode;

    -- Nếu không thấy, tìm kiếm fallback theo LotNo (Vendor Lot)
    IF @MaterialCurrent IS NULL
    BEGIN
        SELECT @MaterialCurrent = MaterialCode 
        FROM STB_MaterialLotInfo WITH(NOLOCK) 
        WHERE LotNo = @pRawMaterialBarcode;
    END
    ```
    Đồng thời, bỏ comment cho nhóm mã vật tư `164181` trong SP nếu cần kiểm tra BOM cho nhóm này.
*   **Chi tiết nghiệp vụ:** Xem log debug ngày 2026-06-15.

---

## K110 — BG2 Warehouse Operations (Vận hành kho BG2)

### Lỗi 1: Kho BG2 không hiển thị NVL đã nhập
*   **Triệu chứng:** Thủ kho BG2 không tìm thấy NVL đã nhập kho tại K110.
*   **Nguyên nhân gốc:** WarehouseCode của kho BG2 khác với kho chính. Dữ liệu lọc theo `WorkCenterCode = 'VVT_BG2'`.
*   **Cách khắc phục:** Kiểm tra WarehouseCode của phiếu nhập kho F330 khớp với kho BG2.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_02_KHO_WMS.md](KB_02_KHO_WMS.md).

---

## P111 — Attendance Time (Chấm công nhân viên)

### Lỗi 1: Dữ liệu chấm công không đồng bộ với thực tế
*   **Triệu chứng:** Bảng chấm công P111 hiển thị thiếu hoặc sai giờ vào/ra.
*   **Nguyên nhân gốc:** Thiết bị chấm công (máy quẹt thẻ) bị mất kết nối hoặc dữ liệu chưa được đồng bộ vào DB.
*   **Cách khắc phục:** Kiểm tra kết nối thiết bị chấm công, chạy đồng bộ lại dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_28_SYSTEM_OBJECTS_MAP.md](KB_28_SYSTEM_OBJECTS_MAP.md).

---

## Z110 — Screen Configuration (Cấu hình màn hình hệ thống)

### Lỗi 1: Màn hình mới tạo không hiển thị trên menu MES
*   **Triệu chứng:** Đã đăng ký màn hình mới trong `STB_ScreenInfo` nhưng không thấy trên menu.
*   **Nguyên nhân gốc:** Cờ `IsPublish` chưa được bật hoặc chưa gán ParentName (thư mục menu cha).
*   **Cách khắc phục:** Vào Z110, tìm Screen mới, bật `IsPublish = 1`, đảm bảo ParentName đúng thư mục.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_28_SYSTEM_OBJECTS_MAP.md § 5](KB_28_SYSTEM_OBJECTS_MAP.md).

---

## Z210 — System Parameter (Tham số hệ thống)

### Lỗi 1: Thay đổi tham số hệ thống không có hiệu lực
*   **Triệu chứng:** Sau khi sửa tham số tại Z210, hệ thống vẫn chạy với cấu hình cũ.
*   **Nguyên nhân gốc:** Một số tham số hệ thống được cache và cần restart ứng dụng client để áp dụng.
*   **Cách khắc phục:** Yêu cầu người dùng đóng hoàn toàn ứng dụng MES và mở lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md).

---

## Z220 — Role Screen Mapping (Phân quyền màn hình theo vai trò)

> 🔗 **Xem thêm:** Mục [Z410 / Z220 / Z330](#z410--z220--z330--user-accounts--role-permissions) phía trên đã có chi tiết phân quyền.

### Lỗi 1: Người dùng không thấy màn hình trên menu MES
*   **Triệu chứng:** User đăng nhập nhưng thiếu nhiều màn hình so với đồng nghiệp.
*   **Nguyên nhân gốc:** Role của User chưa được gán quyền truy cập Screen ID tương ứng tại Z220.
*   **Cách khắc phục:** Vào Z220, chọn Role Group, tick chọn Screen ID cần mở quyền.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.4](KB_01_UI_PHAN_QUYEN.md).

---

## Z330 — Screen Publish (Kích hoạt/ẩn màn hình)

> 🔗 **Xem thêm:** Mục [Z410 / Z220 / Z330](#z410--z220--z330--user-accounts--role-permissions) phía trên đã có chi tiết phân quyền.

### Lỗi 1: Màn hình đã gán quyền Z220 nhưng vẫn không hiện trên menu
*   **Triệu chứng:** Đã gán quyền tại Z220 nhưng user vẫn không thấy màn hình.
*   **Nguyên nhân gốc:** Màn hình chưa được publish/kích hoạt tại Z330 (`IsPublish = 0`).
*   **Cách khắc phục:** Vào Z330, tìm Screen ID, bật `IsPublish = 1`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.4](KB_01_UI_PHAN_QUYEN.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---

## Các Màn Hình Cô Lập Xưởng Hưng Yên (TCode kết thúc bằng `_HY`)

> 🔗 **Xem thêm:** Chi tiết UAT và danh sách đối soát các màn hình cô lập Hưng Yên tại [hy_screens_audit.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/fdbffebe-1907-405f-80d2-5bc839ff4434/hy_screens_audit.md). Các màn hình gồm: `C121_HY`, `C122_HY`, `C220_HY`, `B310_HY`, `B442_HY`, `B470_HY`, `B552_HY`, `B802_HY`, `C460_HY`.

### Lỗi 1: Lỗi nhân bản Stored Procedure bị hậu tố kép `_HY_HY` trong layout XML
*   **Triệu chứng:** Màn hình Hưng Yên load lên báo lỗi Runtime do không tìm thấy Stored Procedure tương ứng (Ví dụ: `usp_ProductionOrderInfo_HY_HY_get`).
*   **Nguyên nhân gốc:** Quá trình chạy script nhân bản layout XML (`clone_screen_layouts.sql`) thực hiện replace chuỗi `_get` và `_iud` thành Stored Procedure Hưng Yên bị lặp lại hoặc chạy chéo, dẫn đến Stored Procedure bị đổi tên sai thành `_HY_HY`.
*   **Cách khắc phục:** Chạy script SQL cập nhật cột `XmlLayout` trong bảng `SmartFramework.dbo.STB_ScreenLayoutInfo` để sửa các chuỗi `_HY_HY` trở về `_HY`.

### Lỗi 2: Màn hình C121_HY (QcInspectionGroup_HY) bị mở thành nhiều Tab (mở nhiều cửa sổ)
*   **Triệu chứng:** Khi người dùng mở màn hình `C121_HY` trên client MES, mỗi lần click menu hệ thống lại mở thêm một tab mới thay vì chỉ mở và focus vào tab duy nhất đã mở (như màn hình gốc C121).
*   **Nguyên nhân gốc:** Cột `IsDialog` của màn hình `QcInspectionGroup_HY` trong bảng `SmartFramework.dbo.STB_ScreenInfo` bị để giá trị **NULL** hoặc `True` thay vì `0` (False).
*   **Cách khắc phục:** Chạy SQL cập nhật thuộc tính `IsDialog = 0` cho màn hình `QcInspectionGroup_HY`:
    ```sql
    UPDATE SmartFramework.dbo.STB_ScreenInfo 
    SET IsDialog = 0
    WHERE Name = 'QcInspectionGroup_HY';
    ```

### Lỗi 3: Màn hình C121_HY vẫn gọi Stored Procedure gốc không có hậu tố Hưng Yên
*   **Triệu chứng:** Khi thực hiện thao tác Thêm/Sửa/Xóa hạng mục kiểm tra QC tại `C121_HY`, hệ thống vẫn gọi SP gốc `usp_QcInspectionItem_iud` thay vì bản cô lập Hưng Yên, làm thay đổi chéo dữ liệu của các xưởng khác.
*   **Nguyên nhân gốc:** Quá trình clone Stored Procedure bị bỏ sót, chưa tạo SP `usp_QcInspectionItem_HY_iud` trên DB chính và chưa đăng ký/ánh xạ vào `STB_ScreenObjects` cho màn hình `C121_HY`.
*   **Cách khắc phục:** 
    1. Nhân bản SP `usp_QcInspectionItem_iud` thành `usp_QcInspectionItem_HY_iud` trên DB `SmartFactoryV2`.
    2. Đăng ký hàm thực thi `usp_QcInspectionItem_HY_iud` (ExecuteFunction) vào bảng `STB_ScreenObjects` cho ScreenName `QcInspectionGroup_HY`.
    3. Cập nhật `XmlLayout` của màn hình `QcInspectionGroup_HY` để thay thế `usp_QcInspectionItem_iud` bằng `usp_QcInspectionItem_HY_iud`.

### Lỗi 4: Object Panel (F5) hoặc giao diện hiển thị Stored Procedure cũ không có hậu tố `_HY`
*   **Triệu chứng:** DB đã cập nhật Stored Procedure `_HY` đầy đủ nhưng trên phần mềm MES (Object Panel hoặc lúc chạy thực tế) vẫn hiển thị và gọi SP cũ.
*   **Nguyên nhân gốc:** Client MES NAIS đang lưu cache layout cũ trên máy tính local của người dùng, chưa cập nhật cấu hình mới từ DB.
*   **Cách khắc phục:** Tắt hoàn toàn phần mềm MES NAIS (đóng chương trình) rồi mở lại để client xóa cache và tải lại layout mới từ database.

---
*Cập nhật: 2026-06-13 — Hoàn thiện cẩm nang tra cứu lỗi cho **125+ màn hình** theo Screen ID riêng biệt và bổ sung phần gỡ lỗi các màn hình cô lập Hưng Yên (_HY). Mỗi màn hình có header ## ScreenID riêng, hỗ trợ tìm kiếm Ctrl+Shift+F trực tiếp.*

