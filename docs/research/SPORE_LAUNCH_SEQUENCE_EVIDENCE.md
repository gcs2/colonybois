# Space Stage launch: sampled staging evidence

> Reference research; observations, proposals and evidence gaps are not implementation status. [Documentation map](../README.md).

24 September 2026. Source: [PoketamaVideos — Spore - Beginning of Space](https://www.youtube.com/watch?v=tPv31DJRST8), displayed runtime 1:34. This supplements the extended-playthrough register; the SingularMix recording starts from a resumed campaign and does not establish the first launch.

## Method and limits

Inspected and archived 19 paused samples at 0, 5, 10, …, 90 seconds through the YouTube UI. No video was downloaded. The full browser PNGs and immediate decoder/time metadata are local research artifacts under `artifacts/references/spore/launch`; the tracked `parity/launch_capture_manifest.json` identifies those exact bytes. They are source references, not production assets.

Native decoder dimensions were **352×262** throughout. Full-screen screenshots are much larger but do not add source detail. Cinematic imagery occupies approximately two-thirds of the native frame height (about 176 pixels) because the original video includes black bands. Thus cinematic effective resolution is roughly **16/100**, and even full-height gameplay is at most **24/100**. Treat all as L1–L2 staging evidence; no readable-evidence workflow pass. Frame 10 is partly clipped by page scrolling; frame 35 is black and supports no staging claim. Exact crop edges, game version/mod configuration and source editing/speed are unverified. Do not use this clip to set exact production timings.

Playback was muted. This is **not a continuous motion review or an audio review**. Five-second gaps can miss a gesture, camera cut, input or joke. The file labels name sampled video timestamps, not measured game event durations. A visible UI after a scene shows a handoff state, not the exact frame when control becomes available. Creator activity was inspected only as an entry/exit connection; a creator remains outside approved implementation scope.

## Observations, not reconstructed missing action

| Sample times | Actually visible | Original adaptation / remaining gap |
|---|---|---|
| 0:00, 0:05 | An inhabited city centered on a tall civic structure; small creatures surround it. The later, closer frame shows raised arms. | A launch can belong to a society with visible inhabitants. Do not substitute only a ship and a title card. Crowd motion/audio still require a better sequence. |
| 0:15, 0:20 | Ship editor, first an empty work area, later a selected/painted ship. | The craft is made personally salient before flight. Our authored starter can receive a reveal without adding an editor. Input sequence was not captured. |
| 0:25, 0:30 | Space Stage loading screen; later includes creation cards. | Loading/transition presentation is distinct from the in-world ceremony; don't count it as cinematic action. |
| 0:40, 0:45 | Same city without the ordinary flight HUD; sparks near the central structure and separate achievement notifications over the world. | Milestone recognition coexists with a world event. Do not infer exactly when or why every achievement fired. |
| 0:50 | Dense pale smoke/effects obscure the base of the central structure. | The reveal uses occlusion and anticipation; exact cause/sequence between frames unverified. |
| 0:55 | Selected spaceship is framed against the purple sky with bright trailing effects. | Give first flight a ship-focused reveal. This still does not establish camera path, acceleration or sound. |
| 1:00 | Ship faces the viewer above the inhabited landscape, still without normal HUD. | Framing returns the ship to a recognizable world context. |
| 1:05 | Same scene with a bottom text passage and confirmation control; its final phrase contrasts grand possibility with learning to fly. | Humor can connect ambition to the immediate act of piloting. Tone/delivery are unreviewed; do not reproduce the source text or mandatory tutorial. |
| 1:10, 1:15 | Normal flight HUD plus large tutorial cards; one card includes a pointer aimed toward communications. | Contextual guidance can point at an actual control. Our optional guidance should use much less copy; this does not endorse copying long interruption cards. |
| 1:20 | Ordinary HUD, world, another achievement notification; the large help card is absent. | Recognition persists into play. Exact dismiss input and timing are not established. |
| 1:25, 1:30 | Flight viewpoint changes over a visibly curved, inhabited world with the HUD retained. | Celebration returns to playable space, not a separate decorative scene with no continuation. Exact steering/zoom input remains unknown. |

These observations add visual sampling for opening, guided introduction and ship-editor connection only. They do not satisfy full interaction, presentation or listening gates. Badge ceremony coverage is not closed by seeing achievement toasts.

## What the next stronger source must resolve

Obtain a higher-resolution continuous opening with visible controls and review the city/ship reveal at normal speed. Mark actual scene boundaries, cuts, character gestures, skip/confirm behavior and return of control. Listen for crowd/ship/voice/music layers and their timing with an actual supported listener. Separately review alien contact acceptance/refusal and a badge/promotion; a launch scene cannot substitute for those.

Our first-contact adaptation is specified in [CONTACT_PERFORMANCE_SPEC.md](../direction/CONTACT_PERFORMANCE_SPEC.md). The Field Instruments assembly is only one part of presentation. The broader launch should establish home, ship and possibility without forcing a city tutorial or a repetitive mission chain.
