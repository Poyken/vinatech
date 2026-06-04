# GW_06 — Yêu Cầu Thanh Toán (Disbursement Document)

> **Màn hình:** Electronic Document → Cost → Disbursement Document
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 💳 Tạo Yêu Cầu Thanh Toán

**Vào:** Electronic Document → Cost → Dusbursenment Document (Lưu ý: Màn hình này trên menu hệ thống bị viết sai chính tả thành **"Dusbursenment Document"** thay vì *Disbursement*)

### Bước 1: Chọn đường line phê duyệt
- Thiết lập đường line phê duyệt phù hợp.

### Bước 2: Điền thông tin form cơ bản
- Đặt tên form (tiêu đề biểu mẫu).
- **Đính kèm file liên quan:** Ở phần Attachment, người dùng tải lên phiếu hoá đơn hoặc vận đơn làm cơ sở xác thực số tiền cước phí cho Phòng Kế toán (Ví dụ: file PDF hóa đơn vận chuyển đường hàng không mang tên [Bee Logistics_Vina tech_By_Air_Inv-2925431946.pdf](attachments/Bee%20Logistics_Vina%20tech_By_Air_Inv-2925431946.pdf)). Kế toán sẽ nhìn trực tiếp vào **Lịch sử Liên Kết Tài Liệu kéo thả** trong tab Cost để kiểm tra Audit bất cứ lúc nào mà không cần đòi hỏi bản cứng.
- Chọn người làm form hộ (nếu đăng ký giúp người khác).

### Bước 3: Chọn nguồn thanh toán & Cơ chế kéo chuỗi liên kết
Để thực hiện gom và xác nhận chi tiền:
- **Cách 1 — Liên kết từ các Đơn mua hàng (Expense Report / PO) đã duyệt:**
  - Nhấn nút **"Liên kết tài liệu"** (1).
  - Hộp thoại popup hiện ra, ở combo box chọn loại tài liệu liên kết → Nhấn **"Kiểm tra"** để tải danh sách các form Expense Report đã approved.
  - Tích chọn một hoặc nhiều Đơn Mua Sắm đã được phê duyệt ở bước trước để ghim lên form. **Cơ chế kéo chuỗi** này cho phép gom nhiều form mua hàng thành một lệnh thanh toán duy nhất.
- **Cách 2 — Thêm trực tiếp đối tác (Vendor):**
  - Nhấn nút thêm trực tiếp vendor (2) cần thanh toán nếu không cần liên kết form PO trước đó.

### Bước 4: Chọn tài khoản thanh toán và Tín dụng (Credit Account)
- Bắt buộc click chọn nút **"Tín dụng"** để chọn tài khoản thanh toán tiền, loại hóa đơn.
- **Chọn đúng loại tài khoản thanh toán theo đồng tiền giao dịch:**

| Trường hợp mua hàng | Tài khoản thanh toán bắt buộc chọn |
|----------------------|-----------------------------------|
| Mua hàng **trong nước** (VNĐ) | Tài khoản ngân hàng **VNĐ Việt Nam** |
| Mua hàng **nước ngoài** (Ngoại tệ) | Tài khoản ngân hàng **USD** |

### Bước 5: Chọn mã tài khoản (Bản ghi nợ)
- Click vào nút **"Bản ghi nợ"** → Cửa sổ mới hiển thị danh mục hệ thống tất cả mã tài khoản theo từng loại hàng.
- Tìm kiếm và chọn mã tài khoản phù hợp với loại hàng cần thanh toán (Bút toán Phân kỳ Cost).

### Bước 6: Điền thông tin hóa đơn và chi phí
| Trường | Mô tả |
|--------|-------|
| **Loại hóa đơn (1)** | Chọn kiểu hóa đơn tương ứng (Hóa đơn GTGT, v.v.) |
| **Phòng ban chịu chi phí (2)** | Chọn phòng ban gánh chịu chi phí của mặt hàng này |

### Bước 7: Chọn ngày thanh toán
Phòng Kế toán sẽ có lịch giải ngân cố định trước:
- **Ngày thanh toán cố định:** Ngày đã fix sẵn theo quy định giải ngân hàng tháng của công ty (Ví dụ: **ngày 15** và **ngày 30** hàng tháng).
- **Ngày user tự chọn:** Chọn ngày khác theo nhu cầu thực tế của User. Tuy nhiên, để được phê duyệt, User **bắt buộc phải thỏa thuận trước** với phòng Kế toán, nếu không kế toán có quyền từ chối ngày thanh toán.

### Bước 8: Trường hợp mua hàng có VAT / Ngoại tệ

| Trường hợp | VAT | Ngoại tệ & Tỷ giá |
|-----------|-----|----------|
| Mua hàng **trong nước** | Phải nhập VAT | Không cần nhập tỷ giá |
| Mua hàng **nước ngoài** | Không cần VAT | Cần chọn tỷ giá (tự động nội suy tại thời điểm làm form) |

> ⚠️ Cả 2 trường hợp **đều phải nhập số tiền của nhà cung cấp**.

### Bước 9: Gửi đi duyệt
- Nhấn nút **"Submit"** (Gửi đi) (Step 3) để lưu lại toàn bộ thông tin.
- Nhấn **"Confirm"** (Xác nhận) (Step 4) để chốt dữ liệu, sau bước này thông tin form sẽ bị khóa không thể chỉnh sửa.

---

## 2. 🔔 Trả Lời Câu Hỏi Từ Người Duyệt

Nếu trong quá trình phê duyệt, người duyệt có câu hỏi yêu cầu làm rõ:
1. Thông báo yêu cầu sẽ hiển thị trực tiếp trong form.
2. Click vào thông báo → Gõ câu trả lời giải trình cho người duyệt.
3. Click nút **"Xác nhận"** để gửi câu trả lời đi.

---

## 3. ✅ Quy Trình Duyệt Form (Dành Cho Người Duyệt)

**Vào:** Electronic Document → Approval Documents

Khi nhận được yêu cầu duyệt form:
- Email tự động gửi đến hộp thư người duyệt, click vào link để truy cập trực tiếp.
- Hoặc đăng nhập Groupware → dashboard chính hoặc bảng chờ duyệt sẽ hiển thị form chờ ký.

### 3 lựa chọn khi duyệt:
| Nút bấm | Lựa chọn hành động |
|----------|-----------|
| **Duyệt (nút trái)** | Phê duyệt thông qua form |
| **Từ chối/Reject (nút đỏ giữa)** | Từ chối form, trả về cho người tạo (Hủy bỏ đơn) |
| **Đặt câu hỏi (nút phải)** | Nhập câu hỏi thắc mắc → Chọn người cần hỏi → Gửi đi |

---

## 4. ❓ Lỗi Thường Gặp

| Tình huống | Nguyên nhân | Xử lý |
|-----------|-------------|-------|
| Không tìm thấy form yêu cầu mua để link | Form chưa được duyệt | Chờ form đề xuất mua hàng (Expense Report) được duyệt xong |
| Sai tài khoản thanh toán | Chọn VNĐ thay vì USD hoặc ngược lại | Kiểm tra lại đồng tiền giao dịch trên hóa đơn thực tế |
| Kế toán từ chối ngày thanh toán | Ngày tự chọn không hợp lệ hoặc chưa thỏa thuận | Chọn ngày thanh toán cố định (ngày 15 / 30) hoặc thỏa thuận lại với kế toán |

---

*Cập nhật: 2026-06-04 | Nguồn: Hướng dẫn groupware_Yêu cầu thanh toán.pptx + Hướng dẫn Groupware_Yêu cầu mua.pptx + Comprehensive_Groupware_Report.md*
