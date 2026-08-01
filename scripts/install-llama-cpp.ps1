# install-llama-cpp.ps1
# llama.cpp (CUDA 가속 바이너리 + llama-server.exe) 다운로드 스크립트

param(
    [string]$InstallDir = "c:\Users\ANN\llm-lab\bin\llama-cpp",
    [string]$Tag = "b10217"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$binUrl    = "https://github.com/ggml-org/llama.cpp/releases/download/$Tag/llama-$Tag-bin-win-cuda-12.4-x64.zip"
$cudartUrl = "https://github.com/ggml-org/llama.cpp/releases/download/$Tag/cudart-llama-bin-win-cuda-12.4-x64.zip"

$binZip    = Join-Path $InstallDir "llama-bin.zip"
$cudartZip = Join-Path $InstallDir "cudart.zip"

Write-Host "📥 llama.cpp 바이너리 및 CUDA 12.4 런타임 다운로드 중..." -ForegroundColor Cyan

try {
    Write-Host "1/2 Executables ($Tag)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $binUrl -OutFile $binZip -UserAgent "PowerShell"
    
    Write-Host "2/2 CUDA Runtimes ($Tag)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $cudartUrl -OutFile $cudartZip -UserAgent "PowerShell"
    
    Write-Host "📦 압축 해제 중..." -ForegroundColor Yellow
    Expand-Archive -Path $binZip -DestinationPath $InstallDir -Force
    Expand-Archive -Path $cudartZip -DestinationPath $InstallDir -Force

    Remove-Item $binZip, $cudartZip -Force -ErrorAction SilentlyContinue

    Write-Host "✅ llama.cpp 설치 완료!" -ForegroundColor Green
    Write-Host "📂 바이너리 목록:" -ForegroundColor Cyan
    Get-ChildItem $InstallDir -Filter "*.exe" | Select-Object Name
} catch {
    Write-Error "설치 중 오류 발생: $_"
    exit 1
}
