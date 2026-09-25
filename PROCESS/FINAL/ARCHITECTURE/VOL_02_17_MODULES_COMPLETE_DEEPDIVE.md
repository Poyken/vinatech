# 🏛️ TẬP 2: PHÂN TÍCH TOÀN DIỆN 17 PHÂN HỆ NGHIỆP VỤ & 213 QUY TRÌNH K-SYSTEM ACE
> **K-SYSTEM ACE ERP 17-MODULE FUNCTIONAL & TECHNICAL SPECIFICATION (VOLUME 2)**
>
> **Hệ Thống:** YoungLimWon K-System Ace Web ERP Suite  
> **Tổng Quy Mô:** **17 Phân hệ lớn**, **213 Nhánh quy trình nghiệp vụ (Process Menus)**, **4.473 Chương trình con (Executable Sub-Programs)**  
> **Cơ Sở Dữ Liệu:** `VINATECVN` (5.571 Tables) & `VINATECVNCommon` (1.319 Tables)  
> ← [Tập 1: Core Engine & Taxonomy](VOL_01_CORE_ENGINE_AND_DATA_TAXONOMY.md) | 📖 [Tập 3: Kế hoạch Hợp nhất Hệ thống Cũ](VOL_03_LEGACY_CONSOLIDATION_BLUEPRINT.md)

---

## 📑 BẢNG TỔNG QUAN 17 PHÂN HỆ NGHIỆP VỤ

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        K-SYSTEM ACE ERP — BẢN ĐỒ 17 PHÂN HỆ                           │
├─────────┬──────────────────────────────────┬──────────────┬──────────────┬─────────────┤
│ Mã Seq  │ Tên Phân Hệ Quản Trị             │ Số Quy Trình │ Số Form Con  │ Trọng Tâm   │
├─────────┼──────────────────────────────────┼──────────────┼──────────────┼─────────────┤
│ 1       │ Điều hành (Admin / Operations)   │ 17           │ 357          │ Hệ thống    │
│ 100     │ Cơ bản (Master Data)             │ 5            │ 105          │ Danh mục    │
│ 2       │ Nhân sự (HRM)                    │ 8            │ 168          │ Nhân sự     │
│ 3       │ Lương, thù lao (Payroll)         │ 30           │ 630          │ Chấm công   │
│ 4       │ Kế toán (General Accounting)     │ 30           │ 630          │ Tài chính   │
│ 118     │ Fintech (Banking Integration)    │ 5            │ 105          │ Ngân hàng   │
│ 6       │ Kinh doanh / Xuất khẩu (Sales)   │ 23           │ 483          │ Đơn hàng    │
│ 126     │ 회계결산/신고 (Closing & Tax)    │ 14           │ 294          │ Quyết toán  │
│ 7       │ Mua hàng / Nhập khẩu (Purchasing)│ 12           │ 252          │ Mua vật tư  │
│ 8       │ Sản xuất / gia công bên ngoài    │ 23           │ 483          │ Lệnh SX, BOM│
│ 9       │ Chất lượng sản phẩm (QA/QC)      │ 7            │ 147          │ IQC/PQC/OQC │
│ 10      │ Vật liệu (Warehouse / Inventory) │ 17           │ 357          │ Kho & LOT   │
│ 11      │ Giá vốn (Costing & COGS)         │ 5            │ 105          │ Giá thành   │
│ 15      │ Đặt hàng / nhận đơn đối tác      │ 1            │ 21           │ B2B EDI     │
│ 17      │ ESS (Employee Self-Service)      │ 3            │ 63           │ Cổng CBNV   │
│ 18      │ Mở đầu (Getting Started)         │ 12           │ 252          │ Dashboard   │
│ 132     │ K-스마트 (Smart Factory / MES)   │ 1            │ 21           │ Bridge MES  │
├─────────┴──────────────────────────────────┼──────────────┼──────────────┼─────────────┤
│ TỔNG CỘNG HỆ THỐNG                         │ 213          │ 4.473        │ Toàn diện   │
└────────────────────────────────────────────┴──────────────┴──────────────┴─────────────┘
```

---

## 🔍 PHÂN TÍCH CHUYÊN SÂU TỪNG PHÂN HỆ NGHIỆP VỤ

### 1. Phân Hệ 01: Điều Hành & Quản Trị Hệ Thống (Admin / Operations)
* **Quy mô:** 17 quy trình, 357 chương trình con thực thi.
* **Chức năng nghiệp vụ:**
  - Khai báo và cấu hình thông tin tổ chức, chi nhánh, nhà máy (`_TCACompany`).
  - Phân quyền theo ma trận 3 lớp: Nhóm người dùng ➔ Từng quy trình ➔ Từng nút bấm hành động (Save/Print/Excel).
  - Quản lý nhật ký truy cập (Audit Logs), theo dõi IP đăng nhập và thời lượng phiên làm việc.
  - Tích hợp nhận diện ký tự quang học (OCR) cho hóa đơn điện tử và chứng từ quét scan.
* **Màn hình trọng điểm:**
  - **`FrmWCMUserEntrySinCompanyWeb` (`PgmSeq: 525585`):** Đăng ký người sử dụng và cấp quyền đăng nhập Web.
  - **`FrmWCMPrcMenuGroupSecuEntry` (`PgmSeq: 524337`):** Ma trận gán quyền nhóm người dùng theo từng Process Menu.
  - **`FrmWCMPrcMenuPgmGroupSecuExcptAll` (`PgmSeq: 526700`):** Thiết lập ngoại lệ bảo mật cho từng màn hình cụ thể.

---

### 2. Phân Hệ 100: Cơ Bản & Danh Mục Dùng Chung (Master Data)
* **Quy mô:** 5 nhóm quy trình, 105 chương trình con thực thi.
* **Chức năng nghiệp vụ:**
  - Thiết lập danh mục vật tư sản xuất (`_TDAItem`): Tụ điện EDLC, tụ điện Hybrid, cuộn nhôm, màng ngăn cách, chất điện giải, dung môi, chân pin, vỏ nhôm, bao bì.
  - Danh mục khách hàng (`_TDACust`) và nhà cung cấp (`_TDAVendor`).
  - Quản lý danh mục kho bãi (`_TDAWH`): Đã nạp 8 kho tiêu chuẩn (Kho tổng, Kho hàng lỗi, Kho chuyển xưởng, Kho chờ bán, Kho bộ linh kiện, Kho chờ nhận hàng...).
  - Quản lý bảng tỷ giá ngoại tệ ngày (`_TDACurrRate`): USD, KRW, VND.

---

### 3. Phân Hệ 02: Quản Trị Nhân Sự (HRM)
* **Quy mô:** 8 nhóm quy trình, 168 chương trình con.
* **Chức năng nghiệp vụ:**
  - Hồ sơ nhân sự trích ngang của toàn bộ 825 cán bộ công nhân viên Vinatech Việt Nam (`_THREmp`).
  - Quản lý sơ đồ tổ chức phòng ban (`_THRDept`), chức danh, cấp bậc (Nhân viên, Trưởng nhóm, Quản đốc, Giám đốc khối).
  - Quản lý hợp đồng lao động, theo dõi thời hạn thử việc, tăng lương định kỳ và đánh giá hiệu suất KPI.

---

### 4. Phân Hệ 03: Chấm Công, Tiền Lương & Bảo Hiểm (Payroll)
* **Quy mô:** 30 nhóm quy trình, 630 chương trình con.
* **Chức năng nghiệp vụ:**
  - Thu thập dữ liệu máy quét vân tay / thẻ từ nhà xưởng và lịch làm việc ca kíp (`_TCOMCalendar` - 52.595 dòng lịch nạp sẵn).
  - Tự động tính toán công làm thêm giờ (OT ca ngày 150%, ca đêm 200%, ngày lễ 300%).
  - Tích hợp biểu tính thuế thu nhập cá nhân theo luật lao động Việt Nam (`_TPRBasTaxTableEmpCntTax` - 48.273 dòng dữ liệu).
  - Khấu trừ các khoản bảo hiểm xã hội (BHXH 8%, BHYT 1.5%, BHTN 1%) và sinh bảng thanh toán lương tháng tự động.

---

### 5. Phân Hệ 04: Kế Toán Tổng Hợp & Sổ Cái (General Accounting)
* **Quy mô:** 30 nhóm quy trình, 630 chương trình con.
* **Chức năng nghiệp vụ:**
  - Hệ thống tài khoản kế toán chuẩn mực Việt Nam (VAS) và Hàn Quốc (K-GAAP).
  - Đăng ký và xét duyệt chứng từ kế toán (`_TACSlip`, `_TACSlipD`).
  - Quản lý tài sản cố định (`_TACAsst`): Tính toán khấu hao đường thẳng máy móc sản xuất (máy quấn, máy hàn cực, lò sấy chân không).
  - **Động cơ tự động hóa hạch toán:** Bảng `_TACSlipAutoEnvRowCol` (31.277 quy tắc) tự động sinh phiếu kế toán nợ/có khi có nghiệp vụ xuất nhập kho hoặc nghiệm thu công đoạn.

---

### 6. Phân Hệ 118: Fintech & Ngân Hàng Điện Tử (Firm Banking)
* **Quy mô:** 5 nhóm quy trình, 105 chương trình con.
* **Chức năng nghiệp vụ:**
  - Kết nối trực tiếp qua giao diện API bảo mật với các ngân hàng lớn phục vụ FDI (Shinhan Bank Vietnam, Woori Bank, VietinBank).
  - Tự động cào sao kê dòng tiền vào/ra, đối soát số dư thời gian thực với sổ cái kế toán.
  - Tạo lệnh ủy nhiệm chi và chuyển khoản lô thanh toán tiền lương nhân viên hoặc trả tiền vendor.

---

### 7. Phân Hệ 06: Kinh Doanh, Đơn Hàng & Xuất Khẩu (Sales & Trade)
* **Quy mô:** 23 nhóm quy trình, 483 chương trình con.
* **Chức năng nghiệp vụ:**
  - Quản lý báo giá, tiếp nhận đơn đặt hàng bán (Sales Order / Suju) từ khách hàng toàn cầu.
  - Theo dõi tiến độ giao hàng theo hợp đồng thương mại, tạo hóa đơn xuất hàng (`_TSAInvoice`).
  - Quản lý chứng từ thủ tục hải quan xuất khẩu linh kiện tụ điện sang thị trường Mỹ, Châu Âu, Nhật Bản và Hàn Quốc.

---

### 8. Phân Hệ 126: Quyết Toán Kế Toán & Kê Khai Thuế (Tax Closing)
* **Quy mô:** 14 nhóm quy trình, 294 chương trình con.
* **Chức năng nghiệp vụ:**
  - Khóa sổ kế toán định kỳ cuối tháng, cuối quý và cuối năm tài chính.
  - Lập báo cáo thuế Giá trị gia tăng (GTGT), tờ khai thuế Thu nhập doanh nghiệp (TNDN) tạm tính.
  - Kết xuất Báo cáo tài chính hợp nhất phục vụ kiểm toán độc lập quốc tế và nộp báo cáo lên Tập đoàn mẹ tại Hàn Quốc.

---

### 9. Phân Hệ 07: Mua Hàng & Quản Lý Cung Ứng (Purchasing & Import)
* **Quy mô:** 12 nhóm quy trình, 252 chương trình con.
* **Chức năng nghiệp vụ:**
  - Quản lý yêu cầu mua sắm vật tư (Purchase Request - PR) từ các phân xưởng.
  - Phát hành đơn đặt hàng mua (Purchase Order - PO): `_TMAPOH` (Header) và `_TMAPOL` (Line).
  - Đánh giá năng lực nhà cung cấp (Vendor Rating), theo dõi tiến độ giao hàng và tỷ lệ hàng lỗi/đổi trả.

---

### 10. Phân Hệ 08: Quản Lý Sản Xuất & Lệnh SX (Manufacturing Execution)
* **Quy mô:** 23 nhóm quy trình, 483 chương trình con thực thi.
* **Chức năng nghiệp vụ trọng điểm:**
  1. `[Sản xuất] Thông tin cơ bản`: Thiết lập danh mục Routing công đoạn, nhóm máy (Work Center) và năng lực dây chuyền.
  2. `[Sản xuất] Thông tin thiết bị`: Quản lý nhật ký bảo dưỡng máy móc, chỉ số OEE và nhật ký dừng máy.
  3. `[Sản xuất] Thay đổi thiết kế ECO`: Quản lý các lệnh sửa đổi kỹ thuật, cập nhật linh kiện mới vào cấu trúc BOM.
  4. `[Sản xuất] Kế hoạch sản xuất tháng / tuần`: Lập kế hoạch sản xuất cấp cao (MPS) cân đối năng lực xưởng.
  5. `[Sản xuất] Hoạch định nhu cầu vật liệu (MRP)`: Thuật toán tự động bóc tách BOM để tính toán nhu cầu NVL cần cấp phát.
  6. `[Sản xuất] Xuất kho nguyên vật liệu`: Cấp phát NVL từ kho tổng sang kho chuyền phục vụ sản xuất.
  7. `[Sản xuất] Kết quả công việc`: Ghi nhận thực tế sản lượng hoàn thành theo từng công đoạn, giờ chạy máy và giờ nhân công.
  8. `[Sản xuất] Yêu cầu sản xuất lại / Rework`: Quản lý tái chế đối với bán thành phẩm sai hỏng kỹ thuật.
  9. **Màn hình Truy vấn truy xuất LOT 360° (`FrmWPDLotList` - `PgmSeq: 522308`):** Màn hình đối soát nguồn gốc toàn diện của sản phẩm (Routing ➔ Tiêu hao BOM ➔ Đơn mua PO).

---

### 11. Phân Hệ 09: Quản Lý Chất Lượng QA/QC (Quality Management)
* **Quy mô:** 7 nhóm quy trình, 147 chương trình con.
* **Chức năng nghiệp vụ:**
  - **IQC (Incoming Quality Control):** Kiểm tra nghiệm thu nguyên vật liệu cuộn nhôm, hóa chất đầu vào trước khi cho phép nhập kho.
  - **PQC (In-Process Quality Control):** Kiểm soát chất lượng trên dây chuyền (độ dày cực sau cán, dung sai quấn cell, thông số hàn).
  - **OQC (Outgoing Quality Control):** Nghiệm thu thành phẩm hoàn thiện trước khi đóng thùng xuất xưởng.
  - Quản lý phiếu phân tích nguyên nhân lỗi (8D Report, CAPA) và phân loại phế phẩm.

---

### 12. Phân Hệ 10: Quản Lý Vật Liệu & Kho LOT (Warehouse & Inventory)
* **Quy mô:** 17 nhóm quy trình, 357 chương trình con.
* **Chức năng nghiệp vụ:**
  - Quản lý kho theo nguyên tắc LOT-based Tracking: Mọi vật tư và bán thành phẩm đều bắt buộc phải gắn số LotNo.
  - **`FrmWLGMakingLotNoENV` (`PgmSeq: 524859`):** Cấu hình quy tắc sinh số Lot tự động (Lot Prefix, Year/Month, Serial).
  - **`FrmWLGWHLOTStockRealList` (`PgmSeq: 502903`):** Truy vấn chi tiết kiểm kê thực tế hàng tồn kho LOT theo từng kho.
  - **`FrmWLGWHLOTStockSumList` (`PgmSeq: 521504`):** Truy vấn tổng hợp số liệu xuất kho hàng hóa theo mã LOT.
  - Quản lý các giao dịch xuất nhập kho phi sản xuất (xuất hủy, xuất mẫu kiểm tra, xuất trả nhà cung cấp).

---

### 13. Phân Hệ 11: Quản Trị Giá Vốn & Giá Thành Sản Phẩm (Costing & COGS)
* **Quy mô:** 5 nhóm quy trình, 105 chương trình con.
* **Chức năng nghiệp vụ:**
  - Tự động thu thập chi phí nguyên vật liệu trực tiếp từ các lệnh xuất kho Module 10.
  - Tập hợp chi phí nhân công trực tiếp từ bảng chấm công ca kíp Module 3 và Module 4.
  - Phân bổ chi phí sản xuất chung (tiền điện nhà máy, khấu hao máy móc, vật tư phụ tiêu hao).
  - Tự động tính toán chi phí giá thành đơn vị (Unit Costing / COGS) cho từng mã tụ điện nhập kho.

---

### 14. Phân Hệ 15: Cổng Đặt Hàng B2B EDI (Partner Order Portal)
* **Quy mô:** 1 nhóm quy trình, 21 chương trình con.
* **Chức năng nghiệp vụ:** Cung cấp giao diện trao đổi dữ liệu điện tử (Electronic Data Interchange - EDI) cho khách hàng lớn và nhà cung ứng để tiếp nhận PO trực tuyến và thông báo lịch giao hàng tự động.

---

### 15. Phân Hệ 17: Cổng Tự Phục Vụ Cán Bộ Công Nhân Viên (ESS)
* **Quy mô:** 3 nhóm quy trình, 63 chương trình con.
* **Chức năng nghiệp vụ:** Dành cho 825 CBNV tra cứu phiếu lương cá nhân bảo mật trên điện thoại/máy tính, đăng ký xin nghỉ phép, tra cứu lịch làm việc ca và nhật ký công lao động.

---

### 16. Phân Hệ 18: Bảng Tin Điều Hành & Dashboard (Getting Started)
* **Quy mô:** 12 nhóm quy trình, 252 chương trình con.
* **Chức năng nghiệp vụ:** Bảng tin tổng hợp KPI Ban Giám đốc: Biểu đồ doanh thu ngày, tiến độ thực hiện Lệnh sản xuất, tỷ lệ hàng lỗi/NG toàn nhà máy, số dư tồn kho an toàn và cảnh báo dòng tiền.

---

### 17. Phân Hệ 132: Cầu Nối Nhà Máy Thông Minh K-Smart (Smart Factory Bridge)
* **Quy trình nền tảng:** `[K-SMART] 기본정보` (`Seq: 10002131`)
* **Quy mô:** 1 quy trình lõi, 21 chương trình con.
* **Chức năng:** Đây chính là **MẮT XÍCH CHIẾN LƯỢC QUAN TRỌNG NHẤT** phục vụ việc hợp nhất K-System với NAIS MES và POP Kiosk. Phân hệ đóng vai trò vùng đệm (Staging / Buffer) trao đổi hai chiều Lệnh sản xuất, Định mức BOM, Tồn kho LOT và Kết quả chốt công đoạn hiện trường.
