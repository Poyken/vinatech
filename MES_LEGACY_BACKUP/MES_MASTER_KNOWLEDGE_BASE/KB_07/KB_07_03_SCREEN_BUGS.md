<!--
AI-READY METADATA
Purpose: Sổ tay cứu hộ sự cố & kịch bản fix bug phân hệ Hưng Yên & VinaEnesol (HY103, HY141-HYFG01, D000, D051, D100, D110, Dry Oven, Doping JIG)
Scope: Hung Yen & VinaEnesol Screen Bug Fixbook & Emergency Recipes
Single Source of Truth: KB_07_03_SCREEN_BUGS.md (Hung Yen Bug Fixes)
Target Screens: HY103, HY141, HY143, HY151, HY220, HY311, HY312, HY330, HY430, HY431, HY443, HY530, HY540, HY541, HY620, HY740, HYFG01, D000, D051, D100, D110, Dry Oven, Doping JIG
Target Tables: STB_VN_DryOver, STB_VVT_DopingJIG, STB_DetailAgingHY, STB_VINAEnesolBoxLabelPrintHist, STB_MaterialCodeByCustomer, STB_VN_FINISHGOODS_HY
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)
  - [KB_07_01_OVERVIEW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md)
  - [KB_07_02_DEPLOY_HY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md)
-->

# KB_07_03 — Hưng Yên & VinaEnesol Screen Bug Fixbook

> **Mục đích:** Tra cứu và xử lý sự cố khẩn cấp trên các màn hình nhà máy Hưng Yên (`VVT_F5`) và phân hệ Enesol (`D000` Menu).  
> ← [Về Master Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)

---

## 1. 🏭 Sổ Tay Sửa Lỗi Các Màn Hình Hưng Yên (`HY` Prefix)

### [HY530] — Route Process Input HY (Chốt sản lượng công đoạn Hưng Yên)

#### 🔴 Lỗi 1: Bị chặn do Gate Time Aging (`STB_DetailAgingHY`)
*   **Triệu chứng:** Khi chốt sản lượng tại `HY530`, hệ thống văng popup thông báo: *"Chưa đủ thời gian Aging lão hóa theo quy định"*.
*   **Nguyên nhân gốc:** SP `usp_DoProcessProdRouteHist_HY` kiểm tra bảng `STB_DetailAgingHY`. Nếu khoảng cách giữa thời gian chốt công đoạn trước và công đoạn hiện tại nhỏ hơn thời gian Aging chuẩn (24 giờ cho công đoạn Aging BTP Hưng Yên), SP sẽ chặn lại.
*   **Cách khắc phục:**
    ```sql
    BEGIN TRANSACTION;
    -- Lùi thời gian chốt công đoạn trước về 25 giờ trước để thông luồng Gate Aging
    UPDATE STB_ProdRouteHist 
    SET CreateDateTime = DATEADD(HOUR, -25, GETDATE()) 
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE_HƯNG_YÊN')
      AND RouteCode = 'MÃ_CÔNG_ĐOẠN_TRƯỚC';
    ROLLBACK TRANSACTION; -- Đổi thành COMMIT TRANSACTION khi chạy trên SSMS
    ```

#### 🔴 Lỗi 2: Nút "Nhập lỗi" bị ẩn/mờ (Disabled) trên `HY530`
*   **Triệu chứng:** Công nhân không bấm được nút "Nhập lỗi" tại `HY530` để khai báo phế NG ở công đoạn Hưng Yên.
*   **Nguyên nhân gốc:** Công đoạn tiếp theo đã được quét chốt sản lượng (`IsHasNextProd = 1`). Biểu thức Expression của giao diện: `!IsHasNextProd && !IsLoss` trả về `FALSE`.
*   **Cách khắc phục (Script Rollback công đoạn sau):**
    ```sql
    BEGIN TRANSACTION;
    -- 1. Xóa phế NG công đoạn sau (FindRouteCode)
    DELETE FROM STB_DefectRepairInfo 
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE')
      AND FindRouteCode IN ('MÃ_CÔNG_ĐOẠN_SAU');

    -- 2. Xóa lịch sử routing công đoạn sau (RouteCode)
    DELETE FROM STB_ProdRouteHist 
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE')
      AND RouteCode IN ('MÃ_CÔNG_ĐOẠN_SAU');

    -- 3. Reset cờ hoàn thành công đoạn hiện tại: CompleteRoute = NULL
    UPDATE STB_ProdRouteHist
    SET CompleteRoute = NULL
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE')
      AND RouteCode = 'MÃ_CÔNG_ĐOẠN_HIỆN_TẠI';
    ROLLBACK TRANSACTION;
    ```

#### 🔴 Lỗi 3: Hủy kết quả sản xuất Lot để gộp Lot & in lại tem (`HY530` / `B523` / `HY620`)
*   **Triệu chứng:** Lot sản xuất (ví dụ `SP260807-003`, `SP260807-006`) lỡ chốt công đoạn sau (`VE08`, `VE09`, `VE10`), khiến công nhân không gộp được Lot hoặc không in lại được tem tại `B523` / `HY620`.
*   **Nguyên nhân gốc:** Bản ghi routing `STB_ProdRouteHist` của các bước sau đã được sinh ra và cờ `CompleteRoute` công đoạn trước bị chốt ➔ Ứng dụng B523 kiểm tra cờ `IsHasNextProd = 1` nên chặn thao tác gộp/sửa Lot.
*   **Cách khắc phục (Script Rollback & Reset Packing):**
    ```sql
    BEGIN TRANSACTION;
    -- 1. Xóa phế NG các công đoạn thừa sau
    DELETE FROM STB_DefectRepairInfo 
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE_HƯNG_YÊN') 
      AND FindRouteCode IN ('MÃ_CÔNG_ĐOẠN_SAU_1', 'MÃ_CÔNG_ĐOẠN_SAU_2');

    -- 2. Xóa lịch sử routing các công đoạn chốt thừa
    DELETE FROM STB_ProdRouteHist 
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE_HƯNG_YÊN') 
      AND RouteCode IN ('MÃ_CÔNG_ĐOẠN_SAU_1', 'MÃ_CÔNG_ĐOẠN_SAU_2');

    -- 3. Reset cờ CompleteRoute công đoạn cần làm lại về NULL
    UPDATE STB_ProdRouteHist 
    SET CompleteRoute = NULL 
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE_HƯNG_YÊN') 
      AND RouteCode = 'MÃ_CÔNG_ĐOẠN_HIỆN_TẠI';

    -- 4. Xóa thông tin đóng gói tạm nếu có trong STB_DividePackaging & STB_SavePackingTime_VVT
    DELETE FROM STB_DividePackaging WHERE LotNo = 'MÃ_BARCODE_HƯNG_YÊN';
    DELETE FROM STB_SavePackingTime_VVT WHERE LotNo = 'MÃ_BARCODE_HƯNG_YÊN';
    ROLLBACK TRANSACTION; -- Đổi thành COMMIT TRANSACTION khi chạy thực tế
    ```

---

### [HY540] — Process Material Scan HY (Quét NVL thô Assy Card Hưng Yên)

#### 🔴 Lỗi 1: Không lưu được NVL do thiếu 4 cột thuộc tính màu
*   **Triệu chứng:** OP quét Barcode NVL tại `HY540` nhưng hệ thống báo lỗi không cho lưu.
*   **Nguyên nhân gốc:** `HY540` yêu cầu nhập đầy đủ 4 cột thuộc tính màu bắt buộc (nhiệt độ, thời gian sấy, lô sản xuất) trước khi lưu.
*   **Cách khắc phục:** Hướng dẫn OP điền đầy đủ các ô có màu nền đặc biệt trên lưới trước khi nhấn Save.

---

### [HY311] — PO Electrode HY (Lập PO Điện cực Hưng Yên)

#### 🔴 Lỗi 1: Không tạo được PO Điện cực do thiếu cờ Material Type
*   **Triệu chứng:** Khi tạo PO tại `HY311` cho mã điện cực Hưng Yên, danh sách vật tư bị trống không chọn được.
*   **Nguyên nhân gốc:** Mã vật tư điện cực tại `A230` chưa được phân loại `MaterialType = 'EROH'` hoặc chưa tích chọn `Internal Production`.
*   **Cách khắc phục:** Vào `A230`, tìm mã vật tư điện cực, chọn `Material Type = EROH` và tick chọn cờ **Sản xuất nội bộ** (Internal Production).

---

### [HY430]/[HY431] — Material Issue & Receive Confirm (Xuất/Nhận NVL Hưng Yên)

#### 🔴 Lỗi 1: Chuyền Hưng Yên không nhận được NVL xuất từ kho `ROH_HY_WH`
*   **Triệu chứng:** Thủ kho đã làm phiếu xuất tại `HY430` nhưng công nhân chuyền mở `HY431` không thấy lô NVL để xác nhận.
*   **Nguyên nhân gốc:** Mã Line sản xuất `VVHYC-*` chưa được gán mã kho `MaterialWarehouseCode = 'ROH_HY_WH'` trong bảng `STB_LineInfo`.
*   **Cách khắc phục:**
    ```sql
    BEGIN TRANSACTION;
    UPDATE STB_LineInfo 
    SET MaterialWarehouseCode = 'ROH_HY_WH' 
    WHERE LineCode LIKE 'VVHYC%' AND (MaterialWarehouseCode IS NULL OR MaterialWarehouseCode <> 'ROH_HY_WH');
    ROLLBACK TRANSACTION;
    ```

---

### [HYFG01] — Finished Goods WH HY (Kho Thành Phẩm Hưng Yên)

#### 🔴 Lỗi 1: Thùng hàng đóng gói xong không hiển thị trên kho `HYFG01`
*   **Triệu chứng:** Công nhân đóng gói xong tại `HY523`/`B523` nhưng thủ kho mở `HYFG01` tìm không thấy barcode thùng.
*   **Nguyên nhân gốc:** Thùng hàng chưa được lưu cờ PackingQty hoặc bảng `STB_VN_FINISHGOODS_HY` bị thiếu bản ghi nhập kho.
*   **Cách khắc phục:**
    ```sql
    BEGIN TRANSACTION;
    -- Kiểm tra và chèn bổ sung vào kho thành phẩm Hưng Yên
    IF NOT EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_HY WHERE Barcode = 'MÃ_BARCODE_THÙNG')
    BEGIN
        INSERT INTO STB_VN_FINISHGOODS_HY (Barcode, MaterialCode, Quantity, LocationCode, CreateDateTime)
        SELECT Barcode, MaterialCode, ProdQty, 'FGT_HY_WH_01', GETDATE()
        FROM STB_SetInfo WITH(NOLOCK)
        WHERE Barcode = 'MÃ_BARCODE_THÙNG';
    END
    ROLLBACK TRANSACTION;
    ```

---

## 2. 📦 Sổ Tay Sửa Lỗi Phân Hệ Đóng Gói VinaEnesol (`D000` Menu)

### [D051] — Customer Part No Info (Mã vật tư khách hàng Enesol)

#### 🔴 Lỗi 1: Mã sản phẩm khách hàng không hiển thị khi in tem nhãn D100
*   **Triệu chứng:** Khi in tem Enesol tại `D100`, ô Customer Part No bị trống.
*   **Nguyên nhân gốc:** Bảng `STB_MaterialCodeByCustomer` chưa được khai báo mapping giữa mã nội bộ và mã khách hàng.
*   **Cách khắc phục:** vào `D051` thêm dòng mapping hoặc chạy SQL:
    ```sql
    BEGIN TRANSACTION;
    INSERT INTO STB_MaterialCodeByCustomer (CustomerCode, MaterialCodeCustomer, MaterialCode, ShortMaterialCode)
    VALUES ('1125', 'VENDOR_PN_KHÁCH_HÀNG', 'MÃ_MES_NỘI_BỘ', 'SHORT_CODE');
    ROLLBACK TRANSACTION;
    ```

---

### [D100]/[D110] — Enesol Box Label Print & History (In & Lịch Sử Tem Enesol)

#### 🔴 Lỗi 1: Lỗi không ghép được Hộp Nhỏ vào Hộp Lớn (Box Matching Fail)
*   **Triệu chứng:** Khi in tem Outer Box (`LabelClassCode = '2'`), hệ thống báo lỗi không ghép được danh sách Inner Box.
*   **Nguyên nhân gốc:** Chuỗi `SmallBoxList` chứa Barcode Inner Box chưa từng được in tem tại `D100` (`LabelClassCode = '1'`).
*   **Cách khắc phục:** Kiểm tra bảng `STB_VINAEnesolBoxLabelPrintHist` xem các Inner Box đã có cờ `LabelClassCode = '1'` chưa trước khi thực hiện ghép vào Outer Box.

---

## 3. 🌡️ Sửa Lỗi Thiết Bị Sấy & Lão Hóa Hưng Yên

### Dry Oven — Lò sấy điện cực

#### 🔴 Lỗi 1: Lỗi toán tử SQL bypass kiểm tra V-22
*   **Triệu chứng:** Quét đưa Lot vào lò sấy tự do dù chưa hoàn thành công đoạn `V-22`.
*   **Cách khắc phục:** Cập nhật SP `usp_VN_DryOver`, bọc ngoặc đơn Gom điều kiện `OR`:
    ```sql
    SELECT @Stg = routecode FROM STB_ProdRouteHist WITH(NOLOCK)
    WHERE 1=1 
      AND (routecode='V-22' OR routecode='V-22_BG' OR routecode='VE01') -- Thêm ngoặc đơn
      AND controlno = (SELECT controlno FROM stb_setinfo WITH(NOLOCK) WHERE barcode = @BarCode)
    ```

### Doping JIG — Gá nạp Doping Hưng Yên

#### 🔴 Lỗi 1: Mất dữ liệu log khi tự động ngắt JIG (`autoend`)
*   **Triệu chứng:** Khi JIG tự ngắt sau 6 giờ, thông tin lượt chạy biến mất khỏi `Stb_VVT_DopingJIG_History`.
*   **Nguyên nhân gốc:** Lỗi so sánh thời gian `ChangeDateTime > dateadd(second,5,getdate())` trong `usp_Vietnam_DopingJIG_uid`.
*   **Cách khắc phục:** Sửa điều kiện thành `dateadd(second,-5,getdate())`.
