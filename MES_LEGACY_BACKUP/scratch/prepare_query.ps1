$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES_LEGACY_BACKUP"

# We will query all lots in STB_ProdRouteHist where RouteCode LIKE 'V-26%' between 2026-08-11 and 2026-08-20
# and examine them.

$query = @"
SELECT 
    SI.Barcode,
    PRH.RouteCode,
    PRH.WorkCenterCode,
    CAST(PRH.JobDate AS DATE) as JobDate,
    PRH.ProdQty,
    PRH.CompleteRoute,
    PRH.ProdDateTime
FROM dbo.STB_ProdRouteHist PRH WITH (NOLOCK)
INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
WHERE PRH.RouteCode LIKE 'V-26%'
  AND CAST(PRH.JobDate AS DATE) BETWEEN '2026-08-11' AND '2026-08-21'
ORDER BY PRH.JobDate, PRH.WorkCenterCode, SI.Barcode
"@

$query | Out-File "scratch/query_all_aging.sql" -Encoding utf8
