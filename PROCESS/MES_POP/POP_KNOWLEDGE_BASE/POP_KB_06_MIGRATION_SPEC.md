<!--
AI-READY METADATA
Purpose: Đặc tả kỹ thuật & Lộ trình chuyển giao toàn diện từ MES WinForm Desktop sang POP Web 100% (Full Web Cutover)
Scope: Quy hoạch kiến trúc, ánh xạ 1:1 màn hình, giải quyết Gap Analysis, checklist cấu hình và quy trình ngắt kết nối WinForm
Single Source of Truth: POP_KNOWLEDGE_BASE/POP_KB_06_MIGRATION_SPEC.md
Target Systems: pop.vinatech.com (Web), SmartFactoryV2, VINATECH_POP, SmartFramework
Last Updated: 2026-09-21
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [POP_KB_01_ARCHITECTURE_AND_API.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md)
  - [POP_KB_02_SCREEN_OPERATIONS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md)
  - [POP_KB_03_TROUBLESHOOTING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md)
-->

# 🏛️ POP_KB_06 — ĐẶC TẢ KỸ THUẬT & LỘ TRÌNH CHUYỂN GIAO 100% POP WEB (DECOMMISSIONING MES WINFORM)

> **Mục tiêu:** Chuyển đổi toàn bộ hoạt động điều hành, sản xuất, kiểm tra chất lượng và quản trị sang giao diện Web `https://pop.vinatech.com/`, tiến tới gỡ bỏ hoàn toàn ứng dụng Desktop MES WinForm (Awoo SmartFramework) mà không gây gián đoạn sản xuất.  
> **Phiên bản:** v1.0 (2026-09-21)  
> **Trạng thái:** Kế hoạch hành động chuẩn hóa (Actionable Master Plan)

---

## 1. 🗺️ BẢNG QUY CHIẾU 1:1: MÀN HÌNH MES WINFORM ➔ ROUTE WEB POP

Toàn bộ các tác vụ trước đây phụ thuộc vào WinForm Client được quy hoạch chuyển sang các phân hệ Web POP:

| Mã WinForm | Tên màn hình WinForm | Chức năng chính | Route Web POP thay thế tương ứng | Bảng CSDL liên quan | Trạng thái sẵn sàng |
|------------|----------------------|-----------------|----------------------------------|---------------------|---------------------|
| **B530** / **HN530** | Nhập thực tích sản xuất (Line) | Chọn Plan, chốt Routing, nạp NVL | `/pop/screen` (Tab Sản xuất) | `STB_SetInfo`, `STB_ProdRouteHist`, `STB_RawMaterialInputHist` | ✅ Sẵn sàng 100% |
| **B540** | Nhập thực tích công đoạn lẻ | Chốt lẻ từng công đoạn | `/pop/screen` (Modal ghi nhận) | `STB_ProdRouteHist` | ✅ Sẵn sàng 100% |
| **B523** / **HN523** | Nhập thực tích đóng gói Box | Chia Box, gộp Box, in tem thùng | `/pop/screen` (Tab Đóng gói) | `STB_PackingInfo`, `STB_MaterialLotInfo`, `VINA_PACKING_REMAIN_QTY` | 🟡 Cần vá lỗi sinh mã PK (Gap #1) |
| **B520** | Quản lý Box & Hủy đóng gói | Tra cứu Box, hủy Box đóng gói | `/pop/screen` (Nút Lịch sử ➔ Hủy Box) | `STB_PackingInfo`, `usp_DoCancelProdPacking_LotNo` | ✅ Sẵn sàng 100% |
| **B782** | Báo cáo chi tiết công đoạn Lot | Tra cứu tiến độ routing, phế phẩm | `/dashboard/production` & `/dashboard/assemblyTrace` | `STB_ProdRouteHist`, `MongoToMesPerformance` | ✅ Sẵn sàng 100% |
| **B552** | Xử lý sự cố phế & xẻ cuộn | Xóa lượt chốt kẹt xưởng Điện cực | `/systemAdmin/popDebug/flow` & `.\mes.ps1 new-fix -Template b552` | `STB_ProdRouteHist`, `STB_DefectInfo` | ✅ Sẵn sàng 100% |
| **B310** | Quản lý Định mức vật tư (BOM) | Cấu hình NVL theo công đoạn | `/popSetting/assemblyGroupMapping` & `/popSetting/wipRouteMapping` | `VINA_GROUP_INPUT_ROUTE`, `VINA_BOM_INPUT_ROUTE` | ✅ Sẵn sàng 100% |
| **A310** | Quản lý Master Model | Khai báo mã sản phẩm mới | `/dataCollection/modelSetting` | `VINA_MODEL`, `VINA_MODEL_SETTING_DETAIL` | ✅ Sẵn sàng 100% |
| **A510** | Quản lý Routing quy trình | Cấu hình luồng công đoạn | `/popSetting/lineProdMode` | `VINA_LINE_PROD_MODE` | ✅ Sẵn sàng 100% |
| **A520** | Gán máy móc thiết bị | Gán máy cho Line/Route | `/dataCollection/equipmentSetting` | `VINA_EQUIPMENT_SETTING`, `STB_ProductMachine` | ✅ Sẵn sàng 100% |
| **QC Screens** | Màn hình đo kiểm IQC/PQC/OQC | Nhập kết quả tự kiểm tra | `/pop/quality` | `STB_QualityPQC`, `STB_CommInspDocHistory` | ✅ Sẵn sàng 100% |
| **B725** / **F742** | Mở lại Lệnh/Lot đã khóa | Can thiệp cứu hộ dữ liệu | `/systemAdmin/popDebug/dashboard` & `VINA_REOPEN_REQUEST` | `VINA_REOPEN_REQUEST`, `VINA_REOPEN_POLICY` | ✅ Sẵn sàng 100% |

---

## 2. 🔍 GAP ANALYSIS: 4 ĐIỂM NGHẼN BẮT BUỘC XỬ LÝ TRƯỚC CUTOVER

Trước khi thu hồi quyền truy cập WinForm của người dùng, bắt buộc phải hoàn thiện 4 khoảng trống kỹ thuật sau:

### Gap #1: Chuẩn hóa engine sinh mã `PackingID` 11 ký tự khi in tem từ Web Kiosk
* **Vấn đề (POP-ERR-16):** WinForm B523 chạy `usp_Vietnam_DoProcessProdPacking_VVT` sinh mã chuẩn `PKQR1900142` (11 ký tự) giúp máy quét đọc tem ăn ngay 100%. Kiosk POP hiện tại in tem thiếu mã này khiến barcode co rúm lại.
* **Giải pháp:** Cập nhật backend API `/api/pop/screen/savePacking` tự động kích hoạt thủ tục sinh mã `PK...` vào `STB_MaterialLotInfo.PackingID` trước khi đẩy mẫu tem ra máy in Zebra.

### Gap #2: Tự động kích hoạt Kế hoạch sản xuất (Auto-Release DayPlan)
* **Vấn đề (POP-ERR-02):** Khi phòng Kế hoạch phát hành PO từ ERP/Groupware, WinForm B530 yêu cầu người dùng bấm "Release" thủ công thì Kiosk mới thấy DayPlan.
* **Giải pháp:** Cấu hình Web API đón nhận trực tiếp PO từ ERP hoặc bật cờ `IsRelease = 'Y'` mặc định trong bảng `STB_DayProdPlan`. Quản lý xưởng dùng màn hình Web `/popSetting/lotPlanQty` để duyệt nhanh sản lượng.

### Gap #3: Cơ chế tự động giải phóng thiết bị kẹt (Auto-Release Orphan Machine Lock)
* **Vấn đề (POP-ERR-20):** Công nhân ca trước quên bấm "Hủy gán" khiến máy bị kẹt trạng thái `ACTIVE` trong `VINA_EQUIPMENT_MAPPING`, ca sau mở Kiosk bị ẩn máy.
* **Giải pháp:** Thiết lập Scheduled Job định kỳ 15 phút quét bảng `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING`: nếu DayPlan đã kết thúc hoặc Lot đã hoàn tất mà máy vẫn `ACTIVE` ➔ Tự động UPDATE `MAPPING_STATUS = 'RELEASED'`.

### Gap #4: Ràng buộc chuẩn hóa phế phẩm chống lỗi Three-Valued Logic
* **Vấn đề:** Lỗi phế nhập từ Kiosk bị ẩn do `IsDelete IS NULL` hoặc `RepairQty IS NULL` trong `STB_DefectRepairInfo`.
* **Giải pháp:** Áp dụng Template 11 (POP_KB_03) làm sạch dữ liệu cũ và thiết lập trigger/default value `DEFAULT '0'` cho 2 cột này trên DB.

---

## 3. 📋 CHECKLIST 8 BƯỚC CẤU HÌNH SẴN SÀNG CHO MỖI LINE (LINE READINESS)

Trước khi tuyên bố một dây chuyền hoàn toàn độc lập với WinForm, bộ phận IT/MES phải kiểm tra đủ 8 tiêu chí:

- [ ] **Bước 1 — Whitelist Kiosk Hardware:** Địa chỉ MAC của máy Kiosk tại chuyền đã được đăng ký trong `VINATECH_POP.dbo.VINA_PC_MAC` (`/dataCollection/pcMacList`).
- [ ] **Bước 2 — Cố định Factory Config:** Chuyền được gán cứng Nhà máy (Hà Nam / Hưng Yên) trong `VINA_KIOSK_FACTORY_CONFIG` để tránh chọn nhầm kho.
- [ ] **Bước 3 — Cấu hình chế độ chốt sản lượng:** `VINA_LINE_PROD_MODE` đã được đặt là `SUBTRACT` (cho Cell Line) hoặc `ADD` (cho SPT_LINE).
- [ ] **Bước 4 — Khai báo chế độ nạp nhóm:** `VINA_ASSEMBLY_GROUP_MODE` đã bật `INPUT_MODE = 'GROUP'` cho Line.
- [ ] **Bước 5 — Đầy đủ 10 Slot nạp NVL:** Bảng `VINA_GROUP_INPUT_ROUTE` đã có đủ 10 slot chuẩn (`ElectrodeP` đến `Sleeve`) theo đúng Route `V-22`, `V-24`, `V-25`.
- [ ] **Bước 6 — Master Máy móc:** `SmartFactoryV2.dbo.STB_ProductMachine` đã map đầy đủ danh mục máy của Line với Model sản xuất.
- [ ] **Bước 7 — Máy in & Tem nhãn:** Mẫu tem dán thùng đã liên kết trong `VINA_CUSTOM_LABEL_MAPPING` và máy in Zebra tại chuyền đã test lệnh in thông suốt.
- [ ] **Bước 8 — Thông suốt đường truyền Sync:** Bảng `MongoToMesPerformance` trên Line không có bản ghi nào bị kẹt `IsTransferred = 0` quá 3 phút.

*(Sử dụng lệnh tự động `.\mes.ps1 pop-readiness -Line <Mã_Line>` để kiểm tra tự động toàn bộ 8 bước trên trong 1 giây).*

---

## 4. 🏁 LỘ TRÌNH CHUYỂN ĐỔI 4 GIAI ĐOẠN (CUTOVER TIMELINE)

### Giai đoạn 1: Chuẩn Bị & Vá Điểm Nghẽn (Tuần 1 - Tuần 2)
* Hoàn thiện API in tem `PackingID` và Auto-Release máy kẹt.
* Triển khai công cụ kiểm toán tự động `.\mes.ps1 pop-readiness`.
* Khai báo hoàn chỉnh 10 Slot nạp NVL cho 100% các Line đang chạy.

### Giai đoạn 2: Bật Chế Độ Read-Only Trên WinForm (Tuần 3 - Tuần 4)
* Thu hồi quyền ghi dữ liệu (`INSERT/UPDATE/DELETE`) của các tài khoản công nhân và tổ trưởng trên phần mềm WinForm Desktop.
* Khóa chức năng chốt sản lượng tại các màn hình B530, B540, B523.
* **Kết quả đạt được:** Công nhân chỉ có thể thao tác duy nhất trên Kiosk Web POP ➔ Triệt tiêu 100% lỗi xung đột chốt chéo (Dual-entry conflict) và lỗi lệch trạm hiển thị.

### Giai đoạn 3: Di Dời Cấp Quản Lý Lên Web Dashboard (Tuần 5 - Tuần 6)
* Huấn luyện quản đốc, tổ trưởng, kỹ sư PE/QC sử dụng `/dashboard/production`, `/dashboard/report`, `/dashboard/assemblyTrace`.
* Chuyển toàn bộ quy trình duyệt mở lại lệnh sang giao diện Web `/systemAdmin/popDebug/` qua cơ chế `VINA_REOPEN_REQUEST`.

### Giai đoạn 4: Thu Hồi & Khai Tử WinForm Hoàn Toàn (Tuần 7 trở đi)
* Gỡ bỏ ứng dụng Awoo SmartFramework WinForm khỏi toàn bộ máy tính client.
* Đóng các port kết nối không cần thiết.
* Giữ nguyên CSDL `SmartFactoryV2` thuần túy làm backend cho POP RESTful API.
