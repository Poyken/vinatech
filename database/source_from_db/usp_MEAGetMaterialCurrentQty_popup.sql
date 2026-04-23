-- =============================================
-- Author: SONG JU CHOUL
-- Create date: 2022-09-08
-- Browsable : true
-- Group : 자재관리
-- Description: MEA 소재 원자재투입 자재바코드 CurrentQty 팝업
-- Modified:
-- =============================================
 CREATE PROCEDURE [dbo].[usp_MEAGetMaterialCurrentQty_popup]
	@pCompanyCode VARCHAR(20) = 'VNT',
	@pWorkCenterCode VARCHAR(20) = 'VNT_F2',
	@pSourceMaterialWarehouseCode VARCHAR(20) =	'W13', -- W13 : 공정(소재), W15 : 공정(지지체)
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
	AND MLI.WorkCenterCode = @WorkCenterCode
	--AND MLI.MaterialWarehouseCode = @SourceMaterialWarehouseCode
	AND MLI.MaterialWarehouseCode IN ('W13', 'W15')
	AND MLI.LotID = @LotID OR MLI.LotNO = @LotID

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




