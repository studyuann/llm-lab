# start-llama-server.ps1
# llama.cpp (llama-server.exe) GPU 가속 서버 실행 스크립트 (whichllm 비전 모델 프리셋 포함)

param(
    [ValidateSet("coder-7b", "coder-14b", "vl-8b-thinking", "vl-8b-instruct", "vl-8b", "qwen3-8b", "deepseek-14b", "gemma3-4b", "custom")]
    [string]$Preset = "coder-7b",

    [string]$ModelFile = "",
    [int]$Port = 8080,
    [int]$GpuLayers = 99,
    [int]$ContextSize = 4096,
    [int]$Threads = 8
)

[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

$LlamaDir   = "c:\Users\ANN\llm-lab\bin\llama-cpp"
$ServerPath = Join-Path $LlamaDir "llama-server.exe"
$ModelsDir  = "c:\Users\ANN\llm-lab\models"

if (-not (Test-Path $ServerPath)) {
    Write-Error "llama-server.exe not found. Please run .\scripts\install-llama-cpp.ps1 first."
    exit 1
}

# 모델 프리셋 정의 (Qwen3-VL Thinking & Instruct 세분화)
$PresetTable = @{
    "coder-7b"        = @{
        fileName = "Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
        gpuNgl   = 99
        desc     = "Qwen2.5 Coder 7B (8GB VRAM 100% Full GPU Coding)"
    }
    "coder-14b"       = @{
        fileName = "Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen2.5-Coder-14B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf"
        gpuNgl   = 35
        desc     = "Qwen2.5 Coder 14B (High Intelligence 14B Model)"
    }
    "vl-8b-thinking"  = @{
        fileName = "Qwen3-VL-8B-Thinking-Q5_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen3-VL-8B-Thinking-GGUF/resolve/main/Qwen3-VL-8B-Thinking-Q5_K_M.gguf"
        gpuNgl   = 99
        desc     = "Qwen3 VL 8B Thinking (whichllm #1 Recommended Vision+Thinking, VRAM 7.4GB, Score 60.5)"
    }
    "vl-8b-instruct"  = @{
        fileName = "Qwen3-VL-8B-Instruct-Q5_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen3-VL-8B-Instruct-GGUF/resolve/main/Qwen3-VL-8B-Instruct-Q5_K_M.gguf"
        gpuNgl   = 99
        desc     = "Qwen3 VL 8B Instruct (whichllm #2 Recommended Vision+Text, VRAM 7.4GB, Score 59.9)"
    }
    "vl-8b"           = @{
        fileName = "Qwen3-VL-8B-Thinking-Q5_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen3-VL-8B-Thinking-GGUF/resolve/main/Qwen3-VL-8B-Thinking-Q5_K_M.gguf"
        gpuNgl   = 99
        desc     = "Qwen3 VL 8B Thinking (whichllm #1 Recommended Vision+Thinking)"
    }
    "qwen3-8b"        = @{
        fileName = "Qwen3-8B-Q4_K_M.gguf"
        url      = "https://huggingface.co/bartowski/Qwen3-8B-GGUF/resolve/main/Qwen3-8B-Q4_K_M.gguf"
        gpuNgl   = 99
        desc     = "Qwen3 8B (Qwen 3rd Gen Reasoning Model)"
    }
    "deepseek-14b"    = @{
        fileName = "DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf"
        url      = "https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-14B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf"
        gpuNgl   = 35
        desc     = "DeepSeek-R1 Distill 14B (Deep Reasoning Model)"
    }
    "gemma3-4b"       = @{
        fileName = "gemma-3-4b-it-Q4_K_M.gguf"
        url      = "https://huggingface.co/ggml-org/gemma-3-4b-it-GGUF/resolve/main/gemma-3-4b-it-Q4_K_M.gguf"
        gpuNgl   = 99
        desc     = "Gemma 3 4B (Google Ultra-lightweight Model)"
    }
}

if ($Preset -ne "custom") {
    $config    = $PresetTable[$Preset]
    $ModelFile = Join-Path $ModelsDir $config.fileName
    $ModelUrl  = $config.url
    $GpuLayers = $config.gpuNgl
    $Desc      = $config.desc
} else {
    $Desc      = "Custom Model: $ModelFile"
}

if (-not (Test-Path $ModelsDir)) {
    New-Item -ItemType Directory -Path $ModelsDir -Force | Out-Null
}

if (-not (Test-Path $ModelFile)) {
    if (-not $ModelUrl) {
        Write-Error "Model file missing and no URL provided: $ModelFile"
        exit 1
    }
    Write-Host "Downloading GGUF Model [$Preset]..." -ForegroundColor Cyan
    Write-Host "   URL: $ModelUrl" -ForegroundColor DarkGray
    Write-Host "   Path: $ModelFile" -ForegroundColor DarkGray
    
    try {
        Invoke-WebRequest -Uri $ModelUrl -OutFile $ModelFile -UserAgent "PowerShell"
        Write-Host "Download Complete!" -ForegroundColor Green
    } catch {
        Write-Error "Download Failed: $_"
        exit 1
    }
}

Write-Host "==================================================" -ForegroundColor Green
Write-Host " llama-server (OpenAI REST API) Running..." -ForegroundColor Green
Write-Host "   - Model: $Desc" -ForegroundColor Cyan
Write-Host "   - URL: http://127.0.0.1:$Port/v1/chat/completions" -ForegroundColor Cyan
Write-Host "   - GPU Offload (-ngl): $GpuLayers (Flash Attention: Enabled)" -ForegroundColor Yellow
Write-Host "   - Context Size: $ContextSize | Threads: $Threads" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

& $ServerPath -m $ModelFile -ngl $GpuLayers -c $ContextSize -t $Threads -fa on --port $Port --host 127.0.0.1
