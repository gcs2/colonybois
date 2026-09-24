# Extended Spore gameplay: visual evidence register

> Reference research; observations, proposals and evidence gaps are not implementation status. [Documentation map](../README.md).

Companion audit: [REFERENCE_COVERAGE_METRICS.md](REFERENCE_COVERAGE_METRICS.md) and [generated workflow report](../parity/EXPERIENCE_REPORT.md). The twelve timestamp rows below are samples, not twelve completed workflows. V2 frames later in this document add readable state evidence without interaction/listening completion. The comparison atlas is `docs/ui-review/references.html`.

24 September 2026. Independent critic audit. These are newly inspected browser frames from an extended gameplay recording, supplementing the original manual and the earlier GUI forensics. They are not a claim that the entire recording was watched, that its audio was assessed, or that our game received a native playtest.

## Source and method

[SingularMix — Spore Playthrough: Space Stage](https://www.youtube.com/watch?v=0NN5fBVEHcA), with a displayed runtime of **5:51:00**. The visible description says this continues an earlier Cell–Civilization playthrough after a break. Exact game version, expansion configuration and installed mods were not verified. Do not treat every visible behavior as guaranteed unmodified retail behavior.

An independent hidden in-app-browser tab was used. Playback was muted. The critic sought to named times and inspected rendered screenshots; neighboring frames were sampled for the combat and travel/contact/shop sequences. Player time was checked through the visible controls/accessibility tree. Five key full browser screenshots were subsequently saved and visually verified under ignored research artifacts. This audit did not download the video or use footage as production assets. Some frames were inspected enlarged, but the recording itself and the browser player limit fine text readability. Minute text or exact item prices are not inferred where they cannot be read.

## Actually inspected frames

| Timestamp | Visible evidence | What this changes for our review |
|---|---|---|
| [30:00](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=1800s) | Ship over an orange planetary surface, a large grove of distinctly alien purple plants and small creatures. Equipment remains anchored at the bottom-right; planetary/ecosystem information occupies the lower-left. | Alien life is visible scenery with silhouette and scale, not only catalog entries. Our current sparse collection circle fails this visual density test. This frame does not establish complex individual ecology simulation. |
| [1:00:00](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=3600s) | A curved inhabited planet with several visible city structures and differently colored vegetation clusters. A selected local structure has nearby status information. | Surface composition must suggest a world continuing beyond one interaction site. A floating population number cannot substitute for visible settlement structure. |
| [1:00:20](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=3620s) | Closer city combat: a strong vertical luminous weapon/impact effect, city buildings, and a compact target/status stack positioned at the action. Red weapons palette remains bottom-right. | Combat needs an immediately readable focal point and target-local state. Our thin wire warning spheres and distant target-health copy are weaker. This sampled frame does not establish exact effect duration or damage timing. |
| [1:00:25](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=3625s) | City combat with red directional/target arrows around the settlement, a bright red beam and separate yellow flashes. The inhabited environment remains visible. | Telegraph, targeting and impact must have distinct visual roles. Color is useful, but contrast and silhouette must also work over snow, sand and vegetation. |
| [1:30:18](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=5418s) | Curved planet surface with multiple vegetation groups, distant landmarks and long bright ship trails. Persistent interface remains compact relative to the world. | Our whole-world impression needs distributed landmarks and coherent geography. Do not reproduce our small basin at larger scale and call it a planet. |
| [2:00:00](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7200s) | Local galactic view: many stars, ship/range arc, colored route/relationship marks and spatially attached star selection. The destination is part of the world, not a separate application form. | Local range, star selection and route feedback belong in galaxy space. Our new projected range is directionally correct; clarity of known/unknown and reachable states still needs improvement. A colorful nebular background alone does not prove discovery fog behavior. |
| [2:00:10](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7210s) | A solar system with a large luminous star, orbital paths, destination planets, a nearby communicator portrait and retained ship tools. The surface terrain minimap is absent. | Scale changes replace contextual information while preserving familiar ship/tool anchors. Galaxy, system and surface should not feel like unrelated utility windows. |
| [2:00:12](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7212s) | Contact window with a substantial alien portrait on the left, a short greeting on the right and action groups beneath. Trade, Repair and Recharge form a distinct service group beside Missions and Diplomacy. | Communications need a character and a purposeful choice composition. Replacing one paragraph list with another ivory paragraph list would not close the gap. Our inventory-pack rule remains an explicit departure; docking services may still offer priced recharge. |
| [2:00:15](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7215s) | Shop in the same encounter context: portrait retained; dense pictorial equipment grid above; cargo items below; a selected commodity has its own quantity/value/sell area. Some equipment entries are dimmed. | Trade is a distinct transaction layout, not a scroll of generic purchase buttons. Filled, locked and selected inventory states must be represented in the mocks. |
| [2:00:20](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7220s) | The shop persists with the creature in a different pose and changed cargo selection/contents relative to the earlier sample. | The portrait can remain expressive during commerce. The paired frames show different states; they do not establish a particular animation rig or exact transaction mechanics. |
| [3:00:00](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=10800s) | City layout editor: a deliberately bounded circular city, pictorial building choices on the left, large placed structures and colored adjacency links. | Distinguish Spore's purpose-built colony editor from ordinary surface flight and from our SimCity-inspired administration. This is source evidence for a separate construction view, not approval to make our entire explorable world a city editor. |
| [5:00:00](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=18000s) | Later galactic navigation with a dense field of red/warm stars, cloudy spatial background, a range halo and a comparatively collapsed tool area. | The galaxy needs to communicate navigable density at mature campaign scale. Not every tool must remain expanded at every scale. This one frame does not prove full-galaxy population counts or camera freedom. |

The 2:00:00 → 2:00:10 → 2:00:12 → 2:00:15 → 2:00:20 samples provide directly inspected galaxy/system/contact/shop continuity. They are sampled states, not a frame-by-frame measurement of transition timings.

## Comparison rules for Field Instruments mocks

The user selected the **Field Instruments** direction: matte ivory equipment, tactile gauges, restrained color and cute physical assembly. Preserve Spore's hierarchy and interaction clarity while designing original forms. Do not copy its blue frame assets, characters, fonts or sound bank.

Latest direction: aggregate paired **actual Spore reference + our actual view + our proposed mock** before generating more disconnected alternatives. Keep the routine HUD compact; richer content views can use additional room. The requested tool/icon increase is about **40% in area**, approximately **18% in linear dimension**, not a 40% increase in width and height and not larger panel shells. Improve recognizable physical tool artwork along with size.

- Navigation mocks need separate local and overview framing. Put the range in the galaxy plane, centered on the current position; preserve geometric meaning above and below the plane. Do not show a three-parsec ring spanning half the galaxy.
- Surface and orbit need distinct information. The local chart stays on the surface. Hull/energy and tool identity must remain recognizable when instruments fold or context changes.
- Tool categories must open an adequately sized item tray with local charges, selected state, unavailable state, cooldown and hover explanation. Minimalism must not erase the item corpus.
- Contact needs a readable representative, mood/identity and immediate choices. Dock/shop needs goods and transaction controls. Cargo needs item silhouettes and quantities. These must not become one shared text inspector decorated in ivory.
- The proposed assembly/boarding motion should use small catches, shutters, tray movement and gauges settling. It is an original animation direction, not a behavior measured from these videos. Keep it short, interruptible and reduced-motion compatible; do not delay repeated actions to play ceremony.
- Test threat effects over bright and dark environments. Keep target identity near the selected object and separate warning from impact visually.

## Coverage still pending

This is stronger source evidence, **not complete coverage of every Spore view**. Still pending from extended footage: detailed badge collection/reward animation; history/timeline; dense late-game cargo interactions and quantity edge cases; treaty/war/surrender choices; colony-founding sequence; map filter toggles and discovery fog revealing; full zoom-out galaxy overview and camera underside; failure/low-energy/death states; pause/save/settings; exact travel timing and audio.

Our complete-view mock inventory must additionally cover our own freight contracts, colony administration/ledger/services, warehouse, equipment, encounters, sandbox controls and existing ecosystem screens. Several are project additions without a direct Spore equivalent. Mark those explicitly as original designs rather than fabricating source parity. On-foot/RPG/factory proposals remain later work and must not appear as already playable systems.

Primary manual corroboration remains [EA/Maxis Spore manual](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/17390/manuals/manual.pdf?t=1642702281), printed pages 46–51, previously rendered locally as `artifacts/references/spore/manual-26.png` through `manual-28.png`. See [SPORE_GUI_FORENSICS.md](SPORE_GUI_FORENSICS.md) for the earlier evidence register and limits.

## Persisted screenshots and clarity assessment

The five files below were saved directly from browser screenshot bytes using filesystem persistence in the browser REPL, then inspected from disk. Paths are relative to the repository. They are research references, not production assets or a redistribution license. No video downloader or network extraction was used.

The first attempt using `screenshot({clip})` ignored the requested x/y offsets and cut off the bottom HUD. Files **without `-full` are rejected capture attempts** and must not be used in the comparison board. The corrected `-full` files preserve the whole browser frame. Actual PNG dimensions were read from the saved files, not inferred from viewport settings.

| Source family and actual timestamp | Verified file under `artifacts/references/spore/video/` | Full PNG | Approximate gameplay rectangle (x,y,w,h) | Effective game height | Bottom HUD | Legibility |
|---|---|---|---|---|---|---|
| [Galaxy 1:59:59](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7199s) | `singularmix-galaxy-01h59m59s-full.png` | 1280×720 | 24,80,830,467 | 467 px | In frame; YouTube transport overlay obscures part of tool area | 1 |
| [System 2:00:09](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7209s) | `singularmix-system-02h00m09s-full.png` | 1280×720 | 24,80,830,467 | 467 px | In frame; transport overlay obscures part | 1 |
| [Contact 2:00:12](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7212s) | `singularmix-contact-02h00m12s-full.png` | 1280×720 | 24,80,830,467 | 467 px | In frame; transport overlay obscures part | 2 |
| [Shop 2:00:15](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7215s) | `singularmix-shop-02h00m15s-full.png` | 1280×720 | 24,80,830,467 | 467 px | In frame; transport overlay obscures part | 2 |
| [Combat 1:00:20](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=3620s) | `singularmix-combat-01h00m20s-full.png` | 1265×712 | 16,67,862,486 | 486 px | Full game HUD visible; small YouTube Play hint remains above it | 1 |

Gameplay rectangles are measured from the visible saved screenshot composition, approximate by a few pixels. They are not exact DOM bounding rectangles for the capture instant. The decoder was later read through the visible video element: `videoWidth=1280`, `videoHeight=720`, displayed rectangle x=16,y=68,w=873,h=491. That metadata was observed after the captures; adaptive playback resolution at each individual capture was not logged. Do not present a 1280×720 browser PNG as 720 pixels of effective gameplay detail.

Legibility uses the requested scale: **0** unreadable; **1** composition; **2** icons/headings; **3** actual prices/counts/tooltips. The mean for this five-frame set is **1.4/3**. This is a clarity score for these saved references, not percent Spore parity, research completion or proof of complete game understanding. None receives 3: fine transaction values and small tooltips need a clearer capture. The contact/shop composition is directly useful now; fine interaction details remain unverified.

These frames cover five view families. They do not cover every Space Stage screen or every meaningful state within those families. Coverage should be scored against a separate MECE flow inventory, with a state counted only when its actual source and relevant transition have adequate evidence. Adjacent timestamps alone do not prove which mouse click caused a transition. Creator/customization coverage is outside the user's current requirement.

## Higher-detail contact and shop captures (v2)

The YouTube quality menu was inspected and offered **1080p60 HD**, 720p60, 360p and 144p. The playback session was switched from Auto (720p60) to 1080p60 HD. A temporary 1920×1080 browser viewport and full-screen player were used specifically to resolve transaction labels and prices. The viewport was reset afterward and the critic's temporary tab closed. No account settings were changed; playback stayed muted.

| Family | Verified file under `artifacts/references/spore/video/` | Paused source time | PNG | Native decoder at capture | DOM video rectangle | Visible game rectangle | Effective height | HUD and legibility |
|---|---|---|---|---|---|---|---|---|
| [Contact](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7212s) | `singularmix-contact-02h00m12s-v2-full.png` | 7211.997086 seconds (rounded 2:00:12) | 1920×1080 | 1920×1080 | 0,0,1920,1080 | approximately 0,0,1440,810 | **810 px** | Complete, unobscured; **3** |
| [Shop](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7223s) | `singularmix-shop-02h00m23s-v2-full.png` | 7223.413754 seconds (2:00:23) | 1920×1080 | 1920×1080 | 0,0,1920,1080 | approximately 0,0,1440,810 | **810 px** | Complete, unobscured; **3** |

Each PNG has a same-stem `.json` sidecar storing immediate paused time, native decoder size, DOM video rectangle and viewport. PNG dimensions were independently read from disk. Despite the 1080p decoder and DOM size, the saved raster places the visible game in approximately 1440×810 pixels with unused black space at the right and bottom. The cause of that capture/render discrepancy was not established. Consequently the clarity metric conservatively uses **810 pixels**, not the 1080p file label. The screenshots have not been upscaled.

The contact frame makes the greeting, Trade/Repair/Recharge/Missions/Diplomacy choices and the recharge price **450** readable. The treasury reads **12,811**. The shop frame makes cargo counts **8, 33, 13, 5** and displayed per-item prices **11,247; 349; 8,098; 975** readable, along with several equipment prices and inventory counters. Some very small or low-contrast details still require contextual inspection; a score of 3 does not certify every pixel or tooltip. These are observed values from this recording, not universal balance rules and not our Marks economy.

Use the v2 contact/shop images in the paired board. Replacing those two v1 images raises the five-family set's mean legibility to **1.8/3** (galaxy 1, system 1, contact 3, shop 3, combat 1). The two improved frames alone score **3/3**. This improves visual evidence; it does not add new workflow coverage, establish transaction click causality, or provide any audio evidence. Galaxy/system/combat still need higher-detail references before fine HUD claims. Cutscenes, personality over a complete encounter and funny audio remain unassessed.

## Navigation recapture: readable galaxy and system states

24 September 2026. Three new full-screen browser captures replace the small galaxy/system references in the comparison atlas. Playback remained paused and muted; seeking used the player's keyboard controls. Each PNG has a same-stem JSON sidecar with the observed media time, decoder dimensions and viewport. The game fills the 2560×1440 raster; the decoder is 1920×1080, so effective detail is capped at **1080 pixels**, not 1440. Resolution score **100/100** describes this source-detail cap, not game quality or understanding.

| File under artifacts/references/spore/video | Source time | Directly visible evidence |
|---|---|---|
| navigation-galaxy-7199-v3.png | 7199.121965 s | Galaxy route/relationship marks, home marker, an expanded cargo/tool tray at bottom right, two ally portraits, treasury 12,811 and hull 4,500. No surface chart. |
| navigation-system-7204-v3.png | See sidecar, approximately 7204.12 s | System star and orbital paths, moving ship with bright trails, destination brackets, the same lower-right cargo/tool and condition anchors. |
| navigation-system-7209-v3.png | See sidecar, approximately 7209.12 s | System flight continues; purple category selected with a different tray, a collected-spice notification, destination name and persistent condition/treasury. |

These frames are L3 for the cited numbers and labels, and useful for layout comparison. They do **not** establish what each route color means, the source input that caused travel or category selection, collection rules, energy cost, blocked travel, complete transition timing, or audio. The five-second sample interval misses the actual scale-change boundary. This is a before/after reference with an explicit motion gap, not a completed before/action/result verification. Surface entry still needs its own sequence.

Design synthesis: preserve familiar ship/tool anchors across scale changes; replace scale-specific context rather than showing the surface chart everywhere. A populated tray must fit without a giant panel. Keep world-attached destination feedback legible against trails and bright stars. These observations support the original Field Instruments treatment; they do not authorize copying Spore's frame artwork or reviving its permanent application bar against the user's Escape-menu requirement.

Independent review by contact_shop_critic confirmed full-raster gameplay and narrowly readable endpoint states for RF002/RF003. Required mock corrections: reduce the system candidate's competing foreground rocks and redundant chart; correct the galaxy candidate's 2.4 pc destination outside its 3 pc boundary; add populated category trays and contextual ally/notification states. No interaction, motion, audio or user-acceptance gate was passed.

## Surface tool and collection context recapture

24 September: surface-1805-v3.png and surface-mission-log-1810-v3.png under the same video artifact directory, with JSON sidecars. Exact paused times **1805.490461** and **1810.490461** seconds. The 1920×1080 decoder fills a 2560×1440 screenshot: effective source detail remains capped at 1080p. Muted, paused samples; no listening or input-causality claim.

- At 1805, the curved orange landscape has large purple plants and numerous creatures; the ship projects a luminous beam toward life below. The lower-left panel is **planet condition/food-web information**, not a terrain minimap in this state. Bottom-right categories sit above a populated specimen tray with visible quantities and an emphasized beam-tool slot. This demonstrates why a surface-only local chart also needs an alternate contextual instrument state; it does not prove the toggle input or exact collection rule.
- At 1810, My Collections / Mission Log overlays the world. A left mission list, alien portrait, right detail text, reward and tracking control are readable. A separate organism card occupies the top-right corner. This is an observed reference screen, **not approval to restore compulsory specimen-delivery errands**. The transition into the log and the inventory change between these frames are unverified.

For our surface candidate, preserve category→item→world targeting, visible finite-item counts and a compact instrument footprint. The surface condition panel, hover identity card and expanded cargo are separate states needing their own mock evidence. A map alone cannot stand for all three. Current comparison uses the dated scout_surface_95.png fixture; it must not be presented as a fresh runtime capture.

## Galaxy-to-system boundary: intermediate states

24 September follow-up on the same [extended gameplay](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7202s). Local evidence prefix: `artifacts/references/spore/video/navigation-boundary-`; each PNG has a JSON sidecar. Paused, muted samples advanced by 30 YouTube period-key frames between captures. Decoder 1920×1080, captured viewport 2560×1440: effective resolution remains 1080p, R100, not native 1440p detail.

| File suffix | Video time (seconds) | Narrow visible observation |
|---|---:|---|
| 7202-a | 7202.137347 | Small bright star below ship/cursor; no system summary |
| 7202-b | 7202.637346 | Adjacent Maytus summary with four planet rows and differentiated symbols |
| 7203-a | 7203.137345 | Larger star, separated planets and orbit arcs; summary reduced to Maytus header |
| 7203-b | 7203.637344 | Expanded system geometry; summary absent |

Independent critic contact_shop_critic confirmed the sequence and persistent bottom/right HUD anchors. Symbol meanings, exact triggering input, full transition duration/easing/fades and sound are not established. Frame spacing is sampling cadence, not transition duration. The manual's printed pp.48–49 corroborate hover information and wheel-based scale navigation; they do not establish which input triggered this recorded sequence. Source workflow counts and complete interaction/presentation/audio flags remain unchanged.

Compared with our candidates, 05 lacks the compact known-system summary; 04 lacks intermediate/refusal states and retains a redundant chart/heavy asteroid foreground. The dated actual system capture's 12-second quote is historical: current code uses two seconds locally and two–four between systems. Follow the [interface contract](../reviews/SPORE_INTERFACE_CONTRACT.md) for our proposed state behavior rather than copying screenshot values.

## Separate launch source

[SPORE_LAUNCH_SEQUENCE_EVIDENCE.md](SPORE_LAUNCH_SEQUENCE_EVIDENCE.md) documents 19 paused samples from PoketamaVideos’ separate launch clip. Its low native resolution and unreviewed audio must not inherit this recording’s clearer contact/shop scores. Full launch performance remains unverified.
