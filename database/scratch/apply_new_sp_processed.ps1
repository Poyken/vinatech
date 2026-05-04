$content = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\usp_MaterialQcInfo_get.sql' -Raw

# 1. Đổi tên SP
$newContent = $content -replace 'CREATE PROCEDURE \[dbo\]\.\[usp_MaterialQcInfo_get\]', 'CREATE PROCEDURE [dbo].[usp_MaterialQcInfo_Processed_get]'

# 2. Chèn điều kiện loại trừ 'None' vào các khối WHERE
# Tìm đoạn: AND (MQI.DecisionResult LIKE @DecisionResult)
# Thay bằng: AND (MQI.DecisionResult LIKE @DecisionResult) AND (MQI.DecisionResult <> 'None')
$newContent = $newContent -replace 'AND \(MQI\.DecisionResult LIKE @DecisionResult\)', 'AND (MQI.DecisionResult LIKE @DecisionResult) AND (ISNULL(MQI.DecisionResult, '''') <> ''None'')'

# 3. Lưu file script tạo mới
$utf8WithBom = [System.Text.Encoding]::UTF8
[System.IO.File]::WriteAllText('C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\create_usp_MaterialQcInfo_Processed_get.sql', $newContent, $utf8WithBom)

# 4. Thực thi tạo SP trong Database
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -InputFile 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\create_usp_MaterialQcInfo_Processed_get.sql'
