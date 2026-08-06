<!--
AI-READY METADATA
Purpose: Master Index & Định tuyến phân hệ Hưng Yên Factory (VVT_F5) & VinaEnesol
Scope: Hung Yen Factory Master Directory & Screen Routing Matrix
Single Source of Truth: KB_07/INDEX.md (Hung Yen Module Index) & KB_07_01_OVERVIEW.md
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_07_01_OVERVIEW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md)
  - [KB_07_02_DEPLOY_HY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md)
  - [KB_07_03_SCREEN_BUGS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md)
-->

# KB_07 — VinaEnesol & Hưng Yên Factory Master Index

> **WorkCenterCode:** `VVT_F5` (Nhà máy Hưng Yên)  
> ← [Về Master Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)

---

## 📁 Cấu Trúc Các File Tài Liệu Phân Hệ Hưng Yên

| # | File | Nội dung chính | Single Source of Truth (SoT) |
|---|------|----------|------------------------------|
| 01 | [KB_07_01_OVERVIEW](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md) | Kiến trúc VVT_F5, bản đồ 17 màn hình HY, Menu Enesol D000, thuật toán LotNo/Barcode & Box Matching | Hung Yen Architecture & Overview |
| 02 | [KB_07_02_DEPLOY_HY](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md) | Danh mục 93 SPs cô lập `_HY`, bảng FG/VPC, Server-Side Layout Cloning & UTF-8 BOM rules | Hung Yen VVT_F5 Technical SP Reference |
| 03 | [KB_07_03_SCREEN_BUGS](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md) | Sổ tay cứu hộ sự cố 15+ màn hình HY, Gate time Aging `HY530`, Assy Card `HY540`, In tem Enesol `D100` | Hung Yen Screen Bug Fixbook |

---

## 🧭 Tra Cứu Nhanh Theo Màn Hình & TCode Hưng Yên

| TCode / Màn hình | Tên màn hình | Đọc File |
|---|---|---|
| `HY103` | Material Stock HY | → **01_OVERVIEW § 2** |
| `HY141` / `HY143` / `HY151` | IQC / PQC / OQC Master HY | → **01_OVERVIEW § 2** |
| `HY311` / `HY312` | PO Electrode & PO Detail HY | → **01_OVERVIEW § 2** |
| `HY430` / `HY431` | Material Issue & Receive Confirm | → **03_SCREEN_BUGS § 1** |
| `HY530` | Route Process Input HY (Aging Gate) | → **03_SCREEN_BUGS § 1** |
| `HY540` / `HY541` | Process Material Scan & Consumption | → **03_SCREEN_BUGS § 1** |
| `HY620` / `HY740` | OQC Inspection & Split Lot HY | → **01_OVERVIEW § 2** |
| `HYFG01` | Finished Goods WH HY | → **03_SCREEN_BUGS § 1** |
| `D051` | Customer Part No Info (Vendor P/N) | → **01_OVERVIEW § 3** |
| `D100` / `D110` | Enesol Box Label Print & History | → **01_OVERVIEW § 3** |
