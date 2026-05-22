# KB_08 — Kho Thành Phẩm (HN) & Xuất Kho

> **Màn hình liên quan:** HN551, HN544, HN866, FG00, B523
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🔴 Lỗi Hàng xuất ở HN551 nhưng tồn kho HN866 vẫn còn

**Triệu chứng:** Đã quét mã Packing xuất kho ở HN551 thành công, nhưng vào HN866 vẫn thấy hàng còn tồn.

**Tư duy trace:** Hệ thống MES hoạt động theo nguyên tắc **"Màn hình A làm - Màn hình B hưởng"**:
- **HN551 (Xuất):** Ghi vào "Sổ xuất kho" (`STB_VN_FINISHGOODS_HN_Export`) và đánh dấu "đã đi" vào "Sổ tồn kho".
- **HN866 (Tồn):** Chỉ đơn giản mở "Sổ tồn kho" ra xem — cái nào chưa đánh dấu "đã đi" (`QtyOutput = 0`) thì hiện lên.

**→ Nguyên nhân thường gặp:** HN551 đã ghi "Sổ xuất" nhưng **quên đánh dấu** vào "Sổ tồn kho."

---

**Script trace tổng hợp (thay PackingID ở dòng đầu):**
```sql
DECLARE @PackingID NVARCHAR(50) = 'PKHN023117' -- THAY MÃ CẦN TRACE

-- BƯỚC 1: Kiểm tra trạng thái xuất kho
-- StatusExport = 1 → Đã xuất về chứng từ
SELECT CodeExport, PackingID, LotNo, Qty, StatusExport, CreateDateTime
FROM STB_VN_FINISHGOODS_HN_Export
WHERE PackingID = @PackingID

-- BƯỚC 2: Kiểm tra tồn kho thực tế
-- QtyOutput = 0 nhưng BƯỚC 1 có data → LỖI LOGIC TRỪ KHO
SELECT PackingID, Quantity, QtyOutput
FROM FinishGoodMESInstock_HN
WHERE PackingID = @PackingID

-- BƯỚC 3: Kiểm tra Packing là "Tem To" hay "Tem Nhỏ"
-- Tem To (Pallet/Gộp) = có trong STB_PackingOutPutFinishGoods_HN
-- Tem Nhỏ (Box đơn) = không có trong bảng đó
SELECT PackingID FROM STB_PackingOutPutFinishGoods_HN
WHERE PackingOutPutFinishGoodsID = @PackingID
-- Có kết quả → Tem To → xuất 1 mã này sẽ tự động xuất các box con bên trong
```

**Fix (nếu QtyOutput sai):**
```sql
-- SP xuất kho xử lý cả Tem To và Tem Nhỏ
-- Xem logic: SELECT OBJECT_DEFINITION(OBJECT_ID('ExportWarehouseFinshGoodInventory_uid'))

-- Fix thủ công nếu SP bị lỗi giữa chừng
-- ⚠️ Xác minh DB (2026-05-17): Bảng KHÔNG có cột StatusInstock -- chỉ có QtyOutput
UPDATE FinishGoodMESInstock_HN
SET QtyOutput = Quantity  -- Quantity là cột tổng số lượng thực tế
WHERE PackingID = @PackingID

UPDATE STB_VN_FINISHGOODS_HN_Export
SET StatusExport = 1
WHERE PackingID = @PackingID
```

> **SP xuất kho:** `ExportWarehouseFinshGoodInventory_uid`

---

## 2. 🔴 Lỗi Lot bị đổi MaterialCode sau khi sản xuất (5H1 → 6D1)

**Triệu chứng:** Hàng đang nhập liệu với Making = 5H1 nhưng sau đó trên hệ thống bị chuyển sang 6D1.

**Các Packing liên quan: pkpt2000146, pkpt2000147, pkpt2000145**

**Script trace:**
```sql
-- Bước 1: Kiểm tra MaterialCode hiện tại của các Lot
SELECT SI.Barcode, SI.MaterialCode, SI.InputLineCode, SI.CreateDateTime
FROM STB_SetInfo SI
WHERE SI.Barcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')

-- Bước 2: Kiểm tra lịch sử thay đổi MaterialCode
SELECT * FROM STB_LotChangeMaterialHistory
WHERE NewBarcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')
OR OldBarcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')
ORDER BY CreateDateTime DESC

-- Bước 3: Kiểm tra ai đã thay đổi và khi nào
SELECT * FROM STB_MaterialLotInfo
WHERE LotNo IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')
```

**Fix (nếu bị đổi sai):**
```sql
-- Đổi lại MaterialCode đúng (lấy giá trị cũ từ LotChangeMaterialHistory)
UPDATE STB_SetInfo SET MaterialCode = '5H1_MATERIAL_CODE_ĐÚNG'
WHERE Barcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')

UPDATE STB_MaterialLotInfo SET MaterialCode = '5H1_MATERIAL_CODE_ĐÚNG'
WHERE LotNo IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')
```

---

## 3. 🔴 Lỗi màn HNC321 (Nhập phế — báo lỗi)

**Triệu chứng:** Nhập phế liệu ở HNC321 báo lỗi, không lưu được.

**Debug:**
```sql
-- Kiểm tra SP xử lý nhập phế
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_ScrapInput_HN'))
-- hoặc tìm Action theo tên màn hình
SELECT ObjectName, Caption, ObjectType FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName LIKE '%HNC321%' AND ObjectType = 'Action'
```

---

## 4. 🔴 Xóa nhập sản lượng công đoạn (VD: VE260509-004)

**Triệu chứng:** Cần hủy/xóa dữ liệu nhập sản lượng ở 1 công đoạn cụ thể của 1 Barcode.

```sql
-- Bước 1: Xem lịch sử routing của Barcode
SELECT * FROM STB_ProdRouteHist
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260509-004')
ORDER BY ProdDateTime DESC

-- Bước 2: Ghi nhớ RouteCode cần xóa (VD: VE08)
-- Bước 3: Xóa dòng lịch sử routing đó
DELETE FROM STB_ProdRouteHist
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260509-004')
AND RouteCode = 'VE08'

-- Bước 4: Nếu có nhập NG/DefectQty ở công đoạn đó, reset lại
UPDATE STB_SetInfo
SET DefectQty = 0, IsDefect = 0
WHERE Barcode = 'VE260509-004'
-- Chỉ làm nếu DefectQty thực sự cần reset
```

---

## 5. 🔴 Xóa dữ liệu bị đánh dấu ở màn F330 (Hủy nhập kho)

**Triệu chứng:** User muốn xóa phiếu nhập kho đã lỡ nhập ở F330 nhưng phiếu đã bị "đánh dấu" (Confirmed).

```sql
-- Bước 1: Tìm phiếu cần hủy
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = 'Số_Tài_Liệu'

-- Bước 2: Kiểm tra xem đã có IQC chưa
SELECT * FROM STB_MaterialQcInfo
WHERE MaterialDocNo = 'Số_Tài_Liệu'
-- Nếu đã có IQC PASS → Không thể xóa đơn giản, cần xóa cả IQC records

-- Bước 3: Lấy danh sách LotID trong phiếu
SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'Số_Tài_Liệu'

-- Bước 4: Xóa theo thứ tự ngược lại (tránh lỗi FK)
DELETE FROM STB_MaterialLotInfo WHERE LotID IN (
    SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'Số_Tài_Liệu'
)
DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'Số_Tài_Liệu'
DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = 'Số_Tài_Liệu'
DELETE FROM STB_MaterialDocInfo WHERE MaterialDocNo = 'Số_Tài_Liệu'
```

> ⚠️ **Chỉ làm khi hàng chưa được xuất kho hoặc dùng sản xuất.** Nếu đã dùng → báo với QC xử lý.

---

## 6. 📖 Phân biệt Tem To và Tem Nhỏ (Hà Nam)

| Loại tem | Định nghĩa | Bảng DB | Khi xuất |
|----------|-----------|---------|---------|
| **Tem To** (Pallet/Gộp) | Đại diện cho nhiều thùng gộp lại | `STB_PackingOutPutFinishGoods_HN` | Tự động xuất tất cả box con bên trong |
| **Tem Nhỏ** (Box đơn) | Dán trên từng thùng riêng lẻ | Không có trong bảng trên | Xuất từng box riêng |

```sql
-- Kiểm tra PackingID là Tem To hay Tem Nhỏ
SELECT COUNT(*) AS [SoKetQua]
FROM STB_PackingOutPutFinishGoods_HN
WHERE PackingOutPutFinishGoodsID = 'PKHN023117'
-- Có kết quả → Tem To | Không có → Tem Nhỏ
```

*Cập nhật: 2026-05-17*

---

## 7. 🔄 Hướng dẫn thu hồi Lot từ F430 về kho ROH_HN_WH

**Tình huống:** Cần thu hồi (revert) hàng đã xuất ở F430 về lại kho Hà Nam.

**1. Cách kiểm tra tình trạng hiện tại (Script Kiểm tra)**
```sql
-- 1. Xem trạng thái tồn kho hiện tại (Đang ở kho nào?)
SELECT LotID, MaterialWarehouseCode, MaterialLocationCode, CurrentQty, CreateDateTime, ChangeDateTime
FROM STB_MaterialLotInfo 
WHERE LotID = 'ML20260407000696';

-- 2. Xem lịch sử xuất nhập (Tìm ID để xóa)
-- Tìm dòng có WarehouseInOutCode = 'O' (Output) và Target = 'ROUTE_HN_WH'
SELECT MaterialWarehouseInOutHistNo, SourceMaterialWarehouseCode, TargetMaterialWarehouseCode, CreateDateTime, CreateUserID
FROM STB_MaterialWarehouseInOutHist 
WHERE LotID = 'ML20260407000696' 
ORDER BY CreateDateTime DESC;

-- 3. Xem vị trí gốc lúc mới nhập kho (Để biết cần trả về đâu)
SELECT LotID, MaterialLocationCode 
FROM STB_MaterialDocLotInfo 
WHERE LotID = 'ML20260407000696';
```

**2. Các bước xử lý (SQL Script Revert)**
```sql
BEGIN TRAN;

-- 1. Xóa lịch sử xuất kho tại F430 (Mã giao dịch lấy từ bước trên)
DELETE FROM STB_MaterialWarehouseInOutHist 
WHERE MaterialWarehouseInOutHistNo = 'MÃ_GIAO_DỊCH_CẦN_XÓA';

-- 2. Cập nhật lại trạng thái tồn kho cho Lot (Về ROH_HN_WH_01)
UPDATE STB_MaterialLotInfo
SET 
    MaterialWarehouseCode = 'ROH_HN_WH',
    MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID = 'ML20260407000696';

-- KIỂM TRA TRƯỚC KHI CHỐT:
-- SELECT * FROM STB_MaterialLotInfo WHERE LotID = 'ML20260407000696';
-- COMMIT; Hoặc ROLLBACK;
```

**Tại sao phải xóa ở `STB_MaterialWarehouseInOutHist`?**
Vì màn hình **F430** ghi nhận mọi lượt xuất/nhập vào bảng này. Nếu chỉ sửa kho ở bảng tồn kho mà không xóa lịch sử, báo cáo xuất nhập tồn cuối tháng sẽ bị lệch.
```
