# 🏭 SmartFactoryV2 — MES Core Production Database Knowledge Base

> **Máy chủ:** `dbserver.hycap.co.kr,5398` | **CSDL:** `SmartFactoryV2`  
> **Quy mô thực tế:** **1,140 Bảng (Tables)**, **61 Khung nhìn (Views)**, **3,473 Thủ tục (Stored Procedures)**, **29 Khóa ngoại (FKs)**  
> **Dung lượng bảng lớn nhất:** `STB_VVT_ESRDATA` (423+ Triệu dòng, 64.8 GB)

`SmartFactoryV2` là cơ sở dữ liệu cốt lõi của phân hệ điều hành sản xuất **NAIS MES** tại Vinatech Việt Nam (phục vụ đồng thời nhà máy Hà Nam và nhà máy Hưng Yên). Database này lưu trữ toàn bộ dữ liệu giao dịch sản xuất thời gian thực, tiến độ Lot/WIP, đo kiểm ESR tụ điện, phế phẩm và đóng gói xuất xưởng.

---

## 🗺️ 1. Cấu Trúc Phân Bổ Tiền Tố Bảng (Table Prefix Topology)

| Tiền Tố | Số Bảng | Phân Hệ Nghiệp Vụ | Mô Tả Chức Năng |
| :--- | :---: | :--- | :--- |
| **STB_** | **924** | SmartFactory Core | Bảng lõi sản xuất: Routing (`ProdRouteHist`), Lot (`SetInfo`), Phế (`DefectRepairInfo`), WMS (`MaterialStock`) |
| **BAK_** | 67 | Database Backup | Bảng sao lưu dữ liệu trước các đợt Hotfix hoặc bảo trì ca |
| **ESM_** | 19 | Equipment Monitoring | Giám sát cảm biến thiết bị: Nhiệt độ, áp suất, độ rung |
| **BK_** | 19 | System Backup | Bản ghi sao lưu lịch sử |
| **VNTVN_**| 11 | Vietnam Factory Custom | Các màn hình nghiệp vụ mở rộng đặc thù của pháp nhân Việt Nam |
| **HN_** | 5 | Ha Nam Plant | Cấu hình chuyên biệt cho nhà máy Hà Nam |
| **VINA_** | 4 | Integration Gateway | Bảng giao tiếp đồng bộ với POP Web và hệ thống bên ngoài |

---

## 📊 2. Top 12 Bảng Có Khối Lượng Dữ Liệu Lớn Nhất

| Tên Bảng | Số Dòng (Live Rows) | Dung Lượng (MB) | Ý Nghĩa Nghiệp Vụ & Rủi Ro |
| :--- | :---: | :---: | :--- |
| **STB_VVT_ESRDATA** | **423,054,934** | **64,895 MB** | Dữ liệu đo kiểm ESR từng cell siêu tụ điện. **Bắt buộc có index khi SELECT**. |
| **STB_ProductStockInfo** | **69,378,135** | **13,193 MB** | Ảnh chụp tồn kho thành phẩm theo mốc thời gian. |
| **STB_CommInspMeasureHist** | **62,000,134** | **5,710 MB** | Lịch sử thông số đo kiểm chất lượng công đoạn. |
| **STB_ESRInspectionData** | **39,668,717** | **3,115 MB** | Kết quả đo nội trở ESR theo Barcode. |
| **STB_CommInspDocItem** | **34,248,628** | **5,293 MB** | Chi tiết các chỉ tiêu kiểm tra QC. |
| **STB_IoTMeasureHist** | **28,798,427** | **2,531 MB** | Dữ liệu đo đạc cảm biến IoT máy móc tự động. |
| **STB_Vvt_SdProds** | **22,868,733** | **8,419 MB** | Dữ liệu sản phẩm SD Vinatech. |
| **STB_MaterialQcSampleResult** | **20,456,074** | **2,010 MB** | Kết quả đo mẫu kiểm tra nguyên vật liệu đầu vào IQC. |
| **STB_ProcedureLog** | **19,853,120** | **1,914 MB** | Nhật ký thực thi Stored Procedure của hệ thống. |
| **STB_VN_FINISHGOODS_CAPTURE** | **14,843,699** | **8,325 MB** | Dữ liệu xuất nhập kho thành phẩm Việt Nam. |
| **stb_DetailAgaingHN** | **14,121,530** | **2,375 MB** | Dữ liệu công đoạn già hóa (Aging) nhà máy Hà Nam. |
| **STB_MaterialLotSnapshot** | **10,291,746** | **4,063 MB** | Ảnh chụp trạng thái cuộn NVL theo ngày. |

---

## ⚙️ 3. Các Bảng Nghiệp Vụ Vận Hành Cốt Lõi (Golden Tables)

### 3.1 `STB_SetInfo` (75 Cột — Bảng Mẹ Lot Sản Xuất)
- **Khóa chính:** `ControlNo` (varchar(20))
- **Trường truy vết:** `Barcode` (varchar(50)), `LotNumber` (varchar(50)), `DayPlanNo` (varchar(20)), `MaterialCode` (varchar(50)).
- **Trường tiến độ:** `CurrentRouteCode`, `ProdQty`, `DefectQty`, `Status`, `IsProdFinish`.
- **Nguyên tắc an toàn:** **CẤM** xóa hoặc cập nhật đè trên bảng này trong các kịch bản rollback sản xuất.

### 3.2 `STB_ProdRouteHist` (Lịch Sử Tiến Độ Công Đoạn)
- **Trường chính:** `ProdRouteHistNo` (PK), `ControlNo`, `Barcode`, `RouteCode`, `LineCode`, `MachineCode`, `WorkerCode`, `ProdQty`, `ProdDateTime`, `JobDate`, `ShiftCode`, `CompleteRoute`.
- **Quy tắc phân ca:** Ca 1 bắt đầu từ `10:00:00` đến `20:30:00`, Ca 2 từ `20:30:00` đến `10:00:00` ngày hôm sau (JobDate lùi 1 ngày nếu trước 10:00 sáng).

### 3.3 `MongoToMesPerformance` (Bảng Đệm Đồng Bộ POP ➔ MES)
- **Trường chính:** `DayPlanNo`, `Barcode`, `RouteCode`, `MachineCode`, `TotalProdQty`, `IsDone`, `IsTransferred`, `InsertDateTime`.
- **Cơ chế Kiosk:** Web Kiosk POP chỉ ghi và đọc từ bảng này. SP `usp_VINA_SyncPopToMes_SingleLot` đọc từ bảng này để đồng bộ bù sang `STB_ProdRouteHist`.

---

## ⚡ 4. Danh Mục Stored Procedures Trọng Yếu (3,473 SPs)

1. **`usp_DoProcessProdRouteHist`**: Động cơ trung tâm xử lý chốt công đoạn sản xuất trên WinForms MES client.
2. **`usp_GetProdRouteHistForBarcode_VNT`**: Truy xuất toàn bộ lịch sử các công đoạn đã đi qua của một Barcode.
3. **`usp_VINA_SyncPopToMes_SingleLot`**: Thủ tục đồng bộ dữ liệu từ Kiosk POP sang MES RouteHist (hỗ trợ kiểm tra trùng lặp và tính ca tự động).
4. **`usp_CancelCompleteRouteForBG2WithConditionPassOrFail`**: Rollback hủy chốt công đoạn cho nhà máy.
5. **`usp_BlockOPCheckPreviousRouteStatus`**: Interlock kiểm tra công đoạn trước đã PASS chưa trước khi cho phép chốt công đoạn sau.

---

## 🛠️ 5. Lệnh Thao Tác Nhanh Qua CLI Hub `.\db.ps1`
```powershell
# Xem thống kê số lượng bảng, view, SP và top bảng lớn
.\db.ps1 stats -Profile SmartFactoryV2

# Tìm kiếm Stored Procedure
.\db.ps1 sp -Profile SmartFactoryV2 -Search "SyncPop"

# Đọc mã nguồn Stored Procedure
.\db.ps1 sp -Profile SmartFactoryV2 -Name "usp_VINA_SyncPopToMes_SingleLot" -Definition

# Truy vết Lot
.\db.ps1 trace -Type LOT -Value "VVQR153R060615"
```
