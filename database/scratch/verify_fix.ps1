$sql = "
SELECT 'STB_ModelBasicInfo' as CheckType, ModelCode, MBIExtText05 FROM STB_ModelBasicInfo WHERE ModelCode = 'ECVT27-404'
UNION ALL
SELECT 'Old Barcode Count' as CheckType, NULL, CAST(COUNT(*) AS VARCHAR) FROM STB_SetInfo WHERE Barcode LIKE 'VVPQ132R715[0-1][0-9]'
UNION ALL
SELECT 'New Barcode Count' as CheckType, NULL, CAST(COUNT(*) AS VARCHAR) FROM STB_SetInfo WHERE Barcode LIKE 'VVPQ132R7156%'
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
