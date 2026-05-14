# 📋 ZALO & MES MASTER TASK TRACKER

> **Mục đích:** File này dùng để theo dõi các yêu cầu, bug report nhận được từ User (thường qua Zalo hoặc trực tiếp). Cập nhật file này ở Bước 5 của `BUG_INVESTIGATION_FLOW` theo yêu cầu trong `AGENTS.md`.

## 🟢 Đang Xử Lý (In Progress)
*(Chưa có task nào đang chờ)*

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


---
**Quy tắc cập nhật:**
1. Khi có bug mới: Chuyển vào mục **Đang Xử Lý**.
2. Khi đã đưa ra script SQL đề xuất: Chuyển vào mục **Đang Chờ Phản Hồi**.
3. Khi User báo done: Chuyển vào mục **Đã Hoàn Thành** và note lại nguyên nhân gốc rễ (Root Cause) để sau này AI học lại.
