-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2018-08-17
-- Description:	공정별 실적 처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteHistForBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pWorkerCode VARCHAR(20) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pLotID VARCHAR(50) = NULL,
	@pLotNo VARCHAR(50) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pStockAttrib1 VARCHAR(20) = NULL,
	@pStockAttrib2 VARCHAR(20) = NULL,
	@pStockAttrib3 VARCHAR(20) = NULL,
	@pPackingID VARCHAR(50) = NULL,
	@pProcessDateTime DATETIME = NULL,
	@pMarkingCode varchar(20)=NULL,
	@pIsCheckBefRouteProdQty BIT = NULL,
	@pProdRouteHistNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @WorkerCode VARCHAR(20) = @pWorkerCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @LotID VARCHAR(50) = ISNULL(@pLotID,'')
	DECLARE @LotNo VARCHAR(50) = ISNULL(@pLotNo,'')
	DECLARE @StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,'')
	DECLARE @StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,'')
	DECLARE @StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,'')
	DECLARE @PackingID VARCHAR(50) = ISNULL(@pPackingID,'')
	DECLARE @MarkingCode VARCHAR(20) = ISNULL(@pMarkingCode,'')
	DECLARE @ProcessDateTime DATETIME = @pProcessDateTime
	DECLARE @IsCheckBefRouteProdQty BIT = @pIsCheckBefRouteProdQty

	DECLARE @ControlNo VARCHAR(20)	
	DECLARE @PONo VARCHAR(20)
	DECLARE @DayPlanNo VARCHAR(20)
	DECLARE @ProdQty NUMERIC(20,5) = @pProdQty
	DECLARE @PlanDate DATE
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @ProdRouteHistNo VARCHAR(20)

	-- Developer 에서 생성시는 무시
	IF ISNULL(@Barcode,'') <> '' 
	BEGIN
			SELECT
					@ControlNo = SI.ControlNo,
					@PONo = SI.PONo,
					@DayPlanNo = SI.DayPlanNo,
					@ProdQty = CASE WHEN @ProdQty IS NULL THEN SI.ProdQty ELSE @ProdQty END,
					@WorkCenterCode = DPP.WorkCenterCode
			FROM
					STB_SetInfo SI
					LEFT OUTER JOIN STB_DayProdPlan DPP						ON DPP.DayPlanNo = SI.DayPlanNo
			WHERE
					SI.Barcode = @Barcode

			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdRouteHistForBarcode1', '@ProdRouteHistNo', '')

			EXEC usp_DoProcessProdRouteHist	@pProcessUserID = @ProcessUserID,
											@pProcessLanguage = @ProcessLanguage,
											@pPONo = @PONo,
											@pLineCode = @LineCode,
											@pRouteCode = @RouteCode,
											@pProcessDateTime = @ProcessDateTime,
											@pDayPlanNo = @DayPlanNo,
											@pControlNo = @ControlNo,
											@pWorkerCode = @WorkerCode,
											@pProdQty = @ProdQty,
											@pLotID = @LotID,
											@pLotNo = @LotNo,
											@pMachineCode = @pMachineCode,
											@pStockAttrib1 = @StockAttrib1,
											@pStockAttrib2 = @StockAttrib2,
											@pStockAttrib3 = @StockAttrib3,
											@pPackingID = @PackingID,
											@pMarkingCode = @MarkingCode,
											@pIsCheckBefRouteProdQty = @IsCheckBefRouteProdQty,
											@pProdRouteHistNo = @ProdRouteHistNo OUTPUT

			SET @pProdRouteHistNo = @ProdRouteHistNo

			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue)  VALUES ('usp_DoProcessProdRouteHistForBarcode2', '@ProdRouteHistNo', @ProdRouteHistNo)
	END
END
