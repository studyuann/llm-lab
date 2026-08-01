# start-llama-server.ps1
# llama.cpp (llama-server.exe) GPU 가속 서버 실행 스크립트 (모델 프리셋 지원)

param(
    [ValidateSet("coder-7b", "coder-14b", "deepseek-14b", "qwen3-8b", "gemma3-4b", "custom")]
    [string]$Preset = "coder-7b",

    [string]$ModelFile = "",
    [int]$Port = 8080,
    [int]$GpuLayers = 99,
    [int]$ContextSize = 4096
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$LlamaDir   = "c:\Users\ANN\llm-lab\bin\llama-cpp"
$ServerPath = Join-Path $LlamaDir "llama-server.exe"
$ModelsDir  = "c:\Users\ANN\llm-lab\models"

if (-not (Test-Path $ServerPath)) {
    Write-Error "llama-server.exe를 찾을 수 없습니다. 먼저 .\scripts\install-llama-cpp.ps1을 실행하세요."
    exit 1
}

# 모델 프리셋 정의
$PresetTable = @{
    "coder-7b"     = @{
        fileName = "Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
        gpuNgl   = 99 # 8GB VRAM 100% 가속
        desc     = "Qwen2.5 Coder 7B (코딩 특화 7B 모델, 8GB VRAM 100% 가속)"
    }
    "coder-14b"    = @{
        fileName = "Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen2.5-Coder-14B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf"
        gpuNgl   = 35 # 14B 모델 (GPU VRAM + RAM 오프로딩)
        desc     = "Qwen2.5 Coder 14B (코딩/개발 능력 최상급 14B 모델)"
    }
    "qwen3-8b"     = @{
        fileName = "Qwen3-8B-Q4_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen3-8B-GGUF/resolve/main/Qwen3-8B-Q4_K_M.gguf"
        gpuNgl   = 99
        desc     = "Qwen3 8B (Qwen 3세대 범용 추론 모델)"
    }
    "deepseek-14b" = @{
        fileName = "DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf"
        url      = "https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-14B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf"
        gpuNgl   = 35
        desc     = "DeepSeek-R1 Distill 14B (사고력/Deep Reasoning 특화)"
    }
    "gemma3-4b"    = @{
        fileName = "gemma-3-4b-it-Q4_K_M.gguf"
        url      = "https://huggingface.co/ggml-org/gemma-3-4b-it-GGUF/resolve/main/gemma-3-4b-it-Q4_K_M.gguf"
        gpuNgl   = 99
        desc     = "Gemma 3 4B (Google 초경량 모델)"
    }
}

if ($Preset -ne "custom") {
    $config    = $PresetTable[$Preset]
    $ModelFile = Join-Path $ModelsDir $config.fileName
    $ModelUrl  = $config.url
    $GpuLayers = $config.gpuNgl
    $Desc      = $config.desc
} else {
    $Desc      = "커스텀 모델: $ModelFile"
}

if (-not (Test-Path $ModelsDir)) {
    New-Item -ItemType Directory -Path $ModelsDir -Force | Out-Null
}

if (-not (Test-Path $ModelFile)) {
    if (-not $ModelUrl) {
        Write-Error "모델 파일이 없으며 다운로드 URL이 지정되지 않았습니다: $ModelFile"
        exit 1
    }
    Write-Host "📥 [$Preset] GGUF 모델 다운로드를 시작합니다..." -ForegroundColor Cyan
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

Write-Host "🚀 llama-server (OpenAI 호환 REST API) 실행 중..." -ForegroundColor Green
Write-Host "   📌 모델: $Desc" -ForegroundColor Cyan
Write-Host "   📌 URL: http://127.0.0.1:$Port/v1/chat/completions" -ForegroundColor Cyan
Write-Host "   ⚡ GPU Offload (-ngl): $GpuLayers" -ForegroundColor Yellow
Write-Host "   🧠 컨텍스트 크기: $ContextSize" -ForegroundColor Yellow
Write-Host ""

& $ServerPath -m $ModelFile -ngl $GpuLayers -c $ContextSize --port $Port --host 127.0.0.1
