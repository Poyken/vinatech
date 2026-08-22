-- ==============================================================================
-- Update CompleteRoute = 1 for 10 HY Aging lots
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE PRH
    SET PRH.CompleteRoute = 1,
        PRH.WorkCenterCode = 'VVT_F5',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE()
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode IN (
        'VVQQ073R072729', 'VVQQ073R072727', 'VVQQ073R072718', 'VVQQ083R072708', 'VVQQ053R072727',
        'VVQQ073R072701', 'VVQQ053R072726', 'VVQQ053R072724', 'VVQQ053R072725', 'VVQQ073R072732'
    )
    AND PRH.RouteCode = 'V-26'
    AND CAST(PRH.JobDate AS DATE) = '2026-08-13';

    COMMIT TRANSACTION;
    PRINT 'CAP NHAT COMPLETEROUTE CHO 10 LOT HY THANH CONG!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI: %s', 16, 1, @ErrMsg);
END CATCH;
