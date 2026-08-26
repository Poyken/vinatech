# 🅱️ B-Series: Production & Cell/Module Execution

| Screen | Tên / Chức Năng | Search SP (`_get`) | Execute SP (`_iud`) | Bảng DB Chính | Ghi Chú & Bẫy Vận Hành |
|---|---|---|---|---|---|
| **B310** | Lệnh SX (PO Master) | `usp_ProductionOrderInfo_get` | `usp_ProductionOrderInfo_iud` | `STB_ProductionOrderInfo` | Khởi tạo lệnh sản xuất tháng cho Cell hoặc Module |
| **B351** | Chuyển đổi Lot | `usp_GetSetInfoForChangeMaterial` | `usp_DoChangeMaterialForSetInfo` | `STB_LotChangeMaterialHistory` | Cập nhật Barcode/MaterialCode sang mã mới |
| **B442** | Kế hoạch Điện cực | `usp_DayProdPlan_get` | `usp_DoCreateSetInfoForProdQty_VNT` | `STB_SetInfo`, `STB_MaterialMaster` | Tạo kế hoạch tráng cực và cắt dải slitting |
| **B450** | Kế hoạch ngày | `usp_DayProdPlan_get` | `usp_DoCreateSetInfoForProdQty_VNT` | `STB_DayProdPlan`, `STB_SetInfo` | **Tích chọn `IsFixed = 1` mới sinh Lot và in tem** |
| **B452** | Đổi Line sản xuất | `usp_Set_VVT_Info_get` | `usp_Set_VVT_Info_iud` | `STB_SetInfo` | UserID phải nằm trong danh sách whitelist của SP |
| **B523** | Đóng gói Cell & In tem | `usp_Vietnam_GetBoxIDForLotNo_VVT` | `usp_Vietnam_DoProcessProdPacking_VVT` | `STB_DividePackaging`, `STB_SavePackingTime_VVT` | Đóng gói gộp thùng, kiểm tra trọng lượng |
| **B530** | Chốt sản lượng (Core) | `usp_GetProdRouteHistForBarcode_VNT` | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | `STB_ProdRouteHist` | **Bắt buộc chọn Status = "Making"** để mở cổng V25 |
| **B540** | Thẻ công đoạn V22-V28 | `usp_RawMaterialInputHist_get` | `usp_Vietnam_RawMaterialInputHist_uid` | `STB_RawMaterialInputHist` | V23 Lắp cao su bắt buộc phải quét NVL trước |
| **B552** | Slitting Điện cực | `usp_SlittingLocationConfig_VVT_get` | `usp_SlittingLocationConfig_VVT_iud` | `STB_SlittingStock_VVT` | Cực dương (`BY`), Cực âm (`YP`) |
| **B597** | Scan NVL QC Inline | `usp_RawMaterialInputHist_get` | `usp_Vietnam_RawMaterialInputHist_uid` | `STB_MaterialLotInfo` | Kiểm tra 3 lớp (HOLD, Expiry, BOM) |
| **B767** | In tem Sanmina (OP) | `usp_SanminaLabelPrint_get_Vietnam` | `usp_SanminaIndiaLabelPrintHist_iud` | `STB_SanminaIndiaLabelPrintHist`, `STB_SanminaShipmentPlan` | Tự động nạp PO/PartNo/BoxNo từ Plan ACTIVE (Poka-Yoke) |
| **B767_M** | Thiết lập Lô xuất Sanmina | `usp_SanminaShipmentPlan_get` | `usp_SanminaShipmentPlan_iud` | `STB_SanminaShipmentPlan`, `STB_SanminaShipmentPlanLot` | Quản lý Lô xuất Sanmina: Tạo mới, kích hoạt ACTIVE, theo dõi tiến độ in |
| **B782** | Lịch sử Routing | `usp_LotTrackingInfo_VVT2_get` | — | `STB_ProdRouteHist` | Quét toàn bộ lịch sử các công đoạn của 1 Lot |
