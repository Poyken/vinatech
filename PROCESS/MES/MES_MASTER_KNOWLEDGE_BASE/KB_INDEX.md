# 🗂️ NAIS MES — Knowledge Base Index

> **Cập nhật:** 2026-06-27 | **Tổng:** 24 files, 1,085+ KB | **DB Verified:** 19 DBs, 6,648 tables, 3,416 SPs (SmartFactoryV2)
> **Groupware KB:** → [GW_INDEX.md](../../GROUPWARE/GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md)
> **Luồng đi màn hình:** → [PROCESS_FLOW_MAP.md](PROCESS_FLOW_MAP.md) (bản đồ điều hướng process)

---

## 🔍 Cách tra cứu

| Bạn biết gì? | Tra ở đâu |
|---|---|
| **Tên bảng** (VD: STB_SetInfo) | → [Bảng tra TABLE](#-tra-cứu-theo-table-name) |
| **Mã màn hình** (VD: B523) | → **KI: screen_id_reference** (106 screens) hoặc [Bảng tra SCREEN](#-tra-cứu-theo-screen-id-tcode) |
| **Triệu chứng lỗi** | → **KB_31** (70+ bugs) hoặc [Bảng tra TRIỆU CHỨNG](#-tra-cứu-theo-triệu-chứng) |
| **Phân hệ** (Kho/QC/SX) | → [Danh sách file KB](#-danh-sách-file-kb) |
| **SP dependency/impact** | → **KI: deep_system_map** (SP callers, table sizes) |
| **Tìm kiếm nhanh** | `Ctrl + Shift + F` gõ keyword trong VS Code |

---

## 📁 Danh sách file KB

### Core — Phân hệ chính

| File | Size | Nội dung chính |
|------|------|---------------|
| [KB_01](KB_01_UI_PHAN_QUYEN.md) | 14 KB | Login, phân quyền User, Stage Prices |
| [KB_02](KB_02/INDEX.md) | 79 KB | **Kho WMS** — ⚡ **CHUNKED** |
| → [01_NVL_WMS](KB_02/KB_02_01_NVL_WMS.md) | 40 KB | §4 NVL: FIFO, hạn dùng, MaterialDocInfo |
| → [02_FG_WMS](KB_02/KB_02_02_FG_WMS.md) | 12 KB | §5 Kho TP, Hà Nam (gộp KB_08) |
| → [03_SCREEN_BUGS](KB_02/KB_02_03_SCREEN_BUGS.md) | 24 KB | Bugs F110-F750, HN, A130 |
| → [04_APPENDIX](KB_02/KB_02_04_APPENDIX.md) | 4 KB | Warehouse infrastructure |
| [KB_03](KB_03/INDEX.md) | 150 KB | **Sản xuất** — ⚡ **CHUNKED** |
| → [01_OVERVIEW](KB_03/KB_03_01_OVERVIEW.md) | 16 KB | §5 Tổng quan, SetInfo/ProdRouteHist schema |
| → [02_CELL_LINE](KB_03/KB_03_02_CELL_LINE.md) | 64 KB | §6 B530/B523/B597/Rework vận hành |
| → [03_SCREEN_BUGS_B](KB_03/KB_03_03_SCREEN_BUGS_B.md) | 38 KB | Bugs B210-B802, HN, K screens |
| → [04_SCREEN_BUGS_BK](KB_03/KB_03_04_SCREEN_BUGS_BK.md) | 28 KB | Bugs B220-B935 chi tiết |
| → [05_APPENDIX](KB_03/KB_03_05_APPENDIX.md) | 4 KB | Table schemas |
| [KB_04](KB_04/INDEX.md) | 76 KB | **Đóng gói & In tem** — ⚡ **CHUNKED** |
| → [01_CORE_PACKAGING](KB_04/KB_04_01_CORE_PACKAGING.md) | 35 KB | §6 B523/B525 flow, PackingStandard, in tem |
| → [02_SCREEN_BUGS](KB_04/KB_04_02_SCREEN_BUGS.md) | 39 KB | Bugs B351, B523, B717, A418, HN523 |
| → [03_APPENDIX](KB_04/KB_04_03_APPENDIX.md) | 3 KB | Packing table schemas |
| [KB_05](KB_05/INDEX.md) | 105 KB | **QC & Electrode** — ⚡ **CHUNKED** |
| → [01_QC_OVERVIEW](KB_05/KB_05_01_QC_OVERVIEW.md) | 13 KB | §7 QC gates, validation flow |
| → [02_ELECTRODE](KB_05/KB_05_02_ELECTRODE.md) | 15 KB | §8 Coating, Slitting, Pressing |
| → [03_QC_FLOW](KB_05/KB_05_03_QC_FLOW.md) | 16 KB | §9 IQC→PQC→OQC, ESR/Aging |
| → [04_SLITTING_4M](KB_05/KB_05_04_SLITTING_4M_RELIABILITY.md) | 7 KB | §10-12 Slitting HN, 4M, Reliability |
| → [05_SCREEN_BUGS](KB_05/KB_05_05_SCREEN_BUGS_QC.md) | 52 KB | Bugs C-series, B597/B598, HY |
| → [06_APPENDIX](KB_05/KB_05_06_APPENDIX.md) | 4 KB | QC table schemas |
| [KB_06](KB_06_MASTER_DATA_TOOLS.md) | 38 KB | **Master Data** — Model, Material, Checklist thêm mới |
| [KB_07](KB_07/INDEX.md) | 77 KB | **Groupware** — ⚡ **CHUNKED** |
| → [01_OVERVIEW](KB_07/KB_07_01_OVERVIEW_FLOWS.md) | 14 KB | §1-8 Auth, Mua hàng, Bán hàng, PO, HR |
| → [02_ESM_FORMS](KB_07/KB_07_02_ESM_FORMS.md) | 56 KB | §9-11 ESM engine, 25+ forms, step-by-step |
| → [03_BOM_TROUBLESHOOT](KB_07/KB_07_03_BOM_TROUBLESHOOT.md) | 8 KB | §12-14 BOM, Kho, Troubleshoot + Appendix |

### Architecture & Analysis

| File | Size | Nội dung chính |
|------|------|---------------|
| [KB_10](KB_10/INDEX.md) | 92 KB | **Kiến trúc** — ⚡ **CHUNKED** |
| → [01_ARCHITECTURE](KB_10/KB_10_01_ARCHITECTURE.md) | 49 KB | §0-1 Architecture, SmartFramework, Triggers |
| → [02_DATAFLOW_SP](KB_10/KB_10_02_DATAFLOW_SP.md) | 16 KB | §2-6 E2E flow, SP analysis, Debug |
| → [03_LIEN_THONG](KB_10/KB_10_03_LIEN_THONG.md) | 24 KB | §7 Máy móc, phụ tùng, ANDON |
| → [04_APPENDIX](KB_10/KB_10_04_APPENDIX.md) | 3 KB | Table volumes |
| [KB_12](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md) | 23 KB | Deep Core — 5 DNA, SP patterns, DB Audit |
| [KB_14](KB_14/INDEX.md) | 40 KB | **Methodology** — ⚡ **CHUNKED** |
| → [01_METHODOLOGY](KB_14/KB_14_01_METHODOLOGY.md) | 11 KB | §1-3 Triết lý, 6 bước trace, Data Log |
| → [02_SQL_VALIDATION](KB_14/KB_14_02_SQL_VALIDATION.md) | 20 KB | §4-6 SQL utilities, 12 Validation Gates |
| → [03_CASE_STUDY](KB_14/KB_14_03_CASE_STUDY.md) | 9 KB | §7 Case Study end-to-end |

### Infrastructure & Mapping

| File | Size | Nội dung chính |
|------|------|---------------|
| [KB_19](KB_19/INDEX.md) | 86 KB | **19 DBs Map** — ⚡ **CHUNKED** |
| → [01_ARCHITECTURE](KB_19/KB_19_01_ARCHITECTURE.md) | 23 KB | §1-2 Kiến trúc DB, 13 DB Details |
| → [02_WORKFLOWS](KB_19/KB_19_02_WORKFLOWS_QUERIES.md) | 25 KB | §3-8 Workflows, Audit, Troubleshoot |
| → [03_GROUPWARE](KB_19/KB_19_03_GROUPWARE_MAPPING.md) | 21 KB | §9 Form→DB→MES Mapping |
| → [04_ERD](KB_19/KB_19_04_ERD_APPENDIX.md) | 17 KB | §11 ERD + Appendix |
| [KB_26](KB_26/INDEX.md) | 42 KB | **Liên kết** — ⚡ **CHUNKED** |
| → [01_LINKS_BUGS](KB_26/KB_26_01_LINKS_BUGS.md) | 23 KB | §1-4 WMS↔SX↔QC, 4 Bugs, HY routes |
| → [02_TRIGGERS_SCM](KB_26/KB_26_02_TRIGGERS_SCM.md) | 17 KB | §5-6 Triggers, SCM/Rework |
| → [03_APPENDIX](KB_26/KB_26_03_APPENDIX.md) | 2 KB | ESM tables |
| [KB_30](KB_30_CORE_SP_ENGINE.md) | 24 KB | **4 SP cốt lõi** line-by-line: DoProcess, Backflush, ForCalc, Packing |
| [KB_31](KB_31_SCREEN_BUG_FIXBOOK.md) | 27 KB | **Sổ tay Bug** — 60+ bug × 30+ màn hình |
| [KB_32](KB_32_SCREEN_SP_TABLE_MAP.md) | 20 KB | Screen→SP→Table map cho 15 màn hình |

### Factory-specific & Subsystems

| File | Size | Nội dung chính |
|------|------|---------------|
| [KB_25](KB_25/INDEX.md) | 42 KB | **VinaEnesol HY** — ⚡ **CHUNKED** |
| → [01_OVERVIEW](KB_25/KB_25_01_OVERVIEW.md) | 24 KB | §1-5 Tổng quan, DB, SP, SQL |
| → [02_DEPLOY_HY](KB_25/KB_25_02_DEPLOY_HY.md) | 12 KB | §6-7 Cấu hình điểm HY |
| → [03_SCREEN_BUGS](KB_25/KB_25_03_SCREEN_BUGS.md) | 5 KB | Bugs Enesol/HY screens |
| [KB_33](KB_33_FACTORY_WORKCENTER_MATRIX.md) | 9 KB | 9 WorkCenters, 295 Lines, Barcode format |
| [KB_34](KB_34_UNDOCUMENTED_SUBSYSTEMS.md) | 38 KB | 20 subsystems: Spare Parts, Machine, Mold, Scrap, ANDON, 119 VN tables |
| [KB_35](KB_35_TRIGGERS_JOBS_LABELS.md) | 19 KB | 33 Triggers, 36 Agent Jobs, 32 Customer Labels |
| [KB_36](KB_36_HANAM_FACTORY_SCREENS.md) | 20 KB | Hà Nam 83 screens, 63 HN SPs, QC subsystems |
| [KB_37](KB_37_SP_ARCHAEOLOGY_BUGS_AND_PATTERNS.md) | 25 KB | **SP Archaeology** — 12 bugs, 6 patterns, TOP 20 SPs, comment dictionary |

### Meta & Tools

| File | Size | Nội dung |
|------|------|---------|
| [MES_DAILY_PLAYBOOK](MES_DAILY_PLAYBOOK.md) | — | Giám sát hệ thống hằng ngày |
| [MES_OPERATIONAL_LOG](MES_OPERATIONAL_LOG.md) | — | Nhật ký sự cố |
| [MES_SCRIPT_GUIDE](MES_SCRIPT_GUIDE.md) | — | Hướng dẫn 4 PowerShell scripts |

---

## 🗄️ Tra cứu theo TABLE NAME

> **Cách dùng:** Biết tên bảng → tìm dòng → biết đọc KB nào, mục nào.

| Table | KB File | Schema? | Ghi chú |
|---|---|---|---|
| `STB_SetInfo` | **KB_03** Appendix A.1 | ✅ 76 cols | ★★★ Product Passport |
| `STB_ProdRouteHist` | **KB_03** Appendix A.2 | ✅ 23 cols | ★★★ Routing Visa Stamp |
| `STB_MaterialLotInfo` | **KB_02** Appendix | ✅ | ★★ NVL Lot tồn kho |
| `STB_MaterialDocInfo` | **KB_02** Appendix | ✅ 82 cols | Phiếu nhập/xuất kho |
| `STB_MaterialDocLotInfo` | **KB_02**, KB_26 §2 | — | Chi tiết Lot per phiếu |
| `STB_MaterialStock` | **KB_02** Appendix | — | Tồn kho tổng (trigger sync) |
| `STB_MaterialWarehouse` | **KB_02** Appendix | ✅ 20 cols | Config kho |
| `STB_MaterialMaster` | **KB_06** Appendix | ✅ 82 cols | Master vật tư |
| `STB_MaterialStockAttributeInfo` | **KB_06** | — | Thuộc tính F110 (IsLotUse) |
| `STB_MaterialQcInfo` | **KB_05** Appendix A.2 | ✅ 35 cols | QC Lot Header |
| `STB_MaterialQcInspectionItem` | **KB_05** Appendix A.3 | ✅ 20 cols | QC Spec (USL/LSL) |
| `STB_MaterialQcDetail` | **KB_05** Appendix | — | QC Detail per Lot |
| `STB_ModelBasicInfo` | **KB_06** Appendix | ✅ 61 cols | Master Model |
| `STB_PackingStandard` | **KB_04** §6.1, KB_06 | ✅ 11 cols | Tiêu chuẩn đóng gói |
| `STB_DividePackaging` | **KB_04** Appendix | — | Core packing logic |
| `STB_SavePackingTime_VVT` | **KB_04** | — | Takt time đóng gói |
| `STB_ModelLabelInfo` | **KB_04** §6.16 | — | Mapping Model→Label |
| `STB_DayProdPlan` | **KB_03** §5.7 | — | Kế hoạch SX ngày |
| `STB_ProductionOrderInfo` | **KB_03** §5.7, KB_10 | — | PO Header |
| `STB_ProdRouteSummary` | **KB_03** §5.3 | — | Tổng hợp sản lượng |
| `STB_CommInspDocHistory` | **KB_05** §7.1 | — | Lịch sử QC per Barcode |
| `STB_DefectRepairInfo` | **KB_03** §5.8, KB_26 | — | Phế/lỗi sản xuất |
| `STB_RawMaterialInputHist` | **KB_03** §6.1 | — | Lịch sử nhập NVL vào Line |
| `STB_ProcedureLog` | **KB_10** Appendix | — | ★ Audit log (19.3M rows) |
| `STB_LabelInfo` | **KB_04** §6.16 | — | Template tem (SmartFramework) |
| `STB_ScreenObjects` | **KB_10** §1.2 | — | Screen→SP mapping (SmartFramework) |
| `STB_StringResources` | **KB_10** §1.4 | — | Error messages (17,751 records) |
| `STB_VVT_StagePrices` | **KB_10** §1.16 | — | Giá công đoạn (83 cols) |
| `VVT_OQC_REFER` | **KB_04** §6.19 | — | Phân cấp OQC |
| `ESM_*` (19 tables) | **KB_26** Appendix | — | ERP↔MES bridge |

---

## 📺 Tra cứu theo Screen ID (TCode)

> **Cách dùng:** Nhận lỗi từ màn hình → tìm TCode → biết đọc KB nào.

### Sản xuất (B-series)

| TCode | Tên | KB chính | KB phụ |
|---|---|---|---|
| B310 | PO tháng | KB_03 §5.7 | KB_07 |
| B351 | Chuyển đổi Lot | KB_03 §6.9 | KB_04 §6.2 |
| B442 | Kế hoạch Electrode | KB_04 §6.20 | KB_05 |
| B450 | Kế hoạch ngày | KB_03 §5.7 | KB_07 |
| B452 | Đổi Line | KB_03 §6.7 | — |
| B523 | **Đóng gói** | **KB_04** §4.1-6 | KB_03, KB_14 |
| B525 | Đóng gói kho | KB_04 | KB_02 |
| B528 | Barrel Barcode | KB_03 §6.10 | — |
| B530 | Chốt sản lượng | KB_03 §6.3 | KB_14 §4.4, KB_30 |
| B540 | Quét NVL vào Line | KB_03 §6.1 | KB_05 |
| B552 | Slitting | KB_05 §8.1 | — |
| B597 | **Quét NVL QC** | **KB_05** §7 | KB_03, KB_02 |
| B598 | Báo phế NVL | KB_03 §6.12 | — |
| B618 | Rework | KB_26 §2 | KB_14 |
| B682 | Stage Prices | KB_01 §3.1 | KB_06 |
| B717 | Bending/Tapping | KB_03 §6.6 | — |
| B754-B758 | Tem PAC/DigiKey | KB_03 §6.16 | KB_10 §1.12 |
| B781 | SL đóng gói | KB_03 §5.3 | KB_01 |
| B782 | Lịch sử SX | KB_03 §5.2 | — |
| B790 | Tem Phoenix | KB_10 §1.12 | — |
| B802 | SX Electrode | KB_03 §6.11 | KB_10 §1.11 |
| B882 | ANDON | KB_03 §6.20 | KB_34 |

### QC (C-series)

| TCode | Tên | KB chính |
|---|---|---|
| C220 | IQC | KB_05 §9.1, KB_02 |
| C321 | Sửa lỗi Cell | KB_05 §9.5 |
| C443 | PQC Inline | KB_05 §7 |
| C486 | QC Grid | KB_05 §7.8 |
| C512 | QC Report | KB_05 §7.2 |
| C530 | **OQC Sample** | KB_10 §1.10, KB_05 |
| C531 | OQC Packing | KB_04 §6.19 |
| C546 | FOQC | KB_05 §9.6 |
| C560 | FG Receipt | KB_10 §1.10 |

### Kho WMS (F-series)

| TCode | Tên | KB chính |
|---|---|---|
| F110 | Thuộc tính vật tư | KB_06 §1, KB_04 §4.1 |
| F312 | Sửa SL kho | KB_02 §4.5 |
| F330 | **Nhập kho NVL** | **KB_02** §4, KB_07 |
| F430 | Chuyển kho | KB_02, KB_10 §0 |
| F710 | Tồn kho NVL | KB_02 |
| F743-F748 | Slitting HN | KB_05 §10 |
| F750 | Kiểm kê kho | KB_26 §4 |

### Hà Nam / Hưng Yên / Module

| TCode | Tên | KB chính |
|---|---|---|
| HN523 | Đóng gói HN | KB_04, KB_36 |
| HN544 | Gộp túi bóng | KB_04 §6.5, KB_02 |
| HN551 | Xuất kho TP HN | KB_02, KB_36 |
| HN866 | Tồn kho TP HN | KB_02, KB_36 |
| HNC321 | Nhập phế HN | KB_14 §4.6, KB_36 |
| K101 | KH SX BG2 | KB_03 §6.14 |
| K109 | Quét NVL BG2 | KB_03 §6.14 |
| D000-D110 | Enesol HY | KB_25 |

### Master & System

| TCode | Tên | KB chính |
|---|---|---|
| A410 | Model Master | KB_06 §1.2 |
| A419 | Packing Standard | KB_06 §11, KB_04 |
| A460 | Label Config | KB_04 §6.16 |
| Z530 | Label Design | KB_04 §6.16 |

---

## ⚡ Tra cứu theo triệu chứng

### 🔴 Đóng gói & In tem

| Triệu chứng | File & Mục |
|---|---|
| B523 không gộp được Box | KB_04 §4.1 (4 bước debug) |
| "Chưa có tiêu chuẩn đóng gói" | KB_04 §6.1 (STB_PackingStandard) |
| Packing Qty âm hoặc sai | KB_04 §6.6 |
| Không in được tem (nhiều mã) | KB_04 §4.5 (5 bước kiểm tra) |
| Tem in sai mẫu (5H1→6D1) | KB_04 §6.3 |
| Lot không có, cần in tem khẩn | KB_04 §6.15 |
| B353 đổi lot nhưng B523 in lot cũ | KB_04 §6.18 (VJ/VV bug) |
| B560 cắt chuỗi tem (73/80) | KB_04 §6.14 |
| C531 chọn nhầm cấp OQC | KB_04 §6.19 |

### 🟡 Sản xuất

| Triệu chứng | File & Mục |
|---|---|
| Sửa ngày JobDate B782 | KB_03 §5.2 |
| Chuyển Line sản xuất | KB_03 §5.9 |
| Xóa PO (B310/B450) | KB_03 §5.7 |
| Sửa số lượng NG | KB_03 §5.8 |
| Đổi Barcode VV→VJ | KB_03 §5.10 |
| B530 báo "Routing không có trong PO" | KB_03 §6.3 |
| B717 nhập sai thông số | KB_03 §6.6 |
| B442 không hiển thị Độ dày | KB_04 §6.20 |

### 🟢 Kho WMS

| Triệu chứng | File & Mục |
|---|---|
| Kho nhập sai Warehouse (F330) | KB_02 §4.3 |
| Sửa số lượng F312 | KB_02 §4.5 |
| Hàng hết hạn sử dụng | KB_02 §4.10 |
| Chuyển từ Holding sang kho chính | KB_02 §4.7 |
| Xóa phiếu nhập kho F330 đã Confirm | KB_02 §5 |
| Kho lệch số (trigger fail) | KB_26 §2 |
| HN551 xuất nhưng HN866 vẫn còn | KB_02 §1 |

### 🔵 QC

| Triệu chứng | File & Mục |
|---|---|
| B597 lỗi hạng mục kiểm tra cũ | KB_05 §7.1 |
| B597 lỗi hết hạn sử dụng | KB_02 §4.10 |
| B597 lỗi Vỏ Nhôm / Electrolyte | KB_05 §7.4-7.5 |
| Lỗi HOLDING | KB_05 §7.7 |
| "Chưa CONFIG Slitting" | KB_05 §8.2 |
| C546 FOQC chỉ hiện 20ea thay vì 50ea | KB_05 §9.6 |
| QC Audit: không đổi Reject→Pass | KB_26 §3.2 |

### ⚪ Hệ thống & Master Data

| Triệu chứng | File & Mục |
|---|---|
| Không đăng nhập được | KB_01 §1.1 |
| Model mới không hiện Vol/Farad | KB_06 §1.2 |
| Thêm Cell/Line mới | KB_06 §7 |
| Giá B682/B781 trống | KB_01 §3.1 |
| PO không từ Groupware | KB_07 §6 |
| Hệ thống chậm/treo (block session) | KB_14 §5.D |
| Trace lỗi không biết bắt đầu | KB_14 (toàn bộ) |

---

## 🏭 Bản đồ nhà máy → Màn hình

> **Nguyên tắc:** VVT_F1 (Bắc Ninh) = **Chuẩn gốc**. Các cơ sở khác clone/fork từ đây.

### Tổng quan

| Prefix | Số lượng | Cơ sở | Vai trò |
|---|---|---|---|
| **B** | 373 | VVT_F1 (BN) | 🟢 Chuẩn gốc — tất cả chức năng |
| **A** | 33 | Chung | Master config (Model, Label, Packing) |
| **C** | 155 | Chung | QC: IQC, PQC, OQC, Reliability |
| **F** | 124 | Chung | WMS: Kho NVL, Kho TP |
| **Z** | 52 | Chung | System, Label template |
| **H** | 88 | Chung | Spare Part bảo trì |
| **HN** | 92 | VVT_F3 (Hà Nam) | 🔴 Fork riêng, nhiều tùy chỉnh |
| **K** | 28 | VVT_F4 (BG2) | 🔵 Module production (Bloom, Nordex) |
| **D** | 17 | VVT_F4 (HY) | Enesol battery |
| **V** | 26 | Chung | Menu tiếng Việt |

### Mapping Gốc (B) → Biến thể (HN/K)

| Chức năng | B-Gốc | HN (Hà Nam) | K (BG2) | KB |
|---|---|---|---|---|
| Kế hoạch SX ngày | **B450** | — | **K101** | KB_03 |
| Quét NVL | **B597** | — | **K109** | KB_05 |
| Chốt sản lượng | **B530** | — | (dùng chung) | KB_03 |
| Đóng gói box | **B523** | **HN523** | — | KB_04 |
| Gộp box túi bóng | **B523** | **HN544** | — | KB_04 |
| In tem Module | — | — | **K130** | KB_03 §6.14 |
| Báo phế NVL | **B598** | **HN598** | — | KB_03 |
| Tồn kho TP | — | **HN866** | — | KB_02 |
| Xuất kho TP | — | **HN551** | — | KB_02 |
| Lịch sử SX | **B782** | **HN782** | **K107** | KB_03 |
| ANDON | **B882** | **HN561** | — | KB_03 |
| QC nhập phế | **B598** | **HNC321** | — | KB_05 |

> 💡 **Cách đọc:** Nếu cần hiểu **HN523** → đọc **B523** (gốc) trước, rồi đọc HN523 để hiểu khác biệt.

---

## 📊 Thống kê hệ thống (DB Verified 2026-06-18)

| Metric | Value | KB |
|---|---|---|
| Databases | **19** | KB_19 |
| Tables (total) | **6,648** | KB_19 |
| Stored Procedures | **3,639** | KB_12 |
| Functions | **106** | KB_10 |
| Triggers | **33** | KB_10, KB_35 |
| Screens | **1,231** (1,026 unique) | KB_32 |
| Screen Objects | **7,604** | KB_10 |
| Warehouses (active) | **118** | KB_02 |
| Lines (active) | **295** | KB_33 |
| Top table: STB_VVT_ESRDATA | **398M rows / 61 GB** | KI:deep_system_map |
| Top table: STB_ProductStockInfo | **64.5M rows / 12 GB** | KI:deep_system_map |
| Top table: ProdRouteHist | **3.3M rows / 805 MB** | KB_10, KI:deep_system_map |
| Hub table: STB_MaterialMaster | **874 SPs đọc** | KI:deep_system_map |
| Hub table: STB_SetInfo | **711 SPs đọc** | KI:deep_system_map |
| Core SP: usp_DoCreateSerial | **470 callers** | KI:deep_system_map |

---

> 📌 **DB & SP reference:** [KB_19](KB_19/KB_19_01_ARCHITECTURE.md) | **Rules:** [RULES.md](../AI_AGENT_CONFIG/RULES.md)

*Cập nhật: 2026-06-19 | Optimized for lookup: TABLE→KB, SCREEN→KB, Symptom→KB. Added KI references + DB-verified stats. 24 files, 1,085+ KB.*