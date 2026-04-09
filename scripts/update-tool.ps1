#Requires -Version 5.1
<#
.SYNOPSIS
    Updates a tool's agent and prompt files in the target .copilot folder.

.PARAMETER TargetBase
    Path to the .copilot folder (e.g. C:\Users\USERNAME\.copilot).

.PARAMETER Name
    Tool name (e.g. sda). Expects source at: tools/{Name}/agents/ and tools/{Name}/prompts/.
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

$AgentsSrc  = Join-Path $RepoRoot "tools\$Name\agents"
$PromptsSrc = Join-Path $RepoRoot "tools\$Name\prompts"
$AgentsDst  = Join-Path $TargetBase 'agents'
$PromptsDst = Join-Path $TargetBase 'prompts'

# ── Discover managed files from source ────────────────────────────────────────
function Get-SourceFiles($Path, $Filter) {
    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -Filter $Filter -File | Select-Object -ExpandProperty Name
    } else {
        @()
    }
}

[string[]] $AgentFiles  = @(Get-SourceFiles $AgentsSrc  '*.agent.md')
[string[]] $PromptFiles = @(Get-SourceFiles $PromptsSrc '*.prompt.md')

if ($AgentFiles.Count -eq 0 -and $PromptFiles.Count -eq 0) {
    Write-Warning "No agent or prompt files found in tools\$Name. Nothing to do."
    return
}

# ── Helper ────────────────────────────────────────────────────────────────────
function Backup-Files($Subfolder, $SrcDir, [string[]]$FileNames) {
    $BackupDir = Join-Path (Join-Path $BackupsRoot "${Name}_$Timestamp") $Subfolder
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    foreach ($F in $FileNames) {
        $Src = Join-Path $SrcDir $F
        if (Test-Path $Src) {
            Copy-Item $Src -Destination $BackupDir -Force
            Write-Host "    $Subfolder\$F"
        }
    }
}

# ─────────────────────────────────────────────────────────────────────────────
Write-Host "=== Updating tool: $Name ==="

# STEP 1 – BACKUP
Write-Host '  Backup:'
New-Item -ItemType Directory -Path $BackupsRoot -Force | Out-Null
if ($AgentFiles.Count -gt 0)  { Backup-Files 'agents'  $AgentsDst  $AgentFiles }
if ($PromptFiles.Count -gt 0) { Backup-Files 'prompts' $PromptsDst $PromptFiles }

# STEP 2 – DELETE
Write-Host '  Delete:'
foreach ($F in $AgentFiles) {
    $Target = Join-Path $AgentsDst $F
    if (Test-Path $Target) { Remove-Item $Target -Force; Write-Host "    agents\$F" }
}
foreach ($F in $PromptFiles) {
    $Target = Join-Path $PromptsDst $F
    if (Test-Path $Target) { Remove-Item $Target -Force; Write-Host "    prompts\$F" }
}

# STEP 3 – COPY
Write-Host '  Copy:'
foreach ($F in $AgentFiles) {
    Copy-Item (Join-Path $AgentsSrc $F) -Destination (Join-Path $AgentsDst $F) -Force
    Write-Host "    agents\$F"
}
foreach ($F in $PromptFiles) {
    Copy-Item (Join-Path $PromptsSrc $F) -Destination (Join-Path $PromptsDst $F) -Force
    Write-Host "    prompts\$F"
}

Write-Host "  Done.`n"
