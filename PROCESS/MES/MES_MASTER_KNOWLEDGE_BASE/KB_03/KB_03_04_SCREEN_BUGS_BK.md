## [B220] — Route Group Setup (Thiết lập nhóm Route)

> 🔗 **Xem thêm:** Mục [B210 / B220 / B230 / B240](#b210--b220--b230--b240--production-routing-setup) phía trên đã có chi tiết lỗi thiết lập Line/Route.

### Lỗi 1: Nhóm Route không hiển thị đúng công đoạn khi cấu hình sản xuất
*   **Triệu chứng:** Khi lập PO tại B310, danh sách công đoạn bị thiếu hoặc sai thứ tự.
*   **Nguyên nhân gốc:** Nhóm Route chưa được cấu hình đúng tại B220.
*   **Cách khắc phục:** Vào B220 kiểm tra Route Group, đảm bảo các RouteCode được gán đúng thứ tự.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](../KB_06_MASTER_DATA_TOOLS.md) và [../KB_07/KB_07_01_OVERVIEW.md](../KB_07/KB_07_01_OVERVIEW.md).

---


## [B230] — Machine Route Mapping (Ánh xạ máy - Route)

> 🔗 **Xem thêm:** Mục [B210 / B220 / B230 / B240](#b210--b220--b230--b240--production-routing-setup) phía trên.

### [B230]/[B270] — Lỗi 1: Dùng thay thế khi bị lỗi popup
*   **Triệu chứng:** B270 bị lỗi popup trống không hiển thị danh sách máy. Cần cách thay thế.
*   **Nguyên nhân gốc:** SP `usp_Set_VVT_Info_get` bị hardcode Whitelist UserID tại B270.
*   **Cách khắc phục:** Sử dụng B230 để gán máy vào Route khi B270 gặp sự cố. B230 có giao diện tương tự nhưng không qua SP bị whitelist.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_AND_SCREENS.md § 1.3](../KB_01_UI_AND_SCREENS.md) và [../KB_07/KB_07_01_OVERVIEW.md](../KB_07/KB_07_01_OVERVIEW.md).

---


## [B240] — Machine Master Setup (Thiết lập máy theo công đoạn)

> 🔗 **Xem thêm:** Mục [B210 / B220 / B230 / B240](#b210--b220--b230--b240--production-routing-setup) phía trên.

### [B530] — Lỗi 1: không hiển thị máy trong dropdown khi chốt sản lượng
*   **Triệu chứng:** OP quét chốt sản lượng tại B530 nhưng không thấy máy trong danh sách chọn.
*   **Nguyên nhân gốc:** Máy chưa được gán vào Route đang chạy tại B240.
*   **Cách khắc phục:** Vào B240, chọn máy và gán vào RouteCode tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 10](../KB_06_MASTER_DATA_TOOLS.md).

---


## [B270] — Product Machine Mapping (Ánh xạ máy - sản phẩm)

> 🔗 **Xem thêm:** Mục [B250 / B270](#b250--b270--cell--machine-mapping) phía trên đã có chi tiết lỗi popup trống và thêm Cell/Line mới.



## [B301] — Production Order Info (Thông tin lệnh sản xuất chi tiết)

### [B301]/[B310] — Lỗi 1: Dữ liệu PO bị lệch giữa và
*   **Triệu chứng:** Thông tin chi tiết PO tại B301 không khớp với tổng quan tại B310.
*   **Nguyên nhân gốc:** Bảng `STB_ProductionOrderInfo` có dữ liệu không nhất quán do đồng bộ lỗi từ Groupware.
*   **Cách khắc phục:** Kiểm tra dữ liệu trực tiếp trong DB và đồng bộ lại từ Groupware ESM Bridge.
*   **Chi tiết nghiệp vụ:** Xem tại ../KB_19/KB_19_01_ARCHITECTURE.md.

---


## [B450] — Day Production Plan (Kế hoạch sản xuất ngày)

> 🔗 **Xem thêm:** Mục [B310 / B450](#b310--b450--production-orders--day-plan) phía trên đã có chi tiết lỗi đồng bộ PO.

### Lỗi 1: Không tạo được Lot do chưa tích cờ IsFixed
*   **Triệu chứng:** OP lập kế hoạch ngày tại B450, bấm tạo Lot nhưng hệ thống không sinh được Lot.
*   **Nguyên nhân gốc:** Cột `IsFixed` trong `STB_DayProdPlan` chưa được tích chọn (= 0).
*   **Cách khắc phục:** Vào B450, tìm dòng kế hoạch ngày tương ứng, tick chọn cột `IsFixed` rồi nhấn Lưu. Sau đó bấm tạo Lot.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 2](../KB_03/KB_03_02_CELL_LINE.md).

### [B310]/[B450] — Lỗi 2: Xóa PO phải xóa đồng thời ở và
*   **Triệu chứng:** Xóa PO tại B310 nhưng dữ liệu kế hoạch ngày vẫn còn tại B450 gây lỗi trùng.
*   **Nguyên nhân gốc:** Xóa PO cần xóa cả 3 bảng: `STB_ProductionOrderInfo`, `STB_ProductionOrderBom`, `STB_ProductionOrderRouting` (B310) VÀ `STB_DayProdPlan`, `STB_SetInfo` (B450).
*   **Cách khắc phục:** Xóa PO theo quy trình đầy đủ 5 bảng.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5.7](../KB_03/KB_03_02_CELL_LINE.md).

---


## [B453] — Production Schedule (Lịch trình sản xuất)

### Lỗi 1: Lịch trình sản xuất không hiển thị dữ liệu sau khi tạo Lot
*   **Triệu chứng:** Sau khi tạo Lot tại B450, mở B453 nhưng không thấy lịch trình sản xuất tương ứng.
*   **Nguyên nhân gốc:** B453 hiển thị dựa trên dữ liệu `STB_SetInfo` kết hợp `STB_DayProdPlan`. Nếu `InputJobDate` bị NULL hoặc `IsFixed = 0` thì lịch trình không hiển thị.
*   **Cách khắc phục:** Kiểm tra B450 đã tích `IsFixed` và Lot đã được tạo thành công.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 2](../KB_03/KB_03_02_CELL_LINE.md) và [../KB_04/KB_04_01_CORE_PACKAGING.md](../KB_04/KB_04_01_CORE_PACKAGING.md).

---


## [B460] — Production Line Status (Trạng thái Line sản xuất)

### Lỗi 1: Trạng thái Line không cập nhật real-time
*   **Triệu chứng:** Màn hình B460 hiển thị trạng thái Line sản xuất bị delay hoặc không chính xác.
*   **Nguyên nhân gốc:** Dữ liệu lấy từ bảng `STB_SetInfo` kết hợp `STB_ProdRouteHist` có thể bị delay do cache hoặc lỗi refresh.
*   **Cách khắc phục:** Nhấn nút Refresh/Tìm kiếm lại. Nếu vẫn sai, kiểm tra trực tiếp bảng `STB_ProdRouteHist` xem công đoạn đã được ghi nhận chưa.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6](../KB_03/KB_03_02_CELL_LINE.md) và [../KB_07/KB_07_01_OVERVIEW.md](../KB_07/KB_07_01_OVERVIEW.md).

---


## [B470] — Electrode Line Status (Trạng thái Line điện cực)

### Lỗi 1: Trạng thái Line điện cực không hiển thị hoặc không chính xác
*   **Triệu chứng:** B470 không hiện dữ liệu Line điện cực hoặc hiện sai công đoạn đang chạy.
*   **Nguyên nhân gốc:** Dữ liệu điện cực lưu ở bảng riêng (`STB_ElectrodeCoatingInfo`, `STB_ElectrodeSlittingResult`). Nếu Line điện cực chưa được cấu hình Route tương ứng thì B470 sẽ trống.
*   **Cách khắc phục:** Kiểm tra cấu hình Route điện cực tại B220 và mapping máy tại B270.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md § 8](../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md) và [../KB_07/KB_07_01_OVERVIEW.md](../KB_07/KB_07_01_OVERVIEW.md).

---


## [B528] — Barrel Barcode (In tem thùng phuy/Barrel)

### Lỗi 1: Lỗi in tem Barrel hoặc không sinh được mã Barcode Barrel
*   **Triệu chứng:** Bấm in tem thùng Barrel tại B528 bị lỗi hoặc barcode không hiển thị.
*   **Nguyên nhân gốc:** Cấu hình Barrel chưa được khai báo trong bảng cấu hình sản phẩm, hoặc chưa có template tem Barrel tại Z530/A460.
*   **Cách khắc phục:** Kiểm tra cấu hình template tem Barrel tại Z530, mapping tại A460, và đảm bảo Lot đã hoàn thành đóng gói tại B523.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.10](../KB_03/KB_03_02_CELL_LINE.md).

---


## [B540] — Process Input V22→V28 (Nhập NVL theo công đoạn)

### Lỗi 1: Không nhập được NVL do thiếu 4 cột màu bắt buộc
*   **Triệu chứng:** OP quét nhập NVL tại B540 nhưng hệ thống không cho lưu, báo thiếu thông tin bắt buộc.
*   **Nguyên nhân gốc:** 4 cột màu đặc biệt trên lưới B540 phải được nhập đầy đủ trước khi in barcode. Đây là requirement cứng trong SP `usp_Vietnam_RawMaterialInputHist_uid`.
*   **Cách khắc phục:** Hướng dẫn OP nhập đầy đủ 4 cột màu (hiển thị nền vàng/cam trên grid). Nếu vẫn lỗi, kiểm tra `STB_MaterialLotInfo` xem Lot NVL có tồn tại không.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.4](../KB_03/KB_03_02_CELL_LINE.md) và ../KB_14/KB_14_01_METHODOLOGY.md.

### Lỗi 2: Checkbox ProdQtyFinishYN không tích được
*   **Triệu chứng:** OP muốn hoàn thành công đoạn nhưng không tích được checkbox `ProdQtyFinishYN`.
*   **Nguyên nhân gốc:** Hệ thống tự động tích `ProdQtyFinishYN` khi chốt sản lượng ở B530, không cho tích trực tiếp.
*   **Cách khắc phục:** OP cần chốt sản lượng tại B530 trước, hệ thống sẽ tự tích checkbox.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 2](../KB_03/KB_03_02_CELL_LINE.md).

---


## [B726] — Scrap After Production (Báo phế sau sản xuất)

### Lỗi 1: Báo phế không thành công hoặc bản ghi phế không hiển thị
*   **Triệu chứng:** OP thực hiện báo phế sản phẩm sau sản xuất tại B726 nhưng hệ thống không ghi nhận hoặc dữ liệu không hiển thị.
*   **Nguyên nhân gốc:** SP `usp_vn_scrapafterproduction` thực hiện xóa mềm (`IsDeleted = 1`), nếu Lot đã bị đánh dấu xóa trước đó thì không tạo được bản ghi phế mới.
*   **Cách khắc phục:** Kiểm tra bảng `STB_VN_SCRAP_AFTERPRODUCTIONS` xem Lot đã tồn tại chưa. Nếu cần xóa lại: `UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS SET IsDeleted = 0 WHERE LotNo = 'MÃ_LOT'`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6](../KB_03/KB_03_02_CELL_LINE.md).

---


## [B733] — Box Matching Report (Báo cáo gộp Box)

### [B733] — Lỗi 1: Báo cáo hiển thị trống không có dữ liệu
*   **Triệu chứng:** Mở B733 tìm kiếm Lot nhưng không hiện kết quả gộp Box nào.
*   **Nguyên nhân gốc:** Lot đó chưa được gộp Box tại B523 (chưa hoàn thành đóng gói).
*   **Cách khắc phục:** Kiểm tra B523 xem Lot đã được gộp Box chưa. Nếu chưa, thực hiện gộp Box trước rồi quay lại B733.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.5](../KB_03/KB_03_02_CELL_LINE.md).

---


## [B755] — PAC Inner Label (In tem nhãn trong PAC)

> 🔗 **Xem thêm:** Mục [B754 / B756](#b754--b756--pac-customer-labels) phía trên đã có chi tiết lỗi in tem PAC.

### Lỗi 1: In tem Inner Label PAC bị thiếu Serial hoặc thông tin sai
*   **Triệu chứng:** Tem trong (Inner Label) PAC in ra thiếu Serial hoặc trọng lượng không đúng.
*   **Nguyên nhân gốc:** Nhầm lẫn giữa nhãn trong (Inner) và nhãn ngoài (Outer). Serial nhãn trong và ngoài chạy độc lập.
*   **Cách khắc phục:** Đảm bảo chọn đúng loại tem (Inner). Không tick `IsOuter` khi in nhãn trong.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.9.1](../KB_04/KB_04_01_CORE_PACKAGING.md).

---


## [B756] — PAC Outer Label (In tem nhãn ngoài PAC)

> 🔗 **Xem thêm:** Mục [B754 / B756](#b754--b756--pac-customer-labels) phía trên đã có chi tiết lỗi in tem PAC Outer.

### Lỗi 1: Tem thùng Outer Label PAC không hiển thị Serial hoặc cân nặng
*   **Triệu chứng:** In tem thùng lớn B756 thiếu Serial nhãn hoặc không hiện trọng lượng.
*   **Nguyên nhân gốc:** Chưa tick `IsOuter = 1` khi in nhãn ngoài, hoặc chưa bật `IsWeightLabel`.
*   **Cách khắc phục:** Tick `IsOuter` cho nhãn ngoài. Tick `IsWeightLabel` cho tem cân nặng.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.9.1](../KB_04/KB_04_01_CORE_PACKAGING.md) và ../KB_14/KB_14_01_METHODOLOGY.md.

---


## [B758] — Digi-Key Mixed Load Label (In tem hàng hỗn hợp Digi-Key)

> 🔗 **Xem thêm:** Mục [B757 / B758](#b757--b758--digi-key-customer-labels) phía trên đã có chi tiết lỗi in tem Digi-Key.

### [B758] — Lỗi 1: Không in được tem Mixed Load tại
*   **Triệu chứng:** In tem thùng hàng hỗn hợp (Mixed Load) Digi-Key bị lỗi.
*   **Nguyên nhân gốc:** Thùng chứa nhiều model/size khác nhau, SP cần kiểm tra tất cả barcode trong thùng khớp.
*   **Cách khắc phục:** Đảm bảo tất cả barcode trong thùng đã được gộp box tại B523 và thông tin PO đầy đủ.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.9.2](../KB_04/KB_04_01_CORE_PACKAGING.md).

---


## [B767] — Customer Label Print (In tem nhãn khách hàng chung)

### Lỗi 1: Không in được tem cho khách hàng mới
*   **Triệu chứng:** Khi in tem cho khách hàng mới tại B767, hệ thống báo lỗi không tìm thấy mẫu tem.
*   **Nguyên nhân gốc:** Chưa tạo mẫu tem tại Z530 và chưa mapping tại A460.
*   **Cách khắc phục:** Tạo mẫu tem mới tại Z530, approve layout, sau đó mapping model vào mẫu tem tại A460.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_04/KB_04_01_CORE_PACKAGING.md § 6.16](../KB_04/KB_04_01_CORE_PACKAGING.md).

---


## [B782] — Lot Routing History (Lịch sử Routing theo Lot)

### [B782] — Lỗi 1: Sai ngày sản xuất (JobDate) trên báo cáo
*   **Triệu chứng:** Barcode hiển thị sai ngày sản xuất trên lịch sử Routing.
*   **Nguyên nhân gốc:** Cột `JobDate` trong `STB_ProdRouteHist` bị ghi nhận sai do OP chốt sản lượng không đúng ca.
*   **Cách khắc phục:**
    ```sql
    UPDATE STB_ProdRouteHist SET JobDate = 'NGÀY_ĐÚNG'
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE')
    AND RouteCode = 'MÃ_CÔNG_ĐOẠN';
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5.2](../KB_03/KB_03_02_CELL_LINE.md).

---


## [B786] — ESR History (Lịch sử ESR toàn nhà máy)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên.

### Lỗi 1: Tab Online báo Status khác OK hoặc không lấy được data ESR
*   **Triệu chứng:** Tab Online tại B786 hiển thị Status Error, dữ liệu ESR không cập nhật.
*   **Nguyên nhân gốc:** Phần mềm đo ESR tại máy bị mất kết nối hoặc chưa upload kết quả vào bảng `Stb_ESRValueMonitor`.
*   **Cách khắc phục:** Kiểm tra phần mềm đo ESR trên máy tính chuyền. Cột "Mã công ty" trên B786 = version phần mềm đo.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6](../KB_03/KB_03_02_CELL_LINE.md).

---


## [B791] — NG Defect Repair (Sửa chữa lỗi NG)

> 🔗 **Xem thêm:** Mục [B682 / B781 / B786 / B789 / B791](#b682--b781--b786--b789--b791--stage-prices) phía trên.

### Lỗi 1: Lệch DefectQty và ProdQty khi sửa lỗi NG
*   **Triệu chứng:** Sau khi sửa chữa lỗi NG, số lượng hàng lỗi và hàng tốt bị lệch tổng.
*   **Nguyên nhân gốc:** SP `usp_ModuleLotTrackingInfo_VVT2_get` đọc từ cả `STB_DefectRepairInfo` và `STB_ProdRouteHist`. Khi sửa phải cập nhật đồng bộ cả 2 bảng.
*   **Cách khắc phục:** Cập nhật đồng thời `DefectQty` trong `STB_DefectRepairInfo` và `ProdQty` trong `STB_ProdRouteHist`.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5.8](../KB_03/KB_03_02_CELL_LINE.md) và [../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md § 9.5](../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md).

---


## [B882] — ANDON Display (Màn hình ANDON trên MES)

### Lỗi 1: Dữ liệu ANDON không cập nhật hoặc hiển thị trống
*   **Triệu chứng:** Dashboard ANDON tại B882 không hiển thị sản lượng real-time.
*   **Nguyên nhân gốc:** SP `usp_Vietnam_AndonDetail_get` lấy dữ liệu từ `STB_ProdRouteHist` lọc theo `WorkCenterCode`. Nếu WorkCenterCode sai hoặc không khớp sẽ trống.
*   **Cách khắc phục:** Kiểm tra tham số filter WorkCenterCode trên ANDON display khớp với mã nhà máy đang chạy.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6](../KB_03/KB_03_02_CELL_LINE.md) và ../KB_19/KB_19_01_ARCHITECTURE.md.

---


## [B934] — User Permission Config (Cấu hình quyền người dùng SX)

### Lỗi 1: Người dùng không có quyền thao tác trên màn hình sản xuất
*   **Triệu chứng:** OP đăng nhập MES nhưng các nút Save/Delete trên màn hình sản xuất bị disable.
*   **Nguyên nhân gốc:** UserID chưa được cấp quyền Execute cho các Button trên ScreenObject.
*   **Cách khắc phục:** Vào B934 hoặc Z220 gán quyền Execute cho Role tương ứng.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_AND_SCREENS.md § 2](../KB_01_UI_AND_SCREENS.md).

---


## [B935] — Role Screen Mapping (Gán màn hình cho vai trò SX)

### Lỗi 1: Nhóm vai trò sản xuất không thấy màn hình mới trên menu
*   **Triệu chứng:** Sau khi tạo màn hình mới, nhóm SX không nhìn thấy trên menu MES.
*   **Nguyên nhân gốc:** Màn hình mới chưa được gán vào Role của nhóm SX tại B935/Z220.
*   **Cách khắc phục:** Vào B935 hoặc Z220, chọn Role Group tương ứng, tick chọn Screen ID mới, Lưu lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_AND_SCREENS.md § 1.4](../KB_01_UI_AND_SCREENS.md).

---


## [H302] — Machine Repair History (Lịch sử sửa chữa máy)

> 🔗 **Xem thêm:** Mục [H301~H305](#h301h305--spare-parts-management) phía trên đã có tổng quan Spare Parts.

### Lỗi 1: Không ghi nhận được lịch sử sửa chữa máy
*   **Triệu chứng:** OP nhập thông tin sửa chữa tại H302 nhưng không lưu được.
*   **Nguyên nhân gốc:** Thiếu thông tin bắt buộc (MachineCode, TroublePoint, RepairText) hoặc máy chưa đăng ký tại B250.
*   **Cách khắc phục:** Đảm bảo máy đã đăng ký B250 và nhập đủ các trường bắt buộc.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 3](../KB_03/KB_03_02_CELL_LINE.md).

---


## [H303] — Machine Calibration (Hiệu chuẩn thiết bị đo)

### Lỗi 1: Thiết bị đo hết hạn hiệu chuẩn nhưng hệ thống không cảnh báo
*   **Triệu chứng:** Thiết bị đo vượt quá hạn hiệu chuẩn mà H303 không cảnh báo.
*   **Nguyên nhân gốc:** Lịch hiệu chuẩn chưa được thiết lập hoặc ngày hiệu chuẩn tiếp theo bị NULL.
*   **Cách khắc phục:** Vào H303, cập nhật lịch hiệu chuẩn (NextCalibrationDate) cho thiết bị.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 4](../KB_03/KB_03_02_CELL_LINE.md).

---


## [H304] — Spare Part Inventory (Tồn kho phụ tùng)

### Lỗi 1: Tồn kho phụ tùng bị lệch so với thực tế
*   **Triệu chứng:** H304 hiển thị số lượng phụ tùng tồn kho khác với kiểm kê thực tế.
*   **Nguyên nhân gốc:** Phiếu xuất/nhập phụ tùng chưa được xác nhận hoặc dữ liệu bị trùng.
*   **Cách khắc phục:** Kiểm tra lịch sử xuất/nhập phụ tùng tại H305, đối chiếu và điều chỉnh.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5](../KB_03/KB_03_02_CELL_LINE.md).

---


## [H305] — Spare Part In/Out History (Lịch sử xuất nhập phụ tùng)

> 🔗 **Xem thêm:** Mục [H301~H305](#h301h305--spare-parts-management) phía trên đã có tổng quan Spare Parts.

### Lỗi 1: Lịch sử xuất nhập phụ tùng không đồng bộ
*   **Triệu chứng:** Phiếu xuất/nhập ghi nhận tại H305 nhưng tồn kho H304 không cập nhật.
*   **Nguyên nhân gốc:** Phiếu chưa được confirm hoặc SP đồng bộ tồn kho bị lỗi.
*   **Cách khắc phục:** Kiểm tra trạng thái confirm của phiếu, chạy đồng bộ lại nếu cần.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 5](../KB_03/KB_03_02_CELL_LINE.md) và [../KB_03/KB_03_02_CELL_LINE.md § 6.15](../KB_03/KB_03_02_CELL_LINE.md).

---


## [K109] — [BG2] Material Scanning (Quét NVL nhà máy [BG2])

> 🔗 **Xem thêm:** Mục [K101 / K109 / K110](#k101--k109--k110--bg2-production-plan--scan) phía trên đã có chi tiết BG2.

### [BG2] — Lỗi 1: Quét NVL tại bị chặn sai chủng loại
*   **Triệu chứng:** OP BG2 quét NVL bị lỗi tương tự B597 nhưng trên giao diện K109.
*   **Nguyên nhân gốc:** Logic K109 tương đương B597, lọc riêng cho `WorkCenterCode = 'VVT_BG2'`. Cùng nguyên nhân HOLD/Hết hạn/Sai BOM.
*   **Cách khắc phục:** Áp dụng cùng quy trình debug B597 (xem mục B597 phía trên).
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_03/KB_03_02_CELL_LINE.md § 6.9](../KB_03/KB_03_02_CELL_LINE.md).

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


## [K110] — [BG2] Warehouse Operations (Vận hành kho [BG2])

### [BG2] — Lỗi 1: Kho không hiển thị NVL đã nhập
*   **Triệu chứng:** Thủ kho BG2 không tìm thấy NVL đã nhập kho tại K110.
*   **Nguyên nhân gốc:** WarehouseCode của kho BG2 khác với kho chính. Dữ liệu lọc theo `WorkCenterCode = 'VVT_BG2'`.
*   **Cách khắc phục:** Kiểm tra WarehouseCode của phiếu nhập kho F330 khớp với kho BG2.
*   **Chi tiết nghiệp vụ:** Xem tại [../KB_02/KB_02_01_WMS_CORE.md](../KB_02/KB_02_01_WMS_CORE.md).

---


---

### [B530] — Kịch bản sự cố khẩn cấp 1: Hủy/Xóa sản lượng công đoạn sản xuất ()

#### [B530] — 📐 KỊCH BẢN A: Hủy/Xóa sản lượng công đoạn sản xuất (Màn hình )
*   **Triệu chứng:** Công nhân scan nhầm sản lượng vào công đoạn `V-26` (Aging) trong khi Lot chưa chạy xong công đoạn `V-25`. Cần hủy công đoạn `V-26`.
*   **Ví dụ Demo:** Hủy công đoạn sản xuất mã `VE08` của Lot `VE260509-004`.
*   **Quy trình xử lý bằng Transaction:**
    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Xem lịch sử công đoạn của Barcode để xác định sequence (ProcSeq)
        SELECT PRH.ControlNo, PRH.RouteCode, PRH.ProdQty, PRH.CreateDateTime
        FROM STB_ProdRouteHist PRH
        JOIN STB_SetInfo SI ON PRH.ControlNo = SI.ControlNo
        WHERE SI.Barcode = 'VE260521-002'


        -- 2. Thực hiện xóa công đoạn bị nhầm (Ví dụ: RouteCode = 'VE08')
        -- Ràng buộc xóa theo ControlNo và đúng RouteCode của dòng cuối
        DELETE FROM STB_ProdRouteHist
        WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260509-004')
          AND RouteCode = 'VE08';

        -- 3. Cập nhật reset trạng thái lỗi (DefectQty) trên SetInfo nếu cần
        UPDATE STB_SetInfo
        SET DefectQty = 0, IsDefect = 0
        WHERE Barcode = 'VE260509-004';
        --thường là sẽ cần phải xóa ng theo nhưng nếu user quên chưa nhập ng (nv vẫn =0) thì không cần xóa ng

        COMMIT TRANSACTION;
        PRINT 'Hủy công đoạn thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
    ```

---

### [B530] — Kịch bản sự cố khẩn cấp 2: Lỗi không chốt được công đoạn ()

#### 📐 KỊCH BẢN A: Chặn do quên scan Nguyên vật liệu tại trạm trước (V-23 / V-24)
*   **Triệu chứng:** Khi bấm chốt công đoạn `V-23` (Lắp cao su) hoặc `V-24` (Curling), hệ thống báo lỗi: *"Chưa nhập NVL cho Lắp Cao Su"* hoặc *"Chưa nhập NVL cho Curling"*.
*   **Nguyên nhân:** SP `usp_CheckInputRawMaterialCodeForProduct` kiểm tra và phát hiện barcode sản phẩm chưa được scan gán Lot vật tư đầu vào tại trạm **B540**.
*   **Cách khắc phục chuẩn:** Yêu cầu công nhân quay lại màn hình **B540**, scan barcode sản phẩm và quét đúng mã Lot NVL (cao su, sleeve) tương ứng.
*   **Bypass khẩn cấp bằng SQL (IT chèn dữ liệu giả lập NVL để thông luồng):**
    ```sql
    -- Chèn trực tiếp bản ghi scan NVL cho Barcode
    INSERT INTO STB_RawMaterialInputHist 
        (Barcode, RouteCode, MaterialCode, RawMaterialBarcode, CreateDateTime, CreateUserID)
    VALUES 
        ('Mã_Barcode_Bị_Lỗi', 'V-23', 'Mã_Vật_Tư_Cao_Su', 'Mã_Lot_NVL_Thực_Tế', GETDATE(), 'vinaadmin');
    ```

#### 📐 KỊCH BẢN B: Chặn do công đoạn phía sau đã được scan trước ("Đã hoàn thành thực tế rồi")
*   **Triệu chứng:** Công nhân quên chốt công đoạn `V-25` nhưng đã scan chốt công đoạn `V-26`. Khi quay lại chốt `V-25` thì hệ thống báo lỗi: *"Đã hoàn thành thực tế rồi"*.
*   **Nguyên nhân:** SP chặn chốt công đoạn trước nếu công đoạn sau đã có dữ liệu sản lượng (`AftProdQty <> 0`).
*   **Cách khắc phục:**
    1.  Chạy script **hủy công đoạn sau** (`V-26`) trước (Xem mục 4.2).
    2.  Yêu cầu công nhân scan chốt công đoạn trước (`V-25`) trên UI.
    3.  Sau đó scan chốt lại công đoạn sau (`V-26`) đúng thứ tự.


#### 📐 KỊCH BẢN C: Chặn do Gate 20 phút (Chỉ áp dụng tại nhà máy Bắc Ninh - VNT)
*   **Triệu chứng:** Khi bấm chốt công đoạn, hệ thống báo lỗi: *"Thời gian scan quá nhanh, phải đợi tối thiểu 20 phút từ công đoạn trước"*.
*   **Nguyên nhân:** SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` chặn đăng ký liên tiếp giữa các công đoạn có thời gian chênh lệch dưới 20 phút nhằm chống scan khống.
*   **Cách khắc phục (Bypass lùi giờ scan trước):**
    ```sql
    -- Lùi thời gian scan của công đoạn ngay trước đó về 25 phút trước
    UPDATE STB_ProdRouteHist
    SET CreateDateTime = DATEADD(MINUTE, -25, GETDATE())
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'Mã_Barcode_Bị_Chặn')
      AND RouteCode = 'Mã_Công_Đoạn_Trước'; -- Ví dụ: 'V-22'
    ```

---


