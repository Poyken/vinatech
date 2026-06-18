# KB_03 — Sản Xuất & Lịch Sử Routing (INDEX)

> **File gốc:** `KB_03_SAN_XUAT.md` (150KB) đã được tách thành 5 chunks.
> **Đọc chunk phù hợp** thay vì load toàn bộ 150KB.

---

## Chunk Map

| # | File | Nội dung | Size | Tokens |
|---|------|----------|------|--------|
| 01 | [KB_03_01_OVERVIEW](KB_03_01_OVERVIEW.md) | §5 Tổng quan SX, SetInfo schema, ProdRouteHist, Production flow | 16KB | ~4.2K |
| 02 | [KB_03_02_CELL_LINE](KB_03_02_CELL_LINE.md) | §6 Cell Line vận hành: B530, B523, B597, B598, NVL, Route config, Rework | **64KB** | ~16.5K |
| 03 | [KB_03_03_SCREEN_BUGS_B](KB_03_03_SCREEN_BUGS_B.md) | Bug fix theo Screen: B210-B802, H301-H305, HN523-HN866, K101-K110 | 38KB | ~9.8K |
| 04 | [KB_03_04_SCREEN_BUGS_BK](KB_03_04_SCREEN_BUGS_BK.md) | Bug fix theo Screen: B220-B935, H302-H305, K109-K110 (chi tiết) | 28KB | ~7K |
| 05 | [KB_03_05_APPENDIX](KB_03_05_APPENDIX.md) | Core Production Table Schemas (DB Verified) | 4KB | ~1K |

---

## Quick Routing — Tôi cần đọc chunk nào?

| Tình huống | Chunk |
|---|---|
| Hiểu tổng quan SX, schema SetInfo/ProdRouteHist | → **01_OVERVIEW** |
| Debug B530 (chốt SL), B523 (gộp box), B597 (scan NVL) | → **02_CELL_LINE** |
| Bug NVL, Route config, Rework, Barrel, Electrode Plan | → **02_CELL_LINE** |
| Tra bug theo mã màn hình (B-series, HN, K) | → **03_SCREEN_BUGS_B** |
| Chi tiết screen B220-B935, K109-K110 | → **04_SCREEN_BUGS_BK** |
| Schema bảng | → **05_APPENDIX** |
