# llm-lab 🤖

> 로컬 LLM(Ollama)을 내 개발 워크플로우에 붙여보는 작은 실험실

요즘IT 아티클 ["로컬 LLM, 나를 위한 작은 AI 작업대 만들기"](https://yozm.wishket.com/magazine/detail/3835/)에서 영감을 받아 만든 로컬 LLM 활용 스크립트 모음입니다.

## 시스템 환경

| 항목 | 사양 |
|---|---|
| GPU | NVIDIA GeForce RTX 5060 |
| VRAM | 8GB |
| CUDA | 13.1 |
| Ollama | 0.32.5 |

## 설치된 모델

| 모델 | 크기 | 용도 |
|---|---|---|
| `qwen3:8b` | 5.2 GB | 기본 작업 모델 (코드, 문서, 로그) |
| `gemma3:4b` | 3.3 GB | 가벼운 작업용 |

## 스크립트 사용법

> **사전 조건**: Ollama가 실행 중이어야 합니다 (`ollama serve`)

### 📄 로그 요약 — `log-summarize.ps1`

에러 로그를 분석해서 원인을 요약합니다.

```powershell
# 파일 지정
.\scripts\log-summarize.ps1 -LogFile .\samples\sample-error.log

# 다른 모델 사용
.\scripts\log-summarize.ps1 -LogFile app.log -Model gemma3:4b

# 파이프로 전달
Get-Content build.log | .\scripts\log-summarize.ps1
```

### 💬 커밋 메시지 생성 — `commit-message.ps1`

git diff를 분석해서 커밋 메시지 후보를 만듭니다.

```powershell
# 기본 (변경사항 자동 감지)
.\scripts\commit-message.ps1

# staged 변경사항만
.\scripts\commit-message.ps1 -Staged

# Conventional Commits 형식
.\scripts\commit-message.ps1 -Conventional

# 후보 5개
.\scripts\commit-message.ps1 -Count 5
```

### 💡 코드 설명 — `explain-code.ps1`

함수나 파일을 분석해서 설명합니다.

```powershell
# 파일 지정
.\scripts\explain-code.ps1 -FilePath .\samples\sample-function.ts

# 파이프로 전달
Get-Content myfile.py | .\scripts\explain-code.ps1
```

### ✍️ 문서 다듬기 — `readme-polish.ps1`

README나 문서를 다듬거나 제목 후보를 생성합니다.

```powershell
# 문장 다듬기 (기본)
.\scripts\readme-polish.ps1 -FilePath .\README.md

# 제목 후보 생성
.\scripts\readme-polish.ps1 -FilePath .\README.md -Mode titles

# 요약
.\scripts\readme-polish.ps1 -FilePath .\README.md -Mode summary
```

## 디렉토리 구조

```
llm-lab/
├── README.md               # 프로젝트 전체 사용 설명서
├── scripts/
│   ├── log-summarize.ps1   # 로그 분석 및 요약
│   ├── commit-message.ps1  # git diff 기반 커밋 메시지 생성
│   ├── explain-code.ps1    # 코드 분석 및 개선점 제시
│   ├── readme-polish.ps1   # 문서 다듬기 및 제목 추천
│   └── test-all.ps1       # 전체 검증 테스터
└── samples/
    ├── sample-function.ts  # 코드 분석 테스트 샘플
    └── sample-error.log    # 로그 요약 테스트 샘플
```


## 핵심 원칙

아티클에서 강조한 기준 그대로 적용:

- ✅ **틀려도 바로 검증 가능한 작업**만 맡김
- ✅ **입력 범위를 작게** 유지 (파일 하나, 함수 하나)
- ✅ **결과는 항상 직접 확인** 후 사용
- ❌ 복잡한 설계 결정은 맡기지 않음
- ❌ 자동 배포나 코드 수정에 직접 연결하지 않음

## 참고

- [Ollama](https://ollama.com/) — 로컬 LLM 실행 도구
- [whichllm](https://github.com/Andyyyy64/whichllm) — 클라우드 LLM 모델 추천 CLI
- [요즘IT 아티클](https://yozm.wishket.com/magazine/detail/3835/) — 영감의 출처
  