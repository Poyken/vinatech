<!--
AI-READY METADATA
Purpose: Ma trận nhà máy (Factory WorkCenter Matrix) tra cứu WorkCenterCode, Route prefix, Barcode format & Warehouse Mapping cho 6+ nhà máy
Scope: Factory Topology & WorkCenter Configuration
Single Source of Truth: KB_10_FACTORY_WORKCENTER_MATRIX.md (Factory WorkCenter & Barcode Rules)
Target Tables: STB_ProductionOrderInfo, STB_LineInfo, STB_MachineMaster, STB_YearInfo
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md)
  - [KNOWLEDGE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/KNOWLEDGE.md)
-->

# KB_10: Factory WorkCenter Matrix — Bản Đồ Nhà Máy (Verified)

> **📌 Mục đích:** Tra cứu nhanh WorkCenterCode → Nhà máy → Route → Barcode format.
> **🔑 Keywords:** factory, nhà máy, WorkCenter, VVT_F1, VVT_F3, VVT_F4, line, route, barcode format, BG, HN, HY
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)


---

## 1. Bảng Ánh Xạ 9 WorkCenter Codes

| # | WorkCenter | Company | Nhà máy | PO Count | Từ | Đến | Ghi chú |
|---|---|---|---|---|---|---|---|
| 1 | **VNT_F1** | VNT | **Bắc Ninh** (gốc) | 3,081 | 2018-08 | 2026-06 | Cell legacy — barcode `VJ` |
| 2 | **VVT_F1** | VVT | **Bắc Ninh** (mới) | 15,944 | 2019-09 | 2026-06 | **★ Chiếm 71% tổng PO** — barcode `VV` |
| 3 | **VNT_F2** | VNT | **Electrode/MEA** | 1,004 | 2021-12 | 2026-06 | Mixing/Coating/Rollpress/Slitting — barcode `MEA` |
| 4 | **VVT_F2** | VVT | **Bắc Giang 1** | 890 | 2024-01 | 2026-06 | Cell/Module BG1 |
| 5 | **VNT_F3** | VNT | **Hà Nam** (legacy) | 31 | 2023-07 | 2026-04 | Ít PO — đang migrate sang VVT_F3 |
| 6 | **VVT_F3** | VVT | **Hà Nam** (chính) | 1,125 | 2024-07 | 2026-06 | Dùng HN523, Marking Letter |
| 7 | **VNT_F4** | VNT | **BG2** (legacy) | 331 | 2024-10 | 2026-06 | Route VP01→VP18, ND01→ND10 |
| 8 | **VVT_F4** | VVT | **BG2** (mới) | 105 | 2026-02 | 2026-06 | Pass/Fail Route Status |
| 9 | **VNT_F5** | VNT | **Hưng Yên** | 39 | 2025-10 | 2026-06 | VinaEnesol — D100/D110 |

### Sơ đồ quan hệ VNT ↔ VVT

```
         VNT (Company gốc, 2018-2023)          VVT (Company mới, 2019-nay)
    ┌────────────────────────────────┐    ┌────────────────────────────────┐
    │  VNT_F1  = Bắc Ninh (3,081)   │───▷│  VVT_F1  = Bắc Ninh (15,944) │ ★
    │  VNT_F2  = MEA/Elec (1,004)   │    │  VVT_F2  = BG1 Cell (890)     │
    │  VNT_F3  = Hà Nam (31)        │───▷│  VVT_F3  = Hà Nam (1,125)     │
    │  VNT_F4  = BG2 (331)          │───▷│  VVT_F4  = BG2 (105)          │
    │  VNT_F5  = Hưng Yên (39)      │    │                                │
    └────────────────────────────────┘    └────────────────────────────────┘
                 ▲                                       ▲
         Legacy prefix VJ                      Current prefix VV
         (Barcode VJ...)                       (Barcode VV...)
```

> ⚠️ **Tại sao có cả VNT và VVT cho cùng nhà máy?**
> - VNT = CompanyCode ban đầu (Vinatech — pháp nhân cũ)
> - VVT = CompanyCode mới (VVT — pháp nhân mới)
> - Cùng DB `SmartFactoryV2`, cùng MES, chỉ khác CompanyCode
> - SP dùng CompanyCode để phân biệt: barcode prefix, kho NVL, logic in tem

---

## 2. Route Code theo Nhà Máy (Verified)

### Bắc Ninh (VVT_F1 / VNT_F1) — Route V-series

```
V-22 → V-23 → V-24 → V-25 → V-26 → V-27 → V-28
(Nhập)  (Hàn)  (Curl)  (Seal)  (Aging) (Check)(Đóng gói)
                                              ↓
                                          V-33 (Cascade)
```

### Bắc Giang 2 (VVT_F4 / VNT_F4) — Route VP-series + ND-series

```
Cell:  VP01 → VP02 → VP03 → ... → VP17 → VP18
Nordex: ND01 → ND02 → ND03 → ... → ND09 → ND10
```

### Hà Nam (VVT_F3 / VNT_F3) — Route VE-series

```
VE01 → VE03 → VE06 → VE07 → VE10
```

### Electrode/MEA (VNT_F2) — Route E-series

```
E-01 → E-02 → E-03 → E-28 → E-29 → E-33 → E-34
(Mix)  (Coat) (Roll) (Slit) (Check) (Cut)  (Bend)
```

---

## 3. Barcode Prefix Logic (Verified từ SP code + DB thực tế)

| Điều kiện | Prefix | Ví dụ thực |
|---|---|---|
| CompanyCode = 'VNT' | `VJ` | VJ... (Bắc Ninh legacy) |
| CompanyCode ≠ 'VNT' | `VV` | VVQO1812001E23 (BG, 2026-06-18) |
| MaterialTypeCode = 'MDL' + VNT | `MVJ` | MVJ... (Module Bắc Ninh) |
| MaterialTypeCode = 'MDL' + khác | `MVV` | MVV... (Module BG/HN) |
| WorkCenter = VNT_F2 (MEA) | `MEA` | MEA260618... |
| BG2 barcode K-series | `K` | K16418106262500679 |

### Format cấu trúc barcode

```
[Prefix][YearCode][MonthCode][DayCode][Serial]

YearCode: 2024=O, 2025=P, 2026=Q, 2027=R (từ STB_YearInfo)
MonthCode: Jan=J, Feb=K, Mar=L, Apr=M, May=N, Jun=O, Jul=P,
           Aug=Q, Sep=R, Oct=S, Nov=T, Dec=U (CHAR(Month+73))
DayCode: 01-31 (2 ký tự)
Serial: model-dependent format
```

---

## 4. Kho Theo Nhà Máy (Warehouse Mapping)

| Nhà máy | Kho NVL | Kho Hold | Kho Chuyền | Kho TP | Kho TP dự phòng |
|---|---|---|---|---|---|
| **BN (VVT_F1)** | `ROH_VN_WH` | `HOLDING_VN_WH` | `ROUTE_VN_WH` | `PROD_VN_WH` | `PROD_STBY_VN_WH` |
| **BG1 (VVT_F2)** | `ROH_BG_WH` | `HOLDING_BG_WH` | `ROUTE_BG_WH` | `PROD_BG_WH` | `PROD_STBY_BG_WH` |
| **HN (VVT_F3)** | `ROH_HN_WH` | `HOLDING_HN_WH` | `ROUTE_HN_WH` | `PROD_HN_WH` | `PROD_STBY_HN_WH` |
| **BG2 (VVT_F4)** | *(chưa có)* | *(chưa có)* | `ROUTE_BG2_WH` | *(chưa có)* | — |
| **HY (VNT_F5)** | `ROH_HY_WH` | `HOLDING_HY_WH` | `ROUTE_HY_WH` | *(chưa có)* | — |
| **BN legacy (VNT_F1)** | — | — | — | `PROD_WH` | — |

> ⚠️ **BG2 (F4) chỉ có 1 kho** — `ROUTE_BG2_WH`. Chưa setup đầy đủ ROH/HOLDING/PROD.
> ⚠️ **HY (F5) chưa có kho TP** — chỉ có ROH + HOLDING + ROUTE.

---

## 5. SP Validation Logic Theo Nhà Máy

### [B530] (ForBarcode SP) — Phân nhánh theo WorkCenter

```sql
-- Bắc Ninh + BG1 (VVT_F1, VVT_F2): Bắt buộc chọn máy (trừ V-28, V-27, V-33)
IF @WorkCenterCode IN ('VVT_F1','VVT_F2') AND @MachineCode='' AND @PoType NOT IN ('MODULE')
   AND @RouteCode NOT IN ('V-28','V-27','V-33','V-27_BG','V-28_BG','V-33_BG')
   → ERROR "Bạn phải chọn thiết bị thực hiện !"

-- Hà Nam (VVT_F3): Bắt buộc chọn máy MỌI Route
IF @WorkCenterCode IN ('VVT_F3') AND @MachineCode=''
   → ERROR "Bạn phải chọn thiết bị thực hiện !"

-- BG2 (VVT_F4): Check Pass/Fail Route tuần tự
IF @RouteCode = 'VP05' AND @WorkCenterCode = 'VVT_F4'
   AND VP04 status = 'Fail' → ERROR "Sản phẩm đã bị FAIL ở VP04"

-- BG2: Check lịch sử Route phải tồn tại
IF @WorkCenterCode = 'VVT_F4' AND @RouteCode NOT IN ('VP01')
   AND NOT EXISTS (ProdRouteHist cho Route này)
   → ERROR "Công đoạn này chưa hề được sản xuất"
```

---

*Cập nhật: 2026-06-18 | Verified against STB_ProductionOrderInfo (22,553 POs)*

---

## 4. 📊 Line Distribution per WorkCenter (DB Verified 2026-06-18)

> Nguồn: `STB_LineInfo` — Tổng **295 Lines**, **264 Active**

| WorkCenter | Total Lines | Active Lines | Ghi chú |
|---|---|---|---|
| **VVT_F1** | 126 | 126 | **★ Lớn nhất** — BN Cell/Module (100% active) |
| **VNT_F1** | 71 | 45 | BN legacy — 26 line đã ngừng |
| **VVT_F2** | 39 | 39 | BG1 — 100% active |
| **VVT_F5** | 15 | 15 | Reserved |
| **VVT_F3** | 14 | 14 | Hà Nam — 100% active |
| **VNT_F2** | 10 | 10 | MEA/Electrode |
| **VNT_F4** | 7 | 7 | BG2 legacy |
| **VNT_F5** | 7 | 2 | Hưng Yên — chỉ 2 line hoạt động |
| **VVT_F4** | 3 | 3 | BG2 mới |
| **VNT_F3** | 2 | 2 | HN legacy |
| (blank) | 1 | 1 | System |

### `STB_LineInfo` Schema (19 columns)

| Cột chính | Kiểu | Mô tả |
|---|---|---|
| `LineCode` | `varchar(20)` | **PK** — Mã Line |
| `CompanyCode` | `varchar(20)` | Mã công ty (VNT/VVT) |
| `WorkCenterCode` | `varchar(20)` | FK → WorkCenter |
| `LineName` | `nvarchar(100)` | Tên Line |
| `LineType` | `varchar(10)` | Loại Line |
| `ErpCode` | `varchar(20)` | Mã ERP tương ứng |
| `MonitoringGroup` / `MonitoringName` | `nvarchar(100)` | Nhóm/Tên monitoring |
| `IsUsed` | `bit` | Đang hoạt động? |
| `IsCheckScheduleMonitoring` | `bit` | Theo dõi lịch trình? |
| `MaterialWarehouseCode` | `varchar(50)` | Kho NVL gắn với Line |
| `ChildLines` | `varchar(255)` | Danh sách Line con |
| `TotalLossTime` | `numeric(9)` | Tổng thời gian hao phí |

### `STB_MachineMaster` Key Columns

| Cột | Kiểu | Mô tả |
|---|---|---|
| `MachineCode` | `varchar(20)` | **PK** — Mã máy |
| `CompanyCode` | `varchar(20)` | Mã công ty |
| `WorkCenterCode` | `varchar(20)` | FK → WorkCenter |
| `MachineName` | `nvarchar(200)` | Tên máy |
| `IsProdMachine` | `bit` | Máy sản xuất? |

### Machine-related Tables (31 tables total)

| Nhóm | Tables | Mô tả |
|---|---|---|
| **Master** | `STB_MachineMaster`, `STB_MachineBasicInfo`, `STB_MachineCapacity` | Thông tin cơ bản + Năng lực |
| **Maintenance** | `STB_MachinePmHistory`, `STB_MachinePmItem`, `STB_MachineRepairHistory` | Bảo trì + Sửa chữa |
| **IoT/VN** | `STB_VN_DEVICEMACHINES`, `STB_VN_STAGEMACHINES_*`, `STB_VN_STATUSMACHINE(S)` | Kết nối thiết bị VN |
| **Condition** | `STB_MachineConditionAlarm`, `STB_MachineConditionHist`, `STB_MachineConditionName` | Giám sát trạng thái |
| **Routing** | `STB_ProductMachine`, `STB_MachineByRoute_HN` | Machine↔Route mapping |

---

*Cập nhật: 2026-06-18 — Bổ sung Line distribution + STB_LineInfo schema (19 cols) + Machine tables (31 tables). DB verified.*

