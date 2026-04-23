-- =============================================
-- Author: SONG JU CHOUL
-- Create date: 2022-07-01
-- Browsable : true
-- Group : 자재관리
-- Description: 원자재창고자재 포장 수량 조회
-- Modified:
-- =============================================
 CREATE PROCEDURE [dbo].[usp_GetMaterialPackingQty_popup]
	@pSourceMaterialWarehouseCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL

--WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	 
    DECLARE @SourceMaterialWarehouseCode VARCHAR(20) = @pSourceMaterialWarehouseCode
		   ,@MaterialCode VARCHAR(50) = @pMaterialCode

	SELECT DISTINCT MaterialCode
		  ,CurrentQty
	  FROM STB_MaterialLotInfo
	 WHERE MaterialWarehouseCode = @SourceMaterialWarehouseCode
	   AND MaterialCode = @MaterialCode
	   AND CurrentQty - PickingQty > 0

	IF @@ROWCOUNT = 0
		BEGIN
			SELECT NULL AS MaterialCode
				  ,NULL AS CurrentQty

			RAISERROR('현재 재고가 없는 품번입니다.',16,1)
			RETURN
		END
		
END




