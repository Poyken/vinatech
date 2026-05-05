-- Procedure: usp_CheckStandardInfo_iud

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-07-29
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckStandardInfo_iud]
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
  DECLARE @OldCheckStandardNo VARCHAR(20)
  DECLARE @CheckStandardNo VARCHAR(20)
  DECLARE @CheckClassNo VARCHAR(10)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @CheckPartNo VARCHAR(20)
  DECLARE @CheckPartPicture1 VARBINARY(MAX)
  DECLARE @CheckPartPicture2 VARBINARY(MAX)
  DECLARE @CheckPartPicture3 VARBINARY(MAX)
  DECLARE @CheckPartPicture4 VARBINARY(MAX)
  DECLARE @CheckPartPicture5 VARBINARY(MAX)
  DECLARE @RelationshipContent VARCHAR(MAX)
  DECLARE @CheckPartContent VARCHAR(1000)
  DECLARE @CheckStandard VARCHAR(1000)
  DECLARE @CheckMethod VARCHAR(1000)
  DECLARE @CheckRepeatCycleCode VARCHAR(20)
  DECLARE @CheckStartDate DATETIME
  DECLARE @CheckTime DATETIME
  DECLARE @CheckDateOption VARCHAR(10)
  DECLARE @DayOfWeekCode INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @IsUsed BIT
  DECLARE @ScheduleChangeCheck INT
  DECLARE @ImageReferenceNo VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CheckStandardInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CheckStandardInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckStandardNo IS NULL THEN CheckStandardNo
							    ELSE OldCheckStandardNo
							END AS OldCheckStandardNo,
							CheckStandardNo,
							CheckClassNo,
							LineCode,
							MachineCode,
							CheckPartNo,
							dbo.fnBase64ToBinary(CheckPartPicture1) as CheckPartPicture1,
							dbo.fnBase64ToBinary(CheckPartPicture2) as CheckPartPicture2,
							dbo.fnBase64ToBinary(CheckPartPicture3) as CheckPartPicture3,
							dbo.fnBase64ToBinary(CheckPartPicture4) as CheckPartPicture4,
							dbo.fnBase64ToBinary(CheckPartPicture5) as CheckPartPicture5,
							RelationshipContent,
							CheckPartContent,
							CheckStandard,
							CheckMethod,
							CheckRepeatCycleCode,
							CheckStartDate,
							CheckTime,
							CheckDateOption,
							DayOfWeekCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCheckStandardNo VARCHAR(20),
										CheckStandardNo VARCHAR(20),
										CheckClassNo VARCHAR(10),
										LineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										CheckPartNo VARCHAR(20),
										CheckPartPicture1 NVARCHAR(MAX),
										CheckPartPicture2 NVARCHAR(MAX),
										CheckPartPicture3 NVARCHAR(MAX),
										CheckPartPicture4 NVARCHAR(MAX),
										CheckPartPicture5 NVARCHAR(MAX),
										RelationshipContent VARCHAR(MAX),
										CheckPartContent VARCHAR(1000),
										CheckStandard VARCHAR(1000),
										CheckMethod VARCHAR(1000),
										CheckRepeatCycleCode VARCHAR(20),
										CheckStartDate DATETIMEOFFSET,
										CheckTime DATETIMEOFFSET,
										CheckDateOption VARCHAR(10),
										DayOfWeekCode INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckStandardNo = SourceTable.CheckStandardNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CheckClassNo = ISNULL(SourceTable.CheckClassNo,TargetTable.CheckClassNo),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					CheckPartNo = ISNULL(SourceTable.CheckPartNo,TargetTable.CheckPartNo),
					CheckPartPicture1 = ISNULL(SourceTable.CheckPartPicture1,TargetTable.CheckPartPicture1),
					CheckPartPicture2 = ISNULL(SourceTable.CheckPartPicture2,TargetTable.CheckPartPicture2),
					CheckPartPicture3 = ISNULL(SourceTable.CheckPartPicture3,TargetTable.CheckPartPicture3),
					CheckPartPicture4 = ISNULL(SourceTable.CheckPartPicture4,TargetTable.CheckPartPicture4),
					CheckPartPicture5 = ISNULL(SourceTable.CheckPartPicture5,TargetTable.CheckPartPicture5),
					RelationshipContent = ISNULL(SourceTable.RelationshipContent,TargetTable.RelationshipContent),
					CheckPartContent = ISNULL(SourceTable.CheckPartContent,TargetTable.CheckPartContent),
					CheckStandard = ISNULL(SourceTable.CheckStandard,TargetTable.CheckStandard),
					CheckMethod = ISNULL(SourceTable.CheckMethod,TargetTable.CheckMethod),
					CheckRepeatCycleCode = ISNULL(SourceTable.CheckRepeatCycleCode,TargetTable.CheckRepeatCycleCode),
					CheckStartDate = ISNULL(SourceTable.CheckStartDate,TargetTable.CheckStartDate),
					CheckTime = ISNULL(SourceTable.CheckTime,TargetTable.CheckTime),
					CheckDateOption = ISNULL(SourceTable.CheckDateOption,TargetTable.CheckDateOption),
					DayOfWeekCode = ISNULL(SourceTable.DayOfWeekCode,TargetTable.DayOfWeekCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CheckClassNo,
						LineCode,
						MachineCode,
						CheckPartNo,
						CheckPartPicture1,
						CheckPartPicture2,
						CheckPartPicture3,
						CheckPartPicture4,
						CheckPartPicture5,
						RelationshipContent,
						CheckPartContent,
						CheckStandard,
						CheckMethod,
						CheckRepeatCycleCode,
						CheckStartDate,
						CheckTime,
						CheckDateOption,
						DayOfWeekCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CheckClassNo,
							SourceTable.LineCode,
							SourceTable.MachineCode,
							SourceTable.CheckPartNo,
							SourceTable.CheckPartPicture1,
							SourceTable.CheckPartPicture2,
							SourceTable.CheckPartPicture3,
							SourceTable.CheckPartPicture4,
							SourceTable.CheckPartPicture5,
							SourceTable.RelationshipContent,
							SourceTable.CheckPartContent,
							SourceTable.CheckStandard,
							SourceTable.CheckMethod,
							SourceTable.CheckRepeatCycleCode,
							SourceTable.CheckStartDate,
							SourceTable.CheckTime,
							SourceTable.CheckDateOption,
							SourceTable.DayOfWeekCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CheckStandardInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckStandardNo IS NULL THEN CheckStandardNo
							    ELSE OldCheckStandardNo
							END AS OldCheckStandardNo,
							CheckStandardNo,
							CheckClassNo,
							LineCode,
							MachineCode,
							CheckPartNo,
							dbo.fnBase64ToBinary(CheckPartPicture1) as CheckPartPicture1,
							dbo.fnBase64ToBinary(CheckPartPicture2) as CheckPartPicture2,
							dbo.fnBase64ToBinary(CheckPartPicture3) as CheckPartPicture3,
							dbo.fnBase64ToBinary(CheckPartPicture4) as CheckPartPicture4,
							dbo.fnBase64ToBinary(CheckPartPicture5) as CheckPartPicture5,
							RelationshipContent,
							CheckPartContent,
							CheckStandard,
							CheckMethod,
							CheckRepeatCycleCode,
							CheckStartDate,
							CheckTime,
							CheckDateOption,
							DayOfWeekCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCheckStandardNo VARCHAR(20),
										CheckStandardNo VARCHAR(20),
										CheckClassNo VARCHAR(10),
										LineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										CheckPartNo VARCHAR(20),
										CheckPartPicture1 NVARCHAR(MAX),
										CheckPartPicture2 NVARCHAR(MAX),
										CheckPartPicture3 NVARCHAR(MAX),
										CheckPartPicture4 NVARCHAR(MAX),
										CheckPartPicture5 NVARCHAR(MAX),
										RelationshipContent VARCHAR(MAX),
										CheckPartContent VARCHAR(1000),
										CheckStandard VARCHAR(1000),
										CheckMethod VARCHAR(1000),
										CheckRepeatCycleCode VARCHAR(20),
										CheckStartDate DATETIMEOFFSET,
										CheckTime DATETIMEOFFSET,
										CheckDateOption VARCHAR(10),
										DayOfWeekCode INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckStandardNo = SourceTable.OldCheckStandardNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CheckClassNo = ISNULL(SourceTable.CheckClassNo,TargetTable.CheckClassNo),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					CheckPartNo = ISNULL(SourceTable.CheckPartNo,TargetTable.CheckPartNo),
					CheckPartPicture1 = ISNULL(SourceTable.CheckPartPicture1,TargetTable.CheckPartPicture1),
					CheckPartPicture2 = ISNULL(SourceTable.CheckPartPicture2,TargetTable.CheckPartPicture2),
					CheckPartPicture3 = ISNULL(SourceTable.CheckPartPicture3,TargetTable.CheckPartPicture3),
					CheckPartPicture4 = ISNULL(SourceTable.CheckPartPicture4,TargetTable.CheckPartPicture4),
					CheckPartPicture5 = ISNULL(SourceTable.CheckPartPicture5,TargetTable.CheckPartPicture5),
					RelationshipContent = ISNULL(SourceTable.RelationshipContent,TargetTable.RelationshipContent),
					CheckPartContent = ISNULL(SourceTable.CheckPartContent,TargetTable.CheckPartContent),
					CheckStandard = ISNULL(SourceTable.CheckStandard,TargetTable.CheckStandard),
					CheckMethod = ISNULL(SourceTable.CheckMethod,TargetTable.CheckMethod),
					CheckRepeatCycleCode = ISNULL(SourceTable.CheckRepeatCycleCode,TargetTable.CheckRepeatCycleCode),
					CheckStartDate = ISNULL(SourceTable.CheckStartDate,TargetTable.CheckStartDate),
					CheckTime = ISNULL(SourceTable.CheckTime,TargetTable.CheckTime),
					CheckDateOption = ISNULL(SourceTable.CheckDateOption,TargetTable.CheckDateOption),
					DayOfWeekCode = ISNULL(SourceTable.DayOfWeekCode,TargetTable.DayOfWeekCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CheckClassNo,
						LineCode,
						MachineCode,
						CheckPartNo,
						CheckPartPicture1,
						CheckPartPicture2,
						CheckPartPicture3,
						CheckPartPicture4,
						CheckPartPicture5,
						RelationshipContent,
						CheckPartContent,
						CheckStandard,
						CheckMethod,
						CheckRepeatCycleCode,
						CheckStartDate,
						CheckTime,
						CheckDateOption,
						DayOfWeekCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CheckClassNo,
							SourceTable.LineCode,
							SourceTable.MachineCode,
							SourceTable.CheckPartNo,
							SourceTable.CheckPartPicture1,
							SourceTable.CheckPartPicture2,
							SourceTable.CheckPartPicture3,
							SourceTable.CheckPartPicture4,
							SourceTable.CheckPartPicture5,
							SourceTable.RelationshipContent,
							SourceTable.CheckPartContent,
							SourceTable.CheckStandard,
							SourceTable.CheckMethod,
							SourceTable.CheckRepeatCycleCode,
							SourceTable.CheckStartDate,
							SourceTable.CheckTime,
							SourceTable.CheckDateOption,
							SourceTable.DayOfWeekCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CheckStandardInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckStandardNo IS NULL THEN CheckStandardNo
							    ELSE OldCheckStandardNo
							END AS OldCheckStandardNo,
							CheckStandardNo,
							CheckClassNo,
							LineCode,
							MachineCode,
							CheckPartNo,
							dbo.fnBase64ToBinary(CheckPartPicture1) as CheckPartPicture1,
							dbo.fnBase64ToBinary(CheckPartPicture2) as CheckPartPicture2,
							dbo.fnBase64ToBinary(CheckPartPicture3) as CheckPartPicture3,
							dbo.fnBase64ToBinary(CheckPartPicture4) as CheckPartPicture4,
							dbo.fnBase64ToBinary(CheckPartPicture5) as CheckPartPicture5,
							RelationshipContent,
							CheckPartContent,
							CheckStandard,
							CheckMethod,
							CheckRepeatCycleCode,
							CheckStartDate,
							CheckTime,
							CheckDateOption,
							DayOfWeekCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCheckStandardNo VARCHAR(20),
										CheckStandardNo VARCHAR(20),
										CheckClassNo VARCHAR(10),
										LineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										CheckPartNo VARCHAR(20),
										CheckPartPicture1 NVARCHAR(MAX),
										CheckPartPicture2 NVARCHAR(MAX),
										CheckPartPicture3 NVARCHAR(MAX),
										CheckPartPicture4 NVARCHAR(MAX),
										CheckPartPicture5 NVARCHAR(MAX),
										RelationshipContent VARCHAR(MAX),
										CheckPartContent VARCHAR(1000),
										CheckStandard VARCHAR(1000),
										CheckMethod VARCHAR(1000),
										CheckRepeatCycleCode VARCHAR(20),
										CheckStartDate DATETIMEOFFSET,
										CheckTime DATETIMEOFFSET,
										CheckDateOption VARCHAR(10),
										DayOfWeekCode INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckStandardNo = SourceTable.CheckStandardNo
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
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldCheckStandardNo,
									CheckStandardNo,
									CheckClassNo,
									LineCode,
									MachineCode,
									CheckPartNo,
									dbo.fnBase64ToBinary(CheckPartPicture1) as CheckPartPicture1,
									dbo.fnBase64ToBinary(CheckPartPicture2) as CheckPartPicture2,
									dbo.fnBase64ToBinary(CheckPartPicture3) as CheckPartPicture3,
									dbo.fnBase64ToBinary(CheckPartPicture4) as CheckPartPicture4,
									dbo.fnBase64ToBinary(CheckPartPicture5) as CheckPartPicture5,
									RelationshipContent,
									CheckPartContent,
									CheckStandard,
									CheckMethod,
									CheckRepeatCycleCode,
									CheckStartDate,
									CheckTime,
									CheckDateOption,
									DayOfWeekCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsUsed,
									ImageReferenceNo
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCheckStandardNo VARCHAR(20),
											 CheckStandardNo VARCHAR(20),
											 CheckClassNo VARCHAR(10),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CheckPartNo VARCHAR(20),
											 CheckPartPicture1 NVARCHAR(MAX),
											 CheckPartPicture2 NVARCHAR(MAX),
											 CheckPartPicture3 NVARCHAR(MAX),
											 CheckPartPicture4 NVARCHAR(MAX),
											 CheckPartPicture5 NVARCHAR(MAX),
											 RelationshipContent VARCHAR(MAX),
											 CheckPartContent VARCHAR(1000),
											 CheckStandard VARCHAR(1000),
											 CheckMethod VARCHAR(1000),
											 CheckRepeatCycleCode VARCHAR(20),
											 CheckStartDate DATETIMEOFFSET,
											 CheckTime DATETIMEOFFSET,
											 CheckDateOption VARCHAR(10),
											 DayOfWeekCode INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsUsed BIT,
											 ImageReferenceNo VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCheckStandardNo IS NULL THEN CheckStandardNo
										ELSE OldCheckStandardNo
									END AS OldCheckStandardNo,
									CheckStandardNo,
									CheckClassNo,
									LineCode,
									MachineCode,
									CheckPartNo,
									dbo.fnBase64ToBinary(CheckPartPicture1) as CheckPartPicture1,
									dbo.fnBase64ToBinary(CheckPartPicture2) as CheckPartPicture2,
									dbo.fnBase64ToBinary(CheckPartPicture3) as CheckPartPicture3,
									dbo.fnBase64ToBinary(CheckPartPicture4) as CheckPartPicture4,
									dbo.fnBase64ToBinary(CheckPartPicture5) as CheckPartPicture5,
									RelationshipContent,
									CheckPartContent,
									CheckStandard,
									CheckMethod,
									CheckRepeatCycleCode,
									CheckStartDate,
									CheckTime,
									CheckDateOption,
									DayOfWeekCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsUsed,
									ImageReferenceNo
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCheckStandardNo VARCHAR(20),
											 CheckStandardNo VARCHAR(20),
											 CheckClassNo VARCHAR(10),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CheckPartNo VARCHAR(20),
											 CheckPartPicture1 NVARCHAR(MAX),
											 CheckPartPicture2 NVARCHAR(MAX),
											 CheckPartPicture3 NVARCHAR(MAX),
											 CheckPartPicture4 NVARCHAR(MAX),
											 CheckPartPicture5 NVARCHAR(MAX),
											 RelationshipContent VARCHAR(MAX),
											 CheckPartContent VARCHAR(1000),
											 CheckStandard VARCHAR(1000),
											 CheckMethod VARCHAR(1000),
											 CheckRepeatCycleCode VARCHAR(20),
											 CheckStartDate DATETIMEOFFSET,
											 CheckTime DATETIMEOFFSET,
											 CheckDateOption VARCHAR(10),
											 DayOfWeekCode INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsUsed BIT,
											 ImageReferenceNo VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCheckStandardNo IS NULL THEN CheckStandardNo
										ELSE OldCheckStandardNo
									END AS OldCheckStandardNo,
									CheckStandardNo,
									CheckClassNo,
									LineCode,
									MachineCode,
									CheckPartNo,
									dbo.fnBase64ToBinary(CheckPartPicture1) as CheckPartPicture1,
									dbo.fnBase64ToBinary(CheckPartPicture2) as CheckPartPicture2,
									dbo.fnBase64ToBinary(CheckPartPicture3) as CheckPartPicture3,
									dbo.fnBase64ToBinary(CheckPartPicture4) as CheckPartPicture4,
									dbo.fnBase64ToBinary(CheckPartPicture5) as CheckPartPicture5,
									RelationshipContent,
									CheckPartContent,
									CheckStandard,
									CheckMethod,
									CheckRepeatCycleCode,
									CheckStartDate,
									CheckTime,
									CheckDateOption,
									DayOfWeekCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsUsed,
									ImageReferenceNo
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCheckStandardNo VARCHAR(20),
											 CheckStandardNo VARCHAR(20),
											 CheckClassNo VARCHAR(10),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CheckPartNo VARCHAR(20),
											 CheckPartPicture1 NVARCHAR(MAX),
											 CheckPartPicture2 NVARCHAR(MAX),
											 CheckPartPicture3 NVARCHAR(MAX),
											 CheckPartPicture4 NVARCHAR(MAX),
											 CheckPartPicture5 NVARCHAR(MAX),
											 RelationshipContent VARCHAR(MAX),
											 CheckPartContent VARCHAR(1000),
											 CheckStandard VARCHAR(1000),
											 CheckMethod VARCHAR(1000),
											 CheckRepeatCycleCode VARCHAR(20),
											 CheckStartDate DATETIMEOFFSET,
											 CheckTime DATETIMEOFFSET,
											 CheckDateOption VARCHAR(10),
											 DayOfWeekCode INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsUsed BIT,
											 ImageReferenceNo VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCheckStandardNo,
								 @CheckStandardNo,
								 @CheckClassNo,
								 @LineCode,
								 @MachineCode,
								 @CheckPartNo,
								 @CheckPartPicture1,
								 @CheckPartPicture2,
								 @CheckPartPicture3,
								 @CheckPartPicture4,
								 @CheckPartPicture5,
								 @RelationshipContent,
								 @CheckPartContent,
								 @CheckStandard,
								 @CheckMethod,
								 @CheckRepeatCycleCode,
								 @CheckStartDate,
								 @CheckTime,
								 @CheckDateOption,
								 @DayOfWeekCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsUsed,
								 @ImageReferenceNo


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CheckStandardInfo WHERE CheckStandardNo = @CheckStandardNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CheckStandardNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CheckStandardInfo',@CheckStandardNo OUTPUT

						INSERT INTO #Params
							SELECT @CheckStandardNo, @CheckStartDate, @CheckRepeatCycleCode, @CheckDateOption, @DayOfWeekCode
                    END

                    INSERT INTO STB_CheckStandardInfo
						(
						    CheckStandardNo,
							CheckClassNo,
						    LineCode,
						    MachineCode,
						    CheckPartNo,
						    CheckPartPicture1,
						    CheckPartPicture2,
						    CheckPartPicture3,
						    CheckPartPicture4,
						    CheckPartPicture5,
						    RelationshipContent,
						    CheckPartContent,
						    CheckStandard,
						    CheckMethod,
						    CheckRepeatCycleCode,
						    CheckStartDate,
						    CheckTime,
						    CheckDateOption,
						    DayOfWeekCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							ImageReferenceNo
						)
						VALUES
						(
						    @CheckStandardNo,
							@CheckClassNo,
						    @LineCode,
						    @MachineCode,
						    @CheckPartNo,
						    @CheckPartPicture1,
						    @CheckPartPicture2,
						    @CheckPartPicture3,
						    @CheckPartPicture4,
						    @CheckPartPicture5,
						    @RelationshipContent,
						    @CheckPartContent,
						    @CheckStandard,
						    @CheckMethod,
						    @CheckRepeatCycleCode,
						    @CheckStartDate,
						    @CheckTime,
						    @CheckDateOption,
						    @DayOfWeekCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@ImageReferenceNo
						)

						-- 점검 이미지 컬럼은 엑셀로 입력 불가하므로 이미지참조컬럼의 번호를 기준으로 업데이트 해준다.
						UPDATE A
						   SET  A.CheckPartPicture1 = B.CheckPartPicture1
							   ,A.CheckPartPicture2 = B.CheckPartPicture2
							   ,A.CheckPartPicture3 = B.CheckPartPicture3
							   ,A.CheckPartPicture4 = B.CheckPartPicture4
							   ,A.CheckPartPicture5 = B.CheckPartPicture5
						  FROM STB_CheckStandardInfo A
						 INNER JOIN STB_CheckStandardInfo B
							ON A.ImageReferenceNo = B.CheckStandardNo
						 WHERE A.CheckStandardNo = @CheckStandardNo

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    -- 점검일정과 관련된 컬럼이 변경됐는지 확인 후
					SELECT @ScheduleChangeCheck = CASE WHEN CheckRepeatCycleCode <> @CheckRepeatCycleCode 
					                                     OR CheckStartDate <> @CheckStartDate
														 OR CheckDateOption <> @CheckDateOption
														 OR DayOfWeekCode <> @DayOfWeekCode THEN 1
													   ELSE 0 END
					  FROM STB_CheckStandardInfo
					 WHERE CheckStandardNo = @OldCheckStandardNo

					-- 사용여부가 1로 체크되어 넘어올 경우도 스케줄을 다시 생성한다. 2021.12.21 채민수 부문장 요청 by Jackaroe
					--IF @IsUsed = CONVERT(BIT, 1) BEGIN
					--	SET @ScheduleChangeCheck = 1
					--END

					-- 스케줄 생성 기본정보 세팅
					-- 기등록 스케줄 삭제는 생성 프로시저에서 처리.
					IF @ScheduleChangeCheck = 1 BEGIN
						INSERT INTO #Params
							SELECT @CheckStandardNo, @CheckStartDate, @CheckRepeatCycleCode, @CheckDateOption, @DayOfWeekCode
					END
					
					UPDATE STB_CheckStandardInfo
						SET
						    CheckClassNo =   ISNULL(@CheckClassNo,CheckClassNo),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    CheckPartNo =   ISNULL(@CheckPartNo,CheckPartNo),
						    CheckPartPicture1 =   ISNULL(@CheckPartPicture1,CheckPartPicture1),
						    CheckPartPicture2 =   ISNULL(@CheckPartPicture2,CheckPartPicture2),
						    CheckPartPicture3 =   ISNULL(@CheckPartPicture3,CheckPartPicture3),
						    CheckPartPicture4 =   ISNULL(@CheckPartPicture4,CheckPartPicture4),
						    CheckPartPicture5 =   ISNULL(@CheckPartPicture5,CheckPartPicture5),
						    RelationshipContent =   ISNULL(@RelationshipContent,RelationshipContent),
						    CheckPartContent =   ISNULL(@CheckPartContent,CheckPartContent),
						    CheckStandard =   ISNULL(@CheckStandard,CheckStandard),
						    CheckMethod =   ISNULL(@CheckMethod,CheckMethod),
						    CheckRepeatCycleCode =   ISNULL(@CheckRepeatCycleCode,CheckRepeatCycleCode),
						    CheckStartDate =   ISNULL(@CheckStartDate,CheckStartDate),
						    CheckTime =   ISNULL(@CheckTime,CheckTime),
						    CheckDateOption =   ISNULL(@CheckDateOption,CheckDateOption),
						    DayOfWeekCode =   ISNULL(@DayOfWeekCode,DayOfWeekCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							IsUsed = @IsUsed
						WHERE
						    CheckStandardNo = @OldCheckStandardNo

						-- 사용여부는 스케쥴 테이블과 연동한다.
						-- 오늘 날짜 이후의 스케줄만 사용여부를 업데이트한다. 2019.12.10 주영진 차장 요청 By Jackaroe
						-- 현황조회가 생기면서 과거이력을 조회할 수 있어야 하므로 현재 날짜를 기준으로 넣어준다.
						UPDATE STB_CheckScheduleInfo
						   SET IsUsed = @IsUsed
						 WHERE CheckStandardNo = @OldCheckStandardNo
						   AND CheckDate >= CONVERT(DATE, GETDATE())

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CheckStandardInfo
						WHERE
						    CheckStandardNo = @OldCheckStandardNo
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END

GO

