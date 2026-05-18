# GW_06 — Yêu Cầu Thanh Toán (Disbursement Document)

> **Màn hình:** Electronic Document → Cost → Disbursement Document
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 💳 Tạo Yêu Cầu Thanh Toán

**Vào:** Electronic Document → Cost → Disbursement Document

### Bước 1: Chọn đường line phê duyệt

### Bước 2: Điền thông tin form
- Đặt tên form (tiêu đề)
- Đính kèm file liên quan
- Chọn người làm form hộ (nếu cần)

### Bước 3: Chọn nguồn thanh toán

**Cách 1 — Link từ form yêu cầu mua đã duyệt:**
- Nhấn **"Liên kết tài liệu" (nút 1)**
- Chọn định dạng tài liệu cần kết nối (form yêu cầu mua đã approved)
- Chọn một hoặc nhiều form → Áp dụng

**Cách 2 — Thêm trực tiếp vendor:**
- Nhấn **"Nút 2"** → Thêm mới vendor cần thanh toán (không cần có form yêu cầu mua trước)

### Bước 4: Chọn tài khoản thanh toán (Tín dụng)

> ⚠️ **Quan trọng:** Chọn đúng loại tài khoản theo đồng tiền:

| Trường hợp | Tài khoản cần chọn |
|-----------|-------------------|
| Mua hàng **trong nước** (VNĐ) | Tài khoản **VNĐ Việt Nam** |
| Mua hàng **nước ngoài** (USD) | Tài khoản **USD** |

### Bước 5: Chọn mã tài khoản (Bản ghi nợ)
- Click **"Bản ghi nợ"** → Cửa sổ mới hiển thị tất cả mã tài khoản theo loại hàng
- Tìm và chọn mã tài khoản phù hợp với loại hàng cần thanh toán

### Bước 6: Điền thông tin hóa đơn và chi phí
| Trường | Mô tả |
|--------|-------|
| Loại hóa đơn (1) | Chọn kiểu hóa đơn |
| Phòng ban chịu chi phí (2) | Mục này thuộc bộ phận nào |

### Bước 7: Chọn ngày thanh toán

| Lựa chọn | Mô tả |
|----------|-------|
| **Ngày thanh toán cố định (1)** | Ngày đã fix sẵn theo quy định trong tháng |
| **Ngày user chọn (2)** | Ngày khác — cần kế toán đồng ý |

> 💡 Mục số 2 (ngày tự chọn) phụ thuộc vào việc kế toán có đồng ý hay không.

### Bước 8: Trường hợp mua hàng có VAT / Ngoại tệ

| Trường hợp | VAT | Ngoại tệ |
|-----------|-----|----------|
| Mua hàng **trong nước** | Phải nhập VAT | Không cần |
| Mua hàng **nước ngoài** | Không cần VAT | Cần chọn tỷ giá (tính tại thời điểm làm form) |

> ⚠️ Cả 2 trường hợp **đều phải nhập số tiền của nhà cung cấp**.

---

## 2. 🔔 Trả Lời Câu Hỏi Từ Người Duyệt

Nếu người duyệt có câu hỏi trong quá trình duyệt:
1. Thông báo hiển thị trong form
2. Click vào thông báo → Gõ câu trả lời
3. Click **"Xác nhận"** để gửi câu trả lời

---

## 3. ✅ Quy Trình Duyệt Form (Dành Cho Người Duyệt)

**Vào:** Electronic Document → Approval Documents

Khi nhận được yêu cầu duyệt:
- Email tự động gửi đến người duyệt
- Hoặc vào hệ thống → Bảng hiển thị các form chờ duyệt

### 3 lựa chọn khi duyệt:
| Lựa chọn | Hành động |
|----------|-----------|
| **Duyệt (nút trái)** | Chấp thuận form |
| **Từ chối/Reject (nút đỏ giữa)** | Không đồng ý |
| **Đặt câu hỏi (nút phải)** | Gửi câu hỏi về cho người tạo |

---

## 4. ❓ Lỗi Thường Gặp

| Tình huống | Nguyên nhân | Xử lý |
|-----------|-------------|-------|
| Không tìm thấy form yêu cầu mua để link | Form chưa được duyệt | Chờ form yêu cầu mua được duyệt |
| Sai tài khoản thanh toán | Chọn VNĐ thay vì USD hoặc ngược lại | Kiểm tra lại đồng tiền giao dịch |
| Kế toán từ chối ngày thanh toán | Ngày tự chọn không hợp lệ | Chọn ngày thanh toán cố định theo quy định |

---

*Cập nhật: 2026-05-18 | Nguồn: Hướng dẫn groupware_Yêu cầu thanh toán.pptx + Hướng dẫn Groupware_Yêu cầu mua.pptx*
