# NAIS MES - FLOW END-TO-END TOÀN BỘ NHÀ MÁY

> Tổng hợp từ tất cả tài liệu đã đọc | Cập nhật: 2026-03-07

---

## 🏭 SƠ ĐỒ TỔNG QUAN

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          THIẾT LẬP BAN ĐẦU (1 lần)                        │
│  A210 (Loại NVL) → A230 (Mã NVL) → A310 (BOM) → A410 (Chi tiết model)    │
│  A460 (Tem/model) → A418 (Số lượng đóng gói/size)                         │
│  B210-B270 (Line, công đoạn, route, thiết bị, công nhân)                  │
│  F110 (Thuộc tính tồn kho) → F130/F140 (NCC ↔ NVL)                       │
│  C111-C113 (Thống kê, AQL) → C121 (Nhóm KT) → C131/C132 (Mã lỗi)        │
│  C141 (PQC setup) → C143 (PQC/model) → C151 (OQC/model)                  │
│  Z410/Z220/Z330 (User, phân quyền, menu)                                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: KHO NVL NHẬP HÀNG                                               │
│                                                                             │
│  F312 (Ghi chú NVL, số invoice)                                            │
│    ↓                                                                        │
│  F330 (Nhập kho → ARRIVAL → Tách tem → Số lot no → Đặc tính 10)           │
│    ↓                                                                        │
│  C220 (IQC kiểm tra NVL đầu vào) ← C122 (hạng mục đã config)             │
│    ↓                                                                        │
│  F430 (Xuất NVL ra cell line) ⚠️ Phải có Đặc tính 10                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: LẬP KẾ HOẠCH SẢN XUẤT                                          │
│                                                                             │
│  B310 (Tạo PO theo tháng - BOM ver 99)                                     │
│    ↓ Chốt PO                                                               │
│  B450 (Kế hoạch ngày: line, ca, số lượng)                                  │
│    ↓ FixDayPlan → SX mới tạo lot được                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: SẢN XUẤT TRÊN CELL LINE                                         │
│                                                                             │
│  B540 - Nhập thẻ công đoạn (3 chức năng):                                  │
│    ├── [Sấy hàng] → In barcode                                             │
│    ├── [Kiểm tra thường xuyên]                                             │
│    │     ├── Khung A: Thông số sau sấy (ngoại quan, đo đạc)               │
│    │     └── Khung B: Scan mã NVL (phải order từ kho trước)               │
│    └── [Nhập slg SX] → Chọn lỗi (từ C132) → Nhập DefectQty               │
│          → Nhập lỗi → Hoàn thành kết quả SX                               │
│                                                                             │
│  Song song:                                                                 │
│    B597 (Nhập thông số kiểm tra - mã TEST từ C143)                         │
│    C443 (PQC kiểm tra - mã QUALITY từ C143)                                │
│    B530 (Nhập lỗi từng công đoạn - lỗi từ C132)                           │
│    B598 (Báo phế NVL hỏng)                                                 │
│    C385 (Báo cáo bất thường → email) → C390 (Xem lại)                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: ĐÓNG GÓI                                                         │
│                                                                             │
│  B523 (Gộp box → In tem box to → Chia box → In tem box nhỏ)               │
│    ⚠️ In tem 1 lần duy nhất, in trước mới chia được                       │
│    ⚠️ PackQty theo config A418                                              │
│                                                                             │
│  B453 (In tem Inner/Outer cho xuất hàng)                                   │
│    - INNER: không tick IsOuter                                              │
│    - OUTER: tick IsOuter + BoxQTY + Number Of Total                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 5: OQC KIỂM TRA THÀNH PHẨM                                        │
│                                                                             │
│  C512 (Tạo lot OQC - cần barcode từ SX)                                    │
│    ↓                                                                        │
│  C530 (Kiểm tra từng mẫu - 5 bước, chậm)                                  │
│    ↓                                                                        │
│  C540 (Lịch sử kiểm tra)                                                   │
│    ↓                                                                        │
│  C546 (Kiểm tra ESR - khi xuất kho) → C541 (Lịch sử ESR)                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 6: KHO THÀNH PHẨM                                                   │
│                                                                             │
│  FG01 (Tồn kho TP Bắc Ninh)                                               │
│  FG00 (Tồn kho TP Bắc Giang)                                              │
│  HN00 (Tồn kho TP Hà Nam)                                                  │
│  FG02 (Tồn kho tổng hợp BN + BG)                                          │
│  B525 (Đóng gói + in tem kho TP) ← chưa có tài liệu                      │
│  B528 (Lịch sử đóng gói gộp thùng xuất hàng) ← chưa có tài liệu         │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  HOÀN TRẢ NVL (khi dư)                                                     │
│  F610 (Yêu cầu hoàn trả từ cell line về kho)                              │
│  F620 (Thực hiện hoàn trả)                                                  │
│  F430 (Nhập lại - chỉ khi xuất nhầm)                                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  SLITTING - HÀ NAM                                                         │
│  F744 (Config chiều rộng) → F743 (Cắt foil) → C243 (QC check)             │
│  → F430 (Chuyển về kho NVL)                                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  IMPORT DATA (Máy phân cấp)                                                │
│  CSV → XLSX → B934 (Import) → B935 (Lịch sử)                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  BÁO CÁO (Quản lý)                                                         │
│  B781 (Sản lượng + đơn giá) │ B682 (Lỗi tổng) │ B782 (Lỗi chi tiết)      │
│  B726 (NG + holding)         │ B718 (NG cơ khí)  │ B802 (NG điện cực)      │
│  B791 (Phế module)                                                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 BẢNG TRA CỨU NHANH - TẤT CẢ MÀN HÌNH

### Config chung (A)
| Màn | Chức năng | Thuộc flow |
|-----|-----------|-----------|
| A130 | Đối tác giao dịch | Setup |
| A210 | Loại vật liệu (FERT, HALB, ROH...) | Setup |
| A230 | Mã NVL (→ Groupware) | Setup |
| A310 | BOM (→ Groupware) | Setup |
| A410 | Chi tiết model (thông số, MBISizeD) | Setup → C151, A418 |
| A418 | Số lượng đóng gói/size | Setup → B523 |
| A460 | Tem theo model | Setup |

### Kho NVL (F)
| Màn | Chức năng | Thuộc flow |
|-----|-----------|-----------|
| F110 | Thuộc tính tồn kho (IsUseBarCode, IsLotUse) | Setup |
| F130 | NCC → NVL | Setup |
| F140 | NVL → NCC | Setup |
| F312 | Ghi chú NVL đầu vào (invoice) | Nhập kho |
| F330 | Nhập kho + tách tem + lot no | Nhập kho |
| F332 | Tách tem theo mặc định | Nhập kho |
| F430 | Xuất/nhập kho + lịch sử | Xuất kho |
| F610 | Yêu cầu hoàn trả NVL | Hoàn trả |
| F620 | Thực hiện hoàn trả | Hoàn trả |
| F721 | Tồn kho NVL | Tra cứu |
| F740 | Tách tem tùy chọn | Nhập kho |
| F743 | Slitting lot (Hà Nam) | Slitting |
| F744 | Config chiều rộng Slitting | Setup Slitting |

### Sản xuất (B)
| Màn | Chức năng | Thuộc flow |
|-----|-----------|-----------|
| B210 | Line sản xuất | Setup |
| B220 | Công đoạn | Setup |
| B230 | Cấu trúc công đoạn trên line | Setup |
| B240 | Routing | Setup |
| B250 | Thiết bị toàn nhà máy | Setup |
| B260 | Công nhân sản xuất | Setup |
| B270 | Thiết bị sản xuất | Setup |
| B310 | Tạo PO (tháng) | Kế hoạch |
| B450 | Kế hoạch ngày + FixDayPlan | Kế hoạch |
| B453 | In tem inner/outer | Đóng gói |
| B523 | Gộp box, chia box, in tem | Đóng gói |
| B525 | Đóng gói kho TP ⚠️ | Kho TP |
| B528 | Lịch sử gộp thùng ⚠️ | Kho TP |
| B530 | Nhập lỗi từng công đoạn | SX trên line |
| B540 | Nhập thẻ công đoạn (chính) | SX trên line |
| B597 | Kiểm tra thường xuyên (mã TEST) | SX trên line |
| B598 | Báo phế NVL | SX trên line |
| B682 | Báo cáo lỗi tổng | Báo cáo |
| B718 | NG cơ khí | Báo cáo |
| B726 | NG + holding | Báo cáo |
| B781 | Sản lượng + đơn giá | Báo cáo |
| B782 | Lỗi chi tiết/công đoạn | Báo cáo |
| B789 | Lịch sử công đoạn module | Kho TP |
| B791 | Phế module | Báo cáo |
| B802 | NG điện cực | Báo cáo |
| B934 | Import data máy phân cấp | Data |
| B935 | Lịch sử import | Data |

### QC (C)
| Màn | Chức năng | Nhóm |
|-----|-----------|------|
| C111 | Hằng số thống kê | Setup |
| C112 | Tiêu chuẩn AQL | Setup |
| C113 | Kiểm tra mẫu cơ bản | Setup |
| C121 | Nhóm + hạng mục KT (IQC/OQC) | Setup |
| C122 | Hạng mục KT theo NVL | Setup IQC |
| C131 | Nhóm lỗi | Setup |
| C132 | Chi tiết lỗi → B530, B540 | Setup |
| C141 | Hạng mục KT chung PQC | Setup PQC |
| C143 | Hạng mục KT riêng/model (TEST/QUALITY) | Setup PQC |
| C151 | Hạng mục KT riêng/SP OQC | Setup OQC |
| C220 | Kiểm tra NVL đầu vào | IQC |
| C243 | Check Slitting lot | QC Slitting |
| C321 | Phế công đoạn trên cell line | PQC |
| C385 | Báo cáo bất thường (→ email) | QC |
| C390 | Xem báo cáo bất thường | QC |
| C430 | Lịch sử KT PQC | PQC |
| C443 | Kiểm tra PQC (mã QUALITY) | PQC |
| C460 | KT quy trình điện cực ⚠️ | PQC |
| C510 | Quản lý lot KT SP | OQC |
| C512 | Tạo lot KT (cần barcode SX) | OQC |
| C521 | KT công đoạn phát sinh | PQC |
| C530 | KT OQC từng mẫu | OQC |
| C540 | Lịch sử OQC | OQC |
| C541 | Lịch sử ESR | OQC |
| C546 | KT ESR (xuất kho) | OQC |
| C561 | Hạng mục KT Bending/Cutting | Setup B/C |
| C562 | Tạo lot KT B/C | B/C QC |
| C563 | KT B/C từng mẫu | B/C QC |
| C564 | Lịch sử KT B/C | B/C QC |
| C726 | Báo phế điện cực ⚠️ | PQC |

### Thành phẩm (FG/HN)
| Màn | Chức năng |
|-----|-----------|
| FG00 | Tồn kho TP Bắc Giang |
| FG01 | Tồn kho TP Bắc Ninh |
| FG02 | Tồn kho tổng hợp BN + BG |
| HN00 | Tồn kho TP Hà Nam |

### Quản lý (Z)
| Màn | Chức năng |
|-----|-----------|
| Z220 | Phân quyền nhóm |
| Z330 | Quản lý menu |
| Z410 | Quản lý user |

---

## ⚠️ MÀN HÌNH CHƯA CÓ TÀI LIỆU CHI TIẾT

| Màn | Chức năng | Gợi ý tìm |
|-----|-----------|-----------|
| C460 | KT quy trình điện cực | Hỏi PQC team |
| C726 | Báo phế điện cực | Hỏi PQC team |
| B525 | Đóng gói kho TP | Hỏi Kho TP |
| B528 | Lịch sử gộp thùng | Hỏi Kho TP |
| F610/F620 | Hoàn trả NVL | Hỏi Kho NVL |
| F332/F740 | Tách tem (khác F330) | Hỏi Kho NVL |

---

## 🔑 LƯU Ý QUAN TRỌNG NHẤT

1. **Đặc tính 10** (F330) - Không có = NVL vào kho holding, không xuất SX được
2. **FixDayPlan** (B450) - Chưa ấn = SX không tạo lot được
3. **BOM Version = 99** (B310) - Bắt buộc khi tạo PO
4. **In tem 1 lần** (B523) - In lần 2 phải liên hệ EA
5. **Mã TEST vs QUALITY** (C143) - TEST → B597 (SX), QUALITY → C443 (QC)
6. **Barcode từ SX** - OQC (C512) và Bending/Cutting (C562) cần barcode mới tạo lot
7. **C530 chậm** - Nhiều truy vấn, thao tác từ từ
8. **A230, A310** - Đã chuyển sang Groupware, không config trên MES nữa

---

## 📁 DANH SÁCH FILE TÀI LIỆU

| File | Nội dung |
|------|----------|
| `01_tong_quan_MES.md` | Tổng quan hệ thống, phân loại màn hình |
| `02_huong_dan_san_xuat.md` | Flow SX: B310→B450→B540→B598 |
| `03_huong_dan_kho_NVL.md` | Flow Kho: F130→F312→F330→F430→F721 |
| `04_huong_dan_QC.md` | QC tổng quan: IQC/OQC/PQC setup + flow |
| `05_B523_dong_goi.md` | B523 đóng gói: in tem, chia box |
| `06_QC_chi_tiet_OQC_BendingCutting.md` | OQC + Bending/Cutting chi tiết |
| `07_slitting_va_import_data.md` | Slitting (F743/F744) + Import (B934/B935) |
| `08_A418_B453_dong_goi_in_tem.md` | Config đóng gói (A418) + In tem (B453) |
| **`09_FLOW_END_TO_END.md`** | **File này - Tổng hợp toàn bộ** |
