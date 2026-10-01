-- Author: vanduc
-- Description: Unit test safe query
BEGIN TRAN
SELECT TOP 1 LotNo FROM STB_ProdRouteHist WITH(NOLOCK);
ROLLBACK TRAN
