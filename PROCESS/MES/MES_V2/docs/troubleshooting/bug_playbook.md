# 🛠️ MES_V2 — Bug Fix Playbook (70+ Kịch Bản Cứu Hộ Toàn Diện)

> **Mục đích:** Sổ tay cứu hộ 70+ bugs theo TCode thực tế (Tra cứu triệu chứng $\rightarrow$ nguyên nhân $\rightarrow$ giải pháp SQL patch).  
> **CSDL:** `SmartFactoryV2` + `SmartFramework` trên `dbserver.hycap.co.kr,5398`

---

## 📑 Mục Lục Nhanh Theo Nhóm Màn Hình

| Prefix | Phân Hệ & Màn Hình | Số Bug Phủ Kín |
|:---:|---|:---:|
| **A** | [A230, A310, A410, A418, A419, A460, A510](#a-series-master-data--cấu-hình) | 6+ |
| **B** | [B210-B270, B310, B351, B442, B450, B452, B523, B528, B530, B540, B552, B560, B597, B598, B618, B682, B767, B802, W788](#b-series-sản-xuất-cell--module-line) | 28+ |
| **C** | [C121-C122, C220, C243, C321, C443, C451, C486, C512, C530, C546, C560, C585](#c-series-kiểm-soát-chất-lượng-qc) | 16+ |
| **D** | [D100, D110 — VinaEnesol Hưng Yên](#d-series-enesol--hưng-yên) | 3+ |
| **F** | [F330, F430, F721, F742-F748 — Quản Lý Kho & Slitting](#f-series-kho-wms--vật-tư) | 8+ |
| **HN** | [HN523, HN542, HN544, HN551, HN555, HNC321 — Nhà Máy Hà Nam](#hn-series-nhà-máy-hà-nam-vvt_f3) | 6+ |
| **K** | [K101, K109, K110, K198, K361, K366 — Bắc Giang 2 Module Line](#k-series-bắc-giang-2-module-line) | 6+ |
| **Z** | [Z410, Z530 — Quản Trị Hệ Thống SmartFramework](#z-series-hệ-thống--phân-quyền) | 4+ |

---

## 🅰️ A-Series: Master Data & Cấu Hình

### [A230] — Thông tin vật liệu (Material Master)
* **Bug 1: Model mới không hiện Vol/Farad trên chuyền:** Chưa khai báo A230 hoặc thiếu cấu hình Vol/Farad.
  ```sql
  SELECT ModelCode, Voltage, Farad, MBIExtText01, MBIExtText02 FROM STB_ModelBasicInfo WITH(NOLOCK) WHERE ModelCode = 'MÃ_MODEL';
  ```
* **Bug 2: Cột "Độ dày" bị trống trên B442:** Chưa set `MaterialThickness` tại A230 tab "Mã nguyên liệu".
  ```sql
  UPDATE STB_MaterialMaster SET MaterialThickness = '120' WHERE MaterialCode = 'MÃ_NVL';
  ```

### [A310] — Cấu hình Route & BOM
* **Bug 1: OP không thấy công đoạn mới trong danh sách Route:** Chưa tạo Route tại A310 hoặc chưa map vào PO. Vào A310 $\rightarrow$ Thêm `RouteCode` $\rightarrow$ Map vào Line tại B210.

### [A410] — Cấu hình Model Basic Info
* **Bug 1: C512 không tìm thấy Lot OQC:** Chưa config `OqcType`, `InspectionLevel` tại A410.
  ```sql
  UPDATE STB_ModelBasicInfo 
  SET OqcType = 'MANUAL', OqcInspectionRuleType = 'BY_MODEL', InspectionType = 'SAMPLE', InspectionLevel = 'SAMPLE' 
  WHERE ModelCode = 'MÃ_MODEL';
  ```

### [A418] / [A419] — Tiêu chuẩn đóng gói (Packing Standard)
* **Bug 1: B523 báo "Chưa có tiêu chuẩn đóng gói":** Chưa khai báo số lượng đóng gói cho Size/Model mới.
  ```sql
  INSERT INTO STB_PackingStandard (ModelCode, MBISizeH, MBISizeW, InBoxQty, OutBoxQty, CreateDateTime)
  VALUES ('MÃ_MODEL', 30, 10, 200, 1000, GETDATE());
  ```

### [A460] — Cấu hình In Tem (Model Label Info)
* **Bug 1: In tem bị lỗi "Not found label type":** Chưa có record trong `STB_ModelLabelInfo` cho model. Copy từ model cũ cùng loại:
  ```sql
  INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime)
  SELECT 'MODEL_MỚI', LabelType, FormatName, GETDATE() 
  FROM STB_ModelLabelInfo WHERE ModelCode = 'MODEL_CŨ';
  ```

---

## 🅱️ B-Series: Sản Xuất Cell & Module Line

### [B310] — Quản lý Lệnh sản xuất (PO Master)
* **Bug 1: ProdFinishQty lệch so với thực tế:** Crash giữa SP `usp_DoProcessProdRouteHist` khiến dữ liệu cập nhật dở dang.
  ```sql
  UPDATE STB_ProductionOrderInfo 
  SET ProdFinishQty = (SELECT ISNULL(SUM(ProdQty),0) FROM STB_ProdRouteHist WITH(NOLOCK) WHERE PONo = 'MÃ_PO' AND RouteCode = 'V-28') 
  WHERE PONo = 'MÃ_PO';
  ```

### [B351] — Chuyển đổi Lot (Lot Transition)
* **Bug 1: Barcode sinh ra bị chèn dấu chấm (`.`):** Sửa đồng loạt Barcode trong `STB_RawMaterialInputHist`, `STB_SetInfo`, `STB_LotChangeMaterialHistory`.
* **Bug 2: Yêu cầu in lại tem gốc (mã cũ) sau khi đã đổi Lot tại B351:** Chạy script rollback đồng bộ 4 bảng:
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_SetInfo SET Barcode = '@OldBarcode', MaterialCode = '@OldMat' WHERE ControlNo = '@ControlNo';
  UPDATE STB_MaterialLotInfo SET MaterialCode = '@OldMat', LotNo = '@OldBarcode', MaterialLotNo = '@OldBarcode' WHERE LotNo = '@NewBarcode';
  UPDATE STB_ProdRouteHist SET MaterialCode = '@OldMat' WHERE ControlNo = '@ControlNo';
  DELETE FROM STB_LotChangeMaterialHistory WHERE CPHNo = '@CPHNo';
  COMMIT TRANSACTION;
  ```
* **Bug 3: Bấm "Thay đổi model" báo lỗi popup red X "No data to process":** Lưới 2 cần chọn Target Plan ở Lưới 1 để gán `TargetDayPlanNo` và `TargetMaterialCode`.

### [B450] — Kế hoạch ngày (Tạo Lot)
* **Bug 1: Không tạo được Lot:** Cột `IsFixed` chưa được tích chọn trước khi bấm "Tạo Lot". SP `usp_DoFixDayProdPlan` chặn sinh serial nếu chưa chốt kế hoạch ngày.

### [B523] — Đóng gói Cell & In tem (Packaging Master)
* **Bug 1: Gộp box báo lỗi "IsOutputRoute chưa thiết lập":** PO Routing thiếu cờ `IsOutputRoute=1` ở công đoạn cuối.
  ```sql
  UPDATE STB_ProductionOrderRouting SET IsOutputRoute = 1 WHERE PONo = 'MÃ_PO' AND RouteCode = 'V-28';
  ```
* **Bug 2: Popup đỏ "Could not find Kho Thành phẩm chưa nhập cân nặng cho Lót hàng này!":** Mã Lot mới chưa nạp cân vào `STB_VIETNAM_BARCODEWEIGHT` và `STB_VN_FINISHGOODS`.
  ```sql
  BEGIN TRANSACTION;
  INSERT INTO STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, CREATEDATETIME) VALUES ('MÃ_BARCODE', 25.5, GETDATE());
  INSERT INTO STB_VN_FINISHGOODS (IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo, CreatDatePacked, PartNo, CreateDate)
  VALUES ('FGVN_BN' + CONVERT(VARCHAR(8), GETDATE(), 112), 'MÃ_PACKING', 'MÃ_BARCODE', 'MÃ_VẬT_TƯ', 'TÊN_VẬT_TƯ', 2800, 'vvtworker', CONVERT(VARCHAR(10), GETDATE(), 110), 'PART_NO', GETDATE());
  UPDATE STB_PackingLabelPrintHist SET IsPrintAllow = 1, PrintCount = 0 WHERE PackingID = 'MÃ_PACKING';
  COMMIT TRANSACTION;
  ```

### [B530] — Chốt sản lượng sản xuất (Core Route Input)
* **Bug 1: Gate 20 phút không hoạt động:** Sửa lỗi `@SIExtInt01 = Null` $\rightarrow$ `IS NULL` trong SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`.
* **Bug 2: Lỗi "Công đoạn này không có trong Routing hoặc là công đoạn cuối cùng":** Công đoạn liền trước bị set `CompleteRoute = 1` trong khi công đoạn liền sau có bản ghi dở dang.
  ```sql
  BEGIN TRANSACTION;
  DELETE FROM STB_ProdRouteHist WHERE ControlNo = 'MÃ_CONTROL' AND CompleteRoute IS NULL AND RouteCode IN ('CÔNG_ĐOẠN_SAU');
  UPDATE STB_ProdRouteHist SET CompleteRoute = NULL WHERE ControlNo = 'MÃ_CONTROL' AND RouteCode = 'CÔNG_ĐOẠN_TRƯỚC';
  COMMIT TRANSACTION;
  ```
* **Bug 3: Nút "Nhập lỗi" (AddDefect) bị mờ/disabled:** Biểu thức Expression `!IsHasNextProd && !IsLoss`. Do công đoạn sau đã có dữ liệu. Rollback công đoạn sau và reset `CompleteRoute = NULL` ở công đoạn trước.

### [B597] — Scan NVL Đầu Vào Chuyền
* **Bug 1: Cảnh báo đỏ HOLD — "Lot chưa QC":** Lot nằm kho `HOLDING_WH`. Cập nhật về `ROH_WH`:
  ```sql
  UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode = 'ROH_WH' WHERE LotID = 'MÃ_LOT';
  ```
* **Bug 2: "String or binary data would be truncated":** Cột `RawMaterialBarcode` trong `STB_InputMaterialHistory` bị hẹp:
  ```sql
  ALTER TABLE STB_InputMaterialHistory ALTER COLUMN RawMaterialBarcode NVARCHAR(1000);
  ```
* **Bug 3: Vỏ nhôm mới báo sai chủng loại:** Logic vỏ nhôm bị hardcode trong `usp_Vietnam_RawMaterialInputHist_uid`. Cần ALTER SP thêm mã mới vào danh sách `IF / NOT IN`.

### [B767] — In tem Sanmina
* **Bug 1: Tìm kiếm lần 2 bị lặp dữ liệu (6 dòng thay vì 3 dòng):** Mở NAIS Designer B767 $\rightarrow$ Chọn Search Function `usp_SanminaLabelPrint_get_Vietnam` $\rightarrow$ Chuyển `데이터 추가` (`Append Data`) từ `True` sang `False`. Save layout và Approve.
* **Bug 2: S/N của tem Outer bị trống:** Sửa SP gộp `Inner1Serial` và `Inner2Serial` phân cách bằng dấu phẩy cho `BoxSerialNo` của Outer label.

---

## 🆂 C-Series: Kiểm Soát Chất Lượng (QC)

### [C220] — IQC Incoming Quality Control
* **Bug 1: Hàng mới nhập ở F330 không hiện trên C220:** Thủ kho mới bấm Arrival nhưng chưa bấm nút "Tạo tem" tại F330 (bảng `STB_MaterialDocLotInfo` chưa có dòng). Cần mở lại F330 bấm "Tạo tem".

### [C443] — PQC Verification
* **Bug 1: Hủy kết quả kiểm tra QC nhập nhầm:**
  ```sql
  BEGIN TRANSACTION;
  DECLARE @DocNo NVARCHAR(50) = (SELECT TOP 1 CIDH.CommInspDocNo FROM STB_CommInspDocHistory CIDH JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo WHERE SI.Barcode = 'MÃ_BARCODE');
  DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = @DocNo;
  DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = @DocNo;
  COMMIT TRANSACTION;
  ```

### [C530] — OQC Audit
* **Bug 1: Nút Pass bị disable sau khi bấm Reject:** OQC Pass/Fail được xử lý qua SP (không có cột `CommInspResult` trong DB). Cách fix: Gọi `usp_DoDeleteMaterialQcInfo` $\rightarrow$ Tạo lại OQC tại C512 $\rightarrow$ Đánh giá lại kết quả.

### [C546] — FOQC OCV / ESR
* **Bug 1: OCV chỉ hiện 20 dòng thay vì 50 dòng:** SP `usp_Vietnam_MaterialFOQcDetail_get` thiếu block WHILE cho `DetailNo = 2` (OCV). Bổ sung vòng lặp WHILE 50ea trong SP.

---

## 📦 F-Series: Kho WMS & Vật Tư

### [F330] — Nhập kho NVL
* **Bug 1: Hủy phiếu nhập kho đã Confirmed:** Xóa theo thứ tự ngược:
  ```sql
  BEGIN TRANSACTION;
  DELETE FROM STB_MaterialLotInfo WHERE LotID IN (SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'MÃ_PHIẾU');
  DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'MÃ_PHIẾU';
  DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = 'MÃ_PHIẾU';
  DELETE FROM STB_MaterialDocInfo WHERE MaterialDocNo = 'MÃ_PHIẾU';
  COMMIT TRANSACTION;
  ```

### [F430] — Xuất kho & Chuyển kho
* **Bug 1: Chặn xuất hàng do vi phạm FIFO:** Bypass bằng cách cập nhật:
  ```sql
  UPDATE STB_MaterialStockAttributeInfo SET IsFIFO = 0 WHERE MaterialCode = 'MÃ_NVL';
  ```
* **Bug 2: Xuất chuyển kho sang Hưng Yên không hiện mã kho tới:** Sửa SP `usp_TargetMaterialWarehouse_popup` dùng `UNION` (không dùng `UNION ALL`), thêm chuyền `HY_BN`/`HY_BG` vào `STB_LineInfo`.

### [F742] / [F744] — Slitting Điện Cực
* **Bug 1: Cuộn nguyên liệu Lot cha không hiện trên danh sách "Chờ cắt" tại F742:** Do cờ `IsSlitting = 1` và `CurrentQty = 0`. Reset lại:
  ```sql
  UPDATE STB_MaterialLotInfo SET IsSlitting = 0, CurrentQty = @SoMetCanCat WHERE LotID = 'MÃ_LOT_CHA';
  ```

---

## 🏛️ HN-Series: Nhà Máy Hà Nam (VVT_F3)

### [HN544] — Gộp túi bóng thành hộp nhỏ
* **Bug 1: Hủy gộp box / Rã box túi bóng ở HN544:**
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_MaterialLotInfo SET PackingID = NULL WHERE PackingID = 'MÃ_PACKING';
  DELETE FROM STB_DividePackaging WHERE PackingID = 'MÃ_PACKING';
  COMMIT TRANSACTION;
  ```

### [HN523] — Hủy tem đóng gói & Giảm sản lượng VE10
* **Bug 1: Hủy tem đóng gói đã chốt:**
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_MaterialLotInfo SET PackingID = '' WHERE PackingID = 'MÃ_PACKING';
  DELETE FROM STB_SavePackingTime_VVT WHERE PackingID = 'MÃ_PACKING';
  SET CONTEXT_INFO 0x999997;
  DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'MÃ_PHIẾU_XUẤT';
  SET CONTEXT_INFO 0;
  DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = 'MÃ_PHIẾU_XUẤT';
  UPDATE STB_ProdRouteHist SET ProdQty = ProdQty - @Qty WHERE ControlNo = 'MÃ_CONTROL' AND RouteCode = 'VE10';
  UPDATE STB_ProductionOrderInfo SET ProdFinishQty = ProdFinishQty - @Qty WHERE PONo = 'MÃ_PO';
  COMMIT TRANSACTION;
  ```

---

## ⚙️ K-Series: Bắc Giang 2 (Module Line)

### [K361] — Hoàn thành công đoạn cuối BG2
* **Bug 1: Công đoạn ND08 hiển thị "Chưa hoàn thành" dù công đoạn trước đã Pass:**
  * **CẤM sửa `IsOutputRoute = 1`**. Giữ nguyên `IsOutputRoute = NULL`.
  * Thao tác trên K361: Tích chọn dòng `ND08` $\rightarrow$ Bấm **"Hoàn thành kết quả sản xuất"** (gọi `usp_CompleteRouteFinalForBacGiang2` để set `CompleteRoute = 1`).

### [K366] — Lot Tracking BG2
* **Bug 1: Cột Status (Pass/Fail) bị trống:** Thêm CASE WHEN tính trạng thái vào SP `usp_LotTrackingInfo_VVTF4_get`.

---

## 🛡️ Z-Series: Quản Trị Hệ Thống SmartFramework

### [Z410] — Quản lý tài khoản
* **Bug 1: Tài khoản bị khóa:** Mở khóa tài khoản:
  ```sql
  UPDATE SmartFramework.dbo.STB_UserInfo SET AllowFlag = 1 WHERE UserID = 'TÊN_USER';
  ```
