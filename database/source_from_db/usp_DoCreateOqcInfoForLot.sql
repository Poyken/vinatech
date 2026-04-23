
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 품질관리
-- Description: 출하검사 Lot을 생성합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateOqcInfoForLot]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pMaterialQcNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = ISNULL(@pMaterialQcNo,''),
			@Barcode VARCHAR(50) = @pBarcode,
			@ControlNo VARCHAR(20),
			@CurrentMaterialCode VARCHAR(50),
			@MaterialCode VARCHAR(50),
			@QcQty NUMERIC(20,5),
			@ErrorMessage NVARCHAR(500),
			@LotNumber VARCHAR(50),
			@MaxSampleQty INT,
			@MaxDefectQty INT
			
	SELECT
			@ControlNo = SI.ControlNo,
			@QcQty = CASE WHEN ISNULL(@pProdQty,0) = 0 THEN SI.ProdQty ELSE @pProdQty END,
			@LotNumber = SI.LotNumber
	FROM
			STB_SetInfo SI
	WHERE
			SI.Barcode = @Barcode

	IF ISNULL(@LotNumber,'') <> '' BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																'^이미 Lot이 구성되어있습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]/[%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@LotNumber)
			RETURN
	END
			
	IF ISNULL(@ControlNo,'') = '' BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																'^존재하지 않는 바코드입니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END

	IF ISNULL(@MaterialQcNo,'') = '' BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialQCInfo', @MaterialQcNo OUTPUT
			
			INSERT INTO STB_MaterialQcInfo
				(
					MaterialQcNo,
					CompanyCode,
					WorkCenterCode,
					InspectionDocType,
					MaterialCode,
					QcQty,
					InspectionType,
					BasicDate,
					TargetSampleQty,
					ActualSampleQty,
					DestoryInspectionQty,
					ProcessQty,
					MaxAcceptDefectQty,
					PassedSampleQty,
					DefectSampleQty,
					DecisionResult,
					CreateDateTime,
					CreateUserID
				)
				SELECT
						@MaterialQcNo,
						POI.CompanyCode,
						POI.WorkCenterCode,
						'OQC',
						SI.MaterialCode,
						@QcQty,
						MBI.InspectionType,
						GETDATE(),
						0 AS TargetSampleQty,
						0 AS ActualSampleQty,
						0 AS DestoryInspectionQty,
						0 AS GrProcessQty,
						0 AS MaxAcceptDefectQty,
						0 AS PassedSampleQty,
						0 AS DefectSampleQty,
						'None' AS DecisionResult,
						GETDATE(),
						@pProcessUserID
				FROM
						STB_SetInfo SI
						INNER JOIN STB_ProductionOrderInfo POI
							ON POI.PONo = SI.PONo
						INNER JOIN STB_ModelBasicInfo MBI
							ON MBI.ModelCode = SI.MaterialCode
				WHERE
						SI.ControlNo = @ControlNo

				--IF @@ROWCOUNT = 0 BEGIN
				--		--RAISERROR('%/%',16,1,@ControlNo,@MaterialQcNo)
				--		--RETURN
				--END

				EXEC usp_DoMakeMaterialIQCDetailList	@pProcessUserID = @pProcessUserID,
														@pProcessLanguage = @pProcessLanguage,
														@pMaterialQcNo = @MaterialQcNo

				SET @MaxSampleQty = (SELECT ISNULL(MAX(RequestSampleQty), 0) FROM STB_MaterialQcDetail WHERE MaterialQcNo = @MaterialQcNo)
				SET @MaxDefectQty = (SELECT ISNULL(MAX(MaxAcceptDefectQty), 0) FROM STB_MaterialQcDetail WHERE MaterialQcNo = @MaterialQcNo)

				UPDATE STB_MaterialQcInfo
				SET
						TargetSampleQty = @MaxSampleQty,
						MaxAcceptDefectQty = @MaxDefectQty
				WHERE
						MaterialQcNo = @MaterialQcNo
	END ELSE BEGIN
			SELECT
					@CurrentMaterialCode = MQI.MaterialCode
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @MaterialQcNo

			IF @CurrentMaterialCode <> @MaterialCode BEGIN
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																		'^진행중인 출하검사Lot과 다른제품입니다^',
																		@ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]/[%s]'
					RAISERROR(@ErrorMessage,16,1,@CurrentMaterialCode,@MaterialCode)
					RETURN
			END

			UPDATE	STB_MaterialQcInfo
			SET
					QcQty = QcQty + @QcQty
			WHERE
					MaterialQcNo = @MaterialQcNo
	END

	UPDATE	STB_SetInfo
	SET
			LotNumber = @MaterialQcNo,
			LotCreateDateTime = GETDATE(),
			LotDecisionResult = 'None'
	WHERE
			Barcode = @Barcode

	SET @pMaterialQcNo = @MaterialQcNo
END

