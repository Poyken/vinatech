# TỔNG HỢP KIẾN THỨC VÀ HƯỚNG DẪN SỬ DỤNG HỆ THỐNG ECM (MỤC QUẢN TRỊ ADMIN)

*Tài liệu này tổng hợp toàn bộ các kết quả từ quá trình nghiên cứu, khảo sát thực tế trên hệ thống ECM của Vinatech.*

---

## PHẦN 1: THÔNG TIN HỆ THỐNG CHUNG

- **Tên hệ thống:** 문서중앙화 ADMIN (Hệ thống Trung tâm Tài liệu / ECM)
- **Địa chỉ truy cập:** `http://192.168.20.254/admin/main.php`
- **Tài khoản nghiên cứu:** `VVEAADMIN` (Mật khẩu: `VINA!@#TECH2024`)
- **Tình trạng hệ thống (Lưu ý rất quan trọng):**
  - Giới hạn License hiện tại: 350 người dùng.
  - Số lượng người dùng hiện tại: 382 người.
  - Tình trạng: **Vượt quá License (382/350)** ở cả Empower License và M-Drive License. *Điều này có thể sẽ gây lỗi khi bạn tạo thêm user mới toanh, nhưng không ảnh hưởng tới việc set quyền cho những user có sẵn.*

---

## PHẦN 2: TỪ ĐIỂN DỊCH THUẬT GIAO DIỆN ECM (HÀN - VIỆT)

Hệ thống sử dụng tiếng Hàn 100%. Dưới đây là dịch thuật các thẻ/menu quan trọng nhất mà tôi đã khảo sát:

### 1. Menu Chính (Thanh điều hướng trên cùng)
- **기본관리 (Quản lý cơ bản):** Nơi để quản lý thông tin các bộ phận, sơ đồ tổ chức và tài khoản người dùng cá nhân.
- **보안 파일 서버 (Máy chủ tập tin bảo mật):** Nơi cấu hình quyền và chia sẻ các thư mục mạng/thư mục chung. Đây là tính năng quan trọng nhất để cấp quyền ECM.
- **PC 저장 제어 (Bảo mật/Kiểm soát lưu trữ PC):** Quản lý các chính sách cài đặt bảo mật cho máy trạm.

### 2. Menu Điều hướng trái của "보안 파일 서버" (Quản lý Thư mục Mạng)
- **공용폴더 구성 (Cấu hình Thư mục Công cộng):** **<-- (QUAN TRỌNG NHẤT)** Dùng để cấp/thêm quyền truy cập cho user vào các thư mục Sales, Vinatec, Enesol.
- **부서 기본폴더 구성 (Cấu hình thư mục mặc định Phòng/Ban):** Dùng để tạo hàng loạt cấu trúc thư mục tiêu chuẩn thông qua thẻ file CSV.
- **폴더 비밀번호 관리 (Quản lý Mật khẩu Thư mục):** Cài đặt mật khẩu cho các thư mục nhạy cảm.
- **폴더 조회 / 파일 조회 (Tra cứu thư mục / Tra cứu tập tin):** Chức năng search tìm kiếm dữ liệu trên toàn hệ thống.
- **잠금 파일 해제 (Gỡ khóa tập tin):** Mở khóa cho những file đang bị treo do có user khác đang mở/chỉnh sửa.
- **삭제 파일 복구 (Khôi phục tập tin đã xóa):** Lấy lại dữ liệu từ thùng rác.

### 3. Phân loại Thư mục mạng (khi vào 공용폴더 구성)
Hệ thống cho phép chia nhỏ ổ đĩa theo nhiều loại:
- **조직 및 그룹 (Tổ chức & Nhóm):** Thư mục bám theo sơ đồ công ty (VD: Vinatec -> Vietnam Company...).
- **그룹 공유 (Chia sẻ Nhóm):** Các ổ cứng ảo dành riêng cho nhóm làm việc (Bao gồm nhóm **Sales team** nằm ở đây).
- **전체 공유 (Chia sẻ Toàn thể):** Dữ liệu rập khuôn ai cũng có quyền xem.
- **프로젝트 (Dự án):** Thư mục dữ liệu lập ra cho 1 dự án ngắn hạn.

### 4. Bảng tính năng trong Thư mục cụ thể (Các Tabs bên phải)
- **기본 (Cơ bản):** Hiển thị người tạo (생성자), tên thư mục (폴더 이름), và thứ tự hiển thị (폴더 시퀀스).
- **권한 (Quyền / Permissions):** Đây là tab cốt lõi để quyết định **ai (대상) có quyền gì (권한)** trên thư mục. 
- **공유 (Chia sẻ / Sharing):** Nếu thư mục không gán quyền trực tiếp, có thể dùng tab chia sẻ ("이 폴더를 공유합니다" = Có, "이 폴더를 공유하지 않습니다" = Không).
  *(Kinh nghiệm khảo sát: Bạn CHỈ CẦN dùng tab "권한" để phân quyền là đủ, tab "공유" thường để tắt cho đỡ rối - Ví dụ thư mục Regulation đang là như vậy).*

---

## PHẦN 3: KIẾN THỨC VỀ QUẢN LÝ QUYỀN (PERMISSION) VÀ VÍ DỤ THỰC TẾ

### Các tùy chọn Đối tượng (대상) để cấp quyền:
- **조직 (Tổ chức):** Cấp quyền cho toàn bộ 1 phòng ban.
- **그룹 (Nhóm):** Cấp quyền cho 1 nhóm (Group) được lập ra.
- **사용자 (Người dùng cá nhân):** Cấp quyền cho 1 nhân viên cụ thể thông qua ID (Đây là thứ bạn dùng để cấp cho VŨ THỊ HÀ TRANG).

### Các tùy chọn mức độ quyền (권한):
- **모든 권한 (Toàn quyền):** Bạn có thể Xem, Sửa, Xóa và tạo thêm file/thư mục.
- **읽기/쓰기 (Đọc/Ghi):** Chỉ có thể xem và sửa, thông thường không có quyền xóa thay đổi cấu trúc thư mục con/xóa file lớn.
- **읽기 (Chỉ đọc):** Không chỉnh sửa được file.

### Tham khảo cách hệ thống Cấu hình quyền (Từ file Regulation có sẵn)
Tôi đã tìm vào thử thư mục **비나텍 사규(Regulation)** (Quy định nội bộ công ty) để xem Admin trước đó đã phân quyền ra sao bằng cách soi tab "Quyền". Hệ thống đang được cấu hình rất chuẩn:
1. Thư mục được chia quyền cho nhiều **NHÓM (그룹)** một mạng lưới như: ESH (1000_K1020), Quality control (1000_K1300), v.v.
2. Tất cả họ đều được cấp quyền là **"모든 권한" (Toàn quyền)**.
3. Tab Chia sẻ vẫn đặt là "Không chia sẻ". (Chỉ cần tab Quyền là người dùng tự mở được).

---

## PHẦN 4: HƯỚNG DẪN CHI TIẾT CẤP QUYỀN CHO USER VŨ THỊ HÀ TRANG

Với yêu cầu của User: *"vutrang@vina.co.kr (Vina Enesol_CS team) xin quyền vào ổ Sales chung"*

### Bước 1: Điều tra các User
- Chủ Group Sales là **vvsales28 (NGUYỄN TRÀ LINH)**.
- User cần xin quyền là **vutrang@vina.co.kr (VŨ THỊ HÀ TRANG)** (Thuộc Admin-CS). Trạng thái tài khoản = 사용 (Bình thường). Không cần phải tạo tài khoản mới.

### Bước 2: Tìm Thư mục Sales team
1. Tại ECM Admin, bấm chọn Menu trên cùng: **보안 파일 서버 (Máy chủ bảo mật)**.
2. Sidebar trái: **공용폴더 구성 (Cấu hình Thư mục chung)**.
3. Dưới chữ "공용폴더 구성" có nút bấm ô tìm kiếm dropbar. Không dùng *조직 및 그룹* , hãy bấm vào dấu cộng **[+]** bên cạnh để tìm.
4. Ở ô popup tìm kiếm (Nhóm), gõ chữ `Sales` rồi nhấn **검색**.
5. Chọn nhóm **Sales team** và nhấn **확인** (OK). Cây cấu trúc 11 thư mục con của Sales team (Từ 0 đến 11) sẽ bung ra. Vina Enesol nằm ở thư mục số **9. VINA Enesol**.

### Bước 3: Áp dụng Quyền
1. Nhấp chuột vào thư mục cha gốc **Sales team** (Hoặc bấm thẳng vào **9. VINA Enesol** nếu bạn chỉ muốn cấp quyền thư mục nhỏ).
2. Nhìn sang Panel bên phải, chọn tab nằm ở giữa là **권한 (Quyền)**.
3. Tại dòng gán quyền ( 대상 | 권한 ) đang ở chế độ chờ thêm mới:
   - Dòng 대상: Bấm mũi tên xổ xuống chọn **사용자 (Người dùng cá nhân)**.
   - Khi chọn Người dùng, popup Tìm kiếm Người Bật Lên.
   - Cửa sổ nhỏ này: gõ `vutrang` vào ô tìm kiếm -> Nhấn **검색** -> Chọn tick "VŨ THỊ HÀ TRANG" -> Nhấn **확인 (OK)**.
   - Dòng 권한 (bên phải): Mặc định là **모든 권한 (Toàn Quyền)**. Tùy ý bạn để vậy luôn cho tiện làm việc.
4. Bấm chữ mầu Cam nổi bật **추가 (THÊM / ADD)**.
5. *(Phải rất thận trọng)* Sau khi bấm THÊM, xem tên của Vũ Thị Hà Trang có rơi xuống cái bảng trắng tinh "데이터가 없습니다 (Không có dữ liệu)" bên dưới hay chưa. Nếu có rồi là OK. 
6. Bấm nút Mầu Cam số 2 dưới cùng: **하위 폴더 일괄 적용 (Áp Dụng Đồng Loạt Cho Thư Mục Con)**. Như vậy quyền của Hà Trang sẽ được đồng bộ vào cả 11 Thư mục Sales bên trong mà không cần làm bằng tay.

### Cuối cùng
Chỉ cần nhắn tin Reply lại email bảo **vutrang** đăng xuất (Log Out) cái phần mềm ổ đĩa ảo ECM Drive trên máy tính và đăng nhập lại là thấy thư mục Sales. Không cần Reset máy tính!

---
Tài liệu được kết xuất từ Trợ lý AI dựa trên hệ thống thực tế (Chưa thực hiện bất kỳ thay đổi nào làm ảnh hưởng đến dữ liệu công ty).
