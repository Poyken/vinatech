# KB_20 — Máy Móc, Bảo Trì & Spare Part

> **Màn hình liên quan:** B250, B270, MCM (Machine Repair), VVT_MeasurementControlList, H301-H305
> **Verified against DB:** 2026-06-10
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Tổng Quan

Hệ thống MES quản lý máy móc qua 3 nhóm chức năng chính:
1. **Master Data Máy** — Đăng ký, phân bổ máy theo Line/Route
2. **Bảo trì & Sửa chữa** — Ghi nhận sự cố, chi phí, nhân công
3. **Hiệu chuẩn thiết bị đo** — Theo dõi lịch sử và nhắc hạn hiệu chuẩn
4. **Spare Part (Phụ tùng)** — Quản lý kho phụ tùng, xuất/nhập/tồn

---

## 2. 🔧 Master Data Máy Móc

### 2.1 Bảng chính

| Bảng | Chức năng | Màn hình |
|------|-----------|----------|
| `STB_MachineMaster` | Thông tin master máy | B250 |
| `STB_ProductMachine` | Mapping máy ↔ Route (máy nào chạy công đoạn nào) | B270 |
| `STB_MachineCapacity` | Năng lực sản xuất của máy | — |

### 2.2 Tra cứu máy

```sql
-- Xem tất cả máy active theo Line
SELECT MachineCode, MachineName, LineCode, WorkCenterCode
FROM STB_MachineMaster
WHERE IsUsed = 1
ORDER BY LineCode, MachineCode

-- Xem mapping máy ↔ Route
SELECT PM.MachineCode, PM.RouteCode, MM.MachineName, MM.LineCode
FROM STB_ProductMachine PM
JOIN STB_MachineMaster MM ON PM.MachineCode = MM.MachineCode
WHERE PM.MaterialCode = 'ECVT30-367' -- Model cần kiểm tra
ORDER BY PM.RouteCode
```

---

## 3. 🛠️ Bảo Trì & Sửa Chữa Máy

### 3.1 Luồng bảo trì

```
Máy hỏng/Lỗi phát sinh
    ↓
STB_MachineRepairHistory — Ghi nhận sự cố
    ├── MachineCode, JobDate, JobStartDateTime, JobEndDateTime
    ├── TroublePoint (Vị trí hỏng)
    ├── TroubleText (Mô tả lỗi)
    ├── RepairText (Cách sửa)
    ├── TotalRepairCost (Chi phí sửa chữa)
    └── IsMachineLoss (Máy có bị mất sản lượng?)
         │
         ├── STB_MachineRepairWorker — Kỹ thuật viên phụ trách
         │   ├── MachineRepairWorkerCode
         │   ├── MachineRepairWorkerName
         │   └── BasicCost (Chi phí nhân công cơ bản)
         │
         └── STB_MachineRepairMaterialHist — NVL/phụ tùng dùng để sửa
```

### 3.2 Tra cứu lịch sử sửa chữa

```sql
-- Xem lịch sử sửa chữa máy trong 30 ngày gần nhất
SELECT MachineRepairHistoryNo, MachineCode, JobDate,
       TroublePoint, TroubleText, RepairText, TotalRepairCost,
       DATEDIFF(MINUTE, JobStartDateTime, JobEndDateTime) AS RepairMinutes
FROM STB_MachineRepairHistory
WHERE JobDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY JobDate DESC

-- Xem kỹ thuật viên sửa chữa
SELECT * FROM STB_MachineRepairWorker WHERE IsUsed = 1
ORDER BY WorkCenterCode, MachineRepairWorkerName
```

---

## 4. 📏 Hiệu Chuẩn Thiết Bị Đo

### 4.1 Bảng liên quan

| Bảng | Chức năng | Màn hình |
|------|-----------|----------|
| `STB_MeasurementControlCalibrateHistory_VVT` | Lịch sử hiệu chuẩn | VVT_MeasurementControlList |
| `STB_IoTCalibrationHist` | Lịch sử hiệu chuẩn IoT | — |

### 4.2 Schema lịch sử hiệu chuẩn

```
STB_MeasurementControlCalibrateHistory_VVT
    ├── ID (PK, auto-increment)
    ├── ManagementNo (Mã quản lý thiết bị)
    ├── SerialNo (Số seri)
    ├── DayOfCalibration (Ngày hiệu chuẩn)
    ├── Remark (Ghi chú)
    └── Note (Chi tiết)
```

### 4.3 Tra cứu hiệu chuẩn

```sql
-- Xem lịch sử hiệu chuẩn của thiết bị
SELECT ManagementNo, SerialNo, DayOfCalibration, Remark, Note
FROM STB_MeasurementControlCalibrateHistory_VVT
WHERE ManagementNo = 'MÃ_QUẢN_LÝ'
ORDER BY DayOfCalibration DESC

-- Tìm thiết bị sắp hết hạn hiệu chuẩn (trong 30 ngày tới)
-- Logic: DayOfCalibration + CycleMonth < GETDATE() + 30
```

---

## 5. 📦 Spare Part (Phụ Tùng) Management

### 5.1 Bảng chính

| Bảng | Chức năng |
|------|-----------|
| `STB_VNSparePartInfo` | Master phụ tùng VN (thông tin cơ bản, spec, giá) |
| `STB_VNSparePartStockInfo` | Tồn kho phụ tùng |
| `STB_VNSparePartIOHistory` | Lịch sử xuất/nhập phụ tùng |
| `STB_VNSparePartChangeHistory` | Lịch sử thay đổi thông tin |
| `STB_VNSparePartBasicLocation` | Vị trí lưu trữ |
| `STB_VN_SparePartLineUsage` | Phụ tùng theo Line |
| `STB_VN_SpecialSparePartInfo` | Phụ tùng đặc biệt |
| `STB_VN_SpecialSparePartLotInfo` | Lot phụ tùng đặc biệt |
| `STB_VN_SpecialSparePartIOHist` | Xuất/nhập phụ tùng đặc biệt |
| `STB_VN_SpecialSparePartCurrent` | Tồn kho phụ tùng đặc biệt hiện tại |

### 5.2 Luồng quản lý Spare Part

```
H301 — Đăng ký mã phụ tùng mới (STB_VNSparePartInfo)
    ↓
H302 — Nhập phụ tùng vào kho (STB_VNSparePartIOHistory, STB_VNSparePartStockInfo)
    ↓
H303 — Xuất phụ tùng cho Line (STB_VN_SparePartLineUsage)
    ↓
H304 — Kiểm tra tồn kho (STB_VNSparePartStockInfo)
    ↓
H305 — Lịch sử xuất/nhập (STB_VNSparePartIOHistory)
```

### 5.3 Schema chi tiết `STB_VNSparePartInfo`

| Cột | Mô tả |
|-----|-------|
| `SparePartCode` | Mã phụ tùng (PK) |
| `SparePartName` | Tên phụ tùng |
| `SparePartSpec01-05` | Thông số kỹ thuật (5 cột) |
| `BasicUnitPrice` | Đơn giá cơ bản |
| `BasicDeliveryDay` | Thời gian giao hàng (ngày) |
| `SafeQty` | Mức tồn kho an toàn tối thiểu |
| `MaxSafeQty` | Mức tồn kho an toàn tối đa |
| `CurrentStock` | Tồn kho hiện tại |
| `TypeCode` | Phân loại phụ tùng |
| `Position` / `PositionBG` | Vị trí lưu trữ (VN / BG) |
| `IsSpecial` | Phụ tùng đặc biệt (1=Yes) |
| `LastDeliveryVendor` | NCC giao hàng gần nhất |

### 5.4 Tra cứu Spare Part

```sql
-- Xem tồn kho phụ tùng (dưới mức an toàn)
SELECT SparePartCode, SparePartName, CurrentStock, SafeQty,
       CASE WHEN CurrentStock < SafeQty THEN 'CẦN ĐẶT HÀNG' ELSE 'OK' END AS Status
FROM STB_VNSparePartInfo
WHERE IsUsed = 1 AND CurrentStock < SafeQty
ORDER BY CurrentStock ASC

-- Xem lịch sử xuất/nhập phụ tùng
SELECT * FROM STB_VNSparePartIOHistory
WHERE SparePartCode = 'MÃ_PHỤ_TÙNG'
ORDER BY CreateDateTime DESC

-- Xóa mã spare part thừa (đã có trong KB_02 §4.14)
SELECT * FROM STB_VNSparePartInfo WHERE SparePartCode = '[Mã cần xóa]'
DELETE FROM STB_VNSparePartInfo WHERE SparePartCode = '[Mã cần xóa]'
```

---

## 6. ❓ Câu Hỏi Nghiệp Vụ Cần Xác Minh

> Các câu hỏi dưới đây cần được xác minh với bộ phận vận hành/bảo trì:

1. **Flow bảo trì phòng ngừa (Preventive Maintenance):** Hệ thống có quản lý lịch bảo trì định kỳ không? Hay chỉ ghi nhận sửa chữa đột xuất?
2. **Tích hợp IoT:** `STB_IoTCalibrationHist` — Có thiết bị IoT nào đang kết nối tự động ghi dữ liệu hiệu chuẩn?
3. **Chi phí bảo trì:** `TotalRepairCost` trong `STB_MachineRepairHistory` có được tổng hợp vào báo cáo chi phí sản xuất?
4. **Spare Part đặc biệt vs thường:** Phân biệt giữa `STB_VNSparePartInfo` và `STB_VN_SpecialSparePartInfo` — tiêu chí nào để xác định phụ tùng là "đặc biệt"?

---

*Cập nhật: 2026-06-10 — Tạo mới từ truy vấn DB thực tế*
