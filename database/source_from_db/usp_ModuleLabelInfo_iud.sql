-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-01-30
-- Browsable : true
-- Group : 모듈관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModuleLabelInfo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

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
  DECLARE @OldModuleSerialNo VARCHAR(20)
  DECLARE @ModuleSerialNo VARCHAR(20)
  DECLARE @ProductNo VARCHAR(20)
  DECLARE @RevisionNo VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModuleLabelInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ModuleLabelInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModuleSerialNo IS NULL THEN ModuleSerialNo
							    ELSE OldModuleSerialNo
							END AS OldModuleSerialNo,
							ModuleSerialNo,
							ProductNo,
							RevisionNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							SingleLotNo
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldModuleSerialNo VARCHAR(20),
										ModuleSerialNo VARCHAR(20),
										ProductNo VARCHAR(20),
										RevisionNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										SingleLotNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModuleSerialNo = SourceTable.ModuleSerialNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					ModuleSerialNo = ISNULL(SourceTable.ModuleSerialNo,TargetTable.ModuleSerialNo),
					ProductNo = ISNULL(SourceTable.ProductNo,TargetTable.ProductNo),
					RevisionNo = ISNULL(SourceTable.RevisionNo,TargetTable.RevisionNo),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					SingleLotNo = ISNULL(SourceTable.SingleLotNo,TargetTable.SingleLotNo)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ModuleSerialNo,
						ProductNo,
						RevisionNo,
						CreateDateTime,
						CreateUserID,
						SingleLotNo
					)
				VALUES
					(
							SourceTable.ModuleSerialNo,
							SourceTable.ProductNo,
							SourceTable.RevisionNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.SingleLotNo
					);


			-- Process Update Table
            MERGE STB_ModuleLabelInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModuleSerialNo IS NULL THEN ModuleSerialNo
							    ELSE OldModuleSerialNo
							END AS OldModuleSerialNo,
							ModuleSerialNo,
							ProductNo,
							RevisionNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							SingleLotNo
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldModuleSerialNo VARCHAR(20),
										ModuleSerialNo VARCHAR(20),
										ProductNo VARCHAR(20),
										RevisionNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										SingleLotNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModuleSerialNo = SourceTable.OldModuleSerialNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					ModuleSerialNo = ISNULL(SourceTable.ModuleSerialNo,TargetTable.ModuleSerialNo),
					ProductNo = ISNULL(SourceTable.ProductNo,TargetTable.ProductNo),
					RevisionNo = ISNULL(SourceTable.RevisionNo,TargetTable.RevisionNo),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					SingleLotNo = ISNULL(SourceTable.SingleLotNo,TargetTable.SingleLotNo)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ModuleSerialNo,
						ProductNo,
						RevisionNo,
						CreateDateTime,
						CreateUserID,
						SingleLotNo
					)
				VALUES
					(
							SourceTable.ModuleSerialNo,
							SourceTable.ProductNo,
							SourceTable.RevisionNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.SingleLotNo
					);


			-- Process Delete Table
            MERGE STB_ModuleLabelInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModuleSerialNo IS NULL THEN ModuleSerialNo
							    ELSE OldModuleSerialNo
							END AS OldModuleSerialNo,
							ModuleSerialNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldModuleSerialNo VARCHAR(20),
										ModuleSerialNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModuleSerialNo = SourceTable.ModuleSerialNo
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        PRINT 'Loop was removed'
    END
END
