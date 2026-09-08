<!--
AI-READY METADATA
Purpose: Kiến trúc hệ thống POP, API endpoints, DB schema mapping, luồng dữ liệu
Scope: POP Web Architecture (Frontend → API → DB)
Single Source of Truth: POP_KB_01_ARCHITECTURE_AND_API.md
Target Tables: VINATECH_POP.dbo.*, SmartFactoryV2.dbo.STB_SetInfo, STB_ProdRouteHist, STB_MaterialLotInfo, STB_DayProdPlan
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [POP_SYSTEM_INTEGRATION_GUIDE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_SYSTEM_INTEGRATION_GUIDE.md)
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
| GET | `/api/common/getEquipmentList` | Thiết bị theo Line | READ `SmartFactoryV2.STB_EquipmentInfo` |

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

### 3.1 VINATECH_POP — Bảng Riêng POP (Đã Đối Chiếu Live DB 59 Bảng)

| Bảng | Mục đích | Vai trò vận hành POP |
|------|----------|----------------------|
| `VINA_MATERIAL_INPUT_HIST` | **Lịch sử nạp NVL** (SoT cho POP) | Ghi nhận chi tiết từng lần quét cuộn NVL, Lot, Qty, Worker, Route |
| `VINA_KIOSK_SESSION` | Phiên làm việc trên Kiosk | Quản lý token đăng nhập, trạng thái Kiosk, WorkerID ca hiện hành |
| `VINA_KIOSK_LOG` / `VINA_POP_ACTION_LOG` | Nhật ký thao tác Kiosk | Ghi lại hành vi bấm nút, đổi Line, quét mã, tải lệnh sản xuất |
| `VINA_LABEL_INFO` / `VINA_CUSTOM_LABEL` | Cấu hình tem nhãn Kiosk | Mẫu in ZPL, định dạng mã vạch Code128/DataMatrix cho máy in Zebra |
| `VINA_EQUIPMENT_MAPPING` | Gán thiết bị với Kiosk | Ánh xạ mã máy móc, cân điện tử RS232, PLC baseline theo dây chuyền |
| `VINA_PACKING_REMAIN_QTY` | Quản lý số lượng lẻ khi đóng gói | Theo dõi tồn dư của các Lot lẻ phục vụ tính năng "Tìm Lot còn lại" & Merge Pack |
| `VINA_QC_DECISION_HIST` | Lịch sử phán định QC trên POP | Lưu kết quả kiểm định IQC, PQC, OQC, FOQC và Route Judgment |
| `VINA_QUALITY_ITEM_EQUIPMENT_MAP` | Ánh xạ hạng mục đo với thiết bị đo | Liên kết chỉ tiêu chất lượng với máy đo tự động tại chuyền |
| `VINA_INTERLOCK_SETTING` | Cài đặt khóa liên động liên công đoạn | Ngăn chặn nhảy cóc công đoạn hoặc nạp sai NVL khi chưa hoàn tất kiểm tra |
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
| `STB_EquipmentInfo` | Master data thiết bị | Read only |

### 3.3 Sơ Đồ Data Flow — Nhập NVL (Material Input)

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

---

## 6. 🔧 CÂU SQL KIỂM CHỨNG KIẾN TRÚC

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
