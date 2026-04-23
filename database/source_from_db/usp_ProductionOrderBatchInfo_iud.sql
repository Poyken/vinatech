-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-02-27
-- Browsable : true
-- Group : 지지체
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_ProductionOrderBatchInfo_iud
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
  DECLARE @OldParentMaterialCode VARCHAR(20)
  DECLARE @OldTargetMaterialCode VARCHAR(20)
  DECLARE @ParentMaterialCode VARCHAR(20)
  DECLARE @TargetMaterialCode VARCHAR(20)
  DECLARE @OrderRate NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ProductionOrderBatchInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ProductionOrderBatchInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldParentMaterialCode IS NULL THEN ParentMaterialCode
							    ELSE OldParentMaterialCode
							END AS OldParentMaterialCode,
							CASE
							    WHEN OldTargetMaterialCode IS NULL THEN TargetMaterialCode
							    ELSE OldTargetMaterialCode
							END AS OldTargetMaterialCode,
							ParentMaterialCode,
							TargetMaterialCode,
							OrderRate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldParentMaterialCode VARCHAR(20),
										OldTargetMaterialCode VARCHAR(20),
										ParentMaterialCode VARCHAR(20),
										TargetMaterialCode VARCHAR(20),
										OrderRate NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ParentMaterialCode = SourceTable.ParentMaterialCode AND
					TargetTable.TargetMaterialCode = SourceTable.TargetMaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ParentMaterialCode = ISNULL(SourceTable.ParentMaterialCode,TargetTable.ParentMaterialCode),
					TargetMaterialCode = ISNULL(SourceTable.TargetMaterialCode,TargetTable.TargetMaterialCode),
					OrderRate = ISNULL(SourceTable.OrderRate,TargetTable.OrderRate),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ParentMaterialCode,
						TargetMaterialCode,
						OrderRate,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ParentMaterialCode,
							SourceTable.TargetMaterialCode,
							SourceTable.OrderRate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ProductionOrderBatchInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldParentMaterialCode IS NULL THEN ParentMaterialCode
							    ELSE OldParentMaterialCode
							END AS OldParentMaterialCode,
							CASE
							    WHEN OldTargetMaterialCode IS NULL THEN TargetMaterialCode
							    ELSE OldTargetMaterialCode
							END AS OldTargetMaterialCode,
							ParentMaterialCode,
							TargetMaterialCode,
							OrderRate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldParentMaterialCode VARCHAR(20),
										OldTargetMaterialCode VARCHAR(20),
										ParentMaterialCode VARCHAR(20),
										TargetMaterialCode VARCHAR(20),
										OrderRate NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ParentMaterialCode = SourceTable.OldParentMaterialCode AND
					TargetTable.TargetMaterialCode = SourceTable.OldTargetMaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ParentMaterialCode = ISNULL(SourceTable.ParentMaterialCode,TargetTable.ParentMaterialCode),
					TargetMaterialCode = ISNULL(SourceTable.TargetMaterialCode,TargetTable.TargetMaterialCode),
					OrderRate = ISNULL(SourceTable.OrderRate,TargetTable.OrderRate),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ParentMaterialCode,
						TargetMaterialCode,
						OrderRate,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ParentMaterialCode,
							SourceTable.TargetMaterialCode,
							SourceTable.OrderRate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ProductionOrderBatchInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldParentMaterialCode IS NULL THEN ParentMaterialCode
							    ELSE OldParentMaterialCode
							END AS OldParentMaterialCode,
							CASE
							    WHEN OldTargetMaterialCode IS NULL THEN TargetMaterialCode
							    ELSE OldTargetMaterialCode
							END AS OldTargetMaterialCode,
							ParentMaterialCode,
							TargetMaterialCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldParentMaterialCode VARCHAR(20),
										OldTargetMaterialCode VARCHAR(20),
										ParentMaterialCode VARCHAR(20),
										TargetMaterialCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ParentMaterialCode = SourceTable.ParentMaterialCode AND
					TargetTable.TargetMaterialCode = SourceTable.TargetMaterialCode
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
