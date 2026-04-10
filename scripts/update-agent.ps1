#Requires -Version 5.1
<#
.SYNOPSIS
    Updates a standalone agent folder in the target .copilot folder.

.PARAMETER TargetBase
    Path to the .copilot folder (e.g. C:\Users\USERNAME\.copilot).

.PARAMETER Name
    Agent name (e.g. commit). Expects source at: agents/{Name}/.
#>

param(
    [string] $TargetBase = "$env:USERPROFILE\.copilot",
    [Parameter(Mandatory)] [string] $Name
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Paths ────────────────────────────────────────────────────────────────────
$RepoRoot    = $PSScriptRoot | Split-Path -Parent
$BackupsRoot = Join-Path $TargetBase 'backups'
$Timestamp   = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'

$AgentSrc = Join-Path $RepoRoot "agents\$Name"
$AgentDst = Join-Path $TargetBase "agents"

if (-not (Test-Path $AgentSrc)) {
    Write-Warning "Source agent folder not found: $AgentSrc. Nothing to do."
    return
}

# ── Discover managed files from source ────────────────────────────────────────
[string[]] $AgentFiles = @(
    Get-ChildItem -Path $AgentSrc -Filter '*.agent.md' -File |
        Select-Object -ExpandProperty Name
)

if ($AgentFiles.Count -eq 0) {
    Write-Warning "No .agent.md files found in agents\$Name. Nothing to do."
    return
}

# ─────────────────────────────────────────────────────────────────────────────
Write-Host "=== Updating agent: $Name ==="

# STEP 1 – BACKUP
Write-Host '  Backup:'
New-Item -ItemType Directory -Path $BackupsRoot -Force | Out-Null
$BackupDir = Join-Path $BackupsRoot "${Name}_$Timestamp"
$BackedUp = $false
foreach ($F in $AgentFiles) {
    $Target = Join-Path $AgentDst $F
    if (Test-Path $Target) {
        if (-not $BackedUp) {
            New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
            $BackedUp = $true
        }
        Copy-Item $Target -Destination $BackupDir -Force
        Write-Host "    $F"
    }
}
if (-not $BackedUp) { Write-Host '    (nothing to back up)' }

# STEP 2 – DELETE
Write-Host '  Delete:'
foreach ($F in $AgentFiles) {
    $Target = Join-Path $AgentDst $F
    if (Test-Path $Target) {
        Remove-Item $Target -Force
        Write-Host "    $F"
    }
}

# STEP 3 – COPY
Write-Host '  Copy:'
New-Item -ItemType Directory -Path $AgentDst -Force | Out-Null
foreach ($F in $AgentFiles) {
    Copy-Item (Join-Path $AgentSrc $F) -Destination (Join-Path $AgentDst $F) -Force
    Write-Host "    $F"
}

Write-Host "  Done.`n"
