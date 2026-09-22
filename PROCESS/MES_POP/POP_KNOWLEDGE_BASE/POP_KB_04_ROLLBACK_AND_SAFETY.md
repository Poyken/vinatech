<!--
AI-READY METADATA
Purpose: Phân tích chi tiết khả năng Rollback/Hoàn tác trên POP Web UI + DB Safety Assessment
Scope: Mọi thao tác WRITE trên POP Web và khả năng hoàn tác tương ứng
Single Source of Truth: POP_KB_04_ROLLBACK_AND_SAFETY.md
Target Tables: STB_PackingInfo, STB_SetInfo, VINA_MATERIAL_INPUT_HIST, STB_ProdRouteHist
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [POP_KB_02_SCREEN_OPERATIONS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md)
  - [KB_04_PACKING](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_04)
-->

# POP_KB_04 — Rollback & An Toàn Dữ Liệu (Rollback & Data Safety)

> **Phạm vi:** Phân tích toàn diện khả năng hoàn tác (rollback) cho MỌI thao tác ghi dữ liệu trên POP Web  
> **Xác minh:** Dựa trên Live UI Testing (2026-09-08) + API behavior analysis  
> **🔑 Keywords:** rollback, undo, cancel, hủy, hoàn tác, revert, safety, an toàn, xóa, delete  
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)

---

## 1. 📊 TỔNG QUAN — BẢNG ROLLBACK MATRIX

> [!IMPORTANT]
> Bảng dưới đây tóm tắt khả năng rollback cho **từng loại thao tác** trên POP Web UI.
> ✅ = Có thể rollback trên UI | ⚠️ = Rollback hạn chế | ❌ = Không thể rollback trên UI

| # | Thao tác | Rollback trên UI | Cách thức | Rủi ro |
|---|----------|-----------------|-----------|--------|
| 1 | **Đăng nhập / Chọn Line** | ✅ Hoàn toàn | Đổi Line, logout bất kỳ lúc nào | Không rủi ro |
| 2 | **Chọn Work Order / DayPlan** | ✅ Hoàn toàn | Bỏ chọn, chọn WO khác | Không rủi ro (read-only) |
| 3 | **Chọn LOT** | ✅ Hoàn toàn | Click LOT khác | Không rủi ro (read-only) |
| 4 | **Nhập sản lượng / Đăng ký lỗi** | ✅ **CÓ THỂ (Trước khi chốt)** | Chuyển sang **Chế độ `SUB` Mode** trên Numpad để trừ bớt số đã đăng ký sai | An toàn tuyệt đối trước khi bấm "Ghi nhận sản xuất" |
| 5 | **Nhập NVL (Material Input)** | ❌ **Không thể** | Không có nút "Undo" trực tiếp trên UI | **Trừ kho tức thì** — cần SQL fix hoàn kho |
| 6 | **Hoàn thành SX (Ghi Nhận SX)** | ❌ **Không thể trên Web** | Không có nút Cancel sau khi đã chốt routing | Routing đã chuyển bước, cần MES Desktop WinForm |
| 7 | **Đóng gói (Packing)** | ✅ **CÓ THỂ** | Nút **"Hủy Đóng Gói"** trong Lịch sử đóng gói | Khôi phục trạng thái Lot chuẩn xác 100% |
| 8 | **In nhãn (Label Print)** | ✅ Hoàn toàn | In lại bất kỳ lúc nào qua modal in chuẩn 83x49mm | Không ảnh hưởng số liệu DB |
| 9 | **Điều chuyển kho (WH Transfer)**| ✅ **CÓ THỂ** | Mở lại `#wtModalPanel`, đảo chiều Kho Nhập ⇄ Kho Xuất | Tự khắc phục được ngay trên Kiosk |
| 10 | **Tự kiểm (Self-Inspection)** | ⚠️ **Hạn chế** | Chỉnh sửa số liệu trên trang `/pop/quality/self` trước khi submit | Sau khi submit lưu kết quả vào DB |

---

## 2. 🔍 PHÂN TÍCH CHI TIẾT TỪNG THAO TÁC

### 2.1 ✅ Đăng Nhập & Chọn Line/WO — AN TOÀN HOÀN TOÀN

**Bản chất:** Đây là các thao tác **read-only**, chỉ đọc dữ liệu từ DB, không ghi gì.

- **Chọn Line:** GET `/api/common/getLineList` → Chỉ đọc `STB_LineInfo`
- **Chọn WO:** GET `/api/pop/screen/getDayPlanList` → Chỉ đọc `STB_DayProdPlan`
- **Chọn LOT:** GET `/api/pop/screen/getLotList` → Chỉ đọc `STB_SetInfo`

**Kết luận:** Thoải mái thay đổi, không ảnh hưởng gì đến DB.

---

### 2.2 ⚠️ Nhập NVL (Material Input) — KHÔNG CÓ ROLLBACK TRÊN UI

**Hành vi DB khi bấm "Nhập":**
```
1. SmartFactoryV2.STB_MaterialLotInfo  
   → UPDATE: Qty = Qty - InputQty  (TRỪ KHO TỨC THÌ)
   
2. VINATECH_POP.VINA_MATERIAL_INPUT_HIST  
   → INSERT: Bản ghi log nhập NVL
   
3. SmartFactoryV2.STB_SetInfo  
   → UPDATE: IsLineInput = 1
```

**Trên UI:** 
- ❌ **KHÔNG CÓ** nút "Hủy nhập NVL" hoặc "Undo Material Input"
- ❌ Không thể nhập số âm để hoàn trả kho
- Sau khi bấm "NHẬP", kho đã bị trừ → **Không thể hoàn tác từ POP Web**

**Cách rollback (chỉ qua SQL):**
```sql
-- ⚠️ CHỈ DÙNG KHI CẦN THIẾT - Cần BEGIN TRAN...ROLLBACK trước
-- Bước 1: Tìm record nhập sai (đối chiếu cột thực tế của VINATECH_POP)
SELECT SEQ_NO, DAY_PLAN_NO, LOT_NO, BARCODE, SUB_MATERIAL_CODE, SUB_MATERIAL_NAME, INPUT_QTY, WORKER_ID, INPUT_DATE_TIME, STATUS, CANCEL_SEQ_NO
FROM VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST WITH(NOLOCK)
WHERE LOT_NO = N'<LOT_NUMBER>' AND INPUT_DATE_TIME >= '<NGÀY>'
ORDER BY INPUT_DATE_TIME DESC;

-- Bước 2: Hoàn trả kho (cộng lại)
-- UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo 
-- SET Qty = Qty + <SốLượngĐãTrừ>
-- WHERE MaterialCode = N'<MÃ_NVL>' AND RouteCode = '<ROUTE>';

-- Bước 3: Đánh dấu hủy bản ghi nhập (Cập nhật CANCEL_SEQ_NO hoặc STATUS thay vì DELETE vật lý)
-- UPDATE VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST 
-- SET STATUS = 'CANCEL', CANCEL_SEQ_NO = @CancelSeq, MODIFY_DATE = GETDATE()
-- WHERE SEQ_NO = @TargetSeqNo;
```

> [!CAUTION]
> Nhập NVL là thao tác **KHÔNG THỂ HOÀN TÁC** trên POP UI. Công nhân cần cẩn thận kiểm tra 
> mã NVL và số lượng TRƯỚC KHI bấm "NHẬP". Sai sót cần IT can thiệp bằng SQL.

---

### 2.3 ⚠️ Đăng Ký Phế Phẩm (Defect Registration) — HẠN CHẾ

**Hành vi DB:**
```
STB_ProdRouteHist → UPDATE: DefectQty += InputDefect
                     INSERT: Chi tiết loại lỗi (DefectType, DefectQty)
```

**Trên UI:**
- ✅ Có thể **sửa số lượng defect** trước khi hoàn thành công đoạn
- ❌ Sau khi bấm "Save Production", defect đã ghi cứng → không xóa được trên UI
- ⚠️ Defect Type đã chọn có thể thay đổi trước Save nhưng không sau

**Cách rollback (SQL):**
```sql
-- Kiểm tra defect đã ghi
SELECT * FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE SetNo = N'<LOT>' AND RouteSeq = <SEQ>
ORDER BY CreateDate DESC;
```

---

### 2.4 ❌ Hoàn Thành SX (Save Production) — KHÔNG THỂ ROLLBACK

**Hành vi DB:**
```
1. STB_ProdRouteHist → INSERT: Bản ghi routing mới (GoodQty, DefectQty)
2. STB_SetInfo → UPDATE: CurrentRoute move sang công đoạn tiếp theo
3. Logic FIFO/Interlock có thể trigger cascade
```

**Trên UI:**
- ❌ **TUYỆT ĐỐI KHÔNG CÓ** nút Undo/Cancel sau Save Production
- Sau Save, LOT đã di chuyển sang công đoạn tiếp → Không quay lại được
- Đây là hành vi **by design** — production move là one-way

**Cách rollback (chỉ DBA/IT):**
```sql
-- ⛔ CỰC KỲ NGUY HIỂM — Chỉ DBA thực hiện
-- Cần: DELETE ProdRouteHist mới + UPDATE STB_SetInfo.CurrentRoute về route cũ
-- Phải check toàn bộ cascade: PackingInfo, MaterialLotInfo, etc.
-- KHÔNG BAO GIỜ LÀM MÀ KHÔNG CÓ BACKUP TRƯỚC
```

> [!WARNING]
> Save Production là thao tác **MỘT CHIỀU** (irreversible) trên cả POP Web và MES Desktop.
> Công nhân cần xác nhận đúng số lượng OK/NG trước khi Save.

---

### 2.5 ✅ Đóng Gói (Packing) — CƠ CHẾ HỦY HỘP & ROLLBACK ĐÓNG GÓI TRÊN POP WEB KIOSK
*(Xác minh thực tế 100% trên Live DB ngày 20/09/2026 với Lot `VVQQ253R072701` & `VVQR033R072774`)*

**Đây là chức năng rollback hoàn chỉnh và an toàn nhất trên POP Web UI, được bảo vệ bằng lớp xác thực Quản Trị Viên (Supervisor Mode).**

#### A. Giao Diện & Điều Kiện Kích Hoạt (UI Trigger):
1. **Cách 1 — Chạm trực tiếp vào Thẻ Lot đã đóng trong danh sách "Tiến độ LOT":**
   - Khi Lot đã có hộp (icon Thùng hàng màu cam/xanh kèm mã hộp, ví dụ: `ECVT30-357QR1800379`), công nhân chạm vào thẻ đó.
   - Hệ thống hiển thị Modal cảnh báo màu cam:
     ```
     [ ! ] Xác nhận quản trị viên
           Hủy hộp này?
           ECVT30-357QR1800379
           Nhập mã nhân viên quản trị
           [ ____________________ ]
           [ Có (Đỏ) ]  [ Không (Xám) ]
     ```
   - **Bảo mật:** Bắt buộc nhập mã nhân viên có thẩm quyền quản trị (ví dụ: `92603003`). Công nhân vận hành bình thường không thể tự ý bấm hủy nếu không có sự giám sát của quản lý.
2. **Cách 2 — Vào popup "Lịch sử" đóng gói:**
   - Chạm vào nút **"Lịch sử"** ở thanh dưới -> Bấm nút **`[HỦY]`** từng Box hoặc **`[HỦY TẤT CẢ]`**.

---

#### B. Thực Tế Dưới Hệ Thống & CSDL Sẽ Run Gì (End-to-End Execution Flow):

Khi người dùng nhập mã nhân viên quản lý và bấm **[Có]**, backend API của POP Web kích hoạt trực tiếp Stored Procedure duy nhất phụ trách hủy đóng gói:
```sql
EXEC SmartFactoryV2.dbo.usp_DoCancelProdPacking_LotNo
     @pProcessUserID   = '92603003',      -- Mã nhân viên quản trị vừa nhập
     @pProcessLanguage = 'VIETNAMESE',   -- Ngôn ngữ giao diện
     @pRouteCode       = 'V-28',          -- Công đoạn đóng gói (V-28 hoặc V-28_HY)
     @pBarcode         = 'VVQQ253R072701' -- Mã Lot gốc cần hủy hộp
```

**Chi tiết 6 bước xử lý tuần tự bên trong Stored Procedure:**

1. **Ghi nhận Audit Trail (Bắt buộc kiểm toán):**
   - Ghi nhật ký vào bảng `STB_ProdRouteHistCancelHist`:
     ```sql
     INSERT INTO STB_ProdRouteHistCancelHist (LotNo, CreateUserID, CreateDateTime)
     VALUES (@LotNo, @pProcessUserID, GETDATE())
     ```
   - *Kiểm chứng thực tế:* Ghi nhận bản ghi `Idx = 87327`, `LotNo = VVQQ253R072701`, `CreateUserID = 92603003` lúc 12:51:33 ngày 20/09/2026.

2. **Kiểm tra nghiệp vụ xuất nhập kho (Chặn hủy nếu đã nhập kho):**
   - Nếu Lot thuộc nhà máy Hà Nam (`VE%`, `SP%`, `RW%`), kiểm tra bảng `STB_VN_FINISHGOODS_HN_New`.
   - Nếu hàng đã nhập kho thành phẩm ➔ Báo lỗi chặn ngay:
     `'Lot này đã được nhập kho, không thể huỷ gộp box. Nếu muốn huỷ liên hệ Chị Xuân kho thành phẩm'` (HTTP 500 / Error Alert).

3. **Dọn dẹp lượt chốt công đoạn đóng gói (`STB_ProdRouteHist`):**
   - Đối với model Việt Nam (`V%`, `MV%`), xóa sạch các bản ghi chốt sản lượng tại các Route đóng gói (`V-28`, `V-28_HY`, `VE10`, `E-28`, `MV-05`) trong `STB_ProdRouteHist` nếu Lot chưa phân bổ bán thành phẩm:
     ```sql
     DELETE STB_ProdRouteHist 
     WHERE RouteCode IN ('V-28','V-28_BG','VE10','E-28','MV-05','V-28_HY')
       AND ControlNo IN (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
     ```
   - *Kiểm chứng thực tế:* 20 bản ghi chốt V-28 (51 pcs mỗi box) của Lot `VVQQ253R072701` được xóa sạch hoàn toàn (Count về 0).

4. **Thu hồi toàn bộ Box BTP trong `STB_MaterialLotInfo`:**
   - Xóa các bản ghi mang mã `PackingID` (`PK...`) tương ứng đã tạo ra trong lượt đóng gói đó.
   - *Kiểm chứng thực tế:* 20 bản ghi Box (`PKQR1800557` ~ `PKQR1800576`) trong `STB_MaterialLotInfo` đã bị xóa sạch, giải phóng hoàn toàn mã thùng.

5. **Hoàn tác số lượng Lệnh sản xuất & Tồn kho thành phẩm:**
   - **PO Finish Qty:** Giảm trừ `ProdFinishQty` trên `STB_ProductionOrderInfo`:
     `ProdFinishQty = ProdFinishQty - @ProdQty`
   - **Tóm tắt công đoạn:** Giảm trừ `OutputQty` trên `STB_ProdRouteSummary`.
   - **Chứng từ kho:** Gọi `usp_DoCancelMaterialDoc` để chuyển trạng thái hủy (`IsCancel = 1`) cho chứng từ nhập/xuất trong `STB_MaterialDocInfo` và xóa chi tiết trong `STB_MaterialDocLotInfo`.
   - **Xóa vết nhân công:** Xóa bản ghi thợ đóng gói tương ứng trong `STB_ProdRouteWorkerHist`.

6. **Khôi phục trạng thái LOT về đang chờ đóng gói:**
   - Cập nhật bảng `STB_SetInfo`:
     ```sql
     UPDATE STB_SetInfo
     SET IsProdFinish = 0,
         ProdFinishDateTime = NULL,
         ProdFinishJobDate = NULL,
         ProdFinishShiftCode = NULL
     WHERE ControlNo = @ControlNo AND IsProdFinish = 1
     ```
   - Đưa thẻ Lot trên giao diện POP Kiosk quay trở lại danh sách chờ đóng gói (icon Đồng hồ cát màu vàng), số lượng sẵn sàng được hoàn trả nguyên vẹn (1072 EA).

---

#### C. Bảng So Sánh Trước vs Sau Khi Bấm Hủy (Live Verified Matrix):

| Bảng CSDL / Chỉ Số | Trước Khi Hủy (12:45) | Sau Khi Quản Trị Viên Bấm Hủy (12:51) | Cơ Chế Tác Động |
| :--- | :--- | :--- | :--- |
| **`STB_ProdRouteHistCancelHist`** | Chưa có | **Có bản ghi Idx 87327** (`92603003`) | Ghi nhận Audit Log quản trị |
| **`STB_MaterialLotInfo`** | 20 bản ghi Box (`PKQR1800557`..576) | **0 bản ghi** (Đã xóa sạch) | Thu hồi mã Box BTP |
| **`STB_ProdRouteHist` (V-28)** | 20 bản ghi (51 EA × 20 = 1020 EA) | **0 bản ghi** (Đã xóa) | Xóa lượt chốt sản lượng đóng gói |
| **`STB_SetInfo.IsProdFinish`** | 0 (hoặc 1 nếu chốt xong) | **0 (`False`)** | Mở lại Lot cho phép đóng gói lại |
| **`STB_ProductionOrderInfo`** | Tính gộp 1020 EA vào `ProdFinishQty` | **Trừ 1020 EA** ra khỏi lũy kế PO | Trả lại hạn mức Lệnh sản xuất |
| **Giao diện POP Kiosk** | Đã đóng gói: 1,020 EA, Còn lại: 0 EA | **Sẵn sàng: 1,072 EA, Đã đóng gói: 0 EA** | Khôi phục 100% trên màn hình chuyền |

---

#### D. Hướng Dẫn Hủy Đóng Gói Thủ Công (Manual Override Guide):

Khi Kiosk POP bị treo, lỗi mất mạng, không hiển thị được popup "Xác nhận quản trị viên" hoặc cần xử lý cưỡng bức cho sản xuất gấp, IT/DBA/Quản lý có thể thực hiện theo 3 phương án thủ công sau:

##### 🌟 Phương Án 1 (Khuyên Dùng Nhất) — Gọi Trực Tiếp Stored Procedure Qua SQL / PowerShell
Đây là cách an toàn và chuẩn hóa nhất vì tái sử dụng đúng 100% logic của hệ thống, không sợ bỏ sót bảng hoặc lệch tồn kho kế toán:

- **Chạy qua SQL Server Management Studio / DBeaver:**
```sql
USE SmartFactoryV2;
GO

EXEC dbo.usp_DoCancelProdPacking_LotNo
     @pProcessUserID   = '92603003',       -- Mã quản trị viên / IT
     @pProcessLanguage = 'VIETNAMESE',    -- Ngôn ngữ ('VIETNAMESE' hoặc 'KOREAN')
     @pRouteCode       = 'V-28',           -- V-28 (Bắc Ninh), V-28_HY (Hưng Yên), VE10 (Hà Nam)
     @pBarcode         = 'VVQQ253R072701'; -- Mã Lot cần hủy đóng gói
GO
```

- **Hoặc chạy nhanh qua PowerShell CLI tại trạm MES:**
```powershell
.\mes.ps1 -Command "EXEC SmartFactoryV2.dbo.usp_DoCancelProdPacking_LotNo '92603003', 'VIETNAMESE', 'V-28', 'VVQQ253R072701'"
```

---

##### 🖥️ Phương Án 2 (Dành Cho Quản Lý Xưởng / Leader) — Hủy Trên MES WinForm Desktop
Nếu không tiện mở tool SQL, Quản lý sản xuất có thể dùng ứng dụng WinForm MES:
1. Mở phần mềm **MES WinForm (Awoo SmartFramework)**.
2. Vào menu: **생산관리 (Quản lý sản xuất) ➔ [B520] 제품 박스실적입력 (Nhập thực tích Box sản phẩm)** hoặc **[B523] / [HN523]**.
3. Tại ô tìm kiếm `Lot No` / `Barcode`: Quét hoặc nhập mã Lot (ví dụ: `VVQQ253R072701`) ➔ Bấm **[조회] (Tìm kiếm)**.
4. Lưới dữ liệu bên dưới sẽ liệt kê toàn bộ các Box BTP (`PK...`) đã đóng.
5. Chọn dòng Box cần hủy (hoặc chọn tất cả) ➔ Bấm nút **[실적취소] (Hủy thực tích / Cancel Result)** trên thanh công cụ.
6. Xác nhận đồng ý ➔ Phần mềm WinForm sẽ tự động gọi `usp_DoCancelProdPacking_LotNo` để dọn dẹp và khôi phục trạng thái.

---

##### 🔧 Phương Án 3 (Dành Cho DBA / Cứu Hộ Khẩn Cấp) — Transaction SQL Script Can Thiệp Đa Bảng
Sử dụng khi SP hệ thống bị kẹt (ví dụ vướng điều kiện khóa kho hoặc cần can thiệp ngoại lệ riêng cho 1 Box lẻ). **BẮT BUỘC** tuân thủ quy tắc an toàn `BEGIN TRAN ... ROLLBACK`:

```sql
-- ==============================================================================
-- HOTFIX THỦ CÔNG: ROLLBACK HỦY ĐÓNG GÓI CHO LOT [VVQQ253R072701]
-- Tuân thủ Rule 1: BEGIN TRAN ... ROLLBACK -> Kiểm tra @@ROWCOUNT -> Đổi COMMIT
-- ==============================================================================
USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @LotNo VARCHAR(50) = 'VVQQ253R072701';
    DECLARE @RouteCode VARCHAR(20) = 'V-28';           -- V-28 hoặc V-28_HY
    DECLARE @BoxQty NUMERIC(20,5) = 1020.00000;       -- Tổng SL hủy (51 EA x 20 Box)
    DECLARE @UserID VARCHAR(20) = '92603003';

    -- 1. Lấy thông tin điều phối ControlNo & PONo
    DECLARE @ControlNo VARCHAR(20), @PONo VARCHAR(20);
    SELECT @ControlNo = ControlNo, @PONo = PONo 
    FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
    WHERE Barcode = @LotNo;

    IF @ControlNo IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy thông tin Lot trong STB_SetInfo!', 16, 1);
        RETURN;
    END

    -- 2. Ghi nhật ký kiểm toán Audit Trail
    INSERT INTO SmartFactoryV2.dbo.STB_ProdRouteHistCancelHist (LotNo, CreateUserID, CreateDateTime)
    VALUES (@LotNo, @UserID, GETDATE());
    PRINT N'>> 1. Ghi log Audit STB_ProdRouteHistCancelHist thành công.';

    -- 3. Xóa các Box BTP trong STB_MaterialLotInfo
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo 
    WHERE LotNo = @LotNo;
    PRINT N'>> 2. Đã xóa STB_MaterialLotInfo: ' + CAST(@@ROWCOUNT AS VARCHAR) + N' bản ghi Box.';

    -- 4. Xóa lượt chốt công đoạn đóng gói trong STB_ProdRouteHist
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
    WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode;
    PRINT N'>> 3. Đã xóa STB_ProdRouteHist: ' + CAST(@@ROWCOUNT AS VARCHAR) + N' lượt chốt.';

    -- 5. Giảm trừ sản lượng hoàn thành trên Lệnh sản xuất (PO)
    UPDATE SmartFactoryV2.dbo.STB_ProductionOrderInfo 
    SET ProdFinishQty = CASE WHEN ProdFinishQty >= @BoxQty THEN ProdFinishQty - @BoxQty ELSE 0 END
    WHERE PONo = @PONo;
    PRINT N'>> 4. Đã giảm trừ ProdFinishQty trên PO: ' + @PONo;

    -- 6. Giảm trừ sản lượng tóm tắt công đoạn STB_ProdRouteSummary
    UPDATE SmartFactoryV2.dbo.STB_ProdRouteSummary
    SET OutputQty = CASE WHEN OutputQty >= @BoxQty THEN OutputQty - @BoxQty ELSE 0 END
    WHERE PONo = @PONo AND RouteCode = @RouteCode;
    PRINT N'>> 5. Đã giảm trừ OutputQty trong STB_ProdRouteSummary.';

    -- 7. Xóa vết phân công thợ đóng gói
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist 
    WHERE ProdRouteHistNo IN (SELECT ProdRouteHistNo FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = @ControlNo);

    -- 8. Khôi phục trạng thái Lot trong STB_SetInfo về WIP
    UPDATE SmartFactoryV2.dbo.STB_SetInfo 
    SET IsProdFinish = 0,
        ProdFinishDateTime = NULL,
        ProdFinishJobDate = NULL,
        ProdFinishShiftCode = NULL,
        ChangeDateTime = GETDATE()
    WHERE ControlNo = @ControlNo;
    PRINT N'>> 6. Đã khôi phục trạng thái IsProdFinish = 0 trong STB_SetInfo.';

    -- 9. Dọn dẹp tồn dư tạm trên POP Kiosk (nếu có)
    DELETE FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY 
    WHERE BARCODE = @LotNo AND ROUTE_CODE = @RouteCode;
    PRINT N'>> 7. Đã dọn dẹp bảng tạm VINA_PACKING_REMAIN_QTY trên POP.';

    -- [BẢO VỆ]: Mặc định để ROLLBACK khi chạy khảo sát, đổi thành COMMIT sau khi kiểm tra @@ROWCOUNT chuẩn
    ROLLBACK TRANSACTION;
    PRINT N'>> [AN TOÀN] Giao dịch đã được ROLLBACK để kiểm tra. Hãy đổi sang COMMIT khi xác nhận chính xác!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'>> LỖI PHÁT SINH: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
```

---

##### 🌟 Phương Án 4 (Chuyên Sâu) — HỦY LẺ TỪNG BOX / PACK (Partial Packing Cancellation)
*(Xác minh thực tế ngày 23/09/2026 trên Line HY #17 với Lot `VVQR143R060619`, Box `ECVT30-260QR2300003` - Pack `PKQR2300158`)*

###### A. Cách Xác Định `@pMaterialDocNo` Và Mã Đối Ứng Từ Box Barcode:
Trong CSDL `SmartFactoryV2.dbo.STB_MaterialDocLotInfo`, cột **`LotID`** chính là **Mã Tem Box (Box Barcode)** in dán trên thùng carton và hiển thị trên Web POP!

Truy vết siêu tốc 1 câu lệnh SQL:
```sql
SELECT 
    MDLI.MaterialDocNo,      -- Số chứng từ kho cần truyền vào @pMaterialDocNo (VD: 260923000241)
    MDLI.PackingID,          -- Mã Pack BTP (VD: PKQR2300158)
    MDLI.LotID AS BoxBarcode,-- Mã nhãn Box trên POP (VD: ECVT30-260QR2300003)
    MDLI.StockQty,           -- Số lượng của riêng Box này (VD: 495.00000)
    MDLI.LotNo,              -- Mã Lot gốc (VD: VVQR143R060619)
    MDLI.MaterialLotNo,      -- Khóa chính thùng BTP trong STB_MaterialLotInfo (VD: 20260923000371)
    MDI.IsCancel,            -- Trạng thái chứng từ (0: Active, 1: Đã hủy)
    MDI.CreateDateTime       -- Thời điểm đóng hộp
FROM SmartFactoryV2.dbo.STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_MaterialDocInfo MDI WITH(NOLOCK) 
    ON MDI.MaterialDocNo = MDLI.MaterialDocNo
WHERE MDLI.LotID = 'ECVT30-260QR2300003'   -- Quét theo mã tem Box
   OR MDLI.LotNo = 'VVQR143R060619';       -- Hoặc quét theo mã Lot để thấy cả 2 Box
```

###### B. Script Hotfix Hủy Lẻ 1 Box Duy Nhất (Chuẩn An Toàn Vinatech):
```sql
-- ==============================================================================
-- HOTFIX THỦ CÔNG: HỦY LẺ 1 PACK [PKQR2300158] CỦA LOT [VVQR143R060619]
-- Author: vanduc
-- ==============================================================================
USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @LotNo VARCHAR(50) = 'VVQR143R060619';
    DECLARE @PackingID VARCHAR(50) = 'PKQR2300158';       -- Mã pack cần hủy lẻ
    DECLARE @BoxBarcode VARCHAR(50) = 'ECVT30-260QR2300003';
    DECLARE @CancelQty NUMERIC(20,5) = 495.00000;         -- Số lượng của riêng Box này
    DECLARE @RouteCode VARCHAR(20) = 'V-28_HY';
    DECLARE @UserID VARCHAR(20) = 'vanduc';

    -- 1. Lấy thông tin điều phối
    DECLARE @ControlNo VARCHAR(20), @PONo VARCHAR(20);
    SELECT @ControlNo = ControlNo, @PONo = PONo 
    FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
    WHERE Barcode = @LotNo;

    -- 2. Tìm đúng chứng từ kho xuất/nhập của Box và hủy qua SP chuẩn
    DECLARE @MaterialDocNo VARCHAR(20);
    SELECT @MaterialDocNo = MaterialDocNo 
    FROM SmartFactoryV2.dbo.STB_MaterialDocLotInfo WITH(NOLOCK)
    WHERE PackingID = @PackingID AND LotNo = @LotNo;

    IF @MaterialDocNo IS NOT NULL
    BEGIN
        EXEC usp_DoCancelMaterialDoc 
             @pProcessLanguage = 'VIETNAMESE', 
             @pProcessUserID = @UserID, 
             @pMaterialDocNo = @MaterialDocNo;
        PRINT N'>> 1. Đã hủy chứng từ kho: ' + @MaterialDocNo;
    END

    -- 3. Xóa thùng BTP của riêng Box này trong STB_MaterialLotInfo
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo 
    WHERE LotNo = @LotNo AND PackingID = @PackingID;
    PRINT N'>> 2. Đã xóa Box trong STB_MaterialLotInfo: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 4. Giảm trừ sản lượng lũy kế V-28_HY trong STB_ProdRouteHist (từ 995 -> 500)
    UPDATE SmartFactoryV2.dbo.STB_ProdRouteHist
    SET ProdQty = ProdQty - @CancelQty,
        ChangeDateTime = GETDATE()
    WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode;
    PRINT N'>> 3. Đã giảm trừ ProdQty trong STB_ProdRouteHist.';

    -- 5. Giảm trừ sản lượng hoàn thành PO và Tổng kết công đoạn
    UPDATE SmartFactoryV2.dbo.STB_ProductionOrderInfo
    SET ProdFinishQty = ProdFinishQty - @CancelQty
    WHERE PONo = @PONo;

    UPDATE SmartFactoryV2.dbo.STB_ProdRouteSummary
    SET OutputQty = OutputQty - @CancelQty
    WHERE PONo = @PONo AND RouteCode = @RouteCode;
    PRINT N'>> 4. Đã giảm trừ sản lượng PO và RouteSummary.';

    -- 6. Đồng bộ Kiosk POP (MongoToMesPerformance)
    UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
    SET TotalProdQty = TotalProdQty - CAST(@CancelQty AS INT),
        IsDone = 0,
        IsTransferred = 0,
        InsertDateTime = GETDATE()
    WHERE Barcode = @LotNo AND RouteCode = @RouteCode;
    PRINT N'>> 5. Đã đồng bộ giảm trừ Kiosk POP.';

    -- 7. Khôi phục trạng thái Lot trong STB_SetInfo về WIP (chưa hoàn thành)
    UPDATE SmartFactoryV2.dbo.STB_SetInfo 
    SET IsProdFinish = 0,
        ProdFinishDateTime = NULL,
        ChangeDateTime = GETDATE()
    WHERE ControlNo = @ControlNo;
    PRINT N'>> 6. Đã khôi phục IsProdFinish = 0 trong STB_SetInfo.';

    -- Đối soát kiểm tra
    SELECT Barcode, IsProdFinish FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @ControlNo;
    SELECT RouteCode, ProdQty FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode;
    SELECT MaterialLotNo, PackingID, CurrentQty FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = @LotNo;

    ROLLBACK TRANSACTION;
    PRINT N'>> [AN TOÀN] Giao dịch đã ROLLBACK để kiểm tra. Đổi sang COMMIT khi xác nhận chính xác.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'>> LỖI: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
```

---


### 2.6 ✅ In Nhãn (Label Print) — AN TOÀN TUYỆT ĐỐI
*(Tham chiếu Slide 38, 45, 46, 47)*

**Bản chất:** In nhãn là thao tác **read + print**, không làm biến động số lượng tồn kho hay routing của LOT.
- Đề xuất nhãn phù hợp có gắn Sao ⭐.
- Cho phép chỉnh sửa `MaterialNo` (Tên vật tư) trực tiếp trên giao diện trước khi xuất lệnh in.
- In lại nhãn bất kỳ lúc nào qua nút "In lại" trong Lịch sử đóng gói hoặc màn hình In nhãn.
- Không gây side-effect nào trên kho/sản lượng.

---

### 2.7 ⚠️ Hạng Mục Tự Kiểm Tại Chuyền (In-Line QC Auto-Save)
*(Tham chiếu Slide 49, 50 — `image46.png`, `image47.png`)*

- **Cơ chế Auto-save on blur:** Khi nhập giá trị đo vào ô dữ liệu tại `/pop/quality/self`, chỉ cần click chuột ra ngoài ô nhập là hệ thống tự động lưu vào DB và đồng bộ tức thì về NAIS MES.
- **Cách Rollback / Sửa sai số đo:**
  - Nếu công nhân gõ nhầm số đo (ví dụ: `12.5` thay vì `12.0`): Chỉ cần click lại vào ô đó, gõ lại số đúng và click ra ngoài -> Hệ thống tự động ghi đè giá trị đo mới nhất.
  - Nếu cần tăng mẫu đo: Bấm nút `[+]` để thêm lần đo mẫu.
  - Nếu cần giải trình bất thường: Bấm nút thêm ghi chú hiện trường.

---

### 2.8 ⚠️ Quality Inspection (/pop/quality: IQC / PQC / OQC) — HẠN CHẾ

**Trước Submit Final:**
- ✅ Sửa kết quả kiểm tra (Pass/Fail, giá trị đo)
- ✅ Thay đổi mẫu kiểm tra
- ✅ Hủy toàn bộ và bắt đầu lại

**Sau Submit Final:**
- ❌ Không sửa được trên UI
- Cần admin MES hoặc SQL intervention
- Kết quả QC đã ghi vào bảng `STB_Quality*` là cố định

---

## 3. 📋 BẢNG TÓM TẮT — HƯỚNG DẪN AN TOÀN CHO CÔNG NHÂN

| Thao tác | Trước khi bấm, kiểm tra | Nếu sai, cách xử lý |
|----------|-------------------------|---------------------|
| **Nhập NVL** | ✅ Đúng mã NVL, đúng số lượng, đúng LOT | 🔴 Báo IT ngay — cần SQL fix |
| **Đăng ký lỗi** | ✅ Đúng loại lỗi, đúng số lượng | 🟡 Sửa trước Save, sau Save → báo IT |
| **Save Production** | ✅ Đúng SL OK/NG, đúng công đoạn | 🔴 Báo IT ngay — irreversible |
| **Đóng gói** | ✅ Đúng LOT, đúng SL, đúng kho | 🟢 Hủy trên UI (Lịch sử → Hủy đóng gói) |
| **In tem** | ✅ Đúng LOT/Box | 🟢 In lại bất kỳ lúc nào |
| **Quality** | ✅ Đúng giá trị đo, đúng mẫu | 🟡 Sửa trước Submit → OK; sau → báo QC Manager |

---

## 4. 🛡️ NGUYÊN TẮC AN TOÀN KHI TEST TRÊN PRODUCTION

> [!CAUTION]
> POP Web kết nối **TRỰC TIẾP** tới Production DB. Mọi thao tác đều ảnh hưởng dữ liệu thật.

### 4.1 Các Thao Tác AN TOÀN Khi Khảo Sát
- ✅ Đăng nhập, chọn Line, xem danh sách WO/LOT
- ✅ Xem chi tiết LOT, kiểm tra BOM, xem tồn kho
- ✅ Duyệt menu Quality (IQC/PQC/OQC) ở chế độ xem
- ✅ Xem Lịch sử đóng gói
- ✅ Chuyển đổi ngôn ngữ, Dark/Light mode

### 4.2 Các Thao Tác CẦN THẬN TRỌNG
- ⚠️ Bấm "NHẬP" NVL → Trừ kho thật
- ⚠️ Bấm "Save" Production → Move routing thật
- ⚠️ Submit Quality Inspection → Ghi kết quả QC thật

### 4.3 Đánh Giá Rủi Ro Phiên Test 2026-09-08
- **Kết quả:** Phiên test chỉ thực hiện các thao tác **READ-ONLY** (xem, duyệt menu, kiểm tra UI)
- **Không có thao tác WRITE** nào được thực hiện (không nhập NVL, không Save, không đóng gói)
- **Impact trên DB:** ZERO — Không có dữ liệu nào bị thay đổi
- **Rollback cần thiết:** Không — Không có gì cần rollback

---

## 5. 🔧 SQL SCRIPTS — KIỂM TRA IMPACT SAU THAO TÁC

### 5.1 Kiểm tra có nhập NVL gần đây không
```sql
SELECT TOP 20 LotNo, MaterialCode, InputQty, InputDate, ProcessUser
FROM VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST WITH(NOLOCK)
WHERE InputDate >= DATEADD(HOUR, -2, GETDATE())
ORDER BY InputDate DESC;
```

### 5.2 Kiểm tra đóng gói gần đây
```sql
SELECT TOP 20 BoxID, LotNo, PackQty, PackDate, CancelFlag
FROM VINATECH_POP.dbo.VINA_PACKING_LOG WITH(NOLOCK)
WHERE PackDate >= DATEADD(HOUR, -2, GETDATE())
ORDER BY PackDate DESC;
```

### 5.3 Kiểm tra routing move gần đây
```sql
SELECT TOP 20 SetNo, RouteSeq, GoodQty, DefectQty, CreateDate, ProcessUserID
FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE CreateDate >= DATEADD(HOUR, -2, GETDATE())
ORDER BY CreateDate DESC;
```
