# Wider flight camera and bounded effects

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

The ship, globe geography and underlying terrain art remain prototypes. Distant terrain and a wider camera do not constitute a new planet surface. Future system/galaxy navigation, authored ship art, more convincing planets and real-catalog stars remain tracked independently. Content breadth and depth across the whole game are a separate explicit requirement in [CONTENT_CORPUS.md](CONTENT_CORPUS.md).

Validation at this checkpoint: **353 assertions plus UI checks** (full suite, followed by targeted flight/presentation reruns for the final input-priority correction). Rendered effects and wide-view locators reviewed in engine.
