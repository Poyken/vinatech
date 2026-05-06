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

```sql
-- Template INSERT giá theo từng Route cho 1 model
INSERT INTO STB_VVT_StagePrices (
    model, RouteV22, PriceV22, RouteV23, PriceV23,
    RouteV24, PriceV24, RouteV25, PriceV25, RouteV26, PriceV26,
    RouteV27, PriceV27, RouteV28, PriceV28, CreateDate
)
VALUES (
    'ECVT27-399',
    'V-22', 0.0657356, 'V-23', 0.0718827,
    'V-24', 0.0897135, 'V-25', 0.0945566,
    'V-26', 0.0945566, 'V-27', 0.1100989,
    'V-28', 0.1183676,
    GETDATE()
);
```

---

### 3.2 Add giá Module lên màn B789 & B791

**Vị trí xử lý:** Function `fn_VVT_StagePricesMODULE`

```sql
-- Ví dụ thêm giá MODULE
select 'EDVTMD-214', '0.254127629071929', '0.257442076659429', '0.258507610420299'
union all
-- ... thêm các dòng tiếp theo
```

---

### 3.3 Xóa / Sửa số lượng Packing ở màn B789

```sql
-- 1. Tìm record sai số lượng
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = '[Điền LotNo]'

-- 2. Sửa số lượng
UPDATE STB_SavePackingTime_VVT
SET PackQty = [Số lượng mới]
WHERE LotNo = '[LotNo]' AND id = '[ID]'

-- 3. Xóa nếu cần
DELETE FROM STB_SavePackingTime_VVT
WHERE LotNo = '[LotNo]' AND id = '[ID]'
```

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
