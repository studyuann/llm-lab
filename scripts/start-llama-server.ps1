# start-llama-server.ps1
# llama.cpp (llama-server.exe) GPU 가속 서버 실행 스크립트

param(
    [string]$ModelFile = "c:\Users\ANN\llm-lab\models\Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf",
    [string]$ModelUrl  = "https://huggingface.co/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf",
    [int]$Port = 8080,
    [int]$GpuLayers = 99,
    [int]$ContextSize = 4096
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$LlamaDir   = "c:\Users\ANN\llm-lab\bin\llama-cpp"
$ServerPath = Join-Path $LlamaDir "llama-server.exe"
$ModelDir   = Split-Path $ModelFile

if (-not (Test-Path $ServerPath)) {
    Write-Error "llama-server.exe를 찾을 수 없습니다. 먼저 .\scripts\install-llama-cpp.ps1을 실행하세요."
    exit 1
}

# 모델 폴더 생성 및 모델 다운로드 확인
if (-not (Test-Path $ModelDir)) {
    New-Item -ItemType Directory -Path $ModelDir -Force | Out-Null
}

if (-not (Test-Path $ModelFile)) {
    Write-Host "📥 GGUF 모델 파일이 없습니다. 다운로드를 시작합니다..." -ForegroundColor Cyan
    Write-Host "   URL: $ModelUrl" -ForegroundColor DarkGray
    Write-Host "   파일: $ModelFile" -ForegroundColor DarkGray
    
    try {
        Invoke-WebRequest -Uri $ModelUrl -OutFile $ModelFile -UserAgent "PowerShell"
        Write-Host "✅ 모델 다운로드 완료!" -ForegroundColor Green
    } catch {
        Write-Error "모델 다운로드 실패: $_"
        exit 1
    }
}

Write-Host "🚀 llama-server (OpenAI API 호환 서버) 시작 중..." -ForegroundColor Green
Write-Host "   📌 포트: http://127.0.0.1:$Port/v1/chat/completions" -ForegroundColor Cyan
Write-Host "   ⚡ GPU 레이어: $GpuLayers (NVIDIA RTX 5060 100% 가속)" -ForegroundColor Yellow
Write-Host "   🧠 컨텍스트 크기: $ContextSize" -ForegroundColor Yellow
Write-Host ""

# llama-server.exe 실행
& $ServerPath -m $ModelFile -ngl $GpuLayers -c $ContextSize --port $Port --host 127.0.0.1
