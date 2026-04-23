
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-07-02
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_CustomerComplaintsDefectTypeInfo_iud
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
  DECLARE @OldCustomerComplaintsDefectCode VARCHAR(20)
  DECLARE @CustomerComplaintsDefectCode VARCHAR(20)
  DECLARE @CustomerComplaintsDefectName NVARCHAR(100)
  DECLARE @CustomerComplaintsDefectTypeCode VARCHAR(20)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CustomerComplaintsDefectTypeInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CustomerComplaintsDefectTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerComplaintsDefectCode IS NULL THEN CustomerComplaintsDefectCode
							    ELSE OldCustomerComplaintsDefectCode
							END AS OldCustomerComplaintsDefectCode,
							CustomerComplaintsDefectCode,
							CustomerComplaintsDefectName,
							CustomerComplaintsDefectTypeCode,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCustomerComplaintsDefectCode VARCHAR(20),
										CustomerComplaintsDefectCode VARCHAR(20),
										CustomerComplaintsDefectName NVARCHAR(100),
										CustomerComplaintsDefectTypeCode VARCHAR(20),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerComplaintsDefectCode = SourceTable.CustomerComplaintsDefectCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CustomerComplaintsDefectCode = ISNULL(SourceTable.CustomerComplaintsDefectCode,TargetTable.CustomerComplaintsDefectCode),
					CustomerComplaintsDefectName = ISNULL(SourceTable.CustomerComplaintsDefectName,TargetTable.CustomerComplaintsDefectName),
					CustomerComplaintsDefectTypeCode = ISNULL(SourceTable.CustomerComplaintsDefectTypeCode,TargetTable.CustomerComplaintsDefectTypeCode),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CustomerComplaintsDefectCode,
						CustomerComplaintsDefectName,
						CustomerComplaintsDefectTypeCode,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CustomerComplaintsDefectCode,
							SourceTable.CustomerComplaintsDefectName,
							SourceTable.CustomerComplaintsDefectTypeCode,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CustomerComplaintsDefectTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerComplaintsDefectCode IS NULL THEN CustomerComplaintsDefectCode
							    ELSE OldCustomerComplaintsDefectCode
							END AS OldCustomerComplaintsDefectCode,
							CustomerComplaintsDefectCode,
							CustomerComplaintsDefectName,
							CustomerComplaintsDefectTypeCode,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCustomerComplaintsDefectCode VARCHAR(20),
										CustomerComplaintsDefectCode VARCHAR(20),
										CustomerComplaintsDefectName NVARCHAR(100),
										CustomerComplaintsDefectTypeCode VARCHAR(20),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerComplaintsDefectCode = SourceTable.OldCustomerComplaintsDefectCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CustomerComplaintsDefectCode = ISNULL(SourceTable.CustomerComplaintsDefectCode,TargetTable.CustomerComplaintsDefectCode),
					CustomerComplaintsDefectName = ISNULL(SourceTable.CustomerComplaintsDefectName,TargetTable.CustomerComplaintsDefectName),
					CustomerComplaintsDefectTypeCode = ISNULL(SourceTable.CustomerComplaintsDefectTypeCode,TargetTable.CustomerComplaintsDefectTypeCode),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CustomerComplaintsDefectCode,
						CustomerComplaintsDefectName,
						CustomerComplaintsDefectTypeCode,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CustomerComplaintsDefectCode,
							SourceTable.CustomerComplaintsDefectName,
							SourceTable.CustomerComplaintsDefectTypeCode,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CustomerComplaintsDefectTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerComplaintsDefectCode IS NULL THEN CustomerComplaintsDefectCode
							    ELSE OldCustomerComplaintsDefectCode
							END AS OldCustomerComplaintsDefectCode,
							CustomerComplaintsDefectCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCustomerComplaintsDefectCode VARCHAR(20),
										CustomerComplaintsDefectCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerComplaintsDefectCode = SourceTable.CustomerComplaintsDefectCode
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
