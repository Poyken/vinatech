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
| **`7fee40d0`** | **Ô nhiễm Workspace (103 scripts rác trong `tools/`) & Nguy cơ lộ Token** | 1. AI liên tục sinh hàng trăm script `.ps1` rời rạc để trace trực tiếp trong `tools/` thay vì dùng `.\mes.ps1 trace` hoặc `.\mes.ps1 query`.<br>2. Ghi đè token và API key thật vào file `tools/telegram_config.json` thay vì dùng file local gitignored `telegram_config.local.json`. | **BẮT BUỘC:** 1. Tuyệt đối không tạo file trong `tools/`; mọi scratch script phải nằm trong `tools/scratch/`.<br>2. File `telegram_config.json` chỉ giữ placeholder mẫu, secrets thật 100% nằm trong `*.local.json`. |
| **`79bc60db`** | **Lệch nhận thức vận hành sàn xưởng so với tài liệu cũ** (Kỹ sư Nguyễn Văn Đức chuẩn hóa thực tế) | 1. F5 Hưng Yên đã 100% POP Kiosk (không còn WinForm ở xưởng), F3 Hà Nam vẫn là Hybrid.<br>2. 95% chốt nhầm do OP bấm nhầm Kiosk cảm ứng.<br>3. Vật tư phụ dở dang bắt buộc OP dùng súng quét lại barcode per Lot (không auto carry-over).<br>4. Định mức cuộn BTP điện cực đã nâng cấp lên tối đa 3 LOTNO (tài liệu cũ ghi 2).<br>5. Thu thập PLC tự động qua `.exe`: OP không đếm OK thủ công, OP nhập báo phế trước ➔ Kiosk tự trừ để ra OK Qty ➔ OP xác nhận chốt.<br>6. Sự cố POP-ERR-14 đã được EA Team xử lý hoàn tất (Closed).<br>7. Mốc 10h00 AM JobDate: Không sửa đè DB vật lý vì vướng IATF 16949 & OEE; hướng xử lý triệt để là tại Reporting Layer. | **BẮT BUỘC:** 1. Cập nhật ngay SoT KB (`POP_KB_02`, `POP_KB_03`, `GEMINI.md`).<br>2. Áp dụng chuẩn 3 LOTNO cho cuộn BTP.<br>3. Không bao giờ khuyến nghị sửa data ngày ca 10h trong DB mà tư vấn xử lý tại tầng Báo Cáo. |

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
6. **RULE 12 - ZERO KEY LEAKAGE:** Tuyệt đối không commit key thật lên GitHub repository. File `telegram_config.json` chỉ giữ placeholder mẫu, secrets thật 100% nằm trong `*.local.json`.
7. **RULE 13 - DUAL-SYNC POP & MES:** Luôn đối chiếu `MongoToMesPerformance` song song với `STB_ProdRouteHist` khi xử lý sự cố tiến độ trên POP Kiosk.
