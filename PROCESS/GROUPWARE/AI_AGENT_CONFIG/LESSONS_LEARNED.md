# 📚 LESSONS LEARNED — KINH NGHIỆM VẬN HÀNH GROUPWARE VINATECH

> **Cập nhật:** 2026-09-21 | **Mục đích:** Ghi nhận các bài học và tình huống sự cố thực tế đã xử lý trên hệ thống Groupware Vinatech để tránh lặp lại sai lầm.

---

## 💡 1. Bài Học Về CSDL & Luồng Dữ Liệu

### Bài học 1: Không được Update trạng thái `DOCUMENT_SAVE_STATE` thủ công bằng SQL
- **Hiện tượng:** Khi một phiếu Purchase Order bị kẹt ở trạng thái `002` do người duyệt nghỉ việc, IT từng chạy câu lệnh:
  `UPDATE VINA_DOCUMENT_SAVE SET DOCUMENT_SAVE_STATE = '008' WHERE DOCUMENT_SAVE_CODE = '...'`
- **Hậu quả:** Trạng thái trên giao diện web hiện "Approved", nhưng **ERP Douzone (NEOE) hoàn toàn không có dữ liệu đơn hàng**!
- **Nguyên nhân cốt lõi:** Khi người dùng nhấn nút duyệt trên Web GUI, Groupware gọi qua Web API và chạy một chuỗi Store Procedures để đồng bộ sang ERP (`PU_PO`, `PU_POL`). Update trực tiếp DB sẽ bỏ qua toàn bộ logic đồng bộ này.
- **Cách xử lý chuẩn:** Điều chuyển phiếu sang người duyệt thay thế hợp lệ trên giao diện, hoặc sử dụng tool/SP chính thức để kích hoạt trigger đồng bộ.

---

### Bài học 2: Bẫy tỷ giá ngoại tệ (Exchange Rate) đối với đơn mua nước ngoài (Overseas PO)
- **Hiện tượng:** Tạo đơn PO mua từ công ty mẹ Hàn Quốc (Partner `13000`) bị báo lỗi `Invalid Currency Conversion Rate`.
- **Nguyên nhân:** Người tạo form chọn loại tiền tệ KRW hoặc USD nhưng Kế toán chưa cập nhật bảng tỷ giá ngày trên phân hệ Kế toán Bizbox.
- **Cách xử lý chuẩn:** Kiểm tra bảng tỷ giá hối đoái ngày trước khi lập PO nước ngoài, hoặc liên hệ bộ phận Kế toán nhập tỷ giá chính thức.

---

### Bài học 3: Mắt xích IQC C220 giữa MES và Groupware
- **Hiện tượng:** Nhân viên kho và Mua hàng tranh cãi vì thủ kho đã nhận hàng F330 nhưng Mua hàng không làm được phiếu `Receiving Confirmation` để thanh toán cho đối tác.
- **Nguyên nhân:** Thủ kho in tem nhận hàng mới chỉ là bước "Khai báo hàng đến". Hàng bắt buộc phải qua QC kiểm tra trên màn hình **MES C220** và nhấn **PASS** thì cờ dữ liệu mới được bật cho Groupware.
- **Cách xử lý chuẩn:** Theo dõi tiến độ kiểm định trên màn hình C220 trước khi yêu cầu làm Receiving Confirmation.
