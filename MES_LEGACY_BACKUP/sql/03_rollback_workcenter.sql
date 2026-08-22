-- ==============================================================================
-- ROLLBACK WORKCENTERCODE FOR SHEET 1 LOTS
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE PRH
    SET 
        PRH.WorkCenterCode = BK.WorkCenterCode,
        PRH.ChangeUserID = BK.ChangeUserID,
        PRH.ChangeDateTime = BK.ChangeDateTime
    FROM dbo.STB_ProdRouteHist PRH
    INNER JOIN dbo.BK_20260821_HY_WorkCenter BK 
        ON PRH.ControlNo = BK.ControlNo AND PRH.RouteCode = BK.RouteCode;

    PRINT 'ROLLBACK WORKCENTERCODE SUCCESSFUL!';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
END CATCH;
