# KỊCH BẢN THUYẾT TRÌNH BÁO CÁO THỬ VIỆC - NGUYỄN VĂN ĐỨC

---

# SLIDE 1: TRANG TIÊU ĐỀ
## Nội dung slide:
- **BÁO CÁO KẾT THÚC THỬ VIỆC**
- Vị trí: Nhân viên thử việc IT / MES Support
- Bộ phận: Enterprise Application (EA) Team
- Người thực hiện: Nguyễn Văn Đức
- Thời gian: Tháng 03/2026 - Tháng 05/2026

## Lời thoại (Speaker Notes):
"Kính thưa Ban lãnh đạo và các anh chị đồng nghiệp, em là Nguyễn Văn Đức, hiện đang là nhân viên thử việc tại bộ phận EA Team với vị trí IT / MES Support. Hôm nay, em xin phép được trình bày báo cáo tổng kết quá trình thử việc 2 tháng vừa qua của mình tại Vinatech. Báo cáo của em sẽ đi sâu vào những công việc thực tế em đã thực hiện, những đánh giá về bản thân và kế hoạch phát triển trong thời gian tới."

---

# SLIDE 2: NỘI DUNG BÁO CÁO
## Nội dung slide:
1. **Phần 01: Công việc thực tế** (MES/NAIS, Phát triển phần mềm, Hạ tầng mạng, Helpdesk)
2. **Phần 02: Đánh giá quá trình** (Thuận lợi, Khó khăn, Sự trưởng thành)
3. **Phần 03: Kế hoạch & Đề xuất** (Ngắn hạn, Trung hạn, Đề xuất cải tiến)

## Lời thoại (Speaker Notes):
"Nội dung báo cáo hôm nay của em gồm 3 phần chính. Phần đầu tiên em sẽ điểm lại các đầu mục công việc thực tế đã triển khai từ hệ thống MES, phát triển phần mềm đến hạ tầng mạng. Phần thứ hai là những nhìn nhận khách quan về quá trình làm việc, những gì em đã học được và những thách thức còn tồn tại. Cuối cùng, em sẽ trình bày mục tiêu cụ thể trong 6 tháng tới cùng một số đề xuất nhỏ để tối ưu hóa công việc."

---

# SLIDE 3: HỖ TRỢ HỆ THỐNG MES & NAIS
## Nội dung slide:
- **Xử lý sự cố sản xuất:** Hỗ trợ kịp thời các lỗi phát sinh trên line.
- **Hệ thống máy Sorting:**
    - Fix lỗi Runtime và thiếu Dependency.
    - Khắc phục tình trạng Crash khi xử lý dữ liệu lớn.
- **Hỗ trợ hệ thống NAIS:**
    - Triển khai NAIS cho các trạm OQC mới (Bắc Giang 1).
    - Cấu hình Display Error và đảm bảo tính ổn định của luồng dữ liệu.

## Lời thoại (Speaker Notes):
"Trong mảng MES và NAIS, trọng tâm của em là đảm bảo hệ thống vận hành liên tục cho sản xuất. Em đã trực tiếp xử lý các sự cố Runtime trên máy Sorting, giúp máy hoạt động ổn định không bị treo khi xử lý lượng dữ liệu lớn. Đồng thời, em cũng đã hỗ trợ triển khai hệ thống NAIS cho các trạm OQC mới tại Bắc Giang 1, cấu hình hiển thị lỗi giúp công nhân dễ dàng nhận biết và xử lý."

---

# SLIDE 4: PHÁT TRIỂN PHẦN MỀM
## Nội dung slide:
- **Module Import Excel to Database:**
    - Tự động hóa quá trình nhập liệu, giảm sai sót thủ công.
    - Hoàn thành logic parsing dữ liệu phức tạp.
- **Nghiên cứu hệ thống ANDON:** Tìm hiểu kiến trúc cảnh báo thời gian thực và kết nối phần cứng.
- **Công nghệ sử dụng:** WinForms (C#), SQL Server optimization.
- **Nghiên cứu MES Screens:** Phát triển các giao diện quản lý trực quan hơn.

## Lời thoại (Speaker Notes):
"Về mảng phát triển phần mềm, dự án quan trọng nhất em đang thực hiện là Module tự động nhập liệu từ Excel vào Database. Công cụ này giúp loại bỏ các thao tác thủ công dễ nhầm lẫn. Ngoài ra, em cũng dành thời gian nghiên cứu chuyên sâu về hệ thống ANDON và các màn hình MES để chuẩn bị cho việc nâng cấp giao diện, giúp người dùng thao tác nhanh chóng và trực quan hơn trên nền tảng WinForms và SQL Server."

---

# SLIDE 5: QUẢN TRỊ HẠ TẦNG MẠNG 3 SITE (BG1, BG2, BN)
## Nội dung slide:
- **Xử lý sự cố mạng phức tạp:** Khắc phục tình trạng Broadcast Storm (xung mạng) gây mất kết nối cục bộ.
- **Bảo trì hạ tầng vật lý:**
    - Thay thế RJ45, bảo trì cáp Cat6 tại các vùng sản xuất cao điểm.
    - Vệ sinh và tối ưu hóa kết nối sợi quang tại tủ MDF.
- **Bảo mật & WiFi:** Cấu hình WPA2-Enterprise cho bộ phận QC và thiết lập VLAN riêng biệt.
- **Khảo sát & Quy hoạch:** Đo tốc độ mạng tại các phòng ban BG1, lập sơ đồ hạ tầng thực tế.

## Lời thoại (Speaker Notes):
"Hạ tầng mạng là xương sống của nhà máy. Em đã cùng anh Hải đi sâu vào giải quyết các lỗi xung mạng (Broadcast Storm) gây tắc nghẽn dữ liệu. Em cũng đã trực tiếp bảo trì, thay thế các đầu nối RJ45 và tối ưu lại hệ thống cáp quang tại tủ MDF ở cả 3 site. Đặc biệt, em đã triển khai hệ thống WiFi bảo mật WPA2-Enterprise cho bộ phận QC và thực hiện khảo sát toàn diện tốc độ mạng tại Bắc Giang 1 để đề xuất nâng cấp các thiết bị lỗi thời."

---

# SLIDE 6: IT HELPDESK & SYSTEM ADMIN
## Nội dung slide:
- **Quản lý thiết bị:** Hỗ trợ hơn 150+ thiết bị (PC, Laptop, Printer, TV).
- **Security:** Cập nhật Admin Password định kỳ cho các phòng ban R&D, QC và các tài khoản quản lý Hàn Quốc.
- **Hệ thống:** Cấu hình Scan to Email (Accounting), phân quyền ECM (Customer Service).
- **Hỗ trợ 24/7:** Đảm bảo thời gian phản hồi nhanh, giảm thiểu downtime cho văn phòng và sản xuất.

## Lời thoại (Speaker Notes):
"Trong vai trò Helpdesk, em quản lý và hỗ trợ hơn 150 thiết bị đầu cuối. Em đã thực hiện chuẩn hóa mật khẩu admin để tăng cường bảo mật cho các phòng ban quan trọng như R&D và QC. Các yêu cầu về phân quyền ECM hay cấu hình máy in, Scan to Email cho bộ phận Kế toán luôn được em xử lý trong thời gian ngắn nhất để đảm bảo không làm gián đoạn công việc của mọi người."

---

# SLIDE 7: PHẦN 02 - ĐÁNH GIÁ QUÁ TRÌNH
## Nội dung slide:
- Nhìn lại hành trình 2 tháng thử việc tại Vinatech.
- Tự đánh giá năng lực thích nghi và chuyên môn.
- Mối quan hệ phối hợp với các đồng nghiệp và các phòng ban.

## Lời thoại (Speaker Notes):
"Tiếp theo, em xin phép đi vào phần tự đánh giá về quá trình thử việc của mình. Đây là giai đoạn em được tiếp cận với môi trường sản xuất thực tế đầy năng động tại Vinatech, nơi giúp em có cái nhìn rõ nét hơn về vai trò của IT trong việc hỗ trợ doanh nghiệp."

---

# SLIDE 8: THUẬN LỢI & SỰ TRƯỞNG THÀNH
## Nội dung slide:
- **Môi trường:** Nhận được sự hỗ trợ nhiệt tình từ Mentor và đồng nghiệp trong EA Team.
- **Kỹ thuật:** 
    - Nắm vững kiến trúc SQL Server và quy trình phát triển WinForms.
    - Hiểu sâu về mô hình mạng công nghiệp và các vấn đề vật lý tại nhà máy.
- **Kỹ năng mềm:** Cải thiện khả năng giao tiếp với người dùng và tư duy giải quyết vấn đề tại hiện trường (Gemba).
- **Văn hóa:** Tham gia các hoạt động Team Building, gắn kết với giá trị cốt lõi của công ty.

## Lời thoại (Speaker Notes):
"Về thuận lợi, em cảm thấy rất may mắn khi được làm việc trong một môi trường cởi mở, nơi các anh chị đi trước luôn sẵn sàng chỉ bảo. Qua 2 tháng, em đã trưởng thành hơn rất nhiều về mặt chuyên môn, đặc biệt là tư duy 'Gemba' - tức là phải bám sát thực tế sản xuất để giải quyết vấn đề. Sự kiện Team Building vừa qua cũng giúp em hiểu và yêu thêm văn hóa Vinatech, cảm thấy mình thực sự là một phần của đại gia đình này."

---

# SLIDE 9: KHÓ KHĂN & THÁCH THỨC
## Nội dung slide:
- **Kiến thức nghiệp vụ:** Cần thêm thời gian để hiểu sâu hết các quy trình sản xuất phức tạp của Supercapacitor.
- **Xử lý lỗi đặc thù:** Một số lỗi phần cứng cũ (máy in cân phế, thiết bị R&D) đòi hỏi tài liệu kỹ thuật chuyên sâu.
- **Quản lý thời gian:** Cân bằng giữa các task hỗ trợ Helpdesk đột xuất và các dự án phát triển phần mềm dài hạn.

## Lời thoại (Speaker Notes):
"Tất nhiên, em cũng gặp không ít khó khăn. Quy trình sản xuất của công ty rất phức tạp, đòi hỏi em phải nỗ lực học hỏi nhiều hơn để hiểu được nghiệp vụ đằng sau mỗi dòng code. Đôi khi, việc cân bằng giữa các yêu cầu hỗ trợ người dùng ngay lập tức và tiến độ viết code cho các dự án cũng là một thách thức mà em đang cố gắng điều phối hiệu quả hơn."

---

# SLIDE 10: KẾ HOẠCH NGẮN HẠN (1-3 THÁNG)
## Nội dung slide:
- **Phần mềm:** Hoàn thiện và triển khai chính thức Module Import Excel.
- **Hệ thống:** Tối ưu hóa các màn hình hiển thị MES tại xưởng.
- **Hạ tầng:** Cập nhật lại sơ đồ mạng (Network Diagram) chi tiết cho cả 3 site.
- **Kiến thức:** Tham gia các khóa đào tạo nội bộ về bảo mật thông tin.

## Lời thoại (Speaker Notes):
"Trong 3 tháng tới, mục tiêu ưu tiên của em là đưa Module Import Excel vào vận hành chính thức để giải phóng sức lao động cho các bộ phận liên quan. Em cũng sẽ tập trung hoàn thiện bộ sơ đồ mạng chi tiết để phục vụ việc quản lý và ứng cứu sự cố nhanh hơn, đồng thời không ngừng trau dồi kiến thức về bảo mật hệ thống theo tiêu chuẩn công ty."

---

# SLIDE 11: KẾ HOẠCH TRUNG HẠN (3-6 THÁNG)
## Nội dung slide:
- **Dự án:** Tham gia phát triển các module quan trọng trong hệ thống ANDON mới.
- **Hệ thống:** Nghiên cứu áp dụng AI/Data Analytics đơn giản vào việc dự báo lỗi thiết bị mạng/phần cứng.
- **Nâng cấp:** Đề xuất và thực hiện thay thế các thiết bị mạng cũ theo danh sách khảo sát tại BG1.
- **Quy trình:** Xây dựng kho tài liệu hướng dẫn tự xử lý lỗi IT cơ bản cho người dùng (Knowledge Base).

## Lời thoại (Speaker Notes):
"Tầm nhìn từ 3 đến 6 tháng, em mong muốn được đóng góp sâu hơn vào hệ thống ANDON thế hệ mới. Em cũng dự định xây dựng một kho dữ liệu hướng dẫn (Knowledge Base) giúp người dùng có thể tự xử lý các lỗi IT cơ bản, từ đó giảm tải cho bộ phận IT và tăng năng suất chung. Xa hơn nữa, em muốn tìm hiểu việc ứng dụng phân tích dữ liệu để dự báo trước các hỏng hóc của thiết bị hạ tầng."

---

# SLIDE 12: ĐỀ XUẤT & GIẢI ĐÁP THẮC MẮC
## Nội dung slide:
- **Đề xuất:**
    - Xây dựng hệ thống Wiki/Knowledge Base nội bộ cho EA Team.
    - Định kỳ tổ chức các buổi chia sẻ kỹ thuật giữa các thành viên.
- **CẢM ƠN BAN LÃNH ĐẠO VÀ CÁC ANH CHỊ ĐÃ LẮNG NGHE!**
- Q&A: Giải đáp các câu hỏi từ Hội đồng đánh giá.

## Lời thoại (Speaker Notes):
"Cuối cùng, em có một đề xuất nhỏ về việc xây dựng hệ thống Wiki nội bộ cho team để lưu trữ các 'case study' khó, giúp việc đào tạo nhân sự mới sau này thuận tiện hơn. Em xin chân thành cảm ơn Ban lãnh đạo và các anh chị đã dành thời gian lắng nghe báo cáo của em. Sau đây, em rất mong nhận được những ý kiến đóng góp và câu hỏi từ phía Hội đồng ạ."
