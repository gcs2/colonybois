# Wider flight camera and bounded effects

## Landing target and altitude cues (24 September 2026)

During active orbital descent, a restrained ivory ring highlights the actual site and inherits the globe rotation. It disappears on cancellation, inspection and surface arrival. Orbit readout now shows ORBIT and speed instead of misleading signed scene Y. Surface ALT is height above terrain directly below the ship, rather than world-space Y. No new navigation destination or world simulation is implied.

19 transition assertions pass, including ring attachment/cancellation and a ten-unit terrain-clearance readout. Build `20260924-035235`. Independent critic verified the ring and ORBIT readout in refreshed sequence frames 040/050/055/065 with no new blocking regression; terrain-relative accuracy relies on the test, not the still. The broader HUD treatment, site-to-ground landmark continuity and human input/feel acceptance remain open.


## Planet-fixed landing destination (24 September 2026)

The orbital approach previously ended at a hard-coded space position, unrelated to the globe's site marker. Entry now uses the actual marker direction transformed by the planet rotation, at radius plus six units. The final leg follows the moving site as the globe rotates; the same named site remains selected. This is a destination-alignment correction, not generated matching surface terrain.

The landing-flow test now rotates the globe and advances its rotation throughout 24 hemisphere/rate cases. It verifies marker/entry-ray alignment every step, arrival within 0.66 units of the current target, surface completion and no collision-clamp contact. All pass; 15 transition assertions also pass. The original static far-side fixture is 5.90 seconds. The refreshed native sequence includes planet rotation and reaches surface around 5.8 seconds with steadily declining final sampled speed in this case. Do not generalize that trace to all braking paths. Build `20260924-034851`. Independent critic found no blocking route/arrival regression in the sampled sequence, but flagged the tiny site marker and misleading negative orbital Y label. Terrain continuity and human motion-feel acceptance remain open.


## Shorter transition concealment (24 September 2026)

The critic found that approach scenery became almost black well before arrival while orbital labels remained. The departure veil now covers only the last 1.8 to 0.65 approach units rather than the last nine; ship, planet, wreck and guardian labels fade with the world. Cancellation restores opacity immediately. This preserves the existing reference-frame transition rather than claiming seamless descent.

15 transition assertions pass, including the visible approach at three units, hidden locators at the swap and cancellation recovery. Build `20260924-034422`. The isolated native eight-second sequence was refreshed. Independent critic confirms planet/ship visibility in frames 053/055/057 and world-label fading at 059, with surface visible under fade at 060 and clear at 065. Exact near-black duration and human feel are not established by sampled stills. Geographic landmark continuity and the final-braking speed rebound remain unresolved; neither this fade correction nor the earlier route-speed change establishes accepted flight feel.


## Continuous landing turns (24 September 2026)

Far-side landing previously treated every arc waypoint as a stopping destination. A measured fixture took 12.667 seconds, reaching only 0.84 units/s between intermediate points and spending 470 physics frames below half speed. Intermediate landing waypoints now use continuous travel speed and hand off within four units; only the final destination uses arrival slowdown. The identical fixture completes in 5.983 seconds with minimum intermediate speed 12.53 and zero slow frames. This changes landing guidance only, not ship maximum speed, travel prices or energy.

`tests/test_landing_flow.gd` checks the far-side duration/speed regression and 24 direction/integration-rate cases (30/60/120 Hz), including reaching the surface without touching the globe collision clamp. All pass, alongside 12 transition and 21 flight-presentation assertions. Synthetic native capture `tests/review_landing_motion.gd` samples an eight-second actual physics/camera sequence at 10 fps into artifacts/landing-motion, with trace.csv. This fixture uses standalone flight and isolated saves; it does not prove connected campaign progression or native human feel. Existing world art, transition disguise and sound acceptance remain open. Independent critic confirmed sustained intermediate speed in the sampled sequence, but flagged the black pre-arrival interval with orphaned orbital labels, lost landmark continuity and a small final-braking speed rebound. These are unresolved transition-presentation issues, not proven regressions without an earlier capture. The next descent pass should address these before claiming a smooth orbit-to-surface experience.


> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. Candidate V05 implementation, following the first composed HUD. This changes flight presentation and navigation intent, not world simulation scope.

## Behavior

- Ordinary wheel input now zooms the camera. Surface range: 12–110 local units; orbital range: 18–320. Camera distance eases toward the requested value. Dedicated arrow/numpad/WASD flight and altitude controls remain intact; Ctrl-wheel changes altitude.
- Another outward scroll at the surface overview limit starts actual ascent. Scrolling back in or pressing Stop cancels that camera-requested ascent. The view does not instantly teleport the ship into orbit. Plus/minus buttons beside the chart support mouse-only zoom.
- Wider orbital framing balances ship and planet; the camera avoids entering the globe. A brief world-only veil and location label cover the local reference-frame swap. This is not seamless planetary flight or system/galaxy integration.
- Coarse distant terrain surrounds the detailed basin, using the same height function. It is scenery; the playable travel radius remains unchanged. No additional settlements, resources or advertised destinations are fabricated.
- Two exhaust emitters respond to motion; atmospheric ground dust is restricted to low surface flight. Validated tool execution drives scan/thermal sweeps and directional specimen particles. Successful actions trigger a short burst; rejected operations cannot trigger success effects.
- All five particle emitters are reused and capped at **184 particles total**, simulated at 30 Hz. They reset on cancellation, pause/inspection and reference-frame transitions. They cannot change inventory, simulation time or rewards.

The implementation uses Godot's [CPUParticles3D](https://docs.godotengine.org/en/stable/classes/class_cpuparticles3d.html) with an original radial SVG sprite, keeping the existing compatibility renderer. Effects and engine audio use the same speed normalization/response. This does not replace or approve the rejected sound bank; acquiring the approved AI hum remains A01/A02 work.

## Evidence and limits

`tests/test_flight_presentation.gd` adds 21 checks for scroll intent, ascent/cancellation, manual-control priority, orbit arrival, preserved simulation time/history, wide-camera bounds, inspection guards, fixed particle budget, orbit dust suppression, effect reset and separation from saved state. Headless checks do not prove visual quality.

`tests/review_flight_effects.gd` renders arranged source-engine states to ignored `artifacts/flight_effects_*.png`: wide surface, thrust, active scan and wide orbit. These captures demonstrate actual components with scripted review inputs, not native player footage. Native flight feel, listening and human art approval remain open.

The ship, globe geography and underlying terrain art remain prototypes. Distant terrain and a wider camera do not constitute a new planet surface. Future system/galaxy navigation, authored ship art, more convincing planets and real-catalog stars remain tracked independently. Content breadth and depth across the whole game are a separate explicit requirement in [CONTENT_CORPUS.md](../direction/CONTENT_CORPUS.md).

Validation at this checkpoint: **353 assertions plus UI checks** (full suite, followed by targeted flight/presentation reruns for the final input-priority correction). Rendered effects and wide-view locators reviewed in engine.
