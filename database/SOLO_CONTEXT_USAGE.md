# SOLO CONTEXT — Cách dùng nhanh

## 1) File nào cần mở trước khi debug?
1) `SOLO_CONTEXT_OVERVIEW.md` → map tổng quan (đọc file này trước).
2) `MES_MASTER_KNOWLEDGE_BASE\KB_05_TRACE_BUG_METHODOLOGY.md` → quy trình trace.
3) `MES_MASTER_KNOWLEDGE_BASE\Vinatech_MES_Complete_DataFlow.md` → flow & SP/bảng theo phase.
4) `MES_MASTER_KNOWLEDGE_BASE\KB_INDEX.md` → mở đúng KB_01..KB_06 theo triệu chứng.

## 2) Khi bạn nhờ “trace lỗi”, hãy gửi tối thiểu
Copy form trong [`BUG_REPORT_TEMPLATE.md`](BUG_REPORT_TEMPLATE.md) (đủ field = trace nhanh hơn).

Tóm tắt tối thiểu:
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

## 5) Kiểm chứng tài liệu với database thật
Agent không kết nối được SQL Server của bạn theo mặc định. Để xác minh DataFlow/KB khớp DB:
- Chạy read-only [`VERIFY_DB_DOCUMENTATION.sql`](VERIFY_DB_DOCUMENTATION.sql) trên SSMS (và [`test_GBSN00_002.sql`](test_GBSN00_002.sql) cho case vendor lot).
- Gửi **kết quả grid** (hoặc ảnh) vào chat để đối chiếu.
- Tùy chọn: đồng bộ `schema_export\` vào workspace ([`CORE_WORKSPACE_MAP.md`](CORE_WORKSPACE_MAP.md)) hoặc cấu hình MCP SQL chỉ SELECT để agent tra cứu không cần paste tay.

