
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17 -> 2019-05-03
-- Browsable : true
-- Group : 생산관리 >  [B520]제품박스실적입력 > Grid1 제품Lot정보 조회
-- Description: 패킹공정 실적 입력을 위한 바코드 정보를 가져옵니다
-- Modified: 베트남의 경우 제품검사를 거치지 않고 패킹하므로 쿼리를 수정함. 
-- 결과값이 존재해도 제품검사합격여부 판단 후 에러처리를 하기 때문에 문제 없을 것으로 판단함. 2020.01.06 By Jackaroe #200106J
-- 팅크웨어 향 라벨 출력 관련 컬럼 추가 2021.04.22 #210422
-- 지지체 남은수량 계산 방식 적용 #240530

-- 프로시저 실행 :  EXEC [usp_GetProdPackingForBarcode_VNT] '','','VJOR083R850601', '', ''

-- EXEC [usp_GetProdPackingForBarcode_VNT] '','','', '', ''
-- ================================================================================================================
CREATE PROCEDURE [dbo].[usp_GetProdPackingForBarcode_VNT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBarcode VARCHAR(50) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pWorkerCode VARCHAR(20) = NULL,
						@pMachineID VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @WorkerCode VARCHAR(20) = @pWorkerCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode	
	DECLARE @MachineID VARCHAR(20) = ISNULL(@pMachineID,'')

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
	DECLARE @CompanyCode  varchar(20) = 'VNT' 
	DECLARE @NewBarcode VARCHAR(50)

	Declare @ProductGroupCode VARCHAR(20)

	SELECT @NewBarcode = NewBarcode 
	  FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	 WHERE OldBarcode = @Barcode



 
	 	DECLARE @OldBarcode VARCHAR(50)
	 	SELECT @OldBarcode = oldLotID
	  FROM STB_ChangePartNoAndLotNo WITH(NOLOCK)
	 WHERE NewLotID = @Barcode
	--For Vietnam Only, auto insert negative Quantity in V-28 - Packing
	--By Mr. Tung  first   on 25-November-2020
	--By Mr. Tung  second  on 31-March-2021
	SELECT  @CompanyCode = CompanyCode   
	FROM  STB_UserInfo 
	where UserID=@pProcessUserID

	if(@CompanyCode='VVT') begin
			--EXEC	usp_autoInsertQtyV28_VVT_uid 
			--					@pProcessUserID = @ProcessUserID,
			--					@pBarcode = @Barcode
			DECLARE @cCount NUMERIC(20,5)

			select @cCount = count(*)
			from STB_SetInfo
			where Barcode = @Barcode 

			if(@cCount=0) 
			begin 
				select @Barcode = STUFF(@Barcode,1,2,'VV')
			end

			if (@Barcode='VEM3562' OR @Barcode='VVM3562')
			begin
						SELECT
							''  AS ControlNo,
							''  AS DayPlanNo,
							''  AS PONo,
							@Barcode  AS Barcode,
							''  AS MaterialCode,
							''  AS MaterialName,
							0 AS  POPlanQty,
							''  AS MachineID,
							''  AS LineCode,
							'' as LineName,
							'' as RouteCode,
							''  AS WorkerCode,
							GETDATE() AS JobDate,
							0 AS PlanQty,
							0 AS ProdQty,
							0 AS  RemainQty,
							0 AS  InputQty,
							0 AS  OutputQty,			
							0 AS  DefectQty,
							0 AS  LossQty,

							0 AS BasicPackingQty,
							0 AS InProdQty,
							0 AS BarcodeCount,
							0 AS LotCount,
							0 AS BasicBoxQty,
							0 AS BoxQty,
							'' AS StockAttrib1

							, 0  AS VinylBagQty 
							, 0  AS InnerBoxQty  
							, 0  AS  OutBoxQty  
							, 0 AS InputValue
							, '' AS DecisionResult
							, '' AS LabelType 
			     return
			end
	end
	--end by Mr.Tung

	
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
			INNER JOIN         STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = SI.PONo                   AND POR.IsOutputRoute = 1
			LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)		       ON PRH.ControlNo = SI.ControlNo        AND PRH.RouteCode = POR.RouteCode
			LEFT OUTER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		       ON MQI.MaterialQcNo = SI.LotNumber                                                          --#200106J
			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				           ON DPP.DayPlanNo = SI.DayPlanNo
			--INNER JOIN STB_MaterialMaster MM WITH(NOLOCK)			--	ON MM.MaterialCode = SI.MaterialCode
			--INNER JOIN STB_MaterialType MT WITH(NOLOCK)  			--	ON MT.MaterialTypeCode = MM.MaterialTypeCode
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
			--MT.BasicMaterialType
			SI.InputLineCode,
			MQI.DecisionResult,
			DPP.DPPExtText01

	IF ISNULL(@DPPExtText01,'') = '1' 
	
	BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '마감처리된 Lot입니다'
			RETURN
	END

	-- 입력 받은 Lot번호로 해당 품목이 완제품(FERT)인지 확인 
	SELECT @ProductGroupCode = ProductGroupCode
	  FROM STB_MaterialMaster
	 WHERE MaterialCode = (SELECT TOP 1 MaterialCode 
	                         FROM STB_SetInfo 
							WHERE Barcode IN (@Barcode, @NewBarcode))
	
	--검사결과가 합격이거나 특채가 아니고, 완주공장이면서 완제품이면 제품검사를 진행해야 한다.		
	IF ISNULL(@DecisionResult,'None') NOT IN ('Pass','Special')  AND @WorkCenterCode = 'VNT_F2' AND @ProductGroupCode = 'FERT'
	
	BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	
			       @ProcessLanguage,
					'^제품검사 합격이 되지 않은 바코드입니다^',
					@ErrorMessage OUTPUT
			  SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END
			
	--IF @InputLineCode <> @LineCode BEGIN
	--		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
	--										'^라인에 맞지 않는 바코드입니다^',
	--										@ErrorMessage OUTPUT
	--		SET @ErrorMessage = @ErrorMessage + ' [%s]/[%s]'
	--		RAISERROR(@ErrorMessage,16,1,@InputLineCode,@Barcode)
	--		RETURN
	--END	

	-- 생산시 불량으로 차감된 수량이 마지막 Lot에 포함되므로 수량으로 에러낼수 없음
	--IF @CurrentQty >= @TotalQty BEGIN
	--		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
	--										'^해당 Lot 생산이 완료됐습니다^',
	--										@ErrorMessage OUTPUT
	--		SET @ErrorMessage = @ErrorMessage + ' [%s] ' + CONVERT(VARCHAR,@CurrentQty) + '/' + CONVERT(VARCHAR,@TotalQty)
	--		RAISERROR(@ErrorMessage,16,1,@Barcode)
	--		RETURN
	--END


	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTimeV3(@ProcessDateTime,@WorkCenterCode)
	DECLARE @JobDate       DATE            = SUBSTRING(@JobDateShift,1,8)
	DECLARE @ShiftCode     VARCHAR(1)  = SUBSTRING(@JobDateShift,9,1)
 
	
	--;WITH Prod AS
	--(
	--	SELECT
	--			PRS.PONo,
	--			PRS.LineCode,
	--			PRS.RouteCode,
	--			PRS.JobDate,
	--			PRS.ShiftCode,
	--			SUM(PRS.InputQty) AS InputQty,
	--			SUM(PRS.OutputQty) AS OutputQty,
	--			SUM(PRS.DefectQty) AS DefectQty,
	--			SUM(PRS.LossQty) AS LossQty
	--	FROM
	--			STB_ProdRouteSummary PRS WITH(NOLOCK)
	--	WHERE
	--			PRS.PONo = @PONo AND
	--			PRS.LineCode = @LineCode AND
	--			PRS.RouteCode = @RouteCode AND
	--			PRS.JobDate = @JobDate AND
	--			PRS.ShiftCode = @ShiftCode
	--	GROUP BY
	--			PRS.PONo,
	--			PRS.LineCode,
	--			PRS.RouteCode,
	--			PRS.JobDate,
	--			PRS.ShiftCode
	--), 
	-- #240530 CTE : ProdRoute2 추가
	;WITH ProdRoute AS
	(
		SELECT
				PRH.ControlNo,
				SUM(PRH.ProdQty) AS ProdRouteQty
		FROM
				STB_ProdRouteHist PRH                                WITH(NOLOCK)
				INNER JOIN STB_SetInfo SI                            WITH(NOLOCK)  ON SI.ControlNo = PRH.ControlNo
				INNER JOIN STB_ProductionOrderRouting POR  WITH(NOLOCK)	  ON POR.PONo = SI.PONo               AND					POR.IsOutputRoute = 1
				AND POR.RouteCode = PRH.RouteCode
		WHERE
				SI.Barcode = @Barcode
				OR SI.Barcode = @NewBarcode --(SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)
		GROUP BY
				PRH.ControlNo



	), ProdDefect AS
	(
		SELECT
				DRI.ControlNo,
				SUM(DRI.DefectQty) AS DefectQty,
				SUM(DRI.LossQty)    AS LossQty,
				SUM(DRI.RepairQty) AS RepairQty
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
		WHERE 1=1
		   AND DRI.ControlNo = @ControlNo
		   AND DRI.RepairType NOT IN ('MISSING')
		GROUP BY
				DRI.ControlNo
	), ProdRoute2 AS
	(
		SELECT
				PRH.ControlNo,
				SUM(PRH.ProdQty) AS ProdRouteQty
		FROM
				STB_ProdRouteHist PRH                                WITH(NOLOCK)
				INNER JOIN STB_SetInfo SI                            WITH(NOLOCK)  ON SI.ControlNo = PRH.ControlNo
				INNER JOIN STB_ProductionOrderRouting POR  WITH(NOLOCK)	  ON POR.PONo = SI.PONo               AND					POR.IsInputRoute = 1
				AND POR.RouteCode = PRH.RouteCode
		WHERE
				SI.Barcode = @Barcode
				OR SI.Barcode = @NewBarcode --(SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)
		GROUP BY
				PRH.ControlNo



	)
	SELECT
			SI.ControlNo,
			SI.DayPlanNo,
			SI.PONo,
			SI.Barcode,
			SI.MaterialCode,
			MM.MaterialName,
			POI.PlanQty AS POPlanQty,
			@MachineID AS MachineID,
			@LineCode AS LineCode,
			LI.LineName,
			POR.RouteCode,
			@WorkerCode AS WorkerCode,
			@JobDate AS JobDate,
			DPP.PlanQty,
			SI.ProdQty,
			CASE WHEN @MachineID = 'SPT' THEN ISNULL(PR2.ProdRouteQty,0) - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0)
			     ELSE SI.ProdQty - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0) + ISNULL(PD.RepairQty, 0) END   AS RemainQty, -- 불량수량 적용 -- #240530 지지체의 경우, 투입수량과 포장수량 - 불량 계산

			-- 원본백업
			--ISNULL(Prod.InputQty,0) AS InputQty,
			--ISNULL(Prod.OutputQty,0) AS OutputQty,
			--ISNULL(Prod.DefectQty,0) AS DefectQty,
			--ISNULL(Prod.LossQty,0) AS LossQty,

			ISNULL(PR.ProdRouteQty,0) AS InputQty,
			ISNULL(PR.ProdRouteQty,0) AS OutputQty,			
			PD.DefectQty,
			PD.LossQty,

			MM.BasicPackingQty,
			MM.BasicPackingQty AS InProdQty,
			1 AS BarcodeCount,
			0 AS LotCount,
			CONVERT(INT,(SI.ProdQty - ISNULL(PR.ProdRouteQty,0)) / MM.BasicPackingQty) AS BasicBoxQty,
			CONVERT(INT,(SI.ProdQty - ISNULL(PR.ProdRouteQty,0)) / MM.BasicPackingQty) AS BoxQty,
			'' AS StockAttrib1

			, ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty  -- 2020.10.08 추가
			, ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty  -- 2020.10.08 추가
			, ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty   -- 2020.10.08 추가
			, 0 AS InputValue
			, @DecisionResult AS DecisionResult
			, CASE WHEN SI.MaterialCode IN ('ECVT30-333', 'ECVT30-322', 'ECVT30-320', 'ECVT30-321') THEN 'ThinkwareLabel' 
				   WHEN POI.WorkCenterCode = 'VNT_F2' THEN 'MEA_PackLabel'
				   ELSE 'BoxLabel' END AS LabelType --#210422
			, MM.MaterialUnit
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)		ON POI.PONo = SI.PONo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				ON DPP.DayPlanNo = SI.DayPlanNo
			--LEFT OUTER JOIN Prod				                                        ON Prod.PONo = SI.PONo
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)				        ON LI.LineCode = @LineCode
			LEFT OUTER JOIN ProdRoute PR				                                ON PR.ControlNo = SI.ControlNo
			LEFT OUTER JOIN ProdRoute2 PR2 ON PR2.ControlNo = SI.ControlNo
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)	ON POR.PONo = SI.PONo AND				POR.IsOutputRoute = 1
			LEFT OUTER JOIN ProdDefect PD				                                ON PD.ControlNo = SI.ControlNo			

			LEFT OUTER JOIN STB_PackingStandard SPS				             
			  ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
	WHERE 1=1
     --AND  SI.Barcode = @Barcode                                                                                                                                                          -- 원본 백업
	   AND (SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode --(SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)       -- 기종변경으로 인해서 수정 (2020.04.16)
		OR SI.Barcode =  	@OldBarcode
			
			  )

END