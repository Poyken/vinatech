$server = 'dbserver.hycap.co.kr,5398'
$database = 'SmartFactoryV2'
$user = 'vinaadmin'
$pass = 'vina1234%6&8'

$sql = "EXEC usp_SanminaLabelPrint_get_Vietnam 'vinaadmin', 'EN', '1', 'VVQL033R07279S', '1', 1"
$res = Invoke-Sqlcmd -ServerInstance $server -Database $database -Username $user -Password $pass -Query $sql
$res | Select-Object LotNo, LotCode, CartonBoxNo | Format-Table
