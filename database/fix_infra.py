import io

file_path = r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Vinatech_MES_Complete_DataFlow.md"

with io.open(file_path, "r", encoding="utf-8") as f:
    text = f.read()

marker = "## Infrastructure & Plant Codes"
index = text.find(marker)

if index != -1:
    before = text[:index]
    after = """## 🏗️ Infrastructure & Plant Codes

| Thành phần | Chi tiết |
|-----------|---------|
| **Server** | `dbserver.hycap.co.kr,5398` |
| **Database chính** | `SmartFactoryV2` |
| **Database phụ** | `SmartFramework` (`STB_LabelInfo`, `usp_DoCreateSerial`) |
| **Auth** | SQL Server Auth: `vinaadmin` |
| **Audit** | `STB_ProcedureLog` ghi log mọi thực thi SP quan trọng |
| **Batch processing** | `OPENXML` + `CURSOR` pattern cho bulk operations |
| **Atomicity** | `BEGIN TRAN` / `ROLLBACK TRAN` cho operations đa bảng |

### 🏭 Nhà máy (Plant Codes)

| Code | Tên | WorkCenterCode | Route Prefix | Ghi chú |
|------|-----|---------------|-------------|---------|
| **VNT** | Nhà máy 1 - Bình Dương | VNT | `V-xx` | Winding -> gửi Korea HQ |
| **VVT** | Nhà máy 2 - Bình Dương | VVT | `E-xx` | Full production cycle |
| **HN** | **Nhà máy 3 - Hà Nam** (PHÁT HIỆN MỚI) | VVT_F3 | `E-xx` | Dùng `FinishGoodMESInstock_HN` |

> **⚠️ QUAN TRỌNG:** `WorkCenterCode='VVT_F3'` dùng label format `'NewVietNam_HN'` trong `usp_DivideAndPrintPackagingLabels`. Nhà máy Hà Nam CHƯA được document trước đây!

### 🗄️ Objects đặc biệt

| Object | Loại | Vai trò |
|--------|------|---------|
| `FinishGoodMESInstock_HN` | VIEW | FG Hà Nam - Dùng trong Phase 5 label printing |
| `SmartFramework.dbo.STB_LabelInfo` | TABLE (DB khác) | Template nhãn in |
| `stb_vvt_OpenExpiredMaterial` | TABLE | Vật tư hết hạn đã phê duyệt (FIFO bypass) |
| `dbo.fnGetJobDateShiftTime` | FUNCTION | Tính JobDate/ShiftCode từ ProcessDateTime |

### 🔗 Cross-Factory: VNT Winding -> Korea HQ
VNT thực hiện Winding -> bán thành phẩm gửi Korea HQ (본사) xử lý tiếp.

**Logic:** `IF LineCompanyCode='VNT' THEN GRWarehouse = lookup REPLACE(RouteCode,'V-','E-')`

> **Lưu ý:** Khai báo GR tại VN location KHÔNG tự động vào danh sách nhập dự kiến - phải làm thủ công.

---

## 🚫 SP Không tìm thấy trong Database

| SP | Ghi chú |
|----|---------|
| `usp_ExportWarehouseFinshGood_RD_HN_uid` | Không tồn tại trong `SmartFactoryV2`. Cần kiểm tra lại lịch sử đổi tên hoặc nằm ở DB khác. |

---

## ⚠️ Khoảng trống ngoài 21 SPs đã phân tích

Các quy trình này là **bắt buộc** trong thực tế nhưng **chưa** nằm trong danh sách 21 SPs được giao kiểm tra (được thực hiện bởi UI MES hoặc các SPs khác):

| Bước | Tables liên quan | Ghi chú / Cách thực hiện giả định |
|------|-----------------|---------------|
| Tạo lệnh SX (PONo) | `STB_ProductionOrderInfo`, `STB_ProductionOrderRouting`, `STB_ProductionOrderBom` | SP khác / Tạo trên giao diện UI MES |
| Lập kế hoạch ngày | `STB_DayPlanInfo`, `STB_DayPlanDetail` | Nhập tay / Hệ thống MRP đồng bộ sang |
| In barcode SX | `STB_SetInfo` (`ControlNo`) | Chức năng in barcode trên UI MES gọi SP tạo mã |
| Quản lý ca làm việc | `dbo.fnGetJobDateShiftTime` | Có function tính tự động dựa vào `ProcessDateTime` |

---

*Tài liệu tổng hợp từ 21 SPs trong `SmartFactoryV2` - Phiên bản cập nhật 2026-04-09.*
*Bổ sung quan trọng: Phase 2.5 (Chuẩn bị SX), Nhà máy Hà Nam (VVT_F3), Cross-factory flow.*
"""
    with io.open(file_path, "w", encoding="utf-8") as f:
        f.write(before + after)
    print("Document successfully updated.")
else:
    print("Marker not found.")
