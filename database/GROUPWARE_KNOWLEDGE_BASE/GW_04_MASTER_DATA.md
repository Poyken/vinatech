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
| **Copy** | Copy nội dung tab trước, chỉnh sửa lại |
| **Delete** | Xóa tab không cần |

Các trường cần điền:
- **Kiểu code:** Bán thành phẩm / Nguyên vật liệu
- **Voltage:** VD: `12-3.0 C035`
- **Farad:** VD: `3.5 mm`

### Bước 4: Thông tin yêu cầu (Request Information)
- Loại hàng: Phát triển hay sản xuất hàng loạt
- Tên khách hàng
- Bộ phận sản xuất
- Người dùng code
- Ngày đặt hàng dự kiến

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
3. Nhập phiên bản BOM
4. Thêm dòng dữ liệu
5. Chọn mã nguyên vật liệu
6. Chọn số lượng NVL
7. Lưu lại

**Cập nhật BOM đã có:**
1. Tìm mã code thành phẩm
2. Nhấn Tìm kiếm → chọn phiên bản cần sửa
3. Thay đổi thông tin → Lưu

### 3.2 Phê Duyệt BOM trên Groupware

**Vào:** Electronic Document → Production/Development → BOM Addition And Update Document

| Bước | Thao tác |
|------|----------|
| 1 | Chọn line phê duyệt |
| 2 | Đặt tên form |
| 3 | Đính kèm file |
| 4 | Thêm mục / tìm kiếm code → Hệ thống tự sinh các mã đi kèm |
| 5 | Ghi chú / giải thích lý do thay đổi |
| 6 | Gửi đi duyệt |

### 3.3 Kiểm Tra BOM Sau Khi Duyệt

| Màn hình MES | Mục đích |
|--------------|----------|
| **A310** | Kiểm tra BOM |
| **B310** | Xem khi làm PO |
| **A230** | Xem lại mã code |

---

## 4. 🏢 Đăng Ký Nhà Thầu / Khách Hàng (Partner Management)

**Vào:** Electronic Document → Basic → Partner Management

### Đăng ký mới:
| Trường | Mô tả |
|--------|-------|
| Quốc gia | Nước của công ty đối tác |
| Tên công ty | Tên đầy đủ |
| Người đại diện | Tên đại diện pháp lý |
| Email | Email liên hệ chính |
| Mã số thuế | MST của doanh nghiệp |
| Danh mục thuế | Thường chọn "Người nộp thuế chung" |
| Công ty chính/con | Thường chọn **N** (không phải công ty con) |
| Định dạng hóa đơn | Chọn kiểu hóa đơn phát hành |
| Mục đích | Khách hàng mua, bán, công ty thẻ tín dụng, ngân hàng |
| Phân loại | Mua / Bán / Khác |
| Ngân hàng | Ngân hàng giao dịch + số tài khoản |
| Trạng thái | Còn hoạt động hay không |
| Use / For mass use | **Use** = Đã dùng | **For mass use** = Chưa dùng |

### Cập nhật thông tin đối tác:
**Vào:** Electronic Document → Basic → Modify Partner Management

1. Chọn người phê duyệt
2. Đặt tiêu đề, đính kèm file
3. Tìm và chọn nhà thầu/khách hàng cần cập nhật
4. Thay đổi thông tin → Gửi đi duyệt

---

*Cập nhật: 2026-05-18 | Nguồn: Hướng dẫn đăng ký các loại code.pptx + Hướng dẫn sửa đổi BOM.pptx*
