# 💾 erpdb — Legacy ERP (Douzone NeoPlus / Smart A) Database Knowledge Base

`erpdb` là cơ sở dữ liệu lưu trữ dữ liệu **ERP thế hệ cũ (Legacy ERP)** tại Vinatech Việt Nam. Đây là cơ sở dữ liệu của giải pháp **Douzone NeoPlus / Smart A** (thế hệ ERP trước của hãng Douzone), hiện tại chủ yếu đóng vai trò làm kho lưu trữ dữ liệu lịch sử (Historical Archive DB) phục vụ tra cứu số liệu quá khứ trước khi Vinatech nâng cấp lên hệ thống ERP iU hiện đại (`NEOE`).

---

## 🗺️ 1. Đặc Điểm Kiến Trúc & Sự Khác Biệt

Cơ sở dữ liệu này có một đặc trưng kỹ thuật rất lớn so với các database khác trong hệ thống:

1.  **Tên bảng bằng Tiếng Hàn (Korean Collation):** Toàn bộ 884 bảng dữ liệu trong `erpdb` được đặt tên trực tiếp bằng các ký tự chữ cái tiếng Hàn (ví dụ: `사원마스타` - Employee Master, `거래처마스타` - Partner Master, `전표H` - Slip Header) thay vì ký tự Latinh (English).
2.  **Mã hóa ký tự:** Do sử dụng bảng mã ký tự tiếng Hàn đặc thù (EUC-KR hoặc Korean Wansung), các truy vấn thông thường từ PowerShell hoặc các công cụ không hỗ trợ Unicode tiếng Hàn đầy đủ sẽ hiển thị tên bảng thành các ký tự dấu hỏi (`?????`).
3.  **Hệ thống độc lập (Offline/Read-only):** CSDL này hiện tại đã ngừng ghi nhận các giao dịch sản xuất hoặc tài chính trực tuyến mới. Hệ thống MES (`SmartFactoryV2`) và Groupware (`VINATECH_GROUP`) mới đã ngắt kết nối đồng bộ với `erpdb` để chuyển hoàn toàn sang kết nối trực tiếp với `NEOE`.

---

## 🗄️ 2. Mô Phỏng Cấu Trúc Các Bảng Tra Cứu Lịch Sử Cốt Lõi

Mặc dù hiển thị dạng Unicode tiếng Hàn, cấu trúc nghiệp vụ của hệ thống Douzone NeoPlus chuẩn hóa bao gồm các bảng tương ứng sau:

| Tên Bảng Tiếng Hàn | Ý nghĩa nghiệp vụ | Chức năng lưu trữ dữ liệu lịch sử |
| :--- | :--- | :--- |
| **사원마스타** (Sawon Master) | Danh mục Nhân sự | Lưu thông tin lý lịch, ngày vào/ngày nghỉ việc của nhân viên cũ |
| **거래처마스타** (Georaecheo Master)| Danh mục Đối tác | Thông tin nhà cung cấp, khách hàng, số tài khoản ngân hàng lịch sử |
| **전표H** / **전표D** (Jeonpyo) | Chứng từ Kế toán | Sổ nhật ký chung, chứng từ thu chi, báo cáo công nợ cũ (Header & Line) |
| **재무제표** (Jaemujeopyo) | Báo cáo tài chính | Các báo cáo cân đối kế toán, kết quả kinh doanh lũy kế của các năm trước |
| **품목마스타** (Pummok Master) | Danh mục Vật tư | Mã hàng hóa, nguyên vật liệu của giai đoạn vận hành cũ |

---

## 📊 3. Kết Luận Vận Hành

CSDL `erpdb` hiện tại là **CSDL tĩnh (Static Archive Database)**. Kế toán Vinatech chỉ truy cập vào cơ sở dữ liệu này thông qua phần mềm Douzone cũ khi cần đối chiếu hoặc quyết toán các vấn đề tài chính tồn đọng thuộc về giai đoạn lịch sử trước khi nâng cấp hệ thống. Trong quá trình phát triển hoặc sửa lỗi hệ thống MES/Groupware hiện tại, AI và Lập trình viên **không cần tác động hoặc đọc dữ liệu** từ database này.

---

*Tài liệu được biên soạn dựa trên phân tích cấu trúc CSDL Douzone NeoPlus tiêu chuẩn tích hợp trên máy chủ `dbserver.hycap.co.kr,5398`.*
