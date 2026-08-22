$path = 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\c46fbacd-0132-4001-96ff-cdd8e7f501f6\.system_generated\logs\transcript.jsonl'
Get-Content $path | ForEach-Object {
    $obj = $_ | ConvertFrom-Json
    if ($obj.type -eq 'USER_INPUT') { Write-Output "USER: $($obj.content)" }
    if ($obj.tool_calls) {
        foreach ($tc in $obj.tool_calls) {
            Write-Output "TOOL: $($tc.name) -> $($tc.args.CommandLine)"
        }
    }
}
