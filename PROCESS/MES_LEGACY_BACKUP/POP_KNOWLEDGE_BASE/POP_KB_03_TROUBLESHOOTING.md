<!--
AI-READY METADATA
Purpose: Cẩm nang xử lý sự cố khẩn cấp trên hệ thống POP Web Kiosk Vinatech
Scope: Toàn bộ các lỗi vận hành POP, Kiosk phần cứng, API lỗi, kẹt Lot, lỗi in tem, và SQL Fix Scripts
Single Source of Truth: POP_KB_03_TROUBLESHOOTING.md
Target Tables: STB_SetInfo, STB_MaterialLotInfo, STB_PackingInfo, VINA_MATERIAL_INPUT_HIST, STB_DayProdPlan
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [POP_KB_01_ARCHITECTURE_AND_API.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md)
  - [POP_KB_02_SCREEN_OPERATIONS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md)
  - [POP_KB_04_ROLLBACK_AND_SAFETY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_04_ROLLBACK_AND_SAFETY.md)
-->

# POP_KB_03 — Cẩm Nang Xử Lý Sự Cố POP (Troubleshooting & Incident Guide)

> **Hệ thống:** POP Kiosk Web — `https://pop.vinatech.com/`  
> **Phạm vi:** Chẩn đoán sự cố, Root Cause Analysis (RCA), Hướng xử lý nhanh và SQL Hotfix cứu hộ  
> **🔑 Keywords:** troubleshoot, error, fix, bug, incident, timeout, printer, stuck lot, material error, packing error  
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)

---

## 1. 🚨 DANH MỤC SỰ CỐ KHẨN CẤP NHANH (QUICK DIAGNOSTIC MATRIX)

| Mã lỗi / Hiện tượng | Nguyên nhân gốc (Root Cause) | Khắc phục nhanh | Cần can thiệp SQL? |
|---------------------|-----------------------------|-----------------|--------------------|
| **POP-ERR-01: Không đăng nhập được** | Hết hạn SSO Token, sai mật khẩu, hoặc IIS AppPool restart | Xóa cache trình duyệt (Ctrl+F5), đăng nhập lại | Không |
| **POP-ERR-02: Trống danh sách Work Order** | DayPlan chưa kích hoạt trạng thái Release trên MES WinForm | Kỹ sư MES kích hoạt DayPlan trên WinForm B530 | Không |
| **POP-ERR-03: Thẻ LOT không hiển thị** | Lot đang bị HOLD, hoặc Lot đã finish, hoặc sai Line Code | Kiểm tra trạng thái Lot trên MES WinForm | Kiểm tra SELECT |
| **POP-ERR-04: Lỗi NVL không khớp BOM** | Mã cuộn NVL quét vào không nằm trong định mức Model | Kiểm tra lại tem cuộn NVL, đối chiếu BOM | Không |
| **POP-ERR-05: Lỗi NVL âm kho (Negative Stock)** | Cuộn NVL trên hệ thống đã trừ hết Qty trước đó | Báo kho cấp thêm hoặc bổ sung Lot NVL mới | Có thể |
| **POP-ERR-06: Không Merge được các Lot lẻ** | Khác chủng loại (Model mismatch) hoặc khác quy cách | Chỉ gộp các Lot cùng chung Model Code | Không |
| **POP-ERR-07: Lỗi in tem (Zebra Printer Fail)** | Máy in offline, kẹt giấy, mất IP LAN, hoặc ZPL format lỗi | Bật máy in, check đèn đỏ, kiểm tra Print Spooler | Không |
| **POP-ERR-08: Kẹt nút "Hoàn thành sản xuất"** | Thiếu bước nạp NVL bắt buộc (IsLineInput = 0) | Hoàn thành nạp NVL theo định mức trước khi Save | Không |
| **POP-ERR-09: Lỗi "This route is already completed in MES"** | Công đoạn đã có lượt chốt cũ/thử trong `STB_ProdRouteHist`, WinForm chặn POP | Xóa lượt chốt kẹt cũ trong `STB_ProdRouteHist` & `STB_ProdRouteWorkerHist` | **CÓ (SQL Hotfix)** |
| **POP-ERR-10: Lỗi chốt sớm Đóng gói V-28_HY** | Chốt đóng gói trước khi hoàn tất BTP/Lot lẻ, kẹt `VINA_PACKING_REMAIN_QTY` | Rollback đồng bộ 3 bảng (`MaterialLotInfo`, `ProdRouteHist`, `VINA_PACKING_REMAIN_QTY`) | **CÓ (SQL Hotfix)** |
| **POP-ERR-11: Lỗi "Số mẫu mục tiêu là 0" (Quality PQC)** | Sample Size = 0 ở khung quy cách hoặc Master Data, không hiện ô nhập `#1, #2` | Chạm ô số mẫu ở khung tiêu chuẩn để tăng >0, hoặc cấu hình `STB_MaterialQcInspectionItem_HY` | Không (trừ khi sửa Master) |
| **POP-ERR-12: Khóa kết quả đo sau khi bấm "Hoàn thành"** | Phiên PQC đã đóng (`STB_CommInspDocHistory.IsFinished=1`), nút đổi thành "Hoàn tác" | Bấm Hoàn tác gửi yêu cầu (Admin duyệt `VINA_REOPEN_REQUEST`) hoặc IT reset `IsFinished=0` | Cần duyệt / SQL |
| **POP-ERR-13: Lệch / Không đồng nhất công đoạn giữa Kiosk POP và MES** | Chốt chéo WinForm trước Kiosk, nhảy cóc công đoạn V-27_HY sang V-28_HY, hoặc kẹt dở dang V-26_HY | Dùng Golden Query `.\mes.ps1 trace '<Lot>'`. Xóa bản ghi kẹt cũ qua Template 3 hoặc rollback Đóng gói qua Template 4 | **CÓ (SQL Hotfix)** |

---

## 2. 🔍 CHI TIẾT SỰ CỐ & QUY TRÌNH XỬ LÝ CHUẨN

### 2.1 POP-ERR-01: Lỗi Truy Cập & Đăng Nhập Kiosk

**Hiện tượng:** Trình duyệt báo `401 Unauthorized`, `Token Expired`, hoặc màn hình trắng xóa khi mở `https://pop.vinatech.com/`.

**Quy trình kiểm tra:**
1. Mở Console trình duyệt (`F12`): Kiểm tra xem API gọi `/api/common/login` hay `/api/common/verifyToken` trả về mã gì.
2. Nếu mã lỗi `401`: Token JWT trong LocalStorage đã quá hạn (thường sau 8 giờ hoặc đổi ca).
   - **Xử lý:** Bấm nút **"Đăng xuất"** hoặc xóa Cookie/LocalStorage, sau đó đăng nhập lại bằng User ID & Password.
3. Nếu mạng báo `ERR_CONNECTION_REFUSED`: 
   - Kiểm tra kết nối mạng nội bộ của Kiosk tới IP Web Server (`dbserver.hycap.co.kr` hoặc Server IIS POP).
   - Kiểm tra dịch vụ IIS trên máy chủ POP.

---

### 2.2 POP-ERR-02 & 03: Không Thấy Lệnh Sản Xuất (WO) Hoặc Thẻ LOT

**Hiện tượng:** Chọn đúng Chuyền (Line) và đúng Ngày nhưng bảng danh sách Lệnh SX hoặc Thẻ Lot trống rỗng.

**Root Cause:**
1. **Lệnh SX chưa phát hành:** Quản lý sản xuất tạo Kế hoạch ngày nhưng chưa ấn nút "Phát hành" (Release/Confirm) trên MES WinForm.
2. **Lot chưa được gán vào Chuyền:** Lot được tạo nhưng `CurrentLineCode` bị lệch so với Line mà Kiosk đang chọn.
3. **Lot bị chặn (HOLD):** Lot bị QC gắn cờ `IsHold = 1` do phát sinh sự cố ở công đoạn trước.

**Kiểm chứng nhanh bằng SQL (SELECT-Only):**
```sql
-- Kiểm tra trạng thái Kế hoạch ngày
SELECT PlanDate, DayPlanID, LineCode, ModelCode, PlanQty, ProdQty, PlanStatus
FROM SmartFactoryV2.dbo.STB_DayProdPlan WITH(NOLOCK)
WHERE LineCode = N'<MÃ_LINE>' AND PlanDate = CONVERT(VARCHAR(10), GETDATE(), 120);

-- Kiểm tra trạng thái Lot
SELECT LotNo, ModelCode, CurrentLineCode, CurrentRouteCode, IsHold, IsComplete, BadQty, GoodQty
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE LotNo = N'<LOT_NO>';
```

---

### 2.3 POP-ERR-04 & 05: Sự Cố Nhập Nguyên Vật Liệu (Material Input)

**Hiện tượng:** Quét mã vạch cuộn NVL, màn hình báo popup đỏ: *"Vật liệu không hợp lệ"* hoặc *"Số lượng tồn kho không đủ"*.

**Nguyên nhân & Cách khắc phục:**
1. **Sai BOM:** Kiểm tra cấu trúc BOM của sản phẩm. Cuộn NVL quét vào phải có mã vật tư (`MaterialCode`) trùng khớp với BOM đã phê duyệt của Model hiện hành.
2. **Hết tồn kho trên hệ thống:** Dù thực tế cuộn vật liệu còn trên tay, nhưng trong hệ thống `SmartFactoryV2.dbo.STB_MaterialLotInfo`, cột `Qty` đã bằng 0 (do ca trước đã quét trừ hết).
   - *Khắc phục:* Yêu cầu thủ kho MES nhập phiếu bổ sung NVL hoặc đổi sang cuộn tem khác có tồn kho hợp lệ.

---

### 2.4 POP-ERR-06: Lỗi Khi Đóng Gói Gộp Thùng (Merge Pack)

**Hiện tượng:** Bấm chọn thêm Lot lẻ thứ 2, hệ thống từ chối và báo lỗi *"Không thể gộp các Lot khác quy cách"*.

**Quy tắc nghiệp vụ bất biến:**
- **Quy tắc 1:** Chỉ được merge các Lot có **cùng ModelCode** chính xác 100%.
- **Quy tắc 2:** Các Lot tham gia merge phải ở **cùng công đoạn Đóng gói** (`CurrentRouteCode` = Packing Route).
- **Quy tắc 3:** Tổng số lượng sau khi merge **không được vượt quá quy cách đóng gói tối đa** của Model (ví dụ: Box tiêu chuẩn là 200 cái, tổng các Lot lẻ không được vượt quá 200).

---

### 2.5 POP-ERR-07: Sự Cố Máy In Tem Nhãn (Zebra Label Printer)

**Hiện tượng:** Bấm in tem nhưng máy in không phản hồi, hoặc in ra tem trắng, hoặc tem bị lệch hàng.

**Checklist xử lý tại chỗ:**
1. **Kiểm tra phần cứng máy in:**
   - Đèn trạng thái trên máy in Zebra: Xanh lá (Ready), Đỏ nhấp nháy (Hết giấy hoặc ruy-băng mực), Vàng (Nắp mở).
   - Bấm nút **Feed** trên máy in để kiểm tra xem tem có đẩy ra đúng 1 con tem chuẩn không. Nếu đẩy ra nhiều tem: Cần **Calibrate** lại sensor máy in (giữ nút Feed cho đến khi đèn nháy 2 lần rồi nhả).
2. **Kiểm tra kết nối mạng / USB:**
   - Đảm bảo Kiosk vẫn nhận máy in trong Windows Printers (`ZDesigner ZT230` hoặc tương đương).
3. **In lại từ Web:** Mở tab **Lịch sử đóng gói** → Chọn lô đóng gói → Bấm **"In lại"**.

---

## 3. 🛠️ TEMPLATE SQL CỨU HỘ VẬN HÀNH (SAFETY HOTFIX TEMPLATES)

> [!CAUTION]
> Tuân thủ tuyệt đối **RULE 1 (SELECT-Only)**. Chỉ chạy lệnh ghi khi có sự đồng ý bằng văn bản của Quản lý MES.
> Luôn sử dụng cú pháp an toàn `BEGIN TRAN ... ROLLBACK` để kiểm tra số dòng ảnh hưởng trước khi Commit!

### Template 1: Hoàn Trả Kho Khi Quét Nhầm NVL Trên POP
```sql
BEGIN TRAN;

DECLARE @LotNo NVARCHAR(50) = N'VNCELL260908001';
DECLARE @MatLotNo NVARCHAR(50) = N'RAW-MAT-2026-09-0012';
DECLARE @RefundQty DECIMAL(18,4) = 50.0;

-- 1. Hoàn trả số lượng tồn kho NVL
UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo
SET Qty = Qty + @RefundQty,
    ModifyDate = GETDATE()
WHERE MaterialLotNo = @MatLotNo;

-- 2. Ghi chú điều chỉnh vào nhật ký POP
INSERT INTO VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST (
    LOT_NO, MATERIAL_LOT_NO, INPUT_QTY, INPUT_DATE_TIME, WORKER_ID, STATUS
) VALUES (
    @LotNo, @MatLotNo, -@RefundQty, GETDATE(), N'ADMIN_FIX', N'CANCEL'
);

-- Kiểm tra kết quả
SELECT MaterialLotNo, Qty FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE MaterialLotNo = @MatLotNo;

-- Nếu đúng số lượng mong muốn: Thay ROLLBACK bằng COMMIT
ROLLBACK;
```

---

### 2.6 POP-ERR-09: Lỗi "This route is already completed in MES" Khi Chốt Công Đoạn
**Hiện tượng:** Công nhân chọn công đoạn (ví dụ Aging `V-26_HY`) và bấm **"HOÀN THÀNH SẢN XUẤT"** trên POP Kiosk, hệ thống văng popup đỏ: *"Thất bại: This route is already completed in MES."*. Quay sang mở MES WinForm (B530/B540) để chốt thủ công thì MES chặn: *"Vui lòng sử dụng hệ thống POP để nhập sản lượng"*.

**Nguyên nhân gốc (Root Cause):**
- Trong bảng `SmartFactoryV2.dbo.STB_ProdRouteHist`, công đoạn đó của Lot đã tồn tại sẵn một bản ghi chốt cũ (do chốt nhầm, chốt thử hoặc chạy dở từ các ca trước).
- API POP kiểm tra thấy công đoạn đã tồn tại nên chặn không cho chốt đè để tránh nhân đôi sản lượng. Đồng thời MES WinForm đã cấu hình chuyển giao quyền sang Kiosk nên từ chối nhập liệu.

**Quy trình khắc phục:**
1. Tra cứu `ProdRouteHistNo` của bản ghi kẹt cũ:
   ```sql
   SELECT ProdRouteHistNo, ControlNo, RouteCode, ProdQty, JobDate, CreateDateTime
   FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
   WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = N'<LOT_NO>')
     AND RouteCode = N'<MÃ_ROUTE>';
   ```
2. Thực hiện xóa bản ghi kẹt cũ trong `STB_ProdRouteWorkerHist` và `STB_ProdRouteHist` qua Template 3.
3. Hướng dẫn công nhân F5 Kiosk, chọn lại Lot và bấm **"HOÀN THÀNH SẢN XUẤT"** bình thường.

---

### 2.7 POP-ERR-10: Kẹt Đóng Gói Do Chốt Sớm Công Đoạn V-28_HY
**Hiện tượng:** Lot không thể đóng gói gộp hoặc in tem thùng tại trạm đóng gói POP Kiosk.

**Nguyên nhân gốc:** Công đoạn `V-28_HY` bị chốt trước khi hoàn tất đóng gói thực tế, làm sinh bản ghi mồ côi trong `STB_MaterialLotInfo` và `VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY`.
**Khắc phục:** Rollback đồng bộ 3 bảng qua Template 4.

---

### 2.8 POP-ERR-11 & 12: Sự Cố Phân Hệ Chất Lượng Quality (`/pop/quality/self`)
**Hiện tượng 1:** Màn hình đo PQC hiện thông báo *"Số mẫu mục tiêu là 0 — tăng số mẫu mục tiêu ở khung quy cách để hiện ô nhập"*, không có ô gõ số liệu.
- **Xử lý:** Chạm vào ô số mẫu `0/0` ở khung quy cách bên phải (bên dưới ô Tiêu chuẩn) để tăng số lượng mẫu đo lên (>0). Nếu là hạng mục đo định kỳ không bắt buộc theo Lot thì bỏ qua.

**Hiện tượng 2:** Nút "Hoàn thành" biến mất, thay bằng nút **`Hoàn tác`** và popup *"Lý do mở lại"*.
- **Nguyên nhân:** Phiên đo kiểm đã bấm `Hoàn thành` (`STB_CommInspDocHistory.IsFinished = 1` - Pass). Hệ thống khóa Read-only theo chính sách `VINA_REOPEN_POLICY`.
- **Cách mở lại:**
  - *Cách 1 (Chuẩn UI):* Gõ lý do bấm **"Gửi yêu cầu"**, Quản lý QC hoặc IT vào bảng `VINA_REOPEN_REQUEST` duyệt `STATUS = 'APPROVED'`.
  - *Cách 2 (SQL khẩn cấp):* IT reset cờ hoàn thành qua Template 5.

---

### 2.9 POP-ERR-13: Hiện Tượng Không Đồng Nhất Công Đoạn Giữa POP Kiosk và MES WinForm
**Hiện tượng:** 
1. Cùng 1 mã Lot nhưng xem trên POP Kiosk hiển thị công đoạn khác so với MES WinForm Desktop (B530/HY530).
2. Tại POP Kiosk, bấm "Hoàn thành sản xuất" bị chặn báo *"This route is already completed in MES"*, hoặc sang Đóng gói Kiosk bị báo *"Vượt quá số lượng còn lại (0 EA)"*.
3. Tại MES WinForm (B530), quét Lot thì bị popup chặn: *"Search failed: Vui lòng sử dụng hệ thống POP để nhập sản lượng"*.

**Nguyên nhân gốc (Root Cause):**
- **Xung đột chốt chéo (Dual-entry):** Dữ liệu công đoạn đã được chốt trước trên WinForm, DB đã ghi nhận bản ghi trong `STB_ProdRouteHist`. Kiosk POP đối chiếu thấy đã có bản ghi nên chặn ghi đè để bảo vệ số liệu.
- **Nhảy cóc công đoạn (Skip Route):** Bỏ qua công đoạn trung gian (như `V-27_HY` Ngoại quan) nhảy thẳng từ `V-26_HY` sang `V-28_HY` Đóng gói, hoặc công đoạn liền trước bị treo dở dang `CompleteRoute = NULL`.
- **Chốt sớm công đoạn đóng gói:** Chốt `V-28_HY` trên WinForm làm sinh BTP trong `STB_MaterialLotInfo` và tiêu thụ hết sản lượng khả dụng của Lot trên Kiosk.

**Quy trình chuẩn đoán & Khắc phục:**
1. Chạy Golden Query 360: `.\mes.ps1 trace '<LotID>'` để lấy `ControlNo`, đối soát trạng thái `STB_SetInfo` và các dòng trong `STB_ProdRouteHist`.
2. Nếu kẹt bản ghi công đoạn cũ ở giữa (Aging `V-26_HY`): Áp dụng **Template 3** xóa bản ghi kẹt cũ trong `STB_ProdRouteWorkerHist` và `STB_ProdRouteHist`.
3. Nếu chốt sớm công đoạn đóng gói (`V-28_HY`): Áp dụng **Template 4** rollback đồng bộ 3 bảng (`STB_MaterialLotInfo`, `STB_ProdRouteHist`, `VINA_PACKING_REMAIN_QTY`).

---

## 3. 🛠️ TEMPLATE SQL CỨU HỘ VẬN HÀNH (SAFETY HOTFIX TEMPLATES)

> [!CAUTION]
> Tuân thủ tuyệt đối **RULE 1 (SELECT-Only)**. Chỉ chạy lệnh ghi khi có sự đồng ý bằng văn bản của Quản lý MES.
> Luôn sử dụng cú pháp an toàn `BEGIN TRAN ... ROLLBACK` để kiểm tra số dòng ảnh hưởng trước khi Commit!

### Template 1: Hoàn Trả Kho Khi Quét Nhầm NVL Trên POP
```sql
BEGIN TRAN;

DECLARE @LotNo NVARCHAR(50) = N'VNCELL260908001';
DECLARE @MatLotNo NVARCHAR(50) = N'RAW-MAT-2026-09-0012';
DECLARE @RefundQty DECIMAL(18,4) = 50.0;

-- 1. Hoàn trả số lượng tồn kho NVL
UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo
SET Qty = Qty + @RefundQty,
    ModifyDate = GETDATE()
WHERE MaterialLotNo = @MatLotNo;

-- 2. Ghi chú điều chỉnh vào nhật ký POP
INSERT INTO VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST (
    LOT_NO, MATERIAL_LOT_NO, INPUT_QTY, INPUT_DATE_TIME, WORKER_ID, STATUS
) VALUES (
    @LotNo, @MatLotNo, -@RefundQty, GETDATE(), N'ADMIN_FIX', N'CANCEL'
);

-- Kiểm tra kết quả
SELECT MaterialLotNo, Qty FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE MaterialLotNo = @MatLotNo;

-- Nếu đúng số lượng mong muốn: Thay ROLLBACK bằng COMMIT
ROLLBACK;
```

---

### Template 2: Giải Tỏa Lot Bị Treo Trạng Thái Khóa (HOLD Release)
```sql
BEGIN TRAN;

DECLARE @TargetLot NVARCHAR(50) = N'VNCELL260908002';

UPDATE SmartFactoryV2.dbo.STB_SetInfo
SET IsHold = 0,
    HoldReason = NULL,
    ModifyDate = GETDATE()
WHERE LotNo = @TargetLot AND IsHold = 1;

-- Xác minh
SELECT LotNo, IsHold, CurrentRouteCode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE LotNo = @TargetLot;

ROLLBACK; -- Thay bằng COMMIT sau khi verify
```

---

### Template 3: Giải Phóng Lượt Chốt Công Đoạn Kẹt (This route is already completed in MES)
```sql
-- Áp dụng khi POP chặn chốt công đoạn do có bản ghi cũ trong MES
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @TargetHistNo VARCHAR(20) = '20260830000798';
    DECLARE @TargetControlNo VARCHAR(20) = '20260807000462';
    DECLARE @TargetRoute VARCHAR(20) = 'V-26_HY';

    -- 1. Snapshot backup an toàn
    -- SELECT * INTO BAK_STB_ProdRouteHist_<Date> FROM STB_ProdRouteHist WHERE ProdRouteHistNo = @TargetHistNo;
    -- SELECT * INTO BAK_STB_ProdRouteWorkerHist_<Date> FROM STB_ProdRouteWorkerHist WHERE ProdRouteHistNo = @TargetHistNo;

    -- 2. Xóa bản ghi worker mapping
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist WHERE ProdRouteHistNo = @TargetHistNo;

    -- 3. Xóa bản ghi routing kẹt
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
    WHERE ProdRouteHistNo = @TargetHistNo AND ControlNo = @TargetControlNo AND RouteCode = @TargetRoute;

    IF @@ROWCOUNT = 1
        COMMIT TRANSACTION;
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Số dòng ảnh hưởng khác 1, đã rollback!', 16, 1);
    END
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

---

### Template 4: Rollback Lượt Chốt Sớm Đóng Gói V-28_HY
```sql
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @MatLotNo VARCHAR(50) = '20260917000404';
    DECLARE @LotNo VARCHAR(50) = 'VVQR013R072727';
    DECLARE @HistNo VARCHAR(20) = '20260917000709';
    DECLARE @ControlNo VARCHAR(20) = '20260901000137';

    -- 1. Xóa bán thành phẩm sinh sớm
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WHERE MaterialLotNo = @MatLotNo AND LotNo = @LotNo;

    -- 2. Xóa lượt chốt công đoạn V-28_HY
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist WHERE ProdRouteHistNo = @HistNo AND ControlNo = @ControlNo AND RouteCode = 'V-28_HY';

    -- 3. Xóa tồn dư tạm trong POP
    DELETE FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY WHERE BARCODE = @LotNo AND ROUTE_CODE = 'V-28_HY';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

---

### Template 5: Mở Lại Phiếu Đo Kiểm PQC Đã Đóng (Reopen Inspection)
```sql
-- Reset trạng thái phiếu đo kiểm đã đóng để mở lại ô nhập liệu trên Kiosk
UPDATE SmartFactoryV2.dbo.STB_CommInspDocHistory
SET IsFinished = 0,
    ChangeDateTime = GETDATE(),
    ChangeUserID = N'ADMIN_REOPEN'
WHERE CommInspDocNo = N'<COMM_INSP_DOC_NO>';
```

