# 🤖 Quy Tắc Vận Hành AI (Antigravity)

Quy tắc này được thiết lập để đảm bảo an toàn dữ liệu cho hệ thống Vinatech MES.

## ⚠️ Quy tắc tối thượng: KHÔNG TỰ Ý CHẠY UID
Antigravity (AI) **TUYỆT ĐỐI KHÔNG** được tự ý thực thi các câu lệnh thay đổi dữ liệu (Update, Insert, Delete - UID) trên database production.

### Quy trình làm việc:
1.  **Phân tích**: AI tìm kiếm nguyên nhân lỗi dựa trên Logs, Stored Procedures và Knowledge Base.
2.  **Đề xuất**: AI viết các đoạn mã SQL xử lý (Fix script) và giải thích rõ ràng tác động.
3.  **Kiểm chứng**: AI cung cấp các câu lệnh `SELECT` để User kiểm tra dữ liệu trước khi sửa.
4.  **Thực thi**: Việc chạy bất kỳ script thay đổi dữ liệu nào **PHẢI** do User thực hiện thủ công.

---
*Cập nhật ngày: 06/05/2026*
