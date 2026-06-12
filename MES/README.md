# 🚀 VINATECH MES - SYSTEM INDEX

> **Mục đích:** Entry point chính cho toàn bộ hệ thống cơ sở tri thức & mã nguồn MES Vinatech
> **Cập nhật:** 2026-06-10
> **Quy tắc cốt lõi:** NO DIRECT UID - Tuân thủ quy tắc an toàn CSDL tuyệt đối

---

## 📁 CẤU TRÚC HỆ THỐNG MỚI (RESTURED)

Dưới đây là cấu trúc thư mục dự án thực tế sau khi được dọn dẹp và chuẩn hóa:

```
MES/
├── README.md                              # File này - Entry point chính
├── AI_AGENT_CONFIG/                       # Cấu hình tối ưu token dành cho AI Agent
│   ├── README.md                          # Entry point hướng dẫn load
│   ├── RULES.md                           # Quy tắc an toàn bắt buộc (Surgical changes, SELECT-only)
│   ├── KNOWLEDGE.md                       # Cheat sheet tra cứu nhanh bảng/SP
│   └── SKILLS.md                          # SQL/PS templates & lessons learned
├── MES_MASTER_KNOWLEDGE_BASE/             # Cơ sở tri thức nghiệp vụ MES & Groupware
│   ├── KB_INDEX.md                        # ← BẮT ĐẦU TRA CỨU TỪ ĐÂY
│   ├── KB_01_UI_PHAN_QUYEN.md             # Đăng nhập, phân quyền, Stage Prices
│   ├── KB_02_KHO_WMS.md                   # Kho NVL, FIFO, Hạn dùng, tách Lot
│   └── ... (các file chi tiết)
├── sql/                                   # Mã nguồn đối tượng CSDL
│   ├── hotfixes/                          # Lịch sử 5 SQL hotfix scripts đã triển khai trên production
│   │   ├── 01_FIX_DRY_OVEN_OPERATOR_PRIORITY.sql
│   │   ├── 02_FIX_DOPING_JIG_HISTORY_SYNC.sql
│   │   ├── 03_FIX_SLITTING_KNIFE_LIFE_METRIC.sql
│   │   ├── 04_FIX_REWORK_HARDCODED_PERMISSION.sql
│   │   └── 05_FIX_RETURNS_FG_IQC_VALIDATION.sql
│   └── scripts/                           # Các script thiết lập hệ thống
├── db_sync_tool.ps1                       # Tiện ích PowerShell để tải SP tạm thời từ DB (không check-in Git)
└── deploy_tool.ps1                        # Tiện ích PowerShell để triển khai SQL lên DB
```

---

## 🎯 QUICK START CHO NHÀ PHÁT TRIỂN / AI AGENT

### 1. Khi nhận yêu cầu sửa lỗi / Bug MES:
1. Đọc và tuân thủ quy tắc tại [AI_AGENT_CONFIG/RULES.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/AI_AGENT_CONFIG/RULES.md).
2. Tra cứu triệu chứng lỗi tại [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md).
3. Sử dụng [db_sync_tool.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/db_sync_tool.ps1) để tải Stored Procedure mới nhất từ DB server về để kiểm tra, tránh dùng bản cache cũ.

### 2. Khi cần thực thi SQL Query:
1. Tuyệt đối tuân thủ việc sử dụng `WITH(NOLOCK)` khi query các bảng giao dịch lớn.
2. Không tự ý chạy `INSERT/UPDATE/DELETE` trực tiếp. Phải viết script bọc trong `BEGIN TRANSACTION ... ROLLBACK` bàn giao để User chạy trên SSMS.

---

## 📋 HƯỚNG DẪN KNOWLEDGE BASE CHI TIẾT

### Hệ thống MES & Groupware ([MES_MASTER_KNOWLEDGE_BASE/](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/))

| File | Phạm vi nghiệp vụ | Màn hình liên quan |
|------|-------------------|-------------------|
| [KB_01_UI_PHAN_QUYEN.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_PHAN_QUYEN.md) | Login, phân quyền, Stage Prices | A460, Z410, Z220 |
| [KB_02_KHO_WMS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md) | Kho NVL, FIFO, Holding, Hạn dùng, Revert F430 | F330, F312, F430 |
| [KB_03_SAN_XUAT.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_03_SAN_XUAT.md) | JobDate, Chuyển Line, Xóa PO, NG, Cell Line | B782, B781, B310, B530 |
| [KB_04_DONG_GOI_IN_TEM.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_04_DONG_GOI_IN_TEM.md) | Đóng gói, fix B523, Lot, HN523 Qty=0 | B523, B789, B351, HN523 |
| [KB_05_QC_ELECTRODE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_05_QC_ELECTRODE.md) | QC B597/C443/C486, Điện cực B552, Rollback Slitting | B597, C443, C486, F742/F746 |
| [KB_06_MASTER_DATA_TOOLS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md) | Model mới, Cell/Line, Bypass, MaterialMaster SQL | A410, B250, B270, A230 |
| [KB_07_GROUPWARE_INTEGRATION.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_07_GROUPWARE_INTEGRATION.md) | Tích hợp Groupware: Mua hàng→F330, Kế hoạch→B310 | F330, B310, B450 |
| [KB_08_KHO_THANH_PHAM_HN.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_08_KHO_THANH_PHAM_HN.md) | Kho TP Hà Nam, xuất/hủy/xóa, STB_ChangeMaterialCode_HN | HN551, HN866, HN15 |
| [KB_09_IN_TEM_LABEL.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_09_IN_TEM_LABEL.md) | Tem đặc biệt, in khẩn, sai mẫu, kiến trúc Z530/A460 | B450, B756, B767, Z530 |
| [KB_10_KIEN_TRUC_VA_DATAFLOW.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_10_KIEN_TRUC_VA_DATAFLOW.md) | Kiến trúc hệ thống, sơ đồ Data Flow, SPs | Toàn bộ |
| [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md) | Phân tích sâu cốt lõi, DNA, Kết quả DB Audit | DB/Audit |
| [KB_14_TRACE_BUG_METHODOLOGY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_14_TRACE_BUG_METHODOLOGY.md) | Phương pháp trace bug 5 bước, Block Session DB | Toàn bộ |
| [KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_26_LIEN_KET_HE_THONG_VA_BUG_LOGIC.md) | Liên kết WMS-Sản xuất-QC-Xuất hàng, Cơ chế trừ kho Trigger | QC/WMS |
| [KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_27_SCM_REWORK_TRA_HANG_KIEM_KE.md) | Phân hệ SCM, Rework, Trả hàng (Returns), Kiểm kê (Stocktaking) | SCM/Rework |
| [KB_28_SYSTEM_OBJECTS_MAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_28_SYSTEM_OBJECTS_MAP.md) | Bản đồ đối tượng hệ thống (Bảng, SPs, Màn hình) | SmartFramework |
| [KB_29_SUPER_DEEP_SYSTEM_DISCOVERY_PROMPT.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_29_SUPER_DEEP_SYSTEM_DISCOVERY_PROMPT.md) | Siêu Prompt đào sâu bản chất màn hình & liên kết nghiệp vụ | Meta-Prompt |
| [KB_30_THIET_BI_PHU_TRO_SAY_GA_DAO.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/MES_MASTER_KNOWLEDGE_BASE/KB_30_THIET_BI_PHU_TRO_SAY_GA_DAO.md) | Phân hệ lò sấy (Dry Oven), Gá nạp Doping, Tuổi thọ dao Slitting | Thiết bị phụ trợ |

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
