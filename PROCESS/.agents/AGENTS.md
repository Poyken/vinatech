# 🤖 VINATECH MASTER AGENT ECOSYSTEM (.agents)

> **Workspace:** `PROCESS` (Enterprise Operations & Systems Portal) | **Phiên bản:** 3.1

## Cấu Trúc 5 Trụ Cột Điều Hành
1. **Trụ Cột POP KIOSK (`MES_POP/`):**
   - Rules: `MES_POP/.agents/rules/` (Rule 20 - EA Playbook)
   - L1 Cache: `MES_POP/AI_AGENT_CONFIG/POP_MATRIX.json`
   - Chức năng: Vận hành Kiosk xưởng, tra cứu BOM NVL & tồn kho `ROUTE_VN_WH`, mở khóa máy kẹt `ACTIVE`, kiểm tra sync `MongoToMesPerformance`, kiểm toán readiness
   - CLI: `.\pop.ps1`
2. **Trụ Cột CORE MES SẢN XUẤT (`MES_POP/`):**
   - Rules: `MES_POP/.agents/rules/`
   - Agents: `investigator-agent`, `auditor-agent`, `hotfix-deployer`
   - Skills: `vinatech-mes-troubleshoot`, `vinatech-db-operations`, `vinatech-new-model-setup`
   - L1 Cache: `MES_POP/AI_AGENT_CONFIG/QUICK_MATRIX.json` (95 screens)
   - Chức năng: Vòng đời Lot, màn hình WinForm (B530, B540, B552, B781, B782...), hotfixes nghiệp vụ có bọc Transaction (Author/ChangeUserID 'vanduc'), Morning Health Check, Watchdog 24/7
   - CLI: `.\mes.ps1`
3. **Trụ Cột GROUPWARE & ERP PHÊ DUYỆT (`GROUPWARE/`):**
   - Rules: `GROUPWARE/.agents/rules/`
   - Agents: `form-auditor`, `sync-investigator`, `masterdata-coordinator`
   - Skills: `groupware-form-trace`, `groupware-erp-sync`, `groupware-db-operations`
   - L1 Cache: `GROUPWARE/AI_AGENT_CONFIG/GW_FORM_MATRIX.json` (17 forms) & `APPROVAL_LINE_MATRIX.json`
   - Chức năng: Quy trình duyệt PO, tờ trình, chi phí, phả hệ liên kết văn bản, đồng bộ ERP NEOE
   - CLI: `.\gw.ps1`
4. **Trụ Cột DATABASE MULTI-ENGINE (`DATABASE/`):**
   - Rules: `DATABASE/.agents/rules/`
   - Agents: `db-auditor`, `schema-inspector`
   - Skills: `vinatech-database-operations`, `vinatech-cross-system-query`
   - L1 Cache: `DATABASE/AI_AGENT_CONFIG/DATABASE_MATRIX.json` (15 CSDL)
   - Chức năng: Quản trị an toàn, cross-db lineage, jobs, triggers, indexes cho 15 CSDL
   - CLI: `.\db.ps1`
5. **Trụ Cột HỢP NHẤT K-SYSTEM ACE (`FINAL/`):**
   - Rules: `FINAL/AI_AGENT_CONFIG/RULES.md`
   - L1 Cache: `FINAL/AI_AGENT_CONFIG/KSYSTEM_MATRIX.json` (17 modules) & `UNIFIED_INTEGRATION_MATRIX.json`
   - Specifications: `FINAL/ARCHITECTURE/` (4 Volumes Kiến Trúc Vận Hành Thâm Sâu)
   - CLI: `.\ksys.ps1`

## Bảng Tra Cứu L1 Cache Siêu Tốc
- POP Kiosk: `MES_POP/AI_AGENT_CONFIG/POP_MATRIX.json`
- MES WinForm & Backend: `MES_POP/AI_AGENT_CONFIG/QUICK_MATRIX.json` (95 screens)
- Groupware: `GROUPWARE/AI_AGENT_CONFIG/GW_FORM_MATRIX.json` (17 forms) & `APPROVAL_LINE_MATRIX.json`
- Database: `DATABASE/AI_AGENT_CONFIG/DATABASE_MATRIX.json` (15 CSDL)
- K-System Ace: `FINAL/AI_AGENT_CONFIG/KSYSTEM_MATRIX.json` (17 modules) & `UNIFIED_INTEGRATION_MATRIX.json`
