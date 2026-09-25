# 🗂️ GROUPWARE — Knowledge Base Index

> **Cập nhật:** 2026-06-12 | **Nguồn:** extracted_text_utf8.txt + GROUPWARE User Manuals (Purchase, Production, Sales, Admin, Cost)
> **Cách dùng:** Đọc file INDEX này trước, sau đó mở file GW chuyên biệt theo nhóm chức năng.

---

## 📋 Danh sách file KB chuyên biệt

| File | Nội dung | Chức năng chính |
|------|----------|-----------------|
| [GW_00_CORE_OPERATING_PRINCIPLES.md](GW_00_CORE_OPERATING_PRINCIPLES.md) | **Bản chất cốt lõi & 7 Quy tắc vận hành bất biến** | **Kim chỉ nam tối cao, State Machine, Side-effects, Interlocks** |
| [GW_01_DANG_NHAP.md](GW_01_DANG_NHAP.md) | Đăng nhập, mật khẩu, chọn công ty | Login, Reset password, Bảng thông báo, Q&A |
| [GW_02_MUA_HANG.md](GW_02_MUA_HANG.md) | Luồng mua hàng đầy đủ: PO → Arrival → IQC → Receiving → Closing | Purchase Order, Inter-company PO, Hủy/Đóng PO, Hải quan & B/L |
| [GW_03_KE_HOACH_SX.md](GW_03_KE_HOACH_SX.md) | Tạo PO tháng, kế hoạch ngày, tạo Lot | Month Production Plan, Đồng bộ tự động từ Suju, Nguyên vật liệu, B310, B450 |
| [GW_04_MASTER_DATA.md](GW_04_MASTER_DATA.md) | Đăng ký mã code, BOM, nhà thầu/khách hàng/vendor | Item Registration (Cell/Module/Raw), BOM 2001, Partner Management |
| [GW_05_HANH_CHINH.md](GW_05_HANH_CHINH.md) | Công tác, ngày nghỉ, tuyển dụng, nghỉ việc, phê duyệt | Business Trip, Holiday Work, HR, Draft Document, AI Tinh Chỉnh |
| [GW_06_THANH_TOAN.md](GW_06_THANH_TOAN.md) | Yêu cầu thanh toán, chọn tài khoản, phê duyệt chi phí | Disbursement Document, Kéo liên kết PO, Phí Logistics |
| [GW_07_KHO_THANH_PHAM.md](GW_07_KHO_THANH_PHAM.md) | Vận hành kho thành phẩm và quản lý mã kho | FG01, B750, B752, Tra cứu mã kho Bắc Ninh/Bắc Giang/Hà Nam |
| [GW_08_BAN_HANG.md](GW_08_BAN_HANG.md) | Luồng bán hàng & xuất khẩu (Suju, Shipment, Invoice) | Sales Order (Suju), Shipment Request, Shipment Confirmation, 매출결의서 |
| [GW_09_DATABASE_ARCHITECTURE_AND_SCHEMA.md](GW_09_DATABASE_ARCHITECTURE_AND_SCHEMA.md) | Kiến trúc & Lược đồ CSDL VINATECH_GROUP | Generic Document Schema, 20+ Bảng nghiệp vụ, Khóa chính/ngoại, Triggers |
| [GW_10_APPROVAL_ENGINE_AND_LIFECYCLE.md](GW_10_APPROVAL_ENGINE_AND_LIFECYCLE.md) | Cỗ máy phê duyệt điện tử & Vòng đời văn bản | State Machine (001→002→008), Phân tuyến duyệt, Ủy quyền, Ký số PDF |
| [GW_11_TROUBLESHOOTING_AND_ERROR_SOLUTIONS.md](GW_11_TROUBLESHOOTING_AND_ERROR_SOLUTIONS.md) | Sổ tay cứu hộ & Xử lý 20+ sự cố thường gặp | Bảng chẩn đoán nhanh, Kẹt duyệt, Lỗi sync ERP, Mất kết nối F330 |
| [GW_12_CROSS_SYSTEM_INTEGRATION_GUIDE.md](GW_12_CROSS_SYSTEM_INTEGRATION_GUIDE.md) | Cẩm nang tích hợp đa hệ thống (GW ↔ ERP ↔ MES ↔ POP) | Luồng Mua hàng, Lệnh sản xuất, Bán hàng khép kín, SSO Mesh |
| [GW_13_BIZBOX_AI_AGENT_ENGINE.md](GW_13_BIZBOX_AI_AGENT_ENGINE.md) | Kiến trúc AI Agent & Dynamic APIs của Bizbox Alpha | VINA_AGENT_%, Spring Beans, Tool Calling, Quản lý Token |
| [GW_14_GROUPWARE_DATABASE_ROUTINES_AND_VIEWS.md](GW_14_GROUPWARE_DATABASE_ROUTINES_AND_VIEWS.md) | Sổ tay Stored Procedures, Functions & Views | usp_DoSyncMaterialUnit_itf_TF, UP_HR_WTMCALC_TIME_CALC, 4 Views lõi |
| [GW_15_GROUPWARE_ECOSYSTEM_DATABASES.md](GW_15_GROUPWARE_ECOSYSTEM_DATABASES.md) | Hệ sinh thái 5 CSDL thành phần hỗ trợ Groupware | VINATECH_RESTFUL, streamdocs, SPREADSHEET, WEBSOCKET, NEOE |
| [GW_16_FULL_FEATURE_DATABASE_MAPPING_BLUEPRINT.md](GW_16_FULL_FEATURE_DATABASE_MAPPING_BLUEPRINT.md) | **Bản thiết kế toàn cảnh: 100% tính năng & Ánh xạ CSDL** | **Field-level Schema, Bảng khóa ngoại, Stored Procedures, Interlocks** |
| [integrations/](integrations/README.md) | Bộ 10 tài liệu kỹ thuật tích hợp chuyên sâu | Purchase, Sales, HR, Planning, Master Data, SSO, Disbursement |

---


## ⚡ Tra cứu nhanh theo tình huống

| Tình huống | File & Mục |
|-----------|------------|
| Không đăng nhập được Groupware | GW_01 § 1 |
| Không nhớ mật khẩu hoặc cần reset | GW_01 § 3 |
| Muốn hỏi ý kiến người duyệt trên biểu mẫu | GW_01 § 6 |
| Yêu cầu mua hàng (Expense Report) | GW_02 § 1 |
| Tạo đơn mua hàng (PO) mới | GW_02 § 2 |
| Làm Arrival Confirmation | GW_02 § 3 |
| Không nhập được kho F330 | GW_02 § 3 (chưa duyệt Arrival?) |
| Làm Receiving Confirmation | GW_02 § 4 |
| Không làm được Receiving | GW_02 § 4 (C220 đã PASS chưa?) |
| Trả hàng về nhà cung cấp (Return Product) | GW_02 § 5 |
| Hủy đơn mua hàng bị sai (PO Cancel) | GW_02 § 6.1 |
| Đóng/Kết thúc đơn mua hàng (PO Closing) | GW_02 § 6.2 |
| Đóng sổ thanh toán (Purchase Resolution) | GW_02 § 7 |
| Nhận hàng mua từ công ty mẹ Hàn Quốc (Inter-company PO) | GW_02 § 8 |
| Tạo PO sản xuất theo tháng (Month Plan) | GW_03 § 1 |
| Tự động tạo kế hoạch sản xuất từ Suju | GW_03 § 2 |
| Tính toán nguyên vật liệu sản xuất từ BOM | GW_03 § 3 |
| PO không hiện trên MES (B310/B450) | GW_03 § 6 |
| Tạo kế hoạch ngày + Lot | GW_03 § 5 |
| Đăng ký mã vật tư mới (Cell/Module/NVL) | GW_04 § 1 |
| Cập nhật thông tin mã code | GW_04 § 2 |
| Tạo/sửa BOM trên ERP và Groupware | GW_04 § 3 |
| Đăng ký nhà thầu/khách hàng/vendor mới | GW_04 § 4 |
| Thay đổi thông tin nhà thầu/khách hàng | GW_04 § 4.2 |
| Form đi công tác (Business Trip) | GW_05 § 1 |
| Báo cáo công tác về (Trip Report) | GW_05 § 2 |
| Thay đổi lịch trình công tác (Trip Change) | GW_05 § 3 |
| Đăng ký đi làm ngày nghỉ/lễ (Holiday Work) | GW_05 § 4 |
| Báo cáo kết quả đi làm ngày lễ | GW_05 § 4 (Báo cáo đi làm) |
| Yêu cầu tuyển dụng (Emp Request) | GW_05 § 5 |
| Form nghỉ việc (Employee Retire) | GW_05 § 6 |
| Phê duyệt văn bản nội bộ tự do (Draft) | GW_05 § 7 |
| Làm yêu cầu thanh toán (Disbursement) | GW_06 § 1 |
| Tra cứu phí logistics vận chuyển | GW_06 § 5 |
| Xem tổng hợp đơn mua hàng (Purchase Total List) | GW_02 § 9 |
| Tạo đơn bán hàng/suju (Sales Order) | GW_08 § 1 |
| Bắn lệnh xuất hàng (Shipment Request) | GW_08 § 2 |
| Xác nhận xuất hàng & thông quan (Shipment Confirm) | GW_08 § 3 |
| Xuất kho thành phẩm trên MES (FG01) | GW_07 § 1 |
| In tem pallet (B750) | GW_07 § 2 |
| Tra cứu mã kho tại Việt Nam | GW_07 § Master List |

---

## 🔗 Luồng tích hợp dữ liệu Groupware ↔ MES ↔ ERP

### 1. Luồng mua hàng & quản lý kho nguyên vật liệu
```
[GROUPWARE]                          [MES]                            [ERP]
Expense Report (Duyệt)
        ↓
Purchase Order (Duyệt) ──────────────────────────────────────────────→ Tự động đăng ký PO
        ↓
Arrival Confirmation (Duyệt) ─────→ F330 (Thủ kho nhận hàng, in tem) ──→ Tự động đăng ký B/L
        ↓
                                ──→ C220 (IQC kiểm tra) → PASS
        ↓
Receiving Confirmation (Duyệt) ───→ Cập nhật tồn kho thực tế ──────────→ Cập nhật tồn kho ERP
        ↓
Purchase Resolution (Thanh toán) ─────────────────────────────────────→ Tự động tạo bút toán kế toán
```

### 2. Luồng bán hàng & xuất kho thành phẩm
```
[GROUPWARE]                          [MES]                            [ERP]
Sales Order Request (Suju) ──────────────────────────────────────────→ Tự động đăng ký đơn bán
        ↓
Shipment Request (Duyệt) ─────────→ FG01 (Quét Packing ID, trừ kho) ──→ Tự động đăng ký xuất
        ↓
Shipment Confirmation (Duyệt) ────→ B750 (In tem pallet, dán niêm phong) → Tự động đăng ký doanh thu
        ↓
Sales Resolution (Thanh toán) ───────────────────────────────────────→ Duyệt chứng từ kế toán
```

### 3. Luồng kế hoạch & lệnh sản xuất
```
[Suju Approved] (Groupware) ────────→ Tự động tạo Month Production Plan (Groupware)
                                                        ↓
                                            BOM 2001 & Tính toán NVL
                                                        ↓
                                            Xác nhận lô hàng (PO Trạng thái "Sản xuất")
                                                        ↓
[MES B310] (Giám sát PO) ←──────────────────────────────┘
        ↓
Kế hoạch ngày (Groupware)
        ↓
[MES B450] (Tạo LOT sản xuất, in tem lô mã)
        ↓
[MES sản xuất] B540 (Cell) → B597 → B530 (Module) → B523 (Thành phẩm)
```

---

## ⚠️ Các lỗi phổ biến & Checklist

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| PO không hiện trên B310 | PO chưa được "Xác nhận lô hàng" hoặc BOM version sai | Kiểm tra trạng thái PO trên GW, đổi sang "Sản xuất", kiểm tra BOM version 2001 |
| Không nhập được F330 | Arrival Confirmation chưa duyệt | Hỏi bộ phận Mua hàng duyệt trước |
| Không làm Receiving Confirmation | C220 IQC chưa Pass | Đội QC làm C220 Pass trước |
| Không đăng nhập được | Sai mật khẩu / sai company | Chọn đúng "VINATech VINA Co.,Ltd" |
| LOT hàng bị trả về kho lỗi | Đã làm Return Product Document | Kiểm tra trạng thái LOT trong MES và Return trên GW |
| Không tạo được Lot sản xuất | Phiên bản BOM khác 2001 | Sửa lại BOM version thành 2001 |

---

*Cập nhật: 2026-06-12 | Tổng hợp từ: GROUPWARE User Manuals + Comprehensive_Groupware_Report.md*

