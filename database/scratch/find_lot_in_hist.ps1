$lotNo = "VVQL033R07279S"
$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$pass = "vina1234%6&8"

$tables = @("STB_VietnamLabelPrintHist", "STB_BloomBoxLabalPrintHist", "STB_PACLablePrintHist", "STB_MarkingLabelPrintHist", "STB_PackingLabelPrintHist")

foreach ($t in $tables) {
    Write-Host "Checking $t..."
    $query = "SELECT TOP 1 * FROM $t WHERE 1=1" # Just to get a hit if possible, but I need columns
    # Actually, better to search for the value in all columns
    $searchQuery = "
    DECLARE @lot VARCHAR(50) = '$lotNo';
    DECLARE @sql NVARCHAR(MAX) = '';
    SELECT @sql = @sql + 'SELECT ''' + TABLE_NAME + ''' AS TableName, * FROM ' + TABLE_NAME + ' WHERE ' + COLUMN_NAME + ' = ''' + @lot + ''';'
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = '$t' AND DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar')
    EXEC sp_executesql @sql;
    "
    sqlcmd -S $server -d $database -U $user -P $pass -Q $searchQuery -W -C
}
