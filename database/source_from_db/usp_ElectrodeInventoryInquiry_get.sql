-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-08
-- Browsable : true
-- Group : 생산관리 > [B799] 전극재고현황
-- Description:	
-- Modified:

-- usp_ElectrodeInventoryInquiry_get 'klee', 'Korean', 'VVT', '2020-05-01', '2020-05-15', 'Slitting'
-- usp_ElectrodeInventoryInquiry_get 'klee', 'Korean', 'VNT', '2020-01-01', '2020-05-25', ''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeInventoryInquiry_get]
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pCompanyCode VARCHAR(20) = NULL,
								@pFromDate DATE,
								@pToDate     DATE,
								@pElectrodeRouteGroup VARCHAR(20) = NULL
								--@pPrintYn     VARCHAR(1)
								
AS

BEGIN
	DECLARE @ElectrodeLotNumber  VARCHAR(20) 
		       , @FromDate                DATE = @pFromDate
	           , @ToDate                   DATE = @pToDate
			   , @ElectrodeRouteGroup  VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteGroup, '') = '' THEN '*' ELSE @pElectrodeRouteGroup END
			  -- , @PrintYn                   VARCHAR(1) = CASE WHEN ISNULL(@pPrintYn, '') = '' THEN '*' ELSE @pPrintYn END
			  -- , @PrintYn                   VARCHAR(1) = CASE WHEN @pCompanyCode = 'VVT' THEN '1'  WHEN @pCompanyCode = 'VNT' THEN '0'  ELSE '' END
			   --, @CompanyCode         VARCHAR(20) = @pCompanyCode
			    , @PrintYn                  BIT = CASE WHEN @pCompanyCode = 'VVT' THEN CONVERT(BIT, 1)   ELSE  CONVERT(BIT, 0) END

	
--               SELECT A.ElectrodeLotNumber
--			            , A.ElectrodeType
--		             	,A.MachineCode
--						,A.MachineName
--						,A.WorkDate
--						,A.WorkerCode 
--						,A.WorkerName
--						,A.Temperature
--						,A.Humidity
--						--,A.RollingDensityValue
--						--,A.RollingDensityResult
--						--,A.HeadGapInitLeft
--						--,A.HeadGapInitRight
--						--,A.ProdConTemp
--						--,A.ProdConSpeed
--						--,A.ProductionQty
--						--,A.GoodQty
--						--,A.BadQty
--						,A.VisualInspectionResult
--						,A.CreateDateTime
--						,A.CreateUserID
--						,A.ChangeDateTime
--						,A.ChangeUserID
--						,A.MaterialCode
--						,A.MaterialName
--						,A.MaterialThickness
--						, A.PrintYn
--						, A.ElectrodeRouteGroup
--		  --, (	SELECT BaseMonth
--			 --    FROM STB_AggregationPeriod
--				-- WHERE 1=1										   
--				--   AND  FromDate <= A.JobDate
--				--   AND  ToDate    >= A.JobDate
--				--						                     )  AS YearMonth

-- FROM (
--			SELECT   ISNULL(ERPI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
--					  , Case When MM2.MaterialName like '%MSP%' Then 'MSP'
--						       When MM2.MaterialName like '%YP%' Then 'YP'
--						       When MM2.MaterialName like '%CEP%' Then 'CEP'
--								When MM2.MaterialName like '%LMO%' Then 'LMO' ELSE '기타' END  ElectrodeType
--						,ERPI.MachineCode
--						,MM.MachineName
						
--						,ERPI.WorkDate
--						,ERPI.WorkerCode 
--						,PWI.WorkerName
--						,ERPI.Temperature
--						,ERPI.Humidity
--						--, ISNULL(ERPI.RollingDensityValue, 0) AS RollingDensityValue              -- SELECT ISNULL(RollingDensityValue,0), *  FROM STB_ElectrodeRollPressingInfo
--						--,ERPI.RollingDensityResult
--						--,ERPI.HeadGapInitLeft
--						--,ERPI.HeadGapInitRight
--						--,ERPI.ProdConTemp
--						--,ERPI.ProdConSpeed
--						--,ERPI.ProductionQty
--						--,ERPI.GoodQty
--						--,ERPI.BadQty
--						,ERPI.VisualInspectionResult
--						,ERPI.CreateDateTime
--						,ERPI.CreateUserID
--						,ERPI.ChangeDateTime
--						,ERPI.ChangeUserID
--						,SI.MaterialCode
--						,MM2.MaterialName
--						,MM2.MaterialThickness
--						,'Report' AS CommandType
--						,'O'        AS IsRollPress
--						, ECI.PrintYn
--						,'OneRoll'     AS ElectrodeRouteGroup
--				  FROM STB_SetInfo SI
--						  LEFT OUTER JOIN STB_MaterialMaster MM2	               ON SI.MaterialCode = MM2.MaterialCode
--						  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	   ON SI.Barcode = ERPI.ElectrodeLotNumber
--						  LEFT OUTER JOIN STB_MachineMaster MM	               ON ERPI.MachineCode = MM.MachineCode
--						  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	               ON ERPI.WorkerCode = PWI.WorkerCode
--						  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI           ON ECI.ElectrodeLotNumber = ERPI.ElectrodeLotNumber   AND ECI.ElectrodeLotNumber = SI.Barcode 

--				 WHERE  1=1
--					--AND SI.Barcode = 'VJHR1120001E03'
--					AND NOT SI.Barcode IN ( SELECT ElectrodeLotNumber  FROM STB_ElectrodeSlittingInfo )
--					--AND NOT SI.Barcode Like '%VVK%'
		
--						-- [프린터 여부에 따라 법인으로 이동했는지 체크]
--					--SELECT PrintYn, * FROM STB_ElectrodeCoatingInfo Where PrintYn is not Null
--					--SELECT PrintYn, * FROM STB_ElectrodeSlittingInfo  Where PrintYn is not Null

--					AND ERPI.CreateDateTime BetWeen @FromDate AND @ToDate 
--					--AND (@ElectrodeRouteCode = '*' OR ElectrodeRouteCode = @ElectrodeRouteCode)

--					UNION ALL

		
--			-- [슬리팅 실적 체크]
--			 SELECT  ISNULL(ESI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
--				       , Case When MM2.MaterialName like '%MSP%' Then 'MSP'
--						        When MM2.MaterialName like '%YP%' Then 'YP'
--						        When MM2.MaterialName like '%CEP%' Then 'CEP'
--								When MM2.MaterialName like '%LMO%' Then 'LMO' ELSE '기타' END  ElectrodeType						
--						,ESI.MachineCode
--						,MM.MachineName
--						,ESI.WorkDate
--						,ESI.WorkerCode 
--						,PWI.WorkerName
--						,ESI.Temperature
--						,ESI.Humidity
--						--, 0.00 AS RollingDensityValue
--						--, '0' AS RollingDensityResult
--						--, 0  AS HeadGapInitLeft
--						--, 0 AS HeadGapInitRight
--						--, 0 AS ProdConTemp
--						--, 0 AS ProdConSpeed
--						--, 0 AS ProductionQty
--						--, ESI.SlittingLength    AS GoodQty     --GoodQty
--						--, 0  AS BadQty
--						,ESI.VisualInspectionResult
--						,ESI.CreateDateTime
--						,ESI.CreateUserID
--						,ESI.ChangeDateTime
--						,ESI.ChangeUserID
--						,SI.MaterialCode
--						,MM2.MaterialName
--						,MM2.MaterialThickness
--						,'Report' AS CommandType
--						,'O' AS IsRollPress
--						, ECI.PrintYn AS PrintYn
--						,'SlittingRoll'     AS ElectrodeRouteGroup
--				  FROM STB_SetInfo SI
--						  LEFT OUTER JOIN STB_MaterialMaster MM2	               ON SI.MaterialCode = MM2.MaterialCode
--						  LEFT OUTER JOIN STB_ElectrodeSlittingInfo ESI	   ON SI.Barcode = ESI.ElectrodeLotNumber
--						  LEFT OUTER JOIN STB_MachineMaster MM	               ON ESI.MachineCode = MM.MachineCode
--						  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	               ON ESI.WorkerCode = PWI.WorkerCode
--						  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI           ON ECI.ElectrodeLotNumber = ESI.ElectrodeLotNumber   AND ECI.ElectrodeLotNumber = SI.Barcode 

--				 WHERE 1=1					
--					AND ESI.CreateDateTime BetWeen  @FromDate AND @ToDate 
--					--AND ESI.PrintYn <> '1'                                                                                             -- 프린트 출력이 안된제품 (출력하면 법인으로 이동) 

--			) A
--	LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		  ON BC.ItemCode = A.ElectrodeRouteGroup		 AND BC.CodeGroup = 'ElectrodeRouteGroup'
-- WHERE 1=1
--     AND A.CreateDateTime BETWEEN @FromDate AND @ToDate
--	 AND (@ElectrodeRouteGroup = '*' OR A.ElectrodeRouteGroup = @ElectrodeRouteGroup)	 	 
--	 AND ISNULL(A.PrintYn, CONVERT(BIT, 0)) = @PrintYn
--ORDER BY A.CreateDateTime, A.ElectrodeLotNumber, A.ElectrodeRouteGroup

  
END


--SELECT * FROM SmartFramework.dbo.STB_BaseCode WHERE CodeGroup =  'ElectrodeRouteGroup'
-- SELECT * FROM STB_ElectrodeSlittingInfo WHERE ElectrodeLotNumber = 'VJKN0620001E07'