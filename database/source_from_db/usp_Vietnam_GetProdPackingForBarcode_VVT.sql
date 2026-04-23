
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-19
-- Browsable : true

-- 프로시저 실행 :  EXEC [usp_Vietnam_GetProdPackingForBarcode_VVT] '','','VVOP223R010536', '', ''

-- EXEC [usp_Vietnam_GetProdPackingForBarcode_VVT] '','','', '', '' usp_GetProdPackingForBarcode_VNT
-- ================================================================================================================
CREATE PROCEDURE [dbo].[usp_Vietnam_GetProdPackingForBarcode_VVT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBarcode VARCHAR(50) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pWorkerCode VARCHAR(20) = NULL,
						@pMachineID VARCHAR(20) = NULL,
						--VVLM273R050503
						--usp_PackingQtyPerSize_popup
						@pBoxQty INT = NULL
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
	

	--For Vietnam Only, auto insert negative Quantity in V-28 - Packing
	--By Mr. Tung  first   on 25-November-2020
	--By Mr. Tung  second  on 31-March-2021
	SELECT  @CompanyCode = CompanyCode
			--,@WorkCenterCode = WorkCenterCode  -- turn on for audit 2025-09-05
	FROM  STB_UserInfo 
	where UserID=@pProcessUserID ;
------------------------------------------------------------ check QC pass hàng này chưa
	if(@CompanyCode='VVT' and @WorkCenterCode in ('VVT_F1') )
	begin	
			declare @MaterialCode varchar(20);
			declare @Partno varchar(20);

			----Lấy Parno
			select 
				@Partno= case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
							when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
							else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end 
			from   STB_SetInfo SI  WITH(NOLOCK) join  STB_MaterialMaster MM  WITH(NOLOCK)  on  SI.MaterialCode = MM.MaterialCode 
			where   Barcode = @Barcode
		
			select @MaterialCode= MaterialCode from STB_SetInfo WHERE Barcode = @Barcode
					--IF (@Barcode NOT LIKE 'M%')  AND (@MaterialCode NOT IN (
					--											   'VEL10303R8107G', 'VECV30-051', 'VHCV23-004', 'VVVEC30-056',
					--											   'VNVEC30-039', 'PECVT30-104', 'VNVEL38-001', 'VNVEL38-002',
					--											   'VVVEC27-025', 'VVVEC30-054', 'VVVEC30-032', 'VSVVVEC30-032',
					--											   'VVVEC30-052', 'S35626S-01', 'VVVEC30-S01', 'VVVEC30-058',
					--											   'VVVEC30-S02', 'VVVEC30-037', 'VVVEC27-028', 'VNVEC30-035',
					--											   'VVVEC30-053', 'VVVEC30-S56', 'VVVEC30-043', 'LSECVT30-076',
					--											   'VVVEC30-038', 'VVVEC30-046', 'VVVET27-002', 'VVVEC30-060',
					--											   'VNVEL38-003', 'MVCE160-001', 'VNVEL38-005', 'VNVEL38-006'
					--										   ))

					IF (@Barcode NOT LIKE 'M%') AND (@Partno NOT IN (
														'VEL10303R8107G', 'VEC3R0107QG-L', 'VHC2R3307QG', 'VEC3R0107QG-C', 
														'VEC3R0407QA', 'VEL08253R8506G-B034', 'VEL08253R8506G', 'VEC2R7107QG', 
														'VEC3R0107QG-B036', 'VEB3R0107QG', 'VEC3R0227QG', 'VEM16R0606QG', 
														'VEC3R0207QG', 'VEC3R0287QG', 'VEC3R0367QG', 'VEC2R7367QG', 
														'VEC3R0357QG', 'VEC3R0387QG', 'VEC3R0487QG', 'VEC3R0507QG', 
														'VEP3R0367QG', 'VEP3R0507QG', 'VET35622R7367G', 'VEC3R0727QG', 
														'VEL13353R8257G', 'VEL13353R8257G-B0625', 'VEL08253R8506G-B030R'
													))
					begin
								Declare @DecisionResultQC varchar(20) = NULL;
									select @DecisionResultQC=DecisionResult from STB_MaterialQcInfo MQI where  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo WHERE Barcode = @Barcode)

								if(@DecisionResultQC not LIKE 'pass' OR @DecisionResultQC IS NULL)
										begin
											EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																N'Lot này QC chưa đánh giá PASS vui lòng liên hệ chị Hạnh BN: ',
																@ErrorMessage OUTPUT
										SET @ErrorMessage = @ErrorMessage + ' [%s]'
										RAISERROR(@ErrorMessage,16,1,@Barcode)
										RETURN	
										end
					end



			
			
	end


---------------------------------------------------------


	if(@CompanyCode='VVT') 
	begin
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
			OR SI.Barcode = (SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)
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
			--raiserror (@DPPExtText01,16,1)
	IF ISNULL(@DPPExtText01,'') = '1' 
	
	BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '마감처리된 Lot입니다'
			RETURN
	END
			
	--IF ISNULL(@DecisionResult,'None') NOT IN ('Pass','Special')  AND @Barcode like 'VJ%'
	
	--BEGIN
	--		EXEC SmartFramework.dbo.usp_GetAddonStringResource	
	--		       @ProcessLanguage,
	--				'^제품검사 합격이 되지 않은 바코드입니다^',
	--				@ErrorMessage OUTPUT
	--		  SET @ErrorMessage = @ErrorMessage + ' [%s]'
	--		RAISERROR(@ErrorMessage,16,1,@Barcode)
	--		RETURN
	--END
			
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
				OR SI.Barcode = (SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)
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
	)
	SELECT
			SI.ControlNo,
			SI.DayPlanNo,
			SI.PONo,
			SI.Barcode,
			SI.MaterialCode,
			MM.MaterialName,
			--case when SI.MaterialCode = 'ECVT30-367' then 'HY-CAP  WEC3R0106QG (1030)' else MM.MaterialName end as MaterialName, --Ms Phuong request update audit 2025-11-26
			POI.PlanQty AS POPlanQty,
			@MachineID AS MachineID,
			@LineCode AS LineCode,
			LI.LineName,
			POR.RouteCode,
			@WorkerCode AS WorkerCode,
			@JobDate AS JobDate,
			DPP.PlanQty,
			SI.ProdQty,
			ISNULL(SI.ProdQty,0) - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0) + ISNULL(PD.RepairQty, 0)  AS RemainQty, -- 불량수량 적용

			-- 원본백업
			--ISNULL(Prod.InputQty,0) AS InputQty,
			--ISNULL(Prod.OutputQty,0) AS OutputQty,
			--ISNULL(Prod.DefectQty,0) AS DefectQty,
			--ISNULL(Prod.LossQty,0) AS LossQty,

			ISNULL(PR.ProdRouteQty,0) AS InputQty,
			ISNULL(PR.ProdRouteQty,0) AS OutputQty,			
			PD.DefectQty,
			PD.LossQty,

			isnull(MM.BasicPackingQty,0)BasicPackingQty,
			ISNULL(SI.ProdQty,0) - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0) + ISNULL(PD.RepairQty, 0)   AS InProdQty,
			0 AS BarcodeCount,
			0 AS LotCount,
			CONVERT(INT,(ISNULL(SI.ProdQty,0) - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0) + ISNULL(PD.RepairQty, 0)) / isnull(MM.BasicPackingQty,1)) AS BasicBoxQty,
			CONVERT(INT,(ISNULL(SI.ProdQty,0) - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0) + ISNULL(PD.RepairQty, 0)) / isnull(MM.BasicPackingQty,1)) AS BoxQty,
			CONVERT(INT,(ISNULL(SI.ProdQty,0) - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0) + ISNULL(PD.RepairQty, 0)) / isnull(MM.BasicPackingQty,1)) AS BoxQty1,
			'' AS StockAttrib1

			, ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty  -- 2020.10.08 추가
			, ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty  -- 2020.10.08 추가
			, ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty   -- 2020.10.08 추가
			, 0 AS InputValue
			, @DecisionResult AS DecisionResult
			--, CASE WHEN SI.MaterialCode IN ('ECVT30-333', 'ECVT30-322', 'ECVT30-320', 'ECVT30-321') 
			--       THEN 'ThinkwareLabel' ELSE 'BoxLabel' END AS LabelType --#210422
			,'BoxLabel'  AS LabelType
			, 0 as MergeQty
			, '' as MarkingCode
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)		ON POI.PONo = SI.PONo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				ON DPP.DayPlanNo = SI.DayPlanNo
			--LEFT OUTER JOIN Prod				                                        ON Prod.PONo = SI.PONo
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)				        ON LI.LineCode = @LineCode
			LEFT OUTER JOIN ProdRoute PR				                                ON PR.ControlNo = SI.ControlNo
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)	ON POR.PONo = SI.PONo AND				POR.IsOutputRoute = 1
			LEFT OUTER JOIN ProdDefect PD				                                ON PD.ControlNo = SI.ControlNo			

			LEFT OUTER JOIN STB_PackingStandard SPS				             ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
	WHERE 1=1
     --AND  SI.Barcode = @Barcode                                                                                                                                                          -- 원본 백업
	   AND (SI.Barcode = @Barcode OR SI.Barcode = (SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @Barcode)       -- 기종변경으로 인해서 수정 (2020.04.16)
			  )

END
