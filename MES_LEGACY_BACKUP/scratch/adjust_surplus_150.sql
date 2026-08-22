BEGIN TRANSACTION;
BEGIN TRY

    -- Day 13: +108 -> Total = 20,150 (Diff: +150)
    UPDATE PRH
    SET PRH.ProdQty = PRH.ProdQty + 108
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQQ073R072701' AND PRH.RouteCode LIKE 'V-26%' AND CAST(PRH.JobDate AS DATE) = '2026-08-13';

    -- Day 14: +81 -> Total = 40,150 (Diff: +150)
    UPDATE PRH
    SET PRH.ProdQty = PRH.ProdQty + 81
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQQ143R072709' AND PRH.RouteCode LIKE 'V-26%' AND CAST(PRH.JobDate AS DATE) = '2026-08-14';

    -- Day 15: +258 -> Total = 23,150 (Diff: +150)
    UPDATE PRH
    SET PRH.ProdQty = PRH.ProdQty + 258
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQQ153R072708' AND PRH.RouteCode LIKE 'V-26%' AND CAST(PRH.JobDate AS DATE) = '2026-08-15';

    -- Day 16: +184 -> Total = 25,150 (Diff: +150)
    UPDATE PRH
    SET PRH.ProdQty = PRH.ProdQty + 184
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQQ163R072704' AND PRH.RouteCode LIKE 'V-26%' AND CAST(PRH.JobDate AS DATE) = '2026-08-16';

    -- Day 17: +179 -> Total = 25,150 (Diff: +150)
    UPDATE PRH
    SET PRH.ProdQty = PRH.ProdQty + 179
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072711' AND PRH.RouteCode LIKE 'V-26%' AND CAST(PRH.JobDate AS DATE) = '2026-08-17';

    -- Day 18: +208 -> Total = 25,150 (Diff: +150)
    UPDATE PRH
    SET PRH.ProdQty = PRH.ProdQty + 208
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQO203R072713' AND PRH.RouteCode LIKE 'V-26%' AND CAST(PRH.JobDate AS DATE) = '2026-08-18';

    -- Day 19: +123 -> Total = 26,150 (Diff: +150)
    UPDATE PRH
    SET PRH.ProdQty = PRH.ProdQty + 123
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode = 'VVQP263R072710' AND PRH.RouteCode LIKE 'V-26%' AND CAST(PRH.JobDate AS DATE) = '2026-08-19';

    COMMIT TRANSACTION;
    PRINT 'DA DIEU CHINH THUA 150 HANG CHO MOI NGAY THANH CONG!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI: %s', 16, 1, @ErrMsg);
END CATCH;
