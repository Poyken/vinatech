Email công ty cấp cho bạn chính là một tài khoản nằm trên một Mail Server (thường là Office 365 của Microsoft hoặc Google Workspace). Bạn hoàn toàn có thể dùng chính tài khoản email này để làm cổng gửi tin (SMTP) cho Database Mail trong SQL Server.

Dưới đây là thông số cấu hình và cách thực hiện bằng chính Email công ty của bạn:

1. Xác định thông số SMTP theo đuôi Email công ty
Tùy vào nền tảng email công ty bạn đang dùng, hãy chọn thông số tương ứng:

* Nền tảng Microsoft Office 365 (Phổ biến nhất ở các doanh nghiệp)
  * SMTP Server (Mail Server): smtp.office365.com
  * Port: 587
  * SSL (Secure Connection): Bắt buộc tích chọn (Yes)
  * User/Username: Địa chỉ email của bạn (ví dụ: nguyenvan@vinatech.com.vn)
  * Password: Mật khẩu email của bạn (nếu tài khoản có bật bảo mật 2 lớp MFA, bạn cần tạo App Password trong trang bảo mật tài khoản Microsoft để điền vào đây).

* Nền tảng Google Workspace (Gmail doanh nghiệp)
  * SMTP Server (Mail Server): smtp.gmail.com
  * Port: 587
  * SSL (Secure Connection): Bắt buộc tích chọn (Yes)
  * User/Username: Địa chỉ email của bạn
  * Password: Mật khẩu ứng dụng (App Password) (Tạo trong phần Cài đặt tài khoản Google -> Bảo mật -> Mật khẩu ứng dụng).

2. Các bước cấu hình trong SSMS (SQL Server Management Studio)
* Mở SSMS, kết nối vào Database.
* Tìm đến thư mục Management -> Nhấp chuột phải vào Database Mail -> Chọn Configure Database Mail.
* Chọn Set up Database Mail by performing the following tasks -> Nhấn Next.
* Nhập tên Profile Name (ví dụ: Vinatech_Alert).
* Tại ô SMTP Accounts, nhấn nút Add... để tạo tài khoản gửi:
  * Email Address: Điền email công ty của bạn.
  * Server name: Điền smtp.office365.com hoặc smtp.gmail.com tùy theo nền tảng.
  * Port: 587.
  * Tích chọn This server requires a secure connection (SSL).
  * Chọn Basic authentication:
    * User name: Điền lại email của bạn.
    * Password / Confirm Password: Mật khẩu email hoặc App Password.
* Nhấn OK -> Next cho đến khi hoàn thành.
* Kiểm tra thử: Nhấp chuột phải vào Database Mail -> Chọn Send Test E-mail..., điền email nhận để test xem hệ thống đã gửi thư thành công chưa.

(Lưu ý: Sau khi cấu hình thành công, bạn có thể quay lại bước cài đặt Job BK_ECUS để chọn Profile Vinatech_Alert vừa tạo nhằm tự động gửi mail báo lỗi).
