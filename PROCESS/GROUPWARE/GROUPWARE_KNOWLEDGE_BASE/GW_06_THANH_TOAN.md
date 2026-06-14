# GW_06 — Yêu Cầu Thanh Toán (Disbursement Document)

> **Màn hình:** Electronic Document → Cost → Dusbursenment Document (Màn hình bị ghi sai chính tả trên menu hệ thống)
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 💳 Tạo Yêu Cầu Thanh Toán

**Vào:** Electronic Document → Cost → Dusbursenment Document (Lưu ý: Chữ *Disbursement* bị viết sai chính tả thành **"Dusbursenment Document"** trên thanh thực đơn của hệ thống)

### Bước 1: Chọn đường line phê duyệt
- Thiết lập đường line phê duyệt phù hợp. (Tuyến mặc định là **22205010-Nguyễn Thị Thúy_V6** → **21910034-Trần Quang Thỏa**).

### Bước 2: Điền thông tin form cơ bản
- Đặt tên form (tiêu đề biểu mẫu).
- **Đính kèm file liên quan:** Ở phần Attachment, người dùng tải lên phiếu hoá đơn hoặc vận đơn làm cơ sở xác thực số tiền cước phí cho Phòng Kế toán (Ví dụ: file PDF hóa đơn vận chuyển đường hàng không mang tên [Bee Logistics_Vina tech_By_Air_Inv-2925431946.pdf](Bee%20Logistics_Vina%20tech_By_Air_Inv-2925431946.pdf)). Kế toán sẽ nhìn trực tiếp vào **Lịch sử Liên Kết Tài Liệu kéo thả** trong tab Cost để kiểm tra Audit bất cứ lúc nào mà không cần đòi hỏi bản cứng.
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

## 4. 🔀 Quy Trình Duyệt Mặc Định (Approval Line)

Khi khởi tạo Yêu cầu thanh toán (Disbursement Document, bao gồm cả Card Disbursement, Financial Expenditure, National Policy Disbursement...), đường line duyệt và tiếp nhận được thiết lập cố định từ Excel:
- **Tuyến phê duyệt (Approval):** **22205010-Nguyễn Thị Thúy_V6** → **21910034-Trần Quang Thỏa** (Final Approval).
- **Tuyến tiếp nhận (Receipt):** Nhóm nhận Kế toán* (Final Receipt).

*\*Nhóm nhận Kế toán bao gồm các nhân sự: 22205010-NGUYỄN THỊ THÚY_V6, 22205011-NGUYỄN THỊ PHƯƠNG LINH, 22308006-NGÔ PHƯƠNG ANH, 22312004-LÊ THỊ TRANG, 22404015-NGUYỄN THỊ HỒNG_V3.*

---

## 5. 🚢 Danh Mục Chi Tiết Phí Logistics (Logistics Fees Reference Dictionary)

Khi làm yêu cầu thanh toán cho các hóa đơn vận chuyển, logistics (đường biển, đường hàng không, trucking nội địa), nhân sự bắt buộc phải đối chiếu chọn chính xác mã/ký hiệu phụ phí tương ứng từ bảng mã chuẩn của công ty:

| Ký hiệu phí | Tên Tiếng Anh | Tên Tiếng Hàn | Ý nghĩa nghiệp vụ |
|-------------|---------------|---------------|-------------------|
| **FREIGHT COST** | Freight Cost | 운임비 | Cước vận chuyển đường biển/đường không |
| **Pay on behalf** | Pay on behalf | 대신 지불 | Các khoản thanh toán hộ |
| **Trucking fee** | Trucking fee | 운송 트럭킹 비용 | Phí vận tải nội địa bằng xe tải/container |
| **EXW/DAP Charge** | EXW/DAP Charge | 국제 비용 | Chi phí quốc tế theo điều kiện EXW/DAP |
| **CFS** | Container Freight Station fee | 컨테이너 화물역 수수료 | Phí khai thác kho hàng lẻ CFS (hàng LCL) |
| **FSC** | Fuel Surcharge | 유류할증료 | Phụ phí xăng dầu (áp dụng cho hàng không) |
| **THC** | Terminal Handling Charge | 단말기 취급 수수료 | Phí bốc dỡ tại cảng/terminal |
| **Custom Declarations fee** | Custom Declarations fee | 면장 신고 비용 | Phí dịch vụ khai báo tờ khai hải quan |
| **CIC** | Container Imbalance Charge | 컨테이너 불균형 요금 | Phí mất cân bằng vỏ container |
| **GRI** | General Rate Increase | 일반 요금 인상 | Phụ phí tăng giá cước chung của hãng tàu |
| **HDL FEE** | Handling fee | 핸드링 비용 | Phí làm hàng/handling |
| **LSS** | Low Sulphur Surcharge | 낮은 유황 할증료 | Phụ phí giảm thải lưu huỳnh (đường biển) |
| **Inspection of old machinery** | Inspection of old machinery | 오래된 기계 검사 | Phí kiểm định máy móc thiết bị cũ nhập khẩu |
| **PSS** | Peak Season Surcharge | 성수기 요금 | Phụ phí mùa cao điểm |
| **Cleaning fee** | Cleaning fee | 청소비용 | Phí vệ sinh container |
| **AMS** | Automated Manifest System fee | 자동 매니페스트 시스템 요금 | Phí truyền dữ liệu manifest tự động (đi Mỹ/Á) |
| **D/O FEE** | Delivery Order fee | 배달 주문 수수료 | Phí lệnh giao hàng |
| **DOC** | Documentation fee | 서류 발급 비용 | Phí chứng từ/vận đơn |
| **SSC** | Security Surcharge | 보안 추가 요금 | Phụ phí an ninh |
| **TEST COVID-19 fee** | TEST COVID-19 fee | 코로나19 테스트 | Chi phí xét nghiệm Covid-19 liên quan |
| **Other charge** | Other charge | 기타 요금 | Chi phí khác |
| **Inspection fee** | Inspection fee | 검사비용 | Phí kiểm tra/kiểm định chất lượng hàng |
| **Chemical Declaration** | Chemical Declaration | 화학물질 선언 | Khai báo hóa chất nhập khẩu |
| **CD Amendment** | CD Amendment fee | 면장 신고 수정 | Phí sửa đổi tờ khai hải quan khi có sai sót |
| **Lobby fee** | Lobby fee | 로비 요금 | Phí lobby/chi phí đối ngoại |
| **X-ray fee** | X-ray fee | 엑스레이 요금 | Phí soi chiếu X-ray container |
| **SEAL** | Other charge (Seal) | 기타 요금 (Seal) | Phí kẹp chì container |
| **Overtime Supervision at NB** | Overtime Supervision at NB | 노이바이 초과근무 감독 | Phí giám sát bốc xếp ngoài giờ tại sân bay Nội Bài |
| **Pickup on Saturday** | Pickup on Saturday | 토요일 픽업 | Phụ phí nhận hàng vào ngày thứ Bảy |

---

## 6. ❓ Lỗi Thường Gặp

| Tình huống | Nguyên nhân | Xử lý |
|-----------|-------------|-------|
| Không tìm thấy form yêu cầu mua để link | Form chưa được duyệt | Chờ form đề xuất mua hàng (Expense Report) được duyệt xong |
| Sai tài khoản thanh toán | Chọn VNĐ thay vì USD hoặc ngược lại | Kiểm tra lại đồng tiền giao dịch trên hóa đơn thực tế |
| Kế toán từ chối ngày thanh toán | Ngày tự chọn không hợp lệ hoặc chưa thỏa thuận | Chọn ngày thanh toán cố định (ngày 15 / 30) hoặc thỏa thuận lại với kế toán |

---

*Cập nhật: 2026-06-12 | Nguồn: Hướng dẫn groupware_Yêu cầu thanh toán.pptx + Vietnam Corporation Approval Setting List.xlsx + Logistics fee - division.xlsx + Comprehensive_Groupware_Report.md*

