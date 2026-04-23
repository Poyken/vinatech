
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-03-31
-- Browsable : true
-- Group : 신뢰성관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_ReliabilityTestMeasureInfo_iud
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
  DECLARE @OldRTMeasureNo VARCHAR(20)
  DECLARE @RTMeasureNo VARCHAR(20)
  DECLARE @RTNo VARCHAR(20)
  DECLARE @RTItemCode VARCHAR(20)
  DECLARE @RTDate DATE
  DECLARE @RTClassCode VARCHAR(20)
  DECLARE @RequestDeptCode VARCHAR(20)
  DECLARE @RequestEmployeeNo VARCHAR(20)
  DECLARE @RequestDate DATE
  DECLARE @TestEndDate DATE
  DECLARE @ProductType VARCHAR(20)
  DECLARE @ModelType VARCHAR(50)
  DECLARE @Ocv NUMERIC(5,2)
  DECLARE @Temp NUMERIC(5,2)
  DECLARE @Humi NUMERIC(5,2)
  DECLARE @SampleCnt INT
  DECLARE @MeasureCycle INT
  DECLARE @CharacterizationCode VARCHAR(20)
  DECLARE @CharacterizationCode2 VARCHAR(20)
  DECLARE @SampleName NVARCHAR(100)
  DECLARE @SampleSeqNo INT
  DECLARE @MeasureValue NUMERIC(20,5)
  DECLARE @TestName NVARCHAR(300)
  DECLARE @SampleLotNo VARCHAR(50)
  DECLARE @TestPurpose NVARCHAR(300)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ReliabilityTestMeasureInfo',
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
									OldRTMeasureNo,
									RTMeasureNo,
									RTNo,
									RTItemCode,
									RTDate,
									RTClassCode,
									RequestDeptCode,
									RequestEmployeeNo,
									RequestDate,
									TestEndDate,
									ProductType,
									ModelType,
									Ocv,
									Temp,
									Humi,
									SampleCnt,
									MeasureCycle,
									CharacterizationCode,
									CharacterizationCode2,
									SampleName,
									SampleSeqNo,
									MeasureValue,
									TestName,
									SampleLotNo,
									TestPurpose,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRTMeasureNo VARCHAR(20),
											 RTMeasureNo VARCHAR(20),
											 RTNo VARCHAR(20),
											 RTItemCode VARCHAR(20),
											 RTDate DATETIMEOFFSET,
											 RTClassCode VARCHAR(20),
											 RequestDeptCode VARCHAR(20),
											 RequestEmployeeNo VARCHAR(20),
											 RequestDate DATETIMEOFFSET,
											 TestEndDate DATETIMEOFFSET,
											 ProductType VARCHAR(20),
											 ModelType VARCHAR(50),
											 Ocv NUMERIC(5,2),
											 Temp NUMERIC(5,2),
											 Humi NUMERIC(5,2),
											 SampleCnt INT,
											 MeasureCycle INT,
											 CharacterizationCode VARCHAR(20),
											 CharacterizationCode2 VARCHAR(20),
											 SampleName NVARCHAR(100),
											 SampleSeqNo INT,
											 MeasureValue NUMERIC(20,5),
											 TestName NVARCHAR(300),
											 SampleLotNo VARCHAR(50),
											 TestPurpose NVARCHAR(300),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRTMeasureNo IS NULL THEN RTMeasureNo
										ELSE OldRTMeasureNo
									END AS OldRTMeasureNo,
									RTMeasureNo,
									RTNo,
									RTItemCode,
									RTDate,
									RTClassCode,
									RequestDeptCode,
									RequestEmployeeNo,
									RequestDate,
									TestEndDate,
									ProductType,
									ModelType,
									Ocv,
									Temp,
									Humi,
									SampleCnt,
									MeasureCycle,
									CharacterizationCode,
									CharacterizationCode2,
									SampleName,
									SampleSeqNo,
									MeasureValue,
									TestName,
									SampleLotNo,
									TestPurpose,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRTMeasureNo VARCHAR(20),
											 RTMeasureNo VARCHAR(20),
											 RTNo VARCHAR(20),
											 RTItemCode VARCHAR(20),
											 RTDate DATETIMEOFFSET,
											 RTClassCode VARCHAR(20),
											 RequestDeptCode VARCHAR(20),
											 RequestEmployeeNo VARCHAR(20),
											 RequestDate DATETIMEOFFSET,
											 TestEndDate DATETIMEOFFSET,
											 ProductType VARCHAR(20),
											 ModelType VARCHAR(50),
											 Ocv NUMERIC(5,2),
											 Temp NUMERIC(5,2),
											 Humi NUMERIC(5,2),
											 SampleCnt INT,
											 MeasureCycle INT,
											 CharacterizationCode VARCHAR(20),
											 CharacterizationCode2 VARCHAR(20),
											 SampleName NVARCHAR(100),
											 SampleSeqNo INT,
											 MeasureValue NUMERIC(20,5),
											 TestName NVARCHAR(300),
											 SampleLotNo VARCHAR(50),
											 TestPurpose NVARCHAR(300),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRTMeasureNo IS NULL THEN RTMeasureNo
										ELSE OldRTMeasureNo
									END AS OldRTMeasureNo,
									RTMeasureNo,
									RTNo,
									RTItemCode,
									RTDate,
									RTClassCode,
									RequestDeptCode,
									RequestEmployeeNo,
									RequestDate,
									TestEndDate,
									ProductType,
									ModelType,
									Ocv,
									Temp,
									Humi,
									SampleCnt,
									MeasureCycle,
									CharacterizationCode,
									CharacterizationCode2,
									SampleName,
									SampleSeqNo,
									MeasureValue,
									TestName,
									SampleLotNo,
									TestPurpose,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRTMeasureNo VARCHAR(20),
											 RTMeasureNo VARCHAR(20),
											 RTNo VARCHAR(20),
											 RTItemCode VARCHAR(20),
											 RTDate DATETIMEOFFSET,
											 RTClassCode VARCHAR(20),
											 RequestDeptCode VARCHAR(20),
											 RequestEmployeeNo VARCHAR(20),
											 RequestDate DATETIMEOFFSET,
											 TestEndDate DATETIMEOFFSET,
											 ProductType VARCHAR(20),
											 ModelType VARCHAR(50),
											 Ocv NUMERIC(5,2),
											 Temp NUMERIC(5,2),
											 Humi NUMERIC(5,2),
											 SampleCnt INT,
											 MeasureCycle INT,
											 CharacterizationCode VARCHAR(20),
											 CharacterizationCode2 VARCHAR(20),
											 SampleName NVARCHAR(100),
											 SampleSeqNo INT,
											 MeasureValue NUMERIC(20,5),
											 TestName NVARCHAR(300),
											 SampleLotNo VARCHAR(50),
											 TestPurpose NVARCHAR(300),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRTMeasureNo,
								 @RTMeasureNo,
								 @RTNo,
								 @RTItemCode,
								 @RTDate,
								 @RTClassCode,
								 @RequestDeptCode,
								 @RequestEmployeeNo,
								 @RequestDate,
								 @TestEndDate,
								 @ProductType,
								 @ModelType,
								 @Ocv,
								 @Temp,
								 @Humi,
								 @SampleCnt,
								 @MeasureCycle,
								 @CharacterizationCode,
								 @CharacterizationCode2,
								 @SampleName,
								 @SampleSeqNo,
								 @MeasureValue,
								 @TestName,
								 @SampleLotNo,
								 @TestPurpose,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ReliabilityTestMeasureInfo WHERE RTMeasureNo = @RTMeasureNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RTMeasureNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ReliabilityTestMeasureInfo',@RTMeasureNo OUTPUT
                    END

                    INSERT INTO STB_ReliabilityTestMeasureInfo
						(
						    RTMeasureNo,
						    RTNo,
						    RTItemCode,
						    RTDate,
						    RTClassCode,
						    RequestDeptCode,
						    RequestEmployeeNo,
						    RequestDate,
						    TestEndDate,
						    ProductType,
						    ModelType,
						    Ocv,
						    Temp,
						    Humi,
						    SampleCnt,
						    MeasureCycle,
						    CharacterizationCode,
						    CharacterizationCode2,
						    SampleName,
						    SampleSeqNo,
						    MeasureValue,
						    TestName,
						    SampleLotNo,
						    TestPurpose,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @RTMeasureNo,
						    @RTNo,
						    @RTItemCode,
						    @RTDate,
						    @RTClassCode,
						    @RequestDeptCode,
						    @RequestEmployeeNo,
						    @RequestDate,
						    @TestEndDate,
						    @ProductType,
						    @ModelType,
						    @Ocv,
						    @Temp,
						    @Humi,
						    @SampleCnt,
						    @MeasureCycle,
						    @CharacterizationCode,
						    @CharacterizationCode2,
						    @SampleName,
						    @SampleSeqNo,
						    @MeasureValue,
						    @TestName,
						    @SampleLotNo,
						    @TestPurpose,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ReliabilityTestMeasureInfo
						SET
						    RTNo =   ISNULL(@RTNo,RTNo),
						    RTItemCode =   ISNULL(@RTItemCode,RTItemCode),
						    RTDate =   ISNULL(@RTDate,RTDate),
						    RTClassCode =   ISNULL(@RTClassCode,RTClassCode),
						    RequestDeptCode =   ISNULL(@RequestDeptCode,RequestDeptCode),
						    RequestEmployeeNo =   ISNULL(@RequestEmployeeNo,RequestEmployeeNo),
						    RequestDate =   ISNULL(@RequestDate,RequestDate),
						    TestEndDate =   ISNULL(@TestEndDate,TestEndDate),
						    ProductType =   ISNULL(@ProductType,ProductType),
						    ModelType =   ISNULL(@ModelType,ModelType),
						    Ocv =   ISNULL(@Ocv,Ocv),
						    Temp =   ISNULL(@Temp,Temp),
						    Humi =   ISNULL(@Humi,Humi),
						    SampleCnt =   ISNULL(@SampleCnt,SampleCnt),
						    MeasureCycle =   ISNULL(@MeasureCycle,MeasureCycle),
						    CharacterizationCode =   ISNULL(@CharacterizationCode,CharacterizationCode),
						    CharacterizationCode2 =   ISNULL(@CharacterizationCode2,CharacterizationCode2),
						    SampleName =   ISNULL(@SampleName,SampleName),
						    SampleSeqNo =   ISNULL(@SampleSeqNo,SampleSeqNo),
						    MeasureValue =   ISNULL(@MeasureValue,MeasureValue),
						    TestName =   ISNULL(@TestName,TestName),
						    SampleLotNo =   ISNULL(@SampleLotNo,SampleLotNo),
						    TestPurpose =   ISNULL(@TestPurpose,TestPurpose),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    RTMeasureNo = @OldRTMeasureNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ReliabilityTestMeasureInfo
						WHERE
						    RTMeasureNo = @OldRTMeasureNo
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
