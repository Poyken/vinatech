---
name: vinatech-new-model-setup
description: Quy trình triển khai và Checklist 9 bước khai báo Model / Sản phẩm mới trên MES Vinatech, tiêu chí nghiệm thu và kiểm toán liên thông 4 bảng.
---

# 🏭 Vinatech New Model Setup & Master Data Deployment Skill

> **Quy trình chuẩn:** [SOP-03 New Model Rollout](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/.agents/rules/DEPLOYMENT_SOP.md)  
> **Người thực hiện:** Kỹ sư IT Nguyễn Văn Đức (`Author='vanduc'`) & Quản đốc Xưởng

## Khi Nào Kích Hoạt Skill Này?
Kích hoạt khi nhà máy chuẩn bị sản xuất mã hàng mới, thêm Model/BOM mới hoặc kiểm tra cấu hình Master Data cho sản phẩm mới trên toàn hệ thống Vinatech (Vĩnh Phúc, Hà Nam, Hưng Yên).

---

## 📋 Checklist 9 Bước Khai Báo Tuần Tự (Nghiêm Ngặt):

1. **Bước 1: Khai báo Master Nguyên Vật Liệu (A230 - `STB_MaterialMaster`)**
   - Kiểm tra `MaterialCode`, `MaterialName`, `MaterialThickness`.
   - **Bắt buộc:** Gán cột `BasicRoutingCode` khớp với bộ Routing đã cấu hình cho nhà máy sản xuất tại **B240** (ví dụ Hưng Yên `VVT_F5` là `HY_MainRoutingMedium` hoặc `HY_MainRoutingBigSiz`).
   - Khóa logic: `MaterialThickness` phải >= 100 µm để không bị mờ nút Cắt điện cực trên Kiosk (Rule 20.3).

2. **Bước 2: Khai báo Master Sản Phẩm / Model (A410 - `STB_ModelMaster`)**
   - Kiểm tra `ModelCode`, `ModelName`, `ModelType`, `Capacity`, `Voltage`.
   - Đảm bảo các thông số Farad (F) và Điện áp (V) chính xác để hiển thị đúng trên nhãn dán.

3. **Bước 3: Khai báo Quy Cách Đóng Gói (A418 - `STB_PackingStandard`)**
   - Cấu hình số lượng chiếc/box, chiếc/carton, chiếc/pallet theo kích thước Size.
   - Tránh lỗi không thể đóng thùng hoặc gộp box lẻ (B523).

4. **Bước 4: Cấu hình Mẫu Tem & Định dạng In (A460 - `STB_ModelLabelInfo`)**
   - Cấu hình `LabelType`, `FormatName`, tem Barcode, tem Sanmina (nếu là khách hàng Sanmina).
   - Kiểm tra mẫu Barcode có tiền tố phù hợp.

5. **Bước 5: Thiết lập Quy Trình Sản Xuất / Line Route (B210/B220/B230/B240/B270)**
   - **B240 (`STB_BasicRoutingInfo` + `STB_BasicRoutingDetail`):** Thiết lập và tick chọn danh sách các công đoạn (`RouteCode`) cho nhà máy (`WorkCenterCode`).
   - **B270 (`STB_ProductMachine`):** Bắt buộc gán danh mục Máy móc cho Dây chuyền & Công đoạn (`LineCode` + `RouteCode` + `MachineCode`), đặc biệt là Winding, Curling, Sleeving để trên Kiosk POP hiển thị danh sách máy cho công nhân chọn.
   - ⚠️ **Kiểm tra POP Kiosk:** Đảm bảo các máy trong `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING` không bị kẹt trạng thái `ACTIVE` ở Kế hoạch cũ làm ẩn máy trên Kiosk.

6. **Bước 6: Cấu hình Tự Động Sinh Số Lô (A416 / `STB_Vietnam_PackingPrinting`)**
   - Kiểm tra tiền tố VJ hoặc prefix Lot cho từng khách hàng.

7. **Bước 7: Xác nhận QC IQC/PQC đã cấu hình Tiêu Chuẩn Đánh Giá (A510)**
   - Khai báo tiêu chuẩn kiểm tra chất lượng trước khi nạp Lot lên dây chuyền.

8. **Bước 8: Khai báo giá thành phẩm & Đơn giá phế trên B802 (Đặc thù Điện cực - Electrode)**
   - **Giá bán thành phẩm:** Khai báo mã mới vào bảng `STB_ElectrodePriceB802` (cả mã gốc và mã chi tiết như `CRFYN85L-01`).
   - **Đơn giá phế & Tỷ lệ Kg ↔ Mét:** Nếu model có độ dày mới (như size `180`) hoặc hậu tố tên đặc thù (`A301`), cần kiểm tra và bổ sung khai báo trong Function `[dbo].[fn_VVT_ElecErrorPriceMeter2KG]()` để tránh lỗi B802 không nhảy giá phế (Waste Price = 0) và không tự đổi ra mét (Defect Meter = 0).

9. **Bước 9: Kiểm thử Tạo Thử Lot & Nghiệm Thu Dây Chuyền**
   - Tạo thử 1 Lot Test trên WinForm MES.
   - Quét thử trên Kiosk POP tại công đoạn đầu tiên.

---

## 🔍 Tiêu Chí Nghiệm Thu (Acceptance Criteria):
Sau khi hoàn thành 9 bước khai báo, chạy kiểm toán nghiệm thu:
```powershell
# Kiểm tra liên kết 4 bảng MES & POP:
ops trace "<TestLot>"

# Kiểm tra định mức BOM NVL khả dụng trong kho:
pop nvl "<TestLot>"
```

**Bảng Tiêu Chuẩn Đạt Chuẩn:**
- [x] `STB_SetInfo`: Sinh mã Barcode thành công, Model khớp với khai báo.
- [x] `STB_ProdRouteHist`: Có đầy đủ danh mục công đoạn đã tick tại B240.
- [x] Kiosk POP: Màn hình hiện đầy đủ danh sách máy tại B270.
- [x] Nhãn In: Đầy đủ ModelName, Dung lượng (F), Điện áp (V) và Barcode scan được bằng máy quét.
