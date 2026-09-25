"""Validate Space Stage source provenance and workflow-source traceability."""
from collections import Counter
from html import unescape
from pathlib import Path
import json
import re
import sys
from urllib.parse import parse_qs, unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
INVENTORY_PATH = ROOT / "docs/parity/reference_inventory.json"
COVERAGE_PATH = ROOT / "docs/parity/experience_coverage.json"
DOC_SUFFIXES = {".md", ".json", ".tsv", ".html", ".js"}


def canonical_url(raw: str) -> str:
    """Normalize markdown/JSON punctuation, URL aliases and YouTube timestamps."""
    value = unescape(raw)
    while value:
        tail = value[-1]
        if tail in (".", ",", ";", ":", "!", "?", "]", "}", ">", '"', "'", chr(96), "*"):
            value = value[:-1]
        elif tail == ")" and value.count(")") > value.count("("):
            value = value[:-1]
        else:
            break
    parsed = urlsplit(value)
    host = parsed.netloc.lower().split(":")[0]
    path = unquote(parsed.path).rstrip("/")
    if host in {"youtube.com", "www.youtube.com", "m.youtube.com"}:
        video_id = parse_qs(parsed.query).get("v", [""])[0]
        return f"youtube:{video_id}"
    if host == "youtu.be":
        return f"youtube:{path.strip('/')}"
    if host.endswith("steamstatic.com"):
        host = "steamstatic.com"
    if host.startswith("www.") and host.endswith("spore.com"):
        host = host[4:]
    return f"{host}{path}"


def is_tracked_source(raw: str) -> bool:
    host = urlsplit(raw).netloc.lower().split(":")[0]
    return any(host.endswith(domain) for domain in (
        "fandom.com", "strategywiki.org", "youtube.com", "youtu.be",
        "gamepressure.com", "spore.com", "steamstatic.com",
        "modapi-docs.sporecommunity.com",
    ))


def main() -> int:
    inventory = json.loads(INVENTORY_PATH.read_text(encoding="utf-8"))
    coverage = json.loads(COVERAGE_PATH.read_text(encoding="utf-8"))
    sources = inventory["sources"]
    source_ids = set(sources)
    errors: list[str] = []

    if len(sources) != inventory.get("source_census", {}).get("registered_source_records"):
        errors.append("source_census registered_source_records does not match the source map")

    group_fields = {
        "SporeWiki (Fandom)": "sporewiki_pages",
        "StrategyWiki": "strategywiki_pages",
        "YouTube": "youtube_videos",
        "Gamepressure guide": "gamepressure_guides",
        "Gamepressure visual reference": "gamepressure_visual_references",
        "Official EA/Maxis": "official_ea_maxis_references",
        "Community reverse-engineering reference": "community_reverse_engineering_references",
    }
    group_counts = Counter(source.get("source_group", "") for source in sources.values())
    for group, census_field in group_fields.items():
        if group_counts[group] != inventory["source_census"].get(census_field):
            errors.append(f"source census mismatch for {group}: {group_counts[group]} indexed")

    registered_urls: dict[str, str] = {}
    for source_id, source in sources.items():
        for required in ("url", "source_group", "title", "evidence", "limits", "project_refs"):
            if not source.get(required):
                errors.append(f"{source_id}: missing {required}")
        key = canonical_url(source["url"])
        if key in registered_urls:
            errors.append(f"duplicate canonical URL: {source_id} and {registered_urls[key]} ({key})")
        registered_urls[key] = source_id
        for reference in source.get("project_refs", []):
            target = ROOT / reference
            if not target.is_file():
                errors.append(f"{source_id}: project reference does not exist: {reference}")

    categories = {category["id"]: category for category in coverage["categories"]}
    if len(categories) != len(coverage["categories"]):
        errors.append("duplicate workflow category IDs")
    flow_ids = set()
    for flow in coverage["flows"]:
        if flow["id"] in flow_ids:
            errors.append(f"duplicate workflow ID: {flow['id']}")
        flow_ids.add(flow["id"])
        if flow.get("category") not in categories:
            errors.append(f"{flow['id']}: category is not registered")
        refs = flow.get("source_refs", [])
        if not refs:
            errors.append(f"{flow['id']}: no source_refs")
        for source_id in refs:
            if source_id not in source_ids:
                errors.append(f"{flow['id']}: unresolved source ID {source_id}")

    found_urls: set[str] = set()
    for document in (ROOT / "docs").rglob("*"):
        if not document.is_file() or document.suffix.lower() not in DOC_SUFFIXES:
            continue
        try:
            text = document.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for raw in re.findall(r"https?://\S+", text):
            if is_tracked_source(raw):
                found_urls.add(canonical_url(raw))

    missing = sorted(found_urls - set(registered_urls))
    for url in missing:
        errors.append(f"unregistered cited URL: {url}")

    print(f"Reference registry: {len(sources)} sources across {len(group_counts)} groups.")
    print(f"Workflow denominator: {len(flow_ids)} rows across {len(categories)} categories; all rows have resolvable source IDs: {not any('unresolved source ID' in item or 'no source_refs' in item for item in errors)}.")
    print(f"Relevant URLs in maintained docs: {len(found_urls)}; unregistered: {len(missing)}.")
    for group, count in sorted(group_counts.items()):
        print(f"  {group}: {count}")
    if errors:
        print("Errors:")
        for error in errors:
            print(f"  - {error}")
        return 1
    print("Source IDs, URL coverage, canonical uniqueness, census totals and project paths are valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
