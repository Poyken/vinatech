UPDATE PRH
SET PRH.WorkCenterCode = 'VVT_F1',
    PRH.CompleteRoute = NULL
FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
WHERE SI.Barcode = 'VVQP233R072701' AND PRH.RouteCode LIKE 'V-26%';
