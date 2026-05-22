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
-- Kiểm tra quyền in tem của user trên các màn hình in tem (B756, B767, B790)
SELECT UserID, ScreenID, FuncID, Allow 
FROM SmartFramework.dbo.STB_UserPermission 
WHERE UserID = 'user_cần_in' AND ScreenID IN ('B756', 'B767', 'B790')

-- Nếu user thiếu quyền → Thêm quyền tạm thời vào màn hình tương ứng
-- Không có SP bypass chuẩn → Cần tạo Lot dummy hoặc dùng PA2
```

**PA2 - Tạo Lot thủ công (xem KB_06 Mục 6):**
→ Xem [KB_06 § 6](KB_06_MASTER_DATA_TOOLS.md#6-manual-lot-bypass-in-tem-khẩn-khi-không-có-lot-trên-hệ-thống)

---

## 5. 🔴 Màn hình thiết kế tem là màn nào?

| Tác vụ | Màn hình |
|--------|---------|
| Chỉnh sửa design mẫu tem (Label Template) | **Z530** (STB_LabelInfo) |
| Cấu hình mapping Model → Mẫu tem | **A460** (STB_ModelLabelInfo) |
| In tem theo nhiều định dạng | **B756**, **B767**, **B790** |

**Tìm màn hình in tem cho 1 LotNo:**
```sql
-- Tìm các Action liên quan đến In/Tem trong ScreenObjects
SELECT ScreenName, ObjectName, Caption, ObjectType
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE (ObjectName LIKE '%Print%' OR ObjectName LIKE '%Label%')
  AND ObjectType = 'Action'

-- Hoặc tìm các Stored Procedure in tem trong DB SmartFactoryV2
SELECT name FROM sys.procedures 
WHERE name LIKE '%Label%Print%' OR name LIKE '%Print%Label%'
```

---

## 6. 🔴 Lỗi in tem B767 (sai format)

**Triệu chứng:** Vào B767 in tem nhưng format bị sai hoặc không ra template đúng.

```sql
-- Kiểm tra template đang gán cho model (Z530)
SELECT * FROM SmartFramework.dbo.STB_LabelInfo
WHERE FormatName LIKE '%[Tên/Mã Model]%'
AND IsApproval = 1
ORDER BY ApplyDate DESC

-- Kiểm tra mapping A460 (STB_ModelLabelInfo)
SELECT * FROM STB_ModelLabelInfo WHERE ModelCode = 'Mã_Model'
```

---

## 7. ⚙️ Setup tem mới cho một mã vật tư

**Checklist:**
```
□ 1. Z530 — Tạo/chọn mẫu tem (Format Name) trong STB_LabelInfo, set IsApproval = 1
□ 2. A460 — Map Model → FormatName trong STB_ModelLabelInfo
□ 3. F110 — Bật IsLotUse = 1, IsUseBarcode = 1 cho mã NVL
□ 4. Test in thử 1 tem → Xác nhận format đúng
```

**SQL thêm mapping A460:**
```sql
INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
VALUES ('MÃ_MODEL', 'AssembleLabel', 'Tên_Format_Trong_Z530', GETDATE(), 'vinaadmin')
```

*Cập nhật: 2026-05-17*

---

## 8. 🏷️ Hướng Dẫn Thiết Kế & Triển Khai Tem Khách Hàng Phoenix Contact

(Tham khảo thêm từ file hướng dẫn cũ)

**1. Phân tích Luồng Dữ liệu (Data Logic)**
*   **Model:** `VEC3R0367QG` (3562)
    *   **Mã hệ thống hỗ trợ:** `ECVT30-197` (Active) và `ECVT30-098` (Old).
*   **Datecode:** Lấy từ bảng `STB_SetInfo`, cột `InputJobDate` (Đây là ngày ghi nhận tại công đoạn cuốn).
*   **Quy cách in:** In theo lô hàng (`LotNo` hoặc `PackingID`) tại trạm đóng gói.
*   **Số lượng:** 120 pcs/thùng.

**2. Các bước Triển khai Hệ thống**
*   **Bước 1: Thiết kế mẫu tem trong Z530 (Label Design)**
    *   **Label Type:** `Phoenix_Label`
    *   **Format Name:** `Phoenix_Contact_V1`
    *   **Kích thước:** 80mm x 50mm (8x5 cm).
    *   **Nội dung:** Gán biến `@DateCode` để hiển thị định dạng `YYMMDD`.
*   **Bước 2: Viết Stored Procedure lấy dữ liệu in**
    *   Sử dụng SP `usp_Vietnam_PhoenixContactLabelPrint_get` (đã có sẵn).
*   **Bước 3: Cấu hình màn hình in tem mới (B790 - Giao diện kiểu B756)**
    *   **Ô nhập liệu:** `Number Label` (Mặc định = 1).
    *   Hệ thống gọi SP `usp_Vietnam_PhoenixContactLabelPrint_get` kèm theo tham số số lượng.

**3. Cách Design tem trong Z530 (Nâng cao)**
1.  **Datecode:** `@DateCode` (Định dạng YYMMDD).
2.  **Số thứ tự tem:** `@CurrentIndex / @TotalQty` (Ví dụ: 1/3, 2/3).
3.  **Mã vạch:** Chứa thông tin `PackingID` để truy vết thùng hàng.

**4. Hướng dẫn Test & Nghiệm thu**
*   **Test Logic dữ liệu (SQL)**
    ```sql
    EXEC [dbo].[usp_Vietnam_PhoenixContactLabelPrint_get] 
         @pPackingID = 'MÃ_PACKING_THỰC_TẾ', 
         @pNumberLabel = 2
    ```
    *Kỳ vọng:* Trả ra 2 dòng, cột `DateCode` có định dạng `YYMMDD`.
```
