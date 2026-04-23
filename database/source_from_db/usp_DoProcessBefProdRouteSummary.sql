
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-02
-- Browsable : true
-- Group : 생산관리
-- Description: 공정별 실적을 처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessBefProdRouteSummary]
	@pProcessUserID VARCHAR(20),
	@pPONo VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pJobDate DATE,
	@pShiftCode VARCHAR(1),
	@pTimeCode VARCHAR(2),
	@pProdQty NUMERIC(20,5) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @JobDate DATE = @pJobDate
	DECLARE @ShiftCode VARCHAR(1) = @pShiftCode
	DECLARE @TimeCode VARCHAR(2) = @pTimeCode
	DECLARE @ProdQty NUMERIC(20,5) = ISNULL(@pProdQty,1)

	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)	
	DECLARE @BefRouteCode VARCHAR(20)
	DECLARE @RouteIndex INT

	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@RouteIndex = POR.RouteIndex
	FROM
			STB_ProductionOrderInfo POI
			INNER JOIN STB_ProductionOrderRouting POR
				ON POR.PONo = POI.PONo
	WHERE
			POI.PONo = @PONo AND
			POR.RouteCode = @RouteCode

	IF ISNULL(@RouteIndex,-1) >= 0 BEGIN
			SELECT
					TOP 1
					@BefRouteCode = POR.RouteCode
			FROM
					STB_ProductionOrderRouting POR
			WHERE
					POR.PONo = @PONo AND
					POR.RouteIndex < @RouteIndex
			ORDER BY
					POR.RouteIndex DESC

			IF ISNULL(@BefRouteCode,'') <> '' BEGIN
					-- 이전공정 출하처리
					EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
														@pWorkCenterCode = @WorkCenterCode,
														@pLineCode = @LineCode,
														@pRouteCode = @BefRouteCode,
														@pPONo = @PONo,
														@pJobDate = @JobDate,
														@pShiftCode = @ShiftCode,
														@pTimeCode = @TimeCode,
														@pProdQty = @ProdQty
			END
	END
END

