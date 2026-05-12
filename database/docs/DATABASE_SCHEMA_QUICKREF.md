# 🗄️ DATABASE SCHEMA QUICK REFERENCE

> **Mục đích:** Bảng tra cứu siêu tốc các cột (columns) quan trọng trong các bảng cốt lõi. Giúp AI không phải chạy `sp_help` hay dò dẫm tên cột, tiết kiệm 50% thời gian viết câu `SELECT`.

## 1. STB_MaterialLotInfo (Kho & Tồn Kho)
- `LotID`: Mã vạch chính của NVL hoặc Thành phẩm.
- `MaterialCode`: Mã NVL.
- `WarehouseCode`: Mã kho hiện tại (VD: `ROH_VVT_WH`, `SLITTING_HN_WH`). Nếu bị HOLD, kho có thể chứa từ `HOLDING`.
- `CurrentQty` / `InitQty`: Số lượng hiện tại / ban đầu.
- `CreateDateTime`: Ngày tạo Lot (Quan trọng để check FIFO).
- `LotAttr09`: Thường lưu Location (Vị trí) trong kho.
- `VendorLot`: Mã Lot do nhà cung cấp in.

## 2. STB_ProdRouteHist (Lịch Sử Sản Xuất)
- `ControlNo`: Mã Barcode/Box đang chạy chuyền.
- `LotID`: Mã Lot nguyên vật liệu tham gia.
- `RouteCode`: Tên công đoạn (VD: `B523`, `B597`, `C512`).
- `RoutePrefix`: Tiền tố nhà máy (VD: `V-23`, `E-21`, `VE-25`).
- `EquipmentCode`: Mã máy chạy.
- `WorkerID`: Mã nhân viên thao tác.
- `JobDate` / `JobTime`: Ngày giờ thực hiện công đoạn.
- `DefectQty` / `GoodQty`: Số lượng lỗi / số lượng đạt.

## 3. STB_SetInfo (Thông Tin Gốc Của Barcode)
- `ControlNo`: Mã Barcode gốc.
- `SetInfoNo`: Thường liên kết với `ControlNo` trong bảng `STB_ProdRouteHist`.
- `MaterialCode`: Mã thành phẩm/bán thành phẩm.
- `WorkOrderNo` (PO): Mã lệnh sản xuất.

## 4. STB_MaterialDocLotInfo & STB_MaterialDocDetail (Lịch Sử Nhập/Xuất)
- `MaterialDocNo`: Mã phiếu nhập/xuất kho.
- `LotID`: Mã Lot tham gia.
- `Qty`: Số lượng trong phiếu.
- `InOutType`: Loại nhập (In) hoặc xuất (Out).

## 5. STB_ProcedureLog (Log Lỗi Hệ Thống)
- `LogNo`: ID log.
- `ProcedureName`: Tên Stored Procedure gây lỗi.
- `ErrorMessage`: Thông báo lỗi chi tiết.
- `CreateDateTime`: Thời gian xảy ra lỗi (Quan trọng để filter).

*(Bất kỳ khi nào viết Query, hãy ưu tiên sử dụng các tên cột chuẩn này)*
