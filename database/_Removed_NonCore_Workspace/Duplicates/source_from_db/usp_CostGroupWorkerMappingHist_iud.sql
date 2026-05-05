
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-02-17
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostGroupWorkerMappingHist_iud]
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
  DECLARE @OldJobDate DATE
  DECLARE @OldCostGroupCode VARCHAR(20)
  DECLARE @OldCostGroupSeq INT
  DECLARE @OldWorkerCode VARCHAR(20)
  DECLARE @JobDate DATE
  DECLARE @CostGroupCode VARCHAR(20)
  DECLARE @CostGroupSeq INT
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @IsAssigned BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @JobStartDateTime DATETIME
  DECLARE @JobEndDateTime DATETIME
  DECLARE @BasicWorkTime NUMERIC(5,1)
  DECLARE @SupportCostGroupCode VARCHAR(20)
  DECLARE @ApplyTime NUMERIC(20,1)
  DECLARE @WorkTypeCode VARCHAR(20)
  DECLARE @CostGroupRemark NVARCHAR(MAX)

  --근무조, 근무시간 업데이트용 추가
  -- WorkGroupCode, ShiftCode 추가
  Declare @WorkGroupCode VARCHAR(20)
  Declare @ShiftCode VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CostGroupWorkerMappingHist',
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
									OldJobDate,
									OldCostGroupCode,
									OldCostGroupSeq,
									OldWorkerCode,
									JobDate,
									CostGroupCode,
									CostGroupSeq,
									WorkerCode,
									IsAssigned,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									JobStartDateTime,
									JobEndDateTime,
									BasicWorkTime,
									SupportCostGroupCode,
									ApplyTime,
									WorkTypeCode,
									WorkGroupCode,
									ShiftCode,
									CostGroupRemark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldJobDate DATETIMEOFFSET,
											 OldCostGroupCode VARCHAR(20),
											 OldCostGroupSeq INT,
											 OldWorkerCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CostGroupCode VARCHAR(20),
											 CostGroupSeq INT,
											 WorkerCode VARCHAR(20),
											 IsAssigned BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 JobStartDateTime DATETIMEOFFSET,
											 JobEndDateTime DATETIMEOFFSET,
											 BasicWorkTime NUMERIC(5,1),
											 SupportCostGroupCode VARCHAR(20),
											 ApplyTime NUMERIC(20,1),
											 WorkTypeCode VARCHAR(20),
											 WorkGroupCode VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 CostGroupRemark NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldJobDate IS NULL THEN JobDate
										ELSE OldJobDate
									END AS OldJobDate,
									CASE 
										WHEN OldCostGroupCode IS NULL THEN CostGroupCode
										ELSE OldCostGroupCode
									END AS OldCostGroupCode,
									CASE 
										WHEN OldCostGroupSeq IS NULL THEN CostGroupSeq
										ELSE OldCostGroupSeq
									END AS OldCostGroupSeq,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									JobDate,
									CostGroupCode,
									CostGroupSeq,
									WorkerCode,
									IsAssigned,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									JobStartDateTime,
									JobEndDateTime,
									BasicWorkTime,
									SupportCostGroupCode,
									ApplyTime,
									WorkTypeCode,
									WorkGroupCode,
									ShiftCode,
									CostGroupRemark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldJobDate DATETIMEOFFSET,
											 OldCostGroupCode VARCHAR(20),
											 OldCostGroupSeq INT,
											 OldWorkerCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CostGroupCode VARCHAR(20),
											 CostGroupSeq INT,
											 WorkerCode VARCHAR(20),
											 IsAssigned BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 JobStartDateTime DATETIMEOFFSET,
											 JobEndDateTime DATETIMEOFFSET,
											 BasicWorkTime NUMERIC(5,1),
											 SupportCostGroupCode VARCHAR(20),
											 ApplyTime NUMERIC(20,1),
											 WorkTypeCode VARCHAR(20),
											 WorkGroupCode VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 CostGroupRemark NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldJobDate IS NULL THEN JobDate
										ELSE OldJobDate
									END AS OldJobDate,
									CASE 
										WHEN OldCostGroupCode IS NULL THEN CostGroupCode
										ELSE OldCostGroupCode
									END AS OldCostGroupCode,
									CASE 
										WHEN OldCostGroupSeq IS NULL THEN CostGroupSeq
										ELSE OldCostGroupSeq
									END AS OldCostGroupSeq,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									JobDate,
									CostGroupCode,
									CostGroupSeq,
									WorkerCode,
									IsAssigned,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									JobStartDateTime,
									JobEndDateTime,
									BasicWorkTime,
									SupportCostGroupCode,
									ApplyTime,
									WorkTypeCode,
									WorkGroupCode,
									ShiftCode,
									CostGroupRemark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldJobDate DATETIMEOFFSET,
											 OldCostGroupCode VARCHAR(20),
											 OldCostGroupSeq INT,
											 OldWorkerCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CostGroupCode VARCHAR(20),
											 CostGroupSeq INT,
											 WorkerCode VARCHAR(20),
											 IsAssigned BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 JobStartDateTime DATETIMEOFFSET,
											 JobEndDateTime DATETIMEOFFSET,
											 BasicWorkTime NUMERIC(5,1),
											 SupportCostGroupCode VARCHAR(20),
											 ApplyTime NUMERIC(20,1),
											 WorkTypeCode VARCHAR(20),
											 WorkGroupCode VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 CostGroupRemark NVARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldJobDate,
								 @OldCostGroupCode,
								 @OldCostGroupSeq,
								 @OldWorkerCode,
								 @JobDate,
								 @CostGroupCode,
								 @CostGroupSeq,
								 @WorkerCode,
								 @IsAssigned,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @JobStartDateTime,
								 @JobEndDateTime,
								 @BasicWorkTime,
								 @SupportCostGroupCode,
								 @ApplyTime,
								 @WorkTypeCode,
								 @WorkGroupCode,
								 @ShiftCode,
								 @CostGroupRemark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CostGroupWorkerMappingHist WHERE JobDate = @JobDate AND CostGroupCode = @CostGroupCode AND WorkerCode = @WorkerCode) BEGIN
						SELECT @CostGroupSeq = ISNULL(MAX(CostGroupSeq), 0) + 1
						  FROM STB_CostGroupWorkerMappingHist
						 WHERE JobDate = @JobDate
						   AND CostGroupCode = @CostGroupCode 
						   AND WorkerCode = @WorkerCode
					END ELSE BEGIN
						SET @CostGroupSeq = 1
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_CostGroupWorkerMappingHist',@JobDate OUTPUT
                    END

                    INSERT INTO STB_CostGroupWorkerMappingHist
						(
						    JobDate,
						    CostGroupCode,
						    CostGroupSeq,
						    WorkerCode,
						    IsAssigned,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    JobStartDateTime,
						    JobEndDateTime,
						    BasicWorkTime,
						    SupportCostGroupCode,
						    ApplyTime,
						    WorkTypeCode,
						    CostGroupRemark
						)
						VALUES
						(
						    @JobDate,
						    @CostGroupCode,
						    @CostGroupSeq,
						    @WorkerCode,
						    CONVERT(BIT, 1),
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @JobStartDateTime,
						    @JobEndDateTime,
						    @BasicWorkTime,
						    @SupportCostGroupCode,
						    @ApplyTime,
						    @WorkTypeCode,
						    @CostGroupRemark
						)

						-- 근무조코드, 근무코드 업데이트
						UPDATE STB_DayWorkGroup
						   SET WorkGroupCode = @WorkGroupCode
						      ,ShiftCode = @ShiftCode
						 WHERE WorkerCode = @WorkerCode
						   AND JobDate = @JobDate

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CostGroupWorkerMappingHist
						SET
						    JobDate =   ISNULL(@JobDate,JobDate),
						    CostGroupCode =   ISNULL(@CostGroupCode,CostGroupCode),
						    CostGroupSeq =   ISNULL(@CostGroupSeq,CostGroupSeq),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    IsAssigned =   CONVERT(BIT, 1),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    JobStartDateTime =   ISNULL(@JobStartDateTime,JobStartDateTime),
						    JobEndDateTime =   ISNULL(@JobEndDateTime,JobEndDateTime),
						    BasicWorkTime =   ISNULL(@BasicWorkTime,BasicWorkTime),
						    SupportCostGroupCode =   ISNULL(@SupportCostGroupCode,SupportCostGroupCode),
						    ApplyTime =   ISNULL(@ApplyTime,ApplyTime),
						    WorkTypeCode =   ISNULL(@WorkTypeCode,WorkTypeCode),
						    CostGroupRemark =   ISNULL(@CostGroupRemark,CostGroupRemark)
						WHERE
						    JobDate = @OldJobDate AND
						    CostGroupCode = @OldCostGroupCode AND
						    CostGroupSeq = @OldCostGroupSeq AND
						    WorkerCode = @OldWorkerCode

						-- 근무조코드, 근무코드 업데이트
						UPDATE STB_DayWorkGroup
						   SET WorkGroupCode = @WorkGroupCode
						      ,ShiftCode = @ShiftCode
						 WHERE WorkerCode = @WorkerCode
						   AND JobDate = @JobDate

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CostGroupWorkerMappingHist
						WHERE
						    JobDate = @OldJobDate AND
						    CostGroupCode = @OldCostGroupCode AND
						    CostGroupSeq = @OldCostGroupSeq AND
						    WorkerCode = @OldWorkerCode
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
