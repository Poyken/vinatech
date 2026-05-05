-- Procedure: usp_DoUpgradeToCustomer




-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-09-12
-- Description:	업그레이드를 처리합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpgradeToCustomer]
	@pCustomerName NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query NVARCHAR(MAX) = '
    INSERT INTO [{CUSTOMER_NAME}].[SmartFramework].[dbo].[STB_UpgradeFiles]
	(
		ProgramName,
		FileName,
		Version,
		FileData,
		TargetPath,
		CreateDateTime,
		CreateUserID,
		ChangeDateTime,
		ChangeUserID
	)
	SELECT
			ProgramName,
			FileName,
			Version,
			FileData,
			TargetPath,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID
	FROM
			STB_UpgradeFiles S
	WHERE
			NOT EXISTS	(
							SELECT
									1
							FROM
									[{CUSTOMER_NAME}].[SmartFramework].[dbo].[STB_UpgradeFiles] T
							WHERE
									T.ProgramName = S.ProgramName AND
									T.FileName = S.FileName
						)
	
	UPDATE
			[{CUSTOMER_NAME}].[SmartFramework].[dbo].[STB_UpgradeFiles]
	SET
			FileData = S.FileData,
			Version = S.Version,
			ChangeDateTime = S.ChangeDateTime,
			ChangeUserID = S.ChangeUserID
	FROM
			[{CUSTOMER_NAME}].[SmartFramework].[dbo].[STB_UpgradeFiles] T
			INNER JOIN STB_UpgradeFiles S
				ON	S.ProgramName = T.ProgramName AND
					S.FileName = T.FileName AND
					S.Version <> T.Version
	WHERE
			T.ProgramName = ''GUI''
'
	SET @Query = REPLACE(@Query, '{CUSTOMER_NAME}', @pCustomerName)

	EXEC sp_executesql @Query
END





GO

