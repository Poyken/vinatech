# KB_28 — Bản Đồ Đối Tượng Hệ Thống (976 Bảng, 3314 SPs & 1442 Màn Hình)

> **Màn hình liên quan:** Z-System Config, SmartFramework Screens Registration, Metadata Directory
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 📊 Tổng Quan Quy Mô Hệ Thống NAIS MES (Vinatech)

Hệ thống NAIS MES tại Vinatech vận hành trên một kiến trúc CSDL SQL Server đồ sộ, được thiết kế theo mô hình **Đa Phân Hệ Tích Hợp Động (Dynamic Integrated Subsystems)**. Quy mô hệ thống bao gồm:
* **976 Bảng cơ sở dữ liệu (Database Tables)** chia thành bảng chuẩn (Standard SmartFactory) và các bảng tùy chỉnh riêng cho nhà máy Việt Nam (Vietnam Custom).
* **3,314 Stored Procedures (SPs)** đảm nhận toàn bộ logic tính toán, kiểm tra (validation) và điều hướng dữ liệu.
* **1,442 Màn hình (Screens)** được đăng ký động trong hệ thống thông qua giao diện SmartFramework.

---

## 🗂️ 2. Phân Loại 976 Bảng Cơ Sở Dữ Liệu (Database Tables)

Toàn bộ 976 bảng trong database `SmartFactoryV2` được phân chia một cách hệ thống dựa trên tiền tố (Prefix) và phân hệ nghiệp vụ:

| Nhóm Prefix | Số Lượng Bảng | Chức Năng & Ý Nghĩa Nghiệp Vụ | Ví Dụ Điển Hình |
|:---|:---:|:---|:---|
| **`STB_`** | **721** | Bảng chuẩn của hệ thống SmartFactory (Hàn Quốc). Quản lý dữ liệu nền, WIP, WMS, thiết bị, và lịch sử công đoạn chuẩn. | `STB_SetInfo`, `STB_ProdRouteHist`, `STB_MaterialLotInfo`, `STB_ProductionOrderInfo` |
| **`STB_VN_`** | **117** | Các bảng tùy chỉnh riêng cho thị trường Việt Nam (Bắc Giang, Hà Nam). Lưu thông tin gộp module, xuất/nhập thành phẩm, ghi nhận phế phẩm thực tế cân scale. | `STB_VN_MASTERMODULES`, `STB_VN_DETAILMODULES`, `STB_VN_FINISHGOODS_forQCAudit`, `STB_VN_SCRAP_AFTERPRODUCTIONS` |
| **`STB_VVT_`** | **23** | Bảng tùy chỉnh nâng cao cho Vinatech Vina (điện cực, ESR, giá công đoạn, cảnh báo). | `STB_VVT_ESRDATA`, `STB_VVT_StagePrices`, `STB_VVT_SortingErrorData` |
| **`STB_ESM_` / `ESM_`** | **18** | Bảng tích hợp cầu nối với hệ thống ERP Douzone và Groupware (sync kế hoạch ngày, BOM, dữ liệu kế toán). | `ESM_DayProdPlan`, `ESM_ProdRouteHist` |
| **`VNTVN_`** | **11** | Bảng phân quyền, quản lý tài khoản người dùng Việt Nam. | `VNTVN_Users`, `VNTVN_UserRoles` |
| **`AspNet`** | **7** | Hệ thống bảng bảo mật Identity mặc định. | `AspNetUsers`, `AspNetRoles` |
| **`OUT_`** | **2** | Bảng giao tiếp Cargo, đồng bộ kết quả xuất kho thành phẩm ra cảng. | `OUT_ASN` (yêu cầu), `OUT_RSLT` (kết quả) |
| **`Other`** | **76** | Bảng tạm, bảng backup dữ liệu lịch sử hoặc trung gian. | `FinishGoodMESInstock_HN`, `stb_DetailAgaingHN` |

---

## ⚙️ 3. Bản Đồ 3,314 Stored Procedures (Logic Engine)

Logic nghiệp vụ của hệ thống không nằm ở ứng dụng Client, mà được đóng gói toàn bộ trong các Stored Procedures tại database để tối ưu hóa hiệu năng giao dịch. Các SPs được phân loại như sau:

### A. Phân loại theo Logic Giao Dịch
* **Stored Procedures Truy Vấn (SELECT Queries) — 998 SPs:**
  * Có tiền tố `usp_Get...` hoặc hậu tố `..._get`.
  * Chỉ thực hiện các câu lệnh `SELECT` để đổ dữ liệu lên Grid hoặc Dashboard trên UI Client.
  * Ví dụ: `usp_GetMaterialLotInfoForReturn`, `usp_WarehouseDelivery_get`.
* **Stored Procedures Nghiệp Vụ/Giao Dịch (Action / IUD) — 676 SPs:**
  * Có tiền tố `usp_Do...` hoặc hậu tố `..._iud`.
  * Thực hiện chèn (`INSERT`), cập nhật (`UPDATE`), hoặc xóa (`DELETE`) dữ liệu trong các khối giao dịch (`BEGIN TRANSACTION ... COMMIT`).
  * Ví dụ: `usp_DoApplyStocktakingToStock`, `usp_SalesOrder_iud`.

### B. Phân loại theo Phân Hệ Tùy Chỉnh Việt Nam (632 SPs)
Các kỹ sư EA/MES Việt Nam đã viết thêm 632 SPs để bổ sung tính năng phù hợp với đặc thù sản xuất tại Việt Nam:
* **`usp_VN_...` (370 SPs):** Quản lý gộp module, xuất nhập thành phẩm Bắc Giang/Hà Nam, kiểm tra QC Audit, chấm công thực tế. (Ví dụ: `usp_VN_WaitingCheckBeforeExport_forQCAudit_Pass`).
* **`usp_Vietnam_...` (156 SPs):** Quản lý cân trọng lượng, cấu hình Andon, in tem nhãn Foxconn/Schneider/Digi-Key. (Ví dụ: `usp_Vietnam_AndonDetail_get`).
* **`usp_VVT_...` (105 SPs):** Logic kiểm tra FIFO thành phẩm, kiểm tra HOLD kho, ghi nhận dữ liệu ESR. (Ví dụ: `usp_VVT_ESRdata_uid`).
* **`usp_HN_...` (1 SP):** SP chuyên dụng cho xuất nhập thành phẩm Hà Nam qua Excel (`usp_HN_FinishGood_ImportExcel_uid`).

---

## 🖥️ 4. Bản Đồ Phân Hệ 1,442 Màn Hình (SmartFramework Screens)

Hệ thống NAIS MES có tổng cộng **1,442 màn hình** được khai báo trong hệ thống. Mã giao dịch màn hình (**TCode**) là định danh chính của màn hình, được phân nhóm nghiệp vụ theo chữ cái đầu tiên:

| Ký tự TCode | Số Màn Hình | Phân Hệ Nghiệp Vụ | Màn Hình Tiêu Biểu |
|:---:|:---:|:---|:---|
| **`B`** | **372** | **Production Management (Sản xuất):** Lịch trình, Work Orders, POs, công đoạn ráp Cell/Module, gộp Box, Andon, báo phế trên Line. | `B301` (PO Info), `B530` (Prod Route Input), `B523` (Vietnam Đóng gói), `B882` (Andon Report) |
| **`H`** | **160** | **Equipment & Maintenance (Bảo trì/Thiết bị):** Lịch bảo dưỡng máy, Spare Parts tồn kho, hiệu chuẩn dụng cụ đo. | `H301` (Spare Parts Basic Info) |
| **`C`** | **154** | **Quality Control (QC):** Thiết lập hạng mục kiểm tra, kết quả IQC, kiểm định PQC, duyệt xuất xưởng OQC/FOQC, OCV & Aging. | `C112` (AQL Basic Rules), `C522` (Aging ESR SD), `C530` (QC Audit) |
| **`F`** | **124** | **WMS & Inventory (Kho WMS):** Nhập kho NVL, di chuyển vị trí, FIFO validation, xuất kho sản xuất, kiểm kê kho vật lý. | `F330` (Goods Receipt), `F750` (Kiểm kê kho) |
| **`Z`** | **52** | **System Admin (Hệ thống):** Menu cấu hình, phân quyền vai trò, định nghĩa String Resource đa ngôn ngữ. | `Z110` (Screen Config), `Z220` (Role Screen Mapping) |
| **`A`** | **33** | **Master Data (Dữ liệu nền):** Khai báo Model, Mã vật tư, BOM, Khai báo Line/Route, thiết lập dải số lượng đóng gói. | `A410` (Model Basic Info), `A230` (Material Master), `A310` (BOM Info) |
| **`P`** | **30** | **HR & Attendance (Nhân sự & Chấm công):** Quản lý ca kíp, chấm công công nhân. | `P111` (Attendance Time) |
| **`K`** | **27** | **Worker Assignments (Ca kíp sản xuất):** Theo dõi lịch sử phân line, bản đồ bố trí công nhân. | `K101` (Worker Assignment) |
| **Khác** | **138** | Các phân hệ chuyên biệt (Đồng bộ Douzone ERP, powerBI bridge, test lab). | `D000` (VinaEnesol Factory Menu) |

---

## 🧱 5. Kiến Trúc Màn Hình Động (Dynamic UI Registry) của SmartFramework

Lý do hệ thống NAIS MES có thể vận hành hơn 1,400 màn hình một cách nhẹ nhàng trên một phần mềm Client duy nhất là nhờ kiến trúc **Dynamic UI Registry** nằm trong database `SmartFramework`. 

Mỗi khi một màn hình được mở:
1. **Truy vấn Đăng Ký Màn Hình (`STB_ScreenInfo`):** Client gửi `TCode` (ví dụ: `B530`) để lấy thông tin khai báo (`Name` - tên Class thực thi, `ParentName` - Thư mục menu, `Caption` - Tiêu đề đa ngôn ngữ).
2. **Tải Layout Giao Diện (`STB_ScreenLayoutInfo`):** Tải cấu trúc XML thiết kế lưới (Grid), các nút bấm (Buttons), và các ô nhập liệu (Textboxes) được cấu hình động cho màn hình đó.
3. **Binding Đối Tượng (`STB_ScreenObjects`):** Ánh xạ các trường dữ liệu trên màn hình với các cột của bảng CSDL hoặc tham số của Stored Procedure tương ứng.
4. **Hiển thị & Thực thi:** Client tự động sinh (render) giao diện người dùng dựa trên metadata tải về, giải thích lý do tại sao thay đổi cấu trúc lưới hay thêm cột kiểm tra chỉ cần cập nhật ở database (ví dụ qua bảng `STB_ScreenLayoutInfo`) mà không cần compile/redeploy lại app Client.

---
*Cập nhật: 2026-06-10 | Biên soạn dựa trên dữ liệu phân tích hệ thống thực tế từ database SmartFactoryV2 & SmartFramework*
