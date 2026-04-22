Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # 1. Get column names for STB_MaterialDocLotInfo
    $cmd.CommandText = "SELECT name FROM sys.columns WHERE object_id = OBJECT_ID('STB_MaterialDocLotInfo')"
    $columns = @()
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) { $columns += $reader['name'] }
    $reader.Close()
    Write-Host "Columns: $($columns -join ', ')"

    # 2. Check for PBDM00-186 Material Master
    $cmd.CommandText = "SELECT TOP 5 MaterialCode, MaterialName FROM STB_MaterialInfo WHERE MaterialCode LIKE 'PBDM00-186%'"
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Material Master Check ---"
    while ($reader.Read()) {
        Write-Host "Code: '$($reader['MaterialCode'])' | Name: $($reader['MaterialName'])"
    }
    $reader.Close()

    # 3. Check for recent lots using found columns 
    # Use LotAttribute1 or LotNo if VendorLot was wrong
    $lotCol = ($columns | Where-Object { $_ -like "*Lot*" -or $_ -like "*Vendor*" })[0]
    Write-Host "Attempting Lot Check with column: $lotCol"
    if ($lotCol) {
        $cmd.CommandText = "SELECT TOP 5 MaterialCode, $lotCol, CreateDateTime FROM STB_MaterialDocLotInfo WHERE MaterialCode LIKE 'PBDM00-186%' ORDER BY CreateDateTime DESC"
        $reader = $cmd.ExecuteReader()
        while ($reader.Read()) {
             Write-Host "Material: '$($reader['MaterialCode'])' | Lot: '$($reader[$lotCol])' | Created: $($reader['CreateDateTime'])"
        }
        $reader.Close()
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
