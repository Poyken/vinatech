param ()
$sql = "
SELECT h.ModelCode, m.ModelName, d.MaterialCode, mm.MaterialName
FROM STB_BomHeader h
JOIN STB_ModelBasicInfo m ON h.ModelCode = m.ModelCode
JOIN STB_BomDetail d ON h.BomHeaderNo = d.BomHeaderNo
JOIN STB_MaterialMaster mm ON d.MaterialCode = mm.MaterialCode
WHERE m.ModelName LIKE '%WEC3R0606QG%'
AND (d.MaterialCode LIKE '%GBCP%' OR d.MaterialCode LIKE '%GBEC%')
"
Invoke-Sqlcmd -ServerInstance "dbserver.hycap.co.kr,5398" -Database "SmartFactoryV2" -Username "vanduc" -Password "MK vina1234%6&8" -Query $sql | Format-Table -AutoSize
