-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-09-17
-- Description :  생산관리 > 생산현황 > LOT생산이력정보
-- Modified :
-- =============================================
-- EXEC [usp_LotTrackingInfo_get_Test] '','','2019-09-15','2019-09-15','E-28',''

CREATE PROCEDURE [dbo].[usp_LotTrackingInfo_get_Test]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL
AS
	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = '' THEN '%' ELSE @pRouteCode END
	DECLARE	@LineCode   VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '%' ELSE @pLineCode END

BEGIN
	;WITH NextProd AS

	(
		SELECT
				SI.ControlNo,
				SUM(PRH.ProdQty) AS AftProdQty
		FROM
									   STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN        STB_ProductionOrderRouting POR WITH(NOLOCK)			 ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	     ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN        STB_ProdRouteHist PRH WITH(NOLOCK)					     ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode
			--   INNER JOIN        STB_BasicRoutingDetail         BRD WITH(NOLOCK)	         ON BRD.RouteCode = PRH.RouteCode 
        WHERE 1=1
		--   AND BRD.IsOutputRoute = '1'    -- 포장공정 조회안되는 이유
		GROUP BY
				SI.ControlNo
	)
	SELECT SI.ControlNo
	      ,SI.Barcode
		  ,SI.MaterialCode
		  ,MM2.MaterialName
		  ,SI.InputLineCode
		  ,LI.LineName
		  ,PRH.RouteCode
		  ,RI.RouteName
		  ,PRH.ProdDateTime
		  ,PRH.MachineCode
		  ,MM.MachineName
		  ,PRH.WorkerCode
		  ,PWI.WorkerName
		  ,CASE WHEN SI.SIExtInt01 IS NULL THEN ''
		          WHEN SI.SIExtInt01 = 1      THEN '검사불합격'
				  WHEN SI.SIExtInt01 = 0      THEN '검사불합격이력'    END                     AS RouteInspectionResult
		 , CONVERT(BIT,CASE WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd
		 , PRH.ProdQty 
	  FROM STB_SetInfo SI
			  LEFT OUTER JOIN STB_ProdRouteHist    PRH	    ON SI.ControlNo = PRH.ControlNo
			  LEFT OUTER JOIN STB_RouteInfo           RI	    ON PRH.RouteCode = RI.RouteCode
			  LEFT OUTER JOIN STB_MachineMaster  MM	    ON PRH.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON PRH.WorkerCode = PWI.WorkerCode
			  LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
			  LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo
	 WHERE 1=1
	   --AND SI.InputJobDate BETWEEN @FromDate AND @ToDate                                            -- 원본백업
	   AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate                                           -- 2019.09.17 수정
	   AND PRH.RouteCode LIKE @RouteCode
	   AND PRH.LineCode LIKE @LineCode
	   AND ISNULL(NP.AftProdQty,0) > CASE WHEN @RouteCode = '%' THEN -1 ELSE 0 END
	 ORDER BY PRH.ProdDateTime, SI.Barcode, PRH.RouteCode

END


-- SELECT  * FROM STB_SetInfo where barcode = 'VJJQ123R018612'