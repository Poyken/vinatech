# 🛡️ SCREEN & STORED PROCEDURE MAPPING RULES (VINATECH MES)

## 1. NGUYÊN TẮC ĐỊNH VỊ MÀN HÌNH TỨC THÌ (IMMEDIATE SCREEN MAPPING)
Khi nhận Screen ID hoặc ảnh chụp giao diện từ User:
- **B530 (Nhập sản lượng công đoạn):** SP chính `usp_DoProcessProdRouteHist`, Bảng `STB_ProdRouteHist`.
- **B540 (Chốt sản lượng Cell Line):** SP chính `usp_DoProcessProdRouteHist`, chốt công đoạn cuối.
- **B523 (Gộp/Chia Box Cell):** Bảng `STB_DividePackaging`, `STB_MaterialLotInfo`.
- **B351 (Chuyển đổi Lot/Model):** Bảng `STB_LotChangeMaterialHistory`, `STB_SetInfo`.
- **A230 (Thông tin vật liệu / Master Data):** Bảng `STB_MaterialMaster` (Cấu hình `BasicRoutingCode`).
- **B240 (Thông tin routing):** SP `usp_BasicRoutingInfo_get`, `usp_GetBasicRouteingDetailForRoute`, Bảng `STB_BasicRoutingInfo`, `STB_BasicRoutingDetail` (Cấu hình công đoạn `RouteCode` theo `WorkCenterCode`).
- **B310 (Tạo/Quản lý PO tháng):** SP `usp_DoCreateProductionOrder`, Bảng `STB_ProductionOrderInfo`, `STB_ProductionOrderRouting`, `STB_ProductionOrderBom`.
- **HN523 / HN544 / HN555 (Hà Nam Packaging):** Tra cứu trực tiếp tại `KB_11_HANAM_FACTORY_SCREENS.md`.
- **F330 / F721 (Kho & Tồn kho WMS):** Bảng `STB_MaterialDocInfo`, `STB_MaterialLotInfo`.
- **B723 (Hạng mục kiểm kê - CheckItems):** Bảng `STB_VN_ITEM_CHECK` (Độ dày, quy cách điện cực, danh mục kiểm kê Line).
- **B725 (Kiểm kê cuối tháng - ViewCategorieInventory):** SP `usp_VN_show_InvetoryEndmonths`, Bảng `STB_VN_ITEM_CHECK`.
- **B552 (Kết quả đo điện cực - Mixing/Coating/Rollpress/Slitting):**
  - **SP chính:** `usp_ElectrodeMixInfo_get/iud`, `usp_ElectrodeMixStepInfo_get/iud`, `usp_ElectrodeSlittingInfo_get/iud`, `usp_ElectrodeSlittingResult_get/iud`.
  - **Bảng Mixing:** `STB_ElectrodeMixInfo` (`ElectrodeLotNumber, ProductionQty, WorkDate...`), `STB_ElectrodeMixStepInfo` (`ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode, InputQty1, MaterialLotNumber...`).
  - **Bảng Slitting:** `STB_ElectrodeSlittingInfo` (`ElectrodeLotNumber, MachineCode, WorkerCode...`), `STB_ElectrodeSlittingResult` (`ElectrodeLotNumber, Seq, Barcode, SlittingWidth, GoodQtyLength...`), `STB_ElectrodeSlittingResultHist`.
  - ⚠️ **BẪY FONT CHỮ TRÊN GIAO DIỆN MES:** Ký tự `VV` đứng liền hiển thị giống chữ `W` (VD: `VVQP...` nhìn như `WQP...`), `01` nhìn như `D1`. Khi tra cứu DB, **BẮT BUỘC dùng LIKE '%...%'** hoặc quy đổi `W -> VV` để tránh truy vấn 0 rows!

## 2. QUY TẮC PULL & ĐỒNG BỘ SP
- Cấm sửa SP dựa trên trí nhớ cũ; luôn dùng `.\mes.ps1 sp <SP_Name>` để lấy định nghĩa mới nhất từ SQL Server.
- Sau khi phân tích xong, dọn dẹp SP tạm bằng `.\mes.ps1 sp -Clean`.
