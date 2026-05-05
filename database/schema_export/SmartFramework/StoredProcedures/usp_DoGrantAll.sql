-- Procedure: usp_DoGrantAll




-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : true
-- Create date: 2017-01-03
-- Description:	사용자그룹에 전체 권한을 할당합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoGrantAll]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUserType VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@UserType VARCHAR(20) = @pUserType;


	MERGE STB_UserTypeBasicPermission AS T
	USING (
			SELECT
					SI.Name
			FROM
					STB_ScreenInfo SI WITH(NOLOCK)
			WHERE
					SI.IsFolder = 0
			) AS S
		ON	(
				T.UserType = @UserType AND
				S.Name = T.Name
			)
	WHEN MATCHED THEN
		UPDATE
		SET
				AllowView = 1
	WHEN NOT MATCHED THEN
		INSERT
		(
			UserType,
			Name,
			AllowView
		)
		VALUES
		(
			@UserType,
			S.Name,
			1
		);

	MERGE STB_UserTypeViewPermission AS T
	USING	(
				SELECT
						SO.ScreenName,
						SO.ObjectType,
						SO.ObjectName
				FROM
						STB_ScreenObjects SO WITH(NOLOCK)	
				WHERE
						SO.ObjectType = 'View'
			) AS S
		ON	(
				T.UserType = @UserType AND
				S.ScreenName = T.Name AND
				S.ObjectName = T.ViewName
			)
	WHEN MATCHED THEN
		UPDATE
		SET
				AllowAdd = 1,
				AllowModify = 1,
				AllowDelete = 1,
				AllowExcel = 1,
				AllowImport = 1
	WHEN NOT MATCHED THEN
		INSERT
		(
			UserType,
			Name,
			ViewName,
			AllowAdd,
			AllowModify,
			AllowDelete,
			AllowExcel,
			AllowImport
		)
		VALUES
		(
			@UserType,
			S.ScreenName,
			S.ObjectName,
			1,
			1,
			1,
			1,
			1
		);

	MERGE STB_UserTypeFunctionPermission AS T
	USING	(
				SELECT
						DISTINCT
						S.ScreenName,
						S.ObjectName
				FROM
						STB_ScreenObjects S WITH(NOLOCK)
				WHERE
						S.ObjectType = 'Action'
			) AS S
	ON		(
				T.UserType = @UserType AND
				S.ScreenName = T.Name AND
				S.ObjectName = T.FunctionName
			)
	WHEN MATCHED THEN
		UPDATE
		SET
				Allow = 1
	WHEN NOT MATCHED THEN
		INSERT
		(
			UserType,
			Name,
			FunctionName,
			Allow
		)
		VALUES
		(
			@UserType,
			S.ScreenName,
			S.ObjectName,
			1
		);
END





GO

