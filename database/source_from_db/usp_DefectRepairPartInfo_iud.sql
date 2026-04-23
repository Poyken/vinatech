
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectRepairPartInfo_iud]
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
	DECLARE @OldDefectSummaryNo VARCHAR(20)
	DECLARE @OldMaterialCode VARCHAR(50)
	DECLARE @DefectSummaryNo VARCHAR(20)
	DECLARE @DefectSummaryDetailNo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @DefectCauseType VARCHAR(20)
	DECLARE @DutyCostCenterCode VARCHAR(20)
	DECLARE @DutyVendorCode VARCHAR(20)
	DECLARE @DefectCode VARCHAR(20)
	DECLARE @DefectCauseCode VARCHAR(20)
	DECLARE @DefectCauseDesc NVARCHAR(200)
	DECLARE @LossQty NUMERIC(20,5)
	DECLARE @ProcessQty NUMERIC(20,5)
	DECLARE @IsChangeMaterial BIT
	DECLARE @ChangePartBarcode VARCHAR(50)
	DECLARE @ChangePartSerial VARCHAR(50)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @IsUseFlush BIT
	DECLARE @IsUseBackFlush BIT
	DECLARE @MaterialDocNo VARCHAR(20)
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @LineCode VARCHAR(20)
	DECLARE @RouteCode VARCHAR(20)

	DECLARE @iDoc INT
    
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	BEGIN TRY
		DECLARE SourceData CURSOR FOR
			SELECT
					'INSERT' AS IUD_FLAG,
								OldDefectSummaryNo,
								OldMaterialCode,
								DefectSummaryNo,
								DefectSummaryDetailNo,
								MaterialCode,
								DefectCauseType,
								DutyCostCenterCode,
								DutyVendorCode,
								DefectCode,
								DefectCauseCode,
								DefectCauseDesc,
								LossQty,
								ProcessQty,
								IsChangeMaterial,
								ChangePartBarcode,
								ChangePartSerial,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
								WITH  (
											OldDefectSummaryNo VARCHAR(20),
											OldMaterialCode VARCHAR(50),
											DefectSummaryNo VARCHAR(20),
											DefectSummaryDetailNo VARCHAR(20),
											MaterialCode VARCHAR(50),
											DefectCauseType VARCHAR(20),
											DutyCostCenterCode VARCHAR(20),
											DutyVendorCode VARCHAR(20),
											DefectCode VARCHAR(20),
											DefectCauseCode VARCHAR(20),
											DefectCauseDesc NVARCHAR(200),
											LossQty NUMERIC(20,5),
											ProcessQty NUMERIC(20,5),
											IsChangeMaterial BIT,
											ChangePartBarcode VARCHAR(50),
											ChangePartSerial VARCHAR(50),
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
								CASE 
									WHEN OldMaterialCode IS NULL THEN MaterialCode
									ELSE OldMaterialCode
								END AS OldMaterialCode,
								DefectSummaryNo,
								DefectSummaryDetailNo,
								MaterialCode,
								DefectCauseType,
								DutyCostCenterCode,
								DutyVendorCode,
								DefectCode,
								DefectCauseCode,
								DefectCauseDesc,
								LossQty,
								ProcessQty,
								IsChangeMaterial,
								ChangePartBarcode,
								ChangePartSerial,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
								WITH  (
											OldDefectSummaryNo VARCHAR(20),
											OldMaterialCode VARCHAR(50),
											DefectSummaryNo VARCHAR(20),
											DefectSummaryDetailNo VARCHAR(20),
											MaterialCode VARCHAR(50),
											DefectCauseType VARCHAR(20),
											DutyCostCenterCode VARCHAR(20),
											DutyVendorCode VARCHAR(20),
											DefectCode VARCHAR(20),
											DefectCauseCode VARCHAR(20),
											DefectCauseDesc NVARCHAR(200),
											LossQty NUMERIC(20,5),
											ProcessQty NUMERIC(20,5),
											IsChangeMaterial BIT,
											ChangePartBarcode VARCHAR(50),
											ChangePartSerial VARCHAR(50),
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
								CASE 
									WHEN OldMaterialCode IS NULL THEN MaterialCode
									ELSE OldMaterialCode
								END AS OldMaterialCode,
								DefectSummaryNo,
								DefectSummaryDetailNo,
								MaterialCode,
								DefectCauseType,
								DutyCostCenterCode,
								DutyVendorCode,
								DefectCode,
								DefectCauseCode,
								DefectCauseDesc,
								LossQty,
								ProcessQty,
								IsChangeMaterial,
								ChangePartBarcode,
								ChangePartSerial,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
								WITH  (
											OldDefectSummaryNo VARCHAR(20),
											OldMaterialCode VARCHAR(50),
											DefectSummaryNo VARCHAR(20),
											DefectSummaryDetailNo VARCHAR(20),
											MaterialCode VARCHAR(50),
											DefectCauseType VARCHAR(20),
											DutyCostCenterCode VARCHAR(20),
											DutyVendorCode VARCHAR(20),
											DefectCode VARCHAR(20),
											DefectCauseCode VARCHAR(20),
											DefectCauseDesc NVARCHAR(200),
											LossQty NUMERIC(20,5),
											ProcessQty NUMERIC(20,5),
											IsChangeMaterial BIT,
											ChangePartBarcode VARCHAR(50),
											ChangePartSerial VARCHAR(50),
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
								@OldMaterialCode,
								@DefectSummaryNo,
								@DefectSummaryDetailNo,
								@MaterialCode,
								@DefectCauseType,
								@DutyCostCenterCode,
								@DutyVendorCode,
								@DefectCode,
								@DefectCauseCode,
								@DefectCauseDesc,
								@LossQty,
								@ProcessQty,
								@IsChangeMaterial,
								@ChangePartBarcode,
								@ChangePartSerial,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID


			IF @@FETCH_STATUS <> 0 BEGIN
				IF ISNULL(@MaterialDocNo,'') <> '' BEGIN
						EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @ProcessLanguage,
														@pProcessUserID = @ProcessUserID,
														@pMaterialDocNo = @MaterialDocNo

						EXEC usp_DoFixMaterialDoc	@pProcessUserID = @ProcessUserID,
													@pProcessLanguage = @ProcessLanguage,
													@pMaterialDocNo = @MaterialDocNo
				END
				BREAK
			END

			-- 
			--IF NOT EXISTS (
			--				SELECT	1
			--				FROM
			--						STB_DefectRepairPartInfo DRPI
			--				WHERE
			--						DRPI.DefectSummaryNo = @DefectSummaryNo AND
			--						DRPI.MaterialCode = @MaterialCode
			--				) BEGIN
			--		SET @IUD_FLAG = 'INSERT'
			--END
			SET @IUD_FLAG = 'INSERT'
			
			IF OBJECT_ID(N'tempdb..#SEQUENCE_TABLE', N'U') IS NOT NULL BEGIN
					SELECT
							@DefectSummaryDetailNo = KeyValue
					FROM
							#SEQUENCE_TABLE
					WHERE
							UID_KEY = @DefectSummaryDetailNo
			END


			SELECT
					@CompanyCode = DRI.CompanyCode,
					@WorkCenterCode = DRI.WorkCenterCode,
					@PONo = DRI.PONo,
					@LineCode = DRI.FindLineCode,
					@RouteCode = DRI.FindRouteCode,
					@IsUseBackFlush = MM.IsUseBackFlush,
					@IsUseFlush = MM.IsUseFlush
			FROM
					STB_DefectRepairInfo DRI
					LEFT OUTER JOIN STB_MaterialMaster MM
						ON MM.MaterialCode = DRI.MaterialCode
			WHERE
					DRI.DefectSummaryNo = @DefectSummaryNo

			IF @IsUseBackFlush = 1 OR @IsUseFlush = 1 BEGIN
					PRINT '문서생성하여 자재 차감'
					EXEC usp_DoProcessLossGIMaterial	@pProcessUserID = @ProcessUserID,
														@pProcessLanguage = @ProcessLanguage,
														@pCompanyCode = @CompanyCode,
														@pWorkCenterCode = @WorkCenterCode,
														@pPONo = @PONo,
														@pLineCode = @LineCode,
														@pRouteCode = @RouteCode,
														@pMaterialCode = @MaterialCode,
														@pProdQty = @LossQty,
														@pFPItemWorkNo = @DefectSummaryNo,
														@pMaterialDocNo = @MaterialDocNo OUTPUT
			END	-- 자재관리 하지 않는 자재는 이력만

			IF @IUD_FLAG = 'INSERT' BEGIN
				INSERT INTO STB_DefectRepairPartInfo
					(
						DefectSummaryNo,
						DefectSummaryDetailNo,
						MaterialCode,
						DefectCauseType,
						DutyCostCenterCode,
						DutyVendorCode,
						DefectCode,
						DefectCauseCode,
						DefectCauseDesc,
						LossQty,
						IsChangeMaterial,
						ChangePartBarcode,
						ChangePartSerial,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
						@DefectSummaryNo,
						@DefectSummaryDetailNo,
						@MaterialCode,
						@DefectCauseType,
						@DutyCostCenterCode,
						@DutyVendorCode,
						@DefectCode,
						@DefectCauseCode,
						@DefectCauseDesc,
						@ProcessQty,
						@IsChangeMaterial,
						@ChangePartBarcode,
						@ChangePartSerial,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				UPDATE STB_DefectRepairPartInfo
					SET
						MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						DefectCauseType =   ISNULL(@DefectCauseType,DefectCauseType),
						DutyCostCenterCode =   ISNULL(@DutyCostCenterCode,DutyCostCenterCode),
						DutyVendorCode =   ISNULL(@DutyVendorCode,DutyVendorCode),
						DefectCode =   ISNULL(@DefectCode,DefectCode),
						DefectCauseCode =   ISNULL(@DefectCauseCode,DefectCauseCode),
						DefectCauseDesc =   ISNULL(@DefectCauseDesc,DefectCauseDesc),
						LossQty =   LossQty + @ProcessQty,
						ChangePartBarcode =   ISNULL(@ChangePartBarcode,ChangePartBarcode),
						ChangePartSerial =   ISNULL(@ChangePartSerial,ChangePartSerial),
						CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID
					WHERE
						DefectSummaryNo = @OldDefectSummaryNo AND
						DefectSummaryDetailNo = @DefectSummaryDetailNo AND
						MaterialCode = @OldMaterialCode
			END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
				DELETE FROM STB_DefectRepairPartInfo
					WHERE
						DefectSummaryNo = @OldDefectSummaryNo AND
						MaterialCode = @OldMaterialCode
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
