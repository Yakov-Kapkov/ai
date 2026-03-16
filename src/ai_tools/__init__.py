"""
ai-tools-cli — install/update/uninstall AI tools from the Yakov-Kapkov/ai repo.

Usage:
    ai-tools list
    ai-tools install sda
    ai-tools install sda --language typescript
    ai-tools update sda
    ai-tools uninstall sda

Or without installing the CLI:
    uvx --from git+https://github.com/Yakov-Kapkov/ai.git ai-tools install sda
"""

from __future__ import annotations

import shutil
import json
from pathlib import Path
from typing import Optional

import typer
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

app = typer.Typer(
    name="ai-tools",
    help="Install AI agents, prompts, and workflows into your project.",
    add_completion=False,
)
console = Console()

# ---------------------------------------------------------------------------
# Tool registry
# ---------------------------------------------------------------------------

TOOLS: dict[str, dict] = {
    "sda": {
        "description": "Software Development Assistant — sda-init, sda-feature-designer, sda-dev agents.",
        "source_dirs": [
            ("tools/sda/agents",         ".github/agents"),
            ("tools/sda/prompts",        ".github/prompts"),
            ("tools/sda/.dev-assistant", ".dev-assistant"),
        ],
    },
    # "tdd-workflow": {
    #     "description": "Orchestrated TDD lifecycle across focused sub-agents.",
    #     "source_dirs": [
    #         ("agents/tdd-workflow", ".github/agents/tdd-workflow"),
    #         ("prompts/tdd",         ".github/prompts/tdd"),
    #     ],
    # },
    # "feature-designer": {
    #     "description": "BA-style agent that brainstorms and designs features — no implementation.",
    #     "source_dirs": [
    #         ("agents/feature-designer", ".github/agents/feature-designer"),
    #     ],
    # },
}

REGISTRY_FILE = ".ai-tools-registry.json"

TOOL_ARG = typer.Argument(help=f"Tool to act on. Available: {', '.join(TOOLS)}.")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _repo_root() -> Path:
    return Path(__file__).parent.parent.parent


def _project_root() -> Path:
    return Path.cwd()


def _load_registry(project: Path) -> dict:
    reg_file = project / REGISTRY_FILE
    if reg_file.exists():
        try:
            return json.loads(reg_file.read_text(encoding="utf-8"))
        except Exception:
            pass
    return {}


def _save_registry(project: Path, registry: dict) -> None:
    (project / REGISTRY_FILE).write_text(json.dumps(registry, indent=2), encoding="utf-8")


def _resolve_tool(tool: str) -> dict:
    if tool not in TOOLS:
        console.print(f"[red]Error:[/red] Unknown tool '{tool}'.")
        console.print(f"Available: {', '.join(TOOLS)}")
        raise typer.Exit(1)
    return TOOLS[tool]


def _copy_tool(tool: str, project: Path, *, overwrite: bool = False) -> list[str]:
    repo = _repo_root()
    copied: list[str] = []

    for src_rel, dst_rel in TOOLS[tool]["source_dirs"]:
        src = repo / src_rel
        dst = project / dst_rel

        if not src.exists():
            console.print(f"[yellow]Warning:[/yellow] Source not found: {src_rel} — skipping.")
            continue

        for item in src.rglob("*"):
            if not item.is_file():
                continue
            rel = item.relative_to(src)
            target = dst / rel
            if target.exists() and not overwrite:
                console.print(f"  [dim]skip[/dim]  {dst_rel}/{rel}")
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(item, target)
            copied.append(str(target.relative_to(project)))
            console.print(f"  [green]copy[/green]  {dst_rel}/{rel}")

    return copied


def _remove_tool(tool: str, project: Path, installed_files: list[str]) -> None:
    for rel in installed_files:
        target = project / rel
        if target.exists():
            target.unlink()
            console.print(f"  [red]remove[/red]  {rel}")

    for _, dst_rel in TOOLS[tool]["source_dirs"]:
        dst = project / dst_rel
        if dst.is_dir():
            for dirpath in sorted(dst.rglob("*"), reverse=True):
                if dirpath.is_dir():
                    try:
                        dirpath.rmdir()
                    except OSError:
                        pass
            try:
                dst.rmdir()
            except OSError:
                pass


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

@app.command(name="list")
def list_tools() -> None:
    """List available tools and their installation status."""
    project = _project_root()
    registry = _load_registry(project)

    table = Table(show_header=True, header_style="bold cyan")
    table.add_column("Tool", style="bold")
    table.add_column("Status")
    table.add_column("Description")

    for name, spec in TOOLS.items():
        status = "[green]installed[/green]" if name in registry else "[dim]not installed[/dim]"
        table.add_row(name, status, spec["description"])

    console.print(table)


@app.command()
def install(
    tool: str = TOOL_ARG,
    force: bool = typer.Option(False, "--force", "-f", help="Overwrite existing files."),
    language: Optional[str] = typer.Option(
        None, "--language", "-l",
        help="Also copy language resources into .dev-assistant/resources/ (typescript | python, comma-separated).",
    ),
) -> None:
    """Install a tool's agents and prompt files into the current project."""
    _resolve_tool(tool)
    project = _project_root()
    registry = _load_registry(project)

    if tool in registry and not force:
        console.print(f"[yellow]'{tool}' is already installed.[/yellow] Use [cyan]--force[/cyan] to overwrite, or [cyan]ai-tools update {tool}[/cyan].")
        raise typer.Exit(0)

    console.print(Panel(f"Installing [bold]{tool}[/bold]…", border_style="cyan"))
    copied = _copy_tool(tool, project, overwrite=force)

    if language:
        repo = _repo_root()
        for lang in [l.strip() for l in language.split(",")]:
            lang_src = repo / "resources" / lang
            if not lang_src.exists():
                console.print(f"[yellow]Warning:[/yellow] No resources found for language '{lang}'.")
                continue
            lang_dst = project / ".dev-assistant" / "resources" / lang
            for item in lang_src.rglob("*"):
                if not item.is_file():
                    continue
                rel = item.relative_to(lang_src)
                target = lang_dst / rel
                if target.exists() and not force:
                    console.print(f"  [dim]skip[/dim]  .dev-assistant/resources/{lang}/{rel}")
                    continue
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(item, target)
                copied.append(str(target.relative_to(project)))
                console.print(f"  [green]copy[/green]  .dev-assistant/resources/{lang}/{rel}")

    registry[tool] = {"files": copied}
    _save_registry(project, registry)
    console.print(f"\n[bold green]✓[/bold green] '{tool}' installed ({len(copied)} files).")


@app.command()
def update(
    tool: str = TOOL_ARG,
) -> None:
    """Update an installed tool by overwriting its files with the latest from the repo."""
    _resolve_tool(tool)
    project = _project_root()
    registry = _load_registry(project)

    if tool not in registry:
        console.print(f"[yellow]'{tool}' is not installed.[/yellow] Run [cyan]ai-tools install {tool}[/cyan] first.")
        raise typer.Exit(1)

    console.print(Panel(f"Updating [bold]{tool}[/bold]…", border_style="cyan"))
    copied = _copy_tool(tool, project, overwrite=True)
    registry[tool] = {"files": copied}
    _save_registry(project, registry)
    console.print(f"\n[bold green]✓[/bold green] '{tool}' updated ({len(copied)} files).")


@app.command()
def uninstall(
    tool: str = TOOL_ARG,
    yes: bool = typer.Option(False, "--yes", "-y", help="Skip confirmation prompt."),
) -> None:
    """Remove a previously installed tool's files from the current project."""
    _resolve_tool(tool)
    project = _project_root()
    registry = _load_registry(project)

    if tool not in registry:
        console.print(f"[yellow]'{tool}' is not installed.[/yellow]")
        raise typer.Exit(0)

    installed_files = registry[tool].get("files", [])

    if not yes:
        console.print(f"This will remove [bold]{len(installed_files)}[/bold] files for '[bold]{tool}[/bold]'.")
        typer.confirm("Continue?", abort=True)

    console.print(Panel(f"Uninstalling [bold]{tool}[/bold]…", border_style="red"))
    _remove_tool(tool, project, installed_files)
    del registry[tool]
    _save_registry(project, registry)
    console.print(f"\n[bold green]✓[/bold green] '{tool}' uninstalled.")


def main() -> None:
    app()


if __name__ == "__main__":
    main()
