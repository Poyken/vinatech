-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Browsable : true
-- Group : 설비그룹
-- Description:	설비수리이력마스터 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairHistory_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null--,
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
  DECLARE @MachineRepairHistoryNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @MachineLossHistNo VARCHAR(20)
  DECLARE @TroublePoint NVARCHAR(100)
  DECLARE @TroubleText NVARCHAR(100)
  DECLARE @RepairText NVARCHAR(200)
  DECLARE @IsMachineLoss BIT
  DECLARE @TotalRepairCost NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  
  DECLARE @OldMachineCode VARCHAR(20)
  


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineRepairHistory',
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
									XMLData.MachineRepairHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MachineCode,
									XMLData.MachineLossHistNo,
									XMLData.TroublePoint,
									XMLData.TroubleText,
									XMLData.RepairText,
									XMLData.IsMachineLoss,
									XMLData.TotalRepairCost,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 MachineRepairHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MachineLossHistNo VARCHAR(20),
											 TroublePoint NVARCHAR(100),
											 TroubleText NVARCHAR(100),
											 RepairText NVARCHAR(200),
											 IsMachineLoss BIT,
											 TotalRepairCost NUMERIC(20,5),
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
									XMLData.MachineRepairHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MachineCode,
									XMLData.MachineLossHistNo,
									XMLData.TroublePoint,
									XMLData.TroubleText,
									XMLData.RepairText,
									XMLData.IsMachineLoss,
									XMLData.TotalRepairCost,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 MachineRepairHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MachineLossHistNo VARCHAR(20),
											 TroublePoint NVARCHAR(100),
											 TroubleText NVARCHAR(100),
											 RepairText NVARCHAR(200),
											 IsMachineLoss BIT,
											 TotalRepairCost NUMERIC(20,5),
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
									XMLData.MachineRepairHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MachineCode,
									XMLData.MachineLossHistNo,
									XMLData.TroublePoint,
									XMLData.TroubleText,
									XMLData.RepairText,
									XMLData.IsMachineLoss,
									XMLData.TotalRepairCost,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 MachineRepairHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MachineLossHistNo VARCHAR(20),
											 TroublePoint NVARCHAR(100),
											 TroubleText NVARCHAR(100),
											 RepairText NVARCHAR(200),
											 IsMachineLoss BIT,
											 TotalRepairCost NUMERIC(20,5),
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
								 @MachineRepairHistoryNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MachineCode,
								 @MachineLossHistNo,
								 @TroublePoint,
								 @TroubleText,
								 @RepairText,
								 @IsMachineLoss,
								 @TotalRepairCost,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN


                    IF EXISTS (SELECT 1 FROM STB_MachineRepairHistory WHERE MachineRepairHistoryNo = @MachineRepairHistoryNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachineRepairHistoryNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						-- 임시 SEQUENCE TABLE 사용 버젼
						SET @OldMachineRepairHistoryNo = @MachineRepairHistoryNo
						--
                    
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MachineRepairHistory', @MachineRepairHistoryNo OUTPUT
						
						-- 임시 SEQUENCE TABLE 사용 버젼
							INSERT INTO #SEQUENCE_TABLE
								(KeyValue, UID_KEY)
							VALUES
								(@MachineRepairHistoryNo, @OldMachineRepairHistoryNo)
						--
						
						
                    END
                    
                   

                    INSERT INTO STB_MachineRepairHistory
						(
						    MachineRepairHistoryNo,
						    CompanyCode,
						    WorkCenterCode,
						    MachineCode,
						    MachineLossHistNo,
						    TroublePoint,
						    TroubleText,
						    RepairText,
						    IsMachineLoss,
						    --TotalRepairCost,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MachineRepairHistoryNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MachineCode,
						    @MachineLossHistNo,
						    @TroublePoint,
						    @TroubleText,
						    @RepairText,
						    @IsMachineLoss,
						    --@TotalRepairCost,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
						--SET @pOutMachineRepairHistoryNo = @MachineRepairHistoryNo

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					SELECT
							@OldMachineCode = MachineCode
					FROM
							STB_MachineRepairHistory 
					WHERE
							MachineRepairHistoryNo = @OldMachineRepairHistoryNo
					
					
					IF @OldMachineCode <> @MachineCode BEGIN
						RAISERROR('설비코드는 변경할 수 없습니다. : %s',16,1,@OldMachineRepairHistoryNo)
						RETURN
					END
							
                    UPDATE STB_MachineRepairHistory
						SET
						    --MachineRepairHistoryNo =   CASE
						    --            WHEN @MachineRepairHistoryNo IS NOT NULL THEN @MachineRepairHistoryNo
						    --            ELSE MachineRepairHistoryNo
						    --        END,
						    --CompanyCode =   CASE
						    --            WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						    --            ELSE CompanyCode
						    --        END,
						    --WorkCenterCode =   CASE
						    --            WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						    --            ELSE WorkCenterCode
						    --        END,
						    --MachineCode =   CASE
						    --            WHEN @MachineCode IS NOT NULL THEN @MachineCode
						    --            ELSE MachineCode
						    --        END,
						   
						    MachineLossHistNo =   CASE
						                WHEN @MachineLossHistNo IS NOT NULL THEN @MachineLossHistNo
						                ELSE MachineLossHistNo
						            END,
						    TroublePoint =   CASE
						                WHEN @TroublePoint IS NOT NULL THEN @TroublePoint
						                ELSE TroublePoint
						            END,
						    TroubleText =   CASE
						                WHEN @TroubleText IS NOT NULL THEN @TroubleText
						                ELSE TroubleText
						            END,
						    RepairText =   CASE
						                WHEN @RepairText IS NOT NULL THEN @RepairText
						                ELSE RepairText
						            END,
						    IsMachineLoss =   CASE
						                WHEN @IsMachineLoss IS NOT NULL THEN @IsMachineLoss
						                ELSE IsMachineLoss
						            END,
						    --TotalRepairCost =   CASE
						    --            WHEN @TotalRepairCost IS NOT NULL THEN @TotalRepairCost
						    --            ELSE TotalRepairCost
						    --        END,
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
						    MachineRepairHistoryNo = @OldMachineRepairHistoryNo
						    
						--SET @pOutMachineRepairHistoryNo = @MachineRepairHistoryNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                
                    DELETE FROM STB_MachineRepairHistory
					WHERE
						    MachineRepairHistoryNo = @MachineRepairHistoryNo
					
						    
					EXEC usp_MachineRepairHistorySub_DELETE @pMachineRepairHistoryNo = @MachineRepairHistoryNo
					
					--SET @pOutMachineRepairHistoryNo = @MachineRepairHistoryNo 
					
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

