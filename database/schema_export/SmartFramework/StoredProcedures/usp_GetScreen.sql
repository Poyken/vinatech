-- Procedure: usp_GetScreen






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Get Screen
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetScreen]
	@pName VARCHAR(50),
	@pVersion INT = 0,
	@pDeveloperVersion VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Name VARCHAR(50) = @pName,
			@Version INT = @pVersion,
			@DeveloperVersion VARCHAR(20) = @pDeveloperVersion,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(50) = @pProcessLanguage,
			@CurrentVersion INT,
			@CurrentDate DATE,
			@SystemCode VARCHAR(20)
			
	SET @CurrentDate = CONVERT(DATE, GETDATE())			
			
	IF (
			SELECT 
					COUNT(*) 
			FROM
					STB_MenuUsedHistory MUH
			WHERE
					MUH.UseDate = @CurrentDate AND
					MUH.UserID = @ProcessUserID AND
					MUH.Name = @Name
		) > 0
	BEGIN
			UPDATE STB_MenuUsedHistory
			SET
					UsedCount = UsedCount + 1
			WHERE
					UseDate = @CurrentDate AND
					UserID = @ProcessUserID AND
					Name = @Name
	END ELSE BEGIN
			INSERT INTO STB_MenuUsedHistory
				(UseDate, UserID, Name, UsedCount)
			VALUES
				(@CurrentDate, @ProcessUserID, @Name, 1)
	END

	SELECT
			@SystemCode = UI.SystemCode

	FROM
			STB_UserInfo UI WITH (NOLOCK)
	WHERE
			UI.UserID = @ProcessUserID
					
			
	--SELECT
	--		@Version = MAX(SLI.Version)
	--FROM
	--		STB_ScreenInfo SI WITH(NOLOCK)			
	--		INNER JOIN STB_ScreenLayoutInfo SLI WITH(NOLOCK)
	--			ON	SI.Name = SLI.Name AND
	--				SI.CurrentVersion = SLI.Version
	--WHERE
	--		SI.Name = @Name --AND
			--((SLI.DeveloperVersion = @DeveloperVersion) OR
			-- (SLI.DeveloperVersion = (	SELECT
			--									MAX(SLI.DeveloperVersion)
			--							FROM
			--									STB_ScreenLayoutInfo SLI WITH(NOLOCK)
			--							WHERE
			--									SLI.Name = @Name )))
		
	SELECT
			@CurrentVersion = SI.CurrentVersion
	FROM
			STB_ScreenInfo SI WITH(NOLOCK)
	WHERE
			SI.Name = @Name
	/********************************************************************************/
	-- 2016-08-29 Kim Han Young(hykim@awoo.co.kr)
	-- Developer 에서 대화상자 오픈시에는 체크아웃을 하지 않아야 하는 문제로
	-- CheckOut 은 usp_DoCheckOut 을 별도로 호출
	/********************************************************************************/
	-- DEVELOPER 에거 조회할 때는 체크아웃
	-- IF @Version > 0 BEGIN
		--DECLARE @CheckOutUserID VARCHAR(20)
		--SELECT
		--		@CheckOutUserID = SI.CheckOutUserID
		--FROM
		--		STB_ScreenInfo SI WITH(NOLOCK)
		--WHERE
		--		SI.Name = @Name

		--IF ISNULL(@CheckOutUserID,'') = '' BEGIN
		--	UPDATE STB_ScreenInfo
		--	SET
		--			CheckOutUserID = @ProcessUserID
		--	WHERE
		--			Name = @Name
		--END
	-- END

	IF @Version <= 0 BEGIN
		SET @Version = @CurrentVersion
	END
	
    SELECT
			CASE
				WHEN VSI.Name IS NULL THEN SI.Name
				ELSE VSI.Name
			END AS Name,
			CASE
				WHEN VSI.TCode IS NULL THEN SI.TCode
				ELSE VSI.TCode
			END AS TCode,
			CASE
				WHEN VSI.IsFolder IS NULL THEN SI.IsFolder
				ELSE VSI.IsFolder
			END AS IsFolder,
			CASE	
				WHEN VSI.IsNeverClose IS NULL THEN SI.IsNeverClose
				ELSE VSI.IsNeverClose
			END AS IsNeverClose,
			CASE
				WHEN VSI.ShowAfterStart IS NULL THEN SI.ShowAfterStart
				ELSE VSI.ShowAfterStart
			END AS ShowAfterStart,
			CASE 
				WHEN VSI.ParentName IS NULL THEN SI.ParentName
				ELSE VSI.ParentName
			END AS ParentName,
			CASE
				WHEN VSI.Caption IS NULL THEN SI.Caption
				ELSE VSI.Caption
			END AS Caption,
			SI.CreateDateTime,
			SI.CreateUserID,
			SLI.Layout,
			SLI.XmlLayout,			
			@Version AS Version,
			SLI.Description,
			--CASE SI.IsFolder
			CASE VSI.IsFolder
				WHEN 1 THEN 0
				ELSE
						(
							SELECT
									MAX(SLI.Version)
							FROM
									STB_ScreenLayoutInfo SLI WITH(NOLOCK)
							WHERE
									SLI.Name = SI.Name
						)
			END AS MaxVersion,
			SI.CheckOutUserID,
			CASE
				WHEN ISNULL(SI.CheckOutUserID,@ProcessUserID) <> @ProcessUserID THEN CONVERT(BIT,1)
				ELSE CONVERT(BIT,0)
			END AS IsReadOnly,
			SI.CreateDateTime,
			SI.CreateUserID,
			SI.ChangeDateTime,
			SI.ChangeUserID
    FROM
			STB_ScreenInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_VendorScreenInfo VSI WITH (NOLOCK)
				ON (VSI.SystemCode = @SystemCode AND VSI.Name = SI.Name)
			INNER JOIN STB_ScreenLayoutInfo SLI WITH(NOLOCK)
				ON	SLI.Name = SI.Name AND
					SLI.Version = @Version
	WHERE
			SI.Name = @Name
			
			
	-- View Permission			
	SELECT
		UTVP.ViewName,
		CONVERT(BIT,
		CASE	
			WHEN SUM(AllowAddCount) > 0 THEN 1
			ELSE 0
		END) AS AllowAdd,
		CONVERT(BIT,
		CASE
			WHEN SUM(AllowModifyCount) > 0 THEN 1
			ELSE 0
		END) AS AllowModify,
		CONVERT(BIT,
		CASE
			WHEN SUM(AllowDeleteCount) > 0 THEN 1
			ELSE 0
		END) AS AllowDelete,
		CONVERT(BIT,
		CASE
			WHEN SUM(AllowExcelCount) > 0 THEN 1
			ELSE 0
		END) AS AllowExcel,
		CONVERT(BIT,
		CASE
			WHEN SUM(AllowImportCount) > 0 THEN 1
			ELSE 0
		END) AS AllowImport
	FROM
		(
			SELECT
					UTVP.ViewName,
					CASE 
						WHEN ISNULL(UTVP.AllowAdd, 0) = 1 THEN 1
						ELSE 0
					END AS AllowAddCount,
					CASE
						WHEN ISNULL(UTVP.AllowModify,0) = 1 THEN 1
						ELSE 0
					END AS AllowModifyCount,
					CASE 
						WHEN ISNULL(UTVP.AllowDelete,0) = 1 THEN 1
						ELSE 0
					END AS AllowDeleteCount,
					CASE 
						WHEN ISNULL(UTVP.AllowExcel,0) = 1 THEN 1
						ELSE 0
					END AS AllowExcelCount,
					CASE 
						WHEN ISNULL(UTVP.AllowImport,0) = 1 THEN 1
						ELSE 0
					END AS AllowImportCount
			FROM
					STB_UserTypeViewPermission UTVP	
			WHERE
					UTVP.Name = @Name AND
					UTVP.UserType IN (
									SELECT
											UserType
									FROM
											STB_UserPermissionGroup UPG
									WHERE
											UPG.UserID = @pProcessUserID AND
											ISNULL(UPG.HasPermission, 0) = 1
								)

		) UTVP
	GROUP BY
		UTVP.ViewName


	-- Function Permission			
	SELECT
		UTFP.FunctionName,
		CONVERT(BIT,
		CASE	
			WHEN SUM(AllowCount) > 0 THEN 1
			ELSE 0
		END) AS Allow
	FROM
		(
			SELECT
					UTFP.FunctionName,
					CASE 
						WHEN ISNULL(UTFP.Allow, 0) = 1 THEN 1
						ELSE 0
					END AS AllowCount
			FROM
					STB_UserTypeFunctionPermission UTFP	
			WHERE
					UTFP.Name = @Name AND
					UTFP.UserType IN (
									SELECT
											UserType
									FROM
											STB_UserPermissionGroup UPG
									WHERE
											UPG.UserID = @pProcessUserID AND
											ISNULL(UPG.HasPermission, 0) = 1
								)

		) UTFP
	GROUP BY
		UTFP.FunctionName

	SELECT
			*
	FROM
			STB_UserViewLayout UVL WITH(NOLOCK)
	WHERE
			UVL.UserID = @ProcessUserID AND
			UVL.ScreenName = @Name
		
END







GO

