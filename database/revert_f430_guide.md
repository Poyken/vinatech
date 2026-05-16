# 🔄 Hướng dẫn thu hồi Lot từ F430 về kho ROH_HN_WH

Dựa trên lịch sử hệ thống, tôi đã tìm thấy cách xử lý yêu cầu này (tương tự như case Lot `ML20260209000136` đã thực hiện vào ngày 11/05). 

Dưới đây là chi tiết tình trạng hiện tại của Lot **ML20260407000696** và các bước để "xóa ở F430" (thu hồi export) để đưa hàng về lại kho Hà Nam.

## 1. Cách kiểm tra tình trạng hiện tại (Script Kiểm tra)

Trước khi sửa, bạn nên chạy script này để biết Lot đang ở đâu và lấy mã giao dịch (History No) cần xóa:

```sql
-- 1. Xem trạng thái tồn kho hiện tại (Đang ở kho nào?)
SELECT LotID, MaterialWarehouseCode, MaterialLocationCode, CurrentQty, CreateDateTime, ChangeDateTime
FROM STB_MaterialLotInfo 
WHERE LotID = 'ML20260407000696';

-- 2. Xem lịch sử xuất nhập (Tìm ID để xóa)
-- Hãy tìm dòng có WarehouseInOutCode = 'O' (Output) và Target = 'ROUTE_HN_WH'
SELECT MaterialWarehouseInOutHistNo, SourceMaterialWarehouseCode, TargetMaterialWarehouseCode, CreateDateTime, CreateUserID
FROM STB_MaterialWarehouseInOutHist 
WHERE LotID = 'ML20260407000696' 
ORDER BY CreateDateTime DESC;

-- 3. Xem vị trí gốc lúc mới nhập kho (Để biết cần trả về đâu)
SELECT LotID, MaterialLocationCode 
FROM STB_MaterialDocLotInfo 
WHERE LotID = 'ML20260407000696';
```

---

## 2. Các bước xử lý (SQL Script Revert)

Để đưa Lot này về lại kho `ROH_HN_WH`, bạn cần thực hiện 2 thao tác: Xóa bản ghi lịch sử xuất và Cập nhật lại vị trí tồn kho hiện tại.

> [!IMPORTANT]
> **Lưu ý an toàn:** Luôn chạy lệnh trong khối `BEGIN TRAN` và `ROLLBACK/COMMIT` để kiểm tra số dòng bị ảnh hưởng trước khi chốt dữ liệu.

```sql
BEGIN TRAN;

-- 1. Xóa lịch sử xuất kho tại F430 (Mã giao dịch: 20260516000635)
-- Thao tác này sẽ làm biến mất bản ghi xuất kho hôm nay của Lot này.
DELETE FROM STB_MaterialWarehouseInOutHist 
WHERE MaterialWarehouseInOutHistNo = '20260516000635';

-- 2. Cập nhật lại trạng thái tồn kho cho Lot
-- Đưa Lot từ ROUTE_HN_WH về lại kho chính ROH_HN_WH (vị trí ROH_HN_WH_01)
UPDATE STB_MaterialLotInfo
SET 
    MaterialWarehouseCode = 'ROH_HN_WH',
    MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID = 'ML20260407000696';

-- KIỂM TRA TRƯỚC KHI CHỐT:
-- SELECT * FROM STB_MaterialLotInfo WHERE LotID = 'ML20260407000696';
-- SELECT * FROM STB_MaterialWarehouseInOutHist WHERE LotID = 'ML20260407000696';

-- Nếu kết quả OK (1 dòng xóa, 1 dòng update) -> Chạy lệnh COMMIT bên dưới:
-- COMMIT;

-- Nếu thấy sai -> Chạy lệnh ROLLBACK:
-- ROLLBACK;
```

---

## 3. Giải thích cơ chế

*   **Tại sao phải xóa ở `STB_MaterialWarehouseInOutHist`?**
    Vì màn hình **F430** ghi nhận mọi lượt xuất/nhập vào bảng này. Nếu chỉ sửa kho ở bảng tồn kho mà không xóa lịch sử, báo cáo xuất nhập tồn cuối tháng sẽ bị lệch.
*   **Tại sao set vị trí là `ROH_HN_WH_01`?**
    Theo dữ liệu gốc từ bảng `STB_MaterialDocLotInfo`, đây là vị trí ban đầu của Lot này khi mới nhập kho Hà Nam.

Bạn có muốn tôi hỗ trợ thực thi trực tiếp script này trên database không, hay bạn sẽ tự chạy qua SQL Management Studio?
