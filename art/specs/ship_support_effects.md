# Active combat support effects

Original candidate effects, 23 September 2026. Not final art/audio approval.

- Shield: a translucent cyan envelope following the actual flagship position, radius 3.9 m and height 6.2 m. Strong edge, nearly clear interior, thin travelling bands. A blocked strike brightens it for its simulation tick. Never replace the ship silhouette with an opaque sphere. No glow-dependent rendering path; supports the current Compatibility renderer.
- Rally Call: a violet orbital ring and expanding, fading signal ring centred on the flagship. Its tempo stops during inspection/pause. Actual personal and escort shots carry the buff; the effect is not a second damage system.
- Icons: editable 64 px vector shield/formation silhouettes within the existing temporary vocabulary. No icon wells, copper frames or persistent headings above the tool palette. Tooltips name the ability, costs, duration, cooldown and target scope. Active icons beside ship condition retain countdowns even when another palette category is selected.
- Budget: one 32×16 sphere and two 48-segment rings per flagship, hidden when inactive. No unbounded particles or physics objects. Explicit shader phase freezes with inspection. Shield impact is visual only and never written as persistent damage state.
- Audio: activation and blocked impacts currently reuse existing scan/lock candidate cues. Dedicated generated/licensed masters, listening review and final mix remain outstanding. No new audio purchase or synthetic sound-generation claim.

Source: `ship_support_visual.gd`, `ship_shield.gdshader`, `shield.svg`, `rally_call.svg`. In-engine review: `tools/CaptureShipSupport.gd` at 1080p/1440p.
