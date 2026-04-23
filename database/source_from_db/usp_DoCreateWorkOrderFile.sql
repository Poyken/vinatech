CREATE PROC [dbo].[usp_DoCreateWorkOrderFile]
    @pCompanyCode VARCHAR(20)
   ,@pFromDate CHAR(10)
   ,@pToDate CHAR(10)
AS
BEGIN
	Declare @FromDate CHAR(19) = @pFromDate + ' 08:30:00'
		   ,@ToDate CHAR(19) = CONVERT(CHAR(19), DATEADD(day, 1, @pToDate) + ' 08:29:59', 121)
		   ,@CompanyCode VARCHAR(20) = @pCompanyCode
		   ,@CD_COMPANY VARCHAR(20) = CASE WHEN @pCompanyCode = 'VNT' THEN '1000' ELSE '2000' END

	Declare @QueryTable TABLE (
		CD_OP VARCHAR(20)
	   ,CD_WC VARCHAR(20)
	   ,CD_WCOP VARCHAR(20)
	   ,YN_BF CHAR(1)
	   ,FG_GR CHAR(1)
	   ,DC_RMK NVARCHAR(100)
	   ,TP_WO VARCHAR(20)
	   ,CD_ITEM VARCHAR(20)
	   ,QT_ITEM NUMERIC(20,5)
	   ,DT_REL CHAR(8)
	   ,DT_DUE CHAR(8)
	   ,PATN_ROUT CHAR(1)
	   ,CD_SL VARCHAR(20)
	);

	-- 제품 작업지시
	INSERT INTO @QueryTable
	SELECT '100' AS CD_OP
		  ,'1300' AS CD_WC
		  ,CASE WHEN @CompanyCode = 'VNT' THEN 'E-28' ELSE 'V-28' END AS CD_WCOP
		  ,'Y' AS YN_BF
		  ,'Y' AS FG_GR
		  ,'기존 MES실적 일괄처리' AS DC_RMK
		  ,'200' AS TP_WO
		  ,dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 1) AS CD_ITEM
		  ,ProdQty AS QT_ITEM
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_REL
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_DUE
		  ,'S' AS PATN_ROUT
		  ,'W03' AS CD_SL
	  FROM STB_ProdRouteHist
	 WHERE ProdDateTime BETWEEN @FromDate AND @ToDate
	   AND RouteCode IN ('E-28', 'V-28')
	   AND CompanyCode = @CompanyCode
	UNION ALL
	-- 슬리브 작업지시
	SELECT '100' AS CD_OP
		  ,'1200' AS CD_WC
		  ,CASE WHEN @CompanyCode = 'VNT' THEN 'E-25' ELSE 'V-25' END AS CD_WCOP
		  ,'Y' AS YN_BF
		  ,'Y' AS FG_GR
		  ,'기존 MES실적 일괄처리' AS DC_RMK
		  ,'200' AS TP_WO
		  ,dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 2) AS CD_ITEM
		  ,ProdQty AS QT_ITEM
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_REL
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_DUE
		  ,'S' AS PATN_ROUT
		  ,'W03' AS CD_SL
	  FROM STB_ProdRouteHist PRH
	 WHERE ProdDateTime BETWEEN @FromDate AND @ToDate
	   AND RouteCode IN ('E-28', 'V-28')
	   AND CompanyCode = @CompanyCode
	UNION ALL
	-- 권취소자 작업지시
	SELECT '100' AS CD_OP
		  ,'1100' AS CD_WC
		  ,CASE WHEN @CompanyCode = 'VNT' THEN 'E-22' ELSE 'V-22' END AS CD_WCOP
		  ,'Y' AS YN_BF
		  ,'Y' AS FG_GR
		  ,'기존 MES실적 일괄처리' AS DC_RMK
		  ,'200' AS TP_WO
		  ,dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 3) AS CD_ITEM
		  ,ProdQty AS QT_ITEM
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_REL
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_DUE
		  ,'S' AS PATN_ROUT
		  ,'W03' AS CD_SL
	  FROM STB_ProdRouteHist PRH
	 WHERE ProdDateTime BETWEEN @FromDate AND @ToDate
	   AND RouteCode IN ('E-28', 'V-28')
	   AND CompanyCode = @CompanyCode
	UNION ALL
	-- 슬리팅롤 작업지시 1
	SELECT '100' AS CD_OP
		  ,'1000' AS CD_WC
		  ,CASE WHEN @CompanyCode = 'VNT' THEN 'E-11' ELSE 'V-11' END AS CD_WCOP
		  ,'Y' AS YN_BF
		  ,'Y' AS FG_GR
		  ,'기존 MES실적 일괄처리' AS DC_RMK
		  ,'200' AS TP_WO
		  ,dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 4) AS CD_ITEM
		  ,ProdQty * (SELECT MAX(QT_ITEM)
						FROM NEOE.NEOE.PR_BOM 
					   WHERE CD_ITEM = dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 3)
						 AND CD_MATL = dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 4)) AS QT_ITEM
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_REL
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_DUE
		  ,'S' AS PATN_ROUT
		  ,'W11' AS CD_SL
	  FROM STB_ProdRouteHist PRH
	 WHERE ProdDateTime BETWEEN @FromDate AND @ToDate
	   AND RouteCode IN ('E-28', 'V-28')
	   AND CompanyCode = @CompanyCode
	UNION ALL
	-- 슬리팅롤 작업지시 2
	SELECT '100' AS CD_OP
		  ,'1000' AS CD_WC
		  ,CASE WHEN @CompanyCode = 'VNT' THEN 'E-11' ELSE 'V-11' END AS CD_WCOP
		  ,'Y' AS YN_BF
		  ,'Y' AS FG_GR
		  ,'기존 MES실적 일괄처리' AS DC_RMK
		  ,'200' AS TP_WO
		  ,dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 5) AS CD_ITEM
		  ,ProdQty * (SELECT MAX(QT_ITEM)
						FROM NEOE.NEOE.PR_BOM 
					   WHERE CD_ITEM = dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 3)
						 AND CD_MATL = dbo.fnGetChildMaterialCode(@CD_COMPANY, MaterialCode, 5)) AS QT_ITEM
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_REL
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmdd', CASE WHEN CONVERT(CHAR(8), ProdDateTime, 108) < '08:30:00' THEN DATEADD(day, -1, ProdDateTime) ELSE ProdDateTime END) AS DT_DUE
		  ,'S' AS PATN_ROUT
		  ,'W11' AS CD_SL
	  FROM STB_ProdRouteHist PRH
	 WHERE ProdDateTime BETWEEN @FromDate AND @ToDate
	   AND RouteCode IN ('E-28', 'V-28')
	   AND CompanyCode = @CompanyCode

	SELECT  CD_OP
		   ,CD_WC
		   ,CD_WCOP
		   ,YN_BF
		   ,FG_GR
		   ,DC_RMK
		   ,TP_WO
		   ,CD_ITEM
		   ,SUM(QT_ITEM)
		   ,MAX(DT_REL)
		   ,MAX(DT_DUE)
		   ,MAX(PATN_ROUT)
		   ,MAX(CD_SL)
	  FROM @QueryTable
	 WHERE CD_ITEM IS NOT NULL
	 GROUP BY   CD_OP
			   ,CD_WC
			   ,CD_WCOP
			   ,YN_BF
			   ,FG_GR
			   ,DC_RMK
			   ,TP_WO
			   ,CD_ITEM
END