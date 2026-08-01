# explain-code.ps1
# 코드 파일이나 함수를 설명하는 스크립트 (llama.cpp 및 Ollama 호환)
# 사용법: .\scripts\explain-code.ps1 -FilePath .\samples\sample-function.ts

param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath,
    [string]$Backend = "llamacpp",
    [string]$Model = "gemma3:4b",
    [string]$Lang = "auto"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Invoke-LlamaCppExplain {
    param([string]$code, [string]$lang)
    $url = "http://127.0.0.1:8080/v1/chat/completions"
    $langHint = if ($lang -ne "auto") { " (언어: $lang)" } else { "" }

    $instruction = "다음 코드가 어떤 역할을 하는지 오직 한국어로만 설명해주세요.$langHint`n" + `
                   "구성:`n" + `
                   "1. 입력 매개변수`n" + `
                   "2. 주요 처리 과정`n" + `
                   "3. 반환값`n" + `
                   "4. 개선할 수 있는 부분 및 주의사항`n" + `
                   "영어 설명이나 사설 없이 100% 한국어로만 답변하세요."

    $bodyObj = @{
        messages = @(
            @{ role = "system"; content = $instruction },
            @{ role = "user";   content = $code }
        )
        temperature = 0.2
        max_tokens  = 1500
    }

    $jsonStr   = $bodyObj | ConvertTo-Json -Depth 5
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonStr)

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $bodyBytes -ContentType "application/json; charset=utf-8" -TimeoutSec 180
        return $response.choices[0].message.content
    } catch {
        Write-Error "llama.cpp 서버 연결 실패: $_"
        exit 1
    }
}

function Invoke-OllamaExplain {
    param([string]$code, [string]$model, [string]$lang)
    $url = "http://localhost:11434/api/generate"
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
        }
    } | ConvertTo-Json -Depth 3

    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $bodyBytes -ContentType "application/json; charset=utf-8" -TimeoutSec 180
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

Write-Host "Backend: $Backend  |  Lang: $Lang" -ForegroundColor Green
Write-Host "Analyzing code..." -ForegroundColor Yellow
Write-Host ""

if ($Backend -eq "llamacpp") {
    $result = Invoke-LlamaCppExplain -code $code -lang $Lang
} else {
    $result = Invoke-OllamaExplain -code $code -model $Model -lang $Lang
}

Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host "Code Explanation [$Backend]" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host $result
Write-Host "------------------------------------" -ForegroundColor DarkGray
