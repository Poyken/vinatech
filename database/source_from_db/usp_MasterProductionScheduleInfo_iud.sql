
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-07
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MasterProductionScheduleInfo_iud]
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
  DECLARE @OldMasterProductionScheduleNo VARCHAR(20)
  DECLARE @MasterProductionScheduleNo VARCHAR(20)
  DECLARE @BaseYearMonth DATE
  DECLARE @SalesRegionCode VARCHAR(20)
  DECLARE @SalesDate DATE
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @OrderTypeCode VARCHAR(10)
  DECLARE @MaterialOrderQty NUMERIC(20,4)
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @ContactWorkerCode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTIme DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MasterProductionScheduleInfo',
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
									OldMasterProductionScheduleNo,
									MasterProductionScheduleNo,
									BaseYearMonth,
									SalesRegionCode,
									SalesDate,
									MaterialCode,
									OrderTypeCode,
									MaterialOrderQty,
									CustomerCode,
									ContactWorkerCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTIme,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMasterProductionScheduleNo VARCHAR(20),
											 MasterProductionScheduleNo VARCHAR(20),
											 BaseYearMonth DATETIMEOFFSET,
											 SalesRegionCode VARCHAR(20),
											 SalesDate DATETIMEOFFSET,
											 MaterialCode VARCHAR(20),
											 OrderTypeCode VARCHAR(10),
											 MaterialOrderQty NUMERIC(20,4),
											 CustomerCode VARCHAR(20),
											 ContactWorkerCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTIme DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMasterProductionScheduleNo IS NULL THEN MasterProductionScheduleNo
										ELSE OldMasterProductionScheduleNo
									END AS OldMasterProductionScheduleNo,
									MasterProductionScheduleNo,
									BaseYearMonth,
									SalesRegionCode,
									SalesDate,
									MaterialCode,
									OrderTypeCode,
									MaterialOrderQty,
									CustomerCode,
									ContactWorkerCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTIme,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMasterProductionScheduleNo VARCHAR(20),
											 MasterProductionScheduleNo VARCHAR(20),
											 BaseYearMonth DATETIMEOFFSET,
											 SalesRegionCode VARCHAR(20),
											 SalesDate DATETIMEOFFSET,
											 MaterialCode VARCHAR(20),
											 OrderTypeCode VARCHAR(10),
											 MaterialOrderQty NUMERIC(20,4),
											 CustomerCode VARCHAR(20),
											 ContactWorkerCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTIme DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMasterProductionScheduleNo IS NULL THEN MasterProductionScheduleNo
										ELSE OldMasterProductionScheduleNo
									END AS OldMasterProductionScheduleNo,
									MasterProductionScheduleNo,
									BaseYearMonth,
									SalesRegionCode,
									SalesDate,
									MaterialCode,
									OrderTypeCode,
									MaterialOrderQty,
									CustomerCode,
									ContactWorkerCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTIme,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMasterProductionScheduleNo VARCHAR(20),
											 MasterProductionScheduleNo VARCHAR(20),
											 BaseYearMonth DATETIMEOFFSET,
											 SalesRegionCode VARCHAR(20),
											 SalesDate DATETIMEOFFSET,
											 MaterialCode VARCHAR(20),
											 OrderTypeCode VARCHAR(10),
											 MaterialOrderQty NUMERIC(20,4),
											 CustomerCode VARCHAR(20),
											 ContactWorkerCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTIme DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMasterProductionScheduleNo,
								 @MasterProductionScheduleNo,
								 @BaseYearMonth,
								 @SalesRegionCode,
								 @SalesDate,
								 @MaterialCode,
								 @OrderTypeCode,
								 @MaterialOrderQty,
								 @CustomerCode,
								 @ContactWorkerCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTIme,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MasterProductionScheduleInfo WHERE MasterProductionScheduleNo = @MasterProductionScheduleNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MasterProductionScheduleNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_MasterProductionScheduleInfo',@MasterProductionScheduleNo OUTPUT
                    END

                    INSERT INTO STB_MasterProductionScheduleInfo
						(
						    MasterProductionScheduleNo,
						    BaseYearMonth,
						    SalesRegionCode,
						    SalesDate,
						    MaterialCode,
						    OrderTypeCode,
						    MaterialOrderQty,
						    CustomerCode,
						    ContactWorkerCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTIme,
						    ChangeUserID
						)
						VALUES
						(
						    @MasterProductionScheduleNo,
						    @BaseYearMonth,
						    @SalesRegionCode,
						    @SalesDate,
						    @MaterialCode,
						    @OrderTypeCode,
						    @MaterialOrderQty,
						    @CustomerCode,
						    @ContactWorkerCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTIme,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MasterProductionScheduleInfo
						SET
						    MasterProductionScheduleNo =   ISNULL(@MasterProductionScheduleNo,MasterProductionScheduleNo),
						    BaseYearMonth =   ISNULL(@BaseYearMonth,BaseYearMonth),
						    SalesRegionCode =   ISNULL(@SalesRegionCode,SalesRegionCode),
						    SalesDate =   ISNULL(@SalesDate,SalesDate),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    OrderTypeCode =   ISNULL(@OrderTypeCode,OrderTypeCode),
						    MaterialOrderQty =   ISNULL(@MaterialOrderQty,MaterialOrderQty),
						    CustomerCode =   ISNULL(@CustomerCode,CustomerCode),
						    ContactWorkerCode =   ISNULL(@ContactWorkerCode,ContactWorkerCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTIme =   ISNULL(@ChangeDateTIme,ChangeDateTIme),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MasterProductionScheduleNo = @OldMasterProductionScheduleNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MasterProductionScheduleInfo
						WHERE
						    MasterProductionScheduleNo = @OldMasterProductionScheduleNo
                END

				INSERT INTO STB_MasterProductionScheduleInfoHist
				(
					ActionMethodCode
				   ,MasterProductionScheduleNo
				   ,BaseYearMonth
				   ,SalesRegionCode
				   ,SalesDate
				   ,MaterialCode
				   ,OrderTypeCode
				   ,MaterialOrderQty
				   ,CustomerCode
				   ,ContactWorkerCode
				   ,CreateDateTime
				   ,CreateUserID
				   ,ChangeDateTIme
				   ,ChangeUserID
				) VALUES (
					@IUD_FLAG
				   ,@MasterProductionScheduleNo
				   ,@BaseYearMonth
				   ,@SalesRegionCode
				   ,@SalesDate
				   ,@MaterialCode
				   ,@OrderTypeCode
				   ,@MaterialOrderQty
				   ,@CustomerCode
				   ,@ContactWorkerCode
				   ,GETDATE()
				   ,@pProcessUserID
				   ,GETDATE()
				   ,@pProcessUserID
				)
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
