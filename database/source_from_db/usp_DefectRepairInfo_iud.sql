
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectRepairInfo_iud]
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
  DECLARE @OldDefectSummaryNo VARCHAR(20)
  DECLARE @DefectSummaryNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @ControlNo VARCHAR(20)
  DECLARE @PONo VARCHAR(20)
  DECLARE @DayPlanNo VARCHAR(20)
  DECLARE @FindJobdate DATE
  DECLARE @FindShiftCode VARCHAR(1)
  DECLARE @FindTimeCode VARCHAR(2)
  DECLARE @FindLineCode VARCHAR(20)
  DECLARE @FindRouteCode VARCHAR(20)
  DECLARE @FindSubRouteCode VARCHAR(20)
  DECLARE @FindFacilityRouteCode VARCHAR(20)
  DECLARE @CauseJobDate DATE
  DECLARE @CauseShiftCode VARCHAR(1)
  DECLARE @CauseTimeCode VARCHAR(2)
  DECLARE @CauseLineCode VARCHAR(20)
  DECLARE @CauseFacilityRouteCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @BomVersion VARCHAR(10)
  DECLARE @FindDateTime DATETIME
  DECLARE @DefectCauseType VARCHAR(1)
  DECLARE @DutyCostCenterCode VARCHAR(20)
  DECLARE @DutyVendorCode VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
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
  DECLARE @FileID BIGINT
  DECLARE @DRIExtText01 NVARCHAR(200)
  DECLARE @DRIExtText02 NVARCHAR(200)
  DECLARE @DRIExtText03 NVARCHAR(200)
  DECLARE @IsDelete VARCHAR(1)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @JobDateShift VARCHAR(20)


	DECLARE @iDoc INT
    
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								OldDefectSummaryNo,
								DefectSummaryNo,
								CompanyCode,
								WorkCenterCode,
								ControlNo,
								PONo,
								DayPlanNo,
								FindJobdate,
								FindShiftCode,
								FindTimeCode,
								FindLineCode,
								FindRouteCode,
								FindSubRouteCode,
								FindFacilityRouteCode,
								CauseJobDate,
								CauseShiftCode,
								CauseTimeCode,
								CauseLineCode,
								CauseFacilityRouteCode,
								MaterialCode,
								BomVersion,
								FindDateTime,
								DefectCauseType,
								DutyCostCenterCode,
								DutyVendorCode,
								DefectCode,
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
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
											OldDefectSummaryNo VARCHAR(20),
											DefectSummaryNo VARCHAR(20),
											CompanyCode VARCHAR(20),
											WorkCenterCode VARCHAR(20),
											ControlNo VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											FindJobdate DATETIMEOFFSET,
											FindShiftCode VARCHAR(1),
											FindTimeCode VARCHAR(1),
											FindLineCode VARCHAR(20),
											FindRouteCode VARCHAR(20),
											FindSubRouteCode VARCHAR(20),
											FindFacilityRouteCode VARCHAR(20),
											CauseJobDate DATETIMEOFFSET,
											CauseShiftCode VARCHAR(1),
											CauseTimeCode VARCHAR(1),
											CauseLineCode VARCHAR(20),
											CauseFacilityRouteCode VARCHAR(20),
											MaterialCode VARCHAR(50),
											BomVersion VARCHAR(10),
											FindDateTime DATETIMEOFFSET,
											DefectCauseType VARCHAR(1),
											DutyCostCenterCode VARCHAR(20),
											DutyVendorCode VARCHAR(20),
											DefectCode VARCHAR(20),
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
									WHEN OldDefectSummaryNo IS NULL THEN DefectSummaryNo
									ELSE OldDefectSummaryNo
								END AS OldDefectSummaryNo,
								DefectSummaryNo,
								CompanyCode,
								WorkCenterCode,
								ControlNo,
								PONo,
								DayPlanNo,
								FindJobdate,
								FindShiftCode,
								FindTimeCode,
								FindLineCode,
								FindRouteCode,
								FindSubRouteCode,
								FindFacilityRouteCode,
								CauseJobDate,
								CauseShiftCode,
								CauseTimeCode,
								CauseLineCode,
								CauseFacilityRouteCode,
								MaterialCode,
								BomVersion,
								FindDateTime,
								DefectCauseType,
								DutyCostCenterCode,
								DutyVendorCode,
								DefectCode,
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
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldDefectSummaryNo VARCHAR(20),
											DefectSummaryNo VARCHAR(20),
											CompanyCode VARCHAR(20),
											WorkCenterCode VARCHAR(20),
											ControlNo VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											FindJobdate DATETIMEOFFSET,
											FindShiftCode VARCHAR(1),
											FindTimeCode VARCHAR(1),
											FindLineCode VARCHAR(20),
											FindRouteCode VARCHAR(20),
											FindSubRouteCode VARCHAR(20),
											FindFacilityRouteCode VARCHAR(20),
											CauseJobDate DATETIMEOFFSET,
											CauseShiftCode VARCHAR(1),
											CauseTimeCode VARCHAR(1),
											CauseLineCode VARCHAR(20),
											CauseFacilityRouteCode VARCHAR(20),
											MaterialCode VARCHAR(50),
											BomVersion VARCHAR(10),
											FindDateTime DATETIMEOFFSET,
											DefectCauseType VARCHAR(1),
											DutyCostCenterCode VARCHAR(20),
											DutyVendorCode VARCHAR(20),
											DefectCode VARCHAR(20),
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
									WHEN OldDefectSummaryNo IS NULL THEN DefectSummaryNo
									ELSE OldDefectSummaryNo
								END AS OldDefectSummaryNo,
								DefectSummaryNo,
								CompanyCode,
								WorkCenterCode,
								ControlNo,
								PONo,
								DayPlanNo,
								FindJobdate,
								FindShiftCode,
								FindTimeCode,
								FindLineCode,
								FindRouteCode,
								FindSubRouteCode,
								FindFacilityRouteCode,
								CauseJobDate,
								CauseShiftCode,
								CauseTimeCode,
								CauseLineCode,
								CauseFacilityRouteCode,
								MaterialCode,
								BomVersion,
								FindDateTime,
								DefectCauseType,
								DutyCostCenterCode,
								DutyVendorCode,
								DefectCode,
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
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
											OldDefectSummaryNo VARCHAR(20),
											DefectSummaryNo VARCHAR(20),
											CompanyCode VARCHAR(20),
											WorkCenterCode VARCHAR(20),
											ControlNo VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											FindJobdate DATETIMEOFFSET,
											FindShiftCode VARCHAR(1),
											FindTimeCode VARCHAR(1),
											FindLineCode VARCHAR(20),
											FindRouteCode VARCHAR(20),
											FindSubRouteCode VARCHAR(20),
											FindFacilityRouteCode VARCHAR(20),
											CauseJobDate DATETIMEOFFSET,
											CauseShiftCode VARCHAR(1),
											CauseTimeCode VARCHAR(1),
											CauseLineCode VARCHAR(20),
											CauseFacilityRouteCode VARCHAR(20),
											MaterialCode VARCHAR(50),
											BomVersion VARCHAR(10),
											FindDateTime DATETIMEOFFSET,
											DefectCauseType VARCHAR(1),
											DutyCostCenterCode VARCHAR(20),
											DutyVendorCode VARCHAR(20),
											DefectCode VARCHAR(20),
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
								@OldDefectSummaryNo,
								@DefectSummaryNo,
								@CompanyCode,
								@WorkCenterCode,
								@ControlNo,
								@PONo,
								@DayPlanNo,
								@FindJobdate,
								@FindShiftCode,
								@FindTimeCode,
								@FindLineCode,
								@FindRouteCode,
								@FindSubRouteCode,
								@FindFacilityRouteCode,
								@CauseJobDate,
								@CauseShiftCode,
								@CauseTimeCode,
								@CauseLineCode,
								@CauseFacilityRouteCode,
								@MaterialCode,
								@BomVersion,
								@FindDateTime,
								@DefectCauseType,
								@DutyCostCenterCode,
								@DutyVendorCode,
								@DefectCode,
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

			DECLARE @IsLoss BIT
			DECLARE @IsProdFinish BIT
			DECLARE @Barcode VARCHAR(50)

			SELECT
					@Barcode = SI.Barcode,
					@IsLoss = SI.IsLoss,
					@IsProdFinish = SI.IsProdFinish
			FROM
					STB_SetInfo SI
			WHERE
					SI.ControlNo = @ControlNo

			IF @IsLoss = 1 BEGIN
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																		'^폐기된 제품입니다^',
																		@ERROR_MSG OUTPUT
					SET @ERROR_MSG = @ERROR_MSG + ' [%s]'
					RAISERROR(@ERROR_MSG,16,1,@Barcode)
					RETURN
			END

			IF @IsProdFinish = 1 BEGIN
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																		'^생산완료된 제품입니다^',
																		@ERROR_MSG OUTPUT
					SET @ERROR_MSG = @ERROR_MSG + ' [%s]'
					RAISERROR(@ERROR_MSG,16,1,@Barcode)
					RETURN
			END

			IF (@IUD_FLAG = 'UPDATE') AND (@DefectSummaryNo IS NULL)
			BEGIN
				SET @IUD_FLAG = 'INSERT'
			END

			DECLARE @ProcessDateTime DATETIME = GETDATE()
			SET @JobDateShift = dbo.fnGetJobDateShiftTimeV3(@ProcessDateTime,@WorkCenterCode)
			SET @CauseJobDate = SUBSTRING(@JobDateShift,1,8)
			SET @CauseShiftCode = SUBSTRING(@JobDateShift,9,1)
			SET @CauseTimeCode = SUBSTRING(@JobDateShift,10,2)
			
            IF @IUD_FLAG = 'INSERT' BEGIN
					EXEC usp_DoProcessDefectRepairInfoByBarcode	@pProcessUserID = @ProcessUserID,
																@pProcessLanguage = @ProcessLanguage,
																@pLineCode = @FindLineCode,
																@pRouteCode = @FindRouteCode,
																@pBarcode = @Barcode,
																@pDefectCode = @DefectCode,
																@pDefectQty = @DefectQty,
																@pProcessDateTime = @ProcessDateTime,
																@pDefectSummaryNo = @DefectSummaryNo OUTPUT
			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					DECLARE @OldLineCode VARCHAR(20)
					DECLARE @OldRouteCode VARCHAR(20)
					DECLARE @OldRepairType VARCHAR(10)
					DECLARE @OldFindJobDate DATE
					DECLARE @OldFindShiftCode VARCHAR(1)
					DECLARE @OldFindTimeCode VARCHAR(2)
					DECLARE @OldDefectQty NUMERIC(20,5)

					SELECT
							@OldLineCode = DRI.FindLineCode,
							@OldRouteCode = DRI.FindRouteCode,
							@OldRepairType = DRI.RepairType,
							@OldFindJobDate = DRI.FindJobdate,
							@OldFindShiftCode = DRI.FindShiftCode,
							@OldFindTimeCode = DRI.FindTimeCode,
							@OldDefectQty = DRI.DefectQty
					FROM
							STB_DefectRepairInfo DRI
					WHERE
							DRI.DefectSummaryNo = @DefectSummaryNo

					IF ISNULL(@OldRepairType,'NONE') <> 'NONE' BEGIN
							EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																				'^처리완료된  제품입니다^',
																				@ERROR_MSG OUTPUT
							SET @ERROR_MSG = @ERROR_MSG + ' [%s]'
							RAISERROR(@ERROR_MSG,16,1,@Barcode)
							RETURN
					END
							-- 검출라인,공정,수량이 다르면 Summary에서 빼준다
					IF @RepairType <> 'MISSING' AND (@OldLineCode <> @FindLineCode) OR (@OldRouteCode <> @FindRouteCode) OR (@OldDefectQty <> @DefectQty) BEGIN
							IF @OldDefectQty <> @DefectQty BEGIN
									DECLARE @DiffQty NUMERIC(20,5) = @DefectQty - @OldDefectQty

									UPDATE	STB_SetInfo
									SET
											DefectQty = DefectQty + @DiffQty,
											IsDefect = CONVERT(BIT,CASE WHEN DefectQty + @DiffQty > 0 THEN 1 ELSE 0 END)
									WHERE
											ControlNo = @ControlNo
							END

							SET @OldDefectQty = @OldDefectQty * -1
							EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
																@pWorkCenterCode = @WorkCenterCode,
																@pLineCode = @OldLineCode,
																@pRouteCode = @OldRouteCode,
																@pPONo = @PONo,
																@pJobDate = @OldFindJobDate,
																@pShiftCode = @OldFindShiftCode,
																@pTimeCode = @OldFindTimeCode,
																@pDefectQty = @OldDefectQty

							EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
																@pWorkCenterCode = @WorkCenterCode,
																@pLineCode = @FindLineCode,
																@pRouteCode = @FindRouteCode,
																@pPONo = @PONo,
																@pJobDate = @OldFindJobDate,
																@pShiftCode = @OldFindShiftCode,
																@pTimeCode = @OldFindTimeCode,
																@pDefectQty = @DefectQty
					END	--IF (@OldLineCode <> @FindLineCode) OR (@OldRouteCode <> @FindRouteCode) OR (@OldDefectQty <> @DefectQty) BEGIN
			END	--END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

			IF @RepairType = 'MISSING' BEGIN
					SET @OldDefectQty = @OldDefectQty * -1
					EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
														@pWorkCenterCode = @WorkCenterCode,
														@pLineCode = @OldLineCode,
														@pRouteCode = @OldRouteCode,
														@pPONo = @PONo,
														@pJobDate = @OldFindJobDate,
														@pShiftCode = @OldFindShiftCode,
														@pTimeCode = @OldFindTimeCode,
														@pDefectQty = @OldDefectQty
			END ELSE BEGIN
					SET @RepairQty = @DefectQty
					SET @LossQty = 0
					IF @RepairType = 'LOSS' BEGIN
							UPDATE	STB_SetInfo
							SET
									IsLoss = 1
							WHERE
									ControlNo = @ControlNo

							SET @RepairQty = 0
							SET @LossQty = @DefectQty
					END

					EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
														@pWorkCenterCode = @WorkCenterCode,
														@pLineCode = @FindLineCode,
														@pRouteCode = @FindRouteCode,
														@pPONo = @PONo,
														@pJobDate = @CauseJobDate,
														@pShiftCode = @CauseShiftCode,
														@pTimeCode = @CauseTimeCode,
														@pRepairQty = @RepairQty,
														@pLossQty = @LossQty
			END

            UPDATE STB_DefectRepairInfo
			SET
				FindJobdate =   ISNULL(@FindJobdate,FindJobdate),
				FindShiftCode =   ISNULL(@FindShiftCode,FindShiftCode),
				FindTimeCode =   ISNULL(@FindTimeCode,FindTimeCode),
				FindLineCode =   ISNULL(@FindLineCode,FindLineCode),
				FindRouteCode =   ISNULL(@FindRouteCode,FindRouteCode),
				--FindSubRouteCode =   ISNULL(@FindSubRouteCode,FindSubRouteCode),
				--FindFacilityRouteCode =   ISNULL(@FindFacilityRouteCode,FindFacilityRouteCode),
				--CauseFacilityRouteCode =   ISNULL(@CauseFacilityRouteCode,CauseFacilityRouteCode),
				MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
				BomVersion =   ISNULL(@BomVersion,BomVersion),
				FindDateTime =   ISNULL(@FindDateTime,FindDateTime),
				CauseJobDate = ISNULL(CauseJobDate,@CauseJobDate),
				CauseShiftCode = ISNULL(CauseShiftCode,@CauseShiftCode),
				CauseTimeCode = ISNULL(CauseTimeCode,@CauseTimeCode),
				DefectCauseType =   ISNULL(@DefectCauseType,DefectCauseType),
				DutyCostCenterCode =   ISNULL(@DutyCostCenterCode,DutyCostCenterCode),
				DutyVendorCode =   ISNULL(@DutyVendorCode,DutyVendorCode),
				DefectCode =   ISNULL(@DefectCode,DefectCode),
				DefectCauseCode =   ISNULL(@DefectCauseCode,DefectCauseCode),
				DefectCauseDetailCode =   ISNULL(@DefectCauseDetailCode,DefectCauseDetailCode),
				DefectExtDesc =   ISNULL(@DefectExtDesc,DefectExtDesc),
				RepairType =   ISNULL(@RepairType,RepairType),
				RepairUserID =   ISNULL(@RepairUserID,RepairUserID),
				RepairDateTime =   ISNULL(@RepairDateTime,RepairDateTime),
				RepairDesc =   ISNULL(@RepairDesc,RepairDesc),
				DefectQty =   ISNULL(@DefectQty,DefectQty),
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
