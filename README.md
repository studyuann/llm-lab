# llm-lab 🤖

> **llama.cpp** 및 **Ollama**를 활용한 로컬 AI 자동화 워크플로우 스크립트 모음

요즘IT 아티클 ["로컬 LLM, 나를 위한 작은 AI 작업대 만들기"](https://yozm.wishket.com/magazine/detail/3835/)에서 영감을 받아 제작된 개인 개발용 로컬 AI 작업대 프로젝트입니다.

---

## ⚡ 왜 llama.cpp 인가? (Ollama vs llama.cpp)

| 비교 항목 | Ollama | **llama.cpp** (권장) |
|---|---|---|
| **구조** | 내부 추상화 레이어 + 데몬 프로세스 | 네이티브 C++ 경량 실행 파일 (`llama-server.exe`) |
| **API 호환성** | 자체 커스텀 API (`/api/generate`) | **표준 OpenAI API** 호환 (`/v1/chat/completions`) |
| **GPU 오프로딩** | 기본 설정 의존 | `-ngl 99`로 VRAM 100% 온전히 활용 |
| **메모리 / 속도** | 상위 추상화 오버헤드 존재 | C++ 네이티브 최고 속도 및 최저 딜레이 |

---

## 🖥️ 시스템 환경

- **GPU**: NVIDIA GeForce RTX 5060 (8GB VRAM)
- **CUDA**: 12.4 / 13.1
- **엔진**: `llama.cpp` (CUDA 12.4 가속) & `Ollama`

---

## 🛠️ 빠른 시작 (Quick Start)

### 1단계: llama.cpp 설치
```powershell
.\scripts\install-llama-cpp.ps1
```

### 2단계: llama.cpp GPU 서버 시작
```powershell
.\scripts\start-llama-server.ps1
```
> `llama-server.exe`가 실행되어 `http://127.0.0.1:8080/v1/chat/completions` REST API 제공

---

## 📜 스크립트 사용법

기본 백엔드는 **`llama.cpp`**로 동작하며, 필요 시 `-Backend ollama` 옵션을 주어 Ollama로도 전환 가능합니다.

### 📄 로그 분석 및 요약 — `log-summarize.ps1`
```powershell
# llama.cpp 사용 (기본)
.\scripts\log-summarize.ps1 -LogFile .\samples\sample-error.log

# Ollama 백엔드로 실행하고 싶은 경우
.\scripts\log-summarize.ps1 -LogFile .\samples\sample-error.log -Backend ollama
```

### 💡 코드 역할 분석 및 설명 — `explain-code.ps1`
```powershell
.\scripts\explain-code.ps1 -FilePath .\samples\sample-function.ts
```

### ✍️ 문서 다듬기 및 제목 추천 — `readme-polish.ps1`
```powershell
# 제목 후보 5개 생성
.\scripts\readme-polish.ps1 -FilePath .\README.md -Mode titles

# 문서 문장 다듬기
.\scripts\readme-polish.ps1 -FilePath .\README.md -Mode polish

# 문서 요약
.\scripts\readme-polish.ps1 -FilePath .\README.md -Mode summary
```

### 💬 커밋 메시지 자동 생성 — `commit-message.ps1`
```powershell
.\scripts\commit-message.ps1 -Conventional
```

---

## 📂 디렉토리 구조

```
llm-lab/
├── README.md               # 프로젝트 전체 설명서
├── bin/
│   └── llama-cpp/          # llama.cpp CUDA 실행 파일 및 DLL
├── models/                 # GGUF 모델 파일 저장소
├── scripts/
│   ├── install-llama-cpp.ps1 # llama.cpp 바이너리 자동 설치
│   ├── start-llama-server.ps1# llama-server GPU 가속 실행
│   ├── download-gguf.ps1   # Hugging Face GGUF 다운로더
│   ├── log-summarize.ps1   # 로그 분석 및 요약
│   ├── explain-code.ps1    # 코드 분석 및 설명
│   ├── readme-polish.ps1   # 문서 다듬기 및 제목 추천
│   └── commit-message.ps1  # git diff 기반 커밋 메시지 추천
└── samples/
    ├── sample-function.ts  # 테스트 코드 샘플
    └── sample-error.log    # 테스트 로그 샘플
```

---

## 🎯 핵심 원칙

- ✅ **C++ 네이티브 지연시간 최소화** (llama.cpp)
- ✅ **표준 OpenAI REST API 호환** (`/v1/chat/completions`)
- ✅ **틀려도 바로 검증 가능한 범위**에서 로컬 AI 활용