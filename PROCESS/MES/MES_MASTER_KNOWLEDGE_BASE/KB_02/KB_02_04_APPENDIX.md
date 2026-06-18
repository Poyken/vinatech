
### A.1 Active Warehouse Distribution (118 tổng)

> **STB_MaterialWarehouse** schema: 20 columns (MaterialWarehouseCode varchar(20) PK, CompanyCode, WorkCenterCode, MaterialWarehouseName nvarchar(100), IsUsed bit, IsRouteWarehouse bit)

| CompanyCode | WorkCenterCode | Factory | Count | Key Warehouses |
|---|---|---|---|---|
| **VVT** | **VVT_F1** | **Bắc Ninh** | **32** | W02BN (Materials), W04BN (Products), W06BN (WIP), W08BN (NG), W09BN (Semi), W11BN (Electrode), W15BN (Holding), W19BN (OQC) |
| **VVT** | **VVT_F2** | **Bắc Giang 1** | **20** | W01BG (Materials), W03BG (Products), W07BG (NG), W12BG (Electrode), W27BG (WIP), ROH_BG_WH, ROUTE_BG_WH |
| **VVT** | **VVT_F3** | **Hà Nam** | **13** | ROH_HN_WH, PROD_HN_WH, MODULE_HN_WH, SLITTING_HN_WH, HOLDING_HN_WH |
| **VVT** | **VVT_F4** | **Bắc Giang 2** | **5** | MODULE_BG2_WH, ROUTE_BG2_WH, W61-W63 |
| **VVT** | **VVT_F5** | **Hưng Yên** | **5** | ROH_HY_WH, ROUTE_HY_WH, MODULE_HY_WH, HOLDING_HY_WH, NG_RAW_HY_WH |
| **VNT** | **VNT_F1** | **VNT BN** | **16** | W20-W24, W33-W38 |
| **VNT** | **VNT_F2** | **VNT BG** | **7** | W06-W12 |
| **VNT** | **VNT_F3** | **VNT HN** | **6** | W13-W18 |
| **VNT** | **VNT_F4** | **VNT BG2** | **8** | W40-W46 |
| **VNT** | **VNT_F5** | **VNT HY** | **6** | W34-W38, W46 |
| | | **TỔNG** | **118** | |

> [!IMPORTANT]
> Warehouse code có 2 hệ thống song song:
> - **W##XX** (W02BN, W01BG...) = Mã kho theo quy ước Hàn Quốc
> - **PREFIX_XX_WH** (ROH_HN_WH, HOLDING_BG_WH...) = Mã kho logic (ROH=Raw material, PROD=Production, HOLDING=Giữ hàng, NG_RAW=NG, ROUTE=On route, MODULE=Module)

### A.2 STB_MaterialDocInfo Schema (82 columns — Core WMS Transaction)

> Bảng này là **trung tâm** của toàn bộ WMS. Mỗi phiếu nhập/xuất/chuyển kho = 1 record.

| Column nhóm | Columns chính | Mô tả |
|---|---|---|
| **Header** | `MaterialDocNo` (PK, varchar 20), `BasicDate`, `MaterialDocType`, `DocStatus` | Số phiếu + ngày + loại |
| **Source** | `SourceCompanyCode`, `SourceWorkCenterCode`, `SourceRouteCode`, `SourceMaterialWarehouseCode` | Kho nguồn |
| **Target** | `TargetCompanyCode`, `TargetWorkCenterCode`, `TargetRouteCode`, `TargetMaterialWarehouseCode` | Kho đích |
| **PO Link** | `PONo`, `FPItemWorkNo`, `RefMaterialDocNo` | Liên kết PO + phiếu tham chiếu |
| **Workflow** | `RequestUserID`, `RequestApprovalUserID`, `PickingUserID`, `SourceProcessUserID`, `TargetProcessUserID` | 5 mốc người dùng |
| **Flags** | `IsRequestApproval`, `IsAssignPicking`, `IsSourceFinish`, `IsTargetFinish`, `IsCancel` | 5 cờ trạng thái |
| **ERP** | `IsUploadERP`, `MDIErpRefText01..10` | 10 trường đồng bộ ERP |
| **Extension** | `MRMIExtText01..15`, `MRMIExtBit01..05` | 20 trường mở rộng |

### A.3 Stock Table Inventory

| Table | Mô tả |
|---|---|
| `STB_MaterialStock` | **★ Tồn kho NVL** chính (tính toán real-time) |
| `STB_MaterialStockHist` | Lịch sử thay đổi tồn kho |
| `STB_MaterialStockAttributeInfo` | Thuộc tính tồn kho (lot, location, etc.) |
| `STB_MaterialRouteMoveStockDetail` | Chi tiết chuyển kho theo Route |
| `STB_ProductStockInfo` | **★ Tồn kho thành phẩm** |
| `STB_ProductStockInfoUpload` | Upload tồn kho TP lên ERP |
| `STB_ProductStockInfoUploadHist` | Lịch sử upload |
| `STB_PackingQtyWarehouse` | SL đóng gói theo kho |
| `STB_SFGWarehouse_VVTF3` | Kho bán thành phẩm HN (VVT_F3) |
| `STB_SystemWarehouseMappingInfo` | Ánh xạ kho hệ thống |
| `STB_MaterialWarehouseInOutHist` | **★ Lịch sử nhập/xuất kho** |

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: Warehouse Infrastructure (118 active, 10 factory zones) + MaterialDocInfo 82 cols + Stock tables. DB verified.*
