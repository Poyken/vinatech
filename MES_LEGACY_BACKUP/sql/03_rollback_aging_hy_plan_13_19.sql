-- ==============================================================================
-- 03_rollback_aging_hy_plan_13_19.sql
-- Khoi phuc du lieu ve trang thai truoc khi chay plan 13-19
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY

    UPDATE PRH
    SET PRH.WorkCenterCode = BK.WorkCenterCode,
        PRH.JobDate = BK.JobDate,
        PRH.ProdDateTime = BK.ProdDateTime,
        PRH.CompleteRoute = BK.CompleteRoute,
        PRH.ChangeUserID = BK.ChangeUserID,
        PRH.ChangeDateTime = BK.ChangeDateTime
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.BK_20260821_AGING_PLAN_ProdRouteHist BK WITH (NOLOCK)
        ON PRH.ControlNo = BK.ControlNo AND PRH.RouteCode = BK.RouteCode;

    COMMIT TRANSACTION;
    PRINT 'ROLLBACK Dá»® LIá»†U AGING 13-19 Vá»€ NGUYÃŠN Báº¢N THÃ€NH CÃ”NG!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI ROLLBACK: %s', 16, 1, @ErrMsg);
END CATCH;
