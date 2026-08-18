# 🅰️ A-Series: Master Data & System Setup

| Screen | Tên / Chức Năng | Search SP (`_get`) | Execute SP (`_iud`) | Bảng DB Chính | Ghi Chú & Bẫy Vận Hành |
|---|---|---|---|---|---|
| **A230** | Danh mục vật tư (Material Master) | `usp_MaterialMaster_get` | `usp_MaterialMaster_iud` | `STB_MaterialMaster` | Tab "Mã nguyên liệu" cần khai báo `MaterialThickness` để hiển thị trên B442 |
| **A310** | Cấu hình BOM | `usp_BomHeader_get` | `usp_BomHeader_iud` | `STB_BomHeader`, `STB_BomDetail` | Quản lý công thức định mức NVL theo từng công đoạn |
| **A320** | Cấu hình Route | `usp_RouteInfo_get` | `usp_RouteInfo_iud` | `STB_RouteInfo` | Định tuyến chuỗi công đoạn V-22 ➔ V-28 |
| **A410** | Thông số Model (ModelBasicInfo) | `usp_ModelBasicInfo_get` | `usp_ModelBasicInfo_iud` | `STB_ModelBasicInfo` | **Bắt buộc khi thêm model mới.** Khai báo Vol, Farad, OqcType |
| **A419** | Tiêu chuẩn đóng gói | `usp_PackingStandard_get` | `usp_PackingStandard_iud` | `STB_PackingStandard` | Cấu hình số lượng chiếc/box để không bị chặn tại B523 |
| **A460** | Cấu hình In Tem | `usp_ModelLabelInfo_get` | `usp_DoMakeModelLabelInfo` | `STB_ModelLabelInfo`, `STB_LabelInfo` | Ánh xạ ModelCode với mẫu tem ở Z530 |
