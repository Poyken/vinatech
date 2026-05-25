$slidesDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\slide\extracted\ppt\slides"
$relsDir = "$slidesDir\_rels"

1..11 | ForEach-Object {
    $i = $_
    $slidePath = "$slidesDir\slide$i.xml"
    $relsPath = "$relsDir\slide${i}.xml.rels"
    
    if (Test-Path $slidePath) {
        Write-Host "--- Slide $i ---"
        
        # Extract text using regex because [xml] sometimes fails with namespaces in powershell
        $content = Get-Content $slidePath -Raw
        $text = [regex]::Matches($content, '<a:t>(.*?)</a:t>') | ForEach-Object { $_.Groups[1].Value }
        Write-Host "Text:"
        Write-Host ($text -join "`n")
        
        # Extract image rels using regex
        if (Test-Path $relsPath) {
            $relsContent = Get-Content $relsPath -Raw
            $images = [regex]::Matches($relsContent, 'Target="\.\./media/(.*?)"') | ForEach-Object { $_.Groups[1].Value }
            Write-Host "Images:"
            Write-Host ($images -join ", ")
        }
        Write-Host ""
    }
}
