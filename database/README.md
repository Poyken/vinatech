# 🚀 VINATECH MES & GROUPWARE - SYSTEM INDEX

> **Mục đích:** Entry point chính cho toàn bộ hệ thống MES & Groupware
> **Cập nhật:** 2026-06-03
> **Quy tắc cốt lõi:** NO DIRECT UID - Database là nguồn sự thật duy nhất

---

## 📁 CẤU TRÚC HỆ THỐNG MỚI (RESTURED)

Dưới đây là cấu trúc thư mục dự án sau khi được sắp xếp và phân loại khoa học:

```
database/
├── README.md                              # File này - Entry point chính
├── AI_CONFIG.md                           # Hướng dẫn AI debug lỗi & cấu hình
├── CLAUDE.md                              # Quy tắc hành vi coding cốt lõi
├── docs/                                  # Tài liệu nghiệp vụ & Phân tích hệ thống
│   ├── DATABASE_SCHEMA_QUICKREF.md        # Schema nhanh các bảng chính
│   ├── DataFlow.md                        # Data flow tổng quan của hệ thống
│   ├── electrode_weighing_analysis.md     # Tài liệu phân tích cân điện cực
│   └── huong_dan_cau_hinh_dbmail.md       # Tài liệu cấu hình DB Mail SQL Server
├── electrode.weighing/                    # Ứng dụng Desktop Cân Điện Cực (x64 Electron app)
├── sql/                                   # Mã nguồn đối tượng cơ sở dữ liệu SQL
│   ├── procedures/                        # Các Stored Procedure (Thủ tục lưu trữ)
│   │   ├── usp_AddStartDate.sql
│   │   ├── usp_DoChangeMaterialDocLotInfo.sql
│   │   ├── usp_MaterialDocLotInfo_get.sql
│   │   ├── usp_Vietnam_GetBoxIDForLotNo_VVT.sql
│   │   ├── usp_Vietnam_RawMaterialInputHist_uid.sql
│   │   └── usp_vvt_MaterialLotInfo_get.sql
│   ├── functions/                         # Các User-Defined Function (Hàm tự định nghĩa)
│   │   ├── fn_VVT_getdatebyVendorLot.sql
│   │   ├── fn_VVT_getdatebyVendorLot_MergeCode.sql
│   │   ├── alter_fn_VVT_getdatebyVendorLot.sql
│   │   └── alter_fn_VVT_getdatebyVendorLot_MergeCode.sql
│   ├── triggers/                          # Các Database Trigger
│   │   └── tgMaterialDocLotInfoIUD.sql
│   └── scripts/                           # Các script thiết lập & Tiện ích
│       └── Phoenix_Contact_Label_Setup.sql
├── MES_MASTER_KNOWLEDGE_BASE/             # Cơ sở tri thức MES (Tài liệu chuyên biệt)
│   ├── KB_INDEX.md                        # ← BẮT ĐẦU TRA CỨU TỪ ĐÂY
│   ├── KB_01_UI_PHAN_QUYEN.md
│   ├── KB_02_KHO_WMS.md
│   ├── KB_03_SAN_XUAT.md
│   ├── ... (các file chi tiết từ KB_01 đến KB_14)
│   └── NAIS_SYSTEM_MASTER_TROUBLESHOOTING.md
└── GROUPWARE_KNOWLEDGE_BASE/              # Cơ sở tri thức Groupware
    ├── GW_INDEX.md                        # ← Tra cứu các nghiệp vụ Groupware
    ├── GW_01_DANG_NHAP.md
    └── ... (các file chi tiết từ GW_01 đến GW_07)
```

---

## 🎯 QUICK START CHO NHÀ PHÁT TRIỂN / AI AGENT

### 1. Khi nhận yêu cầu Bug MES:
1. Mở và tra cứu ngay [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md) để tìm theo triệu chứng lỗi.
2. Kiểm tra log hoặc dùng các query mẫu để xác định nguyên nhân.
3. Tham chiếu mã nguồn Stored Procedure tương ứng trong thư mục [sql/procedures/](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/sql/procedures/).

### 2. Khi cần thực thi SQL Query:
1. Đọc kỹ các ràng buộc an toàn trong [CLAUDE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/CLAUDE.md) và [AI_CONFIG.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/AI_CONFIG.md).
2. Tuyệt đối tuân thủ việc sử dụng `WITH(NOLOCK)` và liệt kê rõ ràng danh sách cột (Không dùng `SELECT *`).

### 3. Khi nhận yêu cầu liên quan đến Groupware:
1. Tra cứu [GW_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/GROUPWARE_KNOWLEDGE_BASE/GW_INDEX.md).
2. Đọc file nghiệp vụ `GW_0X` tương ứng (Mua hàng, Kế hoạch, Master Data...).

---

## 📋 HƯỚNG DẪN KNOWLEDGE BASE CHI TIẾT

### Hệ thống MES ([MES_MASTER_KNOWLEDGE_BASE/](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/))
| File | Phạm vi nghiệp vụ | Màn hình liên quan |
|------|-------------------|-------------------|
| [KB_01_UI_PHAN_QUYEN.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md) | Login, phân quyền, Stage Prices | A460, Z410, Z220 |
| [KB_02_KHO_WMS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md) | Kho NVL, FIFO, Holding, Hạn dùng, Revert F430 | F330, F312, F430 |
| [KB_03_SAN_XUAT.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) | JobDate, Chuyển Line, Xóa PO, NG, Rollback công đoạn, Cell Line | B782, B781, B310, B530 |
| [KB_04_DONG_GOI_IN_TEM.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md) | Đóng gói, fix B523, Lot, HN523 Qty=0 | B523, B789, B351, HN523 |
| [KB_05_QC_ELECTRODE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md) | QC B597/C443/C486, Điện cực B552, Rollback Slitting F742 | B597, C443, C486, F742/F746 |
| [KB_06_MASTER_DATA_TOOLS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md) | Model mới, Cell/Line, Bypass, MaterialMaster SQL | A410, B250, B270, A230 |
| [KB_07_GROUPWARE_INTEGRATION.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_07_GROUPWARE_INTEGRATION.md) | Tích hợp Groupware: Mua hàng→F330, Kế hoạch→B310 | F330, B310, B450 |
| [KB_08_KHO_THANH_PHAM_HN.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md) | Kho TP Hà Nam, xuất/hủy/xóa, STB_ChangeMaterialCode_HN | HN551, HN866, HN15 |
| [KB_09_IN_TEM_LABEL.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_09_IN_TEM_LABEL.md) | Tem đặc biệt, in khẩn, sai mẫu, kiến trúc Z530/A460 | B450, B756, B767, Z530 |
| [KB_10_KIEN_TRUC_TONG_QUAN.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_10_KIEN_TRUC_TONG_QUAN.md) | Kiến trúc hệ thống, vòng đời dữ liệu | Toàn bộ |
| [KB_11_SP_DATAFLOW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_11_SP_DATAFLOW.md) | End-to-End Data Flow, Dictionary SP | DB/SP |
| [KB_12_DEEP_CORE_ANALYSIS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_12_DEEP_CORE_ANALYSIS.md) | Phân tích sâu cốt lõi, DNA hệ thống | DB/SP |
| [KB_13_DB_AUDIT.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_13_DB_AUDIT.md) | Nhật ký Audit DB, lỗi thực tế | DB/Audit |
| [KB_14_TRACE_BUG_METHODOLOGY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md) | Phương pháp trace bug 5 bước, Block Session DB | Toàn bộ |
| [NAIS_SYSTEM_MASTER_TROUBLESHOOTING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/NAIS_SYSTEM_MASTER_TROUBLESHOOTING.md) | Master Index lỗi trọng điểm - liên kết trực tiếp đến KB | Toàn bộ |

### Hệ thống Groupware ([GROUPWARE_KNOWLEDGE_BASE/](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/GROUPWARE_KNOWLEDGE_BASE/))
| File | Phạm vi nghiệp vụ |
|------|-------------------|
| [GW_02_MUA_HANG.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/GROUPWARE_KNOWLEDGE_BASE/GW_02_MUA_HANG.md) | Mua hàng, PO, nhà cung cấp |
| [GW_03_KE_HOACH_SX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/GROUPWARE_KNOWLEDGE_BASE/GW_03_KE_HOACH_SX.md) | Kế hoạch sản xuất |
| [GW_04_MASTER_DATA.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/GROUPWARE_KNOWLEDGE_BASE/GW_04_MASTER_DATA.md) | BOM, Model, Vật tư |
| [GW_05_HANH_CHINH.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/GROUPWARE_KNOWLEDGE_BASE/GW_05_HANH_CHINH.md) | Hành chính, nhân sự |
| [GW_06_THANH_TOAN.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/GROUPWARE_KNOWLEDGE_BASE/GW_06_THANH_TOAN.md) | Thanh toán, công nợ |

---

## ⚠️ QUY TẮC AN TOÀN QUAN TRỌNG KHI TÁC ĐỘNG DB

1. **NO DIRECT UID:** Tuyệt đối không tự ý chạy lệnh `INSERT`/`UPDATE`/`DELETE` trực tiếp thông qua terminal hoặc các tool tự động của AI. Chỉ chạy lệnh `SELECT` để kiểm tra.
2. **TRANSACTION SAFETY:** Các script sửa đổi dữ liệu bắt buộc phải được bọc trong block `BEGIN TRANSACTION ... ROLLBACK` và bàn giao để USER tự chạy thủ công qua SSMS.
3. **READ PERFORMANCE:** Luôn append `WITH(NOLOCK)` khi truy vấn các bảng giao dịch lớn (`STB_ProdRouteHist`, `STB_MaterialLotInfo`, v.v.) để tránh khóa bảng (block sessions).
4. **NO SPECULATIVE CODING:** Chỉ can thiệp đúng phạm vi lỗi được yêu cầu, giữ nguyên cấu trúc code xung quanh và khớp hoàn toàn style viết code hiện tại.

---

## 🔧 THÔNG TIN MÔI TRƯỜNG HỆ THỐNG

| Thông số | Giá trị |
|-----------|---------|
| **Server** | `dbserver.hycap.co.kr,5398` |
| **Database** | `SmartFactoryV2` |
| **Framework DB** | `SmartFramework` |
| **Username** | `vinaadmin` |
| **Platform** | NAIS / SmartFramework by Awoo |
| **Nhà máy** | VVT_F1 (Bắc Ninh), VVT_F2 (Bắc Giang), VVT_F3 (Hà Nam), VVT_F4 (Bắc Giang 2) |
