-- Procedure: usp_GetScreenListForVendor

-- =============================================
-- Author:		Park Jong Seob (jspark@awoo.co.kr)
-- Create date: 2016-01-20
-- Browsable : true
-- Group : 시스템관리
-- Modified : 2016-10-05 Jeon Gyeong Ho(khjun@awoo.co.kr) 1단계 상위메뉴명이 아닌 최상위 메뉴명이 나오게
-- Description:	Get Screen List For UserType
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetScreenListForVendor]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(50) = null, -- SystemBase.Language를 가져옴
	@pUserType VARCHAR(20) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Language VARCHAR(50) = @pProcessLanguage,
			@UserType VARCHAR(20) = @pUserType,
			@SystemCode VARCHAR(20)

	SELECT
			@SystemCode = UI.SystemCode
	FROM
			STB_UserInfo UI WITH(NOLOCK)
	WHERE
			UI.UserID = @pProcessUserID

	;WITH MenuList(SCLevel,Name,Caption,IsFolder,TCode,ParentName) AS
	(
		SELECT
				0 AS SCLevel,
				SI.Name,
				SI.Caption,
				SI.IsFolder,
				SI.TCode,
				dbo.fnGetVendorRootScreen(@pProcessUserID, SI.ParentName) AS ParentName
		FROM
				STB_VendorScreenInfo SI WITH(NOLOCK)
		WHERE
				SI.SystemCode IN ('Common',@SystemCode) AND
				SI.IsFolder = 0 AND
				SI.IsDelete = 0
	)
	SELECT
			@UserType AS UserType,
			ML.Name,
			ISNULL(ISNULL(SR.Value,DSR.Value),ML.Caption) AS Caption,
			ISNULL(UTBP.AllowView,0) AS AllowView,
			ML.ParentName,
			ISNULL(ISNULL(PSR.Value,PDSR.Value),SI.Caption) AS ParentCaption,--SI.Caption AS ParentCaption,
			ML.IsFolder
	FROM
			MenuList ML
			LEFT OUTER JOIN STB_VendorScreenInfo SI WITH(NOLOCK)
				ON	SI.SystemCode IN ('Common',@SystemCode) AND
					SI.Name = ML.ParentName
			LEFT OUTER JOIN STB_UserTypeBasicPermission UTBP WITH(NOLOCK)
				ON (UTBP.Name = ML.Name AND UTBP.UserType = @UserType)
			LEFT OUTER JOIN STB_StringResources DSR WITH(NOLOCK)
				ON	DSR.Language = 'Default' AND
					DSR.Type = 'AddOn' AND
					DSR.Name = ML.Caption
			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
				ON	SR.Language = @Language AND
					SR.Type = 'AddOn' AND
					SR.Name = ML.Caption
			LEFT OUTER JOIN STB_StringResources PDSR WITH(NOLOCK)
				ON	PDSR.Language = 'Default' AND
					PDSR.Type = 'AddOn' AND
					PDSR.Name = SI.Caption
			LEFT OUTER JOIN STB_StringResources PSR WITH(NOLOCK)
				ON	PSR.Language = @Language AND
					PSR.Type = 'AddOn' AND
					PSR.Name = SI.Caption
	ORDER BY
			ML.ParentName,
			ML.TCode

END

GO

