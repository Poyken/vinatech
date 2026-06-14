# 📋 Báo Cáo Phân Tích Chuyên Sâu Các Nghiệp Vụ Từ Sách Hướng Dẫn Groupware Vinatech

> **Ngày lập:** 14/06/2026
> **Nguồn trích xuất:** Tự động giải nén XML và khai phá dữ liệu từ 14 tệp PowerPoint hướng dẫn chính thức trong thư mục `GROUPWARE_KNOWLEDGE_BASE`.
> **Mục tiêu:** Cung cấp thông tin thực tế về cách vận hành biểu mẫu, tuyến phê duyệt mặc định, các trường thông tin bắt buộc và các ràng buộc nghiệp vụ cụ thể.

---

## 📂 Danh Mục Các Tệp Tin Hướng Dẫn Đã Khai Phá

Dưới đây là kết quả trích xuất text thành công từ các tệp PowerPoint hướng dẫn:

| Tên File Hướng Dẫn gốc | Số lượng slide | Tên File Text trích xuất |
|-----------------------|---------------|--------------------------|
| `GROUPWARE PURCHASE, SALES FUNCTION MANUAL.pptx` | 107 slides | `GROUPWARE PURCHASE, SALES FUNCTION MANUAL.txt` |
| `Hướng dẫn Draft Document.pptx` | 8 slides | `Hướng dẫn Draft Document.txt` |
| `Hướng dẫn Finished Good warehouse.pptx` | 8 slides | `Hướng dẫn Finished Good warehouse.txt` |
| `Hướng dẫn Form Yêu cầu tuyển dụng - Emp Request.pptx` | 9 slides | `Hướng dẫn Form Yêu cầu tuyển dụng - Emp Request.txt` |
| `Hướng dẫn Form nghỉ việc - Employee Retire Document.pptx` | 10 slides | `Hướng dẫn Form nghỉ việc - Employee Retire Document.txt` |
| `Hướng dẫn Groupware_Form đi công tác.pptx` | 30 slides | `Hướng dẫn Groupware_Form đi công tác.txt` |
| `Hướng dẫn Groupware_Form đăng ký nhà thầu_khách hàng.pptx` | 15 slides | `Hướng dẫn Groupware_Form đăng ký nhà thầu_khách hàng.txt` |
| `Hướng dẫn Groupware_Form đăng ký đi làm ngày lễ_ngày nghỉ.pptx` | 15 slides | `Hướng dẫn Groupware_Form đăng ký đi làm ngày lễ_ngày nghỉ.txt` |
| `Hướng dẫn Groupware_Yêu cầu mua.pptx` | 12 slides | `Hướng dẫn Groupware_Yêu cầu mua.txt` |
| `Hướng dẫn groupware_Yêu cầu thanh toán.pptx` | 15 slides | `Hướng dẫn groupware_Yêu cầu thanh toán.txt` |
| `Hướng dẫn sửa đổi BOM trên ERP và Groupware.pptx` | 8 slides | `Hướng dẫn sửa đổi BOM trên ERP và Groupware.txt` |
| `Hướng dẫn tạo PO trên Groupware.pptx` | 13 slides | `Hướng dẫn tạo PO trên Groupware.txt` |
| `Hướng dẫn tạo PO và Kế hoạch ngày trên Groupware.pptx` | 24 slides | `Hướng dẫn tạo PO và Kế hoạch ngày trên Groupware.txt` |
| `Hướng dẫn đăng ký các loại code.pptx` | 16 slides | `Hướng dẫn đăng ký các loại code.txt` |

---

## 🎯 Chi Tiết Nghiệp Vụ Quan Trọng Trích Xuất Được

### 1. Quy Trình Lập Yêu Cầu Tuyển Dụng (Emp Request)
*   **Mục đích:** Đề xuất phê duyệt nhu cầu bổ sung nhân lực cho các phòng ban.
*   **Đường dẫn:** `Electronic Document` ➔ `Human Sources` ➔ `Emp Request`
*   **Tuyến phê duyệt mặc định:** `Team Leader` ➔ `Group Leader` (CC hoặc thêm người duyệt tùy chọn).
*   **Các trường dữ liệu bắt buộc:**
    1.  **Phân loại tuyển dụng:** Tuyển thay thế, Tuyển mới, hoặc Tuyển bổ sung.
    2.  **Phân loại nhân viên:** Nhân viên chính thức, Thử việc, hoặc Công nhân thời vụ.
    3.  **Số lượng tuyển dụng.**
    4.  **Ngày đến hạn yêu cầu.**
    5.  **Kinh nghiệm / Trình độ học vấn / Chuyên ngành liên quan / Giới tính ưu tiên.**
*   **Hủy đơn:** Người dùng chỉ có thể nhấn **Hủy đơn đăng ký** khi tờ trình chưa được phê duyệt hoàn toàn. Form sau khi hủy sẽ quay về mục **Temporary Storage (Lưu trữ tạm thời)** để sửa hoặc xóa.

### 2. Quy Trình Lập Tờ Trình Nghỉ Việc (Employee Retire Document)
*   **Mục đích:** Phê duyệt nghỉ việc cho cán bộ công nhân viên.
*   **Đường dẫn:** `Electronic Document` ➔ `Human Sources` ➔ `Employee Retire Document`
*   **Tuyến phê duyệt bắt buộc:** `Team Leader` ➔ `Group Leader` ➔ `Quản lý người Hàn` ➔ `Bác Jang (Group Leader)` ➔ `Bác COO` (CEO duyệt cuối).
*   **Ràng buộc đăng ký hộ:**
    *   Nếu đăng ký hộ cho công nhân/nhân viên dưới quyền: **Bắt buộc phải chọn lại trường "Người dùng"** là tên của người nghỉ việc thực tế. Nếu không, hệ thống sẽ mặc định đăng ký cho người trực tiếp làm form.
*   **Các trường dữ liệu bắt buộc:**
    1.  Ngày nghỉ việc & Ngày làm việc cuối cùng.
    2.  Người đảm nhiệm bàn giao công việc thay thế.
    3.  Thông tin liên lạc & Địa chỉ liên hệ sau khi nghỉ (để gửi tài liệu chốt sổ BHXH).
    4.  Lý do xin nghỉ việc và mô tả chi tiết.

### 3. Vận Hành Kho Thành Phẩm (Finished Good Warehouse)
*   **Vận hành quét mã vạch:** Thủ kho mở trạm **MES FG01** quét mã vạch **Packing ID (Box/Carton)**.
*   **Ràng buộc chất lượng:** Hệ thống tự động truy vấn DB để đảm bảo Box này đã đạt trạng thái **OQC PASS** (kiểm định chất lượng xuất xưởng tại màn hình **C530/C546**).
*   **Pallet hóa & Container:**
    1.  Gom các Box lẻ thành Pallet và in tem Pallet dán niêm phong tại màn hình **MES B750**.
    2.  Quét mã Pallet dán lên container và đối chiếu với lệnh xuất hàng gốc tại màn hình **MES B752** trước khi xe lăn bánh.

### 4. Quy Trình Tạo PO Sản Xuất & Kế Hoạch Ngày
*   **Tạo PO sản xuất:** Lấy thông tin từ Suju bán hàng đã duyệt. Bắt buộc kiểm tra phiên bản BOM được nạp. **Chỉ BOM version 2001 hoặc 2002 (Cell line mới)** mới được MES chấp nhận.
*   **Đồng bộ xuống MES B310:** Khi PO ở trạng thái phê duyệt "Sản xuất" trên Groupware, dữ liệu sẽ ngay lập tức hiển thị trên màn hình **MES B310**.
*   **Lập Kế hoạch ngày:** Sử dụng biểu mẫu `dailyProductionOrderDocument` để phân bổ kế hoạch ngày xuống Line sản xuất, Ca làm việc. Dữ liệu đổ về bảng `STB_DayProdPlan` và hiển thị trên màn hình **MES B450** để chia Lot và in nhãn.

---

## 🛠️ Cẩm Nang Xử Lý Sự Cố Khách Quan
Dựa trên phân tích 14 tệp hướng dẫn, dưới đây là bảng tra cứu nhanh các lỗi vận hành phổ biến:

| Triệu chứng | Nguyên nhân thực tế | Giải pháp khắc phục |
|-------------|---------------------|---------------------|
| Không thể tìm thấy form xin mua PO để liên kết thanh toán | Tờ trình PO/Expense Report gốc vẫn đang ở trạng thái chờ duyệt hoặc bị từ chối | Kiểm tra lại mục *My Documents*, liên hệ người duyệt tiếp theo để ký thông qua |
| Khi làm đơn nghỉ việc bị sai tên người nghỉ | Không sửa trường "Người dùng" khi đăng ký hộ | Thực hiện **Hủy đơn đăng ký** (nếu chưa duyệt xong), vào mục *Temporary Storage* chọn sửa lại trường "Người dùng" |
| Mã vật tư mới không xuất hiện trên MES A230 | Tuyến phê duyệt mặc định chưa duyệt xong hoặc tiến trình ERP sync bị trễ | Đợi line phê duyệt hoàn tất. Chạy SQL query kiểm tra cờ sync trên bảng master data nếu quá 30 phút chưa thấy mã |
| Không in được tem lô tại màn hình B450 | Trạng thái kế hoạch ngày chưa được xác nhận trên Groupware | Người lập kế hoạch ngày trên Groupware phải tích chọn dòng kế hoạch và nhấn **"Mục tiêu lựa chọn Đã xác nhận"** |
