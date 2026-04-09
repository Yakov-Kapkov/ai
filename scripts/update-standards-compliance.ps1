#Requires -Version 5.1
<#
.SYNOPSIS
    Updates the standards-compliance skill in the target .copilot folder.

.DESCRIPTION
    Assembles the skill from two repo locations:
      - skills/standards-compliance/  (SKILL.md)
      - resources/{lang}/standards/   (per-language standards files)

.PARAMETER TargetBase
    Path to the .copilot folder (e.g. C:\Users\USERNAME\.copilot).
#>

param(
    [Parameter(Mandatory)] [string] $TargetBase
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Paths ────────────────────────────────────────────────────────────────────
$RepoRoot    = $PSScriptRoot | Split-Path -Parent
$ResourceSrc = Join-Path $RepoRoot 'resources'
$SkillDst    = Join-Path $TargetBase 'skills\standards-compliance'

$Languages = Get-ChildItem -Path $ResourceSrc -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'standards') } |
    ForEach-Object { $_.Name }

# ─────────────────────────────────────────────────────────────────────────────
# STEPS 1-3 – BACKUP, DELETE, COPY skill folder via update-skill.ps1
& (Join-Path $PSScriptRoot 'update-skill.ps1') -TargetBase $TargetBase -Name 'standards-compliance'

# STEP 4 – COPY common-standards.md from resources/
$CommonSrc = Join-Path $ResourceSrc 'common-standards.md'
$StandardsDst = Join-Path $SkillDst 'standards'
if (Test-Path $CommonSrc) {
    New-Item -ItemType Directory -Path $StandardsDst -Force | Out-Null
    Copy-Item $CommonSrc -Destination $StandardsDst -Force
    Write-Host "    standards\common-standards.md"
} else {
    Write-Warning "    Common standards not found: $CommonSrc"
}

# STEP 5 – COPY standards from resources/{lang}/standards/
Write-Host '  Copy standards:'
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
