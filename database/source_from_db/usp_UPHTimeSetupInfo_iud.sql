-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-06-18
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_UPHTimeSetupInfo_iud
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
  DECLARE @OldBaseDate DATE
  DECLARE @OldUPHItemCode VARCHAR(20)
  DECLARE @OldMachineCode VARCHAR(20)
  DECLARE @BaseDate DATE
  DECLARE @UPHItemCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @DayWorkTime NUMERIC(20,5)
  DECLARE @RequiredTime NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_UPHTimeSetupInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_UPHTimeSetupInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBaseDate IS NULL THEN BaseDate
							    ELSE OldBaseDate
							END AS OldBaseDate,
							CASE
							    WHEN OldUPHItemCode IS NULL THEN UPHItemCode
							    ELSE OldUPHItemCode
							END AS OldUPHItemCode,
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							BaseDate,
							UPHItemCode,
							MachineCode,
							LineCode,
							DayWorkTime,
							RequiredTime,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldBaseDate DATETIMEOFFSET,
										OldUPHItemCode VARCHAR(20),
										OldMachineCode VARCHAR(20),
										BaseDate DATETIMEOFFSET,
										UPHItemCode VARCHAR(20),
										MachineCode VARCHAR(20),
										LineCode VARCHAR(20),
										DayWorkTime NUMERIC(20,5),
										RequiredTime NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					CONVERT(VARCHAR(10), TargetTable.BaseDate, 121) = CONVERT(VARCHAR(10), SourceTable.BaseDate, 121) AND
					TargetTable.UPHItemCode = SourceTable.UPHItemCode AND
					TargetTable.MachineCode = SourceTable.MachineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					BaseDate = ISNULL(SourceTable.BaseDate,TargetTable.BaseDate),
					UPHItemCode = ISNULL(SourceTable.UPHItemCode,TargetTable.UPHItemCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					DayWorkTime = ISNULL(SourceTable.DayWorkTime,TargetTable.DayWorkTime),
					RequiredTime = ISNULL(SourceTable.RequiredTime,TargetTable.RequiredTime),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						BaseDate,
						UPHItemCode,
						MachineCode,
						LineCode,
						DayWorkTime,
						RequiredTime,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.BaseDate,
							SourceTable.UPHItemCode,
							SourceTable.MachineCode,
							SourceTable.LineCode,
							SourceTable.DayWorkTime,
							SourceTable.RequiredTime,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_UPHTimeSetupInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBaseDate IS NULL THEN BaseDate
							    ELSE OldBaseDate
							END AS OldBaseDate,
							CASE
							    WHEN OldUPHItemCode IS NULL THEN UPHItemCode
							    ELSE OldUPHItemCode
							END AS OldUPHItemCode,
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							BaseDate,
							UPHItemCode,
							MachineCode,
							LineCode,
							DayWorkTime,
							RequiredTime,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldBaseDate DATETIMEOFFSET,
										OldUPHItemCode VARCHAR(20),
										OldMachineCode VARCHAR(20),
										BaseDate DATETIMEOFFSET,
										UPHItemCode VARCHAR(20),
										MachineCode VARCHAR(20),
										LineCode VARCHAR(20),
										DayWorkTime NUMERIC(20,5),
										RequiredTime NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					CONVERT(VARCHAR(10), TargetTable.BaseDate, 121) = CONVERT(VARCHAR(10), SourceTable.OldBaseDate, 121) AND
					TargetTable.UPHItemCode = SourceTable.OldUPHItemCode AND
					TargetTable.MachineCode = SourceTable.OldMachineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					BaseDate = ISNULL(SourceTable.BaseDate,TargetTable.BaseDate),
					UPHItemCode = ISNULL(SourceTable.UPHItemCode,TargetTable.UPHItemCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					RequiredTime = ISNULL(SourceTable.RequiredTime,TargetTable.RequiredTime),
					DayWorkTime = ISNULL(SourceTable.DayWorkTime,TargetTable.DayWorkTime),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						BaseDate,
						UPHItemCode,
						MachineCode,
						LineCode,
						DayWorkTime,
						RequiredTime,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.BaseDate,
							SourceTable.UPHItemCode,
							SourceTable.MachineCode,
							SourceTable.LineCode,
							SourceTable.DayWorkTime,
							SourceTable.RequiredTime,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_UPHTimeSetupInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBaseDate IS NULL THEN BaseDate
							    ELSE OldBaseDate
							END AS OldBaseDate,
							CASE
							    WHEN OldUPHItemCode IS NULL THEN UPHItemCode
							    ELSE OldUPHItemCode
							END AS OldUPHItemCode,
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							BaseDate,
							UPHItemCode,
							MachineCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldBaseDate DATETIMEOFFSET,
										OldUPHItemCode VARCHAR(20),
										OldMachineCode VARCHAR(20),
										BaseDate DATETIMEOFFSET,
										UPHItemCode VARCHAR(20),
										MachineCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					CONVERT(VARCHAR(10), TargetTable.BaseDate, 121) = CONVERT(VARCHAR(10), SourceTable.BaseDate, 121) AND
					TargetTable.UPHItemCode = SourceTable.UPHItemCode AND
					TargetTable.MachineCode = SourceTable.MachineCode
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