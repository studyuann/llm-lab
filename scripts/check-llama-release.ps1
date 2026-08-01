param()

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$apiUrl = "https://api.github.com/repos/ggml-org/llama.cpp/releases/latest"
$headers = @{ "User-Agent" = "PowerShell" }

try {
    $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    Write-Host "Latest Release Tag: $($release.tag_name)" -ForegroundColor Green

    # Find CUDA 12 / Vulkan / x64 Windows zip
    $winAssets = $release.assets | Where-Object { $_.name -like "*bin-win-cuda*x64*.zip" -or $_.name -like "*bin-win-vulkan*x64*.zip" -or $_.name -like "*bin-win-avx2*x64*.zip" }

    Write-Host "Found Assets:" -ForegroundColor Yellow
    foreach ($asset in $winAssets) {
        Write-Host " - $($asset.name) ($([math]::Round($asset.size / 1MB, 1)) MB)"
        Write-Host "   URL: $($asset.browser_download_url)"
    }
} catch {
    Write-Error "Failed to fetch releases: $_"
}
