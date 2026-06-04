# GW_04 — Master Data (Mã Code, BOM, Nhà Thầu)

> **Màn hình:** Electronic Document → Item / Basic / Production-Development
> **MES kiểm tra:** A230 (Code), A310 (BOM), B310 (PO)
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 📦 Đăng Ký Mã Vật Tư Mới (Item Registration)

**Vào:** Electronic Document → Item → Item Registration Document

> ⚠️ **Bối cảnh:** Trước đây dùng màn A230 trên MES. Hiện nay EA HQ yêu cầu đăng ký trên Groupware thay thế.

### Bước 1: Chọn thông tin phê duyệt
1. Chọn người duyệt.
2. Ghi tiêu đề biểu mẫu.
3. Tải file đính kèm (nếu có).
4. Chọn người làm form hộ (nếu cần) - sử dụng khi làm thay cho người khác.

### Bước 2: Chọn kiểu code và phân loại tài liệu
Chọn đường line phê duyệt tương thích chính xác với phân loại:
- **[Cell]** → Chọn line **Single Cell**
- **[Module]** → Chọn line **Module**
- **[Raw material]** → Chọn line **Raw materials**

### Bước 3: Điền thông tin code (Các nút chức năng trên lưới tab)
- **Add:** Thêm một tab mới để đăng ký đồng thời một mã code khác.
- **Copy:** Sao chép nguyên vẹn nội dung của tab trước đó. Đây là tính năng **"Copy thông số cũ sửa lại"** giúp quản lý khai báo nhanh chóng mà không cần nhập lại từ đầu khi đăng ký các sản phẩm tương đương.
- **Delete:** Xóa tab hiện hành nếu không cần thiết.

**Thông tin kỹ thuật bắt buộc nhập:**
- **Kiểu của mã code:** Bán thành phẩm hoặc Nguyên vật liệu.
- **Thông số kỹ thuật (Spec Values):**
  - **Voltage (Điện áp cấu hình):** Ví dụ: `12- 3.0 C035`.
  - **Farad (Tiêu chuẩn tiết diện/kích cỡ Điện dung Faraday):** Ví dụ: `3.5 mm`.

### Bước 4: Thông tin yêu cầu (Request Information)
- **Loại hàng:** Chọn hàng để phát triển (**Dev**) hoặc sản xuất hàng loạt (**Mass Production**).
- **Tên khách hàng:** Nhập tên đối tác thụ hưởng.
- **Bộ phận sản xuất:** Khai báo nhóm bộ phận chịu chi phí / thụ hưởng kinh phí khi sản xuất mặt hàng này (Cost Center).
- **Người dùng code:** Khai báo người trực tiếp quản lý/sử dụng mã code này.
- **Ngày đặt hàng dự kiến:** Khai báo thời hạn dự kiến đối tác đặt hàng.

### Bước 5: Kiểm tra chi tiết (Detail Check)
Hệ thống hiển thị lưới thông tin kiểm kê chi tiết:
1. Đơn vị đo lường.
2. Danh mục loại hàng.
3. Phân loại hàng.
4. Nhóm danh mục sản phẩm.
5. Kích cỡ con hàng.
6. Kiểu mua sắm con hàng.
7. Kiểu loại mặt hàng.
8. Kiểu giao dịch (Trong nước hay nước ngoài).

---

## 2. ✏️ Cập Nhật Thông Tin Mã Code (Item Change)

**Vào:** Electronic Document → Item → Item Change Document

1. Nhấn nút **"Tìm kiếm mặt hàng"** → Một cửa sổ popup hiện ra.
2. Tìm kiếm và chọn mã code cần cập nhật thông tin → Nhấn **"Áp dụng lựa chọn"**. Hệ thống sẽ tự động hiển thị mã code và các thông tin đi kèm.
3. Cập nhật lại các trường thông tin cần thiết:
   - **Kiểu loại mua hàng** (Purchase Type)
   - **Kho đưa vào** (Incoming Warehouse)
   - **Kho đưa ra** (Outgoing Warehouse)
   - **Bộ phận chịu cost** (Cost Center)
4. Nhập nội dung giải thích lý do cần cập nhật (6).
5. Thực hiện các thao tác ở chân trang:
   - **Gửi đi (1):** Gửi tới người duyệt.
   - **Lưu tạm thời (2):** Lưu nháp vào Temporary Storage để chỉnh sửa/gửi sau.
   - **Xóa (3):** Xóa biểu mẫu hiện tại.
   - **Xem trước (4):** Review tổng thể form trước khi gửi.
   - **Reset (5):** Xóa hết dữ liệu nhập lại từ đầu.


---

## 3. 🧩 Tạo / Sửa BOM

### 3.1 Tạo BOM trên ERP (EBOM)

**Vào:** ERP → Tìm kiếm "EBOM" trên thanh công cụ

1. Chọn mã code thành phẩm/bán thành phẩm
2. Nhấn Tìm kiếm
3. Nhập phiên bản BOM:
   > [!WARNING]
   > **CẢNH BÁO BẮT BUỘC:** Mọi nhân sự/công nhân Việt Nam khi đăng ký phiên bản BOM trên hệ thống bắt buộc phải chọn hoặc nhập đúng mã BOM version code chuẩn mực của Việt Nam là **2001**. Tuyệt đối không chọn hoặc nhập version khác.
4. Thêm dòng dữ liệu
5. Chọn mã nguyên vật liệu
6. Chọn số lượng NVL
7. Lưu lại

**Cập nhật BOM đã có:**
1. Tìm mã code thành phẩm
2. Nhấn Tìm kiếm → chọn phiên bản cần sửa (chọn bản **2001**)
3. Thay đổi thông tin → Lưu

### 3.2 Phê Duyệt BOM trên Groupware

**Vào:** Electronic Document → Production/Development → BOM Addition And Update Document

| Bước | Thao tác |
|------|----------|
| 1 | Chọn line phê duyệt |
| 2 | Đặt tên form |
| 3 | Đính kèm file |
| 4 | Thêm mục / tìm kiếm code → Hệ thống tự sinh các mã đi kèm |
| 5 | Ghi chú / giải thích lý do thay đổi (chèn Note giải thích rõ ràng lý do thay đổi để trình Approve) |
| 6 | Gửi đi duyệt |

### 3.3 Kiểm Tra BOM Sau Khi Duyệt & Đồng Bộ MES

Tiến trình đồng bộ BOM từ ERP/Groupware sang MES sẽ tự động chạy sau khi được duyệt:
- **A310 (Màn Quản Trị MES):** Sử dụng để kiểm tra BOM đã đồng bộ chính xác chưa.
- **B310 (Màn Giám Sát PO cấp xưởng MES):** Xem khi làm PO xem BOM đã được áp dụng.
- **A230 (Màn Thiết Lập MES):** Xem lại mã code.

---

## 4. 🏢 Đăng Ký Nhà Thầu / Khách Hàng (Partner Management)

**Vào:** Electronic Document → Basic → Partner Management

### 4.1 Quy trình đăng ký mới:
1. **Chọn line phê duyệt:** Chọn line có sẵn hoặc thiết lập người duyệt.
2. **Điền thông tin cơ bản:** Tiêu đề, đính kèm tài liệu doanh nghiệp, điền người làm hộ (nếu đăng ký giúp người khác - hệ thống mặc định lấy tên người đăng nhập).
3. **Các trường thông tin bắt buộc:**
   - **Quốc gia:** Nước đặt trụ sở đối tác.
   - **Tên công ty:** Tên đăng ký doanh nghiệp (DKKD) đầy đủ.
   - **Người đại diện:** Tên Giám đốc đại diện pháp lý.
   - **Email:** Email liên hệ giao dịch chính.
   - **Mã số thuế:** ⚠️ **Bắt buộc nhập chính xác tuyệt đối**.
   - **Danh mục thuế:** Thường chọn **"Người nộp thuế chung"** (do doanh nghiệp thường có cả hoạt động mua và bán).
   - **Công ty chính/con:** Thường chọn **N** (Không phải công ty con).
   - **Định dạng hóa đơn:** Chọn định dạng hóa đơn phát hành của đối tác.
   - **Mục đích:** Phân loại định tuyến ngầm (Khách hàng bán hàng/Khách Bán, Khách hàng mua hàng/Khách Mua, Công ty thẻ tín dụng, Đối tác ngân hàng).
   - **Phân loại:** Mua, Bán, hoặc Khác.
   - **Loại hình & Lĩnh vực kinh doanh:** Điền ngành nghề, lĩnh vực đối tác hoạt động.
   - **Địa chỉ chi tiết:** Nhập địa chỉ chi tiết (thường nhập cả địa chỉ tiếng Anh/Hàn và tiếng Việt vào 2 trường địa chỉ tương ứng).
   - **Trạng thái:** Còn hoạt động hay không.
   - **Sử dụng:** Chọn **Use** để kích hoạt sử dụng ngay trên toàn hệ thống cho mọi người dùng, **không chọn** *For mass use* (trạng thái nháp, thụ động chưa sử dụng).
4. **Thông tin ngân hàng giao dịch:**
   - Chọn ngân hàng giao dịch của đối tác.
   - Nhập chính xác số tài khoản và tên tài khoản/số thẻ thụ hưởng của đối tác.
5. **Thực hiện gửi duyệt:**
   - Viết ghi chú chi tiết về đối tác (ở khung nội dung).
   - Nhấn **"Gửi đi"** (1) để trình duyệt, hoặc **"Lưu trữ tạm thời"** (2) để nháp, hoặc **"Xem trước"** (4) để review lại form, hoặc **"Reset"** (5) để làm lại mới hoàn toàn.

### 4.2 Cập nhật thông tin đối tác:
**Vào:** Electronic Document → Basic → Modify Partner Management

1. Chọn line phê duyệt cho form cập nhật.
2. Đặt tiêu đề và đính kèm tệp tin liên quan (ví dụ: DKKD mới, thay đổi thông tin tài khoản ngân hàng).
3. Nhấp chọn mục **"Chọn nhà thầu/vendor/khách hàng cần thay đổi thông tin"** → Tìm kiếm và click chọn đối tác tương ứng.
4. Tại form thông tin hiển thị, trực tiếp nhập đè dữ liệu mới vào các textbox hoặc chọn lại combo box cần thay đổi.
5. Ghi rõ lý do thay đổi ở phần nội dung và nhấn **"Gửi đi"** / **"Lưu trữ tạm thời"** / **"Xem trước"**.

---

*Cập nhật: 2026-06-04 | Nguồn: Hướng dẫn đăng ký các loại code.pptx + Hướng dẫn sửa đổi BOM.pptx + Hướng dẫn Groupware_Form đăng ký nhà thầu_khách hàng.pptx + Comprehensive_Groupware_Report.md*

