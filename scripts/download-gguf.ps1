# download-gguf.ps1
# Hugging Face에서 llama.cpp용 GGUF 모델을 다운로드하는 스크립트

param(
    [string]$ModelDir = "c:\Users\ANN\llm-lab\models",
    [string]$Url = "https://huggingface.co/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf",
    [string]$FileName = "Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $ModelDir)) {
    New-Item -ItemType Directory -Path $ModelDir -Force | Out-Null
}

$destPath = Join-Path $ModelDir $FileName

if (Test-Path $destPath) {
    Write-Host "✅ GGUF 모델 파일이 이미 존재합니다: $destPath" -ForegroundColor Green
    exit 0
}

Write-Host "📥 GGUF 모델 다운로드 시작: $FileName" -ForegroundColor Cyan
Write-Host "   URL: $Url" -ForegroundColor DarkGray
Write-Host "   저장 경로: $destPath" -ForegroundColor DarkGray

try {
    Invoke-WebRequest -Uri $Url -OutFile $destPath -UserAgent "PowerShell"
    Write-Host "✅ 다운로드 완료!" -ForegroundColor Green
} catch {
    Write-Error "다운로드 실패: $_"
    exit 1
}
