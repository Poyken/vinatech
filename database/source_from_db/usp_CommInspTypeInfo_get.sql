


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사유형정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspTypeInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName NVARCHAR(50) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pWorkCenterName NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

    
	SELECT
			CITI.CommInspTypeCode AS OldCommInspTypeCode,
			CITI.CommInspTypeCode,
			CITI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			CITI.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			CITI.CommInspTypeName,
			CITI.CommInspTypeDesc,
			ISNULL(CITI.IsRouteKey,0) AS IsRouteKey,
			ISNULL(CITI.IsFacilityRouteKey,0) AS IsFacilityRouteKey,
			ISNULL(CITI.IsMachineKey,0) AS IsMachineKey,
			ISNULL(CITI.IsMoldKey,0) AS IsMoldKey,
			ISNULL(CITI.IsMaterialKey,0) AS IsMaterialKey,
			ISNULL(CITI.IsDocKey,0) AS IsDocKey,
			ISNULL(CITI.IsShiftKey,0) AS IsShiftKey,
			ISNULL(CITI.IsTimeCodeKey,0) AS IsTimeCodeKey,
			ISNULL(CITI.IsCategoryKey,0) AS IsCategoryKey,
			ISNULL(CITI.IsProdKey,0) AS IsProdKey,
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			CITI.ImageFileID,
			ISNULL(CITI.IsAutoFinish,0) AS IsAutoFinish,
			CITI.CITIExtText01,
			CITI.CITIExtText02,
			CITI.CITIExtText03,
			CITI.CITIExtInt01,
			CITI.CITIExtInt02,
			CITI.CITIExtInt03,
			CITI.CITIExtReal01,
			CITI.CITIExtReal02,
			CITI.CITIExtReal03,
			CITI.CreateDateTime,
			CITI.CreateUserID,
			CITI.ChangeDateTime,
			CITI.ChangeUserID
	FROM
			STB_CommInspTypeInfo                     CITI WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON CITI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo       CI WITH(NOLOCK)				ON CITI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)				ON (AFM.FileID = CITI.ImageFileID)
	WHERE 1=1
	  AND	((@CompanyCode = '*') OR (CITI.CompanyCode = @CompanyCode)) 
	  AND	((@WorkCenterCode = '*') OR (CITI.WorkCenterCode = @WorkCenterCode)) 

END


--- SELECT * FROM STB_CommInspTypeInfo
