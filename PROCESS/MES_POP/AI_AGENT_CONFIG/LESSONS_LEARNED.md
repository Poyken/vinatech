# 📘 LESSONS LEARNED & AGENT OPERATIONAL OPTIMIZATION PROTOCOL

> **Mục đích:** Ghi nhận các điểm vận hành kém hiệu quả trong quá khứ và quy chuẩn hóa các bước phản xạ tự động để đạt hiệu năng tối đa.
> **Cập nhật:** 2026-08-28 (Audit toàn diện các phiên làm việc kéo dài & kém hiệu quả)

---

## 1. BÓC TÁCH CHI TIẾT CÁC PHIÊN LÀM VIỆC KÉM HIỆU QUẢ TRONG QUÁ KHỨ

| Phiên (CID) | Vấn đề phát sinh | Nguyên nhân gốc rễ (Root Cause) | Giải pháp bắt buộc |
|:---|:---|:---|:---|
| **`41d642a6`** (74 steps) | **Vội vàng đưa script xóa sản lượng sai số dòng** (User phản ánh: *"Tôi tưởng chỉ xóa 1 bản ghi thôi sao lại xóa 2? Query thử chưa mà đưa cho tôi script?"*) | AI không đối chiếu quy trình giảm/hủy sản lượng trong SoT (`KB_04_02` / `KB_03_02`), không tra cứu quan hệ giữa `STB_ProdRouteHist`, `STB_ProdRouteSummary` và `STB_ProductionOrderInfo`. | **BẮT BUỘC:** Mọi thao tác hủy/sửa sản lượng phải tra cứu kịch bản hủy chuẩn trong KB trước, chạy `SELECT` kiểm chứng đúng số lượng dòng trước khi xuất script fix. |
| **`f74ddf57`** (128 steps, 44 SELECTs) | **Chạy 44 câu SELECT thăm dò mò mẫm** khi nhận lệnh "check" ngắn gọn từ User. | AI không định vị được SP/Màn hình cần kiểm tra từ tài liệu KB, chạy hàng chục câu SELECT rời rạc để tìm cấu trúc bảng. | **BẮT BUỘC:** Chạy `.\find_kb.ps1` hoặc `.\mes.ps1 health` thay vì SELECT tự do. |
| **`6866bde1`** (115 steps, 35 SELECTs) | **Mò Lot từng bảng lặp đi lặp lại** cho danh sách mã `VVQQ023R072703...` | AI query từng bảng riêng lẻ (`MaterialLotInfo` ➔ `ProdRouteHist` ➔ `SetInfo`) cho từng mã, mỗi câu mất 3s qua mạng WAN. | **BẮT BUỘC:** Dùng ngay `.\mes.ps1 trace "<Lot>"` (Golden Query 360°) để quét sạch 4 bảng trong 1 lần gọi duy nhất (tiết kiệm 95% thời gian). |
| **`6fb1bcfa`** (365 steps) | **Đọc tài liệu quá rộng gây loãng context** (User phản ánh: *"Tôi cảm thấy bạn đọc tài liệu quá sơ sài/cẩu thả hoặc do quá nhiều chi tiết..."*) | AI nạp cả file markdown >100KB vào context, dẫn đến hiện tượng "ngợp thông tin", đọc lướt và bỏ sót thông số kỹ thuật cốt lõi. | **BẮT BUỘC:** Cấm đọc full file. Dùng `find_kb.ps1` lấy chính xác line range cần thiết và chỉ đọc 20-40 dòng trọng tâm. |
| **`7900588b`** | **Script PowerShell bị crash do Emoji 4-byte & lồng chuỗi `"`** | Parser của PowerShell 5.1 trên Windows không xử lý được emoji 4-byte trong mã nguồn và bị cắt chuỗi khi lồng ngoặc kép. | **BẮT BUỘC:** 100% script lưu UTF-8 with BOM, tuyệt đối không dùng Emoji trong code, sử dụng chuỗi đơn `'...'`. |
| **`a3b62f34`** | **Lỗi phế không link sang MES và báo không tìm thấy Lot NVL trong kho** | 1. Phép tính phế trong SP B782 `DefectQty - RepairQty` không bọc `ISNULL`, gặp RepairQty là NULL thì toàn bộ ra NULL.<br>2. POP Kiosk kiểm tra khớp BOM chính xác giữa cuộn điện cực và PO, nếu xuất kho mang mã rev mới khác mã trong PO thì Kiosk chặn. | **BẮT BUỘC:** Mọi phép tính số học trên SQL phải bọc `ISNULL(col, 0)`. Khi xuất NVL điện cực phải đối chiếu mã BOM trong PO trước. |
| **`25ce539c`** | **Kiosk thiếu thiết bị và lỗi độ dài chuỗi SQL khi giải phóng máy** | 1. POP Kiosk ẩn máy nếu máy bị kẹt `MAPPING_STATUS = 'ACTIVE'` ở DayPlan cũ trong `VINA_EQUIPMENT_MAPPING`.<br>2. Cột `RELEASE_REASON` chỉ có độ dài `NVARCHAR(50)`, nếu truyền lý do dài hơn 50 ký tự sẽ gây lỗi `String or binary data would be truncated`. | **BẮT BUỘC:** Khi thêm máy cho Model mới phải kiểm tra giải phóng lock cũ. Luôn kiểm tra schema độ dài cột trước khi UPDATE chuỗi. |
| **`7fee40d0`** | **Ô nhiễm Workspace & Khai tử Telegram Bot (Nguy cơ lộ dữ liệu CSDL)** | 1. AI liên tục sinh hàng trăm script `.ps1` rời rạc để trace trực tiếp trong `tools/` thay vì dùng `.\mes.ps1 trace` hoặc `.\mes.ps1 query`.<br>2. Telegram Bot có nguy cơ làm lộ schema CSDL, IP máy chủ, và dữ liệu sản xuất ra máy chủ cloud Telegram bên ngoài. | **BẮT BUỘC:** 1. Tuyệt đối không tạo file trong `tools/`; mọi scratch script phải nằm trong `tools/scratch/`.<br>2. Khai tử hoàn toàn Telegram Bot, chuyển 100% sang Web Operations Portal nội bộ (`MES_POP/web`) bảo mật qua Cloudflare Tunnel và API Relay. |
| **`79bc60db`** | **Lệch nhận thức vận hành sàn xưởng so với tài liệu cũ** (Kỹ sư Nguyễn Văn Đức chuẩn hóa thực tế) | 1. F5 Hưng Yên đã 100% POP Kiosk (không còn WinForm ở xưởng), F3 Hà Nam vẫn là Hybrid.<br>2. 95% chốt nhầm do OP bấm nhầm Kiosk cảm ứng.<br>3. Vật tư phụ dở dang bắt buộc OP dùng súng quét lại barcode per Lot (không auto carry-over).<br>4. Định mức cuộn BTP điện cực đã nâng cấp lên tối đa 3 LOTNO (tài liệu cũ ghi 2).<br>5. Thu thập PLC tự động qua `.exe`: OP không đếm OK thủ công, OP nhập báo phế trước ➔ Kiosk tự trừ để ra OK Qty ➔ OP xác nhận chốt.<br>6. Sự cố POP-ERR-14 đã được EA Team xử lý hoàn tất (Closed).<br>7. Mốc 10h00 AM JobDate: Không sửa đè DB vật lý vì vướng IATF 16949 & OEE; hướng xử lý triệt để là tại Reporting Layer. | **BẮT BUỘC:** 1. Cập nhật ngay SoT KB (`POP_KB_02`, `POP_KB_03`, `GEMINI.md`).<br>2. Áp dụng chuẩn 3 LOTNO cho cuộn BTP.<br>3. Không bao giờ khuyến nghị sửa data ngày ca 10h trong DB mà tư vấn xử lý tại tầng Báo Cáo. |
| **`Audit 2026-09`** | **Khoảng cách giữa tài liệu lý thuyết và vận hành thực tế xưởng** | 1. Tài liệu mô tả quy trình hoàn hảo nhưng thực tế 95% lỗi do OP găng tay bấm nhầm trên màn hình cảm ứng.<br>2. Xung đột kiến trúc Dual-Run: WinForm đẻ dòng `CompleteRoute IS NULL` khiến Kiosk POP chặn `POP-ERR-09`.<br>3. Độ trễ WAN sang server Hàn Quốc (`dbserver.hycap.co.kr,5398`) gây rủi ro khi dùng Auto-save on blur.<br>4. Bảng `VINA_MATERIAL_INPUT_HIST` thực tế có 0 dòng (ghi vào `STB_RawMaterialInputHist`). | **BẮT BUỘC:** 1. Tự vấn theo 5 Trục Phản Biện Chuyên Sâu trong `MASTER_OPERATIONAL_PLAYBOOK.md` v4.0.<br>2. Tuân thủ Rule 22: Phân định tuyệt đối POP vs MES.<br>3. Không sửa đè `JobDate` vật lý để bảo toàn chuẩn audit IATF 16949.<br>4. Dùng CLI Hubs chuẩn (`pop.ps1`, `mes.ps1`), 0 blind SQL looping. |
| **`90f1ec9a`** (2026-09-30) | **Kiosk POP báo "Không có thiết bị đăng ký (0)" tại công đoạn Lão hóa/Aging (HY Cell Line #16) & Sai lệch Master Data Sorting** | 1. POP Kiosk truy vấn thiết bị theo cặp `(LineCode, RouteCode)` trong `STB_ProductMachine`. Chuyền Cell `VVHYC-16` chỉ có 9 máy (V-22~V-25), thiếu hẳn công đoạn Aging `V-26_HY` do Master Data F5 ban đầu tách Aging thành các chuyền riêng `VVHYBAS-01~05`.<br>2. 5 máy Sorting Hưng Yên (`VVMHY16~20`) bị sai 2 lỗi ngớ ngẩn: Tên để là `Bigsize_Auto Sorting #1..#5` và `WorkCenterCode` bị nhập nhầm thành `VVT_F2` (Bắc Giang) thay vì `VVT_F5` (Hưng Yên), đồng thời chưa từng được map vào `STB_ProductMachine`.<br>3. Quy trình Cell Hưng Yên không có Route Sorting riêng (`V-35_HY`), mà cả 10 máy (5 Auto Aging `VVMHY34~38` + 5 Sorting `VVMHY16~20`) chạy chung trên công đoạn Lão hóa `V-26_HY`. | **BẮT BUỘC:** 1. Khi xưởng báo thiếu máy trên Kiosk, phân biệt rõ: Kẹt lock ACTIVE (`VINA_EQUIPMENT_MAPPING` - POP-ERR-20) vs Chưa gán máy vào Line (`STB_ProductMachine` - POP-ERR-36).<br>2. Sửa Master Data: Đổi tên chuẩn hóa và sửa WorkCenter về đúng `VVT_F5` qua màn hình MES WinForm `B250`.<br>3. Gán máy vào Chuyền: Dùng màn hình `B270` hoặc chạy script SQL INSERT `STB_ProductMachine` cho toàn bộ chuyền Cell `VVHYC-%`. |
| **`7776a635`** (2026-09-30) | **Hạng mục PQC kiểm tra đánh giá ngoại quan/tích chọn (`CHECK`) tích trên Web POP là OK nhưng trên NAIS MES C443 hiển thị thành NG** | 1. Trên POP Web (`/pop/quality`), khi công nhân tích PASS (tích xanh `[✓]`), hệ thống lưu `MeasureResult = '0'` (0 = Không lỗi / PASS) vào `SmartFactoryV2.dbo.STB_CommInspMeasureHist`.<br>2. Trên NAIS MES C443, Stored Procedure `dbo.usp_GetCommInspection_HistoryForBarcode_Vietnam` chứa logic so sánh cứng lỗi thời: `WHEN CIMH.MeasureResult = '1' OR CIMH.MeasureResult = 'OK' THEN 'OK' ELSE 'NG'`, dẫn đến mọi bản ghi `'0'` từ POP (hơn 22,000 dòng) bị ép thành `NG`.<br>3. SP còn nhầm lẫn trỏ tất cả các cột đo Lần 1, Lần 2, Lần 3... vào biến đại diện mẫu cuối `CIMH` thay vì dùng đúng từng mẫu `CIMH1`, `CIMH2`, `CIMH3`...<br>4. Cột `CheckDisplay` (Kiểm tra OK) chỉ bật khi `MeasureResult = 'OK'`, bỏ qua `'0'` làm trống checkbox. | **BẮT BUỘC:** 1. Phân biệt rõ dữ liệu nguồn vs hiển thị: Tra cứu trực tiếp `STB_CommInspMeasureHist` trước khi khẳng định Lot bị lỗi.<br>2. Cập nhật SP `usp_GetCommInspection_HistoryForBarcode_Vietnam`: Cho phép `MeasureResult IN ('0', 'OK', 'PASS')` là ĐẠT, `IN ('1', 'NG', 'FAIL')` là NG, và trỏ đúng biến từng mẫu `CIMH1..CIMH20`.<br>3. Thông báo cho QC/OP an tâm: Dữ liệu trên DB và POP đã ĐẠT, không ảnh hưởng chất lượng xuất chuyền. |


---

## 2. QUY TRÌNH PHẢN XẠ VẬN HÀNH CHUẨN HÓA (KNOWLEDGE-FIRST 4 BƯỚC)

```
[Nhận yêu cầu / Mã lỗi / Screen ID / Mã Lot từ User]
                         │
                         ▼
 ┌────────────────────────────────────────────────────────────┐
 │ BƯỚC 1: TRA CỨU TÀI LIỆU TRƯỚC (find_kb.ps1 / KB Modules)  │
 ├────────────────────────────────────────────────────────────┤
 │ - CẤM CHẠY SELECT NGAY LẬP TỨC.                            │
 │ - Tra cứu Screen ID Matrix, Bug Fixbook KB_09, WMS, Prod.   │
 │ - Xác định Reliability Score từ KB_RELIABILITY_REPORT.md   │
 └─────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
 ┌────────────────────────────────────────────────────────────┐
 │ BƯỚC 2: TRÍCH DẪN CĂN CỨ TÀI LIỆU & NGUYÊN NHÂN GỐC RỄ     │
 ├────────────────────────────────────────────────────────────┤
 │ - Nêu rõ: File KB, số dòng, Root Cause và giải pháp chuẩn. │
 │ - Nếu KB KHÔNG CÓ: Tuyên bố rõ danh sách KB đã tra cứu.    │
 └─────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
 ┌────────────────────────────────────────────────────────────┐
 │ BƯỚC 3: KIỂM CHỨNG CÓ MỤC ĐÍCH BẰNG SELECT / GOLDEN QUERY  │
 ├────────────────────────────────────────────────────────────┤
 │ - Dùng .\mes.ps1 trace <Lot> nếu là truy vết Lot/Barcode.  │
 │ - Hoặc SELECT đúng 3-5 cột để chứng minh hiện trạng.       │
 └─────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
 ┌────────────────────────────────────────────────────────────┐
 │ BƯỚC 4: XUẤT HOTFIX CHUẨN HÓA (BEGIN TRAN...ROLLBACK)      │
 ├────────────────────────────────────────────────────────────┤
 │ - Dùng .\mes.ps1 new-fix để sinh template UTF-8-BOM.       │
 │ - Đảm bảo đồng bộ đủ các bảng liên quan (4-Table Integrity)│
 └────────────────────────────────────────────────────────────┘
```

---

## 3. CAM KẾT TUÂN THỦ BẤT BIẾN (INVIOLABLE RULES)

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB:** Cấm chạy SELECT khi chưa tra cứu KB và trích dẫn căn cứ.
2. **RULE 1 - SELECT-ONLY ON PROD:** Không tự ý chạy lệnh ghi trực tiếp. Mọi hotfix phải bọc `BEGIN TRAN...ROLLBACK` và chạy qua `deploy_tool.ps1`.
3. **RULE 4 - SURGICAL RETRIEVAL:** Không đọc tràn lan file >50KB. Chỉ đọc đoạn dòng cần thiết để tránh loãng context.
4. **RULE 6 - GOLDEN QUERY 360° FIRST:** Quét toàn diện Lot qua `mes.ps1 trace` trong lần kiểm tra đầu tiên.
5. **RULE 10 - NO JUNK SCRIPTS:** Dùng đúng bộ công cụ chuẩn hóa (`mes.ps1`, `find_kb.ps1`, `health_check.ps1`, `deploy_tool.ps1`). Mọi script test tạm bắt buộc đặt trong `tools/scratch/` và dọn dẹp sạch sẽ sau khi hoàn thành.
6. **RULE 12 - ZERO KEY LEAKAGE & NO TELEGRAM BOT:** Tuyệt đối không commit key thật lên GitHub repository. Khai tử Telegram bot, bảo mật API keys và relay secret trong `*.local.json` và `.env.local`.
7. **RULE 13 - DUAL-SYNC POP & MES:** Luôn đối chiếu `MongoToMesPerformance` song song với `STB_ProdRouteHist` khi xử lý sự cố tiến độ trên POP Kiosk.
8. **RULE 22 - STRICT SYSTEM TAXONOMY (POP vs MES):** Mọi sự cố/task/ticket/báo cáo tuần liên quan đến Kiosk xưởng, Web POP, nạp NVL Kiosk, kẹt máy Kiosk, đồng bộ `MongoToMes*` BẮT BUỘC ghi phân loại là **POP**, TUYỆT ĐỐI KHÔNG ghi là **MES**. MES chỉ dành riêng cho WinForm B-series và CSDL lõi `SmartFactoryV2`.

