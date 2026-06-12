#Requires -Version 5.1
<#
.SYNOPSIS
  새 PC 개발 환경 일괄 설치 (현재 PC 기준 inventory)

.DESCRIPTION
  winget으로 Git, Python, Cursor, Docker 등을 순서대로 설치합니다.
  확장·Python 패키지·Git 설정은 하위 스크립트를 호출합니다.

.PARAMETER Phase
  All       = 전체 (기본)
  Core      = Git, Python, Node, Cursor, VS Code, Terminal, gh, PowerShell
  Utils     = Everything, Bandizip, Notepad++, PowerToys, Chrome
  Docker    = WSL + Docker Desktop
  AI        = Ollama, Open WebUI
  VS        = Visual Studio 2022 Community + C++ 워크로드
  Remote    = RustDesk, Discord, KakaoTalk
  Post      = uv, rustup, 확장, Python 패키지, Git 설정 (재부팅 후 권장)

.EXAMPLE
  .\setup-dev.ps1
  .\setup-dev.ps1 -Phase Core,Utils
  .\setup-dev.ps1 -Phase Post -SkipPython
#>

[CmdletBinding()]
param(
    [ValidateSet('All', 'Core', 'Utils', 'Docker', 'AI', 'VS', 'Remote', 'Post')]
    [string[]]$Phase = @('All'),

    [switch]$SkipExtensions,
    [switch]$SkipPython,
    [switch]$SkipGitConfig,
    [switch]$Force,
    [switch]$NoLog
)

$ErrorActionPreference = 'Continue'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ScriptDir "setup-dev-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message, [ConsoleColor]$Color = 'Gray')
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    if (-not $NoLog) { Add-Content -Path $LogFile -Value $line -Encoding UTF8 }
    Write-Host $line -ForegroundColor $Color
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-Phase {
    param([string]$Name)
    if ($Phase -contains 'All') {
        # Post는 재부팅 후 -Phase Post 로 따로 돌리는 것을 권장
        if ($Name -eq 'Post') { return $false }
        return $true
    }
    return $Phase -contains $Name
}

function Install-Winget {
    param(
        [string]$Id,
        [string]$Label,
        [string[]]$ExtraArgs = @()
    )
    Write-Log "설치 시도: $Label ($Id)" 'Cyan'
    $args = @(
        'install', '--id', $Id, '-e',
        '--accept-package-agreements', '--accept-source-agreements'
    )
    if ($Force) { $args += '--force' }
    if ($ExtraArgs.Count -gt 0) { $args += $ExtraArgs }

    $proc = Start-Process -FilePath 'winget' -ArgumentList $args -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -in 0, -1978335189, -1978335188) {
        # 0=OK, -1978335189=already installed, -1978335188=no upgrade
        Write-Log "  OK: $Label" 'Green'
        return $true
    }
    Write-Log "  실패(exit $($proc.ExitCode)): $Label — 수동 설치 필요" 'Yellow'
    return $false
}

function Test-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Log 'winget이 없습니다. Microsoft Store에서 App Installer를 설치하세요.' 'Red'
        exit 1
    }
    Write-Log "winget: $(winget --version)" 'Gray'
}

function Invoke-CorePhase {
    Write-Log '=== Phase: Core (개발 필수) ===' 'White'
    Install-Winget 'Git.Git' 'Git'
    Install-Winget 'GitHub.cli' 'GitHub CLI'
    Install-Winget 'Python.Python.3.12' 'Python 3.12'
    Install-Winget 'OpenJS.NodeJS' 'Node.js'
    Install-Winget 'Anysphere.Cursor' 'Cursor'
    Install-Winget 'Microsoft.VisualStudioCode' 'Visual Studio Code'
    Install-Winget 'Microsoft.PowerShell' 'PowerShell 7'
    Install-Winget 'Microsoft.WindowsTerminal' 'Windows Terminal'
}

function Invoke-UtilsPhase {
    Write-Log '=== Phase: Utils (유틸) ===' 'White'
    Install-Winget 'voidtools.Everything' 'Everything'
    Install-Winget 'Bandisoft.Bandizip' 'Bandizip'
    Install-Winget 'Notepad++.Notepad++' 'Notepad++'
    Install-Winget 'Microsoft.PowerToys' 'PowerToys'
    Install-Winget 'Google.Chrome.EXE' 'Google Chrome'
}

function Invoke-DockerPhase {
    Write-Log '=== Phase: Docker + WSL ===' 'White'
    if (-not (Test-Admin)) {
        Write-Log 'Docker/WSL 설치는 관리자 권한이 필요합니다. 관리자 PowerShell에서 다시 실행하세요.' 'Yellow'
        return
    }
    Install-Winget 'Microsoft.WSL' 'WSL'
    Install-Winget 'Docker.DockerDesktop' 'Docker Desktop'
    Write-Log 'Docker 설치 후 재부팅 → Docker Desktop 실행 → WSL2 백엔드 확인' 'Yellow'
}

function Invoke-AIPhase {
    Write-Log '=== Phase: AI (로컬 LLM) ===' 'White'
    Install-Winget 'Ollama.Ollama' 'Ollama'
    Install-Winget 'OpenWebUI.OpenWebUI' 'Open WebUI'
}

function Invoke-VSPhase {
    Write-Log '=== Phase: Visual Studio 2022 + C++ ===' 'White'
    if (-not (Test-Admin)) {
        Write-Log 'VS 설치는 관리자 권한 권장. 관리자 PowerShell에서 실행하세요.' 'Yellow'
    }
    $vsOverride = @(
        '--override'
        '"--wait --passive --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended"'
    )
    Install-Winget 'Microsoft.VisualStudio.2022.Community' 'Visual Studio Community 2022' $vsOverride
    Write-Log 'VS 설치는 30분~1시간 걸릴 수 있습니다.' 'Gray'
}

function Invoke-RemotePhase {
    Write-Log '=== Phase: Remote / 메신저 (선택) ===' 'White'
    Install-Winget 'RustDesk.RustDesk' 'RustDesk'
    Install-Winget 'Discord.Discord' 'Discord'
    Install-Winget 'Kakao.KakaoTalk' '카카오톡'
}

function Invoke-PostPhase {
    Write-Log '=== Phase: Post (도구·확장·패키지) ===' 'White'

    # uv
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Log 'uv 설치 중...' 'Cyan'
        try {
            Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
            $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
            Write-Log 'uv 설치 완료' 'Green'
        }
        catch {
            Write-Log "uv 설치 실패: $_" 'Yellow'
        }
    }
    else {
        Write-Log 'uv 이미 설치됨' 'Gray'
    }

    # rustup
    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
        Write-Log 'rustup 설치 후 stable toolchain 설정...' 'Cyan'
        if (Get-Command rustup -ErrorAction SilentlyContinue) {
            rustup default stable 2>&1 | Out-Null
        }
        else {
            Write-Log 'Rust는 winget Rustlang.Rustup으로 설치됩니다. 터미널 재시작 후: rustup default stable' 'Yellow'
            Install-Winget 'Rustlang.Rustup' 'Rustup'
        }
    }
    else {
        rustup default stable 2>&1 | Out-Null
        Write-Log "Rust: $(rustc --version 2>$null)" 'Gray'
    }

    # 하위 스크립트
    $extScript = Join-Path $ScriptDir 'setup-dev-extensions.ps1'
    if (-not $SkipExtensions -and (Test-Path $extScript)) {
        Write-Log '에디터 확장 설치 스크립트 실행...' 'Cyan'
        & $extScript
    }

    $pyScript = Join-Path $ScriptDir 'setup-dev-python.ps1'
    if (-not $SkipPython -and (Test-Path $pyScript)) {
        Write-Log 'Python 패키지 설치 스크립트 실행...' 'Cyan'
        & $pyScript
    }

    $cfgScript = Join-Path $ScriptDir 'setup-dev-config.ps1'
    if (-not $SkipGitConfig -and (Test-Path $cfgScript)) {
        Write-Log 'Git 설정 스크립트 실행...' 'Cyan'
        & $cfgScript
    }
}

# --- main ---
Write-Log '========================================' 'White'
Write-Log '  새 PC 개발 환경 설치 시작' 'White'
Write-Log "  로그: $LogFile" 'Gray'
Write-Log '========================================' 'White'

if (-not (Test-Admin)) {
    Write-Log '일반 권한으로 실행 중. Docker/WSL/VS는 관리자 PowerShell 권장.' 'Yellow'
    Write-Log '관리자 실행: Start-Process pwsh -Verb RunAs -ArgumentList ''-File `"'$MyInvocation.MyCommand.Path'`"''' 'Gray'
}

Test-Winget

if (Test-Phase 'Core')     { Invoke-CorePhase }
if (Test-Phase 'Utils')    { Invoke-UtilsPhase }
if (Test-Phase 'Docker')   { Invoke-DockerPhase }
if (Test-Phase 'AI')       { Invoke-AIPhase }
if (Test-Phase 'VS')       { Invoke-VSPhase }
if (Test-Phase 'Remote')   { Invoke-RemotePhase }
if (Test-Phase 'Post')     { Invoke-PostPhase }

if ($Phase -contains 'All') {
    Write-Log 'All 완료. 재부팅 후 Post 단계 실행: .\setup-dev.ps1 -Phase Post' 'Yellow'
}

Write-Log '========================================' 'White'
Write-Log '  설치 스크립트 완료' 'Green'
Write-Log '  다음: 새PC-환경구축-설명서.md 의 「설치 후 체크리스트」' 'Cyan'
Write-Log '========================================' 'White'
