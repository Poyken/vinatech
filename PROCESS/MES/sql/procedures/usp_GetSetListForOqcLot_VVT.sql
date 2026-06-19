
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 품질관리 > 제품검사 >  [C512] Vietnam제품검사 Lot관리 
-- Description: 출하검사 Lot생성을 위한 Set정보를 조회합니다.
-- Modified: 
--              2019.07.20 바코드 조회란 추가
--              2020.04.17 기종변경에 따른 전후바코드 조회되도록 SQL 수정

-- EXEC usp_GetSetListForOqcLot_VVT @pProcessUserID='yjyu',@pProcessLanguage='Korean',@pCompanyCode='VNT',@pWorkCenterCode='VNT_F1',@pLineCode=default,@pRouteCode=''
-- EXEC usp_GetSetListForOqcLot_VVT @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode='',@pRouteCode='V-22',@pBarCode = 'VVKK093R033504'    --베트남 제품검사 LOT관리 (되는것)
-- EXEC usp_GetSetListForOqcLot_VVT @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode='',@pRouteCode='',@pBarCode = 'VVKK122R740611'         --베트남 제품검사 LOT관리 (안되는것)
-- EXEC usp_GetSetListForOqcLot_VVT @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode='',@pBarCode = 'VVKK083R025601'                              --베트남 제품검사 LOT관리 (안되는것)
-- EXEC [usp_GetSetListForOqcLot_VVT] @pProcessUserID='anhduy157',@pProcessLanguage='vi',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F3',@pLineCode='',@pBarCode = 'MVVPR105R450501'       
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetSetListForOqcLot_VVT]
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
	-- select top 2 * from STB_SetInfo where Barcode='MVVPR105R450501' 

 
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

	-- check nếu mà 
		

	 --raiserror (@sepaBarcode, 16,1)
	 --return

	;WITH SetList AS
	(
		SELECT
				TOP 1					-- Mr.Manh update 2025-12-15 change DISTINCT to TOP 1
				--DISTINCT
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
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SI.PONo AND POR.RouteCode IN ('E-22','V-22', 'MV-01','V-22_BG','VE01', 'V-33', 'V-33_BG','V-25','VP12') -- Mr.Triều add V-25 with Model JIANGHAI
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
					OR SI.Barcode = @mergeBarcode )            	-- 2025-04-28
					order by POR.RouteCode desc
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
			case when @CountChange =1 AND  SL.ComPanyCode = 'VNT' THEN @OldLotidChange
				
				when @CountChange =1 AND  SL.ComPanyCode = 'VVT' 
				then
					--@OldLotidChange	--2026-05-26 Mr.Manh changed because OQC dont want to create by Old LotID
					SI.Barcode
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