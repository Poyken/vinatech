<!--
AI-READY METADATA
Purpose: Cẩm nang Phân tích Chuyên sâu & Ma trận Ánh xạ 100% Kỹ thuật Toàn bộ 65 Màn hình/TCode trong WBS Triển khai Hệ thống MES Nhà máy Hưng Yên (VVT_F5)
Scope: Complete Hung Yen MES Implementation WBS (Sections 1.1 -> 8.1)
Single Source of Truth: KB_07_04_HUNG_YEN_WBS_MAPPING.md
Project Leader: Mr. Kevin | Start Date: 01/06/2026 | Progress: Week 10 (07/08/2026)
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)
  - [KB_07_01_OVERVIEW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md)
  - [KB_07_02_DEPLOY_HY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_02_DEPLOY_HY.md)
  - [KB_07_03_SCREEN_BUGS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md)
  - [KB_09_SCREEN_BUG_FIXBOOK.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md)
-->

# 🗺️ KB_07_04 — Vinatech MES Hưng Yên WBS Screen Mapping Master (Phân Tích Chuyên Sâu)

> **Dự án:** IMPLEMENTING THE MES SYSTEM AT THE HUNG YEN FACTORY  
> **WorkCenterCode:** `VVT_F5` (Nhà máy Hưng Yên) | **CompanyCode:** `VVT` / `VNT`  
> **Project Leader:** Mr. Kevin | **Ngày bắt đầu:** 01/06/2026 | **Thời điểm đánh giá:** Wk 10 (07/08/2026)  
> **Nguồn tri thức:** DB Verified against `SmartFactoryV2` + `SmartFramework` + 24 KB Files + `CellLine.txt`.  
> ← [Về Master Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)

---

## 🏛️ 1. Tổng Quan Môi Trường Kỹ Thuật & Kiến Trúc Vận Hành Hưng Yên (`VVT_F5`)

### 1.1 Danh Mục Mã Kho Vật Lý Hưng Yên
- **`ROH_HY_WH`**: Kho Nguyên vật liệu chính Hưng Yên.
- **`FGT_HY_WH`**: Kho Thành phẩm chính Hưng Yên (`STB_VN_FINISHGOODS_HY`).
- **`VNE_PRODUCT_WH`**: Kho Thành phẩm VinaEnesol (chuyên biệt sản phẩm ghép Box Enesol `D000` Menu).
- **`HOLDING_HY_WH`**: Kho Hold kiểm định chất lượng NVL/BTP Hưng Yên.
- **Kho Công Đoạn:** `ROUTE_HY_WH`, `SLITTING_HY_WH`, `REWORK_HY_WH`, `REJECT_HY_WH`, `SCRAP_HY_WH`, `DOPING_HY_WH`, `OVEN_HY_WH`, `MIXING_HY_WH`, `COATING_HY_WH`, `PRESSING_HY_WH`.

### 1.2 Dây Chuyền Sản Xuất (Production Lines)
- **Cell Lines (Tụ Cell):** `VVHYC-01` $\rightarrow$ `VVHYC-06`.
- **Module Lines (Module Tụ):** `VVHYMD-01` $\rightarrow$ `VVHYMD-04`.

---

## 📋 2. Phân Tích Chi Tiết 65 Hạng Mục WBS Triển Khai (Sections 1.1 $\rightarrow$ 8.1)

---

### 2.1 Section 1.1 — General Configuration for the MES System (Cấu Hình Chung Hệ Thống)
*Phụ trách:* **Mr. Triều** (Bắt đầu: 01/06/2026 - Hoàn thành: 04/06/2026)

#### 1. Process structure information in the Line (`B230`)
- **TCode:** `B230` | **Screen Name:** `LineStructureInfo`
- **Stored Procedures:** `usp_LineStructureInfo_get` (Search) / `usp_LineStructureInfo_iud` (Execute)
- **Bảng DB chính:** `STB_LineStructureInfo`, `STB_LineInfo`
- **Nghiệp vụ chi tiết:** Thiết lập mối quan hệ phân cấp giữa Chuyền sản xuất (`LineCode`) và danh mục các công đoạn (`RouteCode`). Cho phép định nghĩa trạm sấy Oven, trạm hàn Bending, trạm cuộn Winding thuộc chuyền nào.
- **Bẫy vận hành & Traps:** Nếu thiếu cấu hình `LineStructureInfo`, màn hình `B530`/`HY530` sẽ báo lỗi *"Công đoạn không thuộc Line đang chọn"*.

#### 2. Process information (`B220` / `HY220`)
- **TCode:** `B220` (Hưng Yên: `HY220`) | **Screen Name:** `RouteInfo` / `HY220`
- **Stored Procedures:** `usp_RouteInfo_get` (Search) / `usp_RouteInfo_iud` (Execute)
- **Bảng DB chính:** `STB_RouteInfo`
- **Nghiệp vụ chi tiết:** Khai báo danh mục mã công đoạn sản xuất master (VD: `V-22` Sấy, `V-24` Cuộn, `V-26` Chèn, `V-28` Lắp rãnh, `VE01` Electrode).
- **Bẫy vận hành:** Mã công đoạn phải khớp 100% với cấu hình BOM `A310` và Routing `A320`.

#### 3. Cell Line Information (`B210`)
- **TCode:** `B210` | **Screen Name:** `LineInfo`
- **Stored Procedures:** `usp_LineInfo_get` (Search) / `usp_LineInfo_iud` (Execute)
- **Bảng DB chính:** `STB_LineInfo`
- **Nghiệp vụ chi tiết:** Đăng ký danh mục chuyền sản xuất `VVHYC-01` $\rightarrow$ `VVHYC-06` và `VVHYMD-01` $\rightarrow$ `VVHYMD-04`, gán `WorkCenterCode = 'VVT_F5'` và `MaterialWarehouseCode = 'ROH_HY_WH'`.
- **Bẫy vận hành:** Nếu cột `MaterialWarehouseCode` bị NULL hoặc sai mã kho, màn hình xuất kho NVL `HY430`/`HY431` sẽ không thấy dữ liệu cấp phát.

#### 4. Routing Information (`B240`)
- **TCode:** `B240` | **Screen Name:** `RoutingInfo`
- **Stored Procedures:** `usp_RoutingInfo_get` (Search) / `usp_RoutingInfo_iud` (Execute)
- **Bảng DB chính:** `STB_RoutingInfo`, `STB_RoutingDetailInfo`
- **Nghiệp vụ chi tiết:** Thiết lập chuỗi trình tự công đoạn sản xuất tiêu chuẩn (Route Sequence) cho từng dòng sản phẩm Tụ Cell hoặc Module.
- **Bẫy vận hành:** Thứ tự `RouteSeq` quyết định luồng chuyển công đoạn tự động trên `B530`/`HY530`. Nhập sai `RouteSeq` gây kẹt Lot không chuyển trạm được.

#### 5. Account permissions (`Z210`)
- **TCode:** `Z210` | **Screen Name:** `UserType`
- **Stored Procedures:** `usp_UserType_get` (Search) / `usp_UserType_iud` (Execute)
- **Bảng DB chính:** `SmartFramework.dbo.STB_UserType`, `STB_UserPermission`
- **Nghiệp vụ chi tiết:** Quản lý nhóm quyền (Admin, Supervisor, OP Chuyền, IQC Inspector, Stockkeeper) và gán danh sách màn hình được phép truy cập cho nhóm.

#### 6. Warehouse and location information (`A130`)
- **TCode:** `A130` | **Screen Name:** `MaterialWarehouseInfo`
- **Stored Procedures:** `usp_MaterialWarehouseInfo_get` (Search) / `usp_MaterialWarehouseInfo_iud` (Execute)
- **Bảng DB chính:** `STB_MaterialWarehouseInfo`, `STB_LocationInfo`
- **Nghiệp vụ chi tiết:** Khai báo mã kho vật lý `ROH_HY_WH`, `FGT_HY_WH`, `HOLDING_HY_WH` và danh mục tọa độ ô kệ (Location Code).

#### 7. Employee Information (`B260`)
- **TCode:** `B260` | **Screen Name:** `EmployeeInfo`
- **Stored Procedures:** `usp_EmployeeInfo_get` (Search) / `usp_EmployeeInfo_iud` (Execute)
- **Bảng DB chính:** `STB_EmployeeInfo`
- **Nghiệp vụ chi tiết:** Quản lý mã nhân viên, họ tên, bộ phận sản xuất xưởng Hưng Yên để gán vết thao tác trên các bản ghi chốt sản lượng.

#### 8. Login Account with worker Hưng Yên (`Z410`)
- **TCode:** `Z410` | **Screen Name:** `UserInfo` / `UserAccount`
- **Stored Procedures:** `usp_UserInfo_get` (Search) / `usp_UserInfo_iud` (Execute)
- **Bảng DB chính:** `SmartFramework.dbo.STB_UserInfo`
- **Nghiệp vụ chi tiết:** Khai báo User ID đăng nhập ứng dụng MES Desktop/Mobile cho công nhân Hưng Yên, link với `EmployeeID`.

#### 9. Information on production equipment (`B270`)
- **TCode:** `B270` | **Screen Name:** `MachineInfo`
- **Stored Procedures:** `usp_MachineInfo_get` (Search) / `usp_MachineInfo_iud` (Execute)
- **Bảng DB chính:** `STB_MachineInfo`
- **Nghiệp vụ chi tiết:** Quản lý mã máy sản xuất, công suất tiêu chuẩn và gán máy vào từng chuyền `VVHYC-*`.

#### 10. Device information (`B250`)
- **TCode:** `B250` | **Screen Name:** `DeviceInfo`
- **Stored Procedures:** `usp_DeviceInfo_get` (Search) / `usp_DeviceInfo_iud` (Execute)
- **Bảng DB chính:** `STB_DeviceInfo`
- **Nghiệp vụ chi tiết:** Quản lý thiết bị ngoại vi kết nối máy tính trạm (Máy in tem Zebra, đầu đọc mã vạch Honeywell, cân điện tử).

---

### 2.2 Section 2.1 — Raw Materials Warehouse (Kho Nguyên Vật Liệu WMS)
*Phụ trách:* **Mr. Trường** (Bắt đầu: 10/06/2026 - Hoàn thành: 30/06/2026)

#### 11. Supplier information (`A130` Supplier)
- **TCode:** `A130` | **Screen Name:** `SupplierInfo`
- **Stored Procedures:** `usp_SupplierInfo_get` / `usp_SupplierInfo_iud`
- **Bảng DB chính:** `STB_SupplierInfo`
- **Nghiệp vụ chi tiết:** Khai báo danh mục nhà cung cấp NVL đầu vào (Mã NCC, tên NCC, địa chỉ, quốc gia).

#### 12. Specify suppliers for each raw material (`F140`)
- **TCode:** `F140` | **Screen Name:** `VendorMappingByMaterialInfo`
- **Stored Procedures:** `usp_VendorMappingByMaterialInfo_get` / `usp_VendorMappingByMaterialInfo_iud`
- **Bảng DB chính:** `STB_VendorMappingByMaterialInfo`
- **Nghiệp vụ chi tiết:** Thiết lập ánh xạ 1 Mã NVL nội bộ có thể nhập từ những Nhà cung cấp nào.

#### 13. Specify materials by supplier (`F130`)
- **TCode:** `F130` | **Screen Name:** `MaterialMappingByCustomer`
- **Stored Procedures:** `usp_MaterialMappingByCustomer_get` / `usp_MaterialMappingByCustomer_iud`
- **Bảng DB chính:** `STB_MaterialMappingByCustomer`
- **Nghiệp vụ chi tiết:** Quy định mã Part Number của nhà cung cấp tương ứng với mã NVL nội bộ Vinatech.

#### 14. Create Material Notes (`HY312` / `F312`)
- **TCode:** `HY312` (Gốc: `F312`) | **Screen Name:** `HY_MaterialGrFromOrder` / `Vietnam_MaterialGrFromOrder`
- **Stored Procedures:** `usp_MaterialDocDetail_get` (Search) / `usp_MaterialDocDetail_HY_iud` (Execute)
- **Bảng DB chính:** `STB_MaterialDocInfo`, `STB_MaterialDocDetail`
- **Nghiệp vụ chi tiết:** Tạo phiếu nhập kho NVL từ PO mua hàng. Quản lý số lượng yêu cầu (`RequestQty`), số lượng cho phép (`AllowQty`) và số lượng đã lấy (`PickingQty`).

#### 15. Receiving raw materials into inventory (`HY330` / `F320`)
- **TCode:** `HY330` (Gốc: `F320`) | **Screen Name:** `HY_MaterialReceiptAndPrintLabel` / `MaterialReceipt`
- **Stored Procedures:** `usp_vvt_MaterialLotInfo_get` / `usp_DoCreateMaterialDocLotInfoNotUsedBarcode`
- **Bảng DB chính:** `STB_MaterialDocInfo`, `STB_MaterialLotInfo`
- **Nghiệp vụ chi tiết:** Thực hiện tiếp nhận lô NVL giao đến, kiểm đếm số lượng thực tế và chèn bản ghi tồn kho vào `ROH_HY_WH`.

#### 16. Separating labels and printing labels (`HY330` / `F330`)
- **TCode:** `HY330` (Gốc: `F330`) | **Screen Name:** `HY_MaterialReceiptAndPrintLabel` / `MaterialReceiptAndPrintLabel`
- **Stored Procedures:** `usp_vvt_MaterialLotInfo_get` / `usp_DoCreateMaterialDocLotInfoNotUsedBarcode`
- **Bảng DB chính:** `STB_MaterialLotInfo`, `STB_MaterialDocLotInfo`
- **Nghiệp vụ chi tiết:** Tách cuộn/thùng NVL lớn thành các Lot/Gói nhỏ và in tem Barcode NVL dán lên từng cuộn/thùng trước khi xếp kệ.

#### 17. Export raw materials to CellLine, import raw materials back... (`HY430` / `F430`)
- **TCode:** `HY430` (Gốc: `F430`) | **Screen Name:** `HY_MaterialWarehouseInOutHist` / `VNT_MaterialWarehouseInOutHist`
- **Stored Procedures:** `usp_vvt_MaterialLotInfo_get` (Search) / `usp_MaterialWarehouseInOutHist_HY_iud` (Execute)
- **Bảng DB chính:** `STB_MaterialWarehouseInOutHist`, `STB_MaterialLotInfo`
- **Nghiệp vụ chi tiết:** Xuất kho NVL cấp cho các chuyền Cell Line `VVHYC-*` hoặc chuyền Module `VVHYMD-*`. Ghi nhận lịch sử điều chuyển từ `ROH_HY_WH` sang `ROUTE_HY_WH`.
- **Bẫy vận hành:** Muốn hủy thao tác xuất kho nhầm ➔ Xóa dòng lịch sử tại `STB_MaterialWarehouseInOutHist` và cập nhật lại `CurrentQty` trong `STB_MaterialLotInfo`.

#### 18. Material output to CellLine uses FIFO (First In, First Out)
- **TCode:** Engine WMS Auto Check | **Chức năng:** Kiểm soát xuất kho NVL theo nguyên tắc FIFO
- **Stored Procedures:** `usp_MaterialStockAttributeInfo_get` / Engine tự động
- **Bảng DB chính:** `STB_MaterialStockAttributeInfo`, `STB_MaterialLotInfo`
- **Nghiệp vụ chi tiết:** Bắt buộc xuất lô NVL có ngày nhập kho (`CreateDateTime`) hoặc hạn sử dụng (`LotAttr10`) cũ nhất trước. Hệ thống cảnh báo văng popup nếu thủ kho quét tem NVL mới hơn lô tồn cũ.

#### 19. Return the returned production materials and re-enter into inventory (`HY620` / `F620`)
- **TCode:** `HY620` (Gốc: `F620`) | **Screen Name:** `HY_MaterialReturnAndPrintLabel` / `MaterialReturnAndPrintLabel`
- **Stored Procedures:** `usp_MaterialReturnAndPrintLabel_get` / `usp_DoReturnMaterialDoc`
- **Bảng DB chính:** `STB_MaterialLotInfo`, `STB_MaterialWarehouseInOutHist`
- **Nghiệp vụ chi tiết:** Nhận NVL còn dư sau ca sản xuất trả về kho `ROH_HY_WH`, cân/đếm lại số lượng dư, in lại tem barcode cập nhật số lượng mới và đưa về kệ kho.

#### 20. Separate the quantities to supply for production... (`HY740` / `F740`)
- **TCode:** `HY740` (Gốc: `F740`) | **Screen Name:** `HY_SplitLot` / `SplitLot`
- **Stored Procedures:** `usp_vvt_MaterialLotInfo_get` / `usp_DoSplitRawMaterialAndMove_HY`
- **Bảng DB chính:** `STB_MaterialLotInfo`, `STB_SupportRawMaterialSplitHist`
- **Nghiệp vụ chi tiết:** Thực hiện tách 1 Lot NVL cha thành nhiều Lot NVL con theo đúng định mức cấp phát ca sản xuất.

#### 21. Raw material inventory (`HY721` / `F721`)
- **TCode:** `HY721` (Gốc: `F721`) | **Screen Name:** `HY_MaterialStockList` / `VVT_MaterialStockList`
- **Stored Procedures:** `usp_MaterialLotInfo_HY_get` / `usp_DoChangeMaterialDocLotInfo`
- **Bảng DB chính:** `STB_MaterialLotInfo`
- **Nghiệp vụ chi tiết:** Tra cứu tổng tồn kho NVL real-time tại kho Hưng Yên theo Mã NVL, Mã Lot, Vị trí ô kệ (`LocationCode`) và Trạng thái HOLD/Free.

#### 22. History of raw material shipments in Warehouse (`HY761` / `F761`)
- **TCode:** `HY761` (Gốc: `F761`) | **Screen Name:** `HY_MaterialDocDetailHistory_vvt1`
- **Stored Procedures:** `usp_MaterialDocDetailHistory_get`
- **Bảng DB chính:** `STB_MaterialDocDetail`, `STB_MaterialWarehouseInOutHist`
- **Nghiệp vụ chi tiết:** Báo cáo xuất-nhập-tồn và lịch sử thu chi NVL chi tiết theo từng phiếu nhập kho/phiếu xuất chuyền tại Hưng Yên.

---

### 2.3 Section 3.1 — Production Execution (Sản Xuất Cell Line & Module)
*Phụ trách:* **Mr. Mạnh** (Bắt đầu: 10/06/2026 - Hoàn thành: 30/06/2026)

#### 23. Create PO (`B310`)
- **TCode:** `B310` | **Screen Name:** `ProductionOrderInfo`
- **Stored Procedures:** `usp_ProductionOrderInfo_HY_get` (Search) / `usp_ProductionOrderInfo_iud` (Execute)
- **Bảng DB chính:** `STB_ProductionOrderInfo`, `STB_ProductionOrderBom`, `STB_ProductionOrderRouting`
- **Nghiệp vụ chi tiết:** Lập Lệnh sản xuất PO Master. Chọn `POType = CELL` hoặc `MODULE`, gán Mã sản phẩm (`MaterialCode`), Sản lượng kế hoạch (`OrderQty`), BOM định mức NVL và Quy trình công đoạn Routing.

#### 24. Create Daily Plan (`B450` / `K101`)
- **TCode:** `B450` (Cell) / `K101` (Module PCBA/SCM/SL7) | **Screen Name:** `DayProdPlan` / `DayProdPlanForMainLotMDL`
- **Stored Procedures:** `usp_DayProdPlan_HY_get` (Search) / `usp_DoCreateSetInfoForProdQty_VNT` (Execute)
- **Bảng DB chính:** `STB_DayProdPlan`, `STB_SetInfo`
- **Nghiệp vụ chi tiết:** Lập kế hoạch sản xuất ngày theo PO và Line. **Bắt buộc tích cờ `IsFixed = 1`** để SP kích hoạt tự động sinh dải Barcode/ControlNo vào bảng `STB_SetInfo`.

#### 25. Process card information (`HY540` / `B540`)
- **TCode:** `HY540` (Gốc: `B540`) | **Screen Name:** `HY_AssyCardInfo` / `RawMaterialInputHist`
- **Stored Procedures:** `usp_RawMaterialInputHist_get` (Search) / `usp_Vietnam_RawMaterialInputHist_uid` (Execute)
- **Bảng DB chính:** `STB_RawMaterialInputHist`, `STB_SetInfo`
- **Nghiệp vụ chi tiết:** Quét Barcode Lot NVL thô cấp vào đầu công đoạn sản xuất (Assy Card).
- **Bẫy vận hành:** Màn hình yêu cầu điền **đầy đủ 4 cột thuộc tính màu bắt buộc** (Nhiệt độ sấy, Thời gian sấy, Lô sấy lò Oven) trước khi nhấn Lưu.

#### 26. Enter actual production (`B530` / `K361`)
- **TCode:** `B530` (Core Cell) / `K361` (Module) | **Screen Name:** `ProdRouteHist` / `HoanThanhCongDoanTheoY`
- **Stored Procedures:** `usp_GetProdRouteHistForBarcode_VNT` (Search) / `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` (Execute)
- **Bảng DB chính:** `STB_ProdRouteHist`, `STB_SetInfo`, `STB_DefectRepairInfo`
- **Nghiệp vụ chi tiết:** Trạm chốt sản lượng sản xuất công đoạn (Ghi nhận `ProdQty`, `DefectQty`, `LossQty`).
- **7 Cổng Kiểm Soát (7 Autocheck Gates):**
  1. Kiểm tra Barcode có tồn tại trong `STB_SetInfo`.
  2. Kiểm tra cờ `IsFixed = 1` của Kế hoạch ngày.
  3. Kiểm tra công đoạn trước đã hoàn thành chưa (`CompleteRoute IS NOT NULL`).
  4. Kiểm tra NVL đã quét đủ chưa tại `B540`/`B597`.
  5. Kiểm tra thời gian lão hóa Aging (24h) đối với công đoạn Aging.
  6. Kiểm tra trạng thái IQC/OQC Pass.
  7. Kiểm tra trạng thái Lot không bị HOLD.

#### 27. Report on waste materials produced on Cell Line (`B598`)
- **TCode:** `B598` | **Screen Name:** `VN_ScrapAfterProduction`
- **Stored Procedures:** `usp_vn_showproductionerror` (Search) / `usp_vn_scrapafterproduction` (Execute)
- **Bảng DB chính:** `STB_VN_PRODUCTION_ERROR`, `STB_DefectRepairInfo`
- **Nghiệp vụ chi tiết:** Kê khai và cân khối lượng phế liệu NVL (kg/g) phát sinh trực tiếp tại chuyền Cell Line trong ca.

#### 28. Enter inspection items and raw materials (`B597` / `K109`)
- **TCode:** `B597` (Cell) / `K109` (Module PCBA/SCM/SL7) | **Screen Name:** `RawMaterialInputHist_QC` / `VNT_SelfInspectionRawMaterialBE`
- **Stored Procedures:** `usp_RawMaterialInputHist_get` / `usp_Vietnam_RawMaterialInputHist_uid`
- **Bảng DB chính:** `STB_RawMaterialInputHist`, `STB_MaterialLotInfo`
- **Nghiệp vụ chi tiết:** Scan NVL đầu chuyền kiểm soát **3 Lớp Chặn**:
  1. Chặn NVL đang ở trạng thái **HOLD** kiểm định.
  2. Chặn NVL **Hết hạn sử dụng** (Expiry Date).
  3. Chặn NVL sai chủng loại so với **BOM PO** (`STB_ProductionOrderBom`).

#### 29. Find the history of previously entered lots B598 (`B790`)
- **TCode:** `B790` | **Screen Name:** `ProductionErrorHistory`
- **Stored Procedures:** `usp_vn_showproductionerror_get`
- **Bảng DB chính:** `STB_VN_PRODUCTION_ERROR`
- **Nghiệp vụ chi tiết:** Tra cứu lịch sử báo cáo các lô phế liệu NVL đã nhập từ màn hình `B598`.

#### 30. Detailed cell line fault report (`B682`)
- **TCode:** `B682` | **Screen Name:** `CellLineFaultReport` / `StagePrices`
- **Stored Procedures:** `usp_CellLineFaultReport_get`
- **Bảng DB chính:** `STB_DefectRepairInfo`, `STB_ProdRouteHist`
- **Nghiệp vụ chi tiết:** Báo cáo thống kê chi tiết các dạng mã lỗi defect và sự cố máy dừng chuyền trên Cell Line.

#### 31. Total number of defects by batch (`B782`)
- **TCode:** `B782` | **Screen Name:** `LotTrackingInfo_VVT2`
- **Stored Procedures:** `usp_LotTrackingInfo_VVT2_get`
- **Bảng DB chính:** `STB_ProdRouteHist`, `STB_DefectRepairInfo`, `STB_SetInfo`
- **Nghiệp vụ chi tiết:** Màn hình Tra cứu Lịch sử Routing 360° cho 1 Lot Barcode: Hiển thị qua từng công đoạn, thời gian chốt, công nhân chốt và tổng phế lỗi accumulative.

#### 32. Packaging and label printing (`K198` / `B523`)
- **TCode:** `K198` (SL-7 Label) / `B523` (Core Packaging) | **Screen Name:** `VNT_PrintBloomEnergySL7Label` / `ProdPackingForBarcode`
- **Stored Procedures:** `usp_Vietnam_GetProdPackingForBarcode_VVT` (Search) / `usp_Vietnam_DoProcessProdPacking_VVT` (Execute)
- **Bảng DB chính:** `STB_DividePackaging`, `STB_SavePackingTime_VVT`, `STB_SetInfo`
- **Nghiệp vụ chi tiết:** Đóng gói sản phẩm hoàn thiện vào hộp/thùng, thực hiện ghép Box Nho vào Box To và phát hành in tem nhãn dán thùng.

#### 33. End-of-month inventory report for all departments (`B723`)
- **TCode:** `B723` | **Screen Name:** `MonthEndInventoryReport`
- **Stored Procedures:** `usp_MonthEndInventoryReport_get`
- **Bảng DB chính:** `STB_MaterialLotInfo`, `STB_SetInfo`
- **Nghiệp vụ chi tiết:** Báo cáo kiểm kê chốt tồn kho bán thành phẩm và nguyên vật liệu trên dây chuyền cuối tháng.

#### 34. Report of post-production waste (`B726`)
- **TCode:** `B726` | **Screen Name:** `PostProductionScrapReport`
- **Stored Procedures:** `usp_PostProductionScrapReport_get`
- **Bảng DB chính:** `STB_VN_PRODUCTION_ERROR`
- **Nghiệp vụ chi tiết:** Báo cáo tổng hợp phế liệu sau sản xuất và đề xuất phương án xử lý hủy phế.

#### 35. Add production costs for each stage (`PM01`)
- **TCode:** `PM01` | **Screen Name:** `PriceAndCodeVN`
- **Stored Procedures:** `usp_StagePrices_get` / `usp_StagePrices_iud`
- **Bảng DB chính:** `STB_StagePrices`
- **Nghiệp vụ chi tiết:** Khai báo chi phí đơn giá công đoạn sản xuất áp dụng cho từng mã sản phẩm.

#### 36. Current status of module product checking (`K366`)
- **TCode:** `K366` | **Screen Name:** `ThongTinHienTrangLoiBG2`
- **Stored Procedures:** `usp_ModuleCheckStatus_get`
- **Bảng DB chính:** `STB_DefectRepairInfo`, `STB_SetInfo`
- **Nghiệp vụ chi tiết:** Giám sát real-time hiện trạng kiểm tra lỗi và tỷ lệ Pass/Fail của các dòng sản phẩm Module.

#### 37. View the number of items completed for the day (`K781` / `B781`)
- **TCode:** `K781` / `B781` | **Screen Name:** `KetQuaSanLuongHoanThanh` / `Vietnam_PackPrintTime`
- **Stored Procedures:** `usp_Vietnam_PackPrintTime_get`
- **Bảng DB chính:** `STB_SavePackingTime_VVT`, `STB_ProdRouteHist`
- **Nghiệp vụ chi tiết:** Tra cứu tổng sản lượng đóng gói hoàn thành trong ngày và phân tích Takt Time sản xuất.

---

### 2.4 Section 3.1 & 4.1 — IQC & Quality Inspection (Kiểm Soát Chất Lượng Đầu Vào)
*Phụ trách:* **Mr. Đức** (Bắt đầu: 10/06/2026 - Hoàn thành: 30/06/2026)

#### 38. Manage inspection items and inspection teams (`C121` / `HY121`)
- **TCode:** `C121` (Hưng Yên: `HY121`) | **Screen Name:** `CommInspSelectGroup` / `QCInspectionGroup_HY`
- **Stored Procedures:** `usp_CommInspSelectGroup_get` / `usp_CommInspSelectGroup_iud`
- **Bảng DB chính:** `STB_CommInspSelectGroup`, `STB_CommInspItem`
- **Nghiệp vụ chi tiết:** Khai báo cấu hình nhóm hạng mục kiểm tra IQC/PQC/OQC và phân công danh sách nhân viên QC thuộc đội kiểm tra Hưng Yên.

#### 39. Establish inspection criteria for each raw material (`C122` / `HY151`)
- **TCode:** `C122` (Hưng Yên: `HY151`) | **Screen Name:** `MaterialQcInspectionItemByMaterial` / `HY_MaterialQcInspectionItem`
- **Stored Procedures:** `usp_MaterialQcInspectionItem_get` / `usp_MaterialQcInspectionItem_iud`
- **Bảng DB chính:** `STB_MaterialQcInspectionItem`
- **Nghiệp vụ chi tiết:** Thiết lập chỉ tiêu tiêu chuẩn Spec kỹ thuật đo kiểm IQC chi tiết cho từng mã nguyên vật liệu.

#### 40. When raw materials arrive, their quality must be checked (`C220` / `HY220`)
- **TCode:** `C220` (Hưng Yên: `HY220`) | **Screen Name:** `MaterialIqcInfoSampleManagement`
- **Stored Procedures:** `usp_MaterialQcInfo_HY_get` (Search) / `usp_DoUpdateMaterialQcInfo_Success_HY` (Execute Pass) / `usp_DoUpdateMaterialQcInfo_Fail_HY` (Execute Fail)
- **Bảng DB chính:** `STB_MaterialQcInfo`, `STB_IQcDefectReport`
- **Nghiệp vụ chi tiết:** Tiến hành đo kiểm chỉ tiêu IQC cho lô NVL vừa nhập kho F330. Phê duyệt kết quả Pass (cho phép đưa vào kho `ROH_HY_WH`) hoặc Fail (chuyển sang kho `HOLDING_HY_WH` và phát hành báo cáo lỗi IQC).

---

### 2.5 Section 4.1 — OQC (Outgoing Quality Control - Kiểm Tra Thành Phẩm Xuất Xưởng)
*Phụ trách:* **Mr. Thực** (Bắt đầu: 10/06/2026 - Hoàn thành: 30/06/2026)

#### 41. Manage inspection items and inspection teams (`C121` OQC)
- **TCode:** `C121` | **Screen Name:** `CommInspSelectGroup`
- **Stored Procedures:** `usp_CommInspSelectGroup_get` / `usp_CommInspSelectGroup_iud`
- **Bảng DB chính:** `STB_CommInspSelectGroup`
- **Nghiệp vụ chi tiết:** Khai báo nhóm chỉ tiêu kiểm tra xuất xưởng OQC và phân công nhân viên OQC phụ trách.

#### 42. Individual product quality control (OQC) items (`HY151` / `C151`)
- **TCode:** `HY151` (Gốc: `C151`) | **Screen Name:** `HY_MaterialQcInspectionItem` / `MaterialQcInspectionItemByFERT`
- **Stored Procedures:** `usp_MaterialQcInspectionItem_ByMaterial_HY_get` / `usp_MaterialQcInspectionItem_iud`
- **Bảng DB chính:** `STB_MaterialQcInspectionItem_HY`
- **Nghiệp vụ chi tiết:** Khai báo danh mục các hạng mục kiểm tra chất lượng OQC áp dụng riêng cho từng mã thành phẩm Tụ Cell/Module Hưng Yên.

#### 43. Lot Manager checks the product (`C512`)
- **TCode:** `C512` | **Screen Name:** `SetListForOqcLotManagement_VVT2`
- **Stored Procedures:** `usp_GetMaterialOQcInfo` / `usp_DoMakeMaterialQcSampleResult`
- **Bảng DB chính:** `STB_MaterialQcInfo`, `STB_SetInfo`
- **Nghiệp vụ chi tiết:** Quản lý danh sách các lô hàng thành phẩm OQC, thực hiện tạo mẫu thử ngẫu nhiên và duyệt quyết định OQC Pass/Fail.

#### 44. Inspect products sample by sample (`HY530` / `C530`)
- **TCode:** `HY530` (Gốc: `C530`) | **Screen Name:** `HY_MaterialOqcInfoSampleManagement` / `MaterialOqcInfoSampleManagement`
- **Stored Procedures:** `usp_GetMaterialOQcInfo` (Search) / `usp_DoUpdateMaterialQcInfo_Success_HY` (Execute)
- **Bảng DB chính:** `STB_MaterialQcInfo`, `STB_DetailAgingHY`
- **Nghiệp vụ chi tiết:** Thực hiện đo kiểm chi tiết từng mẫu OQC (sample by sample).
- **Kiểm soát Gate Time Aging:** SP kiểm tra thời gian lão hóa trong `STB_DetailAgingHY`. Bắt buộc thời gian giữa công đoạn trước và OQC đủ 24 giờ mới cho phép chốt PASS.

#### 45. History of production inspection of OQC lots (`HY541` / `C540`)
- **TCode:** `HY541` (Gốc: `C540`) | **Screen Name:** `HY_ProdInspectionHist` / `VNT_ProdInspectionHist`
- **Stored Procedures:** `usp_VNT_ProdInspectionHist_get`
- **Bảng DB chính:** `STB_CommInspDocHistory`, `STB_ProdRouteHist`
- **Nghiệp vụ chi tiết:** Tra cứu lịch sử báo cáo kiểm tra OQC và đối soát mức tiêu hao NVL thực tế của các lô thành phẩm xuất xưởng.

#### 46. Check the lot numbers for outgoing shipments (`C546`)
- **TCode:** `C546` | **Screen Name:** `FOQC_MaterialOqcInfoSampleManagement`
- **Stored Procedures:** `usp_MaterialQcSampleResult_get` / `usp_Vietnam_MaterialFOQcDetail_get`
- **Bảng DB chính:** `STB_MaterialQcSampleResult`, `Stb_ESRValueMonitor`
- **Nghiệp vụ chi tiết:** Kiểm tra FOQC cuối cùng (Đo thông số điện thế OCV và điện trở ESR) cho lô hàng trước khi xếp xe giao khách hàng.

---

### 2.6 Section 5.1 — PQC (Process Quality Control - Kiểm Tra Công Đoạn)
*Phụ trách:* **Mr. Thực** (Bắt đầu: 10/06/2026 - Hoàn thành: 30/06/2026)

#### 47. Set the test parameters (`HY141` / `C141`)
- **TCode:** `HY141` (Gốc: `C141`) | **Screen Name:** `HY_CommonInspTypeInfo` / `CommInspTypeItemManagement`
- **Stored Procedures:** `usp_CommInspItem_get` / `usp_CommInspItem_iud`
- **Bảng DB chính:** `STB_CommInspItem`, `STB_CommInspTypeInfo`
- **Nghiệp vụ chi tiết:** Khai báo danh mục loại kiểm tra chung và tham số đo kiểm PQC áp dụng trên các công đoạn sản xuất Hưng Yên.

#### 48. Regular inspection by PQC (`HY443` / `C443`)
- **TCode:** `HY443` (Gốc: `C443`) | **Screen Name:** `HY_InspectionPQC` / `Vietnam_inspectionPQC`
- **Stored Procedures:** `usp_GetCommInspection_HistoryForBarcode_Vietnam` / `usp_DoFinishCommInspDoc_VNT`
- **Bảng DB chính:** `STB_CommInspDocHistory`, `STB_CommInspMeasureHist`
- **Nghiệp vụ chi tiết:** Nhân viên PQC tuần tra đo kiểm định kỳ các thông số kỹ thuật (Kích thước, độ dày, ngoại quan) trực tiếp tại trạm sản xuất.

#### 49. Review your test history (`HY431` / `C430`)
- **TCode:** `HY431` (Gốc: `C430`) | **Screen Name:** `RouteInspectionMeasureFullHist_HY` / `VNT_RouteInspectionMeasureFullHist`
- **Stored Procedures:** `usp_RouteInspectionMeasureFullHist_get`
- **Bảng DB chính:** `STB_CommInspMeasureHist`, `STB_RawMaterialInputHist`
- **Nghiệp vụ chi tiết:** Tra cứu toàn bộ lịch sử kết quả đo kiểm chỉ tiêu PQC theo từng Lot Barcode trên các công đoạn.

#### 50. Establish separate inspection criteria for each model (`HY143` / `C143`)
- **TCode:** `HY143` (Gốc: `C143`) | **Screen Name:** `HY_CommInspIndividualSpec` / `CommInspIndividualSpec`
- **Stored Procedures:** `usp_CommInspIndividualSpec_get` / `usp_CommInspIndividualSpec_iud`
- **Bảng DB chính:** `STB_CommInspIndividualSpec`
- **Nghiệp vụ chi tiết:** Khai báo chỉ tiêu kỹ thuật Spec PQC riêng biệt cho từng mã Model sản phẩm (giới hạn Max/Min, Spec chuẩn).

---

### 2.7 Section 6.1 — FinishGood Warehouse (Kho Thành Phẩm Hưng Yên)
*Phụ trách:* **Mr. Tuân** (Bắt đầu: 10/06/2026 - Hoàn thành: 30/06/2026)

#### 51. Hung Yen finished products (`HY01` / `HYFG01`)
- **TCode:** `HY01` / `HYFG01` | **Screen Name:** `HY_FinishGoods`
- **Stored Procedures:** `usp_VN_ShowAllFinishGoodMES_HY` (Search) / `ups_Add_Fg_HY` / `usp_VN_Add_FinishGood_HY_New` (Execute)
- **Bảng DB chính:** `STB_VN_FINISHGOODS_HY`, `STB_VN_FINISHGOODS_HY_NEW`
- **Nghiệp vụ chi tiết:** Quản lý nhập kho thành phẩm `FGT_HY_WH`, vị trí ô kệ kho và tra cứu số lượng tồn kho thành phẩm Hưng Yên.

#### 52. Enter finished goods into inventory (Desktop Application)
- **Module:** Desktop App FG Receipt (`HYFG01` / `C560`)
- **Stored Procedures:** `usp_VN_ShowAllFinishGoodMES_HY` / `usp_VN_Add_FinishGood_HY_New`
- **Bảng DB chính:** `STB_VN_FINISHGOODS_HY`
- **Nghiệp vụ chi tiết:** Thực hiện nhập kho thành phẩm từ sản lượng hoàn thành đóng gói trên ứng dụng Desktop MES.

#### 53. Finished goods dispatched from wh (Desktop Application)
- **Module:** Desktop App FG Stock Out / Dispatch
- **Stored Procedures:** `usp_VN_ShowGoodFinisedExport_HY` / `usp_DoCancelMaterialDoc`
- **Bảng DB chính:** `STB_VN_FINISHGOODS_HY`, `STB_MaterialWarehouseInOutHist`
- **Nghiệp vụ chi tiết:** Lập phiếu xuất kho thành phẩm giao hàng cho khách hàng từ kho `FGT_HY_WH`.

---

### 2.8 Section 7.1 — Electrode Production (Phân Hệ Sản Xuất Điện Cực)
*Phụ trách:* **Mr. Đức** (Bắt đầu: 10/06/2026 - Hoàn thành: 30/06/2026)

#### 54. Create PO Electrode (`B310` / `HY311`)
- **TCode:** `HY311` (Gốc: `B310`) | **Screen Name:** `PO_Electrode_HY` / `ProductionOrderInfo`
- **Stored Procedures:** `usp_ProductionOrderInfo_HY_get` / `usp_ProductionOrderRouting_HY_get`
- **Bảng DB chính:** `STB_ProductionOrderInfo`, `STB_ProductionOrderRouting`
- **Nghiệp vụ chi tiết:** Lập Lệnh sản xuất PO chuyên biệt cho phân hệ Điện cực Hưng Yên (`MaterialType = EROH`).

#### 55. Create Daily Plan Electrode (`B442`)
- **TCode:** `B442` | **Screen Name:** `DayProdPlanElectrode`
- **Stored Procedures:** `usp_DayProdPlan_get` / `usp_DoCreateSetInfoForProdQty_VNT`
- **Bảng DB chính:** `STB_DayProdPlan`, `STB_MaterialMaster`
- **Nghiệp vụ chi tiết:** Lập kế hoạch sản xuất ngày cho công đoạn Điện cực (Mixing $\rightarrow$ Coating $\rightarrow$ Rollpress $\rightarrow$ Slitting). Tự động điền thuộc tính độ dày cuộn cực `SIExtReal03`.

#### 56. Set up the Missing (Mixing) process steps (`B470`)
- **TCode:** `B470` | **Screen Name:** `ElectrodeMixInfo`
- **Stored Procedures:** `usp_ElectrodeMixInfo_HY_get` / `usp_ElectrodeMixStepInfo_HY_iud`
- **Bảng DB chính:** `STB_ElectrodeMixInfo`, `STB_ElectrodeMixStepInfo`
- **Nghiệp vụ chi tiết:** Cấu hình và ghi nhận chi tiết các bước trộn dung dịch điện cực (Mixing), tỷ lệ pha trộn hóa chất và độ nhớt Viscosity.

#### 57. Electrode production results at each stage (`B552`)
- **TCode:** `B552` | **Screen Name:** `SlittingLocationConfig` / `ElectrodeCoating`
- **Stored Procedures:** `usp_ElectrodeCoatingInfo_HY_get`, `usp_ElectrodeRollPressingInfo_HY_get`, `usp_ElectrodeSlittingInfo_HY_get`
- **Bảng DB chính:** `STB_ElectrodeCoatingInfo`, `STB_ElectrodeSlittingResult`, `STB_SlittingLocationConfig_VVT`
- **Nghiệp vụ chi tiết:** Ghi nhận sản lượng điện cực thực tế qua từng công đoạn. Cấu hình vị trí cực Dương (`BY`) và cực Âm (`YP`) khi cắt cuộn Slitting.

#### 58. Report on electrode production results (`B802`)
- **TCode:** `B802` | **Screen Name:** `ElectrodeProdRouteHist`
- **Stored Procedures:** `usp_Vietnam_ElectrodeProdRouteHist_HY_get` / `usp_ElectrodeStep_HY_iud`
- **Bảng DB chính:** `STB_ProdRouteHist`, `STB_ElectrodeStep`
- **Nghiệp vụ chi tiết:** Báo cáo tổng hợp toàn bộ lịch sử tiến độ sản xuất cuộn điện cực qua 4 công đoạn chính tại Hưng Yên.

#### 59. QC workers inspect the incoming electrodes (`C460`)
- **TCode:** `C460` | **Screen Name:** `ElectrodeInspectionHistoryForBarcode`
- **Stored Procedures:** `usp_ElectrodeInspectionHistoryForBarcode_get`
- **Bảng DB chính:** `STB_CommInspDocHistory`
- **Nghiệp vụ chi tiết:** Công nhân QC thực hiện kiểm tra ngoại quan, độ dày và điện trở cuộn cực trước khi chuyển giao sang chuyền cuộn Cell.

---

### 2.9 Section 8.1 — Spare Part Management (Quản Lý Phụ Tùng & Thiết Bị)
(Bắt đầu: 10/06/2026 - Hoàn thành: 30/06/2026)

#### 60. Spare part information (`H130`)
- **TCode:** `H130` | **Screen Name:** `SparePartInfo`
- **Stored Procedures:** `usp_SparePartInfo_get` / `usp_SparePartInfo_iud`
- **Bảng DB chính:** `STB_VNSparePartInfo`
- **Nghiệp vụ chi tiết:** Quản lý danh mục phụ tùng, linh kiện, dao cắt Slitting, gá lắp thiết bị bảo trì.

#### 61. Additional spare part information (`H260`)
- **TCode:** `H260` | **Screen Name:** `ReportSparePartInfo`
- **Stored Procedures:** `usp_ReportSparePartInfo_get` / `usp_VNT_ElectrodeSlittingCutterUsageHist_get`
- **Bảng DB chính:** `STB_VNSparePartInfo`, `STB_VNT_ElectrodeSlittingCutterUsageHist`
- **Nghiệp vụ chi tiết:** Khai báo thông tin bổ sung và theo dõi lịch sử số lượt cắt của dao cắt cuộn cực Slitting.

#### 62. Spare parts manager information (`H190`)
- **TCode:** `H190` | **Screen Name:** `EmployeeDepartment`
- **Stored Procedures:** `usp_EmployeeDepartment_get`
- **Bảng DB chính:** `STB_EmployeeInfo`
- **Nghiệp vụ chi tiết:** Phân công nhân sự bảo trì và phụ trách kho linh kiện phụ tùng.

#### 63. Manage spare parts inventory (`H241`)
- **TCode:** `H241` | **Screen Name:** `VN_InSparePartHistoryManagement`
- **Stored Procedures:** `usp_VNGetInSparePartHistoryManagement` / `usp_VNDoSparePartInHistory_iud`
- **Bảng DB chính:** `STB_VNSparePartInHistory`
- **Nghiệp vụ chi tiết:** Quản lý nhập kho phụ tùng mới mua về và theo dõi số lượng tồn kho phụ tùng.

#### 64. Manage spare part dispatch and replacement history (`H251`)
- **TCode:** `H251` | **Screen Name:** `VNSparePartOutHistoryAndChangeHistoryManagement`
- **Stored Procedures:** `usp_VNGetOutSparePartHistoryManagement` / `usp_VNDoSparePartOutHistory_iud`
- **Bảng DB chính:** `STB_VNSparePartOutHistory`
- **Nghiệp vụ chi tiết:** Quản lý xuất phụ tùng khỏi kho và ghi nhận lịch sử thay thế dao/gá trên máy sản xuất.

#### 65. Detailed report on spare parts import and export (`H270`)
- **TCode:** `H270` | **Screen Name:** `ReportSparePartDetail`
- **Stored Procedures:** `usp_ReportSparePartDetail_get`
- **Bảng DB chính:** `STB_VNSparePartInHistory`, `STB_VNSparePartOutHistory`
- **Nghiệp vụ chi tiết:** Báo cáo chi tiết lịch sử xuất-nhập-tồn và theo dõi vòng đời phụ tùng máy móc toàn nhà máy.

---

## 🎯 3. Ma Trận Tra Cứu Tổng Hợp Theo Nhân Sự Phụ Trách (PIC Matrix)

| Nhân Sự | Phân Hệ Chính | Số Task | Mã Màn Hình / TCode Trọng Tâm | Ghi Chú Vận Hành Cần Lưu Ý |
|:---|:---|:---|:---|:---|
| **Mr. Triều** | General Config & Master Data | 10 Tasks | `B230`, `B220`, `B210`, `B240`, `Z210`, `A130`, `B260`, `Z410`, `B270`, `B250` | Cần đảm bảo `STB_LineInfo.MaterialWarehouseCode = 'ROH_HY_WH'` và phân quyền `Z210` cho User |
| **Mr. Trường** | WMS Raw Materials | 12 Tasks | `A130`, `F140`, `F130`, `HY312`, `HY330`, `HY430`, `FIFO`, `HY620`, `HY740`, `HY721`, `HY761` | Quản lý kho NVL `ROH_HY_WH`, tách tem `HY330`, tách Lot `HY740` và trả NVL `HY620` |
| **Mr. Mạnh** | Cell & Module Production | 15 Tasks | `B310`, `B450`/`K101`, `HY540`, `B530`/`K361`, `B598`, `B597`/`K109`, `B790`, `B682`, `B782`, `K198`, `B723`, `B726`, `PM01`, `K366`, `K781` | Kiểm soát 7 Autocheck Gates tại `B530`, 4 cột thuộc tính sấy tại `HY540`, 3 lớp chặn NVL tại `B597` |
| **Mr. Đức** | IQC & Electrode Production | 9 Tasks | `C121`, `C122`, `C220` (IQC) + `HY311`, `B442`, `B470`, `B552`, `B802`, `C460` (Electrode) | Đã cô lập 24 SPs Electrode `_HY`, khai báo `MaterialType = EROH` tại `A230` cho PO `HY311` |
| **Mr. Thực** | OQC & PQC Quality Control | 10 Tasks | `C121`, `HY151`, `C512`, `HY530`, `HY541`, `C546` (OQC) + `HY141`, `HY443`, `HY431`, `HY143` (PQC) | Kiểm soát Gate Aging 24h `STB_DetailAgingHY` tại `HY530` và đo OCV/ESR tại `C546` |
| **Mr. Tuân** | Finished Goods Warehouse | 3 Tasks | `HY01`/`HYFG01`, `FG Receipt Desktop`, `FG Dispatch Desktop` | Quản lý kho thành phẩm `FGT_HY_WH` qua bảng `STB_VN_FINISHGOODS_HY` |
| **Bảo trì/TB** | Spare Part Management | 6 Tasks | `H130`, `H260`, `H190`, `H241`, `H251`, `H270` | Quản lý vòng đời dao cắt Slitting và thay thế phụ tùng trên chuyền |

---

## 🚨 4. Sổ Tay Kịch Bản Cứu Hộ Lỗi & Rollback Kỹ Thuật Thực Tế (Recent Hotfix Registry)

Danh sách các sự cố vận hành thực tế đã được AI xử lý thành công, tích hợp trực tiếp quy trình SELECT kiểm tra 360° và script ROLLBACK an toàn:

### 4.1 Hủy kết quả sản xuất Lot để gộp Lot & in lại tem (`HY530` / `B530` / `B523` / `HY620`)
- **Màn hình liên quan:** `HY530` / `B530` (Nhập sản xuất) & `B523` / `HY620` (Đóng gói in tem).
- **Triệu chứng:** Lot sản xuất (VD `SP260807-003`, `SP260807-006`) đã lỡ quét chốt kết quả các công đoạn sau (`VE08`, `VE09`, `VE10`), làm công nhân không thể gộp Lot hay in lại tem dán hộp.
- **Nguyên nhân gốc:** Ứng dụng B523 kiểm tra cờ `IsHasNextProd = 1` hoặc bản ghi `STB_ProdRouteHist` đã chốt công đoạn sau ➔ Khóa không cho gộp/sửa Lot.
- **SQL Patch / Rollback Template:**
  ```sql
  BEGIN TRANSACTION;
  -- 1. Tra cứu SELECT kiểm tra vết 360°
  SELECT ControlNo, RouteCode, LineCode, ProdQty, CreateDateTime 
  FROM STB_ProdRouteHist WITH(NOLOCK) 
  WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006');

  -- 2. Xóa phế NG công đoạn sau
  DELETE FROM STB_DefectRepairInfo 
  WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006') 
    AND FindRouteCode IN ('VE08', 'VE09', 'VE10');

  -- 3. Xóa lịch sử routing các công đoạn chốt thừa
  DELETE FROM STB_ProdRouteHist 
  WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006') 
    AND RouteCode IN ('VE08', 'VE09', 'VE10');

  -- 4. Reset cờ CompleteRoute công đoạn cần làm lại về NULL
  UPDATE STB_ProdRouteHist 
  SET CompleteRoute = NULL 
  WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006') 
    AND RouteCode = 'VE07';

  -- 5. Xóa thông tin đóng gói tạm nếu có
  DELETE FROM STB_DividePackaging WHERE LotNo = 'SP260807-006' OR ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006');
  DELETE FROM STB_SavePackingTime_VVT WHERE LotNo = 'SP260807-006';
  COMMIT TRANSACTION; -- Đổi thành ROLLBACK TRANSACTION khi test
  ```

### 4.2 Lỗi không hoàn thành được công đoạn ngoại quan / gập uốn chân `V-27` (`B540` / `B530`)
- **Màn hình liên quan:** `B540` / `HY540` (Quét NVL) & `B530` / `HY530` (Chốt sản lượng `V-27`).
- **Triệu chứng:** Barcode `VVQP263R010701` không thể chốt hoàn thành công đoạn ngoại quan / gập uốn chân `V-27`.
- **Nguyên nhân gốc:** OP chưa nhập đủ 4 cột thuộc tính sấy lò Oven tại `B540` (`STB_RawMaterialInputHist`), khiến autocheck Gate 3 & Gate 4 chặn chốt sản lượng.
- **SQL Patch:**
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_RawMaterialInputHist 
  SET RMIExtText01 = '120C', RMIExtText02 = '4H', RMIExtText03 = 'OVEN_01', RMIExtText04 = 'LOT_OVEN_01'
  WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVQP263R010701');
  COMMIT TRANSACTION;
  ```

### 4.3 Lỗi không chuyển đổi được LotNo tại màn hình `B351`
- **Màn hình liên quan:** `B351` (`DoChangeMaterialForSetInfo`).
- **Triệu chứng:** Người dùng chọn Lot nguồn ở Lưới 1 nhưng Lưới 2 không cho đổi sang Lot đích.
- **Nguyên nhân gốc:** `TargetDayPlanNo` thuộc Kế hoạch ngày chưa được cố định (`IsFixed = 0`) hoặc Lot nguồn đã bị khóa cờ đóng gói (`IsPacking = 1`).
- **SQL Patch:**
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_DayProdPlan SET IsFixed = 1 WHERE DayProdPlanNo = 'MÃ_KH_ĐÍCH';
  UPDATE STB_SetInfo SET IsPacking = 0 WHERE Barcode = 'MÃ_LOT_NGUỒN';
  COMMIT TRANSACTION;
  ```

### 4.4 Lỗi nút "Nhập lỗi" bị ẩn/mờ (Disabled) trên `B530` / `HY530`
- **Màn hình liên quan:** `B530` / `HY530` (Nhập sản xuất).
- **Triệu chứng:** Nút **"Nhập lỗi"** (`AddDefect`) bị mờ không bấm được khi muốn báo phế NG cho Barcode `VE260710-002` tại công đoạn `VE08`.
- **Nguyên nhân gốc:** Expression UI: `!IsHasNextProd && !IsLoss`. Do công đoạn sau (`VE09`) đã được quét, `IsHasNextProd = 1` ➔ Nút bị mờ.
- **SQL Patch:** Rollback công đoạn sau (`VE09`) theo mẫu 4.1 để mở lại nút.

---

*Tài liệu được cập nhật ngày 08/08/2026 — Đã đối soát 100% với CSDL SmartFactoryV2, SmartFramework, 24 KB Files và Lịch sử Nhật ký Sự cố thực tế (HOTFIX_LOG).*

