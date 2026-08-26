# GW_06 — Yêu Cầu Thanh Toán (Disbursement Document)

> **Màn hình:** Electronic Document → Cost → Dusbursenment Document (Màn hình bị ghi sai chính tả trên menu hệ thống)
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 💳 Quy Trình Tạo Yêu Cầu Thanh Toán (Disbursement Document)

**Vào:** Electronic Document → Cost → Dusbursenment Document (Lưu ý: Chữ *Disbursement* bị viết sai chính tả thành **"Dusbursenment Document"** trên thanh thực đơn của hệ thống)

### Bước 1: Thiết lập tuyến phê duyệt
* Click nút **"Chọn dòng phê duyệt +"** (nút số 4 bên góc phải) để thiết lập tuyến duyệt.
* *Tuyến phê duyệt mặc định:* **22205010-Nguyễn Thị Thúy_V6** ➔ **21910034-Trần Quang Thỏa** (CEO duyệt cuối). CC nhóm Kế toán.

### Bước 2: Điền thông tin cơ bản & Đính kèm
* **Tiêu đề (Mục 5):** Điền tiêu đề tài liệu.
* **Đính kèm tài liệu (Mục 6):** Tải lên các file hóa đơn, vận đơn, phiếu giao nhận để làm căn cứ đối chiếu.
* **Người dùng:** Hệ thống mặc định điền tên người đăng nhập.

### Bước 3: Liên kết tài liệu đã duyệt ở thượng nguồn
* Click nút **"Liên kết Tài liệu"** (Mục 7) để tìm kiếm và ghim các tờ trình xin mua/đề xuất chi phí (`Expense Report` hoặc `PO`) đã được duyệt trước đó.

### Bước 4: Kiểm tra thông tin Đối tác & Ngân hàng
* Sau khi liên kết, thông tin đối tác (Mã đối tác, mã số ĐKKD) và ngân hàng thụ hưởng sẽ tự động hiển thị.
* Nếu đối tác thay đổi số tài khoản nhận tiền, nhấp vào nút **"Thay đổi tài khoản"** để cập nhật.

### Bước 5: Cấu hình Tài khoản Nợ (Debit Account - Mục 8)
* Nhấp nút **"Chọn Tài khoản"** bên cột **Nợ** để mở popup tìm kiếm.
* **Quy tắc định tuyến tài khoản Nợ (Chi phí):**
  * **Bộ phận sản xuất (Kho NVL, Kho thành phẩm, Chuyền SX):** Tìm kiếm và chọn mã tài khoản bắt đầu bằng **`627`** (Ví dụ: `627..` chi phí sản xuất chung).
  * **Bộ phận hỗ trợ (Support, EA, EHS, Finance, LOG, PUR, RnD):** Tìm kiếm và chọn mã tài khoản bắt đầu bằng **`642`** (Ví dụ: `64231` - Chi phí văn phòng phẩm/Office supplies, `64216` - Welfare, `64287` - Thuế phí...).
  * **Tài sản / Hàng hóa trị giá từ 30 triệu VND trở lên:** Chọn mã tài khoản đầu **`241`** (Xây dựng dở dang/Mua sắm TSCĐ). Nếu phân vân, bắt buộc liên hệ team Kế toán để làm rõ trước khi chọn.
  * *Lưu ý:* Chi phí tiền lương sẽ được hướng dẫn theo quy trình riêng.
* **Chọn tài khoản thuế GTGT tương ứng:** Sau khi chọn tài khoản chi phí, chọn tài khoản thuế GTGT đầu vào bắt đầu bằng **`133`** (thông thường chọn **`13311`** cho hàng hóa trong nước; đối với hàng mua ở nước ngoài thì không cần chọn tài khoản thuế).

### Bước 6: Cấu hình Tài khoản Có (Credit Account - Mục 9)
* Nhấp nút **"Chọn Tài khoản"** bên cột **Có** để mở popup tìm kiếm.
* **Quy tắc chọn tài khoản Có:**
  * **Thanh toán nhà cung cấp trong nước bằng VND:** Chọn mã tài khoản **`33111`** (Short term trade account payable - VND).
  * **Thanh toán nhà cung cấp nước ngoài bằng ngoại tệ (USD):** Chọn mã tài khoản **`33112`** (Short term trade account payable - USD).

### Bước 7: Cấu hình Ngày thanh toán & Ngày dự kiến cấp vốn
* **Ngày dự kiến cấp vốn Yêu cầu (Mục 10):** *Không điền* trừ khi có lý do đặc biệt cần thanh toán vào ngày khác ngày hệ thống đã thiết lập sẵn.
* **Ngày dự kiến cấp vốn (Mục 11):** Chọn loại ngày dự kiến thu/chi từ dropdown tương ứng với loại chi phí: *Lương, Hóa đơn điện, Trả nợ trụ sở chính, Hóa đơn nước / Chi phí Viễn thông, Vật tư (Trả trước), Kết thúc vật tư, Vật tư, Thuế thu nhập cá nhân, Chi phí & Chi phí linh tinh, Thuế hải quan*.
* **Ngày phát hành (Mục 12):** Điền ngày hóa đơn hoặc ngày của tháng ghi nhận chi phí đó.

### Bước 8: Chọn loại chứng từ & Trung tâm Chi phí (Cost Center)
* **Loại Chứng từ (Mục 13):**
  * Chọn **`Tax bill`** nếu thanh toán dựa trên hóa đơn GTGT/hóa đơn bán hàng chính thức.
  * Chọn **`bill`** nếu thanh toán cho các khoản chi phí không có hóa đơn GTGT.
* **Trung tâm Chi phí (Mục 14):** Chọn đúng bộ phận/phòng ban phát sinh chi phí này.
* **Trường hợp hóa đơn cho nhiều bộ phận:** Nhấp nút **"+ Thêm"** (Add) bên dưới lưới chi tiết để tách nhỏ giá trị hóa đơn và chọn trung tâm chi phí tương ứng cho từng phần.

### Bước 9: Thiết lập Loại Thuế (Mục 15)
* Chọn loại thuế suất GTGT tương ứng từ dropdown:
  * Chọn **`[21] Taxation (purchase tax invoice)`** nếu thuế suất hóa đơn là **10%**.
  * Chọn **`[71] Taxation (VAT 8)`** nếu thuế suất hóa đơn là **8%**.
  * Chọn **`[22] Non-Deduction (tax invoice)`** nếu không có thuế.

### Bước 10: Khai báo ngoại tệ bổ sung (nếu có - Mục 16 & 17)
* Phần này tự động xuất hiện khi chọn tài khoản Có là **`33112`** (Thanh toán USD).
* **Loại tiền tệ (Mục 16):** Nhập **`USD`**.
* **Số tiền ngoại tệ (Mục 17):** Nhập số tiền cần thanh toán bằng ngoại tệ. Hệ thống tự động nhân tỷ giá hối đoái thực tế để quy đổi ra Tổng giá cung ứng & Thuế GTGT bằng VND.

### Bước 11: Nhập nội dung và Gửi duyệt (Mục 18 & 19)
* **Nội dung (Mục 18):** Ghi rõ nội dung và lý do thanh toán chi tiết.
* **Hành động (Mục 19):**
  * Nhấn **"Trình duyệt"** để gửi form đi phê duyệt.
  * Nhấn **"Lưu nháp"** nếu muốn lưu lại để tiếp tục chỉnh sửa sau.
  * Nhấn **"Xem trước"** để xem trước layout biểu mẫu.

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

