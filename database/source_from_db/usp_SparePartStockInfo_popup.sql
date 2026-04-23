-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-20
-- Browsable : true
-- Group : 팝업
-- Description:	스페어파트 로케이션별 재고 정보-팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartStockInfo_popup] 
	@pSPWarehouseCode VARCHAR(20) = NULL,
	@pSparePartCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '' ELSE @pSPWarehouseCode END
	DECLARE @SparePartCode VARCHAR(20) = CASE WHEN ISNULL(@pSparePartCode,'') = '' THEN '' ELSE @pSparePartCode END
	
	SELECT
			SPSI.SPLocationCode,
			SPLI.SPLocationName,
			SPLI.SPLocationGroup,
			ISNULL(SPSI.CurrentStockQty,0) AS CurrentStockQty
	FROM
			STB_SparePartStockInfo SPSI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON SPSI.SPWarehouseCode = SPLI.SPWarehouseCode
				AND SPSI.SPLocationCode = SPLI.SPLocationCode
			
	WHERE
			((@SPWarehouseCode = '*') OR (SPSI.SPWarehouseCode = @SPWarehouseCode)) 
			AND ((@SparePartCode = '*') OR (SPSI.SparePartCode = @SparePartCode))
			AND ((SPLI.IsUsed = 1))

END

