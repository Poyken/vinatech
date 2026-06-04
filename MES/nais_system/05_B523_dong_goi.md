# NAIS MES - B523 Đóng Gói, In Tem & Chia Box

> Nguồn: "B523_NewProcess" - Hướng dẫn quy trình mới B523

## Flow B523

```
Gộp box (từ công đoạn SX)
  ↓
Thông tin box to hiển thị ở Bảng 3
  ↓
IN TEM BOX TO (bắt buộc trước)
  ↓
CHIA BOX (nếu cần)
  ↓
IN TEM BOX NHỎ (bắt buộc trước khi chia tiếp)
```

---

## I. In Tem Box To

### Quy trình
1. Tại B523, sau gộp box → thông tin box to ở **Bảng 3**
2. **Chọn dòng** cần in
3. Click **"In tem"**

### ⚠️ Quy tắc quan trọng
- **Chỉ in 1 lần duy nhất** → in lần 2 sẽ báo lỗi
- Muốn in lần 2 → **liên hệ EA team**
- **Phải in tem box to TRƯỚC khi chia box** → không in = không chia được

### Mục đích
Tránh trùng lặp packing khi nhập kho, xuất kho.

---

## II. Chia Box

### Quy trình
1. Chọn dòng **PackingID** cần chia
2. Ấn **"Chia box"**
3. Nhập **số lượng box mới** cần chia
4. Kết quả hiển thị

### ⚠️ Quy tắc quan trọng
- **Chỉ in tem nhỏ 1 lần** → lần 2 báo lỗi → liên hệ EA
- **Phải in tem box nhỏ TRƯỚC khi chia tiếp** → không in = không chia được

---

## Tóm tắt luật B523

| Hành động | Điều kiện | Giới hạn |
|-----------|-----------|----------|
| In tem box to | Phải in trước khi chia box | 1 lần duy nhất |
| Chia box | Phải có tem box to | — |
| In tem box nhỏ | Sau khi chia | 1 lần duy nhất |
| Chia box tiếp | Phải có tem box nhỏ | — |
| In lại (bất kỳ) | Liên hệ EA team | — |

---
*Cập nhật: 2026-03-07 | Phần 5/N*
