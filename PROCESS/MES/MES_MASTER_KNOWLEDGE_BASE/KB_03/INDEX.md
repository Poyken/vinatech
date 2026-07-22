<!--
AI-READY METADATA
Purpose: Chỉ mục định tuyến phân hệ Sản Xuất Cell Line & Routing History (Production Module Directory)
Scope: Production Execution Knowledge Routing
Single Source of Truth: KB_03/INDEX.md (Production Module Index) & KB_03_02_CELL_LINE.md
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_03_01_OVERVIEW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md)
  - [KB_03_02_CELL_LINE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md)
  - [KB_03_03_SCREEN_BUGS_B.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_03_SCREEN_BUGS_B.md)
  - [KB_03_04_SCREEN_BUGS_BK.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_04_SCREEN_BUGS_BK.md)
-->

# KB_03 — Sản Xuất & Lịch Sử Routing (INDEX)

> **File gốc:** KB_03 đã được tách thành 4 chunks.
> **Đọc chunk phù hợp** thay vì load toàn bộ 150KB.
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)

---

## Chunk Map

| # | File | Nội dung | Size | Single Source of Truth (SoT) |
|---|------|----------|------|------------------------------|
| 01 | [KB_03_01_OVERVIEW](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md) | §5 Tổng quan SX, SetInfo schema, ProdRouteHist, Production flow | 16KB | SetInfo & ProdRouteHist Data Schema |
| 02 | [KB_03_02_CELL_LINE](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md) | §6 Cell Line vận hành: B530, B523, B597, B598, NVL, Route config, Rework | **64KB** | Cell Line Production Operations |
| 03 | [KB_03_03_SCREEN_BUGS_B](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_03_SCREEN_BUGS_B.md) | Bug fix theo Screen: B210-B802, H301-H305, HN523-HN866, K101-K110 | 38KB | B-series Production Bug Fixes (Part 1) |
| 04 | [KB_03_04_SCREEN_BUGS_BK](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_04_SCREEN_BUGS_BK.md) | Bug fix theo Screen: B220-B935, H302-H305, K109-K110 (chi tiết) | 28KB | B-series Production Bug Fixes (Part 2) |



---

## Quick Routing — Tôi cần đọc chunk nào?

| Tình huống | Chunk |
|---|---|
| Hiểu tổng quan SX, schema SetInfo/ProdRouteHist | → **01_OVERVIEW** |
| Debug B530 (chốt SL), B523 (gộp box), B597 (scan NVL) | → **02_CELL_LINE** |
| Bug NVL, Route config, Rework, Barrel, Electrode Plan | → **02_CELL_LINE** |
| Tra bug theo mã màn hình (B-series, HN, K) | → **03_SCREEN_BUGS_B** |
| Chi tiết screen B220-B935, K109-K110 | → **04_SCREEN_BUGS_BK** |

