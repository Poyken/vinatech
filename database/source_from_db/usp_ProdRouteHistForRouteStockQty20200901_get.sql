-- ===================================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-06-26
-- Browsable : true
-- Group : 생산관리 > 생산현황 > [B920] 공정재공정보(신규)
-- Description :	
-- Modify : STB_SetInfo의 IsProdFinish = false 인데, 포장실적이 존재하는 경우가 있어 쿼리를 수정함. 2020.06.27 By Jackaroe #200627

-- Exec [usp_ProdRouteHistForRouteStockQty20200901_get] '','','VNT','','ASSYLINE-09'
-- ===================================================================================================

CREATE PROC [dbo].[usp_ProdRouteHistForRouteStockQty20200901_get]
				@pProcessUserID VARCHAR(20) 
			   ,@pProcessLanguage VARCHAR(20)
			   ,@pCompanyCode VARCHAR(20) = NULL
			   ,@pMaterialCode VARCHAR(20) = NULL
			   ,@pLineCode VARCHAR(20) = NULL
AS
BEGIN

	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	Declare @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	Declare @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END

	Declare @RouteBasicTable TABLE (
		RouteCode VARCHAR(20)
	   ,ControlNo VARCHAR(20)
	   ,RouteIndex INT
	);

	Declare @QueryString VARCHAR(MAX)
	Declare @RouteString VARCHAR(MAX) = ''

	;WITH WipRoutingInfo AS (
	SELECT BRD.RouteIndex
		  ,BRD.RouteCode
		  ,RI.RouteName
	  FROM STB_BasicRoutingInfo BRI
	  LEFT OUTER JOIN STB_BasicRoutingDetail BRD		ON BRI.BasicRoutingCode = BRD.BasicRoutingCode	   AND BRD.CompanyCode = @CompanyCode
	  LEFT OUTER JOIN STB_RouteInfo RI		ON RI.RouteCode = BRD.RouteCode
	 WHERE BRI.BasicRoutingCode = 'WipRouting'
	) 
	INSERT INTO @RouteBasicTable
		SELECT WRI.RouteCode, PRH.ControlNo, WRI.RouteIndex
		  FROM WipRoutingInfo WRI
		  LEFT OUTER JOIN STB_ProdRouteHist PRH	ON 1=1
		  LEFT OUTER JOIN STB_SetInfo SI 			    ON PRH.ControlNo = SI.ControlNo
		 GROUP BY WRI.RouteCode, PRH.ControlNo, WRI.RouteIndex
		 

	SELECT *
	  INTO #WipData
	  FROM (
		SELECT SI.Barcode
		      ,SI.InputLineCode
			  ,LI.LineName
			  ,SI.MaterialCode
			  ,MM.MaterialName
			  ,PRH.RouteCode
			  ,CASE WHEN LPRH.RouteCode IS NULL THEN 0
					   WHEN LPRH.RouteCode = 'E-27' AND SI.LotNumber IS NULL THEN PRH.ProdQty
					   WHEN LPRH.RouteCode = 'E-27' AND SI.LotNumber IS NOT NULL THEN 0					   
					ELSE PRH.ProdQty END AS ProdQty
			  ,LPRH.ProdDateTime
			  ,NULL AS DecisionResult
			  , SI.IsProdFinish        --추가
			  , SI.IsLoss               --추가
			   , SI.Remark
		  FROM @RouteBasicTable RBT
		  LEFT OUTER JOIN STB_ProdRouteHist PRH			ON RBT.ControlNo = PRH.ControlNo		   AND RBT.RouteCode = PRH.RouteCode		   AND PRH.RouteCode <> (SELECT RouteCode 
																																																								   FROM STB_BasicRoutingDetail 
																																																								  WHERE CompanyCode = @CompanyCode AND BasicRoutingCode = 'WipRouting'
																																																									AND IsOutputRoute = CONVERT(BIT, 1)
																																																									)
		  LEFT OUTER JOIN (SELECT ControlNo
											 ,MAX(RouteCode) AS RouteCode
											 ,MAX(ProdDateTime) AS ProdDateTime
									 FROM STB_ProdRouteHist							  
									GROUP BY ControlNo
								  ) LPRH			ON PRH.ControlNo = LPRH.ControlNo		   AND PRH.RouteCode = LPRH.RouteCode
		   LEFT OUTER JOIN STB_SetInfo SI			ON SI.ControlNo = PRH.ControlNo
		   LEFT OUTER JOIN STB_LineInfo LI		     ON SI.InputLineCode = LI.LineCode
		   LEFT OUTER JOIN STB_MaterialMaster MM		     ON MM.MaterialCode = SI.MaterialCode
		 WHERE RBT.ControlNo IN (SELECT ControlNo 
											   FROM STB_SetInfo 
											  WHERE IsProdFinish = CONVERT(BIT, 0))
		   AND RBT.ControlNo IN (SELECT ControlNo 
											   FROM STB_SetInfo 
											  WHERE InputLineCode IN (SELECT LineCode 
																		FROM STB_LineInfo 
																	   WHERE CompanyCode = @CompanyCode))

		UNION ALL

		 -- 제품검사 수량
		SELECT SI.Barcode
		      ,SI.InputLineCode
			  ,LI.LineName
			  ,SI.MaterialCode
			  ,MM.MaterialName
			  ,CASE WHEN MQI.DecisionResult IN ('None', 'Reject') THEN 'E-99' ELSE 'E-28' END
			  ,PRH.ProdQty
			  ,MQI.DecisionDateTime
			  ,MQI.DecisionResult
			 , SI.IsProdFinish        --추가
			  , SI.IsLoss               --추가
			   , SI.Remark
		  FROM STB_SetInfo SI
		  LEFT OUTER JOIN STB_MaterialQcInfo MQI			ON SI.LotNumber = MQI.MaterialQcNo		   AND MQI.InspectionDocType = 'OQC'
		  LEFT OUTER JOIN STB_ProdRouteHist PRH			ON SI.ControlNo = PRH.ControlNo		   AND PRH.RouteCode = 'E-27'
		  LEFT OUTER JOIN STB_LineInfo LI		     ON SI.InputLineCode = LI.LineCode
		   LEFT OUTER JOIN STB_MaterialMaster MM		     ON MM.MaterialCode = SI.MaterialCode
		 WHERE SI.InputLineCode IN (SELECT LineCode FROM STB_LineInfo WHERE CompanyCode = @CompanyCode)
		   AND SI.LotNumber IS NOT NULL
		   AND SI.IsProdFinish = CONVERT(BIT, 0)
	) A


	-- 최종
	SELECT WD.MaterialCode
			  ,WD.MaterialName
			  ,WD.InputLineCode
			  ,WD.LineName
			  ,WD.Barcode
			  ,RI.RouteType
			  ,WD.ProdQty
			  ,WD.IsProdFinish    --추가			 
			  ,WD.IsLoss               --추가
			  ,WD.Remark
	  INTO #LastWipData
	  FROM #WipData WD
	  LEFT OUTER JOIN STB_RouteInfo RI	    ON WD.RouteCode = RI.RouteCode
	 WHERE (@MaterialCode = '*' OR WD.MaterialCode = @MaterialCode)
	   AND (@LineCode = '*' OR WD.InputLineCode = @LineCode)
	   AND WD.MaterialCode IS NOT NULL
	   AND WD.InputLineCode IS NOT NULL
	   -- #200627 Start
	   AND WD.Barcode NOT IN (SELECT Barcode 
											FROM STB_SetInfo 
										   WHERE ControlNo IN (SELECT ControlNo 
																 FROM STB_ProdRouteHist 
																WHERE RouteCode IN (SELECT RouteCode 
																					  FROM STB_BasicRoutingDetail 
																					 WHERE CompanyCode = @CompanyCode 
																					   AND BasicRoutingCode = 'WipRouting'
																					   AND IsOutputRoute = CONVERT(BIT, 1)
																	)
												  )
							 )
		-- #200627 End

	 SELECT @RouteString = @RouteString + '[' + RI.RouteType + '],'
	  FROM                         STB_BasicRoutingInfo BRI
			   LEFT OUTER JOIN STB_BasicRoutingDetail BRD		ON BRI.BasicRoutingCode = BRD.BasicRoutingCode	   AND BRD.CompanyCode = @CompanyCode
			   LEFT OUTER JOIN STB_RouteInfo RI						ON RI.RouteCode = BRD.RouteCode
	 WHERE BRI.BasicRoutingCode = 'WipRouting'
	 ORDER BY BRD.RouteIndex


	SET @RouteString = LEFT(@RouteString, LEN(@RouteString) - 1)

	SET @QueryString = 'SELECT * FROM #LastWipData PIVOT (SUM(ProdQty) FOR RouteType IN (' + @RouteString +')) AS PVT'


	Execute (@QueryString)

	DROP TABLE #WipData
	DROP TABLE #LastWipData

END


--ALTER TABLE STB_SetInfo ADD Remark NVarchar(Max)


--select * from STB_SetInfo