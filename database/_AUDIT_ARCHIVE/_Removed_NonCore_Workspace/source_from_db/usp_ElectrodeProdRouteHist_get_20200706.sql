-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-02-24
-- Browsable : true
-- Group : 생산관리 > [B800] 전극생산현황 
-- Description:	
-- Modified:
--				2020.02.27 품목코드, 명 추가 (안제헌대리 요청사항)
--				2020.03.02 Mixing 추가(안제헌대리 요청사항)
--             2020.07.06 수율추가 (안제헌요청)

-- Exec [usp_ElectrodeProdRouteHist_get_20200706] 'klee', 'Korean', '2020-06-30 08:30:00', '2020-07-07 08:30:00', ''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeProdRouteHist_get_20200706]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATE,
						@pToDate DATE,
						--@pElectrodeRouteCode VARCHAR(20) = NULL
						@pElectrodeRouteGroup VARCHAR(20) = NULL
AS

BEGIN
	Declare @FromDate              DATE = @pFromDate
	        , @ToDate                 DATE = @pToDate
		 --   , @ElectrodeRouteCode VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteCode, '') = '' THEN '*' ELSE @pElectrodeRouteCode END
		    , @ElectrodeRouteGroup VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteGroup, '') = '' THEN '*' ELSE @pElectrodeRouteGroup END


	SELECT A.PlanDate
		  , A.ElectrodeLotNumber
		  , A.PlanShiftCode
		  , CASE WHEN A.PlanShiftCode = '1' THEN '주간' ELSE '야간' END PlanShiftName
		  , A.WorkerCode
		  , A.WorkerName
		  , A.ElectrodeRouteCode
		  , BC.Description AS ElectrodeRouteName
		  , A.ProductionQty
		  , A.GoodQty
		  , A.BadQty
		  , ROUND(A.Yield, 1) AS Yield
		  , A.MaterialLotNumber
		  , A.Remark
		  , A.SpecificComment1
		  , A.SpecificComment2
		  , A.MaterialCode                -- kilee추가 (2020.02.27)
		  , A.MaterialName               -- kilee추가 (2020.02.27)
		  , A.JobDate                -- kilee추가 (2020.03.30)

		  , (	SELECT BaseMonth
			     FROM STB_AggregationPeriod
				 WHERE 1=1										   
				   AND  FromDate <= A.JobDate
				   AND  ToDate    >= A.JobDate
										                     )  AS YearMonth
	  FROM (
	          -- 1. 
				SELECT DPP.PlanDate
						  ,DPP.PlanShiftCode
						  ,ECI.ElectrodeLotNumber
						  ,ECI.WorkerCode
						  ,PWI.WorkerName
						  ,'Coating' AS ElectrodeRouteCode
						  ,ECI.ProductionQty
						  ,ECI.GoodQty
						  ,ECI.BadQty						 
						  , CASE WHEN ECI.ProductionQty = 0 THEN 0 WHEN  ECI.GoodQty = 0 THEN 0  ELSE  (ECI.GoodQty / ECI.ProductionQty) * 100 END AS Yield     --수율추가 (2020.07.05)
						  ,ECI.MaterialLotNumber
						  ,ECI.Remark
						  ,ECI.SpecificComment1
						  ,ECI.SpecificComment2

						  , DPP.MaterialCode                                                                                                    AS MaterialCode             -- kilee추가 (2020.02.27)
						  , (Select MaterialName From STB_MaterialMaster MM WHERE MM.MaterialCode = DPP.MaterialCode) AS MaterialName    -- kilee추가 (2020.02.27)
						  , ECI.WorkDate                                                                                                      AS JobDate                       -- kilee추가 (2020.03.30)

						  
				  FROM STB_DayProdPlan DPP
						  INNER JOIN STB_SetInfo SI   				                ON DPP.DayPlanNo = SI.DayPlanNo
						  INNER JOIN STB_ElectrodeCoatingInfo ECI				ON SI.Barcode = ECI.ElectrodeLotNumber
						  LEFT OUTER JOIN STB_ProdWorkerInfo PWI				ON PWI.WorkerCode = ECI.WorkerCode
				 WHERE DPP.LineCode = 'ELECTRODE LINE'

			 UNION ALL

		 --2. 
			SELECT DPP.PlanDate
					  ,DPP.PlanShiftCode
					  ,ERPI.ElectrodeLotNumber
					  ,ERPI.WorkerCode
					  ,PWI.WorkerName
					  ,'RollPress' AS ElectrodeRouteCode
					  ,ERPI.ProductionQty
					  ,ERPI.GoodQty
					  ,ERPI.BadQty					   
					  ,CASE WHEN ERPI.ProductionQty = 0 THEN 0 WHEN ERPI.GoodQty = 0 THEN 0 ELSE	(ERPI.GoodQty / ERPI.ProductionQty) * 100 END AS Yield
					  ,NULL AS MaterialLotNumber
					  ,NULL AS Remark
					  ,NULL AS SpecificComment1
					  ,NULL AS SpecificComment2

					  , DPP.MaterialCode                                                                                                   AS MaterialCode             -- kilee추가 (2020.02.27)         
					 , (Select MaterialName From STB_MaterialMaster MM WHERE MM.MaterialCode = DPP.MaterialCode) AS MaterialName       -- kilee추가 (2020.02.27)			  
					 , ERPI.WorkDate                                                                                                      AS JobDate              -- kilee추가 (2020.03.30)

			  FROM STB_DayProdPlan DPP
					  INNER JOIN STB_SetInfo SI				                   ON DPP.DayPlanNo = SI.DayPlanNo
					  INNER JOIN STB_ElectrodeRollPressingInfo ERPI		   ON SI.Barcode = ERPI.ElectrodeLotNumber
					  LEFT OUTER JOIN STB_ProdWorkerInfo PWI			   ON PWI.WorkerCode = ERPI.WorkerCode
			 WHERE DPP.LineCode = 'ELECTRODE LINE'

			-- UNION ALL

	  --  --  3. Mixing 추가 (2020.03.02 kilee추가)
			--SELECT DPP.PlanDate
			--		  ,DPP.PlanShiftCode
			--		  ,EMI.ElectrodeLotNumber
			--		  ,EMI.WorkerCode
			--		  ,PWI.WorkerName
			--		  ,'Mixing' AS ElectrodeRouteCode
			--		  ,EMI.ProductionQty
			--		  ,EMI.ProductionQty
			--		  , 0 
			--		  , 0  AS Yield
			--		  ,NULL AS MaterialLotNumber
			--		  ,NULL AS Remark
			--		  ,NULL AS SpecificComment1
			--		  ,NULL AS SpecificComment2

			--		  , DPP.MaterialCode                                                                                                   AS MaterialCode             -- kilee추가 (2020.02.27)         
			--		 , (Select MaterialName From STB_MaterialMaster MM WHERE MM.MaterialCode = DPP.MaterialCode) AS MaterialName       -- kilee추가 (2020.02.27)			  
			--		 , EMI.WorkDate                                                                                                        AS JobDate              -- kilee추가 (2020.03.30)
			--  FROM STB_DayProdPlan DPP
			--		  INNER JOIN STB_SetInfo SI				                   ON DPP.DayPlanNo = SI.DayPlanNo
			--		  INNER JOIN STB_ElectrodeMixInfo EMI		   ON SI.Barcode = EMI.ElectrodeLotNumber
			--		  LEFT OUTER JOIN STB_ProdWorkerInfo PWI			   ON PWI.WorkerCode = EMI.WorkerCode
			-- WHERE DPP.LineCode = 'ELECTRODE LINE'

		) A
		LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		  ON BC.ItemCode = A.ElectrodeRouteCode		 AND BC.CodeGroup = '@ElectrodeRouteGroup'

	 WHERE 1=1
	    AND A.PlanDate BETWEEN @FromDate AND @ToDate		
	    AND (@ElectrodeRouteGroup = '*' OR A.ElectrodeRouteCode = @ElectrodeRouteGroup)				
  -- 합계추가
	 UNION ALL

	 SELECT NULL
		  ,'<합계>'
		  ,NULL
		  , NULL
		  , NULL
		  , NULL
		  , NULL
		  , NULL
		  , sum(A.ProductionQty)
		  , sum(A.GoodQty)
		  , sum(A.BadQty)
		  , Avg(ROUND(A.Yield, 1)) AS Yield
		  , NULL
		  , NULL
		  , NULL
		  , NULL
		  , NULL
		  , NULL
		  , NULL

		  , NULL
	  FROM (
	          -- 1. 
				SELECT DPP.PlanDate
						  ,DPP.PlanShiftCode
						  ,ECI.ElectrodeLotNumber
						  ,ECI.WorkerCode
						  ,PWI.WorkerName
						  ,'Coating' AS ElectrodeRouteCode
						  ,ECI.ProductionQty
						  ,ECI.GoodQty
						  ,ECI.BadQty						 
						  , CASE WHEN ECI.ProductionQty = 0 THEN 0 WHEN  ECI.GoodQty = 0 THEN 0  ELSE  (ECI.GoodQty / ECI.ProductionQty) * 100 END AS Yield     --수율추가 (2020.07.05)
						  ,ECI.MaterialLotNumber
						  ,ECI.Remark
						  ,ECI.SpecificComment1
						  ,ECI.SpecificComment2

						  , DPP.MaterialCode                                                                                                    AS MaterialCode             -- kilee추가 (2020.02.27)
						  , (Select MaterialName From STB_MaterialMaster MM WHERE MM.MaterialCode = DPP.MaterialCode) AS MaterialName    -- kilee추가 (2020.02.27)
						  , ECI.WorkDate                                                                                                      AS JobDate                       -- kilee추가 (2020.03.30)

						  
				  FROM STB_DayProdPlan DPP
						  INNER JOIN STB_SetInfo SI   				                ON DPP.DayPlanNo = SI.DayPlanNo
						  INNER JOIN STB_ElectrodeCoatingInfo ECI				ON SI.Barcode = ECI.ElectrodeLotNumber
						  LEFT OUTER JOIN STB_ProdWorkerInfo PWI				ON PWI.WorkerCode = ECI.WorkerCode
				 WHERE DPP.LineCode = 'ELECTRODE LINE'

			 UNION ALL

		 --2. 
			SELECT DPP.PlanDate
					  ,DPP.PlanShiftCode
					  ,ERPI.ElectrodeLotNumber
					  ,ERPI.WorkerCode
					  ,PWI.WorkerName
					  ,'RollPress' AS ElectrodeRouteCode
					  ,ERPI.ProductionQty
					  ,ERPI.GoodQty
					  ,ERPI.BadQty					   
					  ,CASE WHEN ERPI.ProductionQty = 0 THEN 0 WHEN ERPI.GoodQty = 0 THEN 0 ELSE	(ERPI.GoodQty / ERPI.ProductionQty) * 100 END AS Yield
					  ,NULL AS MaterialLotNumber
					  ,NULL AS Remark
					  ,NULL AS SpecificComment1
					  ,NULL AS SpecificComment2

					  , DPP.MaterialCode                                                                                                   AS MaterialCode             -- kilee추가 (2020.02.27)         
					 , (Select MaterialName From STB_MaterialMaster MM WHERE MM.MaterialCode = DPP.MaterialCode) AS MaterialName       -- kilee추가 (2020.02.27)			  
					 , ERPI.WorkDate                                                                                                      AS JobDate              -- kilee추가 (2020.03.30)

			  FROM STB_DayProdPlan DPP
					  INNER JOIN STB_SetInfo SI				                   ON DPP.DayPlanNo = SI.DayPlanNo
					  INNER JOIN STB_ElectrodeRollPressingInfo ERPI		   ON SI.Barcode = ERPI.ElectrodeLotNumber
					  LEFT OUTER JOIN STB_ProdWorkerInfo PWI			   ON PWI.WorkerCode = ERPI.WorkerCode
			 WHERE DPP.LineCode = 'ELECTRODE LINE'

		) A
		LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		  ON BC.ItemCode = A.ElectrodeRouteCode		 AND BC.CodeGroup = '@ElectrodeRouteGroup'

	 WHERE 1=1
	    AND A.PlanDate BETWEEN @FromDate AND @ToDate		
	    AND (@ElectrodeRouteGroup = '*' OR A.ElectrodeRouteCode = @ElectrodeRouteGroup)	

	    

END
