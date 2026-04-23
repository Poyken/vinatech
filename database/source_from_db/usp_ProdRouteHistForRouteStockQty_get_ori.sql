-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-06-26
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- exec [usp_ProdRouteHistForRouteStockQty_get] '','','VNT','','ASSYLINE-09'
-- =============================================
CREATE PROC [dbo].[usp_ProdRouteHistForRouteStockQty_get_ori]
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
	  LEFT OUTER JOIN STB_BasicRoutingDetail BRD
		ON BRI.BasicRoutingCode = BRD.BasicRoutingCode
	   AND BRD.CompanyCode = @CompanyCode
	  LEFT OUTER JOIN STB_RouteInfo RI
		ON RI.RouteCode = BRD.RouteCode
	 WHERE BRI.BasicRoutingCode = 'WipRouting'
	) 
	INSERT INTO @RouteBasicTable
		SELECT WRI.RouteCode, PRH.ControlNo, WRI.RouteIndex
		  FROM WipRoutingInfo WRI
		  LEFT OUTER JOIN STB_ProdRouteHist PRH
			ON 1=1
		  LEFT OUTER JOIN STB_SetInfo SI
			ON PRH.ControlNo = SI.ControlNo
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
					   WHEN LPRH.RouteCode = 'E-26' AND SI.LotNumber IS NOT NULL THEN Null
					ELSE PRH.ProdQty END AS ProdQty
			  ,LPRH.ProdDateTime
			  ,NULL AS DecisionResult
		  FROM @RouteBasicTable RBT
		  LEFT OUTER JOIN STB_ProdRouteHist PRH
			ON RBT.ControlNo = PRH.ControlNo
		   AND RBT.RouteCode = PRH.RouteCode
		   AND PRH.RouteCode <> (SELECT RouteCode 
								   FROM STB_BasicRoutingDetail 
								  WHERE CompanyCode = @CompanyCode AND BasicRoutingCode = 'WipRouting'
									AND IsOutputRoute = CONVERT(BIT, 1))
		  LEFT OUTER JOIN (SELECT ControlNo
								 ,MAX(RouteCode) AS RouteCode
								 ,MAX(ProdDateTime) AS ProdDateTime
							 FROM STB_ProdRouteHist
							GROUP BY ControlNo
						  ) LPRH
			ON PRH.ControlNo = LPRH.ControlNo
		   AND PRH.RouteCode = LPRH.RouteCode
		   LEFT OUTER JOIN STB_SetInfo SI
			ON SI.ControlNo = PRH.ControlNo
		   LEFT OUTER JOIN STB_LineInfo LI
		     ON SI.InputLineCode = LI.LineCode
		   LEFT OUTER JOIN STB_MaterialMaster MM
		     ON MM.MaterialCode = SI.MaterialCode
		 WHERE RBT.ControlNo IN (SELECT ControlNo 
								   FROM STB_SetInfo 
								  WHERE IsProdFinish = CONVERT(BIT, 0))
		   AND RBT.ControlNo IN (SELECT ControlNo 
								   FROM STB_SetInfo 
								  WHERE InputLineCode IN (SELECT LineCode 
															FROM STB_LineInfo 
														   WHERE CompanyCode = @CompanyCode))
		UNION ALL -- 제품검사 수량
		SELECT SI.Barcode
		      ,SI.InputLineCode
			  ,LI.LineName
			  ,SI.MaterialCode
			  ,MM.MaterialName
			  ,CASE WHEN MQI.DecisionResult IN ('None', 'Reject') THEN 'E-99' ELSE 'E-28' END
			  ,ISNULL(PRH.ProdQty , 0)
			  ,MQI.DecisionDateTime
			  ,MQI.DecisionResult
		  FROM STB_SetInfo SI
		  LEFT OUTER JOIN STB_MaterialQcInfo MQI
			ON SI.LotNumber = MQI.MaterialQcNo
		   AND MQI.InspectionDocType = 'OQC'
		  LEFT OUTER JOIN STB_ProdRouteHist PRH
			ON SI.ControlNo = PRH.ControlNo
		   AND PRH.RouteCode = 'E-27'
		  LEFT OUTER JOIN STB_LineInfo LI
		     ON SI.InputLineCode = LI.LineCode
		   LEFT OUTER JOIN STB_MaterialMaster MM
		     ON MM.MaterialCode = SI.MaterialCode
		 WHERE SI.InputLineCode IN (SELECT LineCode FROM STB_LineInfo WHERE CompanyCode = @CompanyCode)
		   AND SI.LotNumber IS NOT NULL
		   AND SI.IsProdFinish = CONVERT(BIT, 0)
	) A

	SELECT WD.MaterialCode
	      ,WD.MaterialName
		  ,WD.InputLineCode
		  ,WD.LineName
		  ,WD.Barcode
		  ,WD.RouteCode
		  ,WD.ProdQty
	  INTO #LastWipData
	  FROM #WipData WD
	 WHERE (@MaterialCode = '*' OR WD.MaterialCode = @MaterialCode)
	   AND (@LineCode = '*' OR WD.InputLineCode = @LineCode)
	   AND WD.MaterialCode IS NOT NULL
	   AND WD.InputLineCode IS NOT NULL

	SELECT @RouteString = @RouteString + '[' + BRD.RouteCode + '],'
	  FROM STB_BasicRoutingInfo BRI
	  LEFT OUTER JOIN STB_BasicRoutingDetail BRD
		ON BRI.BasicRoutingCode = BRD.BasicRoutingCode
	   AND BRD.CompanyCode = @CompanyCode
	  LEFT OUTER JOIN STB_RouteInfo RI
		ON RI.RouteCode = BRD.RouteCode
	 WHERE BRI.BasicRoutingCode = 'WipRouting'
	 ORDER BY BRD.RouteIndex

	SET @RouteString = LEFT(@RouteString, LEN(@RouteString) - 1)

	SET @QueryString = 'SELECT * FROM #LastWipData PIVOT (SUM(ProdQty) FOR RouteCode IN (' + @RouteString +')) AS PVT'

	execute (@QueryString)

	DROP TABLE #WipData
	DROP TABLE #LastWipData
END
