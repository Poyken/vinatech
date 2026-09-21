<!--
AI-READY METADATA
Purpose: Nhật ký ghi chép lịch sử xử lý bug & hotfix đã được AI triển khai thành công
Scope: Hotfix History Registry
Single Source of Truth: HOTFIX_LOG.md (Lịch sử hotfixes) & KB_09 (Sổ tay cứu hộ)
Related Files:
  - [KB_09_SCREEN_BUG_FIXBOOK.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md)
  - [record_hotfix.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/tools/record_hotfix.ps1)
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


> 💡 **Lưu trữ:** Các hotfix cũ hơn (Tháng 07 & 08/2026, 24 entries) đã được chuyển vào [HOTFIX_LOG_2026_JUL_AUG.md](HOTFIX_LOG_2026_JUL_AUG.md).

### [B530]/[POP Screen] — 📍 ID_52 Cập nhật chính xác tên máy công đoạn Cuốn Winding (V-22_HY) cho 3 Lot Hưng Yên
* **Ngày sửa:** `2026-09-21`
* **Màn hình liên quan (TCode / Module):** `[B530] - Nhập sản lượng / Kiosk POP Hưng Yên`
* **Triệu chứng lỗi:**
  - 3 Lot bị gán nhầm mã máy sấy chân không (`Dry Vacuum Oven`) thay vì máy cuốn (`Winding`) tại công đoạn cuốn `V-22_HY`:
    + `VVQR203R072777`: Bị gán `Dry Vacuum Oven C#2-01` (`VVMHY45`) thay vì `Winding C#2-02` (`VVMHY40`).
    + `VVQR213R072722`: Bị gán `Dry Vacuum Oven C#9-01` (`VVMHY136`) thay vì `Winding C#9-01` (`VVMHY130`).
    + `VVQR083R072762`: Bị gán `Dry Vacuum Oven C#9-01` (`VVMHY136`) thay vì `Winding C#9-01` (`VVMHY130`).
* **Nguyên nhân gốc (Root Cause):**
  - Trong quá trình chốt công đoạn đầu `V-22_HY` trên UI B530 hoặc cấu hình máy quét trạm, công nhân chọn nhầm thiết bị Dry Vacuum Oven thuộc cùng cụm chuyền.
* **Phương án sửa lỗi & Backup (Thực thi thành công):**
  - Đã sao lưu pre-flight snapshot tự động qua `deploy_tool.ps1`.
  - Cập nhật trực tiếp trên bảng `SmartFactoryV2.dbo.STB_ProdRouteHist`:
    + `ProdRouteHistNo = '20260921001516'` -> `MachineCode = 'VVMHY40'` (`Winding C#2-02`).
    + `ProdRouteHistNo = '20260921001529'` -> `MachineCode = 'VVMHY130'` (`Winding C#9-01`).
    + `ProdRouteHistNo = '20260921001420'` -> `MachineCode = 'VVMHY130'` (`Winding C#9-01`).
    + `ChangeUserID = 'vanduc'`, `ChangeDateTime = GETDATE()`.
  - File hotfix: `sql/hotfixes/hotfix_20260921_UPDATE_MACHINE_NAME_3LOTS.sql`.

### [POP Screen] — 📍 ID_51 Xóa kẹt trạng thái công đoạn hoàn thành trên Kiosk POP (MongoToMesPerformance)
* **Ngày sửa:** `2026-09-19`
* **Màn hình liên quan (TCode / URL):** `[POP Screen] - pop.vinatech.com/pop/screen (Kiosk HY Cell Line #17)`
* **Triệu chứng lỗi:** 
  - Lot `VVQR023R060672` (ControlNo `20260902000418`) đã bị xóa bản ghi trong `STB_ProdRouteHist` nhưng trên giao diện POP Kiosk vẫn hiển thị công đoạn 24 (`Curling`), 25 (`Sleeving`), 26 (`Aging`) có dấu tích xanh `[✓]`, số lượng `987/987`, thẻ Lot mang nhãn `[Visual Inspection (Ngoại quan)]`, và nút "Ghi nhận sản xuất" bị khóa báo `■ Công đoạn này đã hoàn thành`.
* **Nguyên nhân gốc (Root Cause):** 
  - Kiosk POP Web KHÔNG đọc trực tiếp từ `STB_ProdRouteHist` để render trạng thái tiến độ Lot, mà đọc từ bảng đồng bộ trung gian: **`SmartFactoryV2.dbo.MongoToMesPerformance`**.
  - Khi công nhân bấm chốt trên Kiosk, dữ liệu được ghi vào `MongoToMesPerformance` với `IsDone = 1`, `TotalProdQty = 987`, `SourceType = 'MANUAL'`.
  - Nếu chỉ xóa trong `STB_ProdRouteHist` mà không xóa bản ghi tương ứng trong `MongoToMesPerformance`, Kiosk POP vẫn coi các công đoạn đó là đã hoàn thành và khóa nút chốt.
* **Phương án sửa lỗi & Kiến thức chuẩn hóa:**
  1. Snapshot backup bảng `MongoToMesPerformance` cho Barcode cần xử lý.
  2. `DELETE FROM SmartFactoryV2.dbo.MongoToMesPerformance WHERE Barcode = @Barcode AND RouteCode IN (...)`.
  3. Cập nhật `STB_SetInfo.CurrentRouteCode = 'V-24_HY'` để đồng bộ lại con trỏ công đoạn.
  4. F5 Kiosk POP ➔ Giao diện nhả khóa, nút "Ghi nhận sản xuất" sáng lại bình thường.

### [C443] — 📍 ID_26 Xóa dữ liệu kết quả đo C443 công đoạn Cuốn (VE01) Lot VE260914-001
* **Ngày sửa:** `2026-09-16`
* **Màn hình liên quan (TCode):** `[C443] - Vietnam_inspectionPQC`
* **Triệu chứng lỗi:** Lot `VE260914-001` (ControlNo `20260914000296`) bị khóa công đoạn Cuốn (Winding `VE01`) trên màn hình C443, cần xóa để QC đo lại từ đầu.
* **Nguyên nhân gốc (Root Cause):** 
  - Tại C443: Đã ghi nhận 123 dòng đo trong `STB_CommInspMeasureHist` và `ItemQty > 0` trong `STB_CommInspDocItem` (Phiếu `20260914000208`) làm khóa ô nhập liệu C443.
  - Tại HNC321: Kiểm tra không có bản ghi phế nào trong `STB_DefectRepairInfo` (0 rows).
* **Phương án sửa lỗi & Backup (Thực thi thành công):**
  - **Snapshot Backup:** Đã sao lưu toàn bộ tại `tools/backups/backup_VE260914-001_pre_fix_20260916.json` (15 rows DocItem, 123 rows MeasureHist).
  - **SQL Patch đã deploy:**
    1. Xóa 123 dòng đo công đoạn `VE01` trong `STB_CommInspMeasureHist`.
    2. Reset `ItemQty = 0` cho 15 hạng mục `VE01` trong `STB_CommInspDocItem`.
    - Script: `sql/hotfix_20260916_080000_CLEAR_WINDING_C443_VE260914-001.sql`.

### [C443]/[HNC321] — 📍 ID_25 Xóa dữ liệu kết quả đo C443 và lỗi phế HNC321 công đoạn Cuốn (VE01) Lot VE260914-002
* **Ngày sửa:** `2026-09-15`
* **Màn hình liên quan (TCode):** `[C443] - Vietnam_inspectionPQC`, `[HNC321] - QC_InputQtyForProductCheck (Hà Nam)`
* **Triệu chứng lỗi:** Người dùng yêu cầu xóa Lot `VE260914-002` (ControlNo `20260914000299`) ở màn hình HNC321 và màn hình C443 công đoạn cuốn (Winding `VE01`) để làm lại kết quả kiểm tra chất lượng & sửa lỗi phế.
* **Nguyên nhân gốc (Root Cause):** 
  - Tại C443: Đã ghi nhận 123 dòng đo trong `STB_CommInspMeasureHist` và `ItemQty = 9` trong `STB_CommInspDocItem` (Phiếu `20260915000294`) làm khóa lưới C443.
  - Tại HNC321: Đang tồn tại 3 bản ghi phế công đoạn cuốn (`VE01_11`, `VE01_12`, `VE01_30`) trong `STB_DefectRepairInfo`.
* **Phương án sửa lỗi & Backup (Thực thi thành công):**
  - **Snapshot Backup:** Đã sao lưu toàn bộ trước khi xóa tại `tools/backups/backup_VE260914-002_pre_fix_20260915.json` (3 rows Defect, 15 rows DocItem, 123 rows MeasureHist).
  - **SQL Patch đã deploy:**
    1. Xóa 123 dòng đo công đoạn `VE01` trong `STB_CommInspMeasureHist`.
    2. Reset `ItemQty = 0` cho 15 hạng mục `VE01` trong `STB_CommInspDocItem`.
    3. Xóa 3 dòng phế `VE01` trong `STB_DefectRepairInfo` (giữ nguyên lỗi `VE03`).
    - Script: `sql/hotfix_20260915_174900_CLEAR_WINDING_C443_HNC321_VE260914-002.sql`.

### [F430] — 📍 ID_24 Chuyển đổi cơ chế kiểm tra FIFO từ NGÀY sang THÁNG (usp_DoValidateFIFO)
* **Ngày sửa:** `2026-09-11`
* **Màn hình liên quan (TCode):** `[F430] - Xuất kho nguyên vật liệu WMS`, `[F721] - Danh mục tồn kho NVL`
* **Triệu chứng lỗi:** Quét xuất Lot NVL (ví dụ `ML20260507002369` mã `GCSN00-002`) báo lỗi vi phạm FIFO: *"Trước tiên hãy lấy nguyên liệu nhập trước... Tồn tại mã vạch này được nhập trước (/ Sản Xuất trước): 20260522000148 ~ ML20260402000402"*, mặc dù cả 2 Lot đều sản xuất trong cùng tháng 03/2026.
* **Nguyên nhân gốc (Root Cause):** SP lõi `[dbo].[usp_DoValidateFIFO]` trên DB `SmartFactoryV2` đang so sánh ngày sản xuất vendor (`LotAttr10`) theo định dạng ngày `'yyyy-MM-dd'` (chế độ Audit Bắc Ninh của Mr Mạnh kích hoạt từ 2025-11-20), khiến hệ thống so sánh ngày 04 < ngày 20 và chặn xuất kho.
* **Phương án sửa lỗi (SQL Patch / Action):**
  - Chuyển định dạng so sánh tại cả 4 vị trí trong `usp_DoValidateFIFO` từ `'yyyy-MM-dd'` sang `'yyyy-MM'`:
    + Vị trí 1 (Dòng 83): `@Lotattr10fifo` (Lấy ngày SX của Lot cũ).
    + Vị trí 2 (Dòng 93): `set @CreateDateTime`.
    + Vị trí 3 (Dòng 123): `@A1` & `@B1` (Lấy thông tin Lot cũ để in ra thông báo lỗi).
    + Vị trí 4 (Dòng 154): Điều kiện `IF EXISTS` chặn xuất kho.
  - *Đã deploy trực tiếp lên Live DB SmartFactoryV2 vào lúc 14:22:22 ngày 2026-09-11. Hệ thống F430 hiện đã cho phép xuất tự do giữa các Lot sản xuất trong cùng một tháng.*

### [B725] — 📍 ID_37 Xóa 10 bản ghi kiểm kê nhập nhầm cho chuyền Điện cực Bắc Ninh (ElectrodeBN)
* **Ngày sửa:** `2026-09-02`
* **Màn hình liên quan (TCode):** `[B725] - Kiểm kê cuối tháng (ViewCategorieInventory)`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_VN_ITEM_CHECK`
* **Triệu chứng lỗi:** Người dùng gửi ảnh chụp màn hình kiểm kê B725 của chuyền `ElectrodeBN` có 14 dòng, yêu cầu xóa chính xác **10 dòng khoanh đỏ** và giữ nguyên 4 dòng còn lại (STT 2, 3, 12, 13).
* **Nguyên nhân gốc (Root Cause):** Người vận hành nhập nhầm số liệu kiểm kê thực tế tại màn hình B725.
* **Cơ chế sao lưu (Backup & Pre-flight):**
  - Snapshot file preflight: `tools/backups/preflight_20260902_102816_STB_VN_ITEM_CHECK_deploy_preflight.json` (Lưu trọn vẹn 10 dòng trước khi xóa).
* **Phương án sửa lỗi & Script Deploy:**
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;

  -- 1. [BEFORE] Khảo sát chính xác 10 bản ghi cần xóa
  SELECT 
      ID, CODELINE, NAMELINE, CATEGORIESCHECK, QTY, TYPEINPUT, INPUT, CODENAME, REMARK, CreateDateTime, CreateUserID
  FROM STB_VN_ITEM_CHECK WITH(NOLOCK)
  WHERE ID IN (47692, 47638, 47680, 47704, 47703, 47702, 47713, 47679, 47672, 47664)
  ORDER BY ID ASC;

  -- 2. [EXECUTION] Xóa chính xác 10 bản ghi theo ID
  DELETE FROM STB_VN_ITEM_CHECK
  WHERE ID IN (47692, 47638, 47680, 47704, 47703, 47702, 47713, 47679, 47672, 47664);

  -- 3. [AFTER] Kiểm tra lại kết quả (Kỳ vọng: 0 dòng)
  SELECT 
      ID, CODELINE, NAMELINE, CATEGORIESCHECK, QTY, TYPEINPUT, INPUT, CODENAME, REMARK, CreateDateTime, CreateUserID
  FROM STB_VN_ITEM_CHECK WITH(NOLOCK)
  WHERE ID IN (47692, 47638, 47680, 47704, 47703, 47702, 47713, 47679, 47672, 47664);

  COMMIT TRANSACTION;
  GO
  ```
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § B725](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#b725)

---

### [B723] — 📍 ID_38 Cập nhật độ dày Model 0820-low và bổ sung 9 mã NVL điện cực vào danh mục kiểm kê
* **Ngày sửa:** `2026-09-02`
* **Màn hình liên quan (TCode):** `[B723] - Hạng mục kiểm kê (CheckItems)`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_VN_ITEM_CHECK`
* **Triệu chứng lỗi:**
  1. Hạng mục kiểm kê cho Model 0820-low bị sai độ dày: Cuộn dương đang để `SREBO85` (200) thay vì `SREBL85L` (120), Cuộn âm đang để `SRFYO85` (180) thay vì `SRFYL85` (120).
  2. Thiếu 9 mã điện cực mới trong danh mục kiểm kê của chuyền `ElectrodeBN` (Bắc Ninh) và `VVC-ELECTRODE-LINE` (Việt Nam).
  3. Bản ghi ID `47831` bị thiếu đơn vị tính `UNIT`.
* **Nguyên nhân gốc (Root Cause):** Master data kiểm kê `STB_VN_ITEM_CHECK` chưa được cập nhật khi có quy cách sản phẩm mới và thay đổi thông số kỹ thuật NVL điện cực.
* **Cơ chế sao lưu (Backup & Pre-flight):**
  - Snapshot file preflight: `tools/backups/preflight_20260902_102816_STB_VN_ITEM_CHECK_deploy_preflight.json`
* **Phương án sửa lỗi & Script Deploy:**
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;

  -- 1. Sửa độ dày model 0820-low
  UPDATE STB_VN_ITEM_CHECK
  SET CODENAME = N'SREBL85L', INPUT = N'BY85 120(A301) (độ rộng 13.7 -0820-low)(+)', ChangeDateTime = GETDATE(), ChangeUserID = N'ADMIN'
  WHERE CODENAME = N'SREBO85' AND INPUT LIKE N'%0820-low%(+)%';

  UPDATE STB_VN_ITEM_CHECK
  SET CODENAME = N'SRFYL85', INPUT = N'YP 85 120(A301)(độ rộng 13.7 -0820-low)(-)', ChangeDateTime = GETDATE(), ChangeUserID = N'ADMIN'
  WHERE CODENAME = N'SRFYO85' AND INPUT LIKE N'%0820-low%(-)%';

  -- 2. Bổ sung 9 mã điện cực mới cho 2 chuyền (ElectrodeBN & VVC-ELECTRODE-LINE)
  DECLARE @NewItems TABLE (CODENAME NVARCHAR(50), INPUT NVARCHAR(500), UNIT NVARCHAR(20));
  INSERT INTO @NewItems (CODENAME, INPUT, UNIT) VALUES
  (N'SRFYL85', N'YP 85 120(A301)(độ rộng 13.7 -0820-low)(-)', N'M'),
  (N'SREBL85L', N'BY85 120(A301) (độ rộng 13.7 -0820-low)(+)', N'M'),
  (N'CREYO85B', N'Coating-Roll Etching -YP 85 200(A-401D) (+)', N'M'),
  (N'SRFYN85L', N'YP 180 (Độ rộng 23.7 -1030-10F LOW) cuộn âm', N'M'),
  (N'SREBO85L', N'BY 85 200 (Độ rộng 23.7 -1030-10F LOW) cuộn dương', N'M'),
  (N'CRECO85A', N'Coating - Roll Etching - CY85 200 (+) A301', N'M'),
  (N'CREBK85L', N'Điện cực BY 116 (A301) Cuộn Dương', N'M'),
  (N'CRFBO83', N'Điện cực BA21E-200 Cuộn âm', N'M'),
  (N'CRNCM85-001', N'Coatingroll-NCM 85 (VPC) (+)', N'M');

  -- Insert nếu chưa tồn tại
  INSERT INTO STB_VN_ITEM_CHECK (DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, REMARK, CODENAME, INPUT, UNIT, CreateDateTime, CreateUserID)
  SELECT N'SẢN XUẤT', N'ElectrodeBN', N'Điện cực Bắc Ninh', N'Điện cực Việt Nam', N'NVL', N'', n.CODENAME, n.INPUT, n.UNIT, GETDATE(), N'ADMIN'
  FROM @NewItems n
  WHERE NOT EXISTS (SELECT 1 FROM STB_VN_ITEM_CHECK c WITH(NOLOCK) WHERE c.CODELINE = N'ElectrodeBN' AND c.CODENAME = n.CODENAME AND c.INPUT = n.INPUT);

  INSERT INTO STB_VN_ITEM_CHECK (DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, REMARK, CODENAME, INPUT, UNIT, CreateDateTime, CreateUserID)
  SELECT N'SẢN XUẤT', N'VVC-ELECTRODE-LINE', N'베트남 전극라인 Line điện cực Việt Nam', N'Điện cực Việt Nam', N'NVL', N'', n.CODENAME, n.INPUT, n.UNIT, GETDATE(), N'ADMIN'
  FROM @NewItems n
  WHERE NOT EXISTS (SELECT 1 FROM STB_VN_ITEM_CHECK c WITH(NOLOCK) WHERE c.CODELINE = N'VVC-ELECTRODE-LINE' AND c.CODENAME = n.CODENAME AND c.INPUT = n.INPUT);

  -- 3. Cập nhật Unit cho ID 47831
  UPDATE STB_VN_ITEM_CHECK SET UNIT = 'M' WHERE ID = 47831;

  COMMIT TRANSACTION;
  ```
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § B723](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#b723)

---

### [B552] — 📍 ID_39 Xóa 10 bản ghi kết quả cắt điện cực thừa (STT 16-25) cho Lot VVQP0920001E11
* **Ngày sửa:** `2026-09-03`
* **Màn hình liên quan (TCode):** `[B552] - Vietnam_Kết quả đo điện cực (Tab Slitting - Cắt điện cực)`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ElectrodeSlittingResult`, `SmartFactoryV2.dbo.STB_ElectrodeSlittingResultHist`
* **Triệu chứng lỗi:** OP tại máy cắt điện cực VVEP016 yêu cầu xóa 10 dòng kết quả chia cuộn thừa (STT 16 đến 25), giữ lại đúng 15 cuộn hợp lệ (Seq 1 ➔ 15).
* **Nguyên nhân gốc (Root Cause):** Thao tác cắt chia cuộn dư hoặc lỗi dòng kết quả cần dọn dẹp. Giao diện B552 không có nút xóa dòng kết quả cắt nên yêu cầu IT/MES xử lý qua DB.
* **Cơ chế sao lưu (Backup & Pre-flight):**
  - Snapshot file preflight: `tools/backups/preflight_20260903_084109_STB_ElectrodeSlittingResult_deploy_preflight.json` (10 bản ghi đầy đủ trước khi xóa).
  - Bảng Audit history: `SmartFactoryV2.dbo.STB_ElectrodeSlittingResultHist` (10 bản ghi, Flag = `DELETE`, User = `SYSTEM_AI_FIX`).
* **Phương án sửa lỗi & Script Deploy (Thực thi thành công):**
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;

  -- 1. [AUDIT LOG] Ghi lưu vết lịch sử trước khi xóa (Chuẩn SOP KB_09 § B552)
  INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID)
  SELECT ElectrodeLotNumber, Seq, 'DELETE', GETDATE(), N'SYSTEM_AI_FIX'
  FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
  WHERE ElectrodeLotNumber = 'VVQP0920001E11' AND Seq BETWEEN 16 AND 25;

  -- 2. [EXECUTION] Xóa 10 bản ghi cắt thừa
  DELETE FROM STB_ElectrodeSlittingResult
  WHERE ElectrodeLotNumber = 'VVQP0920001E11' AND Seq BETWEEN 16 AND 25;

  COMMIT TRANSACTION;
  GO
  ```
* **Kết quả nghiệm thu:**
  - `STB_ElectrodeSlittingResult`: Còn lại chính xác **15 bản ghi** (`Seq` từ 1 đến 15).
  - Không có bất kỳ lỗi phát sinh nào, dữ liệu hạ nguồn an toàn 100%.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L210), [HOTFIX_LOG.md § ID_36](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/HOTFIX_LOG.md#L499)

---

### [B552] — 📍 ID_40 Hủy / Xóa mẻ trộn điện cực thừa (Mixing) cho Lot VVQR0120001E38
* **Ngày sửa:** `2026-09-03`
* **Màn hình liên quan (TCode):** `[B552] - Vietnam_Kết quả đo điện cực (Tab Mixing - Trộn điện cực)`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ElectrodeMixStepInfo`, `SmartFactoryV2.dbo.STB_ElectrodeMixInfo`, `SmartFactoryV2.dbo.STB_SetInfo`
* **Triệu chứng lỗi:** OP tại công đoạn cân trộn điện cực yêu cầu xóa mẻ trộn điện cực thừa của Lot `VVQR0120001E38` (Model `CREHCO85`, 181.41 kg, gồm 10 bước cân) để hủy mẻ hoặc cân lại.
* **Nguyên nhân gốc (Root Cause):** Mẻ trộn cân đêm 01/09/2026 không chạy đến hoặc đổi kế hoạch sản xuất, chưa tráng Coating (`STB_ElectrodeCoatingInfo = 0`).
* **Cơ chế sao lưu (Backup & Pre-flight):**
  - Snapshot file preflight:
    - `tools/backups/preflight_20260903_085431_STB_ElectrodeMixStepInfo_deploy_preflight.json` (10 bản ghi).
    - `tools/backups/preflight_20260903_085436_STB_ElectrodeMixInfo_deploy_preflight.json` (1 bản ghi).
    - `tools/backups/preflight_20260903_085436_STB_SetInfo_deploy_preflight.json` (1 bản ghi).
  - Rollback script chuẩn bị sẵn: `sql/rollback_20260903_B552_DELETE_MIXING_VVQR0120001E38.sql`.
* **Phương án sửa lỗi & Script Deploy (Thực thi thành công):**
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;

  -- 1. Xóa chi tiết các bước cân nguyên vật liệu (10 bước cân)
  DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'VVQR0120001E38';

  -- 2. Xóa header mẻ trộn điện cực (1 bản ghi)
  DELETE FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = 'VVQR0120001E38';

  -- 3. Xóa mã khởi tạo Lot thùng / SetInfo (1 bản ghi)
  DELETE FROM STB_SetInfo WHERE Barcode = 'VVQR0120001E38';

  COMMIT TRANSACTION;
  GO
  ```
* **Kết quả nghiệm thu:**
  - `STB_ElectrodeMixStepInfo`: Còn lại **0 bản ghi**.
  - `STB_ElectrodeMixInfo`: Còn lại **0 bản ghi**.
  - `STB_SetInfo`: Còn lại **0 bản ghi**.
  - Không có bất kỳ lỗi phát sinh nào, dữ liệu hạ nguồn an toàn 100%.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L211), [KB_05_01 § 8.10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#810-quy-trình-dọn-dẹp--xóa-mẻ-trộn-điện-cực-thừa-electrode-mixing-cancellation-sop)

---

### [B552] — 📍 ID_41 Xóa 45 bản ghi kết quả cắt điện cực thừa cho Lot VVQR0720001E66 (STT 11-50) & VVQP0720001E11 (STT 16-20)
* **Ngày sửa:** `2026-09-08`
* **Màn hình liên quan (TCode):** `[B552] - Vietnam_Kết quả đo điện cực (Tab Slitting - Cắt điện cực)`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ElectrodeSlittingResult`, `SmartFactoryV2.dbo.STB_ElectrodeSlittingResultHist`
* **Triệu chứng lỗi:** OP tại máy chia cuộn điện cực yêu cầu xóa các cuộn cắt thừa/lỗi:
  1. Lot `VVQR0720001E66` (Model 35105 / Slitting Code `CY`): Xóa STT từ 11 đến 50 (40 bản ghi).
  2. Lot `VVQP0720001E11` (Model 35105 / Slitting Code `HC`): Xóa STT từ 16 đến 20 (5 bản ghi).
* **Nguyên nhân gốc (Root Cause):** Thao tác cắt chia cuộn dư/lỗi dòng kết quả cần dọn dẹp để chạy lại hoặc chuẩn hóa dữ liệu. Giao diện B552 không có nút xóa dòng kết quả cắt nên cần xử lý qua DB.
* **Cơ chế sao lưu (Backup & Pre-flight):**
  - Snapshot file preflight: `tools/backups/preflight_20260908_131509_STB_ElectrodeSlittingResult_deploy_preflight.json` (40 bản ghi đầy đủ trước khi xóa).
  - Bảng Audit history: `SmartFactoryV2.dbo.STB_ElectrodeSlittingResultHist` (45 bản ghi, Flag = `DELETE`, User = `SYSTEM_AI_FIX`).
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260908_131431_FIX_B552_SLITTING_DEL_SEQ.sql`
  ```sql
  USE SmartFactoryV2;
  GO

  BEGIN TRANSACTION;

  -- 1. [AUDIT LOG] Ghi lưu vết lịch sử trước khi xóa (Chuẩn SOP KB_09 § B552)
  INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID)
  SELECT ElectrodeLotNumber, Seq, 'DELETE', GETDATE(), N'SYSTEM_AI_FIX'
  FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
  WHERE (ElectrodeLotNumber = 'VVQR0720001E66' AND Seq BETWEEN 11 AND 50)
     OR (ElectrodeLotNumber = 'VVQP0720001E11' AND Seq BETWEEN 16 AND 20);

  -- 2. [EXECUTION] Xóa 45 bản ghi cắt thừa theo yêu cầu người dùng
  DELETE FROM STB_ElectrodeSlittingResult
  WHERE (ElectrodeLotNumber = 'VVQR0720001E66' AND Seq BETWEEN 11 AND 50)
     OR (ElectrodeLotNumber = 'VVQP0720001E11' AND Seq BETWEEN 16 AND 20);

  COMMIT TRANSACTION;
  GO
  ```
* **Kết quả nghiệm thu:**
  - `VVQR0720001E66`: Đã xóa thành công 40 bản ghi (Seq 11 ➔ 50). Còn lại chính xác **12 bản ghi** (Seq 1 ➔ 10 và Seq 51, 52).
  - `VVQP0720001E11`: Đã xóa thành công 5 bản ghi (Seq 16 ➔ 20). Còn lại chính xác **15 bản ghi** (Seq 1 ➔ 15).
  - `STB_ElectrodeSlittingResultHist`: Đã ghi nhận đầy đủ 45 dòng audit log.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L210), [HOTFIX_LOG.md § ID_36](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/HOTFIX_LOG.md#L515), [HOTFIX_LOG.md § ID_39](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/HOTFIX_LOG.md#L638)

---

### [B470]/[B552] — 📍 ID_42 Hủy / Xóa mẻ trộn điện cực thừa Lot VVQR0720001E40
* **Ngày sửa:** `2026-09-10`
* **Màn hình liên quan (TCode):** `[B470] - Mixing Info & [B552] - Kết quả đo điện cực`
* **Bảng liên quan:** `STB_ElectrodeMixStepInfo`, `STB_ElectrodeMixInfo`, `STB_SetInfo`
* **Triệu chứng lỗi:** Mẻ trộn điện cực `VVQR0720001E40` đã cân trộn nhưng không chạy tiếp tráng phủ Coating do đổi kế hoạch sản xuất. Cần xóa sạch mẻ trộn để tránh rác hệ thống.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - Snapshot file: `tools/backups/backup_VVQR0720001E40_20260910_085658.json` & `preflight_20260910_085809_STB_ElectrodeMixStepInfo_deploy_preflight.json`.
* **Phương án sửa lỗi & Script Deploy:**
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;
  DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'VVQR0720001E40';
  DELETE FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = 'VVQR0720001E40';
  DELETE FROM STB_SetInfo WHERE Barcode = 'VVQR0720001E40';
  COMMIT TRANSACTION;
  GO
  ```
* **Kết quả nghiệm thu:** Xóa thành công 8 dòng MixStep, 1 dòng MixInfo, 1 dòng SetInfo. Đã kiểm tra `STB_ElectrodeCoatingInfo = 0`.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L211), [KB_05_01 § 8.10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#810-quy-trình-dọn-dẹp--xóa-mẻ-trộn-điện-cực-thừa-electrode-mixing-cancellation-sop)

---

### [B470]/[B552] — 📍 ID_43 Hủy / Xóa mẻ trộn điện cực thừa Lot VVQQ2520001E79
* **Ngày sửa:** `2026-09-11`
* **Màn hình liên quan (TCode):** `[B470] - Mixing Info & [B552] - Kết quả đo điện cực`
* **Bảng liên quan:** `STB_ElectrodeMixStepInfo`, `STB_ElectrodeMixInfo`, `STB_SetInfo`
* **Triệu chứng lỗi:** Mẻ trộn điện cực âm `VVQQ2520001E79` thừa cần dọn dẹp theo SOP Mixing Cancellation.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - Snapshot file: `tools/backups/backup_VVQQ2520001E79_20260911_083440.json`.
* **Phương án sửa lỗi & Script Deploy:**
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;
  DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'VVQQ2520001E79';
  DELETE FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = 'VVQQ2520001E79';
  DELETE FROM STB_SetInfo WHERE Barcode = 'VVQQ2520001E79';
  COMMIT TRANSACTION;
  GO
  ```
* **Kết quả nghiệm thu:** Xóa thành công mẻ trộn, khôi phục trạng thái sạch cho phân xưởng điện cực.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L211)

---

### [B782]/[B530] — 📍 ID_44 Rollback chốt nhầm sản lượng Winding (V-22_HY) cho Lot VVQR103R072760 & VVQR103R072761
* **Ngày sửa:** `2026-09-11`
* **Màn hình liên quan (TCode):** `[B782] - LotTrackingInfo_VVT2 & [B530] - Nhập sản xuất`
* **Bảng liên quan:** `STB_ProdRouteHist`, `STB_DefectRepairInfo`
* **Triệu chứng lỗi:** OP chốt nhầm sản lượng công đoạn Quấn cuộn Winding (`V-22_HY`), khiến màn hình B782 hiển thị kết quả chốt nhầm và công đoạn kế tiếp `V-23_HY` tự động sinh ra chặn không cho OP chốt lại.
* **Nguyên nhân gốc (Root Cause):**
  - Winding là công đoạn đầu vào (`IsInputRoute = 1`). Khi chốt, hệ thống set `CompleteRoute = '1'` ở `V-22_HY` và tự sinh `V-23_HY` với số lượng còn lại sau khi trừ phế NG (`STB_DefectRepairInfo`).
  - Màn hình B782 lọc `CompleteRoute = 1` nên hiển thị kết quả.
  - Màn hình B530 check nếu công đoạn tiếp theo (`V-23_HY`) có số lượng (`@AftProdQty <> 0`) thì báo lỗi chặn `이미 실적처리 완료한 공정입니다`.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - `tools/backups/preflight_20260911_083313_STB_DefectRepairInfo_deploy_preflight.json` (4 dòng phế NG).
  - `tools/backups/preflight_20260911_083314_STB_ProdRouteHist_deploy_preflight.json` (4 dòng routing V-22 và V-23).
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260911_082405_B782_ROLLBACK_WINDING_20260911.sql`
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;
  -- 1. Xóa phế NG nhập nhầm ở Winding
  DELETE FROM STB_DefectRepairInfo 
  WHERE ControlNo IN ('20260910000423', '20260910000424') AND FindRouteCode = 'V-22_HY';

  -- 2. Xóa công đoạn downstream tự sinh (V-23_HY)
  DELETE FROM STB_ProdRouteHist 
  WHERE ControlNo IN ('20260910000423', '20260910000424') AND RouteCode = 'V-23_HY';

  -- 3. Reset CompleteRoute = NULL ở Winding (V-22_HY) để mở lại chốt
  UPDATE STB_ProdRouteHist 
  SET CompleteRoute = NULL 
  WHERE ControlNo IN ('20260910000423', '20260910000424') AND RouteCode = 'V-22_HY';

  COMMIT TRANSACTION;
  GO
  ```
* **Quy tắc vàng:** Ở công đoạn đầu vào (Winding `V-22`): KHÔNG xóa dòng `V-22_HY` mà chỉ đưa `CompleteRoute = NULL` để bảo toàn thông tin Lot trên B530. BẮT BUỘC xóa `V-23_HY` để giải phóng cổng chặn downstream.
* **Kết quả nghiệm thu:**
  - B782: 0 dòng hiển thị (ẩn hoàn toàn 2 Lot).
  - B530: Mở lại Winding `V-22_HY` để OP chốt lại số lượng chuẩn.
  - Toàn bộ dữ liệu NVL quét tại B540 được giữ nguyên vẹn.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B782]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md), [KB_03_01_OVERVIEW.md § 5.16](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md#L345)

---

### [B782]/[B530] — 📍 ID_45 Rollback Cascade chốt nhầm sản lượng Winding (V-22_HY) cho 6 Lot (Hưng Yên)
* **Ngày sửa:** `2026-09-12`
* **Màn hình liên quan (TCode):** `[B782] - LotTrackingInfo_VVT2 & [B530] - Nhập sản xuất`
* **Bảng liên quan:** `STB_ProdRouteHist`, `STB_DefectRepairInfo`, `STB_SetInfo`
* **Danh sách Lot:** `VVQQ203R072720`, `VVQQ213R072726`, `VVQR103R072760`, `VVQR103R072761`, `VVQR113R072731`, `VVQR113R072734`
* **ControlNo:** `20260820000244`, `20260821000637`, `20260910000423`, `20260910000424`, `20260911000196`, `20260911000199`
* **Triệu chứng lỗi:** OP chốt nhầm ở công đoạn Winding (`V-22_HY`), sau đó các ca tiếp tục chốt downstream xuống các công đoạn sau (V-23 đến V-28), thậm chí 2 Lot đã hoàn thành sản phẩm (`IsProdFinish = True`). Cần rollback toàn bộ về lại công đoạn Winding để OP nhập lại sản lượng chuẩn.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - `tools/backups/preflight_20260912_083037_STB_DefectRepairInfo_deploy_preflight.json` (21 dòng phế NG).
  - `tools/backups/preflight_20260912_083038_STB_ProdRouteHist_deploy_preflight.json` (32 dòng routing).
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260912_082956_B782_ROLLBACK_CASCADE_WINDING_6LOTS.sql`
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;
  -- 1. Xóa phế NG trên toàn bộ các công đoạn
  DELETE FROM STB_DefectRepairInfo WHERE ControlNo IN (...);
  -- 2. Xóa toàn bộ công đoạn downstream phát sinh sau Winding (V-23 -> V-28)
  DELETE FROM STB_ProdRouteHist WHERE ControlNo IN (...) AND RouteCode <> 'V-22_HY';
  -- 3. Reset CompleteRoute = NULL ở Winding (V-22_HY) để mở lại chốt B530
  UPDATE STB_ProdRouteHist SET CompleteRoute = NULL WHERE ControlNo IN (...) AND RouteCode = 'V-22_HY';
  -- 4. Reset trạng thái hoàn thành sản phẩm trên STB_SetInfo
  UPDATE STB_SetInfo SET IsProdFinish = 0, ProdFinishDateTime = NULL, ProdFinishJobDate = NULL WHERE ControlNo IN (...);
  COMMIT TRANSACTION;
  GO
  ```
* **Kết quả nghiệm thu:**
  - `STB_ProdRouteHist`: Đúng 6 dòng (chỉ còn lại `V-22_HY`, `CompleteRoute = NULL`).
  - `STB_DefectRepairInfo`: Đã xóa sạch 21 bản ghi phế NG.
  - `STB_SetInfo`: 6 Lot đều có `IsProdFinish = False`.
  - B530: Đã mở lại công đoạn Winding `V-22_HY` để OP chốt lại số lượng chuẩn.
  - Dữ liệu NVL scan tại B540 giữ nguyên 100%.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B782]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L356-L363)

---

### [B470]/[B552]/[electrode.weighing] — 📍 ID_46 Hủy / Xóa mẻ trộn điện cực thừa (Mixing) cho 4 Lot (VVQR1120001E44, E45, E48, E49)
* **Ngày sửa:** `2026-09-12`
* **Màn hình liên quan (TCode):** `[B470], [B552] - Tab Mixing, Ứng dụng cân điện cực (electrode.weighing)`
* **Bảng liên quan:** `STB_ElectrodeMixStepInfo`, `STB_ElectrodeMixInfo`, `STB_SetInfo`, `STB_ElectrodeCoatingInfo`
* **Danh sách Lot:** `VVQR1120001E49`, `VVQR1120001E48`, `VVQR1120001E44`, `VVQR1120001E45`
* **Triệu chứng lỗi:** OP ca đêm cân dang dở các bước mẻ trộn điện cực trên phần mềm cân, nhưng hiện tại không dùng đến / đổi kế hoạch, các mã Lot thừa hiển thị trên giao diện làm cản trở cấp phát NVL.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - `tools/backups/preflight_20260912_083636_STB_ElectrodeMixStepInfo_deploy_preflight.json` (17 dòng bước cân).
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260912_083621_ELECTRODE_MIXING_CANCEL_4LOTS.sql`
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;
  -- 1. Xóa các bước cân tạm của 4 Lot điện cực thừa
  DELETE FROM STB_ElectrodeMixStepInfo
  WHERE ElectrodeLotNumber IN ('VVQR1120001E49', 'VVQR1120001E48', 'VVQR1120001E44', 'VVQR1120001E45');
  COMMIT TRANSACTION;
  GO
  ```
* **Kết quả nghiệm thu:**
  - `STB_ElectrodeMixStepInfo`: 0 dòng (đã dọn sạch toàn bộ 17 bản ghi bước cân).
  - Giao diện lưới cân điện cực / B552 / B470: Không còn hiển thị 4 mã Lot thừa này nữa.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B552] #3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L220), [KB_05_01 §8.10](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#810-quy-trình-dọn-dẹp--xóa-mẻ-trộn-điện-cực-thừa-electrode-mixing-cancellation-sop)

---

### [POP/B523/V-28_HY] — 📍 ID_47 Rollback chốt sớm công đoạn đóng gói V-28_HY cho Lot VVQR013R072727 trên POP Kiosk
* **Ngày sửa:** `2026-09-17`
* **Màn hình liên quan (TCode):** `POP Web Kiosk (pop.vinatech.com/pop/screen) - Tab Đóng gói chia / Đóng gói đơn`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_MaterialLotInfo`, `SmartFactoryV2.dbo.STB_ProdRouteHist`, `VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY`
* **Danh sách Lot:** `VVQR013R072727` (ControlNo `20260901000137`, PO `260828000020`, Model `ECVT30-357`, Chuyền `HY Cell Line #2`)
* **Triệu chứng lỗi:** Trên giao diện Kiosk Web `pop.vinatech.com/pop/screen`, khi công nhân chuyển sang tab "Đóng gói chia" và bấm Đóng gói, hệ thống báo lỗi popup: `"Vượt quá số lượng còn lại. (Có thể đóng gói thêm: 0 EA)"` và hiển thị Còn lại: 0 EA.
* **Nguyên nhân gốc (Root Cause):** Vào lúc 12:05:12 trưa 17/09/2026, tài khoản `92603003` đã chốt sản lượng toàn bộ 1046 pcs ở công đoạn cuối V-28_HY trên MES WinForm (B530), làm phát sinh bản ghi BTP `20260917000404` trong `STB_MaterialLotInfo` và tiêu thụ hết hạn mức khả dụng của Lot trên POP Web.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - Snapshot JSON files:
    - `tools/backups/preflight_20260917_131551_STB_MaterialLotInfo_deploy_preflight.json`
    - `tools/backups/preflight_20260917_131551_STB_ProdRouteHist_deploy_preflight.json`
    - `tools/backups/preflight_20260917_131551_VINATECH_POPdboVINA_PACKING_REMAIN_QTY_deploy_preflight.json`
  - Snapshot Database Tables:
    - `SmartFactoryV2.dbo.BAK_STB_MaterialLotInfo_20260917_VVQR013R072727` (1 row)
    - `SmartFactoryV2.dbo.BAK_STB_ProdRouteHist_20260917_VVQR013R072727` (1 row)
    - `VINATECH_POP.dbo.BAK_VINA_PACKING_REMAIN_QTY_20260917_VVQR013R072727` (1 row)
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260917_131511_ROLLBACK_V28_VVQR013R072727.sql`
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;
  -- 1. Xóa bản ghi BTP sinh sớm ở kho tuyến
  DELETE FROM STB_MaterialLotInfo 
  WHERE MaterialLotNo = '20260917000404' AND LotNo = 'VVQR013R072727';
  -- 2. Xóa lượt chốt công đoạn đóng gói V-28_HY
  DELETE FROM STB_ProdRouteHist 
  WHERE ProdRouteHistNo = '20260917000709' AND ControlNo = '20260901000137' AND RouteCode = 'V-28_HY';
  -- 3. Xóa bản ghi tạm trong VINATECH_POP
  DELETE FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY 
  WHERE BARCODE = 'VVQR013R072727' AND ROUTE_CODE = 'V-28_HY';
  COMMIT TRANSACTION;
  GO
  ```
* **Kết quả nghiệm thu:**
  - `STB_MaterialLotInfo`: 0 dòng (đã xóa bản ghi 20260917000404).
  - `STB_ProdRouteHist`: 5 dòng (công đoạn cuối trả về V-26_HY 1053 pcs, công đoạn V-28_HY đã được giải phóng).
  - `VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY`: Đã xóa bản ghi tạm.
  - Giao diện POP Kiosk Web: Khôi phục hạn mức còn lại 1046 EA, cho phép công nhân chia Box và bấm Đóng gói bình thường.
* **Tham chiếu KB:** [POP_KB_04_ROLLBACK_AND_SAFETY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_04_ROLLBACK_AND_SAFETY.md), [KB_07_03_SCREEN_BUGS.md § Lỗi 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md#hy530--route-process-input-hy-chốt-sản-lượng-công-đoạn-hưng-yên)

---

### [POP/B530/V-26_HY] — 📍 ID_48 Giải phóng lượt chốt tồn cũ V-26_HY cho Lot VVQQ073R072736
* **Ngày sửa:** `2026-09-17` (13:37:00)
* **Màn hình liên quan (TCode):** `POP Web Kiosk (pop.vinatech.com/pop/screen) - Công đoạn Aging (Lão hóa)` & `[B530] - Nhập thực tế sản xuất`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ProdRouteHist`, `SmartFactoryV2.dbo.STB_ProdRouteWorkerHist`
* **Danh sách Lot:** `VVQQ073R072736` (ControlNo `20260807000462`, PO `260804000017`, Model `ECVT30-357`, Chuyền `HY Cell Line #1`)
* **Triệu chứng lỗi:** Công nhân chọn công đoạn Aging `V-26_HY` và bấm "HOÀN THÀNH SẢN XUẤT" trên POP Kiosk, hệ thống báo popup đỏ: *"Thất bại: This route is already completed in MES."*. Sang MES WinForm (B530) chốt thì MES chặn: *"Search failed: Vui lòng sử dụng hệ thống POP để nhập sản lượng"*.
* **Nguyên nhân gốc (Root Cause):** Trong `STB_ProdRouteHist` đã tồn tại bản ghi cũ `ProdRouteHistNo = 20260830000798` (từ ngày 30/08/2026) của công đoạn `V-26_HY` do chạy thử hoặc thao tác dở ca cũ, làm API POP chặn chốt đè sản lượng.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - Snapshot Tables: `SmartFactoryV2.dbo.BAK_STB_ProdRouteHist_20260917_VVQQ073R072736` & `BAK_STB_ProdRouteWorkerHist_20260917_VVQQ073R072736`.
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260917_133700_ROLLBACK_V26_VVQQ073R072736.sql`
  ```sql
  USE SmartFactoryV2;
  GO
  BEGIN TRANSACTION;
  BEGIN TRY
      -- 1. Xóa worker mapping
      DELETE FROM STB_ProdRouteWorkerHist WHERE ProdRouteHistNo = '20260830000798';
      -- 2. Xóa bản ghi kẹt cũ V-26_HY
      DELETE FROM STB_ProdRouteHist 
      WHERE ProdRouteHistNo = '20260830000798' AND ControlNo = '20260807000462' AND RouteCode = 'V-26_HY';
      COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
      ROLLBACK TRANSACTION;
      THROW;
  END CATCH;
  GO
  ```
* **Kết quả nghiệm thu:** Xóa thành công bản ghi kẹt cũ, mở lại trạng thái để công nhân F5 Kiosk và bấm Hoàn thành sản xuất trên POP Kiosk bình thường.
* **Tham chiếu KB:** [POP_KB_03 § 2.6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#26-pop-err-09-lỗi-this-route-is-already-completed-in-mes-khi-chốt-công-đoạn), [KB_09_SCREEN_BUG_FIXBOOK.md § [B530] #11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L202)

---

### [B782] — 📍 ID_50 Chuyển ngày ghi nhận sản xuất của 4 Lot (VVQR153R825706, 707, 712, 714) từ ngày 17 sang 18 trên màn B782
* **Ngày sửa:** `2026-09-19` (02:05:00)
* **Màn hình liên quan (TCode):** `[B782] - VNT_LotTrackingInfo_vvt22`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ProdRouteHist`, `SmartFactoryV2.dbo.STB_DefectRepairInfo`
* **Danh sách Lot:** `VVQR153R825706`, `VVQR153R825707`, `VVQR153R825712`, `VVQR153R825714` (Chuyền `VVHYC-13`, Xưởng Hưng Yên `VVT_F5`, mã NVL `LIVT38-009`)
* **Triệu chứng & Yêu cầu:** Người dùng yêu cầu chuyển ngày ghi nhận của 4 Lot trên màn hình B782 từ ngày 17 sang 18.
* **Nguyên nhân gốc (Root Cause):**
  - Màn hình B782 (`usp_LotTrackingInfo_VVT2_get`) quy định ca làm việc từ 10:00:00 sáng hôm trước đến 10:00:00 sáng hôm sau. Cột hiển thị `JobDate` được tính toán tự động: nếu `ProdDateTime` trước 10:00:00 thì quy về ngày hôm trước.
  - 4 Lot trên có 2 công đoạn `V-23_HY` (Rubber/Riveting) và `V-24_HY` (Curling) được chốt vào ca đêm rạng sáng ngày 18/09 (01:05 - 05:58 AM), do đó B782 tự động xếp vào ca ngày 17/09.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - `tools/backups/preflight_20260919_020445_STB_ProdRouteHist_backup_b782_move_date_17_to_18.json` (8 bản ghi routing)
  - `tools/backups/preflight_20260919_020447_STB_DefectRepairInfo_backup_b782_move_date_17_to_18.json` (2 bản ghi phế NG)
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260919_020500_B782_MOVE_4LOTS_DATE_17_TO_18.sql`
  - Dời `ProdDateTime` của `V-23_HY` sang `2026-09-18 10:05:00` và `V-24_HY` sang `2026-09-18 10:06:00`.
  - Cập nhật `JobDate = '2026-09-18'`.
  - Đồng bộ `CreateDateTime` trong `STB_DefectRepairInfo` sang `2026-09-18 10:05:00`.
* **Script Rollback chuẩn bị sẵn:** `sql/rollback_20260919_020500_B782_MOVE_4LOTS_DATE_17_TO_18.sql`
* **Kết quả nghiệm thu:**
  - `usp_LotTrackingInfo_VVT2_get` ngày 17/09: Trả về **0 dòng** (đã ẩn sạch khỏi ngày 17).
  - `usp_LotTrackingInfo_VVT2_get` ngày 18/09: Trả về đầy đủ tất cả công đoạn (`V-23_HY`, `V-24_HY`, `V-25_HY`, `V-27_HY`, `V-28_HY`, `V-29_HY`), hiển thị liền mạch trên màn hình B782.
* **Tham chiếu KB:** [KB_03_01_OVERVIEW.md § 5.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md#L53-L79), [KB_09_SCREEN_BUG_FIXBOOK.md § [B782]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L357)

---

### [B782] — 📍 ID_51 Chuyển ngày ghi nhận sản xuất của 6 Lot (VVQR173R825701 -> 706) từ ngày 18 về ngày 17 trên màn B782
* **Ngày sửa:** `2026-09-19` (03:15:00)
* **Màn hình liên quan (TCode):** `[B782] - VNT_LotTrackingInfo_vvt22`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ProdRouteHist`, `SmartFactoryV2.dbo.STB_DefectRepairInfo`, `SmartFactoryV2.dbo.STB_SetInfo`
* **Danh sách Lot:** `VVQR173R825701`, `VVQR173R825702`, `VVQR173R825703`, `VVQR173R825704`, `VVQR173R825705`, `VVQR173R825706` (Chuyền `VVHYC-13`, Xưởng Hưng Yên `VVT_F5`, mã NVL `LIVT38-009`)
* **Triệu chứng & Yêu cầu:** Người dùng yêu cầu chuyển ngày ghi nhận của 6 Lot trên màn hình B782 từ ngày 18 về ngày 17.
* **Nguyên nhân gốc (Root Cause):**
  - Màn hình B782 (`usp_LotTrackingInfo_VVT2_get`) quy định ca làm việc từ 10:00:00 sáng hôm trước đến 10:00:00 sáng hôm sau. Cột hiển thị `JobDate` được tính toán tự động dựa theo `ProdDateTime`.
  - 6 Lot trên chỉ mới hoàn thành công đoạn đầu `V-22_HY` (Winding - Quấn cuộn) lúc 12:56 - 12:58 PM ngày 18/09 (sau 10:00 AM ngày 18), do đó B782 tự động xếp vào ca ngày 18/09.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - `tools/backups/preflight_20260919_031122_STB_ProdRouteHist_backup_b782_move_date_18_to_17.json` (6 bản ghi routing)
  - `tools/backups/preflight_20260919_031123_STB_DefectRepairInfo_backup_b782_move_date_18_to_17.json` (12 bản ghi phế NG)
  - `tools/backups/preflight_20260919_031123_STB_SetInfo_backup_b782_move_date_18_to_17.json` (6 bản ghi SetInfo)
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260919_031500_B782_MOVE_6LOTS_DATE_18_TO_17.sql`
  - Dời `ProdDateTime` của `V-22_HY` lùi 1 ngày về `2026-09-17 12:56 - 12:58` và cập nhật `JobDate = '2026-09-17'`.
  - Đồng bộ `CreateDateTime` của 12 bản ghi phế NG trong `STB_DefectRepairInfo` về `2026-09-17 12:56 - 12:58`.
  - Đồng bộ `InputDateTime` và `InputJobDate` trong `STB_SetInfo` về `2026-09-17`.
* **Script Rollback chuẩn bị sẵn:** `sql/rollback_20260919_031500_B782_MOVE_6LOTS_DATE_18_TO_17.sql`
* **Kết quả nghiệm thu:**
  - `usp_LotTrackingInfo_VVT2_get` ngày 17/09: Trả về **đầy đủ 6 Lot** ở công đoạn `V-22_HY` (sản lượng 988 PCS sau trừ 12 phế NG).
  - `usp_LotTrackingInfo_VVT2_get` ngày 18/09: Trả về **0 dòng** (đã ẩn sạch khỏi ngày 18).
* **Tham chiếu KB:** [KB_03_01_OVERVIEW.md § 5.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md#L53-L79), [KB_09_SCREEN_BUG_FIXBOOK.md § [B782]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L357)

---

### [B782/B530] — 📍 ID_52 Chuyển "Ngày làm" (JobDate) của 17 Lot tại công đoạn V-24_HY (Curling) sang ngày 18/09/2026
* **Ngày sửa:** `2026-09-19` (05:14:25)
* **Màn hình liên quan (TCode):** `[B530] - Nhập sản lượng công đoạn`, `[B782] - VNT_LotTrackingInfo_vvt22`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ProdRouteHist`, `SmartFactoryV2.dbo.STB_DefectRepairInfo`
* **Danh sách 17 Barcode:** `VVQR113R060641`, `VVQR103R060625`, `VVQR113R060639`, `VVQR103R060615`, `VVQR073R060647`, `VVQR073R060620`, `VVQR023R060671`, `VVQR023R060616`, `VVQR113R060628`, `VVQR023R060615`, `VVQR023R060678`, `VVQR023R060603`, `VVQQ313R060616`, `VVQR073R060605`, `VVQR073R060607`, `VVQR043R060604`, `VVQR023R060606`
* **Danh sách 17 ControlNo:** `20260911000619`, `20260910000370`, `20260911000617`, `20260910000055`, `20260907000380`, `20260907000154`, `20260902000417`, `20260902000178`, `20260911000606`, `20260902000177`, `20260902000424`, `20260902000165`, `20260831000089`, `20260907000139`, `20260907000141`, `20260904000095`, `20260902000168`
* **Triệu chứng & Yêu cầu:** Người dùng yêu cầu chuyển "Ngày làm" của 17 Lot tại công đoạn `V-24_HY` (Curling - Cuốn mép) sang ngày 18.
* **Nguyên nhân gốc (Root Cause):**
  - Cả 17 Lot thực tế hoàn thành dập mép `V-24_HY` vào rạng sáng 04:15 - 08:22 ngày 18/09/2026.
  - Chu kỳ ca làm việc của MES tính từ 10:00:00 sáng hôm nay đến 10:00:00 sáng hôm sau, nên các thao tác trước 10:00 AM tự động được gán vào `JobDate` của ca ngày hôm trước (17/09 hoặc ngày kế hoạch cũ 10, 12, 15, 16/09).
* **Cơ chế sao lưu (Pre-flight Backup):**
  - `tools/backups/preflight_20260919_051345_STB_ProdRouteHist_backup_b782_17lots_v24_move_to_18.json` (17 bản ghi)
  - `tools/backups/preflight_20260919_051346_STB_DefectRepairInfo_backup_b782_17lots_v24_move_to_18.json` (15 bản ghi)
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260919_051500_B782_MOVE_17LOTS_V24_DATE_18.sql`
  - Cập nhật `JobDate = '2026-09-18'` cho 17 ControlNo tại công đoạn `V-24_HY` trên `STB_ProdRouteHist`.
  - Đồng bộ `FindJobdate = '2026-09-18'` cho các bản ghi phế NG tại `V-24_HY` trên `STB_DefectRepairInfo`.
  - Ghi nhận `ChangeUserID = 'it_hotfix'`, `ChangeDateTime = GETDATE()`.
* **Script Rollback chuẩn bị sẵn:** `sql/rollback_20260919_051500_B782_MOVE_17LOTS_V24_DATE_18.sql`
* **Kết quả nghiệm thu Live DB:**
  - 17/17 bản ghi `STB_ProdRouteHist` tại `V-24_HY` đã cập nhật `JobDate = '2026-09-18'`.
  - 15/15 bản ghi `STB_DefectRepairInfo` tại `V-24_HY` đã đồng bộ `FindJobdate = '2026-09-18'`.
* **Tham chiếu KB:** [KB_03_01_OVERVIEW.md § 5.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md#L53-L79), [KB_09_SCREEN_BUG_FIXBOOK.md § [B782] Mục 2 & 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L366-L368), [HOTFIX_LOG.md § ID_50](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/HOTFIX_LOG.md#L1034-L1055)

---

### [B782/B530] — 📍 ID_53 Chuyển "Ngày làm" (JobDate) của 3 Lot (VVQR153R825705, 708, 713) công đoạn V-24_HY sang ngày 18/09/2026
* **Ngày sửa:** `2026-09-19` (05:18:32)
* **Màn hình liên quan (TCode):** `[B530] - Nhập sản lượng công đoạn`, `[B782] - VNT_LotTrackingInfo_vvt22`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ProdRouteHist`
* **Danh sách 3 Barcode:** `VVQR153R825705`, `VVQR153R825708`, `VVQR153R825713`
* **Danh sách 3 ControlNo:** `20260915000222`, `20260915000225`, `20260915000619` (Chuyền `VVHYC-13`, Xưởng Hưng Yên `VVT_F5`)
* **Triệu chứng & Yêu cầu:** Người dùng yêu cầu chuyển "Ngày làm" của 3 Lot tại công đoạn `V-24_HY` (Curling) sang ngày 18.
* **Nguyên nhân gốc (Root Cause):**
  - Cả 3 Lot hoàn thành công đoạn `V-24_HY` vào ca đêm rạng sáng ngày 18/09 (00:32 - 04:02 AM). Do chốt trước 10:00 AM, hệ thống tự động gán `JobDate = '2026-09-17'`.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - `tools/backups/preflight_20260919_051811_STB_ProdRouteHist_backup_b782_3lots_v24_move_to_18.json` (3 bản ghi)
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260919_052000_B782_MOVE_3LOTS_V24_DATE_18.sql`
  - Cập nhật `JobDate = '2026-09-18'` cho 3 ControlNo tại công đoạn `V-24_HY`.
  - Ghi nhận `ChangeUserID = 'it_hotfix'`, `ChangeDateTime = GETDATE()`.
* **Script Rollback chuẩn bị sẵn:** `sql/rollback_20260919_052000_B782_MOVE_3LOTS_V24_DATE_18.sql`
* **Kết quả nghiệm thu Live DB:**
  - 3/3 bản ghi `STB_ProdRouteHist` tại `V-24_HY` đã cập nhật thành công `JobDate = '2026-09-18'`.
* **Tham chiếu KB:** [KB_03_01_OVERVIEW.md § 5.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md#L53-L79), [KB_09_SCREEN_BUG_FIXBOOK.md § [B782]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L366-L368), [HOTFIX_LOG.md § ID_50, ID_52](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/HOTFIX_LOG.md#L1034-L1082)

---

### [B782] — 📍 ID_54 Cộng thời gian (+10 giờ) cho công đoạn V-24_HY của 20 Lot để hiển thị đầy đủ trên B782 ngày 18/09
* **Ngày sửa:** `2026-09-19` (05:28:00)
* **Màn hình liên quan (TCode):** `[B782] - VNT_LotTrackingInfo_vvt22`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ProdRouteHist`
* **Danh sách 20 Barcode:** 17 Lot đợt 1 + 3 Lot đợt 2 (`VVQR153R825705`, `VVQR153R825708`, `VVQR153R825713`)
* **Triệu chứng & Yêu cầu:** Người dùng yêu cầu chuyển ngày ghi nhận của 20 Lot công đoạn `V-24_HY` (Curling) sang ngày 18 theo cách cộng thời gian (vượt mốc cắt ca 10:00:00 sáng của B782) và kiểm tra lại trên giao diện B782.
* **Nguyên nhân gốc (Root Cause):**
  - Màn hình B782 (`usp_LotTrackingInfo_VVT2_get`) lọc dữ liệu ngày 18/09 theo khoảng thời gian: `ProdDateTime >= '2026-09-18 10:00:00' AND ProdDateTime < '2026-09-19 10:00:00'`.
  - Toàn bộ 20 Lot trên thực tế dập mép vào ca đêm rạng sáng (00:32 - 08:22 AM ngày 18/09), do đó dù cột `JobDate` là `2026-09-18` nhưng vì `ProdDateTime < 10:00:00 AM` nên B782 vẫn gom vào ngày 17/09.
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_20260919_053000_B782_ADD_HOURS_20LOTS_V24_DATE_18.sql`
  - Cập nhật: `SET ProdDateTime = DATEADD(HOUR, 10, ProdDateTime), JobDate = '2026-09-18'` cho 20 ControlNo tại `V-24_HY`.
  - Đẩy giờ dập thực tế sang khoảng `10:32 - 18:22` ngày 18/09, vượt ngưỡng lọc ca của B782.
* **Script Rollback chuẩn bị sẵn:** `sql/rollback_20260919_053000_B782_ADD_HOURS_20LOTS_V24_DATE_18.sql`
* **Kết quả nghiệm thu Live DB qua SP `usp_LotTrackingInfo_VVT2_get`:**
  - **Ngày 18/09/2026:** Trả về **20 / 20 Lot** tại công đoạn `V-24_HY`, hiển thị đầy đủ, liền mạch trên B782.
  - **Ngày 17/09/2026:** Trả về **0 Lot** tại công đoạn `V-24_HY` (đã dọn sạch hoàn toàn khỏi ngày 17).
* **Tham chiếu KB:** [KB_03_01_OVERVIEW.md § 5.2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md#L53-L79), [KB_09_SCREEN_BUG_FIXBOOK.md § [B782]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md#L366-L368), [HOTFIX_LOG.md § ID_50](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/HOTFIX_LOG.md#L1034-L1055)

---

### [POP Screen]/[Electrode] — 📍 ID_55 Reset công đoạn cho Lot điện cực VVQQ2520001E34 phục vụ thực hành Kiosk
* **Ngày sửa:** `2026-09-19` (13:50:44)
* **Màn hình liên quan (URL / TCode):** `POP Web Kiosk (pop.vinatech.com/pop/screen) - Chuyền Điện cực Bắc Ninh`
* **Bảng liên quan:** `SmartFactoryV2.dbo.STB_ElectrodeMixInfo`
* **Mã Lot:** `VVQQ2520001E34` (PO `260825000020`, DayPlan `2026082500040`, Model `CREHCO85`)
* **Triệu chứng & Yêu cầu:** Người dùng yêu cầu chuẩn bị 1 Lot test mới tinh cùng Lệnh sản xuất với `VVQQ2520001E76` để tự tay thực hành quy trình sản xuất điện cực từ đầu trên POP Kiosk.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - Snapshot file: `tools/backups/preflight_20260919_135044_STB_ElectrodeMixInfo_deploy_preflight.json` (1 bản ghi)
* **Phương án sửa lỗi & Script Deploy:** `sql/hotfix_reset_VVQQ2520001E34.sql`
  - Thực hiện xóa 1 dòng khởi tạo mẻ trộn dở dang tại `STB_ElectrodeMixInfo`.
* **Kết quả nghiệm thu Live DB:**
  - `STB_ElectrodeMixInfo`: **0 records**
  - `STB_ElectrodeMixStepInfo`: **0 records**
  - `STB_ElectrodeCoatingInfo`: **0 records**
  - `STB_ElectrodeRollPressingInfo`: **0 records**
  - `STB_ElectrodeSlittingResult`: **0 records**
  - `STB_SetInfo`: **1 record** (Trạng thái Lot mới tinh 100%, sẵn sàng thực hành từ công đoạn Trộn).
* **Tham chiếu KB:** [KB_05_01_QC_AND_ELECTRODE_CORE.md § 8.11](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#L601), [POP_KB_02_SCREEN_OPERATIONS.md § 16](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md#L377)

---

### [B782] — 📍 ID_56 Sửa lỗi hiển thị phế tính toán âm / NULL trên màn hình B782 (Lot Tracking)
* **Ngày sửa:** `2026-09-20` (09:58:00)
* **Người thực hiện / Duyệt:** `vanduc` (IT MES)
* **Màn hình liên quan (TCode):** `[B782] - VNT_LotTrackingInfo_vvt22`
* **Đối tượng CSDL:** Stored Procedure `SmartFactoryV2.dbo.usp_LotTrackingInfo_VVT2_get`
* **Triệu chứng lỗi:**
  - Trên màn hình B782 (Lot Tracking), cột số lượng NG (Defect Qty) từ công đoạn Cuộn (`V-22_HY`) đến Ngoại quan (`V-27_HY`) của Model 35105 (`ECVT30-357`, Chuyền `VVHYC-02`) không hiển thị/không link được số lượng NG từ POP Kiosk xuống NAIS MES dù công nhân trên Kiosk đã nhập phế và dữ liệu đã ghi vào `STB_DefectRepairInfo`.
* **Nguyên nhân gốc (Root Cause):**
  - Trong SP `usp_LotTrackingInfo_VVT2_get` (dài 699 dòng), tác giả gốc sử dụng công thức tính phế thuần: `sum(a.DefectQty) - sum(a.RepairQty)`.
  - Khi một công đoạn phát sinh phế (`DefectQty > 0`) nhưng chưa từng có số lượng sửa chữa/rework (`RepairQty IS NULL`), theo quy tắc SQL ANSI: `DefectQty - NULL = NULL`.
  - Toàn bộ kết quả tính toán NG trả về `NULL`, làm giao diện WinForm B782 hiển thị trống trơn hoặc tính toán sai lệch tổng phế.
* **Phương án sửa lỗi & Patch SQL:**
  - Bọc hàm `ISNULL` bảo vệ tại toàn bộ 12 vị trí (cả 2 nhánh: lọc theo từng Nhà máy và nhánh Tổng 2 nhà máy):
    ```sql
    sum(ISNULL(a.DefectQty, 0)) - sum(ISNULL(a.RepairQty, 0)) /*vanduc update 20260920*/
    ```
  - Cập nhật trực tiếp trên Live DB với định danh user `vanduc`.
* **Kết quả nghiệm thu Live DB:**
  - Cột NG trên màn hình B782 đã hiển thị chính xác 100% số lượng phế thực tế theo thời gian thực từ POP Kiosk.
* **Tham chiếu KB:** [KB_09_SCREEN_BUG_FIXBOOK.md § [B782] Bug #5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md), [KB_03_01_OVERVIEW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md)

---

### [POP Kiosk] — 📍 ID_57 Giải phóng kẹt trạng thái ACTIVE của 7 thiết bị Cell Line Hưng Yên trên POP Kiosk
* **Ngày sửa:** `2026-09-20` (11:32:00)
* **Người thực hiện:** `vanduc` (IT MES)
* **Màn hình liên quan (URL / TCode):** POP Web Kiosk (`pop.vinatech.com/pop/screen`) — Modal "Xác nhận Kết thúc?" (Modal chọn máy khi chốt sản lượng)
* **Đối tượng CSDL:** Bảng `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING` (Profile `VINATECH_POP`, Server `dbserver.hycap.co.kr,5398`)
* **Triệu chứng lỗi:**
  - Khi công nhân thao tác chốt sản lượng cho Model 35105 (`ECVT30-357`, PO `260918000008`, DayPlan `2026091800021`) tại xưởng Hưng Yên `VVT_F5`, modal "Xác nhận Kết thúc?" chỉ hiển thị 16 máy Cuộn (Winding C#3 đến C#10), hoàn toàn thiếu 4 máy đầu chuyền: `Winding C#1 -1`, `Winding C#1 -2`, `Winding C#2 -1`, `Winding C#2 -2`, cùng các máy Curling C#1, Curling C#2, Sleeving C#1.
* **Nguyên nhân gốc (Root Cause):**
  - Màn hình Kiosk truy vấn danh mục máy khả dụng bằng cách lấy cấu hình từ `SmartFactoryV2.dbo.STB_ProductMachine` kết hợp `STB_MachineMaster`, nhưng có bộ lọc kiểm tra xung đột độc quyền thiết bị:
    ```sql
    WHERE NOT EXISTS (
        SELECT 1 FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING M
        WHERE M.EQUIPMENT_ID = E.EQUIPMENT_ID
          AND M.MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
          AND M.DAY_PLAN_NO <> @CurrentDayPlanNo
    )
    ```
  - 7 máy trên đã từng được gán vào Kế hoạch sản xuất cũ (`2026091500008`, `2026091400010`) từ các ngày 14-17/09/2026 nhưng khi kết thúc kế hoạch không được giải phóng (`RELEASED`).
  - Trạng thái `ACTIVE` tồn lưu vĩnh viễn khóa các máy này, khiến Kiosk ẩn hoàn toàn khỏi danh sách lựa chọn của Kế hoạch ngày hôm nay.
* **Cơ chế sao lưu (Pre-flight Backup):**
  - Snapshot file: `tools/backups/preflight_20260920_113219_VINA_EQUIPMENT_MAPPING_release_locked_machines.json` (7 bản ghi)
* **Phương án sửa lỗi & Script Deploy:**
  - Script triển khai: [`sql/hotfix_20260920_release_locked_equipment_mappings.sql`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/sql/hotfix_20260920_release_locked_equipment_mappings.sql)
  - Cập nhật:
    ```sql
    UPDATE VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING
    SET MAPPING_STATUS      = 'RELEASED',
        RELEASED_AT         = GETDATE(),
        RELEASE_REASON      = N'Release cho Model 35105',
        NO_EMP_MODIFYER     = 'vanduc',
        CD_COMPANY_MODIFYER = 'VINA'
    WHERE MAPPING_ID IN (2298, 2416, 2239, 2240, 2346, 2360, 2352)
      AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');
    ```
  - Script Rollback dự phòng: [`sql/rollback_20260920_release_locked_equipment_mappings.sql`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/sql/rollback_20260920_release_locked_equipment_mappings.sql)
* **Kết quả nghiệm thu Live DB:**
  - 7/7 bản ghi đã chuyển sang `MAPPING_STATUS = 'RELEASED'`, `NO_EMP_MODIFYER = 'vanduc'`.
  - Trên Kiosk POP, toàn bộ 20 máy Winding, 10 máy Curling, 10 máy Sleeving hiển thị đầy đủ 100%, công nhân chọn máy và chốt sản lượng thành công.
* **Tham chiếu KB:** [POP_KB_01_ARCHITECTURE_AND_API.md § 3.3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md), [POP_KB_03_TROUBLESHOOTING.md § 2.20](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md), [KB_09_SCREEN_BUG_FIXBOOK.md § [POP Kiosk]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md)



### 📍 ID_58 - POP - Ma loi phe tren POP Kiosk khong hien du STB_DefectRepairInfo...
* **Ngay sua:** `2026-09-21`
* **Man hinh lien quan (TCode):** `POP - Chua xac dinh`
* **Trieu chung loi:** Ma loi phe tren POP Kiosk khong hien du STB_DefectRepairInfo co data (Lot VVQR153R060615)
* **Nguyen nhan goc (Root Cause):** Three-Valued Logic: Cot IsDelete va RepairQty trong STB_DefectRepairInfo bi NULL do thieu constraint default. Menh de WHERE IsDelete=0 bo qua 6,605 ban ghi, STB_SetInfo.DefectQty bi thieu
* **Phuong an sua loi (SQL Patch / Action):**
  ```sql
UPDATE STB_DefectRepairInfo SET IsDelete=0, RepairQty=0 WHERE DefectSummaryNo=20260919000550; UPDATE STB_SetInfo SET DefectQty=9 WHERE Barcode=VVQR153R060615;
  ```
* **Tham chieu KB:** KB_09, POP_KB_03

---

### [POP Cutover] — 📍 ID_59 Bộ công cụ quy hoạch và kiểm toán chuyển đổi 100% sang POP Web (Tắt MES WinForm)
* **Ngày tạo:** `2026-09-21`
* **Màn hình liên quan:** Toàn bộ hệ thống MES WinForm (B530, B540, B523, B520, B782, B552, B310...) và POP Web (`/pop/screen`, `/pop/quality`, `/equipmentData/*`)
* **Nhiệm vụ:** Chuẩn bị hạ tầng, tài liệu đặc tả và công cụ tự động để phục vụ chuyển đổi 100% sang Web POP mà không gây gián đoạn dây chuyền.
* **Các thành phần đã triển khai:**
  1. `POP_KB_06_MIGRATION_SPEC.md`: Bảng ánh xạ 1:1 màn hình, giải pháp 4 Gaps kỹ thuật (PackingID, Machine lock, Defect sync, Line slots), 8 bước checklist Line Readiness và 4 giai đoạn Cutover.
  2. `tools/pop_readiness.ps1` & lệnh `.\mes.ps1 pop-readiness [-Target <Line>]`: Tự động kiểm toán kết nối, 10 slot NVL, chế độ SUBTRACT, máy kẹt, và tắc nghẽn đồng bộ `MongoToMesPerformance` cho toàn bộ 31 dây chuyền.
  3. `tools/release_orphan_machines.ps1` & lệnh `.\mes.ps1 release-machines [-Target <Line>] [-Force]` kèm SQL routine `sql/routine_RELEASE_ORPHAN_MACHINE_LOCKS.sql`: Tự động quét và giải phóng 52 thiết bị bị kẹt `ACTIVE` ở DayPlan cũ.
  4. `sql/template_GENERATE_POP_PACKING_ID.sql`: Thuật toán sinh mã `PackingID` chuẩn 11 ký tự (`PK...`) cập nhật `STB_MaterialLotInfo` và `STB_SavePackingTime_VVT`.
  5. Bổ sung chi tiết 4 bảng CSDL thiết bị & PLC baseline (`VINA_EQUIPMENT_SETTING`, `VINA_PLC_BASELINE`, `VINA_EQUIPMENT_REMAINDER`, `VINA_EQUIPMENT_MAPPING`) vào `POP_KB_02 § 18.4`.
* **Tham chiếu KB:** [POP_KB_06_MIGRATION_SPEC.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_06_MIGRATION_SPEC.md), [POP_KB_02 § 18.4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md), [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)

---

### [Architecture & Speed] — 📍 ID_60 Tối ưu hóa siêu tốc độ truy vết (Single Round-Trip 360°) & Bộ nhớ đệm L1 POP_MATRIX
* **Ngày tạo:** `2026-09-21`
* **Màn hình liên quan:** Toàn bộ hệ sinh thái POP Web & MES WinForm
* **Triệu chứng & Vấn đề tồn tại:** 
  - AI phải chạy nhiều câu truy vấn `SELECT` rời rạc qua kết nối VPN/Internet tới máy chủ `dbserver.hycap.co.kr,5398` (mất 1.5 - 3s mỗi nhịp), dẫn đến thời gian chờ tổng thể lên tới 10-15s.
  - Khi người dùng đưa mã nhưng không rõ định dạng (mã thùng PK, mã máy, mã line hay mã Lot), AI bị query nhầm bảng và không ra kết quả ngay.
* **Phương án giải quyết:**
  1. **Tạo Siêu Module Truy Vết 360° (`tools/pop_trace.ps1`):**
     - Áp dụng kỹ thuật **Single Round-Trip DataSet Batching**: gom toàn bộ truy vấn 7 bảng MES + POP vào đúng 1 nhịp mạng TCP duy nhất, thời gian truy vết giảm từ 15s xuống **< 1-2 giây**.
     - Tích hợp **Smart Identifier Resolver**: tự động phân tích tiền tố chuỗi (`^PK` ➔ Thùng đóng gói, `^V[VN]EP` ➔ Thiết bị, `^(VVC-|VVHYC-|TCX)` ➔ Dây chuyền, `VV...` ➔ Lot) để chọn đúng đường truy vết chính xác 100%.
  2. **Bộ Nhớ Đệm L1 Siêu Tốc (`AI_AGENT_CONFIG/POP_MATRIX.json`):**
     - Biên dịch sẵn cấu hình 31 dây chuyền, các Route Web POP, và Top lỗi runtime.
     - Tích hợp vào `tools/find_kb.ps1` và `mes.ps1 find`: tra cứu thông tin dây chuyền và lỗi trong **< 0.001 giây** không cần kết nối DB.
* **Tham chiếu KB:** [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md), [mes.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/mes.ps1)


