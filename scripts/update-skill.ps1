#Requires -Version 5.1
<#
.SYNOPSIS
    Updates a skill folder in the target .copilot folder.

.PARAMETER TargetBase
    Path to the .copilot folder (e.g. C:\Users\USERNAME\.copilot).

.PARAMETER Name
    Skill name (e.g. commit, standards-compliance). Expects source at: skills/{Name}/.
#>

param(
    [Parameter(Mandatory)] [string] $TargetBase,
    [Parameter(Mandatory)] [string] $Name
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Paths ────────────────────────────────────────────────────────────────────
$RepoRoot    = $PSScriptRoot | Split-Path -Parent
$BackupsRoot = Join-Path $TargetBase 'backups'
$Timestamp   = Get-Date -Format 'yyyy-MM-dd_HH_mm'

$SkillSrc = Join-Path $RepoRoot "skills\$Name"
$SkillDst = Join-Path $TargetBase "skills\$Name"

if (-not (Test-Path $SkillSrc)) {
    Write-Warning "Source skill folder not found: $SkillSrc. Nothing to do."
    return
}

# ─────────────────────────────────────────────────────────────────────────────
Write-Host "=== Updating skill: $Name ==="

# STEP 1 – BACKUP
Write-Host '  Backup:'
if (Test-Path $SkillDst) {
    $BackupDir = Join-Path $BackupsRoot "$Name-$Timestamp"
    New-Item -ItemType Directory -Path (Split-Path $BackupDir) -Force | Out-Null
    Copy-Item $SkillDst -Destination $BackupDir -Recurse -Force
    Write-Host "    -> $BackupDir"
} else {
    Write-Host '    (nothing to back up)'
}

# STEP 2 – DELETE
Write-Host '  Delete:'
if (Test-Path $SkillDst) {
    Remove-Item $SkillDst -Recurse -Force
    Write-Host "    $SkillDst"
} else {
    Write-Host '    (nothing to delete)'
}

# STEP 3 – COPY
Write-Host '  Copy:'
Copy-Item $SkillSrc -Destination $SkillDst -Recurse -Force
Get-ChildItem $SkillSrc -Recurse -File | ForEach-Object {
    $Rel = $_.FullName.Substring($SkillSrc.Length + 1)
    Write-Host "    $Rel"
}

Write-Host "  Done.`n"
