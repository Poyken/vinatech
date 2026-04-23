-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-07-22
-- Browsable : true
-- Group : 자재관리
-- Description:	자재창고정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouse_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pMaterialWarehouseName NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
      DECLARE @MaterialWarehouseName NVARCHAR(50) = CASE WHEN ISNULL(@pMaterialWarehouseName,'') = '' THEN '*' ELSE @pMaterialWarehouseName END

    
	SELECT
	        MW.MaterialWarehouseCode AS OldMaterialWarehouseCode,
	        MW.MaterialWarehouseCode,
	        MW.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        CI.CompanyDesc,
	        CI.CompanyDescL,
	        MW.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        WCI.WorkCenterDesc,
	        WCI.WorkCenterDescL,
	        MW.MaterialWarehouseName,
	        MW.MaterialWarehouseNameL,
	        MW.MaterialWarehouseDesc,
	        MW.MaterialWarehouseDescL,
			MW.DefaultLocationCode,
			ML.MaterialLocationName,
			MW.RequestProductGroupCode,
	        MW.IsUsed,
	        MW.WHExtText01,
	        MW.WHExtText02,
	        MW.WHExtText03,
	        MW.WHExtText04,
	        MW.WHExtText05,
	        MW.CreateDateTime,
	        MW.CreateUserID,
	        MW.ChangeDateTime,
	        MW.ChangeUserID,
			MW.IsRouteWarehouse
	FROM
	        STB_MaterialWarehouse MW WITH(NOLOCK)
	        LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MW.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MW.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_MaterialLocation ML
				ON (ML.MaterialLocationCode = MW.DefaultLocationCode)
	WHERE
	        ((@CompanyCode = '*') OR (MW.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (MW.WorkCenterCode = @WorkCenterCode)) AND
	        ((@MaterialWarehouseName = '*') OR (MW.MaterialWarehouseName LIKE @MaterialWarehouseName + '%')) 

END