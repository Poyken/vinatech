# 🕒 VINATECH ATTENDANCE & CMS SYNC MODULE

> **Vị trí:** `PROCESS/ATTENDANCE_CMS/`  
> **Chức năng:** Quản lý cấu trúc dữ liệu, thủ tục Stored Procedures và kịch bản đồng bộ dữ liệu máy chấm công vân tay (Fingerprint Attendance & CMS).

## Danh Mục Tệp Tin
- `CMS_Add_Fingers.sql`: Script nạp dấu vân tay mới vào CSDL CMS.
- `CMS_Search_FingerUser1.sql`: Tra cứu thông tin người dùng và mã vân tay.
- `CMS_TimeAttendance.sql`: Thủ tục xử lý dữ liệu quẹt thẻ/chấm công theo ca.
- `CMS_Transfer_EmployeesAttendance.sql`: Điều chuyển dữ liệu chấm công nhân viên sang bảng tổng hợp.
- `CMS_View_Time_Ngay.sql` & `CMS_View_Time_Dem.sql`: View phân tích quẹt thẻ theo ca Ngày và ca Đêm.
- `usp_SyncFingerData.sql`: Thủ tục đồng bộ dữ liệu vân tay tự động giữa máy chấm công và phần mềm quản trị.
- `export_*.ps1`: Các kịch bản trích xuất cấu trúc và sao lưu Stored Procedures của module CMS.
