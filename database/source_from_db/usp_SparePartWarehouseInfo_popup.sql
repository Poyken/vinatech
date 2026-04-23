-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 팝업
-- Description:	스페어파트 창고정보-팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartWarehouseInfo_popup] 
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	
	SELECT
			SPWI.SPWarehouseCode,
			SPWI.SPWarehouseName,
			SPWI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			SPWI.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL
	FROM
			STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPWI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON SPWI.CompanyCode = CI.CompanyCode
	WHERE
			((@CompanyCode = '*') OR (SPWI.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (SPWI.WorkCenterCode = @WorkCenterCode))


END

