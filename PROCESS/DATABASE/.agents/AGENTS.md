# 🤖 VINATECH DATABASE AGENT ECOSYSTEM (.agents)

> **Workspace:** `DATABASE` | **Phiên bản:** 1.0  
> **Phạm vi quản lý:** 15 Cơ sở Dữ liệu & 3 Trụ Cột Doanh Nghiệp (Groupware — ERP — MES/POP)

## Cấu Trúc Phân Hệ
- **`rules/`** — `00_vinatech_database_rules.md` (Quy tắc vận hành CSDL), `01_sql_safety_rules.md` (Quy tắc an toàn SQL & Anti-lock)
- **`skills/`** — `vinatech-database-operations`, `vinatech-cross-system-query`
- **`agents/`** — `db-auditor`, `schema-inspector`, `flow-tracer`

## Tra Cứu Nhanh & Điểm Tựa Vận Hành
- **L1 Cache:** `AI_AGENT_CONFIG/DATABASE_MATRIX.json` (15 CSDL, bảng chính, PK, quan hệ, <0.001s)
- **CLI Hub:** `.\db.ps1` (list, health, query, schema, find, trace)
- **Master Index:** `MASTER_INDEX.md`
- **Topology Map:** `SYSTEM_INTEGRATION_MAP.md`
