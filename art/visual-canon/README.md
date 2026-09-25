# Frontier Worlds visual canon

This single project-root folder is the easy home for user-approved visual targets, their exact generation prompts, and provenance. The images are design direction for actual game screens; sample numbers and static compositions do not prove live behavior.

## Morrow flight views — user approved 25 September 2026

| File | Purpose | Dimensions | SHA-256 |
|---|---|---:|---|
| [morrow-surface-ground-truth.png](morrow-surface-ground-truth.png) | User-selected surface environment and Field Instruments HUD | 1672 × 941 | 2E57DBE16817150BAA831B7C889F3E238352F44D00030457D3A4867A604E42C2 |
| [morrow-orbit-approved.png](morrow-orbit-approved.png) | Player-follow orbital gameplay, route and destination | 1672 × 941 | 440D3D90C35C8C5854F595064E1F9A88239A6721BD43A2F3FE09A6A827F85430 |
| [morrow-system-map-approved.png](morrow-system-map-approved.png) | Local solar-system navigation and departure choice | 1672 × 941 | 025B464BD65AD1BC71486673BAB60139EB23DBF80EA7E2223DDB26A073EF8B5D |
| [morrow-approach-approved.png](morrow-approach-approved.png) | Player-follow descent toward the same relay and landing region | 1672 × 941 | 401B50EFF12997D36A129BED4EA3907C53D93B9E5B7B640D330608640D0A00E4 |

The surface image is the user's pinned source. The other three are v2 designer proposals. The user approved these exact originals even though the generator returned 1672 × 941 rather than the requested 1920 × 1080. No resampling or other image edits were applied.

## Galaxy reference — added at the user's request

[galaxy-view-reference.png](galaxy-view-reference.png) copies the earlier galaxy-scale view the user said was nice: [05-galaxy-local-v2.png](../../artifacts/field-instruments-review/05-galaxy-local-v2.png). Its composition is a supporting galaxy-scale direction reference. It predates the current inventory decisions and is not a complete galaxy-state sheet.

## Shared rules

- Preserve Morrow's lively rust-and-teal landscape, broad world-to-scout scale, lake, relay, plants, rocks, distant relief and alien life.
- Ordinary gameplay uses a practical player-follow camera. The scout stays a small tool; cinematic framing is a later mode.
- Keep the full pictorial inventory visible where shown, with tab/category identity and real quantities; notifications upper left; Marks upper right; compact hull and energy; ALT secondary.
- Surface, local solar-system and galaxy navigation are separate scales with separate map treatments. A surface terrain chart never appears in orbit, system or galaxy navigation.
- Use angular matte ivory housings, charcoal inset displays, restrained functional colors, recognizable controls and named tooltips. Avoid rejected blue Windows panels, rounded wells, copper-like borders and persistent selected-tool captions.
- Bind all labels, costs, quantities and actions to current campaign state. Never ship mock-only text or decorative inventory as game data.
- The same scout, destination and expedition should remain recognizable across ordinary views. Static images do not prove transitions, controls, camera-follow behavior, interaction, performance or fun.

## Project records and prompts

- [Exact prompts that produced the approved Morrow views](generation-prompts.md)
- [Current game direction](../../docs/direction/SPACE_FIRST_DIRECTION.md)
- [Space Stage target and exclusions](../../docs/direction/SPACE_STAGE_TARGET.md)
- [Source-to-runtime view coverage](../../docs/reviews/VIEW_MOCK_COVERAGE.md)
- [System travel behavior](../../docs/systems/SYSTEM_NAVIGATION.md)
- [Production queue](../../docs/TASK_BOARD.md)