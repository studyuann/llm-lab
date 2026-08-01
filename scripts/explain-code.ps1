param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath,
    [string]$Model = "gemma3:4b",
    [string]$Lang = "auto"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$OllamaUrl = "http://localhost:11434/api/generate"

function Invoke-OllamaExplain {
    param([string]$code, [string]$model, [string]$lang)

    $langHint = if ($lang -ne "auto") { " (언어: $lang)" } else { "" }

    $instruction = "다음 코드가 어떤 역할을 하는지 오직 한국어로만 설명해주세요.$langHint`n" + `
                   "구성:`n" + `
                   "1. 입력 매개변수`n" + `
                   "2. 주요 처리 과정`n" + `
                   "3. 반환값`n" + `
                   "4. 개선할 수 있는 부분 및 주의사항`n" + `
                   "영어 설명이나 사설 없이 100% 한국어로만 답변하세요."

    $prompt = $instruction + "`n`n--- 코드 시작 ---`n" + $code + "`n--- 코드 끝 ---"

    $body = @{
        model   = $model
        prompt  = $prompt
        stream  = $false
        options = @{
            temperature = 0.2
            num_predict = 1024
            top_p       = 0.9
        }
    } | ConvertTo-Json -Depth 3

    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

    try {
        $response = Invoke-RestMethod -Uri $OllamaUrl -Method Post -Body $bodyBytes -ContentType "application/json; charset=utf-8" -TimeoutSec 180
        return $response.response
    } catch {
        Write-Error "Ollama error: $_"
        exit 1
    }
}

if ($FilePath -and (Test-Path $FilePath)) {
    Write-Host "Reading: $FilePath" -ForegroundColor Cyan
    $code = Get-Content $FilePath -Raw -Encoding UTF8
    if ($Lang -eq "auto") {
        $Lang = [System.IO.Path]::GetExtension($FilePath).TrimStart('.')
    }
} else {
    Write-Error "File not found: $FilePath"
    exit 1
}

if (-not $code.Trim()) {
    Write-Error "File is empty."
    exit 1
}

Write-Host "Model: $Model  |  Lang: $Lang" -ForegroundColor Green
Write-Host "Analyzing code..." -ForegroundColor Yellow
Write-Host ""

$result = Invoke-OllamaExplain -code $code -model $Model -lang $Lang

Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host "Code Explanation" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host $result
Write-Host "------------------------------------" -ForegroundColor DarkGray
