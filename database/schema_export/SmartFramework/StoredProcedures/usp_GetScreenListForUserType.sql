-- Procedure: usp_GetScreenListForUserType



-- =============================================
-- Author:		Park Jong Seob (jspark@awoo.co.kr)
-- Create date: 2016-01-20
-- Browsable : true
-- Group : 시스템관리
-- Modified : 2016-10-05 Jeon Gyeong Ho(khjun@awoo.co.kr) 1단계 상위메뉴명이 아닌 최상위 메뉴명이 나오게
-- Description:	Get Screen List For UserType

-- 프로시저 실행 : [usp_GetScreenListForUserType] 'Korean', 'SBC', 'ProdDepartmentHead'
-- =================================================================================================
CREATE PROCEDURE [dbo].[usp_GetScreenListForUserType]
									@pProcessLanguage VARCHAR(50) = null, -- SystemBase.Language를 가져옴
									@pSystemCode VARCHAR(20) = 'SBC',
									@pUserType VARCHAR(20) = null
AS

BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Language VARCHAR(50) = @pProcessLanguage,
			@SystemCode VARCHAR(20) = @pSystemCode,
			@UserType VARCHAR(20) = @pUserType

	;WITH SC_CTE(SCLevel,Name,Caption,IsFolder,TCode,ParentName,ParentNames) AS
	(
		SELECT
				0 AS SCLevel,
				SI.Name,
				SI.Caption,
				SI.IsFolder,
				SI.TCode,
				SI.ParentName,
				CAST('' AS VARCHAR(MAX)) AS ParentNames
		FROM
				STB_VendorScreenInfo SI WITH(NOLOCK)
		WHERE	
				SI.SystemCode = @SystemCode AND
				ISNULL(SI.ShowInMenu,0) = 1 AND 
				ISNULL(SI.IsDelete,0) = 0 AND
				ISNULL(SI.ParentName,'') = ''
			
		UNION ALL

		SELECT
				CTE.SCLevel + 1,
				SI.Name,
				SI.Caption,
				SI.IsFolder,
				SI.TCode,
				SI.ParentName,
				CAST(CASE WHEN ISNULL(CTE.ParentName,'') = '' THEN '' ELSE CTE.ParentName + ',' + CTE.ParentNames END AS VARCHAR(MAX)) AS ParentNames
		FROM
				STB_VendorScreenInfo SI WITH(NOLOCK)
				INNER JOIN SC_CTE CTE
					ON CTE.Name = SI.ParentName
		WHERE
				SI.SystemCode = @SystemCode AND
				ISNULL(SI.ShowInMenu,0) = 1 AND 
				ISNULL(SI.IsDelete,0) = 0
	),
	MenuList AS
	(
		SELECT
				CTE.Name,
				CTE.Caption,
				CTE.ParentName,
				--(
				--	SELECT
				--			TOP 1
				--			Item
				--	FROM
				--			[SmartFactoryV2].dbo.fnSplitToTable(',',CTE.ParentNames)
				--	WHERE
				--			Item <> ''
				--	ORDER BY
				--			RowNo DESC
				--) AS ParentName,
				CTE.IsFolder,
				CTE.TCode
		FROM
				SC_CTE CTE 
				LEFT OUTER JOIN STB_VendorScreenInfo SI
					ON (SI.SystemCode = @SystemCode AND SI.Name = CTE.ParentName)
		--WHERE
		--		ISNULL(CTE.IsFolder,0) = 0
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
					ON (SI.SystemCode = @SystemCode AND SI.Name = ML.ParentName)
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
				--ML.ParentName,
				ML.TCode
	--SELECT
	--		@pUserType AS UserType,
	--		SI.Name,
	--		ISNULL(ISNULL(SR.Value,DSR.Value),SI.Caption) AS Caption,
	--		UTBP.AllowView,
	--		SI.ParentName,
	--		SI.IsFolder
	--FROM
	--		STB_ScreenInfo SI WITH(NOLOCK)
	--		LEFT OUTER JOIN STB_UserTypeBasicPermission UTBP WITH(NOLOCK)
	--			ON (UTBP.Name = SI.Name AND UTBP.UserType = @UserType)
	--		LEFT OUTER JOIN STB_StringResources DSR WITH(NOLOCK)
	--			ON	DSR.Language = 'Default' AND
	--				DSR.Type = 'AddOn' AND
	--				DSR.Name = SI.Caption
	--		LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
	--			ON	SR.Language = @Language AND
	--				SR.Type = 'AddOn' AND
	--				SR.Name = SI.Caption
	--WHERE
	--		SI.ShowInMenu = 1 AND
	--		SI.IsDelete = 0
	--ORDER BY
	--		SI.TCode,
	--		SI.Name

END



GO

