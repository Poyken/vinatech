
-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-01-14
-- Browsable : true
-- Group : 공통
-- Description:	WorkCenter Information
-- 2021.11.23 WorkCenter부문 추가

-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkCenterInfo_get] 
						@pProcessLanguage VARCHAR(20),
						@pProcessUserID VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode NVARCHAR(20) = NULL,
						@pWorkCenterName NVARCHAR(50) = NULL
WITH RECOMPILE
AS


BEGIN

	SET NOCOUNT ON;
		
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END,
			    @WorkCenterCode NVARCHAR(50) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END,
			    @WorkCenterName NVARCHAR(50) = CASE WHEN ISNULL(@pWorkCenterName,'') = '' THEN '*' ELSE @pWorkCenterName END
			
		
	SELECT
			WCI.WorkCenterCode AS OldWorkCenterCode,
			WCI.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			WCI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			CI.CompanyDesc,
			CI.CompanyDescL,
			WCI.WorkCenterDesc,
			WCI.WorkCenterDescL,
			WCI.WorkCenterBarcode,
			WCI.IsUsed,
			WCI.CreateDateTime,
			WCI.CreateUserID,
			WCI.ChangeDateTime,
			WCI.ChangeUserID
	FROM         		       STB_WorkCenterInfo WCI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON WCI.CompanyCode = CI.CompanyCode
	WHERE 1=1
	  AND ((@CompanyCode = '*') OR (WCI.CompanyCode = @CompanyCode)) 
	  AND ((@WorkCenterCode = '*') OR (WCI.WorkCenterCode = @WorkCenterCode)) 
	  AND ((@WorkCenterName = '*') OR (WCI.WorkCenterName = @WorkCenterName))

END

