# ⚡ CHUYÊN ĐỀ 5: KIẾN TRÚC SỰ KIỆN & BẢNG KÊ DML/DDL TRIGGERS

> **Tài liệu tham chiếu chuyên sâu CSDL Vinatech**  
> **Nguồn xác minh:** Truy vấn trực tiếp từ `sys.triggers` và `sys.sql_modules` trên máy chủ `dbserver.hycap.co.kr,5398`  
> **Cập nhật ngày:** 21/09/2026

---

## 1. Tổng Quan Kiến Trúc Trigger Trong Hệ Sinh Thái

Trong cơ sở dữ liệu Vinatech, Trigger đóng vai trò như một **Hệ thần kinh phản xạ thời gian thực (Event-driven Reflex Mechanism)**:
- **MES (`SmartFactoryV2`)**: Duy trì **31 Triggers** tập trung vào việc tự động cập nhật bảng đích kế hoạch (`ESM_DayProdPlanUpdateTarget`), ghi lịch sử xóa Lot (`STB_SetInfoRemoveHist`), đồng bộ sửa chữa phế phẩm (`STB_DefectRepairInfo`), và kiểm soát thay đổi thủ tục (`utr_ProcedureChangesLog`).
- **ERP (`NEOE`)**: Duy trì **hơn 900 Triggers** phục vụ việc tự động nhân bản lịch sử biến động (`_HST`), đồng bộ ngân sách và luồng phê duyệt chứng từ.
- **Groupware (`VINATECH_GROUP`)**: Duy trì **0 Triggers**, toàn bộ luồng phê duyệt và ghi nhận dữ liệu được điều phối qua Stored Procedures và tầng dịch vụ Backend API.

---

## 2. Bảng Kê Chi Tiết 12 Triggers Trọng Yếu Tại `SmartFactoryV2`

| Tên Trigger | Bảng Tác Động | Loại Sự Kiện | Bản Chất Nghiệp Vụ & Tác Động Nền |
| :--- | :--- | :--- | :--- |
| **`utr_STB_SetInfo_DayPlanNo_iu`** | `STB_SetInfo` | AFTER INSERT, UPDATE, DELETE | **Cực kỳ quan trọng:** Khi một mã Barcode được cấp phát hoặc thay đổi trong `STB_SetInfo`, trigger tự động chèn `(DayPlanNo, Barcode, CreateDateTime)` vào bảng `ESM_DayProdPlanUpdateTarget` để cỗ máy tính toán kế hoạch thực tế cập nhật ngay lập tức. |
| **`utr_SetInfoRemoveHist`** | `STB_SetInfo` | AFTER DELETE | Khi một bản ghi Lot/Barcode bị xóa khỏi xưởng, trigger tự động ghi lại toàn bộ thuộc tính cũ sang bảng lịch sử hủy `STB_SetInfoRemoveHist` để phục vụ thanh tra chất lượng. |
| **`utr_ProdRouteHist_DayPlanNo_iu`** | `STB_ProdRouteHist` | AFTER INSERT, UPDATE | Tự động đồng bộ số thứ tự công đoạn và kế hoạch ngày khi công nhân quét chuyển trạm trên chuyền sản xuất. |
| **`utr_MaterialCodeByLine_i`** | `STB_ProdRouteHist` | AFTER INSERT | Tự động gán mã vật tư tương ứng với từng dây chuyền khi có dữ liệu quét lộ trình. |
| **`utr_MachineInfoChangeHist`** | `STB_MachineMaster` | AFTER UPDATE | Ghi vết mọi sự thay đổi thông số máy móc, trạng thái hiệu chuẩn, hoặc bảo dưỡng sang bảng nhật ký thiết bị. |
| **`tgMaterialLotInfoForInsert`**<br/>**`tgMaterialLotInfoForUpdate`**<br/>**`tgMaterialLotInfoForDelete`** | `STB_MaterialLotInfo` | AFTER I/U/D | Bộ 3 trigger giám sát toàn vẹn Lot nguyên vật liệu, ngăn chặn tình trạng số dư âm hoặc thông số cuộn màng/dung dịch mâu thuẫn. |
| **`tgMaterialDocDetailForInsert`**<br/>**`tgMaterialDocDetailForUpdate`**<br/>**`tgMaterialDocDetailForDelete`** | `STB_MaterialDocDetail` | AFTER I/U/D | Đồng bộ trạng thái chứng từ xuất nhập kho nguyên vật liệu với số lượng thực nhận trên phiếu. |
| **`utr_ProductStockInfoUpload_i`**<br/>**`utr_ProductStockInfoUpload_u`**<br/>**`utr_ProductStockInfoUpload_d`** | `STB_ProductStockInfoUpload` | AFTER I/U/D | Lắng nghe các bản ghi thành phẩm chuyển lên từ `STB_VN_FINISHGOODS` để tự động đẩy vào tồn kho chính thức hoặc gửi sang Hàn Quốc. |
| **`utr_ProcedureChangesLog`** | DDL Trigger (Database) | FOR DDL | Giám sát và ghi nhận mọi thay đổi mã nguồn (ALTER/CREATE PROCEDURE) của lập trình viên vào bảng kiểm toán hệ thống `DDLChangeLog`. |

---

## 3. Kiến Trúc Phản Xạ Của Trigger `utr_STB_SetInfo_DayPlanNo_iu`

Mã nguồn thực tế được trích xuất từ database:
```sql
CREATE TRIGGER [dbo].[utr_STB_SetInfo_DayPlanNo_iu]
   ON  [dbo].[STB_SetInfo]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ESM_DayProdPlanUpdateTarget (DayPlanNo, Barcode, CreateDateTime)
    SELECT
         D.DayPlanNo
        ,D.Barcode
        ,GETDATE()
    FROM
        inserted AS D

   SET NOCOUNT OFF;
END
```

### Điểm Cần Lưu Ý Cho Kỹ Sư CSDL:
- Bất kỳ câu lệnh `UPDATE` hàng loạt trên `STB_SetInfo` (ví dụ `UPDATE STB_SetInfo SET ... WHERE DayPlanNo = '...'`) sẽ kích hoạt Trigger này bắn vào `ESM_DayProdPlanUpdateTarget` số lượng bản ghi tương ứng. Do đó, **tuyệt đối không chạy UPDATE hàng loạt trên bảng này trong giờ sản xuất cao điểm** để tránh gây Lock gián tiếp sang các tiến trình tính toán của MES!
