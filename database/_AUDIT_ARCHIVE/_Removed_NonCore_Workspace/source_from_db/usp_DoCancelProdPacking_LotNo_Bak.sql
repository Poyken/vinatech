-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2019-07-22
-- Browsable : true
-- Group : 생산관리
-- Description:	박스실적을 취소처리합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCancelProdPacking_LotNo_Bak]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pBarcode VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode,
			@LotNo VARCHAR(20) = @pBarcode

	DECLARE @PackingID VARCHAR(50),
			@MaterialDocNo VARCHAR(20),
			@ControlNo VARCHAR(20),
			@ProdRouteHistNo VARCHAR(20),
			@PONo VARCHAR(20)

	DECLARE @JobDate DATE
	DECLARE @ShiftCode VARCHAR(1)
	DECLARE @TimeCode VARCHAR(2)
	DECLARE @ProdQty NUMERIC(20,5)

	DECLARE @MaterialDocInfo TABLE
	(
		IDX INT IDENTITY(1,1),
		MaterialDocNo VARCHAR(20)
	)
	
	DECLARE @ControlInfo TABLE
	(
		IDX INT IDENTITY(1,1),
		ControlNo VARCHAR(20)
	)

	INSERT INTO @MaterialDocInfo
	(
		MaterialDocNo
	)
	SELECT
			DISTINCT
			MDPI.MaterialDocNo
	FROM
			STB_MaterialDocLotInfo MDLI
			INNER JOIN STB_MaterialDocInfo MDI
				ON MDI.MaterialDocNo = MDLI.MaterialDocNo AND
				MDI.IsCancel = 0
			INNER JOIN STB_MaterialDocLotInfo MDPLI
				ON MDPLI.PackingID = MDLI.PackingID
			INNER JOIN STB_MaterialDocInfo MDPI
				ON MDPI.MaterialDocNo = MDPLI.MaterialDocNo AND
				MDPI.IsCancel = 0
	WHERE
			MDLI.LotNo = @LotNo

	INSERT INTO @ControlInfo
	SELECT
			SI.ControlNo
	FROM 
			STB_SetInfo SI 
	WHERE SI.Barcode IN (
							SELECT LotNo 
							FROM 
									@MaterialDocInfo MDI
									INNER JOIN STB_MaterialDocLotInfo MDLI
										ON MDLI.MaterialDocNo = MDI.MaterialDocNo
						)

	DECLARE @Count INT = (SELECT COUNT(*) FROM @MaterialDocInfo)
	DECLARE @Row INT = 1

	-- 생산 입고 취소
	WHILE @Count >= @Row
	BEGIN
		SELECT
				@MaterialDocNo = MaterialDocNo
		FROM
				@MaterialDocInfo
		WHERE
				IDX = @Row

		EXEC usp_DoCancelMaterialDoc	@pProcessLanguage = @pProcessLanguage,
										@pProcessUserID = @pProcessUserID,
										@pMaterialDocNo = @MaterialDocNo

		SET @Row = @Row + 1
	END

	SET @Count = (SELECT COUNT(*) FROM @ControlInfo)
	SET @Row = 1

	-- 실적 취소
	WHILE @Count >= @Row
	BEGIN
		SELECT
				@ControlNo = CI.ControlNo
		FROM
				@ControlInfo CI
		WHERE
				CI.IDX = @Row

		UPDATE STB_ProductionOrderInfo
		SET
				ProdFinishQty = ProdFinishQty - PRH.ProdQty
		FROM
				STB_ProductionOrderInfo POI
				INNER JOIN STB_ProdRouteHist PRH
					ON PRH.PONo = POI.PONo
		WHERE
				PRH.ControlNo = @ControlNo AND
				PRH.RouteCode = @RouteCode

		UPDATE STB_ProdRouteSummary
		SET
				OutputQty = OutputQty - PRH.ProdQty
		FROM
				STB_ProdRouteSummary PRS
				INNER JOIN STB_ProdRouteHist PRH
					ON PRH.RouteCode = PRS.RouteCode AND
					PRH.PONo = PRS.PONo AND
					PRH.JobDate = PRS.JobDate AND
					PRH.ShiftCode = PRS.ShiftCode AND
					PRH.TimeCode = PRS.TimeCode
		WHERE
				PRH.ControlNo = @ControlNo AND
				PRH.RouteCode = @RouteCode

		DELETE FROM STB_ProdRouteWorkerHist
		WHERE
				ProdRouteHistNo IN (
										SELECT	ProdRouteHistNo
										FROM
												STB_ProdRouteHist
										WHERE
												ControlNo = @ControlNo AND
												RouteCode = @RouteCode
									)
		
		DELETE FROM STB_ProdRouteHist
		WHERE
				ControlNo = @ControlNo AND
				RouteCode = @RouteCode
		
		SET @Row = @Row + 1
	END

	UPDATE	STB_SetInfo
	SET
			IsProdFinish = 0,
			ProdFinishDateTime = NULL,
			ProdFinishJobDate = NULL,
			ProdFinishShiftCode = NULL
	WHERE
			ControlNo IN (SELECT ControlNo FROM @ControlInfo)

END