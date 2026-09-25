# 🤖 VINATECH MASTER AGENT ECOSYSTEM (.agents)

> **Workspace:** `PROCESS` (Enterprise Operations & Systems Portal) | **Phiên bản:** 3.0

## Cấu Trúc 4 Trụ Cột Điều Hành
1. **Trụ Cột MES & POP (`MES_POP/`):**
   - Rules: `MES_POP/.agents/rules/`
   - Agents: `investigator-agent`, `auditor-agent`, `hotfix-deployer`
   - Skills: `vinatech-mes-troubleshoot`, `vinatech-db-operations`, `vinatech-new-model-setup`
   - CLI: `.\mes.ps1`
2. **Trụ Cột GROUPWARE (`GROUPWARE/`):**
   - Rules: `GROUPWARE/.agents/rules/`
   - Agents: `form-auditor`, `sync-investigator`, `masterdata-coordinator`
   - Skills: `groupware-form-trace`, `groupware-erp-sync`, `groupware-db-operations`
   - CLI: `.\gw.ps1`
3. **Trụ Cột DATABASE (`DATABASE/`):**
   - Rules: `DATABASE/.agents/rules/`
   - Agents: `db-auditor`, `schema-inspector`
   - Skills: `vinatech-database-operations`, `vinatech-cross-system-query`
   - CLI: `.\db.ps1`
4. **Trụ Cột HỢP NHẤT K-SYSTEM ACE (`FINAL/`):**
   - Rules: `FINAL/AI_AGENT_CONFIG/RULES.md`
   - L1 Cache: `FINAL/AI_AGENT_CONFIG/KSYSTEM_MATRIX.json` & `UNIFIED_INTEGRATION_MATRIX.json`
   - Specifications: `FINAL/ARCHITECTURE/` (4 Volumes Kiến Trúc Vận Hành Thâm Sâu)
   - CLI: `.\ksys.ps1`

## Bảng Tra Cứu L1 Cache Siêu Tốc
- MES & POP: `MES_POP/AI_AGENT_CONFIG/QUICK_MATRIX.json` (95 screens) & `POP_MATRIX.json`
- Groupware: `GROUPWARE/AI_AGENT_CONFIG/GW_FORM_MATRIX.json` (17 forms) & `APPROVAL_LINE_MATRIX.json`
- Database: `DATABASE/AI_AGENT_CONFIG/DATABASE_MATRIX.json` (15 CSDL)
- K-System Ace: `FINAL/AI_AGENT_CONFIG/KSYSTEM_MATRIX.json` (17 modules) & `UNIFIED_INTEGRATION_MATRIX.json`
