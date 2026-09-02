---
name: vinatech-new-model-setup
description: Checklist đầy đủ 8 bước khai báo Model / Sản phẩm mới trên MES Vinatech để tránh lỗi không tạo được Lot, lỗi in tem, lỗi không hiện Vol/Farad, hoặc lỗi gộp thùng.
---

# Vinatech New Model Setup Skill

## Khi Nào Kích Hoạt Skill Này?
Kích hoạt khi nhà máy chuẩn bị sản xuất mã hàng mới, thêm Model/BOM mới hoặc kiểm tra cấu hình Master Data cho sản phẩm mới.

## Checklist 8 Bước Khai Báo Model Mới Chuẩn:

1. **Bước 1: Khai báo Master Nguyên Vật Liệu (A230 - `STB_MaterialMaster`)**
   - Kiểm tra `MaterialCode`, `MaterialName`, `MaterialThickness`.
   - **Bắt buộc:** Gán cột `BasicRoutingCode` khớp với bộ Routing đã cấu hình cho nhà máy sản xuất tại **B240** (ví dụ Hưng Yên `VVT_F5` là `HY_MainRoutingMedium` hoặc `HY_MainRoutingBigSiz`).
2. **Bước 2: Khai báo Master Sản Phẩm / Model (A410 - `STB_ModelMaster`)**
   - Kiểm tra `ModelCode`, `ModelName`, `ModelType`, `Capacity`, `Voltage`.
3. **Bước 3: Khai báo Quy Cách Đóng Gói (A418 - `STB_PackingStandard`)**
   - Cấu hình số lượng chiếc/box, chiếc/carton, chiếc/pallet theo kích thước Size.
4. **Bước 4: Cấu hình Mẫu Tem & Định dạng In (A460 - `STB_ModelLabelInfo`)**
   - Cấu hình `LabelType`, `FormatName`, tem Barcode, tem Sanmina.
5. **Bước 5: Thiết lập Quy Trình Sản Xuất / Line Route (B210/B220/B230/B240)**
   - **B240 (`STB_BasicRoutingInfo` + `STB_BasicRoutingDetail`):** Thiết lập và tick chọn danh sách các công đoạn (`RouteCode`) cho nhà máy (`WorkCenterCode`).
   - Phân bổ danh sách Máy (`STB_RouteEqpInfo`) và Nhân viên (`STB_WorkerInfo`).
6. **Bước 6: Cấu hình Tự Động Sinh Số Lô (A416 / `STB_Vietnam_PackingPrinting`)**
   - Kiểm tra tiền tố VJ hoặc prefix Lot cho từng khách hàng.
7. **Bước 7: Kiểm thử Tạo Thử Lot & Scan Thử Nghiệm**
   - Dùng `.\mes.ps1 trace "<TestLot>"` để xác nhận dữ liệu đã liên kết đầy đủ 4 bảng.
8. **Bước 8: Xác nhận QC IQC/PQC đã cấu hình Tiêu Chuẩn Đánh Giá (A510)**
9. **Bước 9 (Đặc thù Điện cực - Electrode): Khai báo giá thành phẩm & Đơn giá phế trên B802**
   - **Giá bán thành phẩm:** Khai báo mã mới vào bảng `STB_ElectrodePriceB802` (cả mã gốc và mã chi tiết như `CRFYN85L-01`).
   - **Đơn giá phế & Tỷ lệ Kg ↔ Mét:** Nếu model có độ dày mới (như size `180`) hoặc hậu tố tên đặc thù (`A301`), cần kiểm tra và bổ sung khai báo trong Function `[dbo].[fn_VVT_ElecErrorPriceMeter2KG]()` để tránh lỗi B802 không nhảy giá phế (Waste Price = 0) và không tự đổi ra mét (Defect Meter = 0).
