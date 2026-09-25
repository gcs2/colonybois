# Synthetic Squad: token-aware development contract

This is the operating contract for bounded multi-model work on Frontier Worlds. It changes how tasks are handed off; it does not change the product objective or add a production queue. [TASK_BOARD.md](../TASK_BOARD.md) remains the sole production queue, [ROADMAP.md](../ROADMAP.md) owns acceptance gates, and [NEXT_SESSION.md](../NEXT_SESSION.md) owns the current handoff.

## Why and when

Use multiple models when work can be split into narrow, independent implementations. Keep a small correction with the current worker when handoff overhead exceeds the likely work. Record model calls, input/output tokens and cost when the runtime supplies them. Use measured delivery, rework and cost to revise routing; model names are preferences, not evidence.

| Function | Pilot routing | Receives | Produces |
|---|---|---|---|
| Sol coordinator | GPT-6 Sol, high reasoning effort | Goal, owner documents, task-board item and verified baseline | Bounded contracts, assignment packets, integration, owning-record updates and concise report |
| Implementation workers | Up to three GPT-6 Luna agents, high reasoning effort; one independent item each | Scoped task packet, compact project context and assignment roster | Commit, changed player behavior, evidence, selected checks/costs and remaining gaps |
| Mechanical verification | Deterministic tools; model assistance only for interpretation | Patch, declared test budget and acceptance checklist | Exact command outcomes, durations and bounded findings |
| Independent visual critic | One review after an integrated presentation change, when material | Matched source, approved mock and actual runtime evidence | Specific discrepancy/change request or a pass limited to inspected states |

Sol owns product reasoning, integration, save safety, visual review, checkpointing and backup. A critic cannot approve its own unexamined work. Do not fan out solely to fill slots.

This routing follows [OpenAI's multi-agent guidance](https://developers.openai.com/api/docs/guides/agents-api/multi-agent) and [GPT-6 model guidance](https://developers.openai.com/api/docs/guides/latest-model): parallelize bounded independent work, account for coordination/token costs, and use Sol for demanding coordination with Luna for focused implementation.

## Sol-led implementation pilot

The first fan-out is gated on the active HUD and source/mock coverage audit reaching its own checkpoint. Until then, prepare workflow changes only; do not start parallel feature implementation. After that checkpoint, Sol re-reads the task board and selects up to its next three items only when code ownership, interfaces and dependencies are independent. Use fewer or serialize work when the queue does not split cleanly. This contract does not reorder the board or create another queue.

Before dispatch, Sol creates one clean Git worktree and branch per worker from the same verified baseline. Each assignment packet states:

- Task-board ID and the single player-facing outcome to change.
- Baseline commit, exact worktree path and branch.
- Allowed files; all other files are prohibited unless Sol approves an interface change.
- Fixed code/data/persistence interfaces and invariants, plus explicit exclusions.
- Dependencies and a compact roster of the other workers' task IDs, file areas and interface boundaries.
- Acceptance evidence, named domain tests, verification budget and checks that must not be repeated when unchanged.

A worker requests interface or shared-file changes through Sol and pauses dependent edits until the contract is resolved. Two workers never mutate the same campaign state or file set concurrently. If a task needs shared code/schema or mutable save state, Sol defines the interface first or schedules the tasks in order. Workers commit locally but do not push or merge each other's branches. Sol inspects and integrates results, updates owning records, then makes the small verified checkpoint and checks its remote hash.

Each worker returns a compact handoff: task ID; branch/worktree and baseline-to-commit hashes; player behavior changed; evidence; exact checks and elapsed times; integration concerns; remaining gaps; and token/cost figures only when exposed by the runtime. Sol returns one concise summary across the swarm. For material presentation work, integrate first and request one independent visual review of matched runtime states. A critic's review does not replace human acceptance.

Use `tools/Test.ps1 -List`, `-Tests <names> -ProfileId <unique-id>`, or explicit `-All -ProfileId <unique-id>`. No-argument invocation runs nothing. Test only affected behavior, record per-test duration and avoid rerunning unchanged suites. Full-suite runs require a major integration gate or explicit request. `tools/Start-AgentGame.ps1 -ProfileId <unique-id>` opens a worktree in its isolated profile. Give every simultaneously running process a distinct ID; imports and performance measurements remain serialized.

For the first three eligible items, compare delivered and accepted player behavior per elapsed time, integration rework, regressions, verification/runtime cost and available token use. Retain three-worker concurrency only if it improves delivery without increasing integration defects; otherwise reduce concurrency. This is a measured pilot, not a permanent agent quota.

## Context boundary and prompt budget

Each handoff uses `tools/agent_handoff_schema.json` and passes only the target requirement, relevant file excerpts or paths, interface contracts, input fixtures, acceptance commands and known constraints. Run `python tools/ValidateAgentHandoff.py <packet.json>` before dispatch; this dependency-free guard covers required routing fields and asset/visual packets, while the JSON Schema remains the fuller format definition. Include a short `project_rules` digest that preserves user instructions and AGENTS.md requirements. Never use context isolation to hide a constraint. The coordinator keeps the global context and checks the result against it before integration. Avoid repeatedly copying the entire task board, transcript, generated image history or large command logs into worker prompts. Prefer paths, line references, concise diffs and bounded output.

Keep a stable, versioned core contract at the beginning of prompts when the provider supports caching. Treat cache hits as measured provider behavior, not an assurance that a long prompt is free. The preferred output is a concise structured result plus artifact paths. The coordinator may converse with the user normally; structured payloads govern automated **agent-to-agent** transfers.

## One work item through the pipeline

1. **Scope.** Coordinator chooses one TASK_BOARD item, records the baseline commit, touched paths and whether existing files have user or another agent's uncommitted changes. Preserve those edits; use a separate worktree for competing edits. Define evidence at the scale of the claim: actual game screenshot for appearance, native input for interaction, tests for deterministic rules, and export smoke for packaging.
2. **Specify.** Sol states behavior, invariants, data/schema changes, failure cases, visual reference and exclusions. If a task is expensive or changes persistence, Sol can request one bounded challenge before implementation.
3. **Build.** The assigned worker works only within the declared scope. Run only the selected domain checks. Small compiler fixes can loop with the worker without another coordination round. Cap retries and escalate a repeated failure with the exact error and diff.
4. **Review.** Mechanical verification checks declared commands, changed files and save/resource invariants. For visual work, capture the same state at a stated resolution and camera, then compare the approved target and actual runtime. The critic examines composition, materials, world context, legibility and motion evidence when relevant; absence of clipping is not art acceptance. The critic returns a bounded change request or a pass limited to observed evidence.
5. **Integrate.** Sol inspects the diff, runs relevant tests and required native/export checks, updates owning docs, commits and pushes a small checkpoint, and verifies the remote hash. Only then is work called backed up. A proposal or isolated mock is labelled as such and cannot be reported as a playable fix.

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

The verified baseline, active worktree and current state live in [NEXT_SESSION.md](../NEXT_SESSION.md); priority and sequencing live only in [TASK_BOARD.md](../TASK_BOARD.md). Recheck both before every dispatch. Do not copy commit-specific status, stale uncommitted-file lists or a competing queue into this contract. `art/tripo_ready/` remains outside the asset decision. Near-term product work stays focused on playability and visual fidelity.

This pilot adds no paid external orchestration service or second queue. Existing local handoff validation remains sufficient while the team measures this workflow. Any future orchestration investment requires measured evidence and separate user approval; this contract authorizes no service spend.
