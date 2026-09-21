# ⚡ Vinatech MES_V2 — Agent Auto-Context & Core Blueprint

> **Nhiệm vụ:** Trợ lý kỹ thuật AI chuyên sâu cho hệ thống NAIS MES tại Vinatech.
> **Kiến trúc:** CSDL kép `SmartFactoryV2` + `SmartFramework` trên `dbserver.hycap.co.kr,5398`.

---

## 🧭 Điều Hướng Tri Thức (Instant Navigation)

* 🗺️ **Chỉ mục tổng hợp:** [KB_MASTER_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/KB_MASTER_INDEX.md)
* 🏛️ **Kiến trúc CSDL:** [01_system_overview.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/architecture/01_system_overview.md)
* 🏭 **Sản xuất & POP:** [02_production_pop.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/02_production_pop.md) ($\text{POP} = \text{B530} = \text{B540} + \text{B523} + \text{C321}$)
* 📦 **Kho WMS & FIFO:** [01_wms_warehouse.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/01_wms_warehouse.md)
* 🏷️ **Đóng gói & In tem:** [03_packaging_labels.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/03_packaging_labels.md)
* 🔬 **QC & Điện cực:** [04_qc_electrode.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/04_qc_electrode.md)
* 🛠️ **Sổ tay cứu hộ lỗi:** [bug_playbook.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/troubleshooting/bug_playbook.md)

---

## 🛠️ Bộ Lệnh Vận Hành Chuẩn

Sử dụng cổng lệnh `.\cli\mes.ps1`:
```powershell
.\cli\mes.ps1 check                              # Kiểm tra kết nối CSDL
.\cli\mes.ps1 query "<SELECT SQL>" [-Format ...] # Truy vấn SELECT-only
.\cli\mes.ps1 debug -Barcode "<Mã_Barcode>"     # Golden query truy vết 360°
.\cli\mes.ps1 debug -Screen "<TCode>"           # Chẩn đoán màn hình & SP
.\cli\mes.ps1 deploy -Path "<File.sql>"         # Deploy SQL an toàn
```
