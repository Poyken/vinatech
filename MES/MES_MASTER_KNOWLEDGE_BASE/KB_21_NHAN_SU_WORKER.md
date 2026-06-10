# KB_21 — Nhân Sự, Worker & Quản Lý Ca

> **Màn hình liên quan:** B260, VVT_WorkGroupManagement, VNT_WorkerTakeoverInfo, K101
> **Verified against DB:** 2026-06-10
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Tổng Quan

Hệ thống MES quản lý nhân sự sản xuất qua các chức năng:
1. **Đăng ký công nhân** — Master data nhân viên sản xuất
2. **Phân nhóm ca/tổ** — Gán công nhân vào nhóm chi phí
3. **Gán công nhân vào Line** — Quản lý ai chạy Line nào
4. **Giao ca (Takeover)** — Bàn giao thông tin giữa các ca
5. **Tracking công nhân theo Barcode** — Ghi nhận ai xử lý viên tụ nào

---

## 2. 👤 Master Data Công Nhân (`STB_ProdWorkerInfo`)

### 2.1 Schema

| Cột | Mô tả | Ví dụ |
|-----|-------|-------|
| `WorkerCode` | Mã công nhân (PK) | `VES-019` |
| `WorkerName` | Tên hiển thị (tiếng Hàn) | — |
| `OrgWorkerName` | Tên gốc (tiếng Việt) | `Nguyễn Văn A` |
| `EmpNo` | Mã nhân viên (HR) | — |
| `Nationality` | Quốc tịch | `VN` |
| `IsProdWorker` | Là công nhân sản xuất | `1` = Yes |
| `WorkerGroupCode` | Nhóm công nhân | `VE-01`, `VE-02` |
| `LineCode` | Line hiện tại | `VELINE-01` |
| `DATEJOIN` | Ngày vào làm | — |
| `IsUsed` | Còn hoạt động | `1` = Active |
| `WorkCenterCode` | Nhà máy | `VVT_F1`, `VVT_F3` |

### 2.2 Tra cứu công nhân

```sql
-- Danh sách công nhân active theo Line
SELECT WorkerCode, OrgWorkerName, WorkerGroupCode, LineCode, DATEJOIN
FROM STB_ProdWorkerInfo
WHERE IsUsed = 1 AND IsProdWorker = 1
ORDER BY LineCode, WorkerCode

-- Tìm công nhân theo mã hoặc tên
SELECT * FROM STB_ProdWorkerInfo
WHERE WorkerCode = 'VES-019' OR OrgWorkerName LIKE N'%Nguyễn%'
```

---

## 3. 👥 Nhóm Công Nhân & Chi Phí

### 3.1 Bảng liên quan

| Bảng | Chức năng |
|------|-----------|
| `STB_WorkerGroupInfo` | Định nghĩa nhóm (tổ/ca) |
| `STB_CostGroupWorkerMapping` | Gán công nhân vào nhóm chi phí |
| `STB_CostGroupWorkerMappingHist` | Lịch sử thay đổi nhóm |
| `STB_WorkerAssingStatus` | Trạng thái phân công |

### 3.2 Schema nhóm (`STB_WorkerGroupInfo`)

| Cột | Mô tả |
|-----|-------|
| `CostGroupCode` | Mã nhóm (PK) |
| `CostGroupName` | Tên nhóm |
| `CompanyCode` | Công ty |
| `WorkCenterCode` | Nhà máy |

```sql
-- Xem các nhóm công nhân
SELECT * FROM STB_WorkerGroupInfo ORDER BY CostGroupCode

-- Xem mapping công nhân ↔ nhóm chi phí
SELECT CGM.CostGroupCode, WGI.CostGroupName, CGM.WorkerCode, PW.OrgWorkerName
FROM STB_CostGroupWorkerMapping CGM
JOIN STB_WorkerGroupInfo WGI ON CGM.CostGroupCode = WGI.CostGroupCode
JOIN STB_ProdWorkerInfo PW ON CGM.WorkerCode = PW.WorkerCode
ORDER BY CGM.CostGroupCode
```

---

## 4. 🔄 Giao Ca (Worker Takeover)

### 4.1 Schema (`STB_WorkerTakeoverInfo`)

| Cột | Mô tả |
|-----|-------|
| `WorkerTakeoverNo` | Mã bàn giao (PK) |
| `JobDate` | Ngày bàn giao |
| `TimeShiftCode` | Ca làm việc |
| `TakeoverContent` | Nội dung bàn giao |
| `TakeoverLineCode` | Line bàn giao |
| `WriteWorkerCode` | Người ghi bàn giao |
| `IsConfirm` | Đã xác nhận bởi ca sau |
| `ConfirmWorkerCode` | Người xác nhận |
| `ConfirmDateTime` | Thời gian xác nhận |

### 4.2 Flow bàn giao ca

```
Ca Cũ kết thúc
    ↓
WriteWorkerCode ghi nhận TakeoverContent
    (Tình trạng máy, sản phẩm dở dang, lưu ý đặc biệt...)
    ↓
Ca Mới bắt đầu
    ↓
ConfirmWorkerCode xác nhận đã nhận bàn giao (IsConfirm = 1)
```

```sql
-- Xem bàn giao ca gần nhất
SELECT WorkerTakeoverNo, JobDate, TimeShiftCode, TakeoverLineCode,
       TakeoverContent, WriteWorkerCode, IsConfirm, ConfirmWorkerCode
FROM STB_WorkerTakeoverInfo
WHERE JobDate >= DATEADD(DAY, -7, GETDATE())
ORDER BY JobDate DESC, WriteDateTime DESC
```

---

## 5. 📊 Tracking Công Nhân Theo Barcode

### 5.1 Bảng `STB_ProdRouteWorkerHist`

Mỗi khi công nhân scan barcode tại công đoạn, hệ thống ghi nhận:

| Cột | Mô tả |
|-----|-------|
| `PRWHNo` | ID auto-increment |
| `ProdRouteHistNo` | Liên kết đến `STB_ProdRouteHist` (lịch sử công đoạn) |
| `WorkerCode` | Mã công nhân thực hiện |

```sql
-- Tra cứu ai xử lý viên tụ nào tại công đoạn nào
SELECT PRWH.WorkerCode, PW.OrgWorkerName,
       PRH.ControlNo, PRH.RouteCode, PRH.CreateDateTime
FROM STB_ProdRouteWorkerHist PRWH
JOIN STB_ProdRouteHist PRH ON PRWH.ProdRouteHistNo = PRH.ProdRouteHistNo
JOIN STB_ProdWorkerInfo PW ON PRWH.WorkerCode = PW.WorkerCode
WHERE PRH.ControlNo = 'MÃ_BARCODE' -- Thay barcode cần tra
ORDER BY PRH.CreateDateTime ASC
```

---

## 6. 🕐 Chấm Công & Attendance

### 6.1 Bảng liên quan

| Bảng | Chức năng |
|------|-----------|
| `STB_VN_ATTENDANCE_TIME` | Giờ vào/ra của công nhân |
| `STB_VN_EMPLOYEEATTENDANCETRANSTER` | Chuyển đổi dữ liệu chấm công |
| `STB_TechnicalPersonnelAttendanceInfo` | Chấm công kỹ thuật viên |
| `STB_ESDAreaWorkerInOutHist` | Ra/vào khu vực ESD |

```sql
-- Xem chấm công kỹ thuật viên
SELECT * FROM STB_TechnicalPersonnelAttendanceInfo
WHERE AttendDate >= DATEADD(DAY, -7, GETDATE())
ORDER BY AttendDate DESC
```

---

## 7. ❓ Câu Hỏi Nghiệp Vụ Cần Xác Minh

1. **WorkerGroupCode convention:** `VE-01`, `VE-02`... phân theo tiêu chí gì? (Ca sáng/chiều/đêm? Hay theo tổ?)
2. **Chấm công:** `STB_VN_ATTENDANCE_TIME` có kết nối với máy chấm công vân tay/thẻ từ không?
3. **ESD Area:** `STB_ESDAreaWorkerInOutHist` — có bắt buộc quét thẻ khi vào khu vực ESD?
4. **Liên kết HR:** Dữ liệu `STB_ProdWorkerInfo` có tự sync từ Groupware HR module?

---

*Cập nhật: 2026-06-10 — Tạo mới từ truy vấn DB thực tế*
