# DANH SÁCH NHIỆM VỤ MES TỪ ZALO
*(Được cập nhật tự động mỗi 5 phút từ hệ thống OpenClaw Zalo)*

**Quy trình 4 bước:**
1. **[NEW]**: Task do OpenClaw mới hút về. Antigravity sẽ quét và lập kế hoạch -> đổi thành `[WAITING_APPROVAL]`.
2. **[WAITING_APPROVAL]**: Sếp đánh dấu `[x]` vào ô Approve để duyệt.
3. **[APPROVED]**: Antigravity sẽ thực thi SQL, đưa ra kết quả, nháp tin nhắn Zalo hỗ trợ -> đổi thành `[DONE]`.
4. **[DONE]**: Sếp copy tin nhắn nháp gửi lại qua Zalo.

---
