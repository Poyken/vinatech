Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT SUBSTRING(OBJECT_DEFINITION(OBJECT_ID('dbo.usp_Vietnam_RawMaterialInputHist_uid')), 1, 4000) AS def"
$reader = $cmd.ExecuteReader()
if ($reader.Read()) {
    $text = $reader['def'].ToString()
    if ($text.Contains("?")) { Write-Host "Contains question marks!" }
    Write-Host "Snippet:"
    Write-Host $text.Substring(0, Math.Min($text.Length, 200))
}
$conn.Close()
