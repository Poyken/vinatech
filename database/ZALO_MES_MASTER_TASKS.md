# DANH SÁCH NHIỆM VỤ MES TỪ ZALO
*(Được cập nhật tự động mỗi 5 phút từ hệ thống OpenClaw Zalo)*

**Quy trình 4 bước:**
1. **[NEW]**: Task do OpenClaw mới hút về. Antigravity sẽ quét và lập kế hoạch -> đổi thành `[WAITING_APPROVAL]`.
2. **[WAITING_APPROVAL]**: Sếp đánh dấu `[x]` vào ô Approve để duyệt.
3. **[APPROVED]**: Antigravity sẽ thực thi SQL, đưa ra kết quả, nháp tin nhắn Zalo hỗ trợ -> đổi thành `[DONE]`.
4. **[DONE]**: Sếp copy tin nhắn nháp gửi lại qua Zalo.


---

1. **[DONE]**: Lỗi điện cực 1025-10f không lưu được
   - Nguồn gốc lỗi: Quét mã điện cực 1025-10f (Model: ECVT30-270) sử dụng Lot slitting CRCEK0-266. Lỗi xảy ra do độ dày thiết lập trong DB bị lệch (`200` so với `200.000000`), làm logic LIKE so sánh chuỗi sai, dẫn đến `@count < 1` và kích hoạt bắt lỗi "Chưa CONFIG trong bảng STB_SLITTINGLOCATIONCONFIG_VVT".
   - Cách xử lý: Đã bổ sung exception vào Store Procedure `usp_Vietnam_RawMaterialInputHist_uid` để pass mã ECVT30-270 mapping với CRCEK0-266.
   - Trạng thái DB: Đã deploy SQL thành công.
   - Nháp Zalo hỗ trợ: "Em đã check lỗi này. Nguyên nhân do logic check cấu hình của độ dày 200 trên hệ thống bị lỗi so sánh (200 ko khớp với 200.000000). Em đã fix và Update hệ thống cho phép quét mã cặp ECVT30-270 và CRCEK0-266 này rồi nhé, chị lưu Input lại thử xem đã thành công chưa ạ. ^^"

