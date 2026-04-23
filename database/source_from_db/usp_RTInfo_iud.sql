
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-03-24
-- Browsable : true
-- Group : 신뢰성관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_RTInfo_iud]
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
  DECLARE @OldRTNo VARCHAR(20)
  DECLARE @OldSeq INT
  DECLARE @RTNo VARCHAR(20)
  DECLARE @Seq INT
  DECLARE @TestClassCode VARCHAR(20)
  DECLARE @TestItemCode VARCHAR(20)
  DECLARE @TestName NVARCHAR(500)
  DECLARE @ModelSpec NVARCHAR(100)
  DECLARE @AppliedVoltage NUMERIC(20,5)
  DECLARE @Temperature NUMERIC(20,5)
  DECLARE @Humidity NUMERIC(20,5)
  DECLARE @RequestDeptCode VARCHAR(20)
  DECLARE @RequestWorkerCode VARCHAR(20)
  DECLARE @RequestDate DATE
  DECLARE @TestStartDate DATE
  DECLARE @MeasureDate DATE
  DECLARE @TestRestartDate DATE
  DECLARE @MeasureCycle INT
  DECLARE @CumulativeTime INT
  DECLARE @TestEndTime INT
  DECLARE @ChamberCode VARCHAR(20)
  DECLARE @CDMachineChannel VARCHAR(50)
  DECLARE @JigNo VARCHAR(50)
  DECLARE @SampleQty INT
  DECLARE @RTStatusCode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @ModelCode VARCHAR(20)
  DECLARE @Farad NUMERIC(7,2)
  DECLARE @ProdSize VARCHAR(20)
  DECLARE @ModelType VARCHAR(20)
  DECLARE @Remark VARCHAR(20)
  DECLARE @Volt NUMERIC(7,2)
  -- 채번용 변수
  DECLARE @YearCode CHAR(1)
  DECLARE @MonthCode CHAR(1)

  -- 모델명 추가
  DECLARE @ModelName NVARCHAR(500)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_RTInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldRTNo,
									OldSeq,
									RTNo,
									Seq,
									TestClassCode,
									TestItemCode,
									TestName,
									ModelSpec,
									AppliedVoltage,
									Temperature,
									Humidity,
									RequestDeptCode,
									RequestWorkerCode,
									RequestDate,
									TestStartDate,
									MeasureDate,
									TestRestartDate,
									MeasureCycle,
									CumulativeTime,
									TestEndTime,
									ChamberCode,
									CDMachineChannel,
									JigNo,
									SampleQty,
									RTStatusCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ModelCode,
									Farad,
									ProdSize,
									ModelType,
									Remark,
									Volt,
									ModelName
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRTNo VARCHAR(20),
											 OldSeq INT,
											 RTNo VARCHAR(20),
											 Seq INT,
											 TestClassCode VARCHAR(20),
											 TestItemCode VARCHAR(20),
											 TestName NVARCHAR(500),
											 ModelSpec NVARCHAR(100),
											 AppliedVoltage NUMERIC(20,5),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 RequestDeptCode VARCHAR(20),
											 RequestWorkerCode VARCHAR(20),
											 RequestDate DATETIMEOFFSET,
											 TestStartDate DATETIMEOFFSET,
											 MeasureDate DATETIMEOFFSET,
											 TestRestartDate DATETIMEOFFSET,
											 MeasureCycle INT,
											 CumulativeTime INT,
											 TestEndTime INT,
											 ChamberCode VARCHAR(20),
											 CDMachineChannel VARCHAR(50),
											 JigNo VARCHAR(50),
											 SampleQty INT,
											 RTStatusCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ModelCode VARCHAR(20),
											 Farad NUMERIC(7,2),
											 ProdSize VARCHAR(20),
											 ModelType VARCHAR(20),
											 Remark VARCHAR(20),
											 Volt NUMERIC(7,2),
											 ModelName NVARCHAR(500)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRTNo IS NULL THEN RTNo
										ELSE OldRTNo
									END AS OldRTNo,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									RTNo,
									Seq,
									TestClassCode,
									TestItemCode,
									TestName,
									ModelSpec,
									AppliedVoltage,
									Temperature,
									Humidity,
									RequestDeptCode,
									RequestWorkerCode,
									RequestDate,
									TestStartDate,
									MeasureDate,
									TestRestartDate,
									MeasureCycle,
									CumulativeTime,
									TestEndTime,
									ChamberCode,
									CDMachineChannel,
									JigNo,
									SampleQty,
									RTStatusCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ModelCode,
									Farad,
									ProdSize,
									ModelType,
									Remark,
									Volt,
									ModelName
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRTNo VARCHAR(20),
											 OldSeq INT,
											 RTNo VARCHAR(20),
											 Seq INT,
											 TestClassCode VARCHAR(20),
											 TestItemCode VARCHAR(20),
											 TestName NVARCHAR(500),
											 ModelSpec NVARCHAR(100),
											 AppliedVoltage NUMERIC(20,5),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 RequestDeptCode VARCHAR(20),
											 RequestWorkerCode VARCHAR(20),
											 RequestDate DATETIMEOFFSET,
											 TestStartDate DATETIMEOFFSET,
											 MeasureDate DATETIMEOFFSET,
											 TestRestartDate DATETIMEOFFSET,
											 MeasureCycle INT,
											 CumulativeTime INT,
											 TestEndTime INT,
											 ChamberCode VARCHAR(20),
											 CDMachineChannel VARCHAR(50),
											 JigNo VARCHAR(50),
											 SampleQty INT,
											 RTStatusCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ModelCode VARCHAR(20),
											 Farad NUMERIC(7,2),
											 ProdSize VARCHAR(20),
											 ModelType VARCHAR(20),
											 Remark VARCHAR(20),
											 Volt NUMERIC(7,2),
											 ModelName NVARCHAR(500)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRTNo IS NULL THEN RTNo
										ELSE OldRTNo
									END AS OldRTNo,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									RTNo,
									Seq,
									TestClassCode,
									TestItemCode,
									TestName,
									ModelSpec,
									AppliedVoltage,
									Temperature,
									Humidity,
									RequestDeptCode,
									RequestWorkerCode,
									RequestDate,
									TestStartDate,
									MeasureDate,
									TestRestartDate,
									MeasureCycle,
									CumulativeTime,
									TestEndTime,
									ChamberCode,
									CDMachineChannel,
									JigNo,
									SampleQty,
									RTStatusCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ModelCode,
									Farad,
									ProdSize,
									ModelType,
									Remark,
									Volt,
									ModelName
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRTNo VARCHAR(20),
											 OldSeq INT,
											 RTNo VARCHAR(20),
											 Seq INT,
											 TestClassCode VARCHAR(20),
											 TestItemCode VARCHAR(20),
											 TestName NVARCHAR(500),
											 ModelSpec NVARCHAR(100),
											 AppliedVoltage NUMERIC(20,5),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 RequestDeptCode VARCHAR(20),
											 RequestWorkerCode VARCHAR(20),
											 RequestDate DATETIMEOFFSET,
											 TestStartDate DATETIMEOFFSET,
											 MeasureDate DATETIMEOFFSET,
											 TestRestartDate DATETIMEOFFSET,
											 MeasureCycle INT,
											 CumulativeTime INT,
											 TestEndTime INT,
											 ChamberCode VARCHAR(20),
											 CDMachineChannel VARCHAR(50),
											 JigNo VARCHAR(50),
											 SampleQty INT,
											 RTStatusCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ModelCode VARCHAR(20),
											 Farad NUMERIC(7,2),
											 ProdSize VARCHAR(20),
											 ModelType VARCHAR(20),
											 Remark VARCHAR(20),
											 Volt NUMERIC(7,2),
											 ModelName NVARCHAR(500)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRTNo,
								 @OldSeq,
								 @RTNo,
								 @Seq,
								 @TestClassCode,
								 @TestItemCode,
								 @TestName,
								 @ModelSpec,
								 @AppliedVoltage,
								 @Temperature,
								 @Humidity,
								 @RequestDeptCode,
								 @RequestWorkerCode,
								 @RequestDate,
								 @TestStartDate,
								 @MeasureDate,
								 @TestRestartDate,
								 @MeasureCycle,
								 @CumulativeTime,
								 @TestEndTime,
								 @ChamberCode,
								 @CDMachineChannel,
								 @JigNo,
								 @SampleQty,
								 @RTStatusCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @ModelCode,
								 @Farad,
								 @ProdSize,
								 @ModelType,
								 @Remark,
								 @Volt,
								 @ModelName


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_RTInfo WHERE RTNo = @RTNo AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RTNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_RTInfo',@RTNo OUTPUT
                    END
                    
                    -- 규칙에 맞게 별도 채번
			--SET @YearCode = CHAR(CONVERT(INT, RIGHT(CONVERT(CHAR(4), GETDATE(), 121), 2)) + 45)
			--SET @MonthCode = CHAR(CONVERT(INT, RIGHT(CONVERT(CHAR(7), GETDATE(), 121), 2)) + 64)

			--SELECT @RTNo = @YearCode + @MonthCode + CONVERT(VARCHAR(10), RIGHT('0' + CONVERT(VARCHAR(10), ISNULL(CONVERT(INT, MAX(RIGHT(RTNo, 2))), 0) + 1), 2))
			--  FROM STB_RTInfo
			-- WHERE RTNo LIKE @YearCode + @MonthCode + '%'

			--SET @Seq = 1

                    INSERT INTO STB_RTInfo
						(
						    RTNo,
						    Seq,
						    TestClassCode,
						    TestItemCode,
						    TestName,
						    ModelSpec,
						    AppliedVoltage,
						    Temperature,
						    Humidity,
						    RequestDeptCode,
						    RequestWorkerCode,
						    RequestDate,
						    TestStartDate,
						    MeasureDate,
						    TestRestartDate,
						    MeasureCycle,
						    CumulativeTime,
						    TestEndTime,
						    ChamberCode,
						    CDMachineChannel,
						    JigNo,
						    SampleQty,
						    RTStatusCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ModelCode,
						    Farad,
						    ProdSize,
						    ModelType,
						    Remark,
						    Volt,
							ModelName
						)
						VALUES
						(
						    @RTNo,
						    @Seq,
						    @TestClassCode,
						    @TestItemCode,
						    @TestName,
						    @ModelSpec,
						    @AppliedVoltage,
						    @Temperature,
						    @Humidity,
						    @RequestDeptCode,
						    @RequestWorkerCode,
						    @RequestDate,
						    @TestStartDate,
						    @MeasureDate,
						    @TestRestartDate,
						    @MeasureCycle,
						    @CumulativeTime,
						    @TestEndTime,
						    @ChamberCode,
						    @CDMachineChannel,
						    @JigNo,
						    @SampleQty,
						    @RTStatusCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ModelCode,
						    @Farad,
						    @ProdSize,
						    @ModelType,
						    @Remark,
						    @Volt,
							@ModelName
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_RTInfo
						SET
						    RTNo =   ISNULL(@RTNo,RTNo),
						    Seq =   ISNULL(@Seq,Seq),
						    TestClassCode =   ISNULL(@TestClassCode,TestClassCode),
						    TestItemCode =   ISNULL(@TestItemCode,TestItemCode),
						    TestName =   ISNULL(@TestName,TestName),
						    ModelSpec =   ISNULL(@ModelSpec,ModelSpec),
						    AppliedVoltage =   ISNULL(@AppliedVoltage,AppliedVoltage),
						    Temperature =   ISNULL(@Temperature,Temperature),
						    Humidity =   ISNULL(@Humidity,Humidity),
						    RequestDeptCode =   ISNULL(@RequestDeptCode,RequestDeptCode),
						    RequestWorkerCode =   ISNULL(@RequestWorkerCode,RequestWorkerCode),
						    RequestDate =   ISNULL(@RequestDate,RequestDate),
						    TestStartDate =   ISNULL(@TestStartDate,TestStartDate),
						    MeasureDate =   ISNULL(@MeasureDate,MeasureDate),
						    TestRestartDate =   ISNULL(@TestRestartDate,TestRestartDate),
						    MeasureCycle =   ISNULL(@MeasureCycle,MeasureCycle),
						    CumulativeTime =   ISNULL(@CumulativeTime,CumulativeTime),
						    TestEndTime =   ISNULL(@TestEndTime,TestEndTime),
						    ChamberCode =   ISNULL(@ChamberCode,ChamberCode),
						    CDMachineChannel =   ISNULL(@CDMachineChannel,CDMachineChannel),
						    JigNo =   ISNULL(@JigNo,JigNo),
						    SampleQty =   ISNULL(@SampleQty,SampleQty),
						    RTStatusCode =   ISNULL(@RTStatusCode,RTStatusCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    ModelCode =   ISNULL(@ModelCode,ModelCode),
						    Farad =   ISNULL(@Farad,Farad),
						    ProdSize =   ISNULL(@ProdSize,ProdSize),
						    ModelType =   ISNULL(@ModelType,ModelType),
						    Remark =   ISNULL(@Remark,Remark),
						    Volt =   ISNULL(@Volt,Volt),
							ModelName =   ISNULL(@ModelName,ModelName)
						WHERE
						    RTNo = @OldRTNo AND
						    Seq = @OldSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_RTInfo
						WHERE
						    RTNo = @OldRTNo AND
						    Seq = @OldSeq
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
