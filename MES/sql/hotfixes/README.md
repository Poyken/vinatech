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
| **06** | 2026-06-11 | `usp_QcInspectionGroup_HY_get`, `usp_QcInspectionItem_HY_get`, `usp_QcInspectionGroup_HY_iud`, `usp_QcInspectionItem_HY_iud` | Quản lý QC Hưng Yên (QC Group/Item HY) | Tạo lại 4 SP quản lý kiểm tra QC và các bảng liên quan cho chi nhánh Hưng Yên (_HY). | Sẵn sàng bàn giao |
| **07** | 2026-06-11 | `STB_QcInspectionGroup_HY`, `STB_QcInspectionItem_HY` | Di cư dữ liệu QC Hưng Yên (QC Data Migration) | Sao chép toàn bộ dữ liệu danh mục QC từ 2 bảng cũ sang 2 bảng mới của chi nhánh Hưng Yên. | Sẵn sàng bàn giao |
| **08** | 2026-06-11 | `usp_MaterialQcInspectionItem_ByMaterial_HY_get`, `usp_MaterialQcInspectionItem_HY_iud` | Tiêu chuẩn QC NVL Hưng Yên (Material QC Criteria HY) | Tạo lại 2 SP quản lý tiêu chuẩn kiểm tra nguyên vật liệu và bảng liên quan cho chi nhánh Hưng Yên (_HY). | Sẵn sàng bàn giao |
| **09** | 2026-06-11 | `STB_MaterialQcInspectionItem_HY` | Di cư dữ liệu tiêu chuẩn QC NVL Hưng Yên | Sao chép toàn bộ dữ liệu tiêu chuẩn kiểm tra NVL từ bảng cũ sang bảng mới của chi nhánh Hưng Yên. | Sẵn sàng bàn giao |
| **10** | 2026-06-11 | Bộ SP IQC đầu `_HY` (20 SPs) | Phiếu kiểm tra IQC Hưng Yên (Incoming IQC HY) | Tạo lại 20 SP kiểm tra chất lượng nguyên vật liệu đầu vào và bảng liên quan cho chi nhánh Hưng Yên (_HY). | Sẵn sàng bàn giao |
| **11** | 2026-06-11 | `STB_MaterialQcInspectionGroup_HY` | Di cư dữ liệu cấu hình nhóm QC NVL Hưng Yên | Sao chép dữ liệu cấu hình nhóm kiểm tra nguyên vật liệu từ bảng cũ sang bảng mới của chi nhánh Hưng Yên. | Sẵn sàng bàn giao |
| **12** | 2026-06-11 | Bộ SP Quản lý PO đầu `_HY` (7 SPs) | Quản lý Đơn hàng sản xuất Hưng Yên (Create PO HY) | Tạo lại 7 SP quản lý đơn hàng sản xuất (PO) cho chi nhánh Hưng Yên. | Sẵn sàng bàn giao |
| **13** | 2026-06-11 | Bộ SP Kế hoạch ngày `_HY` (4 SPs) | Quản lý Kế hoạch sản xuất ngày Hưng Yên (Create Daily Plan HY) | Tạo lại 4 SP quản lý kế hoạch ngày và tạo lot sản phẩm cho chi nhánh Hưng Yên. | Sẵn sàng bàn giao |
| **14** | 2026-06-11 | Bộ SP Quy trình trộn điện cực `_HY` (6 SPs) | Quản lý Quy trình sản xuất điện cực Hưng Yên (Mixing Prcs Card HY) | Tạo lại 6 SP quản lý quy trình trộn và sấy lò điện cực cho chi nhánh Hưng Yên. | Sẵn sàng bàn giao |
| **15** | 2026-06-11 | Bộ SP Kết quả đo điện cực `_HY` (21 SPs) | Quản lý Kết quả đo điện cực Hưng Yên (Electrode Measure Result HY) | Tạo lại 21 SP quản lý kết quả đo điện cực ở từng công đoạn cho chi nhánh Hưng Yên. | Sẵn sàng bàn giao |
| **16** | 2026-06-11 | Bộ SP Lịch sử sản xuất điện cực `_HY` (2 SPs) | Báo cáo Lịch sử sản xuất điện cực Hưng Yên (Electrode Route Hist HY) | Tạo lại 2 SP tra cứu lịch sử sản xuất và lỗi điện cực cho chi nhánh Hưng Yên. | Sẵn sàng bàn giao |
| **17** | 2026-06-11 | Bộ SP Kiểm tra chất lượng điện cực `_HY` (6 SPs) | Quản lý Kiểm tra QC điện cực Hưng Yên (QC Electrode Inspection HY) | Tạo lại 6 SP kiểm tra chất lượng điện cực đầu vào và xử lý phế/khóa lot cho chi nhánh Hưng Yên. | Sẵn sàng bàn giao |


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
