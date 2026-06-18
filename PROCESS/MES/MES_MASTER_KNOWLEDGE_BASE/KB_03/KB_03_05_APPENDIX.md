## Appendix — Core Production Table Schemas (DB Verified 2026-06-18)

### A.1 STB_SetInfo Schema (76 columns — Product Passport ★★★)

> **Đây là bảng quan trọng nhất trong toàn hệ thống MES** — mỗi sản phẩm (ControlNo) = 1 record. Bảng này là "hộ chiếu" của sản phẩm từ khi sinh ra đến khi xuất xưởng.

| Nhóm | Columns chính | Mô tả |
|---|---|---|
| **Identity** | `ControlNo` (PK, varchar 20), `Barcode` (varchar 50), `NewBarcode` (nvarchar 100) | Định danh sản phẩm |
| **PO Link** | `PONo`, `DayPlanNo`, `MaterialCode`, `BomVersion` (→KB_03 §5.2) | Liên kết lệnh SX |
| **Status Flags** | `IsLineInput` (bit), `IsLoss`, `IsDefect`, `IsProdFinish`, `IsNotWip` | 5 cờ trạng thái |
| **Current Position** | `CurrentRouteCode` (varchar 20), `InputLineCode`, `InputJobDate`, `InputShiftCode` | Vị trí hiện tại trên chuyền |
| **Production Finish** | `ProdFinishJobDate`, `ProdFinishShiftCode`, `ProdFinishDateTime` | Thời điểm hoàn thành SX |
| **Final Inspection** | `IsFinalInspection`, `IsOutboundFinalInspection`, `FinalInspectionJobDate` | QC cuối |
| **Lot Info** | `LotNumber` (varchar 50), `LotCreateDateTime`, `LotDecisionResult`, `LotUniqueNumber` (bigint) | Lot tracking |
| **Grade** | `GradeCode` (varchar 1), `GradeModelCode`, `GradeChangeUserID` | Phân loại A/B/C |
| **Module** | `ModuleLotNumber`, `ModuleBarcode`, `InternalProdNo`, `OutSetNo` | Module link |
| **Sales** | `SalesOrderNo`, `SOISequence` | Đơn hàng |
| **Warehouse** | `WarehouseStatus`, `IsSplitedAging` | Trạng thái kho/Aging |
| **Timing** | `PrintDate`, `LineOutTactTime` (numeric), `ProdQty` | Takt time + SL |
| **Extension** | `SIExtText01..07`, `SIExtInt01..05`, `SIExtReal01..05` | 17 trường mở rộng |
| **Rework** | `LotNumberBC`, `LotNumberRW` (varchar 255), `InitialLot` | Rework tracking |
| **Audit** | `CreateDateTime`, `CreateUserID`, `ChangeDateTime`, `ChangeUserID` | Thời gian tạo/sửa |

> [!IMPORTANT]
> `ControlNo` = PK (không đổi suốt đời sản phẩm). `Barcode` = Nhãn dán vật lý (có thể thay đổi khi re-label). `CurrentRouteCode` = Vị trí cuối cùng trên chuyền — dùng để trace "sản phẩm đang ở đâu".

### A.2 STB_ProdRouteHist Schema (23 columns — Routing Visa Stamp ★★★)

> Mỗi lần công nhân quét barcode tại một trạm → 1 record. **Đây là "visa stamp"** — bằng chứng sản phẩm đã qua công đoạn nào.

| Column | Type | Mô tả |
|---|---|---|
| `ProdRouteHistNo` | varchar(20) | **PK** — Auto-generated (YYYYMMDD + seq) |
| `CompanyCode` | varchar(20) | VVT/VNT |
| `WorkCenterCode` | varchar(20) | VVT_F1..F5 |
| `PONo` | varchar(20) | Số PO |
| `DayPlanNo` | varchar(20) | Số DPP (auto-fill by trigger) |
| `ControlNo` | varchar(20) | **FK → STB_SetInfo** |
| `MaterialCode` | varchar(50) | Mã NVL/SP |
| `BomVersion` | varchar(10) | Phiên bản BOM |
| `JobDate` | date | Ngày sản xuất |
| `ShiftCode` | varchar(1) | Ca (D/N) |
| `TimeCode` | varchar(2) | Mã giờ |
| `LineCode` | varchar(20) | **Mã Line** |
| `RouteCode` | varchar(20) | **★ Mã công đoạn** (V-22, V-24...) |
| `WorkerCode` | varchar(20) | Mã công nhân |
| `MachineCode` | varchar(20) | Mã máy |
| `ProdQty` | numeric | Số lượng |
| `ProdDateTime` | datetime | Thời điểm sản xuất |
| `DelayCode` | nvarchar(max) | Mã delay (nếu có) |
| `CompleteRoute` | varchar(1) | Hoàn thành route (Y/N) |

> [!NOTE]
> **2 Triggers on ProdRouteHist:**
> - `utr_ProdRouteHist_DayPlanNo_iu` → Auto-fill DayPlanNo
> - `utr_MaterialCodeByLine_i` → Log MaterialCode by Line cho thống kê

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: STB_SetInfo 76 cols (Product Passport) + STB_ProdRouteHist 23 cols (Routing Visa Stamp). DB verified.*
