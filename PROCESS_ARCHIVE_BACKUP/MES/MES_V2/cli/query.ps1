param([string]$Sql, [string]$Format = "Table")
& (Join-Path $PSScriptRoot "mes.ps1") query $Sql -Format $Format
