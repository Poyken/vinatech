## Appendix — Packing/Label Table Architecture (DB Verified 2026-06-18)

> **Tổng: 49 tables** liên quan đóng gói và in tem trong SmartFactoryV2

### Core Packing Tables (8)

| Table | Mô tả |
|---|---|
| **`STB_DividePackaging`** | **★ Phân chia đóng gói** (Core packing logic) |
| **`STB_PackingStandard`** | **★ Tiêu chuẩn đóng gói** per Size (VinylBagQty, InnerBoxQty, OutBoxQty) |
| `STB_PackingQtyPerSize` | SL đóng gói theo kích thước |
| `STB_PackingQtyPrintB523_VVT` | SL in tem tại B523 |
| `STB_PackingRemainingQtyInfo` | SL còn lại chưa đóng gói |
| `STB_PackingLabelSpec` | Spec tem đóng gói |
| `STB_ManualPacking` | Đóng gói thủ công |
| `STB_PackingBoxChangeHist` | Lịch sử thay đổi box |

### Customer Label Tables (12)

| Table | Khách hàng |
|---|---|
| `STB_AcbelLabelPrintHist` | Acbel |
| `STB_DigiKeyLabelInnerPrintHist` | DigiKey (Inner) |
| `STB_DigiKeySingleLevelPackagePrintHist` | DigiKey (Single) |
| `STB_FarnellLabelPrintHist` | Farnell |
| `STB_JabilManualLabelPrintHist` | Jabil Manual |
| `STB_JabilMexicoLabelPrintHist` | Jabil Mexico |
| `STB_KlemoveLabelInfo` | Klemove |
| `STB_NordexPackingLabelPrintingHist` | Nordex |
| `STB_PACLabelPrintHistV1` | PAC |
| `STB_SanminaIndiaLabelPrintHist` | Sanmina India |
| `STB_VINAEnesolBoxLabelPrintHist` | VinaEnesol |
| `Stb_VVT_CoverCheckHelaLabelHist` | Hela |

### Print History & Config (14)

| Table | Mô tả |
|---|---|
| `STB_PackingLabelPrintHist` | **★ Lịch sử in tem đóng gói** |
| `STB_MarkingLabelPrintHist` | Lịch sử in tem marking |
| `STB_VietnamLabelPrintHist` | Lịch sử in tem VN |
| `STB_VN_BloomBoxLabelPrintHist` | Lịch sử in tem Bloom box |
| `STB_PassLabelPrintHist` | Lịch sử in tem PASS |
| `STB_HelaPackingCheckHist` / `_Detail` | Kiểm tra packing Hela |
| `STB_ModelLabelInfo` | **★ Mapping ModelCode → LabelType** |
| `STB_ModuleLabelInfo` | Tem Module |
| `STB_ModuleAssemblyLabelInfo` | Tem lắp ráp Module |
| `STB_Vietnam_PackingPrinting` | **★ Config in tem VN** (PrintVJ flag) |
| `STB_Vietnam_SettingPackLabel` | Cài đặt mẫu tem |

### Timing & Qty Tables (9)

| Table | Mô tả |
|---|---|
| **`STB_SavePackingTime_VVT`** | **★ Thời gian Takt đóng gói** |
| `STB_SavePackingQty_VVT_F2` | SL đóng gói BG |
| `STB_SavePackingQtyByLevel_VVT` | SL theo cấp |
| `STB_PackingLabelHistForPS` | Lịch sử tem cho PS |
| `STB_PackingHN710_HN` | Đóng gói HN710 |
| `STB_PackingNilonToBoxSmall_HN` | Gộp túi bóng HN |
| `STB_PackingOutPutFinishGoods_HN` | Output FG packing HN |

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: 49 Packing/Label tables classified (Core 8, Customer Labels 12, Print History 14, Timing 9). DB verified.*
