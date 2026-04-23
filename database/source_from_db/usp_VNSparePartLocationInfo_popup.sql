-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 팝업
-- Description:	스페어파트 로케이션 정보-팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNSparePartLocationInfo_popup] 
	@pSPWarehouseCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END
	
	SELECT
			SPLI.SPLocationCode,
			SPLI.SPLocationName,
			SPLI.SPLocationGroup
	FROM
			STB_VNSparePartLocationInfo SPLI WITH(NOLOCK)
			
	WHERE
			((@SPWarehouseCode = '*') OR (SPLI.SPWarehouseCode = @SPWarehouseCode))
			AND ((SPLI.IsUsed = 1))

END
