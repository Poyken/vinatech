-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 공통
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BomHeader_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END

    
	SELECT
	        BH.MaterialCode AS OldMaterialCode,
	        BH.BomVersion AS OldBomVersion,
	        BH.MaterialCode,
	        BH.BomVersion,
	        
	        BH.RouteCode,
			RI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			CI.CompanyDesc,
			CI.CompanyDescL,
			RI.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			WCI.WorkCenterDesc,
			WCI.WorkCenterDescL,
			RI.RouteName,
			RI.IsExternalRoute,
	        
	        BH.IsBasic,
	        BH.BomHeaderDesc,

			BH.BasicRoutingCode,
			BRI.BasicRoutingName,
			MM.MaterialUnit,
			BH.BomUnit,
	        BH.IsUsed,
	        BH.CreateDateTime,
	        BH.CreateUserID,
	        BH.ChangeDateTime,
	        BH.ChangeUserID
	FROM
	        STB_BomHeader BH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = BH.RouteCode
	        LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON RI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON RI.WorkCenterCode = WCi.WorkCenterCode
			LEFT OUTER JOIN STB_BasicRoutingInfo BRI WITH (NOLOCK)
				ON (BRI.BasicRoutingCode = BH.BasicRoutingCode)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)
				ON (MM.MaterialCode = BH.MaterialCode)
	WHERE
	        ((BH.MaterialCode = @MaterialCode)) 

END
