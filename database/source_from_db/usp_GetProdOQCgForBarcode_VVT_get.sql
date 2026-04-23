-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-22	
-- Description:	For C531 search 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdOQCgForBarcode_VVT_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pBarcode VARCHAR(50) = NULL,
		@pQuantity VARCHAR(20) = NULL,
		@pLevelBox VARCHAR(5) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @Barcode VARCHAR(50) = @pBarcode	

	DECLARE @LineCode VARCHAR(20)
	DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @RouteCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @CurrentQty NUMERIC(20,5)
	DECLARE @TotalQty NUMERIC(20,5)
	DECLARE @BasicMaterialType VARCHAR(20)
	DECLARE @InputLineCode VARCHAR(20)
	DECLARE @DecisionResult VARCHAR(10)
	DECLARE @DPPExtText01 NVARCHAR(100)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @NewBarcode VARCHAR(5)
	DECLARE @LevelBox VARCHAR(5) = @pLevelBox

		SELECT @NewBarcode = NewBarcode
		FROM STB_LotChangeMaterialHistory
		WHERE OldBarcode = @Barcode


	SELECT
			@ControlNo = SI.ControlNo,
			@PONo = SI.PONo,
			@TotalQty = SI.ProdQty,
			@CurrentQty = SUM(PRH.ProdQty),
			@RouteCode = POR.RouteCode,
			@WorkCenterCode = PRH.WorkCenterCode,
			@LineCode = SI.InputLineCode,
			@DecisionResult = MQI.DecisionResult,
			@DPPExtText01 = DPP.DPPExtText01
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)	 ON POR.PONo = SI.PONo                   AND	 POR.IsOutputRoute = 1
			LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)				 ON PRH.ControlNo = SI.ControlNo        AND PRH.RouteCode = POR.RouteCode
			LEFT OUTER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)				 ON MQI.MaterialQcNo = SI.LotNumber --#200106J
			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				     ON DPP.DayPlanNo = SI.DayPlanNo
	WHERE
			(
			SI.Barcode = @Barcode 
			OR SI.Barcode = @NewBarcode --(SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)
			)
	GROUP BY
			SI.ControlNo,
			SI.PONo,
			SI.ProdQty,
			POR.RouteCode,
			PRH.WorkCenterCode,
			SI.InputLineCode,
			MQI.DecisionResult,
			DPP.DPPExtText01

	IF ISNULL(@DPPExtText01,'') = '1' 
	
	BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Lot da duoc xu ly ket thuc'
			RETURN
	END
			

	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTimeV3(@ProcessDateTime,@WorkCenterCode)
	DECLARE @JobDate       DATE            = SUBSTRING(@JobDateShift,1,8)
	DECLARE @ShiftCode     VARCHAR(1)  = SUBSTRING(@JobDateShift,9,1)
	
	
	CREATE TABLE #tmp (Num INT)

	IF @pQuantity = 0 OR @pQuantity IS NULL 
	BEGIN
		declare @errQuantity varchar(60) = N'Ban can nhap so luong!!!';
		RAISERROR( @errQuantity ,16, 1);
		return;
	END

	ELSE IF @pQuantity >= 1 
	BEGIN
		

		DECLARE @Number INT = 1;
		DECLARE @TotalBox INT = 0
		WHILE @Number <= @pQuantity
			BEGIN
				SET @TotalBox = @TotalBox + 1;
				INSERT INTO #tmp (Num) VALUES (@Number)
				SET @Number = @Number + 1;
			END
	END



	;WITH ProdRoute AS
	(
		SELECT
				PRH.ControlNo,
				SUM(PRH.ProdQty) AS ProdRouteQty
		FROM
				STB_ProdRouteHist PRH                                        WITH(NOLOCK)
				         INNER JOIN STB_SetInfo SI                           WITH(NOLOCK)  ON SI.ControlNo = PRH.ControlNo
				         INNER JOIN STB_ProductionOrderRouting POR   WITH(NOLOCK)	  ON POR.PONo = SI.PONo               AND					POR.IsOutputRoute = 1
				         AND POR.RouteCode = PRH.RouteCode
		WHERE
				SI.Barcode = @Barcode
				OR SI.Barcode = @NewBarcode 
		GROUP BY
				PRH.ControlNo

	), ProdDefect AS
	(
		SELECT
				DRI.ControlNo,
				SUM(DRI.DefectQty) AS DefectQty,
				SUM(DRI.LossQty) AS LossQty,
				SUM(DRI.RepairQty) AS RepairQty
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
		WHERE
				DRI.ControlNo = @ControlNo
		  AND DRI.RepairType NOT IN ('MISSING')
		GROUP BY
				DRI.ControlNo
	)

	

	SELECT
			SI.ControlNo,
			SI.DayPlanNo,
			SI.PONo,
			CONCAT(SI.Barcode,'-',#tmp.Num) AS Barcode,
			SI.MaterialCode,
			MM.MaterialName,
			POI.PlanQty AS POPlanQty,
			@LineCode AS LineCode,
			LI.LineName,
			POR.RouteCode,
			@JobDate AS JobDate,
			DPP.PlanQty,
			SI.ProdQty,
			SI.ProdQty - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0) + ISNULL(PD.RepairQty, 0)  AS RemainQty, -- 불량수량 적용
			ISNULL(PR.ProdRouteQty,0) AS InputQty,
			ISNULL(PR.ProdRouteQty,0) AS OutputQty,
			PD.DefectQty,
			PD.LossQty,
			MM.BasicPackingQty,
			MM.BasicPackingQty AS InProdQty,
			--1 AS BarcodeCount,
			--0 AS LotCount,
			--CONVERT(INT,(SI.ProdQty - ISNULL(PR.ProdRouteQty,0)) / MM.BasicPackingQty) AS BasicBoxQty,
			--CONVERT(INT,(SI.ProdQty - ISNULL(PR.ProdRouteQty,0)) / MM.BasicPackingQty) AS BoxQty,
			'' AS StockAttrib1,
			@LevelBox as LevelBx
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)		ON POI.PONo = SI.PONo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				    ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)				            ON LI.LineCode = @LineCode
			LEFT OUTER JOIN ProdRoute PR				                                ON PR.ControlNo = SI.ControlNo
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)	ON POR.PONo = SI.PONo AND				POR.IsOutputRoute = 1
			LEFT OUTER JOIN ProdDefect PD				                                ON PD.ControlNo = SI.ControlNo			
			CROSS JOIN #tmp
			
	WHERE 1=1

	   AND (SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode --(SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)                 -- 기종변경으로 인해서 수정 (2020.04.16)
			  )


	DROP TABLE #tmp

END
