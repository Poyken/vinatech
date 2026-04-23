-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-07
-- Description : 스캔된 바코드 유효성 체크.입고,이동 처리시 바코드를 스캔하기 위한 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoValidateMaterialDocBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20) = NULL,
	@pBarcode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo,			
			@Barcode VARCHAR(50) = @pBarcode,
			@MaterialCode VARCHAR(50),
			@MaterialIqcNo VARCHAR(20),
			@MaterialDocNo VARCHAR(20),
			@MaterialDocType VARCHAR(20),
			@MaterialDocTypeCode VARCHAR(20),
			@CustomerCode VARCHAR(20),
			@DocStatus VARCHAR(20),
			@InspectionType VARCHAR(20),
			@DecisionResult VARCHAR(1),
			@IsRequireQC BIT

	SELECT
			@MaterialDocType = MDI.MaterialDocType,
			@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
			@DocStatus = MDI.DocStatus,
			@MaterialIqcNo = MDD.MaterialIqcNo,
			@CustomerCode = MDI.SourceCustomerCode,
			@MaterialCode  = MDD.MaterialCode,
			@IsRequireQC = MDT.IsRequireQC
	FROM
			STB_MaterialDocDetail MDD WITH(NOLOCK)
			INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)
				ON	MDI.MaterialDocNo = MDD.MaterialDocNo
			INNER JOIN STB_MaterialDocType MDT WITH(NOLOCK)
				ON	MDT.MaterialDocTypeCode = MDI.MaterialDocTypeCode
	WHERE
			MDD.MaterialDocDetailNo = @MaterialDocDetailNo


	IF @MaterialDocType = 'GR' BEGIN
		IF @DocStatus <> 'ARRIVAL' BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage,
											'입하처리가 되지 않았습니다.'
			RETURN
		END

		IF @IsRequireQC = 1 BEGIN
			SELECT
					@InspectionType = MVM.InspectionType
			FROM
					STB_MaterialVendorMapping MVM
			WHERE
					MVM.MaterialCode = @MaterialCode AND
					MVM.CustomerCode = @CustomerCode
			IF @InspectionType <> 'NONE' AND ISNULL(@MaterialIqcNo,'') = '' BEGIN
				EXEC usp_RaiseLocalizedError	@ProcessLanguage,
												'수입검사의뢰 정보를 찾을 수 없습니다.'
				RETURN
			END

			SELECT
					@DecisionResult = MQI.DecisionResult
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @MaterialIqcNo

			IF @DecisionResult <> 'P' BEGIN
				EXEC usp_RaiseLocalizedError	@ProcessLanguage,
												'수입검사 합격처리가 되지 않았습니다.'
				RETURN
			END
		END
	END

	IF @MaterialDocType = 'GR' BEGIN
		SELECT
				MDD.MaterialDocNo,
				MDD.MaterialDocDetailNo,
				NULL AS MaterialLotNo,
				@Barcode AS LotID,
				MDD.MaterialCode,
				MM.MaterialName,
				MM.MaterialTypeCode,
				MT.MaterialTypeName,
				MM.ProductGroupCode,
				PG.ProductGroupName,
				MDD.MaterialStockAttribute,
				MDD.StockAttrib1,
				MDD.StockAttrib2,
				MDD.StockAttrib3,
				ISNULL(MLS.CurrentQty, MDD.AllowQty) AS RequestQty,
				MLS.LotNo,
				MLS.LotAttr01,
				MLS.LotAttr02,
				MLS.LotAttr03,
				MLS.LotAttr04,
				MLS.LotAttr05,
				MLS.LotAttr06,
				MLS.LotAttr07,
				MLS.LotAttr08,
				MLS.LotAttr09,
				MLS.LotAttr10
		FROM
				STB_MaterialDocDetail MDD WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON	MM.MaterialCode = MDD.MaterialCode
				LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
					ON	MT.MaterialTypeCode = MM.MaterialTypeCode
				LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
					ON	PG.ProductGroupCode = MM.ProductGroupCode
				LEFT OUTER JOIN STB_MaterialLotSnapshot MLS WITH(NOLOCK)
					ON	MLS.LotID = @Barcode AND
						MLS.MaterialCode = MDD.MaterialCode
		WHERE
				MDD.MaterialDocDetailNo = @MaterialDocDetailNo
	END ELSE BEGIN
		SELECT
				MDD.MaterialDocNo,
				MDD.MaterialDocDetailNo,
				NULL AS MaterialLotNo,
				@Barcode AS LotID,
				MDD.MaterialCode,
				MM.MaterialName,
				MM.MaterialTypeCode,
				MT.MaterialTypeName,
				MM.ProductGroupCode,
				PG.ProductGroupName,
				MDD.MaterialStockAttribute,
				MDD.StockAttrib1,
				MDD.StockAttrib2,
				MDD.StockAttrib3,
				ISNULL(MLI.CurrentQty, MDD.AllowQty) AS RequestQty,
				MLI.LotNo,
				MLI.LotAttr01,
				MLI.LotAttr02,
				MLI.LotAttr03,
				MLI.LotAttr04,
				MLI.LotAttr05,
				MLI.LotAttr06,
				MLI.LotAttr07,
				MLI.LotAttr08,
				MLI.LotAttr09,
				MLI.LotAttr10
		FROM
				STB_MaterialDocDetail MDD WITH(NOLOCK)
				INNER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)
					ON	MLI.LotID = @Barcode AND
						MLI.MaterialCode = MDD.MaterialCode
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON	MM.MaterialCode = MDD.MaterialCode
				LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
					ON	MT.MaterialTypeCode = MM.MaterialTypeCode
				LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
					ON	PG.ProductGroupCode = MM.ProductGroupCode				
		WHERE
				MDD.MaterialDocDetailNo = @MaterialDocDetailNo
	END
END
