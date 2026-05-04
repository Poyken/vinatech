$sql = "exec usp_MaterialQcInfo_Processed_get 'vinaadmin','EN','','','','2026-03-26','2026-04-25', '' ,'IQC', 'VVT' ,'VVT_F1' ,'', '' , '2026-03-26','2026-04-25',''"
$results = Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
$noneCount = ($results | Where-Object { $_.DecisionResult -eq 'None' }).Count
if ($noneCount -eq 0 -or $null -eq $noneCount) {
    "Verification PASS: No 'None' records found in Processed SP."
} else {
    "Verification FAIL: Found $noneCount 'None' records in Processed SP."
}
"Total records returned: $($results.Count)"
