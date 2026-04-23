-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-08-11
-- Browsable : true
-- Group : 도면관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_MEAClassInfo_iud
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
  DECLARE @MEAClassCode VARCHAR(20)
  DECLARE @MEAClassName NVARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MEAClassInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MEAClassInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMEAClassCode IS NULL THEN MEAClassCode
							    ELSE OldMEAClassCode
							END AS OldMEAClassCode,
							MEAClassCode,
							MEAClassName,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMEAClassCode VARCHAR(20),
										MEAClassCode VARCHAR(20),
										MEAClassName NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MEAClassCode = SourceTable.MEAClassCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MEAClassCode = ISNULL(SourceTable.MEAClassCode,TargetTable.MEAClassCode),
					MEAClassName = ISNULL(SourceTable.MEAClassName,TargetTable.MEAClassName),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MEAClassCode,
						MEAClassName,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MEAClassCode,
							SourceTable.MEAClassName,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MEAClassInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMEAClassCode IS NULL THEN MEAClassCode
							    ELSE OldMEAClassCode
							END AS OldMEAClassCode,
							MEAClassCode,
							MEAClassName,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMEAClassCode VARCHAR(20),
										MEAClassCode VARCHAR(20),
										MEAClassName NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MEAClassCode = SourceTable.OldMEAClassCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MEAClassCode = ISNULL(SourceTable.MEAClassCode,TargetTable.MEAClassCode),
					MEAClassName = ISNULL(SourceTable.MEAClassName,TargetTable.MEAClassName),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MEAClassCode,
						MEAClassName,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MEAClassCode,
							SourceTable.MEAClassName,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MEAClassInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMEAClassCode IS NULL THEN MEAClassCode
							    ELSE OldMEAClassCode
							END AS OldMEAClassCode,
							MEAClassCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMEAClassCode VARCHAR(20),
										MEAClassCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MEAClassCode = SourceTable.MEAClassCode
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