-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateOqcInfoForLot_VNT_BendingCutting]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50) = NULL,
	@pProdQty NUMERIC(20,5) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Barcode VARCHAR(50) = @pBarcode,
			@ControlNo VARCHAR(20),
			@CurrentMaterialCode VARCHAR(50),
			@MaterialCode VARCHAR(50),
			@QcQty NUMERIC(20,5),
			@ErrorMessage NVARCHAR(500),
			@LotNumberBC VARCHAR(50),
			@MaxSampleQty INT,
			@MaxDefectQty INT
			


	---- DinhManh update 2025-04-26: can search separated Lot 
	DECLARE @sepaBarcode VARCHAR(20) = NULL
	DECLARE @mergeBarcode VARCHAR(20) = NULL
	DECLARE @CreatedSeparatedLot BIT = 1
	DECLARE @LotNumberBCSer VARCHAR(50) = NULL
	SELECT	@sepaBarcode = lotid, 
			@mergeBarcode = mergeid,
			@CreatedSeparatedLot = CreatedLot,
			@LotNumberBCSer = LotNumberBC
	FROM VVT_OQC_REFER where lotid = @Barcode and isSeparated = 1

	-- lấy các lot đã chuyển (2025-08-23)
	DECLARE @changedBarcode VARCHAR(20) = NULL
	SELECT @changedBarcode = OldBarcode FROM STB_LotChangeMaterialHistory
	where NewBarcode = @Barcode
	------

	-- update 2025-08-23 (SELECT -> SELECT TOP 1)
	SELECT TOP 1
			@ControlNo = SI.ControlNo,
			@QcQty = CASE WHEN ISNULL(@pProdQty,0) = 0 THEN SI.ProdQty ELSE @pProdQty END,
			@LotNumberBC = SI.LotNumberBC,
			@MaterialCode = SI.MaterialCode
	FROM
			STB_SetInfo SI
	WHERE
			SI.Barcode = @Barcode 
			or SI.Barcode = @mergeBarcode --update 2025-04-26
			or SI.Barcode = @changedBarcode -- update 2025-08-23
	
	--RAISERROR(@Barcode,16,1)
	--RETURN


	IF ((ISNULL(@LotNumberBC,'') <> '') AND (ISNULL(@LotNumberBCSer,'') <> '')) BEGIN  -- Mr.Manh update 2025-05-14 to create lot separate

			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																N'^Lot kiểm tra này đã được tạo!!!^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]/[%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@LotNumberBC)
			RETURN
	END
			
	IF ISNULL(@ControlNo,'') = '' BEGIN
			Raiserror(@ControlNo,16,1)
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																N'^Lot này không tồn tại!!!^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END
		
	INSERT INTO STB_MaterialQcInfo_BendingCutting
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
			@Barcode,
			POI.CompanyCode,
			POI.WorkCenterCode,
			'BCQC',
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
			INNER JOIN STB_ProductionOrderInfo POI			ON POI.PONo = SI.PONo
			INNER JOIN STB_ModelBasicInfo MBI				ON MBI.ModelCode = SI.MaterialCode
	WHERE
			SI.ControlNo = @ControlNo

	IF @@ROWCOUNT = 0 
	
	BEGIN
			RAISERROR('%s',16,1,@Barcode)
			RETURN
	END

			--RAISERROR('hello',16,1,@Barcode)
			--RETURN

	-- Tạo QC Detail List
	EXEC usp_DoMakeMaterialIQCDetailList_BendingCutting	@pProcessUserID = @pProcessUserID,
													@pProcessLanguage = @pProcessLanguage,
													@pMaterialQcNo = @Barcode

	IF NOT EXISTS (
					SELECT	1
					FROM
							STB_MaterialQcDetail_BendingCutting MQD
					WHERE
							MQD.MaterialQcNo = @Barcode
				) BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																N'^Các hạng mục kiểm tra của Model này chưa được đăng ký!!! Vui lòng đăng ký ở C561 !!!^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@MaterialCode)
			RETURN
	END

	SET @MaxSampleQty = (SELECT ISNULL(MAX(RequestSampleQty), 0) FROM STB_MaterialQcDetail_BendingCutting WHERE MaterialQcNo = @Barcode)
	SET @MaxDefectQty = (SELECT ISNULL(MAX(MaxAcceptDefectQty), 0) FROM STB_MaterialQcDetail_BendingCutting WHERE MaterialQcNo = @Barcode)


	IF (@mergeBarcode IS NULL)  -- Nếu không phải lot chia thì cập nhật như thường, còn lot chia thì ko
		BEGIN
			UPDATE STB_MaterialQcInfo_BendingCutting
			SET
					TargetSampleQty = @MaxSampleQty,
					MaxAcceptDefectQty = @MaxDefectQty
			WHERE
					MaterialQcNo = @Barcode

			UPDATE	STB_SetInfo
			SET
					LotNumberBC = @Barcode
			WHERE
					Barcode = @Barcode

		END
	-- Lot đã Tạo lot ở C512 sẽ không tìm kiếm được nữa
	ELSE IF (@mergeBarcode IS NOT NULL AND @sepaBarcode IS NOT NULL)
		BEGIN
			UPDATE VVT_OQC_REFER
			SET LotNumberBC = @Barcode
			WHERE lotid = @sepaBarcode


			UPDATE STB_MaterialQcInfo_BendingCutting
			SET
					TargetSampleQty = @MaxSampleQty,
					MaxAcceptDefectQty = @MaxDefectQty
			WHERE
					MaterialQcNo = @sepaBarcode
		END
END
