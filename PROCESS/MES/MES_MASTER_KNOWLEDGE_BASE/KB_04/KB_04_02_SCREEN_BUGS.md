<!--
AI-READY METADATA
Purpose: Sổ tay các kịch bản lỗi & hướng dẫn khắc phục phân hệ Đóng Gói (B351, B523, B525, B717, B781, B789, B353, C531)
Scope: Packaging Screen Bug Fixbook & Emergency Response
Single Source of Truth: KB_04_02_SCREEN_BUGS.md (Packaging Bug Fixes)
Target Screens: B351, B353, B523, B525, B717, B781, B789, C531
Target Tables: STB_PackingStandard, STB_DividePackaging, STB_SavePackingTime_VVT, STB_MaterialLotInfo, STB_SetInfo
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_04 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/INDEX.md)
  - [KB_04_01_CORE_PACKAGING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md)
-->

# KB_04_02 — Packaging Screen Bugs & Fixes

> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_04 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/INDEX.md)

---


## [B351] — Lot Transition (Chuyển đổi Lot)

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#62-sửa-tên-lot-sau-b351-chuyển-đổi-lot--barcode-có-dấu-chấm).

### Lỗi 2: User yêu cầu in lại tem gốc (mã cũ) sau khi Sản xuất đã chuyển đổi Lot tại B351
*   **Triệu chứng:** User thao tác tại **B525** / **B523** quét Lot cũ (Ví dụ: Lot `507` - `VVQJ303R070507`), nhưng hệ thống tự động in ra tem của mã mới (Ví dụ: Lot `511` - `VVQN263R070511`). Hoặc quét Lot cũ thì bảng phía trên hiện đúng nhưng ô **"Lịch sử quá trình sản xuất"** (góc dưới trái) lại trống rỗng. User yêu cầu IT/Admin chạy SQL rollback để in lại tem gốc.
*   **Nguyên nhân gốc:** Sản xuất đã thực hiện chuyển đổi vật tư/mã hàng tại **B351** (ghi nhận trong `STB_LotChangeMaterialHistory`). B351 cập nhật `MaterialCode`, `DayPlanNo`, `Barcode` trong `STB_SetInfo` sang mã mới. **Tuy nhiên**, B351 **KHÔNG** tự động đồng bộ ngược lại các bảng sau, gây lệch dữ liệu khi rollback thủ công:
    * `STB_MaterialLotInfo` — LotNo, MaterialLotNo, MaterialCode
    * `STB_ProdRouteHist` — DayPlanNo, MaterialCode (cột `DayPlanNo` bị lệch khiến `usp_ProdRouteHist_get` trả 0 dòng)

*   **⛔ NGUYÊN TẮC QUẢN LÝ:**
    > [!CAUTION]
    > **CẦN XÁC NHẬN NGUYÊN TẮC NGHIỆP VỤ TRƯỚC KHI THỰC THI:**
    > 1. Lô hàng đã thực hiện chuyển đổi sản xuất thực tế tại B351, bản chất mã sản phẩm và kế hoạch sản xuất đã được thay đổi.
    > 2. Việc tự ý xóa lịch sử `STB_LotChangeMaterialHistory` hoặc rollback `STB_SetInfo` mà không có xác nhận sẽ gây lệch Traceability và tồn kho MES.
    > 3. **Quy trình chuẩn:** Khi có yêu cầu từ User, cần Quản lý Sản xuất & QC xác nhận. Khi được phê duyệt, thực thi script rollback đồng bộ 4 bảng chuẩn hóa.

*   **🔬 Root Cause — Tại sao ô "Lịch sử quá trình sản xuất" trống sau rollback thủ công:**
    SP `usp_ProdRouteHist_get` (được B525 gọi) có điều kiện WHERE:
    ```sql
    WHERE PRH.PONo = @PONo              -- ⚠️ EXACT MATCH (=), PONo phải khớp chính xác
      AND PRH.DayPlanNo LIKE @DayPlanNo -- DayPlanNo phải khớp giữa STB_SetInfo và STB_ProdRouteHist
      AND PRH.ControlNo LIKE @ControlNo
    ```
    Nếu chỉ sửa `STB_SetInfo.DayPlanNo` mà **quên** sửa `STB_ProdRouteHist.DayPlanNo`, SP sẽ trả về 0 dòng → ô lịch sử trống.

*   **🛠️ Quy trình kỹ thuật Rollback đồng bộ 4 bảng (Mẫu tổng quát):**

    > [!IMPORTANT]
    > **Thay thế các giá trị mẫu** (`@ControlNo`, `@BarcodeGoc`, `@MaterialCodeGoc`, `@DayPlanNoGoc`, `@BarcodeB351`, `@CPHNo`) bằng giá trị thực tế của lô cần rollback. Tra cứu giá trị gốc từ `STB_LotChangeMaterialHistory` (cột `BefMaterialCode`, `BefDayPlanNo`, `BefBarcode`).

    ```sql
    -- ======================================================
    -- TEMPLATE: Rollback B351 Lot Conversion — Đồng bộ 4 bảng
    -- Tra cứu trước: SELECT * FROM STB_LotChangeMaterialHistory WHERE CPHNo = @CPHNo
    -- ======================================================
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Bước 1: Sao lưu dữ liệu hiện tại (an toàn, chỉ tạo 1 lần)
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BAK_STB_SetInfo_@CPHNo')
            SELECT * INTO BAK_STB_SetInfo_@CPHNo FROM STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '@ControlNo';
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BAK_STB_MaterialLotInfo_@CPHNo')
            SELECT * INTO BAK_STB_MaterialLotInfo_@CPHNo FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo IN ('@BarcodeB351', '@BarcodeGoc');

        -- Bước 2: Cập nhật STB_SetInfo (Barcode, MaterialCode, DayPlanNo)
        UPDATE STB_SetInfo
        SET Barcode = '@BarcodeGoc', MaterialCode = '@MaterialCodeGoc', DayPlanNo = '@DayPlanNoGoc'
        WHERE ControlNo = '@ControlNo';

        -- Bước 3: Cập nhật STB_MaterialLotInfo (MaterialCode, MaterialLotNo, LotNo)
        UPDATE STB_MaterialLotInfo
        SET MaterialCode = '@MaterialCodeGoc', MaterialLotNo = '@BarcodeGoc', LotNo = '@BarcodeGoc'
        WHERE LotNo IN ('@BarcodeB351', '@BarcodeGoc') OR MaterialLotNo IN ('@BarcodeB351', '@BarcodeGoc');

        -- Bước 4: ⚠️ QUAN TRỌNG — Cập nhật STB_ProdRouteHist (DayPlanNo, MaterialCode)
        -- Nếu BỎ QUA bước này, ô "Lịch sử quá trình sản xuất" trên B525 sẽ TRỐNG!
        UPDATE STB_ProdRouteHist
        SET DayPlanNo = '@DayPlanNoGoc', MaterialCode = '@MaterialCodeGoc'
        WHERE ControlNo = '@ControlNo';

        -- Bước 5: Xóa nhật ký chuyển đổi B351
        DELETE FROM STB_LotChangeMaterialHistory WHERE CPHNo = @CPHNo;

        COMMIT TRANSACTION;
        PRINT 'SUCCESS: Rollback B351 thanh cong!';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'ERROR: ' + ERROR_MESSAGE();
        THROW;
    END CATCH;
    ```

*   **🔍 Verification Queries (Chạy sau khi thực thi để xác nhận):**
    ```sql
    -- Check 1: STB_SetInfo — Barcode, MaterialCode, DayPlanNo đã về mã gốc
    SELECT ControlNo, Barcode, MaterialCode, DayPlanNo FROM STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '@ControlNo';

    -- Check 2: STB_LotChangeMaterialHistory — Phải trả về 0 dòng
    SELECT * FROM STB_LotChangeMaterialHistory WITH(NOLOCK) WHERE CPHNo = @CPHNo;

    -- Check 3: STB_ProdRouteHist — DayPlanNo khớp với STB_SetInfo
    SELECT ControlNo, RouteCode, DayPlanNo, MaterialCode, ProdQty FROM STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = '@ControlNo';

    -- Check 4: Gọi thử SP hiển thị lịch sử — Phải trả về ≥ 1 dòng
    EXEC usp_ProdRouteHist_get @pProcessLanguage='vn', @pProcessUserID='vinaadmin', @pControlNo='@ControlNo';

    -- Check 5: Bảng Backup còn nguyên (đối soát sau này)
    SELECT * FROM BAK_STB_SetInfo_@CPHNo;
    ```

### Lỗi 3: Bấm nút "Thay đổi model" xuất hiện thông báo `No data to process`
*   **Triệu chứng:** Người dùng chọn Lot ở lưới dưới (`SetInfoForChangeMaterial`) và bấm nút **[Thay đổi model]** trên thanh công cụ góc phải lưới 2, màn hình bật hộp thoại thông báo đỏ **`No data to process`** và không thực hiện chuyển đổi.
*   **Nguyên nhân gốc:** 
    1. Màn hình **B351** vận hành theo cơ chế Master-Detail (2 lưới):
       - Lưới 1 (`DayProdPlanForChangeMaterial` - Kế hoạch mục tiêu): Chứa Kế hoạch sản xuất / Model MỚI.
       - Lưới 2 (`SetInfoForChangeMaterial` - Danh sách Lot): Chứa danh sách các Barcode Lot hiện tại.
    2. Các cột **`TargetDayPlanNo`**, **`TargetMaterialCode`**, **`TargetMaterialName`** ở Lưới 2 đang **bỏ trống (rỗng/NULL)** do người dùng chưa gán Kế hoạch mục tiêu từ Lưới 1 xuống Lưới 2.
    3. Khi bấm nút execute **"Thay đổi model"** (thực thi SP `usp_DoChangeMaterialForSetInfo`), NAIS Client kiểm tra mảng danh sách truyền vào nhưng không tìm thấy bản ghi nào có dữ liệu Target → ném thông báo `No data to process`.
    4. Ngoài ra, nếu Kế hoạch ở Lưới 1 hiển thị trùng đúng Mã nguyên liệu hiện tại của Lot ở Lưới 2 (ví dụ cùng mã `ECVT30-260`), người dùng cần tìm đúng Kế hoạch của Model MỚI ở Lưới 1 trước khi gán.

*   **🛠️ Quy trình thao tác chuẩn trên giao diện B351:**
    ```
    [Bước 1: Tìm Kế hoạch mục tiêu] 
      -> Lưới 1 (DayProdPlanForChangeMaterial): Tìm & chọn dòng Kế hoạch của Model MỚI
      
    [Bước 2: Gán Target xuống Lưới 2] 
      -> Lưới 2 (SetInfoForChangeMaterial): Chọn dòng Lot -> Gán Kế hoạch từ Lưới 1 xuống
      -> Kiểm tra cột TargetDayPlanNo, TargetMaterialCode, TargetMaterialName ĐÃ HIỂN THỊ MÃ MỚI
      
    [Bước 3: Thực hiện Chuyển đổi] 
      -> Bấm nút [Thay đổi model] -> Chạy SP usp_DoChangeMaterialForSetInfo -> Lưu log STB_LotChangeMaterialHistory
    ```

*   **🔍 SQL Debug & Đối Soát Dữ Liệu B351:**
    ```sql
    -- 1. Kiểm tra kế hoạch sản xuất ngày có sẵn để đổi sang (dùng cho Lưới 1)
    EXEC usp_GetDayProdPlanForChangeMaterial 
        @pCompanyCode = 'VT', 
        @pWorkCenterCode = 'VT_F1', 
        @pFromDate = '2026-07-01', 
        @pToDate = '2026-08-07';

    -- 2. Kiểm tra danh sách Lot đủ điều kiện đổi (dùng cho Lưới 2)
    EXEC usp_GetSetInfoForChangeMaterial 
        @pCompanyCode = 'VT', 
        @pWorkCenterCode = 'VT_F1', 
        @pBarcode = 'WQP313R0606QL';

    -- 3. Kiểm tra nhật ký chuyển đổi Lot đã thực hiện thành công
    SELECT CPHNo, OldBarcode, NewBarcode, BefMaterialCode, AftMaterialCode, ChangeDateTime, ChangeUserID
    FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
    WHERE OldBarcode = 'WQP313R0606QL' OR NewBarcode = 'WQP313R0606QL';
    ```

---


## [B523] / [B525] — Packaging & Box Matching (Đóng gói Cell & Module)

### Lỗi 1: Báo lỗi "Chưa có tiêu chuẩn đóng gói" khi gộp Box
*   **Triệu chứng:** Công nhân quét gộp Box tại màn hình **B523** hệ thống báo lỗi đỏ chặn đứng quy trình: `"Chưa có tiêu chuẩn đóng gói"`.
*   **Nguyên nhân gốc:** Model/Size mới chưa được khai báo số lượng đóng gói định mức trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:**
    Khai báo tiêu chuẩn đóng gói (dựa trên loại vật tư `FERT` và size model, không gán theo `MaterialCode`):
    ```sql
    INSERT INTO STB_PackingStandard (MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty, CreateDateTime, CreateUserID)
    VALUES ('FERT', 'KÍCH_THƯỚC_SIZE_4_CHỮ_SỐ', NULL, NULL, 500, 4000, 8000, GETDATE(), 'vinaadmin');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#61-lỗi-chưa-có-tiêu-chuẩn-đóng-gói-b523).

### [F110] — Lỗi 2: Không gộp được Box Cell/Module do chưa có Lot, thiếu QC hoặc cờ
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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#64-lỗi-không-gộp-box-được-b523--quy-trình-debug-chuẩn).

### Lỗi 3: Lỗi Packing Qty hiển thị số âm hoặc sai lệch số lượng thực tế
*   **Triệu chứng:** Màn hình hiển thị số lượng đóng gói bị âm hoặc sai lệch nghiêm trọng.
*   **Nguyên nhân gốc:** Sai lệch lượng trừ kho ảo `CurrentQty` trong bảng `STB_MaterialLotInfo` hoặc sai bản ghi `STB_SavePackingTime_VVT`.
*   **Cách khắc phục:**
    Chạy script reset số lượng thực tế của Lot về giá trị đúng:
    ```sql
    UPDATE STB_MaterialLotInfo SET CurrentQty = [SỐ_LƯỢNG_ĐÚNG] WHERE LotNo = 'MÃ_LOT';
    UPDATE STB_SavePackingTime_VVT SET PackQty = [SỐ_LƯỢNG_ĐÚNG] WHERE LotNo = 'MÃ_LOT' AND id = [ID_GIAO_DỊCH];
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.6](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md#66-lỗi-packing-qty-âm-ở-b523--b789).

### Lỗi 4: Lỗi "Chưa có tiêu chuẩn đóng gói" cho Model/Size 1840 khi quét gộp Box
*   **Triệu chứng:** Khi quét gộp Box cho các Model size `1840` tại B523, hệ thống báo lỗi đỏ chặn không cho thao tác.
*   **Nguyên nhân gốc:** Thiếu cấu hình định mức đóng gói cho kích thước size `1840` trong bảng `STB_PackingStandard`.
*   **Cách khắc phục:** Xem kịch bản chèn `STB_PackingStandard` tại [Lỗi 1](#lỗi-1-báo-lỗi-chưa-có-tiêu-chuẩn-đóng-gói-khi-gộp-box) ở trên.


---


## [B717] — Bending & Tapping (Uốn chân & Dán băng keo Cell)

### [B717] — Lỗi 1: Nhập sai thông số uốn/dán tại không thể sửa hoặc xóa trực tiếp trên giao diện
*   **Triệu chứng:** OP nhập nhầm số lượng, sai kích thước hoặc thông số uốn dán tại **B717**, không thấy nút Edit hay Delete trên UI để chỉnh sửa lại.
*   **Nguyên nhân gốc:** Hệ thống chỉ được thiết kế để ghi nhận 1 lần (Insert hoặc Override) và không hỗ trợ tính năng sửa/xóa giao dịch trên client app.
*   **Cách khắc phục:** IT kiểm tra và chạy script SQL update trực tiếp sản lượng hoặc xóa bản ghi giao dịch sai trong bảng tương ứng để OP quét lại.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md#66-b717--bending--tapping](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#66-b717--bending--tapping).

---


## [B525] — Warehouse Packing (Đóng gói kho)

> 🔗 **Xem thêm:** Mục [B523 / B525](#b523--b525--packaging--box-matching) phía trên đã có chi tiết lỗi đóng gói.

### [B523] — Lỗi 1: Không gộp được Box tại kho (khác dành cho sản xuất)
*   **Triệu chứng:** Thủ kho thao tác đóng gói tại B525 bị chặn tương tự B523.
*   **Nguyên nhân gốc:** B525 là phiên bản dành cho kho, cùng logic với B523 nhưng lọc theo WarehouseCode. Thiếu cờ `IsLotUse` hoặc `IsUseBarcode` tại F110.
*   **Cách khắc phục:** Áp dụng cùng quy trình debug 4 bước như B523 (xem mục B523 phía trên).
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md).

---


## [B781] — Packing Print Time Report (Tra sản lượng đóng gói nhập tay)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên đã có chi tiết lỗi đơn giá.

### [B781] — Lỗi 1: Sai ngày in tem đóng gói tại
*   **Triệu chứng:** Báo cáo B781 hiển thị sai ngày in/đóng gói so với thực tế.
*   **Nguyên nhân gốc:** Cột `PrintTime` trong `STB_SavePackingTime_VVT` bị ghi sai khi nhập tay tại B523.
*   **Cách khắc phục:** Chạy SQL sửa trực tiếp: `UPDATE STB_SavePackingTime_VVT SET PrintTime = 'NGÀY_ĐÚNG' WHERE LotNo = 'MÃ_LOT'`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5.3](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md).

---


## [B789] — Packing Qty Edit (Sửa số lượng đóng gói)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên.

### Lỗi 1: Cần xóa hoặc sửa số lượng Packing đã lưu
*   **Triệu chứng:** Số lượng đóng gói bị ghi nhận sai, cần sửa lại.
*   **Nguyên nhân gốc:** OP nhập nhầm số lượng khi gộp Box tại B523. B789 sử dụng SP `usp_Vietnam_GetBoxIDForLotNo_VVT` để tra cứu.
*   **Cách khắc phục:** Sửa trực tiếp trong bảng `STB_SavePackingTime_VVT` theo LotNo và ID giao dịch.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.6](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md).

---


---


### 4.1 [B523] — LỖI KHÔNG GỘP ĐƯỢC BOX & RÃ BOX (MÀN HÌNH B523)

> [!NOTE]
> Chi tiết quy trình đóng gói B523 và sơ đồ flow in tem được quản lý tập trung tại [KB_04_01_CORE_PACKAGING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md).

#### 🔴 Triệu chứng hiện trường:
Công nhân scan Lot/Barcode sản phẩm tại màn hình đóng gói **B523**, nhưng hệ thống báo lỗi đỏ: *"Chưa có tiêu chuẩn đóng gói"* hoặc *"Barcode không đủ điều kiện gộp box"*.

#### 🔍 Quy trình truy vết & xử lý (4 bước chuẩn):
1. **Kiểm tra Master F110 (`IsLotUse`):** Yêu cầu Master Data vào **F110** tick chọn **Use Barcode** + **Lot Use**, hoặc chạy SQL: `UPDATE STB_MaterialStockAttributeInfo SET IsLotUse = 1, IsUseBarcode = 1 WHERE MaterialCode = 'Mã_Vật_Tư';`
2. **Kiểm tra QC Pass (`STB_SetInfo`):** Đảm bảo `LotDecisionResult = 'PASS'`.
3. **Kiểm tra Box đã gộp (`STB_MaterialLotInfo`):** Check cột `PackingID`. Nếu có mã Box cũ, rã box cũ trước khi gộp mới.
4. **Kiểm tra tiêu chuẩn đóng gói (`STB_PackingStandard`):** Màn hình **A419** phải có quy cách đóng gói cho size của Model.

#### 🛠️ Kịch bản Hủy gộp box / Rã box:
Xem script `BEGIN TRAN` rã box tại [KB_04_01_CORE_PACKAGING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md) hoặc [vinatech_sql_fix_templates](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/knowledge/vinatech_sql_fix_templates/artifacts/sql_fix_templates.md).


---

### [B523] — Kịch bản sự cố khẩn cấp 2: Hủy gộp box / Rã box ()

#### 🛠️ KỊCH BẢN A: Hủy gộp box / Rã box để đóng gói lại
*   **Ví dụ Demo:** Hủy gộp box (rã box) mã `PKHN023117` để giải phóng các Lot con bên trong.
*   **Quy trình xử lý bằng Transaction:**
    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Xem danh sách các Lot con đang nằm trong Box bị gộp nhầm
        SELECT MaterialLotNo, LotNo, PackingID, CurrentQty, InitialQty 
        FROM STB_MaterialLotInfo 
        WHERE PackingID = 'PKHN023117';

        -- 2. Hủy liên kết Box: Set PackingID = NULL để giải phóng các Lot con ra ngoài
        UPDATE STB_MaterialLotInfo 
        SET PackingID = NULL 
        WHERE PackingID = 'PKHN023117';

        -- 3. Xóa thông tin Box lịch sử đóng gói trong bảng Divide (hàng Cell)
        DELETE FROM STB_DividePackaging WHERE PackingID = 'PKHN023117';

        -- 4. Xóa thông tin Box lịch sử đóng gói trong bảng SavePackingTime (nếu là hàng Module)
        DELETE FROM STB_SavePackingTime_VVT WHERE PackingID = 'PKHN023117';

        COMMIT TRANSACTION;
        PRINT 'Rã Box và giải phóng Lot thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Lỗi rã Box: ' + ERROR_MESSAGE();
    END CATCH;
    ```


#### 🛠️ KỊCH BẢN B: Lỗi gộp box bị mất số lượng (Qty = 0 hoặc Qty âm)
*   **Triệu chứng:** Sau khi gộp box, do lỗi xung đột SP `usp_savePackingLabelQty_VVT` hoặc scan đúp, số lượng Lot hiện tại bị dồn về `0` hoặc âm.
*   **Ví dụ Demo:** Khôi phục số lượng thực tế là `20` cho Lot `SP260516-003` và xóa các Lot trùng lặp phát sinh.
*   **Quy trình xử lý:**
    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Cập nhật số lượng thực tế cho Lot chuẩn cần giữ lại
        UPDATE STB_MaterialLotInfo
        SET InitialQty = 20, 
            CurrentQty = 20
        WHERE LotNo = 'SP260516-003';

        -- 2. Xóa bỏ các Lot ID con thừa/trùng lặp do hệ thống tự sinh sai khi scan đúp
        -- Dùng danh sách cụ thể thu thập được khi SELECT ở bước trước
        DELETE FROM STB_MaterialLotInfo 
        WHERE MaterialLotNo IN ('LotID_Thừa_1', 'LotID_Thừa_2');

        COMMIT TRANSACTION;
        PRINT 'Khôi phục số lượng gộp box thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
    ```


#### [B523] — 🛠️ KỊCH BẢN C: Hủy gộp box khi Lot/Packing đã được nhập kho thành phẩm (Finish Goods)/Hủy Packing
*   **Triệu chứng:** Khi cần hủy/rã box để đóng gói lại nhưng hệ thống chặn không cho hủy trên giao diện UI (báo lỗi: *"Lot này đã được nhập kho, không thể huỷ gộp box..."*).
    UPDATE STB_ProductionOrderInfo
    SET ProdFinishQty = ProdFinishQty - 800
    WHERE PONo = '260515000004';
    -- THỬ NGHIỆM AN TOÀN: Mặc định Rollback. Hãy đổi thành COMMIT TRANSACTION khi muốn lưu thay đổi.
    ROLLBACK TRANSACTION;
    PRINT 'Kiểm tra thành công! (Dữ liệu đã rollback an toàn)';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
    THROW;
END CATCH;

*   **Quy trình xử lý bằng Transaction:**
    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Xóa bản ghi trong kho thành phẩm để bypass điều kiện chặn
        DELETE FROM STB_VN_FINISHGOODS_HN_New 
        WHERE PackingID IN ('MÃ_PACKING_1', 'MÃ_PACKING_2') AND LotNo = 'MÃ_LOT_GỐC';

        -- 2. Gọi procedure hệ thống hủy tài liệu nhập kho vật tư (giải phóng STB_MaterialLotInfo)
        -- Chạy lần lượt cho từng mã chứng từ MaterialDocNo tương ứng của từng box
        EXEC usp_DoCancelMaterialDoc 
            @pProcessLanguage = 'vn',
            @pProcessUserID = 'TÀI_KHOẢN_USER',
            @pMaterialDocNo = 'MÃ_CHỨNG_TỪ_1';

        EXEC usp_DoCancelMaterialDoc 
            @pProcessLanguage = 'vn',
            @pProcessUserID = 'TÀI_KHOẢN_USER',
            @pMaterialDocNo = 'MÃ_CHỨNG_TỪ_2';

        -- 3. Cập nhật giảm sản lượng chốt công đoạn cuối (ví dụ: VE10) trong STB_ProdRouteHist
        -- Giảm đi tổng số lượng của các box vừa hủy
        UPDATE STB_ProdRouteHist
        SET ProdQty = ProdQty - [TỔNG_SỐ_LƯỢNG_HỦY]
        WHERE ControlNo = 'MÃ_CONTROL_NO' AND RouteCode = 'MÃ_ROUTE_CUỐI';

        -- 4. Cập nhật giảm sản lượng trong bảng tổng hợp công đoạn STB_ProdRouteSummary
        UPDATE STB_ProdRouteSummary
        SET OutputQty = OutputQty - [TỔNG_SỐ_LƯỢNG_HỦY]
        WHERE ProductSummaryID = 'MÃ_PRODUCT_SUMMARY_ID';

        -- 5. Cập nhật giảm sản lượng hoàn thành của PO (STB_ProductionOrderInfo)
        UPDATE STB_ProductionOrderInfo
        SET ProdFinishQty = ProdFinishQty - [TỔNG_SỐ_LƯỢNG_HỦY]
        WHERE PONo = 'MÃ_PO_NO';

        COMMIT TRANSACTION;
        PRINT 'Hủy gộp box thành phẩm thành công!';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
        THROW;
    END CATCH;
    ```

---


### 4.5 [B450]/[B523]/[B756]/[A460] — LỖI KHÔNG IN ĐƯỢC TEM ( / / / )

#### 🔴 Triệu chứng hiện trường:
Người dùng thao tác tạo Lot sản xuất hoặc in tem đóng gói nhưng máy in không phản hồi hoặc giao diện báo lỗi: *"Không tìm thấy định dạng nhãn"* hoặc tem in ra bị thiếu các thông số bắt buộc (Vol, Farad, Datecode...).

#### 🔍 Quy trình truy vết & xử lý (5 bước kiểm tra):

*   **Bước 1: Kiểm tra cấu hình nhãn in trong SmartFramework (Màn hình A460)**
    Lỗi `"Không tìm thấy định dạng nhãn"` xảy ra khi template nhãn chưa được thiết lập hoặc chưa được phê duyệt.
    ```sql
    -- Kiểm tra sự tồn tại và trạng thái active của mẫu tem
    SELECT FormatName, IsApproval, ApplyDate, FormatType
    FROM SmartFramework.dbo.STB_LabelInfo 
    WHERE FormatName LIKE '%HN%' -- Lọc theo tên nhà máy/mẫu
      AND IsApproval = 1;
    ```
    *   *Cách xử lý:* Nếu trống, vào màn hình **A460** chọn cấu hình: **`AssembleLabel`** (Dòng 2) dùng cho sản xuất, **`PartLabel`** dùng cho tem kho nguyên vật liệu, tích chọn **IsApproval = 1** và bấm **Save**.

*   **Bước 2: Kiểm tra cấu hình Vol/Farad của Model (Màn hình A410)**
    Khi in tem đóng gói, nếu Model thiếu cấu hình giá trị Điện áp (Voltage) và Điện dung (Farad), hệ thống sẽ chặn không cho in hoặc in ra tem trống thông số.
    ```sql
    -- Kiểm tra thông số Model cơ bản
    SELECT ModelCode, ModelName, MBIExtText04 AS Voltage, MBIExtText05 AS Farad 
    FROM STB_ModelBasicInfo 
    WHERE ModelCode = 'Mã_Model'; -- Ví dụ: 'RDMD00-368'
    ```
    *   *Cách xử lý:* Nếu các cột Vol/Farad bị rỗng (`NULL`), yêu cầu Master Data vào màn hình **A410** nhập đầy đủ thông số cho Model đó và bấm **Lưu**.

*   **Bước 3: Kiểm tra trạng thái QC Pass của Lot (Xem mục 4.1)**
    Lot chưa QC Pass (`LotDecisionResult IS NULL`) sẽ chặn in tem đóng gói.

*   **Bước 4: Kiểm tra cấu hình in tem VJ của mã sản phẩm**
    Nếu in tem không ra đúng đầu mã VJ mà ra mã VV:
    ```sql
    -- Kiểm tra thiết lập chuyển đổi mã VV -> VJ
    SELECT * FROM STB_Vietnam_PackingPrinting WHERE MaterialCode = 'Mã_Vật_Tư';
    ```
    *   *Cách xử lý:* Đảm bảo cờ `PrintVJ = 1` để hệ thống tự động đổi đầu mã khi in.

---

### 6.18 [B353]/[B523] — Bug: chuyển đổi Lot nhưng vẫn in tem theo Lot cũ (STB_ChangePartNoAndLotNo bị bỏ qua)

> **Ngày phát hiện:** 2026-06-18 | **Lot mẫu:** `VJQM153R025606` → `VVQM153R025606` | **Model:** `ECVT30-255` (`WEC3R0256QG`)

**Triệu chứng:** User dùng màn hình **B353** (Thay đổi tên lot hàng) để chuyển đổi tên lot từ `VJQM153R025606` sang `VVQM153R025606`. Bản ghi đã lưu thành công vào bảng `STB_ChangePartNoAndLotNo` (ID=1572, isLotID=1). Tuy nhiên, khi ra màn hình **B523** in tem, hệ thống vẫn hiển thị LotNo trên tem là `VJQM153R025606` (lot cũ) thay vì `VVQM153R025606` (lot mới đã chuyển đổi).

**Phân tích Root Cause:**

SP `usp_Vietnam_GetBoxIDForLotNo_VVT` có logic chuyển đổi LotNo tại dòng ~543-555:

```sql
/* Tự thay đổi lotno */
DECLARE @LotNoFirst VARCHAR(100)
SELECT @LotNoFirst = OldBarcode 
FROM STB_LotChangeMaterialHistory 
WHERE (newbarcode = @LotNo OR OldBarcode = @LotNo)

DECLARE @oldLotid VARCHAR(50), @newLotid VARCHAR(50)
SELECT @oldLotid = oldLotid, @newLotid = newLotid 
FROM [STB_ChangePartNoAndLotNo] 
WHERE (oldLotid = @LotNoFirst OR oldLotid = @LotNo) AND isLotID = 1
```

**Chuỗi lỗi logic:**

| Bước | Biến | Giá trị | Giải thích |
|------|-------|---------|------------|
| 1 | `@LotNo` (input) | `VVQM153R025606` | Barcode gốc từ `STB_MaterialLotInfo.LotNo` |
| 2 | `@LotNoFirst` | `NULL` | Không có bản ghi trong `STB_LotChangeMaterialHistory` |
| 3 | Lookup `STB_ChangePartNoAndLotNo` | `WHERE oldLotid = NULL OR oldLotid = 'VVQM153R025606'` | ❌ **KHÔNG MATCH** vì `oldLotID = 'VJQM153R025606'` (đầu VJ) |
| 4 | `@oldLotid`, `@newLotid` | Cả hai `NULL` | Không tìm thấy bản ghi chuyển đổi |
| 5 | CASE LotNo (dòng ~644) | `(@LotNoFirst = @oldLotid OR @oldLotid = @Lotno)` | `NULL = NULL` → **FALSE** trong SQL! |
| 6 | Fall-through → dòng ~754 | `@allowVJ = 1` → `STUFF(LotNo, 1, 2, 'VJ')` | Hệ thống auto chuyển VV→VJ, **phủ định** hành động B353 |

**Điểm mấu chốt:** B353 lưu `oldLotID = 'VJQM153R025606'` (tên in trên tem, đầu VJ). Nhưng SP tra cứu bằng `@LotNo = 'VVQM153R025606'` (barcode gốc từ DB, đầu VV). Do prefix khác nhau (`VJ` vs `VV`), lookup không match → conversion bị bỏ qua.

**Fix SP `usp_Vietnam_GetBoxIDForLotNo_VVT`:** (Sửa 2 chỗ — phiên bản AN TOÀN có guard chống collision)

> [!WARNING]
> **Không dùng STUFF mù quáng!** Có 4 cặp lot mà cả VV lẫn VJ đều tồn tại trong `STB_ChangePartNoAndLotNo` nhưng trỏ tới `NewLotID` khác nhau. Fix phải dùng IF fallback chỉ khi chưa match VV.

**Chỗ 1 — Sau dòng ~548** (thêm IF fallback block):
```sql
-- Giữ nguyên dòng 548 gốc:
select @oldLotid=oldLotid,@newLotid=newLotid from [STB_ChangePartNoAndLotNo] where (oldLotid=@LotNoFirst or oldLotid=@LotNo) and isLotID = 1

-- [FIX-20260618] THÊM SAU dòng 548: Fallback VJ lookup
-- Guard: CHỈ chạy khi chưa tìm thấy record VV VÀ @LotNo bắt đầu 'VV'
IF @oldLotid IS NULL AND @LotNo LIKE 'VV%'
BEGIN
    SELECT @oldLotid=oldLotid, @newLotid=newLotid 
    FROM [STB_ChangePartNoAndLotNo] 
    WHERE oldLotid = STUFF(@LotNo,1,2,'VJ') AND isLotID = 1
END
```

**Chỗ 2 — Dòng ~644** (mở rộng CASE condition):
```diff
- when (@LotNoFirst = @oldLotid or @oldLotid =@Lotno) then @newLotid
+ when (@LotNoFirst = @oldLotid or @oldLotid =@Lotno or (@newLotid IS NOT NULL AND @oldLotid = STUFF(@LotNo,1,2,'VJ'))) then @newLotid
```

**Verification 4 scenarios đã kiểm chứng:**
| Scenario | Input | Kết quả | Status |
|----------|-------|---------|--------|
| A. Lot bình thường (không B353) | `VVXX...` | IF chạy nhưng STUFF không match → auto VJ bình thường | ✅ Safe |
| B. Lot bug (VJ record, không VV) | `VVQM153R025606` | IF match VJ → `@newLotid` = lot mới | ✅ Fixed |
| C. Lot collision (cả VV+VJ có record) | `VVPK133R025603` | Dòng 548 gốc match VV → IF **SKIP** → dùng đúng record VV | ✅ Safe |
| D. Module lot (MVV prefix) | `MVVPO...` | `LIKE 'VV%'` = FALSE → IF **SKIP** | ✅ Safe |

**Query debug nhanh:**
```sql
-- Kiểm tra bản ghi B353 cho 1 lot
SELECT * FROM STB_ChangePartNoAndLotNo WITH(NOLOCK) 
WHERE oldLotID LIKE '%QM153R025606%' OR NewLotID LIKE '%QM153R025606%'

-- Kiểm tra cấu hình PrintVJ
SELECT PrintVJ, MaterialCode, PartNo FROM STB_Vietnam_PackingPrinting WITH(NOLOCK) 
WHERE MaterialCode = 'ECVT30-255'

-- Kiểm tra barcode gốc trong SetInfo
SELECT Barcode, MaterialCode FROM STB_SetInfo WITH(NOLOCK) 
WHERE Barcode = 'VVQM153R025606'
```

**Kết quả kiểm chứng an toàn trên DB Production (2026-06-18):**

| # | Test | Kết quả | Ý nghĩa |
|---|------|---------|---------|
| 1 | Tổng record `STB_ChangePartNoAndLotNo` (isLotID=1) | **1,457** | 126 VJ + 1,325 VV |
| 2 | VJ-only (không có bản VV) = nhóm lot bị bug | **122** | Fix sẽ tác động nhóm này |
| 3 | Collision pairs (cả VV+VJ đều có record riêng) | **4 cặp** | Fix KHÔNG tác động nhờ guard `IF @oldLotid IS NULL` |
| 4 | Lot VV có record riêng | **1,325** | Fix KHÔNG tác động (query gốc đã match) |
| 5 | Lot VV trong MaterialLotInfo tìm thấy VJ match | **58** | 58/58 valid, 0 false positive |
| 6 | Suffix verification (ký tự 3+ giống nhau VV↔VJ) | **58/58** | 100% match đúng cặp lot |
| 7 | Lot đã gộp box xong trong nhóm affected | **58/58** | SP chỉ SELECT output → không ghi DB → lot cũ KHÔNG bị ảnh hưởng |
| 8 | Module lots (MVV prefix) | **20,368** | 100% safe — guard `LIKE 'VV%'` chặn |
| 9 | SP write operations | INSERT dòng 476 dùng `@LotNo` trực tiếp | Fix ở dòng 557+654 → **SAU** INSERT → không ảnh hưởng |

> [!IMPORTANT]
> **Kết luận an toàn:** Fix chỉ thay đổi **output SELECT** (LotNo hiển thị trên tem). Không INSERT/UPDATE/DELETE dữ liệu. Guard 3 lớp: (1) `IF @oldLotid IS NULL` chặn lot đã có record VV, (2) `LIKE 'VV%'` chặn module lot, (3) `@newLotid IS NOT NULL` chặn match rỗng.

> [!WARNING]
> **Pattern chung:** Bug này sẽ xảy ra với **MỌI** lot thuộc model có `PrintVJ = 1` khi dùng B353 để chuyển tên lot từ VJ→VV. Cho đến khi SP được fix, phải workaround bằng cách **hardcode** thêm WHEN clause cho từng lot cụ thể trong SP, giống cách `ducnv` đã làm ở dòng ~621-751.

---
### 6.19 [C531] — Sửa cấp OQC chọn nhầm tại (VVT_OQC_REFER)

> **Ngày:** 2026-06-18 | **Màn hình:** C531 (VVT_CAPA input division / Tạo phân cấp dung lượng OQC)

**Triệu chứng:** Operator chọn nhầm cấp OQC cho lot tại màn C531 (ví dụ: chọn cấp C thay vì cấp B). Sau khi bấm lưu, không thể sửa lại trên giao diện vì `finished = '1'`.

**Bảng liên quan:** `VVT_OQC_REFER` — lưu thông tin phân cấp OQC

| Cột | Ý nghĩa |
|-----|---------|
| `lotid` | Mã lot (= Barcode) |
| `mergeid` | Mã gộp (thường = lotid) |
| `levelB` | Cấp phân loại (B, C, D...) |
| `finished` | Trạng thái gộp (`'1'` = đã gộp xong, `NULL` = chưa) |
| `CreateUserID` | User thực hiện |

**SP đằng sau C531:**

| SP | Chức năng |
|----|-----------|
| `usp_GetProdOQCgForBarcode_VVT` | Load data barcode lên grid |
| `usp_DoProcessOQCrefer_VVT` | Lưu phân cấp OQC vào `VVT_OQC_REFER` |

**Quy trình sửa cấp OQC:**

```sql
-- 1. Kiểm tra trạng thái hiện tại
SELECT lotid, mergeid, levelB, finished, CreateUserID 
FROM VVT_OQC_REFER WITH(NOLOCK) 
WHERE lotid = 'MÃ_LOT';

-- 2. Sửa cấp + reset finished để gộp lại
BEGIN TRAN
UPDATE VVT_OQC_REFER
SET levelB = 'CẤP_ĐÚNG',    -- Ví dụ: 'B'
    finished = NULL
WHERE lotid = 'MÃ_LOT'
  AND levelB = 'CẤP_SAI';   -- Guard: chỉ sửa đúng bản ghi sai
SELECT @@ROWCOUNT AS [Rows]; -- Phải = 1
-- Xác nhận xong → đổi ROLLBACK thành COMMIT
ROLLBACK

-- 3. Sau khi COMMIT: Vào lại C531 → quét barcode → chọn đúng cấp → gộp lại
```

> [!IMPORTANT]
> Nếu lot đã được gộp box (`STB_MaterialLotInfo.PackingID IS NOT NULL`), cần kiểm tra xem box đó có cần điều chỉnh cấp không.

---


**Root Cause:** Model mới (`CRFYL85-01`, `CRFYN85L-01`) chưa được cấu hình cột `MaterialThickness` trong bảng `STB_MaterialMaster`.

**Cơ chế:** SP `usp_DayProdPlan_get` load dữ liệu B442 có logic auto-fill thickness:
```sql
-- Logic auto fill thickness (by Mr.Tung 2022-04-07)
CASE WHEN SI.SIExtReal03 IS NOT NULL THEN SI.SIExtReal03 
     ELSE CONVERT(NUMERIC(20,5), ISNULL(MM.MaterialThickness, '0.0')) 
END AS SIExtReal03   -- SIExtReal03 = cột "Độ dày" trên grid
```
Khi `MaterialThickness` rỗng → auto-fill = `0.0` → tem không hiển thị.

**Fix 2 bước:**

```sql
-- Bước 1: Cấu hình MaterialThickness cho model mới
BEGIN TRAN
UPDATE STB_MaterialMaster SET MaterialThickness = '120' WHERE MaterialCode = 'CRFYL85-01' AND (MaterialThickness IS NULL OR MaterialThickness = '');
UPDATE STB_MaterialMaster SET MaterialThickness = '180' WHERE MaterialCode = 'CRFYN85L-01' AND (MaterialThickness IS NULL OR MaterialThickness = '');
SELECT MaterialCode, MaterialThickness FROM STB_MaterialMaster WHERE MaterialCode IN ('CRFYL85-01','CRFYN85L-01'); -- Verify
-- ROLLBACK hoặc COMMIT
ROLLBACK

-- Bước 2: Fix lot đã tạo (SIExtReal03 đang = 0)
BEGIN TRAN
UPDATE STB_SetInfo SET SIExtReal03 = 120 WHERE MaterialCode = 'CRFYL85-01' AND SIExtReal03 = 0;
UPDATE STB_SetInfo SET SIExtReal03 = 180 WHERE MaterialCode = 'CRFYN85L-01' AND SIExtReal03 = 0;
SELECT Barcode, MaterialCode, SIExtReal03 FROM STB_SetInfo WHERE MaterialCode IN ('CRFYL85-01','CRFYN85L-01'); -- Verify
-- ROLLBACK hoặc COMMIT
ROLLBACK
```

**Mapping cột SetInfo ↔ tên hiển thị trên grid B442:**

| Cột DB | Tên trên grid | Nguồn dữ liệu |
|--------|--------------|----------------|
| `SIExtReal01` | Độ dài | Client input |
| `SIExtReal02` | Khổ | Client input |
| `SIExtReal03` | Độ dày | Auto-fill từ `STB_MaterialMaster.MaterialThickness` |


**Tem thiếu tên binder (VD: `(A301)`) để phân biệt giữa các molder:**

Tem Electrode in `[MaterialName]` trực tiếp từ `STB_MaterialMaster`. Nếu `MaterialName` không chứa tên binder → tem không hiển thị.

```sql
-- Kiểm tra MaterialName hiện tại
SELECT MaterialCode, MaterialName FROM STB_MaterialMaster WITH(NOLOCK)
WHERE MaterialCode IN ('CRFYL85','CRFYL85-01');
-- CRFYL85    : "...YP 85 120 (A301) 1 batch (-)"    ← CÓ binder ✅
-- CRFYL85-01 : "...YP 85 120 1.5 batch (-)"          ← THIẾU binder ❌

-- Fix: Thêm binder name vào MaterialName (tại A230 hoặc SQL)
BEGIN TRAN
UPDATE STB_MaterialMaster SET MaterialName = 'Coating-Roll Forming-YP 85 120 (A301) 1.5 batch (-)'
WHERE MaterialCode = 'CRFYL85-01';
SELECT MaterialCode, MaterialName FROM STB_MaterialMaster WHERE MaterialCode = 'CRFYL85-01';
ROLLBACK
```

> [!IMPORTANT]
> **Tại sao sửa `MaterialName` là an toàn?** Vì `STB_SetInfo` và `STB_DayProdPlan` chỉ lưu `MaterialCode`, `MaterialName` luôn được JOIN từ `STB_MaterialMaster` khi hiển thị. Sửa master = tất cả lot (quá khứ + tương lai) tự động cập nhật.
>
> **Chứng minh:** Trong `usp_SetInfo_get`:
> ```sql
> LEFT JOIN STB_MaterialMaster MM ON MM.MaterialCode = SI.MaterialCode
> SELECT ... MM.MaterialName AS MaterialName ...  -- JOIN từ Master, không lưu riêng
> ```
> Ngoại lệ: 3 ControlNo bị hardcode override bằng CASE WHEN (theo yêu cầu đặc biệt).

**SP liên quan B442:**

| SP | Chức năng |
|----|-----------|
| `usp_DayProdPlan_get` | Load DayProdPlan + auto-fill thickness |
| `usp_SetInfo_iud_VNT` | Lưu SetInfo (truyền `@pThickness = @SIExtReal03`) |
| `usp_SetInfo_get` | Load SetInfo grid |
| `usp_MainAssemblePartWeight_get` | Load thông tin vật tư |

> [!WARNING]
> **Pattern chung:** Khi thêm model Electrode mới (CRF%), phải làm 2 việc:
> 1. **A230** (MaterialMaster): Cấu hình `MaterialThickness` (VD: 120, 180, 200)
> 2. **A460** (LabelInfo): Thêm record vào `STB_ModelLabelInfo` (mapping ModelCode → LabelType)
> Thiếu bước 1 → tem không hiển thị độ dày. Thiếu bước 2 → lỗi **"Not found label type"** khi in tem.

**Lỗi in tem "Not found label type" (A460 chưa config):**

Nếu bấm in tem trên B442 mà popup lỗi `"Not found label type"` → model chưa có record trong `STB_ModelLabelInfo`.

```sql
-- Kiểm tra model có label config chưa
SELECT ModelCode, LabelType, FormatName FROM STB_ModelLabelInfo WITH(NOLOCK) WHERE ModelCode = 'MÃ_MODEL';

-- Nếu không có → copy từ model cũ cùng loại
-- VD: Copy CRFYN85L → CRFYN85L-01
BEGIN TRAN
INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
SELECT 'MODEL_MỚI', LabelType, FormatName, GETDATE(), 'admin'
FROM STB_ModelLabelInfo WHERE ModelCode = 'MODEL_CŨ';
SELECT @@ROWCOUNT; -- Phải > 0
ROLLBACK
```

**Bảng mapping `STB_ModelLabelInfo`:**

| Cột | Ý nghĩa |
|-----|---------|
| `ModelCode` | MaterialCode (mã sản phẩm) |
| `LabelType` | Loại tem: `ElectLabel`, `AssembleLabel`, `PartLabel`, `BoxLabel2`... |
| `FormatName` | Tên format tem (unicode) |

**LabelType phổ biến cho Electrode (CRF%):**

| LabelType | Chức năng | Bắt buộc? |
|-----------|-----------|-----------|
| `ElectLabel` | Tem điện cực (in từ B442) | ✅ Bắt buộc |
| `AssembleLabel` | Tem sản xuất (B450/B540) | Tùy dây chuyền |
| `PartLabel` | Tem vật tư (F330) | Tùy quy trình |


