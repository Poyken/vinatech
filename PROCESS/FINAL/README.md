# 🏛️ K-SYSTEM ACE ERP (FINAL) — TRỤ CỘT ĐÍCH ĐẾN HỢP NHẤT DOANH NGHIỆP

> **Hệ Thống:** YoungLimWon K-System Ace Web ERP Suite (`https://evn.vinatech.com/`)  
> **Đơn Vị Triển Khai:** YoungLimWon SoftLab Co., Ltd. (영림원소프트랩 Hàn Quốc & K-System Vietnam)  
> **Pháp Nhân:** `비나텍(베트남법인)` — Công ty TNHH Vinatech Vina (`CompanySeq = 1`)  
> **Quy Mô Hệ Thống:** **17 Phân hệ**, **213 Nhánh quy trình**, **4.473 Chương trình**, **6.890 Bảng CSDL**  
> **Cơ Sở Dữ Liệu:** `VINATECVN` (5.571 Tables Nghiệp vụ) & `VINATECVNCommon` (1.319 Tables Metadata)  
> **Vị Trí Chiến Lược:** **HẠT NHÂN HỘI TỤ TỐI CAO (UNIFIED ENTERPRISE DESTINATION)**

---

## 🧭 ĐỊNH HƯỚNG BẢN QUYỀN & TRỤ CỘT ĐÍCH ĐẾN

Hệ thống **K-System Ace** là nền tảng quản trị nguồn lực doanh nghiệp thế hệ mới của Vinatech Việt Nam, đại diện cho **Trụ Cột Thứ 4 (Trụ Cột Đích Đến - Final Consolidated Pillar)** trong không gian làm việc `PROCESS`.

Toàn bộ hệ thống cũ bao gồm:
1. **NAIS MES (`SmartFactoryV2`):** Được hợp nhất về Lệnh sản xuất, Định mức BOM, Quản lý kho theo LOT và Sản lượng chốt ca.
2. **POP Web Kiosk (`VINATECH_POP`):** Được chuẩn hóa về Trung tâm gia công (`_TPRWorkCenter`), định danh trạm máy và ghi nhận giờ công/giờ máy.
3. **Groupware (`VINATECH_GROUP`):** Được liên kết chặt chẽ qua mã phê duyệt tờ trình `DOCUMENT_SAVE_CODE`, đồng bộ hồ sơ 825 nhân sự (`_THREmp`).
4. **Douzone iU ERP (`NEOE`) & erpdb:** Được chuyển giao toàn bộ số dư đầu kỳ, danh mục tài khoản kế toán và tài sản cố định.
5. **Andon & Firm Banking (`AndonDB`, `WCMS_STANDARD_NEW`):** Tự động hóa cảnh báo dừng máy OEE và đối soát sao kê dòng tiền ngân hàng.

---

## 📚 HỆ THỐNG 4 TẬP ĐẶC TẢ KIẾN TRÚC VẬN HÀNH THÂM SÂU

Toàn bộ tri thức vận hành thâm sâu, cấu trúc bảng dữ liệu, luồng nghiệp vụ và thuật toán lõi được đóng gói trong thư mục [`ARCHITECTURE/`](ARCHITECTURE/):

* 📖 **[Tập 1: Bản Chất Cốt Lõi Vận Hành & Taxonomy Dữ Liệu](ARCHITECTURE/VOL_01_CORE_ENGINE_AND_DATA_TAXONOMY.md)**  
  *Kiến trúc Metadata-driven (Từ điển 840k mục, 152k cột, 122k controls), Giao diện MDI SPA, Tầng WCF Web Services, Cặp đôi CSDL VINATECVN & VINATECVNCommon, và Bảng mã 10 họ tiền tố bảng.*

* 📖 **[Tập 2: Phân Tích Toàn Diện 17 Phân Hệ & 213 Quy Trình](ARCHITECTURE/VOL_02_17_MODULES_COMPLETE_DEEPDIVE.md)**  
  *Khảo sát chuyên sâu 17 phân hệ (Điều hành, Master Data, Nhân sự, Lương, Kế toán, Fintech, Bán hàng, Thuế, Mua hàng, Sản xuất, QA/QC, Kho LOT, Giá vốn, EDI B2B, ESS, Dashboard, K-Smart Bridge).*

* 📖 **[Tập 3: Bản Thiết Kế Hợp Nhất Hệ Thống Cũ](ARCHITECTURE/VOL_03_LEGACY_CONSOLIDATION_BLUEPRINT.md)**  
  *Kế hoạch hợp nhất 6 hệ thống vệ tinh: Luồng 2 chiều ERP <-> MES qua phân hệ K-스마트, Quản trị kho bằng cờ `_TDAWH.IsMES`, Kết nối Groupware `DOCUMENT_SAVE_CODE`, và Đồng bộ hóa Tập đoàn mẹ Hàn Quốc.*

* 📖 **[Tập 4: Huyết Mạch Truy Vết LOT 360°, MRP & Giá Thành COGS](ARCHITECTURE/VOL_04_LOT360_MRP_AND_COGS_LIFECYCLE.md)**  
  *Giải phẫu màn hình trọng điểm FrmWPDLotList (PgmSeq: 522308) với 3 lưới đồng bộ, Đối chiếu 1-1 với Golden Query `.\mes.ps1 trace`, Thuật toán bóc tách MRP đa tầng, và Chu trình tự động tính giá thành đơn vị.*

---

## ⚡ TRUNG TÂM CHỈ HUY CLI HUB: `.\ksys.ps1`

Hệ thống cung cấp công cụ dòng lệnh chuyên dụng hỗ trợ kỹ sư và quản trị viên tra cứu tức thì:

```powershell
# 1. Tra cứu siêu tốc L1 Cache (<0.001s) qua 17 phân hệ và 213 quy trình
.\ksys.ps1 find "Lot"
.\ksys.ps1 find "K-스마트"
.\ksys.ps1 find "FrmWPDLotList"

# 2. Truy vết 360 độ Lô hàng / Lệnh sản xuất / Vật tư theo chuẩn FrmWPDLotList
.\ksys.ps1 trace "VVQR153R060609"
.\ksys.ps1 trace -WorkOrder "WO-202609-001"

# 3. Xem danh mục và số lượng quy trình của 17 Phân hệ
.\ksys.ps1 module
.\ksys.ps1 module -Seq 8      # Xem chi tiết Phân hệ Sản xuất
.\ksys.ps1 module -Seq 132    # Xem chi tiết Phân hệ K-Smart Bridge

# 4. Kiểm tra cấu trúc bảng hoặc danh sách bảng theo tiền tố
.\ksys.ps1 schema -Prefix "_TPR"
.\ksys.ps1 schema -Table "_TDAItem"

# 5. Kiểm tra trạng thái kết nối máy chủ CSDL K-System
.\ksys.ps1 health
```

---

## 🗂️ BẢNG TRA CỨU L1 CACHE SIÊU TỐC (<0.001s)

* **Ma Trận Phân Hệ & Chương Trình:** [`AI_AGENT_CONFIG/KSYSTEM_MATRIX.json`](AI_AGENT_CONFIG/KSYSTEM_MATRIX.json) — 17 phân hệ, 213 quy trình, PgmSeq tiêu biểu.
* **Ma Trận Ánh Xạ Liên Hệ Thống:** [`AI_AGENT_CONFIG/UNIFIED_INTEGRATION_MATRIX.json`](AI_AGENT_CONFIG/UNIFIED_INTEGRATION_MATRIX.json) — 7 tuyến tích hợp dữ liệu trọng yếu giữa K-System, MES, POP, Groupware, Douzone, Andon và Ngân hàng.
* **Quy Tắc Vận Hành An Toàn:** [`AI_AGENT_CONFIG/RULES.md`](AI_AGENT_CONFIG/RULES.md) — 8 quy tắc bất biến bảo vệ hệ thống Production.
