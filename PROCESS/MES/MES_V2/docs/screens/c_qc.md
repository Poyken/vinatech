# 🆂 C-Series: Quality Control & Inspection

| Screen | Tên / Chức Năng | Search SP (`_get`) | Execute SP (`_iud`) | Bảng DB Chính | Ghi Chú & Bẫy Vận Hành |
|---|---|---|---|---|---|
| **C121/C122** | QC Inspection Setup | `usp_CommInspSelectGroup_get` | `usp_CommInspSelectGroup_iud` | `STB_CommInspSelectGroup` | Cấu hình nhóm tiêu chuẩn kiểm tra đầu vào |
| **C220** | IQC Confirmation | `usp_MaterialQcInfo_get` | `usp_DoUpdateMaterialQcInfo_Success` | `STB_MaterialQcInfo` | Yêu cầu F330 tạo tem trước để không bị trống lưới |
| **C321** | Defect Repair & Scrap | `usp_Vietnam_GetDefectRepairInfo_ForRepair` | `usp_DoProcessLossForBarcode_VNT` | `STB_DefectRepairInfo` | Sửa chữa phế phẩm và nhập kho thành phẩm |
| **C443** | PQC Verification | `usp_GetCommInspection_HistoryForBarcode_Vietnam` | `usp_DoFinishCommInspDoc_VNT` | `STB_CommInspDocHistory` | Xóa trong `CommInspDocHistory` để reset tiêu chuẩn cũ |
| **C512** | OQC Lot Management | `usp_GetMaterialOQcInfo` | `usp_DoMakeMaterialQcSampleResult` | `STB_MaterialQcInfo` | Kiểm tra ModelBasicInfo nếu không tìm thấy Lot |
| **C530** | OQC Audit (Core OQC) | `usp_MaterialQcDetail_get` | `usp_DoUpdateMaterialQcInfo_Success` | `STB_MaterialQcInfo` | Đánh giá chất lượng xuất xưởng PASS / FAIL / HOLD |
| **C546** | FOQC OCV / ESR | `usp_MaterialQcSampleResult_get` | `usp_Vietnam_MaterialFOQcDetail_get` | `STB_MaterialQcSampleResult` | Đo điện áp OCV và nội trở ESR tự động |
