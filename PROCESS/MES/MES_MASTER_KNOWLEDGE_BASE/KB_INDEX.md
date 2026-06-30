# 🗂️ NAIS MES — Knowledge Base Index (Streamlined)

> **Cập nhật:** 2026-06-30 | **Tổng:** 14 files/folders (đã tối ưu hóa 65% token) | **DB:** SmartFactoryV2 + SmartFramework

---

## 🔍 Cách Tra Cứu Nhanh

| Bạn biết gì? | Tra ở đâu |
|---|---|
| **Mã màn hình** (VD: B523) | → **KI: screen_id_reference** hoặc [Bảng tra SCREEN](#-tra-cứu-theo-screen-id-tcode) |
| **Triệu chứng lỗi** | → **KB_31** (Bug Fixbook - 70+ bugs) hoặc [Bảng tra TRIỆU CHỨNG](#-tra-cứu-theo-triệu-chứng) |
| **Phân quyền / Tạo màn hình mới** | → [KB_01_UI_AND_SCREENS.md](KB_01_UI_AND_SCREENS.md) |
| **SP core chốt sản lượng / đóng gói** | → [KB_30_CORE_SP_ENGINE.md](KB_30_CORE_SP_ENGINE.md) |
| **Tìm kiếm nhanh** | `Ctrl + Shift + F` gõ keyword trực tiếp trong VS Code |

---

## 📁 Danh Sách File KB Nghiệp Vụ (Đã Tối Ưu)

### 1. Phân Hệ Vận Hành & Bugs (Core)

| File / Folder | Tên | Nội dung chính |
|--------------|-----|----------------|
| [KB_01_UI_AND_SCREENS.md](KB_01_UI_AND_SCREENS.md) | **UI & Screens** | Login, Z110/Z220/Z330 Tạo màn hình mới, Phân quyền, Error localized, B786, B934 |
| [KB_02](KB_02/INDEX.md) | **WMS / Kho** | FIFO, Hạn sử dụng, Phiếu nhập kho F330, Kho Hà Nam, Bugs F-series |
| [KB_03](KB_03/INDEX.md) | **Sản Xuất** | B530 Chốt sản lượng, B540 quét NVL, Ngày ca JobDate, Bugs B-series |
| [KB_04](KB_04/INDEX.md) | **Đóng Gói & Tem** | B523 Gộp box, C531 OQC Grade, in tem PAC/Digikey, Hủy gộp box, Bugs |
| [KB_05](KB_05/INDEX.md) | **QC & Điện Cực** | IQC/PQC/OQC, Cản OQC C512, Điện cực, Slitting, Bugs QC C-series |
| [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md) | **Master Data** | Đăng ký Model A410, NVL A230, Tiêu chuẩn đóng gói A419, Checklist thêm model mới |

### 2. Sổ Tay Tra Cứu & Trạm Đặc Thù

| File | Tên | Nội dung chính |
|------|-----|----------------|
| [KB_25](KB_25/INDEX.md) | **Hưng Yên** | Màn hình D-series của nhà máy Enesol Hưng Yên |
| [KB_30_CORE_SP_ENGINE.md](KB_30_CORE_SP_ENGINE.md) | **Core SP Engine** | Phân tích line-by-line: usp_DoProcessProdRouteHist, Backflush, ForCalc, Packing, B450 Barcode rules |
| [KB_31_SCREEN_BUG_FIXBOOK.md](KB_31_SCREEN_BUG_FIXBOOK.md) | **Sổ tay Fix Bug** | **Sổ tay cứu hộ 70+ bugs theo TCode thực tế (Đọc khi nhận bug)** |
| [KB_32_SCREEN_SP_TABLE_MAP.md](KB_32_SCREEN_SP_TABLE_MAP.md) | **Mapping Screen** | Bản đồ Screen → SP → Table của 15 màn hình cốt lõi |
| [KB_33_FACTORY_WORKCENTER_MATRIX.md](KB_33_FACTORY_WORKCENTER_MATRIX.md) | **Factory Matrix** | Các nhà máy, LineCode, WorkCenter, định dạng Barcode đầu mã |
| [KB_36_HANAM_FACTORY_SCREENS.md](KB_36_HANAM_FACTORY_SCREENS.md) | **Hà Nam Screens** | Danh sách 83 màn hình và 63 SP đặc thù của nhà máy Hà Nam |
| [MES_SCRIPT_GUIDE.md](MES_SCRIPT_GUIDE.md) | **Script Tools** | Hướng dẫn sử dụng run_query, validate_sql, deploy_tool, db_sync_tool |

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
| B530 | Chốt sản lượng | KB_03 | KB_30 |
| B540 | Quét NVL vào Line | KB_03 | KB_05 |
| B552 | Slitting | KB_05 | — |
| B597 | **Quét NVL QC** | **KB_05** | KB_03 |
| B598 | Báo phế NVL | KB_03 | — |
| B682 | Stage Prices | KB_01 | KB_06 |
| B717 | Bending/Tapping | KB_03 | — |
| B754-B758 | Tem PAC/DigiKey | KB_03 | — |
| B781 | SL đóng gói | KB_03 | KB_01 |
| B782 | Lịch sử SX | KB_03 | — |

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
*   **Hủy gộp box thành phẩm:** Trình tự xóa bản ghi kho thành phẩm, gọi `usp_DoCancelMaterialDoc` và trừ sản lượng PO → Chi tiết: **KB_04 Kịch bản C**

### 🟡 Sản Xuất (Xem KB_03)
*   **Sửa ngày JobDate B782:** Sửa ngày ghi nhận sản xuất của Lot → Chi tiết: **KB_03 §5.2**
*   **Chuyển Line sản xuất:** Chuyển Lot đang chạy sang Line khác → Chi tiết: **KB_03 §5.9**
*   **B530 báo "Routing không có trong PO":** Lỗi lệch cấu hình định tuyến → Chi tiết: **KB_03 §6.3**
*   **B442 không hiển thị Độ dày:** Model mới chưa được khai báo `MaterialThickness` trong `STB_MaterialMaster` → Chi tiết: **KB_04 §6.20**

### 🟢 Kho WMS (Xem KB_02)
*   **Kho nhập sai Warehouse (F330):** Phiếu nhập kho gán sai mã kho → Chi tiết: **KB_02 §4.3**
*   **NVL báo lỗi Hết hạn sử dụng:** Cách kiểm tra hạn dùng và ân xá Lot qua bảng `stb_vvt_OpenExpiredMaterial` → Chi tiết: **KB_02 §4.10**
*   **Chuyển Lot bị HOLD sang kho chính:** Sửa `MaterialWarehouseCode` từ `HOLDING_*` sang `ROH_*` → Chi tiết: **KB_02 §4.7**