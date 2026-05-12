# SOLO CONTEXT — Cách dùng nhanh

## 1) File nào cần mở trước khi debug?
1) `SOLO_CONTEXT_OVERVIEW.md` (file này) → để biết map tổng quan.
2) `MES_MASTER_KNOWLEDGE_BASE\KB_05_TRACE_BUG_METHODOLOGY.md` → quy trình trace.
3) `MES_MASTER_KNOWLEDGE_BASE\Vinatech_MES_Complete_DataFlow.md` → flow & SP/bảng theo phase.
4) `MES_MASTER_KNOWLEDGE_BASE\KB_INDEX.md` → mở đúng KB_01..KB_06 theo triệu chứng.

## 2) Khi bạn nhờ “trace lỗi”, hãy gửi tối thiểu
- Màn hình/TCode (B597/B523/F330/…)
- Barcode/ControlNo/LotID/MaterialDocNo/PONo
- Lỗi hiển thị (copy text hoặc ảnh)
- Khoảng thời gian xảy ra (để lọc log)

## 3) Cách mình sẽ trả lời (để đảm bảo “không ảo tưởng”)
Mỗi kết luận quan trọng sẽ đi kèm ít nhất 1 trong các bằng chứng:
- Trích đoạn từ file KB/DataFlow trong thư mục database (đường dẫn rõ ràng)
- Hoặc truy vấn SQL SELECT/log template (để bạn chạy tay trên SSMS)

## 4) Lưu ý phạm vi
- `.docx` đã được bỏ qua theo yêu cầu.
- Các file `.sql` là “đề xuất/script”. Việc chạy trên production phải do bạn quyết định và tự thực thi.

