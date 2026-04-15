# NAIS MES - QC Chi Tiết: OQC + Bending/Cutting

> Nguồn: "Quy Trình nhập Liệu OQC_new" + "Quy Trình nhập Liệu Bending Cutting QC"

---

## Phần A: OQC - Kiểm tra thành phẩm xuất xưởng

### Flow OQC

```
C121 (Nhóm + hạng mục chung IQC/OQC)
  ↓
C151 (Hạng mục riêng cho từng sản phẩm)
  ↓  ⚠️ Nếu model không có → config A410 trước
C512 (Tạo lot kiểm tra - cần barcode từ SX)
  ↓
C530 (Kiểm tra từng mẫu - 5 bước)
  ↓
C540 (Lịch sử kiểm tra)
  ↓
C546 (Kiểm tra ESR - khi xuất kho)
  ↓
C541 (Lịch sử ESR)
```

### C151 - Thiết lập hạng mục OQC theo sản phẩm

**Quy trình:**
1. Tìm kiếm Mã nguyên liệu → chọn → "Tìm kiếm"
2. Danh sách hạng mục hiển thị
3. Nếu cần thêm → "Chọn trong Nhóm/Hạng mục kiểm tra"
4. Chọn nhóm → tick hạng mục → OK → Lưu
5. Chỉnh sửa thông số cho đúng (mặc định lấy từ C121)

**⚠️ Nếu model không có trong popup tìm kiếm:**
1. Vào **A410** → nhập Mã Model → Tìm kiếm
2. Thiết lập 2 trường: **"Loại kiểm tra"** + **"Loại OQC"**
3. Ấn Lưu
4. **Tắt C151 → mở lại** → model sẽ xuất hiện

### C512 - Tạo lot kiểm tra OQC

**Quy trình:**
1. Dán **Mã barcode** (từ SX) → "Tìm kiếm"
2. Thông tin Lot hiển thị → Ấn **"Tạo Lot"**

**⚠️ Nếu không có dữ liệu:**

| Trường hợp | Giải pháp |
|------------|-----------|
| Lot đã tạo rồi | Sang **C530** để kiểm tra |
| Chưa config hạng mục ở A410 | Config lại A410 |
| Vẫn không thấy | Liên hệ **EA Team** |

### C530 - Kiểm tra OQC theo từng mẫu

**⚠️ Màn hình chậm** - nhiều câu lệnh truy vấn, thao tác từ từ.

**Quy trình 5 bước (lặp lại cho từng hạng mục):**
1. **Chọn hạng mục** cần kiểm tra
2. **Nhập giá trị đo** ở bảng bên phải
3. **Lưu** bảng bên phải
4. **Chọn kết quả Pass** ở bảng bên trái
5. **Lưu** bảng bên trái

**Khi xong:** Ấn **"Đánh giá OK"** → **Lưu**

**Nếu thêm/sửa hạng mục ở C151:** Ấn **"Tổng hợp các hạng mục kiểm tra sản phẩm"** → cập nhật lại từ đầu

### C540 - Lịch sử OQC
- Nhập Mã barcode + Mã địa điểm → Tìm kiếm
- Xem lại kết quả từ C530

### C546 - Kiểm tra ESR (Xuất kho)
- Tìm kiếm theo ngày hoặc mã barcode
- Tra cứu lot do **C510** tạo ra → kiểm tra ESR
- Điền giá trị đo ESR → Save
- ⚠️ Nếu lot không hiển thị → kiểm tra lại C510

### C541 - Lịch sử kiểm tra ESR
- Xem lại lịch sử kiểm tra từ C546

---

## Phần B: Bending/Cutting QC

### Flow Bending/Cutting

```
C121 (Nhóm + hạng mục chung)
  ↓
C561 (Hạng mục riêng cho từng sản phẩm - Bending/Cutting)
  ↓
C562 (Tạo lot kiểm tra - cần barcode từ SX)
  ↓
C563 (Kiểm tra theo mẫu - giống C530)
  ↓
C564 (Lịch sử kiểm tra)
```

### C561 - Thiết lập hạng mục Bending/Cutting
- Tìm Mã nguyên liệu → chọn → Tìm kiếm
- Thêm: "Chọn trong Nhóm/Hạng mục kiểm tra" → tick → OK → Lưu
- Chỉnh sửa thông số cho đúng (mặc định lấy từ C121)

### C562 - Tạo lot kiểm tra
- Dán Mã barcode (từ SX) → Tìm kiếm → "Tạo Lot"

### C563 - Kiểm tra theo mẫu
- Giống **C530** (cùng 5 bước)
- Xong → "Đánh giá OK" → Lưu
- Nếu sửa C561 → ấn "Tổng hợp các hạng mục kiểm tra sản phẩm"

### C564 - Lịch sử kiểm tra
- Nhập Mã barcode + Mã địa điểm → Tìm kiếm

---

## So sánh 3 dòng QC

| | IQC | OQC | Bending/Cutting | PQC |
|---|---|---|---|---|
| **Setup chung** | C121 | C121 | C121 | C141 |
| **Setup riêng/model** | C122 | C151 | C561 | C143 |
| **Tạo lot** | — | C512 | C562 | — |
| **Kiểm tra** | C220 | C530 | C563 | C443 |
| **Lịch sử** | — | C540 | C564 | C430 |
| **ESR** | — | C546/C541 | — | — |
| **Barcode từ SX** | Không | ✅ Bắt buộc | ✅ Bắt buộc | Không |

---
*Cập nhật: 2026-03-07 | Phần 6/N*
