Get-ChildItem -Path 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain' -Filter 'transcript.jsonl' -Recurse | 
    Where-Object { $_.LastWriteTime -ge (Get-Date '2026-08-21 00:00:00') } | 
    Select-Object FullName, Length, LastWriteTime | 
    Format-Table -AutoSize
