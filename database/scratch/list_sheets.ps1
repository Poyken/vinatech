Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Data sorting.xlsx"
$zip = [System.IO.Compression.ZipFile]::OpenRead($xlsxPath)
$workout = $zip.Entries | Where-Object { $_.FullName -eq "xl/workbook.xml" }
$stream = $workout.Open()
$workbookXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
$stream.Close()
$zip.Dispose()

$workbookXml.workbook.sheets.sheet | Select-Object name, sheetId, r:id
