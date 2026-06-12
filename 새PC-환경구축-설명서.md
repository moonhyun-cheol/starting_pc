# 새 PC 개발 환경 구축 설명서

현재 PC(Windows)에 설치된 개발 도구·유틸을 **새 컴퓨터에서 동일하게** 맞추기 위한 가이드입니다.  
[starting_pc](https://github.com/moonhyun-cheol/starting_pc) 저장소의 PowerShell 스크립트로 **대부분 자동 설치**하고, 로그인·보안 파일 등은 **수동**으로 마무리합니다.

**GitHub:** https://github.com/moonhyun-cheol/starting_pc

---

## 파일 구성

| 파일 | 역할 |
|------|------|
| **`setup-dev.ps1`** | 메인 — winget으로 프로그램 일괄 설치 |
| **`setup-dev-extensions.ps1`** | VS Code / Cursor 확장 22개 |
| **`setup-dev-python.ps1`** | Python 전역 패키지 (Google API, pandas 등) |
| **`setup-dev-config.ps1`** | Git user.name / email, gh 로그인 안내 |
| **`새PC-환경구축-설명서.md`** | 이 문서 |

---

## 한 줄 요약

> **`.ps1`만 실행해도 프로그램 설치는 대부분 자동** —  
> **로그인·SSH·OAuth·재부팅·Office 등은 직접** 해야 합니다.

---

## 빠른 시작 (새 PC)

### 1) 사전 준비

1. Windows Update 적용
2. **Microsoft 계정** 로그인 (PowerToys, Cursor Sync 등)
3. Git 설치 후 저장소 clone (또는 USB로 `starting_pc` 폴더 복사)

```powershell
git clone https://github.com/moonhyun-cheol/starting_pc.git
cd starting_pc
```

### 2) PowerShell 실행 정책 (최초 1회)

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 3) 전체 설치 (관리자 권장)

**시작 메뉴 → PowerShell → 우클릭 → 관리자 권한으로 실행**

```powershell
cd starting_pc   # clone한 폴더
.\setup-dev.ps1
```

약 **30분~2시간** (Visual Studio 포함 시 더 김).  
로그 파일: `setup-dev-YYYYMMDD-HHmmss.log`

### 4) 재부팅 후 Post 단계

Docker / WSL 설치했다면 **재부팅** 후:

```powershell
cd starting_pc
.\setup-dev.ps1 -Phase Post
```

---

## Phase별 설치 내용

| Phase | 명령 | 설치 항목 |
|-------|------|-----------|
| **All** (기본) | `.\setup-dev.ps1` | 아래 전부 |
| Core | `-Phase Core` | Git, GitHub CLI, Python 3.12, Node.js, Cursor, VS Code, PowerShell 7, Windows Terminal |
| Utils | `-Phase Utils` | Everything, Bandizip, Notepad++, PowerToys, Chrome |
| Docker | `-Phase Docker` | WSL, Docker Desktop |
| AI | `-Phase AI` | Ollama, Open WebUI |
| VS | `-Phase VS` | Visual Studio 2022 Community + **C++ 데스크톱 워크로드** |
| Remote | `-Phase Remote` | RustDesk, Discord, 카카오톡 |
| Post | `-Phase Post` | uv, Rust, 확장, Python 패키지, Git 설정 |

### 예시: 필수만 먼저

```powershell
.\setup-dev.ps1 -Phase Core,Utils,Post
```

### 예시: VS·Docker 제외 (용량·시간 절약)

```powershell
.\setup-dev.ps1 -Phase Core,Utils,AI,Remote,Post
```

### 개별 스크립트만 실행

```powershell
.\setup-dev-extensions.ps1   # 확장만
.\setup-dev-python.ps1       # pip 패키지만
.\setup-dev-config.ps1       # Git 설정만
```

---

## 스크립트가 **자동으로** 하는 것

- winget으로 프로그램 다운로드·설치 (이미 있으면 건너뜀)
- Visual Studio C++ 워크로드 추가 설치 시도
- uv (Python 패키지 매니저) 설치
- VS Code / Cursor 확장 일괄 설치 시도
- 자주 쓰는 Python 패키지 pip 설치
- Git `user.name` / `user.email` 설정

---

## 스크립트가 **못 하는 것** (수동 체크리스트)

설치 후 아래를 직접 진행하세요.

### 필수

- [ ] **재부팅** (WSL / Docker / VS 설치 후)
- [ ] **Docker Desktop** 실행 → Settings → *Use the WSL 2 based engine* 확인
- [ ] **Cursor** 실행 → 로그인 → **Settings Sync** 켜기 (확장·설정 동기화)
- [ ] **GitHub 로그인**: `gh auth login`
- [ ] **SSH 키** 복사: `C:\Users\<이름>\.ssh\` (GitHub push용)
- [ ] **Google OAuth**: `credentials.json`, `token.json` 복사 (재무관리 deploy용, git 금지)

### 프로젝트

- [ ] `git clone https://github.com/moonhyun-cheol/money-morny.git`
- [ ] `pip install -r requirements.txt` (또는 `setup-dev-python.ps1` 실행)
- [ ] 재무관리: [money-morny 사용설명서](https://github.com/moonhyun-cheol/money-morny/blob/main/docs/사용설명서.md) 참고 (별도 repo — `git clone` 후 `docs/사용설명서.md`)

### 선택

- [ ] **Office LTSC 2024** — 별도 라이선스·설치 (winget 미포함)
- [ ] **Ollama 모델** 다운로드: `ollama pull llama3` 등
- [ ] **HP 프린터** 드라이버 (기종별)
- [ ] **Java 8** — 특정 프로그램 필요할 때만
- [ ] 회사용: NOPSPro, SEGIO Messenger

---

## 현재 PC 기준 설치 목록 (inventory)

### 개발 도구

| 프로그램 | 버전(기준) | winget ID |
|----------|------------|-----------|
| Git | 2.54.0 | `Git.Git` |
| GitHub CLI | 2.93.0 | `GitHub.cli` |
| Python | 3.12.2 | `Python.Python.3.12` |
| Node.js | 24.15.0 | `OpenJS.NodeJS` |
| Cursor | 3.7.27 | `Anysphere.Cursor` |
| VS Code | 1.124.0 | `Microsoft.VisualStudioCode` |
| PowerShell | 7.6.2 | `Microsoft.PowerShell` |
| Windows Terminal | 1.24.x | `Microsoft.WindowsTerminal` |
| Docker Desktop | 4.77.0 | `Docker.DockerDesktop` |
| WSL | 2.7.3 | `Microsoft.WSL` |
| Rust (rustup) | 1.96.0 | `Rustlang.Rustup` |
| uv | 0.11.15 | (스크립트로 설치) |
| VS Community 2022 | 17.14.x | `Microsoft.VisualStudio.2022.Community` |
| Ollama | 0.30.7 | `Ollama.Ollama` |
| Open WebUI | 0.0.20 | `OpenWebUI.OpenWebUI` |

### 유틸

| 프로그램 | winget ID |
|----------|-----------|
| Everything | `voidtools.Everything` |
| Bandizip | `Bandisoft.Bandizip` |
| Notepad++ | `Notepad++.Notepad++` |
| PowerToys | `Microsoft.PowerToys` |
| Google Chrome | `Google.Chrome.EXE` |
| RustDesk | `RustDesk.RustDesk` |
| Discord | `Discord.Discord` |
| 카카오톡 | `Kakao.KakaoTalk` |

### Cursor / VS Code 확장 (22개)

한국어 팩, Python, Black, autopep8, Prettier, Git Graph, Remote SSH/WSL/Containers, Mermaid 3종, Code Spell Checker, indent-rainbow, Path Intellisense, Bookmarks, Highlight Matching Tag, Image preview, Pylance

→ **`setup-dev-extensions.ps1`** 또는 Cursor **Settings Sync**

---

## Git 설정 (기본값)

`setup-dev-config.ps1` 기본값:

```
user.name  = moonhyun-cheol
user.email = ins78516@gmail.com
```

다른 값을 쓰려면:

```powershell
.\setup-dev-config.ps1 -GitName "이름" -GitEmail "email@example.com"
```

---

## 문제 해결

### winget을 찾을 수 없음

Microsoft Store에서 **App Installer** 설치 후 터미널 재시작.

### "스크립트 실행이 금지되어 있습니다"

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Docker 설치 후 WSL 오류

1. 재부팅  
2. `wsl --update`  
3. Docker Desktop 재실행  

### Cursor 확장이 안 깔림

1. Cursor 실행 → Command Palette → **Shell Command: Install 'cursor' command in PATH**  
2. 터미널 재시작 후 `.\setup-dev-extensions.ps1`  
3. 또는 Cursor **Settings Sync** (가장 쉬움)

### Python / pip을 찾을 수 없음

Python 설치 후 **터미널을 완전히 닫고** 다시 연 뒤 `.\setup-dev.ps1 -Phase Post` 실행.

### Visual Studio가 너무 오래 걸림

C++ 불필요하면 VS Phase 생략:

```powershell
.\setup-dev.ps1 -Phase Core,Utils,Docker,AI,Remote,Post
```

나중에만 설치:

```powershell
.\setup-dev.ps1 -Phase VS
```

---

## 권장 설치 순서 (타임라인)

```
Day 0  Windows Update + git clone starting_pc
       관리자 PowerShell → .\setup-dev.ps1
       재부팅

Day 1  .\setup-dev.ps1 -Phase Post
       Docker Desktop, Cursor, gh auth login
       Settings Sync, SSH/OAuth 복사

Day 2  git clone 프로젝트, 재무관리 deploy (필요 시)
       Office·프린터 등 일상 프로그램
```

---

## FAQ

**Q. Import-Module로 실행하나요?**  
A. 아닙니다. `.\setup-dev.ps1` 처럼 **스크립트 파일을 실행**합니다.

**Q. 한 번에 100% 똑같아지나요?**  
A. 프로그램·확장·pip는 **80~90%** 자동. 로그인·보안 파일·Office·바탕화면 데이터는 수동입니다.

**Q. 기존 PC에서 export한 winget 목록을 쓰면?**  
A. `winget export -o packages.json` / `winget import packages.json` 도 가능합니다.  
   이 폴더의 `.ps1`은 **현재 PC inventory를 반영한 큐레이션 버전**이라 더 읽기 쉽습니다.

**Q. 재무관리 시트는 새 PC에서 다시 deploy?**  
A. **아니요.** 이미 만든 Spreadsheet URL만 열면 됩니다. deploy는 **처음 한 번** 또는 **새로 시트를 만들 때**만.

---

## 관련 문서

| 저장소 | 링크 |
|--------|------|
| **starting_pc** (이 repo) | https://github.com/moonhyun-cheol/starting_pc |
| **money-morny** (재무관리) | https://github.com/moonhyun-cheol/money-morny |
| 재무관리 사용설명서 | https://github.com/moonhyun-cheol/money-morny/blob/main/docs/사용설명서.md |
| 재무관리 — 다른 PC · Google 연동 | https://github.com/moonhyun-cheol/money-morny/blob/main/docs/사용설명서.md#다른-컴퓨터에서-github-받기--google-연동 |

> **참고:** `사용설명서.md`는 **starting_pc가 아니라 money-morny** 안에 있습니다.  
> `git clone https://github.com/moonhyun-cheol/money-morny.git` 후 `docs/사용설명서.md` 를 열면 됩니다.

---

*마지막 업데이트: 2026-06-12 — starting_pc repo 기준*
