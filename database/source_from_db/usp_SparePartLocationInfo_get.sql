-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 로케이션 정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartLocationInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pSPWarehouseCode VARCHAR(20) = NULL,
    @pSPLocationCode VARCHAR(20) = NULL,
    @pSPLocationName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END
    DECLARE @SPLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pSPLocationCode,'') = '' THEN '*' ELSE @pSPLocationCode END
    DECLARE @SPLocationName NVARCHAR(100) = CASE WHEN ISNULL(@pSPLocationName,'') = '' THEN '*' ELSE @pSPLocationName END

    
	SELECT
	        SPLI.SPWarehouseCode AS OldSPWarehouseCode,
	        SPLI.SPWarehouseCode,
	        SPWI.SPWarehouseName,
	        
	        SPWI.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        SPWI.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        SPLI.SPLocationCode AS OldSPLocationCode,
	        SPLI.SPLocationCode,
	        SPLI.SPLocationName,
	        
	        SPLI.SPLocationGroup,
	        SPLI.IsUsed,
	        SPLI.CreateDateTime,
	        SPLI.CreateUserID,
	        SPLI.ChangeDateTime,
	        SPLI.ChangeUserID
	FROM
	        STB_SparePartLocationInfo SPLI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPLI.SPWarehouseCode = SPWI.SPWarehouseCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPWI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON SPWI.CompanyCode = CI.CompanyCode
	WHERE
			((@CompanyCode = '*') OR (SPWI.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (SPWI.WorkCenterCode = @WorkCenterCode)) AND
	        ((@SPWarehouseCode = '*') OR (SPLI.SPWarehouseCode = @SPWarehouseCode)) AND
	        ((@SPLocationCode = '*') OR (SPLI.SPLocationCode = @SPLocationCode)) AND
	        ((@SPLocationName = '*') OR (SPLI.SPLocationName = @SPLocationName)) 

END


