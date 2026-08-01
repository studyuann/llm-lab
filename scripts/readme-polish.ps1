# readme-polish.ps1
# README 및 문서 가공 스크립트 (llama.cpp 및 Ollama 호환)
# 사용법: .\scripts\readme-polish.ps1 -FilePath .\README.md -Mode titles

param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath,
    [string]$Backend = "llamacpp",
    [string]$Model = "gemma3:4b",
    [ValidateSet("polish", "titles", "summary")]
    [string]$Mode = "polish",
    [int]$TitleCount = 5
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Invoke-LlamaCppDoc {
    param([string]$content, [string]$mode, [int]$count)
    $url = "http://127.0.0.1:8080/v1/chat/completions"

    if ($mode -eq "polish") {
        $instruction = "다음 문서의 문장을 한국어로 더 자연스럽고 명확하게 다듬어주세요. 원래 의미와 마크다운 형식을 유지하고, 다듬어진 본문만 답변하세요."
    } elseif ($mode -eq "titles") {
        $instruction = "다음 문서 내용을 바탕으로 한국어 제목 후보 $count개를 추천해주세요. 서론이나 설명 없이 오직 한국어 번호 목록만 출력하세요.`n1. 제목 1`n2. 제목 2"
    } else {
        $instruction = "다음 문서의 핵심 내용을 한국어 불렛포인트(•) 3~5개로 요약해 주세요. 표(table)나 특수문자 반복 없이 오직 간결한 요약 문장만 출력하세요."
    }

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
        exit 1
    }
}

function Invoke-OllamaDoc {
    param([string]$content, [string]$model, [string]$mode, [int]$count)
    $url = "http://localhost:11434/api/generate"

    if ($mode -eq "polish") {
        $instruction = "다음 문서의 문장을 한국어로 더 자연스럽고 명확하게 다듬어주세요. 원래 의미와 마크다운 형식을 유지하고, 다듬어진 본문만 답변하세요."
    } elseif ($mode -eq "titles") {
        $instruction = "다음 문서 내용을 바탕으로 한국어 제목 후보 $count개를 추천해주세요. 서론이나 설명 없이 오직 한국어 번호 목록만 출력하세요.`n1. 제목 1`n2. 제목 2"
    } else {
        $instruction = "다음 문서의 핵심 내용을 한국어 불렛포인트(•) 3~5개로 요약해 주세요. 표(table)나 특수문자 반복 없이 오직 간결한 요약 문장만 출력하세요."
    }

    $prompt = $instruction + "`n`n--- 문서 시작 ---`n" + $content + "`n--- 문서 끝 ---"

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
        Write-Error "Ollama error: $_"
        exit 1
    }
}

if ($FilePath -and (Test-Path $FilePath)) {
    Write-Host "Reading: $FilePath" -ForegroundColor Cyan
    $content = Get-Content $FilePath -Raw -Encoding UTF8
} else {
    Write-Error "File not found: $FilePath"
    exit 1
}

if (-not $content.Trim()) {
    Write-Error "File is empty."
    exit 1
}

Write-Host "Backend: $Backend  |  Mode: $Mode" -ForegroundColor Green
Write-Host "Processing..." -ForegroundColor Yellow
Write-Host ""

if ($Backend -eq "llamacpp") {
    $result = Invoke-LlamaCppDoc -content $content -mode $Mode -count $TitleCount
} else {
    $result = Invoke-OllamaDoc -content $content -model $Model -mode $Mode -count $TitleCount
}

Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host "Result [$Mode / $Backend]" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host $result
Write-Host "------------------------------------" -ForegroundColor DarkGray
