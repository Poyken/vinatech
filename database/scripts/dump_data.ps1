
$Server = "dbserver.hycap.co.kr,5398"
$Database = "SmartFactoryV2"
$Username = "vinaadmin"
$Password = "vina1234%6&8"
$Docs = @("260512000200", "260512000347")

$ConnectionString = "Server=$Server;Database=$Database;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$SqlConnection.Open()

function Get-NonEmptyColumns($table, $docNo) {
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand("SELECT * FROM $table WHERE MaterialDocNo = '$docNo'", $SqlConnection)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($SqlCmd)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset) | Out-Null
    
    foreach ($row in $dataset.Tables[0].Rows) {
        Write-Host "`n--- Table: $table | DocNo: $docNo ---" -ForegroundColor Cyan
        foreach ($col in $dataset.Tables[0].Columns) {
            $val = $row[$col.ColumnName]
            if ($val -ne $null -and $val.ToString().Trim() -ne "") {
                Write-Host "$($col.ColumnName): $val"
            }
        }
    }
}

foreach ($doc in $Docs) {
    Get-NonEmptyColumns "STB_MaterialDocInfo" $doc
    Get-NonEmptyColumns "STB_MaterialDocDetail" $doc
    Get-NonEmptyColumns "STB_MaterialDocLotInfo" $doc
}

$SqlConnection.Close()
