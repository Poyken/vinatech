# Tài Liệu Chi Tiết Tất Cả Màn Hình MES — Vinatech NAIS

> **Ngày tạo:** 2026-06-27  
> **Nguồn dữ liệu:** DB thực tế `SmartFramework.dbo.STB_ScreenObjects` + `SmartFramework.dbo.STB_ScreenInfo` + `SmartFactoryV2`  
> **Mục đích:** Tài liệu đầy đủ, thống nhất cho từng object (View, SearchFunction, ExecuteFunction, Action/Button) của tất cả các màn hình đã biết trong hệ thống MES.  
> **Lưu ý:** Không bao gồm các màn hình HY clone (HY121, HY122, HY220, HY310, HY442, HY470, HY552, HY802, HY460) — xem `sql/scripts/hy_clone/HY_9_SCREENS_DOCUMENTATION.md`.

---

## Mục Lục

### Nhóm A — Master Data & Cấu Hình
1. [A230 — MaterialMaster](#a230--materialmasterr)
2. [A310 — BomInfo](#a310--bominfo)
3. [A410 — ModelBasicInfo](#a410--modelbasicinfo)
4. [A419 — PackingQtyWarehouse](#a419--packingqtywarehouse)
5. [A460 — ModelLabelInfo](#a460--modellabelinfo)

### Nhóm B — Sản Xuất & Cell Line
6. [B230 — LineRouteMapping](#b230--lineroutemapping)
7. [B250 — MachineMaster](#b250--machinemaster)
8. [B260 — ProdWorkerInfo](#b260--prodworkerinfo)
9. [B270 — ProductMachine](#b270--productmachine)
10. [B310 — ProductionOrderInfo](#b310--productionorderinfo)
11. [B351 — ProductionOrderForChangeMaterial](#b351--productionorderforchangematerial)
12. [B353 — ChangeNameLotNo](#b353--changenamelotno)
13. [B442 — ElectrodePlan_Vietnam](#b442--electrodeplan_vietnam)
14. [B450 — DayProdPlanForMainLot](#b450--dayprodplanformainlot)
15. [B452 — Vietnam_PrintLotChanged](#b452--vietnam_printlotchanged)
16. [B470 — VNT_ElectrodePrcsCard](#b470--vnt_electrodeprcscard)
17. [B523 — Vietnam_Donggoi](#b523--vietnam_donggoi)
18. [B525 — Kho_Donggoi2](#b525--kho_donggoi2)
19. [B530 — VNT_ProdRouteByBarcode](#b530--vnt_prodroutebybarcode)
20. [B540 — AssyCardInfo](#b540--assycardinfo)
21. [B552 — Vietnam_ElectrodeMeasureResult](#b552--vietnam_electrodemeasureresult)
22. [B597 — VNT_SelfInspectionRawMaterial2](#b597--vnt_selfinspectionrawmaterial2)
23. [B618 — ReworkSorting](#b618--reworksorting)
24. [B682 — VvtProdBadStatus](#b682--vvtprodbadstatus)
25. [B717 — BendingTapping](#b717--bendingtapping)
26. [B718 — SummaryTappingBennding](#b718--summarytappingbennding)
27. [B726 — ScrapAfterProduction](#b726--scrapafterproduction)
28. [B754 — VVT_PrintBoxLabelPAC](#b754--vvt_printboxlabelpac)
29. [B756 — PACLabelCartonAndWeight](#b756--paclabelcartonandweight)
30. [B757 — DigiKeyLabelInner_get](#b757--digikeylabelinner_get)
31. [B758 — DigikeyLabelLevelPackage_get](#b758--digikeylabellevelpackage_get)
32. [B781 — VNT_LotTrackingInfo_vvt21](#b781--vnt_lottrackinginfo_vvt21)
33. [B782 — VNT_LotTrackingInfo_vvt22](#b782--vnt_lottrackinginfo_vvt22)
34. [B786 — VVT_ESR_data](#b786--vvt_esr_data)
35. [B789 — VNT_ModuleLotTrackingInfo_vvt21](#b789--vnt_modulelottrackinginfo_vvt21)
36. [B790 — VNT_RawMaterialInputFullHist](#b790--vnt_rawmaterialinputfullhist)
37. [B791 — VNT_ModuleLotTrackingInfo_vvt22](#b791--vnt_modulelottrackinginfo_vvt22)
38. [B802 — Vietnam_EletrodeProdRouteHist](#b802--vietnam_eletrodeprodRoutehist)
39. [B882 — ANDONReport_V1](#b882--andonreport_v1)

### Nhóm C — QC & Kiểm Tra
40. [C112 — AQLBasicRule](#c112--aqlbasicrule)
41. [C121 — QcInspectionGroup](#c121--qcinspectiongroup)
42. [C122 — MaterialQcInspectionItemByMaterial](#c122--materialqcinspectionitembymaterial)
43. [C131 — DefectGroup](#c131--defectgroup)
44. [C132 — DefectInfo](#c132--defectinfo)
45. [C141 — CommInspTypeItemManagement](#c141--comminsptypeitemmanagement)
46. [C143 — CommInspIndividualSpec](#c143--commInspindividualspec)
47. [C151 — MaterialQcInspectionItemByFERT](#c151--materialqcinspectionitembyfert)
48. [C220 — MaterialIqcInfoSampleManagement](#c220--materialiqcinfosamplemanagement)
49. [C243 — CheckSlittingLot](#c243--checkslittinglot)
50. [C321 — VietnamPQC_ReliabilityAssay](#c321--vietnampqc_reliabilityassay)
51. [C430 — VNT_RouteInspectionMeasureFullHist](#c430--vnt_routeinspectionmeasurefullhist)
52. [C443 — Vietnam_inspectionPQC](#c443--vietnam_inspectionpqc)
53. [C451 — SelfInspectionHistoryForBarcode2](#c451--selfinspectionhistoryforbarcode2)
54. [C460 — ElectrodeInspectionHistoryForBarcode](#c460--electrodeinspectionhistoryforbarcode)
55. [C486 — ErrorDataSorting](#c486--errordatasorting)
56. [C510 — MaterialOqcLotManagement](#c510--materialoqclotmanagement)
57. [C512 — SetListForOqcLotManagement_VVT2](#c512--setlistforoqclotmanagement_vvt2)
58. [C522 — Aging_ESR_SD](#c522--aging_esr_sd)
59. [C530 — MaterialOqcInfoSampleManagement](#c530--materialoqcinfosamplemanagement)
60. [C531 — vvt_ProdRouteForPacking_OQC](#c531--vvt_prodrouteforpacking_oqc)
61. [C540 — VNT_ProdInspectionHist](#c540--vnt_prodinspectionhist)
62. [C546 — FOQC_MaterialOqcInfoSampleManagement](#c546--foqc_materialoqcinfosamplemanagement)
63. [C560 — VNT_ProductsReceiptHist](#c560--vnt_productsreceipthist)
64. [C561 — MaterialQcInspectionItemBendingCutting](#c561--materialqcinspectionitembendingcutting)
65. [C562 — SetListForBendingCuttingQCLot](#c562--setlistforbendingcuttingqclot)
66. [C563 — VVT_QC_BendingCutting](#c563--vvt_qc_bendingcutting)
67. [C585 — VVT_DoCreateDefectOQC](#c585--vvt_docreatedefectoqc)

### Nhóm F — Kho (WMS)
68. [F110 — MaterialStockAttributeInfo](#f110--materialstockattributeinfo)
69. [F140 — VendorMappingByMaterialInfo](#f140--vendormappingbymaterialinfo)
70. [F312 — Vietnam_MaterialGrFromOrder](#f312--vietnam_materialgr fromorder)
71. [F320 — MaterialReceipt](#f320--materialreceipt)
72. [F330 — MaterialReceiptAndPrintLabel](#f330--materialreceiptandprintlabel)
73. [F430 — VNT_MaterialWarehouseInOutHist](#f430--vnt_materialwarehouseinouthist)
74. [F610 — MaterialReturnOrder](#f610--materialreturnorder)
75. [F620 — MaterialReturnAndPrintLabel](#f620--materialreturnandprintlabel)
76. [F710 — MaterialStock](#f710--materialstock)
77. [F721 — VVT_MaterialStockList](#f721--vvt_materialstocklist)
78. [F740 — SplitLot](#f740--splitlot)
79. [F741 — SlittingLot](#f741--slittinglot)
80. [F743 — SlittingLOTMaterialHaNam](#f743--slittinglotmaterialhanam)
81. [F744 — WidthSlittingWH](#f744--widthslittingwh)
82. [F750 — MaterialStocktakingDoc](#f750--materialstocktakingdoc)
83. [F761 — VVT_MaterialDocDetailHistory_vvt1](#f761--vvt_materialdocdetailhistory_vvt1)

### Nhóm G — Xuất Kho Thành Phẩm
84. [G100 — SalesGI](#g100--salesgi)
85. [G400 — ProductReturnAndPrintLabel](#g400--productreturnandprintlabel)
86. [G660 — Daifuku_Warehouse](#g660--daifuku_warehouse)

### Nhóm K — Module/Spare Part
87. [K101 — DayProdPlanForMainLotMDL](#k101--dayprodplanformainlotmdl)
88. [K109 — VNT_SelfInspectionRawMaterialBE](#k109--vnt_selfinspectionrawmaterialbe)
89. [K110 — VNT_ModuleProductionInfo](#k110--vnt_moduleproductioninfo)
90. [K199 — VNT_NordexPackingLabelPrintingHist_get](#k199--vnt_nordexpackinglabelprintinghist_get)

### Nhóm D — Enesol
91. [D051 — VNE_CustomerPartNoInfo](#d051--vne_customerpartnoinfo)
92. [D110 — VNE_BoxLabelPrintHist](#d110--vne_boxlabelprintHist)

### Nhóm S — IoT/Vision/XRF
93. [S212 — VisionGroupInspInfo](#s212--visiongroupinspinfo)

### Nhóm Z — Hệ Thống & Phân Quyền
94. [Z110 — BaseCode](#z110--basecode)
95. [Z120 — SerialRule](#z120--serialrule)
96. [Z210 — UserType](#z210--usertype)
97. [Z220 — UserTypePermission](#z220--usertypepermission)
98. [Z330 — VendorMenuManagement](#z330--vendormenumanagement)
99. [Z410 — UserInfo](#z410--userinfo)
100. [Z530 — LabelInfo](#z530--labelinfo)

---

# NHÓM A — MASTER DATA & CẤU HÌNH

---

## A230 — MaterialMaster

| Thông tin | Giá trị |
|---|---|
| **TCode** | `A230` |
| **Screen Name** | `MaterialMaster` |
| **Parent Menu** | `BI_MaterialInformation_MENU` |
| **Title** | Danh mục vật tư (자재정보) |
| **Tổng Objects** | **7** (3 View + 3 SearchFunction + 1 ExecuteFunction) |

### Workflow

1. Tạo/sửa thông tin **nguyên vật liệu** trong hệ thống MES
2. Thiết lập các thuộc tính: `MaterialTypeCode`, `ProductGroupCode`, `MaterialName`, đơn vị đo, NCC
3. Xem lịch sử **Revision** của NVL
4. Xem danh sách **NCC (Vendor)** cung cấp NVL

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  MaterialMaster (Grid chính)                      │
│  ─ Danh sách vật tư                               │
│  ─ Inline edit: Thêm/Sửa vật tư                  │
├──────────────────────────────────────────────────┤
│  Tab: MaterialRevision (Grid revision)            │
│  ─ Lịch sử phiên bản của NVL đang chọn           │
├──────────────────────────────────────────────────┤
│  Tab: MaterialVendor (Grid NCC)                   │
│  ─ Danh sách NCC cung cấp NVL đang chọn          │
└──────────────────────────────────────────────────┘
```

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialMaster` | MaterialMaster | Grid chính — danh sách vật tư. Inline edit. |
| 2 | `MaterialRevision` | MaterialRevision | Tab lịch sử phiên bản NVL. |
| 3 | `MaterialVendor` | MaterialVendor | Tab danh sách NCC cung cấp NVL. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialMaster_get` | Lấy danh sách vật tư |
| 2 | `usp_MaterialRevision_get` | Lấy lịch sử revision của NVL |
| 3 | `usp_MaterialVendor_get` | Lấy danh sách NCC của NVL |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialMaster_iud` | Thêm/Sửa/Xóa vật tư |

### Actions/Buttons (0)

> Màn hình A230 **không có Action/Button riêng**. Thao tác CRUD được thực hiện trực tiếp trên grid (inline edit) thông qua ExecuteFunction.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialMaster` | Danh mục vật tư chính. Key cols: `MaterialCode` (PK), `MaterialTypeCode`, `ProductGroupCode`, `MaterialName` |

---

## A310 — BomInfo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `A310` |
| **Screen Name** | `BomInfo` |
| **Parent Menu** | `BI_Bom_MENU` |
| **Title** | Cấu hình BOM (모델BOM정보) |
| **Tổng Objects** | **15** (5 View + 5 SearchFunction + 3 ExecuteFunction + 2 Action) |

### Workflow

1. Tạo **BOM Header** — chọn sản phẩm chính, phiên bản BOM
2. Thêm **BOM Detail** — danh sách NVL cấu thành + tỷ lệ sử dụng
3. Cấu hình **BOM Facility Route** — gán NVL vào từng công đoạn
4. Tìm NVL từ danh mục Master (`GetBOMMaterialMaster`)
5. Anh Huy phụ trách. Không tính version BOM.

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  BomHeaderList (Grid BOM chính)                   │
│  ─ Danh sách BOM header                          │
│  ─ Toolbar: [MoveMaterial] [Research]             │
├──────────────────────────────────────────────────┤
│  BomDetailList (Grid chi tiết)                    │
│  ─ Danh sách NVL cấu thành cho BOM đang chọn     │
├──────────────────────────────────────────────────┤
│  BomFacilityRoute (Grid Facility Route)           │
│  ─ Gán NVL vào công đoạn                         │
├──────────────────────────────────────────────────┤
│  BomMaterialMasterList (Grid NVL Master)          │
│  ─ Tra cứu NVL từ master data                    │
├──────────────────────────────────────────────────┤
│  BomMaterialMasterSubList (Grid NVL sub)          │
│  ─ Chi tiết NVL phụ                               │
└──────────────────────────────────────────────────┘
```

### Views (5)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `BomHeaderList` | BOM정보 (BOM Header) | Grid chính — danh sách BOM. |
| 2 | `BomDetailList` | BOM세부정보 (BOM Detail) | Chi tiết NVL cấu thành. |
| 3 | `BomFacilityRoute` | BomFacilityRoute | Gán NVL vào công đoạn. |
| 4 | `BomMaterialMasterList` | 품목정보 (Thông tin phẩm mục) | Tra cứu NVL từ master. |
| 5 | `BomMaterialMasterSubList` | 품목목록 (Danh sách phẩm mục) | Chi tiết NVL phụ. |

### SearchFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BomHeader_get` | Lấy danh sách BOM header |
| 2 | `usp_BomDetail_get` | Lấy chi tiết NVL trong BOM |
| 3 | `usp_BomFacilityRoute_get` | Lấy BOM Facility Route |
| 4 | `usp_GetBOMMaterialMaster` | Lấy NVL master cho BOM |
| 5 | `usp_GetBOMMaterialMasterSub` | Lấy NVL sub cho BOM |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_BomHeader_iud` | Thêm/Sửa/Xóa BOM header |
| 2 | `usp_BomDetail_iud` | Thêm/Sửa/Xóa BOM detail |
| 3 | `usp_BomFacilityRoute_iud` | Thêm/Sửa/Xóa BOM Facility Route |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`MoveMaterial`** | BOM에추가 (Thêm vào BOM) | **Thêm NVL vào BOM** — chọn NVL từ grid master → thêm vào BOM detail đang chọn. |
| 2 | **`Research`** | 재검색 (Tìm lại) | **Tìm kiếm lại** — làm mới bộ lọc và tìm kiếm lại NVL master. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_BomHeader` | BOM header. PK: tương ứng MaterialCode + BomVersion |
| `STB_BomDetail` | Chi tiết NVL cấu thành BOM |
| `STB_MaterialMaster` | Danh mục NVL |

---

## A410 — ModelBasicInfo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `A410` |
| **Screen Name** | `ModelBasicInfo` |
| **Parent Menu** | `BI_ModelInformation_MENU` |
| **Title** | Thông số Model (모델정보) |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction) |

### Workflow

1. Thiết lập **thông số kỹ thuật** cho từng model sản phẩm
2. Cấu hình: `OqcType`, `InspectionType`, `Size H/W`, `Vol/Farad`
3. **Hay bị thiếu khi thêm model mới** — gây lỗi không hiển thị Vol/Farad ở các màn hình khác

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  ModelBasicInfo (Grid duy nhất)                   │
│  ─ Danh sách model + thông số kỹ thuật           │
│  ─ Inline edit                                    │
└──────────────────────────────────────────────────┘
```

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ModelBasicInfo` | ModelBasicInfo | Grid duy nhất — danh sách model + thông số. Inline edit. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModelBasicInfo_get` | Lấy danh sách model + thông số |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModelBasicInfo_iud` | Thêm/Sửa/Xóa model |

### Actions/Buttons (0)

> Màn hình A410 **không có Action/Button riêng**. CRUD qua inline edit.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ModelBasicInfo` | Thông số model sản phẩm. Key cols: `ModelCode`, `OqcType`, `InspectionType`, `SizeH`, `SizeW`, `Vol`, `Farad` |

---

## A419 — PackingQtyWarehouse

| Thông tin | Giá trị |
|---|---|
| **TCode** | `A419` |
| **Screen Name** | `PackingQtyWarehouse` |
| **Parent Menu** | `BI_ModelInformation_MENU` |
| **Title** | Cấu hình số lượng đóng gói |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction) |

### Workflow

1. Thiết lập **tiêu chuẩn số lượng đóng gói** cho từng mã sản phẩm
2. Khi thiếu → B523 báo lỗi "chưa có tiêu chuẩn đóng gói"

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  Vietnam_PackingQtyWarehouse_A419 (Grid)          │
│  ─ Danh sách cấu hình đóng gói theo sản phẩm     │
│  ─ Inline edit                                    │
└──────────────────────────────────────────────────┘
```

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Vietnam_PackingQtyWarehouse_A419` | PackingQtyWarehouse | Grid cấu hình đóng gói. Inline edit. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_PackingQtyWarehouse_A419_get` | Lấy danh sách cấu hình đóng gói |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_PackingQtyWarehouse_A419_iud` | Thêm/Sửa/Xóa cấu hình đóng gói |

### Actions/Buttons (0)

> Màn hình A419 **không có Action/Button riêng**. CRUD qua inline edit.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_PackingStandard` | Tiêu chuẩn đóng gói theo sản phẩm |

---

## A460 — ModelLabelInfo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `A460` |
| **Screen Name** | `ModelLabelInfo` |
| **Parent Menu** | `BI_ModelInformation_MENU` |
| **Title** | Cấu hình In Tem theo Model (모델별 라벨정보) |
| **Tổng Objects** | **7** (2 View + 2 SearchFunction + 3 ExecuteFunction) |

### Workflow

1. Chọn **MaterialCode** → xem danh sách mẫu tem đã gán
2. **Tạo mẫu tem** (`DoMakeModelLabelInfo`) → auto-generate từ template
3. **Lưu spec tem** (`DoSaveModelLabelInfoSpec`) → cấu hình chi tiết nội dung in
4. Khi B450 lỗi không in tem → check `AssembleLabel` ở đây
5. Khi B442 lỗi `Not found label type` → check `STB_ModelLabelInfo`

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  MaterialMaster (Grid NVL)                        │
│  ─ Chọn sản phẩm cần cấu hình tem               │
├──────────────────────────────────────────────────┤
│  GetLabelInfoByMaterial (Grid tem)                │
│  ─ Danh sách mẫu tem cho sản phẩm đang chọn     │
│  ─ Inline edit                                    │
└──────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialMaster` | MaterialMaster | Grid chọn sản phẩm. |
| 2 | `GetLabelInfoByMaterial` | GetLabelInfoByMaterial | Grid danh sách mẫu tem theo NVL. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialMaster_get` | Lấy danh sách NVL |
| 2 | `usp_GetLabelInfoByMaterial` | Lấy mẫu tem theo MaterialCode |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModelLabelInfo_iud` | Thêm/Sửa/Xóa cấu hình tem |
| 2 | `usp_DoMakeModelLabelInfo` | Tạo mẫu tem tự động từ template |
| 3 | `usp_DoSaveModelLabelInfoSpec` | Lưu chi tiết spec tem |

### Actions/Buttons (0)

> Màn hình A460 **không có Action/Button riêng**. Thao tác qua inline edit + ExecuteFunction.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ModelLabelInfo` | Cấu hình tem theo model. SmartFactoryV2 |
| `STB_LabelInfo` | Danh mục mẫu tem. SmartFramework |
| `STB_MaterialMaster` | Danh mục NVL |

---

# NHÓM B — SẢN XUẤT & CELL LINE

---

## B230 — LineRouteMapping

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B230` |
| **Screen Name** | `LineRouteMapping` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | Ánh xạ Line-Route (라인공정구성정보) |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Chọn **Line** sản xuất
2. Gán các **công đoạn (Route)** vào Line
3. Sử dụng thay B270 khi B270 bị lỗi popup

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  LineInfo (Grid Line)                             │
│  ─ Danh sách dây chuyền sản xuất                 │
├──────────────────────────────────────────────────┤
│  LineRouteMapping (Grid Mapping)                  │
│  ─ Công đoạn gán cho Line đang chọn              │
│  ─ Toolbar: [UseAll]                              │
└──────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `LineInfo` | LineInfo | Grid danh sách Line. |
| 2 | `LineRouteMapping` | LineRouteMapping | Grid ánh xạ Line → Route. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LineInfo_get` | Lấy danh sách Line |
| 2 | `usp_LineRouteMapping_get` | Lấy mapping Line → Route |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LineRouteMapping_iud` | Thêm/Sửa/Xóa mapping Line → Route |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`UseAll`** | 전체사용 (Dùng tất cả) | **Gán tất cả Route** — gán tất cả công đoạn có sẵn vào Line đang chọn. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_LineInfo` | Danh mục Line |
| `STB_RouteInfo` | Danh mục công đoạn |
| `STB_LineRouteMapping` | Mapping Line ↔ Route |

---

## B250 — MachineMaster

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B250` |
| **Screen Name** | `MachineMaster` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | Thông tin máy (설비정보) |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction) |

### Workflow

1. Quản lý danh mục **máy móc thiết bị** trong nhà máy
2. Inline edit: thêm/sửa thông tin máy

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  MachineMaster (Grid duy nhất)                    │
│  ─ Danh sách máy                                  │
│  ─ Inline edit                                    │
└──────────────────────────────────────────────────┘
```

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MachineMaster` | MachineMaster | Grid danh sách máy. Inline edit. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MachineMaster_get` | Lấy danh sách máy |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MachineMaster_iud` | Thêm/Sửa/Xóa máy |

### Actions/Buttons (0)

> Không có Action/Button. CRUD qua inline edit.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MachineMaster` | Danh mục máy móc thiết bị |

---

## B260 — ProdWorkerInfo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B260` |
| **Screen Name** | `ProdWorkerInfo` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | Thêm công nhân |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction) |

### Workflow

1. Quản lý danh mục **công nhân sản xuất**
2. Inline edit: thêm/sửa thông tin nhân viên

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdWorkerInfo` | ProdWorkerInfo | Grid danh sách công nhân. Inline edit. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProdWorkerInfo_get` | Lấy danh sách công nhân SX |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProdWorkerInfo_iud` | Thêm/Sửa/Xóa công nhân |

### Actions/Buttons (0)

> Không có Action/Button. CRUD qua inline edit.

---

## B270 — ProductMachine

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B270` |
| **Screen Name** | `ProductMachine` |
| **Parent Menu** | `LineProcessStandard` |
| **Title** | Ánh xạ máy-công đoạn (생산설비정보) |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction) |

### Workflow

1. Gán **máy** cho từng **công đoạn sản xuất**
2. Inline edit

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProductMachine` | ProductMachine | Grid ánh xạ máy ↔ công đoạn. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProductMachine_get` | Lấy danh sách ánh xạ máy-công đoạn |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProductMachine_iud` | Thêm/Sửa/Xóa ánh xạ |

### Actions/Buttons (0)

> Không có Action/Button.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProductMachine` | Mapping máy ↔ công đoạn |

---

## B310 — ProductionOrderInfo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B310` |
| **Screen Name** | `ProductionOrderInfo` |
| **Parent Menu** | `PM_ProductionOrder_MENU` |
| **Title** | Lệnh sản xuất — PO (PO정보조회) |
| **Tổng Objects** | **17** (4 View + 4 SearchFunction + 3 ExecuteFunction + 6 Action) |

### Workflow

1. Tạo **PO mới** → chọn sản phẩm, số lượng, ngày SX
2. Hệ thống tự tạo **BOM** + **Routing** theo master data
3. PO được **Fix** → đóng băng, chuẩn bị sản xuất
4. PO fix → B442/B450 sử dụng để tạo kế hoạch ngày
5. Hủy PO → chỉ hủy được khi chưa phát sinh sản lượng
6. Xóa PO phải xóa cả 3 bảng (Info + Bom + Routing) + B450

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

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProductionOrderInfo` | ProductionOrderInfo | Grid chính — danh sách PO. |
| 2 | `ProductionOrderBom` | ProductionOrderBom | Tab BOM — NVL định mức. |
| 3 | `ProductionOrderRouting` | ProductionOrderRouting | Tab Routing — công đoạn SX. Inline edit. |
| 4 | `MaterialGIForPO` | MaterialGIForPO | Tab GI — NVL cần xuất kho. |

### SearchFunctions (4)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProductionOrderInfo_get` | Lấy danh sách PO |
| 2 | `usp_ProductionOrderBom_get` | Lấy BOM theo PO |
| 3 | `usp_ProductionOrderRouting_get` | Lấy Routing theo PO |
| 4 | `usp_GetMaterialGIForPO` | Lấy NVL cần cấp phát |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoFixProductionOrder` | Fix (xác nhận) PO |
| 2 | `usp_DoCancelPO` | Hủy PO |
| 3 | `usp_ProductionOrderRouting_iud` | Sửa/cập nhật Routing |

### Actions/Buttons (6)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CreateManualPO`** | 수동PO생성 (Tạo PO thủ công) | Mở dialog tạo PO mới. Gọi `usp_DoCreateProductionOrder`. |
| 2 | **`Fix`** | 확정 (Xác nhận) | **Fix PO** — xác nhận lệnh SX. Sau Fix → B442 có thể tạo kế hoạch ngày. |
| 3 | **`POCancel`** | POCancel | **Hủy PO** — chỉ hủy được khi chưa phát sinh sản lượng. |
| 4 | **`Refresh`** | Refresh | Làm mới grid chính và tất cả tab phụ. |
| 5 | **`DoGI`** | 자재불출확인 (Xuất kho NVL) | **Goods Issue** — thực hiện xuất kho NVL cho PO. |
| 6 | **`Tao_PO_ReDroping`** | Tao_PO_ReDroping | **Tạo PO Re-Dropping** — tạo PO mới cho cuộn sấy lại. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProductionOrderInfo` | PK: `PONo`. Lệnh SX chính |
| `STB_ProductionOrderBom` | FK: `PONo`. Định mức NVL |
| `STB_ProductionOrderRouting` | FK: `PONo`. Quy trình công đoạn |
| `STB_SetInfo` | Lot/Cuộn tạo ra từ PO |

---

## B351 — ProductionOrderForChangeMaterial

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B351` |
| **Screen Name** | `ProductionOrderForChangeMaterial` |
| **Parent Menu** | `Model_Change` |
| **Title** | Chuyển đổi Lot (Lot 기종변경) |
| **Tổng Objects** | **7** (2 View + 2 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

1. Chọn **kế hoạch ngày** có Lot cần chuyển đổi
2. Chọn **Lot/Set** → đổi sang model khác
3. Sau B351 phải sửa Barcode format

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlanForChangeMaterial` | DayProdPlanForChangeMaterial | Grid kế hoạch ngày. |
| 2 | `SetInfoForChangeMaterial` | SetInfoForChangeMaterial | Grid Lot/Set cần chuyển đổi. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetDayProdPlanForChangeMaterial` | Lấy kế hoạch có Lot đổi model |
| 2 | `usp_GetSetInfoForChangeMaterial` | Lấy Lot cần chuyển đổi |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoChangeMaterialForSetInfo` | Thực hiện chuyển đổi model cho Lot |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ChangeMaterial`** | 기종변경 (Đổi model) | **Chuyển đổi model** — đổi MaterialCode cho Lot đang chọn. |
| 2 | **`RefreshSetInfo`** | RefreshSetInfo | Làm mới grid Lot. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SetInfo` | Lot/Cuộn sản phẩm |
| `STB_LotChangeMaterialHistory` | Lịch sử chuyển đổi model |
| `STB_DayProdPlan` | Kế hoạch ngày |

---

## B353 — ChangeNameLotNo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B353` |
| **Screen Name** | `ChangeNameLotNo` |
| **Parent Menu** | `vi_PriceAndMaterialCodeVN` |
| **Title** | Thay đổi tên lot hàng |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Tìm Lot cần đổi tên
2. Đổi **tên Lot** mới → in lại tem
3. `oldLotID` = tên in tem (VJ prefix)

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ListChangeLotno` | ListChangeLotno | Grid danh sách Lot cần đổi tên. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetListChangeLotno` | Lấy danh sách Lot |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ChangeLotnoPrintTem` | Đổi tên Lot + in tem mới |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới grid. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ChangePartNoAndLotNo` | Lịch sử đổi tên Lot |

---

## B442 — ElectrodePlan_Vietnam

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B442` |
| **Screen Name** | `ElectrodePlan_Vietnam` |
| **Parent Menu** | `v_ElectrodeArea` |
| **Title** | Kế hoạch Điện cực (Ke hoach Dien cuc) |
| **Tổng Objects** | **21** (3 View + 3 SearchFunction + 4 ExecuteFunction + 11 Action) |

### Workflow

1. Chọn PO đã Fix từ B310
2. Tạo **DayProdPlan** → chỉ định sản phẩm, số lượng, dây chuyền
3. Tạo **SetInfo** (Lot/Cuộn) → gán vào Plan
4. **Fix** Plan → đóng băng Lot → cho phép in tem barcode
5. Cancel Plan nếu cần
6. Lỗi `Not found label type` → check `STB_ModelLabelInfo`

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

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlan` | DayProdPlan | Grid trên — kế hoạch SX ngày. |
| 2 | `SetInfo` | SetInfo | Grid giữa — Lot/Cuộn. Inline edit. |
| 3 | `MainAssemblePartWeight` | MainAssemblePartWeight | Grid dưới — trọng lượng phụ kiện. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_get` | Lấy kế hoạch SX ngày |
| 2 | `usp_SetInfo_get` | Lấy Lot/Set trong Plan |
| 3 | `usp_MainAssemblePartWeight_get` | Lấy trọng lượng phụ kiện |

### ExecuteFunctions (4)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_iud` | Thêm/Sửa/Xóa kế hoạch ngày |
| 2 | `usp_SetInfo_iud_VNT` | Tạo/Cập nhật Lot/Set |
| 3 | `usp_DoFixDayProdPlan` | Fix kế hoạch ngày |
| 4 | `usp_DoCancelDayProdPlan` | Hủy kế hoạch ngày |

### Actions/Buttons (11)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`POSelectDialog`** | POSelectDialog | **Chọn PO** — mở popup chọn PO từ B310. Chỉ hiển thị PO đã Fix. |
| 2 | **`FixDayPlan`** | FixDayPlan | **Fix kế hoạch ngày** — đóng băng kế hoạch + Lot. Sau Fix → in tem barcode. |
| 3 | **`CancelDayPlan`** | CancelDayPlan | **Hủy kế hoạch ngày** — chỉ hủy khi chưa phát sinh kết quả SX. |
| 4 | **`Refresh`** | Refresh | Làm mới grid kế hoạch ngày. |
| 5 | **`RefreshSetInfo`** | Refresh | Làm mới grid Lot/Set. |
| 6 | **`CopyLot`** | CopyLot | **Nhân bản Lot** — copy Lot đang chọn → tạo Lot mới giống hệt. |
| 7 | **`LabelPrint`** | LabelPrint | **In nhãn barcode** — in tem cho Lot/Cuộn Electrode. |
| 8 | **`InputLabelQty`** | LabelPrint | **Nhập số lượng in nhãn** — popup nhập SL label cần in. |
| 9 | **`DoGI`** | 자재불출확인 (Xuất kho NVL) | **Goods Issue** — xuất kho NVL phụ cho kế hoạch ngày. |
| 10 | **`AddMainAssemblePart`** | 부품Lot관리 (Quản lý Lot phụ kiện) | **Gán phụ kiện** — popup gán phụ kiện lắp ráp cho Lot. |
| 11 | **`AddPartWeight`** | 부품중량 (Trọng lượng phụ kiện) | **Ghi nhận trọng lượng** — popup ghi nhận trọng lượng phụ kiện. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DayProdPlan` | PK: `DayPlanNo`. Kế hoạch SX ngày |
| `STB_SetInfo` | PK: `ControlNo`. Lot/Cuộn Electrode |
| `STB_ProductionOrderInfo` | Lệnh sản xuất |
| `STB_MainAssemblePartWeight` | Trọng lượng phụ kiện |
| `STB_LabelInfo` | Cấu hình in nhãn |

---

## B450 — DayProdPlanForMainLot

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B450` |
| **Screen Name** | `DayProdPlanForMainLot` |
| **Parent Menu** | `Plan_Management` |
| **Title** | KH sản xuất ngày Assembly (조립 일일생산계획) |
| **Tổng Objects** | **20** (2 View + 2 SearchFunction + 6 ExecuteFunction + 12 Action) |

### Workflow

1. Chọn PO đã Fix → tạo kế hoạch ngày cho **lắp ráp (Assembly)**
2. **Tạo SetInfo** (Lot) → gán vào kế hoạch
3. Fix kế hoạch → đóng băng Lot → cho phép in tem
4. **Cột IsFixed phải tích** thì mới tạo Lot

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  DayProdPlan (Grid trên)                                     │
│  ─ Kế hoạch ngày Assembly                                    │
│  ─ Toolbar: [POSelectDialog] [FixDayPlan] [CancelDayPlan]   │
│             [DoFinishDayPlan] [Refresh] [DoGI]               │
│             [CreateSetInfo] [InputLotQty]                    │
│             [PrintSlteeingLabel] [InputLabelQty]             │
│             [AddMainAssemblePart] [RefreshSetInfo]           │
├──────────────────────────────────────────────────────────────┤
│  SetInfo (Grid dưới)                                         │
│  ─ Danh sách Lot trong kế hoạch                              │
└──────────────────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlan` | DayProdPlan | Grid kế hoạch ngày Assembly. |
| 2 | `SetInfo` | SetInfo | Grid Lot/Set trong kế hoạch. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_get` | Lấy kế hoạch SX ngày |
| 2 | `usp_SetInfo_get` | Lấy Lot/Set |

### ExecuteFunctions (6)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DayProdPlan_iud` | Thêm/Sửa/Xóa kế hoạch ngày |
| 2 | `usp_SetInfo_iud` | Tạo/Cập nhật Lot |
| 3 | `usp_DoFixDayProdPlan` | Fix kế hoạch ngày |
| 4 | `usp_DoCancelDayProdPlan` | Hủy kế hoạch ngày |
| 5 | `usp_DoFinishDayProdPlan` | Đóng kế hoạch ngày |
| 6 | `usp_DoCreateSetInfoForProdQty_VNT` | Tạo SetInfo theo SL sản xuất |

### Actions/Buttons (12)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`POSelectDialog`** | POSelectDialog | **Chọn PO** — popup chọn PO đã Fix. |
| 2 | **`FixDayPlan`** | FixDayPlan | **Fix kế hoạch** — đóng băng kế hoạch + Lot. |
| 3 | **`CancelDayPlan`** | CancelDayPlan | **Hủy kế hoạch** — chỉ hủy khi chưa có SL thực tế. |
| 4 | **`DoFinishDayPlan`** | 계획마감 (Đóng kế hoạch) | **Đóng kế hoạch** — kết thúc kế hoạch ngày. |
| 5 | **`Refresh`** | Refresh | Làm mới grid kế hoạch. |
| 6 | **`RefreshSetInfo`** | Refresh | Làm mới grid Lot. |
| 7 | **`CreateSetInfo`** | CreateSetInfo | **Tạo SetInfo** — tạo Lot mới cho kế hoạch. |
| 8 | **`InputLotQty`** | Lot생성 (Tạo Lot) | **Nhập SL Lot** — popup nhập số lượng tạo Lot. |
| 9 | **`PrintSlteeingLabel`** | 라벨인쇄 (In nhãn) | **In nhãn** — in nhãn barcode cho Lot. |
| 10 | **`InputLabelQty`** | LabelPrint | **Nhập SL in nhãn** — popup nhập SL label. |
| 11 | **`DoGI`** | 자재출고처리 (Xuất kho NVL) | **Goods Issue** — xuất kho NVL cho kế hoạch. |
| 12 | **`AddMainAssemblePart`** | 자재Lot추가 (Thêm Lot NVL) | **Gán NVL** — gán Lot NVL cho Lot Assembly. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DayProdPlan` | Kế hoạch SX ngày |
| `STB_SetInfo` | Lot/Cuộn |
| `STB_ProductionOrderInfo` | Lệnh SX |

---

## B452 — Vietnam_PrintLotChanged

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B452` |
| **Screen Name** | `Vietnam_PrintLotChanged` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Đổi Line / In lại tem Lot |
| **Tổng Objects** | **9** (1 View + 1 SearchFunction + 1 ExecuteFunction + 7 Action) |

### Workflow

1. Tìm Lot cần đổi Line hoặc in lại tem
2. Đổi **mã Line** (`ChangelinecodeVVT`)
3. In lại **tem Lot** với thông tin mới

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Set_VVT_Info` | Set_VVT_Info | Grid danh sách Lot. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Set_VVT_Info_get` | Lấy danh sách Lot VVT |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Set_VVT_Info_get` | Cập nhật thông tin Lot |

### Actions/Buttons (7)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ChangelinecodeVVT`** | Thay doi ma Line | **Đổi Line** — thay đổi mã Line cho Lot. |
| 2 | **`Genus_NewAdd`** | Genus_NewAdd | **Thêm mới Genus** — thêm thông tin genus mới. |
| 3 | **`InputLabelQty`** | In Tem Lot | **Nhập SL in tem** — popup nhập SL tem cần in. |
| 4 | **`PrintGenusNewAdd`** | PrintGenusNewAdd | **In Genus mới** — in tem cho genus vừa thêm. |
| 5 | **`PrintSlteeingLabel`** | 라벨인쇄 (In nhãn) | **In nhãn** — in nhãn barcode cho Lot. |
| 6 | **`Refresh`** | Refresh | Làm mới grid. |
| 7 | **`RefreshSetInfo`** | Refresh | Làm mới SetInfo. |

---

## B523 — Vietnam_Donggoi

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B523` |
| **Screen Name** | `Vietnam_Donggoi` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Đóng gói & In tem (Vietnam_Donggoi) |
| **Tổng Objects** | **49** (3 View + 3 SearchFunction + 10 ExecuteFunction + 36 Action) |

### Workflow

1. Quét **barcode sản phẩm** → load thông tin Lot
2. Nhập **số lượng đóng gói** → tạo Box ID
3. **In tem** Box Label, Taping Label
4. **Gộp box** (MergeBox) hoặc **chia box** (SplitBoxQty)
5. Hủy đóng gói nếu cần (`DoCancelProdPacking`)
6. Lỗi thường gặp: Packing Qty âm, gộp box tự động

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  ProdRouteHist (Grid SL sản xuất)                            │
│  ─ Lịch sử sản lượng routing                                │
├──────────────────────────────────────────────────────────────┤
│  ProdPackingForBarcode (Grid đóng gói)                       │
│  ─ Quét barcode → đóng gói                                  │
│  ─ Rất nhiều Actions/Buttons (36)                            │
├──────────────────────────────────────────────────────────────┤
│  BoxIDForLotNo_VNT (Grid Box)                                │
│  ─ Danh sách Box ID theo Lot                                 │
└──────────────────────────────────────────────────────────────┘
```

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdRouteHist` | ProdRouteHist | Grid SL sản xuất routing. |
| 2 | `ProdPackingForBarcode` | ProdPackingForBarcode | Grid đóng gói theo barcode. |
| 3 | `BoxIDForLotNo_VNT` | BoxIDForLotNo_VNT | Grid Box ID theo Lot. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ProdRouteHist_get` | Lấy lịch sử routing |
| 2 | `usp_Vietnam_GetProdPackingForBarcode_VVT` | Lấy thông tin đóng gói theo barcode |
| 3 | `usp_Vietnam_GetBoxIDForLotNo_VVT` | Lấy Box ID theo Lot |

### ExecuteFunctions (10)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_DoProcessProdPacking_VVT` | Xử lý đóng gói chính |
| 2 | `usp_DoProcessProdPackingByOne_VNT` | Đóng gói từng sản phẩm |
| 3 | `usp_DoCancelProdPacking_LotNo` | Hủy đóng gói theo LotNo |
| 4 | `usp_DoCreatePackingLabelInfo` | Tạo thông tin tem đóng gói |
| 5 | `usp_PackingLabelPrintInfo` | Lấy thông tin in tem |
| 6 | `usp_savePackingLabelQty_VVT` | Lưu số lượng tem đóng gói |
| 7 | `usp_SplitPackingBox` | Chia box đóng gói |
| 8 | `usp_BoxCheckSetupValue` | Kiểm tra giá trị thiết lập Box |
| 9 | `usp_BoxCheckSetupValueTwo` | Kiểm tra giá trị thiết lập Box v2 |
| 10 | `usp_ZYSLabelPrintHist_iud` | Lưu lịch sử in tem ZYS |

### Actions/Buttons (36)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`InputBoxQty`** | In Tem & | **Nhập SL Box + In tem** — nhập số lượng đóng gói + in tem. |
| 2 | **`InputLabelQty`** | In nhan | **Nhập SL in nhãn** — popup nhập SL label. |
| 3 | **`LabelPrint`** | LabelPrint | **In nhãn** — in nhãn barcode cho sản phẩm. |
| 4 | **`DoProductionByBoxCount`** | BoxID생성 (Tạo BoxID) | **Tạo Box ID** — tạo mã Box mới cho đóng gói. |
| 5 | **`MergeBox`** | Box합치기 (Gộp Box) | **Gộp Box** — gộp nhiều Box nhỏ thành Box lớn. |
| 6 | **`PreMergeBox`** | PreMergeBox | **Chuẩn bị gộp Box** — chọn Box cần gộp trước khi thực hiện. |
| 7 | **`SplitBoxQty`** | Chia box | **Chia Box** — chia Box lớn thành nhiều Box nhỏ. |
| 8 | **`SplitBoxQtyProc`** | SplitBoxQtyProc | **Xử lý chia Box** — thực hiện chia Box. |
| 9 | **`DoCancelProdPacking`** | 실적취소 (Hủy thực tế) | **Hủy đóng gói** — hủy kết quả đóng gói. |
| 10 | **`DeleteData`** | 데이터삭제 (Xóa dữ liệu) | **Xóa dữ liệu** — xóa dữ liệu đóng gói. |
| 11 | **`DeleteAndRefresh`** | DeleteAndRefresh | **Xóa + Làm mới** — xóa dữ liệu rồi làm mới grid. |
| 12 | **`Refresh`** | Refresh | Làm mới grid chính. |
| 13 | **`BoxIDInfoRefresh`** | BoxIDInfoRefresh | Làm mới grid Box ID. |
| 14 | **`LotRefresh`** | LotRefresh | Làm mới grid Lot. |
| 15 | **`OnlyRefresh`** | OnlyRefresh | Chỉ làm mới (không load lại data). |
| 16 | **`Refresh2`** | 취소 (Hủy) | **Hủy thao tác** — undo thao tác hiện tại. |
| 17 | **`IsLabelPrint`** | IsLabelPrint | **Kiểm tra đã in nhãn** — check sản phẩm đã in nhãn chưa. |
| 18 | **`SaveLabelInfo`** | Luu Packing Qty | **Lưu SL đóng gói** — lưu số lượng Packing. |
| 19 | **`SaveLabelInfo2`** | SaveLabelInfo2 | **Lưu label info v2** — lưu thông tin label phiên bản 2. |
| 20 | **`SavePrintQty`** | SavePrintQty | **Lưu SL in** — lưu số lượng đã in. |
| 21 | **`HelaBarcodePrint`** | HelaBarcodePrint | **In Barcode HELA** — in barcode theo format HELA. |
| 22 | **`PrintLabelWH`** | PrintLabelWH | **In nhãn kho** — in nhãn cho kho warehouse. |
| 23 | **`PrintSagem`** | PrintSagem | **In SAGEM** — in tem theo format SAGEM. |
| 24 | **`SagemCom`** | Open Sagem | **Mở SAGEM** — mở giao tiếp SAGEM. |
| 25 | **`SetSagem1`** | Set.Sagem1 | **Cấu hình SAGEM** — thiết lập SAGEM. |
| 26 | **`TapingLabel`** | In Label Taping | **In Label Taping** — in nhãn taping cho sản phẩm. |
| 27 | **`PackingLotRemainQty`** | PackingLotRemainQty | **SL còn lại** — hiển thị SL Lot chưa đóng gói. |
| 28 | **`Lotweightshow`** | Lot weight show | **Hiển thị cân nặng Lot** — popup xem cân nặng. |
| 29 | **`DoDummy`** | DoDummy | **Dummy action** — action placeholder. |
| 30 | **`ChonSoLuongIntem`** | Chọn số lượng in tem | **Chọn SL in tem** — popup chọn SL tem. |
| 31 | **`IntemThepPartNo`** | In tem hộp | **In tem hộp** — in tem hộp theo PartNo. |
| 32 | **`ZYS_InputLabelQty`** | ZYS_InputLabelQty | **ZYS: Nhập SL in** — nhập SL label ZYS. |
| 33 | **`ZYS_IsLabelPrint`** | ZYS_IsLabelPrint | **ZYS: Kiểm tra in** — check ZYS đã in chưa. |
| 34 | **`ZYS_PrintLabel`** | ZYS_PrintLabel | **ZYS: In nhãn** — in nhãn ZYS. |
| 35 | **`ZYS_SavePrintHist`** | ZYS_SavePrintHist | **ZYS: Lưu lịch sử in** — lưu lịch sử in ZYS. |
| 36 | **`ZYS_SetLotQty`** | In Tem ZYS | **ZYS: In tem** — in tem theo format ZYS. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DividePackaging` | Thông tin đóng gói |
| `STB_SavePackingTime_VVT` | Lưu thời gian đóng gói |
| `STB_ProdRouteHist` | Lịch sử routing |
| `STB_SetInfo` | Lot/Cuộn |

---

## B530 — VNT_ProdRouteByBarcode

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B530` |
| **Screen Name** | `VNT_ProdRouteByBarcode` |
| **Parent Menu** | `Packaging_Label_Info` |
| **Title** | Nhập SL sản xuất (제품 생산실적입력) |
| **Tổng Objects** | **31** (3 View + 3 SearchFunction + 10 ExecuteFunction + 18 Action) |

### Workflow

1. Quét **barcode sản phẩm** tại công đoạn → load lịch sử routing
2. Nhập **sản lượng thực tế** (ProdQty, DefectQty)
3. **Pass/Fail** sản phẩm → `PassBarcodeForRoute` / `FailBarcodeForRoute`
4. Nhập **lỗi (Defect)** nếu có
5. **Hoàn thành** → `ProdFinish`
6. Bắt buộc nhập "Making"

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  ProdRouteHistForBarcode_VNT (Grid chính)                    │
│  ─ Lịch sử routing theo barcode                              │
│  ─ Toolbar: [Pass] [Fail] [ProdFinish] [LotProdStart]       │
│             [AddDefect] [Refresh] [RefreshView]              │
│             [RefreshDefectView] [SplitLotAging]              │
│             [TranferRepair] [PrintWasteLabel]                │
│             và nhiều action khác...                           │
├──────────────────────────────────────────────────────────────┤
│  ProdRouteBarcodeForDefect_VNT (Grid lỗi)                    │
│  ─ Danh sách lỗi defect cho barcode đang chọn               │
├──────────────────────────────────────────────────────────────┤
│  WasteWeight (Grid phế liệu)                                │
│  ─ Trọng lượng phế liệu                                     │
└──────────────────────────────────────────────────────────────┘
```

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdRouteHistForBarcode_VNT` | ProdRouteHistForBarcode_VNT | Grid chính — routing theo barcode. |
| 2 | `ProdRouteBarcodeForDefect_VNT` | ProdRouteBarcodeForDefect_VNT | Grid lỗi defect. |
| 3 | `WasteWeight` | WasteWeight | Grid phế liệu. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetProdRouteHistForBarcode_VNT` | Lấy routing theo barcode |
| 2 | `usp_GetProdRouteBarcodeForDefect_VNT` | Lấy defect theo barcode |
| 3 | `usp_WasteWeight_get` | Lấy trọng lượng phế liệu |

### ExecuteFunctions (10)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | Xử lý sản lượng routing chính |
| 2 | `usp_DoProcessDefectRepairInfoByBarcode_SmartApp` | Xử lý lỗi defect |
| 3 | `usp_PassBarcodeForRoute` | Đánh dấu Pass cho barcode |
| 4 | `usp_FailBarcodeForRoute` | Đánh dấu Fail cho barcode |
| 5 | `usp_DoCreateTaktTimeForRoute` | Tạo Takt Time |
| 6 | `usp_InterimProdQtyInfo_iud` | Nhập SL tạm thời |
| 7 | `usp_AddRepairInfor_BG2` | Thêm thông tin sửa chữa BG2 |
| 8 | `usp_DoSplitLotAgingHN` | Chia Lot Aging HN |
| 9 | `usp_DoUpdateDRIExtText02_iud` | Cập nhật DRI ExtText02 |
| 10 | `usp_DoUpdateProdRouteHistMarkingLetter` | Cập nhật Marking Letter |

### Actions/Buttons (18)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Pass`** | Pass | **Pass sản phẩm** — đánh dấu OK. |
| 2 | **`Fail`** | Fail | **Fail sản phẩm** — đánh dấu NG. |
| 3 | **`ProdFinish`** | 실적완료 (Hoàn thành SX) | **Hoàn thành** — hoàn thành nhập SL sản xuất. |
| 4 | **`LotProdStart`** | LotProdStart | **Bắt đầu SX Lot** — bắt đầu sản xuất Lot. |
| 5 | **`AddDefect`** | 불량입력 (Nhập lỗi) | **Nhập lỗi** — thêm defect cho sản phẩm. |
| 6 | **`InputInterimProdQty`** | InputInterimProdQty | **Nhập SL tạm** — nhập sản lượng tạm thời. |
| 7 | **`Refresh`** | Refresh | Làm mới grid chính. |
| 8 | **`RefreshView`** | RefreshView | Làm mới view. |
| 9 | **`RefreshDefectView`** | RefreshDefectView | Làm mới grid lỗi. |
| 10 | **`DeleteView`** | DeleteView | Xóa view hiện tại. |
| 11 | **`SplitLotAging`** | Chia Lot Aging | **Chia Lot Aging** — chia Lot để Aging riêng. |
| 12 | **`DoSplitLotAgingHN`** | DoSplitLotAgingHN | **Chia Lot Aging HN** — chia Lot Aging cho Hà Nam. |
| 13 | **`TranferRepair`** | Chuyển repair | **Chuyển Repair** — chuyển SP sang repair. |
| 14 | **`PrintWasteLabel`** | PrintWasteLabel | **In nhãn phế liệu** — in tem cho phế liệu. |
| 15 | **`ReSend`** | ReSend | **Gửi lại** — gửi lại dữ liệu. |
| 16 | **`UpdateMarkingLetter`** | UpdateMarkingLetter | **Cập nhật Marking** — cập nhật ký hiệu marking. |
| 17 | **`DoUpdateDRIExtText02`** | DoUpdateDRIExtText02 | **Cập nhật DRI** — cập nhật text mở rộng. |
| 18 | **`지연사유등록`** | 지연사유등록 (Đăng ký lý do chậm) | **Lý do chậm** — đăng ký lý do trì hoãn. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProdRouteHist` | Lịch sử routing sản xuất |
| `STB_DefectRepairInfo` | Thông tin sửa lỗi |
| `STB_SetInfo` | Lot/Cuộn |

---

## B597 — VNT_SelfInspectionRawMaterial2

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B597` |
| **Screen Name** | `VNT_SelfInspectionRawMaterial2` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | QC inline scan NVL (VNT_SelfInspectionRawMaterial_VVT) |
| **Tổng Objects** | **17** (2 View + 2 SearchFunction + 6 ExecuteFunction + 7 Action) |

### Workflow

1. Quét **barcode NVL** tại trạm sản xuất → kiểm tra NVL hợp lệ
2. Nhập **kết quả kiểm tra** (đo thông số)
3. **Pass/Fail** NVL
4. SP chặn: HOLD + Hết hạn + Sai chủng loại

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  RawMaterialInputHist (Grid nhập NVL)                        │
│  ─ Lịch sử nhập NVL theo barcode                            │
├──────────────────────────────────────────────────────────────┤
│  CommInspectionHistoryForBarcode (Grid QC)                    │
│  ─ Lịch sử kiểm tra QC inline                               │
│  ─ Toolbar: [DoFinishCommInsp] [DoHoldCommInsp]              │
│             [DoLossCommInsp] [DoLossCommInspDialog]          │
│             [InputDefectCode] [Refresh] [SetHolding]         │
└──────────────────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `RawMaterialInputHist` | RawMaterialInputHist | Grid nhập NVL theo barcode. |
| 2 | `CommInspectionHistoryForBarcode` | SelfInspectionHistoryForBarcode | Grid lịch sử kiểm tra QC inline. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_RawMaterialInputHist_get` | Lấy lịch sử nhập NVL |
| 2 | `usp_GetCommInspectionHistoryForBarcode` | Lấy lịch sử kiểm tra QC |

### ExecuteFunctions (6)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_RawMaterialInputHist_uid` | Nhập lịch sử NVL |
| 2 | `usp_RawMaterialInputHist_iud` | Thêm/Sửa/Xóa lịch sử NVL |
| 3 | `usp_DoAddCommInspMeasureHistForBarcode` | Lưu kết quả đo QC |
| 4 | `usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_iud` | Lưu kết quả self-inspection |
| 5 | `usp_DoFinishCommInspDoc` | Phê duyệt QC — OK |
| 6 | `usp_DoFinishCommInspDoc_VNT` | Phê duyệt QC — OK (VNT mở rộng) |

### Actions/Buttons (7)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoFinishCommInsp`** | 검사합격 (QC Pass) | **Pass QC** — xác nhận NVL đạt kiểm tra. |
| 2 | **`DoHoldCommInsp`** | 검사부적합처리 (Hold) | **Hold NVL** — giữ NVL chờ xử lý. |
| 3 | **`DoLossCommInsp`** | DoLossCommInsp | **Hủy NVL (Loss)** — đánh dấu NVL hỏng. |
| 4 | **`DoLossCommInspDialog`** | 제품폐기 (Phế phẩm) | **Dialog Loss** — xác nhận hủy NVL. |
| 5 | **`InputDefectCode`** | 검사부적합 (Nhập lỗi) | **Nhập mã lỗi** — chọn mã defect. |
| 6 | **`Refresh`** | Refresh | Làm mới grid. |
| 7 | **`SetHolding`** | SetHolding | **Đặt Hold** — đặt trạng thái Hold trên grid. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_RawMaterialInputHist` | Lịch sử nhập NVL |
| `STB_CommInspDocHistory` | Phiếu kiểm tra QC |
| `STB_CommInspDocItemHistory` | Hạng mục trong phiếu QC |

---

> **📋 Phần tiếp theo:** Các màn hình B618→B882, Nhóm C (QC), Nhóm F (Kho), Nhóm G/K/D/S/Z nằm ở phần dưới.

---

## B618 — ReworkSorting

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B618` |
| **Screen Name** | `ReworkSorting` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Lịch sử SX lại (Rework Sorting) |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 2 ExecuteFunction) |

### Workflow

1. Theo dõi lịch sử **sản xuất lại** (rework)
2. Chỉ theo dõi, không thao tác phức tạp

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VN_BENDING_TAPPING` | Rework Sorting | Grid lịch sử rework. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_new_Tapping_VVT_get` | Lấy dữ liệu rework |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_new_Tapping_VVT_iud` | Cập nhật dữ liệu rework |
| 2 | `usp_STB_BENDING_TAPPING` | Xử lý bending/tapping |

### Actions/Buttons (0)

> Không có Action/Button.

---

## B682 — VvtProdBadStatus

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B682` |
| **Screen Name** | `VvtProdBadStatus` |
| **Parent Menu** | `vi_NGqty` |
| **Title** | Report lỗi cell line (VvtProdBadStatus) |
| **Tổng Objects** | **6** (3 View + 3 SearchFunction) |

### Workflow

1. Xem **báo cáo tổng hợp lỗi** cell line — READ-ONLY
2. Tab trên: SUM lỗi theo nhóm
3. Tab dưới: chi tiết lỗi theo Lot

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `ProdBadStatus` | ProdBadStatus | Grid tổng hợp lỗi. |
| 2 | `ProdBadStatus_Detail` | ProdBadStatus_Detail | Grid chi tiết lỗi. |
| 3 | `ProdBadStatus_LotCheck` | ProdBadStatus_LotCheck | Grid kiểm tra Lot lỗi. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Get_VVT_Prod_Bad_Status` | Lấy tổng hợp lỗi |
| 2 | `usp_Get_VVT_Prod_Bad_Stat_tail` | Lấy chi tiết lỗi |
| 3 | `usp_GetProdBadStatus_LotCheck` | Kiểm tra Lot lỗi |

### ExecuteFunctions (0)

> READ-ONLY — không có ExecuteFunction.

### Actions/Buttons (0)

> Không có Action/Button.

---

## B717 — BendingTapping

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B717` |
| **Screen Name** | `BendingTapping` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Theo dõi Bending và Tapping |
| **Tổng Objects** | **8** (1 View + 1 SearchFunction + 3 ExecuteFunction + 4 Action) |

### Workflow

1. Nhập kết quả **Bending** (bẻ cong) và **Tapping** (dán keo)
2. In tem **Marking**
3. Chỉ lưu 1 lần đầu

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VN_BENDING_TAPPING` | VN_BENDING_TAPPING | Grid kết quả Bending/Tapping. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_new_Tapping_VVT_get` | Lấy dữ liệu Bending/Tapping |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_new_Tapping_VVT_iud` | Lưu kết quả Bending/Tapping |
| 2 | `usp_STB_BENDING_TAPPING` | Xử lý Bending/Tapping |
| 3 | `usp_MarkingLabelPrintHistVVT_iud` | Lưu lịch sử in tem Marking |

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PrintLabel`** | In tem Marking | **In tem Marking** — in nhãn đánh dấu. |
| 2 | **`PrintMarkingLabel`** | PrintMarkingLabel | **In Marking Label** — in nhãn marking v2. |
| 3 | **`RefreshView`** | RefreshView | Làm mới view. |
| 4 | **`SavePrintHist`** | SavePrintHist | **Lưu lịch sử in** — lưu thông tin đã in. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VN_BENDING_TAPPING` | Dữ liệu Bending/Tapping |

---

## B726 — ScrapAfterProduction

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B726` |
| **Screen Name** | `ScrapAfterProduction` |
| **Parent Menu** | `vi_NGqty` |
| **Title** | Phế sau sản xuất |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Ghi nhận **phế liệu sau sản xuất** (scrap)
2. Xóa mềm: `IsDeleted = 1`

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `vn_scrapafterproduction` | vn_scrapafterproduction | Grid phế liệu. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_vn_scrapafterproduction` | Lấy danh sách phế liệu |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_addscrapafterproduction` | Thêm phế liệu |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ViewDetails`** | Xem thông tin chi tiết | **Xem chi tiết** — mở popup xem chi tiết phế liệu. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VN_SCRAP_AFTERPRODUCTIONS` | Phế sau SX. Xóa mềm: `IsDeleted = 1` |

---

## B754 — VVT_PrintBoxLabelPAC

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B754` |
| **Screen Name** | `VVT_PrintBoxLabelPAC` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | In tem thùng Khách hàng PAC |
| **Tổng Objects** | **6** (1 View + 1 SearchFunction + 1 ExecuteFunction + 4 Action) |

### Workflow

1. Tra cứu **thông tin Box Label** cho khách hàng PAC
2. **In tem thùng** → lưu lịch sử in

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `PACBoxLabalInfo_Vietnam` | PACBoxLabalInfo_Vietnam | Grid thông tin Box Label PAC. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_PACBoxLabalInfo_get_Vietnam` | Lấy thông tin Box Label PAC |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VN_PACBoxLabelPrintHist_iud` | Lưu lịch sử in tem PAC |

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`PrintLabelPAC`** | IN TEM | **In tem PAC** — in tem thùng cho khách hàng PAC. |
| 2 | **`SavePrintHist`** | SavePrintHist | **Lưu lịch sử in** — lưu thông tin đã in. |
| 3 | **`RefreshView`** | RefreshView | Làm mới view. |
| 4 | **`DeleteData`** | DeleteData | **Xóa dữ liệu** — xóa record đã chọn. |

---

## B756 — PACLabelCartonAndWeight

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B756` |
| **Screen Name** | `PACLabelCartonAndWeight` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | PAC Carton & Weight Label |
| **Tổng Objects** | **5** (1 View + 1 SearchFunction + 4 Action) |

### Workflow

1. Tra cứu **thông tin Carton** và **cân nặng** cho khách hàng PAC
2. In tem **Carton** và tem **cân nặng**

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `PACLabelCartonWeight_Vietnam` | PACLabelCartonWeight_Vietnam | Grid thông tin Carton + Weight. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_PACLabelCartonWeight_get_Vietnam` | Lấy thông tin Carton + Weight PAC |

### Actions/Buttons (4)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CartonNumberLabel`** | Tem thùng Carton | **In tem Carton** — in tem đánh số thùng. |
| 2 | **`SetLabelQty`** | Tem Cân Nặng | **In tem cân nặng** — in tem ghi cân nặng. |
| 3 | **`PrintWeightLabel`** | PrintWeightLabel | **In tem Weight** — in nhãn cân nặng. |
| 4 | **`PrintTestLabel`** | PrintTestLabel | **In tem test** — in tem thử nghiệm. |

---

## B781 — VNT_LotTrackingInfo_vvt21

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B781` |
| **Screen Name** | `VNT_LotTrackingInfo_vvt21` |
| **Parent Menu** | `vi_Productionqty` |
| **Title** | Tra SL đóng gói |
| **Tổng Objects** | **7** (1 View + 1 SearchFunction + 3 ExecuteFunction + 3 Action) |

### Workflow

1. Tra cứu **số lượng đóng gói** theo Lot
2. Sửa **SL đóng gói** theo level / classify
3. Nhập tay ở B523

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `Vietnam_PackPrintTime_view` | Vietnam_PackPrintTime_view | Grid SL đóng gói. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_Vietnam_PackPrintTime_get` | Lấy SL đóng gói theo Lot |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModifyPack_VVT_iud` | Sửa thông tin đóng gói |
| 2 | `usp_ModifyPackingQtyByClassify_VVT` | Sửa SL theo classify |
| 3 | `usp_ModifyPackingQtyByLevel_VVT` | Sửa SL theo level |

### Actions/Buttons (3)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`LuuSave`** | Luu - Save | **Lưu** — lưu thay đổi. |
| 2 | **`refressh`** | Refresh | Làm mới grid. |
| 3 | **`SaveClassQty`** | Lưu số lượng cấp | **Lưu SL cấp** — lưu SL theo phân cấp. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_SavePackingTime_VVT` | Thông tin đóng gói theo thời gian |

---

## B782 — VNT_LotTrackingInfo_vvt22

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B782` |
| **Screen Name** | `VNT_LotTrackingInfo_vvt22` |
| **Parent Menu** | `vi_NGqty` |
| **Title** | Lịch sử Routing |
| **Tổng Objects** | **5** (1 View + 1 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

1. Tra cứu **lịch sử routing** của 1 Lot — tổng lỗi
2. Ghi chú (Notes) cho Lot

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `LotTrackingInfo` | LotTrackingInfo | Grid lịch sử routing. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LotTrackingInfo_VVT2_get` | Lấy lịch sử routing theo Lot |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_ModifyNotesB782_VVT` | Cập nhật Notes cho Lot |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`RefreshView`** | RefreshView | Làm mới view. |
| 2 | **`SaveNotes`** | Save Notes | **Lưu ghi chú** — lưu notes cho Lot. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProdRouteHist` | Lịch sử routing |

---

## B786 — VVT_ESR_data

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B786` |
| **Screen Name** | `VVT_ESR_data` |
| **Parent Menu** | `vi_PQC` |
| **Title** | Lịch sử ESR |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 1 ExecuteFunction + 2 Action) |

### Workflow

1. Xem **dữ liệu ESR** (Equivalent Series Resistance) của sản phẩm
2. Tab Online: Status OK = đang lấy data
3. Lưu data ESR mới

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `VVT_ESRdata` | VVT_ESRdata | Grid dữ liệu ESR. |
| 2 | `VVT_ESRMONITOR` | VVT_ESRMONITOR | Grid monitor ESR realtime. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVT_ESRdata_get` | Lấy dữ liệu ESR |
| 2 | `usp_VVT_ESRMONITOR` | Lấy dữ liệu monitor ESR |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_VVT_ESRdata_uid` | Lưu dữ liệu ESR |

### Actions/Buttons (2)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`Refresh`** | Refresh | Làm mới grid. |
| 2 | **`Save New Data`** | Save New Data | **Lưu data mới** — lưu dữ liệu ESR mới. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_VVT_ESRDATA` | Dữ liệu ESR |

---

> **Tài liệu tiếp tục ở phần sau với Nhóm C (QC), Nhóm F (Kho), Nhóm G/K/D/S/Z.**
> Tổng cộng 100+ màn hình được ghi nhận với format thống nhất.

---

# NHÓM C — QC & KIỂM TRA

---

## C112 — AQLBasicRule

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C112` |
| **Screen Name** | `AQLBasicRule` |
| **Parent Menu** | `QM_BI_Statistics_MENU` |
| **Title** | Cấu hình mẫu AQL (AQL 기준정보) |
| **Tổng Objects** | **3** (1 View + 1 SearchFunction + 1 ExecuteFunction) |

### Workflow

1. Cấu hình **quy tắc AQL** (Acceptable Quality Level) chuẩn
2. Thiết lập số lượng mẫu, mức chấp nhận theo AQL level

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `AqlBasicRule` | AqlBasicRule | Grid cấu hình AQL. Inline edit. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_AqlBasicRule_get` | Lấy danh sách quy tắc AQL |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_AqlBasicRule_iud` | Thêm/Sửa/Xóa quy tắc AQL |

### Actions/Buttons (0)

> Không có Action/Button. CRUD qua inline edit.

---

## C121 — QcInspectionGroup

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C121` |
| **Screen Name** | `QcInspectionGroup` |
| **Parent Menu** | `QM_BI_IQC_MENU` |
| **Title** | Quản lý nhóm/hạng mục QC (검사그룹/항목관리) |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 2 ExecuteFunction) |

### Workflow

1. Tạo **nhóm kiểm tra** (vd: "Kiểm tra ngoại quan", "Kiểm tra kích thước")
2. Trong mỗi nhóm, thêm các **hạng mục kiểm tra** (vd: "Chiều dài", "Chiều rộng")
3. Mỗi hạng mục có: loại dữ liệu (số/checkbox), đơn vị đo, giới hạn USL/LSL/UCL/LCL, AQL, Inspection Level
4. Data C121 → C122 reference → C220 tự động áp dụng khi tạo phiếu IQC

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  QcInspectiongroupList (Grid trên)                │
│  ─ Danh sách nhóm kiểm tra QC                    │
│  ─ Chọn 1 row → load grid dưới                   │
├──────────────────────────────────────────────────┤
│  QcInspectionItem (Grid dưới)                     │
│  ─ Các hạng mục trong nhóm đang chọn             │
│  ─ Inline edit                                    │
└──────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `QcInspectiongroupList` | QcInspectiongroupList | Grid danh sách nhóm QC. Chọn → load Item. |
| 2 | `QcInspectionItem` | QcInspectionItem | Grid hạng mục QC trong nhóm. Inline edit. |

### SearchFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_QcInspectionGroup_get` | Lấy danh sách nhóm QC |
| 2 | `usp_QcInspectionItem_get` | Lấy hạng mục QC theo nhóm |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_QcInspectionGroup_iud` | Thêm/Sửa/Xóa nhóm QC |
| 2 | `usp_QcInspectionItem_iud` | Thêm/Sửa/Xóa hạng mục QC |

### Actions/Buttons (0)

> Không có Action/Button. CRUD qua inline edit.

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_QcInspectionGroup` | Danh mục nhóm kiểm tra |
| `STB_QcInspectionItem` | Danh mục hạng mục kiểm tra |

---

## C122 — MaterialQcInspectionItemByMaterial

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C122` |
| **Screen Name** | `MaterialQcInspectionItemByMaterial` |
| **Parent Menu** | `QM_BI_IQC_MENU` |
| **Title** | Tiêu chuẩn kiểm tra nguyên liệu (자재별검사항목) |
| **Tổng Objects** | **9** (2 View + 1 SearchFunction + 1 ExecuteFunction + 5 Action) |

### Workflow

1. Chọn **MaterialCode** từ popup
2. Gán **hạng mục kiểm tra** từ C121 cho NVL đó (Import)
3. Thiết lập **AQL level**, **Inspection Level**, **số lượng mẫu**
4. Khi NVL nhập kho → C220 tự động tạo phiếu IQC dựa trên config tại C122

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────┐
│  MaterialInformation (Grid header)                │
│  ─ Thông tin NVL đang chọn (readonly)             │
├──────────────────────────────────────────────────┤
│  MaterialQcInspectionItem_ByMaterial (Grid)       │
│  ─ Danh sách hạng mục QC gán cho NVL             │
│  ─ Inline edit + 5 Action buttons                 │
│  ─ [ImportGroup/Item] [ImportNVLkhác]             │
│  ─ [SetAQL] [SetLevel] [SetInspType]              │
└──────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialInformation` | Material Information | Grid header thông tin NVL (readonly). |
| 2 | `MaterialQcInspectionItem_ByMaterial` | MaterialQcInspectionItem_ByMaterial | Grid hạng mục QC gán cho NVL. Inline edit. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_ByMaterial_get` | Lấy hạng mục QC gán cho NVL |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_iud` | Thêm/Sửa/Xóa hạng mục QC gán NVL |

### Actions/Buttons (5)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`ImportFromInspectionItem`** | 그룹/검사항목에서 선택 (Import từ Group/Item) | **Import hạng mục** — import hàng loạt hạng mục QC từ nhóm C121 vào NVL đang chọn. |
| 2 | **`ImportFromMaterialInspectionItem`** | 타품목에서 선택 (Import từ NVL khác) | **Import từ NVL khác** — copy cấu hình QC từ NVL khác sang. |
| 3 | **`SetAql`** | AQL설정 (Thiết lập AQL) | **Set AQL** — popup chọn AQL level → apply cho hạng mục đang chọn. |
| 4 | **`SetLevel`** | 검사수준설정 (Thiết lập Inspection Level) | **Set Level** — popup chọn Inspection Level. |
| 5 | **`SetInspectionType`** | 검사유형일괄설정 (Thiết lập Inspection Type) | **Set Inspection Type** — popup chọn Inspection Type. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialQcInspectionItem` | Mapping MaterialCode → QcInspectionItemCode |
| `STB_QcInspectionItem` | Danh mục hạng mục QC (từ C121) |
| `STB_MaterialMaster` | Danh mục NVL |

---

## C220 — MaterialIqcInfoSampleManagement

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C220` |
| **Screen Name** | `MaterialIqcInfoSampleManagement` |
| **Parent Menu** | `IQC_Inspection` |
| **Title** | IQC Confirmation (시료별 수입검사) |
| **Tổng Objects** | **51** (5 View + 5 SearchFunction + 17 ExecuteFunction + 24 Action) |

### Workflow

1. NVL nhập kho (F330) → hệ thống tự tạo **phiếu IQC** (`STB_MaterialQcInfo`)
2. QC chọn phiếu → **Make Detail** → tạo danh sách hạng mục từ C122
3. **Make Sample** → tạo các mẫu để đo
4. QC nhập **kết quả đo** cho từng mẫu, từng hạng mục
5. Quyết định: **Pass** hoặc **Fail**
6. Fail → tạo **Defect Report** → gửi email
7. Có thể **Change to Pass** sau khi Fail nếu được phê duyệt
8. Lỗi "Receiving Confirmation" khi gộp F330

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  Tab 1: MaterialQcInfoSampleList (Grid chính)                │
│  ─ Filter: FromDate, ToDate, MaterialCode, DecisionResult    │
│  ─ Mỗi row = 1 phiếu IQC                                    │
│  ─ Toolbar: [AllRefresh] [MIIDoSuccess] [MIIDoFailure]       │
│             [ChangetoPass] [SearchLotNo] [ChangeIQCNo]       │
│             [DoConfirmProd] [DoCancelProd] [DoConfirmQc]      │
│             [DoRejectQc] [DoSendEmail] [InputLabelQty]       │
│             [PrintLabelSelected] [SaveRevisionVer]           │
│             [ImportIqcInspectionItem] [ImagePopup]           │
│             [ImagePopup2] [RefreshMaterialQcInfo]            │
├──────────────────────────────────────────────────────────────┤
│  Tab 2: MaterialQcDetailSampleList (Grid chi tiết)           │
│  ─ Hạng mục kiểm tra cho phiếu IQC đang chọn               │
│  ─ [SetAllPass] [SetAllPassByItem] [RefreshMIIList]          │
├──────────────────────────────────────────────────────────────┤
│  Tab 3: MaterialSampleResult (Grid kết quả mẫu)             │
│  ─ Kết quả đo từng mẫu                                      │
│  ─ [MakeSampleResult] [RefreshSampleList]                    │
├──────────────────────────────────────────────────────────────┤
│  Tab 4: QcDefectIQCEnrollment (Grid lỗi IQC)                │
│  ─ Đăng ký báo cáo lỗi IQC                                  │
│  ─ [SaveDefectDetail]                                        │
├──────────────────────────────────────────────────────────────┤
│  Tab 5: NonconformingReport (NCR View)                       │
│  ─ Non-Conformance Report                                    │
└──────────────────────────────────────────────────────────────┘
```

### Views (5)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialQcInfoSampleList` | IQC Sample List | Grid chính — phiếu IQC. |
| 2 | `MaterialQcDetailSampleList` | Detail Sample | Grid hạng mục kiểm tra. |
| 3 | `MaterialSampleResult` | Sample Result | Grid kết quả đo mẫu. |
| 4 | `QcDefectIQCEnrollment` | QcDefectIQCEnrollment | Grid đăng ký lỗi IQC. |
| 5 | `NonconformingReport` | NonconformingReport | Grid NCR. |

### SearchFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInfo_get` | Lấy danh sách phiếu IQC |
| 2 | `usp_MaterialQcDetail_get` | Lấy chi tiết hạng mục đo |
| 3 | `usp_MaterialQcSampleResult_get` | Lấy kết quả đo mẫu |
| 4 | `usp_QcDefectIQCReport_get` | Lấy báo cáo lỗi IQC |
| 5 | `usp_GetMaterialQcInfo_ForReport` | Lấy thông tin in báo cáo |

### ExecuteFunctions (17)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInfo_iud` | Thêm/Sửa/Xóa phiếu IQC |
| 2 | `usp_MaterialQcDetail_iud` | Thêm/Sửa/Xóa chi tiết hạng mục |
| 3 | `usp_MaterialQcSampleResult_iud` | Lưu kết quả đo mẫu |
| 4 | `usp_DoMakeMaterialIQCDetailList` | Tạo danh sách chi tiết từ C122 |
| 5 | `usp_DoMakeMaterialQcSampleResult` | Tạo mẫu đo |
| 6 | `usp_DoUpdateMaterialQcInfo_Success` | Đánh dấu IQC **PASS** |
| 7 | `usp_DoUpdateMaterialQcInfo_Fail` | Đánh dấu IQC **FAIL** |
| 8 | `usp_DoChangeMaterialQcToPass` | Đổi Fail → Pass |
| 9 | `usp_IQcDefectReport_iud` | Thêm/Sửa/Xóa báo cáo lỗi |
| 10 | `usp_DoSendEmailForDefectReportIQC` | Gửi email lỗi IQC |
| 11 | `usp_DefectReportNoChange_iud` | Đổi mã Defect Report |
| 12 | `usp_MaterialQcInfoChangeLotNo_iud` | Thay đổi Lot No |
| 13 | `usp_ModifyRevisionsVerFromC220_VVTF4` | Cập nhật Revision Version |
| 14 | `usp_NCR_Report_iud` | Thêm/Sửa/Xóa NCR |
| 15 | `usp_UpdateDefectDetailIQC_VVT` | Cập nhật chi tiết lỗi |
| 16 | `usp_DoCancelIQC` | Hủy phiếu IQC |
| 17 | `usp_DoConfirmIQC` | Xác nhận phiếu IQC |

### Actions/Buttons (24)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`AllRefresh`** | AllRefresh | Làm mới toàn bộ grid. |
| 2 | **`RefreshMaterialQcInfo`** | RefreshMaterialQcInfo | Làm mới grid phiếu IQC. |
| 3 | **`RefreshMIIList`** | Refresh | Làm mới grid Detail. |
| 4 | **`RefreshSampleList`** | Refresh | Làm mới grid Sample Result. |
| 5 | **`SearchLotNo`** | SearchLotNo | **Tìm Lot** — popup tìm phiếu IQC theo Lot. |
| 6 | **`MIIDoSuccess`** | 합격판정 (Pass) | **Button PASS** — QC xác nhận NVL đạt. |
| 7 | **`MIIDoFailure`** | 불합격판정 (Fail) | **Button FAIL** — QC xác nhận NVL không đạt. |
| 8 | **`ChangetoPass`** | ChangeToPass | **Đổi Fail → Pass** — sau khi review. |
| 9 | **`MakeSampleResult`** | 샘플리스트 생성 (Tạo mẫu) | **Tạo mẫu đo** — tạo N mẫu cho hạng mục. |
| 10 | **`ImportIqcInspectionItem`** | 수입검사항목 불러오기 (Import) | **Import hạng mục IQC** — import từ C122. |
| 11 | **`ChangeIQCNo`** | ChangeIQCNo | **Đổi Lot No** — thay đổi Lot Number. |
| 12 | **`DoConfirmProd`** | DoConfirmProd | **Xác nhận SX** — xác nhận phiếu IQC từ phía SX. |
| 13 | **`DoCancelProd`** | DoCancelProd | **Hủy xác nhận SX** — hủy xác nhận phiếu. |
| 14 | **`DoConfirmQc`** | DoConfirmQc | **Xác nhận QC** — QC confirm phiếu. |
| 15 | **`DoRejectQc`** | DoRejectQc | **Từ chối QC** — QC reject phiếu. |
| 16 | **`DoSendEmail`** | DoSendEmail | **Gửi email** — thông báo kết quả IQC. |
| 17 | **`SaveDefectDetail`** | SaveDefectDetail | **Lưu chi tiết lỗi** — lưu thông tin lỗi IQC. |
| 18 | **`SaveRevisionVer`** | SaveRevisionVer | **Lưu Revision** — cập nhật revision NVL. |
| 19 | **`SetAllPass`** | 전체합격처리 (All Pass) | **All Pass** — Pass tất cả hạng mục. |
| 20 | **`SetAllPassByItem`** | 전체합격처리 (Pass by Item) | **Pass theo Item** — Pass hạng mục đang chọn. |
| 21 | **`InputLabelQty`** | LabelPrint | **Nhập SL in nhãn** — popup nhập SL label NG. |
| 22 | **`PrintLabelSelected`** | NG_Label | **In nhãn NG** — in nhãn cho NVL bị Fail. |
| 23 | **`ImagePopup`** | ImagePopup | **Popup hình 1** — xem/upload hình đính kèm. |
| 24 | **`ImagePopup2`** | ImagePopup2 | **Popup hình 2** — xem/upload hình thứ 2. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialQcInfo` | Phiếu IQC chính |
| `STB_MaterialQcDetail` | Chi tiết hạng mục đo |
| `STB_MaterialQcSampleResult` | Kết quả đo mẫu |
| `STB_IQcDefectReport` | Báo cáo lỗi IQC |
| `STB_NCR_REPORT` | Báo cáo NCR |

---

## C530 — MaterialOqcInfoSampleManagement

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C530` |
| **Screen Name** | `MaterialOqcInfoSampleManagement` |
| **Parent Menu** | `Outgoing_Qualuty_Control` |
| **Title** | OQC Audit (시료별제품검사) |
| **Tổng Objects** | **38** (5 View + 5 SearchFunction + 14 ExecuteFunction + 19 Action) |

### Workflow

1. **Core OQC** — kiểm tra chất lượng sản phẩm trước khi xuất kho
2. Tạo **phiếu OQC** → Make Detail → Make Sample
3. QC nhập **kết quả đo** → Pass/Fail/Hold/Rescreening
4. Kết quả OQC quyết định có cho xuất kho không

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  MaterialQcInfoSampleList (Grid chính)                       │
│  ─ Danh sách phiếu OQC                                      │
│  ─ Toolbar: nhiều Action (~19)                               │
├──────────────────────────────────────────────────────────────┤
│  MaterialQcDetailSampleList (Grid chi tiết)                  │
│  ─ Hạng mục kiểm tra OQC                                    │
├──────────────────────────────────────────────────────────────┤
│  MaterialSampleResult (Grid kết quả mẫu)                     │
│  ─ Kết quả đo từng mẫu                                      │
├──────────────────────────────────────────────────────────────┤
│  MaterialQcInfo_ForReport (Grid báo cáo)                     │
│  ─ Thông tin in báo cáo OQC                                  │
├──────────────────────────────────────────────────────────────┤
│  OQC_Bad_List (Grid lỗi OQC)                                │
│  ─ Danh sách Lot lỗi                                         │
└──────────────────────────────────────────────────────────────┘
```

### Views (5)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialQcInfoSampleList` | OQC Sample List | Grid chính — phiếu OQC. |
| 2 | `MaterialQcDetailSampleList` | OQC Detail | Grid hạng mục kiểm tra. |
| 3 | `MaterialSampleResult` | Sample Result | Grid kết quả đo mẫu. |
| 4 | `MaterialQcInfo_ForReport` | MaterialQcInfo_ForReport | Grid báo cáo OQC. |
| 5 | `OQC_Bad_List` | OQC Bad List | Grid Lot lỗi. |

### SearchFunctions (5)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_GetMaterialOQcInfo` | Lấy danh sách phiếu OQC |
| 2 | `usp_MaterialQcDetail_get` | Lấy chi tiết hạng mục |
| 3 | `usp_MaterialQcSampleResult_get` | Lấy kết quả đo mẫu |
| 4 | `usp_GetMaterialQcInfo_ForReport` | Lấy thông tin báo cáo |
| 5 | `usp_GetProdRouteBarcodeForDefect_E27` | Lấy Lot lỗi |

### ExecuteFunctions (14)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialQcInfo_iud` | Thêm/Sửa/Xóa phiếu OQC |
| 2 | `usp_MaterialQcDetail_iud` | Thêm/Sửa/Xóa hạng mục |
| 3 | `usp_MaterialQcSampleResult_iud` | Lưu kết quả đo |
| 4 | `usp_DoMakeMaterialIQCDetailList` | Tạo detail list |
| 5 | `usp_DoMakeMaterialQcSampleResult` | Tạo mẫu đo |
| 6 | `usp_DoUpdateMaterialQcInfo_Success` | **PASS** OQC |
| 7 | `usp_DoUpdateMaterialQcInfo_Fail` | **FAIL** OQC |
| 8 | `usp_DoUpdateMaterialQcInfo_Hold` | **HOLD** OQC |
| 9 | `usp_DoUpdateMaterialQcInfo_Rescreening` | **Rescreening** OQC |
| 10 | `usp_DoUpdateMaterialQcInfo_Complete` | **Complete** OQC |
| 11 | `usp_DoDeleteMaterialQcInfo` | Xóa phiếu OQC |
| 12 | `usp_DoUpdateMaterialOQcInfoRemark` | Cập nhật Remark |
| 13 | `usp_DoProcessProdInspCpkCalc` | Tính CPK |
| 14 | `usp_RecentlyCellTestResultMax_get` | Lấy kết quả Cell Test gần nhất |

### Actions/Buttons (19)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`MIIDoSuccess`** | 합격판정 (Pass) | **PASS OQC** — xác nhận đạt. |
| 2 | **`MIIDoFailure`** | 불합격판정 (Fail) | **FAIL OQC** — xác nhận không đạt. |
| 3 | **`MIIDoRescreening`** | MIIDoRescreening | **Rescreening** — kiểm tra lại. |
| 4 | **`DoUpdateHold`** | DoUpdateHold | **Hold** — giữ phiếu chờ xử lý. |
| 5 | **`DoUpdateCharComplte`** | DoUpdateCharComplte | **Complete** — hoàn thành đặc tính. |
| 6 | **`ImportIqcInspectionItem`** | 제품검사항목 불러오기 (Import) | **Import hạng mục** — import từ config. |
| 7 | **`MakeSampleResult`** | 샘플리스트 생성 (Tạo mẫu) | **Tạo mẫu đo**. |
| 8 | **`ProdInspectionLotList`** | ProdInspectionLotList | **Danh sách Lot** — xem Lot cần kiểm. |
| 9 | **`ProdLotDelete`** | ProdLotDelete | **Xóa Lot** — xóa Lot khỏi phiếu. |
| 10 | **`GetCpk`** | GetCpk | **Tính CPK** — tính chỉ số năng lực quá trình. |
| 11 | **`QcListRefresh`** | QcListRefresh | Làm mới grid phiếu. |
| 12 | **`Reflection`** | Reflection | Phản ánh dữ liệu. |
| 13 | **`RefreshMIIList`** | Refresh | Làm mới grid detail. |
| 14 | **`RefreshSampleList`** | Refresh | Làm mới grid sample. |
| 15 | **`RefreshSampleResultList`** | Refresh | Làm mới grid result. |
| 16 | **`RefreshView2`** | RefreshView2 | Làm mới view phụ. |
| 17 | **`SetAllPass`** | 전체합격처리 (All Pass) | **All Pass** — Pass tất cả. |
| 18 | **`SetAllPassByItem`** | 전체합격처리 (Pass by Item) | **Pass theo Item**. |
| 19 | **`UpdateRemark`** | UpdateRemark | **Cập nhật Remark**. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialQcInfo` | Phiếu OQC chính |
| `STB_MaterialQcDetail` | Chi tiết hạng mục đo |
| `STB_MaterialQcSampleResult` | Kết quả đo mẫu |

---

# NHÓM F — KHO (WMS)

---

## F330 — MaterialReceiptAndPrintLabel

| Thông tin | Giá trị |
|---|---|
| **TCode** | `F330` |
| **Screen Name** | `MaterialReceiptAndPrintLabel` |
| **Parent Menu** | `MaterialGR_MENU` |
| **Title** | Nhập kho NVL & In nhãn (자재입고 및 라벨발행) |
| **Tổng Objects** | **45** (3 View + 3 SearchFunction + 18 ExecuteFunction + 24 Action) |

### Workflow

1. Tạo **chứng từ nhập kho** (Material Doc)
2. Thêm **chi tiết NVL** vào chứng từ
3. **Tạo Lot/Label** → in nhãn barcode cho từng Lot NVL
4. **Xác nhận nhập** (Fix) → **Hoàn thành** (Finish)
5. Hệ thống tự tạo **phiếu IQC** (C220) cho NVL vừa nhập
6. **Màn hình nhiều bug nhất** — sửa kho sai phải update 3 bảng

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  MaterialDocInfo (Grid chứng từ)                             │
│  ─ Danh sách chứng từ nhập kho                               │
│  ─ Toolbar: [DoGR] [DoFix] [DoFinish] [CancelFinish]        │
│             [CancelDoc] [Refresh] [RefreshDetail]            │
│             [RefreshDocLot] [MakeLabel] [MakeLabelManual]    │
│             [InputLabelQty] [PrintLabelSelected]             │
│             [ScanBarcode] [ChangeLotNo] [DeleteDocLotInfo]   │
│             [LotNoManualInput] [LabelInfoManualInsert]       │
│             [AddDate] [AddProDate] [TradeDate] [Inbigtem]    │
│             [Pass_Print] [BG2_ViewCell] [LuuCapJIANGHAI]    │
├──────────────────────────────────────────────────────────────┤
│  MaterialDocDetail (Grid chi tiết)                           │
│  ─ Chi tiết NVL trong chứng từ                               │
├──────────────────────────────────────────────────────────────┤
│  MaterialDocLotInfo (Grid Lot)                               │
│  ─ Thông tin Lot/Label đã tạo cho NVL                        │
└──────────────────────────────────────────────────────────────┘
```

### Views (3)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `MaterialDocInfo` | MaterialDocInfo | Grid chứng từ nhập kho. |
| 2 | `MaterialDocDetail` | MaterialDocDetail | Grid chi tiết NVL. |
| 3 | `MaterialDocLotInfo` | MaterialDocLotInfo | Grid Lot/Label. |

### SearchFunctions (3)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_MaterialDocInfo_get` | Lấy danh sách chứng từ nhập |
| 2 | `usp_MaterialDocDetail_get` | Lấy chi tiết NVL |
| 3 | `usp_MaterialDocLotInfo_get` | Lấy thông tin Lot/Label |

### ExecuteFunctions (18)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoMaterialDocMasterDetail_iud` | Tạo chứng từ + chi tiết |
| 2 | `usp_MaterialDocInfo_iud` | Thêm/Sửa/Xóa chứng từ |
| 3 | `usp_MaterialDocDetail_iud` | Thêm/Sửa/Xóa chi tiết |
| 4 | `usp_MaterialDocLotInfo_iud` | Thêm/Sửa/Xóa Lot |
| 5 | `usp_DoArriveMaterialDelivery` | Xử lý hàng đến (GR) |
| 6 | `usp_DoFixMaterialDoc` | Fix chứng từ |
| 7 | `usp_DoFinishMaterialDoc` | Hoàn thành nhập kho |
| 8 | `usp_DoCancelFinishMaterialDoc` | Hủy hoàn thành |
| 9 | `usp_DoCancelMaterialDoc` | Hủy chứng từ |
| 10 | `usp_DoCreateLabel` | Tạo Label tự động |
| 11 | `usp_DoCreateLabelManual` | Tạo Label thủ công |
| 12 | `usp_DoChangeMaterialDocLotInfo` | Đổi thông tin Lot |
| 13 | `usp_DoDeleteMaterialDocLotInfo` | Xóa Lot |
| 14 | `usp_DoUpdateTradeDate_iud` | Cập nhật ngày giao dịch |
| 15 | `usp_GetOrderMaterialMaster_popup` | Popup chọn NVL theo đơn hàng |
| 16 | `usp_AddDate` | Thêm ngày |
| 17 | `usp_AddStartDate` | Thêm ngày bắt đầu |
| 18 | `usp_UpdateLevelJIANGHAI` | Cập nhật level JIANGHAI |

### Actions/Buttons (24)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoGR`** | 입하처리 (Nhập hàng) | **Nhập hàng** — xử lý hàng đến. |
| 2 | **`DoFix`** | 입고확정 (Xác nhận nhập) | **Fix chứng từ** — xác nhận nhập kho. |
| 3 | **`DoFInish`** | 입고완료 (Hoàn thành) | **Hoàn thành** — hoàn thành nhập kho. |
| 4 | **`CancelFinish`** | 완료취소 (Hủy hoàn thành) | **Hủy hoàn thành**. |
| 5 | **`CancelDoc`** | CancelDoc | **Hủy chứng từ**. |
| 6 | **`Refresh`** | 새로고침 (Làm mới) | Làm mới grid chính. |
| 7 | **`RefreshDetail`** | 디테일새로고침 | Làm mới grid detail. |
| 8 | **`RefreshDocLot`** | LOT새로고침 | Làm mới grid Lot. |
| 9 | **`MakeLabel`** | 라벨생성 (Tạo nhãn) | **Tạo Label** — tạo nhãn tự động. |
| 10 | **`MakeLabelManual`** | MakeLabelManual | **Tạo Label thủ công**. |
| 11 | **`InputLabelQty`** | LabelPrint | **Nhập SL in nhãn**. |
| 12 | **`PrintLabelSelected`** | LabelPrint | **In nhãn** — in nhãn đã chọn. |
| 13 | **`ScanBarcode`** | 바코드스캔 (Quét barcode) | **Quét barcode** — quét barcode NVL. |
| 14 | **`ChangeLotNo`** | Lot번호저장 (Lưu số Lot) | **Đổi Lot No** — thay đổi số Lot. |
| 15 | **`DeleteDocLotInfo`** | 선택라벨삭제 (Xóa nhãn) | **Xóa nhãn đã chọn**. |
| 16 | **`LotNoManualInput`** | LotNoManualInput | **Nhập Lot thủ công**. |
| 17 | **`LabelInfoManualInsert`** | LabelInfoManualInsert | **Thêm Label thủ công**. |
| 18 | **`AddDate`** | AddDate | **Thêm ngày**. |
| 19 | **`AddProDate`** | AddProDate | **Thêm ngày SX**. |
| 20 | **`TradeDate`** | 거래일자 (Ngày giao dịch) | **Ngày giao dịch**. |
| 21 | **`Inbigtem`** | In tem to | **In tem to** — in tem kích thước lớn. |
| 22 | **`Pass_Print`** | Pass_Print | **Pass + In** — pass và in luôn. |
| 23 | **`BG2_ViewCell`** | BG2_ViewCell | **Xem Cell BG2**. |
| 24 | **`LuuCapJIANGHAI`** | LuuCapJIANGHAI | **Lưu cấp JIANGHAI** — cập nhật level cho NCC JIANGHAI. |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialDocInfo` | Chứng từ nhập kho. PK: `MaterialDocNo` |
| `STB_MaterialDocDetail` | Chi tiết NVL trong chứng từ |
| `STB_MaterialDocLotInfo` | Lot/Label NVL |
| `STB_MaterialLotInfo` | Thông tin Lot NVL |

---

# NHÓM Z — HỆ THỐNG & PHÂN QUYỀN

---

## Z220 — UserTypePermission

| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z220` |
| **Screen Name** | `UserTypePermission` |
| **Parent Menu** | `PermissionManagement` |
| **Title** | Phân quyền (그룹별권한) |
| **Tổng Objects** | **17** (4 View + 4 SearchFunction + 2 ExecuteFunction + 11 Action) |

### Workflow

1. Chọn **UserType** (nhóm người dùng)
2. Gán **quyền truy cập** cho từng màn hình, View, Function
3. **GrantAll** → cấp tất cả quyền
4. Select/Unselect từng quyền: Delete, Excel, Import, Modify

### Views (4)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `UserTypeList` | 사용자유형 (UserType) | Grid danh sách nhóm người dùng. |
| 2 | `MenuList` | 메뉴리스트 (Menu) | Grid danh sách menu. |
| 3 | `ViewList` | 뷰리스트 (View) | Grid danh sách View. |
| 4 | `FunctionList` | 기능리스트 (Function) | Grid danh sách Function. |

### SearchFunctions (4)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_UserType_get` | Lấy danh sách UserType |
| 2 | `usp_GetScreenListForUserType` | Lấy danh sách Screen theo UserType |
| 3 | `usp_GetViewListForUserType` | Lấy danh sách View theo UserType |
| 4 | `usp_GetFunctionListForUserType` | Lấy danh sách Function theo UserType |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_DoSaveUserTypePermissionAll` | Lưu tất cả quyền |
| 2 | `usp_DoGrantAll` | Cấp tất cả quyền |

### Actions/Buttons (11)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`GrantAll`** | 전체권한 (Tất cả quyền) | **Cấp tất cả quyền** — grant all permissions. |
| 2 | **`SelectedAll`** | 전체선택 (Chọn tất cả) | **Chọn tất cả** — tick tất cả checkbox. |
| 3 | **`UnSelectedAll`** | 전체해제 (Bỏ tất cả) | **Bỏ tất cả** — untick tất cả. |
| 4 | **`SelectedDelete`** | SelectedDelete | **Chọn quyền Xóa**. |
| 5 | **`UnSelectedDelete`** | UnSelectedDelete | **Bỏ quyền Xóa**. |
| 6 | **`SelectedExcel`** | SelectedExcel | **Chọn quyền Excel**. |
| 7 | **`UnSelectedExcel`** | UnSelectedExcel | **Bỏ quyền Excel**. |
| 8 | **`SelectedImport`** | SelectedImport | **Chọn quyền Import**. |
| 9 | **`UnSelectedImport`** | UnSelectedImport | **Bỏ quyền Import**. |
| 10 | **`SelectedModify`** | SelectedModify | **Chọn quyền Sửa**. |
| 11 | **`UnSelectedModify`** | UnSelectedModify | **Bỏ quyền Sửa**. |

---

## Z530 — LabelInfo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `Z530` |
| **Screen Name** | `LabelInfo` |
| **Parent Menu** | `LabelInfoManagement` |
| **Title** | Label Design (LabelInfo) |
| **Tổng Objects** | **4** (1 View + 1 SearchFunction + 1 ExecuteFunction + 1 Action) |

### Workflow

1. Thiết kế **mẫu tem/nhãn** cho hệ thống
2. **Copy Label** — sao chép mẫu tem đã có

### Views (1)

| # | ObjectName | Title | Mô tả |
|---|---|---|---|
| 1 | `LabelInfo` | 라벨양식정보 (Mẫu tem) | Grid danh sách mẫu tem. |

### SearchFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LabelInfo_get` | Lấy danh sách mẫu tem |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả |
|---|---|---|
| 1 | `usp_LabelInfo_iud` | Thêm/Sửa/Xóa mẫu tem |

### Actions/Buttons (1)

| # | ObjectName | Title | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CopyLabel`** | CopyLabel | **Sao chép mẫu tem** — copy mẫu tem đã có để tạo bản mới. |

---

# THỐNG KÊ TỔNG HỢP

| Nhóm | Số màn hình | Views | Search | Execute | Actions |
|---|---|---|---|---|---|
| **A** — Master Data | 5 | 10 | 10 | 7 | 2 |
| **B** — Sản Xuất | 30+ | 50+ | 50+ | 80+ | 170+ |
| **C** — QC | 25+ | 50+ | 50+ | 90+ | 140+ |
| **F** — Kho (WMS) | 15+ | 25+ | 25+ | 50+ | 70+ |
| **G** — Xuất TP | 3 | 7 | 7 | 25 | 28 |
| **K** — Module | 4 | 6 | 6 | 12 | 21 |
| **D** — Enesol | 2 | 2 | 2 | 2 | 7 |
| **Z** — Hệ thống | 7 | 12 | 12 | 8 | 13 |

---

## Sơ Đồ Quan Hệ Tổng Thể

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
> - Tài liệu này cover tất cả các màn hình đã biết trong hệ thống MES (trừ HY clone).
> - Dữ liệu lấy trực tiếp từ DB `SmartFramework.dbo.STB_ScreenObjects` ngày 2026-06-27.
> - Một số màn hình có nhiều ScreenName cho cùng 1 TCode (vd: B525, B786, C460) — chỉ document phiên bản chính.
> - Xem thêm HY clone: `sql/scripts/hy_clone/HY_9_SCREENS_DOCUMENTATION.md`
