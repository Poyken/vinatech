
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 품질관리
-- Description:	자주검사이력조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCommInspectionMeasuerForBarcode_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspTypeCode VARCHAR(50) = NULL,
	@pBarcode VARCHAR(50) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pMoldNumber VARCHAR(50) = NULL,
	@pCategoryName VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @CommInspTypeCode VARCHAR(50) = @pCommInspTypeCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @LineCode VARCHAR(20) = ISNULL(@pLineCode,'')
	DECLARE @RouteCode VARCHAR(20) = ISNULL(@pRouteCode,'')
	DECLARE @MachineCode VARCHAR(20) = ISNULL(@pMachineCode,'')
	DECLARE @MoldNumber VARCHAR(50) = ISNULL(@pMoldNumber,'')
	DECLARE @CategoryName VARCHAR(50) = ISNULL(@pCategoryName,'')

	DECLARE @CommInspDocNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @IsFinished BIT
	DECLARE @ProductGroupCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)

	SELECT
			@CommInspDocNo = CIDH.CommInspDocNo,
			@IsFinished = CIDH.IsFinished,
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@PONo = SI.PONo,
			@ControlNo = SI.ControlNo,
			@MaterialCode = SI.MaterialCode,
			@ProductGroupCode = MM.ProductGroupCode
	FROM
			STB_SetInfo SI
			LEFT OUTER JOIN STB_ProductionOrderInfo POI
				ON POI.PONo = SI.PONo
			LEFT OUTER JOIN	STB_CommInspDocHistory CIDH
				ON CIDH.CommInspTypeCode = @CommInspTypeCode AND
				CIDH.ProdNo = SI.ControlNo
			LEFT OUTER JOIN STB_MaterialMaster MM
				ON MM.MaterialCode = SI.MaterialCode
	WHERE
			SI.Barcode = @Barcode

	IF ISNULL(@Barcode,'') <> '' AND ISNULL(@CommInspTypeCode,'') <> '' BEGIN	-- Developer에서 화면 만들때는 생성하지 않게
		IF ISNULL(@CommInspDocNo,'') = '' BEGIN

				EXEC usp_DoCreateCommInspDocHistory	@pProcessLanguage = @ProcessLanguage,
													@pProcessUserID = @ProcessUserID,
													@pCommInspTypeCode = @CommInspTypeCode,
													@pCompanyCode = @CompanyCode,
													@pWorkCenterCode = @WorkCenterCode,
													@pRefDoc = @PONo,
													@pProdNo = @ControlNo,
													@pProductGroupCode = @ProductGroupCode,
													@pMaterialCode = @MaterialCode,
													@pLineCode = @LineCode,
													@pRouteCode = @RouteCode,
													@pMachineCode = @MachineCode,
													@pMoldNumber = @MoldNumber,
													@pCategoryName = @CategoryName,
													@pCommInspDocNo = @CommInspDocNo OUTPUT
		END
	END
    
	;WITH CommInspItem(Seq,CommInspDocItemNo,ItemTargetQty) AS
	(
		SELECT
				1 AS Seq,
				CIDI.CommInspDocItemNo,
				CIDI.ItemTargetQty
		FROM
				STB_CommInspDocItem CIDI WITH(NOLOCK)
		WHERE
				CIDI.CommInspDocNo = @CommInspDocNo
		UNION ALL
		SELECT
				Seq + 1,
				CII.CommInspDocItemNo,
				CII.ItemTargetQty
		FROM
				ComminspItem CII
		WHERE
				CII.Seq < CII.ItemTargetQty
	), MeasureHist AS
	(
		SELECT
				RANK() OVER (PARTITION BY CIMH.CommInspDocItemNo ORDER BY CIMH.MeasureSeq) AS RankIndex,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure
		FROM
				STB_CommInspDocItem CIDI WITH(NOLOCK)
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH WITH(NOLOCK)
					ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
		WHERE
				CIDI.CommInspDocNo = @CommInspDocNo
	), AftMeasureHist AS
	(
		SELECT
				RANK() OVER (PARTITION BY MH.CommInspDocItemNo ORDER BY MH.RankIndex DESC) AS RankIndex,
				MH.CommInspDocItemNo,
				MH.MeasureResult,
				MH.NumericMeasure,
				MH.TextMeasure
		FROM
				MeasureHist MH
				LEFT OUTER JOIN STB_CommInspDocItem CIDI WITH(NOLOCK)
					ON CIDI.CommInspDocNo = MH.CommInspDocItemNo
		WHERE
				CIDI.CommInspDocNo = @CommInspDocNo AND
				MH.RankIndex > CIDI.ItemTargetQty
	)
	SELECT
			CIDI.CommInspDocItemNo,
			CIDI.CommInspDocNo,
			CIDI.CommInspItemCode,
			CII.CommInspItemName,
			CIDI.CommInspUnit,
			CIDI.CommInspItemDesc,
			CIDI.CommInspInputType,
			VIEW_CIIT.CommInspInputTypeName,
			CIDI.CommInspItemSpec,
			CIDI.CommInspUpper,
			CIDI.CommInspLower,
			CIDI.ItemTargetQty,
			ISNULL(CIDI.ItemQty,0) AS ItemQty,
			ISNULL(CIDI.ImageFileID,0) AS ImageFileID,
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			CIDI.CommInspRemark,
			CII.CommInspSelectGroupCode,
			'' AS MeasureResult,
			0.0 AS NumericMeasure,
			'' AS TextMeasure,
			--CISI.CommInspSelectItemCode,
			--CISI.CommInspSelectItemValue,
			--CISI.CommInspSelectResult,
			MH.NumericMeasure AS BefMeasure,
			AMH.NumericMeasure AS AftMeasure
	FROM
			CommInspItem CIIC
			INNER JOIN STB_CommInspDocItem CIDI WITH(NOLOCK)
				ON CIDI.CommInspDocItemNo = CIIC.CommInspDocItemNo
			LEFT OUTER JOIN STB_CommInspItem CII WITH(NOLOCK)
				ON CII.CommInspItemCode = CIDI.CommInspItemCode
			LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT 
				ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
				ON (AFM.FileID = CIDI.ImageFileID)
			--LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)
			--	ON CISI.CommInspSelectResult = MH.MeasureResult
			--	AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
			LEFT OUTER JOIN MeasureHist MH
				ON MH.CommInspDocItemNo = CIIC.CommInspDocItemNo AND
				MH.RankIndex = CIIC.Seq
			LEFT OUTER JOIN AftMeasureHist AMH
				ON AMH.CommInspDocItemNo = CIIC.CommInspDocItemNo AND
				AMH.RankIndex = CIIC.Seq
	WHERE
			CIDI.CommInspDocNo = @CommInspDocNo
END