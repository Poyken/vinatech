[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=30;"

$targetSPs = @(
    "usp_SetInfo_iud",
    "usp_ProductionOrderBatchInfo_iud",
    "usp_Prod_Daily_Input_Schedule_iud",
    "usp_ProductionOrderRouting_iud",
    "usp_ProductionOrderBom_get",
    "usp_SemiFinishGoodWarehouse_VVTF3_Exported"
)

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    
    foreach ($sp in $targetSPs) {
        Write-Host "Fetching $sp..."
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.$sp')) AS def"
        $reader = $cmd.ExecuteReader()
        if ($reader.Read() -and $reader["def"] -ne [DBNull]::Value) {
            $def = $reader["def"].ToString()
            $fileName = "sp_src_$sp.sql"
            [System.IO.File]::WriteAllText("c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\$fileName", $def)
            Write-Host "  Saved to $fileName"
        } else {
            Write-Host "  NOT FOUND or NO ACCESS for $sp"
        }
        $reader.Close()
    }
    
    $conn.Close()
} catch {
    Write-Error $_.Exception.Message
}
