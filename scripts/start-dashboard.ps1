# start-dashboard.ps1
# llama-server Dashboard Launcher

[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

Write-Host "==================================================" -ForegroundColor Green
Write-Host " llama-server Model Switcher Dashboard Starting..." -ForegroundColor Green
Write-Host "   - URL: http://localhost:3000" -ForegroundColor Cyan
Write-Host "   - Action: Select model in top dropdown to switch" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

node "c:\Users\ANN\llm-lab\scripts\dashboard.js"
