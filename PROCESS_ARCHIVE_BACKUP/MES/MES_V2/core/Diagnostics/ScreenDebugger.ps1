# ==============================================================================
# ScreenDebugger.ps1 — Screen & Metadata Diagnostic Engine for MES_V2
# ==============================================================================

class MesScreenDebugger {
    [object]$QueryEngine

    MesScreenDebugger([object]$queryEngine) {
        $this.QueryEngine = $queryEngine
    }

    [hashtable] DiagnoseScreen([string]$tcode) {
        $cleanCode = $tcode.Trim().Replace("'", "''")
        $result = @{
            TCode   = $cleanCode
            Screen  = $null
            Objects = $null
        }

        # Query Screen Info from SmartFramework
        $qScreen = "SELECT Name, TCode, Caption, ParentName, CurrentVersion, SystemCode FROM STB_ScreenInfo WITH(NOLOCK) WHERE TCode = '$cleanCode' OR Name = '$cleanCode'"
        $result.Screen = $this.QueryEngine.ExecuteQuery($qScreen, "Framework")

        if ($result.Screen -and $result.Screen.Rows.Count -gt 0) {
            $screenName = $result.Screen.Rows[0].Name
            $qObj = "SELECT Id, ScreenName, ObjectName, ObjectType, Caption, Description FROM STB_ScreenObjects WITH(NOLOCK) WHERE ScreenName = '$screenName'"
            $result.Objects = $this.QueryEngine.ExecuteQuery($qObj, "Framework")
        }

        return $result
    }
}
