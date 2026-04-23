-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-08-11
-- Browsable : true
-- Group : 도면관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_MEARawMaterialInfo_iud
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
  DECLARE @OldMEAClassCode VARCHAR(20)
  DECLARE @OldMEARawMaterialClassCode VARCHAR(20)
  DECLARE @OldMEARawMaterialCode VARCHAR(20)
  DECLARE @MEAClassCode VARCHAR(20)
  DECLARE @MEARawMaterialClassCode VARCHAR(20)
  DECLARE @MEARawMaterialCode VARCHAR(20)
  DECLARE @MEARawMaterialName NVARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MEARawMaterialInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MEARawMaterialInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMEAClassCode IS NULL THEN MEAClassCode
							    ELSE OldMEAClassCode
							END AS OldMEAClassCode,
							CASE
							    WHEN OldMEARawMaterialClassCode IS NULL THEN MEARawMaterialClassCode
							    ELSE OldMEARawMaterialClassCode
							END AS OldMEARawMaterialClassCode,
							CASE
							    WHEN OldMEARawMaterialCode IS NULL THEN MEARawMaterialCode
							    ELSE OldMEARawMaterialCode
							END AS OldMEARawMaterialCode,
							MEAClassCode,
							MEARawMaterialClassCode,
							MEARawMaterialCode,
							MEARawMaterialName,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMEAClassCode VARCHAR(20),
										OldMEARawMaterialClassCode VARCHAR(20),
										OldMEARawMaterialCode VARCHAR(20),
										MEAClassCode VARCHAR(20),
										MEARawMaterialClassCode VARCHAR(20),
										MEARawMaterialCode VARCHAR(20),
										MEARawMaterialName NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MEAClassCode = SourceTable.MEAClassCode AND
					TargetTable.MEARawMaterialClassCode = SourceTable.MEARawMaterialClassCode AND
					TargetTable.MEARawMaterialCode = SourceTable.MEARawMaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MEAClassCode = ISNULL(SourceTable.MEAClassCode,TargetTable.MEAClassCode),
					MEARawMaterialClassCode = ISNULL(SourceTable.MEARawMaterialClassCode,TargetTable.MEARawMaterialClassCode),
					MEARawMaterialCode = ISNULL(SourceTable.MEARawMaterialCode,TargetTable.MEARawMaterialCode),
					MEARawMaterialName = ISNULL(SourceTable.MEARawMaterialName,TargetTable.MEARawMaterialName),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MEAClassCode,
						MEARawMaterialClassCode,
						MEARawMaterialCode,
						MEARawMaterialName,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MEAClassCode,
							SourceTable.MEARawMaterialClassCode,
							SourceTable.MEARawMaterialCode,
							SourceTable.MEARawMaterialName,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MEARawMaterialInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMEAClassCode IS NULL THEN MEAClassCode
							    ELSE OldMEAClassCode
							END AS OldMEAClassCode,
							CASE
							    WHEN OldMEARawMaterialClassCode IS NULL THEN MEARawMaterialClassCode
							    ELSE OldMEARawMaterialClassCode
							END AS OldMEARawMaterialClassCode,
							CASE
							    WHEN OldMEARawMaterialCode IS NULL THEN MEARawMaterialCode
							    ELSE OldMEARawMaterialCode
							END AS OldMEARawMaterialCode,
							MEAClassCode,
							MEARawMaterialClassCode,
							MEARawMaterialCode,
							MEARawMaterialName,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMEAClassCode VARCHAR(20),
										OldMEARawMaterialClassCode VARCHAR(20),
										OldMEARawMaterialCode VARCHAR(20),
										MEAClassCode VARCHAR(20),
										MEARawMaterialClassCode VARCHAR(20),
										MEARawMaterialCode VARCHAR(20),
										MEARawMaterialName NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MEAClassCode = SourceTable.OldMEAClassCode AND
					TargetTable.MEARawMaterialClassCode = SourceTable.OldMEARawMaterialClassCode AND
					TargetTable.MEARawMaterialCode = SourceTable.OldMEARawMaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MEAClassCode = ISNULL(SourceTable.MEAClassCode,TargetTable.MEAClassCode),
					MEARawMaterialClassCode = ISNULL(SourceTable.MEARawMaterialClassCode,TargetTable.MEARawMaterialClassCode),
					MEARawMaterialCode = ISNULL(SourceTable.MEARawMaterialCode,TargetTable.MEARawMaterialCode),
					MEARawMaterialName = ISNULL(SourceTable.MEARawMaterialName,TargetTable.MEARawMaterialName),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MEAClassCode,
						MEARawMaterialClassCode,
						MEARawMaterialCode,
						MEARawMaterialName,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MEAClassCode,
							SourceTable.MEARawMaterialClassCode,
							SourceTable.MEARawMaterialCode,
							SourceTable.MEARawMaterialName,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MEARawMaterialInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMEAClassCode IS NULL THEN MEAClassCode
							    ELSE OldMEAClassCode
							END AS OldMEAClassCode,
							CASE
							    WHEN OldMEARawMaterialClassCode IS NULL THEN MEARawMaterialClassCode
							    ELSE OldMEARawMaterialClassCode
							END AS OldMEARawMaterialClassCode,
							CASE
							    WHEN OldMEARawMaterialCode IS NULL THEN MEARawMaterialCode
							    ELSE OldMEARawMaterialCode
							END AS OldMEARawMaterialCode,
							MEAClassCode,
							MEARawMaterialClassCode,
							MEARawMaterialCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMEAClassCode VARCHAR(20),
										OldMEARawMaterialClassCode VARCHAR(20),
										OldMEARawMaterialCode VARCHAR(20),
										MEAClassCode VARCHAR(20),
										MEARawMaterialClassCode VARCHAR(20),
										MEARawMaterialCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MEAClassCode = SourceTable.MEAClassCode AND
					TargetTable.MEARawMaterialClassCode = SourceTable.MEARawMaterialClassCode AND
					TargetTable.MEARawMaterialCode = SourceTable.MEARawMaterialCode
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
