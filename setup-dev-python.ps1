#Requires -Version 5.1
<#
.SYNOPSIS
  Python 전역 패키지 설치 (현재 PC에서 자주 쓰는 패키지 + 재무관리 deploy용)
#>

$ErrorActionPreference = 'Continue'

$Packages = @(
    # 재무관리 deploy
    'google-api-python-client>=2.100.0',
    'google-auth-httplib2>=0.2.0',
    'google-auth-oauthlib>=1.2.0',
    # 데이터·과학
    'numpy',
    'pandas',
    'scipy',
    'matplotlib',
    'openpyxl',
    'xlsxwriter',
    'pillow',
    # 웹·유틸
    'flask',
    'httpx',
    'requests',
    'python-dotenv',
    'ipython',
    'pywin32'
)

function Find-Python {
    $candidates = @(
        (Get-Command python -ErrorAction SilentlyContinue)?.Source,
        (Get-Command py -ErrorAction SilentlyContinue)?.Source
    ) | Where-Object { $_ }
    if ($candidates) { return $candidates[0] }
    return $null
}

$python = Find-Python
if (-not $python) {
    Write-Host 'Python을 찾을 수 없습니다. setup-dev.ps1 Core 단계를 먼저 실행하거나 터미널을 재시작하세요.' -ForegroundColor Red
    exit 1
}

Write-Host "Python: $(& $python --version 2>&1)" -ForegroundColor Cyan
Write-Host 'pip 업그레이드...' -ForegroundColor Gray
& $python -m pip install --upgrade pip

Write-Host '패키지 설치 중...' -ForegroundColor Cyan
foreach ($pkg in $Packages) {
    Write-Host "  $pkg" -ForegroundColor Gray
    & $python -m pip install $pkg
}

Write-Host "`n설치된 패키지 (일부):" -ForegroundColor Green
& $python -m pip list | Select-String -Pattern 'google|pandas|numpy|flask|openpyxl'
