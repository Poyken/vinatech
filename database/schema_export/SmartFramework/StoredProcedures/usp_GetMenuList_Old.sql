-- Procedure: usp_GetMenuList_Old






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Get Menu List
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMenuList_Old]
	@pProcessUserID VARCHAR(20),
	@pAccessType VARCHAR(50) = 'PC'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@AccessType VARCHAR(50) = @pAccessType

	
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
		AccessType VARCHAR(50)
	)
	INSERT INTO @ScreenInfo
	SELECT 
			SI.Name AS ID,
			SI.Name,
			SI.TCode,
			SI.IsFolder,
			ISNULL(SI.IsNeverClose,0) AS NeverClose,
			SI.ParentName,
			SI.Caption,
			ISNULL(SI.ShowAfterStart,0) AS ShowAfterStart,
			SI.ShowInMenu,
			0 AS IsFavorite,
			SI.CreateUserID,
			-1 AS CurrentVersion,
			-1 AS MaxVersion,
			@AccessType AS AccessType
	FROM 
			STB_ScreenInfo SI WITH (NOLOCK)
	WHERE
			SI.IsFolder = 1
	UNION
	SELECT 
			SI.Name AS ID,
			SI.Name,
			SI.TCode,
			SI.IsFolder,
			ISNULL(SI.IsNeverClose,0) AS NeverClose,
			SI.ParentName,
			SI.Caption,
			ISNULL(SI.ShowAfterStart,0) AS ShowAfterStart,
			SI.ShowInMenu,
			0 AS IsFavorite,
			SI.CreateUserID,
			SI.CurrentVersion,
			SI.CurrentVersion AS MaxVersion,
			SI.AccessType
	FROM 
			STB_ScreenInfo SI WITH (NOLOCK)
			LEFT OUTER JOIN (
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
						) BP
				ON	SI.Name = BP.Name
	WHERE
			(SI.IsFolder = 0) AND
			(BP.Name IS NOT NULL) AND
			(SI.ShowInMenu = 1) AND
			(SI.IsDelete = 0) AND
			(CharIndex(@pAccessType, SI.AccessType) > 0)
    UNION
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
			@AccessType AS AccessType
	UNION
    SELECT
			'ZZZZ' + FM.Name AS ID,
			FM.Name AS Name,
			SI.TCode,
			0 AS IsFoler,
			ISNULL(SI.IsNeverClose,0) AS NeverClose,
			'ZZZZ' AS Parent,
			SI.Caption AS Caption,
			ISNULL(SI.ShowAfterStart,0) AS ShowAfterStart,
			1 AS ShowInMenu,
			1 AS IsFavorite,
			'' AS CreateUserID,
			SI.CurrentVersion,
			SI.CurrentVersion AS MaxVersion,
			SI.AccessType
	FROM
			STB_FavoriteMenu FM WITH (NOLOCK)
			INNER JOIN STB_ScreenInfo SI WITH (NOLOCK)
				ON	SI.Name = FM.Name
	WHERE
			FM.UserID = @pProcessUserID AND
			SI.IsDelete = 0 AND
			(CharIndex(@pAccessType, SI.AccessType) > 0)
			
 --   SELECT
	--		SI.*
	--FROM
	--		@ScreenInfo SI
	--ORDER BY 
	--		TCode,
	--		Name
			

	
			
	;WITH SI_CTE ( ID, Parent, CNT)
	AS
	(
		SELECT 
				ID,
				ParentName,
				0 AS CNT
		FROM
				@ScreenInfo 
		WHERE
				ISNULL(ParentName,'') = ''
		UNION ALL
		SELECT
				SI.ID,
				SI.ParentName,
				--SI_CTE.CNT + 1 AS CNT
				CASE 
					WHEN SI.IsFolder = 0 THEN SI_CTE.CNT + 1 
					ELSE SI_CTE.CNT
				END AS CNT
		FROM
				@ScreenInfo SI 
				INNER JOIN SI_CTE ON SI.ParentName = SI_CTE.ID
	)
	SELECT
			*
	FROM		
			@ScreenInfo SI
			LEFT OUTER JOIN (
								SELECT 
										Parent,
										SUM(Cnt) AS CNT
								FROM
										SI_CTE
								WHERE 
										CNT > 0
								GROUP BY
										SI_CTE.Parent
							) SI_Folder
				ON (SI_Folder.Parent = SI.ID)
	WHERE
			SI.IsFolder = 0 OR
			(SI.IsFolder = 1 AND SI_Folder.CNT > 0)
	ORDER BY
--			SI.IsFolder DESC,
			SI.TCode,
			SI.Caption
				
			
END







GO

