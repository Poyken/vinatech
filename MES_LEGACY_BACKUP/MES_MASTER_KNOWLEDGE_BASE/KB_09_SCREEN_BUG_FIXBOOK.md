<!--
AI-READY METADATA
Purpose: Sổ tay cứu hộ 70+ bugs theo TCode thực tế (Tra cứu triệu chứng -> nguyên nhân -> giải pháp SQL patch)
Scope: Troubleshooting & Hotfix Knowledge Base
Single Source of Truth: KB_09_SCREEN_BUG_FIXBOOK.md (Troubleshooting & Bug Registry)
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/BOOTSTRAP.md)
  - [HOTFIX_LOG.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/HOTFIX_LOG.md)
-->

# KB_09: Sổ Tay Tra Cứu Bug & Fix Theo Màn Hình

> **📌 Mục đích:** Khi nhận được báo lỗi từ user → tra TCode tại đây → tìm ngay bug + cách fix.
> **🔑 Keywords:** bug, fix, sổ tay, TCode, màn hình, triệu chứng, nguyên nhân, SQL fix, sửa lỗi, khắc phục
> **⚡ DB Status:** Direct Live Connected & Verified against `dbserver.hycap.co.kr,5398` (`SmartFactoryV2` + `SmartFramework`)
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)


---

## Mục lục nhanh

| Prefix | Màn hình | Số bug |
|---|---|---|
| **A** | [A230](#a230), [A310](#a310), [A410](#a410), [A418](#a418), [A460](#a460), [A510](#a510) | 6 |
| **B** | [B210-B270](#b210-b270), [B310](#b310), [B351](#b351), [B442](#b442), [B452](#b452), [B523](#b523), [B528](#b528), [B530](#b530), [B540](#b540), [B552](#b552), [B560](#b560), [B597](#b597), [B598](#b598), [B618](#b618), [B682-B791](#b682-b791), [B754-B790](#b754-b790), [B802](#b802), [B882](#b882) | 27+ |
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

> 🔗 Chi tiết: [KB_06 §9.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md)

### [A310]
**Tên:** Route Info (Định nghĩa công đoạn)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | OP không thấy công đoạn mới trong danh sách Route | Chưa tạo Route tại A310 hoặc chưa map vào PO | Vào A310 → Thêm RouteCode → Map vào B210 (Line) |

> 🔗 Chi tiết: [KB_06 §9.4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md)

### [A410]
**Tên:** Model Basic Info (Cấu hình model)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | C512 không tìm thấy Lot OQC | Chưa config OqcType, InspectionLevel tại A410 | `UPDATE STB_ModelBasicInfo SET OqcType='MANUAL', OqcInspectionRuleType='BY_MODEL', InspectionType='SAMPLE', InspectionLevel='SAMPLE' WHERE ModelCode = 'mã'` |

> 🔗 Chi tiết: [KB_06 §9.5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md)

### [A418]
**Tên:** Packing Qty per Size (SL đóng gói theo Size)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | B523 không cho gộp Box, báo chưa có tiêu chuẩn đóng gói | Chưa khai báo A418 cho Size mới | Vào A418 → Thêm Size + PackingQty. SQL: `INSERT INTO STB_PackingQtyPerSize (SizeCode, PackingQty, ...) VALUES (...)` |

> 🔗 Chi tiết: [KB_06 §9.6](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md)

### [A460]
**Tên:** Model Label Info (Cấu hình in tem)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | In tem bị lỗi "Not found label type" | Chưa có record trong `STB_ModelLabelInfo` cho model | Copy từ model cũ cùng loại: `INSERT INTO STB_ModelLabelInfo SELECT 'MODEL_MỚI', LabelType, ... FROM STB_ModelLabelInfo WHERE ModelCode = 'MODEL_CŨ'` |

> 🔗 Chi tiết: [KB_04 §6.20](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md), [KB_05 §8.7](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md)

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

> 🔗 Chi tiết: [KB_03 §B210-B270](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md), [KB_01 §1.3](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md)

### [B310]
**Tên:** Production Order Info (Quản lý PO)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | PO không tạo được Lot | BOM/Route chưa cấu hình cho PO | Kiểm tra `STB_ProductionOrderRouting`, `STB_ProductionOrderBom` |
| 2 | ProdFinishQty lệch so với thực tế | Crash giữa SP `usp_DoProcessProdRouteHist` → dữ liệu partial | `UPDATE STB_ProductionOrderInfo SET ProdFinishQty = (SELECT SUM(ProdQty) FROM STB_ProdRouteHist WHERE PONo='mã' AND RouteCode='V-28') WHERE PONo='mã'` |
| 3 | PO thiếu công đoạn Aging hoặc sai thứ tự Index khiến không chốt được sản lượng | Cấu hình Routing của PO trên B310 chưa thêm công đoạn Aging (`V-26`) hoặc chưa đánh lại Index khi đổi kế hoạch | Vào B310 → Tìm PO → Kiểm tra danh sách Routing → Thêm công đoạn Aging (`V-26` / `V-26_BG`) và cập nhật lại `RouteIndex`. |
| 4 | Tạo PO thủ công báo lỗi "공정 라우팅 정보가 없습니다" | Mã `BasicRoutingCode` gán cho Model trong `STB_MaterialMaster` không có record nào khớp với `WorkCenterCode` của nhà máy đang tạo PO trong `STB_BasicRoutingDetail` | Gán lại `BasicRoutingCode` chuẩn của nhà máy (ví dụ `HY_MainRoutingBigSiz` cho Hưng Yên `VVT_F5`) trong `STB_MaterialMaster` (hoặc A230) — xem [KB_03_03 §B310 Lỗi 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_03_SCREEN_BUGS_B.md#lỗi-3-공정-라우팅-정보가-없습니다-không-có-thông-tin-routing-công-đoạn-khi-tạo-po-thủ-công-tại-b310) |

### [B351]
**Tên:** Lot Transition (Chuyển đổi Lot/NVL)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Barcode sinh ra bị chèn ký tự dấu chấm (`.`) sai định dạng | Sai lệch logic cắt ghép chuỗi sinh barcode tự động | Sửa đồng loạt Barcode trong `STB_RawMaterialInputHist`, `STB_SetInfo`, `STB_LotChangeMaterialHistory` — xem [KB_04_02 §B351](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md#b351--lot-transition-chuyển-đổi-lot) |
| 2 | Yêu cầu in tem gốc (mã cũ) sau khi B351 đã chuyển đổi mã | Đã chuyển đổi sản xuất tại B351 (lưu `STB_LotChangeMaterialHistory`), B525 tự động in tem mã mới | ⚠️ **CẦN QUẢN LÝ PHÊ DUYỆT:** Khi được phê duyệt, chạy script rollback đồng bộ 4 bảng (`STB_SetInfo`, `STB_MaterialLotInfo`, `STB_ProdRouteHist`, `STB_LotChangeMaterialHistory`) — xem [KB_04_02 §B351 Lỗi 2](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md#lỗi-2-user-yêu-cầu-in-lại-tem-gốc-mã-cũ-sau-khi-sản-xuất-đã-chuyển-đổi-lot-tại-b351) |
| 3 | Bấm nút "Thay đổi model" báo lỗi popup red X `No data to process` | Chưa chọn/gán Kế hoạch mục tiêu (Target Plan/Material) từ Lưới 1 xuống Lưới 2 (`SetInfoForChangeMaterial`), khiến các cột `TargetDayPlanNo` / `TargetMaterialCode` bị trống (rỗng) | Thao tác UI: (1) Tìm Kế hoạch sản xuất mục tiêu ở Lưới 1 (`DayProdPlanForChangeMaterial`), (2) Chọn các dòng Lot ở Lưới 2 và thực hiện gán Target để các cột `TargetDayPlanNo` và `TargetMaterialCode` hiển thị mã mới, (3) Nhấn lại nút "Thay đổi model" — xem [KB_04_02 §B351 Lỗi 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md#lỗi-3-bấm-nút-thay-đổi-model-xuất-hiện-thông-báo-no-data-to-process) |

### [B442]
**Tên:** Electrode Day Plan (Kế hoạch ngày điện cực)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | In tem điện cực lỗi "Not found label type" | Model chưa có record `STB_ModelLabelInfo` (LabelType='ElectLabel') | Xem A460 ở trên |
| 2 | Cột "Độ dày" trống | A230 chưa set MaterialThickness | Xem A230 ở trên |

> 🔗 Chi tiết: [KB_05 §8.7](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md)

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
| 3 | Gộp box HN523 lỗi Qty=0 | `STB_PackingStandard` thiếu record cho model Hà Nam | INSERT record vào `STB_PackingStandard` — xem [KB_04 §6.13](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md) |
| 4 | Gộp box lỗi do PO có công đoạn hậu đóng gói B523 | Thiếu lịch sử Route `V-28_BG` | Chèn dòng ProdRouteHist giả lập — xem [KB_04 §6.13.2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md) |
| 5 | MergeQty không chia đúng khi gộp nhiều Lot | Logic `@pMergeQty < @total + @InProdQty` bị edge case | Kiểm tra số lượng Lot trước khi gộp, đảm bảo tổng = MergeQty |
| 6 | Sanmina QR code has redundant quantities and serials on inner labels | Stored procedure usp_SanminaLabelPrint_get_Vietnam did not return a filtered list of serials and quantities for inner labels. | `-- ============================================= -- Author:		Mr.Manh -- Create date: 2025-12-26 -- Description:	Get Sanmina label -- =================...` |
| 7 | Popup đỏ `"Could not find Kho Thành phẩm chưa nhập cân nặng cho Lót hàng này!"` khi ấn In tem / In Tem & sau B351 chuyển đổi Lot | Mã Lot mới chưa có dữ liệu cân trong `STB_VIETNAM_BARCODEWEIGHT` (SP `usp_Vietnam_GetBoxIDForLotNo_VVT` tính `@lotweight=0`). Lưu ý: SP hardcode Whitelist `IF (@pProcessUserID IN ('vvt_worker', 'vvtworker', ...))` ép `@lotweight=1` bypass cho account test/admin, còn account công nhân sản xuất (vd: `vvtworker_BG`) không thuộc Whitelist nên bị kẹt `@lotweight=0` ➔ SP trả `FormatName = N'Kho Thành phẩm chưa nhập cân nặng...'` ➔ WinForm Client C# tìm file mẫu tem tên này KHÔNG THẤY ➔ Throw popup | Run master SQL fix: Nạp `WEIGHT` vào `STB_VIETNAM_BARCODEWEIGHT` + `STB_VN_FINISHGOODS` + `STB_VN_FINISHGOODS_BG` + đồng bộ `STB_LotChangeMaterialHistory` & `STB_PackingLabelPrintHist`. Xem mẫu SQL chuẩn tại [KB_04_02 §6.20](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md#620-b523--bug-chuyển-đổi-lot-ở-b351-gây-kẹt-nút-in-tem--in-tem--lỗi-could-not-find-kho-thành-phẩm-chưa-nhập-cân-nặng) |

> 🔗 Chi tiết: [KB_04 §6](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md), [KB_08 §5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md)

### [B528]
**Tên:** Barrel Barcode (In tem thùng phuy)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Tem barrel in trống hoặc thiếu thông tin | Label config chưa set cho model dạng Barrel | Kiểm tra `STB_ModelLabelInfo` → LabelType='BarrelLabel' |

### [B530]
**Tên:** Route Input / Production Qty Output (★ CORE — Nhập sản lượng)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Gate 20 phút không hoạt động — OP scan liên tục không bị chặn | BUG: `IF @SIExtInt01 = Null` (phải là `IS NULL`) trong SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | ALTER SP sửa `= Null` → `IS NULL` — xem [KB_08 §4.2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md#42-bug-đã-phát-hiện) |
| 2 | "Routing không có trong PO" hoặc "Đã hoàn thành" | Bỏ qua công đoạn trước chưa scan, hoặc PO config sai RouteIndex | Dùng Golden Query trace: `SELECT * FROM STB_ProdRouteHist WHERE ControlNo=(SELECT ControlNo FROM STB_SetInfo WHERE Barcode='mã') ORDER BY ProdDateTime` |
| 3 | Lỗi "Vượt SL công đoạn trước" (전공정의 수량을 초과할수 없습니다) | CurrentRouteQty + ProdQty > BefRouteQty | Kiểm tra SL Route trước: nếu đúng → chốt thêm ở Route trước. Nếu sai → sửa ProdQty |
| 4 | Thiếu/dư danh mục lỗi (Defect Code) trên lưới nhập lỗi | `STB_DefectInfo` chưa cập nhật | `UPDATE STB_DefectInfo SET IsUsed=0 WHERE DefectCode IN ('cũ')` + `INSERT INTO STB_DefectInfo (...) VALUES (...)` — xem [KB_03 §B530 Lỗi 3](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md) |
| 5 | "Barcode chưa được đưa vào tuyến" (투입처리 되지 않은 바코드) | Barcode chưa qua công đoạn đầu (IsLineInput=0) | Scan lại từ công đoạn đầu (IsInputRoute=1), hoặc IT chạy: `UPDATE STB_SetInfo SET IsLineInput=1 WHERE ControlNo='mã'` |
| 6 | "PQC chưa nhập số lượng NG" | SP check DefectQty ở công đoạn trước phải > 0 khi có mã lỗi `_00` (Đạt) | Logic bug — mã `_00` = OK nhưng SP đọc COUNT lỗi = 0 → nhầm là chưa nhập. Fix: ALTER SP hoặc IT nhập 1 dòng DefectQty=0 cho mã `_00` |
| 7 | Grid `ProdRouteBarcodeForDefect_VNT` hiển thị lỗi sai/thừa cần xóa | OP nhập nhầm defect hoặc defect tạo tự động không đúng | Xóa mềm: `UPDATE STB_DefectRepairInfo SET IsDelete='1', ChangeDateTime=GETDATE(), ChangeUserID='ducnv_fix' WHERE ControlNo=(SELECT ControlNo FROM STB_SetInfo WHERE Barcode='MÃ_BARCODE') AND IsDelete='0'`. VD: Barcode `K16418106262500772` → ControlNo `20260618000445`, DefectSummaryNo `20260619000834/835` (VP02_005, ND02_006). ducnv 2026-06-19 |
| 8 | Nút "Nhập lỗi" bị mờ / Ẩn (Disabled) | Công đoạn tiếp theo đã có dữ liệu (`IsHasNextProd = 1`) hoặc đã bị ghi nhận Loss (`IsLoss = 1`) theo biểu thức Expression: `!IsHasNextProd && !IsLoss` | Hủy/Rollback công đoạn sau: (1) `DELETE FROM STB_DefectRepairInfo WHERE ControlNo='...' AND FindRouteCode IN ('...')`, (2) `DELETE FROM STB_ProdRouteHist WHERE ControlNo='...' AND RouteCode IN ('...')`, (3) `UPDATE STB_ProdRouteHist SET CompleteRoute = NULL WHERE ControlNo='...' AND RouteCode='...'` cho công đoạn trước — xem [KB_03_01_OVERVIEW.md § 5.16](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md) |
| 9 | Báo lỗi "Công đoạn này không có trong Routing hoặc là công đoạn cuối cùng" khi chốt sản lượng | Công đoạn liền trước bị set `CompleteRoute = 1` trong khi các công đoạn downstream đã sinh dòng dở dang | Reset `CompleteRoute = NULL` ở công đoạn trước và xóa các dòng công đoạn downstream chưa hoàn thành: (1) `DELETE FROM STB_ProdRouteHist WHERE ControlNo = '...' AND ProdRouteHistNo IN (các_id_dưới)`, (2) `UPDATE STB_ProdRouteHist SET CompleteRoute = NULL WHERE ControlNo = '...' AND RouteCode = 'công_đoạn_trước'` |
| 10 | Báo lỗi popup "Công đoạn này không có trong Routing hoặc là công đoạn cuối cùng" khi chốt công đoạn Aging | Mã Lot/PO tạo ở nhà máy cũ (Bắc Giang 1 `VVT_F2`) nhưng người dùng đăng nhập bằng tài khoản Hưng Yên (`vvtworker_hy`) hoặc Bắc Ninh (`vvtworker_bn`) | Đổi tài khoản đăng nhập NAIS sang tài khoản nhà máy Bắc Giang (`vvtworker_bg`). Kiểm tra tem cáp thư xem Lot tạo ở nhà máy nào và đối chiếu với tài khoản tương ứng; kiểm tra lại Routing PO trên B310. |


> 🔗 Chi tiết: [KB_03 §B530](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md), [KB_08 §2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md) và [KB_08](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md)

### [B540]
**Tên:** Process Input V22→V28 (Nhập NVL theo công đoạn)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Scan NVL bị lỗi "Sai chủng loại" | Mã NVL không nằm trong BOM config của PO cho Route | Kiểm tra BOM: `SELECT * FROM STB_ProductionOrderBom WHERE PONo='mã' AND RouteCode='V-22'` |

### [B552]
**Tên:** Slitting Configurations & Electrode Measure Result (Chia cuộn & Kết quả đo điện cực)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | "Không tồn tại thiết lập Điện cực... Chưa CONFIG STB_SLITTINGLOCATIONCONFIG_VVT" | Bảng `STB_SlittingLocationConfig_VVT` thiếu record cho model | `INSERT INTO STB_SlittingLocationConfig_VVT (MaterialCode, LocationCode, ...) VALUES (...)` — xem [KB_05_02 §8.2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md#82-lỗi-chưa-config-trong-stb_slittinglocationconfig_vvt) |
| 2 | Yêu cầu xóa dữ liệu kết quả cắt điện cực theo STT (Seq 10-70) tại tab Slitting | Cắt dư hoặc lỗi dòng kết quả cắt điện cực cần dọn dẹp dữ liệu dở dang | Safe SQL Delete: `DELETE FROM STB_ElectrodeSlittingResult WHERE ElectrodeLotNumber = 'MÃ_LOT' AND Seq BETWEEN 10 AND 70` |

> 🔗 Chi tiết: [KB_05_02 §7.6](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md)

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
| 4 | Vỏ nhôm (AluCase) mới báo sai chủng loại | Mã vỏ nhôm bị **hardcode** trong SP `usp_Vietnam_RawMaterialInputHist_uid` | ALTER SP bổ sung mã mới vào `IF / NOT IN` — xem [KB_05_02 §7.4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md) |
| 5 | "String or binary data truncated" khi quét gộp 5 mã điện cực | Cột `RawMaterialBarcode NVARCHAR(100)` quá ngắn | `ALTER TABLE STB_InputMaterialHistory ALTER COLUMN RawMaterialBarcode NVARCHAR(1000)` + sửa SP tương ứng — xem [KB_05_02 §7.5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md) |
| 6 | "Mã Electrolyte/DUNG DỊCH được thiết lập, khác với mã QRCODE nhập vào" | Quét mã dung dịch sai chủng loại → SP check bảng config | Kiểm tra đúng mã NVL dung dịch, hoặc thêm vào config |
| 7 | OP nhập NVL module (Wire/PCB/Chip) bằng gõ tay thay vì scan barcode lot cho model 1840-WC(40) | SP `usp_Vietnam_RawMaterialInputHist_uid` dòng 318 exclude `MODULE%` khỏi validation → OP gõ tự do `40`, `dm`, `0` | Thêm block chặn sau `END -- end chặn chemical`: check `@mmmaterialcode` (lookup sẵn từ `stb_materialdoclotinfo` line 264). ModuleWire→WRHI00-007, ModuleChip→VRE-009, ModulePCB→PBDM00-004. Nếu `@mmmaterialcode=''` (gõ tay) → RAISERROR. ducnv 2026-06-19 |
| 8 | Quét điện cực báo "Lỗi BOM CREYO85B-02 không được phép dùng cho model ECVT30-293" và chặn lưu tồn kho slitting | Quét mã Coating-Roll (CREYO85B-02/CRFYO85B-02) trong khi BOM PO 260601000001 chỉ chứa mã Slitting-Roll (SREYO85A/SRFYO85A), đồng thời Lot chưa có tồn kho slitting | Cách 1: Sửa SP `usp_Vietnam_RawMaterialInputHist_uid` map mã tráng sang mã slitting tại L1279 và bypass slitting stock check tại L2124. Cách 2: Chuyển Lot sang chạy dưới PO `260623000007` (Model `ECVT30-367`) để bypass BOM check (nếu đã khai báo slitting stock). |

> 🔗 Chi tiết: [KB_05_02 §7](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md), [KB_03 §B597](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md)

### [B598]
**Tên:** Material Scrap Report (Báo phế NVL)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Báo phế NVL bị chặn/không đồng bộ | Lệch `JobDate` giữa ca thực tế và kế hoạch | Sửa JobDate: `UPDATE STB_ProdRouteHist SET JobDate = CAST(GETDATE() AS DATE) WHERE ...` |

> 🔗 Chi tiết: [KB_03 §6.12](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md)

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
| 2 | B791 NG Defect Repair — SL NG lệch | `DefectQty` trong `STB_ProdRouteHist` không khớp `STB_DefectRepairInfo` | Đồng bộ lại: xem [KB_03 §5.8](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md) |

### [B754]-[B790]
**Tên:** Customer Labels (PAC, Digi-Key, Phoenix Contact, Sanmina)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | In tem PAC/DigiKey/Phoenix trống | Label spec chưa config hoặc LabelType sai | Kiểm tra `STB_ModelLabelInfo` + `STB_PackingLabelSpec` |
| 2 | Tem Phoenix Contact sai mã khách hàng | Config customer mapping thiếu | Kiểm tra `STB_PackingLabelSpec` (⚠️ `STB_PhoenixContactLabelInfo` KHÔNG tồn tại trong DB — data lưu trong PackingLabelSpec hoặc hardcode SP) |
| 3 | **[B767]** Tìm kiếm lần 2 bị lặp dữ liệu trên lưới (6 dòng thay vì 3 dòng) | Thuộc tính `데이터 추가` (Append Data) của hàm tìm kiếm `usp_SanminaLabelPrint_get_Vietnam` đang set là `True`. Khi search lần 2, do số Serial (`BoxSerialNo`, `PrintSerialNo` tự tăng dựa trên `@MaxSerial`) thay đổi, hệ thống không tìm thấy dòng trùng lặp và tự động append tiếp vào cuối grid. | Mở NAIS screen designer B767 → Chọn `Search Function` `usp_SanminaLabelPrint_get_Vietnam` → Tại bảng Property bên phải, nhóm `Group` → Chuyển `데이터 추가` từ `True` sang `False`. Save layout và Approve. |

> 🔗 Chi tiết: [KB_04 §6.9.4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md)

### [B802]
**Tên:** Electrode Production History

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Thiếu công đoạn trên báo cáo | OP chưa nhập đủ 4 công đoạn (Mixing/Coating/Rollpress/Slitting) tại B552 | Yêu cầu OP bổ sung nhập liệu tại B552 |
| 2 | 🔴 BY/YP 120/180 A301 1.5B: Mixing Input = 0, có Coating Output | App cân NVL Mixing trên máy CMC không gọi SP `usp_DoCreateElectrodeMixStepInfo_electron`. DB + SP + config `STB_ElectrodeStep` đều OK. Ảnh hưởng: `CREBL85L`, `CRFYL85-01`, `CRFYN85L-01`. Phát hiện 2026-06-19. | Kiểm tra phần mềm cân trên máy CMC (log, phiên bản, kết nối DB). Xem [KB_05 §8.9](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md) |
| 3 | Số mét sản lượng Slitting (`V-11`) mã YP (`CREYO85-04`) hiển thị lệch vọt lên 698.60m/697.20m thay vì 499.00m/498.00m | SP `usp_Vietnam_ElectrodeProdRouteHist_get` bị hardcode `SUM(ProductionQty)/5` cho mã `CREYO85-04` trong khi quy cách cắt YP tạo 7 cuộn tem (Seq 1..7) | ALTER SP `usp_Vietnam_ElectrodeProdRouteHist_get` thay `SUM(ProductionQty)/5` bằng `AVG(ProductionQty)` và `AVG(GoodQtyLength)` để tính động theo số cuộn cắt thực tế. |

### [W788]
**Tên:** GetDataSortingProgram (Tra cứu kết quả đo Sorting V2)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Màn hình W788 bị dư nhiều cột thừa hoặc cột trắng khi tra cứu | SP `sp_GetSortingDataProgram` gộp dữ liệu cũ (Ver 1) và trả ra các cột alias dư thừa (ESR_mOhm, OCV_mV...), khiến lưới WinForms tự động sinh thêm cột | 1. Chuyển SP `sp_GetSortingDataProgram` sang đọc thuần bảng V2 `SortingDataImportExcel_V2` (bỏ UNION ALL với V1). <br> 2. Khớp 100% danh sách cột theo đúng thứ tự 3 công đoạn trong file Excel máy đo V2 (`CCCVChg`, `CCDchg`, `Rest`) và thông tin MES (`InputLineCode`, `EquipmentNumber`, `LotNo`). <br> 3. File backup SP gốc: `sp_GetSortingDataProgram_Backup_Original.sql`. |

---



### [B767]
**Tên:** In tem Sanmina (Sanmina Label Print)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Lưới tìm kiếm lần 2 bị lặp dữ liệu (6 dòng thay vì 3 dòng) | Thuộc tính `데이터 추가` (Append Data) của hàm tìm kiếm đang set `True` | Mở NAIS screen designer B767 → Chọn SearchFunction → Chuyển `데이터 추가` từ `True` sang `False` |
| 2 | S/N của tem Outer (tem đầu tiên) bị trống | SP `usp_SanminaLabelPrint_get_Vietnam` set PrintSerialNo trống cho Outer label | Sửa SP: gộp Inner1Serial và Inner2Serial thành danh sách phân cách bằng dấu phẩy cho BoxSerialNo và PrintSerialNo của Outer label |

### [B540]
**Tên:** Nhập thẻ công đoạn (Process Card Info)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Model Nordex ở B540/B530/K361 cần hoàn thành công đoạn ND08 | Chuẩn nghiệp vụ BG2 Module Line: `IsOutputRoute` giữ nguyên `NULL` (hoặc 0), không set bằng 1. Việc chốt hoàn thành công đoạn ND08 được thực hiện qua màn hình K361 (SP `usp_CompleteRouteFinalForBacGiang2`). | **CẤM sửa IsOutputRoute=1**. Giữ `IsOutputRoute = NULL` ➔ Chốt `CompleteRoute = 1` cho `ND08` bằng nút "Hoàn thành kết quả sản xuất" tại K361. |
| 2 | Lỗi PRIMARY KEY violation `PK_STB_ProdRouteHist` (Duplicate key `20260808000824`) khi chốt sản xuất trên UI | Chèn dòng ND08 bằng SQL `INSERT` trực tiếp làm lệch dải số tự động `ProdRouteHistNo` của ứng dụng MES. | **CẤM DÙNG SQL INSERT TRỰC TIẾP VÀO STB_ProdRouteHist**. Thực hiện `UPDATE STB_ProdRouteHist SET CompleteRoute = NULL WHERE RouteCode = 'ND07'` để công nhân bấm chốt lại ND07 ở B530 ➔ Ứng dụng MES sẽ tự động sinh ND08 an toàn 100%. |

### B767
**Ten:** In tem KH Sanmina India

| # | Trieu chung | Nguyen nhan | Fix |
|---|---|---|---|
| 1 | So Serial tem Sanmina khong reset ve 00001 khi Ma ngay (Tuan san xuat) doi sang tuan moi | SP usp_SanminaLabelPrint_get_Vietnam lay serial lon nhat toan bang voi LIKE 'VINA%' khong filter theo @SerialPrefix | `WHERE LEN(BoxSerialNo) = 13 AND BoxSerialNo LIKE @SerialPrefix + '%'` |
## C-Series: QC & Chất Lượng

### [C121]-[C122]
**Tên:** QC Inspection Setup

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Lot NVL không có hạng mục kiểm tra | Chưa gán NVL vào nhóm kiểm tra tại C122 | Vào C121 thêm nhóm → C122 map NVL → nhóm |

> 🔗 Chi tiết: [KB_05 §9.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md)

### [C220]
**Tên:** IQC Incoming Quality Control

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | F330 bị chặn "Receiving Confirmation" | IQC chưa PASS Lot tại C220 | QC hoàn thành nhập kết quả + xác nhận PASS |
| 2 | Hàng mới nhập ở F330 không hiển thị trên C220 để IQC đánh giá (ví dụ: Module Case, Middle Plate) | Thủ kho mới bấm Arrival ở F330 nhưng **chưa bấm nút "Tạo tem"** (bảng `STB_MaterialDocLotInfo` chưa có dòng). SP `usp_MaterialQcInfo_get` INNER JOIN với `STB_MaterialDocLotInfo` nên lọc bỏ các phiếu chưa sinh Lot. | Mở lại F330 → chọn phiếu nhập → nhập thông tin đóng gói / Lot Vendor → bấm **"Tạo tem"** → F5 lại C220. (2026-07-21) |

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

> 🔗 Chi tiết: [KB_05 §9.5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md)

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

> 🔗 Chi tiết: [KB_05_02_SCREEN_BUGS_QC.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md#L752) (§ Kịch bản B: Hủy kết quả QC)

### [C451]
**Tên:** PQC Inspection

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Load lại hạng mục cũ, không cho sửa | Cache QC document từ lần trước | Xóa CommInspDoc cũ rồi tạo lại — xem C443 |

### [C486]
**Tên:** QC Measuring Items (Đo kích thước điện cực)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Cột Note1 thừa trên Grid / cột bị xáo | Lỗi metadata grid trong SmartFramework | Rebuild bảng + ALTER bảng tương ứng — xem [KB_05_02 §7.8](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md) |

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
| 1 | OCV chỉ hiện 20 dòng thay vì 50 | SP `usp_Vietnam_MaterialFOQcDetail_get` thiếu block WHILE cho DetailNo=2 (OCV) | Thêm block WHILE cho OCV — xem [KB_05_02 §9.6](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md) |

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
| 1 | CustomerPartNo trống khi in tem | `STB_CustomerPartNoInfo` thiếu mapping model→customer | INSERT mapping: xem [KB_07 §5.4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md) |
| 2 | Máy in không chạy hoặc tem trống | Cấu hình printer hoặc label template lỗi | Kiểm tra kết nối printer + template trong Z530 |
| 3 | D110 thiếu/trùng bản ghi | Insert duplicate hoặc filter sai | Kiểm tra SP `usp_VNE_BoxLabelPrintHist_*` |

> 🔗 Chi tiết: [KB_07 §5](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md)

---

## F-Series: Kho & Vật Tư

### [F330]
**Tên:** Material Receipt (Phiếu nhập kho NVL)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Bị chặn "Receiving Confirmation" | IQC chưa PASS tại C220 | QC hoàn thành IQC PASS trước |
| 2 | NVL không tìm thấy trong popup chọn | Chưa khai báo NVL tại A230 | Vào A230 thêm MaterialCode |
| 3 | Đổi mã vật tư tự động lỗi | `STB_ChangeMaterialCode_HN` thiếu mapping | INSERT mapping mã cũ→mới — xem [KB_02 §3.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md) |
| 4 | Quét/nhập mã Lot Vendor họ vỏ nhôm AOXING `GBAXAC-%` hoặc họ `GBNKSP-%` không tự động đọc được ngày sản xuất (trả về rỗng / 1900-01-01) ở F330/F620 | Hàm `fn_VVT_getdatebyVendorLot_MergeCode` và `fn_VVT_getdatebyVendorLot` bị hardcode mã đơn lẻ thay vì wildcard `LIKE 'GBAXAC-%'` (18 số) và `LIKE 'GBNKSP-%'` (Tháng mã hóa ký tự) | Cập nhật hàm `fn_VVT_getdatebyVendorLot_MergeCode` & `fn_VVT_getdatebyVendorLot` bổ sung wildcard parse tự động — xem chi tiết [KB_02_01 §4.11 Mẫu 5, Mẫu 6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#3-các-mẫu-viết-logic-parse-ngày-thông-dụng) |

> 🔗 Chi tiết: [KB_02 §4.15](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md)

### [F430]
**Tên:** Material Transfer (Chuyển kho / Lịch sử đầu vào - đầu ra NVL)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Lot không chuyển kho được | Lot bị HOLD hoặc QC Reject | Giải phóng HOLD hoặc xử lý theo quy trình NG |
| 2 | Khi xuất chuyển kho sang nhà máy Hưng Yên (`VVT_F5`), ô **Mã kho hàng (Tới)** không có kho Hưng Yên và ô **Mã chuyền** bị trống (hoặc dùng UNION ALL bị đúp khóa chính `Duplicate primary key`) | 1. Popup `TargetMaterialWarehouse_Search` gọi SP `usp_TargetMaterialWarehouse_popup` chỉ lọc kho thuộc `WorkCenterCode` hiện tại. 2. Popup `LineInfo_InoutMaterial` gọi SP `usp_LineInfo_popup_InoutMaterial` lọc `WHERE MaterialWarehouseCode = @SourceMaterialWarehouse`, mã chuyền `HY_BN`/`HY_BG` bị `NULL` | 1. Sửa `usp_TargetMaterialWarehouse_popup` dùng `UNION` (không dùng `UNION ALL` để tránh đúp khóa chính kho). 2. Thêm `HY_BN` (VVT_F1) & `HY_BG` (VVT_F2) vào `STB_LineInfo` set `MaterialWarehouseCode = 'ROH_HY_WH'`. 3. Sửa `usp_LineInfo_popup_InoutMaterial` thêm `OR (LI.LineCode IN ('HY_BN', 'HY_BG') AND @SourceMaterialWarehouse LIKE '%HY%')`. (vanduc & Mrs.VanOc & Hải Triều 2026-07-30) |
| 3 | Ô `ProcessedLotID3` bị rỗng trên lưới màn hình F430 | `STB_MaterialWarehouseInOutHist.ProcessedLotID` bị NULL khi xuất NVL thô ra chuyền. Cột `ProcessedLotID3` trên F430 chính là `LotID` ở màn F721 (`STB_MaterialLotInfo.LotID`) | Sửa SP `usp_MaterialWarehouseInOutHist_get` dùng fallback `ISNULL(NULLIF(MWIOH.ProcessedLotID, ''), MWIOH.LotID) AS ProcessedLotID3` + Chạy SQL UPDATE bù cho các bản ghi đã tạo. |


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
| 5 | Tạo tem NG bị quá số lượng (ví dụ: cần tạo 1.13m nhưng sinh tem 25.7m khiến Slg còn lại bị âm) | SP `usp_CreateLotSlitting_NG_HN_uid` tính số lượng NG bằng `InitialQty` (dài cuộn thô ban đầu) trừ tổng tem chia, thay vì dùng `ActualExportQuantity` từ `STB_MaterialWarehouseInOutHist` (SL thực tế xuất sang kho Slitting) | ALTER SP `usp_CreateLotSlitting_NG_HN_uid` đọc `ActualExportQuantity` từ `STB_MaterialWarehouseInOutHist` trước khi tính `@TemCurrentQtyNG`. |
| 6 | Cuộn nguyên liệu (Lot cha) không hiển thị trên danh sách "Chờ cắt" màn hình [F742] | Lot mẹ có cờ `IsSlitting = 1` (true) và số lượng `CurrentQty = 0.00` do giao dịch chia cuộn trước đó. SP `usp_ListInputNeedSlitting_HN` lọc: `IsSlitting = 0` hoặc `NULL`, `IsParrent = '1'`. | Chạy SQL Update reset `IsSlitting = 0` và gán lại `CurrentQty = số_mét_cần_cắt` (lấy từ cột `ActualExportQuantity` của giao dịch chuyển kho gần nhất). Xem chi tiết tại [KB_02_02 §Lỗi 6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_02_SCREEN_BUGS.md#f742--lỗi-6-cuộn-nguyên-liệu-lot-cha-không-hiển-thị-trên-danh-sách-chờ-cắt-màn-hình-f742). |



> 🔗 Chi tiết: [KB_05 §10](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md), [KB_02 §Lỗi 4](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_02_SCREEN_BUGS.md#lỗi-4-không-tìm-thấy-mã-foil-mới-trong-popup-để-thiết-lập-chiều-rộng-cắt-ở-f744)


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
| 1 | Gộp box lỗi Qty=0 | `STB_PackingStandard` thiếu record cho model HN | INSERT record — xem [KB_04 §6.13](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_01_CORE_PACKAGING.md) |
| 2 | Gộp túi nilon lỗi | `STB_PackingNilonToBoxSmall_HN` config sai | Kiểm tra + update config |
| 3 | Hủy box packing lẻ / Dòng Qty bị trống PackingID trên lưới HN523 | Đóng gói box lẻ cần rã để đóng lại hoặc `STB_MaterialDocLotInfo` có PackingID nhưng `STB_MaterialLotInfo` chưa được cập nhật (`PackingID = ''`) | 1. Tạo 7 bảng BACKUP snapshot (`STB_MaterialLotInfo_BK`, `STB_MaterialDocInfo_BK`, `STB_MaterialDocDetail_BK`, `STB_MaterialDocLotInfo_BK`, `STB_ProdRouteHist_BK`, `STB_ProdRouteSummary_BK`, `STB_ProductionOrderInfo_BK`) <br> 2. `DELETE FROM STB_MaterialLotInfo WHERE MaterialLotNo IN (...) AND PackingID IN (...)` <br> 3. Hủy chứng từ: `UPDATE STB_MaterialDocInfo SET DocStatus='CREATE'` ➔ `SET CONTEXT_INFO 0x999997` ➔ `DELETE FROM STB_MaterialDocLotInfo` ➔ `SET CONTEXT_INFO 0` ➔ `DELETE FROM STB_MaterialDocDetail` ➔ `UPDATE STB_MaterialDocInfo SET IsCancel=1` <br> 4. Giảm trừ sản lượng: `UPDATE STB_ProdRouteHist SET ProdQty=ProdQty-SL WHERE RouteCode='VE10'`, `UPDATE STB_ProdRouteSummary SET OutputQty=OutputQty-SL`, `UPDATE STB_ProductionOrderInfo SET ProdFinishQty=ProdFinishQty-SL` — Xem chi tiết script [KB_04_02 § [HN523]](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04/KB_04_02_SCREEN_BUGS.md#hn523--kịch-bản-sự-cố-khẩn-cấp-hủy-tem-đóng-gói--rã-box-tại-hà-nam-đồng-bộ-giảm-sản-lượng-ve10--po) |

### [HN555]
**Tên:** Gộp Packing Hàng Lẻ (Hà Nam)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Hủy gộp packing cuộn to mã `PKTTxxxxxxx` | SP `usp_MergePackingHN710_HN` gộp các box lẻ vào `STB_PackingHN710_HN` và cập nhật `STB_MaterialLotInfo.MergePackingId` | 1. `DELETE FROM STB_PackingHN710_HN WHERE PackingId = 'PKTTxxxxxxx'` <br> 2. `UPDATE STB_MaterialLotInfo SET MergePackingId = NULL, CurrentQtyBefMerge = NULL WHERE MergePackingId = 'PKTTxxxxxxx'` <br> 3. `UPDATE STB_DividePackaging SET MergeNilonToSmallBox = NULL WHERE MergeNilonToSmallBox = 'PKTTxxxxxxx'` |

### [HN544]
**Tên:** Gộp túi bóng thành hộp nhỏ (Hà Nam)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Hủy gộp box / Rã box túi bóng ở màn hình HN544 | Gộp nhầm box hoặc nút Hủy trên UI bị chặn/lỗi | 1. Thao tác UI: Nhập PackingID → Chọn dòng → Bấm nút Hủy trên toolbar. <br> 2. SQL Fix: `UPDATE STB_MaterialLotInfo SET PackingID = NULL WHERE PackingID = 'MÃ_PACKING'` + `DELETE FROM STB_DividePackaging WHERE PackingID = 'MÃ_PACKING'` |
| 2 | Lỗi Unique constraint khi tìm kiếm PackingID | SP `usp_GetMaterialLotInfo_Packing_VVT_F3` UNION thứ 3 JOIN thiếu điều kiện | ALTER SP thêm `AND ISNULL(DP.PackingParentID, '') <> ''` — xem [KB_02 §2.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#21-lỗi-unique-constraint-khi-gộp-túi-bóng-hn544--pkqn2100175) |

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

> 🔗 Chi tiết: [KB_05_02_SCREEN_BUGS_QC.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_05/KB_05_02_SCREEN_BUGS_QC.md#L820) (§ Kịch bản sự cố khẩn cấp 3: Lỗi nhập phế HNC321)

### [HN551]
**Tên:** FG Export (Xuất kho Thành Phẩm Hà Nam & Bắc Giang)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Xuất kho TP không hiện data | SP filter WorkCenterCode không match HN | ALTER SP thêm WorkCenterCode HN |
| 2 | Yêu cầu điều chỉnh / lùi ngày xuất kho thành phẩm (DateExport / CreateDate) về tháng trước (VD: Tháng 03/2026) | Ngày xuất kho thực tế bị quét lệch tháng so với kế toán/đối soát | Sửa cả 2 cột `CreateDate` & `DateExport` trên `STB_VN_FINISHGOODS_BG` (Bắc Giang) hoặc `STB_VN_FINISHGOODS_HN_Export` + `FinishGoodMESInstock_HN` (Hà Nam) bằng script bọc `BEGIN TRAN...COMMIT TRAN`. Chi tiết: [KB_02_01_WMS_CORE.md §8](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md#8-fg02--kho-th%C3%A0nh-ph%E1%BA%A9m-b%E1%BA%AFc-giang-fg00) |

### [HYFG01]
**Tên:** Finished Goods WH HY (Kho & Xuất kho Thành Phẩm Hưng Yên)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Thùng hàng đóng gói xong không hiển thị trên kho HYFG01 | Thùng hàng chưa được lưu cờ PackingQty hoặc bảng `STB_VN_FINISHGOODS_HY` bị thiếu bản ghi nhập kho | Chèn bổ sung bản ghi vào `STB_VN_FINISHGOODS_HY` — xem [KB_07_03 §1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md#hyfg01--finished-goods-wh-hy-kho-thành-phẩm-hưng-yên) |
| 2 | Báo xuất kho OK nhưng trên hệ thống không thấy dữ liệu xuất / Không check được Lot đã xuất do thiếu cột `ProcessedLotID3` | Giao diện `HYFG01` chưa cấu hình hiển thị cột `ProcessedLotID3` và chưa setup link nguồn từ phiếu xuất tương tự màn hình F430 | 1. Cấu hình hiển thị cột `ProcessedLotID3` trên lưới HYFG01 và setup link nguồn giống như F430 ở Bắc Ninh. 2. Cung cấp list `ProcessedLotID3` để update lại DB. 3. Thêm cấu hình kho Hưng Yên để nhập và có `ProcessedLotID3`. |
| 3 | Xuất kho bị tình trạng "hệ thống có bao nhiêu lại xuất hết từng đó" (Full Batch Export) | Cơ chế mặc định của phiếu xuất quét toàn bộ tồn kho của Lot/Box thay vì chia tách số lượng nhỏ | Lưu ý chia tách Lot hoặc lập phiếu xuất theo số lượng mong muốn trước khi thực hiện xuất kho. |
| 4 | Không kiểm tra được hàng xuất điều chuyển từ BN sang HY trên NAIS | Khi xuất điều chuyển từ BN sang HY, chưa chọn đúng mã kho đích | Chọn đúng mã kho hàng tới là `ROH-HY-WH` (Kho NVL Hưng Yên) khi làm thủ tục xuất chuyển từ Bắc Ninh. |

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

---

### [K361]
**Tên:** Hoàn thành công đoạn cuối BG2 (Complete Final Route BG2)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Công đoạn cuối (VD ND08) hiển thị "Chưa hoàn thành" trên K361 dù công đoạn trước đã pass | K361 gọi `usp_Vietnam_GetProdPackingForBarcodeForBacGiang2` để đọc các công đoạn `IN ('VP07','VP18','VP12','ND08','ND05')`. Khi `CompleteRoute` IS NULL thì hiển thị "Chưa hoàn thành". | Tích chọn dòng `ND08` trên K361 ➔ Bấm nút **"Hoàn thành kết quả sản xuất"** (gọi `usp_CompleteRouteFinalForBacGiang2` để `UPDATE CompleteRoute=1` và đổi `WorkerCode` thành mã người chốt thực tế) |
| 2 | Công đoạn ND08 chưa chốt nhưng hiển thị tên công nhân vừa làm ND07 | Khi chốt PASS ND07, B530 tự động clone dòng chờ ND08 và tạm copy WorkerCode từ công đoạn ND07 sang. | Không cần sửa SQL: Tên chỉ là hiển thị tạm thời. Khi người làm thực tế chốt K361, `WorkerCode` sẽ tự động cập nhật lại thành tên người chốt thực tế. |

### [K366]
**Tên:** Lot Tracking BG2 (Kết luận Pass/Fail)

| # | Triệu chứng | Nguyên nhân | Fix |
|---|---|---|---|
| 1 | Cột Status (Kết luận cuối cùng Pass/Fail) hiển thị trống | SP `usp_LotTrackingInfo_VVTF4_get` không trả về cột Status | Sửa SP: thêm logic `CASE WHEN df.ControlNo IS NULL THEN 'PASS' WHEN rp.Barcode IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS Status` |

---
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

> 🔗 Chi tiết: [KB_06 §9.3](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md)

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
| Lot chưa hoàn thành V-22 nhưng vẫn vào lò sấy được | SP không check `IsRouteFinish` trước khi cho vào lò | Thêm validation check — xem [KB_07 §5.1](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md) |

### Doping JIG Auto-End Mất Lịch Sử
| Triệu chứng | Nguyên nhân | Fix |
|---|---|---|
| JIG chạy 6h auto-end → lịch sử biến mất | SP `autoend` không INSERT vào `Stb_VVT_DopingJIG_History` | ALTER SP thêm INSERT — xem [KB_07 §5.2](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md) |

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






