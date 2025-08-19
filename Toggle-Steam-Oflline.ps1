# ---- Ensure running as admin ----
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-ExecutionPolicy", "bypass", "-File", ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
}

# ---- Steam executable path ----
$steamExe = "C:\Program Files (x86)\Steam\steam.exe"
# ---- Firewall rule name prefix ----
$rulePrefix = "Steam Offline Lock"

if (-not (Test-Path $steamExe)) {
    Write-Host "Steam executable not found: $steamExe" -ForegroundColor Red
    exit
}

# ---- Functions ----
function Block-Steam {
    $base = Split-Path $steamExe -Leaf
    $outName = "$rulePrefix - OUT - $base"
    $inName = "$rulePrefix - IN  - $base"

    # remove before adding
    Get-NetFirewallRule -DisplayName $outName -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    Get-NetFirewallRule -DisplayName $inName  -ErrorAction SilentlyContinue | Remove-NetFirewallRule

    New-NetFirewallRule -DisplayName $outName -Direction Outbound -Action Block -Program $steamExe -Profile Any | Out-Null
    New-NetFirewallRule -DisplayName $inName  -Direction Inbound  -Action Block -Program $steamExe -Profile Any | Out-Null
    Write-Host "Blocked: $base" -ForegroundColor Green
}

function Unblock-Steam {
    Get-NetFirewallRule -DisplayName "$rulePrefix*" -ErrorAction SilentlyContinue | Remove-NetFirewallRule | Out-Null
    Write-Host "Unblocked Steam (rules removed)." -ForegroundColor Green
}

function Show-Status {
    if (Get-NetFirewallRule -DisplayName "$rulePrefix*" -ErrorAction SilentlyContinue) {
        Write-Host "Status: BLOCKED" -ForegroundColor Red
    }
    else {
        Write-Host "Status: ENABLED" -ForegroundColor Green
    }
}

# ---- Menu ----
Write-Host "Steam Internet Toggle" -ForegroundColor Cyan
Show-Status
Write-Host ""
Write-Host "[D] Disable (block) internet for Steam"
Write-Host "[E] Enable (unblock) internet for Steam"
Write-Host "[Q] Quit"
$choice = Read-Host "Choose an option (D/E/Q)"

switch ($choice.ToUpper()) {
    'D' { Block-Steam; Show-Status }
    'E' { Unblock-Steam; Show-Status }
    'Q' { Write-Host "Bye." }
    Default { Write-Host "Invalid choice." -ForegroundColor Yellow }
}

Write-Host ""
Read-Host "Press Enter to exit"
