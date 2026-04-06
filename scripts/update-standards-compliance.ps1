#Requires -Version 5.1
<#
.SYNOPSIS
    Updates the standards-compliance skill in the target .copilot folder.

.DESCRIPTION
    Assembles the skill from two repo locations:
      - skills/standards-compliance/  (SKILL.md)
      - resources/{lang}/standards/   (per-language standards files)

.PARAMETER TargetBase
    Path to the .copilot folder (e.g. C:\Users\C298270\.copilot).
#>

param(
    [Parameter(Mandatory)] [string] $TargetBase
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Paths ────────────────────────────────────────────────────────────────────
$RepoRoot    = $PSScriptRoot | Split-Path -Parent
$BackupsRoot = Join-Path $TargetBase 'backups'
$Timestamp   = Get-Date -Format 'yyyy-MM-dd_HH_mm'

$SkillSrc    = Join-Path $RepoRoot 'skills\standards-compliance'
$ResourceSrc = Join-Path $RepoRoot 'resources'
$SkillDst    = Join-Path $TargetBase 'skills\standards-compliance'

$Languages = @('python', 'typescript')

# ─────────────────────────────────────────────────────────────────────────────
Write-Host '=== Updating skill: standards-compliance ==='

# STEP 1 – BACKUP
Write-Host '  Backup:'
if (Test-Path $SkillDst) {
    $BackupDir = Join-Path $BackupsRoot "standards-compliance-$Timestamp"
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

# SKILL.md from skills/standards-compliance/
New-Item -ItemType Directory -Path $SkillDst -Force | Out-Null
Copy-Item (Join-Path $SkillSrc 'SKILL.md') -Destination $SkillDst -Force
Write-Host '    SKILL.md'

# Standards from resources/{lang}/standards/
foreach ($Lang in $Languages) {
    $Src = Join-Path $ResourceSrc "$Lang\standards"
    $Dst = Join-Path $SkillDst "standards\$Lang"
    if (Test-Path $Src) {
        New-Item -ItemType Directory -Path $Dst -Force | Out-Null
        Get-ChildItem -Path $Src -File | ForEach-Object {
            Copy-Item $_.FullName -Destination $Dst -Force
            Write-Host "    standards\$Lang\$($_.Name)"
        }
    } else {
        Write-Warning "    Source not found: $Src"
    }
}

Write-Host "  Done.`n"
