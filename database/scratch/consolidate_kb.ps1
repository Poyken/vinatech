$folder = '.\MES_MASTER_KNOWLEDGE_BASE'
if (-not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }

$files = @(
    '.\ZALO_MES_MASTER_TASKS.md',
    '.\Vinatech_MES_Complete_DataFlow.md',
    '.\MES_COMMON_ERRORS_KNOWLEDGE.md',
    '.\Document\Lỗi trên NAIS System_Tái bản.docx',
    '.\Document\Một số lỗi Nais System.docx',
    '.\Document\Bật tắt thành phẩm và nvl.docx'
)

foreach ($f in $files) {
    if (Test-Path $f) {
        Move-Item -Path $f -Destination $folder -Force
        Write-Host "Moved $f to $folder"
    } else {
        Write-Host "File $f not found"
    }
}
