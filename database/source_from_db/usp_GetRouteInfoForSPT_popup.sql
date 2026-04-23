-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-05-09
-- Browsable : true
-- Group : 팝업
-- Description:	공정정보 - 팝업
-- 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRouteInfoForSPT_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	Declare @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode,'') = '' THEN '*' ELSE @pBarcode END
	Declare @PONo VARCHAR(20)
    
    SELECT
			RI.RouteCode,
			RI.RouteName,
			RI.CompanyCode,
			CI.CompanyName,
			RI.WorkCenterCode,
			WCI.WorkCenterName,
			'' AS MachineCode,
			'' AS MachineName,
			CASE WHEN PRH.RouteCode IS NOT NULL 
			     THEN '입력완료' 
				 ELSE CASE WHEN POR.IsOutputRoute = CONVERT(BIT, 1) 
				           THEN '박스실적처리' 
						   ELSE '입력대기' 
					  END 
			END AS Remark
	FROM
			STB_RouteInfo RI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH (NOLOCK)				ON (CI.CompanyCode = RI.CompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH (NOLOCK)			ON (WCI.WorkCenterCode = RI.WorkCenterCode)
			LEFT OUTER JOIN STB_SetInfo SI WITH (NOLOCK)
			  ON SI.Barcode = @Barcode
			LEFT OUTER JOIN STB_ProdRouteHist PRH
			  ON PRH.ControlNo = SI.ControlNo 
			 AND PRH.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR
			  ON POR.PONo = SI.PONo
			 AND POR.RouteCode = RI.RouteCode
	WHERE 1=1
		    AND (RI.IsUsed = 1)
			AND RI.RouteCode IN (
				SELECT RouteCode  
				  FROM STB_BasicRoutingDetail
				 WHERE CompanyCode = @CompanyCode
				   AND WorkCenterCode = @WorkCenterCode
				   AND BasicRoutingCode = (SELECT BasicRoutingCode 
				                             FROM STB_MaterialMaster 
											WHERE MaterialCode = (SELECT MaterialCode 
											                        FROM STB_SetInfo 
																   WHERE Barcode = @Barcode)
										  )
			)
END