// scripts/dashboard.js
// llama-server (Flash-Attn 2배속) 전용 원클릭 모델 스위처 웹 컨트롤 패널

const http = require('http');
const { spawn, execSync } = require('child_process');
const path = path = require('path');
const fs = require('fs');

const PORT = 3000;
const LLAMA_PORT = 8080;
const MODELS_DIR = 'c:\\Users\\ANN\\llm-lab\\models';
const LLAMA_EXE = 'c:\\Users\\ANN\\llm-lab\\bin\\llama-cpp\\llama-server.exe';

let currentServerProcess = null;
let currentPreset = 'coder-7b';

const PRESETS = {
  'coder-7b': {
    name: 'Qwen2.5-Coder 7B (코딩 특화, 8GB VRAM 100% 초고속 추천)',
    fileNameCandidates: ['Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf'],
    url: 'https://huggingface.co/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf',
    gpuNgl: 99
  },
  'coder-14b': {
    name: 'Qwen2.5-Coder 14B (코딩/개발 능력 최상급 14B 모델)',
    fileNameCandidates: ['Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf'],
    url: 'https://huggingface.co/bartowski/Qwen2.5-Coder-14B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf',
    gpuNgl: 35
  },
  'vl-8b-thinking': {
    name: 'Qwen3-VL 8B Thinking (whichllm #1 추천 비전+추론, Score 60.5)',
    fileNameCandidates: ['Qwen3VL-8B-Thinking-Q4_K_M.gguf', 'Qwen3-VL-8B-Thinking-Q5_K_M.gguf', 'Qwen3-VL-8B-Thinking-Q4_K_M.gguf'],
    url: 'https://huggingface.co/bartowski/Qwen3-VL-8B-Thinking-GGUF/resolve/main/Qwen3-VL-8B-Thinking-Q4_K_M.gguf',
    gpuNgl: 99
  },
  'vl-8b-instruct': {
    name: 'Qwen3-VL 8B Instruct (whichllm #2 추천 비전+지시응답, Score 59.9)',
    fileNameCandidates: ['Qwen3VL-8B-Instruct-Q4_K_M.gguf', 'Qwen3-VL-8B-Instruct-Q5_K_M.gguf', 'Qwen3-VL-8B-Instruct-Q4_K_M.gguf'],
    url: 'https://huggingface.co/bartowski/Qwen3-VL-8B-Instruct-GGUF/resolve/main/Qwen3-VL-8B-Instruct-Q5_K_M.gguf',
    gpuNgl: 99
  },
  'deepseek-14b': {
    name: 'DeepSeek-R1 Distill 14B (사고력/Deep Reasoning 특화)',
    fileNameCandidates: ['DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf'],
    url: 'https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-14B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf',
    gpuNgl: 35
  },
  'qwen3-8b': {
    name: 'Qwen3 8B (Qwen 3세대 범용 추론 모델)',
    fileNameCandidates: ['Qwen3-8B-Q4_K_M.gguf'],
    url: 'https://huggingface.co/bartowski/Qwen3-8B-GGUF/resolve/main/Qwen3-8B-Q4_K_M.gguf',
    gpuNgl: 99
  },
  'gemma3-4b': {
    name: 'Gemma 3 4B (Google 초경량 모델)',
    fileNameCandidates: ['gemma-3-4b-it-Q4_K_M.gguf'],
    url: 'https://huggingface.co/ggml-org/gemma-3-4b-it-GGUF/resolve/main/gemma-3-4b-it-Q4_K_M.gguf',
    gpuNgl: 99
  }
};

function killLlamaServer() {
  try {
    execSync('taskkill /F /IM llama-server.exe 2>nul');
  } catch (e) {}
  if (currentServerProcess) {
    try { currentServerProcess.kill(); } catch (e) {}
    currentServerProcess = null;
  }
}

function startLlamaServer(presetKey, callback) {
  killLlamaServer();
  const preset = PRESETS[presetKey] || PRESETS['coder-7b'];
  currentPreset = presetKey;

  if (!fs.existsSync(MODELS_DIR)) {
    fs.mkdirSync(MODELS_DIR, { recursive: true });
  }

  let modelPath = null;
  for (const cand of preset.fileNameCandidates) {
    const testP = path.join(MODELS_DIR, cand);
    if (fs.existsSync(testP)) {
      modelPath = testP;
      break;
    }
  }

  if (!modelPath) {
    modelPath = path.join(MODELS_DIR, preset.fileNameCandidates[0]);
    console.log(`[다운로드] ${preset.name} 초고속 다운로드 중...`);
    try {
      execSync(`curl.exe -L -o "${modelPath}" "${preset.url}"`, { stdio: 'inherit' });
    } catch (e) {
      execSync(`powershell -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '${preset.url}' -OutFile '${modelPath}' -UserAgent 'PowerShell'"`);
    }
  }

  console.log(`[실행] llama-server (${preset.name}) Flash-Attn 적용 구동 중... (${modelPath})`);
  const args = [
    '-m', modelPath,
    '-ngl', String(preset.gpuNgl),
    '-c', '4096',
    '-t', '8',
    '-fa', 'on',
    '--port', String(LLAMA_PORT),
    '--host', '127.0.0.1'
  ];

  currentServerProcess = spawn(LLAMA_EXE, args, { stdio: 'inherit' });
  if (callback) callback();
}

// 초기 7B 서버 구동
startLlamaServer('coder-7b');

const HTML_PAGE = `<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>LLM Lab - 원클릭 모델 스위처</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }
    body { background: #0f172a; color: #f8fafc; display: flex; flex-direction: column; height: 100vh; overflow: hidden; }
    header { background: #1e293b; padding: 15px 25px; border-bottom: 1px solid #334155; display: flex; align-items: center; justify-content: space-between; }
    h1 { font-size: 1.2rem; font-weight: 600; color: #38bdf8; display: flex; align-items: center; gap: 10px; }
    .controls { display: flex; align-items: center; gap: 12px; }
    select { background: #0f172a; color: #f8fafc; border: 1px solid #475569; padding: 8px 14px; border-radius: 8px; font-size: 0.95rem; outline: none; cursor: pointer; min-width: 420px; }
    select:focus { border-color: #38bdf8; }
    button { background: #0284c7; color: white; border: none; padding: 8px 18px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; }
    button:hover { background: #0369a1; }
    .badge { background: #166534; color: #4ade80; padding: 4px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
    iframe { flex: 1; border: none; width: 100%; height: 100%; background: #ffffff; }
    .status-toast { display: none; background: #0284c7; color: white; padding: 12px 24px; position: fixed; top: 70px; right: 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.4); font-size: 0.95rem; z-index: 100; }
  </style>
</head>
<body>
  <header>
    <h1>🚀 llama-server Flash-Attn 전용 스위처</h1>
    <div class="controls">
      <span class="badge" id="statusBadge">⚡ Qwen2.5-Coder 7B 구동 중</span>
      <select id="modelSelect">
        <option value="coder-7b">⚡ Qwen2.5-Coder 7B (코딩 특화, 8GB VRAM 100% 가속)</option>
        <option value="coder-14b">🧠 Qwen2.5-Coder 14B (코딩/개발 능력 최상급 14B)</option>
        <option value="vl-8b-thinking">🧠 Qwen3-VL 8B Thinking (whichllm #1 추천 비전+추론, Score 60.5)</option>
        <option value="vl-8b-instruct">👁️ Qwen3-VL 8B Instruct (whichllm #2 추천 비전+지시응답, Score 59.9)</option>
        <option value="deepseek-14b">💡 DeepSeek-R1 Distill 14B (사고력/추론 특화)</option>
        <option value="qwen3-8b">🌐 Qwen3 8B (3세대 범용 추론 모델)</option>
        <option value="gemma3-4b">⚡ Gemma 3 4B (Google 초경량)</option>
      </select>
      <button onclick="switchModel()">🔄 백그라운드 재가동 및 적용</button>
    </div>
  </header>
  <div class="status-toast" id="toast">⚙️ 모델 교체 및 GPU 메모리 로드 중... 잠시만 기다려주세요.</div>
  <iframe id="llamaFrame" src="http://127.0.0.1:8080"></iframe>

  <script>
    async function checkServerReady() {
      for (let i = 0; i < 30; i++) {
        try {
          const res = await fetch('http://127.0.0.1:8080/v1/models');
          if (res.ok) return true;
        } catch (e) {}
        await new Promise(r => setTimeout(r, 1000));
      }
      return false;
    }

    async function switchModel() {
      const preset = document.getElementById('modelSelect').value;
      const toast = document.getElementById('toast');
      const badge = document.getElementById('statusBadge');
      toast.style.display = 'block';
      toast.innerText = '⚙️ 기존 서버 종료 후 새 모델(' + preset + ') GPU 메모리 로드 중...';
      
      try {
        await fetch('/api/switch', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ preset })
        });
        
        await checkServerReady();
        
        document.getElementById('llamaFrame').src = 'http://127.0.0.1:8080?' + Date.now();
        toast.style.display = 'none';
        badge.innerText = '⚡ ' + preset + ' 구동 중';
      } catch (err) {
        alert('모델 교체 중 오류가 발생했습니다.');
        toast.style.display = 'none';
      }
    }
  </script>
</body>
</html>`;

const server = http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/api/switch') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        startLlamaServer(data.preset, () => {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: 'ok', preset: data.preset }));
        });
      } catch (err) {
        res.writeHead(500);
        res.end(JSON.stringify({ error: err.message }));
      }
    });
  } else {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(HTML_PAGE);
  }
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.log(`[안내] 포트 ${PORT}가 이미 사용 중입니다. 기존 프로세스를 정리합니다...`);
  }
});

server.listen(PORT, () => {
  console.log(`==================================================`);
  console.log(`🚀 원클릭 모델 스위처 컨트롤 패널 구동 완료!`);
  console.log(`   - 접속 주소: http://localhost:${PORT}`);
  console.log(`   - 기능: 상단 드롭다운 클릭 ➔ 백그라운드 llama-server 자동 재가동`);
  console.log(`==================================================`);
});
