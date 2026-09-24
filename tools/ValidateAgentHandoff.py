"""Check the small, stable subset of the Synthetic Squad handoff contract.

No provider SDK or network access is needed. JSON Schema remains the full contract;
this local guard checks the fields that prevent misrouted or underspecified work.
"""
import argparse
import json
import re
from pathlib import Path


REQUIRED = {"schema_version", "task_id", "phase", "baseline_commit", "objective",
            "project_rules", "allowed_paths", "inputs", "acceptance", "output_contract"}
PHASES = {"specify", "implement", "verify", "visual_review"}


def check(packet: object) -> list[str]:
    if not isinstance(packet, dict):
        return ["packet must be a JSON object"]
    errors = [f"missing {key}" for key in sorted(REQUIRED - packet.keys())]
    if errors:
        return errors
    if packet["schema_version"] != 1:
        errors.append("unsupported schema_version")
    if packet["phase"] not in PHASES:
        errors.append("unknown phase")
    if not re.fullmatch(r"[0-9a-f]{7,40}", str(packet["baseline_commit"])):
        errors.append("baseline_commit must be a Git hash")
    for key in ("task_id", "objective", "output_contract"):
        if not isinstance(packet[key], str) or not packet[key].strip():
            errors.append(f"{key} must be nonempty text")
    for key in ("project_rules", "allowed_paths", "inputs", "acceptance"):
        if not isinstance(packet[key], list):
            errors.append(f"{key} must be a list")
    if isinstance(packet["project_rules"], list) and not packet["project_rules"]:
        errors.append("project_rules cannot be empty")
    if isinstance(packet["acceptance"], list) and not packet["acceptance"]:
        errors.append("acceptance cannot be empty")
    if packet["phase"] == "visual_review":
        visual = packet.get("visual")
        fields = {"target_image", "runtime_image", "state", "resolution", "camera", "evidence_limit"}
        if not isinstance(visual, dict) or fields - visual.keys():
            errors.append("visual_review requires a matched two-image visual packet")
    if "asset_pilot" in packet:
        pilot = packet["asset_pilot"]
        fields = {"brief_path", "concept_image", "target_glb", "godot_wrapper", "acceptance_views"}
        if not isinstance(pilot, dict) or fields - pilot.keys():
            errors.append("asset_pilot lacks the concept-to-Godot path")
        elif not isinstance(pilot["acceptance_views"], list) or len(pilot["acceptance_views"]) < 3:
            errors.append("asset_pilot requires at least three acceptance views")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("packet", type=Path)
    args = parser.parse_args()
    try:
        packet = json.loads(args.packet.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    errors = check(packet)
    for error in errors:
        print("INVALID:", error)
    if errors:
        return 1
    print("Valid bounded handoff:", packet["task_id"], packet["phase"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
