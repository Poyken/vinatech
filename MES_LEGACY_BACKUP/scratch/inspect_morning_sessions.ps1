$sessions = @('c46fbacd-0132-4001-96ff-cdd8e7f501f6', '85c35ed2-1f66-4976-aa89-4faa09bb8c16', '6bc79fc4-183c-4dcf-ad08-4394dfd7a9ee', '9483e3e6-110d-475b-83ec-e965ab3d7cdb', '18553f55-445d-4cb7-8b7e-7f5b4fc21618')

foreach ($s in $sessions) {
    $path = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\$s\.system_generated\logs\transcript.jsonl"
    if (Test-Path $path) {
        Write-Output "`n=========================================================================="
        Write-Output "SESSION: $s"
        Write-Output "=========================================================================="
        Get-Content $path | ForEach-Object {
            $obj = $_ | ConvertFrom-Json
            if ($obj.type -eq 'USER_INPUT') {
                Write-Output "USER: $($obj.content)"
            }
            if ($obj.tool_calls) {
                foreach ($tc in $obj.tool_calls) {
                    if ($tc.name -eq 'run_command' -and $tc.args.CommandLine -match 'sql') {
                        Write-Output "CMD: $($tc.args.CommandLine)"
                    }
                }
            }
        }
    }
}
