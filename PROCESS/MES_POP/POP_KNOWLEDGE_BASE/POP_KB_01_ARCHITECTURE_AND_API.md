<!--
AI-READY METADATA
Purpose: Kiến trúc hệ thống POP, API endpoints, DB schema mapping, luồng dữ liệu
Scope: POP Web Architecture (Frontend → API → DB)
Single Source of Truth: POP_KB_01_ARCHITECTURE_AND_API.md
Target Tables: VINATECH_POP.dbo.* (66 bảng), SmartFactoryV2.dbo.STB_SetInfo, STB_ProdRouteHist, STB_MaterialLotInfo, STB_DayProdPlan
Last Updated: 2026-09-21 (Audit DB schema toàn diện 66 bảng)
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [KB_08_CORE_SP_ENGINE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md)
-->

# POP_KB_01 — Kiến Trúc Hệ Thống, API & DB Schema Mapping

> **Hệ thống:** POP Web Kiosk — `https://pop.vinatech.com/`  
> **Bảng chính:** `VINATECH_POP.*`, `SmartFactoryV2.STB_SetInfo`, `STB_ProdRouteHist`, `STB_MaterialLotInfo`  
> **🔑 Keywords:** architecture, API, endpoint, database, schema, SSO, authentication, REST, JSON  
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)

---

## 1. 🏗️ KIẾN TRÚC TỔNG THỂ

### 1.1 Stack Công Nghệ

| Layer | Công nghệ | Chi tiết |
|-------|-----------|----------|
| **Frontend** | Vue.js 2.x + Vuetify + Vanilla JS | SPA cho Kiosk touch (`/pop/screen`, `/pop/quality`), MPA cho Dashboard & Data Collection |
| **Thư viện Giao diện** | ECharts, JsBarcode, QRCode, bwip-js, Select2 | Trực quan hóa tiến độ, render tem mã vạch vector 2D, bộ chọn tìm kiếm máy móc |
| **Giao thức Thời gian thực** | WebSocket / STOMP (`SockJS` + `stomp.js`) | Thu thập dữ liệu cảm biến máy tự động (PLC), Heartbeat Kiosk 24/7 và thông báo đẩy |
| **Client Thu Thập IoT** | `vinatechEquipmentDataSetup.exe` | Windows Service cài tại máy trạm xưởng kết nối PLC (OPC-UA, Modbus TCP, MC Protocol, RS232) |
| **API Server** | ASP.NET Core / Node.js | RESTful JSON, hosted IIS (`pop.vinatech.com/api/`) |
| **Database Nghiệp Vụ 1** | `VINATECH_POP` (MSSQL) | CSDL riêng POP: 66 bảng (SSO token, Kiosk sessions, Action logs, Mapping máy, Quality) |
| **Database Nghiệp Vụ 2** | `SmartFactoryV2` (MSSQL) | Shared với MES: Lot, Routing, Kho, Master Data, `MongoToMesPerformance` |
| **Database IoT & Log** | MongoDB (Time-Series) | Lưu trữ chuỗi thời gian áp suất, nhiệt độ, điện áp, tốc độ máy và log đường truyền PLC |
| **Auth** | SSO Token-based + RBAC | `VINATECH_POP.dbo.VINA_SSO_LOGIN` + `VINA_SSO_TOKEN` (Phân quyền Worker vs Manager) |
| **Print** | In tem đa phương thức | Web Spooler / ZPL Socket đẩy trực tiếp về máy in Zebra/TSC tại xưởng qua API |

### 1.2 Mô Hình Triển Khai

```
Thiết Bị Xưởng (PLC/Cân/Scanner)          Trình Duyệt Kiosk / Tablet
      │ (RS232 / Modbus / OPC-UA)                    │
      ▼                                              ▼
┌──────────────────────────────┐        ┌───────────────────────────────────┐
│ vinatechEquipmentDataSetup   │        │ POP Web Application               │
│ (Windows Service trên PC máy)│        │ pop.vinatech.com                  │
│   └── WebSocket / REST Push  │        │ ├── /pop/screen   (Sản xuất SPA)  │
└──────────────┬───────────────┘        │ ├── /pop/quality  (Chất lượng SPA)│
               │                        │ ├── /equipmentData (Dữ liệu IoT)  │
               │                        │ └── /dashboard    (Quản lý RBAC)  │
               ▼                        └─────────────────┬─────────────────┘
┌─────────────────────────────────────────────────────────┴─────────────────┐
│ IIS Web Server & API Gateway (pop.vinatech.com:443)                       │
│ ├── WebSocket / STOMP Broker (/ws-equipment, /ws-kiosk)                   │
│ └── RESTful APIs (/api/common/*, /api/dayplan/*, /api/material/*...)      │
├────────────────────────────────┬──────────────────────────────────────────┤
│ CSDL Quan Hệ (MSSQL 5398)       │ CSDL Chuỗi Thời Gian (MongoDB)           │
│ ├── VINATECH_POP (66 bảng)     │ ├── EquipmentData_TimeSeries (Cảm biến)  │
│ ├── SmartFactoryV2 (MES Core)  │ └── EquipmentLog_Stream (Nhật ký PLC)    │
│ └── SmartFramework (Hệ thống)  │                                          │
└────────────────────────────────┴──────────────────────────────────────────┘
```

> **⚠️ QUAN TRỌNG:** POP Web và MES WinForm **chia sẻ cùng DB backend** (`SmartFactoryV2`).
> Mọi thao tác chốt sản lượng, trừ kho, hủy hộp trên POP đều tác động trực tiếp và hiển thị tức thì trên MES WinForm và ngược lại.

---

### 1.3 📦 Danh Mục 38 Module JavaScript Frontend (`resources/js/`)

Hệ thống Frontend của POP được module hóa thành 38 tệp JavaScript chuyên biệt, phối hợp điều khiển các nghiệp vụ trên Kiosk:

#### A. Nhóm Quản Trị Hệ Thống, Kiosk Core & Phiên Làm Việc
1. `popCommon.js`: Các hàm tiện ích dùng chung, định dạng ngày giờ, chuỗi, bộ lọc ngôn ngữ (VI/KO/EN).
2. `popScreen.js`: Module điều phối chính của màn hình `/pop/screen`, quản lý State toàn cục `window.POP`.
3. `popLineModal.js`: Điều khiển Modal chọn Dây chuyền, phân cấp Nhà máy VN/KR, bộ nhớ đệm `LINE_HISTORY_KEY`.
4. `popLotSearch.js`: Điều khiển Modal tra cứu Kế hoạch, Lịch biểu tháng, tìm kiếm Lot theo Barcode (>= 4 ký tự).
5. `popWorker.js`: Điều khiển Modal chọn Công nhân ca kíp, cây phòng ban, chỉ định Người đại diện chính.
6. `popEquipment.js`: Quản lý danh sách máy, gán thiết bị Kiosk, kiểm tra tình trạng chiếm dụng máy.
7. `popEquipDataPopup.js`: Cửa sổ Popup xem nhanh thông số tức thời của thiết bị ngoại vi gắn Kiosk.
8. `popKeypad.js`: Bàn phím số cảm ứng ảo Numpad, cơ chế toggle chế độ tính toán `ADD` / `SUB`.
9. `popKioskHeartbeat.js`: Bộ phát nhịp tim định kỳ giữ phiên làm việc và cập nhật `VINA_KIOSK_SESSION`.
10. `popRealtime.js`: Lắng nghe sự kiện đồng bộ trạng thái giữa các trạm Kiosk trong cùng một xưởng.

#### B. Nhóm Nguyên Vật Liệu, Chốt Sản Lượng & Đóng Gói
11. `popMaterialInput.js`: Quy trình nạp NVL, quét barcode cuộn/thùng, trừ tồn kho và ghi nhận lịch sử nạp.
12. `popMaterialBadge.js`: Hiển thị huy hiệu tỷ lệ cấp phát NVL (ví dụ `0/13` -> `13/13`) và mở khóa nút hoàn thành.
13. `popBomModal.js`: Bảng chi tiết định mức BOM, tính toán số lượng dự kiến (`Lượng kiến cấp`).
14. `popScaleSerial.js`: Giao tiếp cổng Serial/RS232 đọc khối lượng cân điện tử thời gian thực.
15. `popRouteMapping.js`: Quản lý quy trình nhảy bước công đoạn và ánh xạ tuyến sản xuất.
16. `popDefect.js`: Quản lý danh mục mã lỗi theo công đoạn, nhập số lượng phế phẩm và trừ lùi lỗi (SUB mode).
17. `popManualPackModal.js`: Giao diện đóng gói thùng (Single Pack, Split Pack, Merge Pack) và thuật toán FIFO.
18. `popKilnCondition.js`: Điều khiển và ghi nhận thông số lò nung/lò sấy nhiệt độ cao.
19. `popMarkingCode.js`: Hộp thoại quét và lưu mã Marking thân vỏ tại công đoạn Bọc Vỏ.

#### C. Nhóm Tem Nhãn & Đồ Họa Mã Vạch
20. `popLabelRenderer.js`: Động cơ dựng tem nhãn vector 2D, hiển thị preview trước khi xuất lệnh in.
21. `popLabelPrint.js`: Giao tiếp hệ thống in ấn, gửi lệnh Spooler tới máy in Zebra/TSC.

#### D. Nhóm Dây Chuyền Điện Cực & Slitting
22. `popMixing.js`: Quy trình Trộn điện cực 3 pha (Trộn khô, Tạo hạt, Nhào Slurry), liên kết cân điện tử.
23. `popCoating.js`: Giao diện Mạ điện cực 1 mặt/2 mặt, ma trận đo độ dày 9 điểm ngang màng (µm).
24. `popRolling.js`: Giao diện Ép cán cuộn (Roll Pressing), kiểm soát nhiệt độ 130°C và mật độ cán (g/cc).
25. `popSlitting.js`: Giao diện Cắt xẻ băng điện cực, cấu hình đa dao xẻ, nhận diện khổ còn lại và sinh Lot con.
26. `popElectrodeBase.js`: Lớp cơ sở chứa các công thức quy đổi thông số công nghệ điện cực.
27. `popElectrodeInfo.js` & `popElectrodeInfoConfig.js`: Cấu hình thông tin cuộn mẹ và thuộc tính lá cực.
28. `popElectrodeProcess.js`: Điều phối vòng đời trạng thái của mẻ điện cực.
29. `popThicknessGrid.js`: Lưới nhập ma trận độ dày đa điểm First/Middle/Last.

#### E. Nhóm Quản Lý Chất Lượng (Quality) & Thống Kê
30. `popQualityMain.js`: Điều khiển khung giao diện chính `/pop/quality` và thanh điều hướng 7 tab.
31. `popQualityScan.js`: Xử lý sự kiện quét Barcode tự động nhận diện loại phiếu kiểm định.
32. `popQualityInsp.js`: Nhập mẫu đo kiểm định, tính toán sai số so với Spec (USL/LSL/Target).
33. `popQualityIqc.js`: Nghiệp vụ kiểm tra nguyên vật liệu đầu vào.
34. `popQualityOqc.js`: Nghiệp vụ kiểm tra xuất xưởng đóng gói thành phẩm.
35. `popQualityFoqc.js`: Nghiệp vụ kiểm tra chất lượng xuất khẩu đặc biệt.
36. `popQualityRouteJudge.js`: Quyết định Phán định tuyến Pass/Fail khóa mở chuyền.
37. `popQualityInspHistory.js`: Tra cứu lịch sử kiểm định đa chiều và xuất báo cáo Excel.
38. `popQualitySpc.js`, `popQualityPareto.js`, `popQualityAql.js`: Biểu đồ kiểm soát SPC, biểu đồ Pareto lỗi và bảng chuẩn lấy mẫu AQL.

---

## 2. 🔌 API ENDPOINTS ĐÃ XÁC MINH

### 2.1 Authentication & Common

| Method | Endpoint | Chức năng | DB Impact |
|--------|----------|-----------|-----------|
| POST | `/api/common/login` | Đăng nhập SSO | READ `VINA_SSO_LOGIN` → INSERT `VINA_SSO_TOKEN` |
| GET | `/api/common/getLineList` | Danh sách dây chuyền | READ `SmartFactoryV2.STB_LineInfo` |
| GET | `/api/common/getWorkerList` | Danh sách công nhân | READ `SmartFactoryV2.STB_WorkerInfo` |
| GET | `/api/common/getEquipmentList` | Thiết bị theo Line & Route | READ `SmartFactoryV2.dbo.STB_ProductMachine` + `STB_MachineMaster` (JOIN `VINATECH_POP.dbo.VINA_EQUIPMENT_SETTING`) |

### 2.2 Screen Module — Sản Xuất (`/api/pop/screen/`)

| Method | Endpoint | Chức năng | DB Impact |
|--------|----------|-----------|-----------|
| GET | `/api/pop/screen/getDayPlanList` | Lệnh SX theo ngày + Line | READ `STB_DayProdPlan` |
| GET | `/api/pop/screen/getLotList` | LOT theo DayPlan | READ `STB_SetInfo` |
| GET | `/api/pop/screen/getProcessList` | Công đoạn theo Routing | READ `STB_ProdRoute` |
| GET | `/api/pop/screen/getMaterialList` | NVL theo BOM + LOT | READ `STB_BomDetail`, `STB_MaterialLotInfo` |
| POST | `/api/pop/screen/saveMaterialInput` | **Nhập NVL** — trừ kho | **WRITE** `SmartFactoryV2.dbo.STB_RawMaterialInputHist` + UPDATE `STB_MaterialLotInfo` |
| POST | `/api/pop/screen/saveDefect` | Đăng ký phế phẩm | **WRITE** `STB_ProdRouteHist` (DefectQty) |
| POST | `/api/pop/screen/saveProduction` | Hoàn thành sản xuất | **WRITE** `STB_ProdRouteHist`, UPDATE `STB_SetInfo` |
| POST | `/api/pop/screen/savePacking` | Đóng gói (single/merge) | **WRITE** `STB_PackingInfo`, UPDATE `STB_SetInfo` |
| POST | `/api/pop/screen/cancelPacking` | **Hủy đóng gói** | **DELETE/UPDATE** `STB_PackingInfo`, REVERT `STB_SetInfo` |
| POST | `/api/pop/screen/printLabel` | In nhãn/tem | READ+PRINT `STB_ModelLabelInfo` |

### 2.3 Quality Module (`/api/pop/quality/`)

| Method | Endpoint | Chức năng | DB Impact |
|--------|----------|-----------|-----------|
| GET | `/api/pop/quality/getIQCList` | Danh sách IQC | READ `STB_QualityIQC` |
| GET | `/api/pop/quality/getPQCList` | Danh sách PQC | READ `STB_QualityPQC` |
| GET | `/api/pop/quality/getOQCList` | Danh sách OQC | READ `STB_QualityOQC` |
| GET | `/api/pop/quality/getFOQCList` | Danh sách FOQC | READ `STB_QualityFOQC` |
| POST | `/api/pop/quality/saveInspection` | Lưu kết quả kiểm tra | **WRITE** Quality tables |
| GET | `/api/pop/quality/getRouteJudgeList` | Phán định Route | READ `STB_RouteJudge` |

### 2.4 🗺️ Bản Đồ Điều Hướng Giao Diện Web POP (Frontend UI Routes)

Dựa trên cấu hình Master Menu (`VINATECH_POP.dbo.VINA_MENU`), hệ thống POP Web phân bổ thành 4 phân hệ chính:

```
                                  pop.vinatech.com
                                         │
     ┌───────────────────┬───────────────┴───────────────┬───────────────────┐
     ▼                   ▼                               ▼                   ▼
[1. Kiosk Thao Tác]  [2. Dashboard Vận Hành]    [3. Debug & Giám Sát]   [4. Cấu Hình Master]
  /pop/screen           /dashboard/production     /systemAdmin/popDebug/    /popSetting/
  /pop/quality          /dashboard/report           dashboard                 wipRouteMapping
                        /dashboard/electrodeStatus  flow                      lineProdMode
                        /dashboard/assemblyTrace    quality-flow              lotPlanQty
                        /dashboard/kiosk/           equipmentTracking/        interlockSetting
                          dashboard                   dashboard               assemblyGroupMapping
```

| Phân hệ | Route URL | Tên màn hình / Chức năng | Đối tượng sử dụng |
|---------|-----------|---------------------------|-------------------|
| **Kiosk Thao Tác** | `/pop/screen` | POP Sản Xuất (Chọn Plan, nạp NVL, chốt sản lượng, đóng gói, in tem) | Công nhân tại chuyền |
| | `/pop/quality` | POP Chất Lượng (Tự kiểm tra In-Line PQC, phán định chất lượng) | Công nhân / QC Line |
| **Dashboard Vận Hành** | `/dashboard/production` | Bảng điều khiển tích hợp tiến độ sản xuất toàn xưởng | Quản lý sản xuất |
| | `/dashboard/report` | Báo cáo tra cứu sản lượng theo ca/ngày/Line | Thống kê / Kế hoạch |
| | `/dashboard/electrodeStatus` | Bảng theo dõi tiến độ công đoạn Điện Cực (Coating, Slitting) | Tổ trưởng xưởng 1 |
| | `/dashboard/assemblyTrace` | Bảng truy vết tiến độ lắp ráp Module & Cell | Kỹ sư chuyền |
| | `/dashboard/kiosk/dashboard` | Dashboard giám sát trạng thái kết nối các Kiosk | IT / Admin |
| **Debug & Giám Sát** | `/systemAdmin/popDebug/dashboard` | Debug Dashboard tổng thể POP | Kỹ sư MES / IT |
| | `/systemAdmin/popDebug/flow` | Giám sát luồng dữ liệu Kiosk ➔ CSDL | Kỹ sư MES / IT |
| | `/systemAdmin/popDebug/quality-flow` | Giám sát luồng dữ liệu tự kiểm QC | Kỹ sư QC / IT |
| | `/systemAdmin/equipmentTracking/dashboard` | Giám sát trạng thái vận hành thiết bị & máy móc | Kỹ sư bảo trì |
| | `/systemAdmin/labelManager` | Quản lý định dạng mẫu tem nhãn tùy biến | Kỹ sư tem nhãn |
| | `/admin/pop/workerQrPrint` | In nhãn mã vạch QR nhân viên | Nhân sự / Tổ trưởng |
| **Cấu Hình Master** | `/popSetting/assemblyGroupMapping` | **Cấu hình 10 Slot nạp NVL theo Line** (`VINA_GROUP_INPUT_ROUTE`) | Quản lý Line / IT |
| | `/popSetting/lineProdMode` | Cấu hình chế độ sản xuất theo Line (`SUBTRACT` vs `ADD`) | Quản lý Line / IT |
| | `/popSetting/wipRouteMapping` | Cấu hình ánh xạ bán thành phẩm luân chuyển công đoạn | Kỹ sư quy trình |
| | `/popSetting/interlockSetting` | Cài đặt điều kiện khóa chặn liên công đoạn | Kỹ sư chất lượng |
| | `/popSetting/lotPlanQty` | Điều chỉnh số lượng kế hoạch của Lot | Kế hoạch sản xuất |
| | `/systemAdmin/qualityEquipment` | Quản trị thiết bị đo kiểm chất lượng | Kỹ sư đo lường |
| | `/dataCollection/modelSetting` | Cấu hình Model thu thập dữ liệu máy tự động | Kỹ sư tự động hóa |
| | `/dataCollection/pcMacList` | Whitelist địa chỉ MAC máy Kiosk | IT Hệ thống |

---

## 3. 🗄️ DATABASE SCHEMA MAPPING

### 3.1 VINATECH_POP — Bảng Riêng POP (Đã Đối Chiếu Live DB 66 Bảng)

> [!WARNING]
> **Kiểm toán 2026-09-21:** Bảng `VINA_MATERIAL_INPUT_HIST` hiện có **0 records** trên production DB. Kiosk POP có thể ghi nhận trực tiếp vào `SmartFactoryV2.dbo.STB_MaterialLotInfo` hoặc sử dụng cơ chế đồng bộ khác. Xem chi tiết danh mục toàn bộ 66 bảng tại [§3.6](#36--danh-mục-đầy-đủ-66-bảng-csdl-vinatech_pop-kiểm-toán-thực-tế-2026-09-21).

| Bảng | Mục đích | Vai trò vận hành POP |
|------|----------|----------------------|
| `VINA_MATERIAL_INPUT_HIST` | **Lịch sử nạp NVL** (SoT cho POP) | Ghi nhận chi tiết từng lần quét cuộn NVL, Lot, Qty, Worker, Route (Hiện 0 rows) |
| `VINA_KIOSK_SESSION` | Phiên làm việc trên Kiosk | Quản lý token đăng nhập, trạng thái Kiosk, WorkerID ca hiện hành |
| `VINA_KIOSK_LOG` / `VINA_POP_ACTION_LOG` | Nhật ký thao tác Kiosk | Ghi lại hành vi bấm nút, đổi Line, quét mã, tải lệnh sản xuất (202K+ rows) |
| `VINA_LABEL_INFO` / `VINA_CUSTOM_LABEL` | Cấu hình tem nhãn Kiosk | Mẫu in ZPL, định dạng mã vạch Code128/DataMatrix cho máy in Zebra |
| `VINA_EQUIPMENT_MAPPING` | Gán thiết bị với Kiosk | Ánh xạ mã máy móc, cân điện tử RS232, PLC baseline theo dây chuyền |
| `VINA_PACKING_REMAIN_QTY` | Quản lý số lượng lẻ khi đóng gói | Theo dõi tồn dư của các Lot lẻ phục vụ tính năng "Tìm Lot còn lại" & Merge Pack |
| `VINA_QC_DECISION_HIST` | Lịch sử phán định QC trên POP | Lưu kết quả kiểm định IQC, PQC, OQC, FOQC và Route Judgment |
| `VINA_QUALITY_ITEM_EQUIPMENT_MAP` | Ánh xạ hạng mục đo với thiết bị đo | Liên kết chỉ tiêu chất lượng với máy đo tự động tại chuyền (Hiện 0 rows) |
| `VINA_INTERLOCK_SETTING` | Cài đặt khóa liên động liên công đoạn | Ngăn chặn nhảy cóc công đoạn hoặc nạp sai NVL khi chưa hoàn tất kiểm tra (Hiện 0 rows) |
| `VINA_WIP_STOCK_HIST` | Lịch sử biến động bán thành phẩm | Theo dõi di chuyển bán thành phẩm giữa các trạm Kiosk |
| `VINA_REOPEN_REQUEST` / `VINA_REOPEN_POLICY` | Yêu cầu mở lại Lot/Lệnh đã đóng | Cơ chế cấp quyền mở lại các lệnh sản xuất đã hoàn tất để tái xử lý |

### 3.2 SmartFactoryV2 — Bảng Chia Sẻ Với MES

| Bảng | Vai trò trong POP | Đọc/Ghi |
|------|-------------------|---------|
| `STB_SetInfo` | Trạng thái LOT (core) | **Read + Write** |
| `STB_DayProdPlan` | Lệnh sản xuất ngày | Read only |
| `STB_ProdRoute` | Routing sản phẩm | Read only |
| `STB_ProdRouteHist` | Lịch sử routing (sản lượng, phế) | **Read + Write** |
| `STB_MaterialLotInfo` | Tồn kho NVL theo công đoạn | **Read + Write** (trừ kho) |
| `STB_BomMaster` / `STB_BomDetail` | BOM Master/Chi tiết | Read only |
| `STB_PackingInfo` | Thông tin đóng gói | **Read + Write** |
| `STB_ModelLabelInfo` | Cấu hình tem nhãn | Read only |
| `STB_QualityIQC/PQC/OQC/FOQC` | Kết quả QC | **Read + Write** |
| `STB_LineInfo` | Master data dây chuyền | Read only |
| `STB_WorkerInfo` | Master data công nhân | Read only |
| `STB_ProductMachine` | Mapping máy móc với Dây chuyền & Công đoạn (`LineCode` + `RouteCode` + `MachineCode`) | Read only |
| `STB_MachineMaster` | Master data máy móc thiết bị (`MachineCode`, `MachineName`, `WorkCenterCode`, `IsProdMachine`, `IsUsed`) | Read only |
| `MongoToMesPerformance` | **Bảng đồng bộ trung gian giữa MongoDB (Kiosk UI) & MES** | **Read + Write** (SoT cho tiến độ Kiosk: `IsDone`, `TotalProdQty`) |

### 3.3 🏭 Kiến Trúc Quản Lý Thiết Bị POP Kiosk & Vòng Đời Mapping

#### A. Hai Câu Truy Vấn Cốt Lõi Khi Load Danh Sách Máy Trên Modal
Khi Kiosk mở modal chốt sản xuất hoặc modal gán máy, Backend thực thi 2 câu query kết hợp:

1. **Query 1 — Lấy danh mục máy cấu hình theo Line & Route:**
   ```sql
   /* 2026-02-19 [POP 화면] - 공정별 설비 목록 조회 */
   SELECT
       MM.MachineCode,
       MM.MachineName,
       MM.CompanyCode,
       CASE 
           WHEN ES.EQUIPMENT_SETTING_PROCESS_MODE = 'CONTINUOUS' THEN 'Y'
           WHEN ES.EQUIPMENT_SETTING_PROCESS_MODE = 'BATCH' THEN 'N'
           WHEN ES.EQUIPMENT_SETTING_PROCESS_MODE = 'MANUAL' THEN NULL
           ELSE ISNULL(ES.EQUIPMENT_SETTING_CONTINUOUS, 'Y')
       END AS Continuous,
       CASE 
           WHEN ES.EQUIPMENT_SETTING_ID IS NULL THEN 1
           WHEN ES.EQUIPMENT_SETTING_PROCESS_MODE = 'MANUAL' THEN 1
           ELSE 0 
       END AS Manual
   FROM SmartFactoryV2.dbo.STB_ProductMachine PM WITH(NOLOCK)
   INNER JOIN SmartFactoryV2.dbo.STB_MachineMaster MM WITH(NOLOCK) ON MM.MachineCode = PM.MachineCode
   LEFT JOIN VINATECH_POP.dbo.VINA_EQUIPMENT_SETTING ES WITH(NOLOCK)
       ON ES.EQUIPMENT_SETTING_ID = PM.MachineCode
       AND ES.EQUIPMENT_SETTING_TYPE = 'STATIC_DATA_000069'
   WHERE PM.LineCode = @LineCode
     AND PM.RouteCode = @RouteCode
   ORDER BY MM.MachineName;
   ```

2. **Query 2 — Kiểm tra trạng thái máy bận (`VINA_EQUIPMENT_MAPPING`):**
   ```sql
   /* 2026-05-14 [김형진] - [설비별 활성 매핑 조회] */
   SELECT MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, MAPPING_STATUS
   FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK)
   WHERE EQUIPMENT_ID = @MachineCode
     AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');
   ```

#### B. Cơ Chế Filter (Chống Xung Đột Thiết Bị)
- **Logic:** Tại 1 thời điểm, 1 máy vật lý chỉ được phục vụ 1 Kế hoạch sản xuất (`DAY_PLAN_NO`).
- Nếu máy có `MAPPING_STATUS = 'ACTIVE'` ở một `DAY_PLAN_NO` khác Kế hoạch đang mở ➔ Backend/UI tự động **loại bỏ (ẩn)** máy đó khỏi danh sách chọn.
- **Sự cố "Khóa mồ côi" (Orphan Lock):** Nếu OP ca trước / ngày trước làm xong Lot nhưng không bấm "Hủy gán / Release", bản ghi `ACTIVE` sẽ tồn tại vĩnh viễn khiến ca sau mở Plan mới không thấy máy.
- **Cách xử lý cứu hộ:** Cập nhật `MAPPING_STATUS = 'RELEASED', RELEASED_AT = GETDATE(), NO_EMP_MODIFYER = 'vanduc'` cho các `MAPPING_ID` bị kẹt của các Plan cũ.

### 3.4 Sơ Đồ Data Flow — Nhập NVL (Material Input)

```
Công nhân chọn LOT → Bấm "Nhập NVL"
     │
     ▼
API: POST /api/pop/screen/saveMaterialInput
     │
     ├─→ SmartFactoryV2.STB_MaterialLotInfo
     │    UPDATE: CurrentQty = CurrentQty - InputQty (trừ kho thực tế)
     │
     ├─→ SmartFactoryV2.STB_RawMaterialInputHist (SoT THỰC TẾ GHI NHẬN 24/7)
     │    INSERT: Bản ghi lịch sử nạp NVL (Barcode, RawMaterialBarcode, CreateDateTime)
     │
     └─→ SmartFactoryV2.STB_SetInfo
          UPDATE: IsLineInput = 1 (đánh dấu đã hoàn thành nạp NVL vào chuyền)
```

> [!IMPORTANT]
> **Điểm mấu chốt kiến trúc:** Bảng `VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST` là bảng thiết kế trung gian cũ hiện **không sử dụng (0 rows)**. Hệ thống POP Web gọi trực tiếp Stored Procedure ghi nhận vào `SmartFactoryV2.dbo.STB_RawMaterialInputHist` để bảo đảm tính thống nhất dữ liệu thời gian thực với toàn bộ phân hệ MES WinForm.

### 3.4 Sơ Đồ Data Flow — Đóng Gói (Packing)

```
Công nhân vào công đoạn Packing → Chọn LOT → Nhập SL
     │
     ▼
API: POST /api/pop/screen/savePacking
     │
     ├─→ SmartFactoryV2.STB_PackingInfo
     │    INSERT: Bản ghi packing mới (BoxID, LotNo, Qty)
     │
     ├─→ SmartFactoryV2.STB_SetInfo
     │    UPDATE: PackingStatus, PackedQty
     │
     ├─→ VINATECH_POP.VINA_PACKING_LOG
     │    INSERT: Log đóng gói
     │
     └─→ [Tùy chọn] Auto Print Label
          Gọi SP in tem → Push to Printer
```

### 3.5 🔄 Cơ Chế Data Pipeline & Các Bảng Đệm Đồng Bộ (Staging & Queue Architecture)

#### 3.5.1 Bảng Trung Gian Cốt Lõi: `MongoToMesPerformance` (Tiến Độ & Sản Lượng Hoàn Thành)
- **Vị trí CSDL:** `SmartFactoryV2.dbo.MongoToMesPerformance`
- **Quy mô dữ liệu thực tế (Audit Live DB 2026-09-21):** **13,372** bản ghi (tích lũy từ 21/01/2026 đến nay).
- **Khóa chính (PK):** Composite Primary Key 3 trường: `PK_MongoToMesPerformance` trên `(DayPlanNo, Barcode, RouteCode)`.
- **Index phụ trợ:** `IX_MTP_Barcode` trên `(Barcode, RouteCode)` tối ưu hóa truy vấn tra cứu theo mã Barcode của Lot.
- **Chi tiết Schema & Ý nghĩa các trường:**
  | Tên Cột | Kiểu Dữ Liệu | Nullable | Ý Nghĩa Kỹ Thuật & Nghiệp Vụ Vận Hành |
  |---------|--------------|:--------:|---------------------------------------|
  | `DayPlanNo` | `varchar(20)` | **NO (PK)** | Mã kế hoạch sản xuất trong ngày (`STB_DayProdPlan.DayPlanNo`). |
  | `Barcode` | `varchar(50)` | **NO (PK)** | Mã Barcode định danh duy nhất của Lot bán thành phẩm / thành phẩm (`STB_SetInfo.Barcode`). |
  | `RouteCode` | `varchar(20)` | **NO (PK)** | Mã công đoạn sản xuất (VD: `V-22`, `V-23`, `V-24`, `V-25`, `V-22_HY`...). |
  | `LineCode` | `varchar(20)` | YES | Mã chuyền sản xuất thực hiện (VD: `VVC-01` .. `VVC-23`, `VVHYC-01` .. `TCX2`). |
  | `MachineCode` | `varchar(200)` | YES | Mã máy/thiết bị gán cho công đoạn (lấy từ `VINA_EQUIPMENT_MAPPING` hoặc gán tự động). |
  | `TotalProdQty` | `int` | YES | Sản lượng đạt (OK) hoàn thành của công đoạn (VD: 1060, 987, 740...). |
  | `TotalDefectQty`| `int` | YES | Tổng sản lượng phế phẩm phát sinh tại công đoạn (= $\sum$ `DefectQty` từ `MongoToMesDefect`). |
  | `CreateUserId` | `varchar(20)` | YES | Mã thẻ công nhân / OP thực hiện chốt công đoạn trên Kiosk (VD: `32507021`, `32607047`). |
  | `IsDone` | `bit` | YES | **Trạng thái hoàn thành công đoạn trên Kiosk Web**: `1` = Đã chốt xong; `0` = Đang sản xuất dở dang. <br>⚠️ **Single Source of Truth để Kiosk Web render dấu tích xanh `[✓]` và khóa nút chốt!** |
  | `IsTransferred`| `bit` | YES | **Trạng thái chuyển giao sang MES Core (`STB_ProdRouteHist`)**: `1` = Đã nạp thành công vào MES; `0` = Đang chờ trong hàng đợi đệm. |
  | `IsSkipped` | `int` | **NO** | Đánh dấu bỏ qua đồng bộ: `0` = Xử lý bình thường; `1` = Đã được xử lý thủ công hoặc bypass, Worker ngầm sẽ bỏ qua không quét. |
  | `SourceType` | `varchar(10)` | **NO** | Phân loại nguồn gốc phát sinh: <br>• `MANUAL` (92.8%): Công nhân bấm chốt thủ công trên màn hình cảm ứng Kiosk.<br>• `AUTO` (7.2%): Tự động ghi nhận từ thiết bị kết nối PLC/máy móc. |
  | `InsertDateTime`| `datetime` | YES | Dấu thời gian bản ghi được tạo ra từ phía POP Kiosk Web. |
  | `ModifyDateTime`| `datetime` | YES | Dấu thời gian Worker cập nhật trạng thái chuyển giao `IsTransferred = 1`. |

#### 3.5.2 Bảng Trung Gian Chi Tiết Phế Phẩm: `MongoToMesDefect` (Lỗi Phế Phẩm In-line)
- **Vị trí CSDL:** `SmartFactoryV2.dbo.MongoToMesDefect`
- **Quy mô dữ liệu thực tế (Audit Live DB 2026-09-21):** **6,861** bản ghi (tích lũy từ 30/04/2026 đến nay; 100% `SourceType = 'AUTO'`).
- **Khóa chính (PK):** Composite Primary Key 4 trường: `PK_MongoToMesDefect` trên `(DayPlanNo, Barcode, RouteCode, DefectCode)`.
- **Chi tiết Schema & Ý nghĩa các trường:**
  | Tên Cột | Kiểu Dữ Liệu | Nullable | Ý Nghĩa Kỹ Thuật & Nghiệp Vụ Vận Hành |
  |---------|--------------|:--------:|---------------------------------------|
  | `DayPlanNo` | `varchar(20)` | **NO (PK)** | Kế hoạch sản xuất phát sinh lỗi. |
  | `Barcode` | `varchar(50)` | **NO (PK)** | Mã Barcode của Lot bị lỗi phế. |
  | `RouteCode` | `varchar(20)` | **NO (PK)** | Mã công đoạn phát sinh lỗi phế (VD: `V-22`, `V-23`...). |
  | `DefectCode` | `varchar(20)` | **NO (PK)** | Mã phân loại lỗi phế phẩm quy chuẩn (VD: `V-22_YY_HY` = Lỗi cuộn lệch mép, `V-22_QQ_HY` = Lỗi phế đầu cuộn, `V-23_NE6` = Lỗi chân cực ngắn...). |
  | `LineCode` | `varchar(20)` | YES | Chuyền sản xuất ghi nhận lỗi. |
  | `MachineCode` | `varchar(20)` | YES | Thiết bị/máy móc phát sinh lỗi. |
  | `DefectQty` | `int` | YES | Số lượng phế phẩm cụ thể của riêng mã lỗi `DefectCode` này. |
  | `CreateUserId` | `varchar(20)` | YES | Mã nhân viên khai báo lỗi trên Kiosk. |
  | `IsDone` | `bit` | YES | Trạng thái chốt lỗi trên Kiosk (`1` = Hoàn thành). |
  | `IsTransferred`| `bit` | YES | Trạng thái đồng bộ sang MES Core (`STB_DefectRepairInfo` và cộng dồn `STB_SetInfo.DefectQty`). |
  | `SourceType` | `varchar(10)` | **NO** | Định danh nguồn: `AUTO` (mặc định do Kiosk đẩy qua API). |
  | `InsertDateTime`| `datetime` | YES | Thời điểm ghi nhận lỗi phế. |
  | `ModifyDateTime`| `datetime` | YES | Thời điểm Worker hoàn tất chuyển phế sang MES Core. |
- **Ràng buộc toàn vẹn giữa hai bảng:**
  $$\sum_{\text{DefectCode}} \text{MongoToMesDefect.DefectQty} = \text{MongoToMesPerformance.TotalDefectQty}$$
  *(Cùng bộ khóa `DayPlanNo` + `Barcode` + `RouteCode`)*.

#### 3.5.3 Vòng Đời Dữ Liệu & Cơ Chế Đồng Bộ Hai Chiều (Data Lifecycle)

```
[Kiosk POP Web Client (pop.vinatech.com)]
      │
      │ 1. Công nhân bấm "Hoàn thành công đoạn" & khai báo phế (hoặc Sensor/PLC kích hoạt)
      ▼
[MongoDB / Cache Layer Kiosk]
      │
      │ 2. Backend NodeJS ghi tức thì vào CSDL SQL Server (SmartFactoryV2)
      ▼
┌──────────────────────────────────────────────┐       ┌──────────────────────────────────────────────┐
│ SmartFactoryV2.dbo.MongoToMesPerformance     │       │ SmartFactoryV2.dbo.MongoToMesDefect          │
│ • IsDone = 1, IsTransferred = 0, IsSkipped = 0│       │ • IsDone = 1, IsTransferred = 0              │
│ • TotalProdQty = 1060, TotalDefectQty = 14   │       │ • DefectCode: V-22_YY (11), V-22_QQ (3)      │
└──────────────────────┬───────────────────────┘       └──────────────────────┬───────────────────────┘
                       │                                                      │
                       │ 3. UI Kiosk ĐỌC TRỰC TIẾP từ bảng này:               │
                       │    - Nếu IsDone=1 ➔ Hiện dấu tích xanh [✓]           │
                       │    - Nút "Ghi nhận" bị mờ (Disable)                  │
                       │                                                      │
                       ▼                                                      ▼
  ⚡ Scheduled Polling Worker (pop.vinatech.com IIS Service ngầm, chu kỳ 1–2 phút)
      ├─► Quét: SELECT * FROM MongoToMesPerformance WHERE IsDone=1 AND IsTransferred=0 AND IsSkipped=0
      ├─► Sinh mã: EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteHist', @NewHistNo OUTPUT
      ├─► Nạp MES Routing: INSERT INTO SmartFactoryV2.dbo.STB_ProdRouteHist (...)
      ├─► Nạp MES Defect:  INSERT INTO SmartFactoryV2.dbo.STB_DefectRepairInfo (...)
      ├─► Cập nhật tiến độ: UPDATE SmartFactoryV2.dbo.STB_SetInfo SET CurrentRouteCode = @RouteCode
      └─► Đóng cờ hoàn tất: UPDATE MongoToMesPerformance SET IsTransferred = 1, ModifyDateTime = GETDATE()
                       │
                       ▼
[SmartFactoryV2.dbo.STB_ProdRouteHist] ─── (Single Source of Truth cho Báo cáo MES WinForm B782, B530, B540)
```

##### 🚨 Cơ Chế Cứu Hộ Đồng Bộ Cưỡng Bức Tức Thì (<0.05s)
Khi Scheduled Worker trên IIS gặp lỗi hoặc độ trễ mạng khiến dữ liệu ứ đọng, IT sử dụng Stored Procedure cứu hộ chuyên dụng:
- **Tên thủ tục:** `SmartFactoryV2.dbo.usp_VINA_SyncPopToMes_SingleLot`
- **Nguyên tắc an toàn (Idempotent):**
  1. Kiểm tra công đoạn đã tồn tại trong `STB_ProdRouteHist` chưa: Nếu đã có ➔ **Tự động bỏ qua (Skip)**, tuyệt đối không nhân đôi sản lượng.
  2. Tính toán chu kỳ ca sản xuất chuẩn mực: Lấy mốc cắt ca `10:00:00` sáng để xác định `JobDate` (ngày sản xuất kế toán) và `ShiftCode` (`1` = Ca ngày 10:00-20:30; `2` = Ca đêm).
  3. Cấp phát số serial chuẩn qua `SmartFramework.dbo.usp_DoCreateSerial` và đóng cờ `IsTransferred = 1` an toàn trong Transaction (`BEGIN TRAN... COMMIT TRAN`).
  4. Lệnh kích hoạt nhanh:
     ```sql
     -- Đồng bộ tức thì toàn bộ các công đoạn đã hoàn thành của Lot
     EXEC SmartFactoryV2.dbo.usp_VINA_SyncPopToMes_SingleLot 
          @pBarcode = 'VVQR203R072760', 
          @pRouteCode = NULL, 
          @pProcessUserID = 'vanduc';
     ```

#### 3.5.4 Phân Tích Hiện Trạng Dữ Liệu Thực Tế & Điểm Nghẽn Kẹt Đồng Bộ (Telemetry Live DB)

Kết quả kiểm toán phân bổ trạng thái trên live database tại thời điểm **2026-09-21**:

##### 1. Thống kê trạng thái `MongoToMesPerformance` (13,372 dòng)
| Nguồn (`SourceType`) | Đã Xong (`IsDone`) | Đã Sang MES (`IsTransferred`) | Bỏ Qua (`IsSkipped`) | Số Dòng | Tỷ Lệ | Trạng Thái Vận Hành |
|----------------------|:------------------:|:----------------------------:|:-------------------:|--------:|------:|---------------------|
| `MANUAL` | **True (1)** | **True (1)** | 0 | **8,693** | 65.0% | ✅ Hoàn thành & đồng bộ chuẩn xác sang MES |
| `MANUAL` | False (0) | True (1) | 0 | **2,174** | 16.3% | ℹ️ Công đoạn dở dang đã khởi tạo trạng thái |
| `MANUAL` | False (0) | False (0) | 0 | **1,210** | 9.0% | 🔄 Công đoạn đang mở trên chuyền chưa chốt |
| `AUTO` | False (0) | False (0) | 0 | **632** | 4.7% | 📡 Dữ liệu máy móc/PLC đang tích lũy |
| `MANUAL` | **True (1)** | **True (1)** | 1 | **596** | 4.5% | 🛠️ Các lượt chốt được IT bypass / sync thủ công |
| `AUTO` | **True (1)** | **False (0)** | 0 | **37** | **0.3%** | ⚠️ **ĐIỂM NGHẼN KẸT ĐỒNG BỘ HIỆN TẠI!** |
| `AUTO` | True (1) | True (1) | 0 | **25** | 0.2% | ✅ Chốt tự động đã sang MES thành công |
| `AUTO` | True (1) | True (1) | 1 | **5** | <0.1% | 🛠️ Chốt tự động được bypass thủ công |

##### 2. Thống kê trạng thái `MongoToMesDefect` (6,861 dòng)
| Nguồn (`SourceType`) | Đã Xong (`IsDone`) | Đã Sang MES (`IsTransferred`) | Số Dòng | Tỷ Lệ | Trạng Thái Vận Hành |
|----------------------|:------------------:|:----------------------------:|--------:|------:|---------------------|
| `AUTO` | **True (1)** | **True (1)** | **6,570** | 95.8% | ✅ Đã đồng bộ chi tiết lỗi sang `STB_DefectRepairInfo` |
| `AUTO` | False (0) | False (0) | **269** | 3.9% | 🔄 Lỗi đang ghi nhận dở dang trên chuyền |
| `AUTO` | **True (1)** | **False (0)** | **22** | **0.3%** | ⚠️ **ĐIỂM NGHẼN KẸT PHẾ CÙNG THỜI ĐIỂM!** |

##### 3. Chi tiết điểm nghẽn kẹt đồng bộ tại dây chuyền `VVC-11` (Hà Nam)
Toàn bộ **37** bản ghi kẹt trong `MongoToMesPerformance` và **22** bản ghi kẹt trong `MongoToMesDefect` tập trung 100% tại:
- **Chuyền sản xuất:** `VVC-11` (Cell Line 11 — Nhà máy Hà Nam).
- **Công đoạn ảnh hưởng:** `V-22` (Cuốn - 18 bản ghi), `V-23` (Lắp cao su - 16 bản ghi), `V-24` (Curling - 2 bản ghi), `V-25` (Bọc vỏ - 1 bản ghi).
- **Thời gian kẹt:** Từ ngày `2026-08-27 12:00:17` đến `2026-09-19 00:09:26`.
- **Nguyên nhân:** Các bản ghi này có `SourceType = 'AUTO'` do máy tự động ghi nhận nhưng Worker IIS gặp lỗi thiếu thông tin máy móc hoặc không thể ánh xạ mã công nhân `WorkerCode` cho nguồn tự động, dẫn tới việc Worker bỏ qua và để lại ở trạng thái `IsTransferred = 0`.
- **Cách xử lý triệt để:** Dùng lệnh `.\mes.ps1 pop-audit` để rà quét và chạy SP `usp_VINA_SyncPopToMes_SingleLot` cho từng Lot bị kẹt.

---

#### 3.5.5 Đào Sâu Các Bảng Trung Gian & Hàng Đợi Tương Tự Trong Toàn Bộ Hệ Thống MES

Hệ sinh thái MES Vinatech là kiến trúc phân tán đa tầng kết nối giữa: Web Kiosk (NodeJS/MongoDB), MES Core (C# WinForm/SQL Server), Douzone iU ERP, máy in Zebra và hệ thống IoT thiết bị. Toàn bộ các bảng đóng vai trò **Staging Buffer / Async Queue / Interface Table** tương tự được hệ thống hóa thành 4 nhóm kiến trúc:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        HỆ SINH THÁI BẢNG ĐỆM TRUNG GIAN VINATECH                       │
├──────────────────────────┬──────────────────────────┬──────────────────────────────────┤
│ 1. POP KIOSK BUFFERS     │ 2. DOUZONE ERP ESB       │ 3. PERIPHERAL & MACHINE QUEUES   │
│ • MongoToMesPerformance  │ • STB_ERP_INTERFACE      │ • STB_RFIDPrintQueue             │
│ • MongoToMesDefect       │ • STB_VN_EMPLOYEESTRANS. │ • STB_InterfaceMachineInfo       │
│ • VINA_PACKING_REMAIN_QTY│ • STB_VN_STAGES_TRANSFER │ • STB_SerialCommunicationInterf. │
│ • VINA_POP_ACTION_LOG    │                          │ 4. DISTRIBUTED SYNC / TOMBSTONES │
│                          │                          │ • ESM_SyncDeleteTarget           │
└──────────────────────────┴──────────────────────────┴──────────────────────────────────┘
```

##### Bảng Tổng Hợp Chi Tiết Các Bảng Đệm Tương Tự:

| Nhóm Kiến Trúc | Tên Bảng | CSDL | Số Dòng | Chiều Tích Hợp | Vai Trò & Cơ Chế Hoạt Động Kỹ Thuật | Rủi Ro & Bẫy Vận Hành |
|----------------|----------|------|--------:|----------------|--------------------------------------|-----------------------|
| **1. POP Kiosk Buffers** | `MongoToMesPerformance` | `SmartFactoryV2` | 13,372 | POP ➔ MES Core | **Buffer tiến độ & sản lượng chốt routing**: Worker IIS quét chu kỳ 1-2 phút đẩy sang `STB_ProdRouteHist`. | Kẹt `IsTransferred=0` (chuyền VVC-11); Kẹt giao diện Kiosk nếu xóa `STB_ProdRouteHist` mà quên xóa bảng này (POP-ERR-15). |
| | `MongoToMesDefect` | `SmartFactoryV2` | 6,861 | POP ➔ MES Core | **Buffer chi tiết mã lỗi phế phẩm in-line**: Tự động chuyển vào `STB_DefectRepairInfo` và cộng dồn `STB_SetInfo.DefectQty`. | Lệch tổng phế giữa bảng lỗi và tổng sản lượng phế trên `STB_SetInfo`. |
| | `VINA_PACKING_REMAIN_QTY` | `VINATECH_POP` | 2,165 | POP Internal | **Buffer lưu trữ Lot lẻ dở dang sau đóng gói**: Đóng vai trò vùng đệm phục vụ tính năng "Tìm Lot còn lại" và Merge Pack gộp thùng. | Tồn dư ảo do không cập nhật `REMAIN_QTY = 0` sau khi gộp thùng thành công. |
| | `VINA_POP_ACTION_LOG` | `VINATECH_POP` | 202,986 | Kiosk ➔ DB | **Staging buffer ghi vết hành vi tương tác 24/7**: Lưu trữ 104 loại sự kiện runtime (Nạp NVL, đo kiểm, chốt công đoạn, lỗi hệ thống) để phục vụ đối soát. | Bảng phình to nhanh chóng (100K+ dòng/tháng), cần chiến lược purge/archive định kỳ. |
| **2. Douzone ERP ESB Staging** | `STB_ERP_INTERFACE` | `SmartFactoryV2` | 26,080 | ERP ⇄ MES Core | **Enterprise Service Bus (ESB) Generic Staging**: Thiết kế theo mô hình Generic Payload (`EIInfText01..10`, `EIInfInt01..10`, `EIInfReal01..10`, `EIInfDate01..10`). Quản lý đồng bộ 2 chiều các nghiệp vụ Goods Receipt (GR: 19K dòng), MaterialMaster (5.1K dòng), Stock Move (1.9K dòng) giữa MES và Douzone iU ERP. Quản lý trạng thái qua cờ `InterfaceFinYn` ('Y'/'N'). | Lỗi parse payload khiến `InterfaceFinYn = 'N'` treo đơn hàng hoặc lệch kho giữa MES và ERP. |
| | `STB_VN_EMPLOYEESTRANSFER` & `...LINE` | `SmartFactoryV2` | 590+ | ERP/HR ➔ MES | **Buffer điều chuyển nhân sự giữa các chuyền**: Ánh xạ việc chuyển công nhân từ chuyền gốc (`CODELINECURRENTLY`) sang chuyền tiếp nhận (`CODELINETRANSFER`) kèm khung thời gian `START_DATES` - `END_DATES`. | Quét thẻ nhân viên trên Kiosk báo lỗi "Không thuộc chuyền" do chưa kích hoạt bản ghi transfer. |
| | `STB_VN_STAGES_TRANSFER` | `SmartFactoryV2` | 6 | MES ➔ ERP Plan | **Staging chuyển tiếp giai đoạn công đoạn**: Ánh xạ lệnh sản xuất của từng Barcode qua các công đoạn (`V-22`, `V-23`, `V-24`, `V-25`) gắn với lệnh PO kế toán. | Treo lệnh đóng Lot nếu kế hoạch PO bị hủy trên ERP. |
| **3. Peripheral & Machine Queues** | `STB_RFIDPrintQueue` | `SmartFactoryV2` | 38 | MES Core ➔ Máy in Zebra | **Hàng đợi in tem RFID / Barcode bất đồng bộ**: Lưu trữ cấu hình socket (`PrinterIP`, `PrinterPort`), chuỗi lệnh in `ZPLText`, cờ `QueueStatus` ('READY', 'SENT', 'FAILED') và `RetryCount`. Background Print Service quét để bắn lệnh in trực tiếp qua TCP Socket. | Máy in mất mạng hoặc kẹt giấy khiến queue bị dồn ứ, `RetryCount` vượt ngưỡng làm dừng luồng in tự động. |
| | `STB_InterfaceMachineInfo` | `SmartFactoryV2` | 3 | Máy Coater ➔ MES | **Bảng đệm cấu hình API máy tráng phủ điện cực**: Quản lý xác thực kết nối bảo mật bằng `APIKey` và mật khẩu cho các máy tráng phủ trực tiếp (Direct Coater #1, Direct Coater XRF #1, Direct Coater Vision #1). | Máy tráng phủ ngắt kết nối đẩy dữ liệu độ dày/màng do sai lệch chu kỳ cập nhật APIKey. |
| | `STB_SerialCommunicationInterface` | `SmartFactoryV2` | 0 | Cổng COM ➔ MES | **Cổng đệm giao tiếp RS232/Serial**: Vùng nhớ đệm đọc tham số đo kiểm điện trở (IR) và điện áp (OCV) từ cổng nối tiếp. | Xung đột chiếm dụng cổng COM vật lý khi mở nhiều ứng dụng đo cùng lúc. |
| **4. Distributed Sync & Tombstones** | `ESM_SyncDeleteTarget` | `SmartFactoryV2` | 155 | Master ➔ Edge Nodes | **Tombstone Deletion Queue**: Bảng ghi nhận danh sách các khóa nghiệp vụ đã bị xóa trên Server mẹ (như `WarehouseInOutHistNo`, `DayPlanNo`) để đồng bộ lệnh xóa xuống các CSDL phân tán / Client trạm con, ngăn ngừa hiện tượng phục hồi dữ liệu ma (Ghost Records). | Nếu trạm con mất mạng lâu ngày, bản ghi xóa có thể bị bỏ lọt khiến dữ liệu cũ bị đồng bộ ngược trở lại. |
| | `STB_InterimProdQtyInfo` | `SmartFactoryV2` | 11 | MES WorkCenter | **Bảng đệm sản lượng dở dang thử nghiệm**: Lưu sản lượng tạm giữa các ca trước khi kiến trúc POP Kiosk ra đời (2022). Hiện đã ngừng sử dụng. | Dữ liệu di sản (Legacy), không sử dụng cho luồng sản xuất hiện hành. |

#### 3.5.6 Ma Trận So Sánh Mẫu Thiết Kế (Design Pattern Matrix)

| Tiêu Chí So Sánh | Nhóm `MongoToMes*` (POP Buffers) | Nhóm `STB_ERP_INTERFACE` (ERP ESB) | Nhóm `STB_RFIDPrintQueue` (Print Queue) |
|------------------|-----------------------------------|-----------------------------------|----------------------------------------|
| **Mẫu Thiết Kế (Pattern)** | **Domain-Specific Staging Table** (Bảng đệm thiết kế riêng theo nghiệp vụ) | **Generic ESB Payload Staging** (Bảng đệm tổng quát với các cột động Text/Int/Real) | **Asynchronous Job Queue** (Hàng đợi công việc bất đồng bộ có Retry) |
| **Cơ Chế Tiêu Thụ (Consumer)** | Scheduled Polling Worker ngầm trên IIS (`pop.vinatech.com`) chu kỳ 1-2 phút | Douzone ERP Batch Sync Agent / EAI Service chạy theo lịch trình | Windows Background Print Service kết nối Socket TCP/IP port 9100 |
| **Cơ Chế Xử Lý Lũy Đẳng (Idempotency)** | Bắt buộc kiểm tra `STB_ProdRouteHist` trước khi chèn; Có SP cứu hộ `usp_VINA_SyncPopToMes_SingleLot` | Cờ `InterfaceFinYn` = 'Y' đánh dấu bản ghi đã xử lý | Cờ `QueueStatus` ('READY' ➔ 'SENT' ➔ 'FAILED') + Giới hạn `RetryCount` |
| **Cơ Chế Rollback Khi Hủy Chốt** | **Bắt buộc DUAL-DELETE**: Xóa `STB_ProdRouteHist` kèm xóa `MongoToMesPerformance` (Template 7) | Cập nhật `IUD_FLAG = 'D'` để ERP nhận biết giao dịch hủy | Đánh dấu `QueueStatus = 'CANCELLED'` |

---

### 3.6 📚 Danh Mục Đầy Đủ 66 Bảng CSDL VINATECH_POP (Kiểm Toán Thực Tế 2026-09-21)

Toàn bộ 66 bảng vật lý trong database `VINATECH_POP` trên server `dbserver.hycap.co.kr,5398` được phân loại theo 11 nhóm chức năng vận hành:

#### Nhóm 1: Core Operations & Kiosk Logs (Vận Hành & Nhật Ký Thao Tác)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_POP_ACTION_LOG` | 202,986 | **Nhật ký hành vi Kiosk cốt lõi**: Ghi nhận 104 loại `ACTION_TYPE` 24/7 (Top: Tự kiểm đo `AUTO_INSPECTION_ADDPROCESS` 117K, Nạp NVL `AUTO_MATERIAL_INPUT` 16K, Cân mẻ `AUTO_MIX_WEIGHING_INPUT` 15K, Hoàn thành `MANUAL_COMPLETE` 7.4K, Phế `MANUAL_DEFECT` 7.3K, Đo màng điện cực `AUTO_ELECTRODE_THICKNESS` 2.6K, Gán ép máy `AUTO_MAPPING_FORCEADD` 2.1K). Lưu giữ toàn bộ lỗi runtime (`ERROR_MESSAGE`). |
| `VINA_KIOSK_LOG` | 27,922 | Log kết nối Kiosk, IP client, trình duyệt, thời gian phiên làm việc. |
| `VINA_WIP_STOCK_HIST` | 1,720 | Lịch sử biến động bán thành phẩm (WIP) luân chuyển qua các công đoạn trên Kiosk. |
| `VINA_PACKING_REMAIN_QTY` | 2,165 | **Bảng quản lý tồn dư Lot lẻ khi đóng gói**: Phục vụ tính năng "Tìm Lot còn lại" & Merge Pack gộp thùng. |
| `VINA_KIOSK_SESSION` | 106 | Quản lý phiên làm việc active của từng máy trạm Kiosk. |
| `VINA_ASSEMBLY_GROUP_MODE` | 31 | **Chế độ nạp nhóm lắp ráp**: 100% chuyền Cell (31/31 line tại HN & HY như VVC-01..23, VVHYC-01..17, TCX1, TCX2) đều kích hoạt `INPUT_MODE = 'GROUP'`, bắt buộc nạp NVL qua cơ chế 10 Slot của `VINA_GROUP_INPUT_ROUTE`. |
| `VINA_LINE_PROD_MODE` | 36 | **Chế độ chốt sản lượng theo chuyền**: Phân chia 2 chế độ `PROD_MODE`: <br>• `SUBTRACT` (34 cấu hình — chuẩn chung Cell Line): Bắt đầu từ quy mô Lot kế hoạch và trừ dần phế/dư.<br>• `ADD` (2 cấu hình — riêng SPT_LINE S-01, S-05): Cộng dồn lũy kế sản lượng từng mẻ. |
| `VINA_ROUTE_DOC` | 2 | Tài liệu / SOP hướng dẫn thao tác gắn với từng công đoạn trên UI Kiosk. |
| `VINA_PATH_SETTTING` | 1 | Đường dẫn lưu trữ tài liệu, file đính kèm, ảnh chụp QC của hệ thống. |
| `VINA_MATERIAL_INPUT_HIST` | 0 | *Bảng lịch sử nạp NVL POP*: Hiện 0 rows (thực tế nạp NVL được ghi trực tiếp vào `SmartFactoryV2.dbo.STB_RawMaterialInputHist` và trừ kho tại `STB_MaterialLotInfo`). |

#### Nhóm 2: BOM & Material Route Mapping (Định Mức & Ánh Xạ NVL)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_BOM_INPUT_ROUTE` | 894 | Quy định chi tiết mã vật tư phụ (`SUB_MATERIAL_CODE`) phải nạp tại công đoạn nào (`INPUT_ROUTE_CODE`) theo từng Version BOM của Module/MEA. |
| `VINA_MATERIAL_ROUTE_MAP` | 435 | Ánh xạ chi tiết danh mục vật tư NVL với Route Code thực tế tại xưởng. |
| `VINA_GROUP_INPUT_ROUTE` | 306 | **Cấu hình 10 Slot nạp NVL chuẩn cho Kiosk**: <br>• `V-22` (Cuốn/Winding): 6 slot (`ElectrodeP`, `ElectrodeM`, `Separator`, `PiTape`, `TerminalP`, `TerminalM`).<br>• `V-24` (Lắp ráp/Assembly): 3 slot (`RubberPad`, `Case`, `Electrolyte`).<br>• `V-25` (Bọc vỏ/Sleeving): 1 slot (`Sleeve`).<br>Nếu slot có `IS_REQUIRED = Y` mà chưa nạp đủ, Kiosk sẽ khóa nút hoàn thành. |

#### Nhóm 3: Equipment & PLC Management (Máy Móc Thiết Bị & PLC)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_EQUIPMENT_MAPPING` | 2,402 | **Quản lý trạng thái gán máy Kiosk**: Theo dõi máy nào đang `ACTIVE`, `AUTO_MAPPED`, hay `RELEASED` theo DayPlan. Tránh đụng máy giữa các ca. |
| `VINA_EQUIPMENT_SETTING` | 93 | Thiết lập thuộc tính máy móc: chế độ chạy liên tục (CONTINUOUS), theo mẻ (BATCH), hoặc thủ công (MANUAL). |
| `VINA_EQUIPMENT_REMAINDER` | 9 | Theo dõi số lượng phôi/bán thành phẩm còn dư đọng lại trên buồng máy sau ca. |
| `VINA_PLC_BASELINE` | 5 | Thông số chuẩn Baseline cho thiết bị kết nối PLC đọc tín hiệu tự động. |

#### Nhóm 4: Quality & Inspection (Chất Lượng & Tự Kiểm Tra In-Line)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_INSP_MASTER_HIST` | 27,111 | **Lịch sử tự kiểm tra Master mẫu**: Ghi nhận kiểm tra đầu ca của công nhân trước khi bắt đầu sản xuất hàng loạt. |
| `VINA_INSP_MASTER_HIST_LOCK` | 1 | Khóa phân tán (Distributed Mutex `INSP_MASTER_HIST_COLLECT`) chống xung đột giữa các background collector jobs khi đồng bộ kết quả kiểm tra. |
| `VINA_BLOOM_JUDGE_POLICY` | 258 | **Chính sách đánh giá hiện tượng Bloom (phồng/rộp bọt khí)**: Quy định theo từng mã NVL (`MATERIAL_CODE`), nếu `APPROVAL_REQUIRED_YN = Y` thì bắt buộc phải có phê duyệt của cấp quản lý mới được thông qua. |
| `VINA_QC_DECISION_HIST` | 188 | Nhật ký phán định kết quả kiểm tra chất lượng trên giao diện POP Quality. |
| `VINA_OQC_SAMPLE_RULE` | 102 | Bảng quy tắc lấy mẫu kiểm tra xuất xưởng OQC theo cỡ lô. |
| `VINA_ROUTE_TEST_SETTING` | 66 | Thiết lập các bài kiểm tra chất lượng bắt buộc theo từng công đoạn. |
| `VINA_FOQC_ITEM_RULE` | 5 | Quy tắc kiểm tra chất lượng hoàn thiện FOQC xuất xưởng. |
| `VINA_QUALITY_ITEM_EQUIPMENT_MAP` | 0 | Ánh xạ chỉ tiêu chất lượng với thiết bị đo (dự phòng). |
| `VINA_QUALITY_EQUIPMENT_LINK` | 0 | Liên kết thiết bị kiểm tra (dự phòng). |
| `VINA_QUALITY_EQUIP_USE_HIST` | 0 | Lịch sử sử dụng thiết bị đo kiểm (dự phòng). |

#### Nhóm 5: Model & Product Configuration (Cấu Hình Model Sản Phẩm)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_MODEL_SETTING_DETAIL` | 2,385 | **Chi tiết thông số cài đặt Model**: Các tham số kỹ thuật hiển thị trên Kiosk theo mã Model. |
| `VINA_MODEL_SETTING_DETAIL_DTM_250120` | 120 | Bảng snapshot cấu hình Model lưu trữ ngày 20/01/2025. |
| `VINA_MODEL_SETTING` | 75 | Cấu hình chung cho từng Model sản phẩm trên POP. |
| `VINA_MODEL` | 65 | Danh mục Master Model sản phẩm kích hoạt trên giao diện POP. |
| `VINA_MODULE_SEARCH` | 24 | Từ điển tìm kiếm và nhận diện cấu trúc mã Module. |
| `VINA_MODULE` | 17 | Danh mục các dòng Module sản phẩm. |
| `VINA_MODEL_SETTING_MACRO` | 14 | Cấu hình macro tự động áp dụng thông số cài đặt Model. |
| `VINA_PACK_GRADE_ITEM` | 1 | Tiêu chuẩn phân hạng đóng gói (Grade). |
| `VINA_FORMULA_CONFIG` | 0 | Cấu hình công thức tính toán tự động (dự phòng). |

#### Nhóm 6: Label & Packing (In Tem Nhãn & Đóng Gói)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_LABEL_PRINT_HIST` | 6,759 | **Nhật ký in tem nhãn**: Lưu trữ toàn bộ lịch sử in tem từ Kiosk (thùng, cuộn, pallet). |
| `VINA_LABEL_INFO` | 39 | Mẫu tem nhãn ZPL và định dạng barcode (Code128, DataMatrix) theo loại tem. |
| `VINA_CUSTOM_LABEL_MAPPING` | 9 | Ánh xạ tem in tùy biến theo khách hàng và chủng loại. |
| `VINA_CUSTOM_LABEL` | 7 | Nội dung định dạng tem in nhãn tùy biến. |
| `VINA_LABEL_PARTNO` | 0 | Ánh xạ Part Number với định dạng tem (dự phòng). |

#### Nhóm 7: System, Security & Network (Bảo Mật, Hệ Thống & Mạng)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_EMP` | 284 | Danh bạ nhân sự, mã nhân viên, quyền thao tác trên POP Kiosk. |
| `VINA_STATIC_DATA` | 101 | Bảng dữ liệu tĩnh (Enum, Dictionary, mã dùng chung của POP). |
| `VINA_PC_MAC` | 58 | **Danh sách địa chỉ MAC Kiosk hợp lệ**: Kiểm soát phần cứng được phép truy cập hệ thống POP. |
| `VINA_ALLOWED_IP` | 13 | Whitelist địa chỉ IP mạng nội bộ được kết nối tới API POP. |
| `VINA_ATTACHED_FILE` | 13 | Quản lý file đính kèm, ảnh bằng chứng lỗi upload từ Kiosk. |
| `VINA_KIOSK_FACTORY_CONFIG` | 7 | Cấu hình gán máy Kiosk theo từng Nhà máy (Hà Nam / Hưng Yên / Bắc Ninh). |
| `VINA_SYSTEM_VERSION` | 1 | Ghi nhận phiên bản ứng dụng POP Kiosk hiện hành. |
| `VINA_COOKIE_NAME` | 0 | Cấu hình định danh cookie phiên làm việc. |

#### Nhóm 8: Menu & Authorization (Menu & Phân Quyền)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_MENU` | 158 | Cây danh mục menu các màn hình chức năng của POP Kiosk. |
| `VINA_MENU_PERMISSIONS_HISTORY` | 18 | Lịch sử phân quyền và chỉnh sửa quyền hạn menu. |
| `VINA_MENU_PERMISSIONS` | 13 | Phân quyền truy cập màn hình menu theo nhóm vai trò người dùng. |

#### Nhóm 9: Interlock & Reopen (Khóa Liên Động & Mở Lại Lệnh)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_REOPEN_REQUEST` | 5 | Danh sách yêu cầu xin mở lại Lệnh / Lot đã hoàn thành để sửa dữ liệu. |
| `VINA_REOPEN_POLICY` | 1 | Chính sách và điều kiện cho phép mở lại Lệnh sản xuất. |
| `VINA_REOPEN_POLICY_HISTORY` | 0 | Lịch sử thay đổi chính sách mở lại (dự phòng). |
| `VINA_INTERLOCK_SETTING` | 0 | Cấu hình điều kiện khóa liên động liên công đoạn (dự phòng). |
| `VINA_INTERLOCK_RELEASE_LOG` | 0 | Nhật ký mở khóa liên động khẩn cấp (dự phòng). |

#### Nhóm 10: Internal BBS & Bulletin (Bản Tin & Trao Đổi Nội Bộ)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_BBS_CONTENT` | 131 | Nội dung các bài thông báo, chỉ thị sản xuất đăng tải trên Kiosk. |
| `VINA_BBS_CONTENT_ADD_FIELD` | 131 | Các trường dữ liệu bổ sung của bài viết thông báo BBS. |
| `VINA_BBS_CATEGORY` | 3 | Danh mục phân loại bài viết thông báo. |
| `VINA_BBS_TYPE` | 2 | Loại hình thông báo nội bộ. |
| `VINA_BBS_TYPE_ADD_FIELD` | 1 | Định nghĩa trường bổ sung theo loại bài viết BBS. |
| `VINA_BBS_COMMENT` | 0 | Ý kiến bình luận bài viết (dự phòng). |
| `VINA_BBS_SEARCH_KEY` | 0 | Từ khóa tìm kiếm bài viết BBS (dự phòng). |

#### Nhóm 11: Backup & Maintenance Tables (Bảng Sao Lưu Cứu Hộ)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_POP_ACTION_LOG_BK20260919` | 24 | Snapshot sao lưu một phần nhật ký thao tác ngày 19/09/2026. |
| `BAK_VINA_PACKING_REMAIN_QTY_20260917_VVQR013R072727` | 1 | Snapshot sao lưu tồn dư đóng gói của Lot VVQR013R072727 ngày 17/09/2026. |

---

## 4. 🔐 XÁC THỰC & PHIÊN LÀM VIỆC

### 4.1 Luồng SSO Authentication

1. **Login Request:** User nhập `EmployeeNo` + `Password` trên POP Web.
2. **API xác thực:** `/api/common/login` → Kiểm tra `VINA_SSO_LOGIN` (hoặc `SmartFramework.STB_UserInfo`).
3. **Cấp Token:** INSERT vào `VINA_SSO_TOKEN` với `ExpireDate` (thường 8h ca làm việc).
4. **Session mỗi request:** Mọi API call đính kèm Token trong header → Server validate trước khi xử lý.
5. **Token hết hạn:** Tự động redirect về trang login.

### 4.2 Phân Quyền Theo Line/Factory

- POP **không có** hệ thống phân quyền phức tạp như MES (không có `STB_UserPermission` riêng).
- Quyền được kiểm soát qua:
  - **Login account** → Xác định `FactoryCode` (VVT_F2, VVT_HY, VVT_BN...)
  - **Line selection** → Filter DayPlan theo Line + Factory
  - Account `92603003` là account chung testing/demo.

---

## 5. 📊 SO SÁNH POP WEB vs MES WINFORM

| Tiêu chí | POP Web (Kiosk) | MES WinForm (Desktop) |
|----------|-----------------|----------------------|
| **Platform** | Browser (Chrome/Edge) | Windows .NET WinForm |
| **Target User** | Công nhân tại chuyền | Kỹ sư, Quản lý |
| **UI/UX** | Touch-optimized, Card view | Traditional grid/form |
| **Chức năng** | Nhập NVL, Đóng gói, Defect, Print | Full CRUD + Admin + Report |
| **DB Write** | Giới hạn (NVL, Packing, Defect) | Full access qua SP |
| **Offline** | ❌ Không hỗ trợ | ✅ Partial (cache) |
| **Master Data** | Read only | Full admin |
| **Rollback** | ✅ Hủy đóng gói trên UI | ✅ Nhiều tùy chọn hơn |
| **In Tem Thùng (Box Label)** | ⚠️ Không tự sinh `PackingID` 11 ký tự (`PK...`) ➔ Mã vạch Code 128 bị co ngắn | ✅ Sinh `PackingID` chuẩn qua chuỗi SP ➔ Mã vạch đủ độ rộng, quét chuẩn 100% |

---

## 6. 🔧 CÂU SQL KIỂM CHỨNG & KIỂM TOÁN ĐỒNG BỘ POP ➔ MES

### 6.1 Kiểm tra POP DB tồn tại
```sql
SELECT name FROM sys.databases WITH(NOLOCK) WHERE name = 'VINATECH_POP';
```

### 6.2 Liệt kê bảng trong VINATECH_POP
```sql
SELECT TABLE_NAME, TABLE_TYPE 
FROM VINATECH_POP.INFORMATION_SCHEMA.TABLES WITH(NOLOCK)
ORDER BY TABLE_NAME;
```

### 6.3 Kiểm tra bảng log nhập NVL
```sql
SELECT TOP 10 * 
FROM VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST WITH(NOLOCK)
ORDER BY InputDate DESC;
```

### 6.4 Cross-check LOT trên POP vs MES
```sql
-- Xem LOT trên SmartFactoryV2 (dữ liệu gốc mà POP đọc)
SELECT TOP 5 SetID, SetNo, MaterialCode, SetQty, CurrentRoute, IsLineInput
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE CreateDate >= DATEADD(DAY, -1, GETDATE())
ORDER BY CreateDate DESC;
```

### 6.5 Kiểm toán các bản ghi POP đã chốt nhưng CHƯA chuyển sang MES (Bị treo `IsTransferred = 0`)
```sql
-- Tìm tất cả bản ghi công nhân đã bấm hoàn thành trên Kiosk nhưng chưa vào STB_ProdRouteHist
SELECT 
    MMP.DayPlanNo,
    MMP.Barcode,
    MMP.RouteCode,
    MMP.TotalProdQty,
    MMP.IsDone,
    MMP.IsTransferred,
    MMP.ModifyDateTime,
    DATEDIFF(MINUTE, MMP.ModifyDateTime, GETDATE()) AS [MinutesPending]
FROM SmartFactoryV2.dbo.MongoToMesPerformance MMP WITH (NOLOCK)
WHERE MMP.IsDone = 1 
  AND MMP.IsTransferred = 0 
  AND MMP.IsSkipped = 0
ORDER BY MMP.ModifyDateTime ASC;
```

### 6.6 Đối soát toàn diện từng Lot giữa POP (`MongoToMesPerformance`) và MES (`STB_ProdRouteHist`)
```sql
-- Chạy đối soát khi nghi ngờ số liệu báo cáo B782/B530 bị lệch so với sản lượng bấm trên Kiosk
SELECT 
    MMP.Barcode,
    SETI.ControlNo,
    MMP.RouteCode,
    MMP.TotalProdQty AS [SL_Chot_POP],
    ISNULL(PRH.ProdQty, 0) AS [SL_Nhan_MES],
    CASE 
        WHEN PRH.ProdRouteHistNo IS NULL THEN N'❌ CHƯA SANG MES'
        WHEN MMP.TotalProdQty <> PRH.ProdQty THEN N'⚠️ LỆCH SỐ LƯỢNG'
        ELSE N'✅ KHỚP 100%'
    END AS [TrangThaiDongBo],
    MMP.ModifyDateTime AS [ThoiDiemChotPOP],
    PRH.ProdDateTime   AS [ThoiDiemNhanMES]
FROM SmartFactoryV2.dbo.MongoToMesPerformance MMP WITH (NOLOCK)
LEFT JOIN SmartFactoryV2.dbo.STB_SetInfo SETI WITH (NOLOCK) 
    ON MMP.Barcode = SETI.Barcode
LEFT JOIN SmartFactoryV2.dbo.STB_ProdRouteHist PRH WITH (NOLOCK) 
    ON PRH.ControlNo = SETI.ControlNo 
   AND PRH.RouteCode = MMP.RouteCode
WHERE MMP.IsDone = 1
  -- Lọc ngày cần đối soát:
  AND MMP.ModifyDateTime >= CAST(GETDATE() AS DATE)
ORDER BY MMP.ModifyDateTime DESC;
```

### 6.7 Thống kê nhanh tỷ lệ khớp dữ liệu POP vs MES trong ca/ngày
```sql
SELECT 
    CASE 
        WHEN PRH.ProdRouteHistNo IS NULL THEN N'CHƯA SANG MES / MẤT BẢN GHI'
        WHEN MMP.TotalProdQty <> PRH.ProdQty THEN N'LỆCH SỐ LƯỢNG'
        ELSE N'KHỚP 100%'
    END AS [Trạng Thái],
    COUNT(*) AS [Số Lượng Bản Ghi]
FROM SmartFactoryV2.dbo.MongoToMesPerformance MMP WITH (NOLOCK)
LEFT JOIN SmartFactoryV2.dbo.STB_SetInfo SETI WITH (NOLOCK) 
    ON MMP.Barcode = SETI.Barcode
LEFT JOIN SmartFactoryV2.dbo.STB_ProdRouteHist PRH WITH (NOLOCK) 
    ON PRH.ControlNo = SETI.ControlNo 
   AND PRH.RouteCode = MMP.RouteCode
WHERE MMP.IsDone = 1 
  AND MMP.ModifyDateTime >= CAST(GETDATE() AS DATE)
GROUP BY 
    CASE 
        WHEN PRH.ProdRouteHistNo IS NULL THEN N'CHƯA SANG MES / MẤT BẢN GHI'
        WHEN MMP.TotalProdQty <> PRH.ProdQty THEN N'LỆCH SỐ LƯỢNG'
        ELSE N'KHỚP 100%'
    END;
```

---

## 7. 🔗 BẢN ĐỒ QUAN HỆ DỮ LIỆU ĐỘC QUYỀN: 8 PHÂN HỆ ADMIN POP VỚI CSDL MSSQL & MONGODB

> [!IMPORTANT]
> **Khám phá Quản trị Cấp cao (Admin Level Audit):** Khảo sát trực tiếp giao diện Admin `https://pop.vinatech.com/` kết hợp truy vấn Schema CSDL `VINATECH_POP`, `SmartFactoryV2` và `MongoDB` cho thấy toàn bộ các màn hình cài đặt Admin đều ánh xạ 1:1 sang các bảng dữ liệu cấu hình và quy tắc nghiệp vụ ngầm.

### 7.1 Ma Trận Ánh Xạ Toàn Diện (Web Admin Screen ➔ Database ➔ CSDL Đích)

| Phân hệ Admin | URL / Màn hình Web | Bảng CSDL Cốt Lõi (`VINATECH_POP`) | CSDL & Bảng Liên Quan (`SmartFactoryV2` / `MongoDB`) | Mục đích & Cơ Chế Vận Hành Ngầm |
|---|---|---|---|---|
| **1. Patch Management** | `/bbs/bbsList?bbsTypeId=patch` | `VINA_BBS_CONTENT`, `VINA_BBS_TYPE`, `VINA_SYSTEM_VERSION` | — | Lưu trữ lịch sử nâng cấp phiên bản hệ thống, bản vá lỗi Kiosk / PLC Agent |
| **2. Interlock Setting** | `/popSetting/interlockSetting` | `VINA_INTERLOCK_SETTING`, `VINA_INTERLOCK_RELEASE_LOG`, `VINA_PACK_GRADE_ITEM`, `VINA_ROUTE_DOC`, `VINA_ROUTE_TEST_SETTING` | `SmartFactoryV2.dbo.STB_ProdRouteHist`, `streamdocs.dbo.*` | Kiểm soát thứ tự Lot (FIFO), thời gian chờ tối thiểu (Min Dwell), khóa quá hạn (Max Dwell). Mở khóa qua tab `관리자 해제` |
| **3. Line Prod Mode** | `/popSetting/lineProdMode` | `VINA_LINE_PROD_MODE` | `SmartFactoryV2.dbo.MongoToMesPerformance` | Chế độ `SUBTRACT` (Đạt = Kế hoạch - Phế) vs `ADD` (Nhập tay sản lượng). Giải thích gốc rễ lỗi lệch mốc sản lượng |
| **4. Assembly Group Mapping** | `/popSetting/assemblyGroupMapping` | `VINA_ASSEMBLY_GROUP_MODE`, `VINA_GROUP_INPUT_ROUTE` | `SmartFactoryV2.dbo.STB_BomMaster`, `STB_MaterialMaster` | Chế độ `GROUP` quản lý 10 Slot nạp NVL linh hoạt theo mã nhóm `ProductGroupCode` thay vì ép cứng mã NVL theo BOM |
| **5. Quality Admin (Rollback)** | `/systemAdmin/qualityAdmin` | `VINA_REOPEN_REQUEST`, `VINA_REOPEN_POLICY` | `SmartFactoryV2.dbo.STB_CommInspDocMaster`, `STB_HoldingMaster`, `STB_DefectRepairInfo` | Xử lý yêu cầu hoàn tác kiểm tra (`되돌리기 요청`). Khi Approve, tự động gỡ `IsDone`, hủy lệnh HOLD và rollback phế trên MES |
| **6. Quality Equipment Bridge** | `/systemAdmin/qualityEquipment` | `VINA_QUALITY_ITEM_EQUIPMENT_MAP`, `VINA_QUALITY_EQUIPMENT_LINK`, `VINA_QUALITY_EQUIP_USE_HIST` | `VINATECH_WEBSOCKET.dbo.*` | Cầu nối thiết bị đo chất lượng (Caliper, Micrometer, CAS Scale...). Cơ chế Fallback Name Matching qua WebSocket Channel |
| **7. Equipment Data & IoT** | `/dataCollection/equipmentSetting`, `/dataCollection/modelSetting`, `/equipmentData/*` | `VINA_EQUIPMENT_SETTING`, `VINA_MODEL_SETTING`, `VINA_MODEL_SETTING_DETAIL`, `VINA_PC_MAC` | **MongoDB (Time-Series)**, `SmartFactoryV2.dbo.MongoToMesPerformance` | Cờ `EQUIPMENT_SETTING_AUTO_PERF = 'Y'`: PLC tự nhận diện Lot & chốt sản lượng không cần bấm Start. Lưu telemetry thô trên MongoDB |
| **8. Kiosk Central & Action Log** | `/dashboard/kiosk/dashboard`, `/pop/screen` | `VINA_POP_ACTION_LOG` (286K+ rows), `VINA_KIOSK_LOG`, `VINA_LABEL_PRINT_HIST` | `SmartFactoryV2.dbo.STB_SetInfo`, `STB_ProdRouteHist` | Giám sát 117 Kiosks toàn cầu. Ghi vết toàn bộ hành vi bấm nút, quét mã, thời gian phản hồi (DurationMs) và lỗi runtime |

---

### 7.2 Chi Tiết Các Cấu Trúc Bảng Cốt Lõi Mới Khám Phá

#### A. Bảng Quản Lý Khóa Liên Động: `VINA_INTERLOCK_SETTING` & `VINA_INTERLOCK_RELEASE_LOG`
- **`VINA_INTERLOCK_SETTING`**:
  - `LINE_CODE` (PK), `ROUTE_CODE` (PK), `INTERLOCK_TYPE` (PK): Gồm `FIFO_ORDER`, `MIN_WAIT`, `MAX_WAIT`.
  - `USE_YN`: Cờ kích hoạt (Y/N).
  - `PARAM_NUM1`: Giá trị tham số số học (Số phút chờ tối thiểu hoặc số phút tối đa cho phép trước khi khóa).
- **`VINA_INTERLOCK_RELEASE_LOG`** (Nhật ký mở khóa của Admin):
  - `RELEASE_LOG_ID`: Khóa tự tăng.
  - `BARCODE`, `ROUTE_CODE`, `DAY_PLAN_NO`, `LINE_CODE`: Xác định Lot và công đoạn bị khóa.
  - `ELAPSED_MIN`: Số phút thực tế Lot đã nằm chờ.
  - `LIMIT_MIN`: Ngưỡng quy định trong cấu hình.
  - `RELEASE_REASON`: Lý do Admin IT/QA mở khóa.
  - `STATUS`: Trạng thái (`LOCKED` ➔ `RELEASED`).
  - `NO_EMP_WRITER`: Mã nhân viên thực hiện mở khóa (Thường là `vanduc`).

#### B. Bảng Yêu Cầu Hoàn Tác Kiểm Tra Chất Lượng: `VINA_REOPEN_REQUEST`
- **Cột cốt lõi:**
  - `COMM_INSP_DOC_NO`: Số chứng từ biên bản kiểm tra (ví dụ: `20260920000162`).
  - `BARCODE`, `CONTROL_NO`, `MATERIAL_CODE`: Lot sản phẩm liên quan.
  - `REQUEST_REASON`: Lý do yêu cầu rollback (ví dụ: *"ko nhap dc kt"*).
  - `REQUESTER_EMP_NO`: Mã nhân viên QC yêu cầu (ví dụ: `32605038` - Nguyễn Đức Lâm).
  - `STATUS`: `PENDING` (Đang chờ duyệt), `APPROVED` (Đã duyệt), `REJECTED` (Từ chối).
  - `APPROVER_EMP_NO`, `APPROVE_DATETIME`: Mã người phê duyệt và thời điểm duyệt.
- **Hệ quả CSDL khi bấm Approve (`승인`):**
  1. `UPDATE VINATECH_POP.dbo.VINA_REOPEN_REQUEST SET STATUS = 'APPROVED'`
  2. `UPDATE SmartFactoryV2.dbo.STB_CommInspDocMaster SET IsDone = 0 WHERE CommInspDocNo = ...`
  3. `UPDATE SmartFactoryV2.dbo.STB_HoldingMaster SET IsDelete = 1 WHERE Barcode = ...`
  4. `UPDATE SmartFactoryV2.dbo.STB_DefectRepairInfo SET IsDelete = 1 WHERE Barcode = ...`

#### C. Bảng Cấu Hình Thiết Bị & Cờ Tự Động Hóa PLC: `VINA_EQUIPMENT_SETTING`
- **`EQUIPMENT_SETTING_AUTO_PERF`**: Char(1) — `Y`: Kích hoạt chế độ **"PLC 자동 실적 등록" (Tự động ghi nhận sản lượng PLC)**.
  - Khi bật `Y`, Kiosk không cần người thao tác bấm Bắt đầu. Bộ xử lý nền đọc dữ liệu nhịp counter từ MongoDB, tự động ánh xạ Lot đang nạp trên máy và ghi vào `MongoToMesPerformance`.
- **`EQUIPMENT_SETTING_LINE_CODE`**: Dây chuyền liên kết.
- **`EQUIPMENT_SETTING_DATA_COLLECTION_TIME`**: Chu kỳ đọc dữ liệu (giây).
- **`EQUIPMENT_SETTING_PROCESS_MODE`**: Chế độ công đoạn (`CONTINUOUS` - Liên tục, `BATCH` - Theo mẻ, `MANUAL` - Thủ công).

#### D. Bảng Giám Sát PC Biên: `VINA_PC_MAC`
- Quản lý **58 PC biên** chạy bộ cài `vinatechEquipmentDataSetup.exe`.
- **`PC_MAC_ADDRESS`**: Địa chỉ MAC vật lý của card mạng.
- **`PC_IPV4_ADDRESS`**: Địa chỉ IP mạng nội bộ của máy trạm.
- **`SYSTEM_VERSION`**: Phiên bản Client Agent (VD: 1.0.1 đến 1.2.33).
- **`EQUIPMENT_SETTING_JSON`**: Chuỗi JSON nạp cấu hình cổng COM (RS232), địa chỉ thanh ghi Modbus, hoặc đường dẫn thư mục File Scraper (AOI/XRF).

#### E. Bảng Nhật Ký Hoạt Động Kiosk Chi Tiết: `VINA_POP_ACTION_LOG`
- Hơn **286,800+ bản ghi**.
- Chứa toàn bộ vết thực thi: `ACTION_TYPE`, `LINE_CODE`, `DAY_PLAN_NO`, `LOT_NUMBER`, `ROUTE_CODE`, `EQUIPMENT_ID`, `RESULT_STATUS` (`PASS`/`FAIL`), `ERROR_MESSAGE`, `CLIENT_IP`, `DURATION_MS` (Độ trễ xử lý từng request), `PARAM_JSON` (Payload gửi lên).
- **Công cụ chẩn đoán số 1:** Khi Kiosk báo lỗi không rõ nguyên nhân, chỉ cần `SELECT TOP 10 * FROM VINA_POP_ACTION_LOG WHERE CLIENT_IP = '...' ORDER BY SEQ DESC` là xác định ngay mã lỗi và tham số gây crash.


