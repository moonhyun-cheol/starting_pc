# starting_pc

새 Windows PC에서 **개발 환경을 한 번에 맞추기** 위한 PowerShell 스크립트 모음입니다.  
현재 사용 중인 PC inventory 기준으로 작성되었습니다.

**GitHub:** https://github.com/moonhyun-cheol/starting_pc

---

## 빠른 시작

```powershell
git clone https://github.com/moonhyun-cheol/starting_pc.git
cd starting_pc

Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# 관리자 PowerShell 권장
.\setup-dev.ps1

# 재부팅 후
.\setup-dev.ps1 -Phase Post
```

📖 **자세한 설명서:** [`새PC-환경구축-설명서.md`](새PC-환경구축-설명서.md)

---

## 파일

| 파일 | 설명 |
|------|------|
| `setup-dev.ps1` | winget 일괄 설치 (메인) |
| `setup-dev-extensions.ps1` | VS Code / Cursor 확장 |
| `setup-dev-python.ps1` | Python pip 패키지 |
| `setup-dev-config.ps1` | Git 설정, gh 로그인 안내 |
| `새PC-환경구축-설명서.md` | 전체 가이드 |

---

## 관련 저장소

| 저장소 | 용도 |
|--------|------|
| [starting_pc](https://github.com/moonhyun-cheol/starting_pc) | 새 PC 개발 환경 설치 (이 repo) |
| [money-morny](https://github.com/moonhyun-cheol/money-morny) | 재무관리 (Google Sheets) — [사용설명서](https://github.com/moonhyun-cheol/money-morny/blob/main/docs/사용설명서.md) |

---

## Phase 요약

```powershell
.\setup-dev.ps1                          # All (Post 제외, 재부팅 후 Post)
.\setup-dev.ps1 -Phase Core,Utils,Post   # 필수만
.\setup-dev.ps1 -Phase VS                # Visual Studio만
```

> `.ps1`은 프로그램 설치까지 자동화합니다. Cursor 로그인, SSH 키, Google OAuth 등은 설명서의 수동 체크리스트를 따르세요.
