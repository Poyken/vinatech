<!--
AI-READY METADATA
Purpose: Cẩm nang triển khai & nhân bản 78 Stored Procedures, 9 screens, T-SQL Server-Side Layout Cloning & Isolated SPs cho Hưng Yên (VVT_F5)
Scope: Hung Yen VVT_F5 Technical Deployment & SP Cloning
Single Source of Truth: KB_07_02_DEPLOY_HY.md (Hung Yen Deployment & SP Isolation)
Target Screens: HY121, HY122, HY220, HY310, HY442, HY470, HY552, HY802, HY460, HY141-HYFG01
Target Tables: STB_ScreenInfo, STB_ScreenLayoutInfo, STB_VN_FINISHGOODS_HY
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)
  - [KB_07_01_OVERVIEW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_01_OVERVIEW.md)
  - [KB_07_03_SCREEN_BUGS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/KB_07_03_SCREEN_BUGS.md)
-->

## 7. 🛠️ Triển Khai & Cấu Hình 9 Màn Hình Mới Hưng Yên (VVT_F5)

> Nhằm đảm bảo tính độc lập vận hành cho xưởng Hưng Yên (`VVT_F5`) mà không làm ảnh hưởng tới logic của các nhà máy Bắc Ninh, Bắc Giang, và Hà Nam, hệ thống thực hiện nhân bản khép kín **78 Stored Procedures** và **9 màn hình chức năng** tương ứng.
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) | [Về KB_07 Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07/INDEX.md)

> VERIFIED 2026-06-18: 8/9 HY TCodes below (HY122, HY220, HY310, HY442, HY470, HY552, HY802, HY460) DO NOT EXIST in STB_ScreenInfo. Actual HY screens: HY141, HY143, HY151, HY311, HY312, HY330, HY430, HY431, HY443, HY530, HY540, HY541, HY620, HY740, HYFG01, HY103 (17 functional screens).

### 7.1 Danh Sách 9 Màn Hình Được Nhân Bản (HY TCodes)

| STT | ScreenName | TCode | Phân hệ | Màn hình gốc | SP Chính Liên Quan |
|---|---|---|---|---|---|
| 1 | `QcInspectionGroup_HY` | `HY121` | Quality Control (QC) | `C121` | `usp_QcInspectionGroup_HY_get`/`_iud` |
| 2 | `MaterialQcInspectionItemByMaterial_HY` | `HY122` | Quality Control (QC) | `C122` | `usp_MaterialQcInspectionItem_ByMaterial_HY_get`/`_iud` |
| 3 | `MaterialIqcInfoSampleManagement_HY` | `HY220` | Quality Control (QC) | `C220` | Bộ SP IQC đầu `_HY` (Detail, SampleResult...) |
| 4 | `ProductionOrderInfo_HY` | `HY310` | Production (PO) | `B310` | `usp_ProductionOrderInfo_HY_get`, `usp_DoFixProductionOrder_HY` |
| 5 | `ElectrodePlan_HY` | `HY442` | Electrode (Điện cực) | `B442` | `usp_DayProdPlan_HY_get`, `usp_SetInfo_HY_get` |
| 6 | `ElectrodePrcsCard_HY` | `HY470` | Electrode (Điện cực) | `B470` | `usp_ElectrodeStep_HY_get`/`_iud`, `_Oven_HY_get` |
| 7 | `ElectrodeMeasureResult_HY` | `HY552` | Electrode (Điện cực) | `B552` | Bộ SP kết quả công đoạn điện cực (Coating, Rollpress...) |
| 8 | `ElectrodeProdRouteHist_HY` | `HY802` | Electrode (Điện cực) | `B802` | `usp_Vietnam_ElectrodeProdRouteHist_HY_get` |
| 9 | `ElectrodeInspectionHistoryForBarcode_HY` | `HY460` | Electrode (Điện cực) | `C460` | `usp_GetElectrodeInspectionHistoryForBarcode_HY` |

### 7.2 Quy Tắc Đặt Tên & Logic Của SP Nhân Bản
*   **Quy tắc đặt tên:**
    *   Hàm lấy dữ liệu: `[Tên SP Gốc]_get` $\rightarrow$ `[Tên SP Gốc]_HY_get` (Ví dụ: `usp_QcInspectionGroup_HY_get`).
    *   Hàm ghi/sửa dữ liệu: `[Tên SP Gốc]_iud` $\rightarrow$ `[Tên SP Gốc]_HY_iud` (Ví dụ: `usp_QcInspectionGroup_HY_iud`).
    *   Các SP nghiệp vụ khác: Thêm hậu tố `_HY` (Ví dụ: `usp_GetMaterialGIForPO_HY`).
*   **Logic độc lập:** Các SP được tự động quét và sửa các lời gọi chéo nhau bên trong thân hàm. Nếu SP A gọi SP B, phiên bản SP A_HY sẽ tự động gọi sang SP B_HY để đảm bảo cô lập dữ liệu hoàn toàn.

### 7.3 Bẫy Mã Hóa Tiếng Hàn (Encoding Trap)
*   **Vấn đề:** Các Stored Procedure tiêu chuẩn chứa rất nhiều bình luận (comment) bằng tiếng Hàn và tiếng Việt có dấu, cũng như các biến logic có ký tự Hàn (Ví dụ: `@sumSampleQty공정`).
*   **Giải pháp:** Khi xuất bản hoặc ghi đè file SQL bằng PowerShell, bắt buộc phải dùng thuộc tính `-Encoding UTF8` (hoặc định dạng UTF-8 with BOM). Nếu ghi bằng mã ANSI/ASCII mặc định, các ký tự tiếng Hàn sẽ bị biến đổi thành dấu hỏi chấm (`??`), gây lỗi biên dịch nghiêm trọng trên SQL Server.

### 7.4 Tự Động Nhân Bản Layout Màn Hình (Server-Side Cloning)
*   **Vấn đề WAN:** File thiết kế màn hình (`XmlLayout` - nvarchar và `Layout` - varbinary) lưu trong bảng `STB_ScreenLayoutInfo` (DB `SmartFramework`) có dung lượng rất lớn. Việc tải các tệp nhị phân này về máy trạm local rồi đẩy ngược lên DB server qua đường truyền WAN quốc tế (đi Hàn Quốc) rất dễ bị nghẽn (hang/timeout).
*   **Giải pháp T-SQL:** Thực hiện sao chép và cập nhật trực tiếp trên server bằng câu lệnh T-SQL để tận dụng bộ nhớ trong của DB Server:
    1.  Thực hiện `INSERT INTO ... SELECT` để clone nguyên trạng bản ghi của màn hình gốc sang màn hình `_HY` (giữ nguyên cột nhị phân `Layout` và `Snapshot` mà không cần truyền tải qua mạng).
    2.  Dùng hàm `REPLACE` trong SQL để cập nhật lại toàn bộ các thẻ tham chiếu SP gốc thành SP `_HY` bên trong cột văn bản `XmlLayout` (Ví dụ: thay thế `usp_ProductionOrderInfo_get` thành `usp_ProductionOrderInfo_HY_get`).

*Các script hỗ trợ đã được tạo sẵn trong thư mục `sql/scripts/`:*
*   `generated_hy_sps.sql` — Script tạo 78 SPs Hưng Yên mới.
*   `register_hy_screens.sql` — Script đăng ký ScreenInfo & ScreenObjects trên DB `SmartFramework`.
*   `clone_screen_layouts.sql` — Script T-SQL chạy trực tiếp trên `SmartFramework` để nhân bản giao diện và cập nhật mapping.

### 7.5 Tổng Hợp Bài Học Kinh Nghiệm & Khắc Phục Sự Cố

#### 7.5.1 Lỗi Khởi Động Client (Menu Initialization Failed)
*   **Hiện tượng:** Khi chạy script đăng ký màn hình `register_hy_screens.sql` nhưng chưa nhân bản hoặc nhân bản thiếu layout tương ứng trong bảng `STB_ScreenLayoutInfo` (ví dụ do timeout đường truyền WAN khi clone layout), Client MES khi khởi động sẽ lập tức báo lỗi nghiêm trọng: **"Menu initialization failed. Internal Server Error. Please contact your administrator."**
*   **Nguyên nhân gốc rễ:** WCF Web Service của NAIS MES khi boot sẽ tải danh mục toàn bộ menu dựa trên bảng `STB_ScreenInfo` rồi thực hiện đối chiếu/khởi tạo với dữ liệu giao diện layout trong `STB_ScreenLayoutInfo`. Việc có bản ghi đăng ký màn hình trong `STB_ScreenInfo` nhưng bị thiếu/NULL layout XML trong `STB_ScreenLayoutInfo` khiến hàm `MenuManager.Initialize` ở phía WCF Service bị crash lỗi 500 NullReferenceException, dẫn đến toàn bộ Client không thể đăng nhập.
*   **Khắc phục & Phòng ngừa:**
    1.  **Quy trình rollback:** Phải thực hiện xóa đồng bộ các bản ghi của màn hình lỗi ở cả 6 bảng cấu hình hệ thống: `STB_ScreenInfo`, `STB_ScreenObjects`, `STB_ScreenLayoutInfo`, `STB_UserTypeBasicPermission`, `STB_UserTypeViewPermission`, và `STB_UserTypeFunctionPermission`.
    2.  **Nguyên tắc nguyên tử (Atomicity):** Khi thêm màn hình mới, tuyệt đối không được để trạng thái "màn hình đã đăng ký nhưng chưa có layout". Cần chạy script chèn đồng thời cả ScreenInfo và ScreenLayoutInfo dưới dạng một Transaction duy nhất.

#### 7.5.2 Lỗi Nghẽn/Timeout Kết Nối Mạng WAN (Database Connection Timeout)
*   **Hiện tượng:** Quá trình clone layout giao diện bị treo hoặc trả về lỗi Timeout từ SQL Server (mặc định 30s) khi thực hiện cập nhật/thay thế các thẻ XML Layout trực tiếp bằng các vòng lặp SQL.
*   **Nguyên nhân gốc rễ:** Bản ghi layout trong bảng `STB_ScreenLayoutInfo` chứa dữ liệu XML dung lượng rất lớn (`XmlLayout` dưới dạng text XML và `Layout` dưới dạng nhị phân `varbinary`). Đường truyền WAN kết nối đến DB Server đặt tại Hàn Quốc có độ trễ lớn và băng thông giới hạn. Việc thực hiện hàng trăm lệnh UPDATE lớn qua mạng hoặc xử lý XML trực tiếp trên SQL Server thông qua các lệnh query lặp đi lặp lại rất dễ vượt ngưỡng Command Timeout 30 giây.
*   **Giải pháp xử lý tối ưu:**
    1.  Tận dụng lệnh `INSERT INTO ... SELECT` trực tiếp trên server để copy cột nhị phân `Layout` và `Snapshot` mà không truyền dữ liệu nhị phân qua WAN.
    2.  Thực hiện thay thế chuỗi XML (Replace tên SP cũ thành SP `_HY`) trong bộ nhớ phía Client (ví dụ sử dụng script PowerShell local) trước khi insert để tránh thực hiện các câu lệnh UPDATE XML nặng nề trên SQL Server.

#### 7.5.3 Vấn Đề Mã Hóa Tiếng Hàn (Korean Encoding Trap)
*   **Hiện tượng:** Các stored procedure sau khi nhân bản bị báo lỗi cú pháp hoặc bị lỗi hiển thị ký tự (dấu chấm hỏi `??`) tại các phần bình luận tiếng Hàn hoặc các biến logic tiếng Hàn (Ví dụ: `@sumSampleQty공정`).
*   **Nguyên nhân gốc rễ:** SQL Server và các script mặc định lưu ở mã hóa ANSI/ASCII sẽ làm hỏng các ký tự Unicode tiếng Hàn.
*   **Giải pháp:** Bắt buộc phải lưu và thực thi toàn bộ các file script SQL bằng mã hóa **UTF-8 với BOM** (`UTF-8 with Signature`) bằng cách sử dụng tham số `-Encoding UTF8` trong PowerShell hoặc lưu đúng định dạng trong editor, giúp bảo toàn tính toàn vẹn của mã nguồn tiếng Hàn.

---



---

## Appendix — HY Isolated SPs & VPC Tables (DB Verified 2026-06-18)

> **Tổng: 93 SPs** có hậu tố `_HY` — tách biệt hoàn toàn khỏi logic BN/BG/HN

### A.1 HY SP theo nhóm chức năng

#### Electrode (24 SPs):
| SP | Chức năng |
|---|---|
| `usp_ElectrodeMixInfo_HY_get/_iud` | Trộn nguyên liệu HY |
| `usp_ElectrodeMixStepInfo_HY_get/_iud` | Bước trộn chi tiết |
| `usp_ElectrodeCoatingInfo_HY_get/_iud` | Phủ Coating |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_*` | Kiểm tra Coating |
| `usp_ElectrodeOven_HY_get/_iud` | Sấy lò |
| `usp_ElectrodeRollPressingInfo_HY_*` | Ép cuộn |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_*` | Kiểm tra ép cuộn |
| `usp_ElectrodeSlittingInfo_HY_*` / `Result_HY_*` | Cắt cuộn |
| `usp_ElectrodeStep_HY_get/_iud` | Quản lý công đoạn |
| `usp_ElectrodeCommon_HY_get/_iud` | Common |
| `usp_ElectrodeWasteInfoNew_HY_iud` | Phế liệu electrode |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | Viscosity |

#### QC / IQC (18 SPs):
| SP | Chức năng |
|---|---|
| `usp_MaterialQcInfo_HY_get/_iud` | Thông tin QC NVL |
| `usp_MaterialQcDetail_HY_get/_iud` | Chi tiết QC |
| `usp_MaterialQcSampleResult_HY_get/_iud` | Kết quả mẫu |
| `usp_DoMakeMaterialIQCDetailList_HY` | Tạo danh sách IQC |
| `usp_DoMakeMaterialQcSampleResult_HY` | Tạo kết quả mẫu |
| `usp_DoChangeMaterialQcToPass_HY` | Đổi QC → Pass |
| `usp_DoUpdateMaterialQcInfo_Fail/Success_HY` | Cập nhật Fail/Pass |
| `usp_IQcDefectReport_HY_iud` | Báo lỗi IQC |
| `usp_DoSendEmailForDefectReportIQC_HY` | Email báo lỗi IQC |
| `usp_QcInspectionGroup/Item_HY_*` | Nhóm/Hạng mục QC |

#### Production (13 SPs):
| SP | Chức năng |
|---|---|
| `usp_DayProdPlan_HY_get/_iud` | Kế hoạch SX ngày |
| `usp_DoCancelDayProdPlan_HY` | Hủy kế hoạch |
| `usp_DoFixDayProdPlan_HY` | Sửa kế hoạch |
| `usp_ProductionOrderInfo_HY_get` | Lệnh SX |
| `usp_ProductionOrderBom_HY_get` | BOM theo PO |
| `usp_ProductionOrderRouting_HY_get/_iud` | Routing |
| `usp_DoCancelPO_HY` | Hủy PO |
| `usp_DoFixProductionOrder_HY` | Sửa PO |
| `usp_SetInfo_HY_get/_iud_VNT` | Set Info |

#### Finished Goods (10 SPs):
| SP | Chức năng |
|---|---|
| `ups_Add_Fg_HY` | Thêm TP (⚠️ typo: `ups_` không phải `usp_`) |
| `usp_VN_ShowAllFinishGoodMES_HY` | Hiển thị tất cả TP |
| `usp_VN_ShowGoodFinisedExport_HY` | Export TP |
| `usp_VN_Add_FinishGood_HY_New` | Thêm TP mới |
| `usp_VN_IMPORTFINISHEDGOOD_HY_New` | Import TP |
| `usp_VN_Update_GoodFinish_HY_New` | Cập nhật TP |

#### Misc:
`usp_DoAddCommInspMeasureHistForBarcode_HY`, `usp_DoFinishCommInspDoc_HY/_VNT_HY`, `usp_HYStagePrices_iud`, `usp_LocationElectric_HY`, `usp_NCR_Report_HY_iud`, `usp_MainAssemblePartWeight_HY_get`, `usp_GetMaterialGIForPO_HY`, `usp_ModifyRevisionsVerFromC220_VVTF4_HY`

### A.2 HY FG Tables

| Table | Mô tả |
|---|---|
| `STB_VN_FINISHGOODS_HY` | **★ Finished Goods** Hưng Yên (chính) |
| `STB_VN_FINISHGOODS_HY_NEW` | Version mới |

### A.3 VPC Tables (VinaEnesol PCBA — 3 tables)

| Table | Mô tả |
|---|---|
| `STB_VPCLinePlan` | Kế hoạch Line VPC |
| `STB_VPCLinePlan_two` | Version 2 |
| `VPC_Performance` | Hiệu suất PCBA |

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: 93 HY-isolated SPs (phân loại theo chức năng) + HY FG Tables + VPC Tables. DB verified.*

