#Requires -Version 5.1
<#
.SYNOPSIS
  Git 전역 설정 + GitHub CLI 로그인 안내

.PARAMETER GitName
.PARAMETER GitEmail
  기본값: 현재 PC와 동일 (moonhyun-cheol)
#>

[CmdletBinding()]
param(
    [string]$GitName = 'moonhyun-cheol',
    [string]$GitEmail = 'ins78516@gmail.com',
    [switch]$SkipGhLogin
)

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host 'Git이 설치되지 않았습니다.' -ForegroundColor Red
    exit 1
}

$currentName = git config --global user.name 2>$null
$currentEmail = git config --global user.email 2>$null

if ($currentName -and $currentEmail) {
    Write-Host "Git 설정 이미 있음: $currentName <$currentEmail>" -ForegroundColor Gray
    $answer = Read-Host '덮어쓸까요? (y/N)'
    if ($answer -notmatch '^[yY]') {
        Write-Host 'Git 설정 유지' -ForegroundColor Green
    }
    else {
        git config --global user.name $GitName
        git config --global user.email $GitEmail
        Write-Host "Git 설정 적용: $GitName <$GitEmail>" -ForegroundColor Green
    }
}
else {
    git config --global user.name $GitName
    git config --global user.email $GitEmail
    Write-Host "Git 설정 적용: $GitName <$GitEmail>" -ForegroundColor Green
}

git config --global init.defaultBranch main 2>$null
git config --global core.autocrlf true 2>$null

Write-Host "`ngit config --global --list:" -ForegroundColor Cyan
git config --global --list

if (-not $SkipGhLogin) {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Host "`nGitHub CLI 로그인 (브라우저):" -ForegroundColor Cyan
        Write-Host '  gh auth login' -ForegroundColor White
        $run = Read-Host '지금 gh auth login 실행? (y/N)'
        if ($run -match '^[yY]') {
            gh auth login
        }
    }
}

Write-Host @"

[수동 복사 필요 — git에 올리지 말 것]
  ~/.ssh/id_ed25519, id_rsa  (SSH 키)
  재무관리 config/credentials.json, token.json

"@ -ForegroundColor Yellow
