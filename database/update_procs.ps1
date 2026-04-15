Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$procs = @(
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\usp_MaterialDocLotInfo_get.sql",
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\usp_MaterialDocDetail_get.sql"
)

foreach ($procFile in $procs) {
    Write-Host "Updating $procFile..."
    $sql = Get-Content $procFile -Raw
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    try {
        $cmd.ExecuteNonQuery()
        Write-Host "Successfully updated $(Split-Path $procFile -Leaf)"
    } catch {
        Write-Error "Failed to update $(Split-Path $procFile -Leaf): $($_.Exception.Message)"
    }
}

$conn.Close()
