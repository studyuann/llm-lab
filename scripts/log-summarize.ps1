# log-summarize.ps1
# 서버 로그를 분석하는 스크립트 (llama.cpp 및 Ollama 호환)
# 사용법: .\scripts\log-summarize.ps1 -LogFile .\samples\sample-error.log

param(
    [Parameter(Mandatory=$false)]
    [string]$LogFile,
    [string]$Backend = "llamacpp", # llamacpp 또는 ollama
    [string]$Model = "gemma3:4b",  # ollama 사용 시 모델명
    [int]$MaxLines = 100
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Invoke-LlamaCppSummarize {
    param([string]$content)
    $url = "http://127.0.0.1:8080/v1/chat/completions"
    $instruction = "다음 서버 로그를 분석하여 오류의 근본 원인을 오직 한국어로만 요약해 설명해 주세요.`n" + `
                   "- 확정된 사실과 추측을 구분하세요.`n" + `
                   "- 10줄 이내로 간결하게 작성하세요.`n" + `
                   "- 영어나 사설 없이 오직 한국어 요약 결과만 출력하세요."

    $bodyObj = @{
        messages = @(
            @{ role = "system"; content = $instruction },
            @{ role = "user";   content = $content }
        )
        temperature = 0.2
        max_tokens  = 1024
    }

    $jsonStr   = $bodyObj | ConvertTo-Json -Depth 5
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonStr)

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $bodyBytes -ContentType "application/json; charset=utf-8" -TimeoutSec 180
        return $response.choices[0].message.content
    } catch {
        Write-Error "llama.cpp 서버 연결 실패: $_"
        Write-Error "llama-server가 실행 중인지 확인하세요: .\scripts\start-llama-server.ps1"
        exit 1
    }
}

function Invoke-OllamaSummarize {
    param([string]$content, [string]$model)
    $url = "http://localhost:11434/api/generate"
    $instruction = "다음 서버 로그를 분석하여 오류의 근본 원인을 오직 한국어로만 요약해 설명해 주세요.`n" + `
                   "- 확정된 사실과 추측을 구분하세요.`n" + `
                   "- 10줄 이내로 간결하게 작성하세요.`n" + `
                   "- 영어나 사설 없이 오직 한국어 요약 결과만 출력하세요."

    $prompt = $instruction + "`n`n--- 로그 시작 ---`n" + $content + "`n--- 로그 끝 ---"

    $body = @{
        model   = $model
        prompt  = $prompt
        stream  = $false
        options = @{
            temperature = 0.2
            num_predict = 512
        }
    } | ConvertTo-Json -Depth 3

    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $bodyBytes -ContentType "application/json; charset=utf-8" -TimeoutSec 180
        return $response.response
    } catch {
        Write-Error "Ollama 연결 실패: $_"
        exit 1
    }
}

if ($LogFile -and (Test-Path $LogFile)) {
    Write-Host "Reading log: $LogFile" -ForegroundColor Cyan
    $logContent = Get-Content $LogFile -Tail $MaxLines -Encoding UTF8 | Out-String
} else {
    Write-Error "File not found: $LogFile"
    exit 1
}

if (-not $logContent.Trim()) {
    Write-Error "Log file is empty."
    exit 1
}

Write-Host ""
Write-Host "Backend: $Backend" -ForegroundColor Green
Write-Host "Analyzing log..." -ForegroundColor Yellow
Write-Host ""

if ($Backend -eq "llamacpp") {
    $result = Invoke-LlamaCppSummarize -content $logContent
} else {
    $result = Invoke-OllamaSummarize -content $logContent -model $Model
}

Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host "Log Summary [$Backend]" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host $result
Write-Host "------------------------------------" -ForegroundColor DarkGray
