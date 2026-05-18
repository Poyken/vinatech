# GW_07 — Kho Thành Phẩm (Finished Good Warehouse)

> **Màn hình MES liên quan:** FG01 (Xuất kho tạm), B750 (In tem pallet), B752 (Kiểm tra chi tiết)
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 📤 Xuất Ra Kho Tạm (FG01)

### Bước 1: Vào menu "Xuất ra kho tạm"

### Bước 2: Scan Packing ID
- Scan **Packing ID** của từng box cần xuất

### Bước 3: Nhập tên khách hàng

### Bước 4: Kiểm tra lại lần cuối → Nhấn **"Lưu dữ liệu"**

---

## 2. 🏷️ In Tem Pallet (B750)

Sau khi xuất ra kho tạm từ FG01:

1. Vào màn hình **B750**
2. In tem pallet
3. Dán tem lên pallet

---

## 3. 🚛 Xuất Lên Xe / Container

- Vào menu **"Xuất lên công te lơ"**
- Scan là xong — Không cần thao tác thêm

---

## 4. 🔍 Kiểm Tra Chi Tiết Pallet (B752)

- Vào màn hình **B752**
- Kiểm tra lại chi tiết từng pallet đã xuất

---

## 5. 📋 Luồng Xuất Kho Thành Phẩm Đầy Đủ

```
[FG01] Xuất ra kho tạm
    ↓ (Scan Packing ID + Nhập khách hàng + Lưu)
[B750] In tem pallet
    ↓ (Dán tem lên pallet)
[Xuất lên xe] Scan container/xe
    ↓
[B752] Kiểm tra chi tiết
```

---

## 6. ❓ Lỗi Thường Gặp

| Tình huống | Nguyên nhân | Xử lý |
|-----------|-------------|-------|
| Không scan được Packing ID | Box chưa đóng gói hoàn chỉnh | Hoàn tất B523 trước |
| Không in được tem pallet | Chưa lưu FG01 thành công | Kiểm tra lại bước "Lưu dữ liệu" FG01 |
| Packing ID không xuất hiện | Box chưa vào kho tạm | Thực hiện FG01 trước |

---

*Cập nhật: 2026-05-18 | Nguồn: Hướng dẫn Finished Good warehouse.pptx*
