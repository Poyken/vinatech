# 🗄️ DATABASE KNOWLEDGE BASE — MASTER INDEX (Mục Lục 15 CSDL)

> **Máy chủ trung tâm:** `dbserver.hycap.co.kr,5398` (SQL Server)  
> **Tổng số CSDL:** 15 Cơ sở Dữ liệu chuyên biệt  
> **Định danh kiến trúc:** 3 Trụ Cột Chiến Lược (Groupware — ERP — MES/POP)

---

## 🗺️ Bản Đồ 15 Cơ Sở Dữ Liệu Theo 3 Trụ Cột

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             HỆ SINH THÁI 15 CSDL VINATECH                         │
├───────────────────────┬──────────────────────────┬───────────────────────────────┤
│  1. TRỤ CỘT GROUPWARE │    2. TRỤ CỘT ERP SỔ CÁI │   3. TRỤ CỘT NHÀ XƯỞNG MES/POP│
├───────────────────────┼──────────────────────────┼───────────────────────────────┤
│ • VINATECH_GROUP      │ • NEOE (Douzone iU)      │ • SmartFactoryV2 (MES Core)   │
│ • WCMS_STANDARD_NEW   │ • DZICUBE (Bizbox Alpha) │ • SmartFramework (MES Auth)   │
│ • streamdocs          │ • erpdb (Legacy NeoPlus) │ • VINATECH_POP (Kiosk & PLC)  │
│ • VINATECH_SPREADSHEET│                          │ • AndonDB (Line Alert)        │
│ • VINATECH_DATA_KSOX  │                          │ • VINATECH_RESTFUL (SSO Token)│
│                       │                          │ • VINATECH_WEBSOCKET (IoT RT) │
│                       │                          │ • SmartFactoryIncubator (R&D) │
└───────────────────────┴──────────────────────────┴───────────────────────────────┘
```

---

## 📚 Danh Mục Chi Tiết 15 Cơ Sở Dữ Liệu

| Mã Số | Tên CSDL | Profile CLI | Quy Mô | Vai Trò Nghiệp Vụ & Chức Năng Cốt Lõi | Tài Liệu Chi Tiết |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **DB_01** | `SmartFactoryV2` | `SmartFactoryV2` | ~430 bảng | **MES Core:** Điều hành sản xuất 2 nhà máy, Quản lý Lot, Routing, WIP, Tem | [DB_01_SmartFactoryV2_MES.md](DB_01_SmartFactoryV2_MES.md) |
| **DB_02** | `SmartFramework` | `SmartFramework` | ~24 bảng | **MES Auth:** Quản trị người dùng, menu, phân quyền màn hình theo Z410 | [DB_02_SmartFramework.md](DB_02_SmartFramework.md) |
| **DB_03** | `VINATECH_GROUP` | `Groupware` | ~310 bảng | **Groupware:** Phê duyệt điện tử 17 Form (PO, PR, Daily Plan, HR, Sales) | [VINATECH_GROUP/README.md](VINATECH_GROUP/README.md) |
| **DB_04** | `NEOE` | `ERP` | 4,876 bảng | **ERP Douzone iU:** Sổ cái kế toán, Master Data gốc (Item, Partner, BOM, SL) | [NEOE/README.md](NEOE/README.md) |
| **DB_05** | `DZICUBE` | `Bizbox` | >3,300 bảng| **Bizbox Alpha:** Tích hợp kế toán, sinh bút toán tự động (`ABDOCU`), tài sản | [DZICUBE/README.md](DZICUBE/README.md) |
| **DB_06** | `VINATECH_POP` | `POP` | ~25 bảng | **POP Kiosk:** Trạm máy tính xưởng, auth địa chỉ MAC, thông số đọc PLC | [VINATECH_POP/README.md](VINATECH_POP/README.md) |
| **DB_07** | `AndonDB` | `Andon` | 3 bảng | **Andon Alert:** Giám sát dừng máy real-time, TV hiển thị, cảnh báo email/app | [AndonDB/README.md](AndonDB/README.md) |
| **DB_08** | `VINATECH_RESTFUL`| `SSO` | 3 bảng | **SSO & REST API:** Quản lý Token đăng nhập một lần, IP Whitelist, session | [VINATECH_RESTFUL/README.md](VINATECH_RESTFUL/README.md) |
| **DB_09** | `VINATECH_WEBSOCKET`| `WebSocket` | ~10 bảng | **IoT WebSocket:** Đẩy tín hiệu thời gian thực cho Andon, máy móc, Groupware | [VINATECH_WEBSOCKET/README.md](VINATECH_WEBSOCKET/README.md) |
| **DB_10** | `VINATECH_SPREADSHEET`| `Spreadsheet`| ~15 bảng | **Web Excel Online:** Lưu trữ bảng tính JSON `nvarchar(max)`, khóa đồng thời | [VINATECH_SPREADSHEET/README.md](VINATECH_SPREADSHEET/README.md) |
| **DB_11** | `WCMS_STANDARD_NEW`| `WCMS` | ~30 bảng | **Cash Management:** Cào sao kê ngân hàng tự động, quản lý thẻ tín dụng | [WCMS_STANDARD_NEW/README.md](WCMS_STANDARD_NEW/README.md) |
| **DB_12** | `SmartFactoryIncubator`| `Incubator`| ~50 bảng | **R&D Sandbox:** Đo kiểm cell tụ điện (ESR/Farad), thử nghiệm logistics ASN | [SmartFactoryIncubator/README.md](SmartFactoryIncubator/README.md) |
| **DB_13** | `VINATECH_DATA_KSOX`| `KSOX` | ~25 bảng | **K-SOX Compliance:** Quản lý tuân thủ kiểm soát nội bộ báo cáo tài chính ICFR | [VINATECH_DATA_KSOX/README.md](VINATECH_DATA_KSOX/README.md) |
| **DB_14** | `erpdb` | `LegacyERP` | 884 bảng | **Legacy ERP Archive:** Bảng tiếng Hàn (EUC-KR), lưu trữ dữ liệu lịch sử | [erpdb/README.md](erpdb/README.md) |
| **DB_15** | `streamdocs` | `StreamDocs` | ~15 bảng | **PDF Stream Engine:** Render tài liệu PDF web bảo mật, dọn dẹp file orphan | [streamdocs/README.md](streamdocs/README.md) |

---

## 📑 9 Chuyên Đề Tích Hợp Sâu Groupware (`VINATECH_GROUP/`)

1. [PURCHASE_INTEGRATION.md](VINATECH_GROUP/PURCHASE_INTEGRATION.md) — Quy trình mua sắm NVL từ PO đến Arrival, IQC, nhập kho và thanh toán.
2. [PRODUCTION_PLANNING.md](VINATECH_GROUP/PRODUCTION_PLANNING.md) — Kế hoạch tháng (Month Plan), lệnh ngày (Daily Plan) và chia tách Lot sản xuất.
3. [MASTER_DATA_INTEGRATION.md](VINATECH_GROUP/MASTER_DATA_INTEGRATION.md) — Đăng ký mã vật tư mới, BOM định mức 2001 và giá đối tác.
4. [DISBURSEMENT_INTEGRATION.md](VINATECH_GROUP/DISBURSEMENT_INTEGRATION.md) — Quyết toán chi phí mua sắm và quản lý chi phí Logistics.
5. [HR_AND_ADMIN_INTEGRATION.md](VINATECH_GROUP/HR_AND_ADMIN_INTEGRATION.md) — Quản lý nghỉ phép, tăng ca, công tác và bàn giao nhân sự.
6. [SALES_AND_SHIPMENT_INTEGRATION.md](VINATECH_GROUP/SALES_AND_SHIPMENT_INTEGRATION.md) — Luồng Suju bán hàng, phiếu xuất kho, thông quan và doanh thu.
7. [WAREHOUSE_AND_INVENTORY_INTEGRATION.md](VINATECH_GROUP/WAREHOUSE_AND_INVENTORY_INTEGRATION.md) — Vận hành kho thực tế MES FG01, B750, B752 và bảng mã kho.
8. [SSO_AND_SECURITY_INTEGRATION.md](VINATECH_GROUP/SSO_AND_SECURITY_INTEGRATION.md) — Tích hợp xác thực một lần qua API Token và IP Whitelist.
9. [ORGANIZATION_AND_WORKFLOW_INTEGRATION.md](VINATECH_GROUP/ORGANIZATION_AND_WORKFLOW.md) — Sơ đồ tổ chức nhân sự và luồng ký duyệt điện tử.

---

## ⚡ Các Lệnh Tra Cứu Nhanh Bằng CLI Hub `.\db.ps1`

- Kiểm tra tình trạng kết nối: `.\db.ps1 health`
- Tra cứu nhanh bảng/cột: `.\db.ps1 find "<TênBảng_Hoặc_TừKhóa>"`
- Xem cấu trúc bảng (schema): `.\db.ps1 schema <Profile> <TênBảng>`
- Chạy truy vấn an toàn: `.\db.ps1 query <Profile> "<CâuLệnhSQL>"`
