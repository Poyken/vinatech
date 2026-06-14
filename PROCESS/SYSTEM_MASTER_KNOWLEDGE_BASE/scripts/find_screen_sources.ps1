# Find which KB files mention each missing screen
$missing = @(
    "A210","A320","A410","A418","A419","A460",
    "B220","B230","B240","B270","B301","B450","B453","B460","B470","B525","B528","B540",
    "B726","B733","B755","B756","B758","B767","B781","B782","B786","B789","B791","B882","B934","B935",
    "C112","C122","C131","C132","C141","C143","C151","C153","C243","C430","C451","C460","C510","C522","C530","C540","C541","C546","C560","C562","C563","C564",
    "D000","D051","D100","D110",
    "F140","F312","F320","F610","F620","F710","F740","F744","F746","F747","F748",
    "H302","H303","H304","H305",
    "K109","K110",
    "P111",
    "Z110","Z210","Z220","Z330"
)

$kbFiles = Get-ChildItem -Path "." -Filter "KB_*.md" | Where-Object { $_.Name -ne "KB_SCREEN_BUG_REF.md" }

foreach ($screen in $missing) {
    $foundIn = @()
    foreach ($file in $kbFiles) {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        if ($content -match "\b$screen\b") {
            $foundIn += $file.Name
        }
    }
    Write-Host "$screen => $($foundIn -join ', ')"
}
