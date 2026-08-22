-- ==============================================================================
-- 06_restore_hy_route_workcenters.sql
-- Dam bao tat ca cac route _HY phai thuoc dung WorkCenterCode = 'VVT_F5'
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY

    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5'
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    WHERE PRH.RouteCode LIKE '%_HY' AND PRH.WorkCenterCode <> 'VVT_F5';

    COMMIT TRANSACTION;
    PRINT 'DA KHOI PHUC TAT CA ROUTE _HY VE DUNG NHA MAY HUNG YEN (VVT_F5)!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI: %s', 16, 1, @ErrMsg);
END CATCH;
