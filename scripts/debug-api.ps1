param()
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$url = "http://localhost:11434/api/generate"

$bodyObj = @{
    model   = "gemma3:4b"
    prompt  = "다음 문서 내용을 바탕으로 한국어 제목 후보 5개를 추천해주세요.`n1. 제목 1`n2. 제목 2`n`n--- 문서 시작 ---`n로컬 LLM 실전 활용기`n--- 문서 끝 ---"
    stream  = $false
}

$jsonStr   = $bodyObj | ConvertTo-Json
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonStr)

try {
    $response = Invoke-RestMethod `
        -Uri $url `
        -Method Post `
        -Body $bodyBytes `
        -ContentType "application/json; charset=utf-8" `
        -TimeoutSec 120

    Write-Host "=== RESPONSE ==="
    Write-Host $response.response
    Write-Host "=== DONE ==="
} catch {
    Write-Host "ERROR: $_"
}
