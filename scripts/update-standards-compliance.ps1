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

$Languages = @('python', 'typescript')

# ─────────────────────────────────────────────────────────────────────────────
# STEPS 1-3 – BACKUP, DELETE, COPY skill folder via update-skill.ps1
& (Join-Path $PSScriptRoot 'update-skill.ps1') -TargetBase $TargetBase -Name 'standards-compliance'

# STEP 4 – COPY standards from resources/{lang}/standards/
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
