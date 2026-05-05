
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-02-17
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostGroupWorkerMapping_iud]
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
  DECLARE @OldCostGroupCode VARCHAR(20)
  DECLARE @OldWorkerCode VARCHAR(20)
  DECLARE @OldSeq INT
  DECLARE @CostGroupCode VARCHAR(20)
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @IsAssigned BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @Seq INT
  DECLARE @SupportCostGroupCode VARCHAR(20)
  DECLARE @ApplyTime NUMERIC(20,1)
  DECLARE @WorkTypeCode VARCHAR(20)
  DECLARE @CostGroupRemark NVARCHAR(MAX)

  -- WorkGroupCode, ShiftCode 추가
  Declare @WorkGroupCode VARCHAR(20)
  Declare @ShiftCode VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CostGroupWorkerMapping',
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
									OldCostGroupCode,
									OldWorkerCode,
									OldSeq,
									CostGroupCode,
									WorkerCode,
									IsAssigned,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Seq,
									SupportCostGroupCode,
									ApplyTime,
									WorkTypeCode,
									WorkGroupCode,
									ShiftCode,
									CostGroupRemark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCostGroupCode VARCHAR(20),
											 OldWorkerCode VARCHAR(20),
											 OldSeq INT,
											 CostGroupCode VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 IsAssigned BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Seq INT,
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
										WHEN OldCostGroupCode IS NULL THEN CostGroupCode
										ELSE OldCostGroupCode
									END AS OldCostGroupCode,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									CostGroupCode,
									WorkerCode,
									IsAssigned,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Seq,
									SupportCostGroupCode,
									ApplyTime,
									--isnull(ApplyTime, 0),
									WorkTypeCode,
									WorkGroupCode,
									ShiftCode,
									CostGroupRemark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCostGroupCode VARCHAR(20),
											 OldWorkerCode VARCHAR(20),
											 OldSeq INT,
											 CostGroupCode VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 IsAssigned BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Seq INT,
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
										WHEN OldCostGroupCode IS NULL THEN CostGroupCode
										ELSE OldCostGroupCode
									END AS OldCostGroupCode,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									CostGroupCode,
									WorkerCode,
									IsAssigned,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Seq,
									SupportCostGroupCode,
									ApplyTime,
									WorkTypeCode,
									WorkGroupCode,
									ShiftCode,
									CostGroupRemark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCostGroupCode VARCHAR(20),
											 OldWorkerCode VARCHAR(20),
											 OldSeq INT,
											 CostGroupCode VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 IsAssigned BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Seq INT,
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
								 @OldCostGroupCode,
								 @OldWorkerCode,
								 @OldSeq,
								 @CostGroupCode,
								 @WorkerCode,
								 @IsAssigned,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Seq,
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

                    IF EXISTS (SELECT 1 FROM STB_CostGroupWorkerMapping WHERE CostGroupCode = @CostGroupCode AND WorkerCode = @WorkerCode) BEGIN
						SELECT @Seq = ISNULL(MAX(Seq), 0) + 1
						  FROM STB_CostGroupWorkerMapping
						 WHERE CostGroupCode = @CostGroupCode 
						   AND WorkerCode = @WorkerCode
					END ELSE BEGIN
						SET @Seq = 1
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_CostGroupWorkerMapping',@CostGroupCode OUTPUT
                    END

                    INSERT INTO STB_CostGroupWorkerMapping
						(
						    CostGroupCode,
						    WorkerCode,
						    IsAssigned,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    Seq,
						    SupportCostGroupCode,
						    ApplyTime,
						    WorkTypeCode,
							CostGroupRemark
						)
						VALUES
						(
						    @CostGroupCode,
						    @WorkerCode,
						    CONVERT(BIT, 1), --@IsAssigned,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @Seq,
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
						   AND JobDate = CONVERT(CHAR(10), GETDATE(), 121)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CostGroupWorkerMapping
						SET
						    CostGroupCode =   ISNULL(@CostGroupCode,CostGroupCode),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    --IsAssigned =   ISNULL(@IsAssigned,IsAssigned),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    Seq =   ISNULL(@Seq,Seq),
						    SupportCostGroupCode =   ISNULL(@SupportCostGroupCode,SupportCostGroupCode),
						    --ApplyTime =   ISNULL(@ApplyTime, ApplyTime),

							 ApplyTime =  Case when  @ApplyTime is null then  0 else  @ApplyTime End ,
							  
						    WorkTypeCode =   ISNULL(@WorkTypeCode,WorkTypeCode),
							CostGroupRemark =   ISNULL(@CostGroupRemark,CostGroupRemark)
						WHERE
						    CostGroupCode = @OldCostGroupCode AND
						    WorkerCode = @OldWorkerCode AND
						    Seq = @OldSeq

					-- 근무조코드, 근무코드 업데이트
						UPDATE STB_DayWorkGroup
						   SET WorkGroupCode = @WorkGroupCode
						      ,ShiftCode = @ShiftCode
						 WHERE WorkerCode = @WorkerCode
						   AND JobDate = CONVERT(CHAR(10), GETDATE(), 121)

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CostGroupWorkerMapping
						WHERE
						    CostGroupCode = @OldCostGroupCode AND
						    WorkerCode = @OldWorkerCode AND
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
