-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 생산관리
-- Description:	[B630] 공정재공정보
-- Modified: 2019-03-14 라인변경
-- EXEC [usp_GetProdRouteHistForRouteStockQty] '','','VNT','VNT_F1','ASSYLINE-05','','VJJQ132R710603'
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetProdRouteHistForRouteStockQty_20200601]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(200) = NULL,
						@pPONo VARCHAR(20) = NULL,
						@pBarcode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	-- 화면에서 검색조건이 넘어오지 않을 경우 테이블 풀스캔을 방지하기 위해 수정함. 2019.09.18 By Jackaroe
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END

	DECLARE @PONo VARCHAR(20) = CASE WHEN ISNULL(@pPONo,'') = '' THEN '*' ELSE @pPONo END
	DECLARE @Barcode VARCHAR(50) = ISNULL(@pBarcode, '')
	       ,@ControlNo VARCHAR(20)

	SELECT @ControlNo = ControlNo 
	  FROM STB_SetInfo
	 WHERE Barcode = @Barcode

	 SET @ControlNo = ISNULL(@ControlNo, '*')

  SELECT	POR.PONo,
			PRH.LineCode,
			LI.LineName,
			SI.MaterialCode,
			MM.MaterialName,
			PRH.ControlNo,
			SI.Barcode,
			POR.RouteIndex,
			POR.RouteCode,
			RI.RouteName,
			ISNULL(SUM(PRH.ProdQty), 0) - ISNULL(SUM(DQI.DefectQty), 0) AS ProdQty,
			NPOR.RouteCode                                                       AS NextRouteCode,
			NRI.RouteName                                                         AS NextRouteName,
			ISNULL(SUM(NPRH.ProdQty), 0)                                       AS NextProdQty,
			CASE WHEN 
				SUM(PRH.ProdQty) - CASE WHEN ISNULL(NPOR.RouteCode,'') = '' 
													OR SUM(NPRH.ProdQty) > SUM(PRH.ProdQty) 
										THEN SUM(PRH.ProdQty)
										ELSE CASE WHEN SUM(NPRH.ProdQty) <= SUM(PRH.ProdQty) 
													THEN ISNULL(SUM(NPRH.ProdQty),0) 
													ELSE 0 END 
										END - CASE WHEN ISNULL(SUM(DQI.DefectQty), 0) > 0 
													THEN ISNULL(SUM(DQI.DefectQty), 0) 
													ELSE 0 
												END < 0
            THEN 0 ELSE 
				SUM(PRH.ProdQty) - CASE WHEN ISNULL(NPOR.RouteCode,'') = '' 
														 OR SUM(NPRH.ProdQty) > SUM(PRH.ProdQty) 
												THEN SUM(PRH.ProdQty)
												ELSE CASE WHEN SUM(NPRH.ProdQty) <= SUM(PRH.ProdQty) 
														  THEN ISNULL(SUM(NPRH.ProdQty),0) 
														  ELSE 0 END 
												END - CASE WHEN ISNULL(SUM(DQI.DefectQty), 0) > 0 
														   THEN ISNULL(SUM(DQI.DefectQty), 0) 
														   ELSE 0 
													   END
			END  AS RouteStockQty
	   FROM (
			SELECT CompanyCode 
			      ,WorkCenterCode
				  ,PONo
				  ,ControlNo
				  ,LineCode
				  ,RouteCode
				  ,SUM(ProdQty) AS ProdQty
			  FROM STB_ProdRouteHist
			 GROUP BY CompanyCode, WorkCenterCode, PONo, ControlNo, LineCode, RouteCode

	   ) PRH
			LEFT OUTER JOIN STB_ProductionOrderRouting POR    WITH(NOLOCK)	ON PRH.PONo = POR.PONo                AND	PRH.RouteCode = POR.RouteCode
			LEFT OUTER JOIN STB_RouteInfo RI                        WITH(NOLOCK)	ON RI.RouteCode = POR.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderRouting NPOR  WITH(NOLOCK)	ON NPOR.PONo = POR.PONo              AND NPOR.RouteIndex = POR.RouteIndex + 1
			LEFT OUTER JOIN (
				SELECT CompanyCode 
			      ,WorkCenterCode
				  ,PONo
				  ,ControlNo
				  ,LineCode
				  ,RouteCode
				  ,SUM(ProdQty) AS ProdQty
			  FROM STB_ProdRouteHist
			 GROUP BY CompanyCode, WorkCenterCode, PONo, ControlNo, LineCode, RouteCode
			) NPRH ON NPRH.PONo = POR.PONo              AND	 NPRH.ControlNo = PRH.ControlNo          AND	NPRH.RouteCode = NPOR.RouteCode
			LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = NPOR.RouteCode
			LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
			LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
			LEFT OUTER JOIN (
				SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
				  FROM STB_DefectRepairInfo
				 WHERE DefectSummaryNo > '201907'
				   AND RepairType NOT IN ('MISSING', 'FINISH')
				 GROUP BY ControlNo, FindLineCode, FindRouteCode
			) DQI ON PRH.ControlNo = DQI.ControlNo
			     AND PRH.LineCode = DQI.FindLineCode
				 AND PRH.RouteCode = DQI.FindRouteCode
	WHERE 1=1
	   AND (@CompanyCode = '*' OR PRH.CompanyCode    =  @CompanyCode)
	   AND (@WorkCenterCode = '*' OR PRH.WorkCenterCode = @WorkCenterCode)
	   AND (@LineCode = '*' OR PRH.LineCode  = @LineCode)
	   AND (@ControlNo = '*' OR PRH.ControlNo = @ControlNo)
	GROUP BY POR.PONo,
			     PRH.LineCode,
				 LI.LineName,
				 SI.MaterialCode,
			 	 MM.MaterialName,
				 PRH.ControlNo,
				 SI.Barcode,
				 POR.RouteCode,
				 RI.RouteName,
				 NPOR.RouteCode,
				 NRI.RouteName,
				 POR.RouteIndex
	ORDER BY
	     	      PRH.LineCode,
			      SI.MaterialCode,
			      POR.PONo,
			  	  PRH.ControlNo,
				  POR.RouteIndex

END
