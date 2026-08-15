<!--
AI-READY METADATA
Purpose: Nhật ký ghi chép lịch sử xử lý bug & hotfix đã được AI triển khai thành công
Scope: Hotfix History Registry
Single Source of Truth: HOTFIX_LOG.md (Lịch sử hotfixes) & KB_09 (Sổ tay cứu hộ)
Related Files:
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md)
  - [KB_09_SCREEN_BUG_FIXBOOK.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md)
  - [record_hotfix.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/record_hotfix.ps1)
-->

# 📓 Vinatech MES Agent — Hotfix Log (Nhật ký lỗi & Giải pháp)

> **Mục đích:** Bảng lưu trữ lịch sử các con bug đã được AI xử lý thành công. File này đóng vai trò là "Bộ nhớ dài hạn" để AI tra cứu trước khi xử lý các sự cố tiếp theo nhằm tự tối ưu bản thân qua thời gian.
> **Quy trình:** Khi hoàn thành fix bất kỳ lỗi nào, AI bắt buộc phải mô tả chi tiết lỗi vào danh sách dưới đây và thực hiện commit.

> **⚠️ Lưu ý:** KHÔNG paste toàn bộ source code SP vào file này — chỉ ghi tóm tắt ALTER + logic chính. Dùng `db_sync_tool.ps1` để xem full SP.

---

## 📋 Danh sách Lịch sử Sửa lỗi (Hotfix Registry)

### 📌 Mẫu ghi chép (Template)
* **Ngày sửa:** `YYYY-MM-DD`
* **Màn hình liên quan (TCode):** `[TCODE_ID] - Tên màn hình`
* **Triệu chứng lỗi:** `Nội dung lỗi hiển thị trên UI (Tiếng Hàn/Anh/Việt)`
* **Nguyên nhân gốc (Root Cause):** `Giải thích lỗi do code SP hay do dữ liệu CSDL`
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  -- Chèn câu lệnh SQL fix hoặc giải pháp xử lý đã thực hiện
  ```

---

## ⚡ Các Lỗi Đã Được Xử Lý (Resolved Bugs)

### [HN544] — 📍 ID_21 Hủy gộp box / Rã box túi bóng ở màn hình HN544
* **Ngày sửa:** `2026-07-30`
* **Màn hình liên quan (TCode):** `[HN544] - Gộp túi bóng thành hộp nhỏ`
* **Triệu chứng lỗi:** Cần hủy gộp mã Packing `PK20260730000000004` (hoặc rã box túi bóng) giải phóng các Lot con để đóng gói lại.
* **Nguyên nhân gốc (Root Cause):** Gộp nhầm box hoặc thao tác hủy trên giao diện UI bị chặn/lỗi.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  -- 1. Giải phóng liên kết PackingID khỏi các Lot con trong STB_MaterialLotInfo
  UPDATE STB_MaterialLotInfo SET PackingID = NULL WHERE PackingID = 'PK20260730000000004';
  -- 2. Xóa thông tin lịch sử gộp box trong STB_DividePackaging
  DELETE FROM STB_DividePackaging WHERE PackingID = 'PK20260730000000004';
  COMMIT TRANSACTION;
  ```

### [K366] — 📍 ID_18 Cột Status trống trên Lot Tracking BG2
* **Ngày sửa:** `2026-07-06`
* **Màn hình liên quan (TCode):** `K366 - Lot Tracking BG2`
* **Triệu chứng lỗi:** Cột Status (Kết luận cuối cùng Pass/Fail) hiển thị trống trên grid
* **Nguyên nhân gốc (Root Cause):** SP `usp_LotTrackingInfo_VVTF4_get` không trả về cột Status cho grid mapping.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  ALTER PROCEDURE [dbo].[usp_LotTrackingInfo_VVTF4_get]
  -- Thêm cột Status vào SELECT:
  -- CASE WHEN df.ControlNo IS NULL THEN 'PASS'
  --      WHEN rp.Barcode IS NOT NULL THEN 'PASS'
  --      ELSE 'FAIL' END AS Status
  -- Tối ưu: dùng temp tables (#TmpBarcodes, #TmpDefect, #TmpMaterialInput, #TmpRepair)
  --         thay vì subquery để giảm thời gian truy vấn.
  -- Full SP: db_sync_tool.ps1 -SPName "usp_LotTrackingInfo_VVTF4_get"
  ```

### [B523] — 📍 ID_19 Sanmina QR code trùng lặp trên tem Inner
* **Ngày sửa:** `2026-07-06`
* **Màn hình liên quan (TCode):** `B523 - Đóng gói (Sanmina Label)`
* **Triệu chứng lỗi:** Sanmina QR code hiển thị số lượng và serial trùng lặp trên inner labels
* **Nguyên nhân gốc (Root Cause):** SP `usp_SanminaLabelPrint_get_Vietnam` không lọc riêng serial/quantity cho inner labels — trả về cùng data cho cả Outer và Inner.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  ALTER PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam]
  -- Thêm #LabelTypes (Outer, Inner-01, Inner-02) + CROSS JOIN #tmp
  -- Quantity: Outer = @pQuantity, Inner = @pQuantity/2
  -- Serial: BoxSerialNo = base, PrintSerialNo = base + suffix
  -- Thêm SerialListForQR: Outer = concat(outer||inner1||inner2), Inner = serial riêng
  -- Full SP: db_sync_tool.ps1 -SPName "usp_SanminaLabelPrint_get_Vietnam"
  ```

### [B767] — 📍 ID_20 S/N tem Outer trống trên Sanmina label
* **Ngày sửa:** `2026-07-16`
* **Màn hình liên quan (TCode):** `B767 - In tem Sanmina`
* **Triệu chứng lỗi:** S/N của tem đầu tiên (Outer label) bị trống khi in
* **Nguyên nhân gốc (Root Cause):** SP `usp_SanminaLabelPrint_get_Vietnam` set PrintSerialNo trống và BoxSerialNo = serial Inner đầu tiên cho Outer label.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  -- 1. Sửa SP: BoxSerialNo + PrintSerialNo cho Outer = comma-separated list (Inner1, Inner2)
  ALTER PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam] ...

  -- 2. Mở rộng cột BoxSerialNo để chứa chuỗi gộp:
  ALTER TABLE STB_SanminaIndiaLabelPrintHist ALTER COLUMN BoxSerialNo VARCHAR(50);

  -- 3. Sửa SP insert lịch sử:
  ALTER PROCEDURE [dbo].[usp_SanminaIndiaLabelPrintHist_iud] ... (@pBoxSerialNo VARCHAR(50) = NULL)
  ```

### [B530] — 📍 ID_22 Nút "Nhập lỗi" bị mờ (Disabled) & Rollback công đoạn chuẩn
* **Ngày sửa:** `2026-08-06`
* **Màn hình liên quan (TCode):** `[B530] - Nhập thực tế sản xuất sản phẩm`
* **Triệu chứng lỗi:** Nút **"Nhập lỗi"** (`AddDefect`) trên B530 bị ẩn/mờ đi (disabled) khi muốn ghi nhận phế lỗi cho Barcode `VE260710-002` tại công đoạn `VE08`.
* **Nguyên nhân gốc (Root Cause):** Biểu thức Expression của giao diện: `!IsHasNextProd && !IsLoss`. Do Barcode đã quét/chốt ở công đoạn tiếp theo (`VE09`), cờ `IsHasNextProd = 1` $\rightarrow$ Nút bị ẩn.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  -- 1. Xóa bản ghi phế NG tại công đoạn sau (cột FindRouteCode trong STB_DefectRepairInfo)
  DELETE FROM STB_DefectRepairInfo WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260710-002') AND FindRouteCode IN ('VE08', 'VE09');
  -- 2. Xóa Routing các bước quét nhầm (cột RouteCode trong STB_ProdRouteHist)
  DELETE FROM STB_ProdRouteHist WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260710-002') AND RouteCode IN ('VE08', 'VE09');
  -- 3. Reset cờ chốt công đoạn trước: CompleteRoute = NULL (cột CompleteRoute trong STB_ProdRouteHist)
  UPDATE STB_ProdRouteHist SET CompleteRoute = NULL WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260710-002') AND RouteCode = 'VE07';
  COMMIT TRANSACTION;
  ```

### [B530]/[HY530]/[B523] — 📍 ID_23 Hủy kết quả sản xuất Lot để gộp Lot & in lại tem
* **Ngày sửa:** `2026-08-08`
* **Màn hình liên quan (TCode):** `[B530]/[HY530] - Nhập sản xuất & [B523]/[HY620] - Đóng gói in tem`
* **Triệu chứng lỗi:** Lot sản xuất (`SP260807-003`, `SP260807-006`) đã lỡ chốt kết quả công đoạn sau (`VE08`, `VE09`, `VE10`), khiến công nhân không gộp được Lot hoặc không in lại được tem dán hộp tại B523 / HY620.
* **Nguyên nhân gốc (Root Cause):** Cờ `CompleteRoute` và bản ghi sản lượng tại `STB_ProdRouteHist` của các công đoạn sau đã bị chốt ➔ Ứng dụng B523 kiểm tra thấy cờ `IsHasNextProd = 1` nên chặn không cho sửa/gộp Lot.
* **Phương án sửa lỗi (SQL Rollback Template):**
  ```sql
  BEGIN TRANSACTION;
  -- 1. Xóa bản ghi lỗi/phế các công đoạn chốt thừa
  DELETE FROM STB_DefectRepairInfo WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006') AND FindRouteCode IN ('VE08', 'VE09', 'VE10');
  -- 2. Xóa lịch sử routing các công đoạn chốt thừa trong STB_ProdRouteHist
  DELETE FROM STB_ProdRouteHist WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006') AND RouteCode IN ('VE08', 'VE09', 'VE10');
  -- 3. Reset cờ CompleteRoute của công đoạn cần làm lại về NULL
  UPDATE STB_ProdRouteHist SET CompleteRoute = NULL WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006') AND RouteCode = 'VE07';
  -- 4. Xóa thông tin đóng gói tạm nếu có trong STB_DividePackaging & STB_SavePackingTime_VVT
  DELETE FROM STB_DividePackaging WHERE LotNo = 'SP260807-006' OR ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'SP260807-006');
  DELETE FROM STB_SavePackingTime_VVT WHERE LotNo = 'SP260807-006';
  COMMIT TRANSACTION;
  ```

### [B540]/[B530] — 📍 ID_24 Không hoàn thành được công đoạn ngoại quan / gập uốn chân V-27
* **Ngày sửa:** `2026-08-07`
* **Màn hình liên quan (TCode):** `[B540] - Quét NVL & [B530] - Chốt sản lượng (V-27 Bending/Tapping)`
* **Triệu chứng lỗi:** Barcode `VVQP263R010701` không thể chốt hoàn thành công đoạn ngoại quan / gập uốn chân `V-27` tại B530.
* **Nguyên nhân gốc (Root Cause):** Chưa nhập đủ 4 cột thuộc tính màu bắt buộc sấy Oven tại `B540` (`STB_RawMaterialInputHist`), hoặc chưa hoàn thành công đoạn trước (`V-26`), khiến autocheck Gate 3 & Gate 4 chặn chốt sản lượng.
* **Phương án sửa lỗi (SQL Action):**
  ```sql
  BEGIN TRANSACTION;
  -- Cập nhật bổ sung thuộc tính sấy Oven cho bản ghi NVL B540
  UPDATE STB_RawMaterialInputHist 
  SET RMIExtText01 = '120C', RMIExtText02 = '4H', RMIExtText03 = 'OVEN_01', RMIExtText04 = 'LOT_OVEN_01'
  WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVQP263R010701');
  COMMIT TRANSACTION;
  ```

### [B351] — 📍 ID_25 Lỗi không chuyển đổi được LotNo tại màn hình B351
* **Ngày sửa:** `2026-08-07`
* **Màn hình liên quan (TCode):** `[B351] - Chuyển đổi Lot (Change Material SetInfo)`
* **Triệu chứng lỗi:** Người dùng chọn Lot nguồn tại Lưới 1 nhưng Lưới 2 báo lỗi không cho chuyển đổi sang Lot đích.
* **Nguyên nhân gốc (Root Cause):** SP `usp_GetDayProdPlanForChangeMaterial` yêu cầu `TargetDayPlanNo` phải thuộc Kế hoạch ngày đã fixed (`IsFixed = 1`) và Lot nguồn chưa bị khóa cờ đóng gói (`IsPacking = 0`).
* **Phương án sửa lỗi (SQL Action):**
  ```sql
  BEGIN TRANSACTION;
  -- Phê duyệt kế hoạch ngày đích và mở khóa cờ đóng gói cho Lot nguồn
  UPDATE STB_DayProdPlan SET IsFixed = 1 WHERE DayProdPlanNo = 'MÃ_KH_ĐÍCH';
  UPDATE STB_SetInfo SET IsPacking = 0 WHERE Barcode = 'MÃ_LOT_NGUỒN';
  COMMIT TRANSACTION;
  ```

### [B540]/[K361] — 📍 ID_26 Model Nordex ở B540/B530/K361 hoàn thành công đoạn ND08 theo chuẩn K361
* **Ngày sửa:** `2026-08-08`
* **Màn hình liên quan (TCode):** `[B540] - Nhập thẻ công đoạn & [K361] - Hoàn thành công đoạn BG2`
* **Triệu chứng lỗi:** Model Nordex (`EDVTMD-246`) ở B540/B530/K361 cần hoàn thành công đoạn `ND08`. Dòng `ND08` hiển thị `Chưa hoàn thành` và tạm gắn tên công nhân vừa làm `ND07`.
* **Nguyên nhân gốc (Root Cause):** 
  1. Theo quy tắc nghiệp vụ BG2 Module Line, cờ `IsOutputRoute` trong `STB_ProductionOrderRouting` giữ nguyên `NULL` (hoặc 0), KHÔNG sửa thành 1.
  2. Màn hình K361 BG2 dùng SP riêng (`usp_Vietnam_GetProdPackingForBarcodeForBacGiang2` để đọc các công đoạn `IN ('VP07','VP18','VP12','ND08','ND05')` và `usp_CompleteRouteFinalForBacGiang2` để chốt `CompleteRoute=1`).
  3. B530 khi chốt PASS `ND07` sẽ tự động clone dòng chờ `ND08` với `CompleteRoute = NULL` và tạm thời copy `WorkerCode` từ `ND07` sang.
* **Phương án sửa lỗi & Thao tác (Giữ IsOutputRoute = NULL):**
  ```sql
  -- 1. GIỮ NGUYÊN IsOutputRoute = NULL (hoặc 0) cho ND08 trong STB_ProductionOrderRouting (Không set = 1).
  -- 2. Thao tác trên UI K361 hoặc giả lập K361: Chốt CompleteRoute = 1 cho ND08 trong STB_ProdRouteHist
  UPDATE PRH
  SET PRH.CompleteRoute = 1, PRH.ProdDateTime = GETDATE(), PRH.ChangeDateTime = GETDATE(), PRH.ChangeUserID = '32606011'
  FROM STB_ProdRouteHist PRH
  INNER JOIN STB_SetInfo SI ON PRH.ControlNo = SI.ControlNo
  WHERE SI.MaterialCode = 'EDVTMD-246' AND PRH.RouteCode = 'ND08' AND (PRH.CompleteRoute IS NULL OR PRH.CompleteRoute <> 1);
  ```

### [HN523] — 📍 ID_27 Hủy tem đóng gói PKQQ1400141 & Đồng bộ giảm sản lượng VE10 + PO
* **Ngày sửa:** `2026-08-14`
* **Màn hình liên quan (TCode):** `[HN523] - Đóng gói Hà Nam (Packaging & Box Matching)`
* **Triệu chứng lỗi:** Cần hủy tem đóng gói `PKQQ1400141` (Lot `VE260804-002`, SL `984` con) để rã Lot và đóng gói lại tại HN523.
* **Nguyên nhân gốc (Root Cause):** Đóng gói nhầm tem. Cần gỡ `PackingID` khỏi `STB_MaterialLotInfo`, xóa lịch sử `STB_SavePackingTime_VVT`, đồng thời giảm trừ sản lượng chốt công đoạn cuối `VE10` (`STB_ProdRouteHist`) và sản lượng hoàn thành PO (`STB_ProductionOrderInfo`). Trigger `tgMaterialDocDetailForDelete` kiểm tra `DocStatus` ➔ Cần tạm chuyển `DocStatus = 'CREATE'` và đặt `CONTEXT_INFO 0x999997` để bypass trigger.
* **Phương án sửa lỗi & Backup (Thực thi thành công):**
  - **Bảng Backup đã lưu:** `STB_MaterialLotInfo_BK_20260814`, `STB_SavePackingTime_VVT_BK_20260814`, `STB_MaterialDocLotInfo_BK_20260814`, `STB_ProdRouteHist_BK_20260814`, `STB_ProductionOrderInfo_BK_20260814`.
  - **SQL Patch đã deploy:**
    ```sql
    BEGIN TRANSACTION;
    -- 1. Gỡ PackingID khỏi STB_MaterialLotInfo
    UPDATE STB_MaterialLotInfo SET PackingID = '' WHERE LotID = '16VHVL180MC6XXVC01QQ1400005' OR PackingID = 'PKQQ1400141';
    -- 2. Xóa lịch sử STB_SavePackingTime_VVT
    DELETE FROM STB_SavePackingTime_VVT WHERE PackingID = 'PKQQ1400141';
    -- 3. Tạm mở DocStatus = 'CREATE' & xóa chứng từ đóng gói (CONTEXT_INFO 0x999997)
    UPDATE STB_MaterialDocInfo SET DocStatus = 'CREATE', IsCancel = 0 WHERE MaterialDocNo = '260814000155';
    SET CONTEXT_INFO 0x999997;
    DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '260814000155';
    SET CONTEXT_INFO 0;
    DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = '260814000155';
    UPDATE STB_MaterialDocInfo SET IsCancel = 1, CancelDateTime = GETDATE(), CancelUserID = 'vanduc' WHERE MaterialDocNo = '260814000155';
    -- 4. Trừ 984 con ở công đoạn cuối VE10 & Lệnh sản xuất PO 260804000007
    UPDATE STB_ProdRouteHist SET ProdQty = ProdQty - 984 WHERE ControlNo = '20260804000078' AND RouteCode = 'VE10';
    UPDATE STB_ProductionOrderInfo SET ProdFinishQty = ProdFinishQty - 984 WHERE PONo = '260804000007';
    COMMIT TRANSACTION;
    ```

### [B523] — 📍 ID_28 Lỗi popup "Could not find Kho Thành phẩm chưa nhập cân nặng cho Lót hàng này!" sau B351 chuyển đổi Lot
* **Ngày sửa:** `2026-08-15`
* **Màn hình liên quan (TCode):** `[B523] - Vietnam_nhập thực tế thùng sản xuất & [B351] - Lot Transition`
* **Triệu chứng lỗi:** Công nhân chuyển đổi Lot tại B351 từ `VVPN263R850606` sang `VVQQ143R850605`. Ra B523 bấm `In Tem &` hoặc `In tem` thì bật popup đỏ: `Could not find Kho Thành phẩm chưa nhập cân nặng cho Lót hàng này! at ScreenControl.PrintLabel`.
* **Nguyên nhân gốc (Root Cause):** 
  1. B351 chỉ cập nhật `STB_SetInfo`, không tự nạp cân Barcode vào `STB_VIETNAM_BARCODEWEIGHT` và cân kho `STB_VN_FINISHGOODS`.
  2. SP `usp_Vietnam_GetBoxIDForLotNo_VVT` tính `@lotweight = 0` do thiếu dòng trong `STB_VIETNAM_BARCODEWEIGHT` ➔ gán `FormatName = N'Kho Thành phẩm chưa nhập cân nặng...'`.
  3. C# WinForm Client `PrintLabel` không thấy template nhãn tên này ➔ Bật popup `Could not find Kho Thành phẩm...`.
* **Phương án sửa lỗi & Script Deploy:**
  ```sql
  BEGIN TRANSACTION;
  -- 1. Nạp cân nặng barcode (Giải quyết nguyên nhân gốc FormatName)
  IF NOT EXISTS (SELECT 1 FROM STB_VIETNAM_BARCODEWEIGHT WHERE BARCODE = 'VVQQ143R850605')
      INSERT INTO STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, CREATEDATETIME) VALUES ('VVQQ143R850605', 25.5, GETDATE());
  IF NOT EXISTS (SELECT 1 FROM STB_VIETNAM_BARCODEWEIGHT WHERE BARCODE = 'VVPN263R850606')
      INSERT INTO STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, CREATEDATETIME) VALUES ('VVPN263R850606', 25.5, GETDATE());
  -- 2. Nạp cân kho thành phẩm chính & Bắc Giang
  IF NOT EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS WHERE PackingID = 'PKQQ1500133' AND LotNo = 'VVQQ143R850605')
      INSERT INTO STB_VN_FINISHGOODS (IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo, CreatDatePacked, PartNo, CreateDate)
      VALUES ('FGVN_BN' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '-', ''), 'PKQQ1500133', 'VVQQ143R850605', 'LIVT38-018', 'VEL08253R8506G-B034', 2800, 'vvtworker_BG', CONVERT(VARCHAR(10), GETDATE(), 110), 'VEL08253R8506G-B034', GETDATE());
  IF NOT EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_BG WHERE PackingID = 'PKQQ1500133' AND LotNo = 'VVQQ143R850605')
      INSERT INTO STB_VN_FINISHGOODS_BG (IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo, CreatDatePacked, PartNo, CreateDate)
      VALUES ('FGVN_BG' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '-', ''), 'PKQQ1500133', 'VVQQ143R850605', 'LIVT38-018', 'VEL08253R8506G-B034', 2800, 'vvtworker_BG', CONVERT(VARCHAR(10), GETDATE(), 110), 'VEL08253R8506G-B034', GETDATE());
  -- 3. Đăng ký ánh xạ tem in mã mới vào STB_ChangePartNoAndLotNo (Quyết định Barcode in ra tem)
  UPDATE STB_ChangePartNoAndLotNo SET NewLotID = 'VVQQ143R850605' WHERE oldLotID = 'VVPN263R850606';
  IF NOT EXISTS (SELECT 1 FROM STB_ChangePartNoAndLotNo WHERE oldLotID = 'VVPN263R850606' AND NewLotID = 'VVQQ143R850605')
      INSERT INTO STB_ChangePartNoAndLotNo (oldLotID, NewLotID, isLotID, CreateDateTime, CreateUserID) VALUES ('VVPN263R850606', 'VVQQ143R850605', 1, GETDATE(), 'vanduc');
  -- 4. Đồng bộ STB_LotChangeMaterialHistory & STB_MaterialLotInfo
  UPDATE STB_LotChangeMaterialHistory SET OldBarcode = 'VVPN263R850606' WHERE NewBarcode = 'VVQQ143R850605';
  UPDATE STB_MaterialLotInfo SET LotNo = 'VVQQ143R850605' WHERE PackingID = 'PKQQ1500133';
  UPDATE STB_PackingLabelPrintHist SET IsPrintAllow = 1, PrintCount = 0 WHERE PackingID = 'PKQQ1500133';
  COMMIT TRANSACTION;
  ```

