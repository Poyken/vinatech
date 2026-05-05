-- Procedure: usp_UserTypeFunctionPermission_iud_old






-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-01-26
-- Browsable : true
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserTypeFunctionPermission_iud_old]
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
						MERGE STB_UserTypeFunctionPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.FunctionName,
							XMLData.Allow
					FROM
							OPENXML(@idoc , '/DataSet/FunctionList_INSERT' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 FunctionName VARCHAR(50),
											 Allow BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name AND
					TargetTable.FunctionName = SourceTable.FunctionName
				)

			WHEN MATCHED THEN
				UPDATE SET
					Allow = SourceTable.Allow
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
							SourceTable.UserType,
							SourceTable.Name,
							SourceTable.FunctionName,
							SourceTable.Allow
					);


			-- Process Update Table
            			MERGE STB_UserTypeFunctionPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.FunctionName,
							XMLData.Allow
					FROM
							OPENXML(@idoc , '/DataSet/FunctionList_UPDATE' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 FunctionName VARCHAR(50),
											 Allow BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name AND
					TargetTable.FunctionName = SourceTable.FunctionName
				)

			WHEN MATCHED THEN
				UPDATE SET
					Allow = SourceTable.Allow
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
							SourceTable.UserType,
							SourceTable.Name,
							SourceTable.FunctionName,
							SourceTable.Allow
					);


			-- Process Delete Table
            			MERGE STB_UserTypeFunctionPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.FunctionName,
							XMLData.Allow
					FROM
							OPENXML(@idoc , '/DataSet/FunctionList_DELETE' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 FunctionName VARCHAR(50),
											 Allow BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name AND
					TargetTable.FunctionName = SourceTable.FunctionName
				)

			WHEN MATCHED THEN
				DELETE;

    END TRY
	BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
		
	EXEC sp_xml_removedocument @idoc
END







GO

