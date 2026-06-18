## 4. 🛠️ CÁC CÂU LỆNH SQL UTILITIES CỨU HỘ NHANH

### A. Kiểm tra nhanh lịch sử di chuyển Lot (Routing Trace)
Khi Lot không hiển thị ở công đoạn hiện tại, kiểm tra xem nó đã qua công đoạn trước chưa:
```sql
SELECT Barcode, ProcSeq, ProcessCode, MachineCode, InQty, OutQty, JobDate, CreateUserID, CreateDateTime
FROM STB_ProdRouteHist
WHERE Barcode = 'Mã_Barcode_Cần_Tra'
ORDER BY ProcSeq ASC;
```

### B. Kiểm tra Lot Nguyên vật liệu đầu vào (WMS Trace)
Khi kho NVL báo không gộp được hoặc hệ thống báo Lot nguyên vật li�### E. Kiểm tra bản ghi chuyển đổi tên Lot (B353 → B523)
Khi B353 đã chuyển đổi lot nhưng B523 vẫn in lot cũ, kiểm tra:
```sql
-- 1. Xem bản ghi chuyển đổi trong STB_ChangePartNoAndLotNo
SELECT * FROM STB_ChangePartNoAndLotNo WITH(NOLOCK) 
WHERE oldLotID = 'MÃ_LOT_CŨ' OR NewLotID = 'MÃ_LOT_MỚI'

-- 2. Xem cấu hình auto VJ (nguyên nhân thường gặp khi bị ghi đè)
SELECT PrintVJ, MaterialCode, PartNo FROM STB_Vietnam_PackingPrinting WITH(NOLOCK) 
WHERE MaterialCode = (SELECT MaterialCode FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'MÃ_BARCODE')

-- 3. Xem barcode gốc thực tế (VV hay VJ?)
SELECT Barcode, MaterialCode FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'MÃ_BARCODE'
```

> ⚠️ **Bug đã biết (2026-06-18):** SP `usp_Vietnam_GetBoxIDForLotNo_VVT` tra cứu `STB_ChangePartNoAndLotNo` bằng `@LotNo` (VV prefix) nhưng bảng lưu `oldLotID` với VJ prefix → lookup không match → bị auto VJ ghi đè. Xem chi tiết tại [KB_04 §6.18](KB_04_DONG_GOI_IN_TEM.md#618-bug-b353-chuyển-đổi-lot-nhưng-b523-vẫn-in-tem-theo-lot-cũ-stb_changepartnoandlotno-bị-bỏ-qua).

---

## 6. 🚦 TỔNG HỢP PATTERN VALIDATION GATES — Yêu Cầu Giả Định Khách Hàng & Cách Thực Hiện Trong SP

> **Mục đích:** Bảng tổng quan tất cả "cổng chặn" (Validation Gates) trong hệ thống MES, được trình bày dưới dạng **yêu cầu giả định của khách hàng** (hypothetical customer requirements) và **cách SP thực hiện** yêu cầu đó. Giúp kỹ sư hiểu nhanh pattern thiết kế chung khi cần thêm/sửa/bỏ một gate.

### 6.1 Bảng Master Reference — 12 Nhóm Validation Gates

| # | Màn Hình | SP Chính | Loại Chặn | Yêu Cầu Giả Định KH | Bảng DB Chính | KB Chi Tiết |
|---|----------|----------|-----------|---------------------|---------------|-------------|
| 1 | **B597** | `usp_Vietnam_RawMaterialInputHist_uid` | NVL đầu vào (7 gates) | Chặn NVL HOLD/hết hạn/sai loại/sai vỏ/sai electrolyte/sai độ dày/thiếu config | `STB_MaterialLotInfo`, `STB_BomDetail`, `STB_MaterialMaster`, `stb_slittinglocationconfig_vvt` | KB_05 §7 |
| 2 | **B530** | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | Chốt sản lượng (7 gates) | Chặn chưa scan NVL/chưa PQC/Lot đóng/20 phút/thiếu máy/PO sai route | `STB_ProdRouteHist`, `STB_RawMaterialInputHist`, `STB_DefectRepairInfo` | KB_03 §6.3 |
| 3 | **B523** | `usp_Vietnam_DoProcessProdPacking_VVT` | Đóng gói (3 gates) | Chặn chưa cân/chưa QC Pass/thiếu tiêu chuẩn đóng gói | `STB_PackingStandard`, `STB_SetInfo`, `STB_DividePackaging` | KB_03 §6.5 |
| 4 | **B452** | `usp_Set_VVT_Info_get` | Phân quyền đổi Line | Chặn user không có quyền đổi Line/PO | `STB_SetInfo` (hardcode whitelist trong SP) | KB_03 §6.7 |
| 5 | **B618** | `usp_GetInforLotReworkHaNamFactory_uid` | Phân quyền Rework | Chặn user không có quyền khai báo Rework | `STB_LotReworkInfo_HN` (hardcode whitelist) | KB_26 §6.2 |
| 6 | **HNC321** | `usp_Vietnam_ScrapInput_HN` | Nhập phế (1 gate) | Chặn nhập phế nếu chưa có lịch sử công đoạn trước | `STB_ProdRouteHist`, `STB_DefectRepairInfo` | KB_05 cẩm nang C321 |
| 7 | **QC Audit** | `usp_VN_WaitingCheckBeforeExport_forQCAudit_Pass` | Khóa trạng thái QC | Chặn đổi Reject→Pass (khóa cứng 1 chiều) | `STB_VN_FINISHGOODS_forQCAudit` | KB_26 §3 Bug 2 |
| 8 | **Returns** | `usp_DoValidateMaterialDocBarcodeForReturn` | Xác thực trả hàng | Chặn nhận hàng trả nếu chưa IQC Pass | `STB_MaterialQcInfo`, `STB_MaterialMaster` | KB_26 §6.3 Bug 2 |
| 9 | **Lò Sấy** | `usp_VN_DryOver` | Thời gian sấy | Chặn ra lò nếu chưa đủ Confighours theo MaterialCode | `STB_VN_DRYOVER` (hardcode thời gian trong SP) | KB_03 §6.23 |
| 10 | **Slitting Knife** | `usp_DoCreateSlittingResult` | Tuổi thọ dao | Chặn cắt nếu dao vượt StandardQty (20k/40k/60k/70k m) | `STB_VN_SlittingKnifeInfo`, `STB_VN_SlittingKnifeInUse` | KB_03 §6.23 |
| 11 | **F330/C220** | `usp_Vietnam_MaterialGrFromOrder_get` | IQC nhập kho | Chặn nhận hàng nếu IQC chưa Pass | `STB_MaterialQcInfo`, `STB_CommInspDocHistory` | KB_02 §4.15 |
| 12 | **Electrode** | `usp_GetElectroMixPresentStep_vietnam` | Thứ tự bước cân | Chặn nếu bước cân nhảy sai thứ tự (logic ca đêm/ngày) | `STB_ElectrodeMixStepInfo`, `STB_ElectrodeStep` | KB_05 §8.6 |

---

### 6.2 Pattern Thiết Kế Chung — 4 Loại Cổng Chặn Trong MES

Dựa trên phân tích 12 nhóm trên, hệ thống MES sử dụng **4 pattern thiết kế** cổng chặn chính:

#### Pattern A: Kiểm Tra Trạng Thái Dữ Liệu (Data State Check)
```
IF (trạng thái dữ liệu KHÔNG đạt điều kiện)
    RAISERROR('Thông báo lỗi', 16, 1)
    RETURN
```
**Áp dụng tại:** B597 (HOLD/Hết hạn/Sai loại), B530 (Gate 1-3: chưa scan NVL/chưa PQC), HNC321 (chưa có routing trước), F330/C220 (IQC chưa Pass), Slitting Knife (vượt tuổi thọ)

**Cách mở rộng:** Thêm/sửa điều kiện `IF` trong SP. Thường cần SELECT từ bảng Master/Transaction để check.

#### Pattern B: Kiểm Tra Phân Quyền Hardcode (User Whitelist)
```
IF (@pProcessUserID NOT IN ('user1', 'user2', ...))
    RAISERROR('Không có quyền', 16, 1)
    RETURN
```
**Áp dụng tại:** B452 (đổi Line), B618 (Rework), B523 (cân - tài khoản worker)

**Cách mở rộng:** Thêm UserID vào danh sách hardcode hoặc (tốt hơn) chuyển sang kiểm tra phân quyền động qua `SmartFramework.dbo.STB_UserPermission`.

#### Pattern C: Khóa Trạng Thái Một Chiều (One-Way State Lock)
```
IF (@currentStatus = 'Reject')  -- Không cho đổi ngược
    RAISERROR('Đã reject, không đổi được')
```
**Áp dụng tại:** QC Audit (Reject → Pass bị khóa), Returns (IQC bắt buộc cho mọi loại hàng kể cả FG)

**Cách mở rộng:** Mở rộng điều kiện `ELSE IF` để cho phép đổi ngược khi cần.

#### Pattern D: Kiểm Tra Cấu Hình Hardcode (Configuration Hardcode)
```
SET @Confighours = CASE WHEN @MaterialCode IN ('mã1','mã2',...) THEN 3
                        WHEN @MaterialCode IN ('mã3',...) THEN 12
                        ELSE 9 END
```
**Áp dụng tại:** Lò Sấy (thời gian sấy theo model), B597 (mapping Vỏ Nhôm/Electrolyte hardcode), Electrode Mixing (thứ tự cân ca đêm)

**Cách mở rộng:** Thêm mã mới vào CASE/IN list trong SP, hoặc (tốt hơn) tạo bảng cấu hình riêng để tránh sửa SP.

---

### 6.3 Chi Tiết 12 Nhóm — Kịch Bản Yêu Cầu Giả Định & Cách Thực Hiện

#### Nhóm 1: B597 — Chặn NVL Đầu Vào (SP `usp_Vietnam_RawMaterialInputHist_uid`)

> **Pattern:** A (Data State Check) + D (Configuration Hardcode)

| # | Yêu Cầu Giả Định KH | Logic Trong SP | SQL Debug | Cách Mở Rộng |
|---|---------------------|----------------|-----------|-------------|
| 1.1 | "NVL bị QC hold không được đưa vào chuyền" | Check `MaterialWarehouseCode LIKE 'HOLDING_%'` trong `STB_MaterialLotInfo` | `SELECT MaterialWarehouseCode FROM STB_MaterialLotInfo WHERE LotID = 'ML...'` | Chuyển kho về `ROH_*_WH` khi QC Pass |
| 1.2 | "NVL hết hạn sử dụng không được dùng" | Check `LotAttr10 + (MMExtInt01 × 30 ngày) < GETDATE()`. Lấy `LotAttr10` từ `STB_MaterialDocLotInfo`, nếu rỗng (Lot tách `%SP%/%SL%/%SM%`) thì fallback sang `STB_MaterialLotInfo` | `SELECT LotAttr10 FROM STB_MaterialDocLotInfo WHERE LotID = 'ML...'` (nếu rỗng check `STB_MaterialLotInfo`) | Gia hạn: UPDATE `LotAttr10` hoặc thêm vào `stb_vvt_OpenExpiredMaterial` |
| 1.3 | "NVL phải khớp BOM của PO đang SX" | Check `@pProductGroupCode` match với BOM qua IF/ELSE | `SELECT BD.MaterialCode FROM STB_BomDetail BD JOIN STB_BomHeader BH ON BD.BomHeaderNo = BH.BomHeaderNo WHERE BH.MaterialCode = 'Mã_Model'` | Thêm mã NVL thay thế vào BOM tại A310 |
| 1.4 | "Vỏ nhôm phải đúng chủng loại cho model" | Hardcode danh sách mã vỏ nhôm trong IF/NOT IN (⚠️ KHÔNG có bảng config) | `SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))` → Ctrl+F 'Vỏ Nhôm' | Thêm mã vỏ mới vào NOT IN list trong SP |
| 1.5 | "Electrolyte phải khớp BOM model" | CTE `eleclyte1` hardcode mapping Electrolyte ↔ Model ↔ Size | Đọc SP → tìm CTE `eleclyte1` | Thêm UNION ALL vào CTE với mã mới |
| 1.6 | "Điện cực phải đúng độ dày (Thickness)" | Check `MaterialThickness` trong `STB_MaterialMaster` | `SELECT MaterialCode, MaterialThickness FROM STB_MaterialMaster WHERE MaterialCode = 'Mã_Điện_Cực'` | UPDATE `MaterialThickness` sang số nguyên (tránh .000000) |
| 1.7 | "Điện cực Slitting phải có cấu hình trong bảng config" | Check tồn tại trong `stb_slittinglocationconfig_vvt` theo PartNo | `SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'` | INSERT cấu hình mới (BY + YP cho cả 2 cực) |

**📌 Chi tiết:** Xem [KB_05 §7](KB_05_QC_ELECTRODE.md#7-kiểm-tra-chất-lượng-qc) và [KB_05 §8.3](KB_05_QC_ELECTRODE.md#83-checklist-khi-b597-báo-lỗi-khi-lưu-nvl)

---

#### Nhóm 2: B530 — Chặn Chốt Sản Lượng (SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`)

> **Pattern:** A (Data State Check)

| # | Yêu Cầu Giả Định KH | Logic Trong SP (Gate) | SQL Debug | Cách Mở Rộng |
|---|---------------------|----------------------|-----------|-------------|
| 2.1 | "Phải scan điện cực trước khi chốt V-22" | GATE 1: `usp_CheckInputElectrodeInputForCodeProduct` — check `tbl_SlittingStock` | `SELECT * FROM Stb_SlittingStock_VVT WHERE Barcode = 'VV...'` | Thêm logic check cho model mới |
| 2.2 | "Phải scan NVL V-23/V-24 trước khi chốt" | GATE 2: `usp_CheckInputRawMaterialCodeForProduct` — check `STB_RawMaterialInputHist` | `SELECT * FROM STB_RawMaterialInputHist WHERE Barcode = 'VV...' AND RouteCode IN ('V-23','V-24')` | Bypass: SET `IsRawMaterialInputFinish = 1` |
| 2.3 | "PQC phải nhập lỗi trước khi chốt (HN)" | GATE 3: `usp_CheckPQCInputForProductHistForBarcode` — check `STB_DefectRepairInfo` | `SELECT * FROM STB_DefectRepairInfo WHERE ControlNo = '...' AND FindRouteCode = 'VE...'` | ⚠️ Bug: Gate yêu cầu CÓ lỗi, không chấp nhận lô đạt 100% |
| 2.4 | "Lot đã chốt kế hoạch không cho sửa" | GATE 4: `DPPExtText01 = '1'` → RAISERROR 'Đã chốt' | `SELECT DPPExtText01 FROM STB_DayProdPlan WHERE DayPlanNo = '...'` | UPDATE `DPPExtText01 = NULL` để mở lại |
| 2.5 | "Chặn chốt liên tục dưới 20 phút" | GATE 5: `DATEDIFF(minute) <= 20` (**⚠️ BUG: = Null thay IS NULL → không hoạt động**) | N/A (gate bị vô hiệu) | Fix: đổi `= Null` thành `IS NULL` |
| 2.6 | "Bắt buộc chọn mã máy khi chốt" | GATE 6: `IsRequireMachine=1 AND MachineCode=''` | `SELECT IsRequireMachine FROM STB_ProductionOrderRouting WHERE PONo = '...' AND RouteCode = '...'` | Set `IsRequireMachine = 0` nếu line thủ công |
| 2.7 | "Routing phải có trong PO" | GATE 7: `PONo IS NULL` → RAISERROR 'Routing không có trong PO' | `SELECT RouteCode FROM STB_ProductionOrderRouting WHERE PONo = '...'` | Thêm RouteCode vào PO tại B310 |

**📌 Chi tiết:** Xem [KB_03 §6.3](KB_03_SAN_XUAT.md#63-b530--nhập-số-lượng-sản-xuất-chi-tiết-sp)

---

#### Nhóm 3: B523 — Chặn Đóng Gói (SP `usp_Vietnam_DoProcessProdPacking_VVT`)

> **Pattern:** A + B (Data Check + User Whitelist)

| # | Yêu Cầu Giả Định KH | Logic Trong SP | SQL Debug |
|---|---------------------|----------------|-----------|
| 3.1 | "Phải cân hàng trước khi in label" | Check `@pProcessUserID NOT IN ('vvt_worker','vvtworker',...)` — chặn user ngoài line | Xem whitelist trong SP |
| 3.2 | "Phải có tiêu chuẩn đóng gói (PackingStandard)" | Check `STB_PackingStandard` theo Size/MaterialTypeCode | `SELECT * FROM STB_PackingStandard WHERE Size = '1840'` |
| 3.3 | "Chỉ in tem 1 lần, in lần 2 phải liên hệ EA" | Logic check trong SP + flag `PrintCount` | Liên hệ EA để reset |

**📌 Chi tiết:** Xem [KB_03 §6.5](KB_03_SAN_XUAT.md#65-b523--đóng-gói-gộp-box--quy-trình-mới) và [KB_04 §6](KB_04_DONG_GOI_IN_TEM.md)

---

#### Nhóm 4: B452 — Chặn Đổi Line (SP `usp_Set_VVT_Info_get`)

> **Pattern:** B (User Whitelist Hardcode)

| Yêu Cầu Giả Định KH | Logic Trong SP | Cách Mở Rộng |
|---------------------|----------------|-------------|
| "Chỉ quản lý SX được phép đổi Line/PO" | `IF @pProcessUserID NOT IN ('user1','user2',...) → RAISERROR` | Thêm UserID vào whitelist trong SP |

**📌 Chi tiết:** Xem [KB_03 §6.7](KB_03_SAN_XUAT.md#67-b452--đổi-line-sai-vietnam-print-lot-changed)

---

#### Nhóm 5: B618 — Chặn Rework (SP `usp_GetInforLotReworkHaNamFactory_uid`)

> **Pattern:** B (User Whitelist Hardcode) → Đã có Hotfix chuyển sang phân quyền động

| Yêu Cầu Giả Định KH | Logic Trong SP (Trước Fix) | Logic Sau Fix | 
|---------------------|---------------------------|--------------| 
| "Chỉ quản lý QC/SX được khai báo Rework" | Hardcode: `IF NOT IN ('HaiTrieu','hoangxuan','ngocanh','doanthao')` | Check `STB_UserPermission` WHERE `ScreenID='B618'` + Fallback whitelist cũ |

**📌 Chi tiết:** Xem [KB_26 §6.2](KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md#2-quy-trình-làm-lại-sản-phẩm-rework-flow)

---

#### Nhóm 6: HNC321 — Chặn Nhập Phế (SP `usp_Vietnam_ScrapInput_HN`)

> **Pattern:** A (Data State Check)

| Yêu Cầu Giả Định KH | Logic Trong SP | SQL Debug | Cách Mở Rộng |
|---------------------|----------------|-----------|-------------|
| "Phải có lịch sử công đoạn trước mới được nhập phế" | Check `STB_ProdRouteHist` cho RouteCode trước đó. Nếu không có → RAISERROR tiếng Hàn | `SELECT * FROM STB_ProdRouteHist WHERE ControlNo = '...' ORDER BY CreateDateTime` | Chèn dòng Routing giả lập cho công đoạn trước |

**📌 Chi tiết:** Xem [KB_05 cẩm nang C321](KB_05_QC_ELECTRODE.md#c321--hnc321--defect-repair--scrap-management)

---

#### Nhóm 7: QC Audit — Chặn Pass/Reject (SP `usp_VN_WaitingCheckBeforeExport_forQCAudit_Pass`)

> **Pattern:** C (One-Way State Lock)

| Yêu Cầu Giả Định KH | Logic Trong SP (Bug) | Đề Xuất Fix |
|---------------------|---------------------|-------------|
| "Không cho đổi ngược Pass→Reject nhưng CHO PHÉP đổi Reject→Pass" | `ELSE IF (@getStatusCheck IS NULL)` → chỉ cho update khi NULL, KHÔNG cho khi Reject | Đổi thành `ELSE IF (@getStatusCheck IS NULL OR @getStatusCheck = 'Reject')` |

**📌 Chi tiết:** Xem [KB_26 §3 Bug 2](KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md#bug-2-sự-bất-đối-xứng-khóa-cứng-trong-qc-audit-passreject)

---

#### Nhóm 8: Returns — Chặn Trả Hàng (SP `usp_DoValidateMaterialDocBarcodeForReturn`)

> **Pattern:** C (One-Way State Lock — áp dụng sai scope)

| Yêu Cầu Giả Định KH | Logic Trong SP (Bug) | Đề Xuất Fix |
|---------------------|---------------------|-------------|
| "Hàng trả lại từ khách phải qua IQC" | Bắt buộc IQC Pass cho MỌI loại hàng kể cả Thành phẩm (FERT) — sai vì FG không có IQC | Thêm check `MaterialTypeCode`: chỉ yêu cầu IQC cho NVL (`ROH`) |

**📌 Chi tiết:** Xem [KB_26 §6.3](KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md#3-phân-hệ-trả-hàng-returns--rma-flow)

---

#### Nhóm 9: Lò Sấy — Chặn Thời Gian (SP `usp_VN_DryOver`)

> **Pattern:** D (Configuration Hardcode)

| Yêu Cầu Giả Định KH | Logic Trong SP | SQL Debug | Cách Mở Rộng |
|---------------------|----------------|-----------|-------------|
| "Phải sấy đủ X giờ theo từng loại model mới được ra lò" | CASE WHEN `@MaterialCodes IN (...)` THEN 3/9/12/15/20/30 giờ | `SELECT * FROM STB_VN_DRYOVER WHERE Barcode = '...'` rồi so sánh `OvenInputDate + Confighours` với `GETDATE()` | Thêm MaterialCode mới vào CASE WHEN (hoặc tạo bảng config riêng) |

**📌 Chi tiết:** Xem [KB_03 §6.23](KB_03_SAN_XUAT.md#623-thiết-bị-phụ-trợ-mes-lò-sấy-gá-doping--dao-cắt-slitting)

---

#### Nhóm 10: Slitting Knife — Chặn Tuổi Thọ Dao (SP `usp_DoCreateSlittingResult`)

> **Pattern:** A (Data State Check)

| Yêu Cầu Giả Định KH | Logic Trong SP | SQL Debug | Cách Mở Rộng |
|---------------------|----------------|-----------|-------------|
| "Dao cắt phải được kiểm tra/thay thế khi đạt mốc 20k/40k/60k/70k mét" | Check `totalkm >= StandardQty` trong `STB_VN_SlittingKnifeInUse` | `SELECT KnifeID, totalkm, StandardQty FROM STB_VN_SlittingKnifeInUse WHERE MachineCode = '...'` | Thay dao mới → reset `totalkm = 0` |

**📌 Chi tiết:** Xem [KB_03 §6.23](KB_03_SAN_XUAT.md#623-thiết-bị-phụ-trợ-mes-lò-sấy-gá-doping--dao-cắt-slitting)

---

#### Nhóm 11: F330/C220 — Chặn Nhập Kho IQC (Validation liên phòng ban)

> **Pattern:** A (Data State Check — liên hệ thống)

| Yêu Cầu Giả Định KH | Logic Trong SP | SQL Debug | Cách Mở Rộng |
|---------------------|----------------|-----------|-------------|
| "NVL nhập kho phải qua IQC trước khi xác nhận" | Check `DecisionResult = 'P'` trong `STB_MaterialQcInfo` | `SELECT MaterialQcNo, DecisionResult FROM STB_MaterialQcInfo WHERE MaterialLotNo = 'ML...'` | QC hoàn thành nhập kết quả tại C220 → set PASS |

**📌 Chi tiết:** Xem [KB_02 §4.15](KB_02_KHO_WMS.md#415-luồng-nhập-kho-đầy-đủ-f330)

---

#### Nhóm 12: Electrode Mixing — Chặn Bước Cân (SP `usp_GetElectroMixPresentStep_vietnam`)

> **Pattern:** D (Configuration Hardcode — logic ca đêm/ngày)

| Yêu Cầu Giả Định KH | Logic Trong SP | SQL Debug | Cách Mở Rộng |
|---------------------|----------------|-----------|-------------|
| "Phải cân lần lượt theo thứ tự (Seq). Ca đêm cho phép đảo thứ tự Binder trước" | SP nhận `@pOrder = 'kdem'` để đảo thứ tự. Ca ngày quên bỏ tích checkbox → bị nhảy thứ tự | `EXEC usp_GetElectroMixPresentStep_vietnam 'VVQN...', ''` | Bỏ tích checkbox "CA ĐÊM CHUẨN BỊ TRƯỚC" → Bấm "Làm mới màn hình". Nếu kẹt: DELETE `STB_ElectrodeMixStepInfo` WHERE Lot bị kẹt |

**📌 Chi tiết:** Xem [KB_05 §8.6](KB_05_QC_ELECTRODE.md#86-quy-trình-cân-điện-cực-mixing--phần-mềm-cân-điện-cực-electrodeweighing)

---

### 6.4 Hướng Dẫn Khi Khách Hàng Yêu Cầu "Thêm Gate Chặn Mới"

Khi nhận yêu cầu bổ sung một cổng chặn mới (ví dụ: "Chặn nếu nhiệt độ phòng ngoài spec"), thực hiện theo checklist:

```
□ 1. XÁC ĐỊNH PATTERN: Yêu cầu thuộc Pattern nào? (A/B/C/D)
□ 2. XÁC ĐỊNH SP: Tìm SP nào đang xử lý tại màn hình đó
     → SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = '...'
□ 3. TÌM VỊ TRÍ: Đọc SP source → tìm các RAISERROR/IF block hiện có
     → SELECT OBJECT_DEFINITION(OBJECT_ID('usp_...'))
□ 4. THÊM LOGIC: Chèn IF block mới VÀO SAU gate cuối hiện tại
     (Giữ nguyên thứ tự gate cũ để tránh regression)
□ 5. TEST: Chạy SP với dữ liệu test → Verify RAISERROR khi sai
□ 6. DEPLOY: ALTER PROCEDURE trên Production
□ 7. GHI CHÉP: Cập nhật KB file tương ứng + KB_INDEX.md
```

---

*Cập nhật: 2026-06-18 | Thêm §5.E (B353→B523 bug trace) + Tổng hợp 12 nhóm Validation Gates từ toàn bộ SP hệ thống MES Vinatech bởi Antigravity AI.*
