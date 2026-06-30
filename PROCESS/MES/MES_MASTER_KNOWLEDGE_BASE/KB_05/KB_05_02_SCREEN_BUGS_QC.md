## 🔴 Cẩm nang khắc phục lỗi theo Screen ID (Gộp từ KB_SCREEN_BUG_REF)

## B597 — Material Scanning & PQC Verification (Scan nguyên vật liệu đầu vào chuyền)

### Lỗi 1: Cảnh báo đỏ chặn không cho lưu Lot NVL đầu vào (HOLD, Hết hạn, Sai chủng loại)
*   **Triệu chứng:** Khi quét mã Lot nguyên liệu đầu vào tại **B597**, hệ thống báo lỗi đỏ cấm sử dụng.
*   **Nguyên nhân gốc:** Lot đang nằm ở kho ảo `HOLDING_WH` (chưa QC), hoặc ngày hết hạn sử dụng vượt quá ngày hiện tại (vi phạm FIFO/Expiry), hoặc mã nguyên liệu không nằm trong BOM cấu hình của PO.
*   **Cách khắc phục:**
    1. Check QC: Yêu cầu QC PASS hoặc chuyển kho Lot về kho chính `ROH_WH` bằng SQL.
    2. Bypass gia hạn dùng tạm thời (Ghi nhận biên bản audit): UPDATE ngày tạo `CreateDateTime` lùi lại hoặc chạy lệnh bỏ qua FIFO.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 7](../KB_05/KB_05_01_QC_OVERVIEW.md#7-lỗi-quét-nguyên-vật-liệu-b597--pqc-check).

### Lỗi 2: Lỗi quét vỏ nhôm (AluCase) mới báo sai chủng loại tại B597
*   **Triệu chứng:** Quét mã vỏ nhôm mới hệ thống báo lỗi chặn đứng sản xuất.
*   **Nguyên nhân gốc:** Logic kiểm tra vỏ nhôm không nằm trong DB cấu hình mà bị hardcode trực tiếp trong SP `usp_Vietnam_RawMaterialInputHist_uid`.
*   **Cách khắc phục:**
    ALTER SP `usp_Vietnam_RawMaterialInputHist_uid` để bổ sung mã vỏ nhôm mới vào khối điều kiện `IF / NOT IN`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 7.4](../KB_05/KB_05_01_QC_OVERVIEW.md#74-lỗi-vỏ-nhôm-alucase).

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

### Lỗi 4: Lỗi BOM điện cực dạng tráng (Coating) không khớp với BOM gốc dạng chia cuộn (Slitting) cho model 1030L (ECVT30-293) tại B597
*   **Triệu chứng:** Khi quét điện cực dương (+) hoặc âm (-) tại trạm **B597** cho model `1030L` (mã model thực tế `ECVT30-293`), hệ thống báo lỗi: `"lỗi BOM CREYO85B-02 không được phép dùng cho model ECVT30-293"`.
*   **Nguyên nhân gốc:**
    1. **Sai lệch cấu trúc BOM**: Trong BOM gốc (phiên bản `2001`) của model `ECVT30-293`, R&D khai báo mã điện cực chia cuộn (**Slitting-Roll** - ví dụ `SREYO85A` và `SRFYO85A`). Tuy nhiên, Lot điện cực quấn thực tế cấp cho chuyền là mã cuộn tráng (**Coating-Roll** - ví dụ `CREYO85B-02` và `CRFYO85B-02`). Khi SP `usp_Vietnam_RawMaterialInputHist_uid` đối chiếu mã cuộn tráng đã quét với BOM, hệ thống không tìm thấy và chặn lại.
    2. **Chặn tồn kho Slitting ảo**: Lot điện cực quét vào không tồn tại hoặc chưa được khai báo đồng bộ vào bảng tồn kho slitting ảo `Stb_SlittingStock_VVT`, dẫn đến việc tiếp tục bị chặn bởi lỗi `"Chưa nhập thông tin Slitting Điện cực ở màn hình B552..."` (nếu vượt qua lỗi BOM).
*   **Cách khắc phục:**
    *   **Phương án 1 (Khuyên dùng - Deploy SP bypass):**
        Sửa đổi SP `usp_Vietnam_RawMaterialInputHist_uid` để vừa ánh xạ tương đương mã Coating sang Slitting trong BOM, vừa bypass tồn kho slitting cho mã này.
        1. Sửa đoạn check BOM (khoảng dòng 1279):
           ```sql
           IF not EXISTS(
               SELECT 1 FROM STB_BomDetail 
               WHERE MaterialCode=@MaterialCodeNotLowESR 
                 AND BomVersion='2001' 
                 AND (
                     ChildMaterialCode=@MaterialCodeBOM
                     OR (@MaterialCodeNotLowESR = 'ECVT30-293' AND @MaterialCodeBOM = 'CREYO85B-02' AND ChildMaterialCode = 'SREYO85A')
                     OR (@MaterialCodeNotLowESR = 'ECVT30-293' AND @MaterialCodeBOM = 'CRFYO85B-02' AND ChildMaterialCode = 'SRFYO85A')
                 )
           )
           ```
        2. Sửa đoạn check tồn kho Slitting (khoảng dòng 2124):
           ```sql
           --update for 1030L (ECVT30-293)
           if (@materialCodeCheck IN ('ECVT30-293') and @rawMaterialCheck IN ('CREYO85B-02', 'CRFYO85B-02'))
           begin
               set @count=1;
           end
           --end 1030L
           ```
        3. Deploy SP lên hệ thống DB:
           ```powershell
           .\deploy_tool.ps1 sql\procedures\usp_Vietnam_RawMaterialInputHist_uid.sql
           ```
    *   **Phương án 2 (Đổi PO/Model - Giải pháp tạm của xưởng):**
        Nếu xưởng chuyển đổi Lot sản phẩm sang chạy dưới PO của model chị em **`ECVT30-367`** (ví dụ PO `260623000007`), hệ thống sẽ cho phép lưu vì `ECVT30-367` không nằm trong danh sách kiểm tra BOM nghiêm ngặt trong SP (tự động bypass check BOM). Tuy nhiên, phương án này **chỉ thành công** nếu các cuộn điện cực quét vào đã được khai báo tồn kho trong `Stb_SlittingStock_VVT` từ trước (nếu chưa khai báo thì vẫn sẽ bị chặn lỗi tồn kho Slitting).
        Để thực hiện chuyển đổi PO bằng SQL cho Lot sản phẩm (chỉ dùng khi có phê duyệt):
        ```sql
        BEGIN TRANSACTION;
        UPDATE STB_SetInfo SET PONo = 'MÃ_PO_MỚI', MaterialCode = 'MÃ_MODEL_MỚI' WHERE Barcode = 'MÃ_LOT_SẢN_PHẨM';
        UPDATE STB_ProdRouteHist SET PONo = 'MÃ_PO_MỚI', MaterialCode = 'MÃ_MODEL_MỚI' WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_LOT_SẢN_PHẨM');
        COMMIT TRANSACTION; -- Đổi thành ROLLBACK nếu muốn kiểm tra trước
        ```

---


## B598 — Material Scrap Report (Báo phế nguyên vật liệu trên chuyền)

### Lỗi 1: Báo phế NVL bị lỗi không ghi nhận hệ thống
*   **Triệu chứng:** Báo phế NVL tại chuyền ở màn hình **B598** bị chặn hoặc không đồng bộ số lượng.
*   **Nguyên nhân gốc:** Lệch ngày `JobDate` giữa ca sản xuất thực tế và ngày khai báo kế hoạch trên MES.
*   **Cách khắc phục:**
    Chạy query cập nhật điều chỉnh `JobDate` của Lot kế hoạch ngày khớp với thực tế để mở luồng ghi nhận phế.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.12](../KB_03/KB_03_02_CELL_LINE.md#612-b598-báo-phế-nvl-sửa-jobdate-đặc-biệt).

---


## C121 / C122 — QC Inspections (Cấu hình QC đầu vào)

### Lỗi 1: Lot nguyên liệu nhập kho không tự động hiển thị các hạng mục kiểm tra QC
*   **Triệu chứng:** Lot nguyên liệu hiển thị trên lưới QC nhưng không có bất kỳ hạng mục nào để nhập kết quả đo.
*   **Nguyên nhân gốc:** Chưa gán mã nguyên vật liệu vào nhóm hạng mục kiểm tra IQC tại màn hình **C122** hoặc chưa cấu hình nhóm kiểm tra tại **C121**.
*   **Cách khắc phục:**
    1. Vào **C121** thêm nhóm kiểm tra và các hạng mục chi tiết.
    2. Vào **C122**, chọn mã nguyên vật liệu và click chọn nhóm kiểm tra tương ứng để map dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.1](../KB_05/KB_05_01_QC_OVERVIEW.md#91-iqc-incoming-quality-control--kiểm-tra-nvl-đầu-vào).

---


## C220 — IQC Incoming Quality Control (Xác nhận kết quả IQC)

### Lỗi 1: Lỗi bị chặn "Receiving Confirmation" khi gộp nhập kho tại F330
*   **Triệu chứng:** Thủ kho bấm nhận hàng tại **F330** hệ thống báo lỗi chặn giao dịch.
*   **Nguyên nhân gốc:** Kết quả kiểm tra mẫu IQC của Lot hàng tại màn hình **C220** vẫn ở trạng thái chờ đánh giá hoặc đã bị đánh giá FAIL.
*   **Cách khắc phục:**
    Yêu cầu bộ phận QC hoàn thành nhập kết quả đo và xác nhận cờ chất lượng PASS cho Lot hàng trên màn hình **C220**.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_NVL_WMS.md § 4.15](../KB_02/KB_02_01_NVL_WMS.md#415-luồng-nhập-kho-đầy-đủ-f330).

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_NVL_WMS.md § 4](../KB_02/KB_02_01_NVL_WMS.md#4-lỗi-màn-hnc321-qc-nhập-ng-sản-phẩm-mang-đi-kiểm-tra--báo-lỗi-chữ-hàn-quốc) và [Kịch bản 3](#kịch-bản-sự-cố-khẩn-cấp-3-lỗi-nhập-phế-hnc321-báo-lỗi-tiếng-hàn).

### Lỗi 2: Nhập phế/sửa chữa tại C321 báo lỗi hoặc không cập nhật được thông số sửa chữa
*   **Triệu chứng:** OP không lưu được thông tin sửa chữa/vật tư thay thế, hoặc bị sai lệch số lượng NG (`DefectQty`) ở các trạm tiếp theo.
*   **Nguyên nhân gốc:** Lỗi khi đồng bộ dữ liệu giữa bảng thông tin lỗi `STB_DefectRepairInfo` và số lượng chốt sản lượng của công đoạn.
*   **Cách khắc phục:** IT kiểm tra thông số và cập nhật đồng bộ lại cột `DefectQty` hoặc `ProdQty` bằng cách chỉnh sửa trực tiếp DB.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.5](../KB_05/KB_05_01_QC_OVERVIEW.md#95-c321---pqc-reliability-assy-sửa-chữa-lỗi-cell-line).

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
*   **Chi tiết nghiệp vụ:** Xem tại [Kịch bản 1](#kịch-bản-sự-cố-khẩn-cấp-1-hủy-kết-quả-kiểm-tra-chất-lượng-qc-b597c443).

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 7.8](../KB_05/KB_05_01_QC_OVERVIEW.md#78-cột-note1-thừa-trên-grid-c486-và-logic-rebuild-bảng).

---


## C512 / C530 / C546 — OQC Lot Management (Quản lý chất lượng đầu ra)

### Lỗi 1: Lỗi không tìm thấy Lot khi tạo hồ sơ kiểm tra OQC ở C512
*   **Triệu chứng:** Bấm tạo Lot OQC tại **C512** hệ thống báo không tìm thấy bản ghi Lot nào của sản phẩm.
*   **Nguyên nhân gốc:** Lot sản phẩm chưa hoàn thành công đoạn đóng gói cuối (chưa gộp Box tại B523) hoặc PO chưa cấu hình cờ đầu ra sản phẩm `IsOutputRoute = 1`.
*   **Cách khắc phục:**
    1. Kiểm tra Lot đã được quét gộp box tại B523 chưa.
    2. Sửa cờ `IsOutputRoute = 1` cho công đoạn cuối của PO trong `STB_ProductionOrderRouting` nếu cấu hình BOM/Routing bị thiếu.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 7.2](../KB_05/KB_05_01_QC_OVERVIEW.md#72-không-tìm-thấy-lot-ở-màn-c512).

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.6](../KB_05/KB_05_01_QC_OVERVIEW.md#96-c546-foqc-ocvsr-chỉ-hiển-thị-20ea-thay-vì-50ea-ocv-lệch-dữ-liệu) và file script vá lỗi [fix_c546_ocv_lots.sql](../sql/scripts/fix_c546_ocv_lots.sql).

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.4](../KB_05/KB_05_01_QC_OVERVIEW.md#94-bendingcutting-qc-c561c564).

---


## C112 — AQL Basic Rules (Quy tắc AQL cơ bản)

### Lỗi 1: Cấu hình mẫu kiểm tra AQL không áp dụng đúng cho OQC
*   **Triệu chứng:** Khi tạo hồ sơ OQC tại C512, số lượng mẫu lấy kiểm tra không đúng với quy tắc AQL.
*   **Nguyên nhân gốc:** Bảng quy tắc AQL chưa được cấu hình cho kích thước lô hàng tương ứng.
*   **Cách khắc phục:** Vào C112, kiểm tra và bổ sung quy tắc AQL cho size lô hàng (Lot Size) phù hợp.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_19/KB_19_01_ARCHITECTURE.md](../KB_19/KB_19_01_ARCHITECTURE.md).

---


## C122 — IQC Material Inspection Setup (Thiết lập hạng mục kiểm tra NVL)

> 🔗 **Xem thêm:** Mục [C121 / C122](#c121--c122--qc-inspections) phía trên đã có chi tiết cấu hình QC đầu vào.

### Lỗi 1: Lot NVL nhập kho không tự động hiện hạng mục kiểm tra
*   **Triệu chứng:** Lot nguyên liệu hiển thị trên lưới QC nhưng không có hạng mục để nhập kết quả đo.
*   **Nguyên nhân gốc:** Mã NVL chưa được gán nhóm hạng mục kiểm tra IQC tại C122.
*   **Cách khắc phục:** Vào C122, chọn mã NVL, click chọn nhóm kiểm tra tương ứng để map dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.1](../KB_05/KB_05_01_QC_OVERVIEW.md).

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_NVL_WMS.md](../KB_02/KB_02_01_NVL_WMS.md) và [../KB_10/KB_10_01_ARCHITECTURE.md § 0](../KB_10/KB_10_01_ARCHITECTURE.md#0-bản-dịch-bình-dân-hiểu-sơ-đồ-luồng-dữ-liệu-mes-trong-5-phút).

---


## C141 — Inspection Type Setup (Thiết lập loại hình kiểm tra chung)

### Lỗi 1: Sai loại dữ liệu nhập liệu (số thay vì checkbox hoặc ngược lại)
*   **Triệu chứng:** Grid nhập liệu kiểm tra QC hiển thị ô nhập số nhưng yêu cầu là checkbox, hoặc ngược lại.
*   **Nguyên nhân gốc:** Cột "Loại dữ liệu nhập vào" tại C141 bị thiết lập sai (`1`=số, `2`=tích checkbox).
*   **Cách khắc phục:** Vào C141, sửa lại cột DataType cho hạng mục tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9](../KB_05/KB_05_01_QC_OVERVIEW.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## C143 — Inspection Item Configuration (Thiết lập hạng mục kiểm tra chi tiết)

### Lỗi 1: Mã NVL quét tại B597 không đi đến đúng hạng mục kiểm tra
*   **Triệu chứng:** NVL quét tại B597 bị map sai nhóm kiểm tra, hiện ra các hạng mục đo không liên quan.
*   **Nguyên nhân gốc:** Cấu hình tại C143 map sai mã NVL vào nhóm hạng mục không phù hợp.
*   **Cách khắc phục:** Vào C143, tìm mã NVL, chỉnh lại nhóm hạng mục kiểm tra tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9](../KB_05/KB_05_01_QC_OVERVIEW.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## C151 — Material QC Detail Setup (Thiết lập chi tiết QC vật tư)

### Lỗi 1: Sau khi set A410 xong phải tắt C151 rồi mở lại mới hiển thị đúng
*   **Triệu chứng:** Cấu hình tại A410 đã lưu nhưng C151 vẫn hiện dữ liệu cũ.
*   **Nguyên nhân gốc:** Cache dữ liệu trên client. C151 không tự refresh sau khi A410 thay đổi.
*   **Cách khắc phục:** Đóng tab C151, mở lại từ menu. Dữ liệu sẽ load lại từ DB.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9](../KB_05/KB_05_01_QC_OVERVIEW.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## C153 — QC Sample Config (Cấu hình mẫu kiểm tra QC)

### Lỗi 1: Số lượng mẫu kiểm tra (SampleQty) không khớp với thực tế đo
*   **Triệu chứng:** Máy đo trả về 50 mẫu nhưng C546 chỉ hiện 20 dòng.
*   **Nguyên nhân gốc:** `SampleQty` cấu hình trong bảng `STB_MaterialQcDetail` bị thiết lập sai.
*   **Cách khắc phục:** Vào C153 hoặc chỉnh trực tiếp `STB_MaterialQcDetail` để SampleQty khớp số lượng mẫu thực tế.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md](../KB_03/KB_03_02_CELL_LINE.md).

---


## C243 — Electrode QC Measurement (Đo lường QC điện cực)

> 🔗 **Xem thêm:** Mục [F743~F748 / C243](#f743f748--c243--electrode-slitting--qc) phía trên đã có chi tiết Slitting & QC điện cực.

### Lỗi 1: Kết quả đo QC điện cực bị lệch hoặc không hiển thị
*   **Triệu chứng:** Grid đo QC điện cực trống hoặc giá trị đo bị sai.
*   **Nguyên nhân gốc:** Dữ liệu đo chưa được upload từ máy đo hoặc mapping giữa Lot điện cực và hạng mục đo bị sai.
*   **Cách khắc phục:** Kiểm tra kết nối máy đo và trạng thái upload trong `Stb_ESRValueMonitor`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 8](../KB_05/KB_05_01_QC_OVERVIEW.md).

---


## C430 — QC Receiving Inspection (Kiểm tra chất lượng nhận hàng)

### Lỗi 1: Không tìm thấy Lot NVL để kiểm tra tại C430
*   **Triệu chứng:** QC mở C430 nhưng không thấy Lot NVL mới nhập kho để kiểm tra.
*   **Nguyên nhân gốc:** Lot NVL chưa được nhập kho tại F330 hoặc chưa được chuyển trạng thái từ `HOLDING_WH`.
*   **Cách khắc phục:** Kiểm tra F330 đã hoàn thành nhập kho, kiểm tra `STB_MaterialLotInfo` xem WarehouseCode.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_NVL_WMS.md § 4.15](../KB_02/KB_02_01_NVL_WMS.md) và [../KB_05/KB_05_01_QC_OVERVIEW.md](../KB_05/KB_05_01_QC_OVERVIEW.md).

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 3](../KB_05/KB_05_01_QC_OVERVIEW.md) và [../KB_25/KB_25_01_OVERVIEW.md](../KB_25/KB_25_01_OVERVIEW.md).

---


## C510 — OQC Lot Search (Tìm kiếm Lot OQC)

> 🔗 **Xem thêm:** Mục [C512 / C530 / C546](#c512--c530--c546--oqc-lot-management) phía trên đã có chi tiết lỗi OQC.

### Lỗi 1: Không tìm thấy Lot tại C510 để tạo hồ sơ OQC
*   **Triệu chứng:** Tìm kiếm Lot tại C510 trả về kết quả trống.
*   **Nguyên nhân gốc:** 3 nguyên nhân chính: (1) Lot chưa được tạo/gộp box, (2) Chưa set A410, (3) Nhà máy HN dùng Route VE02 riêng.
*   **Cách khắc phục:** Áp dụng checklist 3 bước debug giống C512 (xem mục C512 phía trên).
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 7.2](../KB_05/KB_05_01_QC_OVERVIEW.md).

---


## C522 — Aging ESR SD (Dữ liệu Aging & ESR)

### Lỗi 1: Dữ liệu Aging/ESR không đồng bộ hoặc hiển thị sai
*   **Triệu chứng:** Kết quả Aging/ESR tại C522 bị thiếu hoặc không khớp với máy đo.
*   **Nguyên nhân gốc:** Phần mềm ESR chưa upload dữ liệu vào bảng `Stb_ESRValueMonitor` hoặc cờ `UploadToMes` chưa được set.
*   **Cách khắc phục:** Kiểm tra phần mềm đo ESR trên máy, reset cờ upload nếu cần.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_19/KB_19_01_ARCHITECTURE.md](../KB_19/KB_19_01_ARCHITECTURE.md).

---


## C530 — QC Audit (Kiểm tra chất lượng trước xuất hàng)

> 🔗 **Xem thêm:** Mục [C512 / C530 / C546](#c512--c530--c546--oqc-lot-management) phía trên đã có chi tiết lỗi OQC.

### Lỗi 1: Không đổi được trạng thái Reject sang Pass ở QC Audit
*   **Triệu chứng:** Lot đã bị FAIL/Reject tại QC Audit C530 nhưng sau kiểm tra lại cần chuyển sang PASS.
*   **Nguyên nhân gốc:** UI không cho phép đổi ngược trạng thái. Cần can thiệp DB.
*   **Cách khắc phục:** Xóa kết quả QC cũ trong `STB_CommInspDocHistory` và `STB_CommInspDocItem`, sau đó QC kiểm tra lại từ đầu.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_26/KB_26_01_LINKS_BUGS.md § 3.2](../KB_26/KB_26_01_LINKS_BUGS.md).

---


## C540 — QC Result Report (Báo cáo kết quả QC)

### Lỗi 1: Báo cáo kết quả QC hiển thị thiếu hoặc sai thông tin
*   **Triệu chứng:** Báo cáo C540 thiếu kết quả đo hoặc hiện sai trạng thái PASS/FAIL.
*   **Nguyên nhân gốc:** Lệch dữ liệu giữa `STB_CommInspDocHistory` và `STB_MaterialQcSampleResult`.
*   **Cách khắc phục:** Kiểm tra trực tiếp DB, đối chiếu kết quả QC trong 2 bảng và sửa lại nếu lệch.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9](../KB_05/KB_05_01_QC_OVERVIEW.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## C541 — QC Detail Result (Chi tiết kết quả QC)

### Lỗi 1: Chi tiết kết quả QC không load được dữ liệu
*   **Triệu chứng:** Mở C541 nhưng grid chi tiết kết quả trống trơn.
*   **Nguyên nhân gốc:** Chưa thực hiện QC hoặc `CommInspDocNo` bị NULL trong bảng `STB_CommInspDocItem`.
*   **Cách khắc phục:** Kiểm tra Lot đã hoàn thành QC chưa. Nếu đã QC mà vẫn trống, kiểm tra liên kết giữa `STB_CommInspDocHistory` và `STB_CommInspDocItem`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9](../KB_05/KB_05_01_QC_OVERVIEW.md).

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.6](../KB_05/KB_05_01_QC_OVERVIEW.md) và [../KB_26/KB_26_01_LINKS_BUGS.md](../KB_26/KB_26_01_LINKS_BUGS.md).

---


## C560 — Material Lot QC (Kiểm tra chất lượng Lot vật tư)

### Lỗi 1: Lot vật tư không hiển thị để kiểm tra QC
*   **Triệu chứng:** Mở C560 nhưng danh sách Lot vật tư cần QC bị trống.
*   **Nguyên nhân gốc:** Lot vật tư chưa được nhập kho hoặc chưa chuyển trạng thái sang chờ QC.
*   **Cách khắc phục:** Kiểm tra F330 đã nhập kho, kiểm tra bảng `STB_MaterialLotInfo` xem `WarehouseCode` và `QcStatus`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_NVL_WMS.md](../KB_02/KB_02_01_NVL_WMS.md).

---


## C562 — Bending/Cutting Lot Creation (Tạo Lot kiểm định uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên đã có chi tiết quy trình QC Bending/Cutting.

### Lỗi 1: Không tạo được Lot kiểm định tại C562
*   **Triệu chứng:** Quét barcode sản phẩm tại C562 nhưng không sinh được Lot kiểm định.
*   **Nguyên nhân gốc:** Model chưa được cấu hình nhóm kiểm tra tại C561.
*   **Cách khắc phục:** Vào C561 trước, gán nhóm kiểm tra cho MaterialCode, sau đó quay lại C562.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.4](../KB_05/KB_05_01_QC_OVERVIEW.md).

---


## C563 — Bending/Cutting Measurement (Nhập dữ liệu đo uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên.

### Lỗi 1: Lưới đo trống hoặc thiếu hạng mục đo
*   **Triệu chứng:** Quét barcode mẫu tại C563, grid trống không có hạng mục.
*   **Nguyên nhân gốc:** Chưa cấu hình C561 hoặc chưa tạo Lot kiểm định C562.
*   **Cách khắc phục:** Cấu hình C561 → Tạo Lot C562 → Quay lại C563. Nếu vẫn trống, nhấn "Tổng hợp hạng mục".
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.4](../KB_05/KB_05_01_QC_OVERVIEW.md).

---


## C564 — Bending/Cutting Report (Báo cáo kết quả uốn/cắt)

> 🔗 **Xem thêm:** Mục [C561 / C562 / C563 / C564](#c561--c562--c563--c564--bendingcutting-qc) phía trên.

### Lỗi 1: Báo cáo kết quả C564 không hiện dữ liệu sau khi đo
*   **Triệu chứng:** Đã nhập kết quả đo tại C563 nhưng C564 báo cáo trống.
*   **Nguyên nhân gốc:** Kết quả đo chưa được submit/confirm tại C563 (chưa nhấn Save).
*   **Cách khắc phục:** Quay lại C563, đảm bảo nhấn Save/Confirm để kết quả được ghi nhận vào DB.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 9.4](../KB_05/KB_05_01_QC_OVERVIEW.md).

---


## F744 — Electrode Slitting Result (Kết quả chia cuộn điện cực)

### Lỗi 1: Kết quả Slitting điện cực bị thiếu hoặc sai chiều rộng
*   **Triệu chứng:** Kết quả chia cuộn tại F744 hiển thị sai chiều rộng hoặc thiếu cuộn.
*   **Nguyên nhân gốc:** Cấu hình Slitting tại B552 (bảng `stb_slittinglocationconfig_vvt`) bị sai Width.
*   **Cách khắc phục:** Kiểm tra cấu hình B552 và sửa lại Width cho PartNo tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 8](../KB_05/KB_05_01_QC_OVERVIEW.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---


## F746 — Slitting Curling (Bo miệng điện cực)

> 🔗 **Xem thêm:** Mục [F742 / F746](#f742--f746--slitting--curling) phía trên.

### Lỗi 1: Hủy/Rollback Slitting F742 phải xóa F746 trước
*   **Triệu chứng:** Cần rollback kết quả Slitting nhưng hệ thống báo lỗi ràng buộc dữ liệu.
*   **Nguyên nhân gốc:** Bảng F746 (Curling) có FK reference đến F742 (Slitting). Phải xóa F746 trước.
*   **Cách khắc phục:** Xóa kết quả Curling (F746) trước, sau đó mới xóa kết quả Slitting (F742).
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 10.1](../KB_05/KB_05_01_QC_OVERVIEW.md).

---


## F747 — Electrode Coating (Tráng điện cực)

### Lỗi 1: Kết quả tráng điện cực không được ghi nhận
*   **Triệu chứng:** Công đoạn tráng điện cực tại F747 không lưu được kết quả.
*   **Nguyên nhân gốc:** Lot điện cực chưa hoàn thành công đoạn trước (Mixing) hoặc cấu hình Route điện cực sai.
*   **Cách khắc phục:** Kiểm tra Lot đã hoàn thành Mixing, kiểm tra Route điện cực tại B220.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 8](../KB_05/KB_05_01_QC_OVERVIEW.md).

---


## F748 — Electrode Process History (Lịch sử công đoạn điện cực)

> 🔗 **Xem thêm:** Mục [F743~F748 / C243](#f743f748--c243--electrode-slitting--qc) phía trên.

### Lỗi 1: Lịch sử công đoạn điện cực hiển thị thiếu
*   **Triệu chứng:** F748 không hiện đầy đủ các công đoạn của cuộn điện cực.
*   **Nguyên nhân gốc:** Một số công đoạn bị bỏ qua khi scan hoặc bảng `STB_ElectrodeProdRouteHist` thiếu dữ liệu.
*   **Cách khắc phục:** Kiểm tra bảng `STB_ElectrodeProdRouteHist` xem có đủ công đoạn không, chèn bổ sung nếu thiếu.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_OVERVIEW.md § 8](../KB_05/KB_05_01_QC_OVERVIEW.md).

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



---

### Kịch bản sự cố khẩn cấp 1: Hủy kết quả kiểm tra chất lượng QC (B597/C443)

#### 🔬 KỊCH BẢN B: Hủy kết quả kiểm tra chất lượng QC (B597 / C443)
*   **Triệu chứng:** QC đánh giá nhầm Lot hàng sang FAIL hoặc load nhầm hạng mục kiểm tra cũ, muốn hủy kết quả để đo lại từ đầu.
*   **Ví dụ Demo:** Hủy tài liệu QC bị sai cho Barcode `VVPP163R072732`.
*   **Quy trình xử lý bằng Transaction:**
    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Tìm CommInspDocNo (Mã tài liệu QC) đang liên kết với Barcode
        DECLARE @DocNo NVARCHAR(50);
        SELECT @DocNo = CIDH.CommInspDocNo
        FROM STB_CommInspDocHistory CIDH
        JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
        WHERE SI.Barcode = 'VVPP163R072732';

        IF @DocNo IS NOT NULL
        BEGIN
            PRINT 'Tìm thấy tài liệu QC: ' + @DocNo;

            -- 2. Xóa các hạng mục kiểm tra chi tiết trước (STB_CommInspDocItem)
            DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = @DocNo;

            -- 3. Xóa lịch sử tài liệu QC (STB_CommInspDocHistory)
            DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = @DocNo;
            
            PRINT 'Đã xóa hoàn toàn kết quả QC cũ.';
        END
        ELSE
        BEGIN
            PRINT 'Không tìm thấy kết quả QC nào cho Barcode này.';
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH;
    ```
    > ⚠️ **Lưu ý:** Sau khi chạy script, yêu cầu QC **tắt hoàn toàn màn hình B597/C443 và mở lại** để hệ thống xóa bộ nhớ đệm (cache) và tải lại spec mới từ đầu.


---

### Kịch bản sự cố khẩn cấp 2: Hủy/Sửa kết quả OQC thành phẩm (C512/C530)

#### 📦 KỊCH BẢN C: Hủy/Sửa kết quả OQC Thành phẩm (C512 / C530)
*   **Triệu chứng:** Lô thành phẩm bị đánh giá nhầm trạng thái FAIL khiến thủ kho không thể nhập kho ở F110.
*   **Quy trình xử lý nhanh (Bypass sang PASS):**
    ```sql
    -- Cập nhật trực tiếp kết quả OQC sang PASS để thông luồng nhập kho
    UPDATE STB_CommInspDocHistory
    SET CommInspResult = 'PASS',
        FinishDateTime = GETDATE(),
        ChangeUserID = 'admin_fix'
    WHERE CommInspDocNo = (
        SELECT TOP 1 CIDH.CommInspDocNo 
        FROM STB_CommInspDocHistory CIDH
        JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
        WHERE SI.Barcode = 'Mã_Barcode_Thành_Phẩm'
        ORDER BY CIDH.CreateDateTime DESC
    );
    ```


---

### Kịch bản sự cố khẩn cấp 3: Lỗi nhập phế HNC321 báo lỗi tiếng Hàn

### 4.6 LỖI NHẬP PHẾ MÀN HNC321 BÁO LỖI TIẾNG HÀN (이전 공정에 실적처리 이력이 없습니다)

#### 🔴 Triệu chứng hiện trường:
Tại màn hình **HNC321** *(Qc nhập NG sản phẩm mang đi kiểm tra)*, khi nhập số lượng phế cho Barcode `ve260509-001` tại công đoạn `VE08` (Mã lỗi `VE08_34` - Taping khác...), hệ thống báo lỗi đỏ:
`Failed to save: 이전 공정에 실적처리 이력이 없습니다.`
*(Dịch nghĩa: Không có lịch sử xử lý sản lượng ở công đoạn trước).*

#### 🔍 Nguyên nhân gốc rễ:
Stored Procedure xử lý nghiệp vụ nhập phế (`usp_Vietnam_ScrapInput_HN` — ⚠️ SP nội bộ Hà Nam, có thể là alias hoặc được gọi gián tiếp) chặn không cho phép nhập phế liệu tại công đoạn `VE08` nếu sản phẩm này chưa từng có dữ liệu chốt sản lượng (Routing History) ở công đoạn ngay trước đó (Ví dụ: `VE07` hoặc trạm trước của `VE08` trong cấu hình Routing của PO).

#### 🛠️ Kịch bản xử lý từng bước (Bypass bằng SQL):
Khi công đoạn trước bị bỏ qua không quét chốt và hàng thực tế đã phế, IT tiến hành chèn một dòng lịch sử sản lượng giả lập cho trạm trước để thông luồng:

*   **Step 1:** Truy vấn mã `ControlNo` của Barcode bị lỗi:
    ```sql
    SELECT ControlNo, Barcode, PONo, MaterialCode FROM STB_SetInfo WHERE Barcode = 've260509-001';
    ```
*   **Step 2:** Truy vấn xem công đoạn ngay trước `VE08` trong cấu hình Route của PO đó là gì:
    ```sql
    SELECT RouteCode, RouteIndex 
    FROM STB_ProductionOrderRouting 
    WHERE PONo = (SELECT PONo FROM STB_SetInfo WHERE Barcode = 've260509-001')
    ORDER BY RouteIndex ASC;
    -- Kết quả xác định được công đoạn trước là 'VE07'
    ```
*   **Step 3:** Thực hiện chèn bản ghi lịch sử Routing giả lập cho trạm `VE07` bằng Transaction an toàn:
    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @CtrlNo NVARCHAR(50) = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 've260509-001');

        INSERT INTO STB_ProdRouteHist 
            (ControlNo, ProcSeq, RouteCode, LineCode, MachineCode, InQty, OutQty, JobDate, ShiftCode, CreateUserID, CreateDateTime)
        VALUES 
            (@CtrlNo, 
             (SELECT ISNULL(MAX(ProcSeq), 0) + 1 FROM STB_ProdRouteHist WHERE ControlNo = @CtrlNo), 
             'VE07',            -- Mã công đoạn trước VE08
             'MCVC20220',       -- Mã Line phát sinh
             'MCVC20220',       -- Mã máy
             20, 20,            -- Số lượng phế
             CAST(GETDATE() AS DATE), 'A', 
             'vinaadmin', GETDATE());

        COMMIT TRANSACTION;
        PRINT 'Đã chèn lịch sử giả lập thành công! Hãy bảo công nhân bấm Lưu (Save) lại trên giao diện HNC321.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
    ```
---

---

### Kịch bản sự cố khẩn cấp 4: Lỗi nhảy bước cân điện cực Mixing

### 4.7 LỖI NHẢY BƯỚC CÂN ĐIỆN CỰC MIXING (PHẦN MỀM electrode.weighing)

#### 🔴 Triệu chứng hiện trường:
"Các bước cân cứ nhảy không đúng thứ tự process nên không cân được", "Mã điện cực HCE đang lỗi chưa thao tác được, sản xuất ra mà không được ghi nhận trên hệ thống".

#### 🔍 Nguyên nhân gốc rễ:
*   Phần mềm có checkbox **"CA ĐÊM CHUẨN BỊ TRƯỚC"** (`isnight` trên UI). Khi tích vào ô này, phần mềm gọi SP `usp_GetElectroMixPresentStep_vietnam` và `usp_ElectrodeStep_get` (⚠️ tên thực tế trong DB) với tham số `@pOrder = 'kdem'` để đẩy Binder lên cân trước (vì cần thời gian khuấy sấy lâu).
*   Nếu ca ngày làm việc hoặc ca bình thường **quên bỏ tích checkbox này**, thứ tự process sẽ bị xáo trộn, bắt cân Binder trước rồi mới đến bột Than. Công nhân không thể cân lần lượt từ trên xuống theo quy trình chuẩn và bị báo lỗi nhảy bước.
*   Khi bước cân bị treo/chặn, mẻ trộn Mixing không thể chốt hoàn thành trên MES, dẫn đến bán thành phẩm (Slurry) sản xuất ra **không được ghi nhận trên hệ thống** (thiếu bản ghi trong `STB_ElectrodeMixInfo`). Khi sang công đoạn tiếp theo (Coating), quét mã Lot điện cực sẽ bị báo lỗi.

#### 🛠️ Kịch bản xử lý từng bước:

*   **Step 1 (Bypass vận hành):**
    Yêu cầu công nhân ca ngày **bỏ tích checkbox "CA ĐÊM CHUẨN BỊ TRƯỚC"** trên giao diện chính của phần mềm, sau đó bấm nút **"Làm mới màn hình"** để hệ thống sắp xếp lại thứ tự cân than trước.
*   **Step 2 (IT reset Lot bị kẹt):**
    Nếu Lot điện cực (Ví dụ: Lot của mã `HCE-202`) đã bị ghi nhận sai thứ tự và kẹt nửa chừng, IT chạy lệnh xóa dữ liệu cân tạm của Lot đó trong bảng `STB_ElectrodeMixStepInfo` để công nhân cân lại đúng thứ tự từ đầu:
    ```sql
    BEGIN TRANSACTION;
    DELETE FROM STB_ElectrodeMixStepInfo 
    WHERE ElectrodeLotNumber = 'Mã_Lot_Điện_Cực_HCE_Bị_Kẹt';
    COMMIT TRANSACTION;
    ```
    Sau đó chốt mẻ trộn bình thường để hệ thống tự động ghi nhận sản lượng Slurry, thông luồng cho Coating/Slitting tiếp theo.

---

---

### Kịch bản sự cố khẩn cấp 5: Điện cực 3582-600F CY không tạo được tem

### 4.8 ĐIỆN CỰC MÃ LIỆU 3582-600F CY KHÔNG TẠO ĐƯỢC TEM

#### 🔴 Triệu chứng hiện trường:
Khi sản xuất điện cực mã liệu `3582-600F CY`, hệ thống không cho tạo hoặc in tem điện cực.

#### 🔍 Nguyên nhân gốc rễ:
*   Mã điện cực `3582-600F CY` là mã model/sản phẩm mới chưa được khai báo đầy đủ cấu hình trong Master Data.
*   Đặc biệt, trạm cắt điện cực Slitting (B552) yêu cầu phải có cấu hình quy cách Slitting trong bảng **`stb_slittinglocationconfig_vvt`** mới cho phép in tem.

#### 🛠️ Kịch bản xử lý từng bước:

*   **Step 1:** Thêm cấu hình quy cách Slitting cho model `3582` (cả cực dương `BY` và cực âm `YP`):
    ```sql
    BEGIN TRANSACTION;
    INSERT INTO stb_slittinglocationconfig_vvt
        (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse, RollQty, PositiveLocation, NegativeLocation)
    VALUES
        ('3582', 'BY', '200', '600', '39.34', 'VVT_F2', 'kho2', 20, 'A6-T3', 'B6-T3'),
        ('3582', 'YP', '180', '600', '39.34', 'VVT_F2', 'kho2', 20, 'A6-T3', 'B6-T3');
    COMMIT TRANSACTION;
    ```
*   **Step 2:** Kiểm tra và đảm bảo đã khai báo model `3582-600F CY` vào bảng `STB_ModelBasicInfo` (A410) đầy đủ thông số Vol/Farad (Vol = '3R0', Farad = '600.0') để các trạm QC và kho nhận diện được đúng:
    ```sql
    SELECT * FROM STB_ModelBasicInfo WHERE ModelCode = '3582-600F CY';
    -- Nếu thiếu, thực hiện chèn dữ liệu (Xem chi tiết tại KB_06 § 1.1)
    ```

---

