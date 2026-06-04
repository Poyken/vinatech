# NAIS MES - A418 Đóng Gói Theo Size + B453 In Tem Inner/Outer

> Nguồn: "A418 Document" + "B453 Document"

---

## A418 - Số lượng đóng gói theo size

### Mục đích
Config số lượng sản phẩm trong 1 box tại **B523**, theo từng kích thước (size) sản phẩm.

### Liên kết với A410
- **A410** có trường **MBISizeD** = kích thước sản phẩm
- A410 cũng chứa Chiều dài, Đường kính
- MBISizeD chính là **ProdSize** ở A418

### Quy trình

| Thao tác | Cách làm |
|----------|----------|
| **Thêm** | (+) → Điền ProdSize, PackQty, IsUsed → Save |
| **Sửa** | Click trường cần sửa → Sửa → Save |
| **Xóa** | Chọn dòng → (-) → Yes → Save |

### Các trường

| Trường | Ý nghĩa |
|--------|---------|
| **ProdSize** | Kích cỡ sản phẩm (từ A410 - MBISizeD) |
| **PackQty** | Số lượng đóng gói trong 1 box |
| **IsUsed** | Có sử dụng trong SX hay không |

### Flow liên kết
```
A410 (MBISizeD) → A418 (PackQty theo Size) → B523 (Đóng gói theo config)
```

---

## B453 - In Tem Inner và Outer

### Mục đích
In tem **INNER** (tem trong) và **OUTER** (tem ngoài) cho đóng gói xuất hàng.

### In Tem INNER
1. Điền: **Custom Part No**, **Invoice No**, **Invoice Date**, **Packet Qty**
2. ⚠️ **Không tick IsOuter**
3. Ấn Tìm kiếm → Ấn **"In tem INNER"**

### In Tem OUTER
1. Điền: **Custom Part No**, **Invoice No**, **Invoice Date**, **BoxQTY**, **Number Of Total**
2. ✅ **Tick chọn IsOuter**
3. Ấn Tìm kiếm → Ấn **"In tem OUTER"**

| | INNER | OUTER |
|---|---|---|
| **IsOuter** | ❌ Không tick | ✅ Tick |
| **Trường thêm** | Packet Qty | BoxQTY, Number Of Total |
| **Number Of Total** | — | Mặc định = 1 nếu không điền |

---
*Cập nhật: 2026-03-07 | Phần 8/N*
