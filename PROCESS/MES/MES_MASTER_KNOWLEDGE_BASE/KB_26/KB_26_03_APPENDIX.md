## Appendix — ESM Bridge Tables (DB Verified 2026-06-18)

> **19 tables** prefix `ESM_` trong SmartFactoryV2 — cầu nối dữ liệu **ERP ↔ MES**

### ESM Bridge Table Inventory

| Table | Mô tả | Hướng sync |
|---|---|---|
| **`ESM_DayProdPlan`** | ★ Kế hoạch ngày (sync từ ERP) | ERP → MES |
| `ESM_DayProdPlanBatchLog` | Log batch sync DPP | — |
| `ESM_DayProdPlanClose` | DPP đã đóng | MES → ERP |
| `ESM_DayProdPlanError` | Lỗi sync DPP | — |
| `ESM_DayProdPlanNotData` | DPP không có data | — |
| `ESM_DayProdPlanUpdateTarget` | Target update DPP | ERP → MES |
| `ESM_DirectDayProdPlan` | DPP trực tiếp | ERP → MES |
| `ESM_DirectDayProdPlanHead` | Header DPP trực tiếp | ERP → MES |
| **`ESM_ProdRouteHist`** | ★ Lịch sử routing (sync lên ERP) | MES → ERP |
| `ESM_ProdRouteLotHist` | Lot routing history | MES → ERP |
| `ESM_ProdCollectionSetting` | Cài đặt thu thập SX | Config |
| **`ESM_RawMaterialInputHist`** | ★ Lịch sử nhập NVL | MES → ERP |
| `ESM_RawMaterialLotInputHist` | Lot NVL nhập chi tiết | MES → ERP |
| `ESM_DefectInfo` | Thông tin lỗi sync | MES → ERP |
| `ESM_DefectInfoErr` | Lỗi sync defect | — |
| `ESM_LotUpdateTarget` | Target update Lot | ERP → MES |
| `ESM_QtPlanTemp` | QT Plan tạm | Temp |
| `ESM_SyncDeleteTarget` | Target xóa sync | ERP → MES |
| `ESM_WarehouseInOutHist` | ★ Lịch sử nhập/xuất kho | MES → ERP |

> [!NOTE]
> **Pattern ESM Bridge:** Mỗi bảng ESM_ là "hộp thư trung gian" — MES ghi vào bảng ESM → Agent Job đọc bảng ESM → Push lên ERP. Nếu sync fail → error log vào bảng `_Error`/`_Err`. Kiểm tra bảng error khi data ERP-MES bị lệch.

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: ESM Bridge Tables (19 tables, ERP↔MES sync). DB verified.*
