# Focused pictorial UI cutouts — v4

Generated 27 September 2026 with built-in ImageGen. These four NEW standalone RGBA images use the approved mock images as style references; no mock pixels were cropped. They are review candidates, not approved runtime art, and none is wired into Godot. The generated assets rejected during this pass remain outside Git.

| File | Intended use | Mock reference | Review |
|---|---|---|---|
| [energy-pack-v2.png](energy-pack-v2.png) | One real Inventory item image across surface, orbit, approach and system views | Surface and orbit | Revised to match the mock's cyan canister and warm cap; game-size check open. |
| [marks-emblem.png](marks-emblem.png) | Small emblem beside live Marks balance | Surface and galaxy | Independent critic: strong motif candidate; simplify busy bevel if needed. |
| [system-fly-scout.png](system-fly-scout.png) | Fly action pictogram in selected system destination card | System map | Independent critic: readable silhouette candidate; tiny seams may vanish. |
| [galaxy-scanner-module-v2.png](galaxy-scanner-module-v2.png) | First equipment cell in galaxy status rail | Galaxy | Revised with restrained lens and simpler detail; game-size check open. |

RGBA mode and transparent corners were checked on the generated files. An independent visual critic found the Marks emblem, Fly scout and revised galaxy scanner promising at intended HUD size. The cyan Energy Pack is closer to the mock but its handle and glossy finish remain off target. Thin colored edge fringe appears on all four previews; alpha cleanup and actual Godot placement remain open. User acceptance remains open. The same five tab categories and one shared tab shape remain separate. Counts, labels, currency, ownership, destination, route, meter fills and hover state must stay live; no idle or selected glow should be baked into item art. See [PROMPTS.md](PROMPTS.md) for prompt and source provenance and [focused-shells-v3](../focused-shells-v3/README.md) for the blank surface/orbit/approach/system/galaxy housings.
