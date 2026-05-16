# KB_01 — UI / Đăng nhập / Phân quyền / Stage Prices

> **Màn hình liên quan:** Login, A460, A419, B260, Z410, Z220, Z330, B682, B781, B789, B791
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🖥️ UI & Đăng nhập

### 1.1 Lỗi không đăng nhập được vào MES

**Triệu chứng:** Màn hình login bị lỗi, không vào được hệ thống NAIS.

**Cách xử lý:**
1. **C1:** Chạy file Update và vào lại hệ thống NAIS.
2. **C2:** Nếu update không được → Xóa **tất cả** các thư mục trong `C:\AwooSystem` rồi cài lại:
   - Link cài: `http://mes.hycap.co.kr:9952/`
   - Setting lại **New System**: `Alias: nais`, `Url: http://mes.hycap.co.kr:9952`

---

### 1.2 Lỗi không in được tem ở màn B450

**Cách xử lý:** Vào màn **A460** → Tìm đúng loại tem:
- **In tem cho Sản xuất:** `AssembleLabel` (dòng 2)
- **In tem cho Kho:** `PartLabel`

---

### 1.3 Lỗi popup không hiện trên B270

**Cách xử lý:** Sang màn **B230** để xử lý thay thế.

---

## 2. 👤 Quản lý User & Phân quyền

| Tác vụ | Màn hình |
|--------|----------|
| Thêm danh sách công nhân | **B260** |
| Thêm tài khoản MES cho người mới | **Z410** |
| Phân quyền người dùng | **Z220** |
| Thêm màn hình mới cho người dùng | **Z330** |

---

## 3. 💰 Giá & Module (Stage Prices)

### 3.1 Add giá lên màn B682 & B781
> Xem chi tiết phương pháp và script tại: [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md#3-fix-giá-công-đoạn-stage-prices)

---

### 3.2 Add giá Module lên màn B789 & B791
**Vị trí xử lý:** Function `fn_VVT_StagePricesMODULE` (Xem chi tiết tại [KB_06](KB_06_MASTER_DATA_TOOLS.md))

---

### 3.3 Xóa / Sửa số lượng Packing ở màn B789
> Xem chi tiết phương pháp và script tại: [KB_03_SAN_XUAT.md](KB_03_SAN_XUAT.md#514-sửa-xóa-số-lượng-đóng-gói-packing-qty---màn-b789)

---

### 3.4 Lỗi Stored Procedure - Đổi đầu mã (B789)

- **SP liên quan:** `usp_Vietnam_GetBoxIDForLotNo_VVT`
- **Lỗi lưu nhưng không hiện (Packing Qty âm ở B523):** SP `usp_savePackingLabelQty_VVT`

---

### 3.5 Bỏ in VV thành VJ theo Code NVL

```sql
UPDATE STB_Vietnam_PackingPrinting
SET PrintVJ = 0
WHERE MaterialCode = '[Điền mã NVL]'
```
