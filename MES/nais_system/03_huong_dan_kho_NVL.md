# NAIS MES - Hướng Dẫn Kho Nguyên Vật Liệu (F screens)

> Nguồn: "HuongDanHehongKho" + "F130 & F140 Document"

## Flow tổng quan Kho NVL

```
F130/F140 (Config: Chỉ định NCC ↔ NVL) ← Thiết lập 1 lần
  │
  ▼
F312 (Ghi chú NVL đầu vào - số invoice)
  │
  ▼
F330 (Nhập kho + Tạo tem + In tem)
  │  ├── Xử lý hàng nhập về (Create → ARRIVAL)
  │  ├── Tách tem theo PackingQty
  │  └── Điền "Số lot no" → ra "Đặc tính 10"
  │
  ▼
F430 (Xuất kho ra line / Nhập kho lại)
  │  ├── "Nguyên liệu đầu ra" → xuất cho SX
  │  └── "Nguyên liệu đầu vào" → nhập lại khi xuất nhầm
  │
  ▼
F721 (Xem tồn kho NVL)
```

---

## F130 - Chỉ định vật liệu theo từng nhà cung cấp

### Mục đích
Từ **1 nhà cung cấp** → chọn những NVL nào họ cung cấp.

### Quy trình
1. Vào F130 → Ấn **tìm kiếm** (biểu tượng tick xanh)
2. **Bước 1**: Chọn nhà cung cấp
   - Tìm ở bảng bên trái, hoặc nhập **Mã NCC** ở ô tìm kiếm
   - Click vào dòng NCC cần chọn
3. **Bước 2**: Chọn vật liệu
   - Bảng bên phải hiển thị danh sách NVL
   - Tick **"Sử dụng"** cho từng NVL mà NCC này cung cấp
   - Ấn **Save**

---

## F140 - Chỉ định nhà cung cấp theo từng vật liệu

### Mục đích
Từ **1 loại NVL** → chọn những NCC nào cung cấp được.

### Quy trình
1. Vào F140 → Ấn **tìm kiếm**
2. **Bước 1**: Chọn nguyên liệu
   - Tìm ở bảng bên trái, hoặc nhập **Mã nguyên liệu** ở ô tìm kiếm
   - Click vào dòng NVL cần chọn
3. **Bước 2**: Chọn nhà cung cấp
   - Bảng bên phải hiển thị danh sách NCC
   - Tick **"Sử dụng"** cho từng NCC cung cấp NVL này
   - Ấn **Save**

### 💡 So sánh F130 vs F140

| | F130 | F140 |
|---|---|---|
| **Góc nhìn** | NCC → NVL | NVL → NCC |
| **Dùng khi** | Thêm NCC mới, gán nhiều NVL | Thêm NVL mới, gán nhiều NCC |
| **Bản chất** | Cùng 1 mối quan hệ, 2 chiều |  |

---

## F312 - Viết ghi chú nguyên vật liệu

### Mục đích
Ghi nhận thông tin NVL đầu vào (số invoice xuất nhập khẩu, thông tin lô hàng).

### Quy trình
1. Vào F312 → Ấn **"Tìm kiếm"**
2. Ấn dấu **(+)** để thêm dữ liệu
3. Dòng mới hiển thị (bôi đỏ) → điền đầy đủ các cột có **tiêu đề màu đậm** (bắt buộc)
4. Sau khi điền xong phần trên → ấn **(+)** ở ô bên dưới để thêm chi tiết NVL
   - Cột **"Mã nguyên liệu"** tự hiển thị theo Code giao dịch bên trên
   - Các ô **màu xanh đậm** đều bắt buộc nhập
5. Nhập **RequestQty** = số lượng NVL yêu cầu / số lượng thực tế được giao
6. Ấn **Save** để lưu

---

## F330 - Nhập kho và in tem

### Mục đích
Xử lý NVL nhập kho, tách tem theo số lượng, tạo lot có thể xuất cho sản xuất.

### Bước 1: Xử lý hàng nhập về
1. Vào F330 → tìm tài liệu đã tạo ở F312
2. Cột **DocStatusName** ban đầu = **"Create"**
3. Chọn bản ghi → ấn **"Xử lý hàng nhập về"**
4. Cột chuyển thành **"ARRIVAL"** → lúc này mới tạo được lot

### Bước 2: Tách tem (Tạo tem NVL)
| Trường | Ý nghĩa |
|--------|---------|
| **PackingQty** | Số lượng NVL trên **1 tem** |
| **Số tem** | Số lượng tem muốn tách = ReceiveQty ÷ PackingQty |
| **ScanQty** | Số lượng NVL đã tạo tem (nếu < tổng → tạo thêm được; nếu = tổng → hết) |

1. Điền PackingQty → Ấn **"Tạo tem"**
2. Tem hiển thị trong danh sách

### Bước 3: Điền Số Lot No
1. Điền **"Số lot no"** cho mỗi tem
2. Hệ thống tự sinh ra **"Đặc tính 10"**
3. Có Đặc tính 10 → mới xuất ra sản xuất được

### ⚠️ Lưu ý cực kỳ quan trọng
- **Không có "Đặc tính 10"** → NVL sẽ vào **kho holding** (không xuất cho SX được)
- Nếu điền "Số lot no" mà **không ra Đặc tính 10** → **báo EA** để xử lý
- Đây là điều kiện tiên quyết trước khi xuất NVL ra line SX

---

## F430 - Lịch sử Xuất/Nhập kho

### Mục đích
Xuất NVL ra cell line cho sản xuất, hoặc nhập lại khi xuất nhầm.

### Xuất kho (Nguyên liệu đầu ra)
1. Vào F430 → ấn **"Nguyên liệu đầu ra"**
2. Popup hiện → chọn NVL cần xuất
3. ⚠️ Lot **không có "Đặc tính 10"** (từ F330) → sẽ vào **kho holding**

### Nhập kho lại (Nguyên liệu đầu vào)
1. Vào F430 → ấn **"Nguyên liệu đầu vào"**
2. Popup hiện → chọn NVL cần nhập lại

### ⚠️ Khi nào dùng nhập kho lại?
- Chỉ khi **xuất nhầm line** → nhập lại
- Hoặc xuất 500 → nhập lại 500 → rồi xuất lại đúng

---

## F721 - Danh mục vật liệu tồn kho

### Mục đích
Xem tổng hợp tồn kho NVL.

### Cách dùng
- Tìm kiếm theo **kho NVL** → hiển thị tất cả lot NVL hiện có
- Có thể tìm theo **mã NVL** cụ thể

---

## Mối liên hệ F screens ↔ B screens (Sản xuất)

```
Kho NVL                              Sản xuất
────────                              ────────
F312 (ghi chú NVL)
  ↓
F330 (nhập kho, tách tem)
  ↓                                      
F430 (xuất NVL ra line) ──────────→ B540 (Kiểm tra thường xuyên - Khung B)
                                     │  Scan mã NVL đã xuất từ kho
                                     │  ⚠️ NVL phải order từ kho trước
                                     ▼
F430 (nhập lại) ←──────────────── B598/F610/F620 (hoàn trả NVL dư)
```

## Câu hỏi còn thiếu

- [ ] F332 vs F740: Tách tem mặc định vs tách tem tùy chọn - khác gì F330?
- [ ] F610/F620: Hoàn trả NVL - flow chi tiết chưa có
- [ ] F110: Thuộc tính quản lý tồn kho (IsUseBarCode, IsLotUse) - cấu hình thế nào?
- [x] ~~F130/F140: Chỉ định NCC + NVL~~ → Đã thêm ở trên

---
*Cập nhật: 2026-03-07 | Phần 3/N - Đã thêm F130/F140*
