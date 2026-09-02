# BAO CAO DO TIN CAY TAI LIEU & SCHEMA DRIFT AUDIT

> **Cap nhat:** 2026-09-02 10:19:37
> **Tong quan he thong:** **71.9%** doi tuong khop chinh xac voi Live DB (1257 / 1749 doi tuong).
> **Muc dich:** Huong dan AI va Ky su xac dinh chinh xac muc do tin cay cua tung tai lieu truoc khi van hanh.

---

## 1. Tieu Chuan Phan Loai Do Tin Cay

- **HIGH (>= 90%):** Tai lieu chuan xac cao, Bang & Stored Procedure da duoc verify voi CSDL thuc te. **Co the ap dung ngay logic nghiep vu.**
- **MEDIUM (70% - 89%):** Tai lieu co do chinh xac kha, mot so SP/Bang thuoc DB phu (SmartFramework, VINATECH_GROUP) hoac co typo nho. Can kiem tra nhe truoc khi chay.
- **LOW (< 70%):** Tai lieu co nhieu gia dinh hoac de cap SP chua trien khai tren Production. Bat buoc kiem tra ky CSDL.

---

## 2. Bang Danh Gia Chi Tiet Tung Tai Lieu

| File Tai Lieu | Bang Khop | SP Khop | Do Tin Cay | Phan Loai |
|:---|:---:|:---:|:---:|:---:|
| [./MES_MASTER_KNOWLEDGE_BASE/MES_SCRIPT_GUIDE.md](file:///./MES_MASTER_KNOWLEDGE_BASE/MES_SCRIPT_GUIDE.md) | 2/2 | 2/2 | **100%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | 4/4 | 3/3 | **100%** | [HIGH] |
| [./DATABASE_KNOWLEDGE_BASE/DB_07_AndonDB.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_07_AndonDB.md) | 3/3 | 0/0 | **100%** | [HIGH] |
| [./SYSTEM_ARCHITECTURE/MES_OPERATIONAL_LOG.md](file:///./SYSTEM_ARCHITECTURE/MES_OPERATIONAL_LOG.md) | 1/1 | 1/1 | **100%** | [HIGH] |
| [./DATABASE_KNOWLEDGE_BASE/DB_09_VINATECH_WEBSOCKET.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_09_VINATECH_WEBSOCKET.md) | 1/1 | 0/0 | **100%** | [HIGH] |
| [./SYSTEM_ARCHITECTURE/EXTRACTED_MANUALS_ANALYSIS.md](file:///./SYSTEM_ARCHITECTURE/EXTRACTED_MANUALS_ANALYSIS.md) | 1/1 | 0/0 | **100%** | [HIGH] |
| [./AI_AGENT_CONFIG/LESSONS_LEARNED.md](file:///./AI_AGENT_CONFIG/LESSONS_LEARNED.md) | 3/3 | 0/0 | **100%** | [HIGH] |
| [./SYSTEM_ARCHITECTURE/VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md](file:///./SYSTEM_ARCHITECTURE/VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md) | 28/28 | 5/5 | **100%** | [HIGH] |
| [./AI_AGENT_CONFIG/RULES.md](file:///./AI_AGENT_CONFIG/RULES.md) | 4/4 | 0/0 | **100%** | [HIGH] |
| [./SYSTEM_ARCHITECTURE/VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md](file:///./SYSTEM_ARCHITECTURE/VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md) | 2/2 | 0/0 | **100%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_11_HANAM_FACTORY_SCREENS.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_11_HANAM_FACTORY_SCREENS.md) | 70/72 | 45/45 | **98.3%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md) | 33/35 | 12/12 | **95.7%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_04_SCREEN_BUGS_BK.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_04_SCREEN_BUGS_BK.md) | 13/14 | 8/8 | **95.5%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md) | 15/16 | 3/3 | **94.7%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md) | 50/57 | 80/81 | **94.2%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md) | 24/26 | 2/2 | **92.9%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md) | 24/27 | 13/13 | **92.5%** | [HIGH] |
| [./AI_AGENT_CONFIG/HOTFIX_LOG.md](file:///./AI_AGENT_CONFIG/HOTFIX_LOG.md) | 37/40 | 8/9 | **91.8%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md) | 52/60 | 33/33 | **91.4%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md) | 6/11 | 39/39 | **90%** | [HIGH] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md) | 27/31 | 5/5 | **88.9%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md) | 29/33 | 16/18 | **88.2%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md) | 38/42 | 19/24 | **86.4%** | [MEDIUM] |
| [./SYSTEM_ARCHITECTURE/GROUPWARE_MES_INTEGRATION_ANALYSIS.md](file:///./SYSTEM_ARCHITECTURE/GROUPWARE_MES_INTEGRATION_ANALYSIS.md) | 15/19 | 9/9 | **85.7%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md) | 59/71 | 31/35 | **84.9%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_03_SCREEN_BUGS_B.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_03_SCREEN_BUGS_B.md) | 28/36 | 23/25 | **83.6%** | [MEDIUM] |
| [./SYSTEM_ARCHITECTURE/MES_DAILY_PLAYBOOK.md](file:///./SYSTEM_ARCHITECTURE/MES_DAILY_PLAYBOOK.md) | 5/6 | 0/0 | **83.3%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md) | 7/7 | 3/5 | **83.3%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_02_SCREEN_BUGS.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_02_SCREEN_BUGS.md) | 15/20 | 9/9 | **82.8%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md) | 11/13 | 2/3 | **81.2%** | [MEDIUM] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_PRODUCTION_PLANNING.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_PRODUCTION_PLANNING.md) | 4/5 | 0/0 | **80%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md) | 7/11 | 8/8 | **78.9%** | [MEDIUM] |
| [./AI_AGENT_CONFIG/SKILLS.md](file:///./AI_AGENT_CONFIG/SKILLS.md) | 13/16 | 5/8 | **75%** | [MEDIUM] |
| [./AI_AGENT_CONFIG/KNOWLEDGE.md](file:///./AI_AGENT_CONFIG/KNOWLEDGE.md) | 34/43 | 14/21 | **75%** | [MEDIUM] |
| [./SYSTEM_ARCHITECTURE/VOL_01_SYSTEM_ARCHITECTURE.md](file:///./SYSTEM_ARCHITECTURE/VOL_01_SYSTEM_ARCHITECTURE.md) | 30/34 | 8/18 | **73.1%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_10_FACTORY_WORKCENTER_MATRIX.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_10_FACTORY_WORKCENTER_MATRIX.md) | 16/22 | 0/0 | **72.7%** | [MEDIUM] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_04_HUNG_YEN_WBS_MAPPING.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_04_HUNG_YEN_WBS_MAPPING.md) | 44/62 | 64/103 | **65.5%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_PURCHASE.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_PURCHASE.md) | 3/5 | 0/0 | **60%** | [LOW] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_03_SANMINA_LABEL_GUIDE.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_03_SANMINA_LABEL_GUIDE.md) | 5/10 | 4/8 | **50%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_WAREHOUSE.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_WAREHOUSE.md) | 4/9 | 0/0 | **44.4%** | [LOW] |
| [./SYSTEM_INTEGRATION_MAP.md](file:///./SYSTEM_INTEGRATION_MAP.md) | 7/16 | 0/0 | **43.8%** | [LOW] |
| [./AI_AGENT_CONFIG/BOOTSTRAP.md](file:///./AI_AGENT_CONFIG/BOOTSTRAP.md) | 4/10 | 1/2 | **41.7%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_MASTER_DATA.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_MASTER_DATA.md) | 3/10 | 0/0 | **30%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_SALES_SHIPMENT.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_SALES_SHIPMENT.md) | 1/4 | 0/0 | **25%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_SSO_SECURITY.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_SSO_SECURITY.md) | 0/1 | 0/0 | **0%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_ORGANIZATION_WORKFLOW.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_ORGANIZATION_WORKFLOW.md) | 0/3 | 0/0 | **0%** | [LOW] |
| [./KB_RELIABILITY_REPORT.md](file:///./KB_RELIABILITY_REPORT.md) | 0/99 | 0/79 | **0%** | [LOW] |
| [./MASTER_INDEX.md](file:///./MASTER_INDEX.md) | 0/11 | 0/0 | **0%** | [LOW] |
| [./MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md](file:///./MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md) | 0/1 | 0/0 | **0%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_HR_ADMIN.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_HR_ADMIN.md) | 0/6 | 0/0 | **0%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_DISBURSEMENT.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_DISBURSEMENT.md) | 0/3 | 0/0 | **0%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_03_VINATECH_GROUP.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_03_VINATECH_GROUP.md) | 0/1 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_06_THANH_TOAN.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_06_THANH_TOAN.md) | 0/2 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_07_KHO_THANH_PHAM.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_07_KHO_THANH_PHAM.md) | 0/7 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_05_HANH_CHINH.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_05_HANH_CHINH.md) | 0/2 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_03_KE_HOACH_SX.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_03_KE_HOACH_SX.md) | 0/5 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_04_MASTER_DATA.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_04_MASTER_DATA.md) | 0/2 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_08_BAN_HANG.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_08_BAN_HANG.md) | 0/3 | 0/0 | **0%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_INDEX.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_INDEX.md) | 0/1 | 0/0 | **0%** | [LOW] |
| [./DATABASE_KNOWLEDGE_BASE/DB_12_SmartFactoryIncubator.md](file:///./DATABASE_KNOWLEDGE_BASE/DB_12_SmartFactoryIncubator.md) | 0/3 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_01_DANG_NHAP.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_01_DANG_NHAP.md) | 0/2 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md) | 0/16 | 0/0 | **0%** | [LOW] |
| [./GROUPWARE_KNOWLEDGE_BASE/GW_02_MUA_HANG.md](file:///./GROUPWARE_KNOWLEDGE_BASE/GW_02_MUA_HANG.md) | 0/3 | 0/0 | **0%** | [LOW] |

---

## 3. Danh Sach Doi Tuong Can Luu Y (Unverified / Typos / Cross-DB)

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md
- **SP chua tim thay trong Live DB:** usp_Vietnam_NewScreenData_get, usp_Vietnam_NewScreenData_iud

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md
- **Bang chua tim thay trong Live DB:** STB_AluCaseMapping_VVT, VVT_F3, VVT_F2, VVT_F1

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md
- **Bang chua tim thay trong Live DB:** STB_ProdRoute, STB_Material, STB_SerialRules, VVT_F1
- **SP chua tim thay trong Live DB:** usp_DoProcessProdRouteHistForCalc_VNT, usp_DoProcessProdRouteHistForBarcode2, usp_DoProcessProdRouteHistForBarcode1, usp_DoProcessProdGI, usp_DoProcessProdGR

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md
- **Bang chua tim thay trong Live DB:** VVT_F5, VVT_F2, STB_PhoenixContactLabelInfo, VVT_F1, VVT_F3, STB_MaterialDocInfo_BK, STB_MaterialDocDetail_BK, STB_MaterialDocLotInfo_BK, STB_ProdRouteHist_BK, STB_ProdRouteSummary_BK, STB_ProductionOrderInfo_BK, VVT_F4
- **SP chua tim thay trong Live DB:** usp_BasicRoutingInfo_jud, usp_BasicRoutingDetail_jud, usp_GetProductionOrderList, usp_VNE_BoxLabelPrintHist_

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_10_FACTORY_WORKCENTER_MATRIX.md
- **Bang chua tim thay trong Live DB:** VVT_F1, VVT_F3, VVT_F4, VVT_F2, VVT_F5, STB_VN_STAGEMACHINES_

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_11_HANAM_FACTORY_SCREENS.md
- **Bang chua tim thay trong Live DB:** VVT_F3, VVT_Xem

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md
- **Bang chua tim thay trong Live DB:** VVT_F1, VVT_F3, VVT_F2

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_02_SCREEN_BUGS.md
- **Bang chua tim thay trong Live DB:** STB_WarehouseLocation, VVT_F5, VVT_F1, VVT_F2, VVT_F3

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md
- **Bang chua tim thay trong Live DB:** VVT_F1

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md
- **Bang chua tim thay trong Live DB:** VVT_F1, STB_BarrelBarcodeInfo, STB_BarrelBarcodeDetail, STB_ElectrodeProdRouteHist, VVT_BG2, VVT_F4, VVT_MeasurementControlList
- **SP chua tim thay trong Live DB:** usp_GetProdRouteHistForBarcode_PS_get

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_03_SCREEN_BUGS_B.md
- **Bang chua tim thay trong Live DB:** VVT_F2, VVT_F5, VVT_F1, VVT_F3, STB_ElectrodeProdRouteHist, VVT_BG2, VVT_F4, STB_BomInfo
- **SP chua tim thay trong Live DB:** usp_Vietnam_ChangeProductionOrderRoutingLine_VNT, usp_Vietnam_GetLotInfoForRework_VNT

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_04_SCREEN_BUGS_BK.md
- **Bang chua tim thay trong Live DB:** VVT_BG2

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md
- **Bang chua tim thay trong Live DB:** VVT_F1, VVT_F3, VVT_F4, VVT_F5

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md
- **Bang chua tim thay trong Live DB:** VVT_F3, VVT_CAPA

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_03_SANMINA_LABEL_GUIDE.md
- **Bang chua tim thay trong Live DB:** VVT_SanminaShipmentPlan, VVT_SanminaLabelPrint, STB_YShipmentPlan, STB_YShipmentPlanLot, STB_YLabelPrintHist
- **SP chua tim thay trong Live DB:** usp_YShipmentPlan_get, usp_YShipmentPlan_iud, usp_YLabelPrint_get, usp_YLabelPrintHist_iud

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md
- **Bang chua tim thay trong Live DB:** STB_AluCaseMapping_VVT, STB_VVT_SortingErrorData_ALCase_NEW, VVT_F2, STB_AttachedFileMaster, VVT_DoCreateQC4MChange, VVT_ViewDetailQC4MChange, VVT_View4MChange, VVT_CAPAInputSeparateLot

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md
- **Bang chua tim thay trong Live DB:** STB_ElectrodeProdRouteHist, VVT_F2, STB_AluCaseMapping_VVT, STB_VVT_SortingErrorData_ALCase_NEW
- **SP chua tim thay trong Live DB:** usp_Vietnam_ScrapInput_HN, usp_ProductionOrderInfo_HY_HY_get

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md
- **Bang chua tim thay trong Live DB:** VVT_F5

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md
- **Bang chua tim thay trong Live DB:** VVT_F5, STB_DetailAgingHY

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md
- **Bang chua tim thay trong Live DB:** VVT_F5, VVT_F1, VVT_F2, VVT_F4, VVT_F3

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md
- **Bang chua tim thay trong Live DB:** STB_DetailAgingHY, VVT_F5
- **SP chua tim thay trong Live DB:** usp_DoProcessProdRouteHist_HY

### File: ./MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_04_HUNG_YEN_WBS_MAPPING.md
- **Bang chua tim thay trong Live DB:** VVT_F5, STB_LineStructureInfo, STB_RoutingInfo, STB_RoutingDetailInfo, STB_MaterialWarehouseInfo, STB_LocationInfo, STB_EmployeeInfo, STB_MachineInfo, STB_DeviceInfo, STB_SupplierInfo, STB_VendorMappingByMaterialInfo, STB_MaterialMappingByCustomer, VVT_MaterialStockList, STB_StagePrices, STB_DetailAgingHY, STB_VNT_ElectrodeSlittingCutterUsageHist, STB_VNSparePartInHistory, STB_VNSparePartOutHistory
- **SP chua tim thay trong Live DB:** usp_LineStructureInfo_get, usp_LineStructureInfo_iud, usp_RoutingInfo_get, usp_RoutingInfo_iud, usp_MaterialWarehouseInfo_get, usp_MaterialWarehouseInfo_iud, usp_EmployeeInfo_get, usp_EmployeeInfo_iud, usp_MachineInfo_get, usp_MachineInfo_iud, usp_DeviceInfo_get, usp_DeviceInfo_iud, usp_SupplierInfo_get, usp_SupplierInfo_iud, usp_VendorMappingByMaterialInfo_get, usp_VendorMappingByMaterialInfo_iud, usp_MaterialMappingByCustomer_get, usp_MaterialMappingByCustomer_iud, usp_MaterialDocDetail_HY_iud, usp_MaterialWarehouseInOutHist_HY_iud, usp_MaterialReturnAndPrintLabel_get, usp_DoReturnMaterialDoc, usp_DoSplitRawMaterialAndMove_HY, usp_MaterialLotInfo_HY_get, usp_MaterialDocDetailHistory_get, usp_ProductionOrderInfo_iud, usp_vn_showproductionerror_get, usp_CellLineFaultReport_get, usp_MonthEndInventoryReport_get, usp_PostProductionScrapReport_get, usp_StagePrices_get, usp_StagePrices_iud, usp_ModuleCheckStatus_get, usp_VNT_ProdInspectionHist_get, usp_RouteInspectionMeasureFullHist_get, usp_ElectrodeInspectionHistoryForBarcode_get, usp_ReportSparePartInfo_get, usp_VNT_ElectrodeSlittingCutterUsageHist_get, usp_ReportSparePartDetail_get

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_DISBURSEMENT.md
- **Bang chua tim thay trong Live DB:** GW_PO, GW_Pay, GW_06_THANH_TOAN

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_HR_ADMIN.md
- **Bang chua tim thay trong Live DB:** GW_HR, GW_Trip, GW_Report, GW_Leave, GW_Retire, GW_05_HANH_CHINH

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_MASTER_DATA.md
- **Bang chua tim thay trong Live DB:** GW_Item, GW_BOM, GW_Vendor, GW_Price, GW_H, GW_L, GW_04_MASTER_DATA

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_ORGANIZATION_WORKFLOW.md
- **Bang chua tim thay trong Live DB:** GW_01_DANG_NHAP, GW_04_MASTER_DATA, GW_05_HANH_CHINH

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_PRODUCTION_PLANNING.md
- **Bang chua tim thay trong Live DB:** GW_03_KE_HOACH_SX

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_PURCHASE.md
- **Bang chua tim thay trong Live DB:** GW_02_MUA_HANG, GW_06_THANH_TOAN

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_SALES_SHIPMENT.md
- **Bang chua tim thay trong Live DB:** GW_08_BAN_HANG, GW_07_KHO_THANH_PHAM, GW_03

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_SSO_SECURITY.md
- **Bang chua tim thay trong Live DB:** GW_01_DANG_NHAP

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_INTEGRATION_WAREHOUSE.md
- **Bang chua tim thay trong Live DB:** GW_07_KHO_THANH_PHAM, GW_08_BAN_HANG, VVT_F1, VVT_F2, VVT_F3

### File: ./DATABASE_KNOWLEDGE_BASE/DB_03_VINATECH_GROUP.md
- **Bang chua tim thay trong Live DB:** GW_INDEX

### File: ./DATABASE_KNOWLEDGE_BASE/DB_12_SmartFactoryIncubator.md
- **Bang chua tim thay trong Live DB:** STB_CellTestResult, STB_CellTestResultMax, STB_CellTestResultRT

### File: ./DATABASE_KNOWLEDGE_BASE/DB_INDEX.md
- **Bang chua tim thay trong Live DB:** GW_Core

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_01_DANG_NHAP.md
- **Bang chua tim thay trong Live DB:** GW_01, GW_INDEX

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_02_MUA_HANG.md
- **Bang chua tim thay trong Live DB:** GW_02, GW_INDEX, GW_07

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_03_KE_HOACH_SX.md
- **Bang chua tim thay trong Live DB:** GW_03, GW_INDEX, VVT_F1, VVT_F2, VVT_F3

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_04_MASTER_DATA.md
- **Bang chua tim thay trong Live DB:** GW_04, GW_INDEX

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_05_HANH_CHINH.md
- **Bang chua tim thay trong Live DB:** GW_05, GW_INDEX

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_06_THANH_TOAN.md
- **Bang chua tim thay trong Live DB:** GW_06, GW_INDEX

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_07_KHO_THANH_PHAM.md
- **Bang chua tim thay trong Live DB:** GW_07, GW_08, GW_08_BAN_HANG, GW_INDEX, VVT_F2, VVT_F1, VVT_F3

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_08_BAN_HANG.md
- **Bang chua tim thay trong Live DB:** GW_08, GW_INDEX, GW_03

### File: ./GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md
- **Bang chua tim thay trong Live DB:** GW_01_DANG_NHAP, GW_02_MUA_HANG, GW_03_KE_HOACH_SX, GW_04_MASTER_DATA, GW_05_HANH_CHINH, GW_06_THANH_TOAN, GW_07_KHO_THANH_PHAM, GW_08_BAN_HANG, GW_01, GW_02, GW_03, GW_04, GW_05, GW_06, GW_08, GW_07

### File: ./SYSTEM_ARCHITECTURE/GROUPWARE_MES_INTEGRATION_ANALYSIS.md
- **Bang chua tim thay trong Live DB:** STB_UserInfo_MES, VVT_F1, VVT_F2, VVT_F3

### File: ./SYSTEM_ARCHITECTURE/MES_DAILY_PLAYBOOK.md
- **Bang chua tim thay trong Live DB:** STB_ESM_WO_HEADER

### File: ./SYSTEM_ARCHITECTURE/VOL_01_SYSTEM_ARCHITECTURE.md
- **Bang chua tim thay trong Live DB:** STB_MaterialBOM, STB_CellTestResult, GW_H, GW_L
- **SP chua tim thay trong Live DB:** usp_SyncPurchaseRequest, usp_GetPurchaseOrderList, usp_DoApplyIncomingQty, usp_DoCreateAccountingSlip, usp_SyncSalesOrder, usp_GetShipmentRequestList, usp_DoApplyRealShipment, usp_SyncDailyProductionPlan, usp_DoFinishRouteOperation, usp_SyncMaterialMaster

### File: ./AI_AGENT_CONFIG/BOOTSTRAP.md
- **Bang chua tim thay trong Live DB:** STB_MaterialHoldInfo, STB_BarrelBarcodeInfo, VVT_F1, VVT_F2, VVT_F3, VVT_F4
- **SP chua tim thay trong Live DB:** usp_De

### File: ./AI_AGENT_CONFIG/HOTFIX_LOG.md
- **Bang chua tim thay trong Live DB:** VVT_F1, VVT_F2, VVT_F5
- **SP chua tim thay trong Live DB:** usp_DoProcessProdRouteHist_HY

### File: ./AI_AGENT_CONFIG/KNOWLEDGE.md
- **Bang chua tim thay trong Live DB:** VVT_F1, VVT_F2, VVT_F3, VVT_F4, VVT_F5, STB_CellTestResult, STB_MaterialHoldInfo, STB_BarrelBarcodeInfo, STB_HN_AccountingPrice
- **SP chua tim thay trong Live DB:** usp_Get, usp_Do, usp_Vietnam_, usp_VN_, usp_VVT_, usp_HN_, usp_DoCreatePackingLabelInfo

### File: ./AI_AGENT_CONFIG/SKILLS.md
- **Bang chua tim thay trong Live DB:** STB_MaterialHoldInfo, STB_BarrelBarcodeInfo, STB_AluCaseMapping_VVT
- **SP chua tim thay trong Live DB:** usp_TenSP, usp_ElectrodeStep_Vietnam, usp_DeProcessProdPacking_VVT

### File: ./KB_RELIABILITY_REPORT.md
- **Bang chua tim thay trong Live DB:** GW_06_THANH_TOAN, GW_07_KHO_THANH_PHAM, GW_05_HANH_CHINH, GW_03_KE_HOACH_SX, GW_04_MASTER_DATA, GW_08_BAN_HANG, GW_01_DANG_NHAP, GW_INDEX, GW_02_MUA_HANG, STB_AluCaseMapping_VVT, VVT_F3, VVT_F2, VVT_F1, STB_ProdRoute, STB_Material, STB_SerialRules, VVT_F5, STB_PhoenixContactLabelInfo, STB_MaterialDocInfo_BK, STB_MaterialDocDetail_BK, STB_MaterialDocLotInfo_BK, STB_ProdRouteHist_BK, STB_ProdRouteSummary_BK, STB_ProductionOrderInfo_BK, VVT_F4, STB_VN_STAGEMACHINES_, VVT_Xem, STB_WarehouseLocation, STB_BarrelBarcodeInfo, STB_BarrelBarcodeDetail, STB_ElectrodeProdRouteHist, VVT_BG2, VVT_MeasurementControlList, STB_BomInfo, VVT_CAPA, VVT_SanminaShipmentPlan, VVT_SanminaLabelPrint, STB_YShipmentPlan, STB_YShipmentPlanLot, STB_YLabelPrintHist, STB_VVT_SortingErrorData_ALCase_NEW, STB_AttachedFileMaster, VVT_DoCreateQC4MChange, VVT_ViewDetailQC4MChange, VVT_View4MChange, VVT_CAPAInputSeparateLot, STB_DetailAgingHY, STB_LineStructureInfo, STB_RoutingInfo, STB_RoutingDetailInfo, STB_MaterialWarehouseInfo, STB_LocationInfo, STB_EmployeeInfo, STB_MachineInfo, STB_DeviceInfo, STB_SupplierInfo, STB_VendorMappingByMaterialInfo, STB_MaterialMappingByCustomer, VVT_MaterialStockList, STB_StagePrices, STB_VNT_ElectrodeSlittingCutterUsageHist, STB_VNSparePartInHistory, STB_VNSparePartOutHistory, GW_PO, GW_Pay, GW_HR, GW_Trip, GW_Report, GW_Leave, GW_Retire, GW_Item, GW_BOM, GW_Vendor, GW_Price, GW_H, GW_L, GW_03, STB_CellTestResult, STB_CellTestResultMax, STB_CellTestResultRT, GW_Core, GW_01, GW_02, GW_07, GW_04, GW_05, GW_06, GW_08, STB_UserInfo_MES, STB_ESM_WO_HEADER, STB_MaterialBOM, STB_MaterialHoldInfo, STB_HN_AccountingPrice, POP_KNOWLEDGE_BASE, POP_USER_MANUAL, GW_Plan, GW_Suju, POP_DB, GW_DBs
- **SP chua tim thay trong Live DB:** usp_Vietnam_NewScreenData_get, usp_Vietnam_NewScreenData_iud, usp_DoProcessProdRouteHistForCalc_VNT, usp_DoProcessProdRouteHistForBarcode2, usp_DoProcessProdRouteHistForBarcode1, usp_DoProcessProdGI, usp_DoProcessProdGR, usp_VNE_BoxLabelPrintHist_, usp_GetProdRouteHistForBarcode_PS_get, usp_Vietnam_ChangeProductionOrderRoutingLine_VNT, usp_Vietnam_GetLotInfoForRework_VNT, usp_YShipmentPlan_get, usp_YShipmentPlan_iud, usp_YLabelPrint_get, usp_YLabelPrintHist_iud, usp_Vietnam_ScrapInput_HN, usp_ProductionOrderInfo_HY_HY_get, usp_DoProcessProdRouteHist_HY, usp_LineStructureInfo_get, usp_LineStructureInfo_iud, usp_RoutingInfo_get, usp_RoutingInfo_iud, usp_MaterialWarehouseInfo_get, usp_MaterialWarehouseInfo_iud, usp_EmployeeInfo_get, usp_EmployeeInfo_iud, usp_MachineInfo_get, usp_MachineInfo_iud, usp_DeviceInfo_get, usp_DeviceInfo_iud, usp_SupplierInfo_get, usp_SupplierInfo_iud, usp_VendorMappingByMaterialInfo_get, usp_VendorMappingByMaterialInfo_iud, usp_MaterialMappingByCustomer_get, usp_MaterialMappingByCustomer_iud, usp_MaterialDocDetail_HY_iud, usp_MaterialWarehouseInOutHist_HY_iud, usp_MaterialReturnAndPrintLabel_get, usp_DoReturnMaterialDoc, usp_DoSplitRawMaterialAndMove_HY, usp_MaterialLotInfo_HY_get, usp_MaterialDocDetailHistory_get, usp_ProductionOrderInfo_iud, usp_vn_showproductionerror_get, usp_CellLineFaultReport_get, usp_MonthEndInventoryReport_get, usp_PostProductionScrapReport_get, usp_StagePrices_get, usp_StagePrices_iud, usp_ModuleCheckStatus_get, usp_VNT_ProdInspectionHist_get, usp_RouteInspectionMeasureFullHist_get, usp_ElectrodeInspectionHistoryForBarcode_get, usp_ReportSparePartInfo_get, usp_VNT_ElectrodeSlittingCutterUsageHist_get, usp_ReportSparePartDetail_get, usp_SyncPurchaseRequest, usp_GetPurchaseOrderList, usp_DoApplyIncomingQty, usp_DoCreateAccountingSlip, usp_SyncSalesOrder, usp_GetShipmentRequestList, usp_DoApplyRealShipment, usp_SyncDailyProductionPlan, usp_DoFinishRouteOperation, usp_SyncMaterialMaster, usp_De, usp_Get, usp_Do, usp_Vietnam_, usp_VN_, usp_VVT_, usp_HN_, usp_DoCreatePackingLabelInfo, usp_TenSP, usp_ElectrodeStep_Vietnam, usp_DeProcessProdPacking_VVT, usp_xxx

### File: ./MASTER_INDEX.md
- **Bang chua tim thay trong Live DB:** GW_INDEX, GW_01_DANG_NHAP, GW_02_MUA_HANG, GW_03_KE_HOACH_SX, GW_04_MASTER_DATA, GW_05_HANH_CHINH, GW_06_THANH_TOAN, GW_07_KHO_THANH_PHAM, GW_08_BAN_HANG, POP_KNOWLEDGE_BASE, POP_USER_MANUAL

### File: ./SYSTEM_INTEGRATION_MAP.md
- **Bang chua tim thay trong Live DB:** GW_PO, GW_Plan, GW_Suju, GW_HR, GW_Pay, POP_DB, GW_DBs, GW_02, GW_03

---
*Bao cao duoc tao tu dong boi cong cu audit_kb_reliability.ps1.*