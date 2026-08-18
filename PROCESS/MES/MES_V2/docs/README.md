# ⚡ VINATECH MES_V2 — Next-Gen Enterprise Operating Manual

Chào mừng đến với hệ thống **MES_V2** — nền tảng quản trị và vận hành tự động hóa cao cấp cho hệ thống NAIS MES tại Vinatech.

---

## 🚀 1. Khởi Động Nhanh (Quick Start)

Mọi thao tác quản trị, truy vấn, chẩn đoán và deploy đều được điều khiển qua cổng lệnh duy nhất `.\cli\mes.ps1`:

```powershell
# 1. Kiểm tra kết nối CSDL và chẩn đoán mạng
.\cli\mes.ps1 check

# 2. Thực thi truy vấn SELECT siêu tốc (Table / JSON / CSV)
.\cli\mes.ps1 query "SELECT TOP 10 MaterialCode, MaterialName FROM STB_MaterialMaster WITH(NOLOCK)"
.\cli\mes.ps1 query "SELECT @@SERVERNAME, DB_NAME()" -Format Json

# 3. Chẩn đoán Barcode 360° Golden Query & xuất báo cáo HTML
.\cli\mes.ps1 debug -Barcode "VVQL033R07279S" -Html

# 4. Tra cứu thông tin màn hình & ánh xạ Stored Procedure
.\cli\mes.ps1 debug -Screen "B523"

# 5. Deploy script SQL an toàn (bọc Transaction Guard)
.\cli\mes.ps1 deploy -Path ./sql/patches/fix_sample.sql

# 6. Đồng bộ định nghĩa Stored Procedure mới nhất từ DB
.\cli\mes.ps1 sync-sp -Name "usp_DoProcessProdRouteHist"

# 7. Dọn dẹp các Stored Procedure tạm thời trước khi commit Git
.\cli\mes.ps1 clean-sp
```

---

## 🗂️ 2. Cấu Trúc Tài Liệu Tri Thức (Docs Directory)

* 🗺️ [Master Knowledge Index](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/KB_MASTER_INDEX.md) — Tra cứu nhanh Mã màn hình $\rightarrow$ SP $\rightarrow$ Bảng $\rightarrow$ Lỗi
* 🏛️ **Kiến trúc Hệ thống (`docs/architecture/`):**
  * [01_system_overview.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/architecture/01_system_overview.md) — Tổng quan CSDL kép & 4 bảng cốt lõi
  * [02_core_sp_engine.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/architecture/02_core_sp_engine.md) — Phân tích Core SP Engine (DoProcess, Backflush, Packing)
  * [03_factory_matrix.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/architecture/03_factory_matrix.md) — Bản đồ các nhà máy (Bắc Ninh, Bắc Giang, Hà Nam, Hưng Yên)
* 🏭 **Nghiệp vụ Vận hành (`docs/operations/`):**
  * [01_wms_warehouse.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/01_wms_warehouse.md) — Quản lý kho, FIFO, Hạn dùng, Nhập F330, Xuất F430
  * [02_production_pop.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/02_production_pop.md) — POP Sản xuất: $B530 = B540 + B523 + C321$
  * [03_packaging_labels.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/03_packaging_labels.md) — Đóng gói & Quy chuẩn in tem Sanmina, PAC, DigiKey
  * [04_qc_electrode.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/04_qc_electrode.md) — Kiểm soát chất lượng & Quy trình điện cực
* 📺 **Màn Hình Chi Tiết (`docs/screens/`):** [Master Data](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/screens/a_master_data.md), [Sản Xuất B](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/screens/b_production.md), [QC C](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/screens/c_qc.md), [Kho F](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/screens/f_wms.md), [Hà Nam HN](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/screens/hn_hanam.md)
* 🛠️ **Cứu Hộ & Xử Lý Sự Cố (`docs/troubleshooting/`):**
  * [bug_playbook.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/troubleshooting/bug_playbook.md) — Sổ tay cứu hộ 70+ lỗi theo TCode
  * [hotfix_registry.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/troubleshooting/hotfix_registry.md) — Nhật ký các bản hotfix đã áp dụng
