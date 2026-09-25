# Resume here

Updated 24 September 2026. Read the [documentation map](README.md) for ownership; [TASK_BOARD.md](TASK_BOARD.md) is the only production queue. Old session details are in [History](history/README.md), not instructions to execute.

## Current direction

The user has established a token-aware [Synthetic Squad working contract](delivery/SYNTHETIC_SQUAD.md). Its primary art lane is GPT-authored isolated 2D concept → Tripo image-to-model candidate → validated GLB in Godot. Tripo is not yet connected or approved for a paid pilot; `art/tripo_ready/` has rejected crops and is excluded. At this checkpoint Gemini has committed communicator/export work (`3b360bc`, `aa86d0e`) and left uncommitted HUD/encounter/shader/pod/capture edits. Inspect and preserve those edits before further game changes. The working contract adds no new production priority; use TASK_BOARD.md.

**User-directed asset-pack exception:** the user authorized a bounded prop pack and will handle Tripo Studio manually. Nine isolated prop concepts are in `art/concepts/tripo_asset_pack_v1/`; use the pack README for the precise Spore mapping and batch recipe. The orbital context image is not a Tripo prop input. Character experiments were canceled and removed; character modeling and cast production remain deferred. Save manually exported, unreviewed GLBs under `assets/tripo_inbox/`; that directory's README explains promotion after review. Do not use computer control on Tripo.

Character modeling and cast expansion remain **deferred** after the failed modeling demonstration. The later character experiments were canceled and removed from the project asset set. Existing Tavi concept art is a static portrait, not acting. Read the [postmortem](reviews/MODELING_POSTMORTEM_2026-09-24.md) before any future reprioritized retry. The overall space-game objective is unchanged.

First complete the reference/current/mock coverage gate in [TASK_BOARD.md](TASK_BOARD.md), beginning with orbital/surface HUD. The user rejected continued implementation without comprehensive source fidelity and every-view mocks. [Coverage audit](reviews/VIEW_MOCK_COVERAGE.md): 18/61 sampled source workflows, 9/61 readable, zero fully verified interactions/presentation/audio; six base candidate files across 33 families, zero complete family state sets. These are evidence counts, not game completion. No further discretionary UI/feature production ahead of the gate. Existing builds remain available; character production remains deferred.

## Successor handoff — quota checkpoint, 24 September 2026

The user requested this handoff with approximately5% usage remaining. **The goal is active and far from complete.** Do not resume an endless sequence of layout audits and call that game progress. The latest user challenge is whether our actual output meets the approved mocks; it does not. Recent work mostly produced isolated review prototypes, not a better playable game. Explain this distinction plainly.

### Where to pick up

1. Read `TASK_BOARD.md` for the current queue and `reviews/VIEW_MOCK_COVERAGE.md` for evidence. Compare the latest engine capture directly with `artifacts/field-instruments-review/10-contact-v2.png`. Its **face and dialogue were rejected**; its physical Field Instruments housing, pictorial actions, portrait staging and world composition are the reference. Never replace that bar with our weaker flat code-drawn studies.
2. The next bounded task is a stronger communicator/world visual slice: coherent physical casing and portrait lighting, visible ship/destination context, better planet material/geographic hierarchy and detail delivery that does not stall navigation. Keep the approved existing Tavi portrait; no new character design/modeling. Review the whole composition and motion with the independent critic before widening the state sheets. Comprehensive source/current/mock coverage remains required; do not silently bypass its production gate.
3. Planet experiments below are **diagnosis/proposals only**. Do not globally raise texture resolution or ship their synchronous bake. Establish a nonblocking/cache/prebake strategy and representative frozen/temperate/arid visual checks before integration. Do not claim that sharper noise is better geography.

### Current files and experiments

- `tests/communicator_fidelity_study.gd`: static communicator with existing painted action atlas, existing Tavi portrait, recessed continuous display, foreground counter, mounted Goodbye and segmented gauges. First contact and agreements at1080p/1440p. The real globe is framed with an explicit **review camera**, not verified player camera behavior. Static controls, no acting or input acceptance.
- `tests/review_diplomacy_states.gd`: original24-state baseline/proposal harness plus focused fidelity flags. Actual command/refusal and immutable snapshot checks remain. `--fidelity` restricts to first contact/agreements (four captures); detail modes restrict to first contact (two captures).
- `tests/planet_material_study.gd`: review-only generator subclass. Removes ruggedness darkening from albedo, separates frozen sea ice/land snow and regional exposed rock. Same recipe/geography;36 spherical sample comparisons per capture assert unchanged geography/climate. Do not move into production by assumption.
- `--globe-detail`:2048×1024 maps, unchanged shader. Cold bake14,112ms in the measured run. Clearer edges but embossed/foam-like relief remains.
- Add `--relief-study`:1024×512 maps and a review-only shader blending object-space relief normals25% toward the sphere normal. Cold bake3,331ms in that run. Less harsh, but baked albedo veinwork remains.
- Add `--material-study`: uses the subclass above. Latest completed run baked in5,393ms and5,561ms; this mode explicitly clears the shared map cache per fixture because subclass policy is absent from its key. Thus both material timings are cold; ordinary detail manifests repeat original cached bake timing at the second display resolution. Timings are single-run observations, not performance distributions.
- Generated comparisons: `artifacts/diplomacy-review/{fidelity,detail,relief,material}-first-{1080,1440}.png`; corresponding JSON manifests. Images are local ignored artifacts; reproducible code and documentation are the Git backup. Production source and latest playable export are unchanged.

### Validation and critic status

Latest live handle21569 was polled at handoff and **finished exit0**: two material captures, command/refusal invariants, geography comparisons and frozen snapshots passed. No known render process needs resuming. DocumentationReport last passed117registered files /638local links /0errors; rerun after this handoff edit. `git diff --check` passed before the handoff.

Existing critic `/root/contact_shop_critic` is authorized by the user. It confirmed improved communicator composition but remaining thin casing/schematic lighting, missing visible ship/destination and poor planet fidelity. It confirmed2048 improves blockiness while exposing uniform embossed relief;1024/reduced normals is cheaper but inadequate. A final material-image critique was requested; retrieve any pending reply rather than assuming acceptance. Keep visual fidelity, readability, input, audio and user acceptance separate.

### Run / preserve / backup

From repository root in PowerShell:

```powershell
& '.tools/godot/Godot_v4.7.2-stable_win64_console.exe' --path . --script tests/review_diplomacy_states.gd -- --field-capture --fidelity --globe-detail --relief-study --material-study
& 'C:/Users/zephy/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/DocumentationReport.py
git diff --check
```

Native Godot rendering and Git writes/push have needed tool sandbox escalation. Use isolated harness saves/audio; never touch player saves or restart their running game. Branch `codex/frontier-prototype`, remote `https://github.com/gcs2/colonybois`. Previous verified remote checkpoint before this handoff: `c254568` (communicator fidelity study). This handoff and planet experiments are intended to be committed/pushed together; inspect HEAD and verify `git ls-remote` before claiming backup. Leave longstanding untracked `art/concepts/characters/merchant-directions-20260924.png.import` alone.

Prior audit details (cargo, navigation, collection, combat, services, diplomacy, fleet/peace, defense, history/badges, pause/settings) are in the coverage record and Git history. They are not all integrated. Source counts remain18/61sampled,9/61readable,0fully verified interaction/presentation/audio. Do not infer completion from capture counts.

## Playable checkpoint and limits

- Latest playable export: `build/versions/20260924-122541/FrontierWorlds.exe`, selected by `Play.cmd`. [Contact/shop checkpoint](systems/EXPEDITION_CONTACT.md): ivory/charcoal communicator, pictorial equipment grid, persistent representative, contextual greetings, Marks-only finished colony kits and zero-delay native tooltips. In-engine staging elevated: orbit camera framing puts the planet in view on the left, flight HUD is suppressed during contact/services, dedicated Field Instruments status pod displays Hull/Energy/Marks in the bottom-right corner, tactile ivory casing with corner cutouts and screws, illuminated perspective booth behind Tavi's portrait, and segmented relationship meters in the header. The wide commodity layout was user-rejected; trading now uses the preferred compact grid with details beside it, explicit transaction totals and visible refusal reasons; 81 contact and 49 commerce checks pass for this extension. Synthetic native hover confirms tooltip appearance without clicking. Currency artwork remains provisional. 330 focused checks pass; actual 1080p/1440p captures inspected, and exported-pack startup smoke passed. Native acting/art acceptance remains open. See Git history for the corresponding source checkpoint; the older galaxy checkpoint below remains its navigation baseline.
- Latest flight correction: intermediate landing waypoints no longer make the ship nearly stop. Measured far-side descent is 5.98 seconds versus 12.67; 24 route/rate cases, 15 transition and 21 flight presentation assertions pass. The pre-arrival dark interval is shorter and world locators now fade with scenery; the independent critic verified that correction in sampled frames. Landing now targets and follows the rotating site marker; 24 alignment/arrival cases pass. Matching surface terrain remains absent. Final sampled braking is steady on the updated fixture, not proven for every route. Descent now highlights the rotating site with an ivory ring. ORBIT replaces the signed scene-Y readout; surface ALT reports terrain clearance. 19 transition checks and independent sampled-frame review pass. Next major task remains matching surface geography and recognizable landmarks to the globe. Synthetic native sequence captured; human flight feel and full-world visual acceptance remain open. See [flight evidence](systems/FLIGHT_CAMERA_EFFECTS.md).
- That checkpoint records 40 galaxy, 67 full-screen navigation and 41 system assertions plus exported-pack startup smoke. [Galaxy behavior and limits](systems/GALAXY_NAVIGATION.md). Tests do not establish art or playability acceptance.
- Most generated galaxy destinations remain orbital-only. Full inhabited worlds, responsive encounters, final HUD/art/audio and native fun review remain open.
- Preserve the user's running game. Use separate versioned exports and isolated test saves; do not silently restart it.

## Evidence and constraints to preserve

- [Every-view register](reviews/VIEW_MOCK_COVERAGE.md) owns mock gaps; [paired atlas](ui-review/references.html) compares actual/reference/target material. Neither mock count nor reference coverage is game completion.
- [Reference report](parity/EXPERIENCE_REPORT.md) owns current source coverage. Listening and complete interaction evidence remain open; do not claim stills prove acting or audio.
- Local HTML preview was blocked by browser URL policy. Do not work around that block with localhost, a different browser or protocol. Static validation does not establish rendered-board review.
- Field Instruments: compact matte ivory/charcoal, named tooltips, recognizable tool art; about 40% more icon area, not enlarged panel shells. No shiny copper, rounded icon wells or persistent tool captions. Maps fill the screen; local terrain chart appears only on the surface.
- Energy is finite: inventory packs or docking, free at home. Keep danger and meaningful costs. Mouse-first controls plus arrows/numpad remain required.
- No engine migration, creator, coloring or sculpting. Further planet modification and character production are deferred. Cities use aggregate simulation. No purchase without a concrete approved price/license.

## Before the next checkpoint

Follow the board's next bounded task, validate its actual behavior and presentation, update its existing task ID and evidence, then commit/push and verify the remote hash. Documentation-only changes do not require or imply a new game export. Do not copy the full development history back into this handoff.
