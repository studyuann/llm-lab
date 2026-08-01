# start-open-webui.ps1
# Open WebUI (웹 드롭다운 모델 선택 UI) 실행 스크립트

param(
    [int]$Port = 3000
)

# Windows PowerShell 인코딩 최적화
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

Write-Host "==================================================" -ForegroundColor Green
Write-Host " Open WebUI Server Starting..." -ForegroundColor Green
Write-Host "   - URL: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "   - Features: Select models via top dropdown" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

# Open WebUI 포트 지정 (8080 충돌 방지 -> 3000 포트)
$env:PORT = "$Port"
$env:WEBUI_PORT = "$Port"
$env:OLLAMA_BASE_URL = "http://127.0.0.1:11434"
$env:OPENAI_API_BASE_URL = "http://127.0.0.1:8080/v1"

conda run -n open-webui open-webui serve --port $Port
