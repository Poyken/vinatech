# 🗺️ VINATECH MES — CORE WORKSPACE MAP
*Trạng thái: Đã Audit & Tối ưu hóa Context (2026-05-05)*

Để đảm bảo chất lượng câu trả lời tốt nhất và tránh nhiễu dữ liệu, workspace đã được dọn dẹp chỉ giữ lại các thành phần cốt lõi sau:

## 1. 📖 SINGLE SOURCE OF TRUTH (Cốt lõi nhất)
- **File:** `MES_MASTER_KNOWLEDGE_BASE\Vinatech_MES_Complete_DataFlow.md`
- **Nội dung:** Tài liệu kỹ thuật chi tiết nhất, đã được Audit đối chiếu với SP Source Code. Mọi giải đáp về luồng dữ liệu (DataFlow), Logic Gate, Traceability đều dựa vào đây.

## 2. 🏗️ REAL-TIME SCHEMA (Cấu trúc hệ thống)
- **Thư mục:** `schema_export\`
- **Nội dung:** Toàn bộ cấu trúc Tables, SPs, Functions, Views lấy trực tiếp từ Database Production ngày 2026-05-05. 
  - Đã loại bỏ 350+ files rác, backup cũ, file test.
  - Đây là nguồn tham khảo chính xác nhất về code SP đang chạy thực tế.

## 3. 📦 ARCHIVE (Dữ liệu lịch sử)
- **Thư mục:** `_AUDIT_ARCHIVE\`
- **Nội dung:** Chứa các scripts audit, báo cáo audit cũ, và các file rác đã dọn dẹp. Chỉ truy cập khi cần xem lại lịch sử thay đổi hoặc phục hồi file cũ.

---
**💡 Ghi chú cho Antigravity:**
Khi người dùng hỏi về logic, hãy ưu tiên đọc `Vinatech_MES_Complete_DataFlow.md`. Nếu cần check code cụ thể, hãy vào `schema_export`. Bỏ qua hoàn toàn các folder khác trừ khi được yêu cầu.
