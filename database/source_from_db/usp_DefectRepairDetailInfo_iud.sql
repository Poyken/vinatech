
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-31
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectRepairDetailInfo_iud]
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

    -- Declare Columns Variable
    DECLARE @OldDefectSummaryDetailNo VARCHAR(20)
    DECLARE @DefectSummaryDetailNo VARCHAR(20)
    DECLARE @DefectSummaryNo VARCHAR(20)
    DECLARE @CauseJobDate DATE
    DECLARE @CauseShiftCode VARCHAR(1)
    DECLARE @CauseTimeCode VARCHAR(1)
    DECLARE @CauseLineCode VARCHAR(20)
    DECLARE @CauseFacilityRouteCode VARCHAR(20)
    DECLARE @DefectCauseType VARCHAR(1)
    DECLARE @DutyCostCenterCode VARCHAR(20)
    DECLARE @DutyVendorCode VARCHAR(20)
    DECLARE @DefectCauseCode VARCHAR(20)
    DECLARE @DefectCauseDetailCode VARCHAR(20)
    DECLARE @DefectExtDesc NVARCHAR(200)
    DECLARE @RepairType VARCHAR(10)
    DECLARE @RepairUserID VARCHAR(20)
    DECLARE @RepairDateTime DATETIME
    DECLARE @RepairDesc NVARCHAR(MAX)
    DECLARE @DefectQty NUMERIC(20,5)
    DECLARE @RepairQty NUMERIC(20,5)
    DECLARE @LossQty NUMERIC(20,5)
	DECLARE @ProcessQty NUMERIC(20,5)
    DECLARE @FileID BIGINT
    DECLARE @DRIExtText01 NVARCHAR(200)
    DECLARE @DRIExtText02 NVARCHAR(200)
    DECLARE @DRIExtText03 NVARCHAR(200)
    DECLARE @IsDelete VARCHAR(1)
    DECLARE @CreateDateTime DATETIME
    DECLARE @CreateUserID VARCHAR(20)
    DECLARE @ChangeDateTime DATETIME
    DECLARE @ChangeUserID VARCHAR(20)
    
    DECLARE @CompanyCode VARCHAR(20)
    DECLARE @WorkCenterCode VARCHAR(20)
    DECLARE @LineCode VARCHAR(20)
    DECLARE @RouteCode VARCHAR(20)
    DECLARE @PONo VARCHAR(20)
    DECLARE @FindJobDate DATE
    DECLARE @FindShiftCode VARCHAR(1)
    DECLARE @FindTimeCode VARCHAR(2)
	DECLARE @JobDateShift VARCHAR(20)

	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	BEGIN TRY
		DECLARE SourceData CURSOR FOR
			SELECT
				'INSERT' AS IUD_FLAG,
						OldDefectSummaryDetailNo,
						DefectSummaryDetailNo,
						DefectSummaryNo,
						CauseJobDate,
						CauseShiftCode,
						CauseTimeCode,
						CauseLineCode,
						CauseFacilityRouteCode,
						DefectCauseType,
						DutyCostCenterCode,
						DutyVendorCode,
						DefectCauseCode,
						DefectCauseDetailCode,
						DefectExtDesc,
						RepairType,
						RepairUserID,
						RepairDateTime,
						RepairDesc,
						DefectQty,
						RepairQty,
						LossQty,
						ProcessQty,
						FileID,
						DRIExtText01,
						DRIExtText02,
						DRIExtText03,
						IsDelete,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
				FROM
						OPENXML(@idoc , @InsertTableName , 2)
						WITH  (
									OldDefectSummaryDetailNo VARCHAR(20),
									DefectSummaryDetailNo VARCHAR(20),
									DefectSummaryNo VARCHAR(20),
									CauseJobDate DATETIMEOFFSET,
									CauseShiftCode VARCHAR(1),
									CauseTimeCode VARCHAR(1),
									CauseLineCode VARCHAR(20),
									CauseFacilityRouteCode VARCHAR(20),
									DefectCauseType VARCHAR(1),
									DutyCostCenterCode VARCHAR(20),
									DutyVendorCode VARCHAR(20),
									DefectCauseCode VARCHAR(20),
									DefectCauseDetailCode VARCHAR(20),
									DefectExtDesc NVARCHAR(200),
									RepairType VARCHAR(10),
									RepairUserID VARCHAR(20),
									RepairDateTime DATETIMEOFFSET,
									RepairDesc NVARCHAR(MAX),
									DefectQty NUMERIC(20,5),
									RepairQty NUMERIC(20,5),
									LossQty NUMERIC(20,5),
									ProcessQty NUMERIC(20,5),
									FileID BIGINT,
									DRIExtText01 NVARCHAR(200),
									DRIExtText02 NVARCHAR(200),
									DRIExtText03 NVARCHAR(200),
									IsDelete VARCHAR(1),
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20)
								)
				UNION ALL
				SELECT
						'UPDATE' AS IUD_FLAG,
						CASE 
							WHEN OldDefectSummaryDetailNo IS NULL THEN DefectSummaryDetailNo
							ELSE OldDefectSummaryDetailNo
						END AS OldDefectSummaryDetailNo,
						DefectSummaryDetailNo,
						DefectSummaryNo,
						CauseJobDate,
						CauseShiftCode,
						CauseTimeCode,
						CauseLineCode,
						CauseFacilityRouteCode,
						DefectCauseType,
						DutyCostCenterCode,
						DutyVendorCode,
						DefectCauseCode,
						DefectCauseDetailCode,
						DefectExtDesc,
						RepairType,
						RepairUserID,
						RepairDateTime,
						RepairDesc,
						DefectQty,
						RepairQty,
						LossQty,
						ProcessQty,
						FileID,
						DRIExtText01,
						DRIExtText02,
						DRIExtText03,
						IsDelete,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
						WITH  (
									OldDefectSummaryDetailNo VARCHAR(20),
									DefectSummaryDetailNo VARCHAR(20),
									DefectSummaryNo VARCHAR(20),
									CauseJobDate DATETIMEOFFSET,
									CauseShiftCode VARCHAR(1),
									CauseTimeCode VARCHAR(1),
									CauseLineCode VARCHAR(20),
									CauseFacilityRouteCode VARCHAR(20),
									DefectCauseType VARCHAR(1),
									DutyCostCenterCode VARCHAR(20),
									DutyVendorCode VARCHAR(20),
									DefectCauseCode VARCHAR(20),
									DefectCauseDetailCode VARCHAR(20),
									DefectExtDesc NVARCHAR(200),
									RepairType VARCHAR(10),
									RepairUserID VARCHAR(20),
									RepairDateTime DATETIMEOFFSET,
									RepairDesc NVARCHAR(MAX),
									DefectQty NUMERIC(20,5),
									RepairQty NUMERIC(20,5),
									LossQty NUMERIC(20,5),
									ProcessQty NUMERIC(20,5),
									FileID BIGINT,
									DRIExtText01 NVARCHAR(200),
									DRIExtText02 NVARCHAR(200),
									DRIExtText03 NVARCHAR(200),
									IsDelete VARCHAR(1),
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20)
								)
				UNION ALL
				SELECT
						'DELETE' AS IUD_FLAG,
						CASE 
							WHEN OldDefectSummaryDetailNo IS NULL THEN DefectSummaryDetailNo
							ELSE OldDefectSummaryDetailNo
						END AS OldDefectSummaryDetailNo,
						DefectSummaryDetailNo,
						DefectSummaryNo,
						CauseJobDate,
						CauseShiftCode,
						CauseTimeCode,
						CauseLineCode,
						CauseFacilityRouteCode,
						DefectCauseType,
						DutyCostCenterCode,
						DutyVendorCode,
						DefectCauseCode,
						DefectCauseDetailCode,
						DefectExtDesc,
						RepairType,
						RepairUserID,
						RepairDateTime,
						RepairDesc,
						DefectQty,
						RepairQty,
						LossQty,
						ProcessQty,
						FileID,
						DRIExtText01,
						DRIExtText02,
						DRIExtText03,
						IsDelete,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
				FROM
						OPENXML(@idoc , @DeleteTableName , 2)
						WITH  (
									OldDefectSummaryDetailNo VARCHAR(20),
									DefectSummaryDetailNo VARCHAR(20),
									DefectSummaryNo VARCHAR(20),
									CauseJobDate DATETIMEOFFSET,
									CauseShiftCode VARCHAR(1),
									CauseTimeCode VARCHAR(1),
									CauseLineCode VARCHAR(20),
									CauseFacilityRouteCode VARCHAR(20),
									DefectCauseType VARCHAR(1),
									DutyCostCenterCode VARCHAR(20),
									DutyVendorCode VARCHAR(20),
									DefectCauseCode VARCHAR(20),
									DefectCauseDetailCode VARCHAR(20),
									DefectExtDesc NVARCHAR(200),
									RepairType VARCHAR(10),
									RepairUserID VARCHAR(20),
									RepairDateTime DATETIMEOFFSET,
									RepairDesc NVARCHAR(MAX),
									DefectQty NUMERIC(20,5),
									RepairQty NUMERIC(20,5),
									LossQty NUMERIC(20,5),
									ProcessQty NUMERIC(20,5),
									FileID BIGINT,
									DRIExtText01 NVARCHAR(200),
									DRIExtText02 NVARCHAR(200),
									DRIExtText03 NVARCHAR(200),
									IsDelete VARCHAR(1),
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20)
								) 


		OPEN SourceData

		WHILE 1 = 1 BEGIN
			FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldDefectSummaryDetailNo,
								@DefectSummaryDetailNo,
								@DefectSummaryNo,
								@CauseJobDate,
								@CauseShiftCode,
								@CauseTimeCode,
								@CauseLineCode,
								@CauseFacilityRouteCode,
								@DefectCauseType,
								@DutyCostCenterCode,
								@DutyVendorCode,
								@DefectCauseCode,
								@DefectCauseDetailCode,
								@DefectExtDesc,
								@RepairType,
								@RepairUserID,
								@RepairDateTime,
								@RepairDesc,
								@DefectQty,
								@RepairQty,
								@LossQty,
								@ProcessQty,
								@FileID,
								@DRIExtText01,
								@DRIExtText02,
								@DRIExtText03,
								@IsDelete,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID


        IF @@FETCH_STATUS <> 0 BEGIN
			BREAK
		END

		SELECT
				@CompanyCode = DRI.CompanyCode,
				@WorkCenterCode = DRI.WorkCenterCode,
				@LineCode = DRI.FindLineCode,
				@RouteCode = DRI.FindRouteCode,
				@PONo = DRI.PONo,
				@FindJobDate = DRI.FindJobdate,
				@FindShiftCode = DRI.FindShiftCode,
				@FindTimeCode = DRI.FindTimeCode,
				@DefectQty = DRI.DefectQty
		FROM
				STB_DefectRepairInfo DRI
		WHERE
				DRI.DefectSummaryNo = @DefectSummaryNo

		DECLARE @OldRepairType VARCHAR(10)
		DECLARE @CurrentQty NUMERIC(20,5)

		SELECT
				@OldRepairType = DRDI.RepairType
		FROM
				STB_DefectRepairDetailInfo DRDI
		WHERE
				DRDI.DefectSummaryNo = @DefectSummaryNo AND
				DRDI.DefectSummaryDetailNo = @DefectSummaryDetailNo

		SELECT
				@CurrentQty = SUM(DRDI.LossQty) + SUM(DRDI.RepairQty)
		FROM
				STB_DefectRepairDetailInfo DRDI
		WHERE
				DRDI.DefectSummaryNo = @DefectSummaryNo

		IF @DefectQty < @ProcessQty + @CurrentQty BEGIN
				EXEC usp_RaiseLocalizedError @ProcessLanguage, '불량수량보다 처리수량이 더 많습니다'
				RETURN
		END

		SET @JobDateShift = dbo.fnGetJobDateShiftTimeV3(GETDATE(),@WorkCenterCode)
		SET @CauseJobDate = SUBSTRING(@JobDateShift,1,8)
		SET @CauseShiftCode = SUBSTRING(@JobDateShift,9,1)
		SET @CauseTimeCode = SUBSTRING(@JobDateShift,10,2)

		IF @RepairType = 'MISSING' BEGIN
				SET @RepairQty = 0
				SET @LossQty = 0
				SET @DefectQty = @ProcessQty
				DECLARE @MissingQty NUMERIC(20,5) = @ProcessQty * -1

				EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
													@pWorkCenterCode = @WorkCenterCode,
													@pLineCode = @LineCode,
													@pRouteCode = @RouteCode,
													@pPONo = @PONo,
													@pJobDate = @FindJobDate,
													@pShiftCode = @FindShiftCode,
													@pTimeCode = @FindTimeCode,
													@pDefectQty = @MissingQty

				UPDATE	STB_DefectRepairInfo
				SET
						DefectQty = DefectQty - @ProcessQty
				WHERE
						DefectSummaryNo = @DefectSummaryNo
		END ELSE BEGIN
				SET @DefectQty = 0
				IF @RepairType = 'LOSS' BEGIN
						SET @LossQty = @ProcessQty
						SET @RepairQty = 0
				END ELSE BEGIN
						SET @RepairQty = @ProcessQty
						SET @LossQty = 0
				END

				EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
													@pWorkCenterCode = @WorkCenterCode,
													@pLineCode = @CauseLineCode,
													@pRouteCode = @RouteCode,
													@pPONo = @PONo,
													@pJobDate = @CauseJobDate,
													@pShiftCode = @CauseShiftCode,
													@pTimeCode = @CauseTimeCode,
													@pRepairQty = @RepairQty,
													@pLossQty = @LossQty
		END


        IF @IUD_FLAG = 'INSERT' BEGIN
                EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DefectRepairDetailInfo',@DefectSummaryDetailNo OUTPUT

				IF OBJECT_ID(N'tempdb..#SEQUENCE_TABLE', N'U') IS NOT NULL BEGIN
					-- 임시 SEQUENCE TABLE 사용 버젼
					INSERT INTO #SEQUENCE_TABLE
						(KeyValue, UID_KEY)
					VALUES
						(@DefectSummaryDetailNo, @OldDefectSummaryDetailNo)							
				END

				INSERT INTO STB_DefectRepairDetailInfo
					(
						DefectSummaryDetailNo,
						DefectSummaryNo,
						CauseJobDate,
						CauseShiftCode,
						CauseTimeCode,
						CauseLineCode,
						CauseFacilityRouteCode,
						DefectCauseType,
						DutyCostCenterCode,
						DutyVendorCode,
						DefectCauseCode,
						DefectCauseDetailCode,
						DefectExtDesc,
						RepairType,
						RepairUserID,
						RepairDateTime,
						RepairDesc,
						DefectQty,
						RepairQty,
						LossQty,
						FileID,
						DRIExtText01,
						DRIExtText02,
						DRIExtText03,
						IsDelete,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
						@DefectSummaryDetailNo,
						@DefectSummaryNo,
						@CauseJobDate,
						@CauseShiftCode,
						@CauseTimeCode,
						@CauseLineCode,
						@CauseFacilityRouteCode,
						@DefectCauseType,
						@DutyCostCenterCode,
						@DutyVendorCode,
						@DefectCauseCode,
						@DefectCauseDetailCode,
						@DefectExtDesc,
						@RepairType,
						@ProcessUserID,
						GETDATE(),
						@RepairDesc,
						@DefectQty,
						@RepairQty,
						@LossQty,
						@FileID,
						@DRIExtText01,
						@DRIExtText02,
						@DRIExtText03,
						@IsDelete,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)
			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                UPDATE STB_DefectRepairDetailInfo
					SET
						DefectSummaryDetailNo =   ISNULL(@DefectSummaryDetailNo,DefectSummaryDetailNo),
						DefectSummaryNo =   ISNULL(@DefectSummaryNo,DefectSummaryNo),
						CauseLineCode =   ISNULL(@CauseLineCode,CauseLineCode),
						CauseFacilityRouteCode =   ISNULL(@CauseFacilityRouteCode,CauseFacilityRouteCode),
						CauseJobDate = ISNULL(CauseJobDate,@CauseJobDate),
						CauseShiftCode = ISNULL(CauseShiftCode,@CauseShiftCode),
						CauseTimeCode = ISNULL(CauseTimeCode,@CauseTimeCode),
						DefectCauseType =   ISNULL(@DefectCauseType,DefectCauseType),
						DutyCostCenterCode =   ISNULL(@DutyCostCenterCode,DutyCostCenterCode),
						DutyVendorCode =   ISNULL(@DutyVendorCode,DutyVendorCode),
						DefectCauseCode =   ISNULL(@DefectCauseCode,DefectCauseCode),
						DefectCauseDetailCode =   ISNULL(@DefectCauseDetailCode,DefectCauseDetailCode),
						DefectExtDesc =   ISNULL(@DefectExtDesc,DefectExtDesc),
						RepairDesc =   ISNULL(@RepairDesc,RepairDesc),
						RepairQty =   ISNULL(@RepairQty,RepairQty),
						LossQty =   ISNULL(@LossQty,LossQty),
						FileID =   ISNULL(@FileID,FileID),
						DRIExtText01 =   ISNULL(@DRIExtText01,DRIExtText01),
						DRIExtText02 =   ISNULL(@DRIExtText02,DRIExtText02),
						DRIExtText03 =   ISNULL(@DRIExtText03,DRIExtText03),
						IsDelete =   ISNULL(@IsDelete,IsDelete),
						CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID
					WHERE
						DefectSummaryDetailNo = @OldDefectSummaryDetailNo
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM STB_DefectRepairDetailInfo
					WHERE
						DefectSummaryDetailNo = @OldDefectSummaryDetailNo
            END

			SELECT
					@RepairQty = SUM(DRDI.RepairQty),
					@LossQty = SUM(DRDI.LossQty)
			FROM
					STB_DefectRepairDetailInfo DRDI
			WHERE
					DRDI.DefectSummaryNo = @DefectSummaryNo

			UPDATE	STB_DefectRepairInfo
			SET
					RepairQty = ISNULL(@RepairQty,0),
					LossQty = ISNULL(@LossQty,0),
					RepairType = CASE WHEN DefectQty > ISNULL(@RepairQty,0) + ISNULL(@LossQty,0) THEN 'NONE' ELSE 'FINISH' END
			WHERE
					DefectSummaryNo = @DefectSummaryNo
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
