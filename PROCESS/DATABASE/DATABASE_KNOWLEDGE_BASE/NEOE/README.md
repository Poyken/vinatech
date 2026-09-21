# 🏢 NEOE — Douzone ERP iU Enterprise Database Knowledge Base

> **Máy chủ:** `dbserver.hycap.co.kr,5398` | **CSDL:** `NEOE`  
> **Quy mô thực tế:** **4,883 Bảng (Tables)**, **506 Khung nhìn (Views)**, **32,194 Thủ tục (Stored Procedures)**, **34 Khóa ngoại (FKs)**  
> **Vai trò:** Sổ cái trung tâm (General Ledger), Single Source of Truth cho Master Data (Item, BOM, Vendor, Warehouse).

---

## 🗺️ 1. Phân Bổ Tiền Tố Module (Module Prefix Topology — 4,883 Bảng)

| Tiền Tố | Số Bảng | Phân Hệ Nghiệp Vụ | Chức Năng Cốt Lõi |
| :--- | :---: | :--- | :--- |
| **WC_** | **757** | Work Center | Trung tâm làm việc, năng lực máy, tính giá thành công đoạn |
| **FI_** | **631** | Finance & Accounting | Sổ cái tài chính, chứng từ ghi sổ (`FI_DOCU`/`FI_DOCU_D`), tài khoản, thuế |
| **HR_** | **407** | Human Resources | Danh mục nhân sự (`MA_EMP`), bảng lương, bảo hiểm xã hội, chấm công |
| **WP_** | **336** | Work Plant | Lệnh sản xuất phân xưởng, kế hoạch nhà máy |
| **CA_** | **328** | Cost Allocation | Phân bổ chi phí sản xuất chung, giá thành đơn vị sản phẩm |
| **MA_** | **274** | Master Data | Danh mục gốc: Vật tư (`MA_ITEM`), Đối tác (`MA_PARTNER`), Kho (`MA_SL`) |
| **WH_** | **264** | Warehouse Management | Vị trí kho vật lý ERP, kiểm kê đối chiếu tồn kho định kỳ |
| **PR_** | **234** | Production Management | Định mức kỹ thuật Bill of Materials (`PR_BOM`), yêu cầu sản xuất |
| **WS_** | **233** | Work Schedule | Lịch làm việc nhà máy, ca kíp, ngày nghỉ lễ |
| **WM_** | **184** | Warehouse Movement | Điều chuyển kho nội bộ, theo dõi biến động vật tư |
| **SA_** | **182** | Sales & Distribution | Đơn hàng khách hàng (Suju `SA_SOH`/`L`), phiếu xuất kho (`SA_GIRH`/`L`) |
| **PU_** | **120** | Purchasing | Đơn mua hàng (`PU_POH`/`L`), phiếu nhập kho mua hàng (`PU_RCVH`/`L`) |

---

## 📊 2. Top Bảng Có Khối Lượng Dữ Liệu Lớn Nhất Trong `NEOE`

| Tên Bảng | Số Dòng (Live Rows) | Vai Trò Nghiệp Vụ & Ý Nghĩa |
| :--- | :---: | :--- |
| **PR_BOM_LOG** | **3,948,222** | Lịch sử thay đổi và cập nhật định mức BOM sản phẩm |
| **MA_PITEM_LOG** | **2,760,843** | Lịch sử thay đổi thuộc tính vật tư và mã hàng hóa |
| **MM_QTIO_LOG** | **1,175,728** | Nhật ký kiểm toán các giao dịch nhập xuất kho vật tư |
| **MM_QTIOH_LOG** | **1,120,289** | Nhật ký đầu phiếu giao dịch nhập xuất kho |
| **PR_REQH** | **984,842** | Đầu phiếu yêu cầu sản xuất |
| **HR_WTMCALC** | **959,575** | Bảng tính toán giờ làm việc phục vụ tính lương nhân viên |
| **MM_QTIO** | **716,371** | Chi tiết giao dịch nhập xuất tồn kho thời gian thực |
| **MA_LOGIN_NEW** | **695,816** | Nhật ký đăng nhập của người dùng vào phần mềm Douzone ERP |
| **PR_QTIO** | **632,974** | Chi tiết sản lượng sản xuất thực tế nhập kho |
| **PR_QTIOH** | **589,482** | Đầu phiếu sản lượng sản xuất hoàn thành |
| **HR_WTMTOT** | **578,255** | Tổng hợp công làm việc của nhân viên |
| **FI_DOCU** | **437,784** | Số lượng chứng từ kế toán chính thức trong Sổ cái |
| **MM_QTIOH** | **425,236** | Đầu phiếu nhập xuất nguyên vật liệu |

---

## ⚡ 3. Phân Hệ Stored Procedures Khổng Lồ (32,194 SPs)

Các Stored Procedures trong ERP Douzone được chuẩn hóa với tiền tố `UP_`:
- **`UP_WC` (7,204 SPs):** Tính toán chi phí công đoạn và phân bổ năng lực Work Center.
- **`UP_FI` (4,734 SPs):** Hạch toán tự động, kiểm tra cân đối tài khoản, khóa sổ kế toán tháng/năm.
- **`UP_HR` (2,582 SPs):** Tính lương tự động, khấu trừ thuế TNCN, đóng BHXH.
- **`UP_WM` (2,146 SPs):** Nghiệp vụ luân chuyển kho và cập nhật số dư tồn kho.
- **`UP_SA` (1,632 SPs):** Xử lý đơn hàng Suju, xuất hóa đơn VAT điện tử, kiểm tra hạn mức tín dụng khách hàng.
- **`UP_PU` (1,558 SPs):** Đăng ký PO mua hàng, đối chiếu 3 chiều (PO - Receipt - Invoice).
- **`UP_CA` (1,439 SPs):** Kết chuyển chi phí và tính giá thành sản xuất thực tế.
- **`UP_PR` (1,329 SPs):** Triển khai BOM đa cấp và lập kế hoạch nhu cầu nguyên vật liệu (MRP).

---

## 🛠️ 4. Tra Cứu ERP Nhanh Bằng CLI Hub `.\db.ps1`
```powershell
# Xem thống kê tổng quan ERP
.\db.ps1 stats -Profile ERP

# Tra cứu cấu trúc bảng Master Vật tư
.\db.ps1 schema -Profile ERP -Table MA_ITEM

# Tìm kiếm Stored Procedure mua hàng
.\db.ps1 sp -Profile ERP -Search "PU_PO"

# Truy vấn an toàn chứng từ kế toán mới nhất
.\db.ps1 query -Profile ERP "SELECT TOP 10 NO_DOCU, CD_COMPANY, DT_DOCU, AM_DOCU FROM FI_DOCU WITH(NOLOCK) ORDER BY DT_DOCU DESC"
```
