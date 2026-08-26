# ⚡ GEMINI.md — Auto-Context cho Vinatech MES Workspace (MES_V2 Architecture)

> **Mục đích:** File này được AI tự động nạp khi mở workspace. Chứa quy chuẩn vận hành an toàn và điều hướng tri thức cho kiến trúc hiện đại `MES_V2`.
> **Kiến trúc mới:** Xem chi tiết tại [MES_V2/docs/README.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/README.md) và [AGENT.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/.agent/AGENT.md)

---

## 🛡️ 10 Quy Tắc Vàng Bất Biến

> [!CAUTION]
> **1. SELECT-ONLY** — KHÔNG INSERT/UPDATE/DELETE/ALTER/DROP trực tiếp trên production DB ngoài công cụ deploy đã validate.
> **2. Script bọc Transaction** — Viết SQL fix bọc `BEGIN TRAN...ROLLBACK` $\rightarrow$ kiểm thử an toàn trước khi deploy.
> **3. KNOWLEDGE-FIRST HARD STOP** — CẤM CHẠY SQL QUERY KHI CHƯA TRA KB! Bắt buộc tra [bug_playbook.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/troubleshooting/bug_playbook.md) trước.
> **4. TOKEN OPTIMIZATION** — Sử dụng hệ thống tài liệu phân tầng trong `MES_V2/docs/`, phản hồi ngắn gọn 3 khối.
> **5. Hỏi trước khi làm** — Thiếu thông tin hoặc nghi ngờ $\rightarrow$ dừng hỏi user ngay.
> **6. GOLDEN QUERY FIRST** — Dùng Golden Query quét 360° SetInfo, LotInfo, RouteHist qua `.\MES_V2\cli\mes.ps1 debug -Barcode ...`.
> **7. IMMEDIATE SCREEN MAPPING** — Khi nhận mã màn hình (B523, B530, C530...), tra ngay cặp SP `_get` / `_iud` và bảng DB từ [KB_MASTER_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/KB_MASTER_INDEX.md).
> **8. CẤM CHÈN BẢN GHI GIẢ LẬP (DUMMY)** — Mọi thao tác fix dữ liệu phải tuân thủ 100% quy trình từ tài liệu SoT.
> **9. 4-TABLE SYNC INTEGRITY** — Sửa bất kỳ Lot nào phải đồng bộ đủ 4 bảng (`STB_SetInfo`, `STB_MaterialLotInfo`, `STB_ProdRouteHist`, `STB_LotChangeMaterialHistory`).
> **10. SỬ DỤNG CÔNG CỤ THỐNG NHẤT** — BẮT BUỘC chỉ sử dụng cổng lệnh hợp nhất `.\MES_V2\cli\mes.ps1`.

---

## 🔌 Cổng Lệnh Hợp Nhất `.\MES_V2\cli\mes.ps1`

```powershell
.\MES_V2\cli\mes.ps1 check                              # Kiểm tra kết nối CSDL & mạng TCP
.\MES_V2\cli\mes.ps1 query "SELECT..." -Format Json     # Truy vấn SELECT siêu tốc (Table/JSON/CSV)
.\MES_V2\cli\mes.ps1 debug -Barcode "VVNP263R033573"    # Quét 360° Golden Query Live
.\MES_V2\cli\mes.ps1 debug -Screen "B523"               # Chẩn đoán UI Objects & SP Mapping
.\MES_V2\cli\mes.ps1 sync-sp -Name "usp_..."            # Đồng bộ Stored Procedure trực tiếp
.\MES_V2\cli\mes.ps1 clean-sp                           # Dọn dẹp SP tạm thời
.\MES_V2\cli\mes.ps1 deploy -Path ./sql/...             # Deploy SQL an toàn
```

---

## 🧭 Tra Cứu Nhanh Tri Thức `MES_V2`

* **Chỉ mục tổng hợp:** [KB_MASTER_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/KB_MASTER_INDEX.md)
* **Kiến trúc CSDL & SP:** [01_system_overview.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/architecture/01_system_overview.md), [02_core_sp_engine.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/architecture/02_core_sp_engine.md)
* **Sản xuất & POP:** [02_production_pop.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/02_production_pop.md) ($\text{POP} = \text{B530} = \text{B540} + \text{B523} + \text{C321}$)
* **Kho WMS & FIFO:** [01_wms_warehouse.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/01_wms_warehouse.md)
* **Đóng gói & Tem Sanmina:** [03_packaging_labels.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/03_packaging_labels.md)
* **QC & Điện cực:** [04_qc_electrode.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/04_qc_electrode.md)
* **Sổ tay cứu hộ 70+ lỗi:** [bug_playbook.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/troubleshooting/bug_playbook.md)
