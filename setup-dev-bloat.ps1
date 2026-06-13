#Requires -Version 5.1
<#
.SYNOPSIS
  개발 PC에 불필요한 Windows 기본/스토어 앱 제거

.DESCRIPTION
  Bing·Copilot·Xbox·OneDrive·Office 허브 등 Microsoft 번들 앱을 제거합니다.
  Git, Python, Cursor, Chrome, Terminal, PowerToys, 드라이버 등은 유지합니다.

.EXAMPLE
  .\setup-dev-bloat.ps1
  .\setup-dev.ps1 -Phase Bloat
#>

[CmdletBinding()]
param(
    [switch]$IncludeGames,
    [switch]$NoLog
)

$ErrorActionPreference = 'SilentlyContinue'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ScriptDir "setup-dev-bloat-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message, [ConsoleColor]$Color = 'Gray')
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    if (-not $NoLog) { Add-Content -Path $LogFile -Value $line -Encoding UTF8 }
    Write-Host $line -ForegroundColor $Color
}

$removePatterns = @(
    'Microsoft.BingNews',
    'Microsoft.BingWeather',
    'Microsoft.BingSearch',
    'Microsoft.Copilot',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.MicrosoftStickyNotes',
    'Microsoft.MixedReality.Portal',
    'Microsoft.Office.OneNote',
    'Microsoft.OutlookForWindows',
    'Microsoft.Paint',
    'Microsoft.PowerAutomateDesktop',
    'Microsoft.XboxGameOverlay',
    'Microsoft.XboxGamingOverlay',
    'Microsoft.XboxIdentityProvider',
    'Microsoft.XboxSpeechToTextOverlay',
    'Microsoft.ZuneMusic',
    'Microsoft.ZuneVideo',
    'Microsoft.YourPhone',
    'MicrosoftWindows.Client.WebExperience',
    'Microsoft.Windows.DevHome',
    'Microsoft.GetHelp',
    'microsoft.windowscommunicationsapps',
    'Microsoft.WindowsCamera',
    'Microsoft.WindowsAlarms',
    'Microsoft.OneDriveSync',
    'Microsoft.WidgetsPlatformRuntime',
    'Microsoft.StartExperiencesApp',
    'MicrosoftWindows.CrossDevice'
)

if ($IncludeGames) {
    Write-Log '게임/런처 제거 포함 (Steam·Riot 등은 winget으로 별도 확인)' 'Yellow'
}

$removed = @()
$failed = @()

Write-Log '=== 불필요 앱 제거 시작 ===' 'White'

foreach ($pattern in $removePatterns) {
    foreach ($pkg in Get-AppxPackage -Name "*$pattern*") {
        try {
            Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
            $removed += $pkg.Name
            Write-Log "  제거: $($pkg.Name)" 'Green'
        }
        catch {
            $failed += "$($pkg.Name): $_"
            Write-Log "  실패: $($pkg.Name)" 'Yellow'
        }
    }
}

foreach ($item in @(
        @{ Id = 'Microsoft.OneDrive'; Label = 'OneDrive' },
        @{ Id = '9NZBF4GT040C'; Label = 'Microsoft Bing' }
    )) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { break }
    Write-Log "winget 제거 시도: $($item.Label)" 'Cyan'
    $proc = Start-Process -FilePath 'winget' -ArgumentList @(
        'uninstall', '--id', $item.Id, '-e',
        '--accept-source-agreements', '--disable-interactivity'
    ) -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -in 0, -1978335189, -1978335188) {
        $removed += $item.Label
        Write-Log "  OK: $($item.Label)" 'Green'
    }
}

Write-Log "=== 완료: 제거 $($removed.Count) / 실패 $($failed.Count) ===" 'White'
Write-Log 'Microsoft Edge는 Windows 정책상 CLI 제거가 막힐 수 있습니다 → 설정 → 앱에서 수동 제거' 'Gray'
Write-Log "로그: $LogFile" 'Gray'
