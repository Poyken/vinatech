-- ==============================================================================
-- 02_execute_final_conversion.sql — THI HÀNH CHUYỂN ĐỔI CHUẨN XÁC THEO FILE EXCEL
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY

    -- Aging: VVQO183R072714 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072714' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072708 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072708' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072708 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072708' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072768 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072768' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072770 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072770' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072766 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072766' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQP263R072710 -> 2026-08-19
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-19',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-19' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-19' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQP263R072710' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO163R072709 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO163R072709' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO173R072761 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072761' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO173R072761 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072761' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072719 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072719' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072711 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072711' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072712 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072712' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQP283R072702 -> 2026-08-19
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-19',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-19' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-19' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQP283R072702' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072761 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072761' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072748 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072748' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072748 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072748' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072709 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072709' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072720 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072720' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072726 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072726' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQP263R072709 -> 2026-08-19
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-19',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-19' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-19' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQP263R072709' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072716 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072716' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072768 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072768' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072728 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072728' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072712 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072712' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO173R072731 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072731' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQP183R072706 -> 2026-08-19
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-19',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-19' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-19' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQP183R072706' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072713 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072713' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072719 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072719' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072760 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072760' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072717 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072717' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO163R072742 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO163R072742' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072712 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072712' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072709 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072709' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQN033R072790 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQN033R072790' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO203R072713 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072713' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072734 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072734' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072728 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072728' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO173R072718 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072718' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072714 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072714' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072760 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072760' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072767 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072767' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072727 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072727' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072770 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072770' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072749 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072749' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO173R072751 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072751' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072711 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072711' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO203R072758 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072758' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO153R072720 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072720' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO163R072712 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO163R072712' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072712 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072712' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072725 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072725' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072717 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072717' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO173R072705 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072705' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQN033R072790 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQN033R072790' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072769 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072769' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO173R072718 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072718' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO203R072711 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072711' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072767 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072767' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO173R072735 -> 2026-08-17
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-17',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-17' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072735' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072749 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072749' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO203R072758 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072758' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO163R072712 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO163R072712' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO193R072725 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072725' AND PRH.RouteCode LIKE 'V-26%';

    -- Aging: VVQO183R072711 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072711' AND PRH.RouteCode LIKE 'V-26%';

    -- Packing: VVQO113R072735 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO113R072735' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072722 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072722' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072716 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072716' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072710 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072710' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO203R072725 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072725' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072709 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072709' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072724 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072724' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072717 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072717' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072711 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072711' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072727 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072727' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072710 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072710' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072726 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072726' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072718 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072718' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072713 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072713' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072748 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072748' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072711 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072711' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072727 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072727' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072747 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072747' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072714 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072714' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072749 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072749' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072712 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072712' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072728 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072728' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072760 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072760' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072715 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072715' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072758 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072758' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072713 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072713' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO163R072709 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO163R072709' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072761 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072761' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072716 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072716' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072761 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072761' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072714 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072714' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO163R072711 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO163R072711' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072770 -> 2026-08-15
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-15',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-15' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072770' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072717 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072717' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072767 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072767' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072719 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072719' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO163R072742 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO163R072742' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072718 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072718' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072768 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072768' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072720 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072720' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO173R072716 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072716' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072725 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072725' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072777 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072777' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO153R072721 -> 2026-08-13
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-13',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-13' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO153R072721' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO173R072718 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072718' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO193R072727 -> 2026-08-16
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-16',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-16' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO193R072727' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO203R072713 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072713' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO173R072719 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072719' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO203R072743 -> 2026-08-18
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-18',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-18' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072743' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO173R072722 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072722' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO173R072731 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072731' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO173R072735 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072735' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO173R072751 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072751' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO173R072761 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO173R072761' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072710 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072710' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072712 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072712' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072713 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072713' AND PRH.RouteCode LIKE 'V-28%';

    -- Packing: VVQO183R072715 -> 2026-08-14
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '2026-08-14',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('2026-08-14' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO183R072715' AND PRH.RouteCode LIKE 'V-28%';

    -- 10 Lots ECVT30-357 Hưng Yên ngày 13/08
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.ChangeUserID = 'ADMIN_HY_FIX',
        PRH.ChangeDateTime = GETDATE()
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode IN ('VVQQ073R072729', 'VVQQ073R072727', 'VVQQ073R072718', 'VVQQ083R072708', 'VVQQ053R072727', 'VVQQ073R072701', 'VVQQ053R072726', 'VVQQ053R072724', 'VVQQ053R072725', 'VVQQ073R072732') 
      AND PRH.RouteCode LIKE 'V-26%' 
      AND CAST(PRH.JobDate AS DATE) = '2026-08-13';

    -- Sheet 2: 17 Lots ECVT30-357 cho B781 ngày 19/08 Hưng Yên
    UPDATE SPT
    SET SPT.PrintTime = CAST('2026-08-19' AS DATETIME) + CAST(CAST(SPT.PrintTime AS TIME) AS DATETIME),
        SPT.EmpNo = 'vvtworker_hy',
        SPT.EmpChange = 'vvtworker_hy'
    FROM dbo.STB_SavePackingTime_VVT SPT WITH (UPDLOCK)
    WHERE SPT.LotNo IN ('VVQN033R072790', 'VVQO173R072705', 'VVQO173R072737', 'VVQO183R072711', 'VVQO183R072769', 'VVQO193R072702', 'VVQO193R072708', 'VVQO193R072712', 'VVQO193R072735', 'VVQO193R072745', 'VVQO193R072752', 'VVQO193R072760', 'VVQO193R072762', 'VVQO193R072766', 'VVQO203R072711', 'VVQO203R072734', 'VVQO203R072758');


    COMMIT TRANSACTION;
    PRINT 'THI HANH CHUYEN DOI CHUAN XAC HOAN TAT 100%!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI THI HANH: %s', 16, 1, @ErrMsg);
END CATCH;
