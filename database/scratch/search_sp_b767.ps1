$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$pass = "vina1234%6&8"

$query = "SELECT OBJECT_NAME(id) AS SP_Name FROM syscomments WHERE text LIKE '%B767%' GROUP BY OBJECT_NAME(id)"
sqlcmd -S $server -d $database -U $user -P $pass -Q $query -W -C
