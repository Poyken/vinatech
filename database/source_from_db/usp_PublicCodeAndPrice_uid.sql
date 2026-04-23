-- =============================================
-- Author:		<DinhManh>
-- Create date: <2025-01-16>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PublicCodeAndPrice_uid]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = null,
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
	DECLARE @ID INT
	DECLARE @PublicCode VARCHAR(30)
	DECLARE @Price NUMERIC(15,10)
	DECLARE @IsUsed BIT
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @OnlyImport BIT 


	DECLARE @iDoc INT

		EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		BEGIN TRY
			
			-- Process Insert Table
			MERGE STB_PublicCodeAndPrice AS TargetTable
			USING
				(
					SELECT
						ID,
						PublicCode,
						Price,
						IsUsed,
						WorkCenterCode,
						GETDATE() AS CreateDateTime,
						@pProcessUserID AS CreateUserID,
						GETDATE() AS ChangeDateTime,
						@pProcessUserID AS ChangeUserID,
						OnlyImport
					FROM
						OPENXML(@idoc , @InsertTableName , 2)
						WITH	(
									ID INT,
									PublicCode VARCHAR(30),
									Price NUMERIC(15,10),
									IsUsed BIT,
									WorkCenterCode VARCHAR(20),
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20),
									OnlyImport BIT
								)
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)

			WHEN MATCHED THEN
				UPDATE SET
					PublicCode = ISNULL(SourceTable.PublicCode, TargetTable.PublicCode),
					Price = ISNULL(SourceTable.Price, TargetTable.Price),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode, TargetTable.WorkCenterCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					OnlyImport = ISNULL(SourceTable.OnlyImport, TargetTable.OnlyImport)

			WHEN NOT MATCHED THEN
				INSERT
					(
						PublicCode,
						Price,
						IsUsed,
						WorkCenterCode,
						CreateDateTime,
						CreateUserID,
						OnlyImport
					)
				VALUES
					(
						SourceTable.PublicCode,
						SourceTable.Price,
						SourceTable.IsUsed,
						SourceTable.WorkCenterCode,
						SourceTable.CreateDateTime,
						SourceTable.CreateUserID,
						SourceTable.OnlyImport
					);



			-- Process Update Table
			MERGE STB_PublicCodeAndPrice AS TargetTable
			USING
				(
					SELECT
						ID,
						PublicCode,
						Price,
						IsUsed,
						WorkCenterCode,
						GETDATE() AS CreateDateTime,
						@pProcessUserID AS CreateUserID,
						GETDATE() AS ChangeDateTime,
						@pProcessUserID AS ChangeUserID,
						OnlyImport

					FROM
						OPENXML(@idoc , @UpdateTableName , 2)
						WITH	(
									ID INT,
									PublicCode VARCHAR(30),
									Price NUMERIC(15,10),
									IsUsed BIT,
									WorkCenterCode VARCHAR(20),
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20),
									OnlyImport BIT
								)
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID 
				)
			WHEN MATCHED THEN
				UPDATE SET
					PublicCode = ISNULL(SourceTable.PublicCode, TargetTable.PublicCode),
					Price = ISNULL(SourceTable.Price, TargetTable.Price),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode, TargetTable.WorkCenterCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					OnlyImport = ISNULL(SourceTable.OnlyImport,TargetTable.OnlyImport)

			WHEN NOT MATCHED THEN
				INSERT
					(
						PublicCode,
						Price,
						IsUsed,
						WorkCenterCode,
						CreateDateTime,
						CreateUserID,
						OnlyImport
					)
				VALUES
					(
						SourceTable.PublicCode,
						SourceTable.Price,
						SourceTable.IsUsed,
						SourceTable.WorkCenterCode,
						SourceTable.CreateDateTime,
						SourceTable.CreateUserID,
						SourceTable.OnlyImport
					);



			-- Process Delete Table
			MERGE STB_PublicCodeAndPrice AS TargetTable
			USING
				(
					SELECT
						ID,
						PublicCode,
						Price,
						IsUsed,
						WorkCenterCode,
						GETDATE() AS CreateDateTime,
						@pProcessUserID AS CreateUserID,
						GETDATE() AS ChangeDateTime,
						@pProcessUserID AS ChangeUserID,
						OnlyImport

					FROM
						OPENXML(@idoc , @DeleteTableName , 2)
						WITH	(
									ID INT,
									PublicCode VARCHAR(30),
									Price NUMERIC(15,10),
									IsUsed BIT,
									WorkCenterCode VARCHAR(20),
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20),
									OnlyImport BIT
								)
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
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
