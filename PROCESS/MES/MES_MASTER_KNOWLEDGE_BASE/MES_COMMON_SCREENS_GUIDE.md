# 🗺️ Cẩm Nang Tra Cứu & Vận Hành Các Màn Hình MES Thường Dùng (NAIS MES Guide)

Tài liệu này tổng hợp chi tiết tất cả các màn hình (TCode) hoạt động trong hệ thống NAIS MES tại Vinatech. Mỗi màn hình được phân tích theo hai phần chính:
1. **Ý nghĩa & Nghiệp vụ:** Vai trò thực tế trên dây chuyền sản xuất và kho.
2. **Cơ chế hoạt động của các nút bấm:** Mô tả chi tiết hành động của các nút bấm nghiệp vụ chuyên biệt (hoặc các nút CRUD cơ bản như Lưu, Xóa, Tìm kiếm, Làm mới nếu màn hình không có nút đặc thù) - Stored Procedure (SP) nào được gọi, các tham số chính và các bảng CSDL (`STB_*`) chịu tác động.

> 📌 Tra cứu nhanh Screen ID → KB files → SP chính: Xem [screen_id_reference.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/knowledge/vinatech_screen_id_reference/artifacts/screen_id_reference.md)

---

## 🅰️ PHÂN HỆ MASTER DATA & CẤU HÌNH (NHÓM A)

### 1. [A230] Danh mục vật tư (MaterialMaster)
* **Ý nghĩa & Nghiệp vụ:** Quản lý danh mục toàn bộ mã nguyên vật liệu, thành phẩm, bán thành phẩm trong hệ thống. Cung cấp dữ liệu độ dày nguyên liệu điện cực liên kết trực tiếp với kế hoạch sản xuất B442.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm / Làm mới:** Thực hiện thao tác CRUD cơ bản, tác động trực tiếp lên bảng `STB_MaterialMaster` (82 cột, PK: `MaterialCode`).

### 2. [A310] Cấu hình BOM (Bill of Materials)
* **Ý nghĩa & Nghiệp vụ:** Khai báo danh mục nguyên liệu cấu thành cho mỗi sản phẩm (BOM) làm cơ sở cho màn hình B597 đối chiếu quét NVL đầu vào line.
* **Cơ chế nút bấm:**
  * **Lưu Header (`Save`):** Gọi SP `usp_BomHeader_iud`, ghi vào bảng `STB_BomHeader`.
  * **Lưu Detail (`Save`):** Gọi SP `usp_BomDetail_iud`, ghi vào bảng `STB_BomDetail`.
  * **Xóa (`Delete`):** Xóa bản ghi BOM tương ứng.

### 3. [A320] Cấu hình Định tuyến (Route Info)
* **Ý nghĩa & Nghiệp vụ:** Định nghĩa danh mục các công đoạn sản xuất (Winding, Assembly, Sleeving...) làm cơ sở xây dựng quy trình công nghệ cho sản phẩm.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thực hiện thao tác CRUD cơ bản tác động lên bảng `STB_RouteInfo` (PK: `RouteCode`).

### 4. [A410] Đăng ký thông số Model (ModelBasicInfo)
* **Ý nghĩa & Nghiệp vụ:** Khai báo thông số điện áp (Vol), dung lượng (Farad), kích thước sản phẩm và cấu hình hình thức kiểm tra OQC của Model.
* **Cơ chế nút bấm:**
  * **Lưu (`Save`):** Gọi Stored Procedure `usp_ModelBasicInfo_iud` ghi nhận thông tin vào bảng `STB_ModelBasicInfo` (61 cột, PK: `ModelCode`).

### 5. [A418] Số lượng đóng gói theo kích thước (Packing Qty per Size)
* **Ý nghĩa & Nghiệp vụ:** Khai báo cấu hình số lượng sản phẩm chuẩn đóng gói theo từng mã Size.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thao tác CRUD cơ bản tác động lên bảng `STB_PackingQtyPerSize`.

### 6. [A419] Cấu hình số lượng đóng gói (STB_PackingStandard)
* **Ý nghĩa & Nghiệp vụ:** Cấu hình số lượng đóng gói tiêu chuẩn (trong túi nilon, hộp nhỏ, thùng carton) cho từng dòng sản phẩm theo kích thước.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thao tác CRUD cơ bản tác động lên bảng `STB_PackingStandard` (PK Composite: `MaterialTypeCode` + `Size` + `Voltage` + `Farad`).

### 7. [A460] Cấu hình In Tem Nhãn (STB_ModelLabelInfo)
* **Ý nghĩa & Nghiệp vụ:** Ánh xạ mã sản phẩm với định dạng và mẫu thiết kế tem nhãn tương ứng đã phê duyệt tại Z530.
* **Cơ chế nút bấm:**
  * **Lưu (`Save`):** Gọi SP `usp_DoMakeModelLabelInfo` để lưu bản ghi ánh xạ vào bảng `STB_ModelLabelInfo`.
  * **Xóa (`Delete`):** Xóa bản ghi ánh xạ khỏi bảng `STB_ModelLabelInfo`.

### 8. [A510] Lệnh sản xuất tháng (Production Order)
* **Ý nghĩa & Nghiệp vụ:** Khai báo và khởi tạo lệnh sản xuất tháng làm căn cứ cho kế hoạch ngày.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thao tác CRUD cơ bản tác động lên bảng `STB_ProductionOrderInfo`.

---

## 🅱️ PHÂN HỆ SẢN XUẤT & CELL LINE (NHÓM B)

### 9. [B210] Đăng ký Line sản xuất
* **Ý nghĩa & Nghiệp vụ:** Khai báo danh mục các chuyền sản xuất vật lý trong nhà máy.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thao tác CRUD cơ bản tác động lên bảng `STB_LineInfo` (PK: `LineCode`).

### 10. [B220] Đăng ký Route công đoạn
* **Ý nghĩa & Nghiệp vụ:** Khai báo tên công đoạn sản xuất (V-22, V-23, MV-01...).
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thao tác CRUD cơ bản tác động lên bảng `STB_RouteInfo` (PK: `RouteCode`).

### 11. [B230] Phân quyền Route vào Line
* **Ý nghĩa & Nghiệp vụ:** Khai báo và cấu hình chuyền sản xuất chạy những công đoạn nào.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thao tác CRUD cơ bản tác động lên bảng `STB_LineRouteMapping`.

### 12. [B240] Đăng ký Máy sản xuất
* **Ý nghĩa & Nghiệp vụ:** Đăng ký thông tin máy móc thiết bị và phân quyền Máy thuộc công đoạn nào.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thao tác CRUD cơ bản tác động lên bảng `STB_MachineMaster` (PK: `MachineCode`).

### 13. [B250] Thông tin máy chi tiết
* **Ý nghĩa & Nghiệp vụ:** Tra cứu và điều chỉnh chi tiết máy móc thuộc công đoạn nào.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa (`DoSave` / `DoDelete`):** Gọi SP `usp_MachineMaster_get/jud` tác động lên bảng `STB_MachineMaster`.

### 14. [B260] Đăng ký công nhân sản xuất
* **Ý nghĩa & Nghiệp vụ:** Khai báo danh sách công nhân viên trực chuyền, bắt buộc set `WorkerGroupCode = 'VE-01'` để hiển thị ở B530/B540.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa / Tìm kiếm:** Thao tác CRUD cơ bản tác động lên bảng nhân viên hệ thống.

### 15. [B270] Ánh xạ máy-công đoạn
* **Ý nghĩa & Nghiệp vụ:** Map máy móc chạy công đoạn nào của Line sản xuất.
* **Cơ chế nút bấm:**
  * **Lưu (`Save`):** Gọi SP `usp_ProductMachine_get/jud` tác động lên bảng `STB_ProductMachine`.

### 16. [B310] Lệnh sản xuất — Production Order Details
* **Ý nghĩa & Nghiệp vụ:** Tra cứu và điều chỉnh cấu hình chi tiết của PO (BOM PO, PO Routing).
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Gọi SP `usp_ProductionOrderInfo_get` tải danh sách PO từ bảng `STB_ProductionOrderInfo`.

### 17. [B351] Chuyển đổi Lot (Lot Material Change)
* **Ý nghĩa & Nghiệp vụ:** Đổi mã hàng và PO sản xuất cho Lot đã cuộn để tận dụng hoặc sửa sai sót.
* **Cơ chế nút bấm đặc thù:**
  * **Đổi (`Execute` / `Change`):**
    * *Nghiệp vụ:* Xác nhận đổi mã sản phẩm và PO cho Lot.
    * *Logic & SP:* Gọi SP `usp_DoChangeMaterialForSetInfo` cập nhật cột `MaterialCode` và `DayPlanNo` của Lot trong bảng `STB_SetInfo` và ghi log vào `STB_LotChangeMaterialHistory`.

### 18. [B353] Thay đổi tên Lot (Change Lot No)
* **Ý nghĩa & Nghiệp vụ:** Thay thế tên Lot hoặc mã sản phẩm của Lot đã đóng gói để in nhãn xuất khẩu riêng.
* **Cơ chế nút bấm đặc thù:**
  * **Đổi Lot No (`DoChangeLot`):**
    * *Nghiệp vụ:* Chốt đổi mã Lot cũ sang mã Lot mới.
    * *Logic & SP:* Gọi SP `usp_DoChangePartNoAndLotNo` cập nhật trường `LotNo` trong các bảng liên quan và lưu vết vào `STB_ChangePartNoAndLotNo`.

### 19. [B442] Kế hoạch sản xuất Điện cực
* **Ý nghĩa & Nghiệp vụ:** Lập kế hoạch ngày cho Điện cực và sinh Lot điện cực in tem vạch.
* **Cơ chế nút bấm đặc thù:**
  * **Tạo Lot (`DoCreateSetInfo`):** 
    * *Nghiệp vụ:* Sinh mã Lot điện cực (Barcode) dựa trên sản lượng kế hoạch ngày.
    * *Logic & SP:* Gọi SP `usp_DoCreateSetInfoForProdQty_VNT` để sinh mã Barcode điện cực (tiền tố `VVQ...`) và chèn bản ghi mới vào bảng `STB_SetInfo`.
  * **In Tem (`LabelPrint`):** 
    * *Nghiệp vụ:* In nhãn dán barcode cho cuộn điện cực đã tạo Lot.
    * *Logic & SP:* Hệ thống tra cứu mẫu tem `FormatName` từ `STB_ModelLabelInfo` (loại `ElectLabel`), lấy XML thiết kế từ `STB_LabelInfo` ở Z530 và truyền tham số in.

### 20. [B450] Kế hoạch sản xuất ngày & Tạo Lot (DayProdPlan)
* **Ý nghĩa & Nghiệp vụ:** Phân bổ sản lượng theo ngày cho từng Line và sinh mã Lot sản xuất.
* **Cơ chế nút bấm đặc thù:**
  * **Fixed (Khóa kế hoạch - `DoFix`):**
    * *Nghiệp vụ:* Khóa kế hoạch ngày đã lập để tiến hành sản xuất, không cho phép sửa số lượng kế hoạch trên UI nữa.
    * *Logic & SP:* Thực thi SP `usp_DoFixDayProdPlan`, cập nhật cờ `IsFixed = 1` trong bảng `STB_DayProdPlan`.
  * **Tạo Lot (Barcode - `DoCreateSetInfo`):**
    * *Nghiệp vụ:* Sinh ra danh sách mã vạch (Barcode) theo dung lượng Lot size quy định.
    * *Logic & SP:* Thực thi SP `usp_DoCreateSetInfoForProdQty_VNT`. SP gọi `usp_GetNewSerialNoForBarcode` để lấy số thứ tự tăng dần, sinh mã vạch (tiền tố `VV...`) và INSERT các dòng mới vào bảng `STB_SetInfo`.
  * **Hủy kế hoạch (`DoCancel`):**
    * *Nghiệp vụ:* Hủy bỏ kế hoạch ngày đã lập.
    * *Logic & SP:* Gọi SP `usp_DoCancelDayProdPlan`, reset trạng thái kế hoạch trong bảng `STB_DayProdPlan`.
  * **Đóng kế hoạch (`DoFinish`):**
    * *Nghiệp vụ:* Chốt đóng kế hoạch ngày sau khi hoàn thành sản lượng.
    * *Logic & SP:* Gọi SP `usp_DoFinishDayProdPlan`.
  * **In Tem (`LabelPrint`):**
    * *Nghiệp vụ:* In nhãn sản xuất dán lên các Lot vừa sinh.
    * *Logic & SP:* Lấy format template `FormatName` từ `STB_ModelLabelInfo` (A460) ứng với loại `AssembleLabel`, kết hợp XML layout từ Z530 và in ra.

### 21. [B452] Đổi Line sản xuất (Vietnam Print Lot Changed)
* **Ý nghĩa & Nghiệp vụ:** Điều phối chuyển Lot sang Line sản xuất khác khi có sự cố chuyền.
* **Cơ chế nút bấm đặc thù:**
  * **Đổi Line (`Save`):**
    * *Nghiệp vụ:* Lưu thông tin chuyển Line cho Lot được chọn.
    * *Logic & SP:* Thực thi SP `usp_Set_VVT_Info_get`. SP kiểm tra xem UserID hiện tại có nằm trong whitelist được phân quyền đổi Line hay không. Nếu có quyền, thực hiện câu lệnh UPDATE cột `InputLineCode` trong bảng `STB_SetInfo`.

### 22. [B523] Đóng gói & In tem thùng thành phẩm (Donggoi)
* **Ý nghĩa & Nghiệp vụ:** Gộp Lot PASS thành BoxID và in tem nhãn thùng thành phẩm.
* **Cơ chế nút bấm đặc thù:**
  * **Gộp Box (`MergeBox` / `Box합치기`):**
    * *Nghiệp vụ:* Gộp nhiều Lot sản phẩm đã QC PASS thành một thùng hàng chung (BoxID).
    * *Logic & SP:* Thực thi SP `usp_Vietnam_DoProcessProdPacking_VVT` (hoặc `usp_DoProcessProdPackingByOne_VNT`). SP kiểm tra Lot đã QC Pass chưa, kiểm tra tiêu chuẩn đóng gói ở A419, sau đó sinh mã BoxID (`PackingID` mới) và cập nhật cột `PackingID` cho các Lot trong bảng `STB_MaterialLotInfo` cùng bảng phụ `STB_DividePackaging`.
  * **In Tem Box To (`LabelPrint`):**
    * *Nghiệp vụ:* In nhãn thùng Carton (Outer Label) dán ngoài thùng hàng.
    * *Logic & SP:* Lấy XML layout tem Outer từ `STB_LabelInfo`, in mã vạch chứa `PackingID` và ghi nhận số lần in (chỉ cho phép in 1 lần duy nhất).
  * **Chia Box (`SplitBoxQty`):**
    * *Nghiệp vụ:* Tách bớt số lượng sản phẩm từ Box gốc sang một BoxID mới.
    * *Logic & SP:* Gọi SP `usp_SplitPackingBox`. SP thực hiện giảm số lượng `CurrentQty` của Box gốc trong `STB_MaterialLotInfo` và INSERT một dòng BoxID mới với số lượng tách.
  * **Hủy đóng gói (`DoCancelProdPacking`):**
    * *Nghiệp vụ:* Rã Box (hủy thùng), chuyển các Lot trong thùng quay về trạng thái chưa đóng gói.
    * *Logic & SP:* Thực thi SP `usp_DoCancelProdPacking_LotNo`. SP sẽ reset giá trị cột `PackingID = NULL` cho các Lot tương ứng trong bảng `STB_MaterialLotInfo` và `STB_DividePackaging`.

### 23. [B525] Gộp Box Module (Kho)
* **Ý nghĩa & Nghiệp vụ:** Gộp các bán thành phẩm hoặc Lot thành phẩm của Module (MDL) thành các Box lớn.
* **Cơ chế nút bấm đặc thù:**
  * **Gộp Box Module (`DoPackingModule`):**
    * *Nghiệp vụ:* Chốt đóng gói các Lot Module thành BoxID.
    * *Logic & SP:* Gọi SP `usp_Vietnam_DoProcessProdPacking_VVT` để map các Lot Module tương tự như Cell nhưng hoạt động trên nhóm loại hình `MaterialTypeCode = 'MDL'`.
  * **Hủy đóng gói (`DoCancelProdPacking`):**
    * *Nghiệp vụ:* Rã Box Module.
    * *Logic & SP:* Gọi SP `usp_DoCancelProdPacking_LotNo`.

### 24. [B528] Barrel Barcode (Tem thùng phuy)
* **Ý nghĩa & Nghiệp vụ:** In tem dán thùng phuy (Barrel) chứa hóa chất hoặc nguyên liệu thô dạng lỏng.
* **Cơ chế nút bấm đặc thù:**
  * **In tem phuy (`BarrelPrint`):**
    * *Nghiệp vụ:* Tạo lệnh in tem phuy.
    * *Logic & SP:* Hệ thống tra cứu mẫu in tem phuy (LabelType = `BarrelLabel`) từ mapping và in thông tin hóa chất, hạn sử dụng.

### 25. [B530] Nhập số lượng sản xuất theo công đoạn (ProdRouteHist)
* **Ý nghĩa & Nghiệp vụ:** Chốt sản lượng đạt (Yield) và sản phẩm lỗi (Defect) của từng công đoạn sản xuất.
* **Cơ chế nút bấm đặc thù:**
  * **Lưu/Chốt công đoạn (`Save`):**
    * *Nghiệp vụ:* Xác nhận chốt số lượng đạt/lỗi để chuyển Lot sang công đoạn kế tiếp.
    * *Logic & SP:* Gọi SP cốt lõi **`usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`**. SP thực hiện chạy qua 7 cổng chặn (Validation Gates) bao gồm: Kiểm tra nạp điện cực (B552), kiểm tra nạp NVL đầu vào (B597), kiểm tra PQC (Hà Nam), kiểm tra cờ chốt, thời gian chờ chốt (20 phút), mã máy bắt buộc và PO Routing. Sau khi PASS toàn bộ gates, thực hiện INSERT vào `STB_ProdRouteHist` + `STB_DefectRepairInfo` (nếu có lỗi) và UPDATE trạng thái Lot trong `STB_SetInfo`.
  * **Pass Barcode / Fail Barcode (BG2):**
    * *Nghiệp vụ:* Đánh dấu nhanh Lot đạt hoặc lỗi tại các trạm kiểm tra nhanh ở nhà máy Bắc Giang 2.
    * *Logic & SP:* Gọi SP `usp_PassBarcodeForRoute` hoặc `usp_FailBarcodeForRoute` để cập nhật nhanh kết quả chất lượng của Barcode.

### 26. [B540] Assy Card Info — Nhập thông tin sấy & NVL thô
* **Ý nghĩa & Nghiệp vụ:** Ghi nhận nạp nguyên liệu thô và thời gian lò sấy (Oven) trước khi lắp ráp.
* **Cơ chế nút bấm đặc thù:**
  * **Đưa vào máy sấy (`OvenInput`):**
    * *Nghiệp vụ:* Ghi nhận thời điểm bắt đầu đưa Lot vào lò sấy.
    * *Logic & SP:* Ghi nhận thời gian thực tế (`GETDATE()`) vào các cột sấy mở rộng (`SIExtText01`~`SIExtText05`) trong bảng `STB_SetInfo`.
  * **Đưa ra máy sấy (`OvenOutput`):**
    * *Nghiệp vụ:* Xác nhận rút Lot ra khỏi lò sấy sau khi đủ thời gian tiêu chuẩn.
    * *Logic & SP:* Kiểm tra chênh lệch thời gian sấy so với quy chuẩn của lò sấy. Nếu đạt, ghi nhận hoàn thành sấy vào bảng `STB_SetInfo`.
  * **Kiểm tra thường xuyên (`VVT_SelfInspRawMaterial`):**
    * *Nghiệp vụ:* Nút quét kiểm tra chéo Barcode cuộn điện cực nạp vào máy Riveting xem có khớp BOM.
    * *Logic & SP:* Đối chiếu Barcode nguyên liệu quét vào với cấu hình BOM trong `STB_BomDetail`.

### 27. [B552] Cấu hình Slitting & Nhập liệu 4 công đoạn Điện cực
* **Ý nghĩa & Nghiệp vụ:** Nhập sản lượng, phế thải cho 4 công đoạn sản xuất điện cực.
* **Cơ chế nút bấm đặc thù:**
  * **Tạo tem Slitting (`LabelPrint`):**
    * *Nghiệp vụ:* Sinh Lot điện cực cho cuộn sau khi cắt (Slitting) và in tem vạch.
    * *Logic & SP:* Gọi hàm `SmartFramework.dbo.usp_DoCreateSerial` để tự động sinh mã Lot điện cực và ghi nhận vào bảng tồn kho điện cực `Stb_SlittingStock_VVT`.

### 28. [B560] Hela OutBox List (In tem thùng Hela)
* **Ý nghĩa & Nghiệp vụ:** In tem dán ngoài thùng hàng cho dự án đối tác Hela (yêu cầu ghép danh sách tem hộp nhỏ).
* **Cơ chế nút bấm đặc thù:**
  * **In tem Hela (`HelaPrint`):**
    * *Nghiệp vụ:* Xác nhận in tem thùng ngoài Hela.
    * *Logic & SP:* Gọi SP `usp_DoCreateHelaInBoxBarcodeList` / `usp_DoCreateReport` để tổng hợp chuỗi mã vạch các hộp nhỏ bên trong (`InBoxLabelList` kiểu VARCHAR(MAX)) và in nhãn thùng lớn, ghi lịch sử vào `STB_HelaBarcodeOutBoxHist`.

### 29. [B597] QC inline scan NVL (SelfInspection)
* **Ý nghĩa & Nghiệp vụ:** Công nhân tự kiểm tra Barcode NVL trước khi nạp vào máy sản xuất.
* **Cơ chế nút bấm đặc thù:**
  * **Nạp nguyên liệu (`RawMaterialInput`):**
    * *Nghiệp vụ:* Quét kiểm tra cuộn nguyên vật liệu (ML...) chuẩn bị lắp vào máy.
    * *Logic & SP:* Gọi SP `usp_Vietnam_RawMaterialInputHist_uid`. SP tự động thực thi 7 gates kiểm tra (HOLD, Expiry, BOM, Độ dày, Electrolyte, Vỏ Nhôm, Slitting). Nếu vượt qua, thực hiện INSERT bản ghi vào bảng lịch sử nạp `STB_RawMaterialInputHist` và cập nhật cờ `IsRawMaterialInputFinish = 1` để cho phép B530 chốt công đoạn.
  * **Hoàn thành tài liệu QC (`DoFinish`):**
    * *Nghiệp vụ:* QC chốt xác nhận tài liệu tự kiểm của ca sản xuất.
    * *Logic & SP:* Thực thi SP `usp_DoFinishCommInspDoc_VNT` để khóa và lưu tài liệu kiểm tra chất lượng tự kiểm.

### 30. [B598] Báo phế NVL sản xuất (Production Error/Scrap)
* **Ý nghĩa & Nghiệp vụ:** Ghi nhận phế NVL (tính bằng kg/g) phát sinh tại chuyền.
* **Cơ chế nút bấm đặc thù:**
  * **Hủy báo phế (`Cancel`):**
    * *Nghiệp vụ:* Hủy bỏ bản ghi báo phế nhập sai.
    * *Logic & SP:* Gọi SP `usp_VN_update_CanceScrap`. Thực hiện UPDATE cột `Status = 'CANCEL'` trong bảng báo phế `STB_VN_PRODUCTION_ERROR` để loại trừ khỏi báo cáo hao hụt.

### 31. [B618] Lịch sử sản xuất lại (Rework History)
* **Ý nghĩa & Nghiệp vụ:** Quản lý và theo dõi các Lot bị lỗi được đưa vào luồng sản xuất lại (Rework).
* **Cơ chế nút bấm đặc thù:**
  * **Rework (`Rework`):**
    * *Nghiệp vụ:* Đưa Lot quay lại công đoạn trước trong quy trình để sửa đổi.
    * *Logic & SP:* Gọi SP `usp_GetInforLotReworkHaNamFactory_uid` để xác thực quyền hạn và chèn trạng thái Rework cho Lot sản xuất trong bảng `STB_SetInfo` và `STB_ProdRouteHist`.

### 32. [B682] Báo cáo phế lỗi Cell Line
* **Ý nghĩa & Nghiệp vụ:** Tổng hợp và báo cáo số lượng phế sản phẩm trên chuyền Cell Line.
* **Cơ chế nút bấm:**
  * **Tìm kiếm / Xuất báo cáo:** Lọc và hiển thị dữ liệu lỗi từ bảng `STB_VN_PRODUCTION_ERROR` và giá công đoạn từ `STB_VVT_StagePrices`.

### 33. [B717] Bẻ cong & Dán keo (Bending & Tapping)
* **Ý nghĩa & Nghiệp vụ:** Ghi nhận số lượng bẻ chân (Bending) và dán băng keo (Tapping) cho sản phẩm Cell.
* **Cơ chế nút bấm:**
  * **Chốt dữ liệu (`Save`):**
    * *Nghiệp vụ:* Chốt số lượng gia công Cell Bending/Tapping.
    * *Logic & SP:* Hệ thống thực hiện chèn dữ liệu trực tiếp vào bảng `STB_VN_BENDING_TAPPING`. **⚠️ Lưu ý:** Giao dịch chỉ cho phép ghi nhận một lần đầu tiên đối với mã Lot.

### 34. [B718] Báo cáo Rework & Bending/Tapping
* **Ý nghĩa & Nghiệp vụ:** Tra cứu lịch sử và sản lượng của các công đoạn Rework và Bending/Tapping.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Truy vấn dữ liệu từ bảng giao dịch `STB_VN_BENDING_TAPPING`.

### 35. [B726] Báo phế sản phẩm sau sản xuất (Scrap After Production)
* **Ý nghĩa & Nghiệp vụ:** Khai báo phế sản phẩm WIP khi phát hiện lỗi chất lượng nghiêm trọng sau khi chốt công đoạn.
* **Cơ chế nút bấm đặc thù:**
  * **Xác nhận phế (`ScrapConfirm`):**
    * *Nghiệp vụ:* Khóa Lot và ghi nhận số lượng báo phế thành phẩm.
    * *Logic & SP:* Gọi SP `usp_vn_scrapafterproduction` để ghi nhận báo phế vào bảng `STB_VN_SCRAP_AFTERPRODUCTIONS`.

### 36. [B754/[B755]/B756] In tem khách hàng PAC
* **Ý nghĩa & Nghiệp vụ:** In nhãn sản phẩm và tem thùng Carton cho dự án khách hàng PAC.
* **Cơ chế nút bấm đặc thù:**
  * **In tem thùng Carton (tại B756):**
    * *Nghiệp vụ:* Phát hành và in nhãn dán thùng Carton ngoài.
    * *Logic & SP:* Thực thi SP `usp_PACLabelCartonWeight_get_Vietnam` để lấy danh sách in và ghi log lịch sử in vào bảng `STB_PACBoxLabelPrintHist`.
  * **In tem Cân Nặng (tại B756):**
    * *Nghiệp vụ:* In nhãn cân nặng thực tế dán lên thùng hàng.
    * *Logic & SP:* Tích chọn `IsWeightLabel` trên UI, hệ thống sẽ thực thi lấy trọng lượng thực nhập vào để sinh nhãn cân nặng tương ứng qua SP `usp_PACLabelCartonWeight_get_Vietnam`.

### 37. [B757/B758] In tem khách hàng Digi-Key
* **Ý nghĩa & Nghiệp vụ:** In nhãn sản phẩm, nhãn Logistic và nhãn thùng Mixed Load cho dự án Digi-Key.
* **Cơ chế nút bấm đặc thù:**
  * **IN NHÃN SP (tại B757):**
    * *Nghiệp vụ:* In nhãn sản phẩm Digi-Key dán trên hộp sản phẩm.
    * *Logic & SP:* Gọi SP `usp_VN_DigiKeyLabelInnerPrintHist_iud` ghi nhận lịch sử và in nhãn.
  * **IN NHÃN LOGISTIC (tại B757):**
    * *Nghiệp vụ:* In nhãn dán phục vụ khâu vận chuyển/vận tải Logistics của Digi-Key.
    * *Logic & SP:* Gọi SP `usp_VN_DigiKeyLabelInnerPrintHist_iud` với các tham số PoNo, PoLine, PackList.
  * **IN NHÃN MIXED LOAD (tại B758):**
    * *Nghiệp vụ:* In nhãn thùng trộn cho các pallet/thùng chứa nhiều loại model khác nhau.
    * *Logic & SP:* Thực thi SP `usp_VN_DigiKeySingleLevelPackagePrintHist_iud` truyền Invoice (`Pack List Number`), cân nặng tổng (`Weight`) và số kiện (`PackageCount`).

### 38. [B781] Tra cứu sản lượng đóng gói (STB_SavePackingTime_VVT)
* **Ý nghĩa & Nghiệp vụ:** Tra cứu thời gian đóng gói và tổng số lượng BoxID đã in nhãn.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Gọi SP `usp_Vietnam_PackPrintTime_get` truy vấn bảng `STB_SavePackingTime_VVT`.

### 39. [B782] Lịch sử Routing (Lot Tracking)
* **Ý nghĩa & Nghiệp vụ:** Tra cứu hành trình chốt công đoạn và lịch sử lỗi chi tiết của từng Lot sản phẩm.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Gọi SP `usp_LotTrackingInfo_VVT2_get` truy vấn dữ liệu chốt từ bảng `STB_ProdRouteHist`.

### 40. [B786] Lịch sử ESR (Online ESR Monitoring)
* **Ý nghĩa & Nghiệp vụ:** Theo dõi trực tiếp thông số kiểm tra ESR từ các máy đo kết nối tự động.
* **Cơ chế nút bấm đặc thù:**
  * **Lấy dữ liệu (`GetData`):**
    * *Nghiệp vụ:* Cập nhật/tải trực tuyến các thông số ESR đo được của các Lot từ máy đo.
    * *Logic & SP:* Đồng bộ và hiển thị các bản ghi trong bảng `STB_VVT_ESRDATA` lên màn hình.

### 41. [B789] Sửa/xóa Packing (Manage Box/Packing Standard)
* **Ý nghĩa & Nghiệp vụ:** Quản lý, điều chỉnh số lượng hoặc rã Box cho các BoxID đã đóng gói.
* **Cơ chế nút bấm đặc thù:**
  * **Hủy Packing / Rã Box (`Unpack`):**
    * *Nghiệp vụ:* Khôi phục lại trạng thái chưa gộp box cho Lot khi quét BoxID.
    * *Logic & SP:* Thực thi SP `usp_Vietnam_GetBoxIDForLotNo_VVT` để giải phóng liên kết `PackingID` trong `STB_SavePackingTime_VVT`.

### 42. [B790] Báo cáo chi tiết nạp NVL ([B597] Report)
* **Ý nghĩa & Nghiệp vụ:** Báo cáo chi tiết lịch sử quét mã nguyên vật liệu đầu vào chuyền của các Lot.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Truy vấn dữ liệu nạp từ bảng `STB_CommInspDocHistory` và `STB_RawMaterialInputHist`.

### 43. [B791] Lỗi & Sửa chữa sản phẩm (NG/Defect Repair)
* **Ý nghĩa & Nghiệp vụ:** Cho phép sửa đổi số lượng lỗi và sản lượng chốt của Lot.
* **Cơ chế nút bấm đặc thù:**
  * **Sửa lượng lỗi/Yield (`DoRepair`):**
    * *Nghiệp vụ:* Điều chỉnh số lượng lỗi `DefectQty` và sản lượng đạt `ProdQty` của công đoạn.
    * *Logic & SP:* Gọi SP `usp_ModuleLotTrackingInfo_VVT2_get` để cập nhật đồng bộ các bảng `STB_ProdRouteHist` và `STB_DefectRepairInfo`.

### 44. [B802] Lịch sử sản xuất điện cực
* **Ý nghĩa & Nghiệp vụ:** Tra cứu tiến độ chốt sản lượng 4 công đoạn điện cực (Mixing -> Slitting).
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Gọi SP `usp_Vietnam_ElectrodeProdRouteHist_get` kết nối dữ liệu từ `STB_ElectrodeWasteInfoNew`.

### 45. [B882] Bảng hiển thị ANDON MES
* **Ý nghĩa & Nghiệp vụ:** Quản lý hiển thị trạng thái dừng line (Andon) của toàn nhà máy.
* **Cơ chế nút bấm đặc thù:**
  * **Cảnh báo ANDON (`AndonCall`):**
    * *Nghiệp vụ:* Phát tín hiệu gọi cứu hộ, cảnh báo dừng line do sự cố.
    * *Logic & SP:* Gọi SP `usp_Vietnam_AndonDetail_get` để đẩy dữ liệu cảnh báo lên hệ thống Andon.

### 46. [B934/B935] Bảo dưỡng PM & Check Sheet Máy (Machine maintenance)
* **Ý nghĩa & Nghiệp vụ:** Chốt bảo trì PM định kỳ và check sheet máy hàng ngày của công nhân.
* **Cơ chế nút bấm đặc thù:**
  * **Chốt Check Sheet (`ConfirmCheckSheet` - tại B934):**
    * *Nghiệp vụ:* Lưu thông số kiểm tra máy hàng ngày.
    * *Logic & SP:* Ghi nhận vào bảng `stb_CheckSheetDaily`.
  * **Chốt PM máy (`ConfirmPM` - tại B935):**
    * *Nghiệp vụ:* Lưu thông tin hoàn thành bảo dưỡng máy định kỳ.
    * *Logic & SP:* Ghi nhận vào bảng `STB_MachinePmHistory` và chi tiết hạng mục `STB_MachinePmItem`.

---

## 🅲 PHÂN HỆ QUẢN LÝ CHẤT LƯỢNG QC (NHÓM C)

### 47. [C112] AQL Basic Rules (Quy tắc lấy mẫu)
* **Ý nghĩa & Nghiệp vụ:** Quản lý các cấu hình lấy mẫu theo quy tắc AQL cho kiểm thử IQC và OQC.
* **Cơ chế nút bấm:**
  * *Màn hình này không có nút nghiệp vụ đặc thù, chỉ sử dụng các nút CRUD cơ bản.*

### 48. [C121/C122] QC Inspection Setup (Hạng mục QC đầu vào)
* **Ý nghĩa & Nghiệp vụ:** Tạo nhóm hạng mục kiểm tra IQC/PQC/OQC (C121) và ánh xạ gán hạng mục cho từng mã NVL (C122).
* **Cơ chế nút bấm:**
  * *Các màn hình này không có nút nghiệp vụ đặc thù, chỉ sử dụng các nút CRUD cơ bản tác động lên bảng `STB_CommInspSelectGroup` và `STB_CommInspItem`.*

### 49. [C131/[C132]/[C141]/[C143]/[C151]/C153] Hạng mục QC chung & QC theo Model (QC Master Config)
* **Ý nghĩa & Nghiệp vụ:** Định nghĩa hạng mục đo (C131/C132), loại dữ liệu đầu vào (C141), gán hạng mục đo PQC cho model (C143), hạng mục OQC cho model (C151) và quy định số lượng mẫu đo kiểm (C153).
* **Cơ chế nút bấm:**
  * *Các màn hình này chỉ sử dụng các nút CRUD cơ bản.*

### 50. [C220] Đánh giá chất lượng nguyên vật liệu đầu vào (IQC Confirmation)
* **Ý nghĩa & Nghiệp vụ:** Đo kiểm và đánh giá chất lượng lô NVL mua vào trước khi cho phép nhập kho.
* **Cơ chế nút bấm:**
  * **PASS / FAIL / HOLD (Lựa chọn Đánh giá):**
    * *Nghiệp vụ:* Chốt đánh giá chất lượng cho lô nguyên vật liệu.
    * *Logic & SP:* Khi người dùng tích chọn kết quả và bấm Lưu, hệ thống sẽ thực hiện cập nhật cột kết quả chất lượng `LotDecisionResult` và cột mã kết quả `QcResultCode` trong bảng `STB_MaterialQcInfo`. 
    * *Ảnh hưởng:* Nếu chọn `PASS` → F330 cho phép nhập kho. Nếu chọn `HOLD` → Lot tự động bị chuyển vào kho ảo Holding (`HOLDING_*_WH`) để phong tỏa, không cho phép cấp phát ở F430.

### 51. [C243] QC Kiểm tra Lot Slitting (Đo điện cực cắt)
* **Ý nghĩa & Nghiệp vụ:** Ghi nhận thông số QC và đánh giá chất lượng cuộn điện cực sau khi slitting.
* **Cơ chế nút bấm đặc thù:**
  * **Đánh giá Slitting (`SlittingQcConfirm`):**
    * *Nghiệp vụ:* Chốt PASS/FAIL cho Lot slitting để quyết định có cho nhập kho điện cực.
    * *Logic & SP:* Ghi kết quả vào bảng kiểm định QC điện cực. Lot bị FAIL sẽ bị chặn không cho chuyển kho.

### 52. [C321] Sửa chữa lỗi & Báo phế sản phẩm (Defect Repair & Scrap)
* **Ý nghĩa & Nghiệp vụ:** Ghi nhận hàng lỗi cần sửa chữa hoặc báo phế trong quá trình sản xuất Cell Line.
* **Cơ chế nút bấm đặc thù:**
  * **Ghi nhận lỗi / Phế (`Execute` / `Scrap`):**
    * *Nghiệp vụ:* Chốt báo phế sản phẩm hoặc chuyển sang công đoạn sửa chữa (Rework).
    * *Logic & SP:* Thực thi SP `usp_DoProcessLossForBarcode_VNT`. SP sẽ ghi nhận chi tiết lỗi vào bảng `STB_DefectRepairInfo` và trừ trực tiếp số lượng sản phẩm phế khỏi sản lượng đạt của Lot tại công đoạn hiện tại.

### 53. [C430] QC Nhận hàng (QC Receiving)
* **Ý nghĩa & Nghiệp vụ:** Quản lý tiếp nhận Lot thành phẩm hoặc bán thành phẩm chuyển giao giữa các công đoạn hoặc nhà máy.
* **Cơ chế nút bấm:**
  * *Màn hình này không có nút nghiệp vụ đặc thù, chỉ sử dụng các nút CRUD cơ bản.*

### 54. [C443] Kiểm tra chất lượng PQC (PQC Verification)
* **Ý nghĩa & Nghiệp vụ:** Đo và chốt thông số chất lượng bán thành phẩm tại các trạm đo kiểm.
* **Cơ chế nút bấm đặc thù:**
  * **Nhập kết quả đo (`AddMeasure`):**
    * *Nghiệp vụ:* Ghi nhận giá trị đo thực tế cho từng hạng mục kiểm tra chất lượng của Lot.
    * *Logic & SP:* Gọi SP `usp_DoAddCommInspMeasureHistForBarcode` để chèn kết quả đo vào bảng chi tiết `STB_CommInspDocItem`.
  * **Hoàn thành tài liệu QC (`DoFinish`):**
    * *Nghiệp vụ:* Chốt đóng tài liệu PQC sau khi đã đo đủ các hạng mục.
    * *Logic & SP:* Gọi SP `usp_DoFinishCommInspDoc_VNT` để cập nhật trạng thái hoàn thành kiểm tra trong bảng `STB_CommInspDocHistory`.

### 55. [C451] Lập lịch OQC (OQC Schedule Setup)
* **Ý nghĩa & Nghiệp vụ:** Lập kế hoạch kiểm tra chất lượng OQC theo lô thành phẩm.
* **Cơ chế nút bấm đặc thù:**
  * **Tạo lịch OQC (`CreateOqcSchedule`):**
    * *Nghiệp vụ:* Chốt danh sách Lot và kích hoạt lịch kiểm định chất lượng xuất kho.
    * *Logic & SP:* Chèn bản ghi yêu cầu kiểm tra vào bảng lịch trình kiểm định OQC.

### 56. [C460] Báo cáo đo kiểm QC điện cực (Electrode QC Measurement)
* **Ý nghĩa & Nghiệp vụ:** Tra cứu và tổng hợp các thông số đo chất lượng điện cực.
* **Cơ chế nút bấm đặc thù:**
  * **Xuất Excel (`ExportExcel`):**
    * *Nghiệp vụ:* Xuất báo cáo đo lường chất lượng điện cực ra file Excel để kiểm tra chéo.

### 57. [C486] Error Data Sorting Layout Configuration
* **Ý nghĩa & Nghiệp vụ:** Màn hình nhập và kiểm soát chi tiết phân loại lỗi QC.
* **Cơ chế nút bấm đặc thù:**
  * **Lưu Layout lưới (`SaveLayout`):**
    * *Nghiệp vụ:* Khóa lưu thiết kế hiển thị lưới Grid hiện tại (kéo thả ẩn hiện cột) để áp dụng cho tài khoản người dùng.
    * *Logic & SP:* Hệ thống thực hiện serialization cấu hình lưới thành dạng XML và UPDATE vào bảng lưu cấu hình hệ thống `SmartFramework.dbo.STB_ScreenLayoutInfo` ứng với màn hình `ErrorDataSorting`.

### 58. [C510] Tìm kiếm Lot OQC
* **Ý nghĩa & Nghiệp vụ:** Màn hình tra cứu thông tin nhanh các Lot đang kiểm định OQC.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Truy vấn bảng `STB_MaterialQcInfo`.

### 59. [C512] Quản lý Lot kiểm tra OQC (OQC Lot Management)
* **Ý nghĩa & Nghiệp vụ:** Đăng ký Lot OQC kiểm tra chất lượng thành phẩm.
* **Cơ chế nút bấm đặc thù:**
  * **Tạo Lot OQC (`DoCreate`):**
    * *Nghiệp vụ:* Sinh bản ghi kiểm tra OQC cho thùng hàng (BoxID).
    * *Logic & SP:* Kiểm tra cấu hình kiểm tra OQC của Model trong bảng `STB_ModelBasicInfo` (phải cấu hình `OqcType` và `InspectionType`), sau đó chèn bản ghi khởi tạo OQC vào bảng `STB_MaterialQcInfo`.

### 60. [C522] Đồng bộ dữ liệu Aging ESR
* **Ý nghĩa & Nghiệp vụ:** Quản lý đồng bộ ESR kết quả lão hóa tụ điện (Aging).
* **Cơ chế nút bấm đặc thù:**
  * **Đồng bộ ESR (`SyncESR`):**
    * *Nghiệp vụ:* Kéo dữ liệu đo điện trở ESR từ trạm lão hóa Aging vào CSDL.
    * *Logic & SP:* Chạy SP quét và đồng bộ các Lot từ bảng tạm đo lường sang `STB_VVT_ESRDATA`.

### 61. [C530] Đánh giá chất lượng thành phẩm (OQC Audit)
* **Ý nghĩa & Nghiệp vụ:** Lấy mẫu đánh giá chất lượng thùng thành phẩm trước khi xuất kho.
* **Cơ chế nút bấm đặc thù:**
  * **Tổng hợp hạng mục (`MergeItems` / `Reset`):**
    * *Nghiệp vụ:* Nạp lại hoặc cập nhật danh sách các hạng mục đo từ cấu hình mới nhất tại màn hình C151.
    * *Logic & SP:* Đồng bộ lại cấu hình hạng mục đo kiểm của Model từ bảng `STB_MaterialQcInspectionItem` sang tài liệu kiểm tra OQC hiện hành của Lot.

### 62. [C531] OQC Packing (Phân loại OQC xuất hàng)
* **Ý nghĩa & Nghiệp vụ:** Thiết lập phân cấp chất lượng hàng xuất khẩu (A/B Class).
* **Cơ chế nút bấm đặc thù:**
  * **Chốt phân cấp (`ConfirmOqcRefer`):**
    * *Nghiệp vụ:* Xác nhận chốt cấp chất lượng cho lô sản phẩm đóng thùng.
    * *Logic & SP:* Thực thi SP `usp_DoProcessOQCrefer_VVT` cập nhật cột phân cấp `levelB` vào bảng giao dịch `VVT_OQC_REFER`.

### 63. [C540/C541] Báo cáo kết quả QC & Chi tiết kết quả QC
* **Ý nghĩa & Nghiệp vụ:** Hiển thị tổng hợp và chi tiết các chỉ số đo kiểm của OQC/IQC/PQC phục vụ truy xuất chất lượng.
* **Cơ chế nút bấm:**
  * **Tìm kiếm / Xuất Excel:** Lấy dữ liệu từ `STB_MaterialQcInfo` và `STB_MaterialQcDetail`.

### 64. [C546] Kiểm tra OCV/ESR đầu ra (FOQC)
* **Ý nghĩa & Nghiệp vụ:** Đo kiểm thông số điện áp OCV và điện trở ESR của mẫu thành phẩm.
* **Cơ chế nút bấm đặc thù:**
  * **Đồng bộ OCV/ESR (Lấy kết quả đo):**
    * *Nghiệp vụ:* Đồng bộ tự động các giá trị đo thực tế từ máy đo OCV/ESR vào MES.
    * *Logic & SP:* Gọi SP `usp_MaterialQcSampleResult_get` để truy vấn dữ liệu từ bảng monitor máy đo `Stb_ESRValueMonitor` và INSERT/cập nhật trực tiếp vào bảng kết quả đo mẫu `STB_MaterialQcSampleResult`.

### 65. [C560] Nhập kho thành phẩm sản xuất (Material Lot QC)
* **Ý nghĩa & Nghiệp vụ:** Chốt nhập kho thành phẩm từ sản xuất vào kho FG (Finished Goods).
* **Cơ chế nút bấm đặc thù:**
  * **Xác nhận nhập kho (`DoFix`):**
    * *Nghiệp vụ:* Xác nhận hoàn tất nhập kho thành phẩm.
    * *Logic & SP:* Thực thi SP `usp_ProductsReceiptHist_iud`. SP kiểm tra Lot thành phẩm đã có đánh giá OQC PASS chưa. Nếu PASS, tiến hành ghi lịch sử nhập kho vào bảng `STB_ProductsReceiptHist` và cập nhật tăng số lượng tồn kho thành phẩm trong bảng `STB_ProductStockInfo`.

### 66. [C585] VVT Thêm chi tiết lỗi theo Lot
* **Ý nghĩa & Nghiệp vụ:** Ghi nhận và theo dõi các lỗi sản phẩm chi tiết theo các nhóm phân loại lỗi.
* **Cơ chế nút bấm đặc thù:**
  * **Ghi nhận chi tiết lỗi (`Save`):**
    * *Nghiệp vụ:* Chốt lưu thông tin phân loại lỗi cho mã Lot.
    * *Logic & SP:* Gọi SP `usp_DoCreateQCDefectDetailsRecord_iud` để chèn bản ghi lỗi vào bảng `STB_QCDefectDetailsRecord`, và dùng mã nhóm CodeGroup = `DefectDivisionCode` trong bảng base `STB_BaseCode` của `SmartFramework` để hiển thị danh mục.

### 67. [C561/[C562]/[C563]/C564] QC công đoạn Bending / Cutting
* **Ý nghĩa & Nghiệp vụ:** Đo và chốt thông số kỹ thuật (độ bẻ cong chân, kích thước cắt vỏ) tại các công đoạn gia công cơ khí.
* **Cơ chế nút bấm:**
  * **Lưu kết quả đo:** Ghi nhận dữ liệu đo kiểm vào bảng `STB_MaterialQcDetail_BendingCutting`.

---

## 🅵 PHÂN HỆ QUẢN LÝ KHO WMS (NHÓM F)

### 68. [F110] Xác nhận nhập kho & Cấu hình kho (Warehouse Config)
* **Ý nghĩa & Nghiệp vụ:** Quản lý cấu hình kho (kho ảo, kho vật lý) và thiết lập thuộc tính quản lý tồn kho cho từng mã NVL (Barcode, FIFO, Lot tracking).
* **Cơ chế nút bấm:**
  * **Lưu cấu hình (`Save`):** Ghi/cập nhật cấu hình vào `STB_MaterialStockAttributeInfo` và `STB_MaterialWarehouse` quyết định việc chặn/mở gộp box B523.

### 69. [F140] Chỉ định nhà cung cấp - Vật tư (Assign Supplier)
* **Ý nghĩa & Nghiệp vụ:** Thiết lập quan hệ mapping giữa nguyên vật liệu và nhà cung cấp được phép để phục vụ lập phiếu mua hàng nhập kho.
* **Cơ chế nút bấm:**
  * *Màn hình này không có nút nghiệp vụ đặc thù, chỉ sử dụng các nút CRUD cơ bản.*

### 70. [F312] Tạo ghi chú đơn hàng nhập kho (Inward Slip)
* **Ý nghĩa & Nghiệp vụ:** Nhập chi tiết số lượng đơn hàng NVL mua vào từ NCC theo phiếu nhận.
* **Cơ chế nút bấm:**
  * *Màn hình này không có nút nghiệp vụ đặc thù, chỉ sử dụng các nút CRUD cơ bản tác động lên bảng `STB_MaterialDocDetail`.*

### 71. [F320] Nhập kho bán thành phẩm và nguyên vật liệu kiểm tra
* **Ý nghĩa & Nghiệp vụ:** Tiếp nhận và phân loại NVL đầu vào chờ kết quả đo kiểm chất lượng của IQC.
* **Cơ chế nút bấm:**
  * **Lưu / Cập nhật:** Ghi nhận trạng thái hàng đến chờ duyệt vào bảng `STB_MaterialDocInfo`.

### 72. [F330] Nhận nguyên vật liệu mua vào & Chia Lot (MaterialReceipt)
* **Ý nghĩa & Nghiệp vụ:** Tiếp nhận NVL từ nhà cung cấp, thực hiện chia nhỏ Lot và in tem kho.
* **Cơ chế nút bấm đặc thù:**
  * **Xử lý hàng nhập về (`DoArrival`):**
    * *Nghiệp vụ:* Xác nhận nguyên vật liệu đã về đến cổng nhà máy, chuyển trạng thái phiếu để mở tính năng chia Lot.
    * *Logic & SP:* Thực thi SP cập nhật trường `DocStatusName` từ `CREATE` sang `ARRIVAL` trong bảng phiếu nhận `STB_MaterialDocInfo`.
  * **Tạo tem (`MakeLabel` / `Chia Lot`):**
    * *Nghiệp vụ:* Chia tách cuộn/thùng lớn thành các Lot con (mã ML...) phù hợp với lượng nạp máy thực tế.
    * *Logic & SP:* Gọi SP `usp_DoCreateLabel` (hoặc `usp_DoCreateLabelManual`). SP tính số lượng Lot con cần sinh dựa trên số lượng nhận (`ReceiveQty`) và số lượng mỗi tem (`PackingQty`), sau đó thực hiện chèn hàng loạt các mã Lot `ML...` mới vào bảng thông tin Lot kho `STB_MaterialLotInfo`.
  * **In Tem (`LabelPrint`):**
    * *Nghiệp vụ:* In nhãn barcode dán lên từng cuộn/thùng NVL vừa chia Lot.
    * *Logic & SP:* Tra cứu template `PartLabel` từ mapping cấu hình và XML layout tại Z530 để in tem nhãn.
  * **Xác nhận nhập kho (`DoFix`):**
    * *Nghiệp vụ:* Chốt số lượng nhập kho thực tế sau khi đã dán tem và IQC PASS.
    * *Logic & SP:* Thực thi SP `usp_DoFixMaterialDoc`. Chốt cập nhật số lượng và khóa trạng thái phiếu trong bảng `STB_MaterialDocInfo` và `STB_MaterialDocDetail`.

### 73. [F430] Xuất kho nguyên vật liệu cấp phát ra chuyền (MaterialGI)
* **Ý nghĩa & Nghiệp vụ:** Xuất kho cấp phát nguyên vật liệu từ kho chính ra Line sản xuất.
* **Cơ chế nút bấm đặc thù:**
  * **Xác nhận xuất kho (`DoFix`):**
    * *Nghiệp vụ:* Xác nhận xuất cấp phát Lot NVL được quét ra chuyền.
    * *Logic & SP:* Thực thi SP `usp_MaterialWarehouseInOutHist_iud_ConfirmExportNVL`. SP thực hiện gọi SP con `usp_VVTMaterialWarehouse_validFIFO` để kiểm tra nguyên tắc Nhập trước - Xuất trước (FIFO) của Lot. Nếu vi phạm FIFO, chặn và báo lỗi. Nếu hợp lệ, ghi log giao dịch xuất vào bảng `STB_MaterialWarehouseInOutHist` và UPDATE di chuyển kho của Lot sang kho ảo cạnh chuyền trong bảng `STB_MaterialLotInfo` (ví dụ chuyển sang `ROUTE_WH` hoặc `ROUTE_HN_WH`).

### 74. [F610/F620] Stocktaking — Kiểm kê kho NVL
* **Ý nghĩa & Nghiệp vụ:** Lập phiếu kiểm kê và chốt số lượng chênh lệch tồn kho thực tế.
* **Cơ chế nút bấm đặc thù:**
  * **Chốt kiểm kê (`ConfirmStocktaking` - tại F610):**
    * *Nghiệp vụ:* Khóa chứng từ kiểm kê hiện tại để tiến hành đếm hàng.
    * *Logic & SP:* Cập nhật trạng thái chốt trong bảng `STB_StocktakingDoc`.
  * **Tổng hợp chênh lệch (`CalcDiscrepancy` - tại F620):**
    * *Nghiệp vụ:* Chạy đối chiếu tự động giữa số lượng đếm thực tế nhập vào và số lượng sổ sách hiện có của hệ thống WMS để tìm lượng chênh lệch thừa/thiếu.
    * *Logic & SP:* Đối chiếu dữ liệu trong bảng kết quả kiểm đếm `STB_StocktakingPlanResult` và cập nhật lượng chênh lệch để chuẩn bị chạy bút toán điều chỉnh kho.

### 75. [F710] Thẻ kho nguyên vật liệu (Stock Card)
* **Ý nghĩa & Nghiệp vụ:** Tra cứu nhật ký biến động nhập-xuất-tồn chi tiết của từng mã NVL theo thời gian.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Truy vấn lịch sử giao dịch kho từ bảng `STB_MaterialWarehouseInOutHist`.

### 76. [F721] Danh mục vật liệu tồn kho & Gán vị trí vật lý (MaterialStockList)
* **Ý nghĩa & Nghiệp vụ:** Quản lý số lượng tồn kho chi tiết từng Lot NVL và gán vị trí kệ.
* **Cơ chế nút bấm đặc thù:**
  * **Link Vị Trí (`LinkVitri`):**
    * *Nghiệp vụ:* Ánh xạ gán Lot vật tư vào vị trí kệ hàng vật lý cụ thể trong kho.
    * *Logic & SP:* UPDATE giá trị cột vị trí kệ `MaterialLocationCode` của Lot tương ứng trong bảng `STB_MaterialLotInfo`.
  * **Hủy Line Vị Trí (`HuyLinkVitri`):**
    * *Nghiệp vụ:* Gỡ Lot vật tư ra khỏi vị trí kệ hàng hiện tại.
    * *Logic & SP:* UPDATE reset cột vị trí kệ `MaterialLocationCode = NULL` trong bảng `STB_MaterialLotInfo`.

### 77. [F740] Yêu cầu tách Lot vật tư (Material Split Request)
* **Ý nghĩa & Nghiệp vụ:** Lập phiếu đề nghị kho chính tách các cuộn/thùng NVL lớn trước khi xuất cấp.
* **Cơ chế nút bấm:**
  * **Lưu yêu cầu:** Ghi bản ghi yêu cầu vào bảng `STB_MaterialSplitRequest`.

### 78. [F741] Tách Lot nguyên vật liệu (Lot Splitting)
* **Ý nghĩa & Nghiệp vụ:** Tách Lot NVL gốc thành các Lot con nhỏ hơn cấp cho sản xuất.
* **Cơ chế nút bấm đặc thù:**
  * **Xác nhận tách (`DoSplit`):**
    * *Nghiệp vụ:* Thực hiện tách Lot nguyên vật liệu.
    * *Logic & SP:* Thực thi SP `usp_DoSplitRawMaterialAndMove`. SP kiểm tra Lot cha có đang bị khóa không, số lượng tách có hợp lệ không (`SplitQty < CurrentQty`). Nếu đạt, gọi hàm sinh mã Lot con mới, chèn Lot con mới vào `STB_MaterialLotInfo` với cờ `IsSplitLot = 1`, khấu trừ số lượng tồn của Lot cha (`CurrentQty = CurrentQty - SplitQty`), và ghi lịch sử vào `STB_SupportRawMaterialSplitHist`.

### 79. [F742/F746] Lịch sử Slitting / Curling công đoạn điện cực
* **Ý nghĩa & Nghiệp vụ:** Quản lý và lưu nhật ký phân chia Lot cuộn điện cực tráng phủ (Coating Roll) sang cuộn cắt (Slitting Roll).
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Truy vấn dữ liệu từ bảng giao dịch `STB_ElectrodeCoatingInfo`.

### 80. [F743] Slitting — Tách cuộn Điện cực
* **Ý nghĩa & Nghiệp vụ:** Chia tách cuộn điện cực lớn (sau coating/rollpress) thành các cuộn nhỏ có kích thước bề rộng spec.
* **Cơ chế nút bấm đặc thù:**
  * **Tách cuộn (`DoSlitting`):**
    * *Nghiệp vụ:* Xác nhận chia nhỏ Lot cuộn điện cực.
    * *Logic & SP:* Gọi SP `usp_DoSlittingLot` hoặc `usp_DoSplitLot` để sinh Lot con và trừ sản lượng cuộn mẹ.

### 81. [F744] Slitting Width Configuration (Thiết lập dao slitting)
* **Ý nghĩa & Nghiệp vụ:** Đăng ký thông số kỹ thuật bề rộng cắt của các dao Slitting cho model.
* **Cơ chế nút bấm đặc thù:**
  * **Thiết lập chiều rộng cắt (`SetWidthConfig`):**
    * *Nghiệp vụ:* Lưu cấu hình chiều rộng slitting cho model.
    * *Logic & SP:* Ghi nhận thông số vào bảng master slitting `STB_ElectrodeSlittingResult`.

### 82. [F747/F748] Lịch sử tráng phủ & Lịch sử điện cực (Electrode Coating & History)
* **Ý nghĩa & Nghiệp vụ:** Quản lý nhật ký và thông số công đoạn tráng phủ điện cực (Coating Thickness, Speed...) và lịch sử cuộn điện cực.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Truy vấn bảng `STB_ElectrodeCoatingInfo`.

### 83. [F750] Danh mục vị trí kho vật lý
* **Ý nghĩa & Nghiệp vụ:** Khai báo cấu hình các Rack/Location (Kệ chứa hàng) trong kho nguyên vật liệu và kho thành phẩm.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa:** Thao tác CRUD tác động lên bảng danh mục vị trí kho hệ thống.

### 84. [F761] Tra cứu tồn kho theo vị trí kệ
* **Ý nghĩa & Nghiệp vụ:** Xem báo cáo tổng hợp danh sách các mã vạch nguyên vật liệu đang nằm trên từng vị trí kệ cụ thể.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Truy vấn join bảng `STB_MaterialLotInfo` và danh mục vị trí kho.

---

## 🆉 PHÂN HỆ HỆ THỐNG & PHÂN QUYỀN (NHÓM Z)

### 85. [Z110] Cấu hình tham số hệ thống (System Config)
* **Ý nghĩa & Nghiệp vụ:** Cấu hình các hằng số, tham số vận hành chung của phần mềm MES (Timeout, API link...).
* **Cơ chế nút bấm:**
  * **Lưu cấu hình (`Save`):** Ghi nhận cấu hình vào bảng tham số hệ thống.

### 86. [Z210] Danh sách người dùng hệ thống (User List)
* **Ý nghĩa & Nghiệp vụ:** Tra cứu và cập nhật trạng thái hoạt động (AllowFlag) của các tài khoản người dùng MES.
* **Cơ chế nút bấm:**
  * **Lưu / Khóa tài khoản:** Cập nhật bảng `STB_UserInfo` của `SmartFramework`.

### 87. [Z220] Phân quyền người dùng theo nhóm
* **Ý nghĩa & Nghiệp vụ:** Phân quyền truy cập các màn hình TCode cho từng nhóm người dùng.
* **Cơ chế nút bấm:**
  * **Lưu quyền (`Save`):** Ghi nhận các liên kết phân quyền vào bảng `STB_UserPermission` (SmartFramework).

### 88. [Z330] Phân quyền nhanh giao diện (Add Screen to User Group)
* **Ý nghĩa & Nghiệp vụ:** Cấp phép truy cập nhanh hàng loạt màn hình cho nhóm người dùng.
* **Cơ chế nút bấm đặc thù:**
  * **Đồng bộ màn hình (`SyncScreen`):**
    * *Nghiệp vụ:* Gán nhanh danh mục các TCode đã chọn vào nhóm quyền người dùng.
    * *Logic & SP:* Thực hiện INSERT đồng loạt các liên kết vào bảng phân quyền giao diện hệ thống.

### 89. [Z410] Tạo tài khoản người dùng MES
* **Ý nghĩa & Nghiệp vụ:** Khai báo đăng ký tài khoản người dùng mới (UserID, Mật khẩu) trong MES.
* **Cơ chế nút bấm:**
  * **Lưu (`Save`):** INSERT user mới vào bảng `STB_UserInfo` (SmartFramework).

### 90. [Z530] Thiết kế mẫu tem nhãn (Label Layout Design)
* **Ý nghĩa & Nghiệp vụ:** Thiết kế mẫu nhãn in tem vạch (XML template).
* **Cơ chế nút bấm đặc thù:**
  * **Phê duyệt mẫu tem (`Approve`):**
    * *Nghiệp vụ:* Phê duyệt và kích hoạt mẫu tem nhãn để chính thức áp dụng trong hệ thống sản xuất/kho.
    * *Logic & SP:* Cập nhật cờ `IsApproval = 1` ứng với mẫu nhãn (`FormatName` và `LabelType`) trong bảng lưu trữ tem hệ thống `SmartFramework.dbo.STB_LabelInfo`.

---

## 📦 NHÓM IN TEM KHÁCH HÀNG ĐẶC BIỆT ([B754]~[B758])

### 91. [B754/[B755]/B756] In tem khách hàng PAC
* **Ý nghĩa & Nghiệp vụ:** In nhãn sản phẩm và tem thùng Carton cho dự án khách hàng PAC.
* **Cơ chế nút bấm đặc thù:**
  * **In tem thùng Carton (tại B756):**
    * *Nghiệp vụ:* Phát hành và in nhãn dán thùng Carton ngoài.
    * *Logic & SP:* Thực thi SP `usp_PACLabelCartonWeight_get_Vietnam` để lấy danh sách in và ghi log lịch sử in vào bảng `STB_PACBoxLabelPrintHist`.
  * **In tem Cân Nặng (tại B756):**
    * *Nghiệp vụ:* In nhãn cân nặng thực tế dán lên thùng hàng.
    * *Logic & SP:* Tích chọn `IsWeightLabel` trên UI, hệ thống sẽ thực thi lấy trọng lượng thực nhập vào để sinh nhãn cân nặng tương ứng qua SP `usp_PACLabelCartonWeight_get_Vietnam`.

### 92. [B757/B758] In tem khách hàng Digi-Key
* **Ý nghĩa & Nghiệp vụ:** In nhãn sản phẩm, nhãn Logistic và nhãn thùng Mixed Load cho dự án Digi-Key.
* **Cơ chế nút bấm đặc thù:**
  * **IN NHÃN SP (tại B757):**
    * *Nghiệp vụ:* In nhãn sản phẩm Digi-Key dán trên hộp sản phẩm.
    * *Logic & SP:* Gọi SP `usp_VN_DigiKeyLabelInnerPrintHist_iud` ghi nhận lịch sử và in nhãn.
  * **IN NHÃN LOGISTIC (tại B757):**
    * *Nghiệp vụ:* In nhãn dán phục vụ khâu vận chuyển/vận tải Logistics của Digi-Key.
    * *Logic & SP:* Gọi SP `usp_VN_DigiKeyLabelInnerPrintHist_iud` với các tham số PoNo, PoLine, PackList.
  * **IN NHÃN MIXED LOAD (tại B758):**
    * *Nghiệp vụ:* In nhãn thùng trộn cho các pallet/thùng chứa nhiều loại model khác nhau.
    * *Logic & SP:* Thực thi SP `usp_VN_DigiKeySingleLevelPackagePrintHist_iud` truyền Invoice (`Pack List Number`), cân nặng tổng (`Weight`) và số kiện (`PackageCount`).

---

## 🅺/🆂 NHÓM QUẢN LÝ PHỤ TÙNG & THIẾT BỊ ĐO TỰ ĐỘNG (K/S GROUP)

### 93. [K101] Báo cáo Lot Tracking của nhà máy Bắc Giang 2 (VVT_F4)
* **Ý nghĩa & Nghiệp vụ:** Theo dõi hành trình sản xuất và chốt sản lượng của các Lot chạy tại nhà máy Bắc Giang 2.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Lọc thông tin Lot chốt theo PO và quy trình định tuyến của Bắc Giang 2.

### 94. [K109] Quản lý thông tin Spare Part (Phụ tùng dự phòng)
* **Ý nghĩa & Nghiệp vụ:** Khai báo danh mục thiết bị phụ tùng dự phòng của các máy móc sản xuất.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa:** Thao tác CRUD tác động lên bảng `STB_VNSparePartInfo`.

### 95. [K110] Spare Part IO — Xuất nhập phụ tùng máy móc
* **Ý nghĩa & Nghiệp vụ:** Nhập kho phụ tùng mua mới hoặc xuất kho phụ tùng thay thế cho máy sản xuất hỏng.
* **Cơ chế nút bấm đặc thù:**
  * **Xác nhận xuất nhập (`ConfirmIO`):**
    * *Nghiệp vụ:* Khóa chứng từ xuất/nhập phụ tùng.
    * *Logic & SP:* Gọi SP thực thi lưu lịch sử giao dịch vào bảng `STB_VNSparePartInfo` và khấu trừ/tăng số lượng tồn phụ tùng trong kho.

### 96. [K199] In tem nhãn phụ cho khách hàng (Customer Label Spec)
* **Ý nghĩa & Nghiệp vụ:** Thiết lập quy cách đóng gói và mẫu nhãn phụ dán ngoài sản phẩm cho từng khách hàng riêng biệt.
* **Cơ chế nút bấm:**
  * **Lưu / Xóa:** Cập nhật thông tin vào bảng `STB_PackingLabelSpec`.

### 97. [P111] Cấu hình thiết bị PDA cầm tay (WMS PDA Config)
* **Ý nghĩa & Nghiệp vụ:** Cấu hình quyền truy cập và phân bổ các chức năng quét kho cho từng máy PDA cầm tay.
* **Cơ chế nút bấm:**
  * **Lưu cấu hình (`Save`):** Cập nhật địa chỉ MAC và IP của máy PDA vào bảng cấu hình thiết bị PDA hệ thống.

### 98. [S212] Vision AI Camera Inspection Interface
* **Ý nghĩa & Nghiệp vụ:** Nhận kết quả và giao tiếp trực tiếp với hệ thống Camera kiểm tra ngoại quan tự động của sản phẩm.
* **Cơ chế nút bấm đặc thù:**
  * **Trigger chụp ngoại quan (`TriggerCapture`):**
    * *Nghiệp vụ:* Bắn lệnh xuống phần mềm AI Vision để bắt đầu chụp kiểm tra.
    * *Logic & SP:* MES gửi lệnh qua giao diện TCP/IP Socket/REST API, sau đó nhận kết quả ghi vào bảng lưu trữ kết quả Vision của Lot.

### 99. [S213] Tra cứu kết quả Vision AI
* **Ý nghĩa & Nghiệp vụ:** Tra cứu lịch sử kết quả đo kiểm ngoại quan bằng camera AI của các Lot sản phẩm.
* **Cơ chế nút bấm:**
  * **Tìm kiếm (`Search`):** Truy vấn dữ liệu từ bảng kết quả chụp `STB_VisionInspectionResult`.

### 100. [S215] XRF Inspection (X-Ray Fluorescence spectrometer)
* **Ý nghĩa & Nghiệp vụ:** Quản lý kết quả phân tích thành phần chất cấm/RoHS bằng máy quang phổ huỳnh quang X-ray.
* **Cơ chế nút bấm đặc thù:**
  * **Nhận dữ liệu XRF (`FetchXrfData`):**
    * *Nghiệp vụ:* Lấy kết quả đo nồng độ các chất RoHS từ máy đo để tự động xác nhận Lot đạt tiêu chuẩn môi trường.
    * *Logic & SP:* Đọc tệp dữ liệu xuất từ phần mềm máy đo XRF và import vào bảng kết quả phân tích chất của Lot trên MES.

---

## 🅷/🅷🅽/🅷🆈 MÀN HÌNH BIẾN THỂ ĐẶC THÙ HÀ NAM & HƯNG YÊN (HN/H/HY)

### 101. [HN100] HaNam Factory Dashboard
* **Ý nghĩa & Nghiệp vụ:** Bảng điều khiển trung tâm hiển thị trực quan tiến độ và hiệu suất sản xuất của nhà máy Hà Nam.
* **Cơ chế nút bấm:**
  * **Làm mới dữ liệu:** Gọi SP tổng hợp dữ liệu sản lượng và hiệu suất thiết bị toàn nhà máy Hà Nam.

### 102. [HN104] Warehouse HN (Cấu hình kho Hà Nam)
* **Ý nghĩa & Nghiệp vụ:** Thiết lập danh mục kho ảo và kho vật lý riêng biệt cho nhà máy Hà Nam (VVT_F3).
* **Cơ chế nút bấm:**
  * **Lưu cấu hình:** Ghi dữ liệu vào bảng danh mục kho Hà Nam.

### 103. [HN530] Bán thành phẩm Aging Hà Nam (Aging Warehouse HN)
* **Ý nghĩa & Nghiệp vụ:** Quản lý kho BTP bán thành phẩm trong buồng lão hóa (Aging) tại Hà Nam, kiểm tra thời gian sấy/lão hóa tối thiểu.
* **Cơ chế nút bấm đặc thù:**
  * **Tách Lot Aging (`DoSplitLotAging`):**
    * *Nghiệp vụ:* Tách nhỏ số lượng Lot trong lò Aging.
    * *Logic & SP:* Gọi SP `usp_DoSplitLotAgingHN` để sinh Lot con và khấu trừ tồn Lot cũ.
  * **Đồng bộ dữ liệu đo (`GetAgingData`):**
    * *Nghiệp vụ:* Kéo kết quả đo chất lượng OCV/ESR từ máy đo buồng Aging.
    * *Logic & SP:* Gọi SP `usp_GetDetailAgingHN_get` / `usp_GetAllDetailsAgingHN` để đồng bộ kết quả.

### 104. [HN523] Đóng gói Pallet/Box Hà Nam (Vietnam_Donggoi_Hnam)
* **Ý nghĩa & Nghiệp vụ:** Gộp các hộp nhỏ Cell thành pallet/Box lớn và in tem nhãn thùng hàng lớn tại nhà máy Hà Nam.
* **Cơ chế nút bấm đặc thù:**
  * **Gộp Packing Hà Nam (`MergePacking`):**
    * *Nghiệp vụ:* Gộp nhiều hộp nhỏ thành một pallet/Box lớn.
    * *Logic & SP:* Gọi SP `usp_MergePackingHN710_HN` chốt BoxID thùng to dán nhãn Outer.

### 105. [HN542] Chia tem và in tem đóng gói Hà Nam
* **Ý nghĩa & Nghiệp vụ:** Chia tách số lượng đóng gói để in tem con tại Hà Nam.
* **Cơ chế nút bấm đặc thù:**
  * **Chia tem đóng gói (`SplitLabel`):**
    * *Nghiệp vụ:* Chia nhỏ Lot và in tem nhãn.
    * *Logic & SP:* Thực thi SP `usp_VN_Add_ImportExcel_HN` để ghi nhận các Lot con mới tạo vào CSDL Hà Nam.

### 106. [HN544] Gộp túi bóng thành hộp nhỏ Hà Nam
* **Ý nghĩa & Nghiệp vụ:** Gom nhiều túi nilon chứa Cell thành hộp nhỏ tại dây chuyền Hà Nam.
* **Cơ chế nút bấm đặc thù:**
  * **Gộp túi bóng (`MergeBags`):**
    * *Nghiệp vụ:* Gom nhiều túi bóng Cell thành một hộp nhỏ.
    * *Logic & SP:* Gọi SP `usp_getMergePackingBoxSmall_HN` gom Lot, cập nhật cột `PackingID` và chèn vào bảng phụ `STB_MaterialLotInfo` của Hà Nam.

### 107. [HN20] Nhập kho nguyên vật liệu R&D Hà Nam
* **Ý nghĩa & Nghiệp vụ:** Tiếp nhận và nhập kho vật tư đặc biệt dành riêng cho phòng R&D Hà Nam.
* **Cơ chế nút bấm đặc thù:**
  * **Nhập kho R&D (`RnDReceipt`):**
    * *Nghiệp vụ:* Nhập vật liệu thử nghiệm.
    * *Logic & SP:* Thực thi SP `sp_Upsert_Accumulate_STB_RndRawMaterial_HN` cập nhật tồn kho R&D.

### 108. [HN21] Xuất kho nguyên vật liệu R&D Hà Nam
* **Ý nghĩa & Nghiệp vụ:** Xuất cấp phát nguyên vật liệu thử nghiệm ra phòng thí nghiệm Hà Nam.
* **Cơ chế nút bấm đặc thù:**
  * **Xuất kho R&D (`RnDIssue`):**
    * *Nghiệp vụ:* Xuất vật liệu thử nghiệm ra phòng thí nghiệm.
    * *Logic & SP:* Thực thi SP `sp_Export_WithHistory_STB_RndRawMaterial_HN`.

### 109. [HN24] Nhập kho thành phẩm R&D Hà Nam
* **Ý nghĩa & Nghiệp vụ:** Nhập kho các Cell thành phẩm nghiên cứu của R&D Hà Nam.
* **Cơ chế nút bấm đặc thù:**
  * **Nhập kho thành phẩm R&D (`RnDFGReceipt`):**
    * *Nghiệp vụ:* Xác nhận nhập kho sản phẩm R&D.
    * *Logic & SP:* Thực thi SP `ImportWarehouseFinshGood_RD_HN_uid` ghi nhận tồn kho.

### 110. [HN25] Xuất kho thành phẩm R&D Hà Nam
* **Ý nghĩa & Nghiệp vụ:** Xuất kho giao mẫu Cell R&D Hà Nam cho khách hàng.
* **Cơ chế nút bấm đặc thù:**
  * **Xuất kho thành phẩm R&D (`RnDFGIssue`):**
    * *Nghiệp vụ:* Xuất kho giao mẫu R&D.
    * *Logic & SP:* Thực thi SP `ExportWarehouseFinshGood_RD_HN_uid`.

### 111. [H101] Quản lý thiết bị hiệu chuẩn (Calibration Device)
* **Ý nghĩa & Nghiệp vụ:** Lập lịch và chốt lịch sử hiệu chỉnh/hiệu chuẩn thiết bị đo trong nhà máy.
* **Cơ chế nút bấm đặc thù:**
  * **Xác nhận hiệu chuẩn (`CalibrationConfirm`):**
    * *Nghiệp vụ:* Cập nhật ngày đo hiệu chỉnh thực tế và trạng thái đạt/không đạt của thiết bị.
    * *Logic & SP:* Cập nhật cột ngày hiệu chuẩn `LastCalibrationDate` và trạng thái thiết bị trong bảng quản lý hiệu chuẩn của nhóm H-series.

### 112. [HNC321] Reliability Scrap Input Hà Nam
* **Ý nghĩa & Nghiệp vụ:** Báo phế sản phẩm WIP tại Cell Line Hà Nam.
* **Cơ chế nút bấm đặc thù:**
  * **Báo phế Hà Nam (`ScrapHN`):**
    * *Nghiệp vụ:* Ghi nhận phế phẩm Hà Nam.
    * *Logic & SP:* Gọi SP `usp_Vietnam_ScrapInput_HN` cập nhật vào CSDL.

### 113. [HY620] Trả hàng và in tem Hưng Yên
* **Ý nghĩa & Nghiệp vụ:** Trả hàng nguyên vật liệu thừa quay lại kho tại nhà máy Hưng Yên.
* **Cơ chế nút bấm đặc thù:**
  * **Trả hàng và in tem (`ReturnMaterial`):**
    * *Nghiệp vụ:* Trả nguyên vật liệu và in tem trả hàng dán cuộn.
    * *Logic & SP:* Chạy SP kiểm tra số lượng và in tem trả hàng của Hưng Yên.

### 114. [HY740] Tách Lot Hưng Yên
* **Ý nghĩa & Nghiệp vụ:** Chia tách Lot nguyên vật liệu cấp phát tại nhà máy Hưng Yên.
* **Cơ chế nút bấm đặc thù:**
  * **Tách Lot Hưng Yên (`HY_Split`):**
    * *Nghiệp vụ:* Tách Lot tại Hưng Yên.
    * *Logic & SP:* Thực thi SP tách Lot con ở Hưng Yên, khấu trừ cuộn mẹ.

---

## 💡 Quy Tắc Tra Cứu Nhanh

```
Người dùng báo lỗi ở màn nào → Tra bảng trên → Biết ngay SP + Bảng + KB liên quan
Ví dụ:
  "Lỗi B597" → SP: usp_Vietnam_RawMaterialInputHist_uid → KB_03, KB_05, KB_14, KB_31
  "Lỗi B523" → SP: usp_Vietnam_DoProcessProdPacking_VVT → KB_03, KB_04, KB_31, KB_32
  "Lỗi F330" → SP: usp_Vietnam_MaterialGrFromOrder_get → KB_02, KB_06, KB_10, KB_31
  "Lỗi C443" → SP: usp_GetCommInspection_HistoryForBarcode_Vietnam → KB_05, KB_31, KB_32
  "Lỗi HNC321" → Lỗi tiếng Hàn → KB_05 (kịch bản khẩn cấp 3)
```

---

*Nguồn: CellLine.txt + DataFlow.md + 24 KB files — Cập nhật và Đối chiếu CSDL 2026-06-30*
