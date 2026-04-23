
-- ===========================================================================================================
-- Author: Jackaroe
-- Create date: 2020-04-06
-- Browsable : true
-- Group : 생산관리 > 생산현황 > [B780] Lot생산이력정보
-- Description: 품질 이미정차장 요청화면 + 생산팀 이력정보
-- Modified: 
-- 생산부문 요청사항 적용 2020.04.06 By Jackaroe #0406
--                 2021.03.12 마킹문자 
--                 2021.12.22 생산현황에 맞는 공정별이력검사화면 (최덕렬)

-- 프로시저실행 (2021-12-21)  :   usp_LotTrackingInfo_get_20211222  'kilee','Korean', '', 'VNT', '2020-12-20', '2021-12-20', 'E-33', 'VJLT203R815708', '', '', '', ''
 --                                       usp_LotTrackingInfo_get_20211222  'kilee','Korean', '', 'VNT', '2020-12-20', '2021-12-20', 'E-33', '', '', '', '', ''
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[usp_LotTrackingInfo_get_20211222]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pUtcOffset INT,
						@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
						@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pLotNo VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(30) = NULL,
						@pMarkingLetter VARCHAR(8) = NULL,
						@pIsOutputRoute BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode   VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END

	DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            
	DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'   
	
	DECLARE @RouteCode       VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE @LineCode         VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE @LotNo             VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE @MaterialCode    VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @MarkingLetter    VARCHAR(8) = CASE WHEN ISNULL(@pMarkingLetter, '') = '' THEN '*' ELSE @pMarkingLetter END   --2021.03.12 추가

	 -- #211202 프로시저에는 이미 선언되어 있는 파라미터이나 실제 쿼리에서는 사용하지 않음. 이 파라미터를 이용해 포장 실적의 불량수량을 예외처리함.
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute

--IF @CompanyCode='VNT' or @CompanyCode='*'     -- 한국본사 또는 전체일경우

--BEGIN

; WITH NextProd AS
	(
		SELECT
				SI.ControlNo,
				MAX(PRH.RouteCode) AS AftRouteCode,
				SUM(PRH.ProdQty) AS AftProdQty
		FROM
									   STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN        STB_ProductionOrderRouting POR WITH(NOLOCK)			 ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	     ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN        STB_ProdRouteHist PRH WITH(NOLOCK)					     ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode
        WHERE 1=1
		   --AND BRD.IsOutputRoute <> '1'    -- 포장공정 조회안되는 이유
		GROUP BY
				SI.ControlNo
	)


	--;WITH NextProd AS
	--(
	--	SELECT
	--			PRH.PoNo
	--		 ,	SUM(PRH.ProdQty) AS AftProdQty
	--	FROM
	--								   STB_SetInfo SI WITH(NOLOCK)
	--			INNER JOIN        STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
	--			LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	    ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
	--			INNER JOIN        STB_ProdRouteHist PRH WITH(NOLOCK)					ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode
	--	GROUP BY
	--	        PRH.PoNo
	--)


	SELECT CASE WHEN PRS.ComPanyCode = 'VNT' THEN '전주본사'
	                 WHEN PRS.ComPanyCode = 'VVT' THEN '베트남' ELSE '기타' END   AS 사업장
			 , SI.ControlNo
			 , SI.Barcode
			 , PRS.MaterialCode
			 , Max(MM.MaterialName) AS MaterialName
			 --, SI.InputLineCode
			 , PRS.LineCode
			 , LI.LineDesc AS LineName
			 , PRS.RouteCode
			 , RI.RouteName
			 --, dbo.fnGetLocalTime(Max(PRH.ProdDateTime), @pUtcOffset) AS ProdDateTime
			 , PRS.MachineCode
			 , MM2.MachineName
			 --, PRH.WorkerCode
			 --, PWI.WorkerName
			 --, CASE WHEN SI.SIExtInt01 IS NULL THEN ''
				--	  WHEN SI.SIExtInt01 = 1      THEN '검사불합격'
				--	  WHEN SI.SIExtInt01 = 0      THEN '검사불합격이력'    END                               AS RouteInspectionResult
			-- , CONVERT(BIT,CASE WHEN ISNULL(SUM(NP.AftProdQty),0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd		   
			-- , PRH.ProdQty                                                                             AS InputProdQty    -- 투입수량			
			-- , (PRH.ProdQty - ISNULL(DRI.DefectQty, 0))                                          AS ProdQty           -- 생산수량
			-- , ISNULL(SUm(DRI.DefectQty), 0)                                                       AS DefectQty         -- 불량수량 
			 , SUM(PRS.OutputQty)            AS OutputQty                                                                      -- 투입수량 (kilee, 2020.03.25)
			 , CASE WHEN  PRS.RouteCode IN ('E-28', 'V-28') THEN SUM(PRS.OutputQty)  ELSE (SUM(PRS.OutputQty) - SUM(PRS.DefectQty) - ISNULL(SUM(RepairInfo.RepairQty), 0)) END AS GoodsQty          -- 생산수량  (kilee, 2020.03.25) #211202
			 , CASE WHEN  PRS.RouteCode IN ('E-28', 'V-28') THEN 0 ELSE SUM(PRS.DefectQty) - ISNULL(SUM(RepairInfo.RepairQty), 0)  END AS DefectQty --#211202		  
			 --, MAX(SIExtText07)                                                                                                                                          AS MarkingLetter    -- 마킹문자
			-- , CASE WHEN MAX(MC.MeasureCount) > 0      AND PRH.RouteCode IN ('E-25', 'V-25') THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END   AS IsSelfInspection
			---- , CASE WHEN AFM.Barcode is Not Null AND PRH.RouteCode IN ('E-25', 'V-25') THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END   AS IsXRayImage
			-- , CASE WHEN AFM.Barcode is Not Null THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END   AS IsXRayImage
	  FROM 
	          STB_ProdRouteSummary                   PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo                      LI WITH(NOLOCK)   ON LI.LineCode = PRS.LineCode
			LEFT OUTER JOIN STB_RouteInfo                    RI WITH(NOLOCK)  ON RI.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_MachineMaster          MM2 WITH(NOLOCK)  ON MM2.MachineCode = PRS.MachineCode
			LEFT OUTER JOIN STB_MaterialMaster            MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode			
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo      POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan                DPP WITH(NOLOCK) ON DPP.PONo = PRS.PONo AND DPP.LineCode = PRS.LineCode AND DPP.PlanDate = PRS.JobDate AND DPP.PlanShiftCode = PRS.ShiftCode
			
			LEFT OUTER JOIN  STB_SetInfo SI WITH(NOLOCK) ON SI.PoNo = PRS.Pono 	  AND SI.MaterialCode = PRS.MaterialCode        
		 --   LEFT OUTER JOIN STB_ProdRouteHist    PRH	  WITH(NOLOCK)  ON SI.ControlNo = PRH.ControlNo			 			
		    --LEFT OUTER JOIN STB_ProdWorkerInfo PWI	 WITH(NOLOCK)         ON PRH.WorkerCode = PWI.WorkerCode
				  
			LEFT OUTER JOIN NextProd                 NP	 WITH(NOLOCK)     ON NP.ControlNo = SI.ControlNo

			--LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
			--						FROM STB_DefectRepairInfo  WITH(NOLOCK) 
			--						WHERE RepairType = 'NONE'
			--						GROUP BY ControlNo, FindRouteCode
			--						  ) DRI  ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

			--LEFT OUTER JOIN (
			--							SELECT ProdNo, COUNT(*) AS MeasureCount
			--							  FROM STB_CommInspDocHistory CIDH WITH(NOLOCK) 
			--							  LEFT OUTER JOIN STB_CommInspDocItem CIDI					ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
			--							  INNER JOIN STB_CommInspMeasureHist CIMH					ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
			--							 GROUP BY ProdNo
			--					  ) MC  ON SI.ControlNo = MC.ProdNo     -- #0406
			
			--LEFT OUTER JOIN (
			--							SELECT Barcode
			--							  FROM SmartFramework_File.dbo.STB_AttachedFileMaster WITH(NOLOCK) 
			--							 WHERE 1=1
			--							    and (SystemName= 'XRay' Or SystemName= 'STB_XRayImageUploadHist')
			--							 GROUP BY Barcode
			--					     ) AFM ON (SI.Barcode = AFM.Barcode OR AFM.Barcode = (SELECT NewBarcode 
			--																										   FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) 
			--																										  WHERE OldBarcode = @LotNo))              -- #0406
			LEFT OUTER JOIN (
									SELECT CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo
										  ,MaterialCode, FindLineCode, FindRouteCode, ISNULL(SUM(RepairQty), 0) AS RepairQty
									  FROM STB_DefectRepairInfo
									 WHERE RepairType NOT IN ('MISSING')
									 GROUP BY CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo, MaterialCode, FindLineCode, FindRouteCode
								   ) RepairInfo   ON RepairInfo.CompanyCode = PRS.CompanyCode
													AND RepairInfo.WorkCenterCode = PRS.WorkCenterCode
													AND RepairInfo.FindJobDate = PRS.JobDate
													AND RepairInfo.FindShiftCode = PRS.ShiftCode
													AND RepairInfo.PONo = PRS.PONo
													AND RepairInfo.MaterialCode = PRS.MaterialCode
													AND RepairInfo.FindLineCode = PRS.LineCode
													AND RepairInfo.FindRouteCode = PRS.RouteCode
	 WHERE 1=1
		AND PRS.TimeCode <> 'E'         
	-- AND SI.InputJobDate BETWEEN @FromDate AND @ToDate
	-- AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
		AND (PRS.JobDate BETWEEN @FromDate AND @ToDate) 	
		AND ((@CompanyCode = '*') OR (PRS.CompanyCode = @CompanyCode))                                      -- 추가 용은재 (2020.01.23)
		AND (@RouteCode = '*' OR PRS.RouteCode = @RouteCode)
		--AND (PRH.RouteCode IN ('E-27', 'E-28') OR PRH.RouteCode IN (
		--                                                                               SELECT RouteCode 
		--																				FROM STB_ProductMachine 
		--																				WHERE MachineCode = PRH.MachineCode)
		--																				)
		AND (@LineCode = '*' OR PRS.LineCode   = @LineCode)
		--AND (@LotNo = '*' OR SI.Barcode       = @LotNo)
		AND (@MaterialCode = '*' OR PRS.MaterialCode = @MaterialCode)
		AND ISNULL(NP.AftProdQty,0) > CASE WHEN @RouteCode = '*' THEN -1  WHEN (dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) IS NULL OR dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) IN ('E-28', 'V-28')) THEN -1  ELSE 0  END            
		--AND  ((@MarkingLetter = '*') OR (SIExtText07 = @MarkingLetter))         
	
	 GROUP BY
			PRS.RouteCode
			,SI.ControlNo
			,SI.Barcode
			,PRS.MaterialCode
			,PRS.LineCode
			,LI.LineDesc 
			,PRS.RouteCode
			, RI.RouteName
			,PRS.CompanyCode
			
			--, DRI.DefectQty
			, PRS.MachineCode
			, MM2.MachineName
			--, PRH.WorkerCode
			--, PWI.WorkerName
			--, SI.SIExtInt01
			--, NP.AftProdQty
			,PRS.WorkCenterCode
			,PRS.PONo
			,PRS.MaterialCode			
			,PRS.LineCode
			,LI.LineName
			,RI.RouteName			
			,PRS.MoldNumber
			,PRS.MachineCode		
			--,	PRS.JobDate
			--,	PRS.ShiftCode			
			,PRS.TimeCode
			--,	NP.AftProdQty  --추가
			--, SIExtText07
			,  PRS.RouteCode 			
		--	,  AFM.Barcode 
			-- , MC.MeasureCount 
			--, PRH.ProdDateTime
	 ORDER BY PRS.LineCode, PRS.RouteCode
	
	--ORDER BY PRH.ProdDateTime, SI.Barcode, PRH.RouteCode
	 
--End   


------ // 베트남법인

--if @CompanyCode='VVT' 

--Begin
		
--	select @FromDate    = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:29:59'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
--	select @ToDate      = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:30:01'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
	
--	; with tung as (
--		 select  c.Barcode--,b.RouteCode,RouteCode as FindRouteCode,min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
--		 from 
--		 STB_SetInfo c WITH(NOLOCK) 
--		 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
--		 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
	
--	 ),
--	 tungfinished as (
--	  	 select  c.Barcode,count(b.RouteCode) as totalcount
--		 from 
--		 STB_SetInfo c WITH(NOLOCK) 
--		 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
--		 where  c.Barcode in (select Barcode from tung WITH(NOLOCK) )
--		 group by c.Barcode
--	 ),
--	 tungfinished2 as (		
--		 select  c.Barcode,b.RouteCode	, (row_number() over (partition by c.Barcode order by b.Routecode ASC)-tungfinished.totalcount )	  as ProdQtyFinishYn 	 
--		 from 
--		 STB_SetInfo c WITH(NOLOCK) 
--		 left outer join tungfinished  WITH(NOLOCK) on tungfinished.Barcode=c.Barcode
--		 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
--		 where  c.Barcode in (select Barcode from tung WITH(NOLOCK) )
--		 --group by c.Barcode,b.RouteCode--,tungfinished.totalcount	 
--	 ),
--	  tung0 as (
--	 	select  c.Barcode,b.RouteCode,RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
--		min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
--		from  STB_SetInfo c WITH(NOLOCK) 
--		 left outer join  STB_ProdRouteHist b WITH(NOLOCK) 	on c.ControlNo=b.ControlNo	 
--		 where c.Barcode in (select Barcode from tung WITH(NOLOCK) )
--		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01

--		 union
--		 select  c.Barcode, FindRouteCode as RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,'' as MachineCode,'' as WorkerCode,SIExtText07,SIExtInt01,
--		 0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
--		 from  STB_SetInfo c WITH(NOLOCK) 
--		 full outer join  STB_DefectRepairInfo a  WITH(NOLOCK) on  a.ControlNo=c.ControlNo
--		 where   c.Barcode in (select Barcode from tung WITH(NOLOCK) )
--		 group by c.Barcode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,/*c.MachineCode,c.WorkerCode,*/SIExtText07,SIExtInt01

--	 ),
--	 tung11 as (
--	 select Barcode,RouteCode,FindRouteCode,max(ControlNo) as ControlNo,max(MaterialCode) as MaterialCode,max(InputLineCode) as InputLineCode,max(MachineCode) as MachineCode,
--	 max(WorkerCode) as WorkerCode,max(SIExtText07) as SIExtText07,max(SIExtInt01) as SIExtInt01,sum(ProdQty)as ProdQty,sum(DefectQty) as DefectQty,
--	 /*sum(ProdQty)-sum(DefectQty) as soluongOut,*/max(ProdDateTime) as ProdDateTime
--	 from tung0 WITH(NOLOCK) 
--		group by Barcode,RouteCode,FindRouteCode
	
--	),
--	tung1 as (
--	select 
--	tung11.*, isnull(ProdQtyFinishYn,0) as ProdQtyFinishYn
--	 from tung11 WITH(NOLOCK) 
--	 left outer join tungfinished2  WITH(NOLOCK) 
--	 on tung11.Barcode = tungfinished2.Barcode and tung11.RouteCode = tungfinished2.RouteCode	 
--	 ),
--	tung22 as (
--	select *
--	from tung1 WITH(NOLOCK)  where RouteCode='V-22'
--	),
--	tung23 as (
--	select *
--	from tung1 WITH(NOLOCK)  where RouteCode='V-23'
--	)
--	,
--	tung24 as (
--	select *
--	from tung1 WITH(NOLOCK)  where RouteCode='V-24'
--	)
--	,
--	tung25 as (
--	select *
--	from tung1 WITH(NOLOCK)  where RouteCode='V-25'
--	)
--	,
--	tung27 as (
--	select *
--	from tung1 WITH(NOLOCK)  where RouteCode='V-27'
--	)
--	,
--	tung28 as (
--	select *
--	from tung1 WITH(NOLOCK)  where RouteCode='V-28'
--	)
--	,
--	tung40 as (
--	select *
--	from tung1 WITH(NOLOCK)  where RouteCode='V-40'
--	),
--	tlast as (
--				select *from tung22 WITH(NOLOCK) 
--				union
--				select tung23.* from tung23 WITH(NOLOCK) 
--				union  																	
--				select tung40.* from tung40 WITH(NOLOCK) 
--				union									 								
--				select tung24.* from tung24 WITH(NOLOCK) ,tung22 WITH(NOLOCK)   where tung24.Barcode = tung22.Barcode and ( tung24.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) or tung24.ProdQtyFinishYn<0)
--				union  									  									
--				select tung25.* from tung25 WITH(NOLOCK) ,tung24 WITH(NOLOCK)   where tung25.Barcode = tung24.Barcode and ( tung25.ProdDateTime >= DATEADD(ss,5,tung24.ProdDateTime) or tung25.ProdQtyFinishYn<0)
--				union  									 									
--				select tung27.* from tung27 WITH(NOLOCK) ,tung25 WITH(NOLOCK)   where tung27.Barcode = tung25.Barcode and ( tung27.ProdDateTime >= DATEADD(ss,5,tung25.ProdDateTime) or tung27.ProdQtyFinishYn<0)
--				union  									 									
--				select tung28.* from tung28 WITH(NOLOCK) ,tung27 WITH(NOLOCK)   where tung28.Barcode = tung27.Barcode and ( tung28.ProdDateTime >= DATEADD(ss,5,tung27.ProdDateTime) or tung28.ProdQtyFinishYn<0)
--				),
--	last2 as (
--					Select Barcode,(RouteCode),(FindRouteCode),ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01, ProdQty, DefectQty,/*soluongOut,*/ 
--					CONVERT(varchar(19),ProdDateTime,120) as ProdDateTime
--					from tlast WITH(NOLOCK) 
--					),
--	DRI as (
--				select * from last2 WITH(NOLOCK) 
--				where  ProdDateTime>@FromDate  and ProdDateTime<@ToDate
--				)
--	select
--		   'VVT'   AS 사업장
--		  ,DRI.ControlNo
--	      ,DRI.Barcode
--		  ,DRI.MaterialCode
--		  ,MM2.MaterialName
--		  ,DRI.InputLineCode
--		  ,LI.LineName
--		  ,DRI.RouteCode as RouteCode
--		  ,RI.RouteName

--		  ,dbo.fnGetLocalTime (convert(datetime,DRI.ProdDateTime,120), @pUtcOffset) as ProdDateTime
--		  ,DRI.MachineCode
--		  ,MM.MachineName
--		  ,DRI.WorkerCode
--		  ,PWI.WorkerName
--		  ,CASE WHEN DRI.SIExtInt01 IS NULL THEN ''
--		          WHEN DRI.SIExtInt01 = 1      THEN '검사불합격'
--				  WHEN DRI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult

--		  , DRI.ProdQty                                   AS InputProdQty    -- 투입수량
--		  , ISNULL(DRI.DefectQty, 0)                    AS DefectQty          -- 불량수량 		  
--		  , (DRI.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty           -- 생산수량		  
--		  , SIExtText07 AS MarkingLetter   
--	from DRI  WITH(NOLOCK) 
--			LEFT OUTER JOIN STB_RouteInfo          RI	  WITH(NOLOCK)    ON DRI.FindRouteCode = RI.RouteCode
--			  LEFT OUTER JOIN STB_MaterialMaster   MM2	  WITH(NOLOCK)    ON DRI.MaterialCode = MM2.MaterialCode
--			  LEFT OUTER JOIN STB_LineInfo         LI	  WITH(NOLOCK)    ON DRI.InputLineCode = LI.LineCode			 
--			  LEFT OUTER JOIN STB_MachineMaster    MM	  WITH(NOLOCK)    ON DRI.MachineCode = MM.MachineCode
--			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)   ON DRI.WorkerCode = PWI.WorkerCode
--	 where 1=1
--	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
--	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
--	   AND (@LotNo = '*' OR DRI.Barcode       = @LotNo)
--end



END