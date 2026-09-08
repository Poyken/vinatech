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
