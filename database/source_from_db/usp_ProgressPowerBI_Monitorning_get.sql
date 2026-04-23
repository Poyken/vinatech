
-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-08-18
-- Browsable : True
-- Group : 생산관리 > 생산현황 > 라인별 도식화 현황판
-- Description: 
-- Modified: 
 

-- EXEC usp_ProgressPowerBI_Monitorning_get 'VNT', '', '', ''
-- =============================================

CREATE PROCEDURE [dbo].[usp_ProgressPowerBI_Monitorning_get]					
						@pCompanyCode VARCHAR(20) = 'VNT',  			
						@pRouteCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,				
						@pMaterialCode VARCHAR(30) = NULL

AS

	   DECLARE @CompanyCode   VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	-- DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	-- DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	   DECLARE	@RouteCode       VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	   DECLARE	@LineCode         VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	-- DECLARE	@LotNo             VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	   DECLARE	@MaterialCode    VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

	;WITH NextProd AS
	(

		SELECT
				SI.ControlNo,
				MAX(PRH.RouteCode) AS AftRouteCode,
				SUM(PRH.ProdQty)     AS AftProdQty	
				
		FROM
									    STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN        STB_ProductionOrderRouting POR WITH(NOLOCK)	   ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	   ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN        STB_ProdRouteHist PRH WITH(NOLOCK)					   ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode				
				

        WHERE 1=1		   
		   And SI.IsProdFinish <> '1'
		   And InputJobDate is not Null
		   And InputLineCode is not Null
		   And SI.InputLineCode Like 'ASSYLINE%'
		   And prh.CompanyCode = 'VNT'
		GROUP BY
				SI.ControlNo
	)

	--select * from STB_DayProdPlan


	SELECT PRH.ComPanyCode
			 --, SI.ControlNo
			-- , SI.Barcode
			 , SI.MaterialCode
			 , MM2.MaterialName
			 , SI.InputLineCode
		
            ,  LI.LineName

			-- , PRH.RouteCode

				 , Case When PRH.RouteCode = 'E-22' Then 'E-22(권취)'
						  When PRH.RouteCode= 'E-24' Then 'E-24(커링)'
						  When PRH.RouteCode= 'E-25' Then 'E-25(슬리브)'
						  When PRH.RouteCode = 'E-28' Then 'E-28(입고)' Else '기타' End AS '공정코드'

			 , RI.RouteName
			 --, dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset) AS ProdDateTime
			 --, MAX(PRH.MachineCode)
			 --, MAX(MM.MachineName)
			 --, PRH.WorkerCode
			 --, PWI.WorkerName
			 --, CASE WHEN SI.SIExtInt01 IS NULL THEN ''
			 --	  WHEN SI.SIExtInt01 = 1      THEN '검사불합격'
			 --	  WHEN SI.SIExtInt01 = 0      THEN '검사불합격이력'    END                              AS RouteInspectionResult
			 , CONVERT(BIT,CASE WHEN ISNULL(SUM(NP.AftProdQty),0) > 0 THEN 1	ELSE 0 	END) AS IsHasNextProd
		   
		     , ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS '계획(EA)'
			 , ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputProdQty    -- 투입수량
			 , ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty         -- 불량수량 
			 ,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS '생산(EA)'           -- 생산수량)
		

			  , Case When SUM(PRH.ProdQty) = 0 Then 0 
			           When SUM(Round(DPP.PlanQty, 0) )   = 0 Then 0 
			            Else Round((SUM(PRH.ProdQty)    /  SUM(DPP.PlanQty)  * 100), 1)  End       AS '진행율%'   

    --          , Case When SUM(PRH.ProdQty) = 0 Then 0 
			 --          When SUM(Round(DPP.PlanQty, 0) )   = 0 Then 0 
			 --           Else (SUM(PRH.ProdQty) - SUM(DRI.DefectQty))   /  SUM(DPP.PlanQty)  * 100  End       AS '진행율(%)'   

				--, Case When SUM(PRH.ProdQty) = 0 Then 0 
				--		When (SUM(PRH.ProdQty) - SUM(DRI.DefectQty))  = 0 Then 0 
				--		Else ((SUM(PRH.ProdQty) - SUM(DRI.DefectQty)) / SUM(DPP.PlanQty)) * 100  End       AS '진행율(%%)'   

			-- , SIExtText07                                                                                     AS MarkingLetter    -- 마킹문자
			 --, CASE WHEN MC.MeasureCount > 0 AND PRH.RouteCode IN ('E-25', 'V-25')         THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END   AS IsSelfInspection
			 --, CASE WHEN AFM.Barcode IS NOT NULL AND PRH.RouteCode IN ('E-25', 'V-25') THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END   AS IsXRayImage
	  FROM STB_SetInfo SI

			  --LEFT OUTER JOIN STB_ProdRouteHist    PRH	    ON SI.ControlNo = PRH.ControlNo

			    LEFT OUTER JOIN ( 
			                             SELECT ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, Max(MaterialCode) as MaterialCode, MachineCode
										  FROM STB_ProdRouteHist 
										 WHERE 1=1
										   And JobDate Between  Getdate()-5 And Getdate()
										   And ComPanyCode = 'VNT'
										 Group by ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, MachineCode
									  ) PRH	                                              ON SI.ControlNo = PRH.ControlNo


			  LEFT OUTER JOIN STB_RouteInfo           RI	    ON PRH.RouteCode = RI.RouteCode
			  LEFT OUTER JOIN STB_MachineMaster  MM	    ON PRH.MachineCode = MM.MachineCode			  
			  LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
			  LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo

			  LEFT OUTER JOIN ( 
			                             SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
										  FROM STB_DefectRepairInfo 
										 WHERE RepairType = 'NONE'
										 GROUP BY ControlNo, FindRouteCode
									  ) DRI	                                              ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

			  LEFT OUTER JOIN (
										SELECT ProdNo, COUNT(*) AS MeasureCount
										  FROM STB_CommInspDocHistory CIDH
										  LEFT OUTER JOIN STB_CommInspDocItem CIDI					ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
										  INNER JOIN STB_CommInspMeasureHist CIMH					ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
										 GROUP BY ProdNo
								  ) MC                                                   ON SI.ControlNo = MC.ProdNo     -- #0406
			
			--LEFT OUTER JOIN (
			--						SELECT Barcode
			--						  FROM SmartFramework_File.dbo.STB_AttachedFileMaster
			--						 WHERE SystemName = 'XRay'
			--						 GROUP BY Barcode
			--					 ) AFM ON (SI.Barcode = AFM.Barcode OR AFM.Barcode = (SELECT NewBarcode 
			--																								   FROM STB_LotChangeMaterialHistory 
			--																								  WHERE 1=1
			--																								   --AND OldBarcode = @LotNo
			--																								   )
																											   --)              -- #0406
			LEFT OUTER JOIN STB_DayProdPlan  DPP  WITH(NOLOCK)	                   ON DPP.DayPlanNo = SI.DayPlanNo              
	 WHERE 1=1
	   --AND SI.InputJobDate BETWEEN @FromDate AND @ToDate
	   AND ((@CompanyCode = '*') OR (PRH.CompanyCode = @CompanyCode))                                 
	   --AND PRH.ProdDateTime BETWEEN GetDate()-5 AND GetDate()

	   AND (@RouteCode = '*' OR PRH.RouteCode = @RouteCode)
	   AND (@LineCode = '*' OR PRH.LineCode   = @LineCode)	  
	   AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)
	   --AND ISNULL(NP.AftProdQty,0) > CASE WHEN @RouteCode = '%' THEN -1   
		  --                                                WHEN (dbo.fnGetNextRouteCode(SI.PONo, @RouteCode) IS NULL OR dbo.fnGetNextRouteCode(SI.PONo, @RouteCode) IN ('E-28', 'V-28')) THEN -1  ELSE 0  END            -- 추가
		AND SI.InputLineCode <> '%'
      
     Group by PRH.ComPanyCode 
			,  SI.MaterialCode
			 , MM2.MaterialName
			 , SI.InputLineCode
			 , LI.LineName
			 , PRH.RouteCode
			 , RI.RouteName
			 --, PRH.ProdDateTime
			 --, PRH.MachineCode
			 --, MM.MachineName
			 --, PRH.WorkerCode
			 --, PWI.WorkerName
			 --, SI.SIExtInt01 
			 --, CONVERT(BIT,CASE WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd
			  -- , SI.Barcode
		   
	 ORDER BY  LI.LineName
	 

	  --ORDER BY CASE WHEN LI.LineName = '셀 10라인' THEN '셀 19라인'
	  ----             WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
			----	   WHEN DL.MeasureTimeCode = 'LAST' THEN 3
			--	   ELSE LI.LineName  END 

	 
End