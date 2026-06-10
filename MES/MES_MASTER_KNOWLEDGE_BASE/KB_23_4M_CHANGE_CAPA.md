# KB_23 — 4M Change, CAPA & Defect Management

> **Màn hình liên quan:** VVT_DoCreateQC4MChange, VVT_View4MChange, VVT_CAPAInputSeparateLot, VVTDefectRepairByBarcode
> **Verified against DB:** 2026-06-10
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Tổng Quan

Quản lý thay đổi 4M và hành động khắc phục trong hệ thống MES:
- **4M Change** — Man, Machine, Material, Method — Ghi nhận bất kỳ thay đổi nào trên 4 yếu tố này
- **CAPA** — Corrective And Preventive Action — Hành động khắc phục/phòng ngừa
- **Defect Repair** — Sửa chữa sản phẩm lỗi (tái chế)

---

## 2. 🔄 4M Change Management

### 2.1 Schema (`STB_QC4MChangeDataRecord`)

| Cột | Mô tả |
|-----|-------|
| `QC4MNo` | Mã 4M Change (PK) |
| `ApprovalType` | Loại phê duyệt |
| `ChangeType4M` | Loại thay đổi (Man/Machine/Material/Method) |
| `Level` | Mức độ ảnh hưởng |
| `Factory` | Nhà máy |
| `Model` | Model bị ảnh hưởng |
| `LineCode` | Line bị ảnh hưởng |
| `RouteCode` | Công đoạn bị ảnh hưởng |
| `LotNo1/2/3` | Lot bị ảnh hưởng (tối đa 3 Lot) |
| `DetailedChangeCategories` | Phân loại chi tiết |
| `ReasonForChange` | Lý do thay đổi |
| `ConditionsBefChange` | Điều kiện TRƯỚC thay đổi |
| `ConditionsAftChange` | Điều kiện SAU thay đổi |
| `QualityAssuranceContent` | Nội dung đảm bảo chất lượng |
| `ApprovalDate` | Ngày phê duyệt |
| `EffectiveDate` | Ngày có hiệu lực |
| `Conclusion` | Kết luận |
| `Inspector` | Người kiểm tra |
| `Status` | Trạng thái (Open/Closed) |
| `Change4MImageUrl` | Hình ảnh minh chứng |

### 2.2 Flow 4M Change

```
Phát hiện thay đổi (Man/Machine/Material/Method)
    ↓
VVT_DoCreateQC4MChange — Tạo bản ghi 4M Change
    ├── Điền: ChangeType4M, Model, LineCode, RouteCode
    ├── Điền: ReasonForChange, ConditionsBefChange, ConditionsAftChange
    ├── Upload: Change4MImage (minh chứng)
    └── Submit cho phê duyệt
         ↓
VVT_ViewDetailQC4MChange — Xem chi tiết & phê duyệt
    ├── Inspector kiểm tra
    ├── ApprovalDate = ngày phê duyệt
    └── Status → Closed
         ↓
VVT_View4MChange — Xem lịch sử tất cả 4M Changes
```

### 2.3 Tra cứu 4M Change

```sql
-- Xem 4M Change gần nhất
SELECT QC4MNo, ChangeType4M, Model, LineCode, RouteCode,
       ReasonForChange, Status, ApprovalDate, EffectiveDate
FROM STB_QC4MChangeDataRecord
WHERE CreateDateTime >= DATEADD(MONTH, -1, GETDATE())
ORDER BY CreateDateTime DESC

-- Lọc theo loại thay đổi
SELECT * FROM STB_QC4MChangeDataRecord
WHERE ChangeType4M = 'Material' -- Man, Machine, Material, Method
ORDER BY CreateDateTime DESC
```

---

## 3. 🔧 CAPA (Corrective And Preventive Action)

### 3.1 Màn hình liên quan

| Màn hình | Chức năng |
|----------|-----------|
| `VVT_CAPAInputSeparateLot` | Tách Lot để kiểm tra CAPA riêng |
| `VVT_CAPA_input_divison_test` | Test CAPA input |

### 3.2 Flow CAPA

```
Phát hiện lỗi (từ QC/OQC/Customer Complaint)
    ↓
Tạo CAPA Request
    ├── Xác định Root Cause
    ├── Tách Lot bị ảnh hưởng (VVT_CAPAInputSeparateLot)
    └── Kiểm tra riêng Lot tách
         ↓
Thực hiện Corrective Action
    ├── Sửa đổi quy trình/thiết bị/vật liệu
    └── Ghi nhận kết quả
         ↓
Verify & Close CAPA
```

---

## 4. 🔍 Defect Repair (Sửa Chữa Sản Phẩm Lỗi)

### 4.1 Bảng liên quan

| Bảng | Chức năng |
|------|-----------|
| `STB_DefectRepairInfo` | Thông tin sửa chữa sản phẩm lỗi |
| `STB_DefectRepairDetailInfo` | Chi tiết hạng mục sửa |
| `STB_DefectRepairPartInfo` | Phụ tùng/NVL dùng để sửa |
| `STB_ManualDefectInfo` | Nhập lỗi thủ công |

### 4.2 Tra cứu lịch sử sửa chữa

```sql
-- Xem lịch sử sửa chữa sản phẩm lỗi
SELECT * FROM STB_DefectRepairInfo
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
ORDER BY CreateDateTime DESC
```

---

## 5. 📋 Defect Group & Cause (Phân loại lỗi)

### 5.1 Bảng master

| Bảng | Chức năng |
|------|-----------|
| `STB_DefectGroup` | Nhóm lỗi (Major, Minor, Critical) |
| `STB_DefectInfo` | Danh sách mã lỗi chi tiết |
| `STB_DefectCauseGroup` | Nhóm nguyên nhân |
| `STB_DefectCauseInfo` | Chi tiết nguyên nhân lỗi |
| `STB_DefectCauseNG` | Mapping nguyên nhân ↔ NG |
| `STB_DefectProductionCost` | Chi phí phế theo lỗi |

### 5.2 Tra cứu mã lỗi

```sql
-- Xem danh sách mã lỗi active
SELECT DefectCode, DefectName, DefectGroupCode
FROM STB_DefectInfo
WHERE IsUsed = 1
ORDER BY DefectGroupCode, DefectCode

-- Xem nhóm nguyên nhân lỗi
SELECT * FROM STB_DefectCauseGroup ORDER BY DefectCauseGroupCode
```

---

## 6. 📊 QC Defect Report (Báo Cáo Lỗi QC)

### 6.1 Bảng liên quan

| Bảng | Chức năng |
|------|-----------|
| `STB_QcDefectReport` | Báo cáo lỗi QC |
| `STB_QcDefectReportDeleteLog` | Log xóa báo cáo |
| `STB_QcDefectReportReInspectionResult` | Kết quả kiểm tra lại |
| `STB_IOQCDefectDetail` | Chi tiết lỗi IQC/OQC |
| `STB_IOQCDefectInfo` | Thông tin lỗi IQC/OQC |
| `STB_IQcDefectReport` | Báo cáo lỗi IQC |
| `STB_QCDefectDetailsRecord` | Chi tiết record lỗi |
| `STB_QCDefectDetailsRecordDeleteHist` | Lịch sử xóa record lỗi |

---

## 7. ❓ Câu Hỏi Nghiệp Vụ Cần Xác Minh

1. **4M Change approval:** Ai có quyền phê duyệt 4M Change? (QC Manager? Production Manager?)
2. **CAPA tracking:** Có KPI theo dõi thời gian close CAPA không?
3. **Defect Repair flow:** Sản phẩm sau khi sửa chữa có quay lại line sản xuất hay đi riêng?
4. **Customer Complaints:** `STB_CustomerComplaintsDefectTypeInfo` — liên kết thế nào với CAPA?

---

*Cập nhật: 2026-06-10 — Tạo mới từ truy vấn DB thực tế*
