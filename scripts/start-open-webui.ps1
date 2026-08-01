# start-open-webui.ps1
# Open WebUI (llama-server 8080 포트 초고속 전용 연동 스크립트)

param(
    [int]$Port = 3000
)

# Windows PowerShell 인코딩 최적화
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

Write-Host "==================================================" -ForegroundColor Green
Write-Host " Open WebUI Server Starting (llama-server 전용)..." -ForegroundColor Green
Write-Host "   - URL: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "   - Backend: llama-server (http://127.0.0.1:8080/v1 - Flash-Attn FAST)" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

# Open WebUI 포트 지정
$env:PORT = "$Port"
$env:WEBUI_PORT = "$Port"

# 느린 Ollama 백엔드 비활성화
$env:ENABLE_OLLAMA_API = "false"
$env:OLLAMA_BASE_URL = ""

# llama-server (8080 포트 Flash-Attn 전용 백엔드 활성화)
$env:ENABLE_OPENAI_API = "true"
$env:OPENAI_API_BASE_URL = "http://127.0.0.1:8080/v1"
$env:OPENAI_API_BASE_URLS = "http://127.0.0.1:8080/v1"
$env:OPENAI_API_KEY = "sk-no-key-required"
$env:OPENAI_API_KEYS = "sk-no-key-required"

conda run -n open-webui open-webui serve --port $Port
