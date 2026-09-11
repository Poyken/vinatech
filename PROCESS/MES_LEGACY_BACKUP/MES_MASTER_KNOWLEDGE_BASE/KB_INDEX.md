<!--
AI-READY METADATA
Purpose: Master Index & Bản đồ định tuyến tri thức (Routing Map) cho toàn bộ 12+ KB files trong MES Master Knowledge Base
Scope: Master Knowledge Directory & TCode Mapping Matrix
Single Source of Truth: KB_INDEX.md (TCode to KB Routing)
Related Files:
  - [GEMINI.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/GEMINI.md)
  - [KB_01_UI_AND_SCREENS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md)
  - [KB_02 WMS Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/INDEX.md)
  - [KB_03 Production Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/INDEX.md)
  - [KB_04 Packaging Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/INDEX.md)
  - [KB_05 QC Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/INDEX.md)
  - [KB_07 Hung Yen Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)
-->

# 🗂️ NAIS MES — Knowledge Base Index (Streamlined)

> **Cập nhật:** 2026-08-20 | **Tổng:** 12 KB items (5 folders + 6 files + 1 script guide) | **DB:** SmartFactoryV2 + SmartFramework

---

## 🔍 Cách Tra Cứu Nhanh

| Bạn biết gì? | Tra ở đâu |
|---|---|
| **Mã màn hình** (VD: B523, B763, B767) | → **KI: screen_id_reference** hoặc [Bảng tra SCREEN](#-tra-cứu-theo-screen-id-tcode) |
| **Triệu chứng lỗi** | → [KB_09](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md) (Bug Fixbook - 70+ bugs) hoặc [Bảng tra TRIỆU CHỨNG](#-tra-cứu-theo-triệu-chứng) |
| **Phân quyền / Tạo màn hình mới** | → [KB_01_UI_AND_SCREENS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md) |
| **SP core chốt sản lượng / đóng gói** | → [KB_08_CORE_SP_ENGINE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md) |
| **In tem Label & Sanmina Blueprint** | → [KB_04_03](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_03_SANMINA_LABEL_GUIDE.md) |
| **Tìm kiếm nhanh** | `Ctrl + Shift + F` gõ keyword trực tiếp trong VS Code |

---

## 📁 Danh Sách File KB Nghiệp Vụ (Đã Tối Ưu)

### 1. Phân Hệ Vận Hành & Bugs (Core)

| File / Folder | Tên | Nội dung chính | Single Source of Truth (SoT) |
|--------------|-----|----------------|------------------------------|
| [KB_01_UI_AND_SCREENS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md) | **UI & Screens** | Login, Z110/Z220/Z330 Tạo màn hình mới, Phân quyền, Error localized, B786, B934 | Menu & UI Authorization |
| [KB_02 WMS](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/INDEX.md) | **WMS / Kho** | FIFO, Hạn dùng, Nhập kho F330, Xuất kho F430, HN551, HN866, FG00, Bugs | Material Warehouse & Stock |
| [KB_03 Production](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/INDEX.md) | **Sản Xuất** | B530 Chốt sản lượng, B540 quét NVL, Ngày ca JobDate, Bugs B-series | Production Execution & Routing |
| [KB_04 Packaging](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/INDEX.md) | **Đóng Gói & Tem** | B523 Gộp box, C531 OQC Grade, in tem PAC/Digikey, Sanmina B763/B767, Bugs | Box Packaging & Label Printing |
| [KB_05 QC](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/INDEX.md) | **QC & Điện Cực** | IQC/PQC/OQC, Cản OQC C512, Điện cực, Slitting, Xả cuộn, Bugs | Quality Inspection & Electrode |
| [KB_06_MASTER_DATA_TOOLS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md) | **Master Data** | Đăng ký Model A410, NVL A230, Tiêu chuẩn đóng gói A419, Checklist thêm model mới | Master Data Configuration |

### 2. Sổ Tay Tra Cứu & Trạm Đặc Thù

| File | Tên | Nội dung chính |
|------|-----|----------------|
| [KB_07](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md) | **Hưng Yên** | Màn hình D-series của nhà máy Enesol Hưng Yên |
| [KB_08_CORE_SP_ENGINE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md) | **Core SP Engine** | Phân tích line-by-line: usp_DoProcessProdRouteHist, Backflush, ForCalc, Packing, B450 Barcode rules |
| [KB_09_SCREEN_BUG_FIXBOOK.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md) | **Sổ tay Fix Bug** | **Sổ tay cứu hộ 70+ bugs theo TCode thực tế (Đọc khi nhận bug)** |
| [KB_10_FACTORY_WORKCENTER_MATRIX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_10_FACTORY_WORKCENTER_MATRIX.md) | **Factory Matrix** | Các nhà máy, LineCode, WorkCenter, định dạng Barcode đầu mã |
| [KB_11_HANAM_FACTORY_SCREENS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_11_HANAM_FACTORY_SCREENS.md) | **Hà Nam Screens** | Danh sách 83 màn hình và 63 SP đặc thù của nhà máy Hà Nam |
| [BAN_DO_CHI_TIET_CONG_DOAN_SAN_XUAT_MES_VINATECH.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/DATABASE_KNOWLEDGE_BASE/BAN_DO_CHI_TIET_CONG_DOAN_SAN_XUAT_MES_VINATECH.md) | **Bản Đồ 16 Công Đoạn** | Bản đồ 16 công đoạn khép kín từ NVL đến đóng gói, SP, Bảng CSDL, Cổng chặn Gates |
| [DB_02_MES_MANUFACTURING_PROCESS_PIPELINE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/DATABASE_KNOWLEDGE_BASE/DB_02_MES_MANUFACTURING_PROCESS_PIPELINE.md) | **Manufacturing Pipeline** | Dòng chảy dữ liệu End-to-End quy trình sản xuất & cấu trúc bảng |
| [MES_SCRIPT_GUIDE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/MES_SCRIPT_GUIDE.md) | **Script Tools** | Hướng dẫn sử dụng run_query, validate_sql, deploy_tool, db_sync_tool |

---

## 📺 Tra Cứu Theo Screen ID (TCode)

### Sản xuất (B-series)

| TCode | Tên | KB chính | KB phụ |
|---|---|---|---|
| B310 | PO tháng | KB_03 | — |
| B351 | Chuyển đổi Lot | KB_04 | — |
| B442 | Kế hoạch Electrode | KB_04 | KB_05 |
| B450 | Kế hoạch ngày | KB_03 | — |
| B452 | Đổi Line | KB_03 | — |
| B523 | **Đóng gói** | **KB_04** | KB_03 |
| B525 | Đóng gói kho | KB_04 | KB_02 |
| B530 | Chốt sản lượng | KB_03 | KB_08 |
| B540 | Quét NVL vào Line | KB_03 | KB_05 |
| B552 | Slitting | KB_05 | — |
| B597 | Quét NVL B597 | KB_03 | KB_05 |
| B598 | Quét NVL B598 | KB_03 | KB_05 |
| B682 | Nhập công đoạn | KB_03 | — |
| B717 | Bending/Tapping | KB_03 | — |
| B754-B758 | Tem PAC/DigiKey | KB_04 | — |
| B763 | **Thiết lập KH xuất Sanmina** | **KB_04 (03)** | KB_01 |
| B767 | **In tem KH Sanmina India** | **KB_04 (03)** | — |
| B781 | SL đóng gói | KB_03 | KB_01 |
| B782 | **Lịch sử Routing (Lot Tracking)** | **KB_03, KB_09** | **HOTFIX_LOG ID_44** |

### QC (C-series)

| TCode | Tên | KB chính |
|---|---|---|
| C220 | IQC | KB_05 |
| C321 | Sửa lỗi Cell | KB_05 |
| C443 | PQC Inline | KB_05 |
| C486 | QC Grid | KB_05 |
| C512 | QC Report | KB_05 |
| C530 | **OQC Sample** | KB_05 |
| C531 | OQC Packing | KB_04 |
| C546 | FOQC | KB_05 |
| C560 | FG Receipt | KB_05 |

### Kho WMS (F-series)

| TCode | Tên | KB chính |
|---|---|---|
| F110 | Thuộc tính vật tư | KB_06 |
| F312 | Sửa SL kho | KB_02 |
| F330 | **Nhập kho NVL** | **KB_02** |
| F430 | Chuyển kho | KB_02 |
| F710 | Tồn kho NVL | KB_02 |
| F721 | Tồn kho thực | KB_02 |
| F750 | Kiểm kê kho | KB_02 |

---

## ⚡ Tra Cứu Theo Triệu Chứng Lỗi Thường Gặp

### 🔴 Đóng Gói & In Tem (Xem KB_04)
*   **B523 không gộp được Box:** Check cờ F110 (`IsLotUse`, `IsUseBarcode`), check QC Pass (`LotDecisionResult = 'PASS'`), check PO `IsOutputRoute = 1` → Chi tiết: **KB_04 §4.1**
*   **"Chưa có tiêu chuẩn đóng gói":** Model/Size chưa được khai báo số lượng đóng gói tại `STB_PackingStandard` → Chi tiết: **KB_04 §6.1**
*   **Không in được tem (Not found label type):** Chưa map mẫu tem với Model trong `STB_ModelLabelInfo` tại A460 → Chi tiết: **KB_01 §1.2**
*   **B353 đổi lot nhưng B523 in lot cũ:** Lỗi prefix VJ/VV trong SP `usp_Vietnam_GetBoxIDForLotNo_VVT` → Chi tiết: **KB_04 §6.18**
*   **In tem Sanmina theo Plan (B763 & B767):** Tự động sinh CartonBoxNo, Serial tịnh tiến liên tục qua nhiều Lot, sửa tiến độ thùng → Chi tiết: **KB_04_03**
*   **Hủy gộp box thành phẩm (B523):** Trình tự xóa bản ghi kho thành phẩm, gọi `usp_DoCancelMaterialDoc` và trừ sản lượng PO → Chi tiết: **KB_04 Kịch bản C**
*   **Hủy tem đóng gói HN523 (Hà Nam):** Xóa sub-lot `STB_MaterialLotInfo`, hủy chứng từ `MaterialDoc` (bypass trigger `0x999997`), giảm trừ sản lượng công đoạn cuối `VE10` và PO → Chi tiết: **[KB_04_02 § [HN523]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md#hn523--kịch-bản-sự-cố-khẩn-cấp-hủy-tem-đóng-gói--rã-box-tại-hà-nam-đồng-bộ-giảm-sản-lượng-ve10--po)**

### 🟡 Sản Xuất (Xem KB_03)
*   **Hủy chốt nhầm Winding B782 / B530:** Xóa phế `STB_DefectRepairInfo`, xóa công đoạn downstream `V-23_HY` trong `STB_ProdRouteHist`, update `CompleteRoute = NULL` trên `V-22_HY` để OP chốt lại → Chi tiết: **KB_09 §B782**, **KB_03 §5.16**, **HOTFIX_LOG ID_44**
*   **Hủy mẻ trộn điện cực thừa B470/B552:** Xóa sạch `STB_ElectrodeMixStepInfo`, `STB_ElectrodeMixInfo`, `STB_SetInfo` khi chưa tráng Coating → Chi tiết: **KB_09 §B552 #3**, **KB_05_01 §8.10**, **HOTFIX_LOG ID_42 & ID_43**
*   **Sửa ngày JobDate B782:** Sửa ngày ghi nhận sản xuất của Lot → Chi tiết: **KB_03 §5.2**
*   **Chuyển Line sản xuất:** Chuyển Lot đang chạy sang Line khác → Chi tiết: **KB_03 §5.9**
*   **B530 báo "Routing không có trong PO":** Lỗi lệch cấu hình định tuyến → Chi tiết: **KB_03 §6.3**
*   **B442 không hiển thị Độ dày:** Model mới chưa được khai báo `MaterialThickness` trong `STB_MaterialMaster` → Chi tiết: **KB_04 §6.20**

### 🟢 Kho WMS (Xem KB_02)
*   **Kho nhập sai Warehouse (F330):** Phiếu nhập kho gán sai mã kho → Chi tiết: **KB_02 §4.3**
*   **NVL báo lỗi Hết hạn sử dụng:** Cách kiểm tra hạn dùng và ân xá Lot qua bảng `stb_vvt_OpenExpiredMaterial` → Chi tiết: **KB_02 §4.10**
*   **Chuyển Lot bị HOLD sang kho chính:** Sửa `MaterialWarehouseCode` từ `HOLDING_*` sang `ROH_*` → Chi tiết: **KB_02 §4.7**
