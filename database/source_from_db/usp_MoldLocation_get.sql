-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-01
-- Browsable : true
-- Group : 금형관리
-- Description:	금형 보관위치 정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldLocation_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pLocationName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
      DECLARE @LocationName NVARCHAR(100) = CASE WHEN ISNULL(@pLocationName,'') = '' THEN '*' ELSE @pLocationName END

    
	SELECT
	        ML.MoldLocationCode AS OldMoldLocationCode,
	        ML.MoldLocationCode,
	        ML.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        CI.CompanyDesc,
	        CI.CompanyDescL,
	        ML.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        WCI.WorkCenterDesc,
	        WCI.WorkCenterDescL,
	        ML.LocationName,
	        ML.LocationDesc1,
	        ML.LocationDesc2,
	        ML.CreateDateTime,
	        ML.CreateUserID,
	        ML.ChangeDateTime,
	        ML.ChangeUserID
	FROM
	        STB_MoldLocation ML WITH(NOLOCK)
	        LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON ML.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON ML.WorkCenterCode = WCI.WorkCenterCode 
	WHERE
	        ((@CompanyCode = '*') OR (ML.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (ML.WorkCenterCode = @WorkCenterCode)) AND
	        ((@LocationName = '*') OR (ML.LocationName = @LocationName)) 

END


