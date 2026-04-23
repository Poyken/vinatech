-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_GetSetListForBCQCLot_VVT
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	--@pRouteCode VARCHAR(20) = NULL,             -- 베트남법인 문제로 제외 (2020.02.12 kilee)
	@pBarCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	--DECLARE @RouteCode VARCHAR(20)        = @pRouteCode                                                                                                -- 베트남법인 문제로 제외 (2020.02.12 kilee)
	DECLARE @BarCode VARCHAR(20)           = CASE WHEN ISNULL(@pBarCode,'') = '' THEN '%' ELSE @pBarCode END
	-- lấy ra lot ban đầu khi thay đổi mã lot
	DECLARE @CountChange int = 0,@OldLotidChange varchar(50)=''
	SELECT @CountChange=count(*) ,@OldLotidChange=oldlotid FROM STB_ChangePartNoAndLotNo WHERE (NewLotid = @Barcode)-- or oldLotid = @Barcode)
	group by oldlotid
	--end
	
	DECLARE @NewBarcode VARCHAR(20)

	SELECT @NewBarcode = NewBarcode
	  FROM STB_LotChangeMaterialHistory
	 WHERE OldBarcode = case when @CountChange =1
				then
				  @OldLotidChange
				else
					@Barcode
				end

		-- DinhManh update 2025-04-28: can search separated Lot 
	DECLARE @sepaBarcode VARCHAR(20) = NULL
	DECLARE @mergeBarcode VARCHAR(20) = NULL
	DECLARE @CreatedSeparatedLot BIT = '0'
	SELECT	@sepaBarcode = lotid, 
			@mergeBarcode = mergeid, 
			@CreatedSeparatedLot = CreatedLot FROM VVT_OQC_REFER 
	where lotid = @BarCode and (CreatedLot IS NULL or CreatedLot = '') AND isSeparated = 1
		--


	 --raiserror (@sepaBarcode, 16,1)
	 --return

	;WITH SetList AS
	(
		SELECT
				DISTINCT
				LI.CompanyCode,
				SI.ControlNo,
				SI.PONo,
				SI.InputLineCode,
				MBI.ModelName,
				LI.LineName,
				POR.RouteIndex,
				POR.RouteCode,
					SI.Barcode
				
		FROM
				STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)				ON POI.PONo = SI.PONo
				--INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SI.PONo AND					POR.RouteCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@RouteCode))
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SI.PONo AND POR.RouteCode IN ('E-22','V-22', 'MV-01','V-22_BG','VE01')
				INNER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)					ON MBI.ModelCode = SI.MaterialCode AND					MBI.InspectionType NOT IN ('NONE')
				LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)					        ON LI.LineCode = SI.InputLineCode
				--INNER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)					   ON PRH.ControlNo = SI.ControlNo AND					PRH.RouteCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@RouteCode))
				--INNER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)					   ON PRH.ControlNo = SI.ControlNo AND					PRH.RouteCode IN ('E-22','V-22')
		WHERE 1=1
			 -- AND ((@CompanyCode = '*') OR (POI.CompanyCode = @CompanyCode))                                                                                                 -- 추가 용은재 (2020.01.23)
			 -- AND POI.WorkCenterCode LIKE @WorkCenterCode 
			 -- AND SI.InputLineCode LIKE @LineCode 
				AND (SI.LotNumber IS NULL OR SI.LotNumber = '' OR @CreatedSeparatedLot IS NULL)		-- update 2025-05-13		
								
		     -- AND SI.Barcode LIKE @Barcode 				                                                                                                                                      -- 원본백업    
				AND  (SI.Barcode = @Barcode OR SI.Barcode =@NewBarcode					-- 2020.04.17 추가 (기종변경 바코드추가)
					OR SI.Barcode = @mergeBarcode)            	-- 2025-04-28

	), ProdRouteHist AS
	(
		SELECT
				SL.ControlNo,
				SUM(PRH.ProdQty) AS ProdQty
		FROM
				STB_ProdRouteHist PRH WITH(NOLOCK)
				INNER JOIN SetList SL					ON SL.ControlNo = PRH.ControlNo       AND					SL.RouteCode = PRH.RouteCode
		GROUP BY
				SL.ControlNo
	
	
	), ProductMachine AS
	(
		SELECT
				SL.ControlNo,
				POR.RouteCode,
				PM.MachineCode,
				POR.RouteIndex
		FROM
				SetList SL
				INNER JOIN       STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SL.PONo                 AND					POR.RouteIndex <= SL.RouteIndex
				LEFT OUTER JOIN STB_ProductMachine PM WITH(NOLOCK)					ON PM.LineCode = SL.InputLineCode    AND					PM.RouteCode = POR.RouteCode
	
	), RouteMachine AS
	(
		SELECT
				PM.ControlNo,
				PM.RouteIndex,
				PM.RouteCode,
				CASE WHEN ISNULL(PM.MachineCode,'') = '' THEN PRH.MachineCode ELSE PM.MachineCode END AS MachineCode
		FROM
				ProductMachine PM
				LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)			ON PRH.ControlNo = PM.ControlNo                        AND					PRH.RouteCode = PM.RouteCode
				LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)		ON MCM.MachineCode = PRH.MachineCode
	)

	SELECT
			CASE WHEN SL.ComPanyCode = 'VNT' THEN '전주본사'
			WHEN SL.ComPanyCode = 'VVT' THEN '베트남' ELSE 'VietNam' END   AS 사업장,
			SI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.MaterialCode AS ModelCode,
			SL.ModelName,
			case when @CountChange =1
				then
					@OldLotidChange
				when @sepaBarcode IS NOT NULL then @sepaBarcode
				else
					SI.Barcode
				end
				as Barcode,
			SI.InputLineCode,
			SL.LineName AS InputLineName,
			SI.IsFinalInspection,
			SI.FinalInspectionJobDate,
			SI.FinalInspectionShiftCode,
			SI.FinalInspectionDateTime,
			SI.LotNumber,
			SI.LotDecisionResult,
			SI.LotCreateDateTime,
			SI.IsProdFinish,
			SI.ProdFinishJobDate,
			SI.ProdFinishShiftCode,
			SI.ProdFinishDateTime,
			SI.GradeCode,
			SI.ProdQty AS LotQty,
			PRH.ProdQty,
			CASE	WHEN SI.SIExtInt01 IS NULL THEN '정상제품'
				    WHEN SI.SIExtInt01 = 0      THEN '검사부적합 이력제품'
				    WHEN SI.SIExtInt01 = 1      THEN '검사부적합품'		END    AS RouteTestResult
			
	FROM
			SetList SL
			INNER JOIN        STB_SetInfo     SI WITH(NOLOCK)	 ON SI.ControlNo = SL.ControlNo
			LEFT OUTER JOIN ProdRouteHist PRH				     ON PRH.ControlNo = SL.ControlNo
   WHERE 1=1      
END
