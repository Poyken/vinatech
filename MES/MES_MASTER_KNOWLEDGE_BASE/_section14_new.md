
## 14. 📊 Bảng Tổng Hợp Màn Hình MES (Mở Rộng - Quick Reference)

> Tổng hợp từ hình ảnh flowchart + bảng danh sách Screen ID chính thức. Nhóm theo chức năng nghiệp vụ.

### 14.1 Đăng Ký Thông Tin Cơ Bản (Master Data)

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **A210** | Loại vật liệu (FERT/HALB/MDL/ROH...) | `STB_MaterialTypeInfo` |
| **A230** | Thông tin NVL Master | `STB_MaterialMaster` |
| **A310** | Thiết lập BOM / Cấu trúc sản phẩm | `STB_BomHeader`, `STB_BomDetail` |
| **A320** | Thiết lập Route sản xuất | `STB_RouteInfo` |
| **A410** | Model Basic Info + OQC config | `STB_ModelBasicInfo` |
| **A418** | Số lượng đóng gói theo Size | `STB_PackingStandard` |
| **A419** | Tiêu chuẩn đóng gói | `STB_PackingStandard` |
| **A460** | Thiết lập mẫu nhãn in | `STB_LabelInfo` (SmartFramework) |

### 14.2 Đăng Ký Máy Móc, Line & Route

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **B210** | Đăng ký Line | `STB_LineInfo` |
| **B220** | Đăng ký Route | `STB_RouteInfo` |
| **B230** | Phân quyền Route vào Line | `STB_LineRouteMapping` |
| **B240** | Đăng ký Máy | `STB_MachineInfo` |
| **B250** | Phân bổ Máy vào công đoạn | `STB_MachineMaster` |
| **B260** | Nhân viên SX (WorkerGroupCode='VE-01') | `STB_WorkerInfo` |
| **B270** | Kiểm tra phân bổ máy-route | `STB_ProductMachine` |

### 14.3 Quản Lý Kế Hoạch Sản Xuất

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **B310** | Tạo PO kế hoạch tháng | `STB_ProductionOrderInfo` |
| **B450** | Kế hoạch SX ngày + Tạo Lot | `STB_DayProdPlan` |
| **B452** | Đổi Line sai | `STB_DayProdPlan` |

### 14.4 Sản Xuất (Cell Line)

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **B530** | Nhập sản lượng công đoạn | `STB_ProdRouteHist` |
| **B540** | Assy Card Info | `STB_SetInfo` |
| **B552** | Electrode Measure Result | `STB_ElectrodeSlittingResult` |
| **B597** | Kiểm tra thường xuyên + scan NVL | `STB_CommInspDocHistory`, `STB_RawMaterialInputHist` |

### 14.5 Đóng Gói & Đóng Thùng Xuất Hàng

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **B351** | Chuyển đổi Lot/Material | `STB_SetInfo` |
| **B453** | In tem INNER/OUTER | `STB_DividePackaging` |
| **B523** | Gộp Box Cell + Chia Box (quy trình mới) | `STB_DividePackaging`, `STB_MaterialLotInfo` |
| **B525** | Gộp Box Module | `STB_DividePackaging` |
| **B528** | Barrel Barcode (Gộp thùng xuất hàng) | `STB_DividePackaging` |
| **B717** | Bending & Tapping (chỉ lưu 1 lần) | `STB_ProdRouteHist` |

### 14.6 Báo Cáo / Lịch Sử Sản Xuất

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **B598** | Báo phế NVL | `STB_VN_SCRAP_AFTERPRODUCTIONS` |
| **B781** | Lịch sử đóng gói / Packing History | `STB_SavePackingTime_VVT` |
| **B782** | Kiểm tra sản lượng theo công đoạn | `STB_ProdRouteHist` |
| **B789** | Lịch sử đóng gói Module | `STB_SavePackingTime_VVT` |
| **B802** | Lịch sử SX điện cực + giá thành | `STB_ElectrodeCoatingInfo` |
| **B882** | ANDON | - |
| **B934/B935** | Import/Xem dữ liệu máy phân cấp bigsize | - |

### 14.7 In Tem Đặc Biệt

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **B754-B756** | In tem PAC (Inner/Outer/Carton) | `STB_LabelInfo` |
| **B757-B758** | In tem Digi-Key (SP + Logistic) | `STB_LabelInfo` |

### 14.8 Kho NVL (WMS)

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **F110** | Nhập/Xuất kho thành phẩm | `STB_MaterialStockAttributeInfo` |
| **F130** | Chỉ định NCC <-> NVL | `STB_MaterialSupplierMapping` |
| **F140** | Chỉ định NVL theo NCC | `STB_MaterialSupplierMapping` |
| **F312** | Ghi chú NVL (Invoice / PO chi tiết) | `STB_MaterialDocDetail` |
| **F330** | Nhập kho + in tem NVL | `STB_MaterialDocInfo`, `STB_MaterialDocLotInfo`, `STB_MaterialLotInfo` |
| **F430** | Lịch sử xuất/nhập kho | `STB_MaterialWarehouseInOutHist` |
| **F721** | Tồn kho NVL | `STB_MaterialLotInfo` |
| **F741** | Tách Lot theo số lượng mong muốn | `STB_MaterialLotInfo` |
| **F743-F748** | Slitting LOT Material Hà Nam | `stb_slittinglocationconfig_vvt` |

### 14.9 QC - IQC (Kiểm Tra Đầu Vào)

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **C121** | Nhóm hạng mục kiểm tra IQC | `STB_InspectionGroupInfo` |
| **C122** | Hạng mục kiểm tra IQC chi tiết | `STB_InspectionItemInfo` |
| **C220** | Kiểm tra NVL đầu vào (IQC) | `STB_MaterialQcInfo` |

### 14.10 QC - PQC (Kiểm Tra Trong Quá Trình SX)

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **C131** | Đăng ký thông tin nhóm lần PQC | `STB_InspectionGroupInfo` |
| **C132** | Cấu hình lần PQC chi tiết | `STB_InspectionItemInfo` |
| **C141** | Thiết lập thông số kiểm tra PQC chung | `STB_CommInspDocHistory` |
| **C143** | Thiết lập spec PQC riêng theo model | `STB_CommInspDocHistory` |
| **C243** | Kiểm tra Lot Slitting | - |
| **C321** | Thông tin phế công đoạn trên cell line / PQC Reliability | - |
| **C430** | Lịch sử kiểm tra công đoạn mỗi cell line | `STB_CommInspDocHistory` |
| **C443** | Kiểm tra PQC công đoạn ngoài line | `STB_CommInspDocHistory` |

### 14.11 QC - OQC (Kiểm Tra Đầu Ra)

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **C451** | Tạo Lot kiểm tra OQC | - |
| **C510/C512** | Quản lý Lot OQC + Tìm kiếm | `STB_ModelBasicInfo` |
| **C530** | Nhập kết quả kiểm tra OQC mẫu | - |
| **C540** | Lịch sử kiểm tra OQC | - |
| **C546/C541** | Kiểm tra ESR xuất kho | - |
| **C560** | Mẫu kiểm tra OQC | - |
| **C561-C564** | Bending/Cutting QC | - |

### 14.12 Kho Thành Phẩm

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **FG00/FG01/FG02** | Tổng hợp TP Bắc Ninh + Bắc Giang | - |
| **HN551** | Xuất hàng Hà Nam | `STB_VN_FINISHGOODS_HN_New` |
| **HN866** | Tồn kho thành phẩm Hà Nam | `STB_VN_FINISHGOODS_HN_New` |
| **HNC321** | Nhập phế Hà Nam | - |
| **HN00/HN101** | Thành phẩm + Đơn giá Hà Nam | - |

### 14.13 Hỗ Trợ & Khác

| Màn hình | Mô tả | Bảng DB chính |
|----------|-------|---------------|
| **H301-H305** | Spare Part | `STB_VNSparePartInfo` |
| **K101** | Kế hoạch SX ngày nhà máy BG2 | `STB_DayProdPlan` |
| **K109** | Kiểm tra thường xuyên BG2 | `STB_CommInspDocHistory` |
| **Z220** | Phân nhóm quyền User | `STB_UserGroupInfo` (SmartFramework) |
| **Z330** | Publish màn hình ra production | `STB_ScreenInfo` (SmartFramework) |
| **Z410** | Quản lý tài khoản User | `STB_UserInfo` (SmartFramework) |

*Cập nhật: 2026-05-30 - Mở rộng từ 77 lên ~90 màn hình, tổ chức theo nhóm chức năng, bổ sung C131/C132/C430/C451/C560/F741/A320/A419*
