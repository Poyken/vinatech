-- Procedure: usp_GetMenuList




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Get Menu List
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMenuList]
	@pProcessUserID VARCHAR(20),
	@pAccessType VARCHAR(50) = 'PC'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@AccessType VARCHAR(50) = @pAccessType

	DECLARE @SystemCode VARCHAR(20)


	SELECT
			@SystemCode = UI.SystemCode
	FROM
			STB_UserInfo UI WITH (NOLOCK)
	WHERE
			UI.UserID = @ProcessUserID

	
	DECLARE @ScreenInfo TABLE
	(
		ID VARCHAR(54),
		Name VARCHAR(50),
		TCode VARCHAR(10),
		IsFolder BIT,
		IsNeverClose BIT,
		ParentName VARCHAR(50),
		Caption NVARCHAR(100),
		ShowAfterStart BIT,
		ShowInMenu BIT,
		IsFavorite BIT,
		CreateUserID VARCHAR(20),
		CurrentVersion INT,
		MaxVersion INT,
		AccessType VARCHAR(50),
		Icon VARBINARY(MAX),
		[Level] INT		
	)			

	DECLARE @Level INT = 1;

	DECLARE @PermissionScreen TABLE
	(
		Name NVARCHAR(200)
	)
	INSERT INTO @PermissionScreen
	SELECT
			DISTINCT
			SP.Name
	FROM
			(
				SELECT
						UTBP.Name
				FROM
						STB_UserTypeBasicPermission UTBP WITH (NOLOCK)
				WHERE
						UTBP.UserType IN (
									SELECT
											UPG.UserType
									FROM
											STB_UserPermissionGroup UPG WITH (NOLOCK)
									WHERE
											UPG.UserID = @pProcessUserID AND
											ISNULL(UPG.HasPermission,0) = 1
								) AND UTBP.AllowView = 1
			) SP

	INSERT INTO @ScreenInfo
	SELECT 
			VSI.Name AS ID,
			VSI.Name,
			VSI.TCode,
			VSI.IsFolder,
			ISNULL(VSI.IsNeverClose,0) AS NeverClose,
			VSI.ParentName,
			VSI.Caption,
			ISNULL(VSI.ShowAfterStart,0) AS ShowAfterStart,
			VSI.ShowInMenu,
			0 AS IsFavorite,
			VSI.CreateUserID,
			VSI.CurrentVersion,
			VSI.CurrentVersion AS MaxVersion,
			VSI.AccessType,
			VSI.Icon,
			@Level
	FROM 
			@PermissionScreen P
			INNER JOIN STB_VendorScreenInfo VSI WITH (NOLOCK)
				ON	VSI.Name = P.Name AND VSI.SystemCode = @SystemCode
	WHERE
			(VSI.IsFolder = 0) AND
			(VSI.ShowInMenu = 1) AND
			(VSI.IsDelete = 0) AND
			(CharIndex(@pAccessType, VSI.AccessType) > 0)
	
	WHILE 1 = 1 BEGIN
		INSERT INTO @ScreenInfo
		SELECT 
				VSI.Name AS ID,
				VSI.Name,
				VSI.TCode,
				VSI.IsFolder,
				ISNULL(VSI.IsNeverClose,0) AS NeverClose,
				VSI.ParentName,
				VSI.Caption,
				ISNULL(VSI.ShowAfterStart,0) AS ShowAfterStart,
				VSI.ShowInMenu,
				0 AS IsFavorite,
				VSI.CreateUserID,
				-1 AS CurrentVersion,
				-1 AS MaxVersion,
				@AccessType AS AccessType,
				VSI.Icon,
				@Level + 1
		FROM 
				STB_VendorScreenInfo VSI WITH (NOLOCK)
		WHERE
				VSI.SystemCode = @SystemCode AND
				VSI.IsFolder = 1 AND
				VSI.Name IN  (
								SELECT
										C.ParentName
								FROM
										@ScreenInfo C
								WHERE
										C.Level = @Level
							) AND
				NOT EXISTS  (
								SELECT
										1
								FROM
										@ScreenInfo C
								WHERE
										C.Name = VSI.Name
							)
		IF @@ROWCOUNT = 0 BEGIN
			BREAK
		END
		SET @Level = @Level + 1
	END
	
	
	INSERT INTO @ScreenInfo
    SELECT
			'ZZZZ' + FM.Name AS ID,
			FM.Name AS Name,
			VSI.TCode,
			0 AS IsFoler,
			ISNULL(VSI.IsNeverClose,0) AS NeverClose,
			'ZZZZ' AS Parent,
			VSI.Caption AS Caption,
			ISNULL(VSI.ShowAfterStart,0) AS ShowAfterStart,
			1 AS ShowInMenu,
			1 AS IsFavorite,
			'' AS CreateUserID,
			SI.CurrentVersion,
			SI.CurrentVersion AS MaxVersion,
			SI.AccessType,
			SI.Icon,
			-1 AS Level
	FROM
			@PermissionScreen P
			INNER JOIN STB_FavoriteMenu FM WITH (NOLOCK)
				ON	FM.Name = P.Name
			INNER JOIN STB_ScreenInfo SI WITH (NOLOCK)
				ON	SI.Name = FM.Name
			LEFT OUTER JOIN STB_VendorScreenInfo VSI WITH (NOLOCK)
				ON VSI.SystemCode = @SystemCode AND VSI.Name = SI.Name
	WHERE
			FM.UserID = @pProcessUserID AND
			SI.IsDelete = 0 AND
			(CharIndex(@pAccessType, SI.AccessType) > 0)
	--IF @@ROWCOUNT > 0 BEGIN
	IF (
			SELECT
					COUNT(*)
			FROM
					@ScreenInfo
			WHERE
					ParentName = 'ZZZZ'
			
		) > 0 BEGIN
		INSERT INTO @ScreenInfo
		SELECT
				'ZZZZ' AS ID,
				'ZZZZ' AS Name,
				'' AS TCode,
				1 ,
				0 AS NeverClose,
				NULL AS Parent,
				'^즐겨찾기^' AS Caption,
				0 AS ShowAfterStart,
				1 AS ShowInMenu,
				0 AS IsFavorite,			
				'' AS CreateUserID,
				-1 AS CurrentVersion,
				-1 AS MaxVersion,				
				@AccessType AS AccessType,
				NULL AS Icon,
				-1 AS Level
	END
			
	SELECT	*
	FROM
			@ScreenInfo SI
	ORDER BY
			SI.TCode ASC,
			SI.Level DESC
			 
END




GO

