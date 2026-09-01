<!--
AI-READY METADATA
Purpose: Nhật ký ghi chép lịch sử xử lý bug & hotfix đã được AI triển khai thành công
Scope: Hotfix History Registry
Single Source of Truth: HOTFIX_LOG.md (Lịch sử hotfixes) & KB_09 (Sổ tay cứu hộ)
Related Files:
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/BOOTSTRAP.md)
  - [KB_09_SCREEN_BUG_FIXBOOK.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md)
  - [record_hotfix.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/record_hotfix.ps1)
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

### [F620/F330] — 📍 ID_23 Cấu hình tự động bóc tách Ngày SX (Vendor Lot) cho toàn bộ dòng họ vỏ nhôm AOXING GBAXAC-%
* **Ngày sửa:** `2026-08-20`
* **Màn hình liên quan (TCode):** `[F620] - Hoàn trả vật liệu và in tem`, `[F330] - Nhập kho NVL`, `[F311] - Quản lý nguyên vật liệu`
* **Triệu chứng lỗi:** Quét/nhập mã Lot Vendor `072812608060749905` cho mã NVL `GBAXAC-007` không tự động đọc được ngày sản xuất `2026-08-06` (trả về rỗng / 1900-01-01).
* **Nguyên nhân gốc (Root Cause):** Hàm `fn_VVT_getdatebyVendorLot_MergeCode` và `fn_VVT_getdatebyVendorLot` trước đây hardcode đơn lẻ `WHEN @materialcode = 'GBAXAC-009'` thay vì dùng wildcard `GBAXAC-%`.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  -- Cập nhật cả fn_VVT_getdatebyVendorLot_MergeCode và fn_VVT_getdatebyVendorLot:
  -- Format 18 số AOXING: 5 ký tự đầu mã NCC + 2 ký tự Năm + 2 ký tự Tháng + 2 ký tự Ngày + Hậu tố
  WHEN @materialcode LIKE 'GBAXAC-%'
      AND LEN(@vendorlot) >= 11
      AND ISNUMERIC(SUBSTRING(@vendorlot, 6, 6)) = 1
  THEN
      '20' + SUBSTRING(@vendorlot, 6, 2) + '-' +
      SUBSTRING(@vendorlot, 8, 2) + '-' +
      SUBSTRING(@vendorlot, 10, 2)
  ```
  *Đã deploy lên DB SmartFactoryV2 và kiểm thử 100% thành công: `GBAXAC-007` (`072812608060749905` $\rightarrow$ `2026-08-06`), `GBAXAC-009` (`072812608060749905` $\rightarrow$ `2026-08-06`), `GBAXAC-003` (`150222607110832811` $\rightarrow$ `2026-07-11`).*

### [F620/F330] — 📍 ID_22 Cấu hình tự động bóc tách Ngày SX (Vendor Lot) cho dòng họ NVL GBNKSP-%
* **Ngày sửa:** `2026-08-20`
* **Màn hình liên quan (TCode):** `[F620] - Hoàn trả vật liệu và in tem`, `[F330] - Nhập kho NVL`
* **Triệu chứng lỗi:** Quét/nhập mã Lot Vendor `5606N19B` cho mã NVL `GBNKSP-071` không tự động đọc được ngày sản xuất `2025-06-06` (hoặc báo lỗi/trống ngày ở F620/F330).
* **Nguyên nhân gốc (Root Cause):** Cả 2 hàm SQL `fn_VVT_getdatebyVendorLot_MergeCode` và `fn_VVT_getdatebyVendorLot` trước đây chỉ hardcode đơn lẻ mã `GBNKSP-083` với chuỗi cố định `5Y13N36F`, chưa có quy tắc động cho toàn bộ họ `GBNKSP-%`.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  -- Cập nhật cả fn_VVT_getdatebyVendorLot_MergeCode và fn_VVT_getdatebyVendorLot:
  -- Format: 1 ký tự Năm ('5'->2025) + 1 ký tự Tháng (1..9, X/A=10, Y/B=11, Z/C=12) + 2 ký tự Ngày ('06') + Hậu tố
  WHEN @materialcode LIKE 'GBNKSP-%' AND LEN(@vendorlot) >= 4 THEN
      '202' + SUBSTRING(@vendorlot, 1, 1) + '-' 
      + RIGHT('0' + CASE 
          WHEN SUBSTRING(@vendorlot, 2, 1) IN ('X', 'A') THEN '10'
          WHEN SUBSTRING(@vendorlot, 2, 1) IN ('Y', 'B') THEN '11'
          WHEN SUBSTRING(@vendorlot, 2, 1) IN ('Z', 'C') THEN '12'
          ELSE SUBSTRING(@vendorlot, 2, 1)
        END, 2) + '-' 
      + SUBSTRING(@vendorlot, 3, 2)
  ```
  *Đã kiểm thử 100% thành công trên DB: `GBNKSP-071` (`5606N19B` $\rightarrow$ `2025-06-06`), `GBNKSP-083` (`5Y13N36F` $\rightarrow$ `2025-11-13`), `GBNKSP-066` (`4510N03B` $\rightarrow$ `2024-05-10`), Tháng 10 (`5X05...` $\rightarrow$ `2025-10-05`), Tháng 12 (`5Z25...` $\rightarrow$ `2025-12-25`).*

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

### [B552] — 📍 ID_29 Xóa 61 bản ghi kết quả cắt điện cực (STT 10-70) cho Lot VVQO2020001E36
* **Ngày sửa:** `2026-08-15`
* **Màn hình liên quan (TCode):** `[B552] - Vietnam_Kết quả đo điện cực (Tab Slitting - Cắt điện cực)`
* **Triệu chứng lỗi:** Cần dọn dẹp các dòng kết quả cắt điện cực dở dang từ STT 10 đến STT 70 cho Lot `VVQO2020001E36`.
* **Nguyên nhân gốc (Root Cause):** Thao tác cắt chia cuộn dư hoặc lỗi dòng kết quả cần xóa bỏ bản ghi lịch sử trong `STB_ElectrodeSlittingResult`.
* **Phương án sửa lỗi & Script Deploy:**
  ```sql
  BEGIN TRANSACTION;
  DELETE FROM STB_ElectrodeSlittingResult
  WHERE ElectrodeLotNumber = 'VVQO2020001E36'
    AND Seq BETWEEN 10 AND 70;
  COMMIT TRANSACTION;
  ```

### [B530]/[B523]/[HY530] — 📍 ID_30 Lỗi "Công đoạn không có trong Routing" & Chặn Gate Aging 24h khi di chuyển Lot từ BN/BG1 về HY
* **Ngày sửa:** `2026-08-18`
* **Màn hình liên quan (TCode):** `[B530] - Nhập thực tế sản xuất`, `[HY530] - Route Process Input Hưng Yên`, `[B523] - Đóng gói thùng sản xuất`
* **Triệu chứng lỗi:** 
  1. Tại B530/HY530, quét Lot bị văng popup đỏ: *"Công đoạn này không có trong Routing hoặc là công đoạn cuối cùng"* hoặc *"Chưa đủ thời gian Aging lão hóa theo quy định"*.
  2. Tại B523 (Đóng gói), quét Lot bị báo `SlgĐóngGóiCơ bản = 0` và không cho gộp thùng.
* **Nguyên nhân gốc (Root Cause):** 
  1. **Di chuyển Lot lệch RouteCode & LineCode:** Lot chuyển từ Bắc Giang 1 (`Nais BG1`) / Bắc Ninh (`Nais BN`) về Hưng Yên giữ nguyên `RouteCode = 'V-26_BG'`/`'V-26'` và `InputLineCode = 'VVBNTC-01'`. PO Routing Hưng Yên (`260804000017`) yêu cầu `V-26_HY` và `VVHYC-01` ➔ SP `usp_DoProcessProdRouteHist_HY` không match được mã công đoạn ➔ Văng popup lỗi.
  2. **Bản ghi dở dang `CompleteRoute = NULL`:** Công đoạn trước bị set `CompleteRoute = 1` trong khi công đoạn liền sau có bản ghi dở dang ➔ Gây xung đột theo KB_09 Mục 9.
  3. **Khóa Autocheck Gate Aging (24h):** SP kiểm tra `DATEDIFF(HOUR, CreateDateTime, GETDATE()) < 24`. Nếu nhỏ hơn 24 giờ kể từ công đoạn bọc vỏ/sấy, MES tự động chặn chuyển trạm sang Ngoại quan.
  4. **Lệch Phân quyền Tài khoản:** PO tạo ở `VVT_F1`, dùng tài khoản Hưng Yên (`vvtworker_hy`) bị MES chặn chốt. Bắt buộc dùng tài khoản Bắc Giang (`vvtworker_bg`).
* **Phương án sửa lỗi & Script Deploy (Thực thi thành công):**
  ```sql
  BEGIN TRANSACTION;
  -- 1. Quy đổi Mã Line nhập về Line Hưng Yên (VVHYC-01)
  UPDATE SI
  SET SI.InputLineCode = 'VVHYC-01'
  FROM STB_SetInfo SI WITH(NOLOCK)
  WHERE SI.ControlNo IN (
      '20260619000076', '20260619000077', '20260618000074', '20260615000339', '20260617000167',
      '20260615000341', '20260619000082', '20260615000090', '20260618000304', '20260618000066',
      '20260618000287', '20260620000086', '20260617000173', '20260615000087', '20260619000093',
      '20260617000170', '20260619000080', '20260619000081', '20260611000229', '20260716000096',
      '20260719000001', '20260718000040', '20260720000001', '20260722000143', '20260726000223',
      '20260726000083', '20260718000041', '20260727000090', '20260722000141', '20260724000130',
      '20260815000245', '20260816000299', '20260818000302'
  );

  -- 2. Đồng bộ Mã công đoạn từ V-26 / V-26_BG về mã chuẩn Hưng Yên V-26_HY
  UPDATE PRH
  SET PRH.RouteCode = 'V-26_HY'
  FROM STB_ProdRouteHist PRH WITH(NOLOCK)
  WHERE PRH.RouteCode IN ('V-26', 'V-26_BG')
    AND PRH.ControlNo IN (
      '20260619000076', '20260619000077', '20260618000074', '20260615000339', '20260617000167',
      '20260615000341', '20260619000082', '20260615000090', '20260618000304', '20260618000066',
      '20260618000287', '20260620000086', '20260617000173', '20260615000087', '20260619000093',
      '20260617000170', '20260619000080', '20260619000081', '20260611000229', '20260716000096',
      '20260719000001', '20260718000040', '20260720000001', '20260722000143', '20260726000223',
      '20260726000083', '20260718000041', '20260727000090', '20260722000141', '20260724000130',
      '20260815000245', '20260816000299', '20260818000302'
  );

  -- 3. Reset CompleteRoute & xóa bản ghi dở dang theo KB_09 Mục 9
  DELETE FROM STB_ProdRouteHist
  WHERE RouteCode IN ('V-23_HY', 'V-27_HY')
    AND CompleteRoute IS NULL
    AND ControlNo IN ('20260815000245', '20260818000302', '20260818000304');

  UPDATE STB_ProdRouteHist
  SET CompleteRoute = NULL
  WHERE RouteCode IN ('V-22_HY', 'V-26_HY')
    AND ControlNo IN ('20260815000245', '20260816000299', '20260818000302', '20260818000304');

  -- 4. Thông luồng Gate Time Aging (Lùi thời gian sấy về trước 25 giờ)
  UPDATE STB_ProdRouteHist
  SET CreateDateTime = DATEADD(HOUR, -25, GETDATE())
  WHERE ControlNo IN (
      '20260619000076', '20260619000077', '20260618000074', '20260615000339', '20260617000167',
      '20260615000341', '20260619000082', '20260615000090', '20260618000304', '20260618000066',
      '20260618000287', '20260620000086', '20260617000173', '2026061500087', '20260619000093',
      '20260617000170', '20260619000080', '20260619000081', '20260611000229', '20260716000096',
      '20260719000001', '20260718000040', '20260720000001', '20260722000143', '20260726000223',
      '20260726000083', '20260718000041', '20260727000090', '20260722000141', '20260724000130',
      '20260815000245', '20260816000299', '20260818000302'
  );

  COMMIT TRANSACTION;
  ```

### [B767]/[B763] — 📍 ID_31 Hỗ trợ `StartSerial` độc lập theo Shipment Plan & Giữ nguyên Auto-Continuity
* **Ngày sửa:** `2026-08-20`
* **Màn hình liên quan (TCode):** `[B767] - In tem Sanmina India` & `[B763] - Cấu hình kế hoạch xuất Sanmina`
* **Triệu chứng lỗi:** Cột `StartSerial` thiết lập trên B763 bị bỏ qua trên B767 nếu số nhập vào nhỏ hơn số Serial lớn nhất đã in trong lịch sử (`STB_SanminaIndiaLabelPrintHist`), khiến không thể chạy lại dải số Serial từ đầu (ví dụ `0`) hoặc gán dải số cố định cho PO mới.
* **Nguyên nhân gốc (Root Cause):** Điều kiện `IF @IsPlanMode = 1 AND @ActiveStartSerial IS NOT NULL AND @ActiveStartSerial > @BaseSerial` chặn gán `@BaseSerial` khi `StartSerial <= @LatestSerial`. Đồng thời các thùng tiếp theo của cùng Plan cần tự động tịnh tiến dải số theo công thức $Base = StartSerial + (PrintedBoxCount \times 2)$.
* **Phương án sửa lỗi (SQL Patch / Action):**
  - **Backup:** Đã lưu `sql/backup/BAK_usp_SanminaLabelPrint_get_Vietnam_20260820.sql`.
  - **Procedure đã cập nhật:** `sql/procedures/usp_SanminaLabelPrint_get_Vietnam.sql`.
  - **Logic:**
    ```sql
    IF @IsPlanMode = 1 AND @ActiveStartSerial IS NOT NULL
    BEGIN
        -- TRƯỜNG HỢP 1: Plan có chỉ định StartSerial cụ thể (VD: 0, 100, 500...)
        SET @BaseSerial = @ActiveStartSerial + (ISNULL(@ActivePrintedBoxCount, 0) * 2);
    END
    ELSE
    BEGIN
        -- TRƯỜNG HỢP 2: Giữ 100% logic cũ khi StartSerial để trống (NULL) hoặc Non-Plan
        DECLARE @LatestSerial INT = 0;
        SELECT TOP 1 @LatestSerial = TRY_CAST(RIGHT(BoxSerialNo, 5) AS INT)
        FROM STB_SanminaIndiaLabelPrintHist WITH(NOLOCK)
        WHERE LEN(BoxSerialNo) = 13 AND BoxSerialNo LIKE 'VINA%'
        ORDER BY ID DESC;

        SET @BaseSerial = ISNULL(@LatestSerial, 0);
    END
    ```

### [B530]/[B310] — 📍 ID_32 Lỗi chốt sản lượng công đoạn Aging ("Công đoạn không có trong Routing hoặc là công đoạn cuối cùng") do lệch tài khoản phân quyền nhà máy (BG1 vs HY) & thiếu Routing Index trên B310
* **Ngày ghi nhận:** `2026-08-21`
* **Màn hình liên quan (TCode):** `[B530] - Nhập thực tế sản xuất` / `ProdRouteBarcodeForDefect_VNT` & `[B310] - Quản lý Lệnh sản xuất (PO)`
* **Triệu chứng lỗi:** Khi công nhân quét mã barcode (ví dụ `VVQ0163R072710`, PO `26052900013`, Kế hoạch ngày `2026061300044`, mã Route `V-26`, công đoạn `에이징 (Aging)`) để hoàn thành kết quả sản xuất / chốt sản lượng, hệ thống văng popup đỏ: *"Công đoạn này không có trong Routing hoặc là công đoạn cuối cùng."*
* **Nguyên nhân gốc (Root Cause):**
  1. **TH1 - Lệch phân quyền tài khoản nhà máy:** Mã Lot này được tạo PO và Kế hoạch ngày ở nhà máy Bắc Giang 1 (`BG1 cũ` - `VVT_F2`) nhưng người dùng đăng nhập bằng tài khoản Hưng Yên (`vvtworker_hy`) hoặc Bắc Ninh (`vvtworker_bn`) để chốt. Hệ thống MES/NAIS yêu cầu bắt buộc phải sử dụng tài khoản đăng nhập nhà máy Bắc Giang (`vvtworker_bg`) để chốt sản lượng công đoạn.
  2. **TH2 - Thiếu công đoạn Aging hoặc sai Index trong Routing PO:** Khi tạo PO trên màn hình `B310` hoặc khi thay đổi kế hoạch sản xuất, PO có thể chưa được cấu hình công đoạn Aging (`V-26` / `V-26_BG`), hoặc thứ tự Routing (`RouteIndex`) chưa được đánh lại đầy đủ.
* **Quy trình kiểm tra & Phương án khắc phục (Troubleshooting Protocol):**
  1. **Bước 1 - Xem tem cáp thư (Lot Tag):** Kiểm tra mã Lot/Barcode được tạo ở nhà máy nào (`VVT_F1` Bắc Ninh, `VVT_F2` Bắc Giang 1, hay `VVT_F5` Hưng Yên).
  2. **Bước 2 - Kiểm tra tài khoản đăng nhập NAIS:** Đăng nhập đúng tài khoản tương ứng với nhà máy tạo PO (ví dụ: PO tạo ở BG1 ➔ dùng tài khoản `vvtworker_bg` để chốt sản lượng; PO tạo ở Hưng Yên ➔ dùng `vvtworker_hy`).
  3. **Bước 3 - Kiểm tra Routing trên B310:** Vào màn hình `B310`, tìm mã PO, kiểm tra danh sách công đoạn trong Routing. Nếu chưa có công đoạn Aging (`V-26` / `V-26_BG`) thì thêm vào và đánh lại thứ tự `RouteIndex` cho chuẩn xác.

---

### [HYFG01]/[F430] — 📍 ID_33 Màn hình xuất kho thành phẩm HYFG01 không thấy ProcessedLotID3, xuất toàn bộ số lượng & kiểm tra điều chuyển kho BN sang HY (ROH-HY-WH)
* **Ngày ghi nhận:** `2026-08-21`
* **Màn hình liên quan (TCode):** `[HYFG01] - Kho Thành Phẩm Hưng Yên (Xuất kho TP)` & `[F430] - Chuyển kho / Xuất kho NVL Bắc Ninh`
* **Triệu chứng lỗi:**
  1. Khi thực hiện xuất kho tại màn hình `HYFG01`, chương trình báo xuất thành công (OK) nhưng trên hệ thống lại không thấy dữ liệu xuất hoặc không check được đã xuất ID nào do giao diện không hiển thị cột `ProcessedLotID3`.
  2. Khi thao tác xuất kho tại `HYFG01`, hệ thống có bao nhiêu lại xuất hết toàn bộ số lượng (Full batch export) thay vì chỉ xuất một phần (Partial export).
  3. Trên hệ thống NAIS không kiểm tra/theo dõi được hàng từ Bắc Ninh (BN) xuất điều chuyển sang Hưng Yên (HY).
* **Nguyên nhân gốc & Phương án xử lý (Root Cause & Actions):**
  1. **Hiển thị cột ProcessedLotID3:** Cần cấu hình giao diện `HYFG01` hiển thị cột `ProcessedLotID3` và setup nguồn link giống như màn hình `F430` ở Bắc Ninh (`ISNULL(NULLIF(ProcessedLotID, ''), LotID)`). Gửi lại list `ProcessedLotID3` tương ứng để update dữ liệu lịch sử.
  2. **Thêm kho Hưng Yên vào hệ thống:** Đã cấu hình thêm kho Hưng Yên để có thể nhập và ghi nhận mã `ProcessedLotID3` chuẩn hóa.
  3. **Mã kho đích điều chuyển BN ➔ HY:** Khi xuất hàng điều chuyển từ Bắc Ninh sang Hưng Yên, mã kho hàng tới (Target Warehouse) bắt buộc phải chọn đúng là `ROH-HY-WH` (Kho NVL Hưng Yên) thì hệ thống NAIS mới nhận diện và tra cứu được dữ liệu luân chuyển.
  4. **Lưu ý nghiệp vụ xuất kho:** Chú ý cơ chế xuất kho theo cả lô/toàn bộ số lượng của hệ thống so với nhu cầu xuất từng phần để phân chia Lot hoặc chia phiếu phù hợp trước khi xuất.

### 📍 ID_22 - B767 - So Serial tem Sanmina khong reset ve 00001 khi Ma ngay (Tuan...
* **Ngay sua:** `2026-08-22`
* **Man hinh lien quan (TCode):** `B767 - In tem KH Sanmina India`
* **Trieu chung loi:** So Serial tem Sanmina khong reset ve 00001 khi Ma ngay (Tuan san xuat) doi sang tuan moi
* **Nguyen nhan goc (Root Cause):** SP usp_SanminaLabelPrint_get_Vietnam lay serial lon nhat toan bang voi LIKE 'VINA%' khong filter theo @SerialPrefix
* **Phuong an sua loi (SQL Patch / Action):**
  ```sql
WHERE LEN(BoxSerialNo) = 13 AND BoxSerialNo LIKE @SerialPrefix + '%'
  ```
* **Tham chieu KB:** KB_04_03_SANMINA_LABEL_GUIDE.md

---

### [HN523] — 📍 ID_34 Hủy 2 box đóng gói PKQQ2000244 & PKQQ2000250 (Lot VE260813-004) & Đồng bộ giảm sản lượng VE10 + PO
* **Ngày sửa:** `2026-08-22`
* **Màn hình liên quan (TCode):** `[HN523] - Đóng gói Hà Nam (Packaging & Box Matching)`
* **Triệu chứng lỗi:** Cần hủy 2 tem đóng gói `PKQQ2000244` (376 con) và `PKQQ2000250` (342 con) thuộc Lot `VE260813-004` (tổng 718 con) để trả lại sản lượng chưa đóng gói tại HN523.
* **Nguyên nhân gốc & Thao tác:**
  1. Đóng gói box lẻ cần rã để đóng lại. Đã tạo bảng backup: `STB_MaterialLotInfo_BK_20260822_HN523`, `STB_MaterialDocInfo_BK_20260822_HN523`, `STB_MaterialDocDetail_BK_20260822_HN523`, `STB_MaterialDocLotInfo_BK_20260822_HN523`, `STB_ProdRouteHist_BK_20260822_HN523`, `STB_ProdRouteSummary_BK_20260822_HN523`, `STB_ProductionOrderInfo_BK_20260822_HN523`.
  2. Xóa 2 sub-lot `MaterialLotNo` `20260820000403` và `20260820000409` trong `STB_MaterialLotInfo`.
  3. Hủy và xóa chứng từ `260820000261` & `260820000267` trong `STB_MaterialDocInfo`, `STB_MaterialDocLotInfo`, `STB_MaterialDocDetail` (dùng `CONTEXT_INFO 0x999997` bypass trigger `tgMaterialDocDetailForDelete`).
  4. Giảm trừ 718 con ở công đoạn cuối `VE10` (`STB_ProdRouteHist`), bảng tổng hợp ngày `STB_ProdRouteSummary` và sản lượng hoàn thành PO `260813000005` (`STB_ProductionOrderInfo`).
* **File script deploy:** `sql/fix_hn523_cancel_packing_PKQQ2000244_250.sql` (Deploy qua `deploy_tool.ps1` thành công 100%).

---

### [B310] — 📍 ID_35 Lỗi Tạo PO thủ công "공정 라우팅 정보가 없습니다" do BasicRoutingCode không khớp WorkCenterCode (Hưng Yên VVT_F5)
* **Ngày ghi nhận:** `2026-08-24`
* **Màn hình liên quan (TCode):** `[B310] - Quản lý PO (ProductionOrderInfo)` / Popup "Tạo PO thủ công"
* **Triệu chứng lỗi:** Khi tạo PO thủ công cho mã nguyên liệu/thành phẩm (ví dụ `ECVT30-260`) tại nhà máy Hưng Yên (`VVT_F5`), hệ thống văng popup lỗi `Failed to save`:
  ```text
  공정 라우팅 정보가 없습니다.
  ECVT30-260 / 1.00000
  10000.00000
  @PONo :::: 260824000029
  ```
* **Nguyên nhân gốc (Root Cause):**
  * Trong Stored Procedure `usp_DoCreateProductionOrder` (dòng 183 - 213), lệnh `INSERT INTO STB_ProductionOrderRouting` lọc theo:
    ```sql
    WHERE BRD.BasicRoutingCode = @BasicRoutingCode 
      AND BRD.CompanyCode = @CompanyCode 
      AND BRD.WorkCenterCode = @WorkCenterCode
    ```
  * Mã `ECVT30-260` đang được gán `BasicRoutingCode = 'D60_3400F'`. Tuy nhiên, trong `STB_BasicRoutingDetail`, mã `D60_3400F` chỉ được cấu hình cho `VVT_F1` (Bắc Ninh) và `VNT_F4` (Bắc Giang 2), hoàn toàn **không có bản ghi nào cho `VVT_F5` (Hưng Yên)** ➔ `@@ROWCOUNT = 0` ➔ Kích hoạt lỗi localized error.
* **Script truy vết (Trace Script):**
  ```sql
  -- 1. Xem Routing hiện tại của Model
  SELECT MaterialCode, MaterialName, BasicRoutingCode, MaterialTypeCode, ProductGroupCode 
  FROM STB_MaterialMaster 
  WHERE MaterialCode = 'ECVT30-260';

  -- 2. Kiểm tra WorkCenterCode trong BasicRoutingDetail
  SELECT BasicRoutingCode, RouteCode, RouteIndex, CompanyCode, WorkCenterCode, IsInputRoute, IsOutputRoute
  FROM STB_BasicRoutingDetail 
  WHERE BasicRoutingCode = 'D60_3400F'
  ORDER BY RouteIndex;

  -- 3. Kiểm tra các mã BasicRoutingCode chuẩn của Hưng Yên (VVT_F5)
  SELECT DISTINCT BasicRoutingCode, CompanyCode, WorkCenterCode 
  FROM STB_BasicRoutingDetail 
  WHERE WorkCenterCode = 'VVT_F5';
  ```
* **Phương án xử lý (SQL Fix Patch):**
  ```sql
  -- Phương án 1: Cập nhật lại BasicRoutingCode chuẩn của Hưng Yên cho Model
  UPDATE STB_MaterialMaster 
  SET BasicRoutingCode = 'HY_MainRoutingBigSiz'
  WHERE MaterialCode = 'ECVT30-260';
  ```
* **Tham chiếu KB:** [KB_03_03_SCREEN_BUGS_B.md § B310 Lỗi 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_03_SCREEN_BUGS_B.md#lỗi-3-공정-라우팅-정보가-없습니다-không-có-thông-tin-routing-công-đoạn-khi-tạo-po-thủ-công-tại-b310), [KB_09_SCREEN_BUG_FIXBOOK.md § B310 #4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#b310)

---

### [B552] — 📍 ID_36 Xóa 25 bản ghi kết quả cắt điện cực thừa (STT 6-30) cho Lot VVQO3020001E17
* **Ngày sửa:** `2026-08-31`
* **Màn hình liên quan (TCode):** `[B552] - Vietnam_Kết quả đo điện cực (Tab Slitting - Cắt điện cực)`
* **Triệu chứng lỗi:** OP bấm tạo chia cuộn nhiều lần khiến lưới kết quả cắt sinh ra 30 cuộn (Seq 1 ➔ 30). Cần xóa bỏ các cuộn thừa từ Seq 6 đến Seq 30, giữ lại đúng 5 cuộn hợp lệ (Seq 1 ➔ 5).
* **Nguyên nhân gốc (Root Cause):** Thao tác lặp tại màn hình tạo nhiều mẻ cắt trùng nhau cho cùng một cuộn Lot mẹ `VVQO3020001E17`.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - Snapshot file: `tools/backups/preflight_20260831_171127_STB_ElectrodeSlittingResult_deploy_preflight.json`
  - Audit history table: `SmartFactoryV2.dbo.STB_ElectrodeSlittingResultHist` (25 bản ghi, Flag = `DELETE`).
* **Phương án sửa lỗi & Script Deploy:**
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;
  INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID)
  SELECT ElectrodeLotNumber, Seq, 'DELETE', GETDATE(), N'SYSTEM_AI_FIX'
  FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
  WHERE ElectrodeLotNumber = 'VVQO3020001E17' AND Seq BETWEEN 6 AND 30;

  DELETE FROM STB_ElectrodeSlittingResult
  WHERE ElectrodeLotNumber = 'VVQO3020001E17' AND Seq BETWEEN 6 AND 30;
  COMMIT TRANSACTION;
  ```
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L210), [HOTFIX_LOG.md § ID_29](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/HOTFIX_LOG.md#L287)
