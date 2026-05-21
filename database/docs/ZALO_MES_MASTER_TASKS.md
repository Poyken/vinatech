# 📋 ZALO & MES MASTER TASK TRACKER

> **Mục đích:** File này dùng để theo dõi các yêu cầu, bug report nhận được từ User (thường qua Zalo hoặc trực tiếp). Cập nhật file này ở Bước 5 của `BUG_INVESTIGATION_FLOW` theo yêu cầu trong `AGENTS.md`.

## 🟢 Đang Xử Lý (In Progress)
* **Task 7:** Lỗi "Thiếu thiết lập Vỏ Nhôm" model 3562 (16/05/2026) - *Đã xác minh (17/05/2026): Bảng `STB_AluCaseMapping_VVT` KHÔNG TỒN TẠI trong DB. Logic vỏ nhôm hardcode trong SP `usp_Vietnam_RawMaterialInputHist_uid`. Chỉ có thể fix bằng cách sửa SP (thêm mã vỏ vào NOT IN list). Đã cung cấp hướng dẫn, chờ user deploy lại SP.*
* **Task 8:** Lỗi unique constraint màn HN544 mã PKQN2100175 (21/05/2026) - *Đang xử lý: Lỗi do SP `usp_GetMaterialLotInfo_Packing_VVT_F3` trả về 2 dòng khi quét mã cha chưa phân tách (gộp túi bóng). Đang chuẩn bị script hủy giao dịch lỗi và script sửa SP triệt để.*

---

## 🟡 Đang Chờ Phản Hồi (Waiting on User / Testing)
*(Chưa có)*

---

## 🔴 Cần Ưu Tiên (High Priority)
*(Chưa có)*

---

## ✅ Đã Hoàn Thành (Done / Resolved)
* **Task 1:** Triển khai Framework AI Debugging (12/05/2026) - *Hoàn tất setup KBs, DataFlow, AGENTS.md, và kiểm thử kết nối DB thành công bằng PowerShell/sqlcmd.*
* **Task 2:** Tích hợp Context Groupware (12/05/2026) - *Đã nạp toàn bộ slide Groupware vào `KB_07_GROUPWARE_INTEGRATION.md`.*
* **Task 3:** Thiết kế tem Phoenix Contact (14/05/2026) - *Đã hoàn thành thiết kế mẫu tem 5x8 cm, viết SP `usp_Vietnam_PhoenixContactLabelPrint_get` hỗ trợ lấy Datecode từ công đoạn Winding và tích hợp logic in nhiều tem kiểu B756.*
* **Task 4:** Hỗ trợ in tem Hà Nam (13/05/2026) - *Đã cấu hình `PartLabel` cho mã `10140105055` (Anode Foil) theo yêu cầu của chị Hoàng Xuân bộ phận Kho.*
* **Task 5:** Thu hồi Lot ML20260407000696 (16/05/2026) - *Đã cung cấp script SQL để xóa lịch sử F430 và đẩy Lot về kho `ROH_HN_WH`. Đang chờ user xác nhận thực thi.*
* **Task 6:** Lot SP260516-003 gộp túi bóng (16/05/2026) - *Đã xác minh (17/05/2026) CurrentQty=20 đã OK, PackingID=PKQN1600300 → Loồi đã được xử lý thành công.*


---
**Quy tắc cập nhật:**
1. Khi có bug mới: Chuyển vào mục **Đang Xử Lý**.
2. Khi đã đưa ra script SQL đề xuất: Chuyển vào mục **Đang Chờ Phản Hồi**.
3. Khi User báo done: Chuyển vào mục **Đã Hoàn Thành** và note lại nguyên nhân gốc rễ (Root Cause) để sau này AI học lại.
