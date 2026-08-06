<!--
AI-READY METADATA
Purpose: Sổ tay các kịch bản lỗi & hướng dẫn khắc phục phân hệ Hưng Yên & VinaEnesol (Dry Oven, Doping JIG, D000, D051, D100, D110)
Scope: Hung Yen & VinaEnesol Screen Bug Fixbook
Single Source of Truth: KB_07_03_SCREEN_BUGS.md (Hung Yen Bug Fixes)
Target Screens: Dry Oven, Doping JIG, D000, D051, D100, D110
Target Tables: STB_VN_DryOver, STB_VVT_DopingJIG, STB_VINAEnesolBoxLabelPrintHist, STB_MaterialCodeByCustomer
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)
  - [KB_07_01_OVERVIEW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md)
-->

# KB_07_03 — Hung Yen & VinaEnesol Screen Bugs & Fixes

> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#5-danh-sách-lỗi-logic-điểm-yếu--giải-pháp-bugs--troubleshooting).

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
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md#5-danh-sách-lỗi-logic-điểm-yếu--giải-pháp-bugs--troubleshooting).

---


## [D000] — VinaEnesol Management Menu (Menu quản lý VinaEnesol)

### [D000] — Lỗi 1: Không truy cập được menu VinaEnesol
*   **Triệu chứng:** Người dùng không thấy menu VinaEnesol trên giao diện MES.
*   **Nguyên nhân gốc:** Menu D000 chưa được phân quyền cho Role của người dùng tại Z220/Z330.
*   **Cách khắc phục:** Vào Z220 gán Screen D000 cho Role tương ứng, vào Z330 kiểm tra đã publish.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_07/KB_07_01_OVERVIEW.md § 2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md) và [file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_10_FACTORY_WORKCENTER_MATRIX.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_10_FACTORY_WORKCENTER_MATRIX.md) § 1.

---


## [D051] — Customer Part No Info (Mã vật tư khách hàng Enesol)

### Lỗi 1: Mã sản phẩm khách hàng không mapping được với mã nội bộ
*   **Triệu chứng:** Khi in tem Enesol, mã khách hàng (CustomerPartNo) hiện trống hoặc sai.
*   **Nguyên nhân gốc:** Bảng `STB_MaterialCodeByCustomer` chưa có mapping giữa `MaterialCode` nội bộ và `MaterialCodeCustomer`.
*   **Cách khắc phục:** Vào D051 thêm mapping mã vật tư nội bộ ↔ mã khách hàng Enesol.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_07/KB_07_01_OVERVIEW.md § 2.2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md).

---


## [D100] — Enesol Box Label Print (In tem hộp Enesol)

### Lỗi 1: Không in được tem hộp Enesol (Inner/Outer Box)
*   **Triệu chứng:** Bấm in tem tại D100 nhưng máy in không chạy hoặc tem trống.
*   **Nguyên nhân gốc:** Chưa thiết lập D051 (mapping mã khách hàng) hoặc chưa chọn đúng LabelClassCode (1=Inner, 2=Outer).
*   **Cách khắc phục:** Kiểm tra D051 đã mapping, chọn đúng loại tem (Inner/Outer) và đảm bảo máy in kết nối.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_07/KB_07_01_OVERVIEW.md § 4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md).

---


## [D110] — Enesol Box Label History (Lịch sử in tem Enesol)

### Lỗi 1: Lịch sử in tem Enesol hiện thiếu hoặc trùng dữ liệu
*   **Triệu chứng:** Bảng lịch sử D110 hiển thị thiếu bản ghi hoặc có bản ghi trùng lặp.
*   **Nguyên nhân gốc:** Bảng `STB_VINAEnesolBoxLabelPrintHist` bị lỗi khi tạo SerialNo tự tăng hoặc trùng LotNo.
*   **Cách khắc phục:** Kiểm tra trực tiếp DB, xóa bản ghi trùng nếu có.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_07/KB_07_01_OVERVIEW.md § 4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md).

---

## [HY530] — Route Process Input HY (Chốt sản lượng công đoạn Hưng Yên)

### Lỗi 1: Bị chặn do Gate Time Aging (`STB_DetailAgingHY`)
*   **Triệu chứng:** Khi chốt sản lượng tại `HY530`, hệ thống văng popup thông báo: *"Chưa đủ thời gian Aging lão hóa theo quy định"*.
*   **Nguyên nhân gốc:** Stored Procedure `usp_DoProcessProdRouteHist_HY` kiểm tra bảng `STB_DetailAgingHY`. Nếu khoảng cách giữa thời gian chốt công đoạn trước và công đoạn hiện tại nhỏ hơn thời gian Aging chuẩn (ví dụ 24 giờ cho công đoạn Aging BTP Hưng Yên), SP sẽ chặn lại.
*   **Cách khắc phục:** 
    1. Yêu cầu công nhân chờ đủ thời gian Aging quy định.
    2. Trong trường hợp khẩn cấp có sự đồng ý của QA, IT thực hiện lùi thời gian chốt ở công đoạn trước trong `STB_ProdRouteHist`:
    ```sql
    UPDATE STB_ProdRouteHist 
    SET CreateDateTime = DATEADD(HOUR, -25, GETDATE()) 
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE')
      AND RouteCode = 'MÃ_CÔNG_ĐOẠN_TRƯỚC';
    ```

---

## [HY540] — Process Material Scan HY (Quét NVL thô Assy Card Hưng Yên)

### Lỗi 1: Không lưu được NVL do thiếu 4 cột thuộc tính màu
*   **Triệu chứng:** OP quét Barcode NVL tại `HY540` nhưng không cho lưu, báo thiếu thông tin thuộc tính NVL.
*   **Nguyên nhân gốc:** Màn hình `HY540` yêu cầu nhập đầy đủ 4 cột màu bắt buộc (nhiệt độ, thời gian, lô sản xuất) trước khi lưu.
*   **Cách khắc phục:** Hướng dẫn OP điền đầy đủ các ô có màu nền đặc biệt trên grid trước khi nhấn Save.

---

## [HY311] — PO Electrode HY (Lập PO Điện cực Hưng Yên)

### Lỗi 1: Không tạo được PO Điện cực do thiếu cờ Material Type
*   **Triệu chứng:** Khi tạo PO tại `HY311` cho mã điện cực Hưng Yên, danh sách vật tư bị trống không chọn được.
*   **Nguyên nhân gốc:** Mã vật tư điện cực tại `A230` chưa được phân loại `MaterialType = 'EROH'` hoặc chưa tích chọn `Internal Production`.
*   **Cách khắc phục:** Vào `A230`, tìm mã vật tư điện cực, chọn `Material Type = EROH` và tick chọn cờ **Sản xuất nội bộ** (Internal Production).

---




