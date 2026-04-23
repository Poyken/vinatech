-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2022-03-15
-- Browsable : True
-- Group : 팝업
-- Description:	자주검사 + VPC자주검사 팝업
-- Modified:
-- 프로시저 실행 :   usp_VPCCommInspTypeInfo_popup  '','','VNT','VNT_F1'
-- ================================================================
CREATE PROCEDURE [dbo].[usp_VPCCommInspTypeInfo_popup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL
AS


BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

    
	SELECT
			CITI.CommInspTypeCode,
			CITI.CommInspTypeName,
			CITI.CommInspTypeDesc
	FROM
			STB_CommInspTypeInfo CITI WITH(NOLOCK)
	WHERE 1=1
	   --AND			((@CompanyCode = '*') OR (CITI.CompanyCode = @CompanyCode)) 
	   --AND			((@WorkCenterCode = '*') OR (CITI.WorkCenterCode = @WorkCenterCode)) 
	   AND CITI.CommInspTypeCode IN ('ROUTE_TEST_VPC','ROUTE_TEST')

END



