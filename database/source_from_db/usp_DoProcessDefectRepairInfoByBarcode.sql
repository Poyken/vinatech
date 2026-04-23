-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 품질관리
-- Description:	바코드의 불량정보를 등록합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessDefectRepairInfoByBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20),
	@pBarcode VARCHAR(50),
	@pDefectCode VARCHAR(20),
	@pDefectQty NUMERIC(20,5),
	@pProcessDateTime DATETIME = NULL,
	@pMarkingCode VARCHAR(20)= NULL,
	@pDefectCauseID VARCHAR(100)=NULL,
	@pDefectSummaryNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LineCode VARCHAR(20) = ISNULL(@pLineCode,'')
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @Barcode VARCHAR(20) = @pBarcode
	DECLARE @DefectCode VARCHAR(20) = @pDefectCode
	DECLARE @DefectQty NUMERIC(20,5) = @pDefectQty
	DECLARE @ProcessDateTime DATETIME = ISNULL(@pProcessDateTime,GETDATE())
	DECLARE @MarkingCode VARCHAR(20) = ISNULL(@pMarkingCode,'')
	DECLARE @DefectCauseID VARCHAR(100) = ISNULL(@pDefectCauseID,'')
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @DayPlanNo VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @BomVersion VARCHAR(20)
	DECLARE @DefectSummaryNo VARCHAR(20)

	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@BomVersion = POI.BomVersion,
			@PONo = SI.PONo,
			@DayPlanNo = SI.DayPlanNo,
			@MaterialCode = SI.MaterialCode,
			@ControlNo = SI.ControlNo,
			@LineCode = CASE
							WHEN @LineCode = '' THEN SI.InputLineCode
							ELSE @LineCode
						END
	FROM
			STB_SetInfo SI
			LEFT OUTER JOIN STB_ProductionOrderInfo POI
				ON POI.PONo = SI.PONo
	WHERE
			SI.Barcode = @Barcode

	-- 2019-05-10 JGH 수정 불량입력시 이전 공정에 실적처리가 있는지 확인
	DECLARE @BefRouteCode VARCHAR(20)
	
	SELECT
			TOP 1
			@BefRouteCode = BPOR.RouteCode
	FROM
			STB_ProductionOrderRouting POR 
			LEFT OUTER JOIN STB_ProductionOrderRouting BPOR
				ON BPOR.PONo = POR.PONo AND
				BPOR.RouteIndex < POR.RouteIndex
	WHERE
			POR.PONo = @PONo AND
			POR.RouteCode = @RouteCode
	ORDER BY
			BPOR.RouteIndex DESC

	IF ISNULL(@BefRouteCode,'') <> '' BEGIN		-- 첫공정이 아니면
			IF NOT EXISTS (
							SELECT	1					
							FROM
									STB_ProdRouteHist PRH
							WHERE
									PRH.PONo = @PONo AND
									PRH.RouteCode = @BefRouteCode
						)
			BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage,'이전 공정에 실적처리 이력이 없습니다'
					RETURN
			END
	END

	EXEC usp_DoProcessDefectRepairInfo	@pProcessUserID = @pProcessUserID,
										@pProcessLanguage = @pProcessLanguage,
										@pCompanyCode = @CompanyCode,
										@pWorkCenterCode = @WorkCenterCode,
										@pPONo = @PONo,
										@pDayPlanNo = @DayPlanNo,
										@pMaterialCode = @MaterialCode,
										@pBomVersion = @BomVersion,
										@pLineCode = @LineCode,
										@pRouteCode = @RouteCode,
										@pControlNo = @ControlNo,
										@pDefectCode = @DefectCode,
										@pDefectQty = @DefectQty,
										@pProcessDateTime = @ProcessDateTime,
										@pMarkingCode = @MarkingCode,
										@pDefectCauseID=@DefectCauseID,
										@pDefectSummaryNo = @DefectSummaryNo OUTPUT

	SET @pDefectSummaryNo = @DefectSummaryNo		
END
