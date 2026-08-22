-- ==============================================================================
-- 05_full_rollback_everything.sql
-- ROLLBACK TOAN BO TAT CA CAC THAY DOI VE TRUOC KHI THUC HIEN JOB EXCEL
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY

    -- 1. Rollback STB_ProdRouteHist tu BK_20260821_AGING_PLAN_ProdRouteHist (191 lots Aging plan)
    UPDATE PRH
    SET PRH.WorkCenterCode = BK.WorkCenterCode,
        PRH.JobDate        = BK.JobDate,
        PRH.ProdDateTime   = BK.ProdDateTime,
        PRH.ProdQty        = BK.ProdQty,
        PRH.CompleteRoute  = BK.CompleteRoute,
        PRH.ChangeDateTime = BK.ChangeDateTime,
        PRH.ChangeUserID   = BK.ChangeUserID
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.BK_20260821_AGING_PLAN_ProdRouteHist BK WITH (NOLOCK)
        ON PRH.ProdRouteHistNo = BK.ProdRouteHistNo;

    PRINT '1. Da khoi phuc STB_ProdRouteHist tu BK_20260821_AGING_PLAN_ProdRouteHist';

    -- 2. Rollback STB_ProdRouteHist tu BK_20260821_HY_STB_ProdRouteHist (540 records ban dau luc 11:20 AM)
    UPDATE PRH
    SET PRH.WorkCenterCode = BK.WorkCenterCode,
        PRH.RouteCode      = BK.RouteCode,
        PRH.JobDate        = BK.JobDate,
        PRH.ProdDateTime   = BK.ProdDateTime,
        PRH.ProdQty        = BK.ProdQty,
        PRH.CompleteRoute  = BK.CompleteRoute,
        PRH.ChangeDateTime = BK.ChangeDateTime,
        PRH.ChangeUserID   = BK.ChangeUserID
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.BK_20260821_HY_STB_ProdRouteHist BK WITH (NOLOCK)
        ON PRH.ProdRouteHistNo = BK.ProdRouteHistNo;

    PRINT '2. Da khoi phuc STB_ProdRouteHist tu BK_20260821_HY_STB_ProdRouteHist';

    -- 3. Rollback STB_SetInfo tu BK_20260821_HY_STB_SetInfo (81 barcodes ban dau)
    UPDATE SI
    SET SI.CurrentRouteCode = BK.CurrentRouteCode,
        SI.ChangeDateTime   = BK.ChangeDateTime,
        SI.ChangeUserID     = BK.ChangeUserID
    FROM dbo.STB_SetInfo SI WITH (UPDLOCK)
    INNER JOIN dbo.BK_20260821_HY_STB_SetInfo BK WITH (NOLOCK)
        ON SI.ControlNo = BK.ControlNo;

    PRINT '3. Da khoi phuc STB_SetInfo tu BK_20260821_HY_STB_SetInfo';

    -- 4. Rollback STB_SavePackingTime_VVT tu BK_20260821_HY_STB_SavePackingTime_VVT (405 records ban dau)
    UPDATE SPT
    SET SPT.EmpNo       = BK.EmpNo,
        SPT.EmpChange   = BK.EmpChange,
        SPT.isPrinted   = BK.isPrinted,
        SPT.PrintTime   = BK.PrintTime
    FROM dbo.STB_SavePackingTime_VVT SPT WITH (UPDLOCK)
    INNER JOIN dbo.BK_20260821_HY_STB_SavePackingTime_VVT BK WITH (NOLOCK)
        ON SPT.id = BK.id;

    PRINT '4. Da khoi phuc STB_SavePackingTime_VVT tu BK_20260821_HY_STB_SavePackingTime_VVT';

    -- 5. Quet lai tat ca cac ban ghi con dinh ChangeUserID do job tao ra
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F1',
        PRH.ChangeUserID   = NULL,
        PRH.CompleteRoute  = NULL
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    WHERE PRH.ChangeUserID IN ('ADMIN_HY_V2', 'ADMIN_HY_FIX', 'ADMIN_HY_AGING_PLAN');

    PRINT '5. Da lam sach tat ca cac ban ghi ChangeUserID do job tao ra';

    COMMIT TRANSACTION;
    PRINT '==========================================================================';
    PRINT 'ROLLBACK TOAN BO TAT CA CAC THAY DOI VE TRUOC KHI LAM JOB EXCEL THANH CONG 100%!';
    PRINT '==========================================================================';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI ROLLBACK: %s', 16, 1, @ErrMsg);
END CATCH;
