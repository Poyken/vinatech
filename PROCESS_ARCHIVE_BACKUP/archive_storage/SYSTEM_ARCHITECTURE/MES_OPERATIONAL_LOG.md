# 📓 Operational & Troubleshooting Log — Nhật Ký Sự Cố Vận Hành Hệ Thống Vinatech

> **Mục tiêu:** Nơi ghi nhận, theo dõi và giải quyết các sự cố phát sinh tại hiện trường sản xuất xưởng Vinatech.
> **Nguyên tắc phối hợp:** 
> 1. **User** ghi nhận triệu chứng, mã lỗi, và mã Lot/Barcode bị lỗi vào phần **[Sự Cố Mới Phát Sinh]**.
> 2. **AI Agent** đọc log, chạy truy vấn DB kiểm tra, đề xuất SQL fix script an toàn (bọc transaction) hoặc giải pháp cấu hình, cập nhật trạng thái sự cố.
> ← [Về INDEX](README.md) | [Cẩm nang giám sát hàng ngày](MES_DAILY_PLAYBOOK.md)

---

## 📊 Bảng Theo Dõi Sự Cố Hệ Thống (Incident Tracking Board)

| ID | Ngày | Màn hình | Đối tượng bị lỗi | Triệu chứng & Log thô | Trạng thái | Giải pháp & Script khắc phục | Người xử lý |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **#001** | 2026-06-10 | **V-22** (Dry Oven) | Lot `ML260609001` | Lò sấy Dry Oven bị bypass kiểm tra công đoạn do sai thứ tự ưu tiên logic `AND/OR` trong SP `usp_VN_DryOver`. | **RESOLVED** | Đã triển khai Hotfix `01_FIX_DRY_OVEN_OPERATOR_PRIORITY.sql` để sửa mức ưu tiên toán tử trong SP. | AI & DBA |
| **#002** | 2026-06-11 | **B523** (Đóng gói) | Box `PKHN023117` | Lỗi gộp box đúp dẫn đến số lượng túi con bị dồn về `0` hoặc âm tại Hà Nam (Lỗi HN544). | **RESOLVED** | Chạy script rã box và cập nhật lại số lượng thực tế cho Lot gốc. Chi tiết tại [Tập 3 (B523)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#b523--divide-packaging-gộp-box-nhỏ). | AI |
| **#003** | 2026-06-12 | **HNC321** (Phế phẩm) | Barcode `ve260509-001` | Nhập phế công đoạn `VE08` báo lỗi tiếng Hàn: "Không có lịch sử xử lý sản lượng ở công đoạn trước". | **RESOLVED** | Chèn bản ghi lịch sử quét ảo cho trạm trước (`VE07`) để thông luồng validation. Chi tiết tại [Tập 3 (B530)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#b530--production-route-input-chốt-sản-lượng-công-đoạn). | AI |
| **#004** | 2026-06-13 | **Mixing** (Cân điện cực) | Lot `HCE-202` | Màn hình cân nhảy bước Binder trước bột Than làm kẹt mẻ trộn Mixing. | **RESOLVED** | Công nhân bỏ tích checkbox "CA ĐÊM CHUẨN BỊ TRƯỚC" trên UI. IT chạy script reset dữ liệu cân tạm của Lot. [Tập 3 (B597)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#b597--material-scanning-quét-nạp-nguyên-vật-liệu). | AI & IT |
| **#005** | 2026-06-14 | **B552** (Slitting) | Model `3582-600F CY` | Model mới không tạo được tem điện cực do thiếu cấu hình quy cách Slitting. | **RESOLVED** | Thêm cấu hình quy cách vào bảng `stb_slittinglocationconfig_vvt`. Chi tiết tại [Tập 3 (B552)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#b552--slitting-result-chia-cuộn-điện-cực). | AI |

---

## 📝 Mẫu Đăng Ký Sự Cố Mới (Incident Registration Template)

*Kỹ sư vận hành sử dụng mẫu dưới đây để thêm một dòng mới vào phần **[Sự Cố Mới Phát Sinh]** bên dưới khi phát hiện lỗi.*

```markdown
### 🚨 SỰ CỐ #[Số_ID_Tiếp_Theo]: [Tên ngắn gọn của lỗi]
- **Thời gian xảy ra:** YYYY-MM-DD HH:MM
- **Màn hình/TCodes:** [Ví dụ: B530, F330...]
- **Mã lỗi/Lot/Barcode bị kẹt:** [Ví dụ: ML20260614-001, Barcode VVPR...]
- **Triệu chứng lỗi (Ảnh chụp hoặc mô tả chi tiết):**
  > [Mô tả chi tiết hoặc dán log lỗi từ STB_ProcedureLog ở đây]
- **Trạng thái:** OPEN
```

---

## 📥 [SỰ CỐ MỚI PHÁT SINH]

*(Kỹ sư vận hành vui lòng điền các sự cố phát sinh tại đây. AI Agent sẽ quét mục này khi khởi chạy session mới để tiến hành phân tích).*

---

## 🛡️ Hướng Dẫn Vận Hành An Toàn Khi Sửa Sự Cố (Dành cho AI & IT)
1. **Tuyệt đối tuân thủ quy tắc SELECT-ONLY:** AI không được chạy lệnh `UPDATE/DELETE` trực tiếp bằng `run_query.ps1`.
2. **Quy trình cung cấp script fix:**
   - AI viết script fix bọc trong khối `BEGIN TRAN...ROLLBACK TRAN`.
   - AI chạy `validate_sql.ps1` để kiểm tra cú pháp và độ an toàn.
   - AI chuyển script cho User duyệt qua giao diện chat.
   - User đồng ý -> User tự chạy script qua SSMS hoặc AI chạy thông qua `deploy_tool.ps1` (nếu có lệnh phê duyệt cụ thể từ User).
3. **Cập nhật trạng thái:** Sau khi lỗi được fix thành công, AI chuyển trạng thái lỗi trong **Bảng Theo Dõi** thành **RESOLVED** và ghi lại giải pháp để tránh lặp lại lỗi.
