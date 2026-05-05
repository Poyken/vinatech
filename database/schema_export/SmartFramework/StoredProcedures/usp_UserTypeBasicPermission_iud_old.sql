-- Procedure: usp_UserTypeBasicPermission_iud_old






-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-01-26
-- Browsable : true
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserTypeBasicPermission_iud_old]
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
						MERGE STB_UserTypeBasicPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.AllowView,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete
					FROM
							OPENXML(@idoc , '/DataSet/MenuList_INSERT' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 AllowView BIT,
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					AllowView = SourceTable.AllowView,
					AllowAdd = SourceTable.AllowAdd,
					AllowModify = SourceTable.AllowModify,
					AllowDelete = SourceTable.AllowDelete
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserType,
						Name,
						AllowView,
						AllowAdd,
						AllowModify,
						AllowDelete
					)
				VALUES
					(
							SourceTable.UserType,
							SourceTable.Name,
							SourceTable.AllowView,
							SourceTable.AllowAdd,
							SourceTable.AllowModify,
							SourceTable.AllowDelete
					);


			-- Process Update Table
            			MERGE STB_UserTypeBasicPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.AllowView,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete
					FROM
							OPENXML(@idoc , '/DataSet/MenuList_UPDATE' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 AllowView BIT,
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					AllowView = SourceTable.AllowView,
					AllowAdd = SourceTable.AllowAdd,
					AllowModify = SourceTable.AllowModify,
					AllowDelete = SourceTable.AllowDelete
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserType,
						Name,
						AllowView,
						AllowAdd,
						AllowModify,
						AllowDelete
					)
				VALUES
					(
							SourceTable.UserType,
							SourceTable.Name,
							SourceTable.AllowView,
							SourceTable.AllowAdd,
							SourceTable.AllowModify,
							SourceTable.AllowDelete
					);


			-- Process Delete Table
            			MERGE STB_UserTypeBasicPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.AllowView,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete
					FROM
							OPENXML(@idoc , '/DataSet/MenuList_DELETE' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 AllowView BIT,
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name
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

