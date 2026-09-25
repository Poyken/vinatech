# ==============================================================================
# FixbookLogger.ps1 — Automated Hotfix & Playbook Audit Logger for MES_V2
# ==============================================================================

class MesFixbookLogger {
    [string]$DocsRoot

    MesFixbookLogger([string]$docsRoot) {
        $this.DocsRoot = $docsRoot
    }

    [void] RecordFix([string]$tcode, [string]$symptom, [string]$cause, [string]$patch) {
        $dateStr = (Get-Date).ToString("yyyy-MM-dd")
        $logPath = Join-Path $this.DocsRoot "troubleshooting\hotfix_registry.md"
        $playbookPath = Join-Path $this.DocsRoot "troubleshooting\bug_playbook.md"

        $fence = '```'
        $sb = New-Object System.Text.StringBuilder
        $null = $sb.AppendLine('')
        $null = $sb.AppendLine('### [' + $tcode + '] - ' + $symptom)
        $null = $sb.AppendLine('- Date: ' + $dateStr)
        $null = $sb.AppendLine('- TCode: ' + $tcode)
        $null = $sb.AppendLine('- Symptom: ' + $symptom)
        $null = $sb.AppendLine('- Root Cause: ' + $cause)
        $null = $sb.AppendLine('- SQL Fix:')
        $null = $sb.AppendLine($fence + 'sql')
        $null = $sb.AppendLine($patch)
        $null = $sb.AppendLine($fence)
        $null = $sb.AppendLine('')

        $entry = $sb.ToString()

        if (Test-Path $logPath) {
            [System.IO.File]::AppendAllText($logPath, $entry, [System.Text.Encoding]::UTF8)
        }

        if (Test-Path $playbookPath) {
            [System.IO.File]::AppendAllText($playbookPath, $entry, [System.Text.Encoding]::UTF8)
        }
    }
}
