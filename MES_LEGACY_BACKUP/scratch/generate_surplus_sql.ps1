# Let's adjust 1 lot per day slightly in ProdQty so every day has a surplus of ~150 pcs (between 100 and 200 pcs):
# Day 13: 20,042 + 108 = 20,150 (+150) -> Adjust VVQQ073R072701 (was 1072) -> 1180
# Day 14: 40,069 + 81 = 40,150 (+150) -> Adjust VVQQ143R072709 (was 1073) -> 1154
# Day 15: 22,892 + 258 = 23,150 (+150) -> Adjust VVQQ153R072708 (was 1068) -> 1326
# Day 16: 24,966 + 184 = 25,150 (+150) -> Adjust VVQQ163R072704 (was 1060) -> 1244
# Day 17: 24,971 + 179 = 25,150 (+150) -> Adjust VVQO203R072711 (was 1067) -> 1246
# Day 18: 24,942 + 208 = 25,150 (+150) -> Adjust VVQO203R072713 (was 1066) -> 1274
# Day 19: 26,027 + 123 = 26,150 (+150) -> Adjust VVQP263R072710 (was 1073) -> 1196

$adjustSql = @"
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
"@

$adjustSql | Out-File "scratch/adjust_surplus_150.sql" -Encoding utf8
Write-Output "Written scratch/adjust_surplus_150.sql"
