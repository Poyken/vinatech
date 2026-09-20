<!--
AI-READY METADATA
Purpose: Kiến trúc hệ thống POP, API endpoints, DB schema mapping, luồng dữ liệu
Scope: POP Web Architecture (Frontend → API → DB)
Single Source of Truth: POP_KB_01_ARCHITECTURE_AND_API.md
Target Tables: VINATECH_POP.dbo.* (66 bảng), SmartFactoryV2.dbo.STB_SetInfo, STB_ProdRouteHist, STB_MaterialLotInfo, STB_DayProdPlan
Last Updated: 2026-09-21 (Audit DB schema toàn diện 66 bảng)
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [KB_08_CORE_SP_ENGINE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md)
-->

# POP_KB_01 — Kiến Trúc Hệ Thống, API & DB Schema Mapping

> **Hệ thống:** POP Web Kiosk — `https://pop.vinatech.com/`  
> **Bảng chính:** `VINATECH_POP.*`, `SmartFactoryV2.STB_SetInfo`, `STB_ProdRouteHist`, `STB_MaterialLotInfo`  
> **🔑 Keywords:** architecture, API, endpoint, database, schema, SSO, authentication, REST, JSON  
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)

---

## 1. 🏗️ KIẾN TRÚC TỔNG THỂ

### 1.1 Stack Công Nghệ

| Layer | Công nghệ | Chi tiết |
|-------|-----------|----------|
| **Frontend** | Vue.js 2.x + Vuetify | SPA, responsive cho Kiosk touch |
| **API Server** | ASP.NET Core / Node.js | RESTful JSON, hosted IIS |
| **Database 1** | `VINATECH_POP` (MSSQL) | Bảng riêng POP: SSO token, material input hist, quality |
| **Database 2** | `SmartFactoryV2` (MSSQL) | Shared với MES: Lot, Routing, Kho, Master Data |
| **Auth** | SSO Token-based | `VINATECH_POP.dbo.VINA_SSO_LOGIN` + `VINA_SSO_TOKEN` |
| **Print** | Label printing via API | Gọi SP → Generate template → Push to printer |

### 1.2 Mô Hình Triển Khai

```
Internet/Intranet
     │
     ▼
┌─────────────────────────────────┐
│  IIS Web Server                  │
│  pop.vinatech.com               │
│  ├── /pop/screen  (SX Module)   │
│  ├── /pop/quality (QC Module)   │
│  └── /api/*       (REST API)    │
├─────────────────────────────────┤
│  DB Server: dbserver.hycap.co.kr│
│  Port: 5398                     │
│  ├── VINATECH_POP               │
│  ├── SmartFactoryV2             │
│  ├── SmartFramework             │
│  └── VINATECH_RESTFUL           │
└─────────────────────────────────┘
```

> **⚠️ QUAN TRỌNG:** POP Web và MES WinForm **chia sẻ cùng DB backend** (`SmartFactoryV2`).
> Mọi thay đổi trên POP sẽ **tức thì hiển thị** trên MES Desktop và ngược lại.

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
| POST | `/api/pop/screen/saveMaterialInput` | **Nhập NVL** — trừ kho | **WRITE** `VINA_MATERIAL_INPUT_HIST` + UPDATE `STB_MaterialLotInfo` |
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
     │    UPDATE: Qty = Qty - InputQty (trừ kho)
     │
     ├─→ VINATECH_POP.VINA_MATERIAL_INPUT_HIST
     │    INSERT: Log chi tiết nhập NVL
     │
     └─→ SmartFactoryV2.STB_SetInfo
          UPDATE: IsLineInput = 1 (đánh dấu đã nhập NVL)
```

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

### 3.5 🔄 Cơ Chế Data Pipeline Đồng Bộ 3 Tầng Giữa POP Kiosk & MES

Hệ thống có cơ chế đồng bộ tự động chạy ngầm liên tục giữa giao diện Kiosk POP và CSDL MES:

```
[Kiosk POP Web Client] 
      │ (Công nhân bấm chốt sản lượng / hoàn thành)
      ▼
[MongoDB / Cache Layer Kiosk]
      │
      ▼ (Ghi nhận tức thì)
[SmartFactoryV2.dbo.MongoToMesPerformance] ─── (SoT hiển thị Kiosk: IsDone=1, IsTransferred=0)
      │
      │ ⚡ Scheduled Polling Worker (pop.vinatech.com IIS, chu kỳ 1 - 2 phút)
      │    1. Quét: SELECT * FROM MongoToMesPerformance WHERE IsDone=1 AND IsTransferred=0 AND IsSkipped=0
      │    2. Sinh số ProdRouteHistNo: SmartFramework.dbo.usp_DoCreateSerial
      │    3. INSERT: SmartFactoryV2.dbo.STB_ProdRouteHist
      │    4. UPDATE: MongoToMesPerformance SET IsTransferred = 1, ModifyDateTime = GETDATE()
      ▼
[SmartFactoryV2.dbo.STB_ProdRouteHist] ─── (SoT báo cáo MES WinForm: B782, B530, B540)
```

#### 📌 Đặc điểm kỹ thuật & Bẫy vận hành (Gotchas):
1. **Background Polling Worker:** Không phải SQL Server Agent Job mà là tiến trình Worker ngầm trên IIS API Server (`pop.vinatech.com`), do kỹ sư Hàn Quốc Kim Hyung Jin (`[김형진]`) lập trình.
2. **Kiosk hiển thị tiến độ từ `MongoToMesPerformance`:** Nếu IT dùng SQL xóa bản ghi trong `STB_ProdRouteHist` để công nhân chốt lại, nhưng **chưa xóa bản ghi tương ứng trong `MongoToMesPerformance`**, thì Kiosk POP vẫn hiển thị dấu tích xanh `[✓]` và báo *"■ Công đoạn này đã hoàn thành"*, nút ghi nhận bị mờ! (Xem chi tiết lỗi tại [POP_KB_03 § 2.15](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md#215-pop-err-15-%C4%91%C3%A3-x%C3%B3a-stb_prodroutehist-nh%C6%B0ng-tr%C3%AAn-kiosk-pop-v%E1%BA%ABn-hi%E1%BB%87n-c%C3%B4ng-%C4%91o%E1%BA%A1n-n%C3%A0y-%C4%91%C3%A3-ho%C3%A0n-th%C3%A0nh)).
3. **Điểm nghẽn kẹt `IsTransferred = 0`:** Đã từng ghi nhận riêng dây chuyền **`VVC-11`** bị kẹt nhiều bản ghi `IsTransferred = 0` kéo dài từ 27/08 đến 19/09, trong khi các chuyền khác (`VVT_HY`, `VVT_F2`, `VVT_BN`) đồng bộ chỉ sau 30-60 giây. Cần chạy truy vấn kiểm toán định kỳ để giải tỏa.

### 3.6 📚 Danh Mục Đầy Đủ 66 Bảng CSDL VINATECH_POP (Kiểm Toán Thực Tế 2026-09-21)

Toàn bộ 66 bảng vật lý trong database `VINATECH_POP` trên server `dbserver.hycap.co.kr,5398` được phân loại theo 11 nhóm chức năng vận hành:

#### Nhóm 1: Core Operations & Kiosk Logs (Vận Hành & Nhật Ký Thao Tác)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_POP_ACTION_LOG` | 202,986 | **Nhật ký hành vi Kiosk cốt lõi**: Ghi nhận từng cú click, chuyển màn hình, quét barcode, thay đổi Line. Chạy liên tục 24/7. |
| `VINA_KIOSK_LOG` | 27,922 | Log kết nối Kiosk, IP client, trình duyệt, thời gian phiên làm việc. |
| `VINA_WIP_STOCK_HIST` | 1,720 | Lịch sử biến động bán thành phẩm (WIP) luân chuyển qua các công đoạn trên Kiosk. |
| `VINA_PACKING_REMAIN_QTY` | 2,165 | **Bảng quản lý tồn dư Lot lẻ khi đóng gói**: Phục vụ tính năng "Tìm Lot còn lại" & Merge Pack gộp thùng. |
| `VINA_KIOSK_SESSION` | 106 | Quản lý phiên làm việc active của từng máy trạm Kiosk. |
| `VINA_ASSEMBLY_GROUP_MODE` | 31 | Cấu hình chế độ làm việc theo nhóm lắp ráp. |
| `VINA_LINE_PROD_MODE` | 36 | Cấu hình chế độ sản xuất riêng của từng chuyền (VVT_HY, VVT_F2, VVC-11...). |
| `VINA_ROUTE_DOC` | 2 | Tài liệu / SOP hướng dẫn thao tác gắn với từng công đoạn trên UI Kiosk. |
| `VINA_PATH_SETTTING` | 1 | Đường dẫn lưu trữ tài liệu, file đính kèm, ảnh chụp QC của hệ thống. |
| `VINA_MATERIAL_INPUT_HIST` | 0 | *Bảng lịch sử nạp NVL POP*: Hiện 0 rows (thực tế nạp NVL được cập nhật thẳng vào `SmartFactoryV2.dbo.STB_MaterialLotInfo`). |

#### Nhóm 2: BOM & Material Route Mapping (Định Mức & Ánh Xạ NVL)
| Tên bảng | Số dòng (Rows) | Vai trò vận hành & Ghi chú |
|----------|---------------:|---------------------------|
| `VINA_BOM_INPUT_ROUTE` | 894 | Quy định công đoạn nào bắt buộc phải nạp NVL tương ứng theo BOM. |
| `VINA_MATERIAL_ROUTE_MAP` | 435 | Ánh xạ chi tiết danh mục vật tư NVL với Route Code thực tế tại xưởng. |
| `VINA_GROUP_INPUT_ROUTE` | 306 | Cấu hình nạp nhóm NVL theo tổ hợp công đoạn. |

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
| `VINA_INSP_MASTER_HIST_LOCK` | 1 | Khóa chặn sản xuất nếu bài test Master đầu ca chưa Pass hoặc đã hết hiệu lực. |
| `VINA_BLOOM_JUDGE_POLICY` | 258 | Chính sách phán định chất lượng hiện tượng Bloom (phồng rộp bọt khí) trên sản phẩm. |
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

