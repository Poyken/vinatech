-- =============================================
-- Author: SONG JU CHOUL
-- Create date: 2021-09-15
-- Browsable : true
-- Group : 자재관리
-- Description: 생산라인에서 생산중인 제품코드 팝업
-- Modified:
-- =============================================
 CREATE PROCEDURE [dbo].[usp_GetMaterialCurrentQty_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pSourceMaterialWarehouseCode VARCHAR(20) = NULL,
	@pLotID VARCHAR(500) = NULL

--WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	 
    DECLARE 
			 @CompanyCode VARCHAR(20) = @pCompanyCode
			,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
			,@SourceMaterialWarehouseCode VARCHAR(20) = @pSourceMaterialWarehouseCode
			,@LotID VARCHAR(500) = @pLotID
			,@Count Int = NULL

	SELECT MLI.CompanyCode
				  ,MLI.WorkCenterCode
				  ,MLI.MaterialWarehouseCode
				  ,MLI.MaterialCode
				  ,MLI.LotID
				  ,MLI.CurrentQty
	FROM STB_MaterialLotInfo MLI
	WHERE MLI.CompanyCode = @CompanyCode
	AND MLI.WorkCenterCode =@WorkCenterCode
	AND MLI.MaterialWarehouseCode = @SourceMaterialWarehouseCode
	AND MLI.LotID = @LotID

	IF @@ROWCOUNT = 0
		BEGIN
			SELECT NULL AS CompanyCode
				  ,NULL AS WorkCenterCode
				  ,NULL AS MaterialWarehouseCode
				  ,NULL AS MaterialCode
				  ,NULL AS LotID
				  ,NULL AS CurrentQty

			RAISERROR('LotID Check Please',16,1)
			RETURN
		END
		
END




