# Generation prompts for the approved Morrow visual canon

These are the actual prompts used to generate the three approved Morrow flight views. The selected source images and this prompt record now share one tracked project-root home in art/visual-canon. The galaxy reference predates this prompt set; its image provenance is linked from the canon README.
## Exact prompts and selected source records

### 01 — Orbital gameplay
**Selected source:** exec-4fbdffbc-6d04-4090-bc28-09a8336177f3.png

**Refs:** v1 01-orbital-gameplay.png; selected surface 01-surface-populated-v3.png

    Use case: ui-mockup
    Asset type: one standalone 16:9 orbital-flight gameplay screenshot, revision 02 for Frontier Worlds.
    Primary request: Revise Image 1, keeping its strong player-follow composition, large Morrow planet, small scout, route and complete Field Instruments HUD. Use Image 2 as the authoritative selected Morrow surface/environment and ship/HUD scale reference. Correct the altitude conflict by replacing the relay tooltip's near-range text "18 m" with a destination cue that has no distance. Clearly show this is orbit by adding a small ORBIT state beneath MORROW at upper left.
    Input images: Image 1 is the v1 orbital proposal to revise; preserve its composition, ship, route, planet dominance, complete tabbed two-row pictorial inventory with quantities, top-left notification, top-right Marks, and compact hull/energy. Image 2 is the user-selected Morrow surface target, authoritative for the same planet, scout design, art quality and Field Instruments language.
    Scene/backdrop: same Morrow, a prominent curved rust-and-teal world with a bright atmospheric limb, readable route and clear relay/landing-region destination cue. Keep the world much larger than the player scout.
    Subject: same cream-and-rust scout in practical player-follow orbital flight, about 6% of image width. ALT remains clearly secondary to hull and energy.
    Style/medium: polished original in-game mock screenshot, tactile compact matte ivory instruments, charcoal inset displays, purposeful functional yellow/teal/coral accents, readable pictorial item tiles and typography, rich planet art guided by Image 2; no copied Spore art.
    Composition/framing: landscape 16:9. Keep existing strong v1 placement of small scout over the dominant Morrow globe, route to selected relay, top-left MORROW title plus small ORBIT state, top-left notification, top-right Marks and bottom-right full tabbed two-row inventory/cargo with quantities and compact hull/energy. Preserve ALT as a tiny secondary readout. Destination cue can say Relay discovered or Survey relay, but no distance or numeric near-range value.
    Text (verbatim): MORROW; ORBIT; Relay discovered; Survey relay; Marks; HULL; ENERGY; ALT.
    Constraints: Fix the contradiction between 352 km ALT and 18 m destination distance by omitting the distance. Add ORBIT beneath Morrow. Preserve player-follow framing, small scout, planet, route, full two-row inventory, top-corner anchors and compact HUD.
    Avoid: changing the altitude to a large panel, large ship, near-range destination distance, missing ORBIT state, surface chart, thin icon strip, missing inventory quantities, blue Windows panels, rounded icon wells, shiny copper-like borders, shallow-focus blur, cinematic framing, collage, triptych, any changes to the user-selected surface reference.

### 02 — Solar-system map
**Selected source:** exec-7bbd2be0-8193-4ec0-bd02-1a4f53e7ce46.png

**Refs:** v1 02-solar-system-map.png; selected surface 01-surface-populated-v3.png; 04-system-v1.png; 05-galaxy-local-v2.png

    Use case: ui-mockup
    Asset type: one standalone 16:9 solar-system departure decision screenshot, revision 02 for Frontier Worlds.
    Primary request: Revise Image 1. Keep its readable single-star planetary system, Morrow selection and route, complete two-row inventory and Field Instruments HUD. Remove the redundant circular system overview radar at lower left because the orbital system is already the full canvas. Replace the current-ship planet-like disk with a distinctive small cream-and-rust scout silhouette that reads immediately as a ship. Make the selected Morrow trip a real departure choice showing exactly: Fly · 3 energy · 6 seconds. Show current Energy 36/100 and post-departure Energy 33/100 so the cost is explicit and correct.
    Input images: Image 1 is the v1 system-map proposal to revise. Image 2 is the selected Morrow surface target and authoritative HUD/environment reference. Image 3 is the original solar-system layout study. Image 4 is the separate galaxy-scale navigation study; retain the clear scale distinction and do not show a galaxy map.
    Scene/backdrop: one bright central star with multiple distinct planets, at least one moon, clear elliptical orbital paths, and dark-space contrast. Morrow is the highlighted rust-and-teal planet with a relay-discovered cue. A selected route links the distinctive small scout icon at its current orbital position to Morrow.
    Subject: full-canvas solar-system navigation view used to decide whether to launch a local trip. The small scout silhouette replaces the current-ship planet disk. The selected destination is Morrow.
    Style/medium: polished original gameplay screenshot, matte ivory Field Instruments casings, charcoal inset displays, restrained yellow/teal/coral functional accents, pictorial controls, readable original typography, grounded in Image 2. No copied Spore art.
    Composition/framing: landscape 16:9. The single-system orbital diagram fills the full main canvas with no duplicate mini-system radar, no surface chart and no galaxy view. Keep upper-left notification, upper-right Marks, complete tabbed two-row pictorial inventory/cargo with quantities, and compact hull and energy status. Put departure action near the selected destination in a clear compact callout. Current hull 100/100 and Energy 36/100; show post-departure energy 33/100. Keep all text and controls readable and compact.
    Lighting/mood: precise navigational contrast and quiet wonder; luminous star, planets readable against dark space; functional and exploratory.
    Text (verbatim): MORROW SYSTEM; Relay discovered; Current ship; Morrow; Fly · 3 energy · 6 seconds; Energy 36/100; After departure 33/100; Marks; HULL 100/100; ENERGY.
    Constraints: Correct local-system travel context is Fly, 3 energy and 6 seconds. Explicitly show current 36/100 energy and post-departure 33/100. Replace the marker's planet-like disk with a recognizable tiny ship silhouette. Remove the redundant lower-left overview radar. Keep the star, planets, orbital paths, Morrow selection and relay cue, route, full inventory, Marks, notifications, hull and energy.
    Avoid: lower-left mini-system radar, surface chart, spiral galaxy, current-ship marker as planet, wrong energy/time, incorrect post-departure value, oversized ship, missing inventory, thin icon strip, blue Windows panels, rounded icon wells, shiny copper-like borders, collage, triptych, copied Spore artwork.

### 03 — Approach and arrival
**Selected source:** exec-632c78f0-da82-4e2d-bcde-190e3774c0c1.png

**Refs:** latest approach scale output exec-9e315f3e-7f91-4b3e-8470-290f2181b4bd.png; selected surface 01-surface-populated-v3.png; lower-bound approach output exec-4164107d-ec42-4495-9b34-2e7106d0b97a.png

    Use case: ui-mockup
    Asset type: one standalone 16:9 Morrow approach gameplay screenshot, revision 02 for Frontier Worlds.
    Primary request: Correct the scout size in Image 1. Keep its composition and sharp ground scene, but reduce the ship body from its current oversized appearance to a size matching the user-selected ship in Image 2. Image 2's ship is about 6% of the full image width. For a 1672-pixel-wide output, target roughly 100 pixels across the cream-and-rust body, excluding engine trails. Image 3 shows the lower size bound that became too small; make the ship visibly larger than Image 3 but smaller than Image 1, centered close to the exact scale of Image 2.
    Input images: Image 1 is the latest approach scene with correct sharp focus and HUD but an overly large ship; preserve its overall composition and route. Image 2 is the authoritative selected Morrow surface reference for ship scale and landscape. Image 3 is the previous approach scale attempt, only a lower-bound check to avoid making the ship too tiny.
    Scene/backdrop: same Morrow target: broad warm rusty landscape, turquoise lake at left-center, white relay beacon by the lake, teal plant clusters, rocks, orange alien grazers and distant ridged mountains. Preserve the selected reference's lake/relay relation. A clear route line reaches the relay.
    Subject: the same cream-and-rust scout in an ordinary player-follow approach view. Body spans approximately 100 of 1672 pixels, about 6% of image width. Exclude exhaust trails from measurement. Keep the ship a small tool against the landscape.
    Style/medium: polished original game screenshot, rich stylized miniature world and tactile Field Instruments HUD matching Image 2. Crisp readable terrain.
    Composition/framing: landscape 16:9. Preserve Image 1's broad view, selected lake and relay, clear approach cue, exact surface chart at lower left, complete tabbed two-row equipment/cargo inventory and quantities at lower right, top-left notification, top-right Marks, compact hull/energy and tiny secondary ALT. Keep lower foreground fully in focus.
    Lighting/mood: warm daylight, clear and lively, with only gentle atmospheric depth in distant mountains.
    Text (verbatim): Morrow; Relay discovered; Survey relay; Marks; HULL; ENERGY; ALT.
    Constraints: Keep the scout at about 6% full-screen width, matching the selected user surface target. Preserve Image 1's sharp foreground and landscape arrangement. Use Image 3 only to ensure the scale is not made too small again.
    Avoid: ship body below 5% or above 6.5% of image width, close-up ship, fuzzy terrain, depth of field, defocused foreground, tilt-shift, motion blur, cinematic view, changed lake/relay location, missing HUD elements, sparse terrain, blue Windows panels, rounded icon wells, copper borders, collage, triptych.

These exact v2 images were approved by the user as static visual canon on 25 September 2026. Their UI text remains illustrative and is not runtime or campaign-state evidence.
