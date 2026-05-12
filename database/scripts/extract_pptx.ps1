$dir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\GROUPWARE"
$outputFile = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\GROUPWARE\extracted_text.txt"
$powerPoint = New-Object -ComObject PowerPoint.Application
# Skip Visible setting to avoid error

Clear-Content $outputFile -ErrorAction SilentlyContinue

Get-ChildItem -Path $dir -Filter *.pptx | ForEach-Object {
    $presentation = $powerPoint.Presentations.Open($_.FullName, $true, $false, $false)
    Write-Output "File: $($_.Name)" | Out-File -Append -FilePath $outputFile
    foreach ($slide in $presentation.Slides) {
        foreach ($shape in $slide.Shapes) {
            if ($shape.HasTextFrame -and $shape.TextFrame.HasText) {
                $text = $shape.TextFrame.TextRange.Text
                Write-Output $text | Out-File -Append -FilePath $outputFile
            }
        }
    }
    $presentation.Close()
    Write-Output "------------------------" | Out-File -Append -FilePath $outputFile
}

$powerPoint.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($powerPoint) | Out-Null
Write-Host "Extraction completed."
