-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-22
-- Browsable : true
-- Group : 설비관리
-- Description:	설비수리작업자정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairWorkerHist_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null--,
	--@pMachineRepairHistoryNo VARCHAR(20)--,
	--@pOutMachineRepairHistoryNo VARCHAR(20) OUTPUT
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldMachineRepairHistoryNo VARCHAR(20)
  DECLARE @OldMachineRepairWorkerSeq INT
  DECLARE @MachineRepairHistoryNo VARCHAR(20)
  DECLARE @MachineRepairWorkerSeq INT
  DECLARE @MachineRepairWorkerCode VARCHAR(20)
  DECLARE @JobStartDateTime DATETIME
  DECLARE @JobEndDateTime DATETIME
  DECLARE @JobTime INT
  DECLARE @BasicCost NUMERIC(20,5)
  DECLARE @RepairText NVARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  
  DECLARE @MaxSeqNo INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineRepairWorkerHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldMachineRepairHistoryNo,
									XMLData.OldMachineRepairWorkerSeq,
									XMLData.MachineRepairHistoryNo,
									XMLData.MachineRepairWorkerSeq,
									XMLData.MachineRepairWorkerCode,
									XMLData.JobStartDateTime,
									XMLData.JobEndDateTime,
									XMLData.JobTime,
									XMLData.BasicCost,
									XMLData.RepairText,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 OldMachineRepairWorkerSeq INT,
											 MachineRepairHistoryNo VARCHAR(20),
											 MachineRepairWorkerSeq INT,
											 MachineRepairWorkerCode VARCHAR(20),
											 JobStartDateTime DATETIMEOFFSET,
											 JobEndDateTime DATETIMEOFFSET,
											 JobTime INT,
											 BasicCost NUMERIC(20,5),
											 RepairText NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineRepairHistoryNo IS NULL THEN XMLData.MachineRepairHistoryNo
										ELSE XMLData.OldMachineRepairHistoryNo
									END AS OldMachineRepairHistoryNo,
									CASE 
										WHEN XMLData.OldMachineRepairWorkerSeq IS NULL THEN XMLData.MachineRepairWorkerSeq
										ELSE XMLData.OldMachineRepairWorkerSeq
									END AS OldMachineRepairWorkerSeq,
									XMLData.MachineRepairHistoryNo,
									XMLData.MachineRepairWorkerSeq,
									XMLData.MachineRepairWorkerCode,
									XMLData.JobStartDateTime,
									XMLData.JobEndDateTime,
									XMLData.JobTime,
									XMLData.BasicCost,
									XMLData.RepairText,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 OldMachineRepairWorkerSeq INT,
											 MachineRepairHistoryNo VARCHAR(20),
											 MachineRepairWorkerSeq INT,
											 MachineRepairWorkerCode VARCHAR(20),
											 JobStartDateTime DATETIMEOFFSET,
											 JobEndDateTime DATETIMEOFFSET,
											 JobTime INT,
											 BasicCost NUMERIC(20,5),
											 RepairText NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineRepairHistoryNo IS NULL THEN XMLData.MachineRepairHistoryNo
										ELSE XMLData.OldMachineRepairHistoryNo
									END AS OldMachineRepairHistoryNo,
									CASE 
										WHEN XMLData.OldMachineRepairWorkerSeq IS NULL THEN XMLData.MachineRepairWorkerSeq
										ELSE XMLData.OldMachineRepairWorkerSeq
									END AS OldMachineRepairWorkerSeq,
									XMLData.MachineRepairHistoryNo,
									XMLData.MachineRepairWorkerSeq,
									XMLData.MachineRepairWorkerCode,
									XMLData.JobStartDateTime,
									XMLData.JobEndDateTime,
									XMLData.JobTime,
									XMLData.BasicCost,
									XMLData.RepairText,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 OldMachineRepairWorkerSeq INT,
											 MachineRepairHistoryNo VARCHAR(20),
											 MachineRepairWorkerSeq INT,
											 MachineRepairWorkerCode VARCHAR(20),
											 JobStartDateTime DATETIMEOFFSET,
											 JobEndDateTime DATETIMEOFFSET,
											 JobTime INT,
											 BasicCost NUMERIC(20,5),
											 RepairText NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachineRepairHistoryNo,
								 @OldMachineRepairWorkerSeq,
								 @MachineRepairHistoryNo,
								 @MachineRepairWorkerSeq,
								 @MachineRepairWorkerCode,
								 @JobStartDateTime,
								 @JobEndDateTime,
								 @JobTime,
								 @BasicCost,
								 @RepairText,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				--IF @MachineRepairHistoryNo IS NULL BEGIN
				--	SET @pMachineRepairHistoryNo = @MachineRepairHistoryNo
				--END
				
				--SET @pOutMachineRepairHistoryNo = @pMachineRepairHistoryNo
				
                IF @IUD_FLAG = 'INSERT' BEGIN
					-- 임시 SEQUENCE TABLE 사용 버젼
					SET @OldMachineRepairHistoryNo = @MachineRepairHistoryNo 
					
					SET @MachineRepairHistoryNo = NULL
					
					SELECT
							@MachineRepairHistoryNo = KeyValue
					FROM
							#SEQUENCE_TABLE
					WHERE
							UID_KEY = @OldMachineRepairHistoryNo
					
					IF @MachineRepairHistoryNo IS NULL
					BEGIN
							SET @MachineRepairHistoryNo = @OldMachineRepairHistoryNo
					END
					--
					
					


     --               IF EXISTS (SELECT 1 FROM STB_MachineRepairWorkerHist WHERE MachineRepairHistoryNo = @pMachineRepairHistoryNo AND MachineRepairWorkerSeq = @MachineRepairWorkerSeq) BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @pMachineRepairHistoryNo)
					--END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxSeqNo = ISNULL(MAX(MachineRepairWorkerSeq),0) + 1
						FROM
								STB_MachineRepairWorkerHist 
						WHERE
								MachineRepairHistoryNo = @MachineRepairHistoryNo
                    END

                    INSERT INTO STB_MachineRepairWorkerHist
						(
						    MachineRepairHistoryNo,
						    MachineRepairWorkerSeq,
						    MachineRepairWorkerCode,
						    JobStartDateTime,
						    JobEndDateTime,
						    JobTime,
						    BasicCost,
						    RepairText,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MachineRepairHistoryNo,
						    @MaxSeqNo,
						    @MachineRepairWorkerCode,
						    @JobStartDateTime,
						    @JobEndDateTime,
						    --@JobTime,
						    DATEDIFF(MINUTE,@JobStartDateTime,@JobEndDateTime),
						    @BasicCost,
						    @RepairText,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MachineRepairWorkerHist
						SET
						    MachineRepairHistoryNo =   CASE
						                WHEN @MachineRepairHistoryNo IS NOT NULL THEN @MachineRepairHistoryNo
						                ELSE MachineRepairHistoryNo
						            END,
						    MachineRepairWorkerSeq =   CASE
						                WHEN @MachineRepairWorkerSeq IS NOT NULL THEN @MachineRepairWorkerSeq
						                ELSE MachineRepairWorkerSeq
						            END,
						    MachineRepairWorkerCode =   CASE
						                WHEN @MachineRepairWorkerCode IS NOT NULL THEN @MachineRepairWorkerCode
						                ELSE MachineRepairWorkerCode
						            END,
						    JobStartDateTime =   CASE
						                WHEN @JobStartDateTime IS NOT NULL THEN @JobStartDateTime
						                ELSE JobStartDateTime
						            END,
						    JobEndDateTime =   CASE
						                WHEN @JobEndDateTime IS NOT NULL THEN @JobEndDateTime
						                ELSE JobEndDateTime
						            END,
						            
						    JobTime =   DATEDIFF(MINUTE,@JobStartDateTime,@JobEndDateTime),
						    
						    BasicCost =   CASE
						                WHEN @BasicCost IS NOT NULL THEN @BasicCost
						                ELSE BasicCost
						            END,
						    RepairText =   CASE
						                WHEN @RepairText IS NOT NULL THEN @RepairText
						                ELSE RepairText
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MachineRepairHistoryNo = @MachineRepairHistoryNo AND
						    MachineRepairWorkerSeq = @OldMachineRepairWorkerSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					
                    DELETE FROM STB_MachineRepairWorkerHist
						WHERE
						    MachineRepairHistoryNo = @MachineRepairHistoryNo AND
						    MachineRepairWorkerSeq = @MachineRepairWorkerSeq
                END
                
                EXEC usp_DoUpdateMachineRepairHistory @MachineRepairHistoryNo
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

