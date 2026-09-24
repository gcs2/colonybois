# Reference coverage and experience confidence

> Reference research; observations, proposals and evidence gaps are not implementation status. [Documentation map](../README.md).

24 September 2026. A source catalog, screenshots and feature names are not evidence that we understand playing Spore. This ledger measures research quality separately from game implementation. TASK_BOARD.md remains the single production queue; `parity/experience_coverage.json` is the evidence audit, not a competing backlog.

## What is counted

The initial denominator is **61 base-Space-Stage workflows across ten categories**, reconciled at family level against the existing Space Stage target and parity catalog. It is explicitly **open**: newly discovered states/flows enlarge the denominator; they are not hidden to protect a percentage. Character/creature customization and Galactic Adventures are excluded from this research pass. Ship/building editor entry and gameplay connection remain reference coverage; implementation remains deferred. Coloring/sculpting remain reference-only and excluded from delivery. The user's enthusiasm about a creator is a possible later ambition, not authorization to build one now.

The existing **84 tool families / 189 variant entries, 30 badge families, 10 ranks, 40 achievements and 12 inherited traits** are separate catalog dimensions, not fully verified denominators. Workflow coverage cannot close variant/cost/unlock coverage. Those manifest uncertainties remain open in `parity/COVERAGE.md`.

## Four independent percentages

| Metric | Numerator / denominator | What it does NOT mean |
|---|---|---|
| Visual sampling | Workflows with an actually inspected relevant state / 61 | Does not establish inputs, prices, rules, animation or sound. |
| Readable evidence | Workflows with an archived, context-complete frame at adequate effective resolution and legibility for its claims / 61 | A large screenshot or thumbnail does not automatically qualify. |
| Interaction verification | Workflows with readable evidence, documented trigger/input → feedback → outcome, cost/restriction and boundary/failure behavior, corroboration and recorded adaptation / 61 | Does not prove our game implements it, or replace a native playtest. |
| Presentation review | Workflows whose relevant motion, rhythm, camera, character performance and audio (or intentional silence) are actually reviewed / 61 | Still images, transcripts and muted playback cannot pass listening or timing requirements. |

Never average these into a reassuring overall 'understanding score'. Show category numerators, denominators and gaps. Implementation, tests, export verification and user acceptance are separate metrics.

Initial visual sampling is **14/61 (23.0%)**; readable/interaction/presentation verification are **0/61** under this stricter new rubric. This deliberately does not grandfather loosely documented old observations. It does not mean zero knowledge; it means the audited proof is incomplete. The first source-capture pass was too small for fine UI details and cannot be promoted by filename or browser dimensions.

After the improved shop/contact captures, **readable evidence is 3/61 (4.9%)** for contact, cargo selection and the displayed commodity transaction layout. Both reviewers checked the actual saved frames. The source decoder is 1920×1080, but gameplay occupies approximately 1440×810 in the saved raster, so the conservative resolution score is **75/100**; legibility is **L3/3 for the cited labels and values**. This does not verify purchases, pricing semantics, locks, or audiovisual performance. Interaction/presentation/listening remain zero. Generated report is authoritative for later changes.

The later navigation recapture adds narrowly readable galaxy/system endpoint and planet-emphasis evidence for RF002/RF003: **5/61 (8.2%)** readable overall. Three 2560x1440 captures contain full-screen gameplay from a 1920x1080 decoder, capped at R100; root and contact_shop_critic inspected them. The scale-change boundary and surface endpoint are absent. Interaction, presentation and listening remain zero. See the navigation recapture in [extended evidence](SPORE_EXTENDED_VIDEO_EVIDENCE.md).

The surface recapture at1805.490461s adds narrowly readable RF001 state evidence, independently checked by root and contact_shop_critic: **6/61 (9.8%)** readable overall. It shows surface composition and populated tools, not steering, altitude, zoom or beam-input mechanics. Source detail is capped at1080p (R100). All interaction/presentation/audio flags remain false.

Latest collection-feedback sequence adds RF018 sampled/readable evidence: **18/61 (29.5%) sampled; 7/61 (11.5%) readable**. Four inspected frames at1804–1808s have1080p source detail (R100), complete world/HUD context and L3 for the cited cargo counts and Brasstax card. Root and contact_shop_critic agree on those narrow observations. Input, cost, release, failure, full motion and audio remain unverified; all complete interaction/presentation/audio totals remain zero. Earlier counts above are dated checkpoints.

## Resolution and legibility

For every video frame record the full PNG dimensions, decoded source dimensions measured at capture, visible gameplay rectangle excluding browser/letterboxing, actual timestamp, completeness and overlays. Keep originals and rejected captures clearly distinct.

`effective_gameplay_height = min(decoded_source_gameplay_height, captured_visible_gameplay_height)`

`resolution_score = round(100 × min(1, effective_gameplay_height / 1080))`

Unknown decoded dimensions or an uncertain gameplay crop yield **unknown**, not an invented score. Record an upper bound separately if useful. Scaling 720p to 1080p cannot improve this metric. A 1280×720 screenshot containing a 467-pixel-high player is not 720p gameplay evidence. A source may have additional game letterboxing or a cropped HUD; account for that explicitly.

Legibility is a separate human judgment:

- **L0:** unreadable or badly incomplete.
- **L1:** composition and large silhouettes only.
- **L2:** icons and panel headings identifiable; fine numbers/help not reliable.
- **L3:** the specific names, prices, counts, cooldowns and tooltip text used by the claim are readable, with relevant context intact.

For exact mechanics/UI claims require L3 and complete relevant context. Target resolution score at least 67 (effective 720p); prefer 100 (1080p) where source quality allows. Lower-resolution evidence can establish a large-scale layout only, never unreadable prices or hidden controls. Every exception must state the narrower supported claim. A crisp silent screenshot still has no audio evidence.

## Cutscenes, personality, comedy and sound

Review the Space-stage opening/launch, important first-use beats, incoming contact, friendly/hostile/surprised reactions, trade response, warnings, victories/defeats, badge/promotion ceremony, and the galactic-core sequence. This includes potentially spoiler-bearing reference work; our story remains original.

For each sequence document setup → anticipation → action/reaction → release; camera/framing; character pose/gaze/mouth/gesture; speech or expressive nonverbal voice; music/ambience changes; cue layering; silence; duration range; interruption/skip; and return of control. Humor is often the relation between these elements, not a silly sound pasted onto a button. Record which observations are actually seen/heard versus inferred.

The inspected extended footage was muted. **Listening coverage is currently zero.** Available tools in this session expose screenshots and browser control, but no tool that lets this agent actually hear the browser's playback; pressing play with audio on would not justify a listening claim. A human listening review or a supported audio-understanding capability is required. A transcript can establish words, not delivery, mix, music or comic timing. No paid API, extraction workaround or copied sound asset is authorized by this audit.

Our original adaptation should preserve expressive alien performance and contextual musical/sound responses. Field Instruments assembly is one small part: it cannot replace world personality, good combat audio or narrative staging. Original AI audio candidates still need audition, edit, mixing, provenance and license confirmation; no automatic purchase.

## Update discipline

Run `tools/ReferenceCoverageReport.py` after evidence updates. It computes category totals and validates that positive verification flags have the required evidence fields. Frame resolution/legibility records remain independent in the source evidence register and asset index. No percentage is a fun score or game completion percentage.

Next evidence priorities: recover adequately sized shop/contact captures; inspect exact purchase/use and failure sequences; record zoom/navigation continuity; audit first launch, alien reactions and badge/core cinematic sequences; obtain an honest listening path. Complete the reference/our-capture/target synthesis before expanding independent mocks.

## Latest launch sampling checkpoint

17/61 workflows visually sampled (27.9%); 6/61 readable (9.8%); no full interaction, presentation or listening passes. Three new sampled families come from a 352×262 launch recording: roughly R16 cinematic content, R24 full-height upper bound. They do not pass readability. See SPORE_LAUNCH_SEQUENCE_EVIDENCE.md. More screenshots do not establish timing, voice or comedy.
