"""Validate documentation ownership/links; optionally rebuild category indexes.

Only structural coverage is measured. No claim of semantic game-feature MECE,
playability, remote-link validity or art acceptance is made by this tool.
"""
from pathlib import Path
from collections import Counter
import argparse
import json
import re
import subprocess
from urllib.parse import unquote, urlsplit
import os

ROOT = Path(__file__).resolve().parents[1]
CATEGORIES = {
    "direction": "Product intent, world/story and gameplay requirements",
    "delivery": "Work order, handoff, reporting and documentation governance",
    "systems": "Architecture and implementation checkpoints",
    "art": "Asset production briefs and contracts",
    "research": "External sources and reference confidence",
    "reviews": "Internal evidence, critiques, mock provenance and postmortems",
    "history": "Superseded snapshots and unselected alternatives",
}
STATES = {"current", "design", "proposal", "specification", "checkpoint",
          "evidence", "deferred", "historical", "generated"}


def link_targets(text):
    # Inline links and static HTML hrefs, including those in review-board JS.
    yield from re.findall(r'!?\[[^\]\n]*\]\(<?([^\s)>]+)>?(?:\s+"[^"]*")?\)', text)
    yield from re.findall(r'href=[\"\']([^\"\']+)[\"\']', text)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Refresh registered category indexes")
    args = parser.parse_args()
    manifest = json.loads((ROOT / "docs/DOCUMENTATION_MAP.json").read_text(encoding="utf-8"))
    records = manifest["documents"]
    errors = []
    counts = Counter(r["path"] for r in records)
    errors += [f"Duplicate ownership: {p}" for p, n in counts.items() if n != 1]
    for r in records:
        path = Path(r["path"])
        if path.is_absolute() or ".." in path.parts or not r["path"].startswith("docs/"):
            errors.append(f"Invalid documentation path: {r['path']}")
            continue
        if r["category"] not in CATEGORIES or r["status"] not in STATES:
            errors.append(f"Invalid category/status: {r['path']}")
        if not r.get("title"):
            errors.append(f"Missing title: {r['path']}")
        expected = ("delivery" if path.parent.as_posix() == "docs" else
                    "research" if path.parts[1] == "parity" else
                    "reviews" if path.parts[1] == "ui-review" else path.parts[1])
        if r["category"] != expected:
            errors.append(f"Placement disagrees with owner: {r['path']}")
    # Validate first; --write must never write unregistered destinations.
    for category, purpose in CATEGORIES.items():
        dest = f"docs/{category}/README.md"
        if dest not in counts:
            errors.append(f"Unregistered category index: {dest}")
    if errors:
        raise SystemExit("\n".join(errors))
    for category, purpose in CATEGORIES.items():
        dest = ROOT / f"docs/{category}/README.md"
        rows = [r for r in records if r["category"] == category and r["path"] != dest.relative_to(ROOT).as_posix()]
        lines = [f"# {category.title()}", "", purpose + ".", "",
                 "[Documentation map and ownership rules](../README.md). Generated from DOCUMENTATION_MAP.json; update the registry, then run `python tools/DocumentationReport.py --write` from the repository root.", "",
                 "Status is the document's role, not a game-completion claim. The task board alone owns execution order.", "",
                 "| Document | Role |", "|---|---|"]
        for r in sorted(rows, key=lambda row: row["path"]):
            rel = os.path.relpath(ROOT / r["path"], dest.parent).replace("\\", "/")
            lines.append(f"| [{r['title'].replace('|', '/')}](<{rel}>) | {r['status']} |")
        content = "\n".join(lines) + "\n"
        if args.write:
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(content, encoding="utf-8", newline="\n")
        elif not dest.exists() or dest.read_text(encoding="utf-8") != content:
            errors.append(f"Stale index: {dest.relative_to(ROOT)} (run --write)")

    actual = {p.relative_to(ROOT).as_posix() for p in (ROOT / "docs").rglob("*") if p.is_file()}
    registered = set(counts)
    errors += [f"Unregistered file: {p}" for p in sorted(actual - registered)]
    errors += [f"Missing registered file: {p}" for p in sorted(registered - actual)]
    for old, new in manifest["moves"].items():
        if (ROOT / old).exists() or new not in registered:
            errors.append(f"Invalid historical move: {old} -> {new}")

    tracked = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split("\0")
    sources = {ROOT / p for p in tracked if p.endswith(".md") and (ROOT / p).is_file()}
    sources |= {ROOT / p for p in registered if Path(p).suffix in {".md", ".html", ".js"}}
    checked = 0
    for source in sorted(sources):
        for target in link_targets(source.read_text(encoding="utf-8-sig")):
            parts = urlsplit(target)
            if parts.scheme or parts.netloc or not parts.path or "${" in target:
                continue
            dest = (source.parent / unquote(parts.path)).resolve()
            # Ignore optional local media/build outputs; validate documentation and
            # supporting source links. Remote URLs and anchor semantics are separate.
            if dest.suffix.lower() not in {".md", ".json", ".tsv", ".html", ".js", ".py", ".ps1", ".gd"}:
                continue
            checked += 1
            if not dest.is_file():
                errors.append(f"Broken local link: {source.relative_to(ROOT)} -> {target}")
    summary = {"files": len(actual), "registered": len(registered),
               "categories": dict(sorted(Counter(r['category'] for r in records).items())),
               "local_links_checked": checked, "errors": errors}
    print(json.dumps(summary, indent=2))
    raise SystemExit(1 if errors else 0)


if __name__ == "__main__":
    main()
