# 🛠️ DATABASE HOTFIX REGISTRY

Thư mục này lưu trữ lịch sử các đoạn script SQL Hotfix đã được triển khai hoặc bàn giao trên hệ thống cơ sở dữ liệu production **SmartFactoryV2**. 

Do các đối tượng cơ sở dữ liệu (Stored Procedures, Tables, Views...) không được theo dõi phiên bản trực tiếp qua Git, thư mục này là nguồn lịch sử duy nhất để tra cứu các thay đổi cấu trúc/logic DB.

---

## 📋 DANH SÁCH HOTFIX ĐÃ TRIỂN KHAI

| Hotfix ID | Ngày triển khai | Đối tượng tác động | Nghiệp vụ liên quan | Nội dung thay đổi | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **01** | 2026-06-10 | `usp_VN_DryOver` | Lò sấy (Dry Oven) | Sửa độ ưu tiên toán tử `AND/OR` làm bypass kiểm tra công đoạn V-22. | Đã triển khai |
| **02** | 2026-06-10 | `usp_GetDopingJigHistory` | Gá nạp Doping | Fix lỗi đồng bộ lịch sử jig doping giữa các nhà máy. | Đã triển khai |
| **03** | 2026-06-10 | `usp_SlittingKnifeLife` | Tuổi thọ dao Slitting | Điều chỉnh công thức tính tuổi thọ dao dựa trên mét cắt thực tế. | Đã triển khai |
| **04** | 2026-06-10 | `usp_ReworkPermission` | Phân hệ Rework | Fix phân quyền cứng (hardcoded permission) làm lỗi phân quyền nhân viên. | Đã triển khai |
| **05** | 2026-06-10 | `usp_ReturnsFGIqcCheck` | Trả hàng (Returns) | Thêm kiểm tra IQC bắt buộc trước khi nhập kho thành phẩm lỗi trả về. | Đã triển khai |

---

## 🛡️ HƯỚNG DẪN KHI TẠO HOTFIX MỚI

Khi bạn hoặc AI Agent cần tạo một hotfix mới, bắt buộc phải tuân theo các quy tắc sau:

### 1. Quy tắc đặt tên file
Đặt tên file theo định dạng: `[XX]_FIX_[TEN_NGHIEP_VU_VIET_HOA].sql`
*   Ví dụ: `06_FIX_WMS_FIFO_SORTING.sql`

### 2. Định dạng file SQL bắt buộc
Tất cả các file hotfix phải bắt đầu bằng khối chú thích (header metadata) và bọc toàn bộ code chỉnh sửa trong một giao dịch (`BEGIN TRAN` ... `ROLLBACK TRAN`) để kiểm tra an toàn trước khi DBA (Database Administrator) chạy thực tế.

```sql
-- =============================================
-- Hotfix ID: [XX]_FIX_[TEN_NGHIEP_VU]
-- Target Object: [Tên Stored Procedure hoặc Bảng]
-- Author: [Tên người thực hiện hoặc AI Agent]
-- Date: YYYY-MM-DD
-- Description: [Mô tả chi tiết lỗi và phương án sửa]
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;

PRINT 'Starting Hotfix: [XX]...';

-- 1. Triển khai thay đổi logic ở đây (ALTER PROC, v.v.)
-- ...

-- 2. Chạy thử nghiệm / Giả lập (Simulation Test)
-- ...

-- 3. HỦY BỎ GIAO DỊCH (Bắt buộc để chạy an toàn qua deploy_tool)
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
```

### 3. Đăng ký vào bảng
Sau khi bàn giao hoặc triển khai hotfix thành công, hãy cập nhật dòng thông tin tương ứng vào bảng danh sách trong file `README.md` này để tiện theo dõi.
