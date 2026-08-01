param(
    [Parameter(Mandatory=$false)]
    [string]$LogFile,
    [string]$Model = "gemma3:4b",
    [int]$MaxLines = 100
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$OllamaUrl = "http://localhost:11434/api/generate"

function Invoke-OllamaSummarize {
    param([string]$content, [string]$model)

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
Write-Host "Model: $Model" -ForegroundColor Green
Write-Host "Analyzing log..." -ForegroundColor Yellow
Write-Host ""

$result = Invoke-OllamaSummarize -content $logContent -model $Model

Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host "Log Summary" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host $result
Write-Host "------------------------------------" -ForegroundColor DarkGray
