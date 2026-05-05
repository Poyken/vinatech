-- Procedure: usp_GetHelpList







-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-21
-- Description:	도움말을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetHelpList]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pScreenName VARCHAR(50) = NULL
	-- 화면 도움말 사용안함 2017-07-13
	--@pIncludeScreen BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ScreenName VARCHAR(50) = @pScreenName,
			@ScreenCaption NVARCHAR(100),
			@CreateDateTime DATETIME,
			@CreateUserID VARCHAR(20)

	SELECT
			@ScreenCaption = ISNULL(SR.Value, SI.Caption),
			@CreateDateTime = SI.CreateDateTime,
			@CreateUserID = SI.CreateUserID
	FROM
			STB_ScreenInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_StringResources SR
				ON	SR.Language = @ProcessLanguage AND
					SR.Name = SI.Caption
	WHERE
			SI.Name = @ScreenName

	IF @ScreenName IS NULL BEGIN
		SET @ScreenName = ''
	END

	--DECLARE @ScreenFolderName NVARCHAR(50)
	--EXEC usp_GetSystemStringResource @pProcessLanguage,
	--								 '^화면^',
	--								 @ScreenFolderName OUTPUTgeth

	--IF @pIncludeScreen = 1 BEGIN
	--	DECLARE @ScreenInfo TABLE
	--	(
	--		Id VARCHAR(50),
	--		ParentId VARCHAR(50),
	--		ScreenName VARCHAR(50),
	--		Title NVARCHAR(100),
	--		IsFolder BIT,
	--		CreateDateTime DATETIME,
	--		CreateUserID VARCHAR(20),
	--		ChangeDateTime DATETIME,
	--		ChangeUserID VARCHAR(20),
	--		Level INT
	--	)			

	--	DECLARE @Level INT = 1;

	--	WITH Permission AS
	--	(
	--		SELECT
	--				DISTINCT
	--				SP.Name
	--		FROM
	--				(
	--					SELECT
	--							UTBP.Name
	--					FROM
	--							STB_UserTypeBasicPermission UTBP WITH (NOLOCK)
	--					WHERE
	--							UTBP.UserType IN (
	--										SELECT
	--												UPG.UserType
	--										FROM
	--												STB_UserPermissionGroup UPG WITH (NOLOCK)
	--										WHERE
	--												UPG.UserID = @pProcessUserID AND
	--												ISNULL(UPG.HasPermission,0) = 1
	--									) AND UTBP.AllowView = 1
	--				) SP
	--	)
	--	INSERT INTO @ScreenInfo
	--	SELECT 
	--			SI.Name,
	--			SI.ParentName,
	--			SI.Name,			
	--			ISNULL(SR.Value, SI.Caption) AS Title,
	--			SI.IsFolder,
	--			SI.CreateDateTime,
	--			SI.CreateUserID,
	--			SI.ChangeDateTime,
	--			SI.ChangeUserID,
	--			@Level
	--	FROM 
	--			Permission P
	--			INNER JOIN STB_ScreenInfo SI WITH (NOLOCK)
	--				ON	SI.Name = P.Name
	--			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
	--				ON	SR.Language = @ProcessLanguage AND
	--					SR.Type = 'AddOn' AND
	--					SR.Name = SI.Caption
	--	WHERE
	--			(SI.IsFolder = 0) AND
	--			(SI.ShowInMenu = 1) AND
	--			(SI.IsDelete = 0)
	
	--	WHILE 1 = 1 BEGIN
	--		INSERT INTO @ScreenInfo
	--		SELECT 
	--				SI.Name,
	--				CASE 
	--					WHEN ISNULL(SI.ParentName,'') = '' THEN '9999999999'
	--					ELSE SI.ParentName
	--				END,
	--				SI.Name,			
	--				ISNULL(SR.Value, SI.Caption) AS Title,
	--				SI.IsFolder,
	--				SI.CreateDateTime,
	--				SI.CreateUserID,
	--				SI.ChangeDateTime,
	--				SI.ChangeUserID,
	--				@Level + 1
	--		FROM 
	--				STB_ScreenInfo SI WITH (NOLOCK)
	--				LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
	--					ON	SR.Language = @ProcessLanguage AND
	--						SR.Type = 'AddOn' AND
	--						SR.Name = SI.Caption
	--		WHERE
	--				SI.IsFolder = 1 AND
	--				SI.Name IN  (
	--								SELECT
	--										C.ParentId
	--								FROM
	--										@ScreenInfo C
	--								WHERE
	--										C.Level = @Level
	--							) AND
	--				NOT EXISTS  (
	--								SELECT
	--										1
	--								FROM
	--										@ScreenInfo C
	--								WHERE
	--										C.ScreenName = SI.Name
	--							)
	--		IF @@ROWCOUNT = 0 BEGIN
	--			BREAK
	--		END
	--		SET @Level = @Level + 1
	--	END

	--	SELECT
	--			H.Id,
	--			H.ParentId,
	--			ISNULL(HL.Title, H.Title) AS Title,
	--			H.IsFolder,
	--			H.CreateDateTime,
	--			H.CreateUserID,
	--			NULL AS Contents,
	--			ISNULL(HL.ChangeDateTime,H.ChangeDateTime) AS ChangeDateTime,
	--			ISNULL(HL.ChangeUserID,H.ChangeUserID) AS ChangeUserID,
	--			CONVERT(VARCHAR,NULL) AS ScreenName
	--	FROM
	--			STB_Help H WITH(NOLOCK)
	--			LEFT OUTER JOIN STB_HelpLanguage HL WITH(NOLOCK)
	--				ON	HL.Id = H.Id AND
	--					HL.Language = @ProcessLanguage
	--	UNION
	--	SELECT
	--			'9999999999' AS Id,
	--			NULL AS ParentId,
	--			@ScreenFolderName AS Title,
	--			CONVERT(BIT,1) AS IsFolder,
	--			GETDATE() AS CreateDateTime,
	--			@ProcessUserID CreateUserID,
	--			NULL AS Contents,
	--			GETDATE() AS ChangeDateTime,
	--			@ProcessUserID AS ChangeUserID,
	--			CONVERT(VARCHAR,NULL) AS ScreenName
	--	UNION
	--	SELECT
	--			SI.Id,
	--			SI.ParentId,
	--			SI.Title,
	--			SI.IsFolder,
	--			SI.CreateDateTime,
	--			SI.CreateUserID,
	--			NULL AS Contents,
	--			SI.ChangeDateTime,
	--			SI.ChangeUserID,
	--			SI.ScreenName
	--	FROM
	--			@ScreenInfo SI
		
	--END ELSE BEGIN
	SELECT
			H.*
	FROM
			(
		SELECT
				1 AS Seq,
				'9999999999' AS [Key],
				'9999999999' AS Id,
				NULL AS ParentId,
				@ScreenCaption AS Title,
				CONVERT(BIT,1) AS IsFolder,
				@CreateDateTime AS CreateDateTime,
				@CreateUserID AS CreateUserID,
				NULL AS Contents,
				@CreateDateTime AS ChangeDateTime,
				@CreateUserID AS ChangeUserID,
				NULL AS ScreenName
		WHERE
				@ScreenName IS NOT NULL AND @ScreenName <> ''
		UNION
		SELECT
				2 AS Seq,
				@ScreenName + H.Id AS [Key],
				H.Id,
				'9999999999' AS ParentId,
				ISNULL(HL.Title, H.Title) AS Title,
				H.IsFolder,
				H.CreateDateTime,
				H.CreateUserID,
				NULL AS Contents,
				ISNULL(HL.ChangeDateTime,H.ChangeDateTime) AS ChangeDateTime,
				ISNULL(HL.ChangeUserID,H.ChangeUserID) AS ChangeUserID,
				NULL AS ScreenName
		FROM
				STB_ScreenHelp SH WITH(NOLOCK)
				INNER JOIN STB_Help H WITH(NOLOCK)
					ON	H.Id = SH.Id
				INNER JOIN STB_HelpLanguage HL WITH(NOLOCK)
					ON	HL.Id = H.Id AND
						HL.Language = @ProcessLanguage
		WHERE
				SH.Name = @ScreenName
		UNION
		SELECT
				3 AS Seq,
				H.Id AS [Key],
				H.Id,
				H.ParentId,
				ISNULL(HL.Title, H.Title) AS Title,
				H.IsFolder,
				H.CreateDateTime,
				H.CreateUserID,
				NULL AS Contents,
				ISNULL(HL.ChangeDateTime,H.ChangeDateTime) AS ChangeDateTime,
				ISNULL(HL.ChangeUserID,H.ChangeUserID) AS ChangeUserID,
				NULL AS ScreenName
		FROM
				STB_Help H WITH(NOLOCK)
				LEFT OUTER JOIN STB_HelpLanguage HL WITH(NOLOCK)
					ON	HL.Id = H.Id AND
						HL.Language = @ProcessLanguage
		) H
	ORDER BY
			H.Seq,
			H.IsFolder DESC,
			H.Title ASC
	--END
END








GO

