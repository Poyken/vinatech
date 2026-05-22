# 🚀 VINATECH MES & GROUPWARE - SYSTEM INDEX

> **Mục đích:** Entry point chính cho toàn bộ hệ thống MES & Groupware
> **Cập nhật:** 2026-05-22
> **Quy tắc:** NO DIRECT UID - Database là nguồn sự thật duy nhất

---

## 📁 CẤU TRÚC HỆ THỐNG

```
database/
├── README.md                        # File này - Entry point
├── AI_CONFIG.md                     # Hướng dẫn AI debug lỗi & cấu hình
├── Phoenix_Contact_Label_Setup.sql  # SQL cài đặt máy in tem Phoenix
├── docs/                            # Documentation tham khảo
│   ├── DATABASE_SCHEMA_QUICKREF.md  # Schema nhanh các bảng chính
│   └── DataFlow.md                  # Data flow tổng quan
├── scripts/                         # PowerShell scripts tự động hóa
│   ├── auto_debug_barcode.ps1       # Auto debug theo Barcode
│   ├── auto_check_common_issues.ps1 # Check lỗi thường gặp
│   ├── PERFORMANCE_METRICS.ps1      # Track performance scripts
│   ├── extract_pptx.ps1             # Extract text từ PPTX
│   └── fetch_sp.ps1                 # Fetch Stored Procedure từ DB
├── sql/                             # SQL files
│   ├── debug_queries.sql            # 20+ SQL templates debug
│   ├── C486_FINAL_DEPLOY.sql        # Deploy QC C486 (production)
│   ├── check_doping_routing.sql     # Check routing Doping
│   └── check_packing_lots.sql       # Check Lots đóng gói
├── sp_output/                       # Stored Procedures lấy từ DB
│   ├── usp_SetInfo_iud.sql
│   ├── usp_SetInfo_get.sql
│   ├── usp_vvt_MaterialLotInfo_get.sql
│   ├── usp_BomHeader_iud.sql
│   ├── usp_RouteInfo_iud.sql
│   ├── usp_ProductionOrderInfo_get.sql
│   ├── usp_MaterialWarehouseInOutHist_iud.sql
│   ├── usp_DoProcessProdGIMaterialByBOM.sql
│   ├── usp_DoProcessProdRouteHist.sql
│   ├── usp_GetMaterialLotInfo_Packing_VVT_F3.sql
│   ├── usp_VVTMaterialWarehouse_validFIFO.sql
│   ├── usp_getMergePackingBoxSmall_HN.sql
│   ├── usp_Vietnam_RawMaterialInputHist_uid.sql
│   ├── usp_VVT_SortingErrorData_ALCase_get.sql
│   ├── usp_VVT_SortingErrorData_ALCase_iud.sql
│   ├── usp_VVT_SortingErrorData_Plate_get.sql
│   └── usp_VVT_SortingErrorData_Plate_iud.sql
├── MES_MASTER_KNOWLEDGE_BASE/       # Knowledge Base MES (chính)
│   ├── KB_INDEX.md                  # ← BẮT ĐẦU TỪ ĐÂY
│   ├── KB_01_UI_PHAN_QUYEN.md
│   ├── KB_02_KHO_WMS.md
│   ├── KB_03_SAN_XUAT.md
│   ├── KB_04_DONG_GOI_IN_TEM.md
│   ├── KB_05_QC_ELECTRODE.md
│   ├── KB_05_TRACE_BUG_METHODOLOGY.md
│   ├── KB_06_MASTER_DATA_TOOLS.md
│   ├── KB_07_GROUPWARE_INTEGRATION.md
│   ├── KB_08_KHO_THANH_PHAM_HN.md
│   ├── KB_09_IN_TEM_LABEL.md
│   ├── NAIS_SYSTEM_MASTER_TROUBLESHOOTING.md
│   └── Vinatech_MES_Complete_DataFlow.md  # DataFlow đầy đủ (261KB)
├── GROUPWARE_KNOWLEDGE_BASE/        # Knowledge Base Groupware
│   ├── GW_INDEX.md
│   ├── GW_01_DANG_NHAP.md
│   ├── GW_02_MUA_HANG.md
│   ├── GW_03_KE_HOACH_SX.md
│   ├── GW_04_MASTER_DATA.md
│   ├── GW_05_HANH_CHINH.md
│   ├── GW_06_THANH_TOAN.md
│   └── GW_07_KHO_THANH_PHAM.md
└── GROUPWARE/
    └── extracted_text_utf8.txt      # Raw text extract từ 14 PPTX
```

---

## 🎯 QUICK START

### Khi nhận yêu cầu Bug MES:
1. Tra ngay `MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md` → tìm theo triệu chứng
2. Chạy `scripts/auto_debug_barcode.ps1 -Barcode "xxx"`
3. Chạy `scripts/auto_check_common_issues.ps1 -Barcode "xxx"`
4. Dùng `sql/debug_queries.sql` template phù hợp

### Khi nhận yêu cầu SQL Query:
1. Dùng `sql/debug_queries.sql` → chọn template phù hợp
2. Chạy query kiểm tra kết quả trước khi đề xuất

### Khi nhận yêu cầu Groupware:
1. Tra `GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md`
2. Đọc file GW_0X tương ứng

---

## 📋 KNOWLEDGE BASE INDEX

### MES (MES_MASTER_KNOWLEDGE_BASE/)
| File | Phạm vi | Màn hình |
|------|---------|----------|
| KB_01_UI_PHAN_QUYEN | Login, phân quyền, Stage Prices | A460, Z410, Z220 |
| KB_02_KHO_WMS | Kho NVL, FIFO, Holding, Hạn dùng | F330, F312, F430 |
| KB_03_SAN_XUAT | JobDate, ChuyểnLine, Xóa PO, NG | B782, B781, B310 |
| KB_04_DONG_GOI_IN_TEM | Đóng gói, fix B523, Lot | B523, B789, B351 |
| KB_05_QC_ELECTRODE | QC B597/C443/C486, Điện cực B552 | B597, C443, C486 |
| KB_05_TRACE_BUG_METHODOLOGY | Phương pháp trace bug 5 bước | Toàn bộ |
| KB_06_MASTER_DATA_TOOLS | Model mới, Cell/Line, Bypass | A410, B250, B270 |
| KB_07_GROUPWARE_INTEGRATION | Mua hàng→F330, Kế hoạch→B310 | F330, B310, B450 |
| KB_08_KHO_THANH_PHAM_HN | Kho TP Hà Nam, xuất/hủy/xóa | HN551, HN866 |
| KB_09_IN_TEM_LABEL | Tem đặc biệt, in khẩn, sai mẫu | B450, B756, B767 |

### Groupware (GROUPWARE_KNOWLEDGE_BASE/)
| File | Phạm vi |
|------|---------|
| GW_02_MUA_HANG | Mua hàng, PO, nhà cung cấp |
| GW_03_KE_HOACH_SX | Kế hoạch sản xuất |
| GW_04_MASTER_DATA | BOM, Model, Vật tư |
| GW_05_HANH_CHINH | Hành chính, nhân sự |
| GW_06_THANH_TOAN | Thanh toán, công nợ |

---

## 🔧 SCRIPTS INDEX

| Script | Mục đích | Cách dùng |
|--------|----------|-----------|
| auto_debug_barcode.ps1 | Debug theo barcode | `.\auto_debug_barcode.ps1 -Barcode "VE260506-001"` |
| auto_check_common_issues.ps1 | Check lỗi thường gặp | `.\auto_check_common_issues.ps1 -Barcode "xxx"` |
| fetch_sp.ps1 | Xem code SP từ DB | `.\fetch_sp.ps1 -SPName "usp_DoProcessProdRouteHist"` |
| PERFORMANCE_METRICS.ps1 | Track performance | `.\PERFORMANCE_METRICS.ps1` |
| extract_pptx.ps1 | Extract PPTX text | `.\extract_pptx.ps1` |

---

## 🗄️ SQL INDEX

| File | Mục đích |
|------|---------|
| debug_queries.sql | 20+ templates: Golden Query, SetInfo, Holding, FIFO, QC, Electrode, Packing, BOM, Logs... |
| C486_FINAL_DEPLOY.sql | Deploy đầy đủ cho màn hình C486 QC Electrode |
| check_doping_routing.sql | Kiểm tra routing công đoạn Doping |
| check_packing_lots.sql | Kiểm tra Lots trong quá trình đóng gói |

---

## ⚠️ QUY TẮC QUAN TRỌNG

1. **NO DIRECT UID** — Không tự ý chạy UPDATE/INSERT/DELETE
2. **SELECT TRƯỚC** — Luôn kiểm tra dữ liệu trước khi sửa
3. **BEGIN TRAN** — Dùng transaction để xem kết quả trước khi COMMIT
4. **KNOWLEDGE FIRST** — Tra KB trước khi suy đoán
5. **SINGLE SOURCE OF TRUTH** — Database là nguồn sự thật duy nhất

---

## 🔧 THÔNG TIN HỆ THỐNG

| Thông tin | Giá trị |
|-----------|---------|
| **Server** | `dbserver.hycap.co.kr,5398` |
| **Database** | `SmartFactoryV2` |
| **Framework DB** | `SmartFramework` |
| **Username** | `vinaadmin` |
| **Platform** | NAIS / SmartFramework by Awoo |
| **Nhà máy** | VVT_F1=Bắc Ninh, VVT_F2=Bắc Giang, VVT_F3=Hà Nam, VVT_F4=Bắc Giang 2 |
