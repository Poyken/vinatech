param([string]$Key, [string]$Screen, [string]$Barcode, [switch]$Html)
& (Join-Path $PSScriptRoot "mes.ps1") debug -Target $Key -Screen $Screen -Barcode $Barcode -Html:$Html
