# Tài Liệu Chi Tiết Tất Cả Màn Hình MES — Vinatech NAIS

> **Ngày tạo:** 2026-06-27  
> **Nguồn dữ liệu:** DB thực tế `SmartFramework.dbo.STB_ScreenObjects` + `SmartFramework.dbo.STB_ScreenInfo` + `SmartFactoryV2`  
> **Mục đích:** Tài liệu đầy đủ, thống nhất cho từng object (View, SearchFunction, ExecuteFunction, Action/Button) của tất cả các màn hình đã biết trong hệ thống MES.  
> **Lưu ý:** Không bao gồm các màn hình HY clone (HY121, HY122, HY220, HY310, HY442, HY470, HY552, HY802, HY460) — xem `sql/scripts/hy_clone/HY_9_SCREENS_DOCUMENTATION.md`.

---

## Mục Lục

### Bước 1: Thiết Lập Hệ Thống & Cấu Hình Nền Tảng QC
*Các cấu hình ban đầu, khai báo danh mục lỗi, nhóm hạng mục QC, thông tin model sản phẩm và thiết lập máy móc/nhân sự.*

1. [Z110 — BaseCode](#z110-basecode)
2. [Z120 — SerialRule](#z120-serialrule)
3. [C112 — AQLBasicRule](#c112-aqlbasicrule)
4. [C121 — QcInspectionGroup](#c121-qcinspectiongroup)
5. [C122 — MaterialQcInspectionItemByMaterial](#c122-materialqcinspectionitembymaterial)
6. [C131 — DefectGroup](#c131-defectgroup)
7. [C132 — DefectInfo](#c132-defectinfo)
8. [C141 — CommInspTypeItemManagement](#c141-comminsptypeitemmanagement)
9. [C143 — CommInspIndividualSpec](#c143-comminspindividualspec)
10. [C151 — MaterialQcInspectionItemByFERT](#c151-materialqcinspectionitembyfert)
11. [A230 — MaterialMaster](#a230-materialmaster)
12. [A310 — BomInfo](#a310-bominfo)
13. [A410 — ModelBasicInfo](#a410-modelbasicinfo)
14. [A418 — PackingQtyPerSize](#a418-packingqtypersize)
15. [A419 — PackingQtyWarehouse](#a419-packingqtywarehouse)
16. [A460 — ModelLabelInfo](#a460-modellabelinfo)
17. [B210 — LineInfo](#b210-lineinfo)
18. [B220 — RouteInfo](#b220-routeinfo)
19. [B230 — LineRouteMapping](#b230-lineroutemapping)
20. [B240 — BasicRoutingInfo](#b240-basicroutinginfo)
21. [B250 — MachineMaster](#b250-machinemaster)
22. [B260 — ProdWorkerInfo](#b260-prodworkerinfo)
23. [B270 — ProductMachine](#b270-productmachine)

### Bước 2: Nhập Kho Nguyên Vật Liệu & Xác Nhận IQC đầu vào
*Tiếp nhận nguyên vật liệu từ PO mua hàng, in nhãn Lot NVL đầu vào và thực hiện kiểm tra chất lượng IQC.*

24. [F330 — MaterialReceiptAndPrintLabel](#f330-materialreceiptandprintlabel)
25. [F312 — Vietnam_MaterialGrFromOrder](#f312-vietnam_materialgrfromorder)
26. [F320 — MaterialReceipt](#f320-materialreceipt)
27. [F610 — MaterialReturnOrder](#f610-materialreturnorder)
28. [F620 — MaterialReturnAndPrintLabel](#f620-materialreturnandprintlabel)
29. [F130 — MaterialMappingByCustomer](#f130-materialmappingbycustomer)
30. [C220 — MaterialIqcInfoSampleManagement](#c220-materialiqcinfosamplemanagement)

### Bước 3: Lập Kế Hoạch & Lệnh Sản Xuất
*Tạo lệnh sản xuất PO, phân rã PO thành kế hoạch sản xuất hàng ngày theo tổ/máy/ca sản xuất.*

31. [B301 — PO_InformationManagement](#b301-po_informationmanagement)
32. [B310 — ProductionOrderInfo](#b310-productionorderinfo)
33. [B351 — ProductionOrderForChangeMaterial](#b351-productionorderforchangematerial)
34. [B353 — ChangeNameLotNo](#b353-changenamelotno)
35. [B442 — ElectrodePlan_Vietnam](#b442-electrodeplan_vietnam)
36. [B450 — DayProdPlanForMainLot](#b450-dayprodplanformainlot)
37. [B452 — Vietnam_PrintLotChanged](#b452-vietnam_printlotchanged)
38. [B460 — VNT_DayProdPlanByFinished](#b460-vnt_dayprodplanbyfinished)

### Bước 4: Sản Xuất Công Đoạn 1 — Cực Điện (Mixing, Coating, Cán, Cắt)
*Pha chế nguyên liệu (Mixing), phủ màng cực điện (Coating), cán ép cuộn cực điện (RollPressing), xẻ cuộn cực điện (Slitting) và kiểm tra QC cực điện.*

39. [B470 — VNT_ElectrodePrcsCard](#b470-vnt_electrodeprcscard)
40. [F742 — ListInputSlitting_HN](#f742-listinputslitting_hn)
41. [F743 — SlittingLOTMaterialHaNam](#f743-slittinglotmaterialhanam)
42. [F744 — WidthSlittingWH](#f744-widthslittingwh)
43. [F746 — SlittingHistHN](#f746-slittinghisthn)
44. [F747 — ErrorSlittingHN](#f747-errorslittinghn)
45. [F748 — CheckBeforeTransferWarehouse](#f748-checkbeforetransferwarehouse)
46. [B552 — Vietnam_ElectrodeMeasureResult](#b552-vietnam_electrodemeasureresult)
47. [C243 — CheckSlittingLot](#c243-checkslittinglot)
48. [C460 — ElectrodeInspectionHistoryForBarcode](#c460-electrodeinspectionhistoryforbarcode)
49. [B802 — Vietnam_EletrodeProdRouteHist](#b802-vietnam_eletrodeprodroutehist)

### Bước 5: Sản Xuất Công Đoạn 2 — Lắp Ráp & Kiểm Tra QC Công Đoạn Cell Line
*Lắp ráp cell, sấy hàng, bẻ cong/dán keo, kiểm tra QC tự chủ inline và ghi nhận sản lượng, phế phẩm công đoạn Cell Line.*

50. [B597 — VNT_SelfInspectionRawMaterial2](#b597-vnt_selfinspectionrawmaterial2)
51. [B598 — VVT_ProScraps2](#b598-vvt_proscraps2)
52. [B540 — AssyCardInfo](#b540-assycardinfo)
53. [B530 — VNT_ProdRouteByBarcode](#b530-vnt_prodroutebybarcode)
54. [B717 — BendingTapping](#b717-bendingtapping)
55. [B718 — SummaryTappingBennding](#b718-summarytappingbennding)
56. [B733 — B733](#b733-b733)
57. [B618 — ReworkSorting](#b618-reworksorting)
58. [B682 — VvtProdBadStatus](#b682-vvtprodbadstatus)
59. [B726 — ScrapAfterProduction](#b726-scrapafterproduction)
60. [C486 — ErrorDataSorting](#c486-errordatasorting)

### Bước 6: Kiểm Tra Chất Lượng Thành Phẩm (OQC / FOQC / ESR)
*Tập hợp các Lot sản xuất để làm phiếu kiểm tra chất lượng thành phẩm OQC, đo thông số ESR, kiểm tra độ tin cậy và báo cáo sự cố chất lượng.*

61. [C510 — MaterialOqcLotManagement](#c510-materialoqclotmanagement)
62. [C512 — SetListForOqcLotManagement_VVT2](#c512-setlistforoqclotmanagement_vvt2)
63. [C530 — MaterialOqcInfoSampleManagement](#c530-materialoqcinfosamplemanagement)
64. [C321 — VietnamPQC_ReliabilityAssay](#c321-vietnampqc_reliabilityassay)
65. [C522 — Aging_ESR_SD](#c522-aging_esr_sd)
66. [B934 — esrAgingSD_csv](#b934-esragingsd_csv)
67. [B935 — esrAgingSD_get](#b935-esragingsd_get)
68. [C531 — vvt_ProdRouteForPacking_OQC](#c531-vvt_prodrouteforpacking_oqc)
69. [C541 — VVT_ProdInspectionHist_vvt](#c541-vvt_prodinspectionhist_vvt)
70. [C546 — FOQC_MaterialOqcInfoSampleManagement](#c546-foqc_materialoqcinfosamplemanagement)
71. [C564 — VVT_ProdInspectionHist_BendingCutting](#c564-vvt_prodinspectionhist_bendingcutting)
72. [C430 — VNT_RouteInspectionMeasureFullHist](#c430-vnt_routeinspectionmeasurefullhist)
73. [C443 — Vietnam_inspectionPQC](#c443-vietnam_inspectionpqc)
74. [C451 — SelfInspectionHistoryForBarcode2](#c451-selfinspectionhistoryforbarcode2)
75. [C585 — VVT_DoCreateDefectOQC](#c585-vvt_docreatedefectoqc)

### Bước 7: Đóng Gói Thành Phẩm & In Tem Nhãn
*Đóng gói sản phẩm vào Box, Taping, cân trọng lượng, in nhãn đóng gói, nhãn thùng carton PAC và nhãn riêng cho khách hàng Digikey.*

76. [B453 — Vietnam_PrintLabelSchneider](#b453-vietnam_printlabelschneider)
77. [B523 — Vietnam_Donggoi](#b523-vietnam_donggoi)
78. [B525 — Kho_Donggoi2](#b525-kho_donggoi2)
79. [B528 — VVT_ProdPacking_vvt](#b528-vvt_prodpacking_vvt)
80. [B560 — VNT_HelaBarcode](#b560-vnt_helabarcode)
81. [B754 — VVT_PrintBoxLabelPAC](#b754-vvt_printboxlabelpac)
82. [B755 — VVT_PACPrintLabelHist](#b755-vvt_pacprintlabelhist)
83. [B756 — PACLabelCartonAndWeight](#b756-paclabelcartonandweight)
84. [B757 — DigiKeyLabelInner_get](#b757-digikeylabelinner_get)
85. [B758 — DigikeyLabelLevelPackage_get](#b758-digikeylabellevelpackage_get)
86. [B767 — VVT_SanminaLabelPrint](#b767-vvt_sanminalabelprint)
87. [B781 — VNT_LotTrackingInfo_vvt21](#b781-vnt_lottrackinginfo_vvt21)
88. [B789 — VNT_ModuleLotTrackingInfo_vvt21](#b789-vnt_modulelottrackinginfo_vvt21)
89. [B790 — InTemPhoenixContact](#b790-intemphoenixcontact)
90. [B791 — PrintPhoenixDateCode](#b791-printphoenixdatecode)

### Bước 8: Quản Lý Kho Thành Phẩm & Xuất Kho Bán Hàng (WMS FG & GI)
*Nhập kho thành phẩm, quản lý tồn kho, xuất kho thành phẩm bán hàng, vận hành hệ thống kho tự động Daifuku.*

91. [C560 — VNT_ProductsReceiptHist](#c560-vnt_productsreceipthist)
92. [C561 — MaterialQcInspectionItemBendingCutting](#c561-materialqcinspectionitembendingcutting)
93. [C562 — SetListForBendingCuttingQCLot](#c562-setlistforbendingcuttingqclot)
94. [C563 — VVT_QC_BendingCutting](#c563-vvt_qc_bendingcutting)
95. [C540 — VNT_ProdInspectionHist](#c540-vnt_prodinspectionhist)
96. [F110 — MaterialStockAttributeInfo](#f110-materialstockattributeinfo)
97. [F140 — VendorMappingByMaterialInfo](#f140-vendormappingbymaterialinfo)
98. [F710 — MaterialStock](#f710-materialstock)
99. [F721 — VVT_MaterialStockList](#f721-vvt_materialstocklist)
100. [F723 — VVTF4_CellMaterialStockList](#f723-vvtf4_cellmaterialstocklist)
101. [F740 — SplitLot](#f740-splitlot)
102. [F741 — SlittingLot](#f741-slittinglot)
103. [F750 — MaterialStocktakingDoc](#f750-materialstocktakingdoc)
104. [F761 — VVT_MaterialDocDetailHistory_vvt1](#f761-vvt_materialdocdetailhistory_vvt1)
105. [B750 — FinishGoodOutTemporary](#b750-finishgoodouttemporary)
106. [B752 — StatusPallet](#b752-statuspallet)
107. [G100 — SalesGI](#g100-salesgi)
108. [G400 — ProductReturnAndPrintLabel](#g400-productreturnandprintlabel)
109. [G660 — Daifuku_Warehouse](#g660-daifuku_warehouse)
110. [F430 — VNT_MaterialWarehouseInOutHist](#f430-vnt_materialwarehouseinouthist)

### Bước 9: Phân Hệ Module, Khách Hàng Enesol & Quản Lý Hệ Thống
*Các quy trình sản xuất Module, Spare Part, Vision Inspection, phân hệ riêng cho Enesol và phân quyền tài khoản người dùng.*

111. [K101 — DayProdPlanForMainLotMDL](#k101-dayprodplanformainlotmdl)
112. [K109 — VNT_SelfInspectionRawMaterialBE](#k109-vnt_selfinspectionrawmaterialbe)
113. [K110 — VNT_ModuleProductionInfo](#k110-vnt_moduleproductioninfo)
114. [K199 — VNT_NordexPackingLabelPrintingHist_get](#k199-vnt_nordexpackinglabelprintinghist_get)
115. [D000 — VinaEnesol_Management_MENU](#d000-vinaenesol_management_menu)
116. [D051 — VNE_CustomerPartNoInfo](#d051-vne_customerpartnoinfo)
117. [D100 — VinaEnesolProductionManagement_MENU](#d100-vinaenesolproductionmanagement_menu)
118. [D110 — VNE_BoxLabelPrintHist](#d110-vne_boxlabelprinthist)
119. [S212 — VisionGroupInspInfo](#s212-visiongroupinspinfo)
120. [S213 — VNT_VisionInspectionResult](#s213-vnt_visioninspectionresult)
121. [S215 — VNT_XRFInspInfo](#s215-vnt_xrfinspinfo)
122. [B786 — VVT_ESR_data](#b786-vvt_esr_data)
123. [B782 — VNT_LotTrackingInfo_vvt22](#b782-vnt_lottrackinginfo_vvt22)
124. [B882 — ANDONReport_V1](#b882-andonreport_v1)
125. [Z210 — UserType](#z210-usertype)
126. [Z220 — UserTypePermission](#z220-usertypepermission)
127. [Z330 — VendorMenuManagement](#z330-vendormenumanagement)
128. [Z410 — UserInfo](#z410-userinfo)
129. [Z530 — LabelInfo](#z530-labelinfo)

---
---

# BƯỚC 1: THIẾT LẬP HỆ THỐNG & CẤU HÌNH NỀN TẢNG QC

*Các cấu hình ban đầu, khai báo danh mục lỗi, nhóm hạng mục QC, thông tin model sản phẩm và thiết lập máy móc/nhân sự.*

---

## Z110 — BaseCode
| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z110` |
| **Screen Name** | `BaseCode` |
| **Parent Menu** | `CommonManagement` |
| **Title** | ?? ?? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Truy cập giao diện `BaseCode` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_BaseCode_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_BaseCode_iud`.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `BaseCode` | ?? ?? | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BaseCode_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BaseCode_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_BASECODE` | Lưu trữ các nhóm mã cơ sở và mã chi tiết hệ thống. |

---

## Z120 — SerialRule
| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z120` |
| **Screen Name** | `SerialRule` |
| **Parent Menu** | `CommonManagement` |
| **Title** | ???? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Truy cập giao diện `SerialRule` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_SerialRule_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_SerialRule_iud`.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `SerialRule` | ???? | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_SerialRule_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_SerialRule_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SERIALRULE` | Cấu hình quy tắc sinh số serial/barcode tự động. |

---

## C112 — AQLBasicRule
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C112` |
| **Screen Name** | `AQLBasicRule` |
| **Parent Menu** | `QM_BI_Statistics_MENU` |
| **Title** | AQL ???? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **AQLBasicRule** dùng để thực hiện nghiệp vụ: **AQL Basic Rules**.

**Workflow vận hành:**
1. Truy cập vào chức năng `AQLBasicRule` từ menu `KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_AqlBasicRule_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_AqlBasicRule_iud`.

**Lưu ý vận hành:**
- Cấu hình mẫu AQL


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `AqlBasicRule` | AqlBasicRule | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_AqlBasicRule_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_AqlBasicRule_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_AQLBASICRULE` | Quy định tiêu chuẩn lấy mẫu AQL cho công đoạn QC. |

---

## C121 — QcInspectionGroup

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C121` |
| **Screen Name** | `QcInspectionGroup` |
| **Parent Menu** | `QM_BI_IQC_MENU` |
| **Caption** | Quản lý nhóm/hạng mục QC |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 2 ExecuteFunction) |

### Nghiệp vụ

Màn hình cấu hình **nền tảng QC** — thiết lập danh mục nhóm kiểm tra (Inspection Group) và hạng mục kiểm tra (Inspection Item) cho toàn bộ quy trình QC.

**Workflow:**
1. Tạo **nhóm kiểm tra** (vd: "Kiểm tra ngoại quan", "Kiểm tra kích thước")
2. Trong mỗi nhóm, thêm các **hạng mục kiểm tra** (vd: "Chiều dài", "Chiều rộng")
3. Mỗi hạng mục có: loại dữ liệu (số/checkbox), đơn vị đo, giới hạn USL/LSL/UCL/LCL, AQL, Inspection Level
4. Data C121 → C122 reference → C220 tự động áp dụng khi tạo phiếu IQC

### Cấu Trúc UI

```
┌───────────────────────────────────────────────┐
│  QcInspectiongroupList (Grid trên)            │
│  ─ Danh sách nhóm kiểm tra QC                │
│  ─ Chọn 1 row → load grid dưới               │
├───────────────────────────────────────────────┤
│  QcInspectionItem (Grid dưới)                 │
│  ─ Các hạng mục trong nhóm đang chọn         │
│  ─ Inline edit: Thêm/Sửa/Xóa hạng mục       │
└───────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `QcInspectiongroupList` | QcInspectiongroupList | Grid hiển thị danh sách nhóm kiểm tra QC. Chọn 1 row → trigger load grid Item bên dưới. |
| 2 | `QcInspectionItem` | QcInspectionItem | Grid hiển thị danh sách hạng mục kiểm tra thuộc nhóm đang chọn. Hỗ trợ inline edit. |

### SearchFunctions (2)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_QcInspectionGroup_get` | Lấy danh sách nhóm kiểm tra QC | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pQcInspectionGroupCode` varchar(20) |
| 2 | `usp_QcInspectionItem_get` | Lấy danh sách hạng mục QC theo nhóm | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pQcInspectionGroupCode` varchar(20) |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_QcInspectionGroup_iud` | Thêm/Sửa/Xóa nhóm kiểm tra QC | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pProcessViewName` varchar(50), `@pXml` nvarchar(MAX) |
| 2 | `usp_QcInspectionItem_iud` | Thêm/Sửa/Xóa hạng mục QC | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pProcessViewName` varchar(50), `@pXml` nvarchar(MAX) |

### Actions/Buttons (0)

> Màn hình C121 **không có Action/Button riêng**. Thao tác CRUD được thực hiện trực tiếp trên grid (inline edit) thông qua các ExecuteFunction ở trên.

### Bảng DB Chính

| Bảng | Cột chính | Mô tả |
|---|---|---|
| `STB_QcInspectionGroup` | `QcInspectionGroupCode` (PK), `QcInspectionGroupName`, `QcInspectionGroupDesc`, `IsUsed` | Danh mục nhóm kiểm tra |
| `STB_QcInspectionItem` | `QcInspectionItemCode` (PK), `QcInspectionGroupCode` (FK), `QcInspectionItemName`, `InspectionType`, `SpecValue`, `USL`, `LSL`, `UCL`, `LCL`, `AQL`, `InspectionLevel` | Danh mục hạng mục kiểm tra thuộc nhóm |


## C122 — MaterialQcInspectionItemByMaterial

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C122` |
| **Screen Name** | `MaterialQcInspectionItemByMaterial` |
| **Parent Menu** | `QM_BI_IQC_MENU` |
| **Caption** | Tiêu chuẩn kiểm tra nguyên liệu |
| **Tổng Objects** | **9** (2 View + 1 SearchFunction + 1 ExecuteFunction + 5 Action) |

### Nghiệp vụ

Thiết lập **tiêu chuẩn kiểm tra cho từng mã nguyên liệu** — mapping mã NVL → bộ hạng mục QC cần kiểm.

**Workflow:**
1. Chọn **MaterialCode** từ popup (`usp_MaterialMaster_popup`)
2. Gán **hạng mục kiểm tra** từ C121 cho NVL đó (Import)
3. Thiết lập **AQL level**, **Inspection Level**, **số lượng mẫu**
4. Khi NVL nhập kho → C220 tự động tạo phiếu IQC dựa trên config tại C122

**Quan hệ:** C121 (định nghĩa hạng mục) → **C122 (gán cho NVL)** → C220 (kiểm tra thực tế)

### Cấu Trúc UI

```
┌───────────────────────────────────────────────┐
│  MaterialInformation (Grid header)            │
│  ─ Thông tin NVL đang chọn (readonly)         │
├───────────────────────────────────────────────┤
│  MaterialQcInspectionItem_ByMaterial (Grid)   │
│  ─ Danh sách hạng mục QC gán cho NVL         │
│  ─ Inline edit + 5 Action buttons             │
├───────────────────────────────────────────────┤
│  [Import Group/Item] [Import NVL khác]        │
│  [Set AQL] [Set Level] [Set InspType]         │
└───────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `MaterialInformation` | Material Information | Grid header hiển thị thông tin mã NVL đang xem (readonly). |
| 2 | `MaterialQcInspectionItem_ByMaterial` | MaterialQcInspectionItem_ByMaterial | Grid chính hiển thị danh sách hạng mục QC đã gán cho NVL. Hỗ trợ inline edit. |

### SearchFunctions (1)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_ByMaterial_get` | Lấy hạng mục QC đã gán cho NVL | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pMaterialCode` varchar(50) |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_iud` | Thêm/Sửa/Xóa hạng mục QC gán cho NVL | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pProcessViewName` varchar(50), `@pXml` nvarchar(MAX) |

### Actions/Buttons (5)

| # | ObjectName | Caption | Mô tả | SP/Logic |
|---|---|---|---|---|
| 1 | **`ImportFromInspectionItem`** | Import từ Group/Item | Mở popup cho phép import hàng loạt hạng mục QC từ một nhóm kiểm tra (Group) đã tạo ở C121 vào NVL đang chọn. | Đọc từ `STB_QcInspectionItem` → insert vào `STB_MaterialQcInspectionItem` |
| 2 | **`ImportFromMaterialInspectionItem`** | Import từ NVL khác | Mở popup chọn MaterialCode khác → copy toàn bộ cấu hình hạng mục QC từ NVL đó sang NVL hiện tại. | Copy rows từ `STB_MaterialQcInspectionItem` WHERE MaterialCode = @source → insert WHERE MaterialCode = @target |
| 3 | **`SetAql`** | AQL 설정 | Mở popup `usp_GetAql_popup` → chọn AQL level → apply cho các hạng mục đang chọn (multi-select). | `usp_GetAql_popup` → cập nhật cột `AQL` |
| 4 | **`SetLevel`** | Inspection Level 설정 | Mở popup `usp_GetInspectionLevel_popup` → chọn Inspection Level → apply cho các hạng mục đang chọn. | `usp_GetInspectionLevel_popup` → cập nhật cột `InspectionLevel` |
| 5 | **`SetInspectionType`** | Inspection Type 설정 | Mở popup `usp_GetInspectionType_Popup` → chọn Inspection Type → apply cho các hạng mục đang chọn. | `usp_GetInspectionType_Popup` → cập nhật cột `InspectionType` |

### Popup SPs Dùng Chung

| SP | Mô tả | Params chính |
|---|---|---|
| `usp_MaterialMaster_popup` | Popup chọn NVL từ Master | `@pMaterialCode`, `@pMaterialTypeCode`, `@pProductGroupCode`, `@pIsPurchase` |
| `usp_GetAql_popup` | Popup chọn AQL level | *(system params only)* |
| `usp_GetInspectionLevel_popup` | Popup chọn Inspection Level | *(system params only)* |
| `usp_GetInspectionType_Popup` | Popup chọn Inspection Type | *(system params only)* |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialQcInspectionItem` | Bảng chính: mapping MaterialCode → QcInspectionItemCode + AQL + InspectionLevel + SpecValue |
| `STB_QcInspectionItem` | Bảng ref: danh mục hạng mục QC (từ C121) |
| `STB_QcInspectionGroup` | Bảng ref: danh mục nhóm QC (từ C121) |
| `STB_MaterialMaster` | Bảng ref: danh mục nguyên vật liệu |


## C131 — DefectGroup
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C131` |
| **Screen Name** | `DefectGroup` |
| **Parent Menu** | `QM_BI_RouteInspection_MENU` |
| **Title** | ???????? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **DefectGroup** dùng để thực hiện nghiệp vụ: **Inspection Item Master**.

**Workflow vận hành:**
1. Truy cập vào chức năng `DefectGroup` từ menu `KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_DefectGroup_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DefectGroup_iud`.

**Lưu ý vận hành:**
- Thêm hạng mục → không hiển thị ở C143


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DefectGroupView` | ???????? | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DefectGroup_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DefectGroup_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DEFECTGROUP` | Danh mục nhóm lỗi phế phẩm sản xuất. |

---

## C132 — DefectInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C132` |
| **Screen Name** | `DefectInfo` |
| **Parent Menu** | `QM_BI_RouteInspection_MENU` |
| **Title** | ?????? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **DefectInfo** dùng để thực hiện nghiệp vụ: **Inspection Group Setup**.

**Workflow vận hành:**
1. Truy cập vào chức năng `DefectInfo` từ menu `KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_DefectInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DefectInfo_iud`.

**Lưu ý vận hành:**
- Nhóm QC không hiển thị ở C122/C143


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DefectInfoView` | DefectInfoView | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DefectInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DefectInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DEFECTINFO` | Chi tiết các mã lỗi phế phẩm của hệ thống. |
| `STB_DEFECTGROUP` | Danh mục nhóm lỗi phế phẩm sản xuất. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## C141 — CommInspTypeItemManagement
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C141` |
| **Screen Name** | `CommInspTypeItemManagement` |
| **Parent Menu** | `QM_BI_CommInspManagement_MENU` |
| **Title** | ?????????? |
| **Tổng Objects** | **5** (2 View + 2 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **CommInspTypeItemManagement** dùng để thực hiện nghiệp vụ: **Inspection Type Setup**.

**Workflow vận hành:**
1. Truy cập vào chức năng `CommInspTypeItemManagement` từ menu `KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_CommInspTypeInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DoCommInspTypeItem_iud`.

**Lưu ý vận hành:**
- Loại dữ liệu: 1=số, 2=checkbox


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CommInspTypeInfo` | ???????? | Grid hiển thị dữ liệu. |
| 2 | `CommInspItem` | ???????? | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_CommInspTypeInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_CommInspItem_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoCommInspTypeItem_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_COMMINSPTYPEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_COMMINSPITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_FACILITYROUTE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MOLDPRODUCTMACHINE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MOLDBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_COMMINSPSELECTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## C143 — CommInspIndividualSpec
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C143` |
| **Screen Name** | `CommInspIndividualSpec` |
| **Parent Menu** | `QM_BI_CommInspManagement_MENU` |
| **Title** | ?????????? |
| **Tổng Objects** | **7** (3 View + 3 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **CommInspIndividualSpec** dùng để thực hiện nghiệp vụ: **Inspection Item Config**.

**Workflow vận hành:**
1. Truy cập vào chức năng `CommInspIndividualSpec` từ menu `KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_CommInspTypeInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_CommInspIndividualSpec_iud`.

**Lưu ý vận hành:**
- Mã NVL → đúng hạng mục


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CommInspTypeInfo` | ???????? | Grid hiển thị dữ liệu. |
| 2 | `GetCommInspItemForIndividualSpec` | ???????? | Grid hiển thị dữ liệu. |
| 3 | `CommInspIndividualSpec` | ?????????? | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_CommInspTypeInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_GetCommInspItemForIndividualSpec` | Lấy danh sách dữ liệu. |
| 3 | `usp_CommInspIndividualSpec_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_CommInspIndividualSpec_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_COMMINSPTYPEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_COMMINSPITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MOLDPRODUCTMACHINE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MOLDBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_COMMINSPSELECTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_COMMINSPINDIVIDUALSPEC` | Cấu hình tiêu chuẩn kiểm tra riêng cho từng sản phẩm. |

---

## C151 — MaterialQcInspectionItemByFERT
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C151` |
| **Screen Name** | `MaterialQcInspectionItemByFERT` |
| **Parent Menu** | `QM_BI_OQC_MENU` |
| **Title** | ??????? |
| **Tổng Objects** | **9** (2 View + 1 SearchFunction + 1 ExecuteFunction + 5 Action) |

### Workflow

Giao diện **MaterialQcInspectionItemByFERT** dùng để thực hiện nghiệp vụ: **Material QC Detail**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialQcInspectionItemByFERT` từ menu `KB_05`.

**Lưu ý vận hành:**
- Sau A410 → tắt C151 rồi mở lại


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialInformation` | Material Information | Grid hiển thị dữ liệu. |
| 2 | `MaterialQcInspectionItem_ByMaterial` | MaterialQcInspectionItem_ByMaterial | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_ByMaterial_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (5)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ImportFromInspectionItem`** | Import From Inspection Item | Thực hiện tác vụ import from inspection item cho dữ liệu trên màn hình. |
| 2 | **`ImportFromMaterialInspectionItem`** | Import From Material Inspection Item | Thực hiện tác vụ import from material inspection item cho dữ liệu trên màn hình. |
| 3 | **`SetAql`** | Set Aql | Thực hiện tác vụ set aql cho dữ liệu trên màn hình. |
| 4 | **`SetLevel`** | Set Level | Thực hiện tác vụ set level cho dữ liệu trên màn hình. |
| 5 | **`SetInspectionType`** | Set Inspection Type | Thực hiện tác vụ set inspection type cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALQCINSPECTIONITEMBYFERT` | Quy định hạng mục kiểm tra QC cho thành phẩm. |

---

## A230 — MaterialMaster
| Thông tin | Giá trị |
|---|---|
| **TCode** | `A230` |
| **Screen Name** | `MaterialMaster` |
| **Parent Menu** | `BI_MaterialInformation_MENU` |
| **Title** | ???? |
| **Tổng Objects** | **7** (3 View + 3 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **MaterialMaster** dùng để thực hiện nghiệp vụ: **Danh mục vật tư (MaterialMaster)**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialMaster` từ menu `KB_05, KB_06`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MaterialMaster_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MaterialVendor_get`.

**Lưu ý vận hành:**
- Kiểm tra `MaterialTypeCode` khi model không hiển thị Vol/Farad. Tab "Mã nguyên liệu" link độ dày → B442


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialMaster` | MaterialMaster | Grid hiển thị dữ liệu. |
| 2 | `MaterialRevision` | MaterialRevision | Grid hiển thị dữ liệu. |
| 3 | `MaterialVendor` | MaterialVendor | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialMaster_get` | ?????? ?????. |
| 2 | `usp_MaterialRevision_get` | ? ??? ??? ?? ?? ?? |
| 3 | `usp_MaterialVendor_get` | ??? ??? - ??? ?? ?? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialMaster_iud` | ????? IUD |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_BASICROUTINGINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALREVISION` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALVENDOR` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALSTOCKATTRIBUTEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ALTMATERIALMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Model mới không hiện Vol/Farad trên chuyền | Chưa khai báo A230 hoặc thiếu cấu hình Vol/Farad | Vào A230 → tab Thông số kỹ thuật → nhập Vol, Farad, kích thước. SQL: `SELECT ModelCode, Voltage, Farad FROM STB_ModelBasicInfo WHERE ModelCode = 'mã'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Cột "Độ dày" bị trống trên B442 (Kế hoạch Electrode) | Chưa set MaterialThickness tại A230 tab "Mã nguyên liệu" | `UPDATE STB_MaterialMaster SET MaterialThickness = '120' WHERE MaterialCode = 'mã_nvl'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## A310 — BomInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `A310` |
| **Screen Name** | `BomInfo` |
| **Parent Menu** | `BI_Bom_MENU` |
| **Title** | ??BOM?? |
| **Tổng Objects** | **15** (5 View + 5 SearchFunction + 3 ExecuteFunction + 2 Action) |

### Workflow

Giao diện **BomInfo** dùng để thực hiện nghiệp vụ: **Cấu hình BOM**.

**Workflow vận hành:**
1. Truy cập vào chức năng `BomInfo` từ menu `KB_06, KB_12`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_BomHeader_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_BomHeader_iud`.

**Lưu ý vận hành:**
- Anh Huy phụ trách. Không tính version BOM


### Views (5)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `BomMaterialMasterList` | ???? | Grid hiển thị dữ liệu. |
| 2 | `BomMaterialMasterSubList` | ???? | Grid hiển thị dữ liệu. |
| 3 | `BomHeaderList` | BOM?? | Grid hiển thị dữ liệu. |
| 4 | `BomDetailList` | BOM???? | Grid hiển thị dữ liệu. |
| 5 | `BomFacilityRoute` | BomFacilityRoute | Grid hiển thị dữ liệu. |

### SearchFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetBOMMaterialMaster` | Lấy danh sách dữ liệu. |
| 2 | `usp_BomHeader_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_BomDetail_get` | Lấy danh sách dữ liệu. |
| 4 | `usp_GetBOMMaterialMasterSub` | Lấy danh sách dữ liệu. |
| 5 | `usp_BomFacilityRoute_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BomHeader_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_BomDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_BomFacilityRoute_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Research`** | Research | Thực hiện tác vụ research cho dữ liệu trên màn hình. |
| 2 | **`MoveMaterial`** | Move Material | Thực hiện tác vụ move material cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_BOMHEADER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_BASICROUTINGINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_BOMDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | OP không thấy công đoạn mới trong danh sách Route | Chưa tạo Route tại A310 hoặc chưa map vào PO | Vào A310 → Thêm RouteCode → Map vào B210 (Line) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## A410 — ModelBasicInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `A410` |
| **Screen Name** | `ModelBasicInfo` |
| **Parent Menu** | `BI_ModelInformation_MENU` |
| **Title** | ???? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **ModelBasicInfo** dùng để thực hiện nghiệp vụ: **Thông số Model (ModelBasicInfo)**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ModelBasicInfo` từ menu `KB_06, KB_05, KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_ModelBasicInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_ModelBasicInfo_iud`.

**Lưu ý vận hành:**
- **Hay bị thiếu khi thêm model mới.** Thiết lập OqcType, InspectionType, Size H/W, Vol/Farad


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ModelBasicInfo` | ModelBasicInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModelBasicInfo_get` | Model Basic Info |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModelBasicInfo_iud` | ???? IUD |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_OQCLOTCREATERULE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | C512 không tìm thấy Lot OQC | Chưa config OqcType, InspectionLevel tại A410 | `UPDATE STB_ModelBasicInfo SET OqcType='MANUAL', OqcInspectionRuleType='BY_MODEL', InspectionType='SAMPLE', InspectionLevel='SAMPLE' WHERE ModelCode = 'mã'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## A418 — PackingQtyPerSize
| Thông tin | Giá trị |
|---|---|
| **TCode** | `A418` |
| **Screen Name** | `PackingQtyPerSize` |
| **Parent Menu** | `BI_ModelInformation_MENU` |
| **Title** | Set Packing Qty theo Size |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Khai báo số lượng đóng gói tiêu chuẩn (Box/Carton) cho từng kích thước (Size) của sản phẩm.
2. Tìm kiếm thông số đóng gói hiện có theo kích thước (`pProdSize`).
3. Thêm mới, cấu hình hoặc sửa đổi quy định số lượng đóng gói nhằm chuẩn hóa dữ liệu in tem nhãn đóng gói.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `PackingQtyPerSize` | PackingQtyPerSize | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_PackingQtyPerSize_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_PackingQtyPerSize_uid` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PackingQtyPerSize` | Lưu trữ thông số định mức số lượng đóng gói chuẩn theo kích thước sản phẩm. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | B523 không cho gộp Box, báo chưa có tiêu chuẩn đóng gói | Chưa khai báo A418 cho Size mới | Vào A418 → Thêm Size + PackingQty. SQL: `INSERT INTO STB_PackingQtyPerSize (SizeCode, PackingQty, ...) VALUES (...)` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## A419 — PackingQtyWarehouse
| Thông tin | Giá trị |
|---|---|
| **TCode** | `A419` |
| **Screen Name** | `PackingQtyWarehouse` |
| **Parent Menu** | `BI_ModelInformation_MENU` |
| **Title** | PackingQtyWarehouse |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **PackingQtyWarehouse** dùng để thực hiện nghiệp vụ: **Cấu hình số lượng đóng gói**.

**Workflow vận hành:**
1. Truy cập vào chức năng `PackingQtyWarehouse` từ menu `KB_04, KB_06`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_Vietnam_PackingQtyWarehouse_A419_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_Vietnam_PackingQtyWarehouse_A419_iud`.

**Lưu ý vận hành:**
- Thêm khi báo lỗi "chưa có tiêu chuẩn đóng gói" ở B523


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Vietnam_PackingQtyWarehouse_A419` | Vietnam_PackingQtyWarehouse_A419 | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_PackingQtyWarehouse_A419_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_PackingQtyWarehouse_A419_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PACKINGQTYWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## A460 — ModelLabelInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `A460` |
| **Screen Name** | `ModelLabelInfo` |
| **Parent Menu** | `BI_ModelInformation_MENU` |
| **Title** | ??? ???? |
| **Tổng Objects** | **7** (2 View + 2 SearchFunction + 3 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **ModelLabelInfo** dùng để thực hiện nghiệp vụ: **Cấu hình In Tem**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ModelLabelInfo` từ menu `KB_04, KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MaterialMaster_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_ModelLabelInfo_iud`.

**Lưu ý vận hành:**
- B450 lỗi không in → check `AssembleLabel`. B442 lỗi `Not found label type` → check `STB_ModelLabelInfo`


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialMaster` | MaterialMaster | Grid hiển thị dữ liệu. |
| 2 | `GetLabelInfoByMaterial` | GetLabelInfoByMaterial | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialMaster_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_GetLabelInfoByMaterial` | ??? ?? ???? ????? |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoMakeModelLabelInfo` | ??????? ?????. |
| 2 | `usp_ModelLabelInfo_iud` | ??????? ?????. |
| 3 | `usp_DoSaveModelLabelInfoSpec` | ??????? ?????. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_BASICROUTINGINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LABELTYPEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | In tem bị lỗi "Not found label type" | Chưa có record trong `STB_ModelLabelInfo` cho model | Copy từ model cũ cùng loại: `INSERT INTO STB_ModelLabelInfo SELECT 'MODEL_MỚI', LabelType, ... FROM STB_ModelLabelInfo WHERE ModelCode = 'MODEL_CŨ'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B210 — LineInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B210` |
| **Screen Name** | `LineInfo` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | ???? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Khai báo danh mục dây chuyền (Line) sản xuất trong nhà máy, liên kết với Work Center và Company.
2. Cấu hình các thuộc tính của chuyền như: loại chuyền (`LineType`), mã giám sát (`MonitoringGroup`), dây chuyền con (`ChildLines`), và mã kho nguyên vật liệu tương ứng (`MaterialWarehouseCode`).

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `LineInfo` | ???? | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LineInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LineInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_LineInfo` | Lưu trữ thông tin chi tiết và thuộc tính cấu hình của dây chuyền sản xuất. |
| `STB_WorkCenterInfo` | Bảng tham chiếu nhóm trung tâm làm việc (Work Center). |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | B270 popup không hiện dữ liệu | Popup bị cache session cũ | Tắt MES → xóa cache → mở lại. Hoặc kiểm tra `STB_ScreenObjects` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Line mới không hiện trên B460 | Chưa map Line→WorkCenter tại B210 | Vào B210 → Thêm mapping | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 3 | Machine mới scan không được | Chưa khai báo tại B240 | Vào B240 → Thêm MachineCode | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B220 — RouteInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B220` |
| **Screen Name** | `RouteInfo` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | ???? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Định nghĩa các quy trình công đoạn công nghệ (Route) trong nhà máy MES.
2. Thiết lập mã công đoạn (`RouteCode`), tên công đoạn (`RouteName`), trung tâm làm việc (`WorkCenterCode`), loại công đoạn (`RouteType`) và thời gian chuẩn (`StandardTaktTime`).

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `RouteInfo_view` | ???? | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_RouteInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_RouteInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_RouteInfo` | Lưu trữ thông tin và cấu hình các công đoạn sản xuất của nhà máy. |

---

## B230 — LineRouteMapping
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B230` |
| **Screen Name** | `LineRouteMapping` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | ???????? |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

Giao diện **LineRouteMapping** dùng để thực hiện nghiệp vụ: **Thay thế B270**.

**Workflow vận hành:**
1. Truy cập vào chức năng `LineRouteMapping` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_LineInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_LineRouteMapping_iud`.

**Lưu ý vận hành:**
- Dùng thay B270 khi B270 bị lỗi popup


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `LineInfo` | LineInfo | Grid hiển thị dữ liệu. |
| 2 | `LineRouteMapping` | LineRouteMapping | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LineInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_LineRouteMapping_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LineRouteMapping_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`UseAll`** | Use All | Thực hiện tác vụ use all cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_LINEROUTEMAPPING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOCATION` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## B240 — BasicRoutingInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B240` |
| **Screen Name** | `BasicRoutingInfo` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | ????? |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 2 ExecuteFunction + 0 Action) |

### Workflow

1. Thiết lập luồng công nghệ chuẩn (Routing) cho từng sản phẩm bằng cách xâu chuỗi các mã công đoạn lại với nhau.
2. Cấu hình thứ tự công đoạn, chỉ định công đoạn bắt đầu và công đoạn kết thúc để kiểm soát đường đi sản xuất của Lot.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `BasicRoutingInfo` | BasicRoutingInfo | Grid hiển thị dữ liệu. |
| 2 | `BasicRouteingDetailForRoute` | BasicRouteingDetailForRoute | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BasicRoutingInfo_get` | BOM Detail ?? ???? |
| 2 | `usp_GetBasicRouteingDetailForRoute` | BOM Detail ?? ???? |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BasicRoutingInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_BasicRoutingDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_BasicRoutingInfo` | Lưu thông tin đầu mục của quy trình công nghệ sản phẩm. |
| `STB_BasicRoutingDetail` | Lưu trữ chi tiết trình tự các bước công đoạn và điều kiện chuyển đổi trong Routing. |

---

## B250 — MachineMaster
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B250` |
| **Screen Name** | `MachineMaster` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | ???? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **MachineMaster** dùng để thực hiện nghiệp vụ: **Thông tin máy**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MachineMaster` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MachineMaster_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MachineMaster_iud`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MachineMaster` | MachineMaster | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MachineMaster_get` | ???? ?? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MachineMaster_iud` | ???? IUD |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_VN_DEVICEMACHINES` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MOLDPRODUCTMACHINE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTMACHINE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## B260 — ProdWorkerInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B260` |
| **Screen Name** | `ProdWorkerInfo` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | ProdWorkerInfo |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **ProdWorkerInfo** dùng để thực hiện nghiệp vụ: **Thêm công nhân**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ProdWorkerInfo` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_ProdWorkerInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_ProdWorkerInfo_iud`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdWorkerInfo` | ProdWorkerInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProdWorkerInfo_get` | ?? ???? ????? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProdWorkerInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |

---

## B270 — ProductMachine
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B270` |
| **Screen Name** | `ProductMachine` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | ?????? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **ProductMachine** dùng để thực hiện nghiệp vụ: **Ánh xạ máy-công đoạn**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ProductMachine` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_ProductMachine_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_ProductMachine_iud`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProductMachine` | ProductMachine | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProductMachine_get` | ????? ????? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProductMachine_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PRODUCTMACHINE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |

---

---

# BƯỚC 2: NHẬP KHO NGUYÊN VẬT LIỆU & XÁC NHẬN IQC ĐẦU VÀO

*Tiếp nhận nguyên vật liệu từ PO mua hàng, in nhãn Lot NVL đầu vào và thực hiện kiểm tra chất lượng IQC.*

---

## F330 — MaterialReceiptAndPrintLabel
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F330` |
| **Screen Name** | `MaterialReceiptAndPrintLabel` |
| **Parent Menu** | `MaterialGR_MENU` |
| **Title** | ???? ? ???? |
| **Tổng Objects** | **48** (3 View + 3 SearchFunction + 18 ExecuteFunction + 24 Action) |

### Workflow

Giao diện **MaterialReceiptAndPrintLabel** dùng để thực hiện nghiệp vụ: **Nhập vật tư từ PO**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialReceiptAndPrintLabel` từ menu `KB_02, KB_05, KB_06, KB_10, KB_31, KB_32`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MaterialDocInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MaterialDocInfo_get`.

**Lưu ý vận hành:**
- **Sửa kho sai → update 3 bảng.** Màn hình nhiều bug nhất


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocInfo` | MaterialDocInfo | Grid hiển thị dữ liệu. |
| 2 | `MaterialDocDetail` | MaterialDocDetail | Grid hiển thị dữ liệu. |
| 3 | `MaterialDocLotInfo` | MaterialDocLotInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialDocInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialDocDetail_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_MaterialDocLotInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (18)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoArriveMaterialDelivery` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoFixMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_DoMaterialDocMasterDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoCancelMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_DoCancelFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoCreateLabel` | Thêm/Sửa/Xóa dữ liệu. |
| 8 | `usp_MaterialDocLotInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 9 | `usp_DoChangeMaterialDocLotInfo` | Thêm/Sửa/Xóa dữ liệu. |
| 10 | `usp_DoDeleteMaterialDocLotInfo` | Thêm/Sửa/Xóa dữ liệu. |
| 11 | `usp_MaterialDocInfo_iud` | ???????? |
| 12 | `usp_MaterialDocDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 13 | `usp_GetOrderMaterialMaster_popup` | ???????(????) ??? |
| 14 | `usp_DoCreateLabelManual` | ??? ????? ?????. |
| 15 | `usp_DoUpdateTradeDate_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 16 | `usp_AddDate` | Thêm/Sửa/Xóa dữ liệu. |
| 17 | `usp_AddStartDate` | ??? Split ???. |
| 18 | `usp_UpdateLevelJIANGHAI` | C?p nh?t l?i gi� tr? c?p c?a h�ng JIANGHAI |

### Actions/Buttons (24)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`CancelDoc`** | Hủy phiếu | Hủy phiếu chứng từ nhập/xuất đang chọn. |
| 3 | **`DoFix`** | Xác nhận (Fix) | Xác nhận/Chốt phiếu chứng từ, khóa dữ liệu không cho sửa đổi. |
| 4 | **`CancelFinish`** | Hủy hoàn thành | Hủy trạng thái hoàn thành (Finish) của phiếu để cho phép chỉnh sửa. |
| 5 | **`DoFInish`** | F Inish | Thực hiện tác vụ f inish cho dữ liệu trên màn hình. |
| 6 | **`DoGR`** | Nhập kho (GR) | Xác nhận nhập kho thực tế (Goods Receipt) cho các Lot hàng. |
| 7 | **`MakeLabel`** | Sinh tem NVL | Tự động tạo mã Lot ID và in nhãn dán cho vật tư nhập kho thực tế. |
| 8 | **`RefreshDetail`** | Làm mới chi tiết | Làm mới danh sách chi tiết của phiếu. |
| 9 | **`DeleteDocLotInfo`** | Xóa Lot | Xóa Lot vật tư được chọn ra khỏi phiếu nhập kho. |
| 10 | **`PrintLabelSelected`** | LabelPrint | Thực hiện in tem nhãn hàng loạt cho các dòng được chọn. |
| 11 | **`RefreshDocLot`** | Làm mới Lot phiếu | Làm mới danh sách Lot liên kết với phiếu chứng từ. |
| 12 | **`ChangeLotNo`** | Đổi số Lot | Thay đổi hoặc điều chỉnh mã số Lot nhãn vật tư. |
| 13 | **`ScanBarcode`** | Quét Barcode | Quét mã vạch của vật tư để đối chiếu thông tin phiếu giao nhận. |
| 14 | **`InputLabelQty`** | LabelPrint | Nhập số lượng tem nhãn cần in cho Lot. |
| 15 | **`MakeLabelManual`** | Sinh tem thủ công | Tạo mã Lot ID và in nhãn dán cho vật tư bằng tay (nhập thông số thủ công). |
| 16 | **`LabelInfoManualInsert`** | Nhập tem tay | Ghi nhận thông tin tem nhãn bằng cách nhập liệu thủ công. |
| 17 | **`LotNoManualInput`** | Nhập Lot tay | Cho phép nhập trực tiếp mã Lot bằng bàn phím. |
| 18 | **`Pass_Print`** | In tem đạt | In tem chất lượng đạt (PASS) cho Lot sau khi có kết quả IQC. |
| 19 | **`TradeDate`** | Ngày giao dịch | Cập nhật ngày giao dịch nhập kho thực tế. |
| 20 | **`Inbigtem`** | In tem to | In tem nhãn khổ lớn dán trên thùng phuy hoặc pallet nguyên vật liệu. |
| 21 | **`AddDate`** | Thêm ngày | Điều chỉnh ngày nhập kho. |
| 22 | **`AddProDate`** | Thêm ngày SX | Thêm hoặc chỉnh sửa ngày sản xuất của nhà cung cấp. |
| 23 | **`LuuCapJIANGHAI`** | Lưu cấp Jianghai | Lưu thông tin phân cấp chất lượng hoặc revision đặc thù cho hàng Jianghai. |
| 24 | **`BG2_ViewCell`** | Xem Cell BG2 | Xem thông tin chi tiết các Cell sản phẩm tại phân hệ BG2. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALSTOCK` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALSTOCKATTRIBUTEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALQCSAMPLERESULT` | Kết quả đo lường chi tiết các mẫu thử QC. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODPLANBOM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_BOMDETAIL_REVISION` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALVENDORMAPPING` | Ánh xạ mã vật tư nội bộ với mã nhà cung cấp. |
| `STB_LINEROUTEMAPPING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCPICKINGPLAN` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PROCEDURELOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOTSNAPSHOT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCDETAIL` | Chi tiết các hạng mục kiểm định của phiếu QC. |
| `STB_GLOBALPROCESSRULE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO_DEV` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALBARCODEHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALLOTINFO_TEST` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCLOTINFO_TEST1` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Bị chặn "Receiving Confirmation" | IQC chưa PASS tại C220 | QC hoàn thành IQC PASS trước | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | NVL không tìm thấy trong popup chọn | Chưa khai báo NVL tại A230 | Vào A230 thêm MaterialCode | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 3 | Đổi mã vật tư tự động lỗi | `STB_ChangeMaterialCode_HN` thiếu mapping | INSERT mapping mã cũ→mới — xem [KB_02 §3.1](KB_02/KB_02_01_NVL_WMS.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## F312 — Vietnam_MaterialGrFromOrder
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F312` |
| **Screen Name** | `Vietnam_MaterialGrFromOrder` |
| **Parent Menu** | `v_RawMaterial` |
| **Title** | Vietnam_MaterialGrFromOrder |
| **Tổng Objects** | **12** (2 View + 2 SearchFunction + 2 ExecuteFunction + 6 Action) |

### Workflow

Giao diện **Vietnam_MaterialGrFromOrder** dùng để thực hiện nghiệp vụ: **Nhập kho NVL (sửa SL)**.

**Workflow vận hành:**
1. Truy cập vào chức năng `Vietnam_MaterialGrFromOrder` từ menu `KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MaterialDocInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MaterialDocInfo_get`.

**Lưu ý vận hành:**
- MaterialDocNo


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocInfo` | MaterialDocInfo | Grid hiển thị dữ liệu. |
| 2 | `MaterialDocDetail` | MaterialDocDetail | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialDocInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialDocDetail_Vietnam_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoMaterialDocMasterDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoFixMaterialDocList` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (6)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`MaterialGrOrder`** | Material Gr Order | Thực hiện tác vụ material gr order cho dữ liệu trên màn hình. |
| 2 | **`FixDelivery`** | Fix Delivery | Thực hiện tác vụ fix delivery cho dữ liệu trên màn hình. |
| 3 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 4 | **`SalesOrderItemSelect`** | Sales Order Item Select | Thực hiện tác vụ sales order item select cho dữ liệu trên màn hình. |
| 5 | **`InterfaceErp_SA`** | Interface Erp_ S A | Thực hiện tác vụ interface erp_ s a cho dữ liệu trên màn hình. |
| 6 | **`SelectOrder`** | Select Order | Thực hiện tác vụ select order cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALSTOCK` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALSTOCKATTRIBUTEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |

---

## F320 — MaterialReceipt
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F320` |
| **Screen Name** | `MaterialReceipt` |
| **Parent Menu** | `MaterialGR_MENU` |
| **Title** | ???? |
| **Tổng Objects** | **16** (2 View + 2 SearchFunction + 6 ExecuteFunction + 6 Action) |

### Workflow

Giao diện **MaterialReceipt** dùng để thực hiện nghiệp vụ: **—**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialReceipt` từ menu `KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MaterialDocInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MaterialDocInfo_get`.

**Lưu ý vận hành:**
- —


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocInfo` | MaterialDocInfo | Grid hiển thị dữ liệu. |
| 2 | `MaterialDocDetail` | MaterialDocDetail | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialDocInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialDocDetail_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (6)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoArriveMaterialDelivery` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoFixMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_DoMaterialDocMasterDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoCancelMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_DoCancelFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (6)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`CancelDoc`** | Hủy phiếu | Hủy phiếu chứng từ nhập/xuất đang chọn. |
| 3 | **`CancelFinish`** | Hủy hoàn thành | Hủy trạng thái hoàn thành (Finish) của phiếu để cho phép chỉnh sửa. |
| 4 | **`DoFix`** | Xác nhận (Fix) | Xác nhận/Chốt phiếu chứng từ, khóa dữ liệu không cho sửa đổi. |
| 5 | **`DoFInish`** | F Inish | Thực hiện tác vụ f inish cho dữ liệu trên màn hình. |
| 6 | **`DoGR`** | Nhập kho (GR) | Xác nhận nhập kho thực tế (Goods Receipt) cho các Lot hàng. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALSTOCK` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALSTOCKATTRIBUTEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LINEROUTEMAPPING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCPICKINGPLAN` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PROCEDURELOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALLOTSNAPSHOT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCDETAIL` | Chi tiết các hạng mục kiểm định của phiếu QC. |

---

## F610 — MaterialReturnOrder
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F610` |
| **Screen Name** | `MaterialReturnOrder` |
| **Parent Menu** | `MaterialReturn_MENU` |
| **Title** | ?????? |
| **Tổng Objects** | **7** (2 View + 2 SearchFunction + 2 ExecuteFunction + 1 Action) |

### Workflow

Giao diện **MaterialReturnOrder** dùng để thực hiện nghiệp vụ: **Stocktaking**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialReturnOrder` từ menu `KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MaterialDocInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MaterialDocInfo_get`.

**Lưu ý vận hành:**
- —


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocInfo` | MaterialDocInfo | Grid hiển thị dữ liệu. |
| 2 | `MaterialDocDetail` | MaterialDocDetail | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialDocInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialDocDetail_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoMaterialDocMasterDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoFixMaterialDocList` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALSTOCK` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALSTOCKATTRIBUTEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |

---

## F620 — MaterialReturnAndPrintLabel
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F620` |
| **Screen Name** | `MaterialReturnAndPrintLabel` |
| **Parent Menu** | `MaterialReturn_MENU` |
| **Title** | ???? ? ???? |
| **Tổng Objects** | **37** (3 View + 3 SearchFunction + 15 ExecuteFunction + 16 Action) |

### Workflow

Giao diện **MaterialReturnAndPrintLabel** dùng để thực hiện nghiệp vụ: **Stocktaking Result**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialReturnAndPrintLabel` từ menu `KB_02`.

**Lưu ý vận hành:**
- —


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocInfo` | MaterialDocInfo | Grid hiển thị dữ liệu. |
| 2 | `MaterialDocDetail` | MaterialDocDetail | Grid hiển thị dữ liệu. |
| 3 | `MaterialDocLotInfo` | MaterialDocLotInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialDocInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialDocDetail_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_MaterialDocLotInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (15)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoArriveMaterialDelivery` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoFixMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_DoMaterialDocMasterDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoCancelMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_DoCancelFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoCreateLabel` | Thêm/Sửa/Xóa dữ liệu. |
| 8 | `usp_MaterialDocLotInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 9 | `usp_DoChangeMaterialDocLotInfo` | Thêm/Sửa/Xóa dữ liệu. |
| 10 | `usp_DoDeleteMaterialDocLotInfo` | Thêm/Sửa/Xóa dữ liệu. |
| 11 | `usp_MaterialDocInfo_iud` | ???????? |
| 12 | `usp_MaterialDocDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 13 | `usp_DoCreateVVTLabel` | Thêm/Sửa/Xóa dữ liệu. |
| 14 | `usp_addDate_F620` | Thêm/Sửa/Xóa dữ liệu. |
| 15 | `usp_AddDate` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (16)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`CancelDoc`** | Hủy phiếu | Hủy phiếu chứng từ nhập/xuất đang chọn. |
| 3 | **`DoFix`** | Xác nhận (Fix) | Xác nhận/Chốt phiếu chứng từ, khóa dữ liệu không cho sửa đổi. |
| 4 | **`CancelFinish`** | Hủy hoàn thành | Hủy trạng thái hoàn thành (Finish) của phiếu để cho phép chỉnh sửa. |
| 5 | **`DoFInish`** | F Inish | Thực hiện tác vụ f inish cho dữ liệu trên màn hình. |
| 6 | **`DoGR`** | Nhập kho (GR) | Xác nhận nhập kho thực tế (Goods Receipt) cho các Lot hàng. |
| 7 | **`MakeLabel`** | Sinh tem NVL | Tự động tạo mã Lot ID và in nhãn dán cho vật tư nhập kho thực tế. |
| 8 | **`RefreshDetail`** | Làm mới chi tiết | Làm mới danh sách chi tiết của phiếu. |
| 9 | **`DeleteDocLotInfo`** | Xóa Lot | Xóa Lot vật tư được chọn ra khỏi phiếu nhập kho. |
| 10 | **`PrintLabelSelected`** | In tem chọn | Thực hiện in tem nhãn hàng loạt cho các dòng được chọn. |
| 11 | **`RefreshDocLot`** | Làm mới Lot phiếu | Làm mới danh sách Lot liên kết với phiếu chứng từ. |
| 12 | **`ChangeLotNo`** | Đổi số Lot | Thay đổi hoặc điều chỉnh mã số Lot nhãn vật tư. |
| 13 | **`ScanBarcode`** | Quét Barcode | Quét mã vạch của vật tư để đối chiếu thông tin phiếu giao nhận. |
| 14 | **`InTemThuCong`** | In Tem Thu Cong | Thực hiện tác vụ in tem thu cong cho dữ liệu trên màn hình. |
| 15 | **`InputLabelQty`** | LabelPrint | Nhập số lượng tem nhãn cần in cho Lot. |
| 16 | **`AddDate`** | Thêm ngày | Điều chỉnh ngày nhập kho. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALRETURNANDPRINTLABEL` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## F130 — MaterialMappingByCustomer
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F130` |
| **Screen Name** | `MaterialMappingByCustomer` |
| **Parent Menu** | `MM_BasicInformation_MENU` |
| **Title** | ??????? |
| **Tổng Objects** | **5** (2 View + 2 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Thiết lập ánh xạ (Mapping) mã nguyên vật liệu nội bộ với mã vật tư của khách hàng/nhà cung cấp.
2. Giúp đồng bộ và tự động hiển thị thông tin nhãn mác vật tư chính xác khi thực hiện xuất hàng cho từng khách hàng cụ thể (`STB_CustomerInfo`).

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VendorCustomerInfoView` | ?????????? | Grid hiển thị dữ liệu. |
| 2 | `MaterialMappingByCustomerDetailView` | ?????????? | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetMaterialMappingByCustomer` | Lấy danh sách dữ liệu. |
| 2 | `usp_GetVendorCustomerInfo` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialVendorMapping_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialVendorMapping` | Lưu thông tin cấu hình ánh xạ mã vật tư nội bộ và đối tác. |
| `STB_CustomerInfo` | Danh mục thông tin khách hàng/nhà cung cấp. |

---

## C220 — MaterialIqcInfoSampleManagement

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C220` |
| **Screen Name** | `MaterialIqcInfoSampleManagement` |
| **Parent Menu** | `IQC_Inspection` |
| **Caption** | IQC 검사 확인 (IQC Confirmation) |
| **Tổng Objects** | **51** (5 View + 5 SearchFunction + 17 ExecuteFunction + 24 Action) |

### Nghiệp vụ

Màn hình **kiểm tra chất lượng đầu vào (IQC)** — khi nguyên liệu nhập kho qua F330, QC kiểm tra chất lượng trước khi cho phép sử dụng.

**Workflow:**
1. NVL nhập kho (F330) → hệ thống tự tạo **phiếu IQC** (`STB_MaterialQcInfo`)
2. QC chọn phiếu → **Make Detail** → tạo danh sách hạng mục kiểm tra từ C122
3. **Make Sample** → tạo các mẫu để đo
4. QC nhập **kết quả đo** cho từng mẫu, từng hạng mục
5. Quyết định: **Pass** hoặc **Fail**
6. Fail → tạo **Defect Report** → gửi email
7. Có thể **Change to Pass** sau khi Fail nếu được phê duyệt

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  Tab 1: MaterialQcInfoSampleList (Grid chính)                │
│  ─ Filter: FromDate, ToDate, MaterialCode, DecisionResult    │
│  ─ Mỗi row = 1 phiếu IQC                                    │
│  ─ Toolbar: [AllRefresh] [MakeDetail] [Pass] [Fail]          │
│             [ChangeToPass] [SearchLotNo] [ChangeIQCNo]       │
│             [Confirm] [Cancel] [SendEmail] [PrintLabel]      │
│             [SaveRevisionVer] [ImportItem] [ImagePopup]      │
├──────────────────────────────────────────────────────────────┤
│  Tab 2: MaterialQcDetailSampleList (Grid chi tiết)           │
│  ─ Các hạng mục cần đo cho phiếu IQC đang chọn              │
│  ─ [SetAllPass] [SetAllPassByItem]                           │
├──────────────────────────────────────────────────────────────┤
│  Tab 3: MaterialSampleResult (Grid kết quả mẫu)             │
│  ─ Kết quả đo từng mẫu cho hạng mục đang chọn               │
│  ─ [MakeSampleResult] [RefreshSampleList]                    │
├──────────────────────────────────────────────────────────────┤
│  Tab 4: QcDefectIQCEnrollment (Grid đăng ký lỗi)            │
│  ─ Thêm/sửa báo cáo lỗi IQC (Defect Report)                │
│  ─ [SaveDefectDetail]                                        │
├──────────────────────────────────────────────────────────────┤
│  Tab 5: NonconformingReport (NCR View)                       │
│  ─ Non-Conformance Report                                    │
└──────────────────────────────────────────────────────────────┘
```

### Views (5)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `MaterialQcInfoSampleList` | IQC Sample List | Grid chính — danh sách phiếu IQC. Filter theo ngày, mã NVL, kết quả. |
| 2 | `MaterialQcDetailSampleList` | Detail Sample | Grid chi tiết — các hạng mục kiểm tra cho phiếu IQC đang chọn. |
| 3 | `MaterialSampleResult` | Sample Result | Grid kết quả đo — từng mẫu cho hạng mục đang chọn ở Tab 2. |
| 4 | `QcDefectIQCEnrollment` | QcDefectIQCEnrollment | Grid đăng ký/xem báo cáo lỗi IQC (Defect Report). |
| 5 | `NonconformingReport` | NonconformingReport | Grid NCR — Non-Conformance Report cho các lỗi không phù hợp. |

### SearchFunctions (5)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_MaterialQcInfo_get` | Lấy danh sách phiếu IQC theo bộ lọc | `@pMaterialDocNo`, `@pMaterialCode`, `@pCustomerCode`, `@pFromDate` date, `@pToDate` date, `@pDecisionResult`, `@pInspectionDocType`, `@pCompanyCode`, `@pWorkCenterCode`, `@pMaterialTypeCode`, `@pProductGroupCode`, `@pDecisionFromDate` date, `@pDecisionToDate` date, `@pProdInspWorkerCode` |
| 2 | `usp_MaterialQcDetail_get` | Lấy chi tiết hạng mục đo của phiếu IQC | `@pMaterialQcNo` varchar(20) |
| 3 | `usp_MaterialQcSampleResult_get` | Lấy kết quả đo từng mẫu | `@pMaterialQcNo` varchar(20), `@pMaterialQcDetailNo` varchar(20) |
| 4 | `usp_QcDefectIQCReport_get` | Lấy báo cáo lỗi IQC | `@pDefectReportNo` varchar(20), `@pLotNo` varchar(MAX), `@pIQCSampleLotList` varchar(MAX) |
| 5 | `usp_GetMaterialQcInfo_ForReport` | Lấy thông tin in báo cáo IQC | `@pMaterialQcNo` varchar(20) |

### ExecuteFunctions (17)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_MaterialQcInfo_iud` | Thêm/Sửa/Xóa phiếu IQC | `@pProcessViewName`, `@pXml` nvarchar(MAX) |
| 2 | `usp_MaterialQcDetail_iud` | Thêm/Sửa/Xóa chi tiết hạng mục IQC | `@pProcessViewName`, `@pXml` |
| 3 | `usp_MaterialQcSampleResult_iud` | Lưu kết quả đo mẫu | `@pProcessViewName`, `@pXml` |
| 4 | `usp_DoMakeMaterialIQCDetailList` | Tạo danh sách chi tiết hạng mục từ C122 config | `@pMaterialQcNo` varchar(20) |
| 5 | `usp_DoMakeMaterialQcSampleResult` | Tạo mẫu đo cho phiếu IQC | `@pProcessViewName`, `@pXml` |
| 6 | `usp_DoUpdateMaterialQcInfo_Success` | Đánh dấu IQC **PASS** | `@pCompanyCode`, `@pProcessViewName`, `@pXml`, `@pProdInspWorkerCode` |
| 7 | `usp_DoUpdateMaterialQcInfo_Fail` | Đánh dấu IQC **FAIL** | `@pProcessViewName`, `@pXml`, `@pProdInspWorkerCode` |
| 8 | `usp_DoChangeMaterialQcToPass` | Đổi từ Fail → **PASS** (sau khi review) | `@pMaterialQcNo` varchar(30) |
| 9 | `usp_IQcDefectReport_iud` | Thêm/Sửa/Xóa báo cáo lỗi IQC | `@pProcessViewName`, `@pXml` |
| 10 | `usp_DoSendEmailForDefectReportIQC` | Gửi email thông báo lỗi IQC | `@pDefectReportNo` varchar(20) |
| 11 | `usp_DefectReportNoChange_iud` | Đổi mã Defect Report cho phiếu IQC | `@pMaterialQcNo`, `@pDefectReportNo` nvarchar(MAX) |
| 12 | `usp_MaterialQcInfoChangeLotNo_iud` | Thay đổi Lot No cho phiếu IQC | `@pMaterialQcNo`, `@pIQCSampleLotList` nvarchar(MAX) |
| 13 | `usp_ModifyRevisionsVerFromC220_VVTF4` | Cập nhật Revision Version cho NVL | `@pProcessViewName`, `@pXml` |
| 14 | `usp_NCR_Report_iud` | Thêm/Sửa/Xóa báo cáo NCR | `@pProcessViewName`, `@pXml` |
| 15 | `usp_UpdateDefectDetailIQC_VVT` | Cập nhật chi tiết lỗi IQC (VVT custom) | `@pProcessViewName`, `@pXml` |
| 16 | `usp_DoCancelIQC` | Hủy phiếu IQC (client-side action) | *(inline client logic)* |
| 17 | `usp_DoConfirmIQC` | Xác nhận phiếu IQC (client-side action) | *(inline client logic)* |

### Actions/Buttons (24)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`AllRefresh`** | AllRefresh | Làm mới toàn bộ các grid trên màn hình (Grid IQC + Detail + Sample). |
| 2 | **`RefreshMaterialQcInfo`** | RefreshMaterialQcInfo | Làm mới riêng grid phiếu IQC (Tab 1). |
| 3 | **`RefreshMIIList`** | Refresh | Làm mới grid Detail hạng mục (Tab 2). |
| 4 | **`RefreshSampleList`** | Refresh | Làm mới grid Sample Result (Tab 3). |
| 5 | **`SearchLotNo`** | SearchLotNo | Popup tìm kiếm phiếu IQC theo Lot Number. Nhập Lot No → tìm phiếu IQC tương ứng. |
| 6 | **`MIIDoSuccess`** | 판정합격 (Pass) | **Button PASS** — khi QC xác nhận NVL đạt chất lượng. Gọi `usp_DoUpdateMaterialQcInfo_Success`. Yêu cầu chọn InspWorkerCode. |
| 7 | **`MIIDoFailure`** | 판정불합격 (Fail) | **Button FAIL** — khi QC xác nhận NVL không đạt. Gọi `usp_DoUpdateMaterialQcInfo_Fail`. Tự động tạo Defect Report. |
| 8 | **`ChangetoPass`** | ChangeToPass | **Đổi Fail → Pass** — sau khi phiếu IQC bị đánh Fail, nếu review lại và phê duyệt → đổi sang Pass. Gọi `usp_DoChangeMaterialQcToPass`. |
| 9 | **`MakeSampleResult`** | Mẫu tạo 생성 | **Tạo mẫu đo** — sau khi đã Make Detail, bấm nút này để tạo N mẫu cho từng hạng mục. Gọi `usp_DoMakeMaterialQcSampleResult`. |
| 10 | **`ImportIqcInspectionItem`** | 검사항목 불러오기 | **Import hạng mục IQC** — nếu chưa có detail, bấm nút này thay vì Make Detail. Gọi `usp_DoMakeMaterialIQCDetailList` để import từ C122 config. |
| 11 | **`ChangeIQCNo`** | ChangeIQCNo | **Đổi Lot No** — thay đổi Lot Number gắn với phiếu IQC. Gọi `usp_MaterialQcInfoChangeLotNo_iud`. |
| 12 | **`DoConfirmProd`** | DoConfirmProd | **Xác nhận phiếu IQC** (Production Confirm). Xác nhận từ phía sản xuất rằng phiếu IQC hợp lệ. Gọi `usp_DoConfirmIQC`. |
| 13 | **`DoCancelProd`** | DoCancelProd | **Hủy xác nhận** (Production Cancel). Hủy xác nhận phiếu IQC. Gọi `usp_DoCancelIQC`. |
| 14 | **`DoConfirmQc`** | DoConfirmQc | **Xác nhận từ QC** — QC confirm phiếu IQC từ phía chất lượng. |
| 15 | **`DoRejectQc`** | DoRejectQc | **Từ chối từ QC** — QC reject phiếu IQC. |
| 16 | **`DoSendEmail`** | DoSendEmail | **Gửi email** — gửi email thông báo cho các bên liên quan về kết quả IQC Fail. Gọi `usp_DoSendEmailForDefectReportIQC`. |
| 17 | **`SaveDefectDetail`** | SaveDefectDetail | **Lưu chi tiết lỗi** — lưu thông tin chi tiết lỗi IQC vào Defect Report. Gọi `usp_UpdateDefectDetailIQC_VVT`. |
| 18 | **`SaveRevisionVer`** | SaveRevisionVer | **Lưu Revision** — cập nhật phiên bản revision cho NVL từ phiếu IQC. Gọi `usp_ModifyRevisionsVerFromC220_VVTF4`. |
| 19 | **`SetAllPass`** | 전체합격 (All Pass) | **All Pass** — đánh dấu Pass cho TẤT CẢ hạng mục trong phiếu IQC cùng lúc. Client-side → cập nhật toàn bộ detail rows. |
| 20 | **`SetAllPassByItem`** | 항목합격 (Pass by Item) | **Pass theo Item** — đánh dấu Pass cho các hạng mục đang chọn (multi-select). |
| 21 | **`InputLabelQty`** | LabelPrint | **Nhập số lượng in nhãn** — mở popup nhập số lượng label NG cần in. |
| 22 | **`PrintLabelSelected`** | NG_Label | **In nhãn NG** — in nhãn dán cho NVL bị đánh Fail (NG label). |
| 23 | **`ImagePopup`** | ImagePopup | **Popup hình ảnh 1** — mở popup xem/upload hình ảnh đính kèm phiếu IQC. |
| 24 | **`ImagePopup2`** | ImagePopup2 | **Popup hình ảnh 2** — mở popup xem/upload hình ảnh đính kèm thứ 2 cho phiếu IQC. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_CompanyInfo_popup` | Chọn nhà máy/công ty |
| `usp_DecisionResult_popup` | Chọn kết quả quyết định (Pass/Fail/Pending) |
| `usp_DefectCauseGroup_popup` | Chọn nhóm nguyên nhân lỗi |
| `usp_DefectCauseGroup` | Lấy danh mục nhóm nguyên nhân |
| `usp_DoConfirmCancelQc2` | Xác nhận/Hủy xác nhận QC. Params: `@pDefectReportNo`, `@pIsConfirm` bit |
| `usp_GetBaseCode_popup` | Popup lấy BaseCode |
| `usp_GetBaseCodeRemarkFilter_popup` | Popup BaseCode lọc Remark |
| `usp_GetTestResult_popup` | Lọc kết quả đo |
| `usp_MaterialTypeCode_popup` | Lọc theo loại NVL |
| `usp_NameErrorIQC` | Lấy tên lỗi IQC |
| `usp_ProdIInspectionWorkerInfo_Popup` | Chọn nhân viên QC |
| `usp_ProductGroup_get` | Lấy nhóm sản phẩm |
| `usp_ProdWorkerInfo_Popup` | Chọn nhân viên SX |
| `usp_PurchaseMaterialMaster_popup` | Chọn NVL mua ngoài |
| `usp_VendorCustomerInfo_popup` | Chọn NCC/khách hàng |
| `usp_WorkCenterInfo_popup` | Chọn Work Center |

### Bảng DB Chính

| Bảng | PK/FK | Mô tả |
|---|---|---|
| `STB_MaterialQcInfo` | PK: `MaterialQcNo` | Phiếu IQC chính. Key cols: `CompanyCode`, `WorkCenterCode`, `MaterialCode`, `DecisionResult`, `DecisionDateTime` |
| `STB_MaterialQcDetail` | FK: `MaterialQcNo` | Chi tiết hạng mục đo theo phiếu |
| `STB_MaterialQcSampleResult` | FK: `MaterialQcNo`, `MaterialQcDetailNo` | Kết quả đo thực tế từng mẫu |
| `STB_IQcDefectReport` | FK: `MaterialQcNo` | Báo cáo lỗi IQC |
| `STB_NCR_REPORT` | — | Báo cáo không phù hợp (NCR) |
| `STB_MaterialMaster` | — | Danh mục NVL |
| `STB_UserInfo` | — | Người dùng hệ thống |

# BƯỚC 3: LẬP KẾ HOẠCH & LỆNH SẢN XUẤT

*Tạo lệnh sản xuất PO, phân rã PO thành kế hoạch sản xuất hàng ngày theo tổ/máy/ca sản xuất.*

---
## B301 — PO_InformationManagement
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B301` |
| **Screen Name** | `PO_InformationManagement` |
| **Parent Menu** | `PM_ProductionOrder_MENU` |
| **Title** | PO_InformationManagement |
| **Tổng Objects** | **0** (0 View + 0 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Quản lý và theo dõi thông tin các lệnh sản xuất PO (Production Order) được đồng bộ từ ERP hoặc tạo thủ công.
2. Hiển thị trạng thái PO, số lượng yêu cầu, số lượng đã sản xuất và tiến độ thực tế phục vụ lập kế hoạch.

### Views (0)

> Không có View riêng.

### SearchFunctions (0)

> Không có SearchFunction riêng.

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProductionOrderInfo` | Lưu trữ thông tin chi tiết về lệnh sản xuất, số lượng kế hoạch và tiến độ sản xuất Lot. |

---

## B310 — ProductionOrderInfo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B310` |
| **Screen Name** | `ProductionOrderInfo` |
| **Parent Menu** | `PM_ProductionOrder_MENU` |
| **Caption** | PO管理登録 (Quản lý PO) |
| **Tổng Objects** | **17** (4 View + 4 SearchFunction + 3 ExecuteFunction + 6 Action) |

### Nghiệp vụ

Màn hình **Lệnh sản xuất (Production Order - PO)** — dùng để lập kế hoạch, tạo, duyệt, Fix và hủy lệnh sản xuất.

**Workflow:**
1. Tạo PO mới → chọn sản phẩm, số lượng, ngày SX
2. Hệ thống tự tạo **BOM** + **Routing** theo master data
3. PO được **Fix** → đóng băng, chuẩn bị sản xuất
4. PO fix → B442/B450 sử dụng để tạo kế hoạch ngày
5. Hủy PO → chỉ hủy được khi chưa phát sinh sản lượng

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  ProductionOrderInfo (Grid chính)                            │
│  ─ Filter: FromYearMonth, ToYearMonth, ProductGroupCode,     │
│            MaterialCode, IsFix, CompanyCode, WorkCenterCode  │
│  ─ Toolbar: [CreateManualPO] [Fix] [POCancel] [Refresh]     │
│             [DoGI] [Tao_PO_ReDroping]                        │
├──────────────────────────────────────────────────────────────┤
│  Tab BOM: ProductionOrderBom                                 │
│  ─ Danh sách NVL định mức cho PO đang chọn                   │
├──────────────────────────────────────────────────────────────┤
│  Tab Routing: ProductionOrderRouting                          │
│  ─ Các công đoạn sản xuất. Inline edit → iud                 │
├──────────────────────────────────────────────────────────────┤
│  Tab GI: MaterialGIForPO                                     │
│  ─ Danh sách NVL cần xuất kho                                │
└──────────────────────────────────────────────────────────────┘
```

### Views (4)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ProductionOrderInfo` | ProductionOrderInfo | Grid chính — danh sách PO. Filter theo tháng, nhóm SP, mã SP, trạng thái Fix/Cancel. |
| 2 | `ProductionOrderBom` | ProductionOrderBom | Tab BOM — chi tiết NVL định mức cho PO đang chọn. |
| 3 | `ProductionOrderRouting` | ProductionOrderRouting | Tab Routing — các công đoạn sản xuất. Hỗ trợ inline edit. |
| 4 | `MaterialGIForPO` | MaterialGIForPO | Tab GI — danh sách NVL cần xuất kho cho PO. |

### SearchFunctions (4)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_ProductionOrderInfo_get` | Lấy danh sách PO | `@pFromYearMonth` date, `@pToYearMonth` date, `@pProductGroupCode`, `@pMaterialCode`, `@pIsFix` bit, `@pCompanyCode`, `@pWorkCenterCode` |
| 2 | `usp_ProductionOrderBom_get` | Lấy BOM theo PO | `@pPONo` varchar(20), `@pMaterialCode` varchar(50), `@pIsUseAll` bit |
| 3 | `usp_ProductionOrderRouting_get` | Lấy Routing theo PO | `@pPONo` varchar(20) |
| 4 | `usp_GetMaterialGIForPO` | Lấy NVL cần cấp phát | `@pPONo` varchar(20) |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_DoFixProductionOrder` | Fix (xác nhận) PO | `@pPONo` varchar(20), `@pBasicRoutingCode` varchar(20) |
| 2 | `usp_DoCancelPO` | Hủy PO | `@pPONo` varchar(20), `@pDefectSummaryNo` varchar(20) |
| 3 | `usp_ProductionOrderRouting_iud` | Sửa/cập nhật Routing | `@pProcessViewName`, `@pXml` |

### Actions/Buttons (6)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CreateManualPO`** | 수동PO생성 (Tạo PO thủ công) | Mở dialog tạo PO mới bằng tay. Nhập: MaterialCode, BomVersion, PlanYearMonth, StartDate, EndDate, POQty, CompanyCode, WorkCenterCode. Gọi `usp_DoCreateProductionOrder`. |
| 2 | **`Fix`** | 확정 (Xác nhận) | **Fix PO** — xác nhận lệnh sản xuất. PO đã Fix → không thể sửa, chỉ có thể hủy. Gọi `usp_DoFixProductionOrder(@pPONo, @pBasicRoutingCode)`. Sau Fix → B442 có thể tạo kế hoạch ngày. |
| 3 | **`POCancel`** | POCancel | **Hủy PO** — chỉ hủy được khi chưa phát sinh sản lượng thực tế. Gọi `usp_DoCancelPO(@pPONo, @pDefectSummaryNo)`. |
| 4 | **`Refresh`** | Refresh | Làm mới grid chính và tất cả tab phụ. |
| 5 | **`DoGI`** | 자재불출확인 (Xuất kho NVL) | **Goods Issue** — thực hiện xuất kho NVL cho PO. Lấy data từ tab MaterialGIForPO → tạo phiếu xuất kho. |
| 6 | **`Tao_PO_ReDroping`** | Tao_PO_ReDroping | **Tạo PO Re-Dropping** — tạo PO mới cho cuộn sấy lại (re-dropping). Chức năng đặc biệt cho quy trình Electrode. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_DoCreateProductionOrder` | Xử lý tạo PO. Params: `@pPlanYearMonth`, `@pPlanStartDate`, `@pPlanEndDate`, `@pMaterialCode`, `@pBomVersion`, `@pPOQty`, `@pCompanyCode`, `@pWorkCenterCode`, `@pPONos`, `@pIgnoreMaxPlanQty` |
| `usp_BasicRoutingInfo_popup` | Popup chọn quy trình công nghệ |
| `usp_CompanyInfo_popup` | Popup chọn Company/Plant |
| `usp_GetRouteInfoAll_popup` | Popup chọn công đoạn |
| `usp_ProductionMaterialPopup` | Popup chọn vật tư SX |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProductionOrderInfo` | PK: `PONo`. Lệnh sản xuất chính. Key cols: `CompanyCode`, `WorkCenterCode`, `MaterialCode`, `POQty`, `IsFix`, `IsCancel` |
| `STB_ProductionOrderBom` | FK: `PONo`. Định mức NVL theo PO |
| `STB_ProductionOrderRouting` | FK: `PONo`. Quy trình công đoạn theo PO |
| `STB_MaterialMaster` | Danh mục NVL/SP |
| `STB_BasicRoutingInfo` | Danh mục quy trình công nghệ chuẩn |
| `STB_RouteInfo` | Danh mục công đoạn |
| `STB_SetInfo` | Thông tin Lot/Cuộn tạo ra từ PO |


## B351 — ProductionOrderForChangeMaterial
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B351` |
| **Screen Name** | `ProductionOrderForChangeMaterial` |
| **Parent Menu** | `Model_Change` |
| **Title** | Lot ???? |
| **Tổng Objects** | **7** (2 View + 2 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

Giao diện **ProductionOrderForChangeMaterial** dùng để thực hiện nghiệp vụ: **Chuyển đổi Lot**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ProductionOrderForChangeMaterial` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_GetDayProdPlanForChangeMaterial`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DoChangeMaterialForSetInfo`.

**Lưu ý vận hành:**
- Sau B351 phải sửa Barcode format


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlanForChangeMaterial` | DayProdPlanForChangeMaterial | Grid hiển thị dữ liệu. |
| 2 | `SetInfoForChangeMaterial` | SetInfoForChangeMaterial | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetDayProdPlanForChangeMaterial` | ????? ?? PO? ????? |
| 2 | `usp_GetSetInfoForChangeMaterial` | ????? ?? ????? ????? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoChangeMaterialForSetInfo` | PO ?????? |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ChangeMaterial`** | Change Material | Thực hiện tác vụ change material cho dữ liệu trên màn hình. |
| 2 | **`RefreshSetInfo`** | Làm mới Lot/Set | Làm mới danh sách thông tin Lot/Set sản phẩm. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODUCTIONORDERROUTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_YEARINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_RAWMATERIALINPUTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## B353 — ChangeNameLotNo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B353` |
| **Screen Name** | `ChangeNameLotNo` |
| **Parent Menu** | `vi_PriceAndMaterialCodeVN` |
| **Title** | Thay d?i t�n lot h�ng |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

Giao diện **ChangeNameLotNo** dùng để thực hiện nghiệp vụ: **Thay đổi tên lot**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ChangeNameLotNo` từ menu `KB_03, KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_GetListChangeLotno`.

**Lưu ý vận hành:**
- oldLotID = tên in tem (VJ prefix)


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ListChangeLotno` | ListChangeLotno | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetListChangeLotno` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ChangeLotnoPrintTem` | d?i lot no v� luu l?i l?ch s? d?i lot no ? m�n h�nh B523 m�n h�nh d? ch?y store n�y l� B353 |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_CHANGEPARTNOANDLOTNO` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |

---

## B442 — ElectrodePlan_Vietnam

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B442` |
| **Screen Name** | `ElectrodePlan_Vietnam` |
| **Parent Menu** | `v_ElectrodeArea` |
| **Caption** | Ke hoach Dien cuc (Kế hoạch Điện cực) |
| **Tổng Objects** | **21** (3 View + 3 SearchFunction + 4 ExecuteFunction + 11 Action) |

### Nghiệp vụ

Màn hình **kế hoạch sản xuất hàng ngày cho Electrode** — chia PO thành các Set/Lot sản xuất thực tế theo ngày, máy và ca.

**Workflow:**
1. Chọn PO đã Fix từ B310
2. Tạo **DayProdPlan** → chỉ định sản phẩm, số lượng, dây chuyền
3. Tạo **SetInfo** (Lot/Cuộn) → gán vào Plan
4. **Fix** Plan → đóng băng Lot → cho phép in tem barcode
5. Cancel Plan nếu cần

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  DayProdPlan (Grid trên)                                     │
│  ─ Filter: CompanyCode, WorkCenterCode, LineCode, FromDate,  │
│            ToDate, MaterialTypeCode, ProductGroupCode,       │
│            CancelShow, CreateUserID                          │
│  ─ Toolbar: [POSelectDialog] [FixDayPlan] [CancelDayPlan]   │
│             [Refresh] [DoGI]                                 │
├──────────────────────────────────────────────────────────────┤
│  SetInfo (Grid giữa)                                         │
│  ─ Chi tiết Lot/Cuộn trong kế hoạch đang chọn                │
│  ─ Toolbar: [CopyLot] [LabelPrint] [InputLabelQty]          │
│             [RefreshSetInfo] [AddMainAssemblePart]           │
│             [AddPartWeight]                                  │
├──────────────────────────────────────────────────────────────┤
│  MainAssemblePartWeight (Grid dưới)                          │
│  ─ Trọng lượng phụ kiện lắp ráp                              │
└──────────────────────────────────────────────────────────────┘
```

### Views (3)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlan` | DayProdPlan | Grid trên — kế hoạch sản xuất ngày. Mỗi row = 1 kế hoạch ngày. |
| 2 | `SetInfo` | SetInfo | Grid giữa — danh sách Lot/Cuộn trong kế hoạch. Inline edit. |
| 3 | `MainAssemblePartWeight` | MainAssemblePartWeight | Grid dưới — trọng lượng phụ kiện lắp ráp cho Lot đang chọn. |

### SearchFunctions (3)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_DayProdPlan_get` | Lấy kế hoạch SX ngày | `@pUtcOffset` int, `@pCompanyCode`, `@pWorkCenterCode`, `@pLineCode`, `@pFromDate` date, `@pToDate` date, `@pBasicMaterialType`, `@pMaterialTypeCode`, `@pProductGroupCode`, `@pCancelShow` bit, `@pCreateUserID` |
| 2 | `usp_SetInfo_get` | Lấy Lot/Set trong Plan | `@pUtcOffset` int, `@pPONo`, `@pDayPlanNo`, `@pLabelType` nvarchar(30) |
| 3 | `usp_MainAssemblePartWeight_get` | Lấy trọng lượng phụ kiện | `@pControlNo` varchar(20) |

### ExecuteFunctions (4)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_DayProdPlan_iud` | Thêm/Sửa/Xóa kế hoạch ngày | `@pProcessViewName`, `@pXml` |
| 2 | `usp_SetInfo_iud_VNT` | Tạo/Cập nhật Lot/Set (VNT version) | `@pProcessViewName`, `@pCompanyCode`, `@pXml` |
| 3 | `usp_DoFixDayProdPlan` | Fix kế hoạch ngày | `@pDayPlanNo` varchar(20) |
| 4 | `usp_DoCancelDayProdPlan` | Hủy kế hoạch ngày | `@pDayPlanNo` varchar(20) |

### Actions/Buttons (11)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`POSelectDialog`** | POSelectDialog | **Chọn PO** — mở popup chọn Production Order từ B310 để gán cho kế hoạch ngày. Chỉ hiển thị PO đã Fix. |
| 2 | **`FixDayPlan`** | FixDayPlan | **Fix kế hoạch ngày** — đóng băng kế hoạch + tất cả Lot bên trong. Sau Fix → có thể in tem barcode. Gọi `usp_DoFixDayProdPlan(@pDayPlanNo)`. |
| 3 | **`CancelDayPlan`** | CancelDayPlan | **Hủy kế hoạch ngày** — chỉ hủy được khi chưa phát sinh kết quả sản xuất. Gọi `usp_DoCancelDayProdPlan(@pDayPlanNo)`. |
| 4 | **`Refresh`** | Refresh | Làm mới grid kế hoạch ngày (Grid trên). |
| 5 | **`RefreshSetInfo`** | Refresh | Làm mới grid Lot/Set (Grid giữa). |
| 6 | **`CopyLot`** | CopyLot | **Nhân bản Lot** — copy thông tin Lot đang chọn → tạo Lot mới giống hệt (giảm nhập liệu lặp lại). Client-side copy + insert. |
| 7 | **`LabelPrint`** | LabelPrint | **In nhãn barcode** — in nhãn barcode cho Lot/Cuộn Electrode đang chọn. Gửi lệnh in đến máy in đã cấu hình. |
| 8 | **`InputLabelQty`** | LabelPrint | **Nhập số lượng in nhãn** — mở popup nhập số lượng label cần in trước khi in. |
| 9 | **`DoGI`** | 자재불출확인 (Xuất kho NVL) | **Goods Issue** — xuất kho NVL phụ cho kế hoạch ngày. |
| 10 | **`AddMainAssemblePart`** | 부품Lot관리 (Quản lý Lot phụ kiện) | **Gán phụ kiện** — mở popup gán phụ kiện lắp ráp (Main Assemble Part) cho Lot Electrode. |
| 11 | **`AddPartWeight`** | 부품중량 (Trọng lượng phụ kiện) | **Ghi nhận trọng lượng** — mở popup ghi nhận trọng lượng phụ kiện. Data hiển thị ở grid dưới (MainAssemblePartWeight). |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_BomVersion_popup` | Popup chọn phiên bản BOM |
| `usp_CompanyInfo_popup` | Popup chọn Company/Plant |
| `usp_LineInfo_popup` | Popup chọn Line |
| `usp_ProductGroup_popup` | Popup chọn nhóm SP |
| `usp_ProductionMaterialPopup` | Popup chọn vật tư SX |
| `usp_RouteInfoForLine_popup` | Popup chọn công đoạn thuộc Line |
| `usp_ShiftCode_popup` | Popup chọn ca làm việc |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DayProdPlan` | PK: `DayPlanNo`. Kế hoạch SX ngày. Key cols: `CompanyCode`, `WorkCenterCode`, `LineCode`, `PONo`, `PlanDate`, `IsFix`, `IsCancel` |
| `STB_SetInfo` | PK: `ControlNo`. Lot/Cuộn Electrode. FK: `PONo`, `DayPlanNo`. Key cols: `SetNo`, `MaterialCode`, `Barcode` |
| `STB_ProductionOrderInfo` | Lệnh sản xuất |
| `STB_MaterialMaster` | Danh mục NVL/SP |
| `STB_LineInfo` | Danh mục Line |
| `STB_MachineMaster` | Danh mục máy |
| `STB_MainAssemblePartWeight` | Trọng lượng phụ kiện |
| `STB_LabelInfo` | Cấu hình in nhãn |


## B450 — DayProdPlanForMainLot
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B450` |
| **Screen Name** | `DayProdPlanForMainLot` |
| **Parent Menu** | `Plan_Management` |
| **Title** | ?? ?????? |
| **Tổng Objects** | **22** (2 View + 2 SearchFunction + 6 ExecuteFunction + 12 Action) |

### Workflow

Giao diện **DayProdPlanForMainLot** dùng để thực hiện nghiệp vụ: **KH sản xuất ngày**.

**Workflow vận hành:**
1. Truy cập vào chức năng `DayProdPlanForMainLot` từ menu `KB_03, KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_DayProdPlan_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DayProdPlan_iud`.

**Lưu ý vận hành:**
- **Cột IsFixed phải tích** thì mới tạo Lot


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlan` | DayProdPlan | Grid hiển thị dữ liệu. |
| 2 | `SetInfo` | SetInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_get` | ?? ???? |
| 2 | `usp_SetInfo_get` | ????? ????? |

### ExecuteFunctions (6)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoCancelDayProdPlan` | ?? ????? ??????? |
| 3 | `usp_DoFixDayProdPlan` | ?? ????? ??????? |
| 4 | `usp_SetInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoCreateSetInfoForProdQty_VNT` | ?? ??(Lot)? ????? |
| 6 | `usp_DoFinishDayProdPlan` | ?? ????? ??????? |

### Actions/Buttons (12)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CancelDayPlan`** | Hủy Day Plan | Thực hiện tác vụ hủy day plan cho dữ liệu trên màn hình. |
| 2 | **`DoFinishDayPlan`** | Finish Day Plan | Thực hiện tác vụ finish day plan cho dữ liệu trên màn hình. |
| 3 | **`FixDayPlan`** | Fix Day Plan | Thực hiện tác vụ fix day plan cho dữ liệu trên màn hình. |
| 4 | **`DoGI`** | Xuất kho (GI) | Xác nhận xuất kho thực tế (Goods Issue) vật tư cho lệnh sản xuất. |
| 5 | **`POSelectDialog`** | P O Select Dialog | Thực hiện tác vụ p o select dialog cho dữ liệu trên màn hình. |
| 6 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 7 | **`CreateSetInfo`** | Create Set Info | Thực hiện tác vụ create set info cho dữ liệu trên màn hình. |
| 8 | **`RefreshSetInfo`** | Refresh | Làm mới danh sách thông tin Lot/Set sản phẩm. |
| 9 | **`InputLabelQty`** | LabelPrint | Nhập số lượng tem nhãn cần in cho Lot. |
| 10 | **`AddMainAssemblePart`** | Add Main Assemble Part | Thực hiện tác vụ add main assemble part cho dữ liệu trên màn hình. |
| 11 | **`InputLotQty`** | Input Lot Qty | Thực hiện tác vụ input lot qty cho dữ liệu trên màn hình. |
| 12 | **`PrintSlteeingLabel`** | In Slteeing Label | Thực hiện tác vụ in slteeing label cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MOLDBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MAINASSEMBLEPARTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODUCTIONORDERBATCHINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_BOMREVISION_MAP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_BOMDETAIL_REVISION` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_YEARINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## B452 — Vietnam_PrintLotChanged
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B452` |
| **Screen Name** | `Vietnam_PrintLotChanged` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Vietnam_PrintLotChanged |
| **Tổng Objects** | **10** (1 View + 1 SearchFunction + 1 ExecuteFunction + 7 Action) |

### Workflow

Giao diện **Vietnam_PrintLotChanged** dùng để thực hiện nghiệp vụ: **Đổi Line**.

**Workflow vận hành:**
1. Truy cập vào chức năng `Vietnam_PrintLotChanged` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_Set_VVT_Info_get`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Set_VVT_Info` | Set_VVT_Info | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Set_VVT_Info_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Set_VVT_Info_get` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (7)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`RefreshSetInfo`** | Refresh | Làm mới danh sách thông tin Lot/Set sản phẩm. |
| 3 | **`InputLabelQty`** | In Tem Lot | Nhập số lượng tem nhãn cần in cho Lot. |
| 4 | **`ChangelinecodeVVT`** | Thay doi ma Line | Thực hiện tác vụ thay doi ma line cho dữ liệu trên màn hình. |
| 5 | **`PrintSlteeingLabel`** | In Slteeing Label | Thực hiện tác vụ in slteeing label cho dữ liệu trên màn hình. |
| 6 | **`Genus_NewAdd`** | Genus_ New Add | Thực hiện tác vụ genus_ new add cho dữ liệu trên màn hình. |
| 7 | **`PrintGenusNewAdd`** | In Genus New Add | Thực hiện tác vụ in genus new add cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MAINASSEMBLEPARTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Chuyển Line lỗi "Barcode đã tồn tại trên Line khác" | Barcode chưa được `IsLineInput=0` ở Line cũ | `UPDATE STB_SetInfo SET IsLineInput=0, InputLineCode='' WHERE Barcode='mã' AND InputLineCode='LINE_CŨ'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B460 — VNT_DayProdPlanByFinished
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B460` |
| **Screen Name** | `VNT_DayProdPlanByFinished` |
| **Parent Menu** | `PM_DailyPlan_MENU` |
| **Title** | ?????? |
| **Tổng Objects** | **5** (1 View + 1 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

1. Thiết lập và phân rã kế hoạch sản xuất hàng ngày dựa trên sản lượng thành phẩm cần đạt.
2. Hỗ trợ điều phối, tạo kế hoạch chi tiết theo tổ đội, ca sản xuất và phân bổ công việc xuống từng chuyền máy cụ thể.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlanFinished` | DayProdPlanFinished | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetDayProdPlanFinished` | ????? ??? ????? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoCreateDayProdPlanForFinishedPlan` | ????? ???? |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CreateDayProdPlan`** | Create Day Prod Plan | Thực hiện tác vụ create day prod plan cho dữ liệu trên màn hình. |
| 2 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DayProdPlan` | Lưu trữ chi tiết kế hoạch sản xuất hàng ngày theo tổ/máy/ca. |

---

# BƯỚC 4: SẢN XUẤT CÔNG ĐOẠN 1 — CỰC ĐIỆN (MIXING, COATING, CÁN, CẮT)

*Pha chế nguyên liệu (Mixing), phủ màng cực điện (Coating), cán ép cuộn cực điện (RollPressing), xẻ cuộn cực điện (Slitting) và kiểm tra QC cực điện.*

---

## B470 — VNT_ElectrodePrcsCard

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B470` |
| **Screen Name** | `VNT_ElectrodePrcsCard` |
| **Parent Menu** | `Plan_Management` |
| **Caption** | VNT_ElectrodePrcsCard (Process Card Electrode) |
| **Tổng Objects** | **10** (3 View + 3 SearchFunction + 3 ExecuteFunction + 1 Action) |

### Nghiệp vụ

Màn hình **thiết lập công đoạn trộn (Mixing Process Card)** cho sản xuất Electrode — định nghĩa quy trình trộn khô, trộn ướt, khuấy, cấu hình thông số kỹ thuật và gán NVL.

**Workflow:**
1. Tạo công đoạn Electrode (Trộn khô, Trộn ướt, Khuấy)
2. Thiết lập thông số vận hành (nhiệt độ, tốc độ, thời gian)
3. Cấu hình lò sấy (nhiệt độ sấy, thời gian sấy)
4. Gán NVL cần dùng cho mỗi step

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  Tab 1: ElectrodeStep (Grid bước trộn)                       │
│  ─ Danh sách công đoạn trộn, thứ tự trộn                     │
│  ─ Filter: ProdCode (mã sản phẩm electrode)                  │
│  ─ Inline edit: Thêm/Sửa/Xóa bước                           │
├──────────────────────────────────────────────────────────────┤
│  Tab 2: ElectrodeCommon (Grid thông số)                      │
│  ─ Thông số chung: tốc độ, thời gian, nhiệt độ              │
│  ─ Inline edit                                               │
├──────────────────────────────────────────────────────────────┤
│  Tab 3: ElectrodeOven (Grid lò sấy)                          │
│  ─ Cấu hình nhiệt độ sấy, thời gian sấy                     │
│  ─ Inline edit                                               │
├──────────────────────────────────────────────────────────────┤
│  Toolbar: [ElectrodePrcsCardPrint]                           │
└──────────────────────────────────────────────────────────────┘
```

### Views (3)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ElectrodeStep` | ElectrodeStep | Tab 1 — danh sách công đoạn trộn. Inline edit. |
| 2 | `ElectrodeCommon` | ElectrodeCommon | Tab 2 — thông số chung (tốc độ, thời gian). Inline edit. |
| 3 | `ElectrodeOven` | ElectrodeOven | Tab 3 — cấu hình lò sấy. Inline edit. |

### SearchFunctions (3)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_ElectrodeStep_get` | Lấy bước trộn theo sản phẩm | `@pProdCode` varchar(20) |
| 2 | `usp_ElectrodeCommon_get` | Lấy thông số bước trộn | `@pProdCode` varchar(20) |
| 3 | `usp_ElectrodeOven_get` | Lấy cấu hình lò sấy | `@pProdCode` varchar(20) |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_ElectrodeStep_iud` | Thêm/Sửa/Xóa bước trộn | `@pProcessViewName`, `@pXml` |
| 2 | `usp_ElectrodeCommon_iud` | Thêm/Sửa/Xóa thông số | `@pProcessViewName`, `@pXml` |
| 3 | `usp_ElectrodeOven_iud` | Thêm/Sửa/Xóa cấu hình sấy | `@pProcessViewName`, `@pXml` |

### Actions/Buttons (1)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`(Korean name)`** | ElectrodePrcsCardPrint | **In Process Card** — in phiếu công nghệ (Process Card) cho Electrode. In toàn bộ thông tin các bước trộn + thông số + cấu hình sấy của sản phẩm đang chọn ra giấy A4. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_ElectrodeStep_popup` | Popup chọn bước trộn |
| `usp_MaterialMasterByMaterialType_popup` | Popup chọn NVL theo loại |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ElectrodeStep` | PK: tương ứng ProdCode + StepCode. Danh sách bước trộn Electrode |
| `STB_ElectrodeCommon` | Thông số kỹ thuật cho từng bước trộn |
| `STB_ElectrodeOven` | Cấu hình lò sấy |
| `STB_MaterialMaster` | Danh mục NVL |
| `STB_BaseCode` | Danh mục code hệ thống |


## F742 — ListInputSlitting_HN
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F742` |
| **Screen Name** | `ListInputSlitting_HN` |
| **Parent Menu** | `Slitting_HN` |
| **Title** | Danh s�ch d�u v�o kho c?t H� Nam |
| **Tổng Objects** | **4** (2 View + 2 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Quản lý danh sách các Lot nguyên vật liệu cần đưa vào máy xẻ cực điện (Slitting) tại chi nhánh Hà Nam.
2. Theo dõi tiến độ Lot đang chờ xẻ và danh sách các Lot đã thực hiện xẻ cực điện thành công.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ListInputNeedSlitting_HN` | ListInputNeedSlitting_HN | Grid hiển thị dữ liệu. |
| 2 | `ListInputSuccessSlitting_HN` | ListInputSuccessSlitting_HN | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ListInputNeedSlitting_HN` | L?y danh s�ch c?n c?t khi kho nguy�n v?t li?u chuy?n sang kho c?t |
| 2 | `usp_ListInputSuccessSlitting_HN` | L?y danh s�ch da c?t trong th�ng |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialLotInfo` | Lưu trữ thông tin Lot nguyên vật liệu cực điện Hà Nam. |
| `STB_MaterialWarehouseInOutHist` | Lịch sử giao dịch nhập/xuất kho vật tư Slitting. |

---

## F743 — SlittingLOTMaterialHaNam
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F743` |
| **Screen Name** | `SlittingLOTMaterialHaNam` |
| **Parent Menu** | `MaterialStock_MENU` |
| **Title** | SlittingLOTMaterialHaNam |
| **Tổng Objects** | **17** (2 View + 2 SearchFunction + 5 ExecuteFunction + 8 Action) |

### Workflow

Giao diện **SlittingLOTMaterialHaNam** dùng để thực hiện nghiệp vụ: **Slitting**.

**Workflow vận hành:**
1. Truy cập vào chức năng `SlittingLOTMaterialHaNam` từ menu `KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_GetSplittingMaterialLotInfo`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DoSlittingLot`.

**Lưu ý vận hành:**
- Chia cuộn lớn → nhỏ


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `SplitedMaterialLotInfo` | SplitedMaterialLotInfo | Grid hiển thị dữ liệu. |
| 2 | `SplittingMaterialLotInfo` | SplittingMaterialLotInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetSplitedMaterialLotInfo` | ??? ????? ?????. |
| 2 | `usp_GetSplittingMaterialLotInfo` | ??? ????? ?????. |

### ExecuteFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoSplitLot` | ??? Split ???. |
| 2 | `usp_DoSlittingLot` | ??? Split ???. |
| 3 | `usp_ChotSlittingLot` | ??? Split ???. |
| 4 | `usp_Update_POIL_Lot_Transfer_WarehouseCode` | Chuy?n d?i t? sliiting v? kho nvl |
| 5 | `usp_CreateLotSlitting_NG_HN_uid` | T?o tem NG v?i s? lu?ng c�n l?i khi da chia xong tem OK |

### Actions/Buttons (8)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`SplitLot`** | Split Lot | Thực hiện tác vụ split lot cho dữ liệu trên màn hình. |
| 3 | **`PartLabel`** | Part Label | Thực hiện tác vụ part label cho dữ liệu trên màn hình. |
| 4 | **`NewAction`** | New Action | Thực hiện tác vụ new action cho dữ liệu trên màn hình. |
| 5 | **`ChotSlitting`** | ch?t slitting | Thực hiện tác vụ ch?t slitting cho dữ liệu trên màn hình. |
| 6 | **`MakeLable`** | Make Lable | Thực hiện tác vụ make lable cho dữ liệu trên màn hình. |
| 7 | **`SendWarehouseNVL`** | Tr? v? kho NVL | Thực hiện tác vụ tr? v? kho nvl cho dữ liệu trên màn hình. |
| 8 | **`CreateLableNG`** | T?o tem NG | Thực hiện tác vụ t?o tem ng cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALWAREHOUSEINOUTHIST` | Lịch sử chi tiết giao dịch xuất nhập kho vật tư. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOCATION` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_WIDTHSLITTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALLOTINFO_TEST` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCLOTINFO_TEST1` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | "Trùng mã nguyên liệu" khi Slitting | F744 đã có record cho MaterialCode | Kiểm tra + sửa record cũ trong F744 | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Lot không tồn tại khi chuyển F430 | Lot chưa QC check ở C243 | Vào C243 check trước | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 3 | Hủy/Rollback Slitting bị lỗi | Chưa xóa lịch sử F746 trước | Xóa F746 trước rồi mới rollback F742 | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## F744 — WidthSlittingWH
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F744` |
| **Screen Name** | `WidthSlittingWH` |
| **Parent Menu** | `MaterialStock_MENU` |
| **Title** | Thi?t l?p chi?u r?ng Slitting |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

Giao diện **WidthSlittingWH** dùng để thực hiện nghiệp vụ: **Slitting Result**.

**Workflow vận hành:**
1. Truy cập vào chức năng `WidthSlittingWH` từ menu `KB_02, KB_05`.

**Lưu ý vận hành:**
- Chiều rộng


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `WidthSlitting` | WidthSlitting | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_WidthSlitting_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_WidthSlitting_uid` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_WIDTHSLITTINGWH` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## F746 — SlittingHistHN
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F746` |
| **Screen Name** | `SlittingHistHN` |
| **Parent Menu** | `Slitting_HN` |
| **Title** | L?ch s? Slitting H� Nam |
| **Tổng Objects** | **4** (2 View + 2 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Tra cứu lịch sử phân tách Lot cực điện sau khi xẻ cuộn (Slitting) tại Hà Nam.
2. Hiển thị mối quan hệ cây phả hệ chi tiết giữa Lot cha (Parent Lot trước khi xẻ) và các Lot con (Child Lots sau khi xẻ) phục vụ truy vết.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ParentSplitedMaterialLotInfo` | ParentSplitedMaterialLotInfo | Grid hiển thị dữ liệu. |
| 2 | `ChildSplitedMaterialLotInfo` | ChildSplitedMaterialLotInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetParentSplitedMaterialLotInfo` | Get Parent Splited Lot for F746 |
| 2 | `usp_GetChildSplitedMaterialLotInfo` | Get Child Splited Lot for F746 |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialLotInfo` | Lưu thông tin mối quan hệ Lot cha và Lot con. |
| `STB_MaterialWarehouseInOutHist` | Lịch sử xuất/nhập phân tách Lot Slitting. |

---

## F747 — ErrorSlittingHN
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F747` |
| **Screen Name** | `ErrorSlittingHN` |
| **Parent Menu** | `Slitting_HN` |
| **Title** | NG Slitting H� Nam |
| **Tổng Objects** | **6** (3 View + 3 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Quản lý các Lot cực điện bị lỗi trong quá trình xẻ cuộn Slitting tại Hà Nam.
2. Phân loại Lot lỗi (`ErrorSlitting`), Lot đạt tiêu chuẩn chuyển tiếp (`PassedSlitting`) và tổng hợp thống kê số lượng phế phẩm theo chuyền/máy.

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ErrorSlittingHN` | ErrorSlittingHN | Grid hiển thị dữ liệu. |
| 2 | `PassedSlittingHN` | PassedSlittingHN | Grid hiển thị dữ liệu. |
| 3 | `AllQuantityStatisticsSlittingHN` | AllQuantityStatisticsSlittingHN | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ErrorSlittingHN_get` | Get NG slitting for Ha Nam Factory |
| 2 | `usp_PassedSlittingHN_get` | Get Passed slitting for Ha Nam Factory |
| 3 | `usp_AllQuantityStatisticsSlittingHN_get` | Th?ng k� s? lu?ng c?t t?ng lo?i |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialLotInfo` | Lưu trữ trạng thái chất lượng của Lot cực điện sau khi Slitting. |

---

## F748 — CheckBeforeTransferWarehouse
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F748` |
| **Screen Name** | `CheckBeforeTransferWarehouse` |
| **Parent Menu** | `Slitting_HN` |
| **Title** | CheckBeforeTransferWarehouse |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Thực hiện kiểm tra điều kiện chất lượng của Lot cực điện sau Slitting trước khi cho phép xuất kho chuyển tiếp sang kho lắp ráp.
2. Cập nhật mã kho chuyển tiếp mới cho Lot vật tư (`Update_WarehouseCode`).

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CheckedSlittingHN` | CheckedSlittingHN | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_CheckedSlittingHN_get` | Get Material slitting after QC checked for transfer Warehouse |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Update_POIL_Lot_Transfer_WarehouseCode` | Chuy?n d?i t? sliiting v? kho nvl |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`SendToROHWareHouse`** | Chuy?n v? kho NVL | Thực hiện tác vụ chuy?n v? kho nvl cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialLotInfo` | Cập nhật thông tin kho vật tư hiện tại của Lot sau kiểm tra. |
| `STB_MaterialWarehouseInOutHist` | Ghi nhận lịch sử giao dịch chuyển kho vật tư thực tế. |

---

## B552 — Vietnam_ElectrodeMeasureResult

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B552` |
| **Screen Name** | `Vietnam_ElectrodeMeasureResult` |
| **Parent Menu** | `v_ElectrodeArea` |
| **Caption** | Vietnam_ElectrodeMeasureResult |
| **Tổng Objects** | **58** (11 View + 11 SearchFunction + 14 ExecuteFunction + 22 Action) |

### Nghiệp vụ

Màn hình **phức tạp nhất quy trình Electrode** — nhập toàn bộ kết quả sản xuất Electrode qua tất cả các công đoạn: Mixing (Trộn), Coating (Phủ), RollPressing (Cán), Slitting (Cắt), đo Viscosity, in tem barcode cho từng cuộn và ghi nhận phế liệu (Waste).

**Workflow theo công đoạn:**
1. **Mixing:** Chọn mẻ → nhập kết quả trộn + chi tiết từng bước
2. **Coating:** Quét lot bột → nhập kết quả phủ + kiểm tra ngoại quan + đo độ nhớt → in tem
3. **RollPressing:** Quét cuộn phủ → nhập kết quả cán + kiểm tra ngoại quan → in tem
4. **Slitting:** Quét cuộn cán → nhập kết quả cắt → in tem
5. **Waste:** Ghi nhận phế liệu thu hồi

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────────────┐
│  ═══ TAB MIXING ═══                                                  │
│  ElectrodeMixInfo (Grid trộn chính)                                  │
│  ─ Kết quả mẻ trộn. Filter: ElectrodeLotNumber                      │
│  ElectrodeMixStepInfo (Grid chi tiết bước)                           │
│  ─ Thông số chạy chi tiết từng bước trộn                             │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB COATING ═══                                                 │
│  ElectrodeCoatingInfo (Grid phủ chính)                               │
│  ─ Kết quả phủ cuộn. Toolbar: [PrintLabel] [CheckPrint]             │
│    [PackingLabelPrintCoating] [VietnamPackLabelCoating]               │
│    [UpdatePrintYn]                                                   │
│  ElectrodeCoatingVisualInspectionInfo (Grid ngoại quan Coating)      │
│  ─ Kết quả kiểm tra ngoại quan phủ                                   │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB ROLLPRESSING ═══                                            │
│  ElectrodeRollPressingInfo (Grid cán chính)                          │
│  ─ Toolbar: [CheckPrint2] [PackingLabelPrintRollPress]               │
│    [PackingLabelPrintRollPressNormal] [VietnamPackLabelRollPress]     │
│    [UpdatePrintYn2]                                                  │
│  ElectrodeRollPressingVisualInspectionInfo (Grid ngoại quan cán)     │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB SLITTING ═══                                                │
│  ElectrodeSlittingInfo (Grid cắt chính)                              │
│  ─ Toolbar: [CreateSlittingInfo] [ScanSlittingLocation]              │
│    [ScanSlittingLocation2] [UpdatePrintYn3]                          │
│  ElectrodeSlittingResult (Grid chi tiết cuộn con)                    │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB WASTE ═══                                                   │
│  ElectrodeWastePriceNewByBarcode (Grid phế liệu)                    │
│  ─ Toolbar: [PrintElectrodeWasteLabel] [PrintElectrodeWasteList]     │
│    [ElectrodeWasteLabelPrintAction] [FoilWasteLabelPrintAction]      │
│    [PrintFoilWasteList]                                              │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB PHỤ ═══                                                    │
│  LocationElectric (Grid đo điện)                                     │
│  Vietnam_RollPressingSlitting (Grid cán cắt liên tục)                │
│  ─ Toolbar: [DoElectrodeInspection] [RefreshView]                    │
│    [CheckPrintExpired]                                               │
└──────────────────────────────────────────────────────────────────────┘
```

### Views (11)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ElectrodeMixInfo` | ElectrodeMixInfo | Grid trộn chính — kết quả mẻ trộn bột Electrode. |
| 2 | `ElectrodeMixStepInfo` | ElectrodeMixStepInfo | Grid chi tiết bước — thông số chạy từng bước trộn (tốc độ, thời gian, nhiệt độ). |
| 3 | `ElectrodeCoatingInfo` | ElectrodeCoatingInfo | Grid phủ chính — kết quả phủ cuộn Electrode. |
| 4 | `ElectrodeCoatingVisualInspectionInfo` | ElectrodeCoatingVisualInspectionInfo | Grid ngoại quan Coating — kiểm tra bề mặt cuộn phủ. |
| 5 | `ElectrodeRollPressingInfo` | ElectrodeRollPressingInfo | Grid cán chính — kết quả cán cuộn Electrode. |
| 6 | `ElectrodeRollPressingVisualInspectionInfo` | ElectrodeRollPressingVisualInspectionInfo | Grid ngoại quan cán — kiểm tra bề mặt cuộn cán. |
| 7 | `ElectrodeSlittingInfo` | ElectrodeSlittingInfo | Grid cắt chính — kết quả cắt chia cuộn. |
| 8 | `ElectrodeSlittingResult` | ElectrodeSlittingResult | Grid chi tiết cuộn con — dữ liệu các cuộn nhỏ sau khi cắt. |
| 9 | `ElectrodeWastePriceNewByBarcode` | ElectrodeWastePriceNewByBarcode | Grid phế liệu — ghi nhận lượng phế liệu theo barcode. |
| 10 | `LocationElectric` | LocationElectric | Grid phụ — thông tin vị trí đo điện cực. |
| 11 | `Vietnam_RollPressingSlitting` | Vietnam_RollPressingSlitting | Grid phụ — quy trình cán cắt liên tục (combined view). |

### SearchFunctions (11)

| # | ObjectName | Mô tả | Params chính |
|---|---|---|---|
| 1 | `usp_ElectrodeMixInfo_get` | Lấy kết quả trộn | `@pElectrodeLotNumber` varchar(20) |
| 2 | `usp_ElectrodeMixStepInfo_get` | Lấy chi tiết bước trộn | `@pElectrodeLotNumber` varchar(20) |
| 3 | `usp_ElectrodeCoatingInfo_get` | Lấy kết quả phủ | `@pElectrodeLotNumber` varchar(20) |
| 4 | `usp_ElectrodeCoatingVisualInspectionInfo_get` | Lấy ngoại quan Coating | `@pElectrodeLotNumber` varchar(20) |
| 5 | `usp_ElectrodeRollPressingInfo_get` | Lấy kết quả cán | `@pElectrodeLotNumber` varchar(20) |
| 6 | `usp_ElectrodeRollPressingVisualInspectionInfo_get` | Lấy ngoại quan cán | `@pElectrodeLotNumber` varchar(20) |
| 7 | `usp_ElectrodeSlittingInfo_get` | Lấy kết quả cắt | `@pElectrodeLotNumber` varchar(20) |
| 8 | `usp_ElectrodeSlittingResult_get` | Lấy chi tiết cuộn con | `@pElectrodeLotNumber` varchar(20) |
| 9 | `usp_ElectrodeWastePriceNewByBarcode_get` | Lấy phế liệu theo barcode | `@pBarcode` varchar(20) |
| 10 | `usp_LocationElectric` | Lấy vị trí đo điện cực | `@pElectrodeLotNumber` varchar(30) |
| 11 | `usp_Vietnam_RollPressingSlitting_get` | Lấy quy trình cán cắt | `@pElectrodeLotNumber` varchar(20) |

### ExecuteFunctions (14)

| # | ObjectName | Mô tả | Params chính |
|---|---|---|---|
| 1 | `usp_ElectrodeMixInfo_iud` | Lưu kết quả trộn | `@pProcessViewName`, `@pXml` |
| 2 | `usp_ElectrodeMixStepInfo_iud` | Lưu chi tiết bước trộn | `@pProcessViewName`, `@pXml` |
| 3 | `usp_ElectrodeCoatingInfo_iud` | Lưu kết quả phủ | `@pProcessViewName`, `@pXml` |
| 4 | `usp_ElectrodeCoatingVisualInspectionInfo_iud` | Lưu ngoại quan Coating | `@pProcessViewName`, `@pXml` |
| 5 | `usp_ElectrodeRollPressingInfo_iud` | Lưu kết quả cán | `@pProcessViewName`, `@pXml` |
| 6 | `usp_ElectrodeRollPressingVisualInspectionInfo_iud` | Lưu ngoại quan cán | `@pProcessViewName`, `@pXml` |
| 7 | `usp_ElectrodeSlittingInfo_iud` | Lưu kết quả cắt | `@pProcessViewName`, `@pXml` |
| 8 | `usp_ElectrodeSlittingResult_iud` | Lưu chi tiết cuộn con | `@pProcessViewName`, `@pXml`, `@pElectrodeLotNumber` |
| 9 | `usp_ElectrodCoatingInfo_Viscosity_VVT_iud` | Lưu kết quả đo độ nhớt | `@pProcessViewName`, `@pXml` |
| 10 | `usp_DoUpdateCoatingBarcodePrintYn` | Cập nhật trạng thái in nhãn Coating | `@pElectrodeLotNumber` varchar(20) |
| 11 | `usp_DoUpdateRollPressBarcodePrintYn` | Cập nhật trạng thái in nhãn RollPress | `@pElectrodeLotNumber` varchar(20) |
| 12 | `usp_DoUpdateSlitingBarcodePrintYn` | Cập nhật trạng thái in nhãn Slitting | `@pElectrodeLotNumber` varchar(20) |
| 13 | `usp_ElectrodeWasteInfoNew_iud` | Ghi nhận phế liệu | `@pProcessViewName`, `@pXml` |
| 14 | `usp_test_check_expired` | Kiểm tra hạn sử dụng NVL trộn | `@pRawMaterialBarcode1` nvarchar(200) |

### Actions/Buttons (22)

#### Nhóm MIXING

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`RefreshView`** | RefreshView | Làm mới toàn bộ các grid trên màn hình. |
| 2 | **`CheckPrintExpired`** | CheckPrintExpiredn | **Kiểm tra hạn** — kiểm tra hạn sử dụng nguyên vật liệu trộn bột. Gọi `usp_test_check_expired(@pRawMaterialBarcode1)`. Nếu hết hạn → cảnh báo không cho trộn. |

#### Nhóm COATING

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 3 | **`PrintLabel`** | PrintLabel | **In nhãn Coating** — in tem barcode cho cuộn Electrode sau khi phủ. Ghi nhận PrintYn. |
| 4 | **`CheckPrint`** | CheckPrint | **Kiểm tra in nhãn Coating** — kiểm tra cuộn đã in nhãn chưa trước khi cho qua công đoạn tiếp. |
| 5 | **`PackingLabelPrintCoating`** | PackingLabelPrintCoating | **In nhãn đóng gói Coating** — in nhãn cho việc đóng gói cuộn Coating. |
| 6 | **`VietnamPackLabelCoating`** | VietnamPackLabelCoating | **In nhãn VN (Coating)** — bản in nhãn theo format VN cho Coating. |
| 7 | **`UpdatePrintYn`** | UpdatePrintYn | **Cập nhật trạng thái in Coating** — đánh dấu cuộn đã in nhãn. Gọi `usp_DoUpdateCoatingBarcodePrintYn(@pElectrodeLotNumber)`. |

#### Nhóm ROLLPRESSING

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 8 | **`CheckPrint2`** | CheckPrint2 | **Kiểm tra in nhãn RollPress** — kiểm tra cuộn cán đã in nhãn chưa. |
| 9 | **`PackingLabelPrintRollPress`** | PackingLabelPrintRollPress | **In nhãn đóng gói RollPress** — in nhãn cho cuộn cán. |
| 10 | **`PackingLabelPrintRollPressNormal`** | PackingLabelPrintRollPressNormal | **In nhãn RollPress thường** — bản in nhãn tiêu chuẩn cho cuộn cán (không phải special). |
| 11 | **`VietnamPackLabelRollPress`** | VietnamPackLabelRollPress | **In nhãn VN (RollPress)** — bản in nhãn theo format VN cho cuộn cán. |
| 12 | **`UpdatePrintYn2`** | UpdatePrintYn2 | **Cập nhật trạng thái in RollPress** — gọi `usp_DoUpdateRollPressBarcodePrintYn(@pElectrodeLotNumber)`. |

#### Nhóm SLITTING

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 13 | **`CreateSlittingInfo`** | CreateSlittingInfo | **Tạo Slitting Info** — tạo dữ liệu cắt cuộn từ cấu hình SlittingLocationConfig. Phải chạy trước khi nhập kết quả cắt. |
| 14 | **`ScanSlittingLocation`** | Scan Slitting Location | **Quét vị trí cắt** — quét barcode cuộn cán → hệ thống load cấu hình chia cuộn (SlittingLocationConfig) → hiển thị vị trí cắt. |
| 15 | **`ScanSlittingLocation2`** | Scan Slitting Location. | **Quét vị trí cắt (v2)** — phiên bản thứ 2 của scan slitting (có thể khác format barcode hoặc quy trình). |
| 16 | **`UpdatePrintYn3`** | UpdatePrintYn3 | **Cập nhật trạng thái in Slitting** — gọi `usp_DoUpdateSlitingBarcodePrintYn(@pElectrodeLotNumber)`. |

#### Nhóm WASTE

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 17 | **`PrintElectrodeWasteLabel`** | PrintElectrodeWasteLabel | **In nhãn phế liệu Electrode** — in nhãn cho container chứa phế liệu bột electrode. |
| 18 | **`PrintElectrodeWasteList`** | PrintElectrodeWasteList | **In danh sách phế liệu Electrode** — in báo cáo tổng hợp phế liệu electrode. |
| 19 | **`ElectrodeWasteLabelPrintAction`** | ElectrodeWasteLabelPrintAction | **In label phế liệu (Action)** — action in nhãn phế liệu electrode (có thể khác format). |
| 20 | **`FoilWasteLabelPrintAction`** | FoilWasteLabelPrintAction | **In nhãn phế liệu lá đồng/nhôm** — in nhãn cho phế liệu lá kim loại (foil waste). |
| 21 | **`PrintFoilWasteList`** | PrintFoilWasteList | **In danh sách phế liệu lá** — in báo cáo tổng hợp phế liệu lá đồng/nhôm. |

#### Nhóm QC TRIGGER

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 22 | **`DoElectrodeInspection`** | DoElectrodeInspection | **Trigger kiểm QC** — kích hoạt quy trình kiểm tra chất lượng Electrode (link sang C460). Tạo phiếu kiểm QC cho cuộn đang chọn. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_CommonCode_INOUT_popup` | Chọn trạng thái IN/OUT |
| `usp_CommonCode_OKNG_popup` | Chọn trạng thái OK/NG |
| `usp_CommonCode_OX_LEFT_popup` | Trạng thái OX trái |
| `usp_CommonCode_OX_RIGHT_popup` | Trạng thái OX phải |
| `usp_CommonCode_YesNo_popup` | Yes/No |
| `usp_CommonCode_YesNo_PushingYn_popup` | Trạng thái ép đùn |
| `usp_GetBaseCode_popup` | BaseCode |
| `usp_GetBasicRouteingDetailForRoute_popup` | Lọc routing |
| `usp_MaterialMaster_popup` | Chọn NVL |
| `usp_ProductMachine_popup` | Chọn máy SX |
| `usp_ProductMachineForRoute_popup` | Chọn máy theo công đoạn |
| `usp_ProdWorkerInfo_Popup` | Chọn nhân viên SX |
| `usp_RouteInfo_get` | Lấy danh sách công đoạn |
| `usp_Vietnam_DefectInfo_popup` | Chọn mã lỗi defect |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ElectrodeMixInfo` | PK tương ứng ElectrodeLotNumber. Kết quả mẻ trộn |
| `STB_ElectrodeMixStepInfo` | Chi tiết bước trộn |
| `STB_ElectrodeCoatingInfo` | Kết quả phủ cuộn |
| `STB_ElectrodeCoatingVisualInspectionInfo` | Ngoại quan Coating |
| `STB_ElectrodeRollPressingInfo` | Kết quả cán cuộn |
| `STB_ElectrodeRollPressingVisualInspectionInfo` | Ngoại quan cán |
| `STB_ElectrodeSlittingInfo` | Kết quả cắt cuộn |
| `STB_ElectrodeSlittingResult` | Dữ liệu cuộn con |
| `STB_ElectrodeWasteInfoNew` | Phế liệu |
| `STB_ElectrodeWastePriceNew` | Đơn giá phế liệu |
| `STB_SetInfo` | Lot/Cuộn |
| `STB_SlittingLocationConfig_VVT` | Cấu hình vị trí cắt |
| `STB_CoatingToSlittingMaster` | Mapping Coating → Slitting |
| `STB_ProdRouteHist` | Lịch sử routing |


## C243 — CheckSlittingLot
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C243` |
| **Screen Name** | `CheckSlittingLot` |
| **Parent Menu** | `IQCInsepection_MENU` |
| **Title** | CheckSlittingLot |
| **Tổng Objects** | **8** (1 View + 1 SearchFunction + 2 ExecuteFunction + 4 Action) |

### Workflow

Giao diện **CheckSlittingLot** dùng để thực hiện nghiệp vụ: **Electrode QC Measurement**.

**Workflow vận hành:**
1. Truy cập vào chức năng `CheckSlittingLot` từ menu `KB_02, KB_05, KB_31`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_vvt_MaterialSlittingLotInfo_get`.

**Lưu ý vận hành:**
- Đo lường QC điện cực


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `vvt_MaterialSlittingLotInfo` | vvt_MaterialSlittingLotInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_vvt_MaterialSlittingLotInfo_get` | ?? ?????? ?????. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_QCReview_Poil_HaNamFactory` | QC d�nh gi� c�c nguy�n li?u du?c c?t trong ph�ng Slitting H� Nam |
| 2 | `usp_QCReview_Poil_HaNamFactory_Reject` | Reject lot nguy�n li?u trong kho c?t |

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`LabelPrint`** | In tem | Thực hiện in tem nhãn sản phẩm hoặc vật tư. |
| 2 | **`MIIDoSuccess`** | Phê duyệt PASS | Đánh giá Lot hàng đạt chất lượng OQC (PASS) và cho phép chuyển tiếp. Gọi SP usp_DoUpdateMaterialQcInfo_Success. |
| 3 | **`MIIDoFailure`** | Phê duyệt FAIL | Đánh giá Lot hàng không đạt (FAIL), khóa xuất kho và yêu cầu xử lý. Gọi SP usp_DoUpdateMaterialQcInfo_Fail. |
| 4 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Lot slitting không chuyển về kho được | QC đánh Reject → không thể chuyển | Xử lý theo quy trình NG — không bypass | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## C460 — ElectrodeInspectionHistoryForBarcode

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C460` |
| **Screen Name** | `ElectrodeInspectionHistoryForBarcode` |
| **Parent Menu** | `Process inspection` |
| **Caption** | 공정검사이력(바코드) — Lịch sử kiểm tra công đoạn (barcode) |
| **Tổng Objects** | **19** (2 View + 2 SearchFunction + 6 ExecuteFunction + 9 Action) |

> ⚠️ **Lưu ý:** TCode C460 có 2 màn hình khác nhau trong DB: `ElectrodeInspectionHistoryForBarcode` (dùng cho Electrode QC) và `VNT_CustomerComplaintManagementInfo` (dùng cho Customer Complaints). Chỉ clone `ElectrodeInspectionHistoryForBarcode`.

### Nghiệp vụ

Màn hình **QC kiểm tra chất lượng Electrode** — tại trạm QC, quét barcode cuộn → đo thông số → ra quyết định OK/NG/Loss.

**Workflow:**
1. QC quét **barcode Electrode** → hệ thống load lịch sử kiểm tra. Nếu chưa có → tạo phiếu tự động.
2. QC nhập **kết quả đo** cho từng hạng mục QC
3. Xác nhận:
   - **OK** → `DoFinishCommInspDoc` hoặc `DoFinishCommInspDoc_VNT` → cuộn đạt, cho phép dùng
   - **NG** → nhập mã lỗi (Defect Code)
   - **Loss** → `DoLossCommInspDoc_VNT` → hủy cuộn lỗi
4. Chia nhỏ cuộn lỗi nếu cần (`DoLossElectrodeProcess_iud`)
5. Xem thông tin Coating gốc để đối chiếu

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Barcode Input (Ô quét barcode)                         │ │
│  │  ─ Quét/nhập barcode cuộn Electrode                     │ │
│  └─────────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────────┤
│  ElectrodeInspectionHistoryForBarcode (Grid trên)            │
│  ─ Lịch sử phiếu kiểm tra cho barcode cuộn                  │
│  ─ Filter: CompanyCode, WorkCenterCode, CommInspTypeCode,    │
│            Barcode, LineCode, RouteCode, MachineCode,        │
│            MoldNumber, CategoryName, CommInspRemark          │
│  ─ Toolbar: [DoFinishCommInsp] [DoHoldCommInsp]              │
│             [DoLossCommInsp] [DoLossCommInspDialog]          │
│             [InputDefectCode] [MIIDoSuccess] [MIIDoFailure]  │
│             [Refresh] [SetHolding]                           │
├──────────────────────────────────────────────────────────────┤
│  ElectrodeCoatingInfo (Grid dưới)                            │
│  ─ Thông tin Coating gốc của cuộn (readonly, đối chiếu)      │
└──────────────────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ElectrodeInspectionHistoryForBarcode` | ElectrodeInspectionHistoryForBarcode | Grid trên — lịch sử phiếu kiểm QC cho barcode cuộn. Mỗi row = 1 hạng mục kiểm tra. |
| 2 | `ElectrodeCoatingInfo` | ElectrodeCoatingInfo | Grid dưới — thông tin Coating gốc. Readonly — dùng để QC đối chiếu thông số phủ. |

### SearchFunctions (2)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_GetElectrodeInspectionHistoryForBarcode` | Lấy lịch sử kiểm QC theo barcode | `@pCompanyCode`, `@pCompanyName` nvarchar(50), `@pWorkCenterCode`, `@pWorkCenterName` nvarchar(50), `@pCommInspTypeCode` varchar(50), `@pBarcode` varchar(50), `@pLineCode`, `@pRouteCode`, `@pMachineCode`, `@pMoldNumber` varchar(50), `@pCategoryName` varchar(50), `@pCommInspRemark` varchar(50) |
| 2 | `usp_ElectrodeCoatingInfo_get` | Lấy thông tin Coating gốc | `@pElectrodeLotNumber` varchar(20) |

### ExecuteFunctions (6)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_DoAddCommInspMeasureHistForBarcode` | Lưu kết quả đo QC cho barcode | `@pCommInspDocNo`, `@pCommInspDocItemNo`, `@pTextMeasure` varchar(50), `@pNumericMeasure` numeric(13), `@pCheckDisplay` bit, `@pInspWorkerCode`, `@pCIDHExtText02` varchar(200) |
| 2 | `usp_DoAddCommInspMeasureHistForBarcode_TEST` | Alias đo test (cùng logic) | *(same as above)* |
| 3 | `usp_DoFinishCommInspDoc` | Phê duyệt OK phiếu QC (basic) | `@pCommInspDocNo`, `@pIsCheckItem` bit |
| 4 | `usp_DoFinishCommInspDoc_VNT` | Phê duyệt OK (VNT mở rộng) | `@pCommInspDocNo`, `@pIsCheckItem` bit, `@pIsHolding` bit, `@pIsLoss` bit, `@pIsFinished` bit, `@pDefectCode` varchar(20) |
| 5 | `usp_DoLossElectrodeProcess_iud` | Xử lý chia cuộn bị lỗi | `@pBarcode` varchar(50), `@pIsCheckItem` bit |
| 6 | `usp_ElectrodeDivision_popup` | Popup chia nhỏ cuộn | *(system params only)* |

### Actions/Buttons (9)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoFinishCommInsp`** | 검사완료 (Hoàn thành kiểm tra) | **Hoàn thành QC** — xác nhận hoàn thành kiểm tra cho phiếu QC. Gọi `usp_DoFinishCommInspDoc_VNT`. Cuộn được phép chuyển sang công đoạn tiếp theo hoặc lắp ráp. |
| 2 | **`DoHoldCommInsp`** | 보류해제등록 (Giữ/Bỏ giữ) | **Hold/Unhold** — đặt cuộn vào trạng thái chờ (Hold) khi chưa thể quyết định ngay. Cuộn Hold → không được dùng cho lắp ráp. Bỏ Hold → cho phép dùng lại. |
| 3 | **`DoLossCommInsp`** | DoLossCommInsp | **Hủy cuộn (Loss)** — đánh dấu cuộn là Loss (hủy). Gọi `usp_DoLossCommInspDoc_VNT(@pCommInspDocNo, @pIsCheckItem)`. Cuộn bị hủy → không thể sử dụng. |
| 4 | **`DoLossCommInspDialog`** | 불량수리 (Sửa lỗi) | **Dialog xác nhận Loss** — mở dialog xác nhận trước khi hủy cuộn. Cho phép chọn chia nhỏ cuộn (`usp_DoLossElectrodeProcess_iud`) nếu chỉ lỗi 1 phần. |
| 5 | **`InputDefectCode`** | 불량입력 (Nhập mã lỗi) | **Nhập Defect Code** — mở popup chọn mã lỗi defect từ danh mục (`usp_DefectInfo_popup`). Gắn mã lỗi cho cuộn bị NG. |
| 6 | **`MIIDoSuccess`** | MIIDoSuccess | **Đo ĐẠT** — đánh dấu hạng mục đo hiện tại là Pass. Gọi `usp_DoAddCommInspMeasureHistForBarcode` với kết quả OK. |
| 7 | **`MIIDoFailure`** | MIIDoFailure | **Đo KHÔNG ĐẠT** — đánh dấu hạng mục đo hiện tại là Fail/NG. Gọi `usp_DoAddCommInspMeasureHistForBarcode` với kết quả NG. |
| 8 | **`Refresh`** | Refresh | Làm mới cả 2 grid (lịch sử kiểm tra + thông tin Coating). |
| 9 | **`SetHolding`** | SetHolding | **Đặt trạng thái Hold** — client-side action đặt flag Hold trên grid. Kết hợp với `DoHoldCommInsp` để lưu. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_DoLossCommInspDoc_VNT` | Xử lý hủy phiếu QC. Params: `@pCommInspDocNo`, `@pIsCheckItem` bit |
| `usp_CommInspSelectItem_popup` | Popup chọn hạng mục QC |
| `usp_CommonCode_OKNG_popup` | Popup OK/NG |
| `usp_CompanyInfo_popup` | Popup Company |
| `usp_DefectInfo_popup` | Popup mã lỗi defect |
| `usp_LineInfo_popup` | Popup Line |
| `usp_ProdWorkerInfo_Popup` | Popup nhân viên |
| `usp_RouteInfoForLine_popup` | Popup công đoạn theo Line |
| `usp_WorkCenterInfo_popup` | Popup Work Center |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_CommInspDocHistory` | Phiếu kiểm QC Electrode |
| `STB_CommInspDocItemHistory` | Hạng mục trong phiếu kiểm |
| `STB_CommInspMeasureHistory` | Kết quả đo từng hạng mục |
| `STB_ElectrodeCoatingInfo` | Thông tin Coating gốc |
| `STB_SetInfo` | Lot/Cuộn |
| `STB_DefectInfo` | Danh mục mã lỗi |
| `STB_CommInspSelectGroup` | Nhóm hạng mục kiểm tra |
| `STB_CommInspSelectItem` | Hạng mục kiểm tra |

---

## Thống Kê Tổng Hợp

| Màn hình | TCode | Views | Search | Execute | Actions | **Tổng Objects** |
|---|---|---|---|---|---|---|
| QcInspectionGroup | C121 | 2 | 2 | 2 | 0 | **6** |
| MaterialQcInspectionItemByMaterial | C122 | 2 | 1 | 1 | 5 | **9** |
| MaterialIqcInfoSampleManagement | C220 | 5 | 5 | 17 | 24 | **51** |
| ProductionOrderInfo | B310 | 4 | 4 | 3 | 6 | **17** |
| ElectrodePlan_Vietnam | B442 | 3 | 3 | 4 | 11 | **21** |
| VNT_ElectrodePrcsCard | B470 | 3 | 3 | 3 | 1 | **10** |
| Vietnam_ElectrodeMeasureResult | B552 | 11 | 11 | 14 | 22 | **58** |
| Vietnam_EletrodeProdRouteHist | B802 | 2 | 2 | 0 | 2 | **6** |
| ElectrodeInspectionHistoryForBarcode | C460 | 2 | 2 | 6 | 9 | **19** |
| **TỔNG** | | **34** | **33** | **50** | **80** | **197** |

---

## Sơ Đồ Quan Hệ Giữa Các Màn Hình

```
C121 (Định nghĩa nhóm/hạng mục QC)
  │
  ▼
C122 (Gán hạng mục QC → MaterialCode)
  │
  ▼
C220 (IQC: Kiểm tra NVL đầu vào)
  │
  └──► F330 (Nhập kho NVL) ──► tự tạo phiếu IQC

B310 (Tạo PO - Lệnh sản xuất)
  │
  ▼
B442 (Kế hoạch ngày Electrode → tạo Lot/Set)
  │
  ├──► B470 (Cấu hình bước trộn → reference cho B552 Mixing)
  │
  ▼
B552 (Nhập kết quả SX: Mixing → Coating → RollPressing → Slitting → Waste)
  │
  ├──► C460 (QC Electrode: kiểm tra chất lượng cuộn theo barcode)
  │
  ▼
B802 (Báo cáo lịch sử SX Electrode — READ-ONLY)
```

---

> **Ghi chú về clone _HY:**  
> Khi clone sang HY, các SP nghiệp vụ chính (get/iud/action) sẽ thêm suffix `_HY` và thêm điều kiện filter `CompanyCode = 'VVT_F5'` hoặc đọc từ bảng riêng `_HY`. Các popup, helper SPs và functions dùng chung giữa các nhà máy.


## B802 — Vietnam_EletrodeProdRouteHist

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B802` |
| **Screen Name** | `Vietnam_EletrodeProdRouteHist` |
| **Parent Menu** | `v_ElectrodeArea` |
| **Caption** | Vietnam_EletrodeProdRouteHist |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 0 ExecuteFunction + 2 Action) |

### Nghiệp vụ

Màn hình **báo cáo tổng hợp lịch sử sản xuất Electrode** — READ-ONLY. Xem và kết xuất dữ liệu truy xuất nguồn gốc (Traceability) cho toàn bộ quá trình sản xuất Electrode.

**Workflow:**
1. Chọn khoảng ngày, ca SX, dây chuyền Electrode
2. Lọc R&D hay Production
3. Xem lịch sử quy trình (Mixing → Coating → RollPressing → Slitting)
4. Xem lịch sử lỗi defect cho cuộn đang chọn

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  ElectrodeProdRouteHist (Grid trên)                          │
│  ─ Filter: FromDate, ToDate, ElectrodeRouteName,             │
│            CompanyCode, RnD, WorkCenterCode                  │
│  ─ Lịch sử quy trình SX Electrode (readonly)                │
│  ─ Toolbar: [MixingStep] [Thickness]                         │
├──────────────────────────────────────────────────────────────┤
│  Vietnam_ElectrodeDefectHist (Grid dưới)                     │
│  ─ Danh sách lỗi defect tương ứng cuộn đang chọn            │
│  ─ Readonly                                                  │
└──────────────────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ElectrodeProdRouteHist` | ElectrodeProdRouteHist | Grid trên — lịch sử quy trình SX Electrode. Join các công đoạn Mixing, Coating, RollPressing, Slitting. Readonly. |
| 2 | `Vietnam_ElectrodeDefectHist` | Vietnam_ElectrodeDefectHist | Grid dưới — lịch sử lỗi defect. Chọn 1 cuộn ở grid trên → grid dưới load lỗi. Readonly. |

### SearchFunctions (2)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_Vietnam_ElectrodeProdRouteHist_get` | Truy xuất lịch sử SX | `@pFromDate` date, `@pToDate` date, `@pElectrodeRouteName` varchar(20), `@pCompanyCode` varchar(20), `@pRnD` varchar(20), `@pWorkCenterCode` varchar(30) |
| 2 | `usp_Vietnam_ElectrodeDefectHist_get` | Truy xuất lịch sử lỗi | `@pFromDate` date, `@pToDate` date, `@pElectrodeRouteName` varchar(20), `@pCompanyCode` varchar(20), `@pRnD` varchar(20), `@pWorkCenterCode` nvarchar(20) |

### ExecuteFunctions (0)

> Màn hình B802 **không có ExecuteFunction** — hoàn toàn READ-ONLY.

### Actions/Buttons (2)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`MixingStep`** | Mixing Step | **Xem chi tiết bước trộn** — mở popup/dialog hiển thị chi tiết các bước trộn (MixStepInfo) của mẻ trộn tương ứng với cuộn đang chọn. Readonly — chỉ xem, không sửa. |
| 2 | **`Thickness`** | Thickness | **Xem chi tiết độ dày** — mở popup/dialog hiển thị dữ liệu đo độ dày (thickness measurement) của cuộn Electrode đang chọn. Readonly. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_CompanyInfo_get` | Lấy danh mục Company/Plant |
| `usp_GetBaseCode_popup` | Popup BaseCode |
| `usp_GetBaseCode_popup2` | Popup BaseCode v2 |
| `usp_vvt_RnDorProduction_popup` | Popup chọn R&D/Production |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProdRouteHist` | Lịch sử routing di chuyển SP |
| `STB_ElectrodeMixInfo` | Thông tin mẻ trộn |
| `STB_ElectrodeMixStepInfo` | Chi tiết bước trộn |
| `STB_ElectrodeCoatingInfo` | Thông tin phủ |
| `STB_ElectrodeRollPressingInfo` | Thông tin cán |
| `STB_ElectrodeSlittingResult` | Dữ liệu cuộn con |
| `STB_ElectrodeWasteInfoNew` | Phế liệu |
| `STB_DayProdPlan` | Kế hoạch ngày |
| `STB_SetInfo` | Lot/Cuộn |
| `STB_DefectInfo` | Thông tin lỗi |
| `STB_MachineMaster` | Danh mục máy |
| `STB_MaterialMaster` | Danh mục NVL |
| `STB_ProdWorkerInfo` | Nhân viên SX |

# BƯỚC 5: SẢN XUẤT CÔNG ĐOẠN 2 — LẮP RÁP & KIỂM TRA QC CÔNG ĐOẠN CELL LINE

*Lắp ráp cell, sấy hàng, bẻ cong/dán keo, kiểm tra QC tự chủ inline và ghi nhận sản lượng, phế phẩm công đoạn Cell Line.*

---
## B597 — VNT_SelfInspectionRawMaterial2
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B597` |
| **Screen Name** | `VNT_SelfInspectionRawMaterial2` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | VNT_SelfInspectionRawMaterial_VVT |
| **Tổng Objects** | **17** (2 View + 2 SearchFunction + 6 ExecuteFunction + 7 Action) |

### Workflow

Giao diện **VNT_SelfInspectionRawMaterial2** dùng để thực hiện nghiệp vụ: **QC inline scan NVL**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_SelfInspectionRawMaterial2` từ menu `KB_03, KB_05, KB_14, KB_31`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_RawMaterialInputHist_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_Vietnam_RawMaterialInputHist_uid`.

**Lưu ý vận hành:**
- SP chặn: HOLD + Hết hạn + Sai chủng loại


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CommInspectionHistoryForBarcode` | SelfInspectionHistoryForBarcode | Grid hiển thị dữ liệu. |
| 2 | `RawMaterialInputHist` | RawMaterialInputHist | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetCommInspectionHistoryForBarcode` | ???????? |
| 2 | `usp_RawMaterialInputHist_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (6)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoAddCommInspMeasureHistForBarcode` | ?? ????? ?? ???. |
| 2 | `usp_DoFinishCommInspDoc` | ?? ??? ??????? |
| 3 | `usp_DoFinishCommInspDoc_VNT` | ?? ??? ??????? |
| 4 | `usp_RawMaterialInputHist_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_Vietnam_RawMaterialInputHist_uid` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (7)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoLossCommInspDialog`** | Popup Loss | Mở cửa sổ nhập hao hụt/phế liệu công đoạn. |
| 2 | **`DoFinishCommInsp`** | Hoàn thành QC | Xác nhận hoàn tất quá trình kiểm định chất lượng tài liệu QC. |
| 3 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 4 | **`DoHoldCommInsp`** | Khóa Lot (HOLD) | Đưa Lot hàng sang trạng thái HOLD (tạm khóa chất lượng) để kiểm định thêm. |
| 5 | **`DoLossCommInsp`** | Ghi nhận Loss | Ghi nhận lượng hao hụt/phế liệu phát sinh tại công đoạn kiểm tra. |
| 6 | **`InputDefectCode`** | Nhập mã lỗi | Mở cửa sổ chọn và gán mã lỗi phế phẩm cho sản phẩm. |
| 7 | **`SetHolding`** | HOLD Lot | Thiết lập trạng thái HOLD (tạm dừng sử dụng) đối với Lot. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |
| `STB_INPUTMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_RAWMATERIALINPUTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_RAWMATERIALBAISCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ELECTRODESLITTINGRESULT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_BOMDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_DELEGATEMATERIALINPUTLOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_RAWMATERIALEXTENDINFOBE` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_COMMINSPDOCHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_COMMINSPITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_COMMINSPDOCITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_COMMINSPMEASUREHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_COMMINSPSELECTITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_VVT_OPENEXPIREDMATERIAL` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VVT_MATERIALBO` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SLITTINGSTOCK_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_ELECTRODESLITTINGINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_SLITTINGLOCATIONCONFIG_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_BOMDETAIL_REVISION` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALWAREHOUSEINOUTHIST` | Lịch sử chi tiết giao dịch xuất nhập kho vật tư. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PASSORFAILROUTESTATUS` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_BOMHEADER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_COMMINSPTYPEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PROCEDURELOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_PRODUCTIONORDERROUTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Cảnh báo đỏ HOLD — "Lot chưa QC" | Lot nằm kho `HOLDING_WH` | QC hoàn thành IQC hoặc chuyển kho: `UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode='ROH_WH' WHERE LotID='mã'` (⚠️ Cột là `MaterialWarehouseCode`, KHÔNG phải `WarehouseCode`) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Cảnh báo "Hết hạn sử dụng" | Lot vi phạm FIFO/Expiry | Gia hạn: `UPDATE STB_MaterialLotInfo SET CreateDateTime = DATEADD(DAY,-30,GETDATE()) WHERE LotID='mã'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 3 | "Sai chủng loại" — NVL không trong BOM | NVL scan không match BOM config PO | Kiểm tra BOM tại B310 hoặc SQL | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 4 | Vỏ nhôm (AluCase) mới báo sai chủng loại | Mã vỏ nhôm bị **hardcode** trong SP `usp_Vietnam_RawMaterialInputHist_uid` | ALTER SP bổ sung mã mới vào `IF / NOT IN` — xem [KB_05 §7.4](KB_05/KB_05_01_QC_OVERVIEW.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 5 | "String or binary data truncated" khi quét gộp 5 mã điện cực | Cột `RawMaterialBarcode NVARCHAR(100)` quá ngắn | `ALTER TABLE STB_InputMaterialHistory ALTER COLUMN RawMaterialBarcode NVARCHAR(1000)` + sửa SP tương ứng — xem [KB_05 §7.5](KB_05/KB_05_01_QC_OVERVIEW.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 6 | "Mã Electrolyte/DUNG DỊCH được thiết lập, khác với mã QRCODE nhập vào" | Quét mã dung dịch sai chủng loại → SP check bảng config | Kiểm tra đúng mã NVL dung dịch, hoặc thêm vào config | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 7 | OP nhập NVL module (Wire/PCB/Chip) bằng gõ tay thay vì scan barcode lot cho model 1840-WC(40) | SP `usp_Vietnam_RawMaterialInputHist_uid` dòng 318 exclude `MODULE%` khỏi validation → OP gõ tự do `40`, `dm`, `0` | Thêm block chặn sau `END -- end chặn chemical`: check `@mmmaterialcode` (lookup sẵn từ `stb_materialdoclotinfo` line 264). ModuleWire→WRHI00-007, ModuleChip→VRE-009, ModulePCB→PBDM00-004. Nếu `@mmmaterialcode=''` (gõ tay) → RAISERROR. ducnv 2026-06-19 | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B598 — VVT_ProScraps2
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B598` |
| **Screen Name** | `VVT_ProScraps2` |
| **Parent Menu** | `vi_NGqty` |
| **Title** | B�o ph? |
| **Tổng Objects** | **8** (1 View + 1 SearchFunction + 3 ExecuteFunction + 3 Action) |

### Workflow

1. Khai báo phế phẩm phát sinh trực tiếp tại công đoạn Cell Line theo ca làm việc (`STB_VN_Shift`).
2. Ghi nhận mã lỗi, số lượng phế phẩm, người phát hiện và máy móc phát sinh.
3. Cho phép cập nhật thông tin phế phẩm hoặc hủy khai báo scrap.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `vn_showproductionerror` | vn_showproductionerror | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_vn_showproductionerror` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Add_ProductionError` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_VN_update_ProdutionError` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_VN_update_CanceScrap` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Bt_Status`** | H?y ph? | Thực hiện tác vụ h?y ph? cho dữ liệu trên màn hình. |
| 2 | **`Bt_BaoPhe`** | B�o ph? | Thực hiện tác vụ b�o ph? cho dữ liệu trên màn hình. |
| 3 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VN_Production_Error` | Lưu chi tiết lỗi phế phẩm sản xuất công đoạn. |
| `STB_VN_Shift` | Bảng danh mục ca kíp làm việc thực tế. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Báo phế NVL bị chặn/không đồng bộ | Lệch `JobDate` giữa ca thực tế và kế hoạch | Sửa JobDate: `UPDATE STB_ProdRouteHist SET JobDate = CAST(GETDATE() AS DATE) WHERE ...` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B540 — AssyCardInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B540` |
| **Screen Name** | `AssyCardInfo` |
| **Parent Menu** | `Assembly_Measurement_Info` |
| **Title** | AssyCardInfo |
| **Tổng Objects** | **22** (4 View + 5 SearchFunction + 0 ExecuteFunction + 13 Action) |

### Workflow

Giao diện **AssyCardInfo** dùng để thực hiện nghiệp vụ: **Nhập process V22→V28**.

**Workflow vận hành:**
1. Truy cập vào chức năng `AssyCardInfo` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_AssyCardInfoCommon_get`.

**Lưu ý vận hành:**
- 4 cột màu bắt buộc


### Views (4)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `AssyCardInfoCommon` | AssyCardInfoCommon | Grid hiển thị dữ liệu. |
| 2 | `AssyCardInfoProdQty` | AssyCardInfoProdQty | Grid hiển thị dữ liệu. |
| 3 | `AssyCardInfoOven` | AssyCardInfoOven | Grid hiển thị dữ liệu. |
| 4 | `RawMaterialInputHist` | RawMaterialInputHist | Grid hiển thị dữ liệu. |

### SearchFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_AssyCardInfoCommon_get` | Lot ???? ??(??) |
| 2 | `usp_AssyCardInfoProdQty_get` | Lot ???? ??(??) |
| 3 | `usp_AssyCardInfoOven_get` | Lot ???? ??(????) |
| 4 | `usp_GetRawMaterialLotForBarcode_VNT_SF` | ??? ????? ????? |
| 5 | `usp_RawMaterialInputHist_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (13)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoCreateWasteElectrolyteInfo`** | Create Waste Electrolyte Info | Thực hiện tác vụ create waste electrolyte info cho dữ liệu trên màn hình. |
| 2 | **`XRayImagePopup`** | X Ray Image Popup | Thực hiện tác vụ x ray image popup cho dữ liệu trên màn hình. |
| 3 | **`OvenOutput`** | Oven Output | Thực hiện tác vụ oven output cho dữ liệu trên màn hình. |
| 4 | **`OvenInput`** | Oven Input | Thực hiện tác vụ oven input cho dữ liệu trên màn hình. |
| 5 | **`SelfInspectionInput`** | Self Inspection Input | Thực hiện tác vụ self inspection input cho dữ liệu trên màn hình. |
| 6 | **`RawMaterialInput`** | Raw Material Input | Thực hiện tác vụ raw material input cho dữ liệu trên màn hình. |
| 7 | **`ProdQtyInput`** | Prod Qty Input | Thực hiện tác vụ prod qty input cho dữ liệu trên màn hình. |
| 8 | **`OvenBarcodePrint`** | Oven Barcode Print | Thực hiện tác vụ oven barcode print cho dữ liệu trên màn hình. |
| 9 | **`SelftInspRawMaterial`** | Selft Insp Raw Material | Thực hiện tác vụ selft insp raw material cho dữ liệu trên màn hình. |
| 10 | **`SelfInspRawMaterialVPC0825`** | SelfInspRawMaterialVPC | Thực hiện tác vụ selfinsprawmaterialvpc cho dữ liệu trên màn hình. |
| 11 | **`VVT_SelfInspRawMaterial`** | V V T_ Self Insp Raw Material | Thực hiện tác vụ v v t_ self insp raw material cho dữ liệu trên màn hình. |
| 12 | **`DryOven`** | S?y h�ng | Thực hiện tác vụ s?y h�ng cho dữ liệu trên màn hình. |
| 13 | **`VVT_SelfInspRawMaterialBG2`** | Vi?t Nam_Ki?m tra thuong xuy�n BG2 | Thực hiện tác vụ vi?t nam_ki?m tra thuong xuy�n bg2 cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_CHANGEPARTNOANDLOTNO` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_VN_DRYOVER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_PASSORFAILROUTESTATUS` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTIONORDERBOM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MAINASSEMBLEPARTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |
| `STB_INPUTMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_RAWMATERIALINPUTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_RAWMATERIALBAISCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ELECTRODESLITTINGRESULT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_BOMDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_DELEGATEMATERIALINPUTLOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_RAWMATERIALEXTENDINFOBE` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Scan NVL bị lỗi "Sai chủng loại" | Mã NVL không nằm trong BOM config của PO cho Route | Kiểm tra BOM: `SELECT * FROM STB_ProductionOrderBom WHERE PONo='mã' AND RouteCode='V-22'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B530 — VNT_ProdRouteByBarcode
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B530` |
| **Screen Name** | `VNT_ProdRouteByBarcode` |
| **Parent Menu** | `Packaging_Label_Info` |
| **Title** | ?? ?????? |
| **Tổng Objects** | **34** (3 View + 3 SearchFunction + 10 ExecuteFunction + 18 Action) |

### Workflow

Giao diện **VNT_ProdRouteByBarcode** dùng để thực hiện nghiệp vụ: **Nhập SL sản xuất**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_ProdRouteByBarcode` từ menu `KB_03, KB_14`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_GetProdRouteHistForBarcode_VNT`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`.

**Lưu ý vận hành:**
- Bắt buộc nhập "Making"


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdRouteHistForBarcode_VNT` | ProdRouteHistForBarcode_VNT | Grid hiển thị dữ liệu. |
| 2 | `ProdRouteBarcodeForDefect_VNT` | ProdRouteBarcodeForDefect_VNT | Grid hiển thị dữ liệu. |
| 3 | `WasteWeight` | WasteWeight | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetProdRouteHistForBarcode_VNT` | ??? ?? ?? |
| 2 | `usp_GetProdRouteBarcodeForDefect_VNT` | ??? ??? ????? ???? |
| 3 | `usp_WasteWeight_get` | ??? ?? ?? |

### ExecuteFunctions (10)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoProcessDefectRepairInfoByBarcode_SmartApp` | ???? ????? ????? |
| 2 | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | ????? ???? ?? ???? ???? ??? |
| 3 | `usp_DoUpdateProdRouteHistMarkingLetter` | ????? ???? ???. |
| 4 | `usp_DoUpdateDRIExtText02_iud` | ???? ???? (?? ?? ? ???? ?? ?? ??? ?? ?? ?? ???? ???.) |
| 5 | `usp_InterimProdQtyInfo_iud` | ???? ???? ????? ?? ?? ????. |
| 6 | `usp_DoCreateTaktTimeForRoute` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoSplitLotAgingHN` | Split Lot Aging for Ha Nam Factory |
| 8 | `usp_AddRepairInfor_BG2` | Thêm/Sửa/Xóa dữ liệu. |
| 9 | `usp_PassBarcodeForRoute` | D�nh gi� con h�ng n�y l� pass |
| 10 | `usp_FailBarcodeForRoute` | D�nh gi� l� fail v?i ma lot t?ng c�ng doan |

### Actions/Buttons (18)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`ProdFinish`** | Prod Finish | Thực hiện tác vụ prod finish cho dữ liệu trên màn hình. |
| 3 | **`AddDefect`** | Add Defect | Thực hiện tác vụ add defect cho dữ liệu trên màn hình. |
| 4 | **`ReSend`** | Re Send | Thực hiện tác vụ re send cho dữ liệu trên màn hình. |
| 5 | **`PrintWasteLabel`** | In Waste Label | Thực hiện tác vụ in waste label cho dữ liệu trên màn hình. |
| 6 | **`UpdateMarkingLetter`** | Cập nhật Marking Letter | Thực hiện tác vụ cập nhật marking letter cho dữ liệu trên màn hình. |
| 7 | **`DoUpdateDRIExtText02`** | Cập nhật D R I Ext Text02 | Thực hiện tác vụ cập nhật d r i ext text02 cho dữ liệu trên màn hình. |
| 8 | **`RefreshDefectView`** | Làm mới Defect View | Thực hiện tác vụ làm mới defect view cho dữ liệu trên màn hình. |
| 9 | **`??????`** | ?????? | Thực hiện tác vụ ?????? cho dữ liệu trên màn hình. |
| 10 | **`InputInterimProdQty`** | Input Interim Prod Qty | Thực hiện tác vụ input interim prod qty cho dữ liệu trên màn hình. |
| 11 | **`LotProdStart`** | Lot Prod Start | Thực hiện tác vụ lot prod start cho dữ liệu trên màn hình. |
| 12 | **`SplitLotAging`** | Chia Lot Aging | Thực hiện tác vụ chia lot aging cho dữ liệu trên màn hình. |
| 13 | **`DoSplitLotAgingHN`** | Split Lot Aging H N | Thực hiện tác vụ split lot aging h n cho dữ liệu trên màn hình. |
| 14 | **`RefreshView`** | Làm mới | Làm mới giao diện hiển thị dữ liệu. |
| 15 | **`DeleteView`** | Xóa View | Thực hiện tác vụ xóa view cho dữ liệu trên màn hình. |
| 16 | **`TranferRepair`** | Chuy?n repair | Thực hiện tác vụ chuy?n repair cho dữ liệu trên màn hình. |
| 17 | **`Pass`** | Phê duyệt PASS | Đánh giá Lot hàng đạt chất lượng (PASS). |
| 18 | **`Fail`** | Đánh giá FAIL | Đánh giá Lot hàng không đạt chất lượng (FAIL). |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |
| `STB_PASSORFAILROUTESTATUS` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_PRODUCTIONORDERROUTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_RAWMATERIALINPUTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_INTERIMPRODQTYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_DEFECTINFO` | Chi tiết các mã lỗi phế phẩm của hệ thống. |
| `STB_DEFECTGROUP` | Danh mục nhóm lỗi phế phẩm sản xuất. |
| `STB_TYPEERRORGROUPOFFACTORY` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_DEFECTCAUSENG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_WASTEWEIGHT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WASTEUNITPRICE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODROUTEWORKERHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_REPAIRINFOR` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODROUTESUMMARY` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_TAKTTIMEFORROUTE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SFGWAREHOUSE_VVTF3` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Gate 20 phút không hoạt động — OP scan liên tục không bị chặn | BUG: `IF @SIExtInt01 = Null` (phải là `IS NULL`) trong SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | ALTER SP sửa `= Null` → `IS NULL` — xem [KB_12 §2.2](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | "Routing không có trong PO" hoặc "Đã hoàn thành" | Bỏ qua công đoạn trước chưa scan, hoặc PO config sai RouteIndex | Dùng Golden Query trace: `SELECT * FROM STB_ProdRouteHist WHERE ControlNo=(SELECT ControlNo FROM STB_SetInfo WHERE Barcode='mã') ORDER BY ProdDateTime` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 3 | Lỗi "Vượt SL công đoạn trước" (전공정의 수량을 초과할수 없습니다) | CurrentRouteQty + ProdQty > BefRouteQty | Kiểm tra SL Route trước: nếu đúng → chốt thêm ở Route trước. Nếu sai → sửa ProdQty | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 4 | Thiếu/dư danh mục lỗi (Defect Code) trên lưới nhập lỗi | `STB_DefectInfo` chưa cập nhật | `UPDATE STB_DefectInfo SET IsUsed=0 WHERE DefectCode IN ('cũ')` + `INSERT INTO STB_DefectInfo (...) VALUES (...)` — xem [KB_03 §B530 Lỗi 3](KB_03/KB_03_02_CELL_LINE.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 5 | "Barcode chưa được đưa vào tuyến" (투입처리 되지 않은 바코드) | Barcode chưa qua công đoạn đầu (IsLineInput=0) | Scan lại từ công đoạn đầu (IsInputRoute=1), hoặc IT chạy: `UPDATE STB_SetInfo SET IsLineInput=1 WHERE ControlNo='mã'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 6 | "PQC chưa nhập số lượng NG" | SP check DefectQty ở công đoạn trước phải > 0 khi có mã lỗi `_00` (Đạt) | Logic bug — mã `_00` = OK nhưng SP đọc COUNT lỗi = 0 → nhầm là chưa nhập. Fix: ALTER SP hoặc IT nhập 1 dòng DefectQty=0 cho mã `_00` — xem [KB_26 §4.1](KB_26/KB_26_01_LINKS_BUGS.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 7 | Grid `ProdRouteBarcodeForDefect_VNT` hiển thị lỗi sai/thừa cần xóa | OP nhập nhầm defect hoặc defect tạo tự động không đúng | Xóa mềm: `UPDATE STB_DefectRepairInfo SET IsDelete='1', ChangeDateTime=GETDATE(), ChangeUserID='ducnv_fix' WHERE ControlNo=(SELECT ControlNo FROM STB_SetInfo WHERE Barcode='MÃ_BARCODE') AND IsDelete='0'`. VD: Barcode `K16418106262500772` → ControlNo `20260618000445`, DefectSummaryNo `20260619000834/835` (VP02_005, ND02_006). ducnv 2026-06-19 | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B717 — BendingTapping
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B717` |
| **Screen Name** | `BendingTapping` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Theo doi Bending v� Tapping |
| **Tổng Objects** | **9** (1 View + 1 SearchFunction + 3 ExecuteFunction + 4 Action) |

### Workflow

Giao diện **BendingTapping** dùng để thực hiện nghiệp vụ: **Bẻ cong & dán keo**.

**Workflow vận hành:**
1. Truy cập vào chức năng `BendingTapping` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_new_Tapping_VVT_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_new_Tapping_VVT_iud`.

**Lưu ý vận hành:**
- Chỉ lưu 1 lần đầu


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VN_BENDING_TAPPING` | VN_BENDING_TAPPING | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_new_Tapping_VVT_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_STB_BENDING_TAPPING` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_new_Tapping_VVT_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_MarkingLabelPrintHistVVT_iud` | Marking Label Print history in C552 and B718 |

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PrintLabel`** | In tem Marking | Thực hiện in tem nhãn cho đối tượng đang chọn. |
| 2 | **`SavePrintHist`** | Lưu Print Hist | Thực hiện tác vụ lưu print hist cho dữ liệu trên màn hình. |
| 3 | **`PrintMarkingLabel`** | In Marking Label | Thực hiện tác vụ in marking label cho dữ liệu trên màn hình. |
| 4 | **`RefreshView`** | Làm mới | Làm mới giao diện hiển thị dữ liệu. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_VN_BENDING_TAPPING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MARKINGLABELPRINTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## B718 — SummaryTappingBennding
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B718` |
| **Screen Name** | `SummaryTappingBennding` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | T?ng h?p Tapping v� Bennding |
| **Tổng Objects** | **6** (1 View + 1 SearchFunction + 2 ExecuteFunction + 2 Action) |

### Workflow

Giao diện **SummaryTappingBennding** dùng để thực hiện nghiệp vụ: **Report 618 & 717**.

**Workflow vận hành:**
1. Truy cập vào chức năng `SummaryTappingBennding` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_Vietnam_TappingBennding_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MarkingLabelPrintHistVVT_iud`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VN_TappingBennding` | VN_TappingBennding | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_TappingBennding_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BENDING_TAPPING_Delete` | ???????? IUD |
| 2 | `usp_MarkingLabelPrintHistVVT_iud` | Marking Label Print history in C552 and B718 |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PrintMarkingLabel`** | In tem Marking | Thực hiện tác vụ in tem marking cho dữ liệu trên màn hình. |
| 2 | **`SavePrintHist`** | Lưu Print Hist | Thực hiện tác vụ lưu print hist cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_VN_BENDING_TAPPING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_COMMINSPITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MARKINGLABELPRINTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## B733 — B733
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B733` |
| **Screen Name** | `B733` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | In tem theo y�u c?u kh�ch h�ng |
| **Tổng Objects** | **8** (1 View + 1 SearchFunction + 1 ExecuteFunction + 5 Action) |

### Workflow

1. Quản lý in tem nhãn cho dòng sản phẩm Bloom Box tại công đoạn đóng gói.
2. Quét Lot để lấy thông số kỹ thuật sản phẩm, kiểm định QC, quy cách tem từ `STB_ModelBasicInfo` và `STB_PackingLabelSpec`, thực hiện in và ghi nhận lịch sử.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `BloomBoxLabalInfo_Vietname` | BloomBoxLabalInfo_Vietname | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BloomBoxLabalInfo_get_Vietname` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VN_BloomBoxLabelPrintHist_iud` | Print History of BloomBox Label |

### Actions/Buttons (5)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Printerstamper`** | In tem -133975 | Thực hiện tác vụ in tem -133975 cho dữ liệu trên màn hình. |
| 2 | **`SetPONo`** | Set P O No | Thực hiện tác vụ set p o no cho dữ liệu trên màn hình. |
| 3 | **`SavePrintHist`** | Lưu Print Hist | Thực hiện tác vụ lưu print hist cho dữ liệu trên màn hình. |
| 4 | **`PrintLabelFixPN`** | In tem | Thực hiện tác vụ in tem cho dữ liệu trên màn hình. |
| 5 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_BloomBoxLabalPrintHist` | Lưu trữ lịch sử in tem nhãn Bloom Box của nhà máy. |

---

## B618 — ReworkSorting
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B618` |
| **Screen Name** | `ReworkSorting` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Rework Sorting |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 2 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **ReworkSorting** dùng để thực hiện nghiệp vụ: **Lịch sử SX lại**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ReworkSorting` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_new_Tapping_VVT_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_new_Tapping_VVT_iud`.

**Lưu ý vận hành:**
- Chỉ theo dõi


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VN_BENDING_TAPPING` | Rework Sorting | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_new_Tapping_VVT_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_STB_BENDING_TAPPING` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_new_Tapping_VVT_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_VN_BENDING_TAPPING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | "Bạn không có quyền vui lòng liên hệ EA !" | SP `usp_GetInforLotReworkHaNamFactory_uid` hardcode check UserID | Thêm UserID vào whitelist trong SP hoặc tạo record permission — xem [KB_26 §4.5](KB_26/KB_26_01_LINKS_BUGS.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B682 — VvtProdBadStatus
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B682` |
| **Screen Name** | `VvtProdBadStatus` |
| **Parent Menu** | `vi_NGqty` |
| **Title** | VvtProdBadStatus |
| **Tổng Objects** | **6** (3 View + 3 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **VvtProdBadStatus** dùng để thực hiện nghiệp vụ: **Report lỗi cell line**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VvtProdBadStatus` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_Get_VVT_Prod_Bad_Status`.

**Lưu ý vận hành:**
- Tab trên: SUM lỗi. Tab dưới: chi tiết


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdBadStatus` | ProdBadStatus | Grid hiển thị dữ liệu. |
| 2 | `ProdBadStatus_Detail` | ProdBadStatus_Detail | Grid hiển thị dữ liệu. |
| 3 | `ProdBadStatus_LotCheck` | ProdBadStatus_LotCheck | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Get_VVT_Prod_Bad_Status` | Lấy danh sách dữ liệu. |
| 2 | `usp_Get_VVT_Prod_Bad_Stat_tail` | Lấy danh sách dữ liệu. |
| 3 | `usp_GetProdBadStatus_LotCheck` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_DEFECT_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_DEFECTINFO` | Chi tiết các mã lỗi phế phẩm của hệ thống. |
| `STB_TYPEERRORGROUPOFFACTORY` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_DEFECTCAUSENG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VVT_STAGEPRICES` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODUCTIONORDERROUTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |
| `STB_PRODROUTESUMMARY` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_BASICROUTINGDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | B786 ESR không hiện data | ESR data chưa upload hoặc Lot chưa match | Kiểm tra `STB_VVT_ESRDATA` WHERE Barcode='mã' | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | B791 NG Defect Repair — SL NG lệch | `DefectQty` trong `STB_ProdRouteHist` không khớp `STB_DefectRepairInfo` | Đồng bộ lại: xem [KB_03 §5.8](KB_03/KB_03_02_CELL_LINE.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B726 — ScrapAfterProduction
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B726` |
| **Screen Name** | `ScrapAfterProduction` |
| **Parent Menu** | `vi_NGqty` |
| **Title** | Ph? sau s?n xu?t |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

Giao diện **ScrapAfterProduction** dùng để thực hiện nghiệp vụ: **Scrap After Production**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ScrapAfterProduction` từ menu `KB_03`.
2. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_addscrapafterproduction`.

**Lưu ý vận hành:**
- Xóa mềm: `IsDeleted = 1`


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `vn_scrapafterproduction` | vn_scrapafterproduction | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_vn_scrapafterproduction` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_addscrapafterproduction` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ViewDetails`** | Xem th�ng tin chi ti?t | Thực hiện tác vụ xem th�ng tin chi ti?t cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VN_SCRAP_AFTERPRODUCTIONS` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VIETNAM_MAPCODE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## C486 — ErrorDataSorting
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C486` |
| **Screen Name** | `ErrorDataSorting` |
| **Parent Menu** | `vi_IQC` |
| **Title** | ErrorDataSorting |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 2 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **ErrorDataSorting** dùng để thực hiện nghiệp vụ: **QC Measuring Items**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ErrorDataSorting` từ menu `KB_05, KB_31`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VVT_SortingErrorData_ALCase_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_VVT_SortingErrorData_ALCase_iud`.

**Lưu ý vận hành:**
- Thừa cột Note1, xáo trộn layout


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VVT_SortingErrorData_ALCase` | VVT_SortingErrorData_ALCase | Grid hiển thị dữ liệu. |
| 2 | `VVT_SortingErrorData_Plate` | VVT_SortingErrorData_Plate | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVT_SortingErrorData_ALCase_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_VVT_SortingErrorData_Plate_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVT_SortingErrorData_Plate_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_VVT_SortingErrorData_ALCase_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVT_SORTINGERRORDATA_ALCASE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VVT_SORTINGERRORDATA_PLATE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Cột Note1 thừa trên Grid / cột bị xáo | Lỗi metadata grid trong SmartFramework | Rebuild bảng + ALTER bảng tương ứng — xem [KB_05 §7.8](KB_05/KB_05_01_QC_OVERVIEW.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

# BƯỚC 6: KIỂM TRA CHẤT LƯỢNG THÀNH PHẨM (OQC / FOQC / ESR)

*Tập hợp các Lot sản xuất để làm phiếu kiểm tra chất lượng thành phẩm OQC, đo thông số ESR, kiểm tra độ tin cậy và báo cáo sự cố chất lượng.*

---

## C510 — MaterialOqcLotManagement
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C510` |
| **Screen Name** | `MaterialOqcLotManagement` |
| **Parent Menu** | `OQCInsepection_MENU` |
| **Title** | ???? Lot?? |
| **Tổng Objects** | **10** (2 View + 2 SearchFunction + 2 ExecuteFunction + 4 Action) |

### Workflow

Giao diện **MaterialOqcLotManagement** dùng để thực hiện nghiệp vụ: **OQC Lot Search**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialOqcLotManagement` từ menu `KB_05`.

**Lưu ý vận hành:**
- —


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlan` | DayProdPlan | Grid hiển thị dữ liệu. |
| 2 | `SetInfoForOqcLot` | SetInfoForOqcLot | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_get` | ?? ???? |
| 2 | `usp_GetSetInfoForOqcLot_DayPlan` | ???? Lot??? ?? Set??? ?????. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoCreateOqcInfoForLotByOne_VNT` | ???? Lot? ????? |
| 2 | `usp_DoCreateOqcInfoListForLot` | ???? Lot? ????? |

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`RefreshSetInfo`** | Refresh | Làm mới danh sách thông tin Lot/Set sản phẩm. |
| 3 | **`CreateLot`** | Create Lot | Thực hiện tác vụ create lot cho dữ liệu trên màn hình. |
| 4 | **`ListCreateLot`** | List Create Lot | Thực hiện tác vụ list create lot cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALOQCLOTMANAGEMENT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## C512 — SetListForOqcLotManagement_VVT2
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C512` |
| **Screen Name** | `SetListForOqcLotManagement_VVT2` |
| **Parent Menu** | `vi_OQC` |
| **Title** | ??? ????Lot?? |
| **Tổng Objects** | **8** (1 View + 2 SearchFunction + 2 ExecuteFunction + 3 Action) |

### Workflow

Giao diện **SetListForOqcLotManagement_VVT2** dùng để thực hiện nghiệp vụ: **OQC Lot Management**.

**Workflow vận hành:**
1. Truy cập vào chức năng `SetListForOqcLotManagement_VVT2` từ menu `KB_02, KB_05, KB_31, KB_32`.

**Lưu ý vận hành:**
- **3 case lỗi:** (1) Lot chưa tạo, (2) Chưa A410, (3) HN Route VE02


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `SetListForOqcLot_VVT` | SetListForOqcLot_VVT | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetSetListForOqcLot_VNT` | ???? Lot??? ?? Set??? ?????. |
| 2 | `usp_GetSetListForOqcLot_VVT` | ???? Lot??? ?? Set??? ?????. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoCreateOqcInfoForLotByOne_VNT` | ???? Lot? ????? |
| 2 | `usp_DoCreateOqcInfoListForLot` | ???? Lot? ????? |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`CreateLot`** | Create Lot | Thực hiện tác vụ create lot cho dữ liệu trên màn hình. |
| 3 | **`ListCreateLot`** | List Create Lot | Thực hiện tác vụ list create lot cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SETLISTFOROQCLOTMANAGEMENTVVT2` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Không tìm thấy Lot khi tạo OQC | Lot chưa gộp box B523 HOẶC PO thiếu `IsOutputRoute=1` | Kiểm tra B523 + sửa `STB_ProductionOrderRouting` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Model mới không hiện khi chọn | A410 chưa config OqcType | Xem A410 ở trên | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## C530 — MaterialOqcInfoSampleManagement
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C530` |
| **Screen Name** | `MaterialOqcInfoSampleManagement` |
| **Parent Menu** | `Outgoing_Qualuty_Control` |
| **Title** | ??????? |
| **Tổng Objects** | **43** (5 View + 5 SearchFunction + 14 ExecuteFunction + 19 Action) |

### Workflow

Giao diện **MaterialOqcInfoSampleManagement** dùng để thực hiện nghiệp vụ: **OQC Audit**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialOqcInfoSampleManagement` từ menu `KB_05, KB_31, KB_32`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_GetMaterialOQcInfo`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MaterialQcInfo_iud`.

**Lưu ý vận hành:**
- **Core OQC:** Pass/Fail/Hold/Rescreening


### Views (5)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialQcInfoSampleList` | ?????????? | Grid hiển thị dữ liệu. |
| 2 | `MaterialQcDetailSampleList` | ????????? | Grid hiển thị dữ liệu. |
| 3 | `MaterialSampleResult` | ????????? | Grid hiển thị dữ liệu. |
| 4 | `MaterialQcInfo_ForReport` | MaterialQcInfo_ForReport | Grid hiển thị dữ liệu. |
| 5 | `OQC_Bad_List` | ProdRouteBarcodeForDefect_E27 | Grid hiển thị dữ liệu. |

### SearchFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetMaterialOQcInfo` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialQcDetail_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_MaterialQcSampleResult_get` | Lấy danh sách dữ liệu. |
| 4 | `usp_GetMaterialQcInfo_ForReport` | ???? ??? ??? |
| 5 | `usp_GetProdRouteBarcodeForDefect_E27` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (14)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoUpdateMaterialQcInfo_Success` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoUpdateMaterialQcInfo_Fail` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoMakeMaterialQcSampleResult` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_MaterialQcDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_MaterialQcSampleResult_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_MaterialQcInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoMakeMaterialIQCDetailList` | ?? ? ?????? ??? ?????. |
| 8 | `usp_DoUpdateMaterialQcInfo_Rescreening` | ????? ???? ???? ???????. |
| 9 | `usp_DoDeleteMaterialQcInfo` | ????Lot? ?????. |
| 10 | `usp_DoUpdateMaterialOQcInfoRemark` | ????? ???? ???. |
| 11 | `usp_RecentlyCellTestResultMax_get` | Thêm/Sửa/Xóa dữ liệu. |
| 12 | `usp_DoUpdateMaterialQcInfo_Hold` | ???? ???? ????? |
| 13 | `usp_DoUpdateMaterialQcInfo_Complete` | ???? ???? ????? |
| 14 | `usp_DoProcessProdInspCpkCalc` | ???? Cpk ?? |

### Actions/Buttons (19)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`UpdateRemark`** | Lưu ghi chú | Cập nhật các ghi chú và nhận xét chất lượng của nhân viên QC vào phiếu. Gọi SP usp_DoUpdateMaterialOQcInfoRemark. |
| 2 | **`ProdLotDelete`** | Prod Lot Delete | Thực hiện tác vụ prod lot delete cho dữ liệu trên màn hình. |
| 3 | **`MIIDoRescreening`** | M I I Do Rescreening | Thực hiện tác vụ m i i do rescreening cho dữ liệu trên màn hình. |
| 4 | **`MIIDoFailure`** | Phê duyệt FAIL | Đánh giá Lot hàng không đạt (FAIL), khóa xuất kho và yêu cầu xử lý. Gọi SP usp_DoUpdateMaterialQcInfo_Fail. |
| 5 | **`MIIDoSuccess`** | Phê duyệt PASS | Đánh giá Lot hàng đạt chất lượng OQC (PASS) và cho phép chuyển tiếp. Gọi SP usp_DoUpdateMaterialQcInfo_Success. |
| 6 | **`SetAllPassByItem`** | Pass theo hạng mục | Đánh giá đạt (PASS) cho các hạng mục QC đang chọn. |
| 7 | **`MakeSampleResult`** | Tạo mẫu đo | Khởi tạo dòng kết quả đo mẫu thử QC dựa trên cỡ mẫu quy định. |
| 8 | **`RefreshMIIList`** | Refresh | Làm mới danh sách hạng mục kiểm tra QC. |
| 9 | **`RefreshSampleList`** | Refresh | Làm mới danh sách các mẫu đo lường QC. |
| 10 | **`ImportIqcInspectionItem`** | Import hạng mục QC | Import danh sách hạng mục kiểm định chất lượng từ cấu hình master. |
| 11 | **`SetAllPass`** | Pass tất cả | Đánh giá đạt (PASS) nhanh cho tất cả hạng mục kiểm tra QC. |
| 12 | **`ProdInspectionLotList`** | Prod Inspection Lot List | Thực hiện tác vụ prod inspection lot list cho dữ liệu trên màn hình. |
| 13 | **`QcListRefresh`** | Qc List Refresh | Thực hiện tác vụ qc list refresh cho dữ liệu trên màn hình. |
| 14 | **`Reflection`** | Reflection | Thực hiện tác vụ reflection cho dữ liệu trên màn hình. |
| 15 | **`RefreshSampleResultList`** | Refresh | Thực hiện tác vụ refresh cho dữ liệu trên màn hình. |
| 16 | **`DoUpdateHold`** | Cập nhật Hold | Thực hiện tác vụ cập nhật hold cho dữ liệu trên màn hình. |
| 17 | **`DoUpdateCharComplte`** | Cập nhật Char Complte | Thực hiện tác vụ cập nhật char complte cho dữ liệu trên màn hình. |
| 18 | **`GetCpk`** | Tải Cpk | Thực hiện tác vụ tải cpk cho dữ liệu trên màn hình. |
| 19 | **`RefreshView2`** | Làm mới View2 | Thực hiện tác vụ làm mới view2 cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_MATERIALVENDORMAPPING` | Ánh xạ mã vật tư nội bộ với mã nhà cung cấp. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_CREATEMARKINGLETTERANDQTYFORBARCODE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_OQCDETAILSAMPLEQTY_VVT` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_SAVEPACKINGTIME_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCDETAIL` | Chi tiết các hạng mục kiểm định của phiếu QC. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_QCINSPECTIONITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SDINFORBYLOT` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ESRVALUEMONITOR` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCSAMPLERESULT` | Kết quả đo lường chi tiết các mẫu thử QC. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_IQCDEFECTREPORT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_DEFECTINFO` | Chi tiết các mã lỗi phế phẩm của hệ thống. |
| `STB_DEFECTGROUP` | Danh mục nhóm lỗi phế phẩm sản xuất. |
| `STB_NCR_REPORT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCINSPECTIONITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCINSPECTIONGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_QCINSPECTIONGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Sửa hạng mục ở C151 nhưng C530 không hiện | Chưa ấn "Tổng hợp hạng mục" | Vào C530 → ấn nút "Tổng hợp hạng mục" để reset | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | OQC bị lỗi khi bấm Reject nhưng muốn Pass lại | Nút Pass bị disable sau Reject | ⚠️ `CommInspResult` KHÔNG phải cột trong DB — OQC Pass/Fail được xử lý qua SP `usp_DoUpdateMaterialQcInfo_Success/Fail`. Cách fix: (1) Xóa MaterialQcInfo cũ bằng `usp_DoDeleteMaterialQcInfo`, (2) Tạo lại OQC mới tại C512, (3) Nhập lại kết quả QC. Xem [KB_26 §4.2](KB_26/KB_26_01_LINKS_BUGS.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## C321 — VietnamPQC_ReliabilityAssay
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C321` |
| **Screen Name** | `VietnamPQC_ReliabilityAssay` |
| **Parent Menu** | `vi_PQC` |
| **Title** | PQC_Reliability_Assay |
| **Tổng Objects** | **13** (3 View + 3 SearchFunction + 1 ExecuteFunction + 6 Action) |

### Workflow

1. Truy cập giao diện `VietnamPQC_ReliabilityAssay` để thực hiện cấu hình hoặc tra cứu.
2. Tra cứu dữ liệu hiện có trên Grid hiển thị.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DefectRepairInfo_ForRepair` | DefectRepairInfo_ForRepair | Grid hiển thị dữ liệu. |
| 2 | `DefectRepairDetailInfo_ForRepair` | DefectRepairDetailInfo_ForRepair | Grid hiển thị dữ liệu. |
| 3 | `DefectRepairPartInfo` | DefectRepairPartInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_GetDefectRepairInfo_ForRepair` | Lấy danh sách dữ liệu. |
| 2 | `usp_GetDefectRepairDetailInfo_ForRepair` | ????????? ?????. |
| 3 | `usp_GetDefectRepairPartInfo` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoProcessLossForBarcode_VNT` | ?? ???? |

### Actions/Buttons (6)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`btnNewRepair`** | NewRepair | Thực hiện tác vụ newrepair cho dữ liệu trên màn hình. |
| 2 | **`DefectRepairDetailDialog2`** | Defect Repair Detail Dialog2 | Thực hiện tác vụ defect repair detail dialog2 cho dữ liệu trên màn hình. |
| 3 | **`ProcessLoss`** | Process Loss | Thực hiện tác vụ process loss cho dữ liệu trên màn hình. |
| 4 | **`btnModifyRepair`** | ModifyRepair | Thực hiện tác vụ modifyrepair cho dữ liệu trên màn hình. |
| 5 | **`????`** | Refresh | Thực hiện tác vụ refresh cho dữ liệu trên màn hình. |
| 6 | **`DefectRepairDetailDialog`** | Defect Repair Detail Dialog | Thực hiện tác vụ defect repair detail dialog cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VIETNAMPQCRELIABILITYASSAY` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Lưu sửa chữa lỗi → sai lệch DefectQty ở trạm tiếp | Đồng bộ giữa `STB_DefectRepairInfo` và `STB_ProdRouteHist` bị lệch | IT chỉnh sửa DefectQty/ProdQty trực tiếp DB | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## C522 — Aging_ESR_SD
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C522` |
| **Screen Name** | `Aging_ESR_SD` |
| **Parent Menu** | `vi_PQC` |
| **Title** | Aging_ESR_SD |
| **Tổng Objects** | **38** (5 View + 5 SearchFunction + 12 ExecuteFunction + 16 Action) |

### Workflow

Giao diện **Aging_ESR_SD** dùng để thực hiện nghiệp vụ: **Aging ESR SD**.

**Workflow vận hành:**
1. Truy cập vào chức năng `Aging_ESR_SD` từ menu `KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_Vietnam_GetMaterialAgingInfo`.

**Lưu ý vận hành:**
- Data Aging/ESR không đồng bộ


### Views (5)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialQcInfoSampleList` | ?????????? | Grid hiển thị dữ liệu. |
| 2 | `MaterialQcDetailSampleList` | ????????? | Grid hiển thị dữ liệu. |
| 3 | `MaterialSampleResult` | ????????? | Grid hiển thị dữ liệu. |
| 4 | `MaterialQcInfo_ForReport` | MaterialQcInfo_ForReport | Grid hiển thị dữ liệu. |
| 5 | `OQC_Bad_List` | ProdRouteBarcodeForDefect_E27 | Grid hiển thị dữ liệu. |

### SearchFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_GetMaterialAgingInfo` | Lấy danh sách dữ liệu. |
| 2 | `usp_Vietnam_MaterialAgingDetail_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_MaterialQcSampleResult_get` | Lấy danh sách dữ liệu. |
| 4 | `usp_GetMaterialQcInfo_ForReport` | ???? ??? ??? |
| 5 | `usp_GetProdRouteBarcodeForDefect_E27` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (12)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoUpdateMaterialQcInfo_Success` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoUpdateMaterialQcInfo_Fail` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoMakeMaterialQcSampleResult` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_MaterialQcDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_MaterialQcSampleResult_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_MaterialQcInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoMakeMaterialIQCDetailList` | ?? ? ?????? ??? ?????. |
| 8 | `usp_DoUpdateMaterialQcInfo_Rescreening` | ????? ???? ???? ???????. |
| 9 | `usp_DoDeleteMaterialQcInfo` | ????Lot? ?????. |
| 10 | `usp_DoUpdateMaterialOQcInfoRemark` | ????? ???? ???. |
| 11 | `usp_RecentlyCellTestResultMax_get` | Thêm/Sửa/Xóa dữ liệu. |
| 12 | `usp_DoUpdateMaterialQcInfo_Hold` | ???? ???? ????? |

### Actions/Buttons (16)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`UpdateRemark`** | Lưu ghi chú | Cập nhật các ghi chú và nhận xét chất lượng của nhân viên QC vào phiếu. Gọi SP usp_DoUpdateMaterialOQcInfoRemark. |
| 2 | **`ProdLotDelete`** | Prod Lot Delete | Thực hiện tác vụ prod lot delete cho dữ liệu trên màn hình. |
| 3 | **`MIIDoRescreening`** | M I I Do Rescreening | Thực hiện tác vụ m i i do rescreening cho dữ liệu trên màn hình. |
| 4 | **`MIIDoFailure`** | Phê duyệt FAIL | Đánh giá Lot hàng không đạt (FAIL), khóa xuất kho và yêu cầu xử lý. Gọi SP usp_DoUpdateMaterialQcInfo_Fail. |
| 5 | **`MIIDoSuccess`** | Phê duyệt PASS | Đánh giá Lot hàng đạt chất lượng OQC (PASS) và cho phép chuyển tiếp. Gọi SP usp_DoUpdateMaterialQcInfo_Success. |
| 6 | **`SetAllPassByItem`** | Pass theo hạng mục | Đánh giá đạt (PASS) cho các hạng mục QC đang chọn. |
| 7 | **`MakeSampleResult`** | Tạo mẫu đo | Khởi tạo dòng kết quả đo mẫu thử QC dựa trên cỡ mẫu quy định. |
| 8 | **`RefreshMIIList`** | Refresh | Làm mới danh sách hạng mục kiểm tra QC. |
| 9 | **`RefreshSampleList`** | Refresh | Làm mới danh sách các mẫu đo lường QC. |
| 10 | **`ImportIqcInspectionItem`** | Import hạng mục QC | Import danh sách hạng mục kiểm định chất lượng từ cấu hình master. |
| 11 | **`SetAllPass`** | Pass tất cả | Đánh giá đạt (PASS) nhanh cho tất cả hạng mục kiểm tra QC. |
| 12 | **`ProdInspectionLotList`** | Prod Inspection Lot List | Thực hiện tác vụ prod inspection lot list cho dữ liệu trên màn hình. |
| 13 | **`QcListRefresh`** | Qc List Refresh | Thực hiện tác vụ qc list refresh cho dữ liệu trên màn hình. |
| 14 | **`Reflection`** | Reflection | Thực hiện tác vụ reflection cho dữ liệu trên màn hình. |
| 15 | **`RefreshSampleResultList`** | Refresh | Thực hiện tác vụ refresh cho dữ liệu trên màn hình. |
| 16 | **`DoUpdateHold`** | Cập nhật Hold | Thực hiện tác vụ cập nhật hold cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALVENDORMAPPING` | Ánh xạ mã vật tư nội bộ với mã nhà cung cấp. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_QC_LOTNO_MODULE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_MATERIALQCDETAIL` | Chi tiết các hạng mục kiểm định của phiếu QC. |
| `STB_MATERIALQCINSPECTIONITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCSAMPLERESULT` | Kết quả đo lường chi tiết các mẫu thử QC. |
| `STB_SDINFORBYLOT` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ESRVALUEMONITOR` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_IQCDEFECTREPORT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_DEFECTINFO` | Chi tiết các mã lỗi phế phẩm của hệ thống. |
| `STB_DEFECTGROUP` | Danh mục nhóm lỗi phế phẩm sản xuất. |

---

## B934 — esrAgingSD_csv
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B934` |
| **Screen Name** | `esrAgingSD_csv` |
| **Parent Menu** | `vi_PQC` |
| **Title** | esrAgingSD_csv |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Import dữ liệu đo thông số ESR và kết quả Aging của dòng sản phẩm SD từ file CSV vào hệ thống MES.
2. Thực hiện kiểm tra định dạng dữ liệu đầu vào và ghi nhận lịch sử import.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VN_esrAgingSD_import` | VN_esrAgingSD_import | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VN_esrAgingSD_import_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VN_esrAgingSD_import_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVT_SDProds_New` | Lưu trữ toàn bộ kết quả đo lường ESR/Aging của sản phẩm SD phục vụ phân tích chất lượng. |

---

## B935 — esrAgingSD_get
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B935` |
| **Screen Name** | `esrAgingSD_get` |
| **Parent Menu** | `vi_PQC` |
| **Title** | esr AgingSD view |
| **Tổng Objects** | **2** (1 View + 1 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Truy cập giao diện để tra cứu kết quả ESR và trạng thái Aging của sản phẩm SD đã lưu trữ.
2. Hỗ trợ bộ phận QC quét barcode kiểm tra nhanh thông số kỹ thuật của Lot.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VN_esrAgingSD` | VN_esrAgingSD | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VN_esrAgingSD_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVT_SDProds_New` | Cơ sở dữ liệu chính chứa kết quả đo ESR/Aging để đối chiếu. |

---

## C531 — vvt_ProdRouteForPacking_OQC
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C531` |
| **Screen Name** | `vvt_ProdRouteForPacking_OQC` |
| **Parent Menu** | `vi_OQC` |
| **Title** | vvt_ProdRouteForPacking_OQC |
| **Tổng Objects** | **25** (1 View + 3 SearchFunction + 4 ExecuteFunction + 17 Action) |

### Workflow

Giao diện **vvt_ProdRouteForPacking_OQC** dùng để thực hiện nghiệp vụ: **OQC Packing**.

**Workflow vận hành:**
1. Truy cập vào chức năng `vvt_ProdRouteForPacking_OQC` từ menu `KB_04`.

**Lưu ý vận hành:**
- Chọn nhầm cấp → sửa levelB


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdPackingForBarcode` | ProdPackingForBarcode | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetProdOQCgForBarcode_VVT` | ??? ?? ?? |
| 2 | `usp_ProdRouteHist_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_GetBoxIDForLotNo_VNT` | ???? ?? ??? ?? ??? ??? ????? |

### ExecuteFunctions (4)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoProcessOQCrefer_VVT` | ????????? ?????. |
| 2 | `usp_DoProcessProdPackingByOne_VNT` | BoxID? ????? |
| 3 | `usp_DoCancelProdPacking_LotNo` | ????? ???????. |
| 4 | `usp_DoCreatePackingLabelInfo` | ?? ???? ?? |

### Actions/Buttons (17)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`VietnamBoxLabelPrint`** | Vietnam Box Label Print | Thực hiện tác vụ vietnam box label print cho dữ liệu trên màn hình. |
| 2 | **`DoCancelProdPacking`** | Hủy Prod Packing | Thực hiện tác vụ hủy prod packing cho dữ liệu trên màn hình. |
| 3 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 4 | **`MergeBox`** | Merge Box | Thực hiện tác vụ merge box cho dữ liệu trên màn hình. |
| 5 | **`DoProductionByBoxCount`** | Production By Box Count | Thực hiện tác vụ production by box count cho dữ liệu trên màn hình. |
| 6 | **`LabelPrint`** | In tem | Thực hiện in tem nhãn sản phẩm hoặc vật tư. |
| 7 | **`InputLabelQty`** | SL in tem | Nhập số lượng tem nhãn cần in cho Lot. |
| 8 | **`LotRefresh`** | Lot Refresh | Thực hiện tác vụ lot refresh cho dữ liệu trên màn hình. |
| 9 | **`DeleteData`** | Xóa dòng | Xóa dữ liệu dòng đang chọn khỏi lưới. |
| 10 | **`Refresh11`** | Refresh11 | Thực hiện tác vụ refresh11 cho dữ liệu trên màn hình. |
| 11 | **`SaveLabelInfo`** | Lưu Label Info | Thực hiện tác vụ lưu label info cho dữ liệu trên màn hình. |
| 12 | **`HelaBarcodePrint`** | Hela Barcode Print | Thực hiện tác vụ hela barcode print cho dữ liệu trên màn hình. |
| 13 | **`InputBoxQty`** | Input Box Qty | Thực hiện tác vụ input box qty cho dữ liệu trên màn hình. |
| 14 | **`OnlyRefresh`** | Only Refresh | Thực hiện tác vụ only refresh cho dữ liệu trên màn hình. |
| 15 | **`DeleteAndRefresh`** | Xóa And Refresh | Thực hiện tác vụ xóa and refresh cho dữ liệu trên màn hình. |
| 16 | **`PackingLotRemainQty`** | Packing Lot Remain Qty | Thực hiện tác vụ packing lot remain qty cho dữ liệu trên màn hình. |
| 17 | **`BoxIDInfoRefresh`** | Box I D Info Refresh | Thực hiện tác vụ box i d info refresh cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVTPRODROUTEFORPACKINGOQC` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## C541 — VVT_ProdInspectionHist_vvt
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C541` |
| **Screen Name** | `VVT_ProdInspectionHist_vvt` |
| **Parent Menu** | `vi_OQC` |
| **Title** | VVT_ProdInspectionHist_vvt |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Quản lý lịch sử kiểm định chất lượng ngoại quan (OQC) cho thành phẩm.
2. Cho phép cập nhật thông tin Remark/Ghi chú của QC Audit đối với từng Lot kiểm tra.
3. Hiển thị thông số kích thước, ngoại quan, kết quả đo mẫu thử và thông tin nhân viên thực hiện.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdInspectionHist` | ProdInspectionHist | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVT_ProdInspectionHist_vvt_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoUpdateMaterialOQcInfoRemark` | ????? ???? ???. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`????`** | UpdateRemark | Thực hiện tác vụ updateremark cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialQcInfo` | Thông tin phiếu kiểm định QC OQC tổng quan. |
| `STB_MaterialQcSampleResult` | Lưu trữ chi tiết kết quả đo lường các mẫu thử QC OQC. |

---

## C546 — FOQC_MaterialOqcInfoSampleManagement
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C546` |
| **Screen Name** | `FOQC_MaterialOqcInfoSampleManagement` |
| **Parent Menu** | `vi_OQC` |
| **Title** | FOQC_??????? |
| **Tổng Objects** | **38** (5 View + 5 SearchFunction + 12 ExecuteFunction + 16 Action) |

### Workflow

Giao diện **FOQC_MaterialOqcInfoSampleManagement** dùng để thực hiện nghiệp vụ: **FOQC OCV/ESR**.

**Workflow vận hành:**
1. Truy cập vào chức năng `FOQC_MaterialOqcInfoSampleManagement` từ menu `KB_05, KB_31, KB_32`.

**Lưu ý vận hành:**
- OCV/ESR hiển thị 20ea thay vì 50ea


### Views (5)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialQcInfoSampleList` | ?????????? | Grid hiển thị dữ liệu. |
| 2 | `MaterialQcDetailSampleList` | ????????? | Grid hiển thị dữ liệu. |
| 3 | `MaterialSampleResult` | ????????? | Grid hiển thị dữ liệu. |
| 4 | `MaterialQcInfo_ForReport` | MaterialQcInfo_ForReport | Grid hiển thị dữ liệu. |
| 5 | `OQC_Bad_List` | ProdRouteBarcodeForDefect_E27 | Grid hiển thị dữ liệu. |

### SearchFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_GetMaterialFOQCInfo` | Lấy danh sách dữ liệu. |
| 2 | `usp_Vietnam_MaterialFOQcDetail_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_MaterialQcSampleResult_get` | Lấy danh sách dữ liệu. |
| 4 | `usp_GetMaterialQcInfo_ForReport` | ???? ??? ??? |
| 5 | `usp_GetProdRouteBarcodeForDefect_E27` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (12)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoUpdateMaterialQcInfo_Success` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoUpdateMaterialQcInfo_Fail` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoMakeMaterialQcSampleResult` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_MaterialQcDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_MaterialQcSampleResult_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_MaterialQcInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoMakeMaterialIQCDetailList` | ?? ? ?????? ??? ?????. |
| 8 | `usp_DoUpdateMaterialQcInfo_Rescreening` | ????? ???? ???? ???????. |
| 9 | `usp_DoDeleteMaterialQcInfo` | ????Lot? ?????. |
| 10 | `usp_DoUpdateMaterialOQcInfoRemark` | ????? ???? ???. |
| 11 | `usp_RecentlyCellTestResultMax_get` | Thêm/Sửa/Xóa dữ liệu. |
| 12 | `usp_DoUpdateMaterialQcInfo_Hold` | ???? ???? ????? |

### Actions/Buttons (16)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`UpdateRemark`** | Lưu ghi chú | Cập nhật các ghi chú và nhận xét chất lượng của nhân viên QC vào phiếu. Gọi SP usp_DoUpdateMaterialOQcInfoRemark. |
| 2 | **`ProdLotDelete`** | Prod Lot Delete | Thực hiện tác vụ prod lot delete cho dữ liệu trên màn hình. |
| 3 | **`MIIDoRescreening`** | M I I Do Rescreening | Thực hiện tác vụ m i i do rescreening cho dữ liệu trên màn hình. |
| 4 | **`MIIDoFailure`** | Phê duyệt FAIL | Đánh giá Lot hàng không đạt (FAIL), khóa xuất kho và yêu cầu xử lý. Gọi SP usp_DoUpdateMaterialQcInfo_Fail. |
| 5 | **`MIIDoSuccess`** | Phê duyệt PASS | Đánh giá Lot hàng đạt chất lượng OQC (PASS) và cho phép chuyển tiếp. Gọi SP usp_DoUpdateMaterialQcInfo_Success. |
| 6 | **`SetAllPassByItem`** | Pass theo hạng mục | Đánh giá đạt (PASS) cho các hạng mục QC đang chọn. |
| 7 | **`MakeSampleResult`** | Tạo mẫu đo | Khởi tạo dòng kết quả đo mẫu thử QC dựa trên cỡ mẫu quy định. |
| 8 | **`RefreshMIIList`** | Refresh | Làm mới danh sách hạng mục kiểm tra QC. |
| 9 | **`RefreshSampleList`** | Refresh | Làm mới danh sách các mẫu đo lường QC. |
| 10 | **`ImportIqcInspectionItem`** | Import hạng mục QC | Import danh sách hạng mục kiểm định chất lượng từ cấu hình master. |
| 11 | **`SetAllPass`** | Pass tất cả | Đánh giá đạt (PASS) nhanh cho tất cả hạng mục kiểm tra QC. |
| 12 | **`ProdInspectionLotList`** | Prod Inspection Lot List | Thực hiện tác vụ prod inspection lot list cho dữ liệu trên màn hình. |
| 13 | **`QcListRefresh`** | Qc List Refresh | Thực hiện tác vụ qc list refresh cho dữ liệu trên màn hình. |
| 14 | **`Reflection`** | Reflection | Thực hiện tác vụ reflection cho dữ liệu trên màn hình. |
| 15 | **`RefreshSampleResultList`** | Refresh | Thực hiện tác vụ refresh cho dữ liệu trên màn hình. |
| 16 | **`DoUpdateHold`** | Cập nhật Hold | Thực hiện tác vụ cập nhật hold cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_FOQCMATERIALOQCINFOSAMPLEMANAGEMENT` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | OCV chỉ hiện 20 dòng thay vì 50 | SP `usp_Vietnam_MaterialFOQcDetail_get` thiếu block WHILE cho DetailNo=2 (OCV) | Thêm block WHILE cho OCV — xem [KB_05 §9.6](KB_05/KB_05_01_QC_OVERVIEW.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## C564 — VVT_ProdInspectionHist_BendingCutting
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C564` |
| **Screen Name** | `VVT_ProdInspectionHist_BendingCutting` |
| **Parent Menu** | `vi_OQC` |
| **Title** | L?ch s? ki?m tra Bending Cutting |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Xem lịch sử kiểm định chất lượng chuyên biệt cho công đoạn uốn bẻ và cắt (Bending & Cutting).
2. Theo dõi các thông số đo đạc cơ lý của cực điện sau cắt bẻ, cập nhật các ghi chú xử lý của QC.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdInspectionHist_BendingCutting` | ProdInspectionHist_BendingCutting | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProdInspectionHist_get_BendingCutting` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoUpdateMaterialOQcInfoRemark_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`UpdateRemark`** | Lưu ghi chú | Cập nhật các ghi chú và nhận xét chất lượng của nhân viên QC vào phiếu. Gọi SP usp_DoUpdateMaterialOQcInfoRemark. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialQcInfo_BendingCutting` | Đầu phiếu kiểm định công đoạn Bending/Cutting. |
| `STB_MaterialQcSampleResult_BendingCutting` | Kết quả chi tiết các thông số đo đạc mẫu thử Bending/Cutting. |

---

## C430 — VNT_RouteInspectionMeasureFullHist
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C430` |
| **Screen Name** | `VNT_RouteInspectionMeasureFullHist` |
| **Parent Menu** | `Process inspection` |
| **Title** | VNT_RouteInspectionMeasureFullHist |
| **Tổng Objects** | **2** (1 View + 1 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **VNT_RouteInspectionMeasureFullHist** dùng để thực hiện nghiệp vụ: **QC Receiving**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_RouteInspectionMeasureFullHist` từ menu `KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VNT_RouteInspectionMeasureFullHist_get`.

**Lưu ý vận hành:**
- Không tìm thấy Lot NVL


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CommInspectionMeasureFullHist` | RouteInspectionMeasureFullHist | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_CommInspectionMeasureFullHist_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VNTROUTEINSPECTIONMEASUREFULLHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## C443 — Vietnam_inspectionPQC
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C443` |
| **Screen Name** | `Vietnam_inspectionPQC` |
| **Parent Menu** | `vi_PQC` |
| **Title** | Vietnam_inspectionPQC |
| **Tổng Objects** | **13** (1 View + 1 SearchFunction + 4 ExecuteFunction + 7 Action) |

### Workflow

Giao diện **Vietnam_inspectionPQC** dùng để thực hiện nghiệp vụ: **PQC Verification**.

**Workflow vận hành:**
1. Truy cập vào chức năng `Vietnam_inspectionPQC` từ menu `KB_05, KB_31, KB_32`.

**Lưu ý vận hành:**
- Hủy/xác định lại kết quả QC. Xóa trong CommInspDocHistory/Item


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CommInspectionHistoryForBarcode` | CommInspectionHistoryForBarcode | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetCommInspection_HistoryForBarcode_Vietnam` | ???????? |

### ExecuteFunctions (4)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoAddCommInspMeasureHistForBarcode` | ?? ????? ?? ???. |
| 2 | `usp_DoFinishCommInspDoc` | ?? ??? ??????? |
| 3 | `usp_DoFinishCommInspDoc_VNT` | ?? ??? ??????? |
| 4 | `usp_DoAddCommInspMeasureHistForBarcode_Vietnam` | ?? ????? ?? ???. |

### Actions/Buttons (7)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoLossCommInspDialog`** | Popup Loss | Mở cửa sổ nhập hao hụt/phế liệu công đoạn. |
| 2 | **`DoFinishCommInsp`** | Hoàn thành QC | Xác nhận hoàn tất quá trình kiểm định chất lượng tài liệu QC. |
| 3 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 4 | **`DoHoldCommInsp`** | Khóa Lot (HOLD) | Đưa Lot hàng sang trạng thái HOLD (tạm khóa chất lượng) để kiểm định thêm. |
| 5 | **`DoLossCommInsp`** | Ghi nhận Loss | Ghi nhận lượng hao hụt/phế liệu phát sinh tại công đoạn kiểm tra. |
| 6 | **`InputDefectCode`** | Nhập mã lỗi | Mở cửa sổ chọn và gán mã lỗi phế phẩm cho sản phẩm. |
| 7 | **`SetHolding`** | HOLD Lot | Thiết lập trạng thái HOLD (tạm dừng sử dụng) đối với Lot. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VIETNAMINSPECTIONPQC` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Cần hủy kết quả QC (nhập nhầm) | Data đã ghi vào `STB_CommInspDocHistory` + `STB_CommInspDocItem` | Xóa để QC làm lại: | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## C451 — SelfInspectionHistoryForBarcode2
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C451` |
| **Screen Name** | `SelfInspectionHistoryForBarcode2` |
| **Parent Menu** | `CommInspManagement` |
| **Title** | ???????(???) |
| **Tổng Objects** | **12** (1 View + 1 SearchFunction + 3 ExecuteFunction + 7 Action) |

### Workflow

Giao diện **SelfInspectionHistoryForBarcode2** dùng để thực hiện nghiệp vụ: **OQC Schedule**.

**Workflow vận hành:**
1. Truy cập vào chức năng `SelfInspectionHistoryForBarcode2` từ menu `KB_05, KB_31`.

**Lưu ý vận hành:**
- Lịch OQC không hiển thị Lot


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CommInspectionHistoryForBarcode` | SelfInspectionHistoryForBarcode | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetCommInspectionHistoryForBarcode` | ???????? |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoAddCommInspMeasureHistForBarcode` | ?? ????? ?? ???. |
| 2 | `usp_DoFinishCommInspDoc` | ?? ??? ??????? |
| 3 | `usp_DoFinishCommInspDoc_VNT` | ?? ??? ??????? |

### Actions/Buttons (7)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoLossCommInspDialog`** | Popup Loss | Mở cửa sổ nhập hao hụt/phế liệu công đoạn. |
| 2 | **`DoFinishCommInsp`** | Hoàn thành QC | Xác nhận hoàn tất quá trình kiểm định chất lượng tài liệu QC. |
| 3 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 4 | **`DoHoldCommInsp`** | Khóa Lot (HOLD) | Đưa Lot hàng sang trạng thái HOLD (tạm khóa chất lượng) để kiểm định thêm. |
| 5 | **`DoLossCommInsp`** | Ghi nhận Loss | Ghi nhận lượng hao hụt/phế liệu phát sinh tại công đoạn kiểm tra. |
| 6 | **`InputDefectCode`** | Nhập mã lỗi | Mở cửa sổ chọn và gán mã lỗi phế phẩm cho sản phẩm. |
| 7 | **`SetHolding`** | HOLD Lot | Thiết lập trạng thái HOLD (tạm dừng sử dụng) đối với Lot. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SELFINSPECTIONHISTORYFORBARCODE2` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Load lại hạng mục cũ, không cho sửa | Cache QC document từ lần trước | Xóa CommInspDoc cũ rồi tạo lại — xem C443 | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## C585 — VVT_DoCreateDefectOQC
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C585` |
| **Screen Name** | `VVT_DoCreateDefectOQC` |
| **Parent Menu** | `vi_OQC` |
| **Title** | VVT Th�m chi ti?t l?i theo Lot |
| **Tổng Objects** | **5** (1 View + 1 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

Giao diện **VVT_DoCreateDefectOQC** dùng để thực hiện nghiệp vụ: **VVT Thêm chi tiết lỗi theo Lot**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VVT_DoCreateDefectOQC` từ menu `KB_05`.

**Lưu ý vận hành:**
- Popup DefectDivisionCode dùng `GetBaseCode2` → `SmartFramework.STB_BaseCode` (CodeGroup='DefectDivisionCode')


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `QCDefectDetailsRecordDummy` | QCDefectDetailsRecordDummy | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_QCDefectDetailsRecordDummy_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoCreateQCDefectDetailsRecord_iud` | Create QC Defect Details |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`RefreshAll`** | Làm mới All | Thực hiện tác vụ làm mới all cho dữ liệu trên màn hình. |
| 2 | **`DeleteAll`** | Xóa All | Thực hiện tác vụ xóa all cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVTDOCREATEDEFECTOQC` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Dropdown "Tên phân loại lỗi" có mã 05, 06 trùng với 03, 07 | `SmartFramework.STB_BaseCode` (CodeGroup='DefectDivisionCode') chứa entries trùng: 05=제품검사(베트남) trùng 03=제품검사, 06=출하검사(베트남) trùng 07=FOQC | Cập nhật bản ghi giao dịch: `UPDATE STB_QCDefectDetailsRecord SET DefectDivisionCode='03' WHERE DefectDivisionCode='05'`, tương tự 06→07. Sau đó xóa: `DELETE FROM SmartFramework.dbo.STB_BaseCode WHERE CodeGroup='DefectDivisionCode' AND ItemCode IN ('05','06')`. Script: `SQL_Scripts/C585_delete_defect_division_05_06.sql` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

# BƯỚC 7: ĐÓNG GÓI THÀNH PHẨM & IN TEM NHÃN

*Đóng gói sản phẩm vào Box, Taping, cân trọng lượng, in nhãn đóng gói, nhãn thùng carton PAC và nhãn riêng cho khách hàng Digikey.*

---

## B453 — Vietnam_PrintLabelSchneider
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B453` |
| **Screen Name** | `Vietnam_PrintLabelSchneider` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Vietnam_PrintLabelSchneider |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 0 ExecuteFunction + 2 Action) |

### Workflow

1. Cấu hình và thực hiện in tem nhãn đóng gói chuyên dụng cho đối tác khách hàng Schneider.
2. Quét mã Lot sản xuất để hệ thống tự động đối chiếu thông số từ các cấu hình tem nhãn `STB_PackingLabelSpec`, `STB_ModelLabelInfo` trước khi ra lệnh in.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `SetLabelGenus_VVT_Info` | SetLabelGenus_VVT_Info | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_SetLabelGenus_VVT_Info_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`OuterPrint`** | In tem OUTER | Thực hiện tác vụ in tem outer cho dữ liệu trên màn hình. |
| 2 | **`InnerPrint`** | In tem INNER | Thực hiện tác vụ in tem inner cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_Vietnam_PackingPrinting` | Lưu trữ lịch sử in ấn tem nhãn đóng gói thực tế. |
| `STB_PackingLabelSpec` | Cấu hình quy cách, kích thước và thông tin in ấn tem nhãn đóng gói. |

---

## B523 — Vietnam_Donggoi
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B523` |
| **Screen Name** | `Vietnam_Donggoi` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Vietnam_Donggoi |
| **Tổng Objects** | **52** (3 View + 3 SearchFunction + 10 ExecuteFunction + 36 Action) |

### Workflow

Giao diện **Vietnam_Donggoi** dùng để thực hiện nghiệp vụ: **Đóng gói & In tem**.

**Workflow vận hành:**
1. Truy cập vào chức năng `Vietnam_Donggoi` từ menu `KB_03, KB_04, KB_31, KB_32`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_ProdRouteHist_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_Vietnam_DoProcessProdPacking_VVT`.

**Lưu ý vận hành:**
- Lỗi Packing Qty âm, gộp box auto


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdPackingForBarcode` | ProdPackingForBarcode | Grid hiển thị dữ liệu. |
| 2 | `ProdRouteHist` | ProdRouteHist | Grid hiển thị dữ liệu. |
| 3 | `BoxIDForLotNo_VNT` | BoxIDForLotNo_VNT | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_GetProdPackingForBarcode_VVT` | ??? ?? ?? |
| 2 | `usp_ProdRouteHist_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_Vietnam_GetBoxIDForLotNo_VVT` | ???? ?? ??? ?? ??? ??? ????? |

### ExecuteFunctions (10)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_DoProcessProdPacking_VVT` | ????????? ?????. |
| 2 | `usp_DoProcessProdPackingByOne_VNT` | BoxID? ????? |
| 3 | `usp_DoCancelProdPacking_LotNo` | ????? ???????. |
| 4 | `usp_DoCreatePackingLabelInfo` | ?? ???? ?? |
| 5 | `usp_savePackingLabelQty_VVT` | ???? ?? ??? ?? ??? ??? ????? |
| 6 | `usp_BoxCheckSetupValue` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_BoxCheckSetupValueTwo` | Thêm/Sửa/Xóa dữ liệu. |
| 8 | `usp_SplitPackingBox` | Thêm/Sửa/Xóa dữ liệu. |
| 9 | `usp_PackingLabelPrintInfo` | Thêm/Sửa/Xóa dữ liệu. |
| 10 | `usp_ZYSLabelPrintHist_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (36)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ChonSoLuongIntem`** | Ch?n s? lu?ng in tem | Thực hiện tác vụ ch?n s? lu?ng in tem cho dữ liệu trên màn hình. |
| 2 | **`DoCancelProdPacking`** | Hủy Prod Packing | Thực hiện tác vụ hủy prod packing cho dữ liệu trên màn hình. |
| 3 | **`Refresh2`** | Refresh2 | Thực hiện tác vụ refresh2 cho dữ liệu trên màn hình. |
| 4 | **`MergeBox`** | Merge Box | Thực hiện tác vụ merge box cho dữ liệu trên màn hình. |
| 5 | **`DoProductionByBoxCount`** | Production By Box Count | Thực hiện tác vụ production by box count cho dữ liệu trên màn hình. |
| 6 | **`LabelPrint`** | In tem | Thực hiện in tem nhãn sản phẩm hoặc vật tư. |
| 7 | **`InputLabelQty`** | In nhan | Nhập số lượng tem nhãn cần in cho Lot. |
| 8 | **`LotRefresh`** | Lot Refresh | Thực hiện tác vụ lot refresh cho dữ liệu trên màn hình. |
| 9 | **`DeleteData`** | Xóa dòng | Xóa dữ liệu dòng đang chọn khỏi lưới. |
| 10 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 11 | **`SaveLabelInfo`** | Luu Packing Qty | Thực hiện tác vụ luu packing qty cho dữ liệu trên màn hình. |
| 12 | **`HelaBarcodePrint`** | Hela Barcode Print | Thực hiện tác vụ hela barcode print cho dữ liệu trên màn hình. |
| 13 | **`InputBoxQty`** | In Tem & | Thực hiện tác vụ in tem & cho dữ liệu trên màn hình. |
| 14 | **`OnlyRefresh`** | Only Refresh | Thực hiện tác vụ only refresh cho dữ liệu trên màn hình. |
| 15 | **`DeleteAndRefresh`** | Xóa And Refresh | Thực hiện tác vụ xóa and refresh cho dữ liệu trên màn hình. |
| 16 | **`PackingLotRemainQty`** | Packing Lot Remain Qty | Thực hiện tác vụ packing lot remain qty cho dữ liệu trên màn hình. |
| 17 | **`BoxIDInfoRefresh`** | Box I D Info Refresh | Thực hiện tác vụ box i d info refresh cho dữ liệu trên màn hình. |
| 18 | **`SavePrintQty`** | Lưu Print Qty | Thực hiện tác vụ lưu print qty cho dữ liệu trên màn hình. |
| 19 | **`DoDummy`** | Dummy | Thực hiện tác vụ dummy cho dữ liệu trên màn hình. |
| 20 | **`PreMergeBox`** | Pre Merge Box | Thực hiện tác vụ pre merge box cho dữ liệu trên màn hình. |
| 21 | **`TapingLabel`** | In Label Taping | Thực hiện tác vụ in label taping cho dữ liệu trên màn hình. |
| 22 | **`SagemCom`** | Open Sagem | Thực hiện tác vụ open sagem cho dữ liệu trên màn hình. |
| 23 | **`PrintSagem`** | In Sagem | Thực hiện tác vụ in sagem cho dữ liệu trên màn hình. |
| 24 | **`Lotweightshow`** | Lot weight show | Thực hiện tác vụ lot weight show cho dữ liệu trên màn hình. |
| 25 | **`SetSagem1`** | Set.Sagem1 | Thực hiện tác vụ set.sagem1 cho dữ liệu trên màn hình. |
| 26 | **`SaveLabelInfo2`** | Lưu Label Info2 | Thực hiện tác vụ lưu label info2 cho dữ liệu trên màn hình. |
| 27 | **`PrintLabelWH`** | In Label W H | Thực hiện tác vụ in label w h cho dữ liệu trên màn hình. |
| 28 | **`IsLabelPrint`** | Is Label Print | Thực hiện tác vụ is label print cho dữ liệu trên màn hình. |
| 29 | **`SplitBoxQty`** | Chia box | Thực hiện tác vụ chia box cho dữ liệu trên màn hình. |
| 30 | **`SplitBoxQtyProc`** | Split Box Qty Proc | Thực hiện tác vụ split box qty proc cho dữ liệu trên màn hình. |
| 31 | **`IntemThepPartNo`** | In tem h?p | Thực hiện tác vụ in tem h?p cho dữ liệu trên màn hình. |
| 32 | **`ZYS_SetLotQty`** | In Tem ZYS | Thực hiện tác vụ in tem zys cho dữ liệu trên màn hình. |
| 33 | **`ZYS_IsLabelPrint`** | Z Y S_ Is Label Print | Thực hiện tác vụ z y s_ is label print cho dữ liệu trên màn hình. |
| 34 | **`ZYS_InputLabelQty`** | Z Y S_ Input Label Qty | Thực hiện tác vụ z y s_ input label qty cho dữ liệu trên màn hình. |
| 35 | **`ZYS_PrintLabel`** | Z Y S_ Print Label | Thực hiện tác vụ z y s_ print label cho dữ liệu trên màn hình. |
| 36 | **`ZYS_SavePrintHist`** | Z Y S_ Save Print Hist | Thực hiện tác vụ z y s_ save print hist cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_PRODUCTIONORDERROUTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_PRODROUTESUMMARY` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_PACKINGSTANDARD` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PACKINGLABELSPEC` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VIETNAM_PACKINGPRINTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SAVEPACKINGTIME_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VIETNAM_BARCODEWEIGHT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CHANGEPARTNOANDLOTNO` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PACKINGLABELPRINTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_CREATEMARKINGLETTERANDQTYFORBARCODE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_YEARINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PROCEDURELOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VN_FINISHGOODS_HN_NEW` | Lưu thông tin thành phẩm đóng gói mới tại Hà Nam. |
| `STB_PRODROUTEHISTCANCELHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODROUTEWORKERHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_ZYSLABELPRINTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Gộp box bị lỗi "Chưa có tiêu chuẩn đóng gói" | Thiếu config `STB_PackingQtyPerSize` cho Size sản phẩm | Xem A418 | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Gộp box bị lỗi "IsOutputRoute chưa thiết lập" | PO Routing thiếu cờ `IsOutputRoute=1` ở công đoạn cuối | `UPDATE STB_ProductionOrderRouting SET IsOutputRoute=1 WHERE PONo='mã' AND RouteCode='V-28'` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 3 | Gộp box HN523 lỗi Qty=0 | `STB_PackingStandard` thiếu record cho model Hà Nam | INSERT record vào `STB_PackingStandard` — xem [KB_04 §6.13](KB_04/KB_04_01_CORE_PACKAGING.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 4 | Gộp box lỗi do PO có công đoạn hậu đóng gói B523 | Thiếu lịch sử Route `V-28_BG` | Chèn dòng ProdRouteHist giả lập — xem [KB_04 §6.13.2](KB_04/KB_04_01_CORE_PACKAGING.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 5 | MergeQty không chia đúng khi gộp nhiều Lot | Logic `@pMergeQty < @total + @InProdQty` bị edge case | Kiểm tra số lượng Lot trước khi gộp, đảm bảo tổng = MergeQty | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B525 — Kho_Donggoi2
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B525` |
| **Screen Name** | `Kho_Donggoi2` |
| **Parent Menu** | `v_FinishGoods` |
| **Title** | Kho_Donggoi2 |
| **Tổng Objects** | **44** (3 View + 3 SearchFunction + 9 ExecuteFunction + 29 Action) |

### Workflow

Giao diện **Kho_Donggoi2** dùng để thực hiện nghiệp vụ: **Đóng gói kho**.

**Workflow vận hành:**
1. Truy cập vào chức năng `Kho_Donggoi2` từ menu `KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_ProdRouteHist_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_Vietnam_DoProcessProdPacking_VVT`.

**Lưu ý vận hành:**
- Khác B523


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdPackingForBarcode` | ProdPackingForBarcode | Grid hiển thị dữ liệu. |
| 2 | `ProdRouteHist` | ProdRouteHist | Grid hiển thị dữ liệu. |
| 3 | `BoxIDForLotNo_VNT` | BoxIDForLotNo_VNT | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_GetProdPackingForBarcode_VVT` | ??? ?? ?? |
| 2 | `usp_ProdRouteHist_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_Vietnam_GetBoxIDForLotNo_VVT` | ???? ?? ??? ?? ??? ??? ????? |

### ExecuteFunctions (9)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_DoProcessProdPacking_VVT` | ????????? ?????. |
| 2 | `usp_DoProcessProdPackingByOne_VNT` | BoxID? ????? |
| 3 | `usp_DoCancelProdPacking_LotNo` | ????? ???????. |
| 4 | `usp_DoCreatePackingLabelInfo` | ?? ???? ?? |
| 5 | `usp_savePackingLabelQty_VVT` | ???? ?? ??? ?? ??? ??? ????? |
| 6 | `usp_BoxCheckSetupValue` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_BoxCheckSetupValueTwo` | Thêm/Sửa/Xóa dữ liệu. |
| 8 | `usp_PackingLabelPrintInfo` | Thêm/Sửa/Xóa dữ liệu. |
| 9 | `usp_SplitPackingBox` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (29)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoCancelProdPacking`** | Hủy Prod Packing | Thực hiện tác vụ hủy prod packing cho dữ liệu trên màn hình. |
| 2 | **`Refresh2`** | Refresh2 | Thực hiện tác vụ refresh2 cho dữ liệu trên màn hình. |
| 3 | **`MergeBox`** | Merge Box | Thực hiện tác vụ merge box cho dữ liệu trên màn hình. |
| 4 | **`DoProductionByBoxCount`** | Production By Box Count | Thực hiện tác vụ production by box count cho dữ liệu trên màn hình. |
| 5 | **`LabelPrint`** | In tem | Thực hiện in tem nhãn sản phẩm hoặc vật tư. |
| 6 | **`InputLabelQty`** | In nhan | Nhập số lượng tem nhãn cần in cho Lot. |
| 7 | **`LotRefresh`** | Lot Refresh | Thực hiện tác vụ lot refresh cho dữ liệu trên màn hình. |
| 8 | **`DeleteData`** | Xóa dòng | Xóa dữ liệu dòng đang chọn khỏi lưới. |
| 9 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 10 | **`SaveLabelInfo`** | Luu Packing Qty | Thực hiện tác vụ luu packing qty cho dữ liệu trên màn hình. |
| 11 | **`HelaBarcodePrint`** | Hela Barcode Print | Thực hiện tác vụ hela barcode print cho dữ liệu trên màn hình. |
| 12 | **`InputBoxQty`** | In Tem & | Thực hiện tác vụ in tem & cho dữ liệu trên màn hình. |
| 13 | **`OnlyRefresh`** | Only Refresh | Thực hiện tác vụ only refresh cho dữ liệu trên màn hình. |
| 14 | **`DeleteAndRefresh`** | Xóa And Refresh | Thực hiện tác vụ xóa and refresh cho dữ liệu trên màn hình. |
| 15 | **`PackingLotRemainQty`** | Packing Lot Remain Qty | Thực hiện tác vụ packing lot remain qty cho dữ liệu trên màn hình. |
| 16 | **`BoxIDInfoRefresh`** | Box I D Info Refresh | Thực hiện tác vụ box i d info refresh cho dữ liệu trên màn hình. |
| 17 | **`SavePrintQty`** | Lưu Print Qty | Thực hiện tác vụ lưu print qty cho dữ liệu trên màn hình. |
| 18 | **`DoDummy`** | Dummy | Thực hiện tác vụ dummy cho dữ liệu trên màn hình. |
| 19 | **`PreMergeBox`** | Pre Merge Box | Thực hiện tác vụ pre merge box cho dữ liệu trên màn hình. |
| 20 | **`TapingLabel`** | In Label Taping | Thực hiện tác vụ in label taping cho dữ liệu trên màn hình. |
| 21 | **`SagemCom`** | Open Sagem | Thực hiện tác vụ open sagem cho dữ liệu trên màn hình. |
| 22 | **`PrintSagem`** | In Sagem | Thực hiện tác vụ in sagem cho dữ liệu trên màn hình. |
| 23 | **`Lotweightshow`** | Lot weight show | Thực hiện tác vụ lot weight show cho dữ liệu trên màn hình. |
| 24 | **`SetSagem1`** | Set.Sagem1 | Thực hiện tác vụ set.sagem1 cho dữ liệu trên màn hình. |
| 25 | **`SaveLabelInfo2`** | Lưu Label Info2 | Thực hiện tác vụ lưu label info2 cho dữ liệu trên màn hình. |
| 26 | **`PrintLabelWH`** | In Label W H | Thực hiện tác vụ in label w h cho dữ liệu trên màn hình. |
| 27 | **`IsLabelPrint`** | Is Label Print | Thực hiện tác vụ is label print cho dữ liệu trên màn hình. |
| 28 | **`SplitBoxQty`** | Chia box | Thực hiện tác vụ chia box cho dữ liệu trên màn hình. |
| 29 | **`SplitBoxQtyProc`** | Split Box Qty Proc | Thực hiện tác vụ split box qty proc cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_PRODUCTIONORDERROUTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_DAYPRODPLAN` | Kế hoạch sản xuất hàng ngày theo tổ/máy. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_PRODROUTESUMMARY` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_PACKINGSTANDARD` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PACKINGLABELSPEC` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VIETNAM_PACKINGPRINTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SAVEPACKINGTIME_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VIETNAM_BARCODEWEIGHT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CHANGEPARTNOANDLOTNO` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PACKINGLABELPRINTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_CREATEMARKINGLETTERANDQTYFORBARCODE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_YEARINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PROCEDURELOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VN_FINISHGOODS_HN_NEW` | Lưu thông tin thành phẩm đóng gói mới tại Hà Nam. |
| `STB_PRODROUTEHISTCANCELHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODROUTEWORKERHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## B528 — VVT_ProdPacking_vvt
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B528` |
| **Screen Name** | `VVT_ProdPacking_vvt` |
| **Parent Menu** | `PM_ProductManagement_MENU` |
| **Title** | VVT_ProdPacking_vvt |
| **Tổng Objects** | **27** (3 View + 3 SearchFunction + 4 ExecuteFunction + 17 Action) |

### Workflow

1. Thực hiện đóng gói sản phẩm theo Lot và gộp vào Box (Barrel), thực hiện in nhãn barcode Box.
2. Quét Lot để kiểm tra điều kiện đóng gói: kiểm định chất lượng đạt QC (`STB_SetInfo`), kiểm tra thời gian đóng gói (`STB_SavePackingTime_VVT`), kiểm tra Lot có bị HOLD hay không.
3. Cho phép hủy đóng gói hoặc tách Lot ra khỏi Box khi có yêu cầu sửa đổi hoặc xử lý sự cố.

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdPackingForBarcode` | ProdPackingForBarcode | Grid hiển thị dữ liệu. |
| 2 | `ProdRouteHist` | ProdRouteHist | Grid hiển thị dữ liệu. |
| 3 | `BoxIDForLotNo_VNT` | BoxIDForLotNo_VNT | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetProdPackingForBarcode_VNT` | ??? ?? ?? |
| 2 | `usp_ProdRouteHist_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_GetBoxIDForLotNo_VNT` | ???? ?? ??? ?? ??? ??? ????? |

### ExecuteFunctions (4)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoProcessProdPacking_VNT` | ????????? ?????. |
| 2 | `usp_DoProcessProdPackingByOne_VNT` | BoxID? ????? |
| 3 | `usp_DoCancelProdPacking_LotNo` | ????? ???????. |
| 4 | `usp_DoCreatePackingLabelInfo` | ?? ???? ?? |

### Actions/Buttons (17)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`VietnamBoxLabelPrint`** | Vietnam Box Label Print | Thực hiện tác vụ vietnam box label print cho dữ liệu trên màn hình. |
| 2 | **`DoCancelProdPacking`** | Hủy Prod Packing | Thực hiện tác vụ hủy prod packing cho dữ liệu trên màn hình. |
| 3 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 4 | **`MergeBox`** | Merge Box | Thực hiện tác vụ merge box cho dữ liệu trên màn hình. |
| 5 | **`DoProductionByBoxCount`** | Production By Box Count | Thực hiện tác vụ production by box count cho dữ liệu trên màn hình. |
| 6 | **`LabelPrint`** | In tem | Thực hiện in tem nhãn sản phẩm hoặc vật tư. |
| 7 | **`InputLabelQty`** | SL in tem | Nhập số lượng tem nhãn cần in cho Lot. |
| 8 | **`LotRefresh`** | Lot Refresh | Thực hiện tác vụ lot refresh cho dữ liệu trên màn hình. |
| 9 | **`DeleteData`** | Xóa dòng | Xóa dữ liệu dòng đang chọn khỏi lưới. |
| 10 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 11 | **`SaveLabelInfo`** | Lưu Label Info | Thực hiện tác vụ lưu label info cho dữ liệu trên màn hình. |
| 12 | **`HelaBarcodePrint`** | Hela Barcode Print | Thực hiện tác vụ hela barcode print cho dữ liệu trên màn hình. |
| 13 | **`InputBoxQty`** | Input Box Qty | Thực hiện tác vụ input box qty cho dữ liệu trên màn hình. |
| 14 | **`OnlyRefresh`** | Only Refresh | Thực hiện tác vụ only refresh cho dữ liệu trên màn hình. |
| 15 | **`DeleteAndRefresh`** | Xóa And Refresh | Thực hiện tác vụ xóa and refresh cho dữ liệu trên màn hình. |
| 16 | **`PackingLotRemainQty`** | Packing Lot Remain Qty | Thực hiện tác vụ packing lot remain qty cho dữ liệu trên màn hình. |
| 17 | **`BoxIDInfoRefresh`** | Box I D Info Refresh | Thực hiện tác vụ box i d info refresh cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialLotInfo` | Lưu thông tin Lot đóng gói và liên kết Box ID. |
| `STB_SavePackingTime_VVT` | Lưu thời gian đóng gói phục vụ Traceability kiểm soát hạn sử dụng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Tem barrel in trống hoặc thiếu thông tin | Label config chưa set cho model dạng Barrel | Kiểm tra `STB_ModelLabelInfo` → LabelType='BarrelLabel' | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B560 — VNT_HelaBarcode
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B560` |
| **Screen Name** | `VNT_HelaBarcode` |
| **Parent Menu** | `Hela _Menu` |
| **Title** | VNT_HelaBarcode |
| **Tổng Objects** | **22** (2 View + 2 SearchFunction + 7 ExecuteFunction + 11 Action) |

### Workflow

1. Quản lý việc tạo và in mã tem Hela Barcode cho các công đoạn đóng gói trong/ngoài (Inbox/Outbox).
2. Ghi nhận lịch sử in ấn, cập nhật trạng thái đã in (`PrintYn`), kiểm tra điều kiện in nhãn.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `HelaBarcode` | HelaBarcode | Grid hiển thị dữ liệu. |
| 2 | `VNT_HelaBarcodeOutBoxHist` | VNT_HelaBarcodeOutBoxHist | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_HelaBarcode_get` | ????? ???? |
| 2 | `usp_HelaBarcodeOutBoxHist_get` | ????????? |

### ExecuteFunctions (7)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoCreateHelaInBoxBarcode` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoUpdateHelaInBoxBarcodePrintYn` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoCheckInBoxLabelPrintYn` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_DoCreateHelaOutBoxBarcode` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoCreateHelaInBoxBarcodeList` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_DoCheckInBoxLabelPrintYn2` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoSetLabelRePrint_VVT` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (11)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`OutBoxLabelPrint`** | Out Box Label Print | Thực hiện tác vụ out box label print cho dữ liệu trên màn hình. |
| 2 | **`InBoxLabelPrint`** | In Box Label Print | Thực hiện tác vụ in box label print cho dữ liệu trên màn hình. |
| 3 | **`InBoxLabelPrintHistCheck`** | In Box Label Print Hist Check | Thực hiện tác vụ in box label print hist check cho dữ liệu trên màn hình. |
| 4 | **`CreatePackageID`** | Create Package I D | Thực hiện tác vụ create package i d cho dữ liệu trên màn hình. |
| 5 | **`ViewRefresh`** | View Refresh | Thực hiện tác vụ view refresh cho dữ liệu trên màn hình. |
| 6 | **`UpdatePrintYn`** | Cập nhật in | Cập nhật cờ xác nhận đã in tem nhãn (PrintYn = Y). |
| 7 | **`InBoxLabelListCheck`** | In Box Label List Check | Thực hiện tác vụ in box label list check cho dữ liệu trên màn hình. |
| 8 | **`CreateInBoxLabelList`** | Create In Box Label List | Thực hiện tác vụ create in box label list cho dữ liệu trên màn hình. |
| 9 | **`CreateOutBoxLabel`** | Create Out Box Label | Thực hiện tác vụ create out box label cho dữ liệu trên màn hình. |
| 10 | **`ViewRefresh2`** | View Refresh2 | Thực hiện tác vụ view refresh2 cho dữ liệu trên màn hình. |
| 11 | **`SetRePrint`** | Set RePrint | Thực hiện tác vụ set reprint cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_HelaBarcode` | Lưu thông tin và trạng thái in của tem Hela Barcode Inbox. |
| `STB_HelaBarcodeOutBoxHist` | Lưu lịch sử đóng thùng Outbox và liên kết mã vạch Hela. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | In tem Hela trống hoặc sai format | Config label Hela chưa map đúng model | Kiểm tra `STB_HelaPackingCheckHist` + Label config | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B754 — VVT_PrintBoxLabelPAC
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B754` |
| **Screen Name** | `VVT_PrintBoxLabelPAC` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | In tem th�ng Kh�ch h�ng PAC |
| **Tổng Objects** | **7** (1 View + 1 SearchFunction + 1 ExecuteFunction + 4 Action) |

### Workflow

Giao diện **VVT_PrintBoxLabelPAC** dùng để thực hiện nghiệp vụ: **Tem KH PAC (Box)**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VVT_PrintBoxLabelPAC` từ menu `KB_03, KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_PACBoxLabalInfo_get_Vietnam`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_VN_PACBoxLabelPrintHist_iud`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `PACBoxLabalInfo_Vietnam` | PACBoxLabalInfo_Vietnam | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_PACBoxLabalInfo_get_Vietnam` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VN_PACBoxLabelPrintHist_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PrintLabelPAC`** | IN TEM | Thực hiện tác vụ in tem cho dữ liệu trên màn hình. |
| 2 | **`RefreshView`** | Làm mới | Làm mới giao diện hiển thị dữ liệu. |
| 3 | **`SavePrintHist`** | Lưu Print Hist | Thực hiện tác vụ lưu print hist cho dữ liệu trên màn hình. |
| 4 | **`DeleteData`** | Xóa dòng | Xóa dữ liệu dòng đang chọn khỏi lưới. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_PACBOXLABALPRINTHIST` | Lịch sử in tem nhãn PAC Box. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PACBOXLABALPRINTHIST_INNER` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | In tem PAC/DigiKey/Phoenix trống | Label spec chưa config hoặc LabelType sai | Kiểm tra `STB_ModelLabelInfo` + `STB_PackingLabelSpec` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Tem Phoenix Contact sai mã khách hàng | Config customer mapping thiếu | Kiểm tra `STB_PackingLabelSpec` (⚠️ `STB_PhoenixContactLabelInfo` KHÔNG tồn tại trong DB — data lưu trong PackingLabelSpec hoặc hardcode SP) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## B755 — VVT_PACPrintLabelHist
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B755` |
| **Screen Name** | `VVT_PACPrintLabelHist` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | L?ch s? in tem KH PAC |
| **Tổng Objects** | **2** (1 View + 1 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Tra cứu và hiển thị lịch sử in tem nhãn thùng Carton (PAC Box Label).
2. Hỗ trợ giám sát sản lượng đóng gói thành phẩm theo ca và đối chiếu chéo mã vạch thùng.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `PACBoxLabelPrintHist` | PACBoxLabelPrintHist | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_PACBoxLabelPrintHist_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PACBoxLabalPrintHist` | Lưu trữ lịch sử in ấn tem nhãn PAC Box. |

---

## B756 — PACLabelCartonAndWeight
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B756` |
| **Screen Name** | `PACLabelCartonAndWeight` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | PAC Carton & Weight Label |
| **Tổng Objects** | **6** (1 View + 1 SearchFunction + 0 ExecuteFunction + 4 Action) |

### Workflow

Giao diện **PACLabelCartonAndWeight** dùng để thực hiện nghiệp vụ: **Tem PAC Carton**.

**Workflow vận hành:**
1. Truy cập vào chức năng `PACLabelCartonAndWeight` từ menu `KB_03, KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_PACLabelCartonWeight_get_Vietnam`.

**Lưu ý vận hành:**
- Cân nặng


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `PACLabelCartonWeight_Vietnam` | PACLabelCartonWeight_Vietnam | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_PACLabelCartonWeight_get_Vietnam` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`SetLabelQty`** | Tem C�n N?ng | Thực hiện tác vụ tem c�n n?ng cho dữ liệu trên màn hình. |
| 2 | **`CartonNumberLabel`** | Tem th�ng Carton | Thực hiện tác vụ tem th�ng carton cho dữ liệu trên màn hình. |
| 3 | **`PrintWeightLabel`** | In Weight Label | Thực hiện tác vụ in weight label cho dữ liệu trên màn hình. |
| 4 | **`PrintTestLabel`** | In Test Label | Thực hiện tác vụ in test label cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PACLABELCARTONANDWEIGHT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## B757 — DigiKeyLabelInner_get
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B757` |
| **Screen Name** | `DigiKeyLabelInner_get` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | DigiKey-Print Label |
| **Tổng Objects** | **12** (1 View + 1 SearchFunction + 1 ExecuteFunction + 9 Action) |

### Workflow

Giao diện **DigiKeyLabelInner_get** dùng để thực hiện nghiệp vụ: **Tem DigiKey Inner**.

**Workflow vận hành:**
1. Truy cập vào chức năng `DigiKeyLabelInner_get` từ menu `KB_03, KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_DigiKeyLabelInner_get_Vietnam`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_VN_DigiKeyLabelInnerPrintHist_iud`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DigiKeyLabelInner_Vietnam` | DigiKeyLabelInner_Vietnam | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DigiKeyLabelInner_get_Vietnam` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VN_DigiKeyLabelInnerPrintHist_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (9)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`SetLabelQty`** | IN NHAN SP | Thực hiện tác vụ in nhan sp cho dữ liệu trên màn hình. |
| 2 | **`PrintLabel`** | In tem | Thực hiện in tem nhãn cho đối tượng đang chọn. |
| 3 | **`SavePrintHist`** | Lưu Print Hist | Thực hiện tác vụ lưu print hist cho dữ liệu trên màn hình. |
| 4 | **`DeleteView`** | Xóa View | Thực hiện tác vụ xóa view cho dữ liệu trên màn hình. |
| 5 | **`SetPONumber`** | IN NHAN LOGISTIC | Thực hiện tác vụ in nhan logistic cho dữ liệu trên màn hình. |
| 6 | **`SetPOLineNumber`** | Set P O Line Number | Thực hiện tác vụ set p o line number cho dữ liệu trên màn hình. |
| 7 | **`SetPackListNumber`** | Set Pack List Number | Thực hiện tác vụ set pack list number cho dữ liệu trên màn hình. |
| 8 | **`SetLogisticLabelQty`** | Set Logistic Label Qty | Thực hiện tác vụ set logistic label qty cho dữ liệu trên màn hình. |
| 9 | **`PrintLogisticLabel`** | In Logistic Label | Thực hiện tác vụ in logistic label cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_DIGIKEYLABELINNERPRINTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## B758 — DigikeyLabelLevelPackage_get
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B758` |
| **Screen Name** | `DigikeyLabelLevelPackage_get` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Digikey-SingleLevelPackage |
| **Tổng Objects** | **6** (1 View + 1 SearchFunction + 1 ExecuteFunction + 3 Action) |

### Workflow

Giao diện **DigikeyLabelLevelPackage_get** dùng để thực hiện nghiệp vụ: **Tem DigiKey Package**.

**Workflow vận hành:**
1. Truy cập vào chức năng `DigikeyLabelLevelPackage_get` từ menu `KB_03, KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_DigiKeySingleLevelPackage_get_Vietnam`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_VN_DigiKeySingleLevelPackagePrintHist_iud`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DigiKeySingleLevelPackage_Vietnam` | DigiKeySingleLevelPackage_Vietnam | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DigiKeySingleLevelPackage_get_Vietnam` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VN_DigiKeySingleLevelPackagePrintHist_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PrintLabel`** | IN TEM | Thực hiện in tem nhãn cho đối tượng đang chọn. |
| 2 | **`SavePrintHist`** | Lưu Print Hist | Thực hiện tác vụ lưu print hist cho dữ liệu trên màn hình. |
| 3 | **`DeleteView`** | Xóa View | Thực hiện tác vụ xóa view cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DIGIKEYSINGLELEVELPACKAGEPRINTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## B767 — VVT_SanminaLabelPrint
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B767` |
| **Screen Name** | `VVT_SanminaLabelPrint` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | In tem KH Sanmina India |
| **Tổng Objects** | **6** (1 View + 1 SearchFunction + 1 ExecuteFunction + 3 Action) |

### Workflow

1. Thực hiện in tem nhãn đóng gói chuyên dụng cho đối tác Sanmina India.
2. Quét Lot sản xuất để hệ thống tự động đối chiếu thông số QC từ `STB_MaterialQcInfo` và lịch sử thay đổi nguyên vật liệu trước khi cho phép in.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `SanminaLabelPrint_Vietnam` | SanminaLabelPrint_Vietnam | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_SanminaLabelPrint_get_Vietnam` | Get Sanmina label |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_SanminaIndiaLabelPrintHist_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PrintLabel`** | In Tem | Thực hiện in tem nhãn cho đối tượng đang chọn. |
| 2 | **`SavePrintHist`** | Lưu Print Hist | Thực hiện tác vụ lưu print hist cho dữ liệu trên màn hình. |
| 3 | **`test`** | test | Thực hiện tác vụ test cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SanminaIndiaLabelPrintHist` | Lưu trữ chi tiết lịch sử in tem nhãn Sanmina của từng sản phẩm. |

---

## B781 — VNT_LotTrackingInfo_vvt21
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B781` |
| **Screen Name** | `VNT_LotTrackingInfo_vvt21` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | VNT_LotTrackingInfo_vvt21 |
| **Tổng Objects** | **8** (1 View + 1 SearchFunction + 3 ExecuteFunction + 3 Action) |

### Workflow

Giao diện **VNT_LotTrackingInfo_vvt21** dùng để thực hiện nghiệp vụ: **Tra SL đóng gói**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_LotTrackingInfo_vvt21` từ menu `KB_03, KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_Vietnam_PackPrintTime_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_ModifyPack_VVT_iud`.

**Lưu ý vận hành:**
- Nhập tay ở B523


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Vietnam_PackPrintTime_view` | Vietnam_PackPrintTime_view | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_PackPrintTime_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModifyPack_VVT_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_ModifyPackingQtyByLevel_VVT` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_ModifyPackingQtyByClassify_VVT` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`LuuSave`** | Luu - Save | Thực hiện tác vụ luu - save cho dữ liệu trên màn hình. |
| 2 | **`refressh`** | Refresh | Thực hiện tác vụ refresh cho dữ liệu trên màn hình. |
| 3 | **`SaveClassQty`** | Luu s? lu?ng c?p | Thực hiện tác vụ luu s? lu?ng c?p cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SAVEPACKINGTIME_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_CHANGEDATE_B781_220924` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VVT_STAGEPRICES` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SAVEPACKINGQTYBYLEVEL_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_ITEMCODE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_RAWMATERIALINPUTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALVENDORMAPPING` | Ánh xạ mã vật tư nội bộ với mã nhà cung cấp. |
| `STB_MATERIALORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODPLANBOM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## B789 — VNT_ModuleLotTrackingInfo_vvt21
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B789` |
| **Screen Name** | `VNT_ModuleLotTrackingInfo_vvt21` |
| **Parent Menu** | `v_ModuleQty` |
| **Title** | VNT_ModuleLotTrackingInfo_vvt21 |
| **Tổng Objects** | **5** (1 View + 1 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

Giao diện **VNT_ModuleLotTrackingInfo_vvt21** dùng để thực hiện nghiệp vụ: **Sửa/xóa Packing**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_ModuleLotTrackingInfo_vvt21` từ menu `KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_Vietnam_ModulePackPrintTime_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_ModifyPack_VVT_iud`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Vietnam_ModulePackPrintTime` | Vietnam_ModulePackPrintTime | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_ModulePackPrintTime_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModifyPack_VVT_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`LuuSave`** | Luu - Save | Thực hiện tác vụ luu - save cho dữ liệu trên màn hình. |
| 2 | **`refressh`** | Refresh | Thực hiện tác vụ refresh cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SAVEPACKINGTIME_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_LOTCHANGEMATERIALHISTORY` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALVENDORMAPPING` | Ánh xạ mã vật tư nội bộ với mã nhà cung cấp. |
| `STB_MATERIALORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODPLANBOM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## B790 — InTemPhoenixContact
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B790` |
| **Screen Name** | `InTemPhoenixContact` |
| **Parent Menu** | `DucTest` |
| **Title** | In Tem Phoenix Contact |
| **Tổng Objects** | **2** (1 View + 1 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **InTemPhoenixContact** dùng để thực hiện nghiệp vụ: **Report B597**.

**Workflow vận hành:**
1. Truy cập vào chức năng `InTemPhoenixContact` từ menu `KB_03, KB_04`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VNT_RawMaterialInputFullHist_get`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Vietnam_PhoenixContactLabelPrint` | Vietnam_PhoenixContactLabelPrint | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_PhoenixContactLabelPrint_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_INTEMPHOENIXCONTACT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## B791 — PrintPhoenixDateCode
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B791` |
| **Screen Name** | `PrintPhoenixDateCode` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Print Phoenix DateCode |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 0 ExecuteFunction + 1 Action) |

### Workflow

Giao diện **PrintPhoenixDateCode** dùng để thực hiện nghiệp vụ: **NG/Defect Repair**.

**Workflow vận hành:**
1. Truy cập vào chức năng `PrintPhoenixDateCode` từ menu `KB_03, KB_31`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_ModuleLotTrackingInfo_VVT2_get`.

**Lưu ý vận hành:**
- Sửa DefectQty + ProdQty cùng lúc


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Vietnam_PhoenixContactLabelPrint` | Vietnam_PhoenixContactLabelPrint | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_PhoenixContactLabelPrint_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PrintLabel`** | In tem | Thực hiện in tem nhãn cho đối tượng đang chọn. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MOUDLEWEIGHTNG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VIETNAM_WASTEUNITPRICE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

---

# BƯỚC 8: QUẢN LÝ KHO THÀNH PHẨM & XUẤT KHO BÁN HÀNG (WMS FG & GI)

*Nhập kho thành phẩm, quản lý tồn kho, xuất kho thành phẩm bán hàng, vận hành hệ thống kho tự động Daifuku.*

---

## C560 — VNT_ProductsReceiptHist
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C560` |
| **Screen Name** | `VNT_ProductsReceiptHist` |
| **Parent Menu** | `ProductManagement_MENU` |
| **Title** | VNT_ProductsReceiptHist |
| **Tổng Objects** | **7** (3 View + 3 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **VNT_ProductsReceiptHist** dùng để thực hiện nghiệp vụ: **Material Lot QC**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_ProductsReceiptHist` từ menu `KB_05, KB_31, KB_32`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VNT_ProductsReceiptHist_get`.

**Lưu ý vận hành:**
- Nhập sản lượng TP vào kho FG


### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProductsReceiptHist` | ProductsReceiptHist | Grid hiển thị dữ liệu. |
| 2 | `MaterialQcDetail` | MaterialQcDetail | Grid hiển thị dữ liệu. |
| 3 | `MaterialQcSampleResult` | MaterialQcSampleResult | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProductsReceiptHist_get` | ??? ?? ?? ?? |
| 2 | `usp_MaterialQcDetail_get` | ???? ??? ????? |
| 3 | `usp_MaterialQcSampleResult_get` | ??????? ?? ???? ?????. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProductsReceiptHist_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VNTPRODUCTSRECEIPTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Không hiện dữ liệu hàng chờ QC Audit | SP filter theo `WorkCenterCode` không match nhà máy HN/HY | ALTER SP thêm WorkCenterCode mới — xem [KB_26 §4.3](KB_26/KB_26_01_LINKS_BUGS.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Báo "chưa kiểm tra QC" dù carton mới đã Pass | Bug logic `AND @Statusout IS NULL` trong SP | Sửa logic AND → OR hoặc check đúng carton mới | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## C561 — MaterialQcInspectionItemBendingCutting
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C561` |
| **Screen Name** | `MaterialQcInspectionItemBendingCutting` |
| **Parent Menu** | `vi_OQC` |
| **Title** | H?ng m?c ki?m tra Bending/Cutting |
| **Tổng Objects** | **12** (4 View + 1 SearchFunction + 2 ExecuteFunction + 5 Action) |

### Workflow

1. Truy cập giao diện `MaterialQcInspectionItemBendingCutting` để thực hiện cấu hình hoặc tra cứu.
2. Tra cứu dữ liệu hiện có trên Grid hiển thị.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (4)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialInformation` | Material Information | Grid hiển thị dữ liệu. |
| 2 | `MaterialQcInspectionItem_ByMaterial` | MaterialQcInspectionItem_ByMaterial | Grid hiển thị dữ liệu. |
| 3 | `MaterialInformationBC` | MaterialInformationBC | Grid hiển thị dữ liệu. |
| 4 | `MaterialQcInspectionItem_ByMaterial_BendingCutting` | MaterialQcInspectionItem_ByMaterial_BendingCutting | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_ByMaterial_get_Bendin` | ?????????/??? ?????(????????) |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_MaterialQcInspectionItem_iud_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (5)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ImportFromInspectionItem`** | Import From Inspection Item | Thực hiện tác vụ import from inspection item cho dữ liệu trên màn hình. |
| 2 | **`ImportFromMaterialInspectionItem`** | Import From Material Inspection Item | Thực hiện tác vụ import from material inspection item cho dữ liệu trên màn hình. |
| 3 | **`SetAql`** | Set Aql | Thực hiện tác vụ set aql cho dữ liệu trên màn hình. |
| 4 | **`SetLevel`** | Set Level | Thực hiện tác vụ set level cho dữ liệu trên màn hình. |
| 5 | **`SetInspectionType`** | Set Inspection Type | Thực hiện tác vụ set inspection type cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALQCINSPECTIONITEMBENDINGCUTTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## C562 — SetListForBendingCuttingQCLot
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C562` |
| **Screen Name** | `SetListForBendingCuttingQCLot` |
| **Parent Menu** | `vi_OQC` |
| **Title** | T?o Lot ki?m tra Bending Cutting |
| **Tổng Objects** | **5** (1 View + 1 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

1. Truy cập giao diện `SetListForBendingCuttingQCLot` để thực hiện cấu hình hoặc tra cứu.
2. Tra cứu dữ liệu hiện có trên Grid hiển thị.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `SetListForOqcLot_VVT_BendingCutting` | SetListForOqcLot_VVT_BendingCutting | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetSetListForOqcLot_VVT_BendingCutting` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoCreateOqcInfoForLot_VNT_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CreateLot`** | T?o Lot | Thực hiện tác vụ t?o lot cho dữ liệu trên màn hình. |
| 2 | **`RefreshView`** | Làm mới | Làm mới giao diện hiển thị dữ liệu. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SETLISTFORBENDINGCUTTINGQCLOT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## C563 — VVT_QC_BendingCutting
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C563` |
| **Screen Name** | `VVT_QC_BendingCutting` |
| **Parent Menu** | `vi_OQC` |
| **Title** | VVT_QC_BendingCutting |
| **Tổng Objects** | **23** (3 View + 3 SearchFunction + 8 ExecuteFunction + 9 Action) |

### Workflow

1. Truy cập giao diện `VVT_QC_BendingCutting` để thực hiện cấu hình hoặc tra cứu.
2. Tra cứu dữ liệu hiện có trên Grid hiển thị.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialOQcInfo_BendingCutting` | MaterialOQcInfo_BendingCutting | Grid hiển thị dữ liệu. |
| 2 | `MaterialQcDetail_BendingCutting` | MaterialQcDetail_BendingCutting | Grid hiển thị dữ liệu. |
| 3 | `MaterialQcSampleResult_BendingCutting` | MaterialQcSampleResult_BendingCutting | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetMaterialOQcInfo_BendingCutting` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialQcDetail_get_BendingCutting` | Lấy danh sách dữ liệu. |
| 3 | `usp_MaterialQcSampleResult_get_BendingCutting` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (8)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoCreateMaterialQcSampleResult_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_MaterialQcInfo_iud_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_MaterialQcDetail_iud_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_MaterialQcSampleResult_iud_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoUpdateMaterialQcInfo_Fail_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_DoUpdateMaterialQcInfo_Success_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoDeleteMaterialQcInfo_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |
| 8 | `usp_DoMakeMaterialQcSampleResult_BendingCutting` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (9)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`SetAllPass_Detail`** | Set All Pass_ Detail | Thực hiện tác vụ set all pass_ detail cho dữ liệu trên màn hình. |
| 2 | **`SetAllPass_Sample`** | Set All Pass_ Sample | Thực hiện tác vụ set all pass_ sample cho dữ liệu trên màn hình. |
| 3 | **`ProdLotDelete`** | Prod Lot Delete | Thực hiện tác vụ prod lot delete cho dữ liệu trên màn hình. |
| 4 | **`MIIDoFailure`** | Phê duyệt FAIL | Đánh giá Lot hàng không đạt (FAIL), khóa xuất kho và yêu cầu xử lý. Gọi SP usp_DoUpdateMaterialQcInfo_Fail. |
| 5 | **`MIIDoSuccess`** | Phê duyệt PASS | Đánh giá Lot hàng đạt chất lượng OQC (PASS) và cho phép chuyển tiếp. Gọi SP usp_DoUpdateMaterialQcInfo_Success. |
| 6 | **`MakeSampleResult`** | CreateQCSampleResult | Khởi tạo dòng kết quả đo mẫu thử QC dựa trên cỡ mẫu quy định. |
| 7 | **`RefreshViewInfo`** | Làm mới View Info | Thực hiện tác vụ làm mới view info cho dữ liệu trên màn hình. |
| 8 | **`RefreshViewDetail`** | Làm mới View Detail | Thực hiện tác vụ làm mới view detail cho dữ liệu trên màn hình. |
| 9 | **`RefreshViewSampleResult`** | Làm mới View Sample Result | Thực hiện tác vụ làm mới view sample result cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVTQCBENDINGCUTTING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## C540 — VNT_ProdInspectionHist
| Thông tin | Giá trị |
|---|---|
| **TCode** | `C540` |
| **Screen Name** | `VNT_ProdInspectionHist` |
| **Parent Menu** | `Outgoing_Qualuty_Control` |
| **Title** | VNT_ProdInspectionHist |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

Giao diện **VNT_ProdInspectionHist** dùng để thực hiện nghiệp vụ: **QC Result Report**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_ProdInspectionHist` từ menu `KB_05`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VNT_ProdInspectionHist_get`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdInspectionHist` | ProdInspectionHist | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProdInspectionHist_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoUpdateMaterialOQcInfoRemark` | ????? ???? ???. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`??????`** | UpdateRemark | Thực hiện tác vụ updateremark cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VNTPRODINSPECTIONHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## F110 — MaterialStockAttributeInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F110` |
| **Screen Name** | `MaterialStockAttributeInfo` |
| **Parent Menu** | `MM_BasicInformation_MENU` |
| **Title** | ???????? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **MaterialStockAttributeInfo** dùng để thực hiện nghiệp vụ: **Kho TP config FIFO**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialStockAttributeInfo` từ menu `KB_02, KB_04, KB_25`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MaterialStockAttributeInfo_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MaterialStockAttributeInfo_iud`.

**Lưu ý vận hành:**
- Tick khi không gộp Box được


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialStockAttributeInfoView` | ???????? | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialStockAttributeInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialStockAttributeInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALSTOCKATTRIBUTEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## F140 — VendorMappingByMaterialInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F140` |
| **Screen Name** | `VendorMappingByMaterialInfo` |
| **Parent Menu** | `MM_BasicInformation_MENU` |
| **Title** | ??????? |
| **Tổng Objects** | **5** (2 View + 2 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **VendorMappingByMaterialInfo** dùng để thực hiện nghiệp vụ: **—**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VendorMappingByMaterialInfo` từ menu `KB_02, KB_07`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_GetPurchaseMaterialMaster`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_MaterialVendorMapping_iud`.

**Lưu ý vận hành:**
- —


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CustomerMappingByMaterialDetailView` | ?????????? | Grid hiển thị dữ liệu. |
| 2 | `PurchaseMaterialMasterView` | ?????????? | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetCustomerMappingByMaterial` | Lấy danh sách dữ liệu. |
| 2 | `usp_GetPurchaseMaterialMaster` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialVendorMapping_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_MATERIALVENDORMAPPING` | Ánh xạ mã vật tư nội bộ với mã nhà cung cấp. |

---

## F710 — MaterialStock
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F710` |
| **Screen Name** | `MaterialStock` |
| **Parent Menu** | `MaterialStock_MENU` |
| **Title** | ?????? |
| **Tổng Objects** | **7** (2 View + 2 SearchFunction + 0 ExecuteFunction + 3 Action) |

### Workflow

Giao diện **MaterialStock** dùng để thực hiện nghiệp vụ: **—**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialStock` từ menu `KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_MaterialStock_get`.

**Lưu ý vận hành:**
- —


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialStockView` | ?????? | Grid hiển thị dữ liệu. |
| 2 | `MaterialLotInfo` | MaterialLotInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialStock_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialLotInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`InputLabelQty`** | LabelPrint | Nhập số lượng tem nhãn cần in cho Lot. |
| 2 | **`PrintLabelSelected`** | LabelPrint | Thực hiện in tem nhãn hàng loạt cho các dòng được chọn. |
| 3 | **`RefreshDocLot`** | Làm mới Lot phiếu | Làm mới danh sách Lot liên kết với phiếu chứng từ. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALSTOCK` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOCATION` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALSTOCKATTRIBUTEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## F721 — VVT_MaterialStockList
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F721` |
| **Screen Name** | `VVT_MaterialStockList` |
| **Parent Menu** | `v_RawMaterial` |
| **Title** | VVT_MaterialStockList |
| **Tổng Objects** | **7** (1 View + 1 SearchFunction + 0 ExecuteFunction + 5 Action) |

### Workflow

Giao diện **VVT_MaterialStockList** dùng để thực hiện nghiệp vụ: **Tồn kho NVL list**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VVT_MaterialStockList` từ menu `KB_02, KB_12, KB_31`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VVT_MaterialStockList_get`.

**Lưu ý vận hành:**
- Kiểm tra SP điều kiện lọc


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `vvt_MaterialLotInfo_vew` | vvt_MaterialLotInfo_vew | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_vvt_MaterialLotInfo_get` | ?? ?????? ?????. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (5)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`LabelPrint`** | In tem | Thực hiện in tem nhãn sản phẩm hoặc vật tư. |
| 2 | **`PriorFIFO`** | Danh Sach Uu Tien FIFO | Thực hiện tác vụ danh sach uu tien fifo cho dữ liệu trên màn hình. |
| 3 | **`HuyLinkVitri`** | Huy Link Vi tri | Thực hiện tác vụ huy link vi tri cho dữ liệu trên màn hình. |
| 4 | **`LinkVitri`** | Link Vi tri | Thực hiện tác vụ link vi tri cho dữ liệu trên màn hình. |
| 5 | **`VVT_List_Export_NVL`** | Danh s�ch xu?t h�ng | Thực hiện tác vụ danh s�ch xu?t h�ng cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVTMATERIALSTOCKLIST` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Tồn kho âm | Backflush trừ quá hoặc phiếu xuất kho tạo sai | Kiểm tra `STB_MaterialStock` + `STB_MaterialDocInfo` type='GI' | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## F723 — VVTF4_CellMaterialStockList
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F723` |
| **Screen Name** | `VVTF4_CellMaterialStockList` |
| **Parent Menu** | `v_RawMaterial` |
| **Title** | VVTF4_CellMaterialStockList |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 0 ExecuteFunction + 1 Action) |

### Workflow

1. Truy vấn tồn kho chi tiết nguyên vật liệu tại kho Cell (F4), hiển thị số Lot, số lượng khả dụng, vị trí kho và trạng thái chất lượng.
2. Cho phép đối chiếu thông tin chứng từ nhập xuất kho (`STB_MaterialDocInfo`) và lịch sử chia cuộn vật tư nhỏ (`STB_VN_DivideMaterialSmal`).

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VVTF4_CellMaterialLotInfo` | VVTF4_CellMaterialLotInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVTF4_CellMaterialLotInfo_get` | Get Cell Material Stock for Bac Giang 2 |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Print Label`** | PrintLabel | Thực hiện tác vụ printlabel cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialLotInfo` | Lưu thông tin chi tiết tồn kho Lot vật tư hiện tại. |
| `STB_MaterialWarehouseInOutHist` | Lịch sử giao dịch xuất nhập kho vật tư thực tế. |

---

## F740 — SplitLot
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F740` |
| **Screen Name** | `SplitLot` |
| **Parent Menu** | `MaterialStock_MENU` |
| **Title** | ??Lot???? |
| **Tổng Objects** | **8** (1 View + 2 SearchFunction + 1 ExecuteFunction + 4 Action) |

### Workflow

Giao diện **SplitLot** dùng để thực hiện nghiệp vụ: **—**.

**Workflow vận hành:**
1. Truy cập vào chức năng `SplitLot` từ menu `KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_GetMaterialLotInfo_ToCut`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DoSplitLot`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialLotInfoToCut` | MaterialLotInfoToCut | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetSplitedMaterialLotInfo` | ??? ????? ?????. |
| 2 | `usp_GetMaterialLotInfo_ToCut` | Thay d?i t? F740 |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoSplitLot` | ??? Split ???. |

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`SplitLot`** | Split Lot | Thực hiện tác vụ split lot cho dữ liệu trên màn hình. |
| 3 | **`PartLabel`** | Part Label | Thực hiện tác vụ part label cho dữ liệu trên màn hình. |
| 4 | **`LabelPrintVN`** | Label Print V N | Thực hiện tác vụ label print v n cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALWAREHOUSEINOUTHIST` | Lịch sử chi tiết giao dịch xuất nhập kho vật tư. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOCATION` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## F741 — SlittingLot
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F741` |
| **Screen Name** | `SlittingLot` |
| **Parent Menu** | `MaterialStock_MENU` |
| **Title** | ??Lot???? |
| **Tổng Objects** | **6** (1 View + 1 SearchFunction + 1 ExecuteFunction + 3 Action) |

### Workflow

Giao diện **SlittingLot** dùng để thực hiện nghiệp vụ: **—**.

**Workflow vận hành:**
1. Truy cập vào chức năng `SlittingLot` từ menu `KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_GetSplitedMaterialLotInfo`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_DoSplitLot`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `SplitedMaterialLotInfo` | Splited Material Lot Info | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetSplitedMaterialLotInfo` | ??? ????? ?????. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoSplitLot` | ??? Split ???. |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`SplitLot`** | Split Lot | Process Split Lot. |
| 3 | **`PartLabel`** | Label Print | Thực hiện tác vụ label print cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALWAREHOUSEINOUTHIST` | Lịch sử chi tiết giao dịch xuất nhập kho vật tư. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOCATION` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## F750 — MaterialStocktakingDoc
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F750` |
| **Screen Name** | `MaterialStocktakingDoc` |
| **Parent Menu** | `MaterialStock_MENU` |
| **Title** | ?????? |
| **Tổng Objects** | **11** (2 View + 2 SearchFunction + 4 ExecuteFunction + 3 Action) |

### Workflow

Giao diện **MaterialStocktakingDoc** dùng để thực hiện nghiệp vụ: **—**.

**Workflow vận hành:**
1. Truy cập vào chức năng `MaterialStocktakingDoc` từ menu `KB_02, KB_26`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_StocktakingDoc_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_StocktakingDoc_get`.

**Lưu ý vận hành:**
- —


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `StocktakingDoc` | StocktakingDoc | Grid hiển thị dữ liệu. |
| 2 | `StocktakingPlanResult` | StocktakingPlanResult | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_StocktakingDoc_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_StocktakingPlanResult_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (4)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_StocktakingDoc_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoMakeStocktakingPlanResult` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_StocktakingPlanResult_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_DoApplyStocktakingToStock` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`ApplyStocktaking`** | Apply Stocktaking | Thực hiện tác vụ apply stocktaking cho dữ liệu trên màn hình. |
| 3 | **`AddStocktakingPlanResult`** | Add Stocktaking Plan Result | Thực hiện tác vụ add stocktaking plan result cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_STOCKTAKINGDOC` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_STOCKTAKINGPLANRESULT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOCATION` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PACKINGLABELSPEC` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |

---

## F761 — VVT_MaterialDocDetailHistory_vvt1
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F761` |
| **Screen Name** | `VVT_MaterialDocDetailHistory_vvt1` |
| **Parent Menu** | `v_RawMaterial` |
| **Title** | Vietnam_Lich-su-thu-chi-vat-lieu |
| **Tổng Objects** | **5** (2 View + 2 SearchFunction + 0 ExecuteFunction + 1 Action) |

### Workflow

Giao diện **VVT_MaterialDocDetailHistory_vvt1** dùng để thực hiện nghiệp vụ: **—**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VVT_MaterialDocDetailHistory_vvt1` từ menu `KB_02`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VVT_MaterialDocDetailHistory_vvt1_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_VVT_MaterialDocDetailHistory_vvt1_get`.

**Lưu ý vận hành:**
- —


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocDetailHistory` | MaterialDocDetailHistory | Grid hiển thị dữ liệu. |
| 2 | `VVT_MaterialDoc_SummaryHistory` | VVT_MaterialDoc_SummaryHistory | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVT_GetMaterialDoc_DetailHistory` | ?? ??? ???? |
| 2 | `usp_VVT_GetMaterialDoc_SummaryHistory` | ?? ??? ???? |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PhieuXuatKhoNVL`** | Phi?u xu?t nguy�n v?t li?u | Thực hiện tác vụ phi?u xu?t nguy�n v?t li?u cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVTMATERIALDOCDETAILHISTORYVVT1` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## B750 — FinishGoodOutTemporary
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B750` |
| **Screen Name** | `FinishGoodOutTemporary` |
| **Parent Menu** | `ProductManagement_MENU` |
| **Title** | FinishGoodOutTemporary |
| **Tổng Objects** | **5** (2 View + 2 SearchFunction + 0 ExecuteFunction + 1 Action) |

### Workflow

1. Quản lý việc xuất kho tạm thời thành phẩm (Finished Goods) để phục vụ test, làm mẫu hoặc lưu kho ngoài hệ thống WMS chính.
2. Ghi nhận số lượng xuất, lý do, người nhận và theo dõi thời gian trả hàng.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `View_Tem_fg` | View_Tem_fg | Grid hiển thị dữ liệu. |
| 2 | `view_details_fisgood` | view_details_fisgood | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_View_Tem_fg` | Lấy danh sách dữ liệu. |
| 2 | `usp_view_details_fisgood` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Bt_intempallet`** | In tem | Thực hiện tác vụ in tem cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VN_FinishGood_Out_Temporary` | Lưu thông tin chi tiết các Pallet/Box thành phẩm xuất tạm thời. |

---

## B752 — StatusPallet
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B752` |
| **Screen Name** | `StatusPallet` |
| **Parent Menu** | `ProductManagement_MENU` |
| **Title** | StatusPallet |
| **Tổng Objects** | **6** (3 View + 3 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Kiểm tra trạng thái của Pallet thành phẩm trong quy trình xuất kho tạm.
2. Xác định pallet đã được xuất đi (`Exported`), đang chờ hay có lỗi số lượng chênh lệch.

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CheckStatusFinishGoodsB752` | CheckStatusFinishGoodsB752 | Grid hiển thị dữ liệu. |
| 2 | `CheckStatusFinishGoodsB752_Exported` | CheckStatusFinishGoodsB752_Exported | Grid hiển thị dữ liệu. |
| 3 | `ViewDetai_B752` | ViewDetai_B752 | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_CheckStatusFinishGoodsB752_Exported_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_CheckStatusFinishGoodsB752_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_ViewDetai_B752_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VN_FinishGood_Out_Temporary` | Bảng chính dùng để tra cứu trạng thái Pallet thành phẩm xuất tạm. |

---

## G100 — SalesGI
| Thông tin | Giá trị |
|---|---|
| **TCode** | `G100` |
| **Screen Name** | `SalesGI` |
| **Parent Menu** | `ProductManagement_MENU` |
| **Title** | ???? |
| **Tổng Objects** | **28** (3 View + 3 SearchFunction + 10 ExecuteFunction + 12 Action) |

### Workflow

1. Truy cập giao diện `SalesGI` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_MaterialDocInfo_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_MaterialDocInfo_get`.

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocInfo` | ???? | Grid hiển thị dữ liệu. |
| 2 | `MaterialDocDetail` | ?????? | Grid hiển thị dữ liệu. |
| 3 | `MaterialDocLotInfo` | ??LOT?? | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialDocInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialDocDetail_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_MaterialDocLotInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (10)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoUploadMaterialDocToERP_DL` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_MaterialDocLotInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoCancelMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_DoFixMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_PDADoPicking` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_PDADoPickingCancel` | Thêm/Sửa/Xóa dữ liệu. |
| 8 | `usp_DoCancelFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 9 | `usp_MaterialDocInfo_iud` | ???????? |
| 10 | `usp_MaterialDocDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (12)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`RefreshDocLot`** | Làm mới Lot phiếu | Làm mới danh sách Lot liên kết với phiếu chứng từ. |
| 3 | **`PickingCancel`** | Picking Cancel | Thực hiện tác vụ picking cancel cho dữ liệu trên màn hình. |
| 4 | **`SearchStockLot`** | Search Stock Lot | Thực hiện tác vụ search stock lot cho dữ liệu trên màn hình. |
| 5 | **`CancelDoc`** | Hủy phiếu | Hủy phiếu chứng từ nhập/xuất đang chọn. |
| 6 | **`CancelFinish`** | Hủy hoàn thành | Hủy trạng thái hoàn thành (Finish) của phiếu để cho phép chỉnh sửa. |
| 7 | **`Fix`** | Fix PO | Xác nhận (Fix) lệnh sản xuất, chuẩn bị cho lập kế hoạch và chạy chuyền. |
| 8 | **`Finish`** | Finish | Thực hiện tác vụ finish cho dữ liệu trên màn hình. |
| 9 | **`PrintReport`** | In Report | Thực hiện tác vụ in report cho dữ liệu trên màn hình. |
| 10 | **`ScanLotForDetail`** | Scan Lot For Detail | Thực hiện tác vụ scan lot for detail cho dữ liệu trên màn hình. |
| 11 | **`RefreshDocDetail`** | Làm mới Doc Detail | Thực hiện tác vụ làm mới doc detail cho dữ liệu trên màn hình. |
| 12 | **`ScanLotForLot`** | Scan Lot For Lot | Thực hiện tác vụ scan lot for lot cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MATERIALDOCDETAIL` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALDOCINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALDOCTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_CUSTOMERINFO` | Danh mục thông tin khách hàng và nhà cung cấp. |
| `STB_COMPANYINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_WORKCENTERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALWAREHOUSE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALSTOCK` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDERITEM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SALESORDER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_MATERIALTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODUCTGROUP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCINFO` | Thông tin phiếu kiểm định chất lượng nguyên vật liệu / OQC. |
| `STB_ATTACHEDFILEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALSTOCKATTRIBUTEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALQCSAMPLERESULT` | Kết quả đo lường chi tiết các mẫu thử QC. |
| `STB_MODELLABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODPLANBOM` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_BOMDETAIL_REVISION` | Bảng chi tiết các thông số của phiếu ghi nhận. |
| `STB_MATERIALVENDORMAPPING` | Ánh xạ mã vật tư nội bộ với mã nhà cung cấp. |
| `STB_LINEROUTEMAPPING` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCPICKINGPLAN` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PROCEDURELOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALLOTSNAPSHOT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALQCDETAIL` | Chi tiết các hạng mục kiểm định của phiếu QC. |
| `STB_MATERIALDOCLOT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_MATERIALDOCLOTINFI` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## G400 — ProductReturnAndPrintLabel
| Thông tin | Giá trị |
|---|---|
| **TCode** | `G400` |
| **Screen Name** | `ProductReturnAndPrintLabel` |
| **Parent Menu** | `ProductManagement_MENU` |
| **Title** | ???? ? ???? |
| **Tổng Objects** | **31** (3 View + 3 SearchFunction + 12 ExecuteFunction + 13 Action) |

### Workflow

1. Truy cập giao diện `ProductReturnAndPrintLabel` để thực hiện cấu hình hoặc tra cứu.
2. Tra cứu dữ liệu hiện có trên Grid hiển thị.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocInfo` | MaterialDocInfo | Grid hiển thị dữ liệu. |
| 2 | `MaterialDocDetail` | MaterialDocDetail | Grid hiển thị dữ liệu. |
| 3 | `MaterialDocLotInfo` | MaterialDocLotInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialDocInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_MaterialDocDetail_get` | Lấy danh sách dữ liệu. |
| 3 | `usp_MaterialDocLotInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (12)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoArriveMaterialDelivery` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 3 | `usp_DoFixMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 4 | `usp_DoMaterialDocMasterDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoCancelMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 6 | `usp_DoCancelFinishMaterialDoc` | Thêm/Sửa/Xóa dữ liệu. |
| 7 | `usp_DoCreateLabel` | Thêm/Sửa/Xóa dữ liệu. |
| 8 | `usp_MaterialDocLotInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 9 | `usp_DoChangeMaterialDocLotInfo` | Thêm/Sửa/Xóa dữ liệu. |
| 10 | `usp_DoDeleteMaterialDocLotInfo` | Thêm/Sửa/Xóa dữ liệu. |
| 11 | `usp_MaterialDocInfo_iud` | ???????? |
| 12 | `usp_MaterialDocDetail_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (13)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 2 | **`CancelDoc`** | Hủy phiếu | Hủy phiếu chứng từ nhập/xuất đang chọn. |
| 3 | **`DoFix`** | Xác nhận (Fix) | Xác nhận/Chốt phiếu chứng từ, khóa dữ liệu không cho sửa đổi. |
| 4 | **`CancelFinish`** | Hủy hoàn thành | Hủy trạng thái hoàn thành (Finish) của phiếu để cho phép chỉnh sửa. |
| 5 | **`DoFInish`** | F Inish | Thực hiện tác vụ f inish cho dữ liệu trên màn hình. |
| 6 | **`DoGR`** | Nhập kho (GR) | Xác nhận nhập kho thực tế (Goods Receipt) cho các Lot hàng. |
| 7 | **`MakeLabel`** | Sinh tem NVL | Tự động tạo mã Lot ID và in nhãn dán cho vật tư nhập kho thực tế. |
| 8 | **`RefreshDetail`** | Làm mới chi tiết | Làm mới danh sách chi tiết của phiếu. |
| 9 | **`DeleteDocLotInfo`** | Xóa Lot | Xóa Lot vật tư được chọn ra khỏi phiếu nhập kho. |
| 10 | **`PrintLabelSelected`** | In tem chọn | Thực hiện in tem nhãn hàng loạt cho các dòng được chọn. |
| 11 | **`RefreshDocLot`** | Làm mới Lot phiếu | Làm mới danh sách Lot liên kết với phiếu chứng từ. |
| 12 | **`ChangeLotNo`** | Đổi số Lot | Thay đổi hoặc điều chỉnh mã số Lot nhãn vật tư. |
| 13 | **`ScanBarcode`** | Quét Barcode | Quét mã vạch của vật tư để đối chiếu thông tin phiếu giao nhận. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PRODUCTRETURNANDPRINTLABEL` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## G660 — Daifuku_Warehouse
| Thông tin | Giá trị |
|---|---|
| **TCode** | `G660` |
| **Screen Name** | `Daifuku_Warehouse` |
| **Parent Menu** | `ProductStock_MENU` |
| **Title** | Daifuku_Warehouse |
| **Tổng Objects** | **8** (1 View + 1 SearchFunction + 3 ExecuteFunction + 3 Action) |

### Workflow

1. Truy cập giao diện `Daifuku_Warehouse` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_DaifukuWarehouse_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_DaifukuWarehouse_iud`.
6. Quét mã vạch (Barcode) để đối chiếu thông tin tương ứng.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DaifukuWarehouse` | DaifukuWarehouse | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DaifukuWarehouse_get` | ??????? ?????? ???????. |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_WarehouseGrid_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DaifukuWarehouse_iud` | ??????? ?????? ???????. |
| 3 | `usp_DaifukuWarehouse_Del` | ??????? ???? ??? ??? ???. |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`WaitingForArrival`** | Waiting For Arrival | Thực hiện tác vụ waiting for arrival cho dữ liệu trên màn hình. |
| 2 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 3 | **`PackingID_Del`** | Packing I D_ Del | Thực hiện tác vụ packing i d_ del cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_WAREHOUSETEMP` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PROCEDURELOG` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MATERIALDOCLOTINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Robot không nhận lệnh nhập/xuất | Kết nối Daifuku interface bị mất hoặc slot đầy | Kiểm tra `usp_DaifukuWarehouse_iud` + trạng thái slot | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## F430 — VNT_MaterialWarehouseInOutHist
| Thông tin | Giá trị |
|---|---|
| **TCode** | `F430` |
| **Screen Name** | `VNT_MaterialWarehouseInOutHist` |
| **Parent Menu** | `MaterialMove_MENU` |
| **Title** | VNT_MaterialWarehouseInOutHist |
| **Tổng Objects** | **8** (1 View + 1 SearchFunction + 1 ExecuteFunction + 5 Action) |

### Workflow

Giao diện **VNT_MaterialWarehouseInOutHist** dùng để thực hiện nghiệp vụ: **Xuất kho / Move**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_MaterialWarehouseInOutHist` từ menu `KB_02, KB_31`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VNT_MaterialWarehouseInOutHist_get`.

**Lưu ý vận hành:**
- Sửa ngày xuất


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialWarehouseInOutHist` | MaterialWarehouseInOutHist | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialWarehouseInOutHist_get` | ????????? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialWarehouseInOutHist_del` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (5)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`MaterialWarehouseInRequest`** | Material Warehouse In Request | Thực hiện tác vụ material warehouse in request cho dữ liệu trên màn hình. |
| 2 | **`MaterialWarehouseInOutRequest`** | MaterialWarehouseOutRequest | Thực hiện tác vụ materialwarehouseoutrequest cho dữ liệu trên màn hình. |
| 3 | **`Vietnam_MaterialOut`** | Vietnam_Nguyen lieu dau ra | Thực hiện tác vụ vietnam_nguyen lieu dau ra cho dữ liệu trên màn hình. |
| 4 | **`PhieuNhapKhoNVL`** | Phi?u xu?t kho nguy�n v?t li?u | Thực hiện tác vụ phi?u xu?t kho nguy�n v?t li?u cho dữ liệu trên màn hình. |
| 5 | **`ConfirmGetMaterials`** | X�c nh?n c?p NVL | Thực hiện tác vụ x�c nh?n c?p nvl cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VNTMATERIALWAREHOUSEINOUTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Lot không chuyển kho được | Lot bị HOLD hoặc QC Reject | Giải phóng HOLD hoặc xử lý theo quy trình NG | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

# BƯỚC 9: PHÂN HỆ MODULE, KHÁCH HÀNG ENESOL & QUẢN LÝ HỆ THỐNG

*Các quy trình sản xuất Module, Spare Part, Vision Inspection, phân hệ riêng cho Enesol và phân quyền tài khoản người dùng.*

---

## K101 — DayProdPlanForMainLotMDL
| Thông tin | Giá trị |
|---|---|
| **TCode** | `K101` |
| **Screen Name** | `DayProdPlanForMainLotMDL` |
| **Parent Menu** | `VNT_ModuleProdManagement_MENU` |
| **Title** | ?? ??????(PS??) |
| **Tổng Objects** | **22** (2 View + 2 SearchFunction + 6 ExecuteFunction + 12 Action) |

### Workflow

1. Truy cập giao diện `DayProdPlanForMainLotMDL` để thực hiện cấu hình hoặc tra cứu.
2. Tra cứu dữ liệu hiện có trên Grid hiển thị.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlan` | DayProdPlan | Grid hiển thị dữ liệu. |
| 2 | `SetInfo` | SetInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_get` | ?? ???? |
| 2 | `usp_SetInfo_get` | ????? ????? |

### ExecuteFunctions (6)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoCancelDayProdPlan` | ?? ????? ??????? |
| 3 | `usp_DoFixDayProdPlan` | ?? ????? ??????? |
| 4 | `usp_SetInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoCreateSetInfoForProdQty_VNT` | ?? ??(Lot)? ????? |
| 6 | `usp_DoFinishDayProdPlan` | ?? ????? ??????? |

### Actions/Buttons (12)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CancelDayPlan`** | Hủy Day Plan | Thực hiện tác vụ hủy day plan cho dữ liệu trên màn hình. |
| 2 | **`DoFinishDayPlan`** | Finish Day Plan | Thực hiện tác vụ finish day plan cho dữ liệu trên màn hình. |
| 3 | **`FixDayPlan`** | Fix Day Plan | Thực hiện tác vụ fix day plan cho dữ liệu trên màn hình. |
| 4 | **`DoGI`** | Xuất kho (GI) | Xác nhận xuất kho thực tế (Goods Issue) vật tư cho lệnh sản xuất. |
| 5 | **`POSelectDialog`** | P O Select Dialog | Thực hiện tác vụ p o select dialog cho dữ liệu trên màn hình. |
| 6 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 7 | **`CreateSetInfo`** | Create Set Info | Thực hiện tác vụ create set info cho dữ liệu trên màn hình. |
| 8 | **`RefreshSetInfo`** | Refresh | Làm mới danh sách thông tin Lot/Set sản phẩm. |
| 9 | **`InputLabelQty`** | LabelPrint | Nhập số lượng tem nhãn cần in cho Lot. |
| 10 | **`AddMainAssemblePart`** | Add Main Assemble Part | Thực hiện tác vụ add main assemble part cho dữ liệu trên màn hình. |
| 11 | **`InputLotQty`** | Input Lot Qty | Thực hiện tác vụ input lot qty cho dữ liệu trên màn hình. |
| 12 | **`PrintSlteeingLabel`** | In Slteeing Label | Thực hiện tác vụ in slteeing label cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DAYPRODPLANFORMAINLOTMDL` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Lot tracking trống cho PO BG2 | PO chưa config Route cho BG2 (V-22_BG, V-28_BG) | Thêm Route BG2 vào PO | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## K109 — VNT_SelfInspectionRawMaterialBE
| Thông tin | Giá trị |
|---|---|
| **TCode** | `K109` |
| **Screen Name** | `VNT_SelfInspectionRawMaterialBE` |
| **Parent Menu** | `VNT_ModuleProdManagement_MENU` |
| **Title** | VNT_SelfInspectionRawMaterialBE |
| **Tổng Objects** | **16** (2 View + 2 SearchFunction + 5 ExecuteFunction + 7 Action) |

### Workflow

1. Truy cập giao diện `VNT_SelfInspectionRawMaterialBE` để thực hiện cấu hình hoặc tra cứu.
2. Tra cứu dữ liệu hiện có trên Grid hiển thị.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CommInspectionHistoryForBarcode` | SelfInspectionHistoryForBarcode | Grid hiển thị dữ liệu. |
| 2 | `RawMaterialInputHist` | RawMaterialInputHist | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetCommInspectionHistoryForBarcode` | ???????? |
| 2 | `usp_RawMaterialInputHist_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoAddCommInspMeasureHistForBarcode` | ?? ????? ?? ???. |
| 2 | `usp_DoFinishCommInspDoc` | ?? ??? ??????? |
| 3 | `usp_DoFinishCommInspDoc_VNT` | ?? ??? ??????? |
| 4 | `usp_RawMaterialInputHist_iud` | Thêm/Sửa/Xóa dữ liệu. |
| 5 | `usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_iud` | ?? ????? ?? ???. |

### Actions/Buttons (7)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoLossCommInspDialog`** | Popup Loss | Mở cửa sổ nhập hao hụt/phế liệu công đoạn. |
| 2 | **`DoFinishCommInsp`** | Hoàn thành QC | Xác nhận hoàn tất quá trình kiểm định chất lượng tài liệu QC. |
| 3 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |
| 4 | **`DoHoldCommInsp`** | Khóa Lot (HOLD) | Đưa Lot hàng sang trạng thái HOLD (tạm khóa chất lượng) để kiểm định thêm. |
| 5 | **`DoLossCommInsp`** | Ghi nhận Loss | Ghi nhận lượng hao hụt/phế liệu phát sinh tại công đoạn kiểm tra. |
| 6 | **`InputDefectCode`** | Nhập mã lỗi | Mở cửa sổ chọn và gán mã lỗi phế phẩm cho sản phẩm. |
| 7 | **`SetHolding`** | HOLD Lot | Thiết lập trạng thái HOLD (tạm dừng sử dụng) đối với Lot. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VNTSELFINSPECTIONRAWMATERIALBE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Không tạo được kế hoạch ngày BG2 | DayPlan table thiếu config WorkCenterCode='VVT_F4' | Kiểm tra `STB_DayProdPlan` + config | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## K110 — VNT_ModuleProductionInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `K110` |
| **Screen Name** | `VNT_ModuleProductionInfo` |
| **Parent Menu** | `VNT_ModuleProdManagement_MENU` |
| **Title** | VNT_ModuleProductionInfo |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Truy cập giao diện `VNT_ModuleProductionInfo` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_VNT_ModuleProductionInfo_get`.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ModuleProductionInfo` | ModuleProductionInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModuleProductionInfo_get` | ???? ? Lot ? ???? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModuleProductionInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VNTMODULEPRODUCTIONINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Scan NVL BG2 bị chặn | NVL kho BG2 chưa config WarehouseCode | Map kho BG2 trong `STB_LineRouteMapping` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## K199 — VNT_NordexPackingLabelPrintingHist_get
| Thông tin | Giá trị |
|---|---|
| **TCode** | `K199` |
| **Screen Name** | `VNT_NordexPackingLabelPrintingHist_get` |
| **Parent Menu** | `PS_ETC_MENU` |
| **Title** | VNT_NordexPackingLabelPrintingHist_get |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 0 ExecuteFunction + 2 Action) |

### Workflow

1. Truy cập giao diện `VNT_NordexPackingLabelPrintingHist_get` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_VNT_NordexPackingLabelPrintingHist_get`.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `NordexPackingLabelPrintingHist` | NordexPackingLabelPrintingHist | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_NordexPackingLabelPrintingHist_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Standard Packing Label`** | Standard  Packing  Label | Thực hiện tác vụ standard  packing  label cho dữ liệu trên màn hình. |
| 2 | **`Jabil Label`** | Jabil  Label | Thực hiện tác vụ jabil  label cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VNTNORDEXPACKINGLABELPRINTINGHISTGET` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |

---

## D000 — VinaEnesol_Management_MENU
| Thông tin | Giá trị |
|---|---|
| **TCode** | `D000` |
| **Screen Name** | `VinaEnesol_Management_MENU` |
| **Parent Menu** | `System` |
| **Title** | VinaEnesol_Management_MENU |
| **Tổng Objects** | **0** (0 View + 0 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Giao diện Menu/Thư mục quản lý hệ thống phân quyền và cấu hình cho đối tác khách hàng VinaEnesol.
2. Hỗ trợ điều hướng nhanh người dùng đến các màn hình quản lý sản lượng, chất lượng và kho riêng biệt của Enesol.

### Views (0)

> Không có View riêng.

### SearchFunctions (0)

> Không có SearchFunction riêng.

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ScreenInfo` | Bảng cấu hình danh mục menu của hệ thống MES. |

---

## D051 — VNE_CustomerPartNoInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `D051` |
| **Screen Name** | `VNE_CustomerPartNoInfo` |
| **Parent Menu** | `VNE_StandardInfo_MENU` |
| **Title** | VNE_CustomerPartNoInfo |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Truy cập giao diện `VNE_CustomerPartNoInfo` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_CustomerPartNo_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_CustomerPartNoInfo_iud`.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `CustomerPartNo` | CustomerPartNo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_CustomerPartNo_get` | Customer Part No ?? |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_CustomerPartNoInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_CUSTOMERPARTNOINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |

---

## D100 — VinaEnesolProductionManagement_MENU
| Thông tin | Giá trị |
|---|---|
| **TCode** | `D100` |
| **Screen Name** | `VinaEnesolProductionManagement_MENU` |
| **Parent Menu** | `VinaEnesol_Management_MENU` |
| **Title** | VinaEnesolProductionManagement_MENU |
| **Tổng Objects** | **0** (0 View + 0 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Menu điều hướng dành riêng cho phân hệ quản lý sản xuất của Enesol.
2. Giúp người dùng Enesol nhanh chóng truy cập các tính năng lập kế hoạch, báo cáo sản lượng cực điện và lắp ráp cell.

### Views (0)

> Không có View riêng.

### SearchFunctions (0)

> Không có SearchFunction riêng.

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ScreenInfo` | Bảng cấu hình danh mục menu của hệ thống MES. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | CustomerPartNo trống khi in tem | `STB_CustomerPartNoInfo` thiếu mapping model→customer | INSERT mapping: xem [KB_25 §5.4](KB_25/KB_25_01_OVERVIEW.md) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | Máy in không chạy hoặc tem trống | Cấu hình printer hoặc label template lỗi | Kiểm tra kết nối printer + template trong Z530 | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 3 | D110 thiếu/trùng bản ghi | Insert duplicate hoặc filter sai | Kiểm tra SP `usp_VNE_BoxLabelPrintHist_*` | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## D110 — VNE_BoxLabelPrintHist
| Thông tin | Giá trị |
|---|---|
| **TCode** | `D110` |
| **Screen Name** | `VNE_BoxLabelPrintHist` |
| **Parent Menu** | `VinaEnesolProductionManagement_MENU` |
| **Title** | VNE_BoxLabelPrintHist |
| **Tổng Objects** | **10** (1 View + 1 SearchFunction + 1 ExecuteFunction + 7 Action) |

### Workflow

1. Truy cập giao diện `VNE_BoxLabelPrintHist` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_VINAEnesolBoxLabelPrintHist_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_VINAEnesolBoxLabelPrintHist_iud`.
6. Quét mã vạch (Barcode) để đối chiếu thông tin tương ứng.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VINAEnesolBoxLabelPrintHist` | VINAEnesolBoxLabelPrintHist | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VINAEnesolBoxLabelPrintHist_get` | ?? ?? ??? ?????. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VINAEnesolBoxLabelPrintHist_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (7)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`VINAEnesolBoxMatchingHist`** | V I N A Enesol Box Matching Hist | Thực hiện tác vụ v i n a enesol box matching hist cho dữ liệu trên màn hình. |
| 2 | **`ProdShipment`** | Prod Shipment | Thực hiện tác vụ prod shipment cho dữ liệu trên màn hình. |
| 3 | **`LabelReprinting`** | Label Reprinting | Thực hiện tác vụ label reprinting cho dữ liệu trên màn hình. |
| 4 | **`2ndBoxLabelPrint`** | 2nd Box Label Print | Thực hiện tác vụ 2nd box label print cho dữ liệu trên màn hình. |
| 5 | **`1stBoxLabelPrint`** | 1st Box Label Print | Thực hiện tác vụ 1st box label print cho dữ liệu trên màn hình. |
| 6 | **`RefreshView`** | Làm mới | Làm mới giao diện hiển thị dữ liệu. |
| 7 | **`PrintLabel`** | In tem | Thực hiện in tem nhãn cho đối tượng đang chọn. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VINAENESOLBOXLABELPRINTHIST` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |

---

## S212 — VisionGroupInspInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `S212` |
| **Screen Name** | `VisionGroupInspInfo` |
| **Parent Menu** | `RawDataInterfaceInfoMENU` |
| **Title** | VisionGroupInspInfo |
| **Tổng Objects** | **2** (1 View + 1 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Truy cập giao diện `VisionGroupInspInfo` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_VisionGroupInspectionInfo_get`.
3. Cập nhật thông tin cấu hình trực tiếp trên giao diện.
6. Quét mã vạch (Barcode) để đối chiếu thông tin tương ứng.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VisionGroupInspectionInfo` | VisionGroupInspectionInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VisionGroupInspectionInfo_get` | ????1 ????? ?????. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VISIONGROUP1INSPECTIONINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_INTERFACEMACHINEINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_VISIONGROUP2INSPECTIONINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_VISIONGROUP3INSPECTIONINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

---

## S213 — VNT_VisionInspectionResult
| Thông tin | Giá trị |
|---|---|
| **TCode** | `S213` |
| **Screen Name** | `VNT_VisionInspectionResult` |
| **Parent Menu** | `RawDataInterfaceInfoMENU` |
| **Title** | VNT_VisionInspectionResult |
| **Tổng Objects** | **2** (1 View + 1 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Thu thập và hiển thị kết quả kiểm tra ngoại quan bằng hệ thống camera tự động (Vision Inspection) được liên kết qua máy sản xuất.
2. Tra cứu kết quả Pass/Fail và các lỗi phát hiện theo Barcode sản phẩm.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VisionInspectionResult` | VisionInspectionResult | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VisionInspectionResult_get` | ?????? ????? ?????. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VisionInspectionResult` | Lưu trữ kết quả chụp ảnh ngoại quan và đánh giá tự động từ camera kiểm tra. |

---

## S215 — VNT_XRFInspInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `S215` |
| **Screen Name** | `VNT_XRFInspInfo` |
| **Parent Menu** | `RawDataInterfaceInfoMENU` |
| **Title** | VNT_XRFInspInfo |
| **Tổng Objects** | **2** (1 View + 1 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

1. Thu thập và hiển thị kết quả đo độ dày lớp phủ cực điện bằng thiết bị quang phổ huỳnh quang tia X (XRF Inspection).
2. Hỗ trợ bộ phận QC giám sát thông số độ dày và đối chiếu chất lượng bán thành phẩm theo thời gian thực.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `XRFInspectionInfo` | XRFInspectionInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_XRFInspectionInfo_get` | XRF????? ?????. |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_XRFInspectionInfo` | Lưu trữ kết quả đo đạc độ dày lớp phủ bằng tia X từ thiết bị kiểm tra. |

---

## B786 — VVT_ESR_data
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B786` |
| **Screen Name** | `VVT_ESR_data` |
| **Parent Menu** | `vi_PQC` |
| **Title** | VVT_ESR_data |
| **Tổng Objects** | **7** (2 View + 2 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

Giao diện **VVT_ESR_data** dùng để thực hiện nghiệp vụ: **Lịch sử ESR**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VVT_ESR_data` từ menu `KB_01, KB_03`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_VVT_ESRdata_get`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_VVT_ESRdata_uid`.

**Lưu ý vận hành:**
- Tab Online: Status OK = đang lấy data


### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VVT_ESRdata` | VVT_ESRdata | Grid hiển thị dữ liệu. |
| 2 | `VVT_ESRMONITOR` | VVT_ESRMONITOR | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVT_ESRdata_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_VVT_ESRMONITOR` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVT_ESRdata_uid` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Save New Data`** | Lưu New  Data | Thực hiện tác vụ lưu new  data cho dữ liệu trên màn hình. |
| 2 | **`Refresh`** | Refresh | Làm mới dữ liệu trên lưới hiển thị. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVT_ESRDATA` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_VVT_ESRDATA_20221230` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VVT_ESRDATA_20220114` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_VVT_ESR_MONITOR` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## B782 — VNT_LotTrackingInfo_vvt22
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B782` |
| **Screen Name** | `VNT_LotTrackingInfo_vvt22` |
| **Parent Menu** | `vi_NGqty` |
| **Title** | VNT_LotTrackingInfo_vvt22 |
| **Tổng Objects** | **5** (1 View + 1 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

Giao diện **VNT_LotTrackingInfo_vvt22** dùng để thực hiện nghiệp vụ: **Lịch sử Routing**.

**Workflow vận hành:**
1. Truy cập vào chức năng `VNT_LotTrackingInfo_vvt22` từ menu `KB_03, KB_31`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_LotTrackingInfo_VVT2_get`.

**Lưu ý vận hành:**
- Tổng lỗi 1 lot


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `LotTrackingInfo` | LotTrackingInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LotTrackingInfo_VVT2_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModifyNotesB782_VVT` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`SaveNotes`** | Save Notes | Thực hiện tác vụ save notes cho dữ liệu trên màn hình. |
| 2 | **`RefreshView`** | Làm mới | Làm mới giao diện hiển thị dữ liệu. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SETINFO` | Lưu thông số kiểm định kết quả đạt/không đạt của Lot. |
| `STB_PRODROUTEHIST` | Lịch sử di chuyển công đoạn sản xuất của Lot sản phẩm. |
| `STB_TYPEERRORGROUPOFFACTORY` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_DEFECTREPAIRINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODUCTIONORDERINFO` | Thông tin chi tiết lệnh sản xuất PO. |
| `STB_DEFECTINFO` | Chi tiết các mã lỗi phế phẩm của hệ thống. |
| `STB_CHANGEDATE220924` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_ROUTEINFO` | Danh mục các công đoạn sản xuất trong Routing. |
| `STB_MATERIALMASTER` | Danh mục thông tin cấu hình nguyên vật liệu và sản phẩm. |
| `STB_LINEINFO` | Thông tin cấu hình dây chuyền sản xuất. |
| `STB_MACHINEMASTER` | Bảng dữ liệu thực tế liên quan đến công đoạn. |
| `STB_PRODWORKERINFO` | Danh sách và thông tin phân ca của nhân viên sản xuất. |
| `STB_MATERIALLOTINFO` | Thông tin chi tiết và trạng thái tồn kho của Lot vật tư. |
| `STB_MODELBASICINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |
| `STB_PRODROUTEHISTNOTES` | Bảng ghi nhận lịch sử giao dịch/in ấn liên quan. |
| `STB_SAVEPACKINGTIME_VVT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## B882 — ANDONReport_V1
| Thông tin | Giá trị |
|---|---|
| **TCode** | `B882` |
| **Screen Name** | `ANDONReport_V1` |
| **Parent Menu** | `v_MachineManage` |
| **Title** | ANDON Repport_V1 |
| **Tổng Objects** | **2** (1 View + 1 SearchFunction + 0 ExecuteFunction + 0 Action) |

### Workflow

Giao diện **ANDONReport_V1** dùng để thực hiện nghiệp vụ: **ANDON MES**.

**Workflow vận hành:**
1. Truy cập vào chức năng `ANDONReport_V1` từ menu `KB_03, KB_31`.
2. Tra cứu và tìm kiếm thông tin bằng bộ lọc hiển thị thông qua Store Procedure `usp_getAndon_v1`.
3. Thực hiện các tác vụ cập nhật dữ liệu (Thêm/Sửa/Xóa hoặc Xác nhận) thông qua Store Procedure `usp_getAndon_v1`.

**Lưu ý vận hành:**
- —


### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `getAndon_v1` | getAndon_v1 | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_getAndon_v1` | L?y d? li?u andon |

### ExecuteFunctions (0)

> Không có ExecuteFunction riêng.

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ANDONREPORTV1` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | ANDON không hiện real-time | WebSocket disconnect hoặc AndonDB query timeout | Kiểm tra kết nối WebSocket + `AndonDB.dbo.ANDON_*` tables | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## Z210 — UserType
| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z210` |
| **Screen Name** | `UserType` |
| **Parent Menu** | `PermissionManagement` |
| **Title** | ????? |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Truy cập giao diện `UserType` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_UserType_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_UserType_iud`.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `UserTypeList` | ????? | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_UserType_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_UserType_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_USERTYPE` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## Z220 — UserTypePermission
| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z220` |
| **Screen Name** | `UserTypePermission` |
| **Parent Menu** | `PermissionManagement` |
| **Title** | ????? |
| **Tổng Objects** | **21** (4 View + 4 SearchFunction + 2 ExecuteFunction + 11 Action) |

### Workflow

1. Truy cập giao diện `UserTypePermission` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_UserType_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_DoSaveUserTypePermissionAll`.

### Views (4)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `UserTypeList` | ????? | Grid hiển thị dữ liệu. |
| 2 | `MenuList` | ????? | Grid hiển thị dữ liệu. |
| 3 | `ViewList` | ???? | Grid hiển thị dữ liệu. |
| 4 | `FunctionList` | ????? | Grid hiển thị dữ liệu. |

### SearchFunctions (4)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_UserType_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_GetViewListForUserType` | Lấy danh sách dữ liệu. |
| 3 | `usp_GetScreenListForUserType` | Lấy danh sách dữ liệu. |
| 4 | `usp_GetFunctionListForUserType` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoSaveUserTypePermissionAll` | Thêm/Sửa/Xóa dữ liệu. |
| 2 | `usp_DoGrantAll` | ?????? ?? ??? ?????. |

### Actions/Buttons (11)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`UnSelectedAll`** | Bỏ chọn tất cả | Hủy chọn tất cả các checkbox trên danh sách. |
| 2 | **`SelectedAll`** | Chọn tất cả | Chọn tất cả các checkbox trên danh sách. |
| 3 | **`SelectedModify`** | Selected Modify | Thực hiện tác vụ selected modify cho dữ liệu trên màn hình. |
| 4 | **`SelectedDelete`** | Selected Delete | Thực hiện tác vụ selected delete cho dữ liệu trên màn hình. |
| 5 | **`SelectedExcel`** | Selected Excel | Thực hiện tác vụ selected excel cho dữ liệu trên màn hình. |
| 6 | **`SelectedImport`** | Selected Import | Thực hiện tác vụ selected import cho dữ liệu trên màn hình. |
| 7 | **`UnSelectedModify`** | Un Selected Modify | Thực hiện tác vụ un selected modify cho dữ liệu trên màn hình. |
| 8 | **`UnSelectedDelete`** | Un Selected Delete | Thực hiện tác vụ un selected delete cho dữ liệu trên màn hình. |
| 9 | **`UnSelectedExcel`** | Un Selected Excel | Thực hiện tác vụ un selected excel cho dữ liệu trên màn hình. |
| 10 | **`UnSelectedImport`** | Un Selected Import | Thực hiện tác vụ un selected import cho dữ liệu trên màn hình. |
| 11 | **`GrantAll`** | Cấp tất cả quyền | Cấp toàn bộ các quyền truy cập màn hình cho nhóm người dùng. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_USERTYPEPERMISSION` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## Z330 — VendorMenuManagement
| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z330` |
| **Screen Name** | `VendorMenuManagement` |
| **Parent Menu** | `ScreenManagement` |
| **Title** | ??????? |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Truy cập giao diện `VendorMenuManagement` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_VendorScreenInfo_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_VendorScreenInfo_get`.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ScreenInfo` | ?????? | Grid hiển thị dữ liệu. |
| 2 | `GetPossableScreenInfo` | GetPossableScreenInfo | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VendorScreenInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_GetPossableScreenInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VendorScreenInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`AddMenu`** | Add Menu | Thực hiện tác vụ add menu cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VENDORMENUMANAGEMENT` | Bảng dữ liệu thực tế liên quan đến công đoạn. |

---

## Z410 — UserInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z410` |
| **Screen Name** | `UserInfo` |
| **Parent Menu** | `UserManagement` |
| **Title** | ????? |
| **Tổng Objects** | **5** (2 View + 2 SearchFunction + 1 ExecuteFunction + 0 Action) |

### Workflow

1. Truy cập giao diện `UserInfo` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_UserInfo_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_UserInfoUserPermissionGroup_iud`.

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `UserList` | ????? | Grid hiển thị dữ liệu. |
| 2 | `UserPermissonGroup` | ??????? | Grid hiển thị dữ liệu. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_UserInfo_get` | Lấy danh sách dữ liệu. |
| 2 | `usp_UserPermissionGroup_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_UserInfoUserPermissionGroup_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (0)

> Không có Action/Button riêng.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_USERINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Tài khoản bị khóa | Nhập sai mật khẩu quá số lần cho phép | Reset tại Z410 hoặc SQL: `UPDATE SmartFramework.dbo.STB_UserInfo SET AllowFlag=1 WHERE UserID='mã'` (⚠️ Cột là `AllowFlag`, KHÔNG có `IsLocked`) | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |
| 2 | User không thấy menu | Chưa gán quyền tại Z220 (UserTypePermission) | Vào Z220 → tick quyền cho UserType | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

## Z530 — LabelInfo
| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z530` |
| **Screen Name** | `LabelInfo` |
| **Parent Menu** | `LabelInfoManagement` |
| **Title** | LabelInfo (Label Design) |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Truy cập giao diện `LabelInfo` để thực hiện cấu hình hoặc tra cứu.
2. Thực hiện tìm kiếm/tra cứu thông tin bằng các bộ lọc qua Store Procedure `usp_LabelInfo_get`.
3. Thực hiện thêm mới, chỉnh sửa hoặc xóa dữ liệu thông qua Store Procedure `usp_LabelInfo_iud`.

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `LabelInfo` | ?????? | Grid hiển thị dữ liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LabelInfo_get` | Lấy danh sách dữ liệu. |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LabelInfo_iud` | Thêm/Sửa/Xóa dữ liệu. |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CopyLabel`** | Copy Label | Thực hiện tác vụ copy label cho dữ liệu trên màn hình. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_LABELINFO` | Bảng thông tin cấu hình hoặc thuộc tính đối tượng. |

### Chú Ý Vận Hành & Lỗi Thường Gặp

| # | Triệu chứng | Nguyên nhân | Cách khắc phục | Quy trình hỗ trợ |
|---|---|---|---|---|
| 1 | Tem in không đúng format | Template label bị sai layout | Vào Z530 → sửa label template → deploy lại | Tra cứu chi tiết tại kịch bản sửa lỗi của màn hình trong KB_31. |

---

# THỐNG KÊ TỔNG HỢP

| Chỉ số | Số lượng |
|---|---|
| **Tổng số màn hình** | **129** |
| **Tổng số Views** | **236** |
| **Tổng số SearchFunctions** | **236** |
| **Tổng số ExecuteFunctions** | **334** |
| **Tổng số Actions/Buttons** | **572** |

---

## Sơ Đồ Quan Hệ Vận Hành Tổng Thể

```
┌─────────────────────────────────────────────────────────────────┐
│                    MASTER DATA (A)                               │
│  A230 (NVL) → A310 (BOM) → A410 (Model) → A460 (Tem)          │
│                                    A419 (Packing Qty)           │
├─────────────────────────────────────────────────────────────────┤
│                    PLANNING (B3xx-B4xx)                          │
│  B310 (PO) → B442 (KH Electrode) → B470 (Process Card)        │
│            → B450 (KH Assembly)  → B452 (Đổi Line)            │
│            → B351 (Đổi Model)    → B353 (Đổi tên Lot)         │
├─────────────────────────────────────────────────────────────────┤
│                    PRODUCTION (B5xx)                              │
│  B530 (Nhập SL) → B523 (Đóng gói) → B525 (Đóng gói kho)      │
│  B540 (Process Card) → B552 (Electrode SX)                     │
│  B597 (QC inline) → B717 (Bending) → B718 (Summary)           │
│  B726 (Scrap) → B754/B756/B757/B758 (In tem KH)               │
├─────────────────────────────────────────────────────────────────┤
│                    QC (C)                                        │
│  C112 (AQL) → C121 (Nhóm QC) → C122 (Gán NVL) → C220 (IQC)  │
│  C131/C132 (Defect Config) → C141/C143 (CommInsp Config)       │
│  C151 (SP QC) → C451 (PQC) → C460 (Electrode QC)              │
│  C510/C512 (OQC Lot) → C530 (OQC) → C531 (OQC Packing)       │
│  C522 (Aging ESR) → C546 (FOQC)                                │
│  C561-C564 (Bending/Cutting QC) → C585 (Defect OQC)           │
├─────────────────────────────────────────────────────────────────┤
│                    WAREHOUSE (F)                                 │
│  F330 (Nhập NVL) → C220 (IQC tự tạo)                          │
│  F312 (Sửa SL) → F430 (Xuất/Move)                             │
│  F710/F721 (Tồn kho) → F740/F741/F743 (Slitting)              │
│  F750 (Stocktaking) → F761 (Lịch sử)                           │
│  G100 (Xuất TP) → G400 (Trả hàng)                              │
├─────────────────────────────────────────────────────────────────┤
│                    REPORTING (B6xx-B8xx)                         │
│  B618 (Rework) → B682 (Lỗi) → B782 (Routing History)          │
│  B786 (ESR) → B802 (Electrode History) → B882 (ANDON)          │
│  B781 (SL Đóng gói) → B789 (Sửa Packing)                      │
└─────────────────────────────────────────────────────────────────┘
```

---

> **Ghi chú:**
> - Tài liệu này được sinh động tự động 100% từ Database `SmartFramework` và `SmartFactoryV2` thực tế.
> - Đảm bảo chính xác tuyệt đối cấu hình và liên kết bảng thực tế của từng đối tượng.
