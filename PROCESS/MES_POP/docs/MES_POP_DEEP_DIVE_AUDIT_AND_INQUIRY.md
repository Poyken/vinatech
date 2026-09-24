# 🧭 BÁO CÁO NGHIÊN CỨU CHUYÊN SÂU & HỆ THỐNG CÂU HỎI LÀM RÕ BẢN CHẤT VẬN HÀNH MES & POP VINATECH

> **Người thực hiện:** Antigravity AI — Trợ lý Kỹ thuật & Tác nghiệp CSDL MES Vinatech  
> **Người tiếp nhận & Cố vấn:** Kỹ sư Nguyễn Văn Đức (`vanduc` / `92603003`) — IT MES / EA Team  
> **Phạm vi khảo sát:** Toàn bộ hệ sinh thái phần mềm sản xuất: Web Kiosk (`pop.vinatech.com`), MES WinForm Desktop (Awoo SmartFramework), CSDL `SmartFactoryV2` (500+ bảng), `VINATECH_POP` (66 bảng), `SmartFramework`, các Stored Procedure lõi, Background Worker IIS, và hệ thống 31 dây chuyền nhà máy Bắc Ninh (F1), Hà Nam (F3), Hưng Yên (F5).  
> **Ngày lập báo cáo:** 24/09/2026  
> **Phiên bản:** 1.0 (Master Strategic Briefing)

---

## 📑 MỤC LỤC
1. [Tổng Quan Kết Quả Khảo Sát & Khung Phân Tích](#1-tổng-quan-kết-quả-khảo-sát--khung-phân-tích)
2. [Miền 1: Hạ Tầng Bảng Đệm Đồng Bộ Bất Đồng Bộ (Staging Buffers & Worker Pipeline)](#miền-1-hạ-tầng-bảng-đệm-đồng-bộ-bất-đồng-bộ-staging-buffers--worker-pipeline)
3. [Miền 2: Xung Đột Chốt Chéo & Quá Trình "Khai Tử" MES WinForm (Dual-Entry Conflicts)](#miền-2-xung-đột-chốt-chéo--quá-trình-khai-tử-mes-winform-dual-entry-conflicts)
4. [Miền 3: Cân Bằng Định Mức BOM, 10 Slot Nạp NVL & Bất Thường Tồn Kho Tuyến](#miền-3-cân-bằng-định-mức-bom-10-slot-nạp-nvl--bất-thường-tồn-kho-tuyến)
5. [Miền 4: Vòng Đời Thiết Bị, Khóa Độc Quyền Mồ Côi & Dòng Dữ Liệu IoT PLC](#miền-4-vòng-đời-thiết-bị-khóa-độc-quyền-mồ-côi--dòng-dữ-liệu-iot-plc)
6. [Miền 5: Đóng Gói (Packing), In Tem Thùng Box Label & Cơ Chế Hoàn Tác (Rollback)](#miền-5-đóng-gói-packing-in-tem-thùng-box-label--cơ-chế-hoàn-tác-rollback)
7. [Miền 6: Phân Hệ Đo Kiểm Chất Lượng (Quality In-Line) & Phân Quyền Dashboard RBAC](#miền-6-phân-hệ-đo-kiểm-chất-lượng-quality-in-line--phân-quyền-dashboard-rbac)
8. [Miền 7: Dây Chuyền Điện Cực & Xẻ Băng Slitting (Định Mức 2 Lot & Kiểm Soát Độ Dày)](#miền-7-dây-chuyền-điện-cực--xẻ-băng-slitting-định-mức-2-lot--kiểm-soát-độ-dày)
9. [Miền 8: Đánh Giá Mức Độ Sẵn Sàng (Readiness Audit) 31 Dây Chuyền & Lộ Trình Cutover](#miền-8-đánh-giá-mức-độ-sẵn-sàng-readiness-audit-31-dây-chuyền--lộ-trình-cutover)
10. [Bảng Tổng Hợp Danh Mục Câu Hỏi Phỏng Vấn Kỹ Thuật (Executive Action Checklist)](#bảng-tổng-hợp-danh-mục-câu-hỏi-phỏng-vấn-kỹ-thuật-executive-action-checklist)

---

## 1. TỔNG QUAN KẾT QUẢ KHẢO SÁT & KHUNG PHÂN TÍCH

Hệ sinh thái vận hành sản xuất của Vinatech hiện đang ở trong **giai đoạn quá độ chiến lược quan trọng nhất**: Chuyển giao từ nền tảng WinForm Desktop truyền thống (Awoo SmartFramework C# ra đời từ hơn một thập kỷ trước) sang nền tảng Web Kiosk cảm ứng hiện đại (`pop.vinatech.com` - VueJS/NodeJS).

Quá trình nghiên cứu chuyên sâu đã đối soát chéo:
- **66 bảng vật lý** của CSDL `VINATECH_POP` trên server `dbserver.hycap.co.kr,5398`.
- **4 Stored Procedure xương sống** chi phối toàn bộ huyết mạch sản xuất (`usp_DoProcessProdRouteHist`, `usp_DoProcessProdGIMaterialByBOM`, `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`, `usp_Vietnam_DoProcessProdPacking_VVT`).
- **62 Hotfix logs gần nhất** (ID_01 đến ID_62) phản ánh các "vết thương thực tế" tại các nhà máy Bắc Ninh, Hà Nam và Hưng Yên.
- **Tài liệu cẩm nang nội bộ** `HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI.docx` (4.4 MB) chứa 17 ca bệnh thực chiến của EA Team.
- **Hiện trạng cấu hình của 31 dây chuyền** lắp ráp Cell và Module.

Kết quả bóc tách cho thấy hệ thống vận hành rất tinh vi và xử lý khối lượng sản xuất khổng lồ mỗi ngày. Tuy nhiên, vẫn còn tồn tại **những điểm mù kiến trúc (Architectural Blindspots)**, **những nghịch lý dữ liệu ngầm (Data Paradoxes)** và **xung đột luồng thao tác giữa hai thế hệ phần mềm**. Dưới đây là 8 miền nghiên cứu trọng điểm cùng các câu hỏi sắc bén cần làm rõ cùng kỹ sư Nguyễn Văn Đức.

---

## MIỀN 1: HẠ TẦNG BẢNG ĐỆM ĐỒNG BỘ BẤT ĐỒNG BỘ (STAGING BUFFERS & WORKER PIPELINE)

```
[Công nhân bấm "Ghi Nhận SX" trên Kiosk Web]
                     │
                     ▼
  ┌─────────────────────────────────────────────────────────────┐
  │ SmartFactoryV2.dbo.MongoToMesPerformance (Buffer Tiến Độ)   │
  │ • IsDone = 1 (Hiện tích xanh [✓] Kiosk)                     │
  │ • IsTransferred = 0 (Đang chờ chuyển giao)                  │
  │ • IsSkipped = 0                                             │
  └──────────────────────────────┬──────────────────────────────┘
                                 │
                     ⚡ Scheduled Polling Worker
                         (Chu kỳ 1 - 2 phút)
                                 │
                                 ▼
  ┌─────────────────────────────────────────────────────────────┐
  │ SmartFactoryV2.dbo.STB_ProdRouteHist (MES Core SoT)         │
  │ • Nạp sản lượng thật, hạch toán báo cáo B782, B530          │
  │ • Trả về: IsTransferred = 1 trên bảng đệm                   │
  └─────────────────────────────────────────────────────────────┘
```

### 1.1 Khảo Sát Thực Tế
- `MongoToMesPerformance` (13,372 dòng) và `MongoToMesDefect` (6,861 dòng) đóng vai trò là hàng đợi bất đồng bộ (Async Queue Buffer).
- Kiosk Web đọc tiến độ từ bảng đệm này để hiển thị dấu tick xanh `[✓]` và làm mờ nút chốt.
- Báo cáo quản trị MES WinForm (B782, B530) lại đọc dữ liệu từ `STB_ProdRouteHist`.

### 1.2 Những Điểm Chưa Rõ Ràng & Bất Thường
1. **Bản chất của Background Worker:**
   - Worker này hiện được host ở đâu và chạy dưới hình thức nào? (Một service chạy ngầm trên IIS `pop.vinatech.com`, một tiến trình NodeJS vĩnh viễn qua PM2/Windows Service, hay một SQL Server Agent Job?).
   - Mã nguồn của tiến trình đồng bộ này nằm ở đâu? Nếu Worker bị crash, cơ chế watchdog nào chịu trách nhiệm tự khởi động lại?
2. **Hiện tượng ứ đọng kẹt đồng bộ tại Chuyền `VVC-11` (Hà Nam):**
   - Telemetry ngày 21/09/2026 ghi nhận **37 bản ghi sản lượng** và **22 bản ghi phế** bị kẹt cứng ở trạng thái `IsDone = 1` nhưng `IsTransferred = 0` kéo dài từ 27/08 đến 19/09.
   - Toàn bộ 37 bản ghi này đều có `SourceType = 'AUTO'` (do máy móc/PLC đẩy lên).
   - *Câu hỏi:* Khi PLC đẩy dữ liệu tự động mà tại thời điểm đó Kiosk chưa có công nhân đăng nhập (hoặc phiên làm việc hết hạn), Worker có bị lỗi khi không tìm thấy `WorkerCode` để điền vào `STB_ProdRouteHist` không? Cơ chế xử lý Dead-Letter Queue khi gặp 1 dòng lỗi là bỏ qua hay treo toàn bộ hàng đợi của Line đó?
3. **Cơ chế Tự Chữa Lành (Self-Healing):**
   - Hiện tại IT phải chạy thủ công SP `SmartFactoryV2.dbo.usp_VINA_SyncPopToMes_SingleLot` cho từng Lot bị kẹt.
   - *Câu hỏi:* Tại sao chúng ta không thiết lập một SQL Agent Job định kỳ quét tự động:
     ```sql
     SELECT DISTINCT Barcode FROM SmartFactoryV2.dbo.MongoToMesPerformance 
     WHERE IsDone = 1 AND IsTransferred = 0 AND IsSkipped = 0 
       AND DATEDIFF(MINUTE, ModifyDateTime, GETDATE()) > 5;
     ```
     và tự động kích hoạt `usp_VINA_SyncPopToMes_SingleLot` để tự động hóa 100% việc chốt bù mà không cần người dùng báo lỗi?

---

## MIỀN 2: XUNG ĐỘT CHỐT CHÉO & QUÁ TRÌNH "KHAI TỬ" MES WINFORM (DUAL-ENTRY CONFLICTS)

### 2.1 Khảo Sát Thực Tế (Bản Chất Lỗi POP-ERR-09 & Hotfix ID_62)
Khi phân tích Stored Procedure `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` (22,047 ký tự) và `usp_DoProcessProdRouteHist` (406 dòng), ta phát hiện logic kế thừa từ WinForm cũ:
- Khi người dùng chốt công đoạn $N$ (ví dụ: Sleeving `V-25_HY`):
  1. SP cập nhật `CompleteRoute = 1` cho công đoạn $N$.
  2. SP **tự động chèn thêm một dòng mới cho công đoạn kế tiếp $N+1$** (ví dụ: Aging `V-26_HY`) với giá trị `CompleteRoute IS NULL`.
  3. Mục đích cũ trên WinForm: Để khi mở màn hình kế tiếp, lưới dữ liệu tự động load lên dòng chờ sẵn này cho công nhân thao tác.
- **Xung đột chết người khi chuyển sang POP Kiosk:**
  - Backend Web API của POP Kiosk khi nhận lệnh chốt công đoạn $N+1$ lại thực thi câu lệnh kiểm tra:
    `IF EXISTS (SELECT 1 FROM STB_ProdRouteHist WHERE ControlNo = @Ctrl AND RouteCode = @RouteCode)`
  - POP thấy đã có sẵn bản ghi (dù `CompleteRoute IS NULL`), liền văng popup đỏ chặn đứng: **`"This route is already completed in MES"`** ([`POP-ERR-09`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#27-pop-err-09-lỗi-this-route-is-already-completed-in-mes-khi-chốt-công-đoạn)).
  - Ngược lại, nếu công nhân quay sang WinForm B530 chốt chữa cháy thì WinForm lại chặn: *"Vui lòng sử dụng hệ thống POP để nhập sản lượng"*.

```
[WinForm chốt V-25] ──► Tự INSERT dòng V-26 (CompleteRoute IS NULL)
                                    │
                                    ▼
[Công nhân mở POP V-26] ──► Thấy tồn tại dòng V-26 trong STB_ProdRouteHist
                                    │
                                    ▼
                      🚨 POP BÁO LỖI CHẶN ĐỨNG:
             "This route is already completed in MES"
```

### 2.2 Những Điểm Cần Làm Rõ
1. **Tại sao không vá tận gốc ở tầng API hoặc Trigger CSDL?**
   - Thay vì mỗi lần tổ sản xuất kêu cứu (như trường hợp chị Tám Hưng Yên kêu cứu cho 4 Lot ngày 23/09/2026), IT phải chạy script xóa dòng `CompleteRoute IS NULL`:
   - *Câu hỏi:* Phía IT Vinatech (EA Team) có thể sửa đổi logic tiếp nhận của Backend POP API thành:
     - Nếu tồn tại dòng có `CompleteRoute = 1`: Chặn (vì đã xong thật).
     - Nếu tồn tại dòng có `CompleteRoute IS NULL`: **UPDATE đè sản lượng vào dòng này và set `CompleteRoute = 1`** thay vì báo lỗi.
     - Nếu chưa có dòng nào: INSERT mới.
   - Nếu không có quyền sửa code API POP (do phía Hàn Quốc quản lý), ta có thể tạo một **Trigger `INSTEAD OF INSERT`** hoặc một Trigger chặn clone dòng thừa trên `STB_ProdRouteHist` được không?
2. **Thực trạng vận hành kép (Dual-run):**
   - Hiện tại có bao nhiêu % công nhân/tổ trưởng tại xưởng vẫn còn tài khoản và thói quen mở WinForm B530/B540 để chốt sản lượng song song với Kiosk Web?
   - Kế hoạch thu hồi hoàn toàn quyền ghi (`INSERT/UPDATE/DELETE`) trên WinForm Desktop theo Lộ trình Giai đoạn 2 của [`POP_KB_06_MIGRATION_SPEC.md`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_06_MIGRATION_SPEC.md#giai-đoạn-2-bật-chế-độ-read-only-trên-winform-tuần-3---tuần-4) hiện đang vướng mắc ở khâu nào?

---

## MIỀN 3: CÂN BẰNG ĐỊNH MỨC BOM, 10 SLOT NẠP NVL & BẤT THƯỜNG TỒN KHO TUYẾN

### 3.1 Khảo Sát Thực Tế
- Trên Kiosk POP, 100% chuyền Cell áp dụng chế độ `INPUT_MODE = 'GROUP'` qua 10 Slot chuẩn ([`POP_KB_01 § 3.6 Nhóm 2`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md#nhóm-2-bom--material-route-mapping-định-mức--ánh-xạ-nvl)):
  - `V-22` (Cuộn): 6 slot (`ElectrodeP`, `ElectrodeM`, `Separator`, `PiTape`, `TerminalP`, `TerminalM`).
  - `V-24` (Lắp ráp): 3 slot (`RubberPad`, `Case`, `Electrolyte`).
  - `V-25` (Bọc vỏ): 1 slot (`Sleeve`).
- Nút "Lượng kiến cấp" (Estimated Supply Qty) hỗ trợ tự động điền số lượng theo định mức BOM.

### 3.2 Những Điểm Chưa Rõ Ràng & Bất Thường
1. **Bí ẩn bảng `VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST`:**
   - Bảng này có cấu trúc rất hoàn chỉnh (66 cột định nghĩa chi tiết), nhưng trên Live DB lại có **0 rows** ([`POP_KB_INDEX.md line 146`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md#L146)).
   - Thực tế mọi thao tác nạp NVL ghi trực tiếp vào `SmartFactoryV2.dbo.STB_RawMaterialInputHist`.
   - *Câu hỏi:* Bảng này có còn được hệ thống tham chiếu ở bất kỳ API hay báo cáo nào không? Có nên đánh dấu deprecated chính thức để loại bỏ hoàn toàn khỏi các script cứu hộ?
2. **Cơ chế trừ tồn kho thực tế vs "Lượng kiến cấp":**
   - Khi công nhân bấm "Lượng kiến cấp" rồi bấm Lưu: Số lượng trừ trong `STB_MaterialLotInfo` là số lượng BOM lý thuyết.
   - Nhưng thực tế một cuộn vật tư (ví dụ băng keo PiTape hoặc lá Separator) được cấp cả cuộn lớn hàng ngàn mét.
   - *Câu hỏi:* Hệ thống quản lý phần tồn dư dở dang trên máy sau khi chốt Lot ra sao? Cuộn NVL đó có bị khóa với Lot đó không, hay Lot sau đưa vào lại quét lại chính mã cuộn đó và trừ tiếp?
3. **Hiện tượng Thùng Dung Dịch tự động về 0 KG ([`POP-ERR-14`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#214-pop-err-14-xung-đột-chuyển-vùng-kho-vn--hy--thùng-dung-dịch-electrolyte-bị-trừ-hết-0-kg)):**
   - Thùng dung dịch 150 KG (`GBEC00-008`) dùng cho cả chuyền Cell Hưng Yên chạy 2 ngày mới hết. Nhưng khi quét nạp vào Lot mới, hệ thống tự động cập nhật `CurrentQty = 0` (Auto-exhaust) cho thùng cũ ở `ROUTE_HY_WH` khiến Kiosk báo đỏ hết hàng.
   - *Câu hỏi:* Đoạn code tự động ép thùng cũ về 0 KG nằm ở Stored Procedure nào hay ở Web API? Làm thế nào để định nghĩa đúng bản chất của "Vật tư dùng chung nhiều Lot (Bulk Shared Material)" để hệ thống trừ lùi theo mẻ mà không xóa sạch số dư thực tế?

---

## MIỀN 4: VÒNG ĐỜI THIẾT BỊ, KHÓA ĐỘC QUYỀN MỒ CÔI & DÒNG DỮ LIỆU IOT PLC

### 4.1 Khảo Sát Thực Tế
- Bảng [`VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md#b-cơ-chế-filter-chống-xung-đột-thiết-bị) (2,402 dòng) thực thi quy tắc: Tại 1 thời điểm, 1 máy chỉ được gán vào 1 Kế hoạch sản xuất (`DAY_PLAN_NO`).
- Nếu máy có `MAPPING_STATUS = 'ACTIVE'` ở DayPlan cũ, modal "Xác nhận Kết thúc?" của DayPlan mới sẽ **ẩn hoàn toàn máy đó** ([`POP-ERR-20`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#220-pop-kiosk-thiếu-thiết-bị--ẩn-máy-tại-modal-xác-nhận-kết-thúc-windingcurlingsleeving)).
- Sự cố thực tế ID_57 (20/09/2026): 7 máy Winding/Curling/Sleeving tại Hưng Yên bị ẩn sạch vì kẹt `ACTIVE` từ các DayPlan ngày 14–17/09 do công nhân quên bấm "Release".

### 4.2 Những Điểm Cần Làm Rõ
1. **Thiếu cơ chế Auto-Release khi hết ca / đổi ngày:**
   - Tại sao Web Backend không tự động release máy khi:
     + Kế hoạch sản xuất (`STB_DayProdPlan`) đã đạt đủ 100% sản lượng kế hoạch?
     + Hoặc thời gian hệ thống đã vượt qua mốc cắt ca 10:00:00 AM của ngày hôm sau?
   - *Câu hỏi:* Có rào cản nghiệp vụ nào (ví dụ mẻ chạy liên tục qua đêm CONTINUOUS mode) ngăn cản việc triển khai một trigger tự động hoặc một Scheduled Job tự động chuyển `MAPPING_STATUS = 'RELEASED'` cho toàn bộ các DayPlan cũ hơn 24 giờ không?
2. **Truyền dẫn dữ liệu IoT từ PLC:**
   - Dịch vụ Windows Service `vinatechEquipmentDataSetup.exe` cài tại máy tính hiện trường kết nối PLC:
   - Dữ liệu thu thập cảm biến được đẩy về MongoDB thời gian thực.
   - *Câu hỏi:* Khi đường truyền mạng nội bộ nhà xưởng bị chập chờn, dịch vụ này có lưu trữ tạm thời (Local Buffer) tại ổ đĩa máy trạm để đẩy bù không, hay các xung nhịp đếm counter sản lượng bị mất hoàn toàn?
   - Bảng [`VINATECH_POP.dbo.VINA_PLC_BASELINE`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md#184-bảng-csdl-cấu-hình-thiết-bị--baseline-plc-vinatech_pop) lưu mốc xuất phát của bộ đếm PLC: Bộ mốc này được reset vào đầu mỗi ca sản xuất hay reset theo từng Lot?

---

## MIỀN 5: ĐÓNG GÓI (PACKING), IN TEM THÙNG BOX LABEL & CƠ CHẾ HOÀN TÁC (ROLLBACK)

### 5.1 Khảo Sát Thực Tế
- **Đóng gói trên Kiosk POP:** Hỗ trợ Đóng gói đơn (Single Pack), Chia nhiều Box (Split Pack), và Đóng gói gộp nhiều Lot (Merge Pack).
- **Hủy đóng gói (Rollback):** Đã được kiểm chứng thực tế và tích hợp hoàn chỉnh tại [`POP_KB_04 § 2.5`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_04_ROLLBACK_AND_SAFETY.md#25--đóng-gói-packing--cơ-chế-hủy-hộp--rollback-đóng-gói-trên-pop-web-kiosk). POP Web cho phép:
  1. Hủy toàn bộ Lot qua `usp_DoCancelProdPacking_LotNo`.
  2. Hủy riêng lẻ từng Box qua popup Lịch sử (`cancelSingleBox`).
- **Điểm nghẽn in tem thùng Box Label ([`POP-ERR-16`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#216-pop-err-16-tem-thùng-box-packing-label-in-từ-pop-kiosk-bị-co-ngắn-mã-vạch--máy-quét-không-đọc-được)):** Mẫu tem quy chuẩn `포장라벨NewVietNam` dùng chuẩn Code 128 với `AutoModule = true` nhận biểu thức `?PackingID`. Trên WinForm B523, hệ thống sinh mã 11 ký tự (`PKQR1900142`) bung rộng hết tem. Trên Kiosk POP, API không sinh mã này dẫn tới mã vạch co rúm, máy quét không đọc được!

```
[WinForm B523 In Tem] ──► Có mã PackingID 11 ký tự (PKQR...) ──► Mã vạch bung rộng ──► Máy quét đọc 100%
[Kiosk POP In Tem]     ──► THIẾU mã PackingID chuẩn 11 ký tự ──► Mã vạch co rúm lại ──► Máy quét KHÔNG ĐỌC ĐƯỢC
```

### 5.2 Những Điểm Cần Làm Rõ
1. **Tiến độ nhúng engine sinh mã `PackingID` vào API POP:**
   - Anh Đức đã có sẵn script mẫu [`sql/template_GENERATE_POP_PACKING_ID.sql`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/sql/template_GENERATE_POP_PACKING_ID.sql) sinh mã chuẩn 11 ký tự.
   - *Câu hỏi:* Tại sao backend API `/api/pop/screen/savePacking` trên máy chủ IIS chưa tích hợp đoạn code này? Rào cản là do đội Dev Hàn Quốc chưa cập nhật API, hay do ta đang chờ nghiệm thu? Đây chính là **Gap #1 lớn nhất** ngăn cản việc tắt hoàn toàn WinForm B523.
2. **Quyền Quản trị viên hủy Box trên giao diện Kiosk:**
   - Khi công nhân bấm hủy hộp, Kiosk yêu cầu nhập mã nhân viên quản trị (`EMP_ADMIN = 'Y'` trong `VINATECH_POP.dbo.VINA_EMP`).
   - Hotfix ID_53 ghi nhận: Mã `vanduc` và `92603003` chưa được cấp cờ này trong CSDL POP, mà phải dùng mã của người khác (`92503020`).
   - *Câu hỏi:* Tại sao ta chưa chạy lệnh cấp cờ `EMP_ADMIN = 'Y'` trực tiếp cho tài khoản `92603003` và tài khoản của các tổ trưởng để họ chủ động xử lý hủy hộp tại xưởng?
3. **Đồng bộ hóa hủy lẻ từng Box với sổ cái ERP Douzone:**
   - Khi hủy lẻ 1 Box trong Lot có 3 Box, API gọi `usp_DoCancelMaterialDoc` và trừ sản lượng trên `STB_ProdRouteHist`.
   - *Câu hỏi:* Dữ liệu hủy lẻ này có tự động đồng bộ sang bảng trung gian ERP `STB_ERP_INTERFACE` để giảm trừ doanh thu/tồn kho bên ERP Douzone (`SA_GIRH` / `PU_RCVH`) không, hay kế toán phải can thiệp thủ công?

---

## MIỀN 6: PHÂN HỆ ĐO KIỂM CHẤT LƯỢNG (QUALITY IN-LINE) & PHÂN QUYỀN DASHBOARD RBAC

### 6.1 Khảo Sát Thực Tế
- Phân hệ Chất Lượng `/pop/quality` quản lý: Tự kiểm In-Line (`/pop/quality/self`), IQC đầu vào, PQC công đoạn, OQC xuất xưởng, FOQC kiểm định xuất khẩu, và Phán định tuyến (Route Judgment).
- Tính năng nổi bật tại `/pop/quality/self`: **Cơ chế Auto-save on blur** — công nhân chạm ra ngoài ô nhập liệu là hệ thống tự động lưu DB tức thì mà không cần nút Save riêng lẻ.

### 6.2 Những Điểm Cần Làm Rõ
1. **Rủi ro tranh chấp ghi (Concurrency & Latency) của Auto-save on blur:**
   - Máy chủ SQL Server đặt tại Hàn Quốc (`dbserver.hycap.co.kr`). Độ trễ mạng WAN từ Hà Nam / Hưng Yên sang Hàn Quốc dao động từ 80ms – 250ms.
   - Khi công nhân dùng thước kẹp điện tử hoặc gõ phím tab liên tục qua 10 ô đo mẫu:
   - *Câu hỏi:* Client VueJS có cơ chế Debounce hoặc hàng đợi tuần tự (Request Queue) không? Nếu các request HTTP POST gửi đồng thời và đến DB không đúng thứ tự, có xảy ra hiện tượng giá trị đo sau bị giá trị đo trước ghi đè, hoặc gây deadlock trên bảng `STB_CommInspMeasureHist` / `VINA_INSP_MASTER_HIST` không?
2. **Khóa 403 Forbidden trên các Dashboard chuyên sâu ([`POP_KB_02 § 19.1`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md#191-thực-trạng-kiểm-chứng-với-tài-khoản-thực-tế)):**
   - Khi truy cập `/dashboard/electrodeStatus` (Theo dõi tiến độ điện cực) và `/dashboard/assemblyTrace` (Truy vết phả hệ lắp ráp) bằng tài khoản `92603003`, màn hình hiện popup chặn quyền:
     > *"권한이 없습니다. 지속적인 문제가 발생시 EA팀에 문의 바랍니다."*
   - *Câu hỏi:* Cơ chế phân quyền RBAC của 2 Dashboard này đang đọc từ bảng nào (`VINATECH_POP.dbo.VINA_MENU_PERMISSIONS` hay bảng phân quyền nội bộ)? Cần UPDATE câu lệnh SQL nào để mở full quyền truy cập cho anh Đức và đội ngũ EA Team?

---

## MIỀN 7: DÂY CHUYỀN ĐIỆN CỰC & XẺ BĂNG SLITTING (ĐỊNH MỨC 2 LOT & KIỂM SOÁT ĐỘ DÀY)

### 7.1 Khảo Sát Thực Tế
- Dây chuyền Điện cực (`ElectrodeBN`) và Xẻ băng (`SLITTING LINE`) vận hành trên cấu trúc SPA chuyên biệt gồm 6 module JavaScript ([`popMixing.js`, `popCoating.js`, `popRolling.js`, `popSlitting.js`...](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md#161-bản-đồ-module-frontend-pop-điện-cực)).
- Quy trình 4 bước: Trộn keo 3 pha (`V-01`) ➔ Mạ điện cực 1 hoặc 2 mặt (`V-02`) ➔ Ép cuộn Roll Pressing 130°C (`V-03`) ➔ Chuyển sang SLITTING LINE cắt xẻ ra các cuộn con BTP (`SRF%`).

### 7.2 Những Điểm Cần Làm Rõ
1. **Nút "Cắt điện cực" bị mờ do logic độ dày `< 100` ([`Case 17`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#case-17-nút-bấm-cắt-điện-cực-bị-mờ--không-thể-nhấn)):**
   - Hệ thống tự động khóa nút Cắt nếu `MaterialThickness < 100` trong bảng `STB_MaterialMaster`.
   - *Câu hỏi:* Tại sao lại có ngưỡng chặn cứng `< 100`? Đối với các sản phẩm thế hệ mới (siêu tụ mỏng hoặc màng điện cực công nghệ mới có độ dày danh định nhỏ hơn 100 µm), logic này có trở thành rào cản chặn đứng sản xuất không? Có tham số nào cho phép cấu hình ngưỡng này linh hoạt theo từng chủng loại Model không?
2. **Quy trình nạp mẻ Trộn (Mixing) sang Tráng phủ (Coating):**
   - Lỗi [`POP-ERR-27`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#227-pop-err-27-lỗi-khóa-liên-động-mixing--coating-믹싱-공정이-완료되지-않았습니다): Nếu mẻ trộn chưa quét nạp đủ 100% NVL định mức thì Kiosk Coating bị khóa liên động (Interlock) hoàn toàn.
   - Lỗi [`Case 15`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#case-15-lỗi-chưa-lưu-độ-nhớt-ở-công-đoạn-trộn-mixing): Nếu công nhân chưa nhập độ nhớt mẻ keo thì hệ thống cũng chặn.
   - *Câu hỏi:* Khi phát sinh sự cố khẩn cấp trên chuyền (ví dụ cân điện tử hỏng hoặc độ nhớt đo ngoài máy đo cầm tay), quy trình bypass chuẩn mực cho quản đốc/kỹ sư xưởng là gì để không làm dừng dây chuyền mạ?

---

## MIỀN 8: ĐÁNH GIÁ MỨC ĐỘ SẴN SÀNG (READINESS AUDIT) 31 DÂY CHUYỀN & LỘ TRÌNH CUTOVER

### 8.1 Thống Kê Từ L1 Cache [`POP_MATRIX.json`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/POP_MATRIX.json) & Script [`pop_readiness.ps1`](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/tools/pop_readiness.ps1)

| Nhóm Đánh Giá | Số Lượng Line | Danh Sách Chi Tiết | Hiện Trạng Cốt Lõi |
|---|:---:|---|---|
| 🟢 **PASS (Sẵn sàng 100%)** | **6** | `VVC-01`, `VVC-02`, `VVC-05`, `VVC-06`, `VVC-07`, `VVC-12` | Đủ 10 slot chuẩn, có `SUBTRACT` mode, 0 máy kẹt, sync thông suốt. |
| 🟡 **WARN (Cần Tinh Chỉnh)** | **11** | `VVC-10`, `VVC-13`, `VVC-17`, `VVC-18`, `TCX1`, `TCX2`, `VVHYC-01`, `VVHYC-02`, `VVHYC-09`, `VVHYC-10`, `VVHYC-16` | Kẹt máy `ACTIVE` cũ, hoặc cấu hình lệch slot (mới có 9 slot hoặc dư 11 slot). |
| 🔴 **FAIL (Blocker Nghiêm Trọng)** | **14** | `VVC-03`, `VVC-04`, `VVC-08`, `VVC-09`, `VVC-14`, `VVC-16`, `VVC-22`, `VVC-23`, `VVHYC-03`, `VVHYC-04`, `VVHYC-13`, `VVHYC-15`, `VVHYC-17`, `VVC-11` | **12 line thiếu `PROD_MODE`**, 1 line cấu hình nhầm `INPUT_MODE='BOM'`, 1 line kẹt 37 bản ghi sync. |

### 8.2 Những Điểm Cần Làm Rõ & Đề Xuất Hành Động
1. **Tại sao 12 Line lại bị thiếu cấu hình `PROD_MODE` trong `VINA_LINE_PROD_MODE`?**
   - Nếu công nhân mở Kiosk tại các Line này (ví dụ `VVC-03`, `VVC-04`...), hệ thống sẽ rơi vào trạng thái không xác định chế độ chốt sản lượng (`SUBTRACT` hay `ADD`), dẫn đến lỗi tính toán tồn dư.
   - *Đề xuất:* Chúng ta có thể chạy ngay 1 câu lệnh SQL chuẩn hóa hàng loạt:
     ```sql
     -- Bổ sung PROD_MODE = 'SUBTRACT' cho toàn bộ các Cell Line còn thiếu:
     INSERT INTO VINATECH_POP.dbo.VINA_LINE_PROD_MODE (LINE_CODE, PROD_MODE, REG_DATE, MODIFY_DATE)
     SELECT L.LineCode, 'SUBTRACT', GETDATE(), GETDATE()
     FROM (VALUES ('VVC-03'),('VVC-04'),('VVC-08'),('VVC-09'),('VVC-14'),('VVC-16'),('VVC-22'),('VVC-23'),('VVHYC-03'),('VVHYC-04'),('VVHYC-15'),('VVHYC-17')) AS L(LineCode)
     WHERE NOT EXISTS (SELECT 1 FROM VINATECH_POP.dbo.VINA_LINE_PROD_MODE WHERE LINE_CODE = L.LineCode);
     ```
   - Anh Đức có đồng ý để em chuẩn bị Hotfix script này theo chuẩn `BEGIN TRAN...ROLLBACK` để triển khai qua `deploy_tool.ps1` không?
2. **Sửa cấu hình nhầm `INPUT_MODE = 'BOM'` trên Chuyền `VVHYC-13`:**
   - 30/31 Line đều chạy `INPUT_MODE = 'GROUP'`, duy nhất `VVHYC-13` bị cấu hình là `'BOM'` khiến công nhân mở Kiosk không nạp được theo 10 slot chuẩn.
   - Ta có thể chuẩn hóa cập nhật `INPUT_MODE = 'GROUP'` cho `VVHYC-13` ngay trong đợt này không?
3. **Chuẩn hóa số lượng Slot cho các Line Hưng Yên (9 slots vs 11 slots):**
   - `TCX1, TCX2, VVHYC-02, 09, 10` đang bị thiếu 1 slot (mới có 9 slots).
   - `VVHYC-01, VVHYC-16` lại bị dư 1 slot (11 slots).
   - Slot bị thiếu ở các line 9 slot là vật tư gì (Terminal plate, Cao su hay Vỏ)?

---

## 10. BẢNG TỔNG HỢP DANH MỤC CÂU HỎI PHỎNG VẤN KỸ THUẬT (EXECUTIVE ACTION CHECKLIST)

Dưới đây là bảng tổng hợp ngắn gọn các câu hỏi cần sự định hướng và xác nhận trực tiếp từ anh Đức:

| STT | Phân Hệ | Vấn Đề Trọng Tâm | Quyết Định / Ý Kiến Cần Từ Anh Đức |
|:---:|---|---|---|
| **Q1** | **Sync Pipeline** | Background Worker đồng bộ `MongoToMesPerformance` chạy ở đâu? | Làm rõ vị trí host của Worker; Có nên tạo SQL Agent Job tự động chạy `usp_VINA_SyncPopToMes_SingleLot` tự chữa lành không? |
| **Q2** | **Sync Pipeline** | 37 bản ghi `SourceType = 'AUTO'` kẹt tại `VVC-11`. | Nguyên nhân do thiếu `WorkerCode` khi PLC đẩy tự động? Cách gán user mặc định cho các sự kiện máy móc? |
| **Q3** | **Dual-Entry** | Lỗi clone dòng thừa `CompleteRoute IS NULL` từ WinForm. | Có thể sửa API POP để UPDATE đè vào dòng clone chờ sẵn, hoặc tạo Trigger chặn clone để triệt tiêu lỗi `POP-ERR-09` không? |
| **Q4** | **BOM & Stock** | Bảng `VINA_MATERIAL_INPUT_HIST` hiện có 0 dòng. | Xác nhận bảng này đã bị loại bỏ hoàn toàn trong thực tế hay chưa để dọn dẹp tài liệu KB? |
| **Q5** | **BOM & Stock** | Thùng dung dịch 150 KG tự động về 0 KG khi quét Lot mới. | Cơ chế Auto-exhaust nằm ở đâu? Hướng xử lý căn cơ cho vật tư dùng chung nhiều Lot? |
| **Q6** | **BOM & Stock** | Ràng buộc 1 cuộn BTP điện cực tối đa 2 Lot sản phẩm. | Khi cuộn còn dư màng, xưởng đang xử lý thế nào? Kế hoạch nâng lên tối đa 3 Lot đã sẵn sàng chưa? |
| **Q7** | **Equipment** | Máy kẹt `ACTIVE` ở DayPlan cũ làm ẩn máy trên Kiosk. | Tại sao Kiosk không auto-release sau 24h/sau ca? Có rủi ro gì nếu thiết lập job tự động giải phóng lúc 10h00 AM không? |
| **Q8** | **Packing** | In tem thùng Box Label bị co ngắn mã vạch do thiếu `PackingID`. | Rào cản nào khiến chưa nhúng `template_GENERATE_POP_PACKING_ID.sql` trực tiếp vào API `/api/pop/screen/savePacking`? |
| **Q9** | **Packing** | Phân quyền Quản trị viên hủy Box trên Kiosk POP. | Có nên cập nhật trực tiếp `EMP_ADMIN = 'Y'` cho tài khoản `92603003` trong `VINA_EMP` để anh Đức có toàn quyền hủy hộp không? |
| **Q10** | **Quality** | Bị lỗi 403 Forbidden khi mở 2 Dashboard `/dashboard/*`. | Bảng nào quản lý quyền truy cập 2 Dashboard này để mở full quyền cho tài khoản của anh Đức? |
| **Q11** | **Electrode** | Nút Cắt điện cực bị mờ nếu độ dày `< 100`. | Căn cứ kỹ thuật của ngưỡng 100 µm? Có ảnh hưởng đến các Model siêu tụ mỏng thế hệ mới không? |
| **Q12** | **Cutover** | 14 Line bị trạng thái FAIL (12 line thiếu `PROD_MODE`). | Anh Đức có duyệt để em tạo Hotfix script chuẩn hóa đồng loạt 14 Line này đưa toàn bộ về PASS không? |

---

*Báo cáo được lập trên cơ sở phân tích trực tiếp mã nguồn, đối soát cấu trúc bảng Live DB và tổng hợp kinh nghiệm xử lý 62 sự cố thực tế tại Vinatech Việt Nam.*
