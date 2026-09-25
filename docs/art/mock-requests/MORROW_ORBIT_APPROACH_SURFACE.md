# Morrow flight and scale-view mock request

**Owners:** R01 / V01 / V04

**Player activity:** Fly, navigate, discover and approach Morrow as one continuing expedition with the same scout, route, equipment and campaign state.

**Status:** The user approved the Morrow surface target and v2 orbital gameplay, solar-system map, and approach/arrival images on 25 September 2026. Their original 1672 × 941 files are canon; do not regenerate them for critic-requested size/ship revisions. The user also asked to include the earlier galaxy-scale view as a supporting reference. See the single tracked [visual canon home](../../../art/visual-canon/README.md).

## Wider project context

Read [production goal](../../PRODUCTION_GOAL.md), [Space Stage target](../../direction/SPACE_STAGE_TARGET.md), [space-first direction](../../direction/SPACE_FIRST_DIRECTION.md), [Spore research](../../research/SPORE_SPACE_STAGE_RESEARCH.md), [task board](../../TASK_BOARD.md), [Field Instruments icon decisions](../../reviews/UI_ICON_VOCABULARY.md), [view coverage audit](../../reviews/VIEW_MOCK_COVERAGE.md), and [Morrow mining/trade system](../../systems/SHIP_COMMERCE.md). These views support exploration, discovery, equipment use, trade and alien contact in the connected game; they are not a standalone HUD exercise.

## Ground-truth references

- **Selected target:** [Morrow surface populated v3](../../../artifacts/field-instruments-review/01-surface-populated-v3.png). Byte-identical to the image the user pinned on 25 September 2026; SHA-256 2E57DBE16817150BAA831B7C889F3E238352F44D00030457D3A4867A604E42C2. This sets the environment, broad world-to-ship scale and surface HUD.
- **Earlier galaxy reference:** [Galaxy local v2](../../../art/visual-canon/galaxy-view-reference.png), included at the user's request as a supporting scale/composition reference.
- [Surface v1](../../../artifacts/field-instruments-review/01-surface-v1.png) and [surface v2](../../../artifacts/field-instruments-review/01-surface-populated-v2.png): progression only.
- [Orbit v1](../../../artifacts/field-instruments-review/03-orbit-v1.png): candidate composition, camera/HUD not approved.
- [System v1](../../../artifacts/field-instruments-review/04-system-v1.png): candidate solar-system map study.
- [Galaxy local v2](../../../artifacts/field-instruments-review/05-galaxy-local-v2.png): separate galaxy scale.
- [Boarding motion v1](../../../artifacts/field-instruments-review/23-motion-storyboard-v1.png): optional UI assembly timing, not flight or landing.
- [Spore source register](../../research/SPORE_EXTENDED_VIDEO_EVIDENCE.md) links distinct surface and system source moments. No continuous Morrow transition is established.
- The four Codex-generated transition boards from this continuation were rejected. Do not reuse them.

## Decisions

Ordinary gameplay uses a player-follow camera; no cinematic framing. Keep the ship small, about 6% of screen width as in the selected target, and let the world or destination dominate. Preserve the full tabbed two-row inventory/cargo grid and quantities, top-left notifications, top-right Marks, compact hull/energy, and small secondary ALT. Surface terrain chart is surface-only; system and galaxy maps are distinct. Carry the same scout, Morrow, landing region/relay and route across views. Keep the rich selected environment and Field Instruments language.

Avoid oversized ship, shallow-focus blur, dominant altitude panel, thin icon strip in place of inventory, blue Windows panels, rounded icon wells, shiny copper-like borders, copied Spore art, and downgraded sparse landscape.

## Deliverables and shared image home

Put three separate 1920×1080 images (not a collage) in artifacts/designer-mocks/R01-V01-V04/ in the active review worktree:
- 01-orbital-gameplay.png — player-follow orbital flight, planet, route and destination visible.
- 02-solar-system-map.png — star, planets, orbital paths, current ship, selected destination, route and travel context.
- 03-approach-arrival.png — player-follow approach to the same Morrow relay/region, leading to the selected surface target.

Leave the selected source image unchanged. Update the artifact home's README.md with exact prompts actually used, tool, date, source links and status. The current index is the shared view for user, coordinator and critic.

## Copy-ready prompts

### 01 — Orbital gameplay
Use the selected Morrow surface screenshot as visual and HUD ground truth. Create one 1920×1080 ordinary playable orbital-flight screen for an original creepy-cute space exploration game. A practical third-person player-follow camera keeps the scout about 6% of screen width; the planet, atmosphere, route and landing cue dominate. Preserve Field Instruments, full tabbed two-row equipment/cargo grid with counts, notifications top-left, Marks top-right, readable hull/energy and small ALT. No cinematic angle, blur, large ship, surface chart, dominant altitude panel, simplified icon strip, blue Windows panels, rounded wells, copper borders or collage. Original art.

### 02 — Solar-system map
Use the selected Morrow screenshot as the HUD anchor and system-map study as layout context. Create one 1920×1080 original Field Instruments solar-system navigation screen. Clearly show a star, distinct planets, orbital paths, current ship, selected destination, route and useful travel context such as reach, time or access. This is system scale, not the surface chart or galaxy map. Retain top-left notifications, top-right Marks and a compact but continuous equipment/status treatment. Use strong hierarchy and dark-space contrast. No blue Windows panels, rounded wells, copper borders, oversized ship or collage.

### 03 — Approach and arrival
Use the selected Morrow screenshot as exact environment/HUD target. Create one 1920×1080 ordinary gameplay approach toward the same relay and landing region. Practical player-follow camera; scout about 6% screen width; world grows legibly and target cue connects to the relay. Preserve richly detailed Morrow, Field Instruments, full tabbed two-row inventory/counts, top-left notification, top-right Marks, compact hull/energy and small ALT. No cinematic framing, blur, oversized ship, dominant altitude, downgraded sparse landscape, blue Windows panels, rounded wells, copper borders or collage.

## Review gate

The user approved the selected surface and exact v2 orbital/system/approach stills on 25 September; approval and prompt provenance are in the tracked visual canon home. Use accepted images as implementation targets. Continue matching inspected Spore evidence and runtime states, including before/during/after approach and scale transitions. Static mock approval is not proof of source behavior, motion, input, sound, live art quality, performance, fun or full state coverage.