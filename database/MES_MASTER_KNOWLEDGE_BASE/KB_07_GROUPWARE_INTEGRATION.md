# KB_07: GROUPWARE & MES INTEGRATION (Nghiệp vụ Groupware)

## 1. Tổng Quan
Hệ thống Groupware (gw.vinatech.com) là nơi phê duyệt các quy trình hành chính, nhân sự, và đặc biệt là phê duyệt luồng **Mua Hàng (Purchase)**, **Kế Hoạch Sản Xuất (PO & Plan)** và **Master Data (Mã Code, BOM)** trước khi dữ liệu được đồng bộ xuống MES và ERP.

## 2. Luồng Mua Hàng & Nhập Kho (Purchase Flow)
Luồng xử lý mua hàng và kiểm tra đầu vào cần đi qua các bước kết hợp giữa Groupware và MES:
1. **Purchase Order Registration (Groupware):** Khởi tạo đơn đặt hàng. Khi được duyệt, dữ liệu đẩy xuống ERP.
2. **Arrival Confirmation (Groupware):** Khai báo hàng về đến công ty. Đối với hàng nhập khẩu, khai báo B/L và thông tin hải quan.
3. **Tiếp Nhận & In Tem (MES - F330):** Thủ kho dùng màn hình `F330` để nhận hàng thực tế và in tem nhãn (Label).
4. **IQC Inspection (MES - C220):** Đội QC kiểm tra chất lượng lô hàng. **Lưu ý: Hàng phải PASS IQC mới được đi tiếp.**
5. **Receiving Confirmation (Groupware):** Sau khi C220 Pass, nhân viên làm thao tác này trên Groupware để chính thức ghi nhận tồn kho vào hệ thống ERP và MES.
6. **Purchase Resolution (Groupware):** Đóng sổ, thanh toán chi phí cho Vendor.

## 3. Luồng Kế Hoạch Sản Xuất (PO & Production Plan)
Kế hoạch sản xuất được làm trên Groupware và đồng bộ xuống MES:
* **Month Production Plan (Groupware):** Đăng ký PO theo tháng. Cần chọn phiên bản BOM chuẩn (Version 2001 áp dụng cho Việt Nam). Chọn trạng thái là "Sản xuất" để xác nhận.
* **Đồng bộ xuống MES (B310 & B450):** 
    * Thông tin PO được link xuống màn hình `B310` (Tạo PO) trên MES.
    * Kế hoạch theo ngày (Daily Plan) được link xuống `B450` để tạo LOT sản xuất và in tem.

## 4. Master Data (Đăng Ký Code & BOM)
* **EBOM (ERP):** Mã BOM được khởi tạo trên hệ thống ERP (nhập version, thêm nguyên vật liệu, định lượng).
* **BOM Addition & Update (Groupware):** Gửi duyệt thay đổi BOM. Sau khi duyệt, BOM có hiệu lực.
* **MES Checking:** Người dùng có thể kiểm tra BOM trên MES qua `A310`, kiểm tra Code qua `A230`.
* **Item Registration Document (Groupware):** Dùng để đăng ký các mã vật tư mới thay vì làm trực tiếp trên A230 như trước kia. Gồm: `Cell` (Single Cell), `Module` (Module), `Raw material` (Nguyên vật liệu thô).

## 5. Hành Chính & Nhân Sự
Ngoài các quy trình sản xuất, Groupware quản lý các phê duyệt sau:
* **Business Trip Document:** Form đi công tác (trong nước/nước ngoài), yêu cầu làm **Business Trip Report** sau khi về để làm cơ sở thanh toán.
* **Holiday Work Request:** Form đăng ký đi làm ngày lễ/ngày nghỉ.
* **Emp Request / Employee Retire:** Tuyển dụng / Nghỉ việc.
* **Draft Document:** Trình ký văn bản nội bộ.
* **Disbursement Document:** Yêu cầu thanh toán chi phí (chọn đúng tài khoản VNĐ hoặc USD tùy vào mua trong nước hay nước ngoài).
* **Partner Management:** Đăng ký Khách hàng / Nhà cung cấp mới.

## 6. Các điểm cần chú ý khi Debug
* **Không thấy PO trên MES (B310/B450):** Kiểm tra lại trạng thái PO trên Groupware xem đã được "Xác nhận lô hàng" (chuyển sang Sản xuất) chưa, và BOM Version có đúng `2001` không.
* **Không nhập được kho F330:** Kiểm tra đơn Arrival Confirmation trên Groupware đã được duyệt chưa.
* **Không làm được Receiving Confirmation:** Kiểm tra lại lô hàng đã được đội QC test Pass trên màn hình C220 của MES chưa.
