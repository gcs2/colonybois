# New Expedition captain identity and philosophy screen

**Owner:** P02 — Captain identity, philosophies, powers and inherited traits
**Status:** Mock requested 27 September 2026; no image has been generated or accepted.
**Production queue:** [TASK_BOARD.md](../../TASK_BOARD.md) remains the only queue.

## Player activity and game connection

Before a new campaign begins, the player names their captain and chooses a philosophy/archetype. This choice should set expectations for how they will investigate worlds, meet alien powers and handle danger. In the shipped game it must eventually change an available action or obligation and persist with expedition history; a decorative label or hidden numerical bonus is not enough.

The screen starts the same connected campaign: pilot the scout, explore Morrow and other seeded worlds, collect useful resources, meet alien societies, trade, equip the ship and build a chronicle. It does not start a separate character-creator game mode or replace the campaign's world, diplomacy or simulation systems.

## Ground truth and reference roles

- [Tracked visual canon](../../../art/visual-canon/README.md) is the only accepted visual source home. Use it for materials, lighting, scale and continuity, not as a layout to copy.
- [Morrow surface ground truth](../../../art/visual-canon/morrow-surface-ground-truth.png) anchors the playful miniature-world palette and understated ship scale.
- [Approved Morrow orbit](../../../art/visual-canon/morrow-orbit-approved.png), [system map](../../../art/visual-canon/morrow-system-map-approved.png) and [galaxy reference](../../../art/visual-canon/galaxy-view-reference.png) show the ship/world relationship and the wider expedition context. The new screen itself is not represented by these images.
- [Approved Field Instruments elements](../../../art/visual-canon/ui-element-candidates/focused-elements-v5/README.md) and the [icon vocabulary](../../reviews/UI_ICON_VOCABULARY.md) guide recognizable, image-backed controls and material treatment.
- [Player archetype references](../CHARACTER_ARCHETYPES.md) identify Scientist/Science, Zealot/Faith and Knight/Force and name source powers. Those powers are research evidence, not implemented features in this build.

## Current decisions and exclusions

- Treat Scientist, Zealot and Knight as player-facing philosophy/archetype choices, not as planetary governments. The names and exact roster remain subject to the P02 gameplay work.
- Include a captain name field and a clear selected/unselected state. Use short readable descriptions; do not invent numeric stats or claim that an unimplemented power already works.
- Do not decide the player's species. No freeform creature editor, new 3D character model, species-selection flow or new cast art is authorized by this brief. If a captain silhouette is shown, keep it species-neutral and subordinate to the choice UI.
- Preserve the original Field Instruments aesthetic: ivory and charcoal with restrained gold/teal accents, purposeful image-backed controls, disciplined typography and useful empty space. Avoid flat Windows-blue panels, shiny copper trim, decorative icon wells, tiny text and oversized ship art.
- This is a new view proposal. Do not alter, crop or regenerate the approved canon images. Do not place an unreviewed candidate in the tracked canon.

## Composition to explore

Design one 16:9 New Expedition view. Keep the starship and world context present but secondary. The player should see, in order:

1. A clear “NEW EXPEDITION” heading and a concise prompt to create the captain.
2. A name/callsign field with an example value that is easy to replace.
3. Three distinct, recognizable philosophy choices: Scientist, Zealot and Knight. Give each a compact emblem and a short plain-language description. Make selection unmistakable without a persistent caption floating over the scene.
4. One selected-choice detail area that can later explain the real action/obligation attached to that philosophy. Mark any ability line in this mock as a design placeholder, not shipped gameplay.
5. Back and Begin Expedition actions with a clear focus/selected state.

Keep the screen easy to scan at ordinary 1080p. Do not make the ship the foreground subject; if visible, use the approved scout proportions and preserve room for the captain and philosophy decision.

## Deliverables and shared home

Stage candidates at `artifacts/designer-mocks/P02/` in the active integration worktree. Return a small `README.md`, the exact prompt text, generator/tool and date, and the original 1920×1080 PNG. Include a 2560×1440 composition only if it can be produced without changing the layout or cropping the source. Do not commit generated candidates. Sol copies results from a worker worktree to this shared home before review.

The independent critic scores the **screen mock** out of 100 for hierarchy, canon fit, readability, choice clarity, player identity and resolution. The 90/100 live-view gate in [SYNTHETIC_SQUAD.md](../../delivery/SYNTHETIC_SQUAD.md#independent-critic-score) applies after implementation and runtime capture; a mock score is not runtime acceptance. User approval decides whether the image joins the canon.

## Copy-ready prompt

> Create an original 16:9 video-game UI concept for a polished, playful space-exploration game called **Frontier Worlds**. This is the **New Expedition** screen where the player creates an expedition captain by entering a name and choosing a philosophy. Match the attached approved Frontier Worlds references for miniature-world color, restrained ship scale, warm ivory Field Instruments materials, dark charcoal framing, fine gold and teal accents, and clear pictorial controls. Preserve an original design; do not copy Spore, another game's interface, or any reference image's exact layout.
>
> Show a compact captain-name field, then three distinct selectable choices labelled **Scientist**, **Zealot**, and **Knight**, with clearly different simple emblems and concise readable descriptions. Make the selected choice obvious. Include one calm detail area for a future playstyle/action explanation, but do not invent statistics or imply that named powers already work. Include clear Back and Begin Expedition buttons. Keep the ship and starfield in the background at modest scale so the identity choice remains the focus. Use clean alignment, generous practical text space, consistent panel heights, believable 1080p typography, and no overlapping borders.
>
> This captain's species is deliberately undecided. Use no detailed face, creature anatomy, new character portrait, or species editor. Avoid blue Windows-style panels, glossy copper trim, oversized rounded wells, dense tiny labels, a huge foreground ship, and decorative clutter. The result should feel like it belongs beside the approved Morrow surface, orbit and Field Instruments views while still reading as a distinct start-of-expedition screen.

## Review checklist

- Can a player immediately identify this as the start of a new expedition and understand how to begin?
- Are captain naming and philosophy selection visually distinct and usable?
- Do the three archetypes read as deliberate choices without unsupported stat claims?
- Does the screen share the approved materials and typography while leaving the species open?
- Is the ship secondary, and is there enough practical space for eventual real choice consequences?
- Has the exact candidate, prompt, provenance, critic score and user verdict been recorded before promotion?
