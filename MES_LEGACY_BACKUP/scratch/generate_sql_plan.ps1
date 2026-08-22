$data = Import-Csv "scratch/aging_lots_with_material.csv"

# Load the allocated lots
$d13_excel = @('VVQO183R072714', 'VVQO163R072709', 'VVQO193R072761', 'VVQO183R072716', 'VVQO193R072713', 'VVQO153R072712', 'VVQO193R072734', 'VVQO153R072714', 'VVQO153R072727', 'VVQO173R072751')
$d13_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-13' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 9)
$d13_lots = $d13_excel + ($d13_vvqq | ForEach-Object { $_.Barcode })

$d13_rem_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-13' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -Skip 9)
$d14_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-14' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d14_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-14' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 23)
$d14_lots = ($d13_rem_vvqq | ForEach-Object { $_.Barcode }) + ($d14_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d14_f1_vvqq | ForEach-Object { $_.Barcode })

$d15_excel = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748')
$d15_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-15' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d15_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-15' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d15_lots = $d15_excel + ($d15_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d15_f1_vvqq | ForEach-Object { $_.Barcode })

$d16_excel = @('VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760')
$d16_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-16' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d16_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-16' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 14)
$d16_lots = $d16_excel + ($d16_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d16_f1_vvqq | ForEach-Object { $_.Barcode })

$d17_excel = @('VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO173R072705', 'VVQO183R072769', 'VVQO203R072711', 'VVQO173R072735')
$d17_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-17' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d17_lots = $d17_excel + ($d17_f5_vvqq | ForEach-Object { $_.Barcode })

$d17_rem_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-17' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -Skip 8)
$d18_excel = @('VVQO193R072766', 'VVQO193R072712', 'VVQO153R072726', 'VVQO173R072731', 'VVQO163R072742', 'VVQO203R072713')
$d18_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-18' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d18_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-18' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d18_lots = $d18_excel + ($d17_rem_vvqq | ForEach-Object { $_.Barcode }) + ($d18_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d18_f1_vvqq | ForEach-Object { $_.Barcode })

$d19_excel = @('VVQP263R072710', 'VVQP283R072702', 'VVQP263R072709', 'VVQP183R072706', 'VVQO183R072711')
$d19_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-19' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d19_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-19' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 2)
$d19_lots = $d19_excel + ($d19_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d19_f1_vvqq | ForEach-Object { $_.Barcode })

# Generate full SQL script
$allLots = $d13_lots + $d14_lots + $d15_lots + $d16_lots + $d17_lots + $d18_lots + $d19_lots
$allLotsSql = ($allLots | ForEach-Object { "'$_'" }) -join ", "

function Make-SqlUpdate($date, $lotList) {
    $formatted = ($lotList | ForEach-Object { "'$_'" }) -join ", "
    return @"
    -- Cap nhat ngay $date ($($lotList.Count) lots)
    UPDATE PRH
    SET PRH.WorkCenterCode = 'VVT_F5',
        PRH.JobDate = '$date',
        PRH.CompleteRoute = 1,
        PRH.ChangeUserID = 'ADMIN_HY_AGING_PLAN',
        PRH.ChangeDateTime = GETDATE(),
        PRH.ProdDateTime = CASE 
            WHEN DATEPART(HOUR, PRH.ProdDateTime) < 10 
            THEN DATEADD(HOUR, 10, CAST('$date' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME))
            ELSE CAST('$date' AS DATETIME) + CAST(CAST(PRH.ProdDateTime AS TIME) AS DATETIME)
        END
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
    WHERE SI.Barcode IN ($formatted)
      AND PRH.RouteCode LIKE 'V-26%';
"@
}

$sqlScript = @"
-- ==============================================================================
-- 02_execute_aging_hy_plan_13_19.sql
-- Dieu chinh san luong Aging Hung Yen ngay 13 - 19 thang 08/2026 theo dung chi tieu:
-- 13/08: ~20,000 (Target 20k)
-- 14/08: ~40,000 (Target 40k)
-- 15/08: ~23,000 (Target 23k)
-- 16/08: ~25,000 (Target 25k)
-- 17/08: ~25,000 (Target 25k)
-- 18/08: ~25,000 (Target 25k)
-- 19/08: ~26,000 (Target 26k)
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY

$(Make-SqlUpdate '2026-08-13' $d13_lots)

$(Make-SqlUpdate '2026-08-14' $d14_lots)

$(Make-SqlUpdate '2026-08-15' $d15_lots)

$(Make-SqlUpdate '2026-08-16' $d16_lots)

$(Make-SqlUpdate '2026-08-17' $d17_lots)

$(Make-SqlUpdate '2026-08-18' $d18_lots)

$(Make-SqlUpdate '2026-08-19' $d19_lots)

    COMMIT TRANSACTION;
    PRINT 'CAP NHAT AGING HUNG YEN 13-19 HOAN TAT THANH CONG 100%!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI CAP NHAT AGING PLAN: %s', 16, 1, @ErrMsg);
END CATCH;
"@

$sqlScript | Out-File "sql/02_execute_aging_hy_plan_13_19.sql" -Encoding utf8
Write-Output "Generated sql/02_execute_aging_hy_plan_13_19.sql successfully!"
