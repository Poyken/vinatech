# KB_22 — Dashboard, Andon & Monitoring

> **Màn hình liên quan:** VVT_Check_Production, CellLine Andon, Dashboard, VNT_UPHStatusInfo
> **Verified against DB:** 2026-06-10
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Tổng Quan

Hệ thống monitoring của MES bao gồm 3 lớp:
1. **Dashboard** — Tổng quan sản lượng theo công đoạn (cho quản lý)
2. **Andon** — Bảng hiển thị tại xưởng (cho công nhân + leader)
3. **UPH Tracking** — Theo dõi năng suất (Units Per Hour)

---

## 2. 📊 Dashboard Configuration

### 2.1 Bảng `STB_DashboardRouteInfo`

Cấu hình các công đoạn hiển thị trên Dashboard:

| Cột | Mô tả |
|-----|-------|
| `DashboardRouteCode` | Mã công đoạn trên Dashboard |
| `DashboardRouteName` | Tên hiển thị |
| `ProdRouteTypeCode` | Loại Route (production type) |
| `WorkCenterCode` | Nhà máy |

```sql
-- Xem cấu hình Dashboard
SELECT DashboardRouteCode, DashboardRouteName, ProdRouteTypeCode, WorkCenterCode
FROM STB_DashboardRouteInfo
ORDER BY WorkCenterCode, DashboardRouteCode
```

---

## 3. 📺 Andon Display

### 3.1 Bảng Andon

| Bảng | Chức năng |
|------|-----------|
| `CellLineANDON` | Cấu hình Line nào hiển thị trên Andon |
| `DefectReportsAnDon` | Phế/NG hiển thị trên Andon (VN) |
| `DefectReportsAndon_BG` | Phế/NG hiển thị trên Andon (BG) |
| `ProcessStepsANDON` | Các bước công đoạn trên Andon |

### 3.2 Schema CellLineANDON

| Cột | Mô tả |
|-----|-------|
| `CellLineAndon` | ID (nchar) |
| `CellLineName` | Tên Line hiển thị |

### 3.3 Chỉnh sửa Andon (đã có trong KB_03 §7)

> Để chỉnh số dòng hiển thị trên Andon, xem [KB_03_SAN_XUAT.md §7](KB_03_SAN_XUAT.md).

```sql
-- Xem cấu hình Andon
SELECT * FROM CellLineANDON

-- Xem phế trên Andon
SELECT * FROM DefectReportsAnDon WHERE CreateDateTime >= CAST(GETDATE() AS DATE)
```

---

## 4. ⏱️ UPH (Units Per Hour) Tracking

### 4.1 Bảng liên quan

| Bảng / SP | Chức năng | Màn hình |
|-----------|-----------|----------|
| `STB_DashboardRouteInfo` | Config Route cho tính UPH | — |
| `VNT_UPHStatusInfo` | Màn hình xem UPH | VNT_UPHStatusInfo |
| `VNT_UPHTimeSetupInfo` | Cấu hình thời gian tính UPH | VNT_UPHTimeSetupInfo |

### 4.2 Cách tính UPH

UPH được tính dựa trên:
```
UPH = Số lượng sản phẩm hoàn thành / Thời gian sản xuất thực tế (giờ)
```

Nguồn dữ liệu: `STB_ProdRouteHist` (mỗi scan barcode = 1 record có timestamp).

```sql
-- Tính UPH thô cho 1 Line trong 1 ca
SELECT LineCode, RouteCode,
       COUNT(*) AS TotalUnits,
       DATEDIFF(HOUR, MIN(CreateDateTime), MAX(CreateDateTime)) AS TotalHours,
       CASE WHEN DATEDIFF(HOUR, MIN(CreateDateTime), MAX(CreateDateTime)) > 0
            THEN CAST(COUNT(*) AS FLOAT) / DATEDIFF(HOUR, MIN(CreateDateTime), MAX(CreateDateTime))
            ELSE 0 END AS UPH
FROM STB_ProdRouteHist
WHERE LineCode = 'VELINE-01'
  AND RouteCode = 'V-22' -- Công đoạn Aging
  AND CreateDateTime >= CAST(GETDATE() AS DATE)
GROUP BY LineCode, RouteCode
```

---

## 5. ❓ Câu Hỏi Nghiệp Vụ Cần Xác Minh

1. **Andon hardware:** Màn hình Andon tại xưởng kết nối thế nào? (Web URL hay ứng dụng riêng?)
2. **UPH target:** Có bảng nào lưu target UPH cho từng model/line không?
3. **Real-time:** Dashboard cập nhật real-time hay có delay? Tần suất refresh?
4. **Andon alerts:** Khi phế vượt ngưỡng, có cảnh báo tự động trên Andon không?

---

*Cập nhật: 2026-06-10 — Tạo mới từ truy vấn DB thực tế*
