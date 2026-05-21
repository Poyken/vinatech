# 🔍 Phân Tích Lỗi Unique Constraint & Hướng Dẫn Hủy Giao Dịch — Màn Hình HN544

Tài liệu này phân tích nguyên nhân gây lỗi trùng khóa `LotID` trên màn hình **[HN544] Gộp túi bóng thành hộp nhỏ** và cung cấp các script xử lý (hủy giao dịch lỗi + sửa đổi SP triệt để).

---

## 1. 🔴 Nguyên Nhân Gốc Rễ (Root Cause)

Khi User nhập `Packing ID: PKQN2100175` và nhấn Tìm kiếm trên màn hình HN544, hệ thống thực thi Stored Procedure:
`exec usp_GetMaterialLotInfo_Packing_VVT_F3 'trieu','vi','','PKQN2100175'`

Stored Procedure này dùng `UNION ALL` để gộp kết quả từ 3 câu truy vấn:
1. **Truy vấn 1 (Bảng `STB_MaterialLotInfo`):** Quét các Lot có `PackingID = 'PKQN2100175'`. Tìm thấy **1 dòng** (LotID: `63RHHL180ME16XB001QN2100012`).
2. **Truy vấn 3 (Bảng `STB_DividePackaging`):** Quét các dòng có `PackingID = 'PKQN2100175'`. Giao dịch gộp này đã ghi nhận 1 dòng trong bảng này.
   - Do đây là mã cha (chưa được chia tách), cột `PackingParentID` của nó bị bỏ trống (`""` hoặc `NULL`).
   - Cú pháp join trong Truy vấn 3:
     ```sql
     LEFT JOIN STB_MaterialLotInfo MLI ON MLI.LotNo = DP.LotNo and MLI.PackingID = DP.PackingParentID
     ```
     Vì `DP.PackingParentID` trống, phép `LEFT JOIN` không tìm thấy dòng khớp trong `STB_MaterialLotInfo`, khiến toàn bộ các cột của bảng `MLI` bị trả về `NULL`.
   - Kết quả: Truy vấn 3 trả về thêm **1 dòng thứ 2** có `LotID = NULL` và `PackingID = 'PKQN2100175'`.

### 💥 Điểm gây lỗi:
Khi dữ liệu trả về client (DataTable trong ứng dụng C#):
- DataTable có thiết lập ràng buộc duy nhất (`Unique = true`) trên cột `LotID`.
- Khi DataTable nhận dòng thứ 2 (có `LotID` là `null` hoặc chuỗi trống), code client-side tự động điền hoặc clone giá trị mặc định của dòng trước đó hoặc xảy ra xung đột khóa, dẫn đến ngoại lệ:
  > **Column 'LotID' is constrained to be unique. Value '63RHHL180ME16XB001QN2100012' is already present.**

---

## 2. 🛠️ Đề Xuất Script Sửa Lỗi

> [!IMPORTANT]
> Theo **Nguyên tắc vận hành hệ thống**, toàn bộ các script dưới đây phải do **User trực tiếp thực thi trên SSMS**. Vui lòng sao chép và chạy theo thứ tự sau.

### Bước 1: Script hủy giao dịch gộp dở dang (Revert Merge)
Do bạn đã backup bảng `STB_DividePackaging` vào `STB_DividePackaging_BK`, chúng ta sẽ xóa dòng lỗi này và tiến hành backup + xóa dòng tương ứng trong bảng hộp nhỏ `STB_PackingNilonToBoxSmall_HN`.

```sql
-- 1. BẮT ĐẦU TRANSACTION ĐỂ ĐẢM BẢO AN TOÀN
BEGIN TRANSACTION;
BEGIN TRY

    -- 2. SAO LƯU DỮ LIỆU BẢNG HỘP NHỎ (STB_PackingNilonToBoxSmall_HN) TRƯỚC KHI XÓA
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'STB_PackingNilonToBoxSmall_HN_BK')
    BEGIN
        SELECT * INTO STB_PackingNilonToBoxSmall_HN_BK 
        FROM STB_PackingNilonToBoxSmall_HN 
        WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';
    END
    ELSE
    BEGIN
        INSERT INTO STB_PackingNilonToBoxSmall_HN_BK
        SELECT * 
        FROM STB_PackingNilonToBoxSmall_HN 
        WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';
    END

    PRINT '--> Da sao luu thong tin hop nho vao STB_PackingNilonToBoxSmall_HN_BK';

    -- 3. THỰC HIỆN XÓA GIAO DỊCH LỖI Ở BẢNG PHÂN CHIA (ĐÃ CÓ BK TRƯỚC ĐÓ)
    DELETE FROM STB_DividePackaging 
    WHERE PackingID = 'PKQN2100175';
    
    PRINT '--> Da xoa record loi trong STB_DividePackaging';

    -- 4. THỰC HIỆN XÓA RECORD TRONG BẢNG HỘP NHỎ
    DELETE FROM STB_PackingNilonToBoxSmall_HN 
    WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';

    PRINT '--> Da xoa record hop nho trong STB_PackingNilonToBoxSmall_HN';

    -- 5. XÁC NHẬN GIAO DỊCH THÀNH CÔNG
    COMMIT TRANSACTION;
    PRINT '==> HOÀN THÀNH HỦY GIAO DỊCH THÀNH CÔNG!';

END TRY
BEGIN CATCH
    -- NẾU CÓ LỖI XẢY RA, KHÔI PHỤC LẠI TRẠNG THÁI BAN ĐẦU
    ROLLBACK TRANSACTION;
    PRINT '==> CÓ LỖI XẢY RA. ĐÃ ROLLBACK TOÀN BỘ!';
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
```

---

### Bước 2: Script sửa triệt để Stored Procedure (Prevent Future Crash)
Để ngăn chặn lỗi này lặp lại khi người dùng tìm kiếm mã cha hoặc gộp túi bóng, ta sửa đổi câu truy vấn thứ 3 trong Stored Procedure `usp_GetMaterialLotInfo_Packing_VVT_F3` để loại trừ các mã cha (chỉ cho phép các mã con đã chia tách tham gia join).

*Vui lòng chạy script cập nhật Stored Procedure dưới đây:*

```sql
USE [SmartFactoryV2]
GO

ALTER PROCEDURE [dbo].[usp_GetMaterialLotInfo_Packing_VVT_F3]
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pWorkerCode VARCHAR(20) = NULL,
		@pPackingID VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LotId VARCHAR(50) = @pPackingID
	DECLARE @MergeQty INT  = 0

	;
	WITH Lot AS
	(
		SELECT
				MLI.MaterialLotNo
		FROM
				STB_MaterialLotInfo MLI WITH(NOLOCK)
		WHERE  Lotno = @LotId or PackingID = @LotId or MergePackingId=@LotId
	)    
	SELECT DISTINCT
			MLI.MaterialLotNo AS OldMaterialLotNo,
			MLI.MaterialLotNo,
			MLI.LotID,
			T4.MarkingName,
			ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
			MLI.WorkCenterCode,
			MLI.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MLI.MaterialLocationCode,
			ML.MaterialLocationName,
			MLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.PackingID,
			MLI.GRDate,
			MLI.MaterialDeliveryNo,
			MLI.MaterialDeliveryDetailNo,
			FORMAT(MLI.InitialQty, '0.######') as InitialQty,
			FORMAT(MLI.CurrentQty, '0.######') as CurrentQty,
			MLI.CurrentQty AS StockQty,
			MLI.PickingQty,
			MLI.CurrentQty - MLI.PickingQty AS AvailableQty,
			MLI.VendorLotNo,
			MLI.LifeBasicDate,
			MLI.ProductionDate,
			MLI.EndOfLifeDate,
			MLI.LotNo,
			MLI.IsSplitLot,
			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,
			MLI.BefMaterialLotNo,
			MLI.CreateDateTime,
			MLI.CreateUserID,
			MLI.ChangeDateTime,
			MLI.ChangeUserID,
			MLI.PackingIdParent,
			MLI.MergeParentId
			,  ISNULL(MDLI.Lotattr10, MLI.LotAttr10)          AS LotAttr10    
			, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  
			,MLI.isSlitting, 
			@MergeQty as MergeQty 		
	FROM
			Lot L
			INNER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)				ON	MLI.MaterialLotNo = L.MaterialLotNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK) ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        
			LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	        LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
			LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode T4 ON T4.MarkingCode=MLI.MarkingCode
	
	UNION ALL 
	
	SELECT DISTINCT
			MLI.MaterialLotNo AS OldMaterialLotNo,
			MLI.MaterialLotNo,
			MLI.LotID,
			T4.MarkingName,
			ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
			MLI.WorkCenterCode,
			MLI.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MLI.MaterialLocationCode,
			ML.MaterialLocationName,
			MLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.PackingID,
			MLI.GRDate,
			MLI.MaterialDeliveryNo,
			MLI.MaterialDeliveryDetailNo,
			FORMAT(MLI.InitialQty, '0.######') as InitialQty,
			FORMAT(MLI.CurrentQty, '0.######') as CurrentQty,
			MLI.CurrentQty AS StockQty,
			MLI.PickingQty,
			MLI.CurrentQty - MLI.PickingQty AS AvailableQty,
			MLI.VendorLotNo,
			MLI.LifeBasicDate,
			MLI.ProductionDate,
			MLI.EndOfLifeDate,
			MLI.LotNo,
			MLI.IsSplitLot,
			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,
			MLI.BefMaterialLotNo,
			MLI.CreateDateTime,
			MLI.CreateUserID,
			MLI.ChangeDateTime,
			MLI.ChangeUserID,
			MLI.PackingIdParent,
			MLI.MergeParentId
			,  ISNULL(MDLI.Lotattr10, MLI.LotAttr10)          AS LotAttr10    
			, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  
			,MLI.isSlitting, 
			@MergeQty as MergeQty 		
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_PackingNilonToBoxSmall_HN PN WITH(NOLOCK) ON MLI.MergeNilonToSmallBox = PN.PackingNilonToBoxSmallID
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK) ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        
			LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	        LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
		   LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode T4 ON T4.MarkingCode=MLI.MarkingCode
			where PN.PackingNilonToBoxSmallID=@pPackingID
	
	UNION ALL

	SELECT
		DISTINCT
		MLI.MaterialLotNo AS OldMaterialLotNo,
		MLI.MaterialLotNo,
		MLI.LotID,
		'' as MarkingName,
		MLI.CompanyCode,
		MLI.WorkCenterCode,
		MLI.MaterialWarehouseCode,
		MW.MaterialWarehouseName,
		MLI.MaterialLocationCode,
		ML.MaterialLocationName,
		ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
		MM.MaterialName,
		MM.MaterialTypeCode,
		MT.MaterialTypeName,
		MM.ProductGroupCode,
		PG.ProductGroupName,
		MM.MaterialSpec,
		MLI.MaterialStockAttribute,
		MLI.StockAttrib1,
		MLI.StockAttrib2,
		MLI.StockAttrib3,
		DP.PackingID AS PackingID,
		MLI.GRDate,
		MLI.MaterialDeliveryNo,
		MLI.MaterialDeliveryDetailNo,
		FORMAT(DP.Qty, '0.######') AS InitialQty,        
		FORMAT(DP.Qty, '0.######') AS CurrentQty,        
		DP.Qty AS StockQty,                              
		MLI.PickingQty,
		DP.Qty - MLI.PickingQty AS AvailableQty,         
		MLI.VendorLotNo,
		MLI.LifeBasicDate,
		MLI.ProductionDate,
		MLI.EndOfLifeDate,
		MLI.LotNo,
		MLI.IsSplitLot,
		CONVERT(NUMERIC(20,5), NULL) AS SplitQty,
		MLI.BefMaterialLotNo,
		MLI.CreateDateTime,
		MLI.CreateUserID,
		MLI.ChangeDateTime,
		MLI.ChangeUserID,
		MLI.PackingIdParent,
		MLI.MergeParentId,
		ISNULL(MDLI.Lotattr10, MLI.LotAttr10) AS LotAttr10,
		CONVERT(VARCHAR(10), DATEADD(DAY, -1, DATEADD(MM, MM.MMExtInt01, MLI.Lotattr10)), 121) AS PackDate,
		MLI.isSlitting,
		@MergeQty AS MergeQty
    FROM STB_DividePackaging DP WITH(NOLOCK)
    LEFT JOIN STB_MaterialLotInfo MLI ON MLI.LotNo = DP.LotNo and MLI.PackingID = DP.PackingParentID
    LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MLI.MaterialCode = MM.MaterialCode
    LEFT JOIN STB_MaterialType MT WITH(NOLOCK) ON MM.MaterialTypeCode = MT.MaterialTypeCode
    LEFT JOIN STB_ProductGroup PG WITH(NOLOCK) ON PG.ProductGroupCode = MM.ProductGroupCode
    LEFT JOIN STB_MaterialWarehouse MW WITH(NOLOCK) ON MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
    LEFT JOIN STB_MaterialLocation ML WITH(NOLOCK) ON ML.MaterialLocationCode = MLI.MaterialLocationCode
    LEFT JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
		ON MLI.MaterialCode = MDLI.MaterialCode
		AND MLI.LotNo = MDLI.LotNo
		AND MLI.LotID = MDLI.LotID
	LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
	WHERE DP.PackingID = @pPackingID  
	  -- THÊM ĐIỀU KIỆN DƯỚI ĐÂY ĐỂ TRÁNH TRẢ VỀ DÒNG DUMMY KHI QUÉT MÃ CHA CHƯA PHÂN TÁCH
	  AND ISNULL(DP.PackingParentID, '') <> '' 
  
END
GO
```
