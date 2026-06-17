#Requires -Version 5.1
param([string]$Repo = 'lobrzut/ai-studio-server')

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'Install GitHub CLI: winget install GitHub.cli'
}

$exists = $false
try {
    gh repo view $Repo *> $null
    $exists = $LASTEXITCODE -eq 0
} catch { }

if (-not $exists) {
    gh repo create $Repo --public --source=. --remote=origin `
        --description 'AI Studio Server — one-command Debian install (curl | bash). ComfyUI + dashboard hub from AI Studio Portable.'
}

git push -u origin main
gh repo edit $Repo --add-topic ai-studio-server
gh repo edit $Repo --description 'One-command Linux server: curl -fsSL .../bootstrap.sh | sudo bash — AI Studio dashboard + ComfyUI.'

Write-Host "OK: https://github.com/$Repo" -ForegroundColor Green
Write-Host ''
Write-Host 'One-liner (on Debian server):' -ForegroundColor Cyan
Write-Host "  curl -fsSL https://raw.githubusercontent.com/$Repo/main/bootstrap.sh | sudo bash" -ForegroundColor White
