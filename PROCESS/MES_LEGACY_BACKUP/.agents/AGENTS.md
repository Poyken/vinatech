# 🤖 VINATECH MES AGENT ECOSYSTEM MANIFEST (.agents)

> **Workspace:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES_LEGACY_BACKUP`
> **Phiên bản:** 2.0 (Triển khai toàn phần 2026-08-28)

---

## 🏛️ 1. Cấu Trúc Toàn Diện Hệ Sinh Thái (.agents)

- **`rules/` (Quy tắc bất biến nạp tự động vào System Prompt):**
  - [`00_vinatech_rules.md`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/rules/00_vinatech_rules.md): Rule 0 (Knowledge-First), Rule 1 (SELECT-Only), Rule 6 (Golden Query 360° First).
  - [`01_sql_safety_rules.md`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/rules/01_sql_safety_rules.md): Chuẩn `BEGIN TRAN...ROLLBACK`, `WITH(NOLOCK)`, UTF-8 BOM, chuỗi `N''`.
  - [`02_screen_mapping_rules.md`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/rules/02_screen_mapping_rules.md): Bản đồ định vị nhanh Screen ID ➔ SP + Bảng.

- **`skills/` (Kỹ năng chuyên môn nạp On-Demand):**
  - [`vinatech-mes-troubleshoot`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/skills/vinatech-mes-troubleshoot/SKILL.md): Xử lý sự cố chuyền, kẹt Lot, lỗi in tem, rã box.
  - [`vinatech-db-operations`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/skills/vinatech-db-operations/SKILL.md): Quản trị 15 Database Profiles, Morning Health Check, Schema Audit.
  - [`vinatech-new-model-setup`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/skills/vinatech-new-model-setup/SKILL.md): Checklist 8 bước thêm sản phẩm mới.

- **`agents/` (Đội ngũ Subagents chuyên trách):**
  - [`investigator-agent`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/agents/investigator-agent/AGENT.md): Chuyên gia khám nghiệm sự cố khẩn cấp trên chuyền.
  - [`auditor-agent`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/agents/auditor-agent/AGENT.md): Chuyên gia kiểm toán CSDL, Schema Drift và phát hiện dữ liệu mồ côi.
  - [`hotfix-deployer`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/.agents/agents/hotfix-deployer/AGENT.md): Chuyên gia soạn thảo SQL Hotfix và triển khai Pre-flight backup.

- **`hooks.json` (Hệ thống Interceptor tự động):**
  - Tiền kiểm tra an toàn câu truy vấn SQL và tự động kích hoạt bảo vệ dữ liệu.

---

## ⚡ 2. Bộ Công Cụ Điều Phối Trung Tâm ([mes.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/mes.ps1))

- `.\mes.ps1 find "<Keyword>"` : Tra cứu nhanh trong 78+ file KB.
- `.\mes.ps1 trace "<LotID>"` : Golden Query 360° quét Lot, Routing, Kho, Thùng.
- `.\mes.ps1 screen "<ScreenID>"` : Debug màn hình MES.
- `.\mes.ps1 audit` : Audit độ tin cậy tài liệu vs Live DB.
- `.\mes.ps1 health` : Morning Health Check.
- `.\mes.ps1 new-fix "<Issue>"` : Sinh template SQL Hotfix chuẩn UTF-8-BOM có `BEGIN TRAN...ROLLBACK`.
- `.\mes.ps1 deploy <file.sql>` : Deploy SQL kèm Pre-flight Snapshot backup.
