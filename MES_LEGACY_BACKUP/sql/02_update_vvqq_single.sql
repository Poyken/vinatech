-- ==============================================================================
-- Adjust VVQQ073R072729 ProdDateTime past 10:00 AM
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE PRH
    SET PRH.ProdDateTime = '2026-08-13 10:18:38',
        PRH.CompleteRoute = 1,
        PRH.WorkCenterCode = 'VVT_F5',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE()
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQQ073R072729' AND PRH.RouteCode = 'V-26';

    COMMIT TRANSACTION;
    PRINT 'CAP NHAT VVQQ073R072729 THANH CONG!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI: %s', 16, 1, @ErrMsg);
END CATCH;
