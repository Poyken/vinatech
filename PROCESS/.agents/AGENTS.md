# 🤖 VINATECH MASTER AGENT ECOSYSTEM (.agents)

> **Workspace:** `PROCESS` (Enterprise Operations & Systems Portal) | **Phiên bản:** 4.0 (Unified Master Architecture)

## 🏛️ Cấu Trúc Điều Hành 5 Phân Hệ Hợp Nhất

1. **Tổng Hành Dinh Điều Phối (Master Orchestrator Hub):**
   - Công cụ: `ops.ps1` (Morning 360 Patrol, Universal Smart Auto-Router, Workspace Purge & Zombie Killer, 1-Click Snapshot Rollback, Weekly Report)
   - Lifecycle Hooks: `.agents/hooks.json` (`PreToolUse` Safety Gate & `PreInvocation` Governance Reminder)
   - Learned Patterns: `.agents/rules/02_learned_patterns.md` (Lưu bài học từ `/learn` và thực tiễn)
   - Operator Guide: `OPERATOR_COPILOT_GUIDE.md`

2. **Trụ Cột POP KIOSK (`MES_POP/`):**
   - Rules: `MES_POP/.agents/rules/` & Rule 20 (EA Playbook) & Rule 22 (Định danh sự cố là POP)
   - L1 Cache: `MES_POP/AI_AGENT_CONFIG/POP_MATRIX.json`
   - Chức năng: Vận hành Kiosk xưởng, tra cứu BOM NVL & tồn kho `ROUTE_VN_WH`, mở khóa máy kẹt `ACTIVE`, kiểm tra sync `MongoToMesPerformance`, kiểm toán readiness
   - CLI: `pop.ps1` hoặc `ops trace <VVM...>`

3. **Trụ Cột CORE MES SẢN XUẤT (`MES_POP/`):**
   - Rules: `MES_POP/.agents/rules/`
   - L1 Cache: `MES_POP/AI_AGENT_CONFIG/QUICK_MATRIX.json` (95 screens)
   - Chức năng: Vòng đời Lot, màn hình WinForm (B530, B540, B552, B781, B782...), hotfixes nghiệp vụ có bọc Transaction (Author/ChangeUserID 'vanduc'), Morning Health Check
   - CLI: `mes.ps1` hoặc `ops trace <VV...>`

4. **Trụ Cột GROUPWARE & ERP PHÊ DUYỆT (`GROUPWARE/`):**
   - Rules: `GROUPWARE/.agents/rules/` (00_groupware_rules.md)
   - L1 Cache: `GROUPWARE/AI_AGENT_CONFIG/GW_FORM_MATRIX.json` (17 forms) & `APPROVAL_LINE_MATRIX.json`
   - Chức năng: Quy trình duyệt PO, tờ trình, chi phí, phả hệ liên kết văn bản, đồng bộ ERP NEOE
   - CLI: `gw.ps1` hoặc `ops trace <PO/DocCode>`

5. **Trụ Cột DATABASE MULTI-ENGINE (`DATABASE/`):**
   - Rules: `DATABASE/.agents/rules/` (00_vinatech_database_rules.md)
   - L1 Cache: `DATABASE/AI_AGENT_CONFIG/DATABASE_MATRIX.json` (15 CSDL)
   - Chức năng: Quản trị an toàn, cross-db lineage, jobs, triggers, indexes cho 15 CSDL
   - CLI: `db.ps1` hoặc `ops health`

6. **Trụ Cột HỢP NHẤT K-SYSTEM ACE (`FINAL/`):**
   - Rules: `FINAL/AI_AGENT_CONFIG/RULES.md`
   - L1 Cache: `FINAL/AI_AGENT_CONFIG/KSYSTEM_MATRIX.json` (17 modules) & `UNIFIED_INTEGRATION_MATRIX.json`
   - Specifications: `FINAL/ARCHITECTURE/` (4 Volumes Kiến Trúc Vận Hành Thâm Sâu)
   - CLI: `ksys.ps1` hoặc `ops trace <_TPR...>`

---

## 🛠️ Danh Mục 10 Enterprise Skills Tối Ưu (.agents/skills/)
1. `vinatech-enterprise-ops`: Master Orchestrator, Morning Patrol, Universal Router, Snapshot & 1-Click Rollback.
2. `vinatech-mes-troubleshoot`: Xử lý sự cố lỗi dây chuyền MES, chốt sản lượng B530/B540, kẹt Lot HOLD/FIFO.
3. `vinatech-new-model-setup`: Checklist 8 bước khai báo Model/Sản phẩm mới trên MES.
4. `vinatech-database-operations`: Quản trị an toàn 15 CSDL, kiểm tra kết nối và deadlock.
5. `vinatech-cross-system-query`: Truy vết phả hệ dữ liệu liên thông 5 hệ thống.
6. `groupware-form-trace`: Truy vết tờ trình, phê duyệt văn bản Bizbox Alpha.
7. `groupware-erp-sync`: Điều tra lỗi đồng bộ giữa Groupware và ERP NEOE.
8. `groupware-db-operations`: Truy vấn và quản trị CSDL VINATECH_GROUP.
9. `ksystem-unified-operations`: Vận hành YoungLimWon K-System Ace ERP, CompanySeq=1, FrmWPDLotList.
10. `vinatech-db-operations`: Thao tác nghiệp vụ đa CSDL MES/POP/SmartFramework.

## 🕵️ Danh Mục 8 Subagents Chuyên Trách (.agents/agents/)
- `investigator-agent` & `auditor-agent` & `hotfix-deployer` (Phân hệ Sản xuất MES & Kiosk POP)
- `form-auditor` & `sync-investigator` & `masterdata-coordinator` (Phân hệ Groupware & ERP)
- `db-auditor` & `schema-inspector` (Phân hệ Quản trị CSDL)

## ⚡ Bảng Tra Cứu L1 Cache Siêu Tốc
- POP Kiosk: `MES_POP/AI_AGENT_CONFIG/POP_MATRIX.json`
- MES WinForm & Backend: `MES_POP/AI_AGENT_CONFIG/QUICK_MATRIX.json` (95 screens)
- Groupware: `GROUPWARE/AI_AGENT_CONFIG/GW_FORM_MATRIX.json` (17 forms) & `APPROVAL_LINE_MATRIX.json`
- Database: `DATABASE/AI_AGENT_CONFIG/DATABASE_MATRIX.json` (15 CSDL)
- K-System Ace: `FINAL/AI_AGENT_CONFIG/KSYSTEM_MATRIX.json` (17 modules) & `UNIFIED_INTEGRATION_MATRIX.json`

