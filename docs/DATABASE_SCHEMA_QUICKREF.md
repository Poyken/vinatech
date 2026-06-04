# 🗄️ DATABASE SCHEMA QUICK REFERENCE

> **Mục đích:** Bảng tra cứu siêu tốc các cột (columns) quan trọng trong các bảng cốt lõi. Giúp AI không phải chạy `sp_help` hay dò dẫm tên cột, tiết kiệm 50% thời gian viết câu `SELECT`.

## 1. STB_MaterialLotInfo (Kho & Tồn Kho)
- `LotID`: Mã vạch chính của NVL (prefix `ML...`).
- `LotNo`: Mã Lot thành phẩm (dùng khi join với STB_SetInfo.Barcode).
- `MaterialLotNo`: PK của bảng (dùng trong WHERE khi UPDATE).
- `MaterialCode`: Mã NVL.
- `MaterialWarehouseCode`: Mã kho hiện tại (VD: `ROH_VN_WH`, `ROH_HN_WH`). ⚠️ KHÔNG PHẢI `WarehouseCode`.
- `MaterialLocationCode`: Vị trí trong kho.
- `CurrentQty` / `InitialQty`: Số lượng hiện tại / ban đầu. ⚠️ KHÔNG PHẢI `InitQty`.
- `PackingID`: Mã thùng đã gộp vào (NULL = chưa gộp).
- `CreateDateTime`: Ngày tạo Lot (Quan trọng để check FIFO).
- `LotAttr09`: Thường lưu Location thủ công (do user nhập).
- `VendorLotNo`: Mã Lot do nhà cung cấp in. ⚠️ KHÔNG PHẢI `VendorLot`.

## 2. STB_ProdRouteHist (Lịch Sử Sản Xuất)
- `ProdRouteHistNo`: PK của bảng.
- `ControlNo`: Mã Barcode/Lot đang chạy chuyền (join với STB_SetInfo.ControlNo).
- `RouteCode`: Mã công đoạn (VD: `V-22_BG`, `V-23`, `VE-22`).
- `LineCode`: Mã Line sản xuất.
- `MachineCode`: Mã máy chạy. ⚠️ KHÔNG PHẢI `EquipmentCode`.
- `WorkerCode`: Mã nhân viên. ⚠️ KHÔNG PHẢI `WorkerID`.
- `JobDate`: Ngày thực hiện (kiểu DATE, format YYYY-MM-DD).
- `ProdDateTime`: Timestamp đầy đủ khi quét công đoạn.
- `ProdQty`: Số lượng sản xuất tại công đoạn. ⚠️ KHÔNG PHẢI `GoodQty`.
- `PONo`, `DayPlanNo`, `MaterialCode`, `BomVersion`, `ShiftCode`.

⚠️ Các cột KHÔNG TỒN TẠI trong bảng này: `LotID`, `RoutePrefix`, `EquipmentCode`, `WorkerID`, `GoodQty`, `DefectQty`.

## 3. STB_SetInfo (Thông Tin Gốc Của Barcode)
- `ControlNo`: PK. Mã nội bộ duy nhất cho mỗi Barcode (join với STB_ProdRouteHist).
- `Barcode`: Mã tem in ra thực tế (VD: `VVPO273R010713`).
- `MaterialCode`: Mã thành phẩm/bán thành phẩm.
- `PONo`: Mã lệnh sản xuất. ⚠️ KHÔNG PHẢI `WorkOrderNo`.
- `DayPlanNo`: Mã kế hoạch ngày.
- `InputLineCode`: Line sản xuất.
- `ProdQty`: Số lượng sản xuất.
- `InputJobDate`: Ngày bắt đầu sản xuất.
- `LotDecisionResult`: Kết quả QC (`PASS`/`FAIL`/NULL).
- `IsDefect` (bit), `DefectQty` (int): Có hàng lỗi không.
- `IsProdFinish` (bit): Đã hoàn thành sản xuất chưa.

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

## 6. STB_VVT_StagePrices (Bảng Giá Công Đoạn)
- `model`: Mã model sản phẩm.
- `WorkCenterCode`: Phân biệt nhà máy (`VVT_F1`, `VVT_F2`, `VVT_F3`, `VVT_F4`).
- `RouteV22` -> `RouteV34`: Mã công đoạn (V22..V34).
- `PriceV22` -> `PriceV34`: Đơn giá tương ứng.
- `RouteVE01` -> `RouteVE10`: Công đoạn Hà Nam (VE).
- `PriceVE01` -> `PriceVE10`: Đơn giá tương ứng Hà Nam.

## 7. stb_slittinglocationconfig_vvt (Cấu hình Slitting)
- `PartNo`: Mã model rút gọn (VD: `1025`).
- `SlittingCode`: `BY` (Cực dương) hoặc `YP` (Cực âm).
- `SlittingSize`: Kích thước (VD: `200`).
- `Width`: Chiều rộng cắt (Width).
- `WarehouseLocation`: Vị trí kho (VD: `VVT_F2`).
- `PositiveLocation` / `NegativeLocation`: Vị trí khay đựng cụ thể.

*(Bất kỳ khi nào viết Query, hãy ưu tiên sử dụng các tên cột chuẩn này)*

> ⚠️ **Verified against DB: 2026-05-17** — Tất cả tên cột đã được kiểm chứng bằng `INFORMATION_SCHEMA.COLUMNS` trực tiếp từ `SmartFactoryV2`.
