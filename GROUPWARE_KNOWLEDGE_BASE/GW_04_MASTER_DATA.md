# GW_04 — Master Data (Mã Code, BOM, Nhà Thầu)

> **Màn hình:** Electronic Document → Item / Basic / Production-Development
> **MES kiểm tra:** A230 (Code), A310 (BOM), B310 (PO)
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 📦 Đăng Ký Mã Vật Tư Mới (Item Registration)

**Vào:** Electronic Document → Item → Item Registration Document

> ⚠️ **Bối cảnh:** Trước đây dùng màn A230 trên MES. Hiện nay EA HQ yêu cầu đăng ký trên Groupware thay thế.

### Bước 1: Chọn thông tin phê duyệt
1. Chọn người duyệt
2. Ghi tiêu đề form
3. Tải file đính kèm (nếu có)
4. Chọn người làm form hộ (nếu cần)

### Bước 2: Chọn kiểu code

| Loại code | Đường line phê duyệt |
|-----------|---------------------|
| **Cell** | Single Cell |
| **Module** | Module |
| **Raw material** | Raw materials |

### Bước 3: Điền thông tin code

| Tab | Chức năng |
|-----|-----------|
| **Add** | Thêm tab mới để nhập code khác |
| **Copy** | Copy nội dung tab trước, chỉnh sửa lại (Tính năng **"Copy thông số cũ sửa lại"** giúp quản lý khai báo nhanh chóng mà không cần nhập lại từ đầu khi đăng ký các sản phẩm tương đương) |
| **Delete** | Xóa tab không cần |

Các trường cần điền:
- **Kiểu code:** Bán thành phẩm / Nguyên vật liệu
- **Thông số kỹ thuật (Spec Values):**
  - **Voltage (Điện áp cấu hình):** VD: `12-3.0 C035`
  - **Farad (Tiêu chuẩn tiết diện/kích cỡ Điện dung Faraday):** VD: `3.5 mm`

### Bước 4: Thông tin yêu cầu (Request Information)
- **Loại hàng:** Sản xuất chạy thử/phát triển (**Dev**) hoặc Sản xuất hàng loạt (**Mass Production**).
- **Tên khách hàng**
- **Bộ phận sản xuất:** Khai báo nhóm bộ phận hưởng lượng kinh phí khi làm ra mặt hàng này.
- **Người dùng code**
- **Ngày đặt hàng dự kiến:** Khai báo dự kiến đơn hàng bao giờ Order.

### Bước 5: Kiểm tra chi tiết (Detail Check)
- Đơn vị, danh mục, phân loại, nhóm sản phẩm, kích cỡ
- Kiểu mua sắm, kiểu mặt hàng, trong nước/nước ngoài

---

## 2. ✏️ Cập Nhật Thông Tin Mã Code (Item Change)

**Vào:** Electronic Document → Item → Item Change Document

1. Nhấn **"Tìm kiếm mặt hàng"** → Tìm và chọn mã code cần cập nhật
2. Hệ thống tự động hiển thị các mã code đi kèm
3. Cập nhật thông tin cần thay đổi:
   - Kiểu loại mua hàng
   - Kho đưa vào / đưa ra
   - Bộ phận chịu cost
4. Ghi lý do cập nhật → Gửi đi duyệt

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

### Đăng ký mới:
| Trường | Mô tả |
|--------|-------|
| Quốc gia | Nước của công ty đối tác |
| Tên công ty | Tên Đăng ký Doanh nghiệp (DKKD) đầy đủ |
| Người đại diện | Tên Giám đốc đại diện pháp lý |
| Email | Email liên hệ chính của công ty |
| Địa chỉ | Địa chỉ thực tế của doanh nghiệp |
| Mã số thuế | **Bắt buộc** điền chính xác mã số thuế |
| Danh mục thuế | Thường chọn "Người nộp thuế chung" |
| Công ty chính/con | Thường chọn **N** (không phải công ty con) |
| Định dạng hóa đơn | Xác định định dạng hóa đơn phát hành |
| Mục đích | Định tuyến ngầm Customer Business: Khách hàng mua (Khách Mua) / Nhà cung cấp bán (Khách Bán) / Thẻ tín dụng tổ chức / Ngân hàng thụ hưởng |
| Phân loại | Mua / Bán / Khác |
| Ngân hàng | Khai báo chính xác ngân hàng giao dịch và số tài khoản/số thẻ |
| Trạng thái | Còn hoạt động hay không |
| Use / For mass use | Đặt cờ trạng thái **Use** (Lưu lên hệ thống cho mọi người dùng cùng sử dụng) chứ không chọn **For mass use** (Bản nháp thụ động) |

### Cập nhật thông tin đối tác:
**Vào:** Electronic Document → Basic → Modify Partner Management

1. Chọn người phê duyệt
2. Đặt tiêu đề, đính kèm file
3. Tìm và chọn nhà thầu/khách hàng cần cập nhật
4. Thay đổi thông tin → Gửi đi duyệt

---

*Cập nhật: 2026-05-25 | Nguồn: Hướng dẫn đăng ký các loại code.pptx + Hướng dẫn sửa đổi BOM.pptx + Comprehensive_Groupware_Report.md*
