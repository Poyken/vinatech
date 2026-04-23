CREATE PROCEDURE [dbo].[usp_DoCreateCostGroupMappingHist]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProcessViewName VARCHAR(MAX),
	@pXml NVARCHAR(MAX) = null,
	@pJobDate DATE
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


	DECLARE @iDoc INT
    
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
								JobEndDateTime
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
											JobEndDateTime DATETIMEOFFSET
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
								JobEndDateTime
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
											JobEndDateTime DATETIMEOFFSET
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
								JobEndDateTime
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
											JobEndDateTime DATETIMEOFFSET
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
								@JobEndDateTime


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN
				PRINT 'Not Work'
			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                -- Max Seq 
				SELECT @OldCostGroupSeq = ISNULL(MAX(CostGroupSeq), 0)
				  FROM STB_CostGroupWorkerMappingHist
				 WHERE JobDate = @pJobDate
				   AND WorkerCode = @WorkerCode

				IF @pJobDate = CONVERT(DATE, GETDATE()) BEGIN

					UPDATE STB_CostGroupWorkerMappingHist
						SET
							JobEndDateTime =   GETDATE()
						WHERE
							JobDate = @pJobDate AND
							CostGroupCode = @OldCostGroupCode AND
							CostGroupSeq = @OldCostGroupSeq AND
							WorkerCode = @OldWorkerCode
				
					IF @IsAssigned = CONVERT(BIT, 1) BEGIN
						-- New Seq
						SET @OldCostGroupSeq = @OldCostGroupSeq + 1

						INSERT INTO STB_CostGroupWorkerMappingHist (JobDate
																   ,CostGroupCode
																   ,CostGroupSeq
																   ,WorkerCode
																   ,IsAssigned
																   ,CreateDateTime
																   ,CreateUserID
																   ,ChangeDateTime
																   ,ChangeUserID
																   ,JobStartDateTime
																   ,JobEndDateTime)
							VALUES (@pJobDate, @OldCostGroupCode, @OldCostGroupSeq, @OldWorkerCode, @IsAssigned
								   ,GETDATE(), @pProcessUserID, NULL, NULL, GETDATE(), NULL)

					END
				END ELSE BEGIN
					UPDATE STB_CostGroupWorkerMappingHist
						SET
							JobEndDateTime =   CONVERT(VARCHAR(10), @pJobDate, 121) + ' 08:30:00'
						WHERE
							JobDate = @pJobDate AND
							CostGroupCode = @OldCostGroupCode AND
							CostGroupSeq = @OldCostGroupSeq AND
							WorkerCode = @OldWorkerCode
				
					IF @IsAssigned = CONVERT(BIT, 1) BEGIN
						-- New Seq
						SET @OldCostGroupSeq = @OldCostGroupSeq + 1

						INSERT INTO STB_CostGroupWorkerMappingHist (JobDate
																   ,CostGroupCode
																   ,CostGroupSeq
																   ,WorkerCode
																   ,IsAssigned
																   ,CreateDateTime
																   ,CreateUserID
																   ,ChangeDateTime
																   ,ChangeUserID
																   ,JobStartDateTime
																   ,JobEndDateTime)
							VALUES (@pJobDate, @OldCostGroupCode, @OldCostGroupSeq, @OldWorkerCode, @IsAssigned
								   ,GETDATE(), @pProcessUserID, NULL, NULL, CONVERT(VARCHAR(10), @pJobDate, 121) + ' 08:30:00', CONVERT(VARCHAR(10), DATEADD(day, 1, @pJobDate), 121) + ' 08:30:00')

					END
				END
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                PRINT 'Not Work'
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