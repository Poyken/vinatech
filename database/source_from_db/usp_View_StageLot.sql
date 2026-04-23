 CREATE PROC usp_View_StageLot
 @pWorkCenterCode NVARCHAR(10),
 @pBarcode NVARCHAR(50)
 AS
 BEGIN
  SELECT  DISTINCT  A.Barcode,A.ControlNo,B.RouteCode,E.RouteName,B.LineCode,C.LineName,B.PONo,D.MaterialCode,D.MaterialName,B.ProdQty,A.CreateUserID,
 A.CreateDateTime, B.DayPlanNo
 --CASE
	--WHEN 
 FROM 
		 STB_SetInfo A with(nolock) 
		 LEFT OUTER JOIN  STB_ProdRouteHist B WITH(NOLOCK) ON A.ControlNo=B.ControlNo	
		 LEFT OUTER JOIN STB_MaterialMaster D WITH(NOLOCK) ON A.MaterialCode = D.MaterialCode
		 LEFT OUTER JOIN STB_LineInfo C WITH(NOLOCK) ON A.InputLineCode = C.LineCode
		 LEFT OUTER JOIN STB_RouteInfo E WITH(NOLOCK) ON E.RouteCode = B.RouteCode
		
WHERE
		 B.CompanyCode='VVT' AND B.WorkCenterCode = @pWorkCenterCode  AND A.Barcode = @pBarcode

ORDER BY B.RouteCode ASC

 END
