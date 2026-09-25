# ==============================================================================
# Vinatech.MES.psm1 — Master Module Loader for MES_V2
# ==============================================================================

$moduleRoot = $PSScriptRoot

# Dot-source all component classes in correct order
. (Join-Path $moduleRoot "Database\ConnectionManager.ps1")
. (Join-Path $moduleRoot "Database\SafetyValidator.ps1")
. (Join-Path $moduleRoot "Database\QueryEngine.ps1")
. (Join-Path $moduleRoot "Diagnostics\GoldenQueryEngine.ps1")
. (Join-Path $moduleRoot "Diagnostics\ScreenDebugger.ps1")
. (Join-Path $moduleRoot "Diagnostics\HtmlReportGenerator.ps1")
. (Join-Path $moduleRoot "Tools\DeployEngine.ps1")
. (Join-Path $moduleRoot "Tools\SpSyncManager.ps1")
. (Join-Path $moduleRoot "Tools\FixbookLogger.ps1")

# Global singleton factory
function Initialize-MesContext([string]$configPath = "") {
    $mesPopRoot = Split-Path (Split-Path $moduleRoot -Parent) -Parent
    if ([string]::IsNullOrEmpty($configPath)) {
        $candidatePaths = @(
            (Join-Path $mesPopRoot "db_config.json"),
            (Join-Path (Split-Path $moduleRoot -Parent) "db_config.json"),
            (Join-Path (Split-Path $moduleRoot -Parent) "config\db.config.json")
        )
        foreach ($cp in $candidatePaths) {
            if (Test-Path $cp) { $configPath = $cp; break }
        }
    }
    $connMgr = [MesConnectionManager]::new($configPath)
    $queryEng = [MesQueryEngine]::new($connMgr)
    $goldenEng = [MesGoldenQueryEngine]::new($queryEng)
    $screenDbg = [MesScreenDebugger]::new($queryEng)
    $deployEng = [MesDeployEngine]::new($connMgr)
    $procDir = Join-Path $mesPopRoot "sql\procedures"
    $docsRoot = Join-Path $mesPopRoot "docs"
    $syncMgr = [MesSpSyncManager]::new($connMgr, $procDir)
    $logger = [MesFixbookLogger]::new($docsRoot)

    return @{
        ConnectionManager  = $connMgr
        QueryEngine        = $queryEng
        GoldenQueryEngine  = $goldenEng
        ScreenDebugger     = $screenDbg
        DeployEngine       = $deployEng
        SpSyncManager      = $syncMgr
        FixbookLogger      = $logger
    }
}

Export-ModuleMember -Function Initialize-MesContext
