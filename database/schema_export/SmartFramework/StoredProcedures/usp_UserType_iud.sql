-- Procedure: usp_UserType_iud






-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-01-26
-- Browsable : true
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserType_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @ERROR_MSG NVARCHAR(MAX)


	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	BEGIN TRY
			-- Process Insert Table
						MERGE STB_UserType AS TargetTable
			USING
				(
					SELECT
							CASE 
								WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
								ELSE XMLData.OldUserType
							END AS OldUserType,
							XMLData.UserType,
							XMLData.UserTypeName,
							XMLData.IsUse,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , '/DataSet/UserTypeList_INSERT' , 2)
							WITH  (
											OldUserType VARCHAR(20),
											 UserType VARCHAR(20),
											 UserTypeName NVARCHAR(50),
											 IsUse BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserTypeName = SourceTable.UserTypeName,
					IsUse = SourceTable.IsUse,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserType,
						UserTypeName,
						IsUse,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.UserType,
							SourceTable.UserTypeName,
							SourceTable.IsUse,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            			MERGE STB_UserType AS TargetTable
			USING
				(
					SELECT
							CASE 
								WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
								ELSE XMLData.OldUserType
							END AS OldUserType,
							XMLData.UserType,
							XMLData.UserTypeName,
							XMLData.IsUse,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , '/DataSet/UserTypeList_UPDATE' , 2)
							WITH  (
											OldUserType VARCHAR(20),
											 UserType VARCHAR(20),
											 UserTypeName NVARCHAR(50),
											 IsUse BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.OldUserType
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserType = SourceTable.UserType,
					UserTypeName = SourceTable.UserTypeName,
					IsUse = SourceTable.IsUse,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserType,
						UserTypeName,
						IsUse,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.UserType,
							SourceTable.UserTypeName,
							SourceTable.IsUse,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_UserType AS TargetTable
			USING
				(
					SELECT
							CASE 
								WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
								ELSE XMLData.OldUserType
							END AS OldUserType,
							XMLData.UserType,
							XMLData.UserTypeName,
							XMLData.IsUse,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , '/DataSet/UserTypeList_DELETE' , 2)
							WITH  (
											OldUserType VARCHAR(20),
											 UserType VARCHAR(20),
											 UserTypeName NVARCHAR(50),
											 IsUse BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.OldUserType
				)

			WHEN MATCHED THEN
				DELETE;

		
		DELETE FROM STB_UserTypeBasicPermission
		FROM
				STB_UserTypeBasicPermission UTBP
				LEFT OUTER JOIN STB_UserType UT
					ON UT.UserType = UTBP.UserType
		WHERE
				UT.UserType IS NULL
		
		DELETE FROM STB_UserTypeViewPermission
		FROM
				STB_UserTypeViewPermission UTVP
				LEFT OUTER JOIN STB_UserType UT
					ON UT.UserType = UTVP.UserType
		WHERE
				UT.UserType IS NULL

		DELETE FROM STB_UserTypeFunctionPermission
		FROM
				STB_UserTypeFunctionPermission UTFP
				LEFT OUTER JOIN STB_UserType UT
					ON UT.UserType = UTFP.UserType
		WHERE
				UT.UserType IS NULL

    END TRY
	BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
		
	EXEC sp_xml_removedocument @idoc
END







GO

