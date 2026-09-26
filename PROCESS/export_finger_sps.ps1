. "$PSScriptRoot\DATABASE\tools\db_shared.ps1"
$db = Get-DBConnection -Profile SmartFactoryV2

function Export-CMS-SP($spName, $fileName) {
    $cmd = $db.Connection.CreateCommand()
    $cmd.CommandText = "SELECT definition FROM OPENQUERY([CMS_VINA_LINK], 'SELECT definition FROM CMS_VINA.sys.sql_modules WHERE object_id = OBJECT_ID(''CMS_VINA.dbo.$spName'')')"
    $cmd.CommandTimeout = 60
    $def = $cmd.ExecuteScalar()
    [System.IO.File]::WriteAllText("$PSScriptRoot\$fileName", $def, [System.Text.Encoding]::UTF8)
    Write-Host "Exported $spName, Length: $($def.Length)"
}

Export-CMS-SP "Search_FingerUser1" "CMS_Search_FingerUser1.sql"
Export-CMS-SP "Transfer_EmployeesAttendance_CMS_To_MES" "CMS_Transfer_EmployeesAttendance.sql"
