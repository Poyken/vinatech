-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-02-06
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingCutterUsageHist_iud]
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
  DECLARE @OldElectrodeSlittingCutterUsageHistNo VARCHAR(20)
  DECLARE @ElectrodeSlittingCutterUsageHistNo VARCHAR(20)
  DECLARE @BaseDate DATE
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @ShiftCode VARCHAR(20)
  DECLARE @UseQty NUMERIC(20,5)
  DECLARE @CumulativeQty NUMERIC(20,5)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @IsExchange BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  -- 마지막 교체번호
  Declare @LastExchangeNo VARCHAR(20)
  -- 설비별 누적회수 
  Declare @CumulativeQtyByMachine NUMERIC(20,5)
  -- 마지막 입력번호
  Declare @LastElectrodeSlittingCutterUsageHistNo VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeSlittingCutterUsageHist',
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
									OldElectrodeSlittingCutterUsageHistNo,
									ElectrodeSlittingCutterUsageHistNo,
									BaseDate,
									MachineCode,
									ShiftCode,
									UseQty,
									CumulativeQty,
									Remark,
									IsExchange,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeSlittingCutterUsageHistNo VARCHAR(20),
											 ElectrodeSlittingCutterUsageHistNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 MachineCode VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 UseQty NUMERIC(20,5),
											 CumulativeQty NUMERIC(20,5),
											 Remark NVARCHAR(MAX),
											 IsExchange BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeSlittingCutterUsageHistNo IS NULL THEN ElectrodeSlittingCutterUsageHistNo
										ELSE OldElectrodeSlittingCutterUsageHistNo
									END AS OldElectrodeSlittingCutterUsageHistNo,
									ElectrodeSlittingCutterUsageHistNo,
									BaseDate,
									MachineCode,
									ShiftCode,
									UseQty,
									CumulativeQty,
									Remark,
									IsExchange,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeSlittingCutterUsageHistNo VARCHAR(20),
											 ElectrodeSlittingCutterUsageHistNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 MachineCode VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 UseQty NUMERIC(20,5),
											 CumulativeQty NUMERIC(20,5),
											 Remark NVARCHAR(MAX),
											 IsExchange BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeSlittingCutterUsageHistNo IS NULL THEN ElectrodeSlittingCutterUsageHistNo
										ELSE OldElectrodeSlittingCutterUsageHistNo
									END AS OldElectrodeSlittingCutterUsageHistNo,
									ElectrodeSlittingCutterUsageHistNo,
									BaseDate,
									MachineCode,
									ShiftCode,
									UseQty,
									CumulativeQty,
									Remark,
									IsExchange,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeSlittingCutterUsageHistNo VARCHAR(20),
											 ElectrodeSlittingCutterUsageHistNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 MachineCode VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 UseQty NUMERIC(20,5),
											 CumulativeQty NUMERIC(20,5),
											 Remark NVARCHAR(MAX),
											 IsExchange BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeSlittingCutterUsageHistNo,
								 @ElectrodeSlittingCutterUsageHistNo,
								 @BaseDate,
								 @MachineCode,
								 @ShiftCode,
								 @UseQty,
								 @CumulativeQty,
								 @Remark,
								 @IsExchange,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				-- 설비별 마지막 교체이력번호
				SELECT TOP 1 @LastExchangeNo = ElectrodeSlittingCutterUsageHistNo
				  FROM STB_ElectrodeSlittingCutterUsageHist
				 WHERE IsExchange = CONVERT(BIT, 1)
				   AND MachineCode = @MachineCode
				 ORDER BY ElectrodeSlittingCutterUsageHistNo DESC

				IF @LastExchangeNo IS NULL BEGIN
					SET @LastExchangeNo = '1'
				END

				-- 설비별 최종 입력번호
				SELECT @LastElectrodeSlittingCutterUsageHistNo = MAX(ElectrodeSlittingCutterUsageHistNo)
				  FROM STB_ElectrodeSlittingCutterUsageHist
				 WHERE MachineCode = @MachineCode

				-- 설비별 교체 후 사용량 합계
				SELECT @CumulativeQtyByMachine = ISNULL(SUM(UseQty), 0)
				  FROM STB_ElectrodeSlittingCutterUsageHist
				 WHERE ElectrodeSlittingCutterUsageHistNo >= @LastExchangeNo
				   AND MachineCode = @MachineCode

				IF @IsExchange = CONVERT(BIT, 1) BEGIN
					SET @CumulativeQtyByMachine = 0
				END

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeSlittingCutterUsageHist WHERE ElectrodeSlittingCutterUsageHistNo = @ElectrodeSlittingCutterUsageHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeSlittingCutterUsageHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ElectrodeSlittingCutterUsageHist',@ElectrodeSlittingCutterUsageHistNo OUTPUT
                    END

                    INSERT INTO STB_ElectrodeSlittingCutterUsageHist
						(
						    ElectrodeSlittingCutterUsageHistNo,
						    BaseDate,
						    MachineCode,
						    ShiftCode,
						    UseQty,
						    CumulativeQty,
						    Remark,
						    IsExchange,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ElectrodeSlittingCutterUsageHistNo,
						    @BaseDate,
						    @MachineCode,
						    @ShiftCode,
						    @UseQty,
						    @CumulativeQtyByMachine + @UseQty,
						    @Remark,
						    @IsExchange,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					IF @LastElectrodeSlittingCutterUsageHistNo <> @ElectrodeSlittingCutterUsageHistNo BEGIN
						RAISERROR('설비별 마지막 데이터가 아니면 수정할 수 없습니다.', 16, 1)
					END

                    UPDATE STB_ElectrodeSlittingCutterUsageHist
						SET
						    ElectrodeSlittingCutterUsageHistNo =   ISNULL(@ElectrodeSlittingCutterUsageHistNo,ElectrodeSlittingCutterUsageHistNo),
						    BaseDate =   ISNULL(@BaseDate,BaseDate),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    ShiftCode =   ISNULL(@ShiftCode,ShiftCode),
						    UseQty =   ISNULL(@UseQty,UseQty),
						    CumulativeQty =   @CumulativeQtyByMachine - UseQty + ISNULL(@UseQty, UseQty),
						    Remark =   ISNULL(@Remark,Remark),
						    IsExchange =   ISNULL(@IsExchange,IsExchange),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeSlittingCutterUsageHistNo = @OldElectrodeSlittingCutterUsageHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					IF @LastElectrodeSlittingCutterUsageHistNo <> @ElectrodeSlittingCutterUsageHistNo BEGIN
						RAISERROR('설비별 마지막 데이터가 아니면 삭제할 수 없습니다.', 16, 1)
					END
                    DELETE FROM STB_ElectrodeSlittingCutterUsageHist
						WHERE
						    ElectrodeSlittingCutterUsageHistNo = @OldElectrodeSlittingCutterUsageHistNo
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