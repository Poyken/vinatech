# KB_09 — In Tem Label (Các loại tem đặc biệt & Lỗi in tem)

> **Màn hình liên quan:** B450, B756, B767, B790, A460, F330
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 📋 Phân loại tem trong hệ thống

| Loại tem | Màn hình | SP | Ghi chú |
|----------|----------|----|---------|
| **AssembleLabel** (Tem Sản Xuất) | B450, B540 | Gọi qua A460 | Tem chính cho Cell/Module sau khi tạo Lot |
| **PartLabel** (Tem Vật Tư Kho) | F330 | Gọi qua A460 | Tem dán trên NVL nhập kho |
| **자재라벨** (Tem kho Hà Nam) | F721 | `STB_ModelLabelInfo` | Đặc biệt cho Hà Nam (chị Hoàng Xuân) |
| **Phoenix Contact** | B790 | `usp_Vietnam_PhoenixContactLabelPrint_get` | Tem 5x8cm, Datecode YYMMDD |

---

## 2. 🔍 Tìm mẫu tem đang dùng cho 1 Barcode/LotNo

```sql
-- Tìm tem đang dùng cho LotNo
SELECT 
    SI.Barcode,
    SI.MaterialCode,
    LI.FormatName AS [Ten_Mau_Tem],
    LI.IsApproval,
    LI.ApplyDate
FROM STB_SetInfo SI
JOIN STB_MaterialMaster MM ON SI.MaterialCode = MM.MaterialCode
LEFT JOIN SmartFramework.dbo.STB_LabelInfo LI 
    ON LI.FormatName LIKE '%' + RIGHT(MM.MaterialCode, 5) + '%'
    AND LI.IsApproval = 1
WHERE SI.Barcode = 'VVQL033R07279S'
```

---

## 3. 🔴 Lỗi in tem sai mẫu (VD: tem in 5H1 nhưng hệ thống là 6D1)

**Triệu chứng:** Barcode `16/470` in tem ra label 5H1 nhưng hệ thống ghi 6D1.

**Nguyên nhân:** `STB_MaterialLotInfo.MaterialCode` khác với `STB_SetInfo.MaterialCode`.

**Debug:**
```sql
-- So sánh MaterialCode giữa 2 bảng
SELECT 
    SI.Barcode,
    SI.MaterialCode AS [MaterialCode_SetInfo],
    MLI.MaterialCode AS [MaterialCode_LotInfo],
    CASE WHEN SI.MaterialCode = MLI.MaterialCode THEN 'ĐỒNG NHẤT' ELSE 'KHÁC NHAU ← LỖI' END AS [Trang_Thai]
FROM STB_SetInfo SI
LEFT JOIN STB_MaterialLotInfo MLI ON SI.Barcode = MLI.LotNo OR SI.Barcode = MLI.LotID
WHERE SI.Barcode = 'Mã_Barcode'
```

**Fix:**
```sql
-- Đồng bộ MaterialCode về đúng giá trị
UPDATE STB_MaterialLotInfo
SET MaterialCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = 'Mã_Barcode')
WHERE LotNo = 'Mã_Barcode' OR LotID = 'Mã_Barcode'
```

---

## 4. 🔴 Lỗi không in được tem vì không có Lot trên hệ thống

**Triệu chứng:** User báo "muốn in tem nhưng không có Lot trên hệ thống", cần in tem khẩn.

**Tình huống:** Hàng đã đóng gói xong nhưng B450 bị lỗi không tạo được Lot.

**Đánh giá 2 phương án:**

| Phương án | Rủi ro | Khi nào dùng |
|-----------|--------|-------------|
| **PA1:** Cho quyền in thủ công | Thấp | Chỉ in 1-2 tem khẩn, không cần Lot |
| **PA2:** Tạo Lot thủ công (Manual Bypass) | Cao | Khi cần Lot đầy đủ trong hệ thống |

**PA1 - Cho phép in tem không cần Lot (Tạm thời):**
```sql
-- Kiểm tra quyền in tem của user
SELECT * FROM STB_UserRole WHERE UserID = 'user_cần_in'

-- Nếu user thiếu quyền → Thêm quyền tạm thời vào Z220
-- Không có SP bypass chuẩn → Cần tạo Lot dummy hoặc dùng PA2
```

**PA2 - Tạo Lot thủ công (xem KB_06 Mục 6):**
→ Xem [KB_06 § 6](KB_06_MASTER_DATA_TOOLS.md#6-manual-lot-bypass-in-tem-khẩn-khi-không-có-lot-trên-hệ-thống)

---

## 5. 🔴 Màn hình thiết kế tem là màn nào?

| Tác vụ | Màn hình |
|--------|---------|
| Chỉnh sửa design mẫu tem (Label Template) | **A460** |
| Cấu hình mapping Model → Mẫu tem | **Z530** (STB_ModelLabelInfo) |
| In tem theo nhiều định dạng | **B756**, **B767**, **B790** |

**Tìm màn hình in tem cho 1 LotNo:**
```sql
-- Kiểm tra LotNo đang dùng màn nào để in
SELECT SO.ScreenName, SO.Caption, SO.ProcedureName
FROM SmartFramework.dbo.STB_ScreenObjects SO
WHERE SO.ProcedureName LIKE '%Label%Print%'
AND SO.ObjectType = 'Action'
```

---

## 6. 🔴 Lỗi in tem B767 (sai format)

**Triệu chứng:** Vào B767 in tem nhưng format bị sai hoặc không ra template đúng.

```sql
-- Kiểm tra template đang gán cho model
SELECT * FROM SmartFramework.dbo.STB_LabelInfo
WHERE FormatName LIKE '%[Tên/Mã Model]%'
AND IsApproval = 1
ORDER BY ApplyDate DESC

-- Kiểm tra mapping Z530
SELECT * FROM STB_ModelLabelInfo WHERE ModelCode = 'Mã_Model'
```

---

## 7. ⚙️ Setup tem mới cho một mã vật tư

**Checklist:**
```
□ 1. A460 — Tạo/chọn mẫu tem (Format Name), set IsApproval = 1
□ 2. Z530 — Map Model → FormatName trong STB_ModelLabelInfo
□ 3. F110 — Bật IsLotUse = 1, IsUseBarcode = 1 cho mã NVL
□ 4. Test in thử 1 tem → Xác nhận format đúng
```

**SQL thêm mapping Z530:**
```sql
INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
VALUES ('MÃ_MODEL', 'AssembleLabel', 'Tên_Format_Trong_A460', GETDATE(), 'vinaadmin')
```

*Cập nhật: 2026-05-17*
