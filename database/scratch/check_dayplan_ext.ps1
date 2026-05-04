$sql = "SELECT BarcodeModel, DPPExtText01, DPPExtText02, DPPExtText03, DPPExtText04, DPPExtText05 FROM STB_DayProdPlan WHERE DayPlanNo = '2025081300141'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
