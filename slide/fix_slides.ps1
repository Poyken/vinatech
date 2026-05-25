$slidesDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\slide\extracted\ppt\slides"

function Replace-InFile {
    param(
        [string]$Filename,
        [string]$OldText,
        [string]$NewText
    )
    $FilePath = Join-Path -Path $slidesDir -ChildPath $Filename
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $content = $content.Replace($OldText, $NewText)
    Set-Content -Path $FilePath -Value $content -Encoding UTF8
    Write-Host "Updated $Filename"
}

# Slide 4
Replace-InFile -Filename "slide4.xml" -OldText "Inspect kiosks and remove suspected un-licensed/unauthorized software." -NewText "Inspect kiosks and remove unnecessary or conflicting software."
Replace-InFile -Filename "slide4.xml" -OldText "Scanned all kiosk systems to identify unauthorized applications." -NewText "Scanned all kiosk systems to identify conflicting software such as eGalaxTouch Driver."

# Slide 6
Replace-InFile -Filename "slide6.xml" -OldText "Detected GX Works p2 and GX Works p1 software requiring valid licenses." -NewText "Detected GX Works 2, GX Works 3, GX Developer, and MR Configurator2 software requiring valid licenses."

# Slide 7
Replace-InFile -Filename "slide7.xml" -OldText "Detected MR Config2 software requiring a license and proceeded to remove it." -NewText ""
Replace-InFile -Filename "slide7.xml" -OldText " Control software requiring a license and proceeded to remove it." -NewText " Control FPWIN GR7S and PIDSX PLC USB-COM software requiring a license and proceeded to remove them."

# Slide 8
Replace-InFile -Filename "slide8.xml" -OldText "Detected GX Works p2, GX Works p1, and Simple Motion software requiring valid licenses." -NewText "Detected GP-Pro EX (versions 4.08, 4.09) and CodeMeter Runtime Kit software requiring valid licenses."

# Slide 11
Replace-InFile -Filename "slide11.xml" -OldText "Segregated warehouse management logic in the system into Raw Material (NVL) warehouse and Finished Goods warehouse databases." -NewText "Updated the Temperature &amp; Humidity Monitoring System to include data filtering by Raw Material (NVL) and Finished Goods warehouse areas."

Write-Host "Text replacement completed."

# Re-zip to pptx
$sourceDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\slide\extracted\*"
$destinationArchive = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\slide\Weekend Overtime Work Report 2026-05-23_Fixed.zip"
$destinationPptx = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\slide\Weekend Overtime Work Report 2026-05-23_Fixed.pptx"

if (Test-Path $destinationArchive) { Remove-Item $destinationArchive -Force }
if (Test-Path $destinationPptx) { Remove-Item $destinationPptx -Force }

Compress-Archive -Path $sourceDir -DestinationPath $destinationArchive -Force
Rename-Item -Path $destinationArchive -NewName "Weekend Overtime Work Report 2026-05-23_Fixed.pptx" -Force
Write-Host "Created Fixed PPTX file."
