# NAIS SYSTEM - Tổng Quan Hệ Thống MES

> Nguồn: "Hướng dẫn Chung về NAIS SYSTEM" - Created by EA Vietnam

## 1. Thông tin cơ bản

- **Link hệ thống**: http://mes.hycap.co.kr:9952
- **Loại**: Desktop application
- **Nhà máy**: Bắc Ninh, Bắc Giang, Hà Nam

## 2. Phân loại mã màn hình

| Prefix | Nhóm | Mô tả | Quyền |
|--------|-------|--------|-------|
| **A** | Cấu hình chung | Config NVL, BOM, model | Chỉ quản lý |
| **B** | Sản xuất | Kế hoạch, công đoạn, đóng gói, báo cáo | Sản xuất |
| **C** | QC | Kiểm tra chất lượng (IQC, PQC, OQC) | QC |
| **F** | Kho | Kho NVL, nhập xuất, tồn kho | Kho |
| **Z** | Quản lý | User, phân quyền, menu | Admin |
| **HN** | Hà Nam | Màn hình riêng cho nhà máy Hà Nam | — |
| **FG** | Thành phẩm | Tồn kho thành phẩm các nhà máy | Kho TP |

## 3. Phân loại vật liệu (A210)

| Mã | Loại | Tiếng Việt |
|----|------|-----------|
| FERT | Thành phẩm | Finished product |
| HALB | Bán thành phẩm | Semi-finished |
| MDL | Module | Module |
| HAWA | Hàng hóa | Trading goods |
| EROH | Nguyên liệu điện cực | Electrode raw material |
| HIBE | Vật liệu tiêu hao | Consumable |
| ROH | Nguyên liệu thô | Raw material |

## 4. Quy trình sản xuất tổng quan

```
Kho NVL ──→ [QC kiểm tra NVL] ──→ Cell LINE ──→ [QC] ──→ Điện cực ──→ [QC] ──→ Module ──→ [QC] ──→ Thành phẩm ──→ Hàng hóa
```

## 5. Chi tiết các nhóm màn hình

### 5.1 Màn hình Quản lý (Z)

| Màn hình | Chức năng |
|----------|-----------|
| Z410 | Quản lý người dùng (thêm/sửa/xóa, phân quyền user) |
| Z220 | Phân quyền cho nhóm (truy cập màn hình, tính năng) |
| Z330 | Quản lý menu theo nhà cung cấp (đưa từ dev → production) |

### 5.2 Màn hình Cấu hình chung (A)

| Màn hình | Chức năng | Ghi chú |
|----------|-----------|---------|
| A230 | Thông tin các loại NVL | ⚠️ Đã chuyển sang Groupware |
| A210 | Thông tin loại vật liệu (FERT, HALB, MDL...) | |
| A410 | Chi tiết NVL loại TP, BTP, Module (có thông số) | |
| A310 | Thông tin BOM | ⚠️ Đã chuyển sang Groupware |
| A460 | Thông tin tem theo từng model | |

### 5.3 Màn hình QC (C) - Flow PQC

```
C141 (Thiết lập chung PQC) ──→ C143 (Hạng mục kiểm tra riêng/model) ──→ C443 (Kiểm tra công đoạn ngoài line)
 [Thiết lập ban đầu]             [Thiết lập ban đầu]                      [Nhập số liệu]
```

### 5.4 Màn hình QC (C) - Flow OQC

```
C121 (Thiết lập chung IQC+OQC) ──→ C151 (Hạng mục riêng/SP) ──→ C512 (Quản lý Lot) ──→ C530 (Kiểm tra từng mẫu) ──→ C540 (Lịch sử)
 [Thiết lập ban đầu]                [Thiết lập ban đầu]           [Cần barcode từ SX]     [Nhập số liệu]            [Xem lại]
```

### 5.5 Màn hình Sản xuất (B) - Thiết lập

| Màn hình | Chức năng |
|----------|-----------|
| B210 | Thông tin line |
| B220 | Thông tin công đoạn |
| B230 | Cấu trúc công đoạn trong line |
| B240 | Thông tin Route (các công đoạn để SX con hàng) |
| B250 | Thông tin thiết bị (toàn nhà máy) |
| B270 | Thông tin thiết bị sản xuất |
| B260 | Thông tin công nhân SX (nhập liệu + QC) |

### 5.6 Màn hình Sản xuất (B) - Flow sản xuất

```
B310 (Tạo PO)
  │
  ▼
B450 (Tạo Lot theo PO - kế hoạch SX theo ngày)
  │
  ▼
B540 (Nhập thẻ từng công đoạn - theo dõi hàng đang ở công đoạn nào)
  │
  ▼
B597 (Nhập số liệu kiểm tra + NVL đầu vào theo từng công đoạn)
  │
  ▼
B530 (Nhập thực tế SX - số lượng lỗi trên từng công đoạn)
  │
  ▼
B523 (Gộp box, chia box, in tem đóng gói)
  │
  ▼
B781 (Báo cáo sản lượng) + B782 (Số lượng lỗi)
```

### 5.7 Màn hình Thành phẩm

| Màn hình | Chức năng |
|----------|-----------|
| FG00 | Tồn kho thành phẩm Bắc Giang |
| FG01 | Tồn kho thành phẩm Bắc Ninh |
| HN00 | Tồn kho thành phẩm Hà Nam |
| FG02 | Tồn kho tổng hợp Bắc Ninh + Bắc Giang |

---

## 6. Những điểm quan trọng cần lưu ý

1. **A230 và A310** đã đóng chức năng thêm/sửa/xóa trên MES → chuyển sang đăng ký trên **Groupware**
2. **OQC (C512)** cần có mã barcode do **sản xuất cung cấp** mới kiểm tra được
3. **B530** là màn hình nhập số lượng lỗi thực tế (khác với B540 - nhập thẻ công đoạn)
4. 3 nhà máy (Bắc Ninh, Bắc Giang, Hà Nam) dùng chung hệ thống nhưng có màn hình riêng (HN, FG)

---
*Cập nhật: 2026-03-07 | Phần 1/N*
