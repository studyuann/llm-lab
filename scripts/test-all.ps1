param()

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== Testing log-summarize.ps1 with gemma3:4b ===" -ForegroundColor Green
powershell -ExecutionPolicy Bypass -File .\scripts\log-summarize.ps1 -LogFile .\samples\sample-error.log -Model "gemma3:4b"

Write-Host "`n=== Testing log-summarize.ps1 with qwen3:8b ===" -ForegroundColor Green
powershell -ExecutionPolicy Bypass -File .\scripts\log-summarize.ps1 -LogFile .\samples\sample-error.log -Model "qwen3:8b"
