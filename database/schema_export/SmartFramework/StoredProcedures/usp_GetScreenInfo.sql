-- Procedure: usp_GetScreenInfo







-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-06-26
-- Description:	화면의 버전과 권한 정보를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetScreenInfo]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),	
	@pName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@Name VARCHAR(50) = @pName,
			@LastStringResourceChanged VARCHAR(20),
			@SystemCode VARCHAR(50),
			@CurrentDate DATE

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
			
	SELECT @SystemCode = SystemCode 
	FROM STB_UserInfo WITH(NOLOCK) 
	WHERE UserID = @pProcessUserID
    
	SELECT
			@LastStringResourceChanged = ISNULL(CONVERT(VARCHAR,MAX(
			CASE 
				WHEN SR.ChangeDateTime IS NULL THEN SRD.ChangeDateTime
				ELSE SR.ChangeDateTime
			END),120),'2000-01-01 00:00:00')
    FROM
			STB_StringResources SRD WITH(NOLOCK)
			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
				ON	SR.Language = @ProcessLanguage AND
					SR.Type = SRD.Type AND
					SR.Name = SRD.Name
	WHERE
			SRD.Language = 'Default'

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
			SI.CurrentVersion AS Version,
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
			SI.ChangeUserID,
			@LastStringResourceChanged AS LastStringResourceChanged
	FROM
			STB_ScreenInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_VendorScreenInfo VSI WITH (NOLOCK)
				ON (VSI.SystemCode = @SystemCode AND 
					VSI.Name = SI.Name)
			LEFT OUTER JOIN STB_ScreenLayoutInfo SLI WITH(NOLOCK)
				ON	SLI.Name = SI.Name AND
					SLI.Version = SI.CurrentVersion
	WHERE
			SI.Name = @pName

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
	;WITH FunctionPerm AS
	(
		SELECT
				UTFP.FunctionName,
				SUM(CONVERT(INT,ISNULL(UTFP.Allow,0))) AS Allow
		FROM
				STB_UserTypeFunctionPermission UTFP WITH(NOLOCK)
		WHERE
				UTFP.Name = @Name  AND
				UTFP.UserType IN (
								SELECT
										UserType
								FROM
										STB_UserPermissionGroup UPG
								WHERE
										UPG.UserID = @ProcessUserID AND
										ISNULL(UPG.HasPermission, 0) = 1
							)
		GROUP BY
				UTFP.FunctionName
	)
	SELECT
			UTFP.FunctionName,
			CASE
				WHEN UTFP.Allow > 0 THEN CONVERT(BIT,1)
				ELSE CONVERT(BIT,0)
			END AS Allow
	FROM
			FunctionPerm UTFP

	-- User Layout
	SELECT
			*
	FROM
			STB_UserViewLayout UVL WITH(NOLOCK)
	WHERE
			UVL.UserID = @ProcessUserID AND
			UVL.ScreenName = @Name
END

GO

