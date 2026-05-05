-- Procedure: usp_UserTypeViewPermission_iud_old






-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-01-26
-- Browsable : true
-- Description:	
-- Modified By PJS : View 의 Support 속성에 따라 권한 무효화
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserTypeViewPermission_iud_old]
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
			MERGE STB_UserTypeViewPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.ViewName,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete,
							XMLData.AllowExcel,
							XMLData.AllowImport
					FROM
							OPENXML(@idoc , '/DataSet/ViewList_INSERT' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 ViewName VARCHAR(50),
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT,
											 AllowExcel BIT,
											 AllowImport BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name AND
					TargetTable.ViewName = SourceTable.ViewName
				)

			WHEN MATCHED THEN
				UPDATE SET
					AllowAdd = SourceTable.AllowAdd,
					AllowModify = SourceTable.AllowModify,
					AllowDelete = SourceTable.AllowDelete,
					AllowExcel = SourceTable.AllowExcel,
					AllowImport = SourceTable.AllowImport
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
							SourceTable.UserType,
							SourceTable.Name,
							SourceTable.ViewName,
							SourceTable.AllowAdd,
							SourceTable.AllowModify,
							SourceTable.AllowDelete,
							SourceTable.AllowExcel,
							SourceTable.AllowImport
					);


			-- Process Update Table
            			MERGE STB_UserTypeViewPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.ViewName,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete,
							XMLData.AllowExcel,
							XMLData.AllowImport
					FROM
							OPENXML(@idoc , '/DataSet/ViewList_UPDATE' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 ViewName VARCHAR(50),
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT,
											 AllowExcel BIT,
											 AllowImport BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name AND
					TargetTable.ViewName = SourceTable.ViewName
				)

			WHEN MATCHED THEN
				UPDATE SET
					AllowAdd = SourceTable.AllowAdd,
					AllowModify = SourceTable.AllowModify,
					AllowDelete = SourceTable.AllowDelete,
					AllowExcel = SourceTable.AllowExcel,
					AllowImport = SourceTable.AllowImport
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
							SourceTable.UserType,
							SourceTable.Name,
							SourceTable.ViewName,
							SourceTable.AllowAdd,
							SourceTable.AllowModify,
							SourceTable.AllowDelete,
							SourceTable.AllowExcel,
							SourceTable.AllowImport
					);


			-- Process Delete Table
            			MERGE STB_UserTypeViewPermission AS TargetTable
			USING
				(
					SELECT
							XMLData.UserType,
							XMLData.Name,
							XMLData.ViewName,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete,
							XMLData.AllowExcel,
							XMLData.AllowImport
					FROM
							OPENXML(@idoc , '/DataSet/ViewList_DELETE' , 2)
							WITH  (
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 ViewName VARCHAR(50),
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT,
											 AllowExcel BIT,
											 AllowImport BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name AND
					TargetTable.ViewName = SourceTable.ViewName
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

