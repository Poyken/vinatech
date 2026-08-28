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
| **`7900588b`** (Phiên hiện tại) | **Script PowerShell bị crash do Emoji 4-byte & lồng chuỗi `"`** | Parser của PowerShell 5.1 trên Windows không xử lý được emoji 4-byte trong mã nguồn và bị cắt chuỗi khi lồng ngoặc kép. | **BẮT BUỘC:** 100% script lưu UTF-8 with BOM, tuyệt đối không dùng Emoji trong code, sử dụng chuỗi đơn `'...'`. |

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
5. **RULE 10 - NO JUNK SCRIPTS:** Dùng đúng bộ công cụ chuẩn hóa (`mes.ps1`, `find_kb.ps1`, `health_check.ps1`, `deploy_tool.ps1`), dọn dẹp sạch sẽ sau khi hoàn thành.
