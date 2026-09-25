# 📘 VINATECH MES & POP — MASTER OPERATIONAL PLAYBOOK (SỔ TAY VẬN HÀNH THỰC CHIẾN)

> **Cập nhật:** 2026-09-21 | **Phiên bản:** 3.0 Enterprise Core  
> **Nguyên tắc môi trường:** 100% Terminal / PowerShell / Python Console / Telegram Bot. **Tuyệt đối không dùng Trình duyệt Web / Không mở HTML**.  
> **Mục tiêu tối thượng:** Phản xạ tức thời (< 3 giây), chẩn đoán chính xác 100%, an toàn dữ liệu tuyệt đối (SELECT-Only, BEGIN TRAN...ROLLBACK).

---

## PHẦN 1: BẢN ĐỒ TỔNG HỢP 7 NHÓM SỰ CỐ KINH ĐIỂN TOÀN NHÀ MÁY

Qua rà soát toàn bộ lịch sử 60+ hotfixes (`HOTFIX_LOG.md`), 70+ bugs (`KB_09_SCREEN_BUG_FIXBOOK.md`), 20 lỗi Kiosk (`POP_KB_03`) và bài học vận hành (`LESSONS_LEARNED.md`), 95% sự cố tại xưởng Vinatech tập trung vào 7 nhóm cốt lõi:

| Nhóm | Tên nhóm sự cố | Triệu chứng điển hình | Nguyên nhân gốc rễ (Root Cause) | Khắc phục nhanh |
|:---:|:---|:---|:---|:---|
| **1** | **Tranh chấp quyền chốt POP vs WinForm** | POP báo: `This route is already completed in MES`. WinForm B530 báo: `Vui lòng sử dụng hệ thống POP`. | Trong `STB_ProdRouteHist` đã tồn tại bản ghi công đoạn cũ/chạy thử của các ca trước hoặc kẹt `MongoToMesPerformance` (`IsDone=1`). | Dùng `.\mes.ps1 diagnose "<Lot>"` ➔ Xóa bản ghi kẹt cũ trong `STB_ProdRouteHist` & `STB_ProdRouteWorkerHist` ➔ F5 Kiosk chốt lại. |
| **2** | **Lệch ca làm việc & Cắt ca 10:00 AM trên B782** | Lot chốt ca đêm (00:00 - 08:30 AM) bị biến mất khỏi ngày hôm nay, nhảy về ngày hôm trước. | SP `usp_LotTrackingInfo_VVT2_get` quy định ca từ 10h sáng hôm trước đến 10h sáng hôm sau. Nếu chỉ sửa `JobDate` mà không tăng `ProdDateTime` qua 10h thì B782 vẫn gom vào ngày cũ. | Kỹ thuật cộng giờ chuẩn hóa: `SET ProdDateTime = DATEADD(HOUR, 10, ProdDateTime), JobDate = 'YYYY-MM-DD'` (Hotfix ID_50, 52, 54). |
| **3** | **Phế NG rỗng hoặc âm do Three-Valued Logic** | Cột NG trên NAIS B782 bị 0 hoặc rỗng dù công nhân POP Kiosk đã nhập phế và lưu `STB_DefectRepairInfo`. | Kiosk lưu phế để `RepairQty = NULL`. SP tính `DefectQty - RepairQty`. Trong SQL: `Số - NULL = NULL`. | Bọc `ISNULL(RepairQty, 0)` trong SP hoặc chuẩn hóa dữ liệu: `UPDATE STB_DefectRepairInfo SET RepairQty = 0 WHERE RepairQty IS NULL`. |
| **4** | **Kẹt khóa thiết bị độc quyền trên Kiosk POP** | Modal "Xác nhận kết thúc?" bị thiếu máy (Winding, Curling, Sleeving) dù CSDL có cấu hình. | Bảng `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING` giữ trạng thái `ACTIVE` ở DayPlan cũ do công nhân hết ca không bấm Release. | Chạy ngay lệnh tự động 1-Shot: `.\mes.ps1 release-machines -Force` (Tự động snapshot backup và nhả khóa). |
| **5** | **Thiếu Master Data khi ra Model mới** | Tạo PO báo `공정라우팅정보가 없습니다` hoặc B523 báo popup `Could not find Kho Thành phẩm chưa nhập cân nặng`. | (1) B240 thiếu bộ Routing cho xưởng hoặc A230 gán sai `BasicRoutingCode`.<br>(2) Sau B351 chuyển đổi Lot, mã mới thiếu cân nặng trong `STB_VIETNAM_BARCODEWEIGHT`. | (1) Sửa `BasicRoutingCode` ở A230.<br>(2) Nạp `WEIGHT = 25.5` vào `STB_VIETNAM_BARCODEWEIGHT` và mở khóa `STB_PackingLabelPrintHist`. |
| **6** | **Thùng dung dịch điện phân về 0 KG** | Thùng 150 KG (GBEC00/GBCP00) vừa đưa lên chuyền Hưng Yên quét 1 lần đã báo "Hết hàng" (0 KG). | Xung đột chuyển kho: Thùng xuất từ kho Hà Nam (`ROUTE_VN_WH`), sang Hưng Yên hệ thống tự tạo dòng ở `ROUTE_HY_WH` và trừ sạch thùng cũ về 0. | Phục hồi đúng 150.0 KG tại `ROUTE_HY_WH` theo chuẩn SOP Template 6 POP_KB_03: `UPDATE STB_MaterialLotInfo SET CurrentQty = 150.0 ...`. |
| **7** | **Rollback công đoạn đầu Winding vs Công đoạn cuối Đóng gói** | (1) Chốt nhầm Winding V-22 chặn B530.<br>(2) Chốt sớm Đóng gói V-28 làm Kiosk báo `Có thể đóng gói thêm: 0 EA`. | (1) V-22 là công đoạn đầu (`IsInputRoute=1`), khi chốt tự sinh V-23 downstream.<br>(2) V-28 chốt sớm sinh BTP tại `STB_MaterialLotInfo` làm tiêu thụ hết hạn mức. | (1) SOP Winding: Xóa phế NG, xóa dòng V-23, reset V-22 `CompleteRoute = NULL` (CẤM xóa dòng V-22).<br>(2) SOP Đóng gói: Xóa BTP kho tuyến, xóa V-28 trong `STB_ProdRouteHist`, xóa `VINA_PACKING_REMAIN_QTY`. |

---

## PHẦN 2: BỘ CÔNG CỤ TÁC CHIẾN TERMINAL & CLI NATIVE (0 BROWSER)

Toàn bộ hệ thống được điều phối qua CLI Hub duy nhất: `.\mes.ps1` và Persistent REPL Shell:

### 1. Master Auto-Diagnostic Engine (`.\mes.ps1 diagnose "<Text/Lot>"`)
- **Tốc độ:** < 0.2s (tĩnh) đến < 1.5s (có kết nối CSDL).
- **Cơ chế:** Tự động trích xuất Lot, Screen, Line, áp dụng 11 quy tắc suy diễn chuyên gia, kết nối Single Round-Trip vào live CSDL và xuất ngay định dạng chuẩn **"4 DÒNG VÀNG"**:
  1. 🎯 **Nguyên nhân gốc rễ (Root Cause)**
  2. 📍 **Hiện trạng dữ liệu thực tế**
  3. 🛠️ **Cách OP tự xử lý trên UI (Workaround)**
  4. ⚡ **SQL Hotfix chuẩn (BEGIN TRAN...ROLLBACK)**

### 2. Persistent REPL Shell (`.\mes.ps1 shell`)
- **Tốc độ:** **88 ms** (nhanh gấp 20 lần so với cold-start PowerShell).
- **Cơ chế:** Mở 1 phiên làm việc giữ kết nối CSDL và nạp sẵn toàn bộ L1 Cache vào RAM.
- **Tính năng thông minh:** Paste thẳng bất kỳ mã Lot hay câu báo lỗi nào của OP, Shell sẽ tự động nhận diện và kích hoạt bộ máy chẩn đoán ngay lập tức!
- **Lệnh hữu ích:** `diagnose <loi>`, `trace <lot>`, `find <kw>`, `health`, `readiness`, `release -Force`, `query <sql>`.

### 3. Golden Query 360° (`.\mes.ps1 trace "<LotID>"`)
- Gom toàn bộ 6 bảng cốt lõi (`STB_SetInfo`, `STB_ProdRouteHist`, `STB_MaterialLotInfo`, `STB_DefectRepairInfo`, `MongoToMesPerformance`, `VINA_PACKING_REMAIN_QTY`) vào **1 nhịp mạng TCP duy nhất**.

### 4. Auto-Pilot Watchdog 24/7 (`.\mes.ps1 watchdog-hidden`)
- Tuần tra ngầm liên tục 4 chỉ số sinh tồn: Deadlock/Blocking CSDL, Kẹt sync POP >30p, Máy kẹt lock >12h, Lot HOLD.
- Tự động phát hiện và gửi tin nhắn cảnh báo cứu hỏa về Telegram kèm giải pháp tức thì.

---

## PHẦN 3: CÁC BÀI HỌC VẬN HÀNH XƯƠNG MÁU (LESSONS LEARNED)

1. **Nguyên tắc Toàn vẹn 4 Bảng (4-Table Integrity):**
   Khi hủy hoặc sửa sản lượng, luôn đối chiếu và đồng bộ đủ 4 bảng: `STB_ProdRouteHist`, `STB_ProdRouteSummary`, `STB_ProductionOrderInfo` và `STB_SetInfo`. Không bao giờ xóa 1 bảng mà bỏ quên các bảng còn lại.
2. **Cấm chạy SELECT mò mẫm (Zero Blind SELECT):**
   Tuyệt đối không chạy 20–40 câu `SELECT` thăm dò cấu trúc bảng qua đường truyền mạng WAN. Tra cứu L1 Cache trước, chỉ dùng `.\mes.ps1 trace` hoặc `.\mes.ps1 diagnose` trong 1 nhịp.
3. **Bẫy font chữ trên giao diện MES NAIS:**
   Font chữ của NAIS render 2 chữ `VV` sát nhau nhìn giống hệt chữ `W` (ví dụ `VVQP...` nhìn như `WQP...`, `01` nhìn như `D1`). Luôn dùng `LIKE '%...%'` hoặc quy đổi `W` thành `VV` khi truy vấn.
4. **Giới hạn độ dài chuỗi SQL:**
   Cột `RELEASE_REASON` trong `VINA_EQUIPMENT_MAPPING` chỉ có độ dài `NVARCHAR(50)`. Truyền chuỗi dài hơn 50 ký tự sẽ gây crash lỗi `String or binary data would be truncated`.
5. **Bypass Trigger khi xóa chứng từ đóng gói:**
   Bảng `STB_MaterialDocDetail` có trigger `tgMaterialDocDetailForDelete`. Để xóa chứng từ lỗi, bắt buộc phải set `CONTEXT_INFO 0x999997` và mở `DocStatus = 'CREATE'` trước khi DELETE.
6. **Mọi phép tính số học phải bọc `ISNULL(..., 0)`:**
   SQL Server tuân thủ Three-Valued Logic: `Giá trị - NULL = NULL`. Mọi câu lệnh tính phế, sản lượng phải bọc `ISNULL(col, 0)`.
7. **Bẫy Lệch Cột khi Import Excel (Column Shift Misalignment - F330/B598):**
   Khi OP gửi ảnh/file Excel lỗi, phải kiểm tra tiêu đề cột và kiểu dữ liệu từng ô. Lỗi phổ biến nhất là dán nhầm mã vị trí khay/kệ (`E04, E05`) vào cột chu kỳ ngày tháng (`StartPeriod`). Sử dụng ngay `.\mes.ps1 validate-excel <File.xlsx> -Route F330` để phát hiện tự động trong 0.5s.
8. **Đặc thù Hardcode Báo Phế B598 (`usp_vn_showproductionerror`):**
   Màn hình B598 từ năm 2021 đến nay không đọc giá từ bảng Master mà gán cứng công thức chia cân nặng và đơn giá USD trong SP bằng `CASE WHEN MaLotNguyenLieu = '...' THEN ...`. Tra cứu nhanh bằng `.\mes.ps1 b598-price <MaterialCode>` thay vì đọc chay SP.
9. **Huyết mạch Nguyên vật liệu thay thế (Alt Material):**
   Kiosk POP đọc mã thay thế từ trường `DelegateMaterialCode` trong `STB_MaterialMaster`. Nguồn gốc phê duyệt xuất phát từ Tờ trình Groupware và ERP NEOE BOM. Nếu mã chính và mã thay thế lệch quy cách (ví dụ Tape 5mm vs Tape 10mm), Kiosk sẽ chặn không cho quét tem. Soi bằng `.\mes.ps1 nvl <Lot>` hoặc `.\gw.ps1 trace <DocCode>`.
10. **Ngăn chặn Zombie Background Process gây rú quạt CPU 100%:**
    Mọi script nền/bot phải có timeout và cờ lockfile. Chạy định kỳ `.\mes.ps1 clean` để tự động phát hiện và dọn dẹp các tiến trình PowerShell/Python ngầm bị kẹt.
11. **Giám sát Khóa Blocking & Deadlock DMV Real-time:**
    Tránh các hàm Scalar UDF (như `fn_VVT_getdatebyVendorLot_MergeCode`) trong câu lệnh UPDATE lớn vì sẽ giữ Update Lock (U-lock) quét toàn bảng triệu dòng gây deadlock với đóng gói. Soi tức thời qua `.\mes.ps1 locks`.

---

## PHẦN 4: QUY TRÌNH PHẢN XẠ 1-SHOT KHI NHẬN BÁO LỖI TỪ HIỆN TRƯỜNG

```
[OP / Kỹ sư gửi lỗi: "B530 kẹt số lượng Lot 260309..."]
                          │
                          ▼
            Chạy DUY NHẤT 1 lệnh trên Terminal:
        .\mes.ps1 diagnose "B530 kẹt số lượng 260309..."
       (Hoặc paste thẳng vào .\mes.ps1 shell)
                          │
                          ▼  (< 1.5 giây)
  ┌────────────────────────────────────────────────────────────┐
  │ 🎯 1. NGUYÊN NHÂN GỐC: [SP, Cơ chế gây lỗi]               │
  │ 📍 2. HIỆN TRẠNG DỮ LIỆU: [Lot đang kẹt ở đâu, bảng nào]  │
  │ 🛠️ 3. OP TỰ XỬ LÝ (UI): [Thao tác 1-2-3 trên giao diện]    │
  │ ⚡ 4. SQL HOTFIX CHUẨN: [BEGIN TRAN ... ROLLBACK an toàn] │
  └────────────────────────────────────────────────────────────┘
```
