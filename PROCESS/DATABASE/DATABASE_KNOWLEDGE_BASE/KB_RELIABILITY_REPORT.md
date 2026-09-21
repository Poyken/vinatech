# BÃO CÃO Äá»˜ TIN Cáº¬Y TÃ€I LIá»†U & SCHEMA DRIFT AUDIT

> **Cáº­p nháº­t:** 2026-09-21 07:46:06
> **Tá»•ng quan há»‡ thá»‘ng:** **77.8%** Ä‘á»‘i tÆ°á»£ng khá»›p chÃ­nh xÃ¡c vá»›i Live DB (458 / 589 Ä‘á»‘i tÆ°á»£ng).
> **Má»¥c Ä‘Ã­ch:** HÆ°á»›ng dáº«n AI vÃ  Ká»¹ sÆ° xÃ¡c Ä‘á»‹nh chÃ­nh xÃ¡c má»©c Ä‘á»™ tin cáº­y cá»§a tá»«ng tÃ i liá»‡u trÆ°á»›c khi váº­n hÃ nh.

---

## 1. TiÃªu Chuáº©n PhÃ¢n Loáº¡i Äá»™ Tin Cáº­y

- **HIGH (>= 90%):** TÃ i liá»‡u chuáº©n xÃ¡c cao, Báº£ng & Stored Procedure Ä‘Ã£ Ä‘Æ°á»£c verify vá»›i CSDL thá»±c táº¿. **CÃ³ thá»ƒ Ã¡p dá»¥ng ngay logic nghiá»‡p vá»¥.**
- **MEDIUM (70% - 89%):** TÃ i liá»‡u cÃ³ Ä‘á»™ chÃ­nh xÃ¡c khÃ¡, má»™t sá»‘ SP/Báº£ng thuá»™c DB phá»¥ hoáº·c cÃ³ typo nhá». Cáº§n kiá»ƒm tra nháº¹ trÆ°á»›c khi cháº¡y.
- **LOW (< 70%):** TÃ i liá»‡u cÃ³ nhiá»u giáº£ Ä‘á»‹nh hoáº·c Ä‘á» cáº­p SP chÆ°a triá»ƒn khai trÃªn Production. Báº¯t buá»™c kiá»ƒm tra ká»¹ CSDL.

---

## 2. Báº£ng ÄÃ¡nh GiÃ¡ Chi Tiáº¿t Tá»«ng TÃ i Liá»‡u

| File TÃ i Liá»‡u | Báº£ng Khá»›p | SP Khá»›p | Äá»™ Tin Cáº­y | PhÃ¢n Loáº¡i |
|:---|:---:|:---:|:---:|:---:|
| [./DEEP_DIVE_04_HIGH_VOLUME_PERFORMANCE_AND_INDEXES.md](./DEEP_DIVE_04_HIGH_VOLUME_PERFORMANCE_AND_INDEXES.md) | 6/6 | 0/0 | **100%** | [HIGH] |
| [../AI_AGENT_CONFIG/RULES.md](../AI_AGENT_CONFIG/RULES.md) | 3/3 | 0/0 | **100%** | [HIGH] |
| [../SYSTEM_ARCHITECTURE/VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md](../SYSTEM_ARCHITECTURE/VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md) | 10/10 | 0/0 | **100%** | [HIGH] |
| [./VINATECH_POP/README.md](./VINATECH_POP/README.md) | 32/32 | 0/0 | **100%** | [HIGH] |
| [./AndonDB/README.md](./AndonDB/README.md) | 3/3 | 5/5 | **100%** | [HIGH] |
| [../SYSTEM_ARCHITECTURE/MES_OPERATIONAL_LOG.md](../SYSTEM_ARCHITECTURE/MES_OPERATIONAL_LOG.md) | 1/1 | 1/1 | **100%** | [HIGH] |
| [./BUSINESS_RULES_AND_MANUALS_DIGEST.md](./BUSINESS_RULES_AND_MANUALS_DIGEST.md) | 1/1 | 0/0 | **100%** | [HIGH] |
| [./VINATECH_WEBSOCKET/README.md](./VINATECH_WEBSOCKET/README.md) | 6/6 | 0/0 | **100%** | [HIGH] |
| [./DB_01_SmartFactoryV2_MES.md](./DB_01_SmartFactoryV2_MES.md) | 13/13 | 5/5 | **100%** | [HIGH] |
| [./DEEP_DIVE_01_PHYSICAL_TOPOLOGY_AND_LINKED_SERVERS.md](./DEEP_DIVE_01_PHYSICAL_TOPOLOGY_AND_LINKED_SERVERS.md) | 2/2 | 2/2 | **100%** | [HIGH] |
| [./DB_02_SmartFramework.md](./DB_02_SmartFramework.md) | 0/0 | 5/5 | **100%** | [HIGH] |
| [../SYSTEM_ARCHITECTURE/VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md](../SYSTEM_ARCHITECTURE/VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md) | 28/28 | 5/6 | **97.1%** | [HIGH] |
| [./VINATECH_GROUP/README.md](./VINATECH_GROUP/README.md) | 20/21 | 0/0 | **95.2%** | [HIGH] |
| [./DEEP_DIVE_05_TRIGGER_AND_EVENT_DRIVEN_ARCHITECTURE.md](./DEEP_DIVE_05_TRIGGER_AND_EVENT_DRIVEN_ARCHITECTURE.md) | 8/9 | 0/0 | **88.9%** | [MEDIUM] |
| [../AI_AGENT_CONFIG/HOTFIX_LOG_HISTORICAL.md](../AI_AGENT_CONFIG/HOTFIX_LOG_HISTORICAL.md) | 40/44 | 8/11 | **87.3%** | [MEDIUM] |
| [./DEEP_DIVE_02_SQL_AGENT_JOBS_AND_DATA_PUMPS.md](./DEEP_DIVE_02_SQL_AGENT_JOBS_AND_DATA_PUMPS.md) | 3/3 | 9/11 | **85.7%** | [MEDIUM] |
| [./VINATECH_GROUP/PURCHASE_INTEGRATION.md](./VINATECH_GROUP/PURCHASE_INTEGRATION.md) | 17/20 | 0/0 | **85%** | [MEDIUM] |
| [../SYSTEM_ARCHITECTURE/MES_DAILY_PLAYBOOK.md](../SYSTEM_ARCHITECTURE/MES_DAILY_PLAYBOOK.md) | 5/6 | 0/0 | **83.3%** | [MEDIUM] |
| [./ARCHITECTURE_DEEP_DIVE_GROUPWARE_ERP_MES.md](./ARCHITECTURE_DEEP_DIVE_GROUPWARE_ERP_MES.md) | 19/25 | 9/9 | **82.4%** | [MEDIUM] |
| [./NEOE/README.md](./NEOE/README.md) | 9/11 | 0/0 | **81.8%** | [MEDIUM] |
| [../AI_AGENT_CONFIG/KNOWLEDGE.md](../AI_AGENT_CONFIG/KNOWLEDGE.md) | 11/14 | 0/0 | **78.6%** | [MEDIUM] |
| [./VINATECH_GROUP/PRODUCTION_PLANNING.md](./VINATECH_GROUP/PRODUCTION_PLANNING.md) | 7/9 | 0/0 | **77.8%** | [MEDIUM] |
| [../AI_AGENT_CONFIG/LESSONS_LEARNED.md](../AI_AGENT_CONFIG/LESSONS_LEARNED.md) | 13/16 | 2/4 | **75%** | [MEDIUM] |
| [./DEEP_DIVE_03_END_TO_END_DATA_LINEAGE_ATLAS.md](./DEEP_DIVE_03_END_TO_END_DATA_LINEAGE_ATLAS.md) | 15/20 | 0/0 | **75%** | [MEDIUM] |
| [../SYSTEM_ARCHITECTURE/VOL_01_SYSTEM_ARCHITECTURE.md](../SYSTEM_ARCHITECTURE/VOL_01_SYSTEM_ARCHITECTURE.md) | 60/73 | 8/18 | **74.7%** | [MEDIUM] |
| [./VINATECH_GROUP/ORGANIZATION_AND_WORKFLOW.md](./VINATECH_GROUP/ORGANIZATION_AND_WORKFLOW.md) | 6/9 | 0/0 | **66.7%** | [LOW] |
| [./VINATECH_GROUP/MASTER_DATA_INTEGRATION.md](./VINATECH_GROUP/MASTER_DATA_INTEGRATION.md) | 14/21 | 0/0 | **66.7%** | [LOW] |
| [../SYSTEM_INTEGRATION_MAP.md](../SYSTEM_INTEGRATION_MAP.md) | 17/26 | 0/0 | **65.4%** | [LOW] |
| [./VINATECH_GROUP/HR_AND_ADMIN_INTEGRATION.md](./VINATECH_GROUP/HR_AND_ADMIN_INTEGRATION.md) | 7/13 | 0/0 | **53.8%** | [LOW] |
| [./VINATECH_GROUP/DISBURSEMENT_INTEGRATION.md](./VINATECH_GROUP/DISBURSEMENT_INTEGRATION.md) | 5/10 | 0/0 | **50%** | [LOW] |
| [./VINATECH_GROUP/WAREHOUSE_AND_INVENTORY_INTEGRATION.md](./VINATECH_GROUP/WAREHOUSE_AND_INVENTORY_INTEGRATION.md) | 5/10 | 0/0 | **50%** | [LOW] |
| [./VINATECH_GROUP/SALES_AND_SHIPMENT_INTEGRATION.md](./VINATECH_GROUP/SALES_AND_SHIPMENT_INTEGRATION.md) | 5/11 | 0/0 | **45.5%** | [LOW] |
| [./VINATECH_GROUP/SSO_AND_SECURITY_INTEGRATION.md](./VINATECH_GROUP/SSO_AND_SECURITY_INTEGRATION.md) | 2/5 | 0/0 | **40%** | [LOW] |
| [./VINATECH_SPREADSHEET/README.md](./VINATECH_SPREADSHEET/README.md) | 4/12 | 0/0 | **33.3%** | [LOW] |
| [./VINATECH_RESTFUL/README.md](./VINATECH_RESTFUL/README.md) | 1/3 | 0/0 | **33.3%** | [LOW] |
| [./DZICUBE/README.md](./DZICUBE/README.md) | 1/3 | 0/9 | **8.3%** | [LOW] |
| [./legacy_docs/DB_INDEX_legacy.md](./legacy_docs/DB_INDEX_legacy.md) | 0/1 | 0/0 | **0%** | [LOW] |
| [./SmartFactoryIncubator/README.md](./SmartFactoryIncubator/README.md) | 0/3 | 0/0 | **0%** | [LOW] |

---

## 3. Danh SÃ¡ch Äá»‘i TÆ°á»£ng Cáº§n LÆ°u Ã (Unverified / Typos / Cross-DB)

### File: ./ARCHITECTURE_DEEP_DIVE_GROUPWARE_ERP_MES.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** STB_UserInfo_MES, MA_USER_ERP, MA_EMP_ERP, VVT_F1, VVT_F2, VVT_F3

### File: ./DEEP_DIVE_02_SQL_AGENT_JOBS_AND_DATA_PUMPS.md
- **SP chÆ°a tÃ¬m tháº¥y trong Live DB:** usp_DoSyncMaterialUnit, usp_SalesUnitPrice_interface

### File: ./DEEP_DIVE_03_END_TO_END_DATA_LINEAGE_ATLAS.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_PO, POP_LOG, STB_BoxPackagingInfo, STB_PalletPackagingInfo, VVT_F5

### File: ./DEEP_DIVE_05_TRIGGER_AND_EVENT_DRIVEN_ARCHITECTURE.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** STB_SetInfoRemoveHist

### File: ./DZICUBE/README.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** VINA_DOCUMENT_PAYMENT, FI_DOCU_D
- **SP chÆ°a tÃ¬m tháº¥y trong Live DB:** USP_A_, USP_A, USP_B, USP_W, USP_S, USP_P, USP_H, USP_M, USP_D

### File: ./legacy_docs/DB_INDEX_legacy.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_Core

### File: ./NEOE/README.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** FI_DOCU_D, PU_PO

### File: ./SmartFactoryIncubator/README.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** STB_CellTestResult, STB_CellTestResultMax, STB_CellTestResultRT

### File: ./VINATECH_GROUP/DISBURSEMENT_INTEGRATION.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_PO, GW_Pay, FI_DOCU_D, FI_ACCT, GW_06_THANH_TOAN

### File: ./VINATECH_GROUP/HR_AND_ADMIN_INTEGRATION.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_HR, GW_Trip, GW_Report, GW_Leave, GW_Retire, GW_05_HANH_CHINH

### File: ./VINATECH_GROUP/MASTER_DATA_INTEGRATION.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_Item, GW_BOM, GW_Vendor, GW_Price, GW_H, GW_L, GW_04_MASTER_DATA

### File: ./VINATECH_GROUP/ORGANIZATION_AND_WORKFLOW.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_01_DANG_NHAP, GW_04_MASTER_DATA, GW_05_HANH_CHINH

### File: ./VINATECH_GROUP/PRODUCTION_PLANNING.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_03_KE_HOACH_SX, VINA_DOCUMENT_DAILY_PRODUCTION_ORDER_LOT

### File: ./VINATECH_GROUP/PURCHASE_INTEGRATION.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_02_MUA_HANG, GW_06_THANH_TOAN, FI_DOCU_D

### File: ./VINATECH_GROUP/README.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_INDEX

### File: ./VINATECH_GROUP/SALES_AND_SHIPMENT_INTEGRATION.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_08_BAN_HANG, GW_07_KHO_THANH_PHAM, GW_03, VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION, VINA_DOCUMENT_SALES_ORDER_LINE, VINA_DOCUMENT_SALES_RESOLUTION

### File: ./VINATECH_GROUP/SSO_AND_SECURITY_INTEGRATION.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_01_DANG_NHAP, VINA_SSO_TOKEN, VINA_SSO_LOGIN

### File: ./VINATECH_GROUP/WAREHOUSE_AND_INVENTORY_INTEGRATION.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_07_KHO_THANH_PHAM, GW_08_BAN_HANG, VVT_F1, VVT_F2, VVT_F3

### File: ./VINATECH_RESTFUL/README.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** VINA_SSO_LOGIN, VINA_SSO_TOKEN

### File: ./VINATECH_SPREADSHEET/README.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** VINA_SPREAD_SHEET_JSON, VINA_SPREAD_SHEET, VINA_SPREAD_SHEET_OPEN, VINA_SPREAD_SHEET_PERMISSIONS, VINA_SPREAD_SHEET_HISTORY, VINA_SPREAD_SHEET_TYPE, VINA_SPREAD_SHEET_USER, VINA_SPREAD_SHEET_USER_JSON

### File: ../SYSTEM_ARCHITECTURE/MES_DAILY_PLAYBOOK.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** STB_ESM_WO_HEADER

### File: ../SYSTEM_ARCHITECTURE/VOL_01_SYSTEM_ARCHITECTURE.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** STB_MaterialBOM, STB_CellTestResult, VINA_SSO_TOKEN, VINA_SPREAD_SHEET_JSON, VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION, VINA_DOCUMENT_DAILY_PRODUCTION_ORDER_LOT, VINA_DOCUMENT_BUSINESS_TRIP, VINA_DOCUMENT_PARTNER_REG, VINA_DOCUMENT_BOM_REVISION, GW_H, GW_L, VINA_DOCUMENT_SALES_ORDER_LINE, VINA_BG
- **SP chÆ°a tÃ¬m tháº¥y trong Live DB:** usp_SyncPurchaseRequest, usp_GetPurchaseOrderList, usp_DoApplyIncomingQty, usp_DoCreateAccountingSlip, usp_SyncSalesOrder, usp_GetShipmentRequestList, usp_DoApplyRealShipment, usp_SyncDailyProductionPlan, usp_DoFinishRouteOperation, usp_SyncMaterialMaster

### File: ../SYSTEM_ARCHITECTURE/VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md
- **SP chÆ°a tÃ¬m tháº¥y trong Live DB:** fn_VVT_getdatebyVendorLot

### File: ../AI_AGENT_CONFIG/HOTFIX_LOG_HISTORICAL.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** VVT_F1, VVT_F2, VVT_F5, POP_KB_03
- **SP chÆ°a tÃ¬m tháº¥y trong Live DB:** fn_VVT_getdatebyVendorLot_MergeCode, fn_VVT_getdatebyVendorLot, usp_DoProcessProdRouteHist_HY

### File: ../AI_AGENT_CONFIG/KNOWLEDGE.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** VINA_DOCUMENT_DAILY_PLAN, VINA_DOCUMENT_PAYMENT, FI_DOCU_D

### File: ../AI_AGENT_CONFIG/LESSONS_LEARNED.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** VVT_F1, VVT_F2, VVT_F5
- **SP chÆ°a tÃ¬m tháº¥y trong Live DB:** fn_VVT_getdatebyVendorLot_MergeCode, fn_VVT_getdatebyVendorLot

### File: ../SYSTEM_INTEGRATION_MAP.md
- **Báº£ng chÆ°a tÃ¬m tháº¥y trong Live DB:** GW_PO, GW_PLAN, GW_PAY, POP_MAP, VINA_DOCUMENT_DAILY_PLAN, VINA_DOCUMENT_PAYMENT, FI_DOCU_D, VINA_SSO_TOKEN, VINA_SSO_LOGIN

---
*BÃ¡o cÃ¡o Ä‘Æ°á»£c táº¡o tá»± Ä‘á»™ng bá»Ÿi cÃ´ng cá»¥ audit_kb_reliability.ps1.*