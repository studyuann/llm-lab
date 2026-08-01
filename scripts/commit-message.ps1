param(
    [string]$Model = "gemma3:4b",
    [int]$Count = 3,
    [switch]$Staged,
    [switch]$Conventional
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$OllamaUrl = "http://localhost:11434/api/generate"

function Get-GitDiff {
    if ($Staged) {
        $diff = git diff --cached 2>&1
    } else {
        $diff = git diff HEAD 2>&1
        if (-not $diff) { $diff = git diff --cached 2>&1 }
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Not a git repository or git not installed."
        exit 1
    }
    $lines = $diff -split "`n"
    if ($lines.Count -gt 200) {
        $diff = ($lines | Select-Object -First 200) -join "`n"
        $diff += "`n... (truncated)"
    }
    return $diff
}

function Invoke-OllamaCommit {
    param([string]$diff, [string]$model, [int]$count, [bool]$conventional)

    $formatNote = if ($conventional) {
        "Conventional Commits 형식(feat:, fix:, docs:, refactor:, test:, chore: 등)으로 작성하세요."
    } else {
        "간결하고 명확한 형식으로 작성하세요."
    }

    $instruction = "다음 git diff 변경사항을 분석하여 한국어로 된 커밋 메시지 후보 $count개를 만드세요.`n" + `
                   "$formatNote`n" + `
                   "오직 번호 목록 형태의 커밋 메시지만 출력하고, 서론이나 인사말은 생략하세요."

    $prompt = $instruction + "`n`n--- git diff ---`n" + $diff + "`n--- end diff ---"

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

Write-Host "Checking git changes..." -ForegroundColor Cyan
$diff = Get-GitDiff

if (-not $diff.Trim()) {
    Write-Host "No changes found." -ForegroundColor Yellow
    exit 0
}

$lineCount = ($diff -split "`n").Count
Write-Host "Changed lines: $lineCount" -ForegroundColor Green
Write-Host "Model: $Model" -ForegroundColor Green
Write-Host "Generating commit messages..." -ForegroundColor Yellow
Write-Host ""

$result = Invoke-OllamaCommit -diff $diff -model $Model -count $Count -conventional $Conventional.IsPresent

Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host "Commit Message Candidates" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host $result
Write-Host "------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Tip: git commit -m 'paste one of the above'" -ForegroundColor DarkGray
