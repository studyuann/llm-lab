# start-dashboard.ps1
# llama-server Dashboard Launcher

[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

# 기존 3000 포트 dashboard 프로세스 자동 종료 (EADDRINUSE 방지)
Get-Process node -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*dashboard.js*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "==================================================" -ForegroundColor Green
Write-Host " llama-server Model Switcher Dashboard Starting..." -ForegroundColor Green
Write-Host "   - URL: http://localhost:3000" -ForegroundColor Cyan
Write-Host "   - Action: Select model in top dropdown to switch" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

node "c:\Users\ANN\llm-lab\scripts\dashboard.js"
