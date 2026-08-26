param([string]$Path, [switch]$AllowDangerous)
& (Join-Path $PSScriptRoot "mes.ps1") deploy -Path $Path -AllowDangerous:$AllowDangerous
