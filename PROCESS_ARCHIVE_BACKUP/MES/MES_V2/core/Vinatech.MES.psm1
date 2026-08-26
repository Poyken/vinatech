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
    if ([string]::IsNullOrEmpty($configPath)) {
        $configPath = Join-Path (Split-Path $moduleRoot -Parent) "config\db.config.json"
    }
    $connMgr = [MesConnectionManager]::new($configPath)
    $queryEng = [MesQueryEngine]::new($connMgr)
    $goldenEng = [MesGoldenQueryEngine]::new($queryEng)
    $screenDbg = [MesScreenDebugger]::new($queryEng)
    $deployEng = [MesDeployEngine]::new($connMgr)
    $procDir = Join-Path (Split-Path $moduleRoot -Parent) "sql\procedures"
    $docsRoot = Join-Path (Split-Path $moduleRoot -Parent) "docs"
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
