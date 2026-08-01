# start-open-webui.ps1
# Open WebUI (웹 드롭다운에서 모델 자유롭게 클릭 전환) 실행 스크립트

param(
    [int]$Port = 3000
)

[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

Write-Host "==================================================" -ForegroundColor Green
Write-Host " Open WebUI (웹 드롭다운 모델 선택 UI) 실행 중..." -ForegroundColor Green
Write-Host "   - 접속 주소: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "   - 기능: 상단 드롭다운 클릭으로 모델 자동 교체" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

# 백엔드 연결 설정
$env:OLLAMA_BASE_URL = "http://127.0.0.1:11434"
$env:PORT = $Port

conda run -n open-webui open-webui serve
