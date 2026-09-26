# Resume here

Updated 26 September 2026. This is the operational handoff, not a second queue. TASK_BOARD.md is the sole production queue; PRODUCTION_GOAL.md owns the objective and ROADMAP.md owns milestone gates. Main checkout remains protected.

## Direction

The source → approved mock → runtime audit is closed with an insufficiency finding. Available Spore stills and the manual establish scale-specific states and documented controls, not continuous motion, timing, or audio. Do not claim source/runtime transition parity. The five approved/liked stills remain together under art/visual-canon: Morrow surface, orbit, system, approach, and supporting galaxy composition.

Worlds follow the existing pipeline in systems/PLANET_GENERATION.md: persistent recipe → one spherical sampler → stable regions and independent feature streams → biome habitat kits → bounded moving window → sparse stable-ID changes → one connected playable expedition. Do not add planets, species, or decorative density ahead of the Morrow movement/persistence gate. Actual runtime visuals remain rejected against the pinned surface target.

## Protected checkout and active branches

- Main checkout: C:\Users\zephy\Documents\ChatGPT\New project, branch codex/frontier-prototype, HEAD 46fc837c3a745c5147ce6d127e2704a4eb6c026d. It has unrelated dirty edits and was last known six commits behind origin. Do not stage, reset, merge, rebase, or overwrite it.
- Clean Sol integration worktree: C:\Users\zephy\.codex\worktrees\r01-transition-audit\New project, branch codex/r01-v01-v04-transition-audit, HEAD c9f44065dc0fab4aa06e1f3ba6ab6197a7314793. It is clean and is the integration point after worker patches are reviewed. Remote verification previously failed because GitHub port 443 was unreachable; retry only when checkpointing.
- V04 worker worktree: C:\Users\zephy\.codex\worktrees\v04-morrow-world-pipeline\New project, branch codex/v04-morrow-whole-planet, baseline c9f44065dc0fab4aa06e1f3ba6ab6197a7314793. The runtime façade and semantic feature streams are committed and pushed; remote hash verified at 3c5d75fd6b4884ff09893a200bdf0d65e2a8297d. Godot imports left generated .import edits and .uid sidecars; keep them out of Git.
- Older V01 review worktree: C:\Users\zephy\.codex\worktrees\v01-field-instruments-runtime\New project, branch codex/v01-field-instruments-runtime, baseline c9f44065dc0fab4aa06e1f3ba6ab6197a7314793. Preserve its uncommitted HUD patch and generated .import/.uid metadata. Its CaptureFlightScene attempt stalled over two minutes without PNGs; do not repeat that command unchanged.
- Active V01 HUD worker: C:\Users\zephy\.codex\worktrees\v01-hud-surface-pass\New project, branch codex/v01-hud-surface-pass, baseline a51f167a8037cbb9253ad2f433950f14d3f2fdb3. It owns a HUD-only recompose against the approved surface mock. Sol serialized Godot runs; visual acceptance awaits an independent critic.

Other existing worktrees are historical or inactive; preserve them unless their status and contents are inspected first. All worktrees belong to the same Git repository. Do not create another project copy or another production queue.

## V04 world checkpoint and evidence

The prototype now routes Morrow height/color through PlanetGenerator and features through PlanetSurfaceWindow. PlanetSurfaceRuntime groups sample, color, geodesic advance, bounded window, and local projection calls. Named provisional values include 16 km radius, 512 m region cells, 1.5 km feature window, 34 m height scale, and a 1.2 km tangent-frame limit.

This is not yet spherical player movement or streaming. Encounter still moves in flat X/Z from a fixed landing anchor, builds one static terrain mesh and landing-centered feature window, and returns from tangent coordinates. Saved surface_direction remains derived metadata. The session test teleports to the adjacent seam, so a player-steered region crossing is unproven.

Before the façade, test_surface_exploration passed 50 assertions in 1.65 s and test_expedition_session passed 52 in 18.85 s. After scale/cache revisions, the session check passed 52 assertions in 42.18 s; that is test wall time, not a runtime performance profile. The final cache hot-path change removed full-recipe JSON serialization, then test_planet_surface_runtime passed 12 checks in 0.59 s. The follow-up test_planet_surface_window passed 330 assertions in 0.61 s after semantic streams were isolated. The session check was not rerun after the cache optimization. It teleports to the 620 m seam, so player-steered crossing remains unproven.

The live 1920×1080 Morrow surface capture is ignored at artifacts/visual-critic-surface-pass/actual-surface-1080.png in the V04 worktree. Independent critique rejects it: flat olive terrain, faceted props, sparse foreground plants, no visible lake/fauna/ship, distant relay, low-contrast chart, and competing HUD panels. This is not visual acceptance. No performance measurement, native-input playtest, or fun review was done.

## Next work

Region and semantic-kind streams now generate independent feature records with kind-local slot IDs; test_planet_surface_window verifies a cover-count/draw change does not move or rename rocks, flora, fauna or mineral. No saved feature deltas exist yet, so migration is untested. Next make the saved radial direction authoritative for movement and return, recenter the bounded terrain/feature window around it, and persist sparse changes by stable feature/site ID. Prove a player-steered Basin → adjacent-region trip with one useful opportunity, then leave for orbit, save/reload, and return to the same place. Keep scene composition and the full HUD against the pinned mock as a separate visual gate. Do not widen the travel radius again or claim whole-planet exploration.

V01 HUD recomposition is active in its own worktree. Diagnose the old capture stall before any retry; require a same-state runtime capture and independent critique before claiming mock fidelity. After both V01 and V04 are reviewed, use the clean Sol integration worktree, then continue system-map composition and the M1 connected voyage as ordered in TASK_BOARD.md.

## Run discipline

Use Godot 4.7.2. Check existing processes and serialize imports, tests, and captures. Use per-worktree RunGodot.ps1 profiles. Select only tests that cover changed behavior; no full suite unless a major integration gate or explicit request. Use the bundled Python executable for tools/DocumentationReport.py after documentation moves/additions. Keep generated captures and imported runtimes out of Git. Do not make purchases or accept paid terms without explicit approval.