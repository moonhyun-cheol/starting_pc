#Requires -Version 5.1
<#
.SYNOPSIS
  VS Code / Cursor 확장 일괄 설치 (현재 PC inventory 기준)
#>

$ErrorActionPreference = 'Continue'

$Extensions = @(
    'MS-CEINTL.vscode-language-pack-ko',
    'ms-python.python',
    'ms-python.debugpy',
    'ms-python.vscode-python-envs',
    'ms-python.black-formatter',
    'ms-python.autopep8',
    'kevinrose.vsc-python-indent',
    'esbenp.prettier-vscode',
    'mhutchie.git-graph',
    'ms-vscode-remote.remote-ssh',
    'ms-vscode-remote.remote-containers',
    'ms-vscode-remote.remote-wsl',
    'bierner.markdown-mermaid',
    'tomoyukim.vscode-mermaid-editor',
    'ubw.mermaidlens',
    'streetsidesoftware.code-spell-checker',
    'oderwat.indent-rainbow',
    'christian-kohler.path-intellisense',
    'alefragnani.bookmarks',
    'vincaslt.highlight-matching-tag',
    'kisstkondoros.vscode-gutter-preview',
    'ms-python.vscode-pylance'
)

function Install-EditorExtensions {
    param(
        [string]$CliName,
        [string]$DisplayName
    )
    $cli = Get-Command $CliName -ErrorAction SilentlyContinue
    if (-not $cli) {
        Write-Host "[$DisplayName] CLI 없음 ($CliName) — 앱 실행 후 Extensions 탭에서 수동 설치 또는 Settings Sync" -ForegroundColor Yellow
        return
    }
    Write-Host "`n=== $DisplayName 확장 설치 ===" -ForegroundColor Cyan
    foreach ($ext in $Extensions) {
        Write-Host "  $ext" -ForegroundColor Gray
        & $CliName --install-extension $ext --force 2>&1 | Out-Null
    }
    Write-Host "[$DisplayName] 완료" -ForegroundColor Green
}

# PATH 새로고침 (winget 직후)
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = "$machinePath;$userPath"

Install-EditorExtensions -CliName 'code' -DisplayName 'VS Code'

# Cursor: code.cmd 경로와 유사
$cursorPaths = @(
    "$env:LOCALAPPDATA\Programs\cursor\resources\app\bin\cursor.cmd",
    "$env:LOCALAPPDATA\Programs\Cursor\resources\app\bin\cursor.cmd"
)
$cursorCli = $cursorPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($cursorCli) {
    Install-EditorExtensions -CliName $cursorCli -DisplayName 'Cursor'
}
else {
    Write-Host '[Cursor] cursor.cmd 없음 — Cursor → Command Palette → "Shell Command: Install cursor command in PATH"' -ForegroundColor Yellow
    Write-Host '         또는 Cursor Settings Sync (권장)' -ForegroundColor Yellow
}

Write-Host "`n확장 목록 (VS Code):" -ForegroundColor Cyan
if (Get-Command code -ErrorAction SilentlyContinue) {
    code --list-extensions
}
