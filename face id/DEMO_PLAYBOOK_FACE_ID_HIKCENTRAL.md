# 🎬 KỊCH BẢN DEMO TOÀN DIỆN HỆ THỐNG FACE ID & CHẤM CÔNG HIKCENTRAL
### *Dự án: VINATECH VINA (HƯNG YÊN)*
*Tài liệu chuẩn bị phục vụ buổi Demo chiều nay dành cho Ban Giám Đốc & Các Trưởng Bộ Phận*

---

## 📌 MỤC LỤC KỊCH BẢN DEMO
1. [Chuẩn Bị Môi Trường Trước Khi Demo](#1-chuẩn-bị-môi-trường-trước-khi-demo)
2. [Bài Demo 1: Giám Sát Sự Kiện Ra Vào Thời Gian Thực (Live Access Log)](#2-bài-demo-1-giám-sát-sự-kiện-ra-vào-thời-gian-thực)
3. [Bài Demo 2: Đăng Ký Nhân Viên Mới & Đồng Bộ Face ID Cực Nhanh](#3-bài-demo-2-đăng-ký-nhân-viên-mới--đồng-bộ-face-id)
4. [Bài Demo 3: Phân Quyền Cửa & Điều Khiển Mở Cửa Từ Xa (Remote Door Control)](#4-bài-demo-3-phân-quyền-cửa--điều-khiển-mở-cửa-từ-xa)
5. [Bài Demo 4: Tính Toán Công Tự Động & Xuất Báo Cáo Chấm Công](#5-bài-demo-4-tính-toán-công-tự-động--xuất-báo-cáo-chấm-công)
6. [Bài Demo 5: Trích Xuất Dữ Liệu SQL & Tích Hợp Tự Động ERP / MES](#6-bài-demo-5-trích-xuất-dữ-liệu-sql--tích-hợp-erp-mes)
7. [Checklist Xử Lý Tình Huống Nhanh Khi Demo](#7-checklist-xử-lý-tình-huống-nhanh-khi-demo)

---

## 1. CHUẨN BỊ MÔI TRƯỜNG TRƯỚC KHI DEMO

| Hạng mục | Đường dẫn / Địa chỉ | Tài khoản / Thông tin | Trạng thái |
|---|---|---|:---:|
| **Web Quản trị HikCentral** | `https://192.168.184.250/#/portal` | `admin` / `vinatech@2026` | 🟢 Đã sẵn sàng trên Chrome |
| **Local Web Dashboard (Sơ đồ 3 tầng)** | `http://localhost:8090/` | Truy cập trực tiếp (No auth) | 🟢 Đang chạy (server.py) |
| **Cơ sở dữ liệu SQL Server** | `192.168.184.250,1433` (DB: `HCP_DATA`) | `hikcentral` / `vinatech@2026` | 🟢 Kết nối ổn định |
| **Thiết bị Face ID Online** | `AC-05` (P. IT), `AC-06` (Văn phòng 2F), `TA-03` (Locker) | Nhận diện $<0.3$s | 🟢 Online |

---

## 2. BÀI DEMO 1: GIÁM SÁT SỰ KIỆN RA VÀO THỜI GIAN THỰC
> **Mục tiêu:** Chứng minh tốc độ nhận diện Face ID cực nhanh ($<0.3$ giây), không cần chạm, tự động lưu ảnh chụp khuôn mặt thực tế lúc quẹt.

### Các bước thực hiện:
1. **Cách 1: Trình diễn trên Web HikCentral Pro**
   - Trên menu trên cùng, bấm tab **Kiểm soát truy cập** (Access Control).
   - Chọn mục **Tìm kiếm** $\rightarrow$ **Bản ghi xác thực người**.
   - Bấm nút **Tìm kiếm**: Hệ thống hiển thị danh sách các lượt quẹt mới nhất (ví dụ các lượt quẹt sáng nay của anh Đức, Chức, Tưởng).
   - Bấm vào một dòng sự kiện để xem chi tiết ảnh chụp khuôn mặt thực tế (`CapturedPicture`).

2. **Cách 2: Trình diễn trên Local Web Dashboard (`http://localhost:8090/`)**
   - Mở tab `http://localhost:8090/` trên Chrome.
   - Giới thiệu sơ đồ mặt bằng trực quan 3 tầng + khu nhà xe Flap Barrier.
   - Xem bảng **Lịch Sử Sự Kiện Thời Gian Thực**: Tỷ lệ Face ID đạt **93.3%** (153/164 lượt), biểu đồ phân bổ thiết bị tại `AC-05`, `AC-06`, `TA-03`.
   - **Thực hành quẹt thực tế:** Nhờ một người bước qua trước camera `AC-05` hoặc `AC-06`. Sau khi quẹt thành công, bấm F5 hoặc hệ thống tự cập nhật sự kiện mới lên bảng ngay lập tức!

---

## 3. BÀI DEMO 2: ĐĂNG KÝ NHÂN VIÊN MỚI & ĐỒNG BỘ FACE ID
> **Mục tiêu:** Thể hiện quy trình thêm nhân sự mới đơn giản và cơ chế tự động nạp dữ liệu sinh trắc học xuống các thiết bị phần cứng.

### Các bước thực hiện:
1. Trên cổng Web HikCentral, bấm vào tab **Người (Person)**.
2. Chọn phòng ban (ví dụ: `WSI` hoặc `HS Team`) $\rightarrow$ Bấm nút **+ Thêm (+ Add)**.
3. Điền thông tin nhân sự:
   - **Mã nhân viên (ID):** Điền mã thử nghiệm (VD: `9999`).
   - **Họ và Tên:** Điền tên nhân viên demo (VD: `Nguyễn Văn Demo`).
   - **Giới tính / Điện thoại:** (Tùy chọn).
4. **Nạp ảnh khuôn mặt (Face ID):**
   - Chọn mục **Thêm khuôn mặt (Add Face)** $\rightarrow$ Có thể upload trực tiếp 1 bức ảnh chân dung rõ nét từ máy tính hoặc chụp qua webcam/máy đăng ký mẫu.
5. Bấm nút **Lưu (Save)**.
6. **Kiểm tra đồng bộ:** Hệ thống tự động đẩy Face Template của nhân viên mới xuống bộ nhớ cục bộ của máy `AC-05`, `AC-06`. Nhân viên mới có thể quẹt nhận diện ngay lập tức mà không cần khởi động lại thiết bị.

---

## 4. BÀI DEMO 3: PHÂN QUYỀN CỬA & ĐIỀU KHIỂN MỞ CỬA TỪ XA
> **Mục tiêu:** Chứng minh khả năng kiểm soát an ninh linh hoạt theo phòng ban và xử lý tình huống khẩn cấp từ xa qua Web.

### Các bước thực hiện:
1. **Kiểm tra Phân quyền Cửa (Access Levels):**
   - Vào tab **Kiểm soát truy cập** $\rightarrow$ **Cấp độ truy cập** $\rightarrow$ **Quản lý cấp độ truy cập**.
   - Giới thiệu 2 nhóm quyền tiêu chuẩn:
     - **`Door_2F`:** Chỉ mở cửa Phòng IT (`AC-05`) và Văn phòng Tầng 2 (`AC-06`) với lịch hiệu lực 24/7.
     - **`All Door`:** Mở tất cả các cửa an ninh (gồm cả Phòng điều khiển sản xuất 1F `AC-02`).
   - Cho xem danh sách nhân sự được gán trong mục **Chỉ định cấp độ truy cập**.

2. **Thao tác Điều khiển Cửa Từ Xa (Remote Control):**
   - Vào mục **Giám sát thiết bị / Điểm truy cập**.
   - Chọn cửa `AC-05_Door_1` hoặc `AC-06_Door_1`.
   - Biểu diễn các nút điều khiển trung tâm:
     - **Mở cửa (Open Door):** Mở chốt cửa từ xa trong 5 giây cho khách vào mà không cần quẹt thẻ/mặt.
     - **Mở thường trực (Remain Open):** Giữ cửa luôn mở trong các sự kiện đón tiếp đoàn tham quan.
     - **Khóa thường trực (Remain Closed):** Khóa chặn khẩn cấp toàn bộ cửa khi có sự cố an ninh.

---

## 5. BÀI DEMO 4: TÍNH TOÁN CÔNG TỰ ĐỘNG & XUẤT BÁO CÁO CHẤM CÔNG
> **Mục tiêu:** Thuyết phục bộ phận HR và Ban Giám Đốc về tính chính xác, minh bạch của hệ thống chấm công tự động.

### Các bước thực hiện:
1. Trên cổng Web HikCentral, bấm vào tab **Chuyên cần (Time & Attendance)**.
2. Giới thiệu các cấu hình ca kíp đã thiết lập:
   - **Ca làm việc (Shifts):** Ca Hành Chính **`HC`** (08:00 - 17:30).
   - **Lịch trình (Department Schedule):** Thứ 2 $\rightarrow$ Thứ 6 (Thứ 7 & CN nghỉ).
   - **Quy tắc tính công (Calculation Rules):** 
     - Tự động lấy **Lần quẹt đầu tiên (First In)** làm giờ đến và **Lần quẹt cuối cùng (Last Out)** làm giờ về.
     - Quẹt sau `08:15:00` $\rightarrow$ Đánh dấu Đi muộn (Late).
     - Quẹt về trước `17:00:00` $\rightarrow$ Đánh dấu Về sớm (Early).
     - Tiến trình tự động chạy lúc **04:00 AM hàng ngày**.
3. **Xem Báo Cáo Chấm Công Thực Tế:**
   - Vào mục **Báo cáo (Reports)** $\rightarrow$ **Báo cáo hàng ngày (Daily Report)** hoặc **Báo cáo tổng hợp (Summary Report)**.
   - Chọn ngày cần xem (ví dụ: ngày hôm nay `2026-08-25` hoặc từ `2026-08-20` đến nay).
   - Bấm **Tìm kiếm**: Hiển thị đầy đủ giờ vào/ra, tổng giờ làm việc thực tế của từng nhân viên.
   - Bấm nút **Xuất file (Export)** $\rightarrow$ Tải file Excel báo cáo chấm công mẫu hoàn chỉnh.

---

## 6. BÀI DEMO 5: TRÍCH XUẤT DỮ LIỆU SQL & TÍCH HỢP TỰ ĐỘNG ERP / MES
> **Mục tiêu:** Thể hiện năng lực kỹ thuật IT nội bộ, khả năng kết nối dữ liệu trực tiếp sang hệ thống Quản trị Doanh nghiệp (Duzon ERP-iU / Vinatech MES).

### Các bước thực hiện:
1. **Mở giao diện Command Line / PowerShell:**
   Chạy script tra cứu độc lập bằng lệnh:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\query_faceid_db.ps1
   ```
2. **Chạy câu lệnh SQL đối soát giờ công mẫu:**
   ```sql
   SELECT 
       AccessDate AS [Ngày],
       EmployeeID AS [Mã NV],
       PersonName AS [Họ và Tên],
       Department AS [Bộ Phận],
       MIN(AccessTime) AS [Giờ Vào (In)],
       MAX(AccessTime) AS [Giờ Về (Out)],
       COUNT(*) AS [Số Lần Quẹt],
       MAX(CASE WHEN AuthenticationType = 'ACSEventFaceVerifyPass' THEN 'Face ID' ELSE 'Khác' END) AS [Hình Thức]
   FROM dbo.HCP_AccessRecord
   WHERE AccessDate = '2026-08-25'
   GROUP BY AccessDate, EmployeeID, PersonName, Department
   ORDER BY [Giờ Vào (In)] ASC;
   ```
3. **Giải thích luồng tích hợp tự động:**
   - Database `HCP_DATA` lưu trữ toàn bộ sự kiện gốc.
   - Vào lúc **04:30 AM hàng ngày**, sau khi HikCentral tính công xong, một Scheduled Job tự động đẩy dữ liệu sang Database MES / ERP của Vinatech để tự động tính lương và quản lý nhân sự mà không cần bất kỳ thao tác thủ công nào.

---

## 7. CHECKLIST XỬ LÝ TÌNH HUỐNG NHANH KHI DEMO

| Tình huống phát sinh | Nguyên nhân | Cách xử lý tức thì |
|---|---|---|
| Quẹt Face ID báo lỗi đèn đỏ / không mở cửa | Nhân sự chưa được gán vào Access Level `Door_2F` hoặc `All Door` | Vào tab *Kiểm soát truy cập* $\rightarrow$ *Chỉ định cấp độ truy cập* $\rightarrow$ Tích chọn tên nhân viên $\rightarrow$ Bấm Lưu. |
| Người mới chưa nhận diện được | Ảnh upload bị mờ, đeo khẩu trang kín, hoặc chưa đồng bộ xong | Đứng cách camera 0.8m - 1.2m, nhìn thẳng. Kiểm tra tab *Khắc phục sự cố* xem trạng thái nạp dữ liệu xuống thiết bị. |
| Muốn mở cửa khẩn cấp trong phòng họp | Muốn mở nhanh mà không cần thao tác quẹt mặt | Vào Web HikCentral $\rightarrow$ *Điểm truy cập* $\rightarrow$ Bấm nút **Mở cửa từ xa (Remote Open)**. |
| Màn hình Dashboard `http://localhost:8090/` không tải dữ liệu | Server Python bị tắt | Chạy file `start_server.bat` tại thư mục `Desktop\face id`. |

---
*Tài liệu được chuẩn bị hoàn tất bởi Antigravity AI Assistant.*
