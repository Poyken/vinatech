# KB_09 — In Tem Label (Các loại tem đặc biệt & Lỗi in tem)

> **Màn hình liên quan:** B450, B756, B757, B758, B767, B790, A460, F330, Z530
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Phân loại tem trong hệ thống

| Loại tem | Màn hình | SP | Ghi chú |
|----------|----------|----|---------|
| **AssembleLabel** (Tem Sản Xuất) | B450, B540 | Gọi qua A460 | Tem chính cho Cell/Module sau khi tạo Lot |
| **PartLabel** (Tem Vật Tư Kho) | F330 | Gọi qua A460 | Tem dán trên NVL nhập kho |
| **자재라벨** (Tem kho Hà Nam) | F721 | `STB_ModelLabelInfo` | Đặc biệt cho Hà Nam (chị Hoàng Xuân) |
| **Phoenix Contact** | B790 | `usp_Vietnam_PhoenixContactLabelPrint_get` | Tem 5x8cm, Datecode YYMMDD |
| **PAC Inner/Outer** | B754, B755, B756 | — | SN riêng biệt cho Inner và Outer |
| **Digi-Key** | B757, B758 | — | Nhãn SP + Nhãn Logistic |

---

## 2. Tìm mẫu tem đang dùng cho 1 Barcode/LotNo

```sql
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

## 3. Lỗi in tem sai mẫu (VD: tem in 5H1 nhưng hệ thống là 6D1)

**Nguyên nhân:** `STB_MaterialLotInfo.MaterialCode` khác với `STB_SetInfo.MaterialCode`.

```sql
-- Debug: So sánh MaterialCode giữa 2 bảng
SELECT
    SI.Barcode,
    SI.MaterialCode AS [MaterialCode_SetInfo],
    MLI.MaterialCode AS [MaterialCode_LotInfo],
    CASE WHEN SI.MaterialCode = MLI.MaterialCode THEN 'ĐỒNG NHẤT' ELSE 'KHÁC NHAU ← LỖI' END AS [Trang_Thai]
FROM STB_SetInfo SI
LEFT JOIN STB_MaterialLotInfo MLI ON SI.Barcode = MLI.LotNo OR SI.Barcode = MLI.LotID
WHERE SI.Barcode = 'Mã_Barcode'

-- Fix: Đồng bộ MaterialCode về đúng giá trị
UPDATE STB_MaterialLotInfo
SET MaterialCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = 'Mã_Barcode')
WHERE LotNo = 'Mã_Barcode' OR LotID = 'Mã_Barcode'
```

---

## 4. Lỗi không in được tem vì không có Lot trên hệ thống

**Tình huống:** Hàng đã đóng gói xong nhưng B450 bị lỗi không tạo được Lot.

**Phương án 1 — Cho quyền in tem tạm thời (rủi ro thấp):**
```sql
-- Kiểm tra quyền in tem của user
SELECT UserID, ScreenID, FuncID, Allow
FROM SmartFramework.dbo.STB_UserPermission
WHERE UserID = 'user_cần_in' AND ScreenID IN ('B756', 'B767', 'B790')

-- Thêm quyền tạm thời nếu thiếu (qua Z220 hoặc INSERT trực tiếp)
```

**Phương án 2 — Tạo Lot thủ công (rủi ro cao, cần phê duyệt quản lý):**
👉 **Chi tiết Script Fix:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_06_MASTER_DATA_TOOLS.md)

> ⚠️ Ghi lại tất cả thao tác này để audit sau.

---

## 5. Màn hình thiết kế tem

| Tác vụ | Màn hình |
|--------|---------|
| Chỉnh sửa design mẫu tem (Label Template) | **Z530** (STB_LabelInfo) |
| Cấu hình mapping Model → Mẫu tem | **A460** (STB_ModelLabelInfo) |
| In tem theo nhiều định dạng | **B756**, **B767**, **B790** |

```sql
-- Tìm các SP in tem trong DB SmartFactoryV2
SELECT name FROM sys.procedures
WHERE name LIKE '%Label%Print%' OR name LIKE '%Print%Label%'

-- Tìm Action in tem trên màn hình
SELECT ScreenName, ObjectName, Caption, ObjectType
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE (ObjectName LIKE '%Print%' OR ObjectName LIKE '%Label%')
  AND ObjectType = 'Action'
```

---

## 6. Lỗi in tem B767 (sai format)

```sql
-- Kiểm tra template đang gán cho model (Z530)
SELECT * FROM SmartFramework.dbo.STB_LabelInfo
WHERE FormatName LIKE '%[Tên/Mã Model]%' AND IsApproval = 1
ORDER BY ApplyDate DESC

-- Kiểm tra mapping A460
SELECT * FROM STB_ModelLabelInfo WHERE ModelCode = 'Mã_Model'
```

---

## 7. Setup tem mới cho một mã vật tư

```
□ 1. Z530 — Tạo/chọn mẫu tem (Format Name) trong STB_LabelInfo, set IsApproval = 1
□ 2. A460 — Map Model → FormatName trong STB_ModelLabelInfo
□ 3. F110 — Bật IsLotUse = 1, IsUseBarcode = 1 cho mã NVL
□ 4. Test in thử 1 tem → Xác nhận format đúng
```

```sql
-- SQL thêm mapping A460
INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
VALUES ('MÃ_MODEL', 'AssembleLabel', 'Tên_Format_Trong_Z530', GETDATE(), 'vinaadmin')
```

---

## 8. In Tem Khách Hàng PAC (B754 / B755 / B756)

**B754 — In tem Inner/Outer:**

| Thông tin | INNER | OUTER |
|-----------|-------|-------|
| Custom Part No | ✅ | ✅ |
| INVOICE NO | ✅ | ✅ |
| INVOICE Date | ✅ | ✅ |
| Packet Qty | ✅ | — |
| BoxQTY | — | ✅ |
| Number Of Total | — | ✅ (mặc định=1) |
| IsOuter | ❌ Không tick | ✅ Phải tick |

> ⚠️ Tem Inner và Outer tính Serial Number **riêng biệt**.

**B755:** Lịch sử in tem từ B754.

**B756 — In tem thùng Carton + Cân nặng:**
- In tem thùng carton: Nhập số lượng tem → Tìm kiếm → Ấn **Tem thùng Carton**
- In tem cân nặng: Tick `IsWeightLabel` → Tìm kiếm → Ấn **Tem Cân Nặng** → Chọn số lượng

---

## 9. In Tem Khách Hàng Digi-Key (B757 / B758)

**B757 — In 2 loại tem:**

| Loại tem | Thông tin cần | Nút bấm |
|----------|--------------|---------|
| Nhãn sản phẩm | Bắn mã Lot | IN NHÃN SP |
| Nhãn Logistic | Lot + Số PO + PO Line Number + Pack List Number + Số lượng tem | IN NHÃN LOGISTIC |

**B758 — In tem thùng MIXED LOAD:**
- `Pack List Number`: Số INV
- `Weight`: Cân nặng
- `PackageCount`: Số thùng

---

## 10. Thiết Kế Tem Phoenix Contact (B790)

**Thông số:**
- Kích thước: 80mm x 50mm (8x5 cm)
- Label Type: `Phoenix_Label`
- Format Name: `Phoenix_Contact_V1`
- Datecode: `@DateCode` (Định dạng YYMMDD) — lấy từ `STB_SetInfo.InputJobDate`
- Số thứ tự tem: `@CurrentIndex / @TotalQty`
- Mã vạch: chứa `PackingID`

**Mã hệ thống hỗ trợ:** `ECVT30-197` (Active), `ECVT30-098` (Old). Số lượng: 120 pcs/thùng.

```sql
-- Test SP
EXEC [dbo].[usp_Vietnam_PhoenixContactLabelPrint_get]
     @pPackingID = 'MÃ_PACKING_THỰC_TẾ',
     @pNumberLabel = 2
-- Kỳ vọng: Trả ra 2 dòng, cột DateCode có định dạng YYMMDD

-- Logic lấy Datecode từ InputJobDate
SELECT
    SI.Barcode,
    SI.InputJobDate,
    CONVERT(VARCHAR(6), SI.InputJobDate, 12) AS [DateCode_YYMMDD]
FROM STB_SetInfo SI
WHERE SI.Barcode = 'Mã_Barcode'
```

---

## 11. B934 / B935 — Import Data ESR

**Chức năng:** Import dữ liệu ESR (Equivalent Series Resistance) từ file Excel vào hệ thống.

**B934 — Import ESR:**
- Upload file Excel chứa dữ liệu ESR
- Mapping cột: Barcode, ESR Value, Test Date
- Validate dữ liệu trước khi import

**B935 — Xem lịch sử Import:**
- Hiển thị các lần import ESR
- Cho phép xóa/sửa dữ liệu đã import

```sql
-- Kiểm tra dữ liệu ESR đã import
SELECT * FROM STB_ESRData
WHERE Barcode = 'Mã_Barcode'
ORDER BY CreateDateTime DESC

-- Xóa dữ liệu ESR nếu import sai
DELETE FROM STB_ESRData
WHERE Barcode = 'Mã_Barcode' AND CreateDateTime = 'Thời_Gian_Import'
```

*Cập nhật: 2026-05-22*
