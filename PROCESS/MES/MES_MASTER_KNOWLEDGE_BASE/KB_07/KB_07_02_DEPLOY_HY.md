<!--
AI-READY METADATA
Purpose: Cẩm nang kỹ thuật & Danh mục 93 Stored Procedures cô lập, Bảng FG/VPC, Server-Side Layout Cloning & T-SQL Deployment cho Hưng Yên (VVT_F5)
Scope: Hung Yen VVT_F5 Technical Deployment, 93 Isolated SPs & Schema
Single Source of Truth: KB_07_02_DEPLOY_HY.md (Hung Yen Deployment & SP Isolation)
Target Screens: HY103, HY141, HY143, HY151, HY220, HY311, HY312, HY330, HY430, HY431, HY443, HY530, HY540, HY541, HY620, HY740, HYFG01, D051, D100, D110
Target Tables: STB_ScreenInfo, STB_ScreenLayoutInfo, STB_VN_FINISHGOODS_HY, STB_VN_FINISHGOODS_HY_NEW, STB_VPCLinePlan, VPC_Performance
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)
  - [KB_07_01_OVERVIEW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md)
  - [KB_07_03_SCREEN_BUGS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md)
-->

# KB_07_02 — Hưng Yên Technical SP Reference & Deployment Guide

> **Nhà máy:** Hưng Yên (`VVT_F5` / `VNT_F5`)  
> **Tổng SP cô lập:** 93 Stored Procedures có hậu tố `_HY`  
> **Bảng FG & VPC:** `STB_VN_FINISHGOODS_HY`, `STB_VPCLinePlan`, `VPC_Performance`  
> ← [Về Master Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)

---

## 1. ⚙️ Danh Mục 93 Stored Procedures Cô Lập Nhà Máy Hưng Yên (`_HY` Hậu Tố)

Nhằm đảm bảo tính độc lập vận hành cho xưởng Hưng Yên (`VVT_F5`) mà không làm ảnh hưởng tới logic của Bắc Ninh (`VVT_F1`), Bắc Giang (`VVT_F2`/`VVT_F4`) và Hà Nam (`VVT_F3`), hệ thống triển khai bộ **93 Stored Procedures cô lập**:

### 1.1 Nhóm Phân Hệ Điện Cực Electrode (24 SPs)
| Stored Procedure Name | Chức Năng Nghiệp Vụ |
| :--- | :--- |
| `usp_ElectrodeMixInfo_HY_get` / `_iud` | Quản lý thông tin trộn nguyên liệu điện cực Hưng Yên |
| `usp_ElectrodeMixStepInfo_HY_get` / `_iud` | Chi tiết các bước trộn dung dịch điện cực |
| `usp_ElectrodeCoatingInfo_HY_get` / `_iud` | Phủ Coating điện cực Hưng Yên |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_get` / `_iud` | Kiểm tra ngoại quan cuộn Coating |
| `usp_ElectrodeOven_HY_get` / `_iud` | Sấy lò điện cực Hưng Yên |
| `usp_ElectrodeRollPressingInfo_HY_get` / `_iud` | Ép cuộn Rollpress điện cực Hưng Yên |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_get` / `_iud` | Kiểm tra ngoại quan ép cuộn |
| `usp_ElectrodeSlittingInfo_HY_get` / `_iud` | Cắt cuộn Slitting điện cực Hưng Yên |
| `usp_ElectrodeSlittingResult_HY_get` / `_iud` | Kết quả sản lượng cuộn Slitting |
| `usp_ElectrodeStep_HY_get` / `_iud` | Cấu hình quản lý các bước công đoạn điện cực |
| `usp_ElectrodeCommon_HY_get` / `_iud` | Hàm tiện ích chung phân hệ điện cực |
| `usp_ElectrodeWasteInfoNew_HY_iud` | Quản lý phế liệu phát sinh điện cực Hưng Yên |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | Đo độ nhớt Viscosity dung dịch Coating |

### 1.2 Nhóm Quản Lý Chất Lượng QC & IQC (18 SPs)
| Stored Procedure Name | Chức Năng Nghiệp Vụ |
| :--- | :--- |
| `usp_MaterialQcInfo_HY_get` / `_iud` | Thông tin tổng hợp phiếu kiểm tra QC NVL |
| `usp_MaterialQcDetail_HY_get` / `_iud` | Chi tiết kết quả đo kiểm IQC nguyên vật liệu |
| `usp_MaterialQcSampleResult_HY_get` / `_iud` | Kết quả đo mẫu thử phá hủy/ngoại quan |
| `usp_DoMakeMaterialIQCDetailList_HY` | Tự động sinh danh sách chỉ tiêu IQC cho lô NVL mới |
| `usp_DoMakeMaterialQcSampleResult_HY` | Tạo bản ghi lưu kết quả đo mẫu IQC |
| `usp_DoChangeMaterialQcToPass_HY` | Phê duyệt chuyển trạng thái lô NVL sang PASS |
| `usp_DoUpdateMaterialQcInfo_Fail_HY` / `_Success_HY` | Cập nhật kết luận cuối cùng phiếu IQC |
| `usp_IQcDefectReport_HY_iud` | Đăng ký báo cáo lỗi IQC Hưng Yên |
| `usp_DoSendEmailForDefectReportIQC_HY` | Gửi email cảnh báo tự động khi phát sinh lỗi IQC |
| `usp_QcInspectionGroup_HY_get` / `_iud` | Quản lý nhóm chỉ tiêu kiểm tra QC Hưng Yên |
| `usp_MaterialQcInspectionItem_ByMaterial_HY_get` / `_iud` | Gán hạng mục kiểm tra theo mã vật tư |

### 1.3 Nhóm Quản Lý Sản Xuất Production (13 SPs)
| Stored Procedure Name | Chức Năng Nghiệp Vụ |
| :--- | :--- |
| `usp_DayProdPlan_HY_get` / `_iud` | Lập và quản lý kế hoạch sản xuất ngày Hưng Yên |
| `usp_DoCancelDayProdPlan_HY` | Hủy kế hoạch sản xuất ngày |
| `usp_DoFixDayProdPlan_HY` | Khóa/Duyệt kế hoạch sản xuất ngày |
| `usp_ProductionOrderInfo_HY_get` | Tra cứu lệnh sản xuất PO Hưng Yên |
| `usp_ProductionOrderBom_HY_get` | Đọc BOM định mức vật tư theo PO Hưng Yên |
| `usp_ProductionOrderRouting_HY_get` / `_iud` | Cấu hình quy trình định tuyến PO Hưng Yên |
| `usp_DoCancelPO_HY` | Hủy lệnh sản xuất PO |
| `usp_DoFixProductionOrder_HY` | Khóa/Duyệt lệnh sản xuất PO |
| `usp_SetInfo_HY_get` / `_iud_VNT` | Quản lý thông tin Barcode/ControlNo sản phẩm Hưng Yên |

### 1.4 Nhóm Thành Phẩm Kho Finished Goods (10 SPs)
| Stored Procedure Name | Chức Năng Nghiệp Vụ |
| :--- | :--- |
| `ups_Add_Fg_HY` | Thêm mới thùng/box thành phẩm kho Hưng Yên (⚠️ typo `ups_` gốc trong DB) |
| `usp_VN_ShowAllFinishGoodMES_HY` | Hiển thị danh sách tồn kho thành phẩm Hưng Yên |
| `usp_VN_ShowGoodFinisedExport_HY` | Kết xuất dữ liệu báo cáo xuất kho thành phẩm |
| `usp_VN_Add_FinishGood_HY_New` | Nhập kho thành phẩm version mới Hưng Yên |
| `usp_VN_IMPORTFINISHEDGOOD_HY_New` | Import dữ liệu thành phẩm từ Excel vào kho Hưng Yên |
| `usp_VN_Update_GoodFinish_HY_New` | Cập nhật thông tin vị trí ô kệ kho thành phẩm |

---

## 2. 🗄️ Bảng DB Đặc Thù Hưng Yên & Phân Hệ VPC (PCBA)

### 2.1 Bảng Thành Phẩm Hưng Yên
- **`STB_VN_FINISHGOODS_HY`**: Bảng quản lý kho thành phẩm chính nhà máy Hưng Yên (`FGT_HY_WH`).
- **`STB_VN_FINISHGOODS_HY_NEW`**: Version mở rộng quản lý lô hàng thành phẩm mới.

### 2.2 Bảng Phân Hệ VinaEnesol PCBA (VPC Tables — 3 tables)
- **`STB_VPCLinePlan`**: Kế hoạch sản xuất Line PCBA VinaEnesol.
- **`STB_VPCLinePlan_two`**: Phiên bản mở rộng kế hoạch Line PCBA 2.
- **`VPC_Performance`**: Báo cáo hiệu suất máy lắp ráp mạch PCBA VinaEnesol.

---

## 3. 🛠️ Quy Trình Nhân Bản Layout Giao Diện (Server-Side Cloning)

### 3.1 Vấn đề kết nối mạng WAN
Dữ liệu thiết kế giao diện (`XmlLayout` và `Layout` varbinary) trong bảng `STB_ScreenLayoutInfo` (`SmartFramework` DB) có dung lượng lớn. Để tránh timeout kết nối WAN:

### 3.2 T-SQL Script Clone Layout Trực Tiếp Trên Server
```sql
-- Clone nguyên trạng Layout nhị phân và Replace tham số SP sang _HY
INSERT INTO SmartFramework.dbo.STB_ScreenLayoutInfo (ScreenName, UserID, Layout, XmlLayout, CreateDateTime)
SELECT 
    'Vietnam_NewScreen_HY',
    UserID,
    Layout,
    CAST(REPLACE(CAST(XmlLayout AS NVARCHAR(MAX)), 'usp_ProductionOrderInfo_get', 'usp_ProductionOrderInfo_HY_get') AS NTEXT),
    GETDATE()
FROM SmartFramework.dbo.STB_ScreenLayoutInfo
WHERE ScreenName = 'Vietnam_NewScreen';
```

---

## 4. ⚠️ Bẫy Mã Hóa Tiếng Hàn (Korean Encoding Trap)
Các SP Hưng Yên chứa comment tiếng Hàn và tiếng Việt có dấu (`@sumSampleQty공정`). Khi xuất/ghi file `.sql` bằng PowerShell, **bắt buộc phải lưu định dạng UTF-8 with BOM** (`-Encoding UTF8`).
