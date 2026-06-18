## Appendix — QC Table Architecture (DB Verified 2026-06-18)

### A.1 QC Core Tables (20 tables in STB_MaterialQc* family)

| Table | Mô tả | Rows (ước) |
|---|---|---|
| **`STB_MaterialQcInfo`** | **★ Header** — 1 record/Lot QC (35 cols) | ~1M |
| `STB_MaterialQcDetail` | Chi tiết hạng mục kiểm tra per Lot | ~5M |
| `STB_MaterialQcSampleResult` | Kết quả đo mẫu (giá trị thực) | ~20M |
| `STB_MaterialQcInspectionGroup` | Nhóm hạng mục kiểm tra | ~500 |
| **`STB_MaterialQcInspectionItem`** | **★ Config** — Spec limits per MaterialCode (20 cols) | ~5K |
| `STB_MaterialQcInspectionGroup_HY` | Nhóm QC riêng **Hưng Yên** | ~100 |
| `STB_MaterialQcInspectionItem_HY` | Config QC riêng **Hưng Yên** | ~500 |
| `STB_MaterialQcDetail_BendingCutting` | Detail QC **Bending/Cutting** | ~500K |
| `STB_MaterialQcInfo_BendingCutting` | Header QC Bending/Cutting | ~50K |
| `STB_MaterialQcSampleResult_BendingCutting` | Kết quả mẫu Bending | ~2M |
| `STB_MaterialQcInspectionItem_BendingCutting` | Config Bending | ~200 |
| `STB_MaterialQcInspectionItem_PQC_V01_01` | Config PQC version mới | ~200 |
| `STB_MaterialQcInfo_audit` | Audit trail QC | ~100K |
| `STB_MaterialQcInfo_240903` | Backup 2024-09-03 | Archive |
| `STB_MaterialQcDetail_20190920` | Backup 2019-09-20 | Archive |

### A.2 STB_MaterialQcInfo Schema (35 columns — QC Lot Header)

| Column | Type | Mô tả |
|---|---|---|
| `MaterialQcNo` | varchar(20) | **PK** — Số phiếu QC |
| `CompanyCode` | varchar(20) | Mã công ty (VVT/VNT) |
| `WorkCenterCode` | varchar(20) | Mã nhà máy (VVT_F1..F5) |
| `InspectionDocType` | varchar(10) | **Loại QC:** IQC, PQC, OQC |
| `MaterialCode` | varchar(50) | Mã NVL được kiểm |
| `QcQty` | numeric | Số lượng kiểm tra |
| `InspectionType` | varchar(10) | Loại kiểm (Normal/Tightened/Reduced) |
| `TargetSampleQty` | int | Số mẫu yêu cầu |
| `ActualSampleQty` | int | Số mẫu thực tế |
| `MaxAcceptDefectQty` | int | **SL lỗi chấp nhận tối đa** (AQL) |
| `PassedSampleQty` | int | Số mẫu đạt |
| `DefectSampleQty` | int | Số mẫu lỗi |
| **`DecisionResult`** | varchar(10) | **★ PASS/FAIL/HOLD** |
| `DecisionDateTime` | datetime | Thời điểm quyết định |
| `DecisionUserID` | varchar(20) | Người quyết định |
| `VendorLotNo` | varchar(100) | Mã Lot nhà cung cấp |
| `QcMarking` | varchar(50) | Marking QC |
| `CapDungLuong` | nvarchar(40) | Dung lượng (Farad) |

### A.3 STB_MaterialQcInspectionItem Schema (20 columns — QC Spec Config)

> **Đây là bảng định nghĩa giới hạn spec cho từng hạng mục kiểm tra per MaterialCode**

| Column | Type | Mô tả |
|---|---|---|
| `MaterialCode` | varchar(50) | **PK1** — Mã NVL |
| `QcInspectionItemCode` | varchar(20) | **PK2** — Mã hạng mục (VD: Viscosity, Thickness) |
| `InspectionType` | varchar(10) | Loại kiểm |
| `QcSpecDesc` | nvarchar(max) | Mô tả spec |
| `InspectionLevel` | varchar(20) | Mức độ kiểm tra |
| **`AQL`** | numeric | **Acceptable Quality Level** |
| **`SpecValue`** | numeric | **Giá trị tiêu chuẩn** |
| **`USL`** | numeric | **★ Upper Spec Limit** — Giới hạn trên |
| **`LSL`** | numeric | **★ Lower Spec Limit** — Giới hạn dưới |
| **`UCL`** | numeric | **Upper Control Limit** — Kiểm soát trên |
| **`LCL`** | numeric | **Lower Control Limit** — Kiểm soát dưới |
| `TextSpecValue` | nvarchar(400) | Spec dạng text (cho kiểm tra visual) |
| `SampleQty` | int | Số mẫu cần lấy |

> [!NOTE]
> **USL/LSL** = Spec limit (ngoài = NG tuyệt đối)
> **UCL/LCL** = Control limit (ngoài = cảnh báo, cần điều chỉnh)
> Logic QC: Nếu `MeasuredValue > USL` hoặc `MeasuredValue < LSL` → **FAIL**

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: QC Table Architecture (20 tables) + MaterialQcInfo 35 cols + InspectionItem 20 cols (USL/LSL/UCL/LCL/AQL spec). DB verified.*
