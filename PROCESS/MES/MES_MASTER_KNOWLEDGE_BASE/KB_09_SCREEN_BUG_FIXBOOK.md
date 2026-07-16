# KB_09: Sổ Tay Tra Cứu Bug & Fix Theo Màn Hình

> **📌 Mục đích:** Khi nhận được báo lỗi từ user → tra TCode tại đây → tìm ngay bug + cách fix.
> **🔑 Keywords:** bug, fix, sổ tay, TCode, màn hình, triệu chứng, nguyên nhân, SQL fix, sửa lỗi, khắc phục
> File này tổng hợp TẤT CẢ bug đã documented, sắp xếp theo TCode (Mã màn hình).
> Mỗi entry gồm: Triệu chứng | Nguyên nhân | Fix | Tham chiếu KB gốc.

---

## Mục lục nhanh

| Prefix | Màn hình | Số bug |
|---|---|---|
| **A** | [A230](#a230), [A310](#a310), [A410](#a410), [A418](#a418), [A460](#a460), [A510](#a510) | 6 |
| **B** | [B210-B270](#b210-b270), [B310](#b310), [B442](#b442), [B452](#b452), [B523](#b523), [B528](#b528), [B530](#b530), [B540](#b540), [B552](#b552), [B560](#b560), [B597](#b597), [B598](#b598), [B618](#b618), [B682-B791](#b682-b791), [B754-B790](#b754-b790), [B802](#b802), [B882](#b882) | 25+ |
| **C** | [C121-C122](#c121-c122), [C220](#c220), [C243](#c243), [C321](#c321), [C443](#c443), [C451](#c451), [C486](#c486), [C512](#c512), [C530](#c530-oqc), [C546](#c546), [C560](#c560), [C585](#c585) | 16+ |
| **D** | [D100-D110](#d100-d110) | 3 |
| **F** | [F330](#f330), [F430](#f430), [F721](#f721), [F743-F748](#f743-f748) | 6+ |
| **G** | [G660](#g660) | 1 |
| **H** | [HN523](#hn523), [HNC321](#hnc321), [HN551](#hn551) | 4+ |
| **K** | [K101](#k101), [K109](#k109), [K110](#k110), [K198-K199](#k198-k199) | 4+ |
| **P** | [P111](#p111) | 1 |
| **Z** | [Z410](#z410), [Z530](#z530) | 2 |

---

## A-Series: Master Data & Kế Hoạch

### [A230]
**Tên:** Thông tin vật liệu (Material Master)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Model mới không hiện Vol/Farad trên chuyền | Chưa khai báo A230 hoặc thiếu cấu hình Vol/Farad | Vào A230 → tab Thông số kỹ thuật → nhập Vol, Farad, kích thước. SQL: `SELECT ModelCode, Voltage, Farad FROM STB_ModelBasicInfo WHERE ModelCode = 'mã'` |
| 2 | Cột "Độ dày" bị trống trên B442 (Kế hoạch Electrode) | Chưa set MaterialThickness tại A230 tab "Mã nguyên liệu" | `UPDATE STB_MaterialMaster SET MaterialThickness = '120' WHERE MaterialCode = 'mã_nvl'` |

> 🔗 Chi tiết: [KB_06 §9.1](KB_06_MASTER_DATA_TOOLS.md)

### [A310]
**Tên:** Route Info (Định nghĩa công đoạn)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | OP không thấy công đoạn mới trong danh sách Route | Chưa tạo Route tại A310 hoặc chưa map vào PO | Vào A310 → Thêm RouteCode → Map vào B210 (Line) |

> 🔗 Chi tiết: [KB_06 §9.4](KB_06_MASTER_DATA_TOOLS.md)

### [A410]
**Tên:** Model Basic Info (Cấu hình model)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | C512 không tìm thấy Lot OQC | Chưa config OqcType, InspectionLevel tại A410 | `UPDATE STB_ModelBasicInfo SET OqcType='MANUAL', OqcInspectionRuleType='BY_MODEL', InspectionType='SAMPLE', InspectionLevel='SAMPLE' WHERE ModelCode = 'mã'` |

> 🔗 Chi tiết: [KB_06 §9.5](KB_06_MASTER_DATA_TOOLS.md)

### [A418]
**Tên:** Packing Qty per Size (SL đóng gói theo Size)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | B523 không cho gộp Box, báo chưa có tiêu chuẩn đóng gói | Chưa khai báo A418 cho Size mới | Vào A418 → Thêm Size + PackingQty. SQL: `INSERT INTO STB_PackingQtyPerSize (SizeCode, PackingQty, ...) VALUES (...)` |

> 🔗 Chi tiết: [KB_06 §9.6](KB_06_MASTER_DATA_TOOLS.md)

### [A460]
**Tên:** Model Label Info (Cấu hình in tem)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | In tem bị lỗi "Not found label type" | Chưa có record trong `STB_ModelLabelInfo` cho model | Copy từ model cũ cùng loại: `INSERT INTO STB_ModelLabelInfo SELECT 'MODEL_MỚI', LabelType, ... FROM STB_ModelLabelInfo WHERE ModelCode = 'MODEL_CŨ'` |

> 🔗 Chi tiết: [KB_04 §6.20](KB_04/KB_04_01_CORE_PACKAGING.md), [KB_05 §8.7](KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md)

### [A510]
**Tên:** Production Order (Lệnh sản xuất - PO)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Chuyền sản xuất nhưng không trừ kho NVL | PO thiếu BOM hoặc Route chưa map NVL | Kiểm tra: `SELECT * FROM STB_ProductionOrderBom WHERE PONo = 'mã_PO'`. Nếu trống → tạo BOM |

---

## B-Series: Sản Xuất (Production)

### [B210]-[B270]
**Tên:** Line/Route/Machine Setup

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | B270 popup không hiện dữ liệu | Popup bị cache session cũ | Tắt MES → xóa cache → mở lại. Hoặc kiểm tra `STB_ScreenObjects` |
| 2 | Line mới không hiện trên B460 | Chưa map Line→WorkCenter tại B210 | Vào B210 → Thêm mapping |
| 3 | Machine mới scan không được | Chưa khai báo tại B240 | Vào B240 → Thêm MachineCode |

> 🔗 Chi tiết: [KB_03 §B210-B270](KB_03/KB_03_02_CELL_LINE.md), [KB_01 §1.3](KB_01_UI_AND_SCREENS.md)

### [B310]
**Tên:** Production Order Info (Quản lý PO)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | PO không tạo được Lot | BOM/Route chưa cấu hình cho PO | Kiểm tra `STB_ProductionOrderRouting`, `STB_ProductionOrderBom` |
| 2 | ProdFinishQty lệch so với thực tế | Crash giữa SP `usp_DoProcessProdRouteHist` → dữ liệu partial | `UPDATE STB_ProductionOrderInfo SET ProdFinishQty = (SELECT SUM(ProdQty) FROM STB_ProdRouteHist WHERE PONo='mã' AND RouteCode='V-28') WHERE PONo='mã'` |

### [B442]
**Tên:** Electrode Day Plan (Kế hoạch ngày điện cực)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | In tem điện cực lỗi "Not found label type" | Model chưa có record `STB_ModelLabelInfo` (LabelType='ElectLabel') | Xem A460 ở trên |
| 2 | Cột "Độ dày" trống | A230 chưa set MaterialThickness | Xem A230 ở trên |

> 🔗 Chi tiết: [KB_05 §8.7](KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md)

### [B452]
**Tên:** Line Changing (Chuyển Line sản xuất)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Chuyển Line lỗi "Barcode đã tồn tại trên Line khác" | Barcode chưa được `IsLineInput=0` ở Line cũ | `UPDATE STB_SetInfo SET IsLineInput=0, InputLineCode='' WHERE Barcode='mã' AND InputLineCode='LINE_CŨ'` |

### [B523]
**Tên:** Packing / Gộp Box (★ HOT — nhiều bug nhất)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Gộp box bị lỗi "Chưa có tiêu chuẩn đóng gói" | Thiếu config `STB_PackingQtyPerSize` cho Size sản phẩm | Xem A418 |
| 2 | Gộp box bị lỗi "IsOutputRoute chưa thiết lập" | PO Routing thiếu cờ `IsOutputRoute=1` ở công đoạn cuối | `UPDATE STB_ProductionOrderRouting SET IsOutputRoute=1 WHERE PONo='mã' AND RouteCode='V-28'` |
| 3 | Gộp box HN523 lỗi Qty=0 | `STB_PackingStandard` thiếu record cho model Hà Nam | INSERT record vào `STB_PackingStandard` — xem [KB_04 §6.13](KB_04/KB_04_01_CORE_PACKAGING.md) |
| 4 | Gộp box lỗi do PO có công đoạn hậu đóng gói B523 | Thiếu lịch sử Route `V-28_BG` | Chèn dòng ProdRouteHist giả lập — xem [KB_04 §6.13.2](KB_04/KB_04_01_CORE_PACKAGING.md) |
| 5 | MergeQty không chia đúng khi gộp nhiều Lot | Logic `@pMergeQty < @total + @InProdQty` bị edge case | Kiểm tra số lượng Lot trước khi gộp, đảm bảo tổng = MergeQty |
| 6 | Sanmina QR code has redundant quantities and serials on inner labels | Stored procedure usp_SanminaLabelPrint_get_Vietnam did not return a filtered list of serials and quantities for inner labels. | `-- ============================================= -- Author:		Mr.Manh -- Create date: 2025-12-26 -- Description:	Get Sanmina label -- =================...` |

> 🔗 Chi tiết: [KB_04 §6](KB_04/KB_04_01_CORE_PACKAGING.md), [KB_08 §5](KB_08_CORE_SP_ENGINE.md)

### [B528]
**Tên:** Barrel Barcode (In tem thùng phuy)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Tem barrel in trống hoặc thiếu thông tin | Label config chưa set cho model dạng Barrel | Kiểm tra `STB_ModelLabelInfo` → LabelType='BarrelLabel' |

### [B530]
**Tên:** Route Input / Production Qty Output (★ CORE — Nhập sản lượng)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Gate 20 phút không hoạt động — OP scan liên tục không bị chặn | BUG: `IF @SIExtInt01 = Null` (phải là `IS NULL`) trong SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | ALTER SP sửa `= Null` → `IS NULL` — xem [KB_08 §4.2](KB_08_CORE_SP_ENGINE.md#42-bug-đã-phát-hiện) |
| 2 | "Routing không có trong PO" hoặc "Đã hoàn thành" | Bỏ qua công đoạn trước chưa scan, hoặc PO config sai RouteIndex | Dùng Golden Query trace: `SELECT * FROM STB_ProdRouteHist WHERE ControlNo=(SELECT ControlNo FROM STB_SetInfo WHERE Barcode='mã') ORDER BY ProdDateTime` |
| 3 | Lỗi "Vượt SL công đoạn trước" (전공정의 수량을 초과할수 없습니다) | CurrentRouteQty + ProdQty > BefRouteQty | Kiểm tra SL Route trước: nếu đúng → chốt thêm ở Route trước. Nếu sai → sửa ProdQty |
| 4 | Thiếu/dư danh mục lỗi (Defect Code) trên lưới nhập lỗi | `STB_DefectInfo` chưa cập nhật | `UPDATE STB_DefectInfo SET IsUsed=0 WHERE DefectCode IN ('cũ')` + `INSERT INTO STB_DefectInfo (...) VALUES (...)` — xem [KB_03 §B530 Lỗi 3](KB_03/KB_03_02_CELL_LINE.md) |
| 5 | "Barcode chưa được đưa vào tuyến" (투입처리 되지 않은 바코드) | Barcode chưa qua công đoạn đầu (IsLineInput=0) | Scan lại từ công đoạn đầu (IsInputRoute=1), hoặc IT chạy: `UPDATE STB_SetInfo SET IsLineInput=1 WHERE ControlNo='mã'` |
| 6 | "PQC chưa nhập số lượng NG" | SP check DefectQty ở công đoạn trước phải > 0 khi có mã lỗi `_00` (Đạt) | Logic bug — mã `_00` = OK nhưng SP đọc COUNT lỗi = 0 → nhầm là chưa nhập. Fix: ALTER SP hoặc IT nhập 1 dòng DefectQty=0 cho mã `_00` |
| 7 | Grid `ProdRouteBarcodeForDefect_VNT` hiển thị lỗi sai/thừa cần xóa | OP nhập nhầm defect hoặc defect tạo tự động không đúng | Xóa mềm: `UPDATE STB_DefectRepairInfo SET IsDelete='1', ChangeDateTime=GETDATE(), ChangeUserID='ducnv_fix' WHERE ControlNo=(SELECT ControlNo FROM STB_SetInfo WHERE Barcode='MÃ_BARCODE') AND IsDelete='0'`. VD: Barcode `K16418106262500772` → ControlNo `20260618000445`, DefectSummaryNo `20260619000834/835` (VP02_005, ND02_006). ducnv 2026-06-19 |

> 🔗 Chi tiết: [KB_03 §B530](KB_03/KB_03_02_CELL_LINE.md), [KB_08 §2](KB_08_CORE_SP_ENGINE.md) và [KB_08](KB_08_CORE_SP_ENGINE.md)

### [B540]
**Tên:** Process Input V22→V28 (Nhập NVL theo công đoạn)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Scan NVL bị lỗi "Sai chủng loại" | Mã NVL không nằm trong BOM config của PO cho Route | Kiểm tra BOM: `SELECT * FROM STB_ProductionOrderBom WHERE PONo='mã' AND RouteCode='V-22'` |

### [B552]
**Tên:** Slitting Configurations (Thiết lập chia cuộn điện cực)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | "Không tồn tại thiết lập Điện cực... Chưa CONFIG STB_SLITTINGLOCATIONCONFIG_VVT" | Bảng `STB_SlittingLocationConfig_VVT` thiếu record cho model | `INSERT INTO STB_SlittingLocationConfig_VVT (MaterialCode, LocationCode, ...) VALUES (...)` — xem [KB_05_02 §8.2](KB_05/KB_05_02_SCREEN_BUGS_QC.md#82-lỗi-chưa-config-trong-stb_slittinglocationconfig_vvt) |

> 🔗 Chi tiết: [KB_05_02 §7.6](KB_05/KB_05_02_SCREEN_BUGS_QC.md)

### [B560]
**Tên:** Hela OutBox List (In tem thùng Hela)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | In tem Hela trống hoặc sai format | Config label Hela chưa map đúng model | Kiểm tra `STB_HelaPackingCheckHist` + Label config |

### [B597]
**Tên:** Material Scanning (★ HOT — Scan NVL đầu vào chuyền)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Cảnh báo đỏ HOLD — "Lot chưa QC" | Lot nằm kho `HOLDING_WH` | QC hoàn thành IQC hoặc chuyển kho: `UPDATE STB_MaterialLotInfo SET MaterialWarehouseCode='ROH_WH' WHERE LotID='mã'` (⚠️ Cột là `MaterialWarehouseCode`, KHÔNG phải `WarehouseCode`) |
| 2 | Cảnh báo "Hết hạn sử dụng" | Lot vi phạm FIFO/Expiry | Gia hạn: `UPDATE STB_MaterialLotInfo SET CreateDateTime = DATEADD(DAY,-30,GETDATE()) WHERE LotID='mã'` |
| 3 | "Sai chủng loại" — NVL không trong BOM | NVL scan không match BOM config PO | Kiểm tra BOM tại B310 hoặc SQL |
| 4 | Vỏ nhôm (AluCase) mới báo sai chủng loại | Mã vỏ nhôm bị **hardcode** trong SP `usp_Vietnam_RawMaterialInputHist_uid` | ALTER SP bổ sung mã mới vào `IF / NOT IN` — xem [KB_05_02 §7.4](KB_05/KB_05_02_SCREEN_BUGS_QC.md) |
| 5 | "String or binary data truncated" khi quét gộp 5 mã điện cực | Cột `RawMaterialBarcode NVARCHAR(100)` quá ngắn | `ALTER TABLE STB_InputMaterialHistory ALTER COLUMN RawMaterialBarcode NVARCHAR(1000)` + sửa SP tương ứng — xem [KB_05_02 §7.5](KB_05/KB_05_02_SCREEN_BUGS_QC.md) |
| 6 | "Mã Electrolyte/DUNG DỊCH được thiết lập, khác với mã QRCODE nhập vào" | Quét mã dung dịch sai chủng loại → SP check bảng config | Kiểm tra đúng mã NVL dung dịch, hoặc thêm vào config |
| 7 | OP nhập NVL module (Wire/PCB/Chip) bằng gõ tay thay vì scan barcode lot cho model 1840-WC(40) | SP `usp_Vietnam_RawMaterialInputHist_uid` dòng 318 exclude `MODULE%` khỏi validation → OP gõ tự do `40`, `dm`, `0` | Thêm block chặn sau `END -- end chặn chemical`: check `@mmmaterialcode` (lookup sẵn từ `stb_materialdoclotinfo` line 264). ModuleWire→WRHI00-007, ModuleChip→VRE-009, ModulePCB→PBDM00-004. Nếu `@mmmaterialcode=''` (gõ tay) → RAISERROR. ducnv 2026-06-19 |
| 8 | Quét điện cực báo "Lỗi BOM CREYO85B-02 không được phép dùng cho model ECVT30-293" và chặn lưu tồn kho slitting | Quét mã Coating-Roll (CREYO85B-02/CRFYO85B-02) trong khi BOM PO 260601000001 chỉ chứa mã Slitting-Roll (SREYO85A/SRFYO85A), đồng thời Lot chưa có tồn kho slitting | Cách 1: Sửa SP `usp_Vietnam_RawMaterialInputHist_uid` map mã tráng sang mã slitting tại L1279 và bypass slitting stock check tại L2124. Cách 2: Chuyển Lot sang chạy dưới PO `260623000007` (Model `ECVT30-367`) để bypass BOM check (nếu đã khai báo slitting stock). |

> 🔗 Chi tiết: [KB_05_02 §7](KB_05/KB_05_02_SCREEN_BUGS_QC.md), [KB_03 §B597](KB_03/KB_03_02_CELL_LINE.md)

### [B598]
**Tên:** Material Scrap Report (Báo phế NVL)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Báo phế NVL bị chặn/không đồng bộ | Lệch `JobDate` giữa ca thực tế và kế hoạch | Sửa JobDate: `UPDATE STB_ProdRouteHist SET JobDate = CAST(GETDATE() AS DATE) WHERE ...` |

> 🔗 Chi tiết: [KB_03 §6.12](KB_03/KB_03_02_CELL_LINE.md)

### [B618]
**Tên:** Rework (Làm lại sản phẩm)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | "Bạn không có quyền vui lòng liên hệ EA !" | SP `usp_GetInforLotReworkHaNamFactory_uid` hardcode check UserID | Thêm UserID vào whitelist trong SP hoặc tạo record permission |

### [B682]-[B791]
**Tên:** Stage Prices & Defect Reports

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | B786 ESR không hiện data | ESR data chưa upload hoặc Lot chưa match | Kiểm tra `STB_VVT_ESRDATA` WHERE Barcode='mã' |
| 2 | B791 NG Defect Repair — SL NG lệch | `DefectQty` trong `STB_ProdRouteHist` không khớp `STB_DefectRepairInfo` | Đồng bộ lại: xem [KB_03 §5.8](KB_03/KB_03_02_CELL_LINE.md) |

### [B754]-[B790]
**Tên:** Customer Labels (PAC, Digi-Key, Phoenix Contact, Sanmina)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | In tem PAC/DigiKey/Phoenix trống | Label spec chưa config hoặc LabelType sai | Kiểm tra `STB_ModelLabelInfo` + `STB_PackingLabelSpec` |
| 2 | Tem Phoenix Contact sai mã khách hàng | Config customer mapping thiếu | Kiểm tra `STB_PackingLabelSpec` (⚠️ `STB_PhoenixContactLabelInfo` KHÔNG tồn tại trong DB — data lưu trong PackingLabelSpec hoặc hardcode SP) |
| 3 | **[B767]** Tìm kiếm lần 2 bị lặp dữ liệu trên lưới (6 dòng thay vì 3 dòng) | Thuộc tính `데이터 추가` (Append Data) của hàm tìm kiếm `usp_SanminaLabelPrint_get_Vietnam` đang set là `True`. Khi search lần 2, do số Serial (`BoxSerialNo`, `PrintSerialNo` tự tăng dựa trên `@MaxSerial`) thay đổi, hệ thống không tìm thấy dòng trùng lặp và tự động append tiếp vào cuối grid. | Mở NAIS screen designer B767 → Chọn `Search Function` `usp_SanminaLabelPrint_get_Vietnam` → Tại bảng Property bên phải, nhóm `Group` → Chuyển `데이터 추가` từ `True` sang `False`. Save layout và Approve. |

> 🔗 Chi tiết: [KB_04 §6.9.4](KB_04/KB_04_01_CORE_PACKAGING.md)

### [B802]
**Tên:** Electrode Production History

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Thiếu công đoạn trên báo cáo | OP chưa nhập đủ 4 công đoạn (Mixing/Coating/Rollpress/Slitting) tại B552 | Yêu cầu OP bổ sung nhập liệu tại B552 |
| 2 | 🔴 BY/YP 120/180 A301 1.5B: Mixing Input = 0, có Coating Output | App cân NVL Mixing trên máy CMC không gọi SP `usp_DoCreateElectrodeMixStepInfo_electron`. DB + SP + config `STB_ElectrodeStep` đều OK. Ảnh hưởng: `CREBL85L`, `CRFYL85-01`, `CRFYN85L-01`. Phát hiện 2026-06-19. | Kiểm tra phần mềm cân trên máy CMC (log, phiên bản, kết nối DB). Xem [KB_05 §8.9](KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md) |

### [B882]
**Tên:** ANDON Display

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | ANDON không hiện real-time | WebSocket disconnect hoặc AndonDB query timeout | Kiểm tra kết nối WebSocket + `AndonDB.dbo.ANDON_*` tables |

---


### B767
**Ten:** Chua xac dinh

| # | Trieu chung | Nguyen nhan | Fix |
|---|---|---|---|
| 1 | S/N of the first label (Outer label) is blank on Sanmina label print | Stored procedure usp_SanminaLabelPrint_get_Vietnam set PrintSerialNo to empty and BoxSerialNo to first inner serial for Outer label. Changed it to output comma-separated list of inner box serials for both. | `ALTER PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam] ... (BoxSerialNo and PrintSerialNo case expressions changed to combine Inner1Serial and Inne...` |
## C-Series: QC & Chất Lượng

### [C121]-[C122]
**Tên:** QC Inspection Setup

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Lot NVL không có hạng mục kiểm tra | Chưa gán NVL vào nhóm kiểm tra tại C122 | Vào C121 thêm nhóm → C122 map NVL → nhóm |

> 🔗 Chi tiết: [KB_05 §9.1](KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md)

### [C220]
**Tên:** IQC Incoming Quality Control

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | F330 bị chặn "Receiving Confirmation" | IQC chưa PASS Lot tại C220 | QC hoàn thành nhập kết quả + xác nhận PASS |

### [C243]
**Tên:** QC Kiểm Tra Lot Slitting

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Lot slitting không chuyển về kho được | QC đánh Reject → không thể chuyển | Xử lý theo quy trình NG — không bypass |

### [C321]
**Tên:** PQC Reliability Assy (Sửa chữa lỗi Cell Line)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Lưu sửa chữa lỗi → sai lệch DefectQty ở trạm tiếp | Đồng bộ giữa `STB_DefectRepairInfo` và `STB_ProdRouteHist` bị lệch | IT chỉnh sửa DefectQty/ProdQty trực tiếp DB |

> 🔗 Chi tiết: [KB_05 §9.5](KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md)

### [C443]
**Tên:** PQC Quality Verification

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Cần hủy kết quả QC (nhập nhầm) | Data đã ghi vào `STB_CommInspDocHistory` + `STB_CommInspDocItem` | Xóa để QC làm lại: |

```sql
BEGIN TRANSACTION;
DECLARE @DocNo NVARCHAR(50) = (
    SELECT CIDH.CommInspDocNo FROM STB_CommInspDocHistory CIDH
    JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
    WHERE SI.Barcode = 'MÃ_BARCODE'
);
DELETE FROM STB_CommInspDocItem WHERE CommInspDocNo = @DocNo;
DELETE FROM STB_CommInspDocHistory WHERE CommInspDocNo = @DocNo;
COMMIT TRANSACTION;
```

> 🔗 Chi tiết: [KB_05_02_SCREEN_BUGS_QC.md](file:///c:/Users/User Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md#L752) (§ Kịch bản B: Hủy kết quả QC)

### [C451]
**Tên:** PQC Inspection

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Load lại hạng mục cũ, không cho sửa | Cache QC document từ lần trước | Xóa CommInspDoc cũ rồi tạo lại — xem C443 |

### [C486]
**Tên:** QC Measuring Items (Đo kích thước điện cực)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Cột Note1 thừa trên Grid / cột bị xáo | Lỗi metadata grid trong SmartFramework | Rebuild bảng + ALTER bảng tương ứng — xem [KB_05_02 §7.8](KB_05/KB_05_02_SCREEN_BUGS_QC.md) |

### [C512]
**Tên:** OQC Lot Management

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Không tìm thấy Lot khi tạo OQC | Lot chưa gộp box B523 HOẶC PO thiếu `IsOutputRoute=1` | Kiểm tra B523 + sửa `STB_ProductionOrderRouting` |
| 2 | Model mới không hiện khi chọn | A410 chưa config OqcType | Xem A410 ở trên |

### [C530] (OQC)
**Tên:** OQC Product Inspection

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Sửa hạng mục ở C151 nhưng C530 không hiện | Chưa ấn "Tổng hợp hạng mục" | Vào C530 → ấn nút "Tổng hợp hạng mục" để reset |
| 2 | OQC bị lỗi khi bấm Reject nhưng muốn Pass lại | Nút Pass bị disable sau Reject | ⚠️ `CommInspResult` KHÔNG phải cột trong DB — OQC Pass/Fail được xử lý qua SP `usp_DoUpdateMaterialQcInfo_Success/Fail`. Cách fix: (1) Xóa MaterialQcInfo cũ bằng `usp_DoDeleteMaterialQcInfo`, (2) Tạo lại OQC mới tại C512, (3) Nhập lại kết quả QC |

### [C546]
**Tên:** FOQC — OCV/ESR Measurement

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | OCV chỉ hiện 20 dòng thay vì 50 | SP `usp_Vietnam_MaterialFOQcDetail_get` thiếu block WHILE cho DetailNo=2 (OCV) | Thêm block WHILE cho OCV — xem [KB_05_02 §9.6](KB_05/KB_05_02_SCREEN_BUGS_QC.md) |

### [C560]
**Tên:** FG Receipt (Nhập kho thành phẩm)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Không hiện dữ liệu hàng chờ QC Audit | SP filter theo `WorkCenterCode` không match nhà máy HN/HY | ALTER SP thêm WorkCenterCode mới |
| 2 | Báo "chưa kiểm tra QC" dù carton mới đã Pass | Bug logic `AND @Statusout IS NULL` trong SP | Sửa logic AND → OR hoặc check đúng carton mới |

### [C585]
**Tên:** VVT Thêm chi tiết lỗi theo Lot

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Dropdown "Tên phân loại lỗi" có mã 05, 06 trùng với 03, 07 | `SmartFramework.STB_BaseCode` (CodeGroup='DefectDivisionCode') chứa entries trùng: 05=제품검사(베트남) trùng 03=제품검사, 06=출하검사(베트남) trùng 07=FOQC | Cập nhật bản ghi giao dịch: `UPDATE STB_QCDefectDetailsRecord SET DefectDivisionCode='03' WHERE DefectDivisionCode='05'`, tương tự 06→07. Sau đó xóa: `DELETE FROM SmartFramework.dbo.STB_BaseCode WHERE CodeGroup='DefectDivisionCode' AND ItemCode IN ('05','06')`. Script: `sql/data_fixes/C585_delete_defect_division_05_06.sql` |

> 🔗 Popup: `GetBaseCode2` → `SmartFramework.STB_BaseCode`. SP: `usp_QCDefectDetailsRecordDummy_get` / `usp_DoCreateQCDefectDetailsRecord_iud`

---

## D-Series: Enesol / Hưng Yên

### [D100]-[D110]
**Tên:** VinaEnesol Label Print & History

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | CustomerPartNo trống khi in tem | `STB_CustomerPartNoInfo` thiếu mapping model→customer | INSERT mapping: xem [KB_07 §5.4](KB_07/KB_07_01_OVERVIEW.md) |
| 2 | Máy in không chạy hoặc tem trống | Cấu hình printer hoặc label template lỗi | Kiểm tra kết nối printer + template trong Z530 |
| 3 | D110 thiếu/trùng bản ghi | Insert duplicate hoặc filter sai | Kiểm tra SP `usp_VNE_BoxLabelPrintHist_*` |

> 🔗 Chi tiết: [KB_07 §5](KB_07/KB_07_01_OVERVIEW.md)

---

## F-Series: Kho & Vật Tư

### [F330]
**Tên:** Material Receipt (Phiếu nhập kho NVL)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Bị chặn "Receiving Confirmation" | IQC chưa PASS tại C220 | QC hoàn thành IQC PASS trước |
| 2 | NVL không tìm thấy trong popup chọn | Chưa khai báo NVL tại A230 | Vào A230 thêm MaterialCode |
| 3 | Đổi mã vật tư tự động lỗi | `STB_ChangeMaterialCode_HN` thiếu mapping | INSERT mapping mã cũ→mới — xem [KB_02 §3.1](KB_02/KB_02_01_WMS_CORE.md) |

> 🔗 Chi tiết: [KB_02 §4.15](KB_02/KB_02_01_WMS_CORE.md)

### [F430]
**Tên:** Material Transfer (Chuyển kho)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Lot không chuyển kho được | Lot bị HOLD hoặc QC Reject | Giải phóng HOLD hoặc xử lý theo quy trình NG |

### [F721]
**Tên:** Material Stock (Tồn kho NVL)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Tồn kho âm | Backflush trừ quá hoặc phiếu xuất kho tạo sai | Kiểm tra `STB_MaterialStock` + `STB_MaterialDocInfo` type='GI' |

### [F743]-[F748]
**Tên:** Electrode Slitting

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | "Trùng mã nguyên liệu" khi Slitting | F744 đã có record cho MaterialCode | Kiểm tra + sửa record cũ trong F744 |
| 2 | Lot không tồn tại khi chuyển F430 | Lot chưa QC check ở C243 | Vào C243 check trước |
| 3 | Hủy/Rollback Slitting bị lỗi | Chưa xóa lịch sử F746 trước | Xóa F746 trước rồi mới rollback F742 |
| 4 | Không tìm thấy foil mới trong popup hoặc thiếu dòng trên F744 | Mã foil con chưa đăng ký trong STB_MaterialMaster hoặc thiếu dòng trong STB_WidthSlitting | (1) Đăng ký foil vào STB_MaterialMaster nhóm ANODE-FOIL, (2) Set F110 stock attributes, (3) Thêm cấu hình width vào STB_WidthSlitting. Script mẫu: **add_foil_f744_5.5mm.sql** |

> 🔗 Chi tiết: [KB_05 §10](KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md), [KB_02 §Lỗi 4](KB_02/KB_02_02_SCREEN_BUGS.md#lỗi-4-không-tìm-thấy-mã-foil-mới-trong-popup-để-thiết-lập-chiều-rộng-cắt-ở-f744)


---

## G-Series: Thành Phẩm

### [G660]
**Tên:** Daifuku Warehouse (Kho robot tự động)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Robot không nhận lệnh nhập/xuất | Kết nối Daifuku interface bị mất hoặc slot đầy | Kiểm tra `usp_DaifukuWarehouse_iud` + trạng thái slot |

---

## H-Series: Hà Nam (VVT_F3)

### [HN523]
**Tên:** Packing Hà Nam

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Gộp box lỗi Qty=0 | `STB_PackingStandard` thiếu record cho model HN | INSERT record — xem [KB_04 §6.13](KB_04/KB_04_01_CORE_PACKAGING.md) |
| 2 | Gộp túi nilon lỗi | `STB_PackingNilonToBoxSmall_HN` config sai | Kiểm tra + update config |

### [HNC321]
**Tên:** Defect Repair Hà Nam

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | "이전 공정에 실적처리 이력이 없습니다" (Không có lịch sử công đoạn trước) | SP chặn vì chưa có ProdRouteHist ở Route trước | Chèn dòng ProdRouteHist giả lập: |

```sql
BEGIN TRANSACTION;
DECLARE @CtrlNo NVARCHAR(50) = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE');
INSERT INTO STB_ProdRouteHist (ControlNo, ProcSeq, RouteCode, LineCode, ...)
VALUES (@CtrlNo, (SELECT ISNULL(MAX(ProcSeq),0)+1 FROM STB_ProdRouteHist WHERE ControlNo=@CtrlNo),
    'VE07', 'LINE', ...);
COMMIT TRANSACTION;
```

> 🔗 Chi tiết: [KB_05_02_SCREEN_BUGS_QC.md](file:///c:/Users/User Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md#L820) (§ Kịch bản sự cố khẩn cấp 3: Lỗi nhập phế HNC321)

### [HN551]
**Tên:** FG Export Hà Nam

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Xuất kho TP không hiện data | SP filter WorkCenterCode không match HN | ALTER SP thêm WorkCenterCode HN |

---

## [BG2] — K Series: Đặc Biệt /

### [K101]
**Tên:** Lot Tracking BG2

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Lot tracking trống cho PO BG2 | PO chưa config Route cho BG2 (V-22_BG, V-28_BG) | Thêm Route BG2 vào PO |

### [K109]
**Tên:** BG2 Production Plan

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Không tạo được kế hoạch ngày BG2 | DayPlan table thiếu config WorkCenterCode='VVT_F4' | Kiểm tra `STB_DayProdPlan` + config |

### [K110]
**Tên:** BG2 Material Scan

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Scan NVL BG2 bị chặn | NVL kho BG2 chưa config WarehouseCode | Map kho BG2 trong `STB_LineRouteMapping` |

### [K198]-[K199]
**Tên:** Customer Labels (Bloom / Nordex)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Tem Bloom/Nordex in sai format | Label template không match model mới | Kiểm tra `usp_VN_BloomBoxLabelPrintHist_iud` / `usp_NordexPackingLabelPrintingHist_get` |

---


### [K366]
**Ten:** Chua xac dinh

| # | Trieu chung | Nguyen nhan | Fix |
|---|---|---|---|
| 1 | K366 screen displays blank Status column (Final conclusion Pass/Fail) | Stored procedure usp_LotTrackingInfo_VVTF4_get does not return the Status column to map to the grid. | `-- ============================================= -- Author:		Nguyễn Hải Triều(Mr.Dev) -- Create date: 2026-06-18 -- Description:	Kiểm tra dữ liệu Lot ...` |
## P-Series: HR & Tài Liệu

### [P111]
**Tên:** Attendance (Chấm công)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Bảng chấm công thiếu/sai giờ vào/ra | Dữ liệu vân tay (Z711) chưa đồng bộ hoặc lỗi máy chấm | Kiểm tra `STB_VN_Shift` + data máy vân tay |

---

## Z-Series: System Admin

### [Z410]
**Tên:** User Management

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Tài khoản bị khóa | Nhập sai mật khẩu quá số lần cho phép | Reset tại Z410 hoặc SQL: `UPDATE SmartFramework.dbo.STB_UserInfo SET AllowFlag=1 WHERE UserID='mã'` (⚠️ Cột là `AllowFlag`, KHÔNG có `IsLocked`) |
| 2 | User không thấy menu | Chưa gán quyền tại Z220 (UserTypePermission) | Vào Z220 → tick quyền cho UserType |

> 🔗 Chi tiết: [KB_06 §9.3](KB_06_MASTER_DATA_TOOLS.md)

### [Z530]
**Tên:** Label Info (Label Design)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Tem in không đúng format | Template label bị sai layout | Vào Z530 → sửa label template → deploy lại |

---

## Bugs Cấp Hệ Thống (Cross-Screen)

### Vendor Lot Parse Crash
| Triệu chứng | Nguyên nhân | Fix |
|---|---|---|
| Crash "Conversion failed" khi parse Vendor Lot `WRHI00-002` | SP cố parse numeric từ chuỗi chứa ký tự đặc biệt | ALTER SP thêm `TRY_CONVERT` thay vì `CONVERT` |

### LotAttr10 Batch Update Bug
| Triệu chứng | Nguyên nhân | Fix |
|---|---|---|
| Update ngày SX hàng loạt → chỉ Lot cuối cùng được đồng bộ | SP dùng `MAX(LotID)` thay vì loop qua tất cả | ALTER SP sửa logic loop |

### [G400] — Customer Return () Reject
| Triệu chứng | Nguyên nhân | Fix |
|---|---|---|
| Trả hàng lỗi "Chưa hoàn thành IQC" | SP check IQC PASS cả khi hàng trả lại (không cần IQC) | ALTER SP bypass IQC check cho Return type |

### Lò Sấy Bypass (Hưng Yên)
| Triệu chứng | Nguyên nhân | Fix |
|---|---|---|
| Lot chưa hoàn thành V-22 nhưng vẫn vào lò sấy được | SP không check `IsRouteFinish` trước khi cho vào lò | Thêm validation check — xem [KB_07 §5.1](KB_07/KB_07_01_OVERVIEW.md) |

### Doping JIG Auto-End Mất Lịch Sử
| Triệu chứng | Nguyên nhân | Fix |
|---|---|---|
| JIG chạy 6h auto-end → lịch sử biến mất | SP `autoend` không INSERT vào `Stb_VVT_DopingJIG_History` | ALTER SP thêm INSERT — xem [KB_07 §5.2](KB_07/KB_07_01_OVERVIEW.md) |

---

## Quick Reference: Quy Trình Debug Chung

```
1. User báo lỗi → Xác định TCode (mã màn hình)
2. Tra TCode trong file này → tìm Triệu chứng matching
3. Nếu tìm thấy → đọc Fix + tham chiếu KB gốc
4. Nếu KHÔNG tìm thấy → dùng quy trình Trace Methodology dưới đây:
   a. Bước 0: Tra Screen→SP mapping (STB_ScreenObjects)
   b. Bước 1: Thu thập triệu chứng
   c. Bước 2: Pull SP code → đọc RAISERROR
   d. Bước 3: Tìm dòng code gây lỗi
   e. Bước 4: ALTER SP hoặc sửa data
```

---

*Cập nhật: 2026-06-19 | Tổng hợp từ KB_02, KB_03, KB_04, KB_05, KB_06, KB_07*





