$content = Get-Content '.\usp_Vietnam_RawMaterialInputHist_uid_fromdb.sql' -Raw
$target = 'LotMaterialCode =  ISNULL(@LotMaterialBarcode,@LotMaterialBarcode),'
$replacement = "LotMaterialCode =  ISNULL(@LotMaterialBarcode,@LotMaterialBarcode), MaterialCode = ISNULL(MaterialCode, CASE WHEN ISNULL(@mmmaterialcode, '') <> '' THEN @mmmaterialcode WHEN CHARINDEX('#', @RawMaterialBarcode) > 0 THEN LEFT(@RawMaterialBarcode, CHARINDEX('#', @RawMaterialBarcode) - 1) ELSE MaterialCode END),"
$content = $content.Replace($target, $replacement)
$content = $content -replace 'CREATE PROCEDURE', 'ALTER PROCEDURE'
Set-Content '.\usp_Vietnam_RawMaterialInputHist_uid_FIXED.sql' -Value $content -Encoding UTF8
