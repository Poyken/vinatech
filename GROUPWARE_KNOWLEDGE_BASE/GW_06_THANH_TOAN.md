# GW_06 — Yêu Cầu Thanh Toán (Disbursement Document)

> **Màn hình:** Electronic Document → Cost → Disbursement Document
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 💳 Tạo Yêu Cầu Thanh Toán

**Vào:** Electronic Document → Cost → Disbursement Document

### Bước 1: Chọn đường line phê duyệt

### Bước 2: Điền thông tin form
- Đặt tên form (tiêu đề)
- **Đính kèm file liên quan:** Ở phần Attachment, người dùng tải lên phiếu hoá đơn hoặc vận đơn làm cơ sở xác thực số tiền cước phí cho Phòng Kế toán (Ví dụ: file PDF mang tên `Bee Logistics_Vina tech_By_Air_Inv-2925431946.pdf`). Kế toán sẽ nhìn trực tiếp vào **Lịch sử Liên Kết Tài Liệu kéo thả** trong tab Cost để kiểm tra Audit bất cứ lúc nào mà không cần đòi hỏi bản cứng.
- Chọn người làm form hộ (nếu cần)

### Bước 3: Chọn nguồn thanh toán & Cơ chế kéo chuỗi liên kết
Để thực hiện gom và xác nhận chi tiền:
- **Cách 1 — Liên kết từ các Đơn mua hàng (PO) đã duyệt:**
  - Nhấn nút **"Liên kết tài liệu"**
  - Chọn định dạng tài liệu cần kết nối.
  - Tích chọn một hoặc nhiều Đơn Mua Sắm đã được phê duyệt ở bước trước để ghim lên form. **Cơ chế kéo chuỗi** này cho phép gom nhiều form mua hàng thành một lệnh thanh toán duy nhất.
- **Cách 2 — Thêm trực tiếp đối tác (Vendor):**
  - Nhấn nút thêm trực tiếp vendor cần thanh toán nếu không cần liên kết form PO trước đó.

### Bước 4: Chọn tài khoản thanh toán và Tín dụng (Credit Account)
- Bắt buộc click chọn nút **"Tín dụng"** (hoặc tài khoản thanh toán tương ứng) để phân định tài khoản thanh toán tiền, loại hóa đơn.
- **Chọn đúng loại tài khoản thanh toán theo đồng tiền giao dịch:**

| Trường hợp | Tài khoản cần chọn |
|-----------|-------------------|
| Mua hàng **trong nước** (VNĐ) | Tài khoản **VNĐ Việt Nam** |
| Mua hàng **nước ngoài** (USD) | Tài khoản **USD** |

### Bước 5: Chọn mã tài khoản (Bản ghi nợ)
- Click **"Bản ghi nợ"** → Cửa sổ mới hiển thị tất cả mã tài khoản theo loại hàng
- Tìm và chọn mã tài khoản phù hợp với loại hàng cần thanh toán (Bút toán Phân kỳ Cost)

### Bước 6: Điền thông tin hóa đơn và chi phí
| Trường | Mô tả |
|--------|-------|
| Loại hóa đơn (1) | Chọn kiểu hóa đơn |
| Phòng ban chịu chi phí (2) | Mục này thuộc bộ phận nào |

### Bước 7: Chọn ngày thanh toán
Phòng Kế toán sẽ có lịch giải ngân cố định trước:
- **Ngày thanh toán cố định:** Ngày đã fix sẵn theo quy định giải ngân hàng tháng của công ty (Ví dụ: **ngày 15** và **ngày 30** hàng tháng).
- **Ngày user tự chọn:** Chọn ngày khác theo nhu cầu thực tế của User. Tuy nhiên, để được phê duyệt, User **bắt buộc phải thỏa thuận trước** với phòng Kế toán, nếu không kế toán có quyền từ chối ngày thanh toán.

### Bước 8: Trường hợp mua hàng có VAT / Ngoại tệ

| Trường hợp | VAT | Ngoại tệ |
|-----------|-----|----------|
| Mua hàng **trong nước** | Phải nhập VAT | Không cần |
| Mua hàng **nước ngoài** | Không cần VAT | Cần chọn tỷ giá (tự nội suy tại thời điểm làm form) |

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
| Kế toán từ chối ngày thanh toán | Ngày tự chọn không hợp lệ hoặc chưa thỏa thuận | Chọn ngày thanh toán cố định theo quy định hoặc thỏa thuận lại |

---

*Cập nhật: 2026-05-25 | Nguồn: Hướng dẫn groupware_Yêu cầu thanh toán.pptx + Hướng dẫn Groupware_Yêu cầu mua.pptx + Comprehensive_Groupware_Report.md*
