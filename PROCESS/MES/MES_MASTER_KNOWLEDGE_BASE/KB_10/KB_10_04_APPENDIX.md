## Appendix — Core Table Volumes & Production Infrastructure (DB Verified 2026-06-18)

### A.1 Top 10 Transactional Tables by Row Count

| # | Table | Rows | Vai trò |
|---|---|---|---|
| 1 | **`STB_ProcedureLog`** | **19,318,951** | ★ Audit log mọi SP call — "Sổ đen" hệ thống |
| 2 | **`STB_ProdRouteHist`** | **3,297,607** | ★★★ Visa stamp — mỗi scan = 1 record |
| 3 | `STB_ProdRouteSummary` | **1,873,854** | Tổng hợp sản lượng per Route/Line/Date |
| 4 | `STB_MaterialDocLotInfo` | **1,176,771** | Chi tiết Lot per phiếu nhập/xuất kho |
| 5 | `STB_MaterialLotInfo` | **996,824** | ★★ Master Lot NVL (Current = live stock) |
| 6 | `STB_CommInspDocHistory` | **826,344** | Lịch sử kiểm tra QC per Barcode |
| 7 | **`STB_SetInfo`** | **760,640** | ★★★ Product Passport — 1 record/sản phẩm |
| 8 | `STB_MaterialDocInfo` | **670,294** | Header phiếu nhập/xuất/chuyển kho |
| 9 | `STB_DayProdPlan` | **272,839** | Kế hoạch sản xuất ngày |
| 10 | `STB_ProductionOrderInfo` | **22,555** | PO (Lệnh SX) — ~22.5K lệnh tổng |

> [!IMPORTANT]
> **Growth rate ước tính:**
> - `STB_ProdRouteHist` tăng ~4,800 rows/ngày (2 ca × ~2,400 barcode scans/ca)
> - `STB_ProcedureLog` tăng ~50K rows/ngày (mọi SP call đều log)
> - `STB_SetInfo` tăng ~1,000 rows/ngày (sản phẩm mới)

### A.2 Production Table Family (31 tables — STB_Prod* verified)

| Table | Mô tả |
|---|---|
| **`STB_ProdRouteHist`** | ★★★ Core routing (3.3M rows) — Visa stamp |
| `STB_ProdRouteHist_Back` | Backup routing |
| `STB_ProdRouteHist_Temp` | Routing tạm thời |
| `STB_ProdRouteHistCancelHist` | Lịch sử hủy scan |
| `STB_ProdRouteHistNotes` | Ghi chú per scan |
| **`STB_ProdRouteSummary`** | ★ Tổng hợp sản lượng (1.9M rows) |
| `STB_ProdRouteSummary_NEW` | Summary phiên bản mới |
| `STB_ProdRouteSummary_VNM` | Summary riêng VN |
| `STB_ProdRouteWorkerHist` | Lịch sử công nhân per route |
| `STB_ProdSerialMappingInfo` | Ánh xạ serial |
| `STB_ProdLinePlan` | Kế hoạch theo Line |
| `STB_ProdInspIndivisualSpec` | Spec kiểm tra riêng |
| **`STB_ProductionOrderInfo`** | ★ PO Header (22.5K) |
| `STB_ProductionOrderBom` | BOM per PO |
| `STB_ProductionOrderRouting` | Routing per PO |
| `STB_ProductionOrderBatchInfo` | Batch info per PO |
| `STB_ProductionOrderSalesInfo` | Sales link per PO |
| `STB_ProductionPlan` | Kế hoạch SX tháng |
| `STB_ProductMachine` | Máy per sản phẩm |
| `STB_ProductMoistureMeasureHist` | Đo độ ẩm SP |
| `STB_ProductsReceiptHist` | Lịch sử nhập kho TP |
| `STB_ProductsReceiptHistMove` | Chuyển nhập kho |
| **`STB_ProductStockInfo`** | ★ Tồn kho thành phẩm |
| `STB_ProductStockInfoUpload` | Upload tồn kho → ERP |
| `STB_ProductStockInfoUploadHist` | Lịch sử upload |
| `STB_ProdWorkerInfo` | Thông tin công nhân SX |
| `STB_ProductGroup` | Nhóm sản phẩm |

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: Core Table Volumes (Top 10: ProcedureLog 19.3M, ProdRouteHist 3.3M, SetInfo 760K) + Production Table Family (31 tables). DB verified.*
