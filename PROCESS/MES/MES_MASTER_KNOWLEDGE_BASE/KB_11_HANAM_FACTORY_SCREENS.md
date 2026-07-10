# KB_11 — Hà Nam Factory Screen Map & Deep System Discovery

> **Verified against DB:** 2026-06-18
> **🔑 Keywords:** Hà Nam, VVT_F3, HN screen, HNC, VE route, QC subsystem, vision, IoT, XRF, BOM, sales, H screen
> ← [Về INDEX](KB_INDEX.md) | Cross-ref: [KB_02 §HN](KB_02/KB_02_01_WMS_CORE.md), KB_34 §Route

---

## 1. Tổng quan — 83 Unique HN Screens

> Hà Nam (nhà máy F1) có **hệ thống screen riêng** với prefix `HN`, chiếm 8% tổng số screens. Điều này khác biệt hoàn toàn so với Bắc Giang (dùng chung B-series) và Hưng Yên (dùng D-series).

---

## 2. HN Screens — Bản đồ đầy đủ theo chức năng

### 2.1 Thành phẩm & Tồn kho (FG & Stock)
| TCode | Caption | Chức năng |
|---|---|---|
| `HN00` | Thành phẩm Hà Nam | Quản lý thành phẩm |
| `HN01` | Tồn kho thành phẩm HN | Tra cứu tồn kho FG |
| `HN107` | FinishGoodsHN | Thành phẩm Hà Nam (view) |
| `HN530` | Kho Bán thành phẩm Aging HN | **★ Kho BTP Aging** — Gate time |
| `HN781` | Sản lượng hoàn thành HN | Output tracking |
| `HN782` | LotTrackingInfo_HNam | **Lot tracking** |
| `HN788` | Theo dõi các lot Rework | Rework lots HN |
| `HN866` | Tồn kho thành phẩm chị Xuân | Tồn kho view (documented KB_02) |
| `HN867` | Tồn kho theo ngày | Daily stock view |

### 2.2 Đóng gói & In tem (Packing & Label)
| TCode | Caption | Chức năng |
|---|---|---|
| `HN05` | Xuất kho tem to thành phẩm | Xuất kho big label |
| `HN06` | Nhập kho tem nhỏ thành phẩm HN | Nhập kho small label |
| `HN12` | Thay đổi mã NVL để in tem đóng gói | Sửa material code cho label |
| `HN15` | Thay đổi mã NVL để in tem HN | Sửa material code HN |
| `HN523` | **Vietnam_Donggoi_Hnam** | **★ Đóng gói Hà Nam** (tương tự B523) |
| `HN541` | Thêm chữ Marking cho sản phẩm | Marking text config |
| `HN542` | Chia tem và in tem đóng gói | **Split & print packing labels** |
| `HN543` | Chia tem với mã tùy chỉnh NCC | Custom vendor code labels |
| `HN544` | Gộp túi bóng thành hộp nhỏ | **★ Merge bags→small box** (documented KB_02) |
| `HN545` | MergePackingHaNam | Gộp packing HN |
| `HN546` | Lịch sử đóng thùng to | Large box history |
| `HN547` | Lịch sử tách số lượng để in tem | Split qty for labels |
| `HN548` | Lịch sử đóng thùng to túi bóng | Big box bag history |
| `HN549` | In tem tồn kho trước khi có MES | Legacy stock labels |
| `HN550` | Gộp đóng thùng to với hàng tồn | Merge big box + legacy |
| `HN551` | Xuất kho tem to thành phẩm hàng tồn trước MES | **Export legacy** (documented KB_02) |
| `HN553` | In tem khách hàng Soluma V1 | Soluma customer labels |
| `HN554` | Gộp Packing hàng lẻ | Merge single items |
| `HN555` | Gộp Packing Hàng Lẻ | (duplicate screen) |
| `HN556` | Chia tem tồn kho trước MES | Split legacy labels |
| `HN557` | In Tem OuterBox | **Outer box label print** |
| `HN558` | In tem InnerBox | **Inner box label print** |
| `HN559` | Xem lịch sử gộp Packing / Xóa xuất kho | View merge history or delete export |
| `HN560` | Chia tem và in tem tồn trước MES | Split legacy |
| `HN563` | Tách số lượng ở Marking để in tem | Marking qty split for labels |

### 2.3 Máy móc & Thiết bị (Machine)
| TCode | Caption | Chức năng |
|---|---|---|
| `HN040` | Machine Price Cumulative HN | **Giá máy lũy kế** |
| `HN041` | Vietnam_UpgradeMachines_HN | Nâng cấp máy |
| `HN042` | Vietnam_MachineReports_HN | Báo cáo máy |
| `HN500` | AddMachineByRoute | **Thêm máy theo route** |
| `HN801` | Dữ liệu máy đo Aging | **Data máy Aging measurement** |
| `HN802` | GetAllDataMachineAging | Get all Aging machine data |

### 2.4 Nhà máy & Cài đặt (Factory & Settings)
| TCode | Caption | Chức năng |
|---|---|---|
| `HN100` | HaNam_Factory | **Factory dashboard** |
| `HN101` | Setting_HN / SettingPriceByPublicCode | Cài đặt giá |
| `HN102` | Production_HN / ErrorMaterialsPrices | SX + Giá lỗi NVL |
| `HN103` | Giá và mã hàng tại HN | Price & product code |
| `HN104` | Warehouse_HN | Cấu hình kho HN |
| `HN105` | SettingSystem_HN | System settings |
| `HN106` | Setting_Price | Price settings |
| `HN107` | Chuyển đổi đơn vị báo phế | Unit conversion for waste |
| `HN690` | Kiểm tra số lượng công đoạn theo lot | Route qty check by lot |
| `HN706` | Thiết lập khách hàng | Customer settings |
| `HN707` | Thông tin lịch sử in | Print history info |
| `HN708` | Tạo code theo khách hàng | Customer-specific code creation |
| `HN709` | In tem trong kho | In-warehouse label print |
| `HN710` | In tem theo khách hàng | Customer label print |
| `HN711` | InTemKhachHangSolum | Solum customer labels |

### 2.5 Kho NVL R&D
| TCode | Caption | Chức năng |
|---|---|---|
| `HN16` | Cấu hình NVL KTSP | NVL config for KTSP |
| `HN18` | Đẩy dữ liệu TP trước khi có MES | Legacy data push |
| `HN19` | Lịch sử đẩy dữ liệu Excel | Excel push history |
| `HN20` | **Nhập kho NVL RD** | R&D material receipt |
| `HN21` | **Xuất kho NVL R&D** | R&D material issue |
| `HN22` | Lịch sử nhập xuất kho NVL R&D | R&D stock in/out history |
| `HN23` | RDWarehouse | R&D warehouse master |
| `HN24` | Nhập kho thành phẩm RD | R&D FG receipt |
| `HN25` | Xuất kho thành phẩm RD HN | R&D FG issue |
| `HN26` | Thành phẩm RD HN | R&D FG view |
| `HN201` | Lịch sử thay đổi đầu vào NVL của BOM | BOM input change history |
| `HN202` | Xác nhận thay đổi nguyên liệu đầu vào | Confirm BOM material change |

### 2.6 Spare Parts HN
| TCode | Caption | Chức năng |
|---|---|---|
| `HN131` | VN_SparePartInfo_HN | SP Info |
| `HN161` | VNSparePartBasicLocation_HN | SP Location |
| `HN163` | VNN_BalanceSparePart_HN | SP Balance |
| `HN180` | TypeSparePart_HN | SP Type |
| `HN241` | VN_InSparePartHistoryManagement_HN | SP In History |
| `HN251` | VNSparePartOutHistoryAndChangeHistoryManagement_HN | SP Out + Change History |
| `HN260` | ReportSparePartInfo_HN | SP Report |
| `HN270` | ReportSparePartDetail_HN | SP Detail Report |

### 2.7 Misc
| TCode | Caption | Chức năng |
|---|---|---|
| `HN190` | EmployeeDepartment_HN | Bộ phận nhân sự HN |
| `HN561` | Hệ thống ANDON Nhà máy Bắc Giang | **⚠️ Lưu ý: TCode=HN561 nhưng Caption=BG** |
| `HN598` | Báo phế HN | Waste report HN |
| `HN760` | Lấy thông tin mã lot theo mã điện cực | Lot info by electrode code |
| `HN761` | Thông tin sản lượng công đoạn | Route production info |
| `HN850` | Hỗ trợ kế toán dữ liệu | Accounting data support |
| `HN887` | Lấy dữ cho Anh Tuấn Anh | (Personal use — dev/test) |
| `HNC321` | PQC_Reliability_Assay_HN | **PQC Reliability QC Hà Nam** |

---

## 4. H-Series — Equipment, Spare Parts & Calibration (82 screens)

> H-series = hệ thống quản lý thiết bị, phụ tùng, hiệu chuẩn, văn phòng phẩm.

### 4.1 [H01]/[H07] — Equipment Management ( )
| TCode | Caption | Chức năng |
|---|---|---|
| `H01` | Thông tin kho thiết bị | Equipment warehouse |
| `H02` | Trạng thái thiết bị | Equipment status |
| `H03` | Vị trí thiết bị | Equipment location |
| `H04` | Thông tin thiết bị | Equipment master info |
| `H040` | Machine Price Cumulative | **Giá máy lũy kế** |
| `H041` | Vietnam_UpgradeMachines | Nâng cấp máy |
| `H042` | Vietnam_MachineReports | Báo cáo máy |
| `H05` | Quản lý thiết bị HR | Equipment HR |
| `H06` | KPI Máy | Machine KPI |
| `H07` | Temperature/Humidity | Nhiệt ẩm kế |
| `H44` | Thông tin thiết bị (extended) | Equipment detail |
| `H804` | Lịch sử thông tin bảo trì | Maintenance history |

### 4.2 [H101]/[H104] — Calibration Management ( )
| TCode | Caption | Chức năng |
|---|---|---|
| `H101` | VVT_Quản lý thiết bị hiệu chuẩn | **★ Calibration management** |
| `H102` | VVT_Lịch sử hiệu chỉnh | Calibration history |
| `H103` | VVT_Thêm thiết bị hiệu chuẩn | Add calibration device |
| `H104` | VVT_Xem thiết bị hiệu chuẩn | View calibration device |

### 4.3 [H131]/[H270] — Spare Parts ( )
| TCode | Caption | Ghi chú |
|---|---|---|
| `H131` | VN_SparePartInfo | SP master info |
| `H161` | VNSparePartBasicLocation | SP locations |
| `H162/H163/H164` | BalanceSparePart | SP balance views |
| `H180` | TypeSparePart / MachineSparePartInfo | SP type + machine mapping |
| `H190` | EmployeeDepartment | Bộ phận nhân sự |
| `H241/H242` | VN_InSparePartHistoryManagement | SP nhập lịch sử |
| `H251/H252` | VNSparePartOutHistory | SP xuất lịch sử |
| `H260` | ReportSparePartInfo / ElectrodeSlittingCutterUsageHist | SP Report + Cutter usage |
| `H270` | ReportSparePartDetail | SP detail report |
| `H301-H305` | Special Spare Parts | **★ Documented KB_03** |

### 4.4 [H141]/[H149] — Stationery Management ( ) Văn phòng phẩm
| TCode | Caption | Chức năng |
|---|---|---|
| `H141` | StationeryInfor | Thông tin VPP |
| `H142` | Balance_Stationery | Tồn kho VPP |
| `H143` | Input_Warehouse_NVL_Stationery | Nhập kho VPP |
| `H144` | Output_Warehouse_NVL_Stationery | Xuất kho NVL VPP |
| `H145` | Output_Warehouse_KSX_Stationery | Xuất kho SX VPP |
| `H146` | SumReportStationery | Báo cáo tổng VPP |
| `H147` | ReportDetailStationery | Báo cáo chi tiết VPP |
| `H148` | EmployeeAll | Danh sách nhân viên |
| `H149` | ConfirmInput | Xác nhận nhập |

---

## 5. HY-Series — Hưng Yên Factory (17 screens)

> HY = Hưng Yên factory screens. Phân biệt với D-series (VinaEnesol menu) — HY focuses on QC, production, warehouse.

| TCode | Caption | Chức năng |
|---|---|---|
| `HY103` | PricesAndMaterialHY | Giá & NVL Hưng Yên |
| `HY121` | QCInspectionGroupCode_HY | **Mã nhóm kiểm tra QC** |
| `HY141` | HY_CommonInspTypeInfo | Loại kiểm tra chung |
| `HY143` | HY_CommInspIndividualSpec | Spec kiểm tra riêng |
| `HY151` | HY_MaterialQcInspectionItem | **Hạng mục QC NVL** |
| `HY311` | PO_Electrode_HY | **PO Electrode Hưng Yên** |
| `HY312` | HY_MaterialGrFromOrder | GR từ PO |
| `HY330` | (Korean menu) | Menu master |
| `HY430` | HY_MaterialWarehouseInOutHist | **Lịch sử nhập xuất kho** |
| `HY431` | RouteInspectionMeasureFullHist_HY | **Đo kiểm tra toàn route** |
| `HY443` | HY_InspectionPQC | **PQC Inspection HY** |
| `HY530` | HY_MaterialOqcInfoSampleManagement | **OQC mẫu HY** |
| `HY540` | HY_AssyCardInfo / ProdInspectionHist_HY | Assembly Card + SX inspection |
| `HY541` | HY_ProdInspectionHist | SX inspection history |
| `HY620` | HY_MaterialReturnAndPrintLabel | **Trả hàng + in tem HY** |
| `HY740` | HY_SplitLot | **Split lot HY** |

---

## 6. QC Core Subsystems (Verified)

### 6.1 Common Inspection Framework (18 tables)
| Table | Mô tả |
|---|---|
| `STB_CommInspDocHistory` | **★ Lịch sử phiếu kiểm tra** (430/ngày — verified) |
| `STB_CommInspDocItem` | Chi tiết hạng mục |
| `STB_CommInspMeasureHist` | **★ Kết quả đo** (33,783/ngày — verified) |
| `STB_CommInspIndividualSpec` | Spec kiểm tra riêng |
| `STB_CommInspTypeInfo` | Loại kiểm tra (IQC/PQC/OQC/FQC) |
| `STB_CommInspSelectGroup` | Nhóm chọn |
| `STB_CommInspSelectItem` | Hạng mục chọn |
| `STB_CommInspItem` | Master hạng mục |

### 6.2 Material QC (20 tables)
| Table | Mô tả |
|---|---|
| `STB_MaterialQcInfo` | **★ QC info master** |
| `STB_MaterialQcDetail` | Chi tiết QC |
| `STB_MaterialQcInspectionGroup` | Nhóm kiểm tra (+ HY variant) |
| `STB_MaterialQcInspectionItem` | **★ Hạng mục kiểm tra** (+ HY, PQC variants) |
| `STB_MaterialQcSampleResult` | Kết quả mẫu |

### 6.3 OQC/IQC/PQC (13 tables)
| Table | Mô tả |
|---|---|
| `STB_IOQCDefectDetail/Info` | Lỗi incoming/outgoing QC |
| `STB_IQcDefectReport` | IQC defect report |
| `STB_IQCSampleQtyStandard` | IQC tiêu chuẩn mẫu |
| `STB_OQCDetailSampleQty_VVT` | OQC mẫu VVT |
| `STB_OqcLotCreateRule` | **★ OQC lot creation rule** |
| `VVT_OQC_REFER` | **★ OQC reference** (cross-ref KB_04 §6.19) |

---

## 7. Vision/IoT/XRF Inspection (8 tables)

| Table | Mô tả |
|---|---|
| `STB_VisionGroup1InspectionInfo` | Vision camera Group 1 |
| `STB_VisionGroup2InspectionInfo` | Vision camera Group 2 |
| `STB_VisionGroup3InspectionInfo` | Vision camera Group 3 |
| `STB_VisionInspectionResult` | **★ Kết quả kiểm tra Vision** |
| `STB_IoTDeviceInfo` | **Thiết bị IoT master** |
| `STB_IoTMeasureHist` | **Lịch sử đo IoT** |
| `STB_IoTCalibrationHist` | Lịch sử hiệu chuẩn IoT |
| `STB_XRFInspectionInfo` | **X-Ray Fluorescence inspection** |

---

## 8. BOM System (18 tables)

| Table | Mô tả |
|---|---|
| `STB_BomHeader` | **★ BOM master header** |
| `STB_BomDetail` | BOM detail (parent-child) |
| `STB_BomDetail_Revision` | BOM revision tracking |
| `STB_BomBatchInfo` | BOM batch info |
| `STB_BomRevision_Map` | Revision mapping |
| `STB_BOM_Material` | BOM material master |
| `STB_HistoryChangeInputMaterialOfBOM` | **★ Lịch sử thay đổi NVL input** |
| `STB_ProductionOrderBom` | PO BOM |
| `STB_PurchaseBOM` | BOM mua hàng |
| `STB_Vietnam_POBom_VVT` | PO BOM VVT |
| `STB_VN_BOM_LOGITIC` | **BOM logistics** |
| `stb_vvt_materialbom` | VVT material BOM |

---

## 9. Sales/Shipment/Invoice (15 tables)

| Table | Mô tả |
|---|---|
| `STB_SalesOrder` | Đơn hàng |
| `STB_SalesOrderItem` | Chi tiết đơn hàng |
| `STB_SalesPlan` | Kế hoạch bán hàng |
| `STB_SalesMonthlyPlan` | Kế hoạch tháng |
| `STB_ShipmentHist` | **★ Lịch sử giao hàng** |
| `STB_ShipmentOrderInfo` | Lệnh giao hàng |
| `STB_ShipmentInfoTempForERP` | Temp data cho ERP |
| `stb_vietnam_invoiceEcus` | **★ Hóa đơn ECUS** (hải quan) |
| `Stb_Vvt_InvoiceEcus` | Invoice ECUS VVT |
| `InvoiceFinishGoodStockOutBG` | Invoice xuất kho BG |

---

## 10. Special Process Tables

### 10.1 Hela Customer System (6 tables)
| Table | Mô tả |
|---|---|
| `STB_HelaBarcode` | Barcode Hela |
| `STB_HelaBarcodeOutBoxHist` | Lịch sử xuất box |
| `STB_HelaPackingCheckHist` | Packing check |
| `STB_HelaPackingCheckHist_Detail` | Detail check |
| `STB_LotNumberChangeHistForHela` | Lot change cho Hela |
| `Stb_VVT_CoverCheckHelaLabelHist` | Cover check label |

### 10.2 Curling/Stripping (5 tables)
| Table | Mô tả |
|---|---|
| `CURLING_LINE` | Line cuộn |
| `CURLING_PLAN` | Kế hoạch cuộn |
| `CURLING_PROD` | Sản xuất cuộn |
| `STB_StrippingMachineHist` | Lịch sử máy stripping |

### 10.3 Reliability Test (4 tables)
| Table | Mô tả |
|---|---|
| `STB_ReliabilityTestManagementInfo` | **★ Quản lý RTM** |
| `STB_ReliabilityTestMeasureInfo` | Kết quả đo |
| `STB_ReliabilityTestRequestInfo` | Yêu cầu test |
| `STB_ReliabilityTestSampleInfo` | Mẫu test |

### 10.4 Inventory (Kiểm kê) (8 tables)
| Table | Mô tả |
|---|---|
| `STB_VN_InventoryFirst` | **★ Kiểm kê đầu kỳ** |
| `STB_VN_InventoryFirst_History` | Lịch sử kiểm kê |
| `STB_InventoryOfGoodsReport` | Báo cáo kiểm kê |
| `STB_VN_MODEL_INVENTORY` | Kiểm kê theo model |
| `STB_VietnamSemiInventory` | Bán thành phẩm inventory |
| `Stb_InventoryMaterialLiquidation` | Thanh lý NVL |
| `Stb_InventoryProductLiquidation` | Thanh lý thành phẩm |
| `Stb_InventoryUpLine` | Kiểm kê up-line |

### 10.5 Check Schedule System (16 tables)
| Table | Mô tả |
|---|---|
| `STB_CheckScheduleInfo` | **★ Lịch kiểm tra** (18,265 records — verified) |
| `STB_CheckStandardInfo` | Tiêu chuẩn kiểm tra |
| `stb_CheckSheetDaily` | Check sheet hàng ngày |
| `Stb_CheckSheetDailyDetail` | Chi tiết check sheet |
| `STB_CheckScheduleExceptionHist` | Ngoại lệ lịch kiểm |
| `STB_OccasionalCheckScheduleInfo` | Kiểm tra đột xuất |
| `STB_MoldCheckSheetItem` | Check sheet khuôn |
| `STB_MoldCheckSheetMaster` | Master check khuôn |

---

## 11. 📊 Complete Screen Prefix Matrix (Verified)

| Prefix | Count | Documented % | KB File |
|---|---|---|---|
| **B** | **298** | ~60% | KB_03, KB_04 |
| **C** | **141** | ~30% | KB_05 |
| **F** | **87** | ~25% | KB_02 |
| **HN** | **83** | **~5%→100%** | **KB_11** ✅ |
| **H** | **82** | **~10%→90%** | **KB_11** ✅ |
| **Z** | **42** | ~15% | KB_01, KB_34 |
| **A** | **29** | ~20% | KB_06 |
| **K** | **28** | ~15% | KB_03 |
| **P** | **28** | ~50% | KB_34 |
| **V** | **26** | ~50% | KB_34 |
| **E** | **24** | ~40% | KB_05 |
| **L** | **23** | ~50% | KB_34 |
| **FG** | **23** | ~50% | KB_34 |
| **G** | **22** | ~50% | KB_34 |
| **M** | **22** | ~70% | KB_34 |
| **HY** | **17** | **0%→100%** | **KB_11** ✅ |
| **T** | **16** | ~40% | KB_34 |
| **S** | **12** | ~50% | KB_34 |
| **W** | **10** | ~50% | KB_34 |
| **R** | **9** | ~50% | KB_34 |
| **D** | **6** | ~80% | KB_07 |
| **TOTAL** | **~1,044** | **~60%** | 23 KB files |

---

*Cập nhật: 2026-06-18 — Deep discovery Phases 8-11 (HN 83 screens, H 82 screens, HY 17 screens, QC/Vision/IoT/BOM/Sales subsystems)*

---

## Appendix — HN Isolated SPs & Tables (DB Verified 2026-06-18)

> **Tổng: 63 SPs** có hậu tố `_HN` hoặc `_HNam` — tách biệt hoàn toàn khỏi logic BN/BG/HY

### A.1 HN SP theo nhóm chức năng

#### Slitting / Aging (18 SPs):
| SP | Chức năng |
|---|---|
| `usp_CreateLotSlitting_HN_uid` | Tạo Lot Slitting |
| `usp_CreateLotSlitting_NG_HN_uid` | Tạo Lot Slitting NG |
| `usp_SlittingLotInfo_HN_get` | Thông tin Lot Slitting |
| `usp_ListInputNeedSlitting_HN` | DS chờ Slitting |
| `usp_ListInputSuccessSlitting_HN` | DS đã Slitting |
| `usp_CheckedSlittingHN_get` | Đã kiểm tra |
| `usp_ErrorSlittingHN_get` | Lỗi Slitting |
| `usp_PassedSlittingHN_get` | Đã đạt |
| `usp_AllQuantityStatisticsSlittingHN_get` | Thống kê SL |
| `usp_DoSplitLotAgingHN` | Tách Lot Aging |
| `usp_GetMasterAgingHN_get` | Master Aging |
| `usp_GetDetailAgingHN_get` | Chi tiết Aging |
| `usp_GetMidlleAgingHN_get` | Aging trung gian |
| `usp_GetAllDataStatisticsAgingHN` | Thống kê toàn bộ Aging |
| `usp_GetAllDetailsAgingHN` | Chi tiết toàn bộ Aging |
| `usp_GetAllDataDetailsAgingHN_BI` | BI detail |
| `usp_GetDataStatisticAgingHN_BI` | BI statistics |
| `usp_GetDataDetailsAgingHN_BI` | BI detail view |

#### Packing / FG (18 SPs):
| SP | Chức năng |
|---|---|
| `usp_GetMaterialLotInfo_PackingHN710_HaNam` | Lot packing HN |
| `usp_getMergePackingBoxSmall_HN` | Gộp hộp nhỏ HN |
| `usp_MergePackingHN710_HN` | Gộp packing HN710 |
| `usp_getPackingOutPutFinishGoods_HN` | Output FG packing |
| `usp_getPackingOutPutFinishGoodsInventory_HN` | Tồn kho FG packing |
| `usp_VN_ShowAllFinishGoodMES_HN` / `_Export` | Hiển thị / Export FG |
| `usp_VN_ShowAllFinishGoodMES_RD_HN` / `_Export` | FG R&D HN |
| `usp_Add_Fg_HN` / `usp_HN_FinishGood_ImportExcel_uid` | Thêm / Import FG |
| `usp_VN_Add_ImportExcel_HN` / `usp_VN_Update_ExportExcel_HN` | Import/Export Excel |
| `usp_GetFinishGood_HNByLocation` | FG theo vị trí |
| `usp_getFinishGood_ImportExcel_HN` | Import Excel FG |
| `usp_VN_UpdateIDCode_HN` | Cập nhật ID Code |

#### Warehouse / Material (10 SPs):
| SP | Chức năng |
|---|---|
| `usp_InventoryWareHouse_HN` / `_New` | Tồn kho HN |
| `usp_Vietnam_LocateOfRawMaterials_HN` | Vị trí NVL |
| `usp_Vietnam_LocationMapFinishGoodHN` / `AfterMES` | Bản đồ vị trí TP |
| `usp_Vietnam_GetBoxIDForLotInventory_HN` | Box ID tra cứu |
| `usp_ChangeMaterialCode_HN` / `_uid` | Đổi mã NVL |
| `usp_ChangeMaterialNVL_HN_popup` | Popup đổi NVL |
| `usp_extension_warhouse_HN` | Gia hạn kho |
| `usp_CodeNVL_HN598` | Mã NVL 598 |

#### Misc:
| SP | Chức năng |
|---|---|
| `usp_LotTrackingInfo_VVT2_get_HNam` | Lot Tracking HN |
| `usp_MaterialReportTK_new_HN` | Báo cáo NVL |
| `usp_Vietnam_PackPrintTime_get_HN` | Thời gian in tem |
| `usp_Type_inpuT_HN` | Loại nhập |
| `usp_GetRouteInfoHN_popup` | Route info popup |
| `get_MaterialCodePrintTemFor_HN` | Mã NVL in tem |

#### R&D HN (6 SPs):
| SP | Chức năng |
|---|---|
| `ExportWarehouseFinshGood_RD_HN_uid` | Xuất kho R&D |
| `ImportWarehouseFinshGood_RD_HN_uid` | Nhập kho R&D |
| `sp_Export_WithHistory_STB_RndRawMaterial_HN` | Export R&D NVL |
| `sp_SearchRnDRawMaterial_HN_get` / `_Export_HN_get` | Tìm NVL R&D |
| `sp_Upsert_Accumulate_STB_RndRawMaterial_HN` | Tích lũy R&D |

### A.2 HN-Specific Tables

| Table | Mô tả |
|---|---|
| `STB_VN_FINISHGOODS_HN_New` | **★ Finished Goods** Hà Nam (chính) |
| `STB_VN_FINISHGOODS_HN_Export` | Export view HN |
| `STB_VN_RND_FINISHGOODS_HN` / `_Export` | FG R&D Hà Nam |
| `STB_MachineByRoute_HN` | Machine↔Route mapping HN |
| `stb_vn_AgingBG` | Aging data (shared BG→HN) |

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: 63 HN-isolated SPs (phân loại theo chức năng) + 5 HN-specific Tables. DB verified.*

