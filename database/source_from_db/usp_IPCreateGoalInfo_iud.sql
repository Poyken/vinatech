
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-04-22
-- Browsable : true
-- Group : 인사관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_IPCreateGoalInfo_iud
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
  DECLARE @OldEmployeeNo VARCHAR(20)
  DECLARE @OldIPClassCode VARCHAR(20)
  DECLARE @OldBaseYear VARCHAR(4)
  DECLARE @EmployeeNo VARCHAR(20)
  DECLARE @IPClassCode VARCHAR(20)
  DECLARE @TargetQty INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @BaseYear VARCHAR(4)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_IPCreateGoalInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_IPCreateGoalInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldEmployeeNo IS NULL THEN EmployeeNo
							    ELSE OldEmployeeNo
							END AS OldEmployeeNo,
							CASE
							    WHEN OldIPClassCode IS NULL THEN IPClassCode
							    ELSE OldIPClassCode
							END AS OldIPClassCode,
							CASE
							    WHEN OldBaseYear IS NULL THEN BaseYear
							    ELSE OldBaseYear
							END AS OldBaseYear,
							EmployeeNo,
							IPClassCode,
							TargetQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							BaseYear
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldEmployeeNo VARCHAR(20),
										OldIPClassCode VARCHAR(20),
										OldBaseYear VARCHAR(4),
										EmployeeNo VARCHAR(20),
										IPClassCode VARCHAR(20),
										TargetQty INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										BaseYear VARCHAR(4)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.EmployeeNo = SourceTable.EmployeeNo AND
					TargetTable.IPClassCode = SourceTable.IPClassCode AND
					TargetTable.BaseYear = SourceTable.BaseYear
				)

			WHEN MATCHED THEN
				UPDATE SET
					EmployeeNo = ISNULL(SourceTable.EmployeeNo,TargetTable.EmployeeNo),
					IPClassCode = ISNULL(SourceTable.IPClassCode,TargetTable.IPClassCode),
					TargetQty = ISNULL(SourceTable.TargetQty,TargetTable.TargetQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					BaseYear = ISNULL(SourceTable.BaseYear,TargetTable.BaseYear)
			WHEN NOT MATCHED THEN
				INSERT
					(
						EmployeeNo,
						IPClassCode,
						TargetQty,
						CreateDateTime,
						CreateUserID,
						BaseYear
					)
				VALUES
					(
							SourceTable.EmployeeNo,
							SourceTable.IPClassCode,
							SourceTable.TargetQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.BaseYear
					);


			-- Process Update Table
            MERGE STB_IPCreateGoalInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldEmployeeNo IS NULL THEN EmployeeNo
							    ELSE OldEmployeeNo
							END AS OldEmployeeNo,
							CASE
							    WHEN OldIPClassCode IS NULL THEN IPClassCode
							    ELSE OldIPClassCode
							END AS OldIPClassCode,
							CASE
							    WHEN OldBaseYear IS NULL THEN BaseYear
							    ELSE OldBaseYear
							END AS OldBaseYear,
							EmployeeNo,
							IPClassCode,
							TargetQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							BaseYear
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldEmployeeNo VARCHAR(20),
										OldIPClassCode VARCHAR(20),
										OldBaseYear VARCHAR(4),
										EmployeeNo VARCHAR(20),
										IPClassCode VARCHAR(20),
										TargetQty INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										BaseYear VARCHAR(4)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.EmployeeNo = SourceTable.OldEmployeeNo AND
					TargetTable.IPClassCode = SourceTable.OldIPClassCode AND
					TargetTable.BaseYear = SourceTable.OldBaseYear
				)

			WHEN MATCHED THEN
				UPDATE SET
					EmployeeNo = ISNULL(SourceTable.EmployeeNo,TargetTable.EmployeeNo),
					IPClassCode = ISNULL(SourceTable.IPClassCode,TargetTable.IPClassCode),
					TargetQty = ISNULL(SourceTable.TargetQty,TargetTable.TargetQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					BaseYear = ISNULL(SourceTable.BaseYear,TargetTable.BaseYear)
			WHEN NOT MATCHED THEN
				INSERT
					(
						EmployeeNo,
						IPClassCode,
						TargetQty,
						CreateDateTime,
						CreateUserID,
						BaseYear
					)
				VALUES
					(
							SourceTable.EmployeeNo,
							SourceTable.IPClassCode,
							SourceTable.TargetQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.BaseYear
					);


			-- Process Delete Table
            MERGE STB_IPCreateGoalInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldEmployeeNo IS NULL THEN EmployeeNo
							    ELSE OldEmployeeNo
							END AS OldEmployeeNo,
							CASE
							    WHEN OldIPClassCode IS NULL THEN IPClassCode
							    ELSE OldIPClassCode
							END AS OldIPClassCode,
							CASE
							    WHEN OldBaseYear IS NULL THEN BaseYear
							    ELSE OldBaseYear
							END AS OldBaseYear,
							EmployeeNo,
							IPClassCode,
							BaseYear
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldEmployeeNo VARCHAR(20),
										OldIPClassCode VARCHAR(20),
										OldBaseYear VARCHAR(4),
										EmployeeNo VARCHAR(20),
										IPClassCode VARCHAR(20),
										BaseYear VARCHAR(4)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.EmployeeNo = SourceTable.EmployeeNo AND
					TargetTable.IPClassCode = SourceTable.IPClassCode AND
					TargetTable.BaseYear = SourceTable.BaseYear
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
