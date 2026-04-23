-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-09-17
-- Browsable : true
-- Group : 지지체
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_DayProdPlanOrderBatchInfo_iud
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
  DECLARE @OldDayProdPlanOrderBatchNo VARCHAR(20)
  DECLARE @DayProdPlanOrderBatchNo VARCHAR(20)
  DECLARE @PlanYearMonth VARCHAR(7)
  DECLARE @ParentPONo VARCHAR(20)
  DECLARE @TargetPONo VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @PlanShiftCode VARCHAR(20)
  DECLARE @PlanDate DATE
  DECLARE @PlanQty NUMERIC(20,5)
  DECLARE @DayPlanNo VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DayProdPlanOrderBatchInfo',
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
									OldDayProdPlanOrderBatchNo,
									DayProdPlanOrderBatchNo,
									PlanYearMonth,
									ParentPONo,
									TargetPONo,
									LineCode,
									PlanShiftCode,
									PlanDate,
									PlanQty,
									DayPlanNo,
									Barcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDayProdPlanOrderBatchNo VARCHAR(20),
											 DayProdPlanOrderBatchNo VARCHAR(20),
											 PlanYearMonth VARCHAR(7),
											 ParentPONo VARCHAR(20),
											 TargetPONo VARCHAR(20),
											 LineCode VARCHAR(20),
											 PlanShiftCode VARCHAR(20),
											 PlanDate DATETIMEOFFSET,
											 PlanQty NUMERIC(20,5),
											 DayPlanNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDayProdPlanOrderBatchNo IS NULL THEN DayProdPlanOrderBatchNo
										ELSE OldDayProdPlanOrderBatchNo
									END AS OldDayProdPlanOrderBatchNo,
									DayProdPlanOrderBatchNo,
									PlanYearMonth,
									ParentPONo,
									TargetPONo,
									LineCode,
									PlanShiftCode,
									PlanDate,
									PlanQty,
									DayPlanNo,
									Barcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDayProdPlanOrderBatchNo VARCHAR(20),
											 DayProdPlanOrderBatchNo VARCHAR(20),
											 PlanYearMonth VARCHAR(7),
											 ParentPONo VARCHAR(20),
											 TargetPONo VARCHAR(20),
											 LineCode VARCHAR(20),
											 PlanShiftCode VARCHAR(20),
											 PlanDate DATETIMEOFFSET,
											 PlanQty NUMERIC(20,5),
											 DayPlanNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDayProdPlanOrderBatchNo IS NULL THEN DayProdPlanOrderBatchNo
										ELSE OldDayProdPlanOrderBatchNo
									END AS OldDayProdPlanOrderBatchNo,
									DayProdPlanOrderBatchNo,
									PlanYearMonth,
									ParentPONo,
									TargetPONo,
									LineCode,
									PlanShiftCode,
									PlanDate,
									PlanQty,
									DayPlanNo,
									Barcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDayProdPlanOrderBatchNo VARCHAR(20),
											 DayProdPlanOrderBatchNo VARCHAR(20),
											 PlanYearMonth VARCHAR(7),
											 ParentPONo VARCHAR(20),
											 TargetPONo VARCHAR(20),
											 LineCode VARCHAR(20),
											 PlanShiftCode VARCHAR(20),
											 PlanDate DATETIMEOFFSET,
											 PlanQty NUMERIC(20,5),
											 DayPlanNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDayProdPlanOrderBatchNo,
								 @DayProdPlanOrderBatchNo,
								 @PlanYearMonth,
								 @ParentPONo,
								 @TargetPONo,
								 @LineCode,
								 @PlanShiftCode,
								 @PlanDate,
								 @PlanQty,
								 @DayPlanNo,
								 @Barcode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DayProdPlanOrderBatchInfo WHERE DayProdPlanOrderBatchNo = @DayProdPlanOrderBatchNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DayProdPlanOrderBatchNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_DayProdPlanOrderBatchInfo',@DayProdPlanOrderBatchNo OUTPUT
                    END

                    INSERT INTO STB_DayProdPlanOrderBatchInfo
						(
						    DayProdPlanOrderBatchNo,
						    PlanYearMonth,
						    ParentPONo,
						    TargetPONo,
						    LineCode,
						    PlanShiftCode,
						    PlanDate,
						    PlanQty,
						    DayPlanNo,
						    Barcode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DayProdPlanOrderBatchNo,
						    @PlanYearMonth,
						    @ParentPONo,
						    @TargetPONo,
						    @LineCode,
						    @PlanShiftCode,
						    @PlanDate,
						    @PlanQty,
						    @DayPlanNo,
						    @Barcode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_DayProdPlanOrderBatchInfo
						SET
						    DayProdPlanOrderBatchNo =   ISNULL(@DayProdPlanOrderBatchNo,DayProdPlanOrderBatchNo),
						    PlanYearMonth =   ISNULL(@PlanYearMonth,PlanYearMonth),
						    ParentPONo =   ISNULL(@ParentPONo,ParentPONo),
						    TargetPONo =   ISNULL(@TargetPONo,TargetPONo),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    PlanShiftCode =   ISNULL(@PlanShiftCode,PlanShiftCode),
						    PlanDate =   ISNULL(@PlanDate,PlanDate),
						    PlanQty =   ISNULL(@PlanQty,PlanQty),
						    DayPlanNo =   ISNULL(@DayPlanNo,DayPlanNo),
						    Barcode =   ISNULL(@Barcode,Barcode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    DayProdPlanOrderBatchNo = @OldDayProdPlanOrderBatchNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DayProdPlanOrderBatchInfo
						WHERE
						    DayProdPlanOrderBatchNo = @OldDayProdPlanOrderBatchNo
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
