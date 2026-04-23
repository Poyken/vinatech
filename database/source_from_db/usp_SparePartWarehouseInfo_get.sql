-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트창고정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartWarehouseInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pSPWarehouseCode VARCHAR(20) = NULL,
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pSPWarehouseName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
      DECLARE @SPWarehouseName NVARCHAR(100) = CASE WHEN ISNULL(@pSPWarehouseName,'') = '' THEN '*' ELSE @pSPWarehouseName END

    
	SELECT
	        SPWI.SPWarehouseCode AS OldSPWarehouseCode,
	        SPWI.SPWarehouseCode,
	        SPWI.SPWarehouseName,
	        
	        SPWI.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        SPWI.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        SPWI.IsUsed,
	        SPWI.CreateDateTime,
	        SPWI.CreateUserID,
	        SPWI.ChangeDateTime,
	        SPWI.ChangeUserID
	FROM
	        STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPWI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON SPWI.CompanyCode = CI.CompanyCode
	WHERE
	        ((@SPWarehouseCode = '*') OR (SPWI.SPWarehouseCode = @SPWarehouseCode)) AND
	        ((@CompanyCode = '*') OR (SPWI.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (SPWI.WorkCenterCode = @WorkCenterCode)) AND
	        ((@SPWarehouseName = '*') OR (SPWI.SPWarehouseName = @SPWarehouseName)) 

END


