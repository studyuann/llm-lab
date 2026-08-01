# start-dashboard.ps1
# llama-server Dashboard Launcher

[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

Write-Host "==================================================" -ForegroundColor Green
Write-Host " llama-server 원클릭 웹 스위처 대시보드 실행..." -ForegroundColor Green
Write-Host "   - 접속 주소: http://localhost:3000" -ForegroundColor Cyan
Write-Host "   - 기능: 웹 상단 드롭다운 클릭 시 백그라운드 자동 서버 재가동" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

node "c:\Users\ANN\llm-lab\scripts\dashboard.js"
