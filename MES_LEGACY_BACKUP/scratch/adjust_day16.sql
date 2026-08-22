UPDATE PRH
SET PRH.WorkCenterCode = 'VVT_F1',
    PRH.ChangeUserID = NULL
FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
WHERE SI.Barcode = 'VVQQ103R072717' AND PRH.RouteCode = 'V-26';
