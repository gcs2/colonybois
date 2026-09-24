# Synthetic Squad: token-aware development contract

This is the operating contract for optional multi-model work on Frontier Worlds. It changes how bounded tasks are handed off; it does not change the product objective or the production queue. [TASK_BOARD.md](../TASK_BOARD.md) owns priority, [ROADMAP.md](../ROADMAP.md) owns acceptance gates, and [NEXT_SESSION.md](../NEXT_SESSION.md) owns the current handoff.

## Why and when

Use multiple models when a task can be divided into a narrow specification, implementation, and independent review. Keep a small correction with the current worker when handoff overhead exceeds the likely work. Record model calls, input/output tokens and cost when a provider supplies them. Use measured cost and defect rates to revise routing; model names below are preferences, not locked dependencies or proof that a provider is connected.

| Function | Preferred routing | Receives | Produces |
|---|---|---|---|
| Architect | Strong reasoning model, e.g. GPT-6 Astra | Product intent, relevant owner docs, interfaces and constraints | Bounded spec, invariants, acceptance evidence and affected files |
| Implementer | Coding model, e.g. GPT-5.6 Sol or Claude Sonnet | Approved spec and scoped repository context | Patch, tests and actual command output |
| Mechanical verifier | Fast model or deterministic tool | Patch, compiler/test output and acceptance checklist | Machine-readable pass/fail findings |
| Independent critic | Strong reasoning model | Spec, exact source/mock/current evidence and measured state | Specific discrepancy and change request or evidence-limited pass |

The architect and critic can be the same model family, but the critic must not review its own unexamined claims as evidence. The coordinator retains responsibility for integration, save safety, visual quality and backup. Do not split work solely to satisfy this table.

## Context boundary and prompt budget

Each handoff uses `tools/agent_handoff_schema.json` and passes only the target requirement, relevant file excerpts or paths, interface contracts, input fixtures, acceptance commands and known constraints. Run `python tools/ValidateAgentHandoff.py <packet.json>` before dispatch; this dependency-free guard covers required routing fields and asset/visual packets, while the JSON Schema remains the fuller format definition. Include a short `project_rules` digest that preserves user instructions and AGENTS.md requirements. Never use context isolation to hide a constraint. The coordinator keeps the global context and checks the result against it before integration. Avoid repeatedly copying the entire task board, transcript, generated image history or large command logs into worker prompts. Prefer paths, line references, concise diffs and bounded output.

Keep a stable, versioned core contract at the beginning of prompts when the provider supports caching. Treat cache hits as measured provider behavior, not an assurance that a long prompt is free. The preferred output is a concise structured result plus artifact paths. The coordinator may converse with the user normally; structured payloads govern automated **agent-to-agent** transfers.

## One work item through the pipeline

1. **Scope.** Coordinator chooses one TASK_BOARD item, records the baseline commit, touched paths and whether existing files have user or another agent's uncommitted changes. Preserve those edits; use a separate worktree for competing edits. Define evidence at the scale of the claim: actual game screenshot for appearance, native input for interaction, tests for deterministic rules, and export smoke for packaging.
2. **Specify.** Architect states behavior, invariants, data/schema changes, failure cases, visual reference and exclusions. A reviewer can challenge the spec before coding if it is expensive or changes persistence.
3. **Build.** Implementer works only within the declared scope. Deterministic code checks and syntax checks run locally. Small compiler fixes can loop with the implementer without another architect call. Cap retries and escalate a repeated failure with the exact errors and diff.
4. **Review.** Mechanical verification checks declared commands, changed files and save/resource invariants. For visual work, capture the same state at a stated resolution and camera, then compare a target and runtime image. The critic must examine composition, materials, world context, legibility and motion evidence when relevant; an absence of clipping is not art acceptance. The critic returns a bounded change request or a pass limited to observed evidence.
5. **Integrate.** Coordinator inspects the diff, runs the relevant tests and native/export checks required by the change, updates the owning docs, commits and pushes a small checkpoint, and verifies the remote hash. Only then is work called backed up. A proposal or isolated mock is labelled as such and cannot be reported as a playable fix.

Stop optional loops when the next attempt merely reshuffles the same mock, the evidence no longer changes the decision, or costs exceed the scoped value. Return to the task board and the playable acceptance gate.

## Visual review packet

A focused review packet contains one JSON handoff and **two images in this order**: (0) the target reference or approved mock and (1) the actual runtime capture of a matched state. Record source/provenance, view, state, resolution, camera, render build/commit, relevant node bounds and data values. Godot uses `Control` anchors/containers and `CanvasLayer`/`SubViewport`; the attached example's `UI_Toolkit_Flexbox` is not our engine. If layout metadata is unavailable, say `unknown` rather than inventing it. Add separate packets for before/action/after, hover, denial, other resolutions or motion; two images alone cannot establish those behaviors. The critic should report observed deltas, likely cause with confidence, and a change request. It need not be forbidden from identifying code when the coordinator specifically asks for a code review, but visual approval cannot rest on prose alone.

## Primary art lane: GPT concept → Tripo model → Godot

The user's intended production loop is **GPT makes the 2D artistic vision, Tripo reconstructs a textured 3D mesh from that vision, and Godot imports the result**. Start with one scout ship or planet expedition prop. Repeat only after one asset looks and performs well in the actual game camera. This is an art pipeline, not a character creator or a commitment to produce a large asset corpus now.

1. **Asset brief.** Define original silhouette, proportions, color/material language, intended camera distances, target engine size, front direction and pivot, required sockets/hardpoints, motion needs, approximate triangle and texture limits, collision and LOD needs. The brief must name what is distinctive about this asset in Frontier Worlds. Keep gameplay interfaces separate from visual guesses.
2. **GPT 2D concept.** Generate a single isolated object against a plain, contrasting background, with the complete silhouette visible, no overlapping objects, labels, hands, stands, scenery, dramatic foreshortening or hidden rear components. Keep a separate cinematic composition for mood; do **not** crop an object out of a busy scene. Review the full image and silhouette before sending anything to Tripo. Save the prompt, seed/variant if available, image provenance and exact approved file path. A second front/side/back/right sheet can be made from the same design if single-view reconstruction is weak.
3. **Tripo submission.** Begin with one image-to-model pilot. Tripo's [generation API](https://platform.tripo3d.ai/docs/generation) accepts `image_to_model` and a file token or URL; its multi-view mode expects views ordered **front, left, back, right**. Prefer a tested isolated source over the rejected `art/tripo_ready/` crops. Record exact model version, seed, face limit, PBR/UV settings, task ID and charged amount. Inspect all sides of the result before export. A convincing front render alone is insufficient.
4. **Godot import.** Export binary glTF (`.glb`), which [Godot supports as a 3D scene](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html). Import into Godot 4.7.2 as a source asset and create a small inherited wrapper scene for scale, pivot, material overrides, collision and named attachment nodes. Inspect texture/normal orientation, topology, back faces, bounds, draw calls, transparency and memory. Test at orbital and surface camera distances, in motion and under actual game lighting. A valid GLB import is **not** proof that the mesh is ready to ship unchanged.
5. **Acceptance.** Compare the 3D capture against the approved 2D concept and the game's Field Instruments/world style. Check silhouette and materials from front, side and rear, visual continuity under rotation, animation or hardpoint behavior, performance and exported-build loading. Reject, rework in a modeling tool or regenerate based on a named defect. Keep only approved source and provenance in Git; avoid checking in discarded variants.

Tripo is **not connected by this contract**. Its [web app and API bill separately](https://platform.tripo3d.ai/docs/faq); confirm the exact account route, per-pilot price and commercial-use license before a paid submission. No pipeline may upload project art, call a paid API or buy credits until the user has approved a concrete price and license. Store credentials outside Git. `art/tripo_ready/` remains excluded because the previous cropping attempt failed; it is not the source set for this pipeline.

Reusable authored meshes and hand-edited fixes remain valid. A blanket ban on a strong model writing procedural geometry would block useful prototypes without improving quality, so route geometry to the tool that produces the best verified result. Character modeling remains deferred.

## Current application

Recent Gemini work includes committed communicator/export changes at `3b360bc` and `aa86d0e` plus uncommitted HUD, encounter, shader, capture and pod files at the time this contract was written. Treat committed work as a checkpoint to review and the uncommitted work as another worker's active state. Do not overwrite or stage those paths casually. `art/tripo_ready/` remains outside this pipeline decision. The near-term game priority remains visual fidelity and playable flight, not building a general orchestration service.

An API orchestrator may be built after one manual end-to-end task demonstrates lower cost **and** equal or better quality. A first version should validate packets and run local commands with explicit file allowlists and timeouts; provider adapters, caching metrics and spending ceilings follow measured use. This document authorizes no service spend.
