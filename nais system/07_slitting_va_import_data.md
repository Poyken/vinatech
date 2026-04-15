# NAIS MES - Slitting (F743/F744) + Import Data (B934/B935)

> Nguồn: "F743 & F744 Document" + "Hướng dẫn nhập dữ liệu máy phân cấp bigsize"

---

## Phần A: Slitting - Cắt Foil (Hà Nam)

### Flow Slitting

```
F744 (Config chiều rộng Slitting)
  ↓
F743 (Thực hiện Slitting - cắt foil)
  ↓ Chốt Slitting
C243 (QC check slitting lot)
  ↓ QC check xong
F743 (Hiển thị trạng thái, thời gian, người check)
  ↓
F430 (Chuyển foil đã cắt về kho NVL)
  ↓
F721 (Xem tồn kho)
```

### F744 - Thiết lập chiều rộng Slitting

**Mục đích:** Config chiều rộng foil cho từng mã NVL trước khi cắt.

| Thao tác | Cách làm |
|----------|----------|
| **Thêm** | (+) → Chọn Mã nguyên liệu → Nhập Width → Save |
| **Sửa** | Chọn dòng → Click trường cần sửa → Save |
| **Xóa** | Chọn dòng → (-) → Yes → Save |

### F743 - Slitting LOT Material

**Mục đích:** Thực hiện cắt foil và quản lý lot foil đã cắt.

**Quy trình:**
1. Chọn **Mã nguyên liệu** → Tìm kiếm
2. **Bảng trái**: Thông tin foil ban đầu
3. **Bảng phải**: Thông tin foil đã cắt
4. Thêm foil đã cắt: (+) → Chọn Mã NL (từ F744) → Nhập **Length Slitting** → Save
5. **Chốt Slitting** → Lot chuyển sang **C243** để QC check
6. **In tem**: Tick lot → "Phát hành tem" → Chọn máy in

### C243 - QC Check Slitting Lot

- Lot từ F743 chuyển đến → QC check → Save
- Sau check → F743 hiển thị: trạng thái, thời gian, người check

### Chuyển về kho NVL (sau QC check)

1. Vào **F430** → "Nguyên liệu đầu ra"
2. Điền thông tin (LotID lấy từ F743) → Tìm kiếm → Hoàn thành
3. ⚠️ Lot chưa check hoặc không tồn tại → **báo lỗi**
4. Xem tồn kho tại **F721**

---

## Phần B: Import Data Máy Phân Cấp Bigsize

### Flow Import

```
File CSV (từ máy phân cấp)
  ↓ Đổi sang .xlsx
B934 (Import data lên MES)
  ↓
B935 (Xem lịch sử import)
```

### Bước 1: Chuyển CSV → XLSX
- MES **không support file CSV** → phải Save As .xlsx

### B934 - Import Data

1. Nhập **LotNo** + **FileName** (tên tùy ý, dễ tìm) → Tìm kiếm
2. Ấn **Import data**
3. Import Wizard:
   - Source Type: **Excel**
   - Source Excel: chọn file .xlsx
   - Chọn file + sheet → OK
4. **Map trường dữ liệu**: Bấm cột trái → chọn cột phải tương ứng
   - ⚠️ **Không chọn LotNo, FileName**
   - Từ CH trở xuống đã sắp xếp thứ tự → chọn lần lượt
5. Next → OK → **Save**

### B935 - Xem lịch sử import
- Tìm kiếm theo **LotNo**, **FileName**, hoặc **ngày import**

---
*Cập nhật: 2026-03-07 | Phần 7/N*
