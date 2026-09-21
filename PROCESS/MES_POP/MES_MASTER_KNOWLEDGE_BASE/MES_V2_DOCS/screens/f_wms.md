# 📦 F-Series: Warehouse Management (WMS)

| Screen | Tên / Chức Năng | Search SP (`_get`) | Execute SP (`_iud`) | Bảng DB Chính | Ghi Chú & Bẫy Vận Hành |
|---|---|---|---|---|---|
| **F110** | Thuộc tính quản lý tồn kho | `usp_MaterialStockAttributeInfo_get` | `usp_MaterialStockAttributeInfo_iud` | `STB_MaterialStockAttributeInfo` | Tick chọn `IsLotUse` và `IsUseBarcode` để cho phép B523 gộp box |
| **F312** | Tạo PO và sửa SL kho | `usp_MaterialDocInfo_get` | `usp_MaterialDocInfo_iud` | `STB_MaterialDocInfo` | Tạo phiếu nhập kho và đối chiếu nhà cung cấp |
| **F330** | Nhập kho NVL & In tem | `usp_MaterialDeliveryList_get` | `usp_DoCreateMaterialDoc` | `STB_MaterialLotInfo`, `STB_MaterialDocDetail` | Bấm "Tạo tem" để sinh `STB_MaterialDocLotInfo` |
| **F430** | Xuất kho ra chuyền | `usp_MaterialIssueList_get` | `usp_DoProcessMaterialIssue` | `STB_MaterialStock` | Kiểm soát nguyên tắc xuất hàng FIFO |
| **F721** | Kiểm tra tồn kho thực | `usp_vvt_MaterialLotInfo_get` | — | `STB_MaterialLotInfo` | Tra cứu chi tiết vị trí và hạn sử dụng từng Lot |
| **F750** | Kiểm kê kho định kỳ | `usp_StockTaking_get` | `usp_StockTaking_iud` | `STB_StockTaking` | Điều chỉnh tồn kho thực tế và chênh lệch |
