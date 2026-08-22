-- ==============================================================================
-- 02_execute_day14.sql — CẬP NHẬT DỮ LIỆU AGING NGÀY 14/08 ĐẠT ~40.000 HÀNG
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Cập nhật 21 Lot chuyển từ Excel sang Hưng Yên ngày 14/08
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.CompleteRoute = 1,
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode IN ('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748', 'VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760', 'VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO183R072711') AND PRH.RouteCode LIKE 'V-26%';

    -- 2. Kích hoạt CompleteRoute = 1 cho 15 Lot có sẵn trên Aging Hưng Yên ngày 14/08
    UPDATE PRH
    SET PRH.CompleteRoute = 1,
        PRH.WorkCenterCode = 'VVT_F5',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE()
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode IN ('VVQQ103R072724', 'VVQQ103R072726', 'VVQQ133R072719', 'VVQQ133R072720', 'VVQQ113R072715', 'VVQQ103R072725', 'VVQQ123R072727', 'VVQQ113R072717', 'VVQQ133R072717', 'VVQQ143R072715', 'VVQQ133R072727', 'VVQQ123R072719', 'VVQQ123R072726', 'VVQQ143R072709', 'VVQQ123R072733') 
      AND PRH.RouteCode LIKE 'V-26%'
      AND CAST(PRH.JobDate AS DATE) = '2026-08-14';

    -- 3. Kích hoạt CompleteRoute = 1 và chuyển WorkCenterCode về VVT_F5 cho 5 Lot ECVT ngày 14/08
    UPDATE PRH
    SET PRH.CompleteRoute = 1,
        PRH.WorkCenterCode = 'VVT_F5',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE()
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode IN ('VVQQ073R072702', 'VVQQ093R072715', 'VVQQ063R072730', 'VVQQ073R072720', 'VVQQ073R072731') 
      AND PRH.RouteCode LIKE 'V-26%'
      AND CAST(PRH.JobDate AS DATE) = '2026-08-14';

    COMMIT TRANSACTION;
    PRINT 'CAP NHAT AGING NGAY 14/08 HOAN TAT THANH CONG 100%!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI: %s', 16, 1, @ErrMsg);
END CATCH;
