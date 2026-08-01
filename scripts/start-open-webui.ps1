# start-open-webui.ps1
# Open WebUI (llama-server 8080 포트 고속 엔진 + Ollama 드롭다운 통합 연동)

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
Write-Host "   - Backend 1 (llama-server): http://127.0.0.1:8080/v1" -ForegroundColor Yellow
Write-Host "   - Backend 2 (Ollama):       http://127.0.0.1:11434" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

# Open WebUI 연동 환경변수
$env:PORT = "$Port"
$env:WEBUI_PORT = "$Port"

# Ollama 백엔드
$env:OLLAMA_BASE_URL = "http://127.0.0.1:11434"
$env:ENABLE_OLLAMA_API = "true"

# OpenAI 백엔드 (llama-server 8080 포트)
$env:ENABLE_OPENAI_API = "true"
$env:OPENAI_API_BASE_URL = "http://127.0.0.1:8080/v1"
$env:OPENAI_API_BASE_URLS = "http://127.0.0.1:8080/v1"
$env:OPENAI_API_KEY = "sk-no-key-required"
$env:OPENAI_API_KEYS = "sk-no-key-required"

conda run -n open-webui open-webui serve --port $Port
