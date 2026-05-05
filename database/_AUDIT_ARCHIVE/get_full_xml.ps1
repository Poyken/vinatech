$server = 'dbserver.hycap.co.kr,5398'
$database = 'SmartFramework'
$user = 'vinaadmin'
$pass = 'vina1234%6&8'

$formatName = 'SanminaIndiaLabel_ver2'
$fullXml = ""

for ($i = 0; $i -lt 8; $i++) {
    $start = $i * 4000 + 1
    $sql = "SELECT SUBSTRING(CAST(Format AS NVARCHAR(MAX)), $start, 4000) as Chunk FROM STB_LabelInfo WHERE FormatName = '$formatName'"
    $chunk = Invoke-Sqlcmd -ServerInstance $server -Database $database -Username $user -Password $pass -Query $sql
    if ($chunk.Chunk) {
        $fullXml += $chunk.Chunk
    }
}

$fullXml | Set-Content -Path 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_full_clean.xml'
Write-Host "Total length: $($fullXml.Length)"
