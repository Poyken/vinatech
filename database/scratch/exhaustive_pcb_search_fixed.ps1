Add-Type -AssemblyName System.Data
$server = "dbserver.hycap.co.kr,5398"
$user = "vinaadmin"
$pass = "vina1234%6&8"

function Search($dbName) {
    $cs = "Server=$server;Initial Catalog=$dbName;User ID=$user;Password=$pass;TrustServerCertificate=True;Connect Timeout=30;"
    $conn = New-Object System.Data.SqlClient.SqlConnection($cs)
    try {
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "
            SELECT SCHEMA_NAME(schema_id) as S, name as N, OBJECT_DEFINITION(object_id) as D 
            FROM sys.objects 
            WHERE name = 'fn_VVT_getdatebyVendorLot'
        "
        $reader = $cmd.ExecuteReader()
        while ($reader.Read()) {
            $def = $reader['D'].ToString()
            Write-Host "--- Database: $dbName | Schema: $($reader['S']) ---"
            if ($def -like "*PBDM00-186*") {
                Write-Host "Status: Logic for PBDM00-186 is PRESENT."
            } else {
                Write-Host "Status: Logic for PBDM00-186 is MISSING!"
            }
        }
        $reader.Close()

        # Search for any other SP/Fn containing the string 'PBDM00-186' or 'fn_VVT_getdatebyVendorLot'
        $cmd.CommandText = "
            SELECT name, type_desc FROM sys.sql_modules m 
            JOIN sys.objects o ON m.object_id = o.object_id 
            WHERE m.definition LIKE '%PBDM00-186%'
        "
        $reader = $cmd.ExecuteReader()
        Write-Host "--- Other objects containing 'PBDM00-186' in $dbName ---"
        while ($reader.Read()) {
            Write-Host "$($reader['type_desc']): $($reader['name'])"
        }
        $reader.Close()

    } catch {
        Write-Host "Error in $($dbName): $($_.Exception.Message)"
    } finally {
        $conn.Close()
    }
}

Write-Host "Starting exhaustive search..."
Search "SmartFactoryV2"
Search "SmartFactory"
