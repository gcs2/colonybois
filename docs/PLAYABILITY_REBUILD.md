# Space Stage playability and inhabited-world correction

23 September 2026, evening playtest. Supersedes the next-tool-family production priority. Full Space Stage breadth remains the eventual goal; more shallow systems cannot establish the requested quality.

The user reports clunky UI, stilted combat, cheap sounds, confusing zoom, slow and jumpy navigation, long transit waits and a tiny stage with little beneath it. Explorer recognition was the positive exception. They want big homeworld cities, clear animated guidance, aliens, communications, inhabited worlds and fully explorable procedural planets. Planet, system and galaxy navigation must occupy the screen.

## Evidence and current correction

Surface flight is clamped to a radius of 39 world units; scenery farther away is not traversable. `planet_generator.gd` samples seeded spherical geography, but `planet_geography.gd` builds the local ground from a different basin function. These are not whole explorable planets. The old 120,000-person urban scenario is separate from the flight campaign; it is not a visibly inhabited Morrow. Three faction portraits exist, but their communications are buried in panels. Travel uses 12 simulation seconds per link and six within a system, presented as real-time map waits. The rejected audio bank and missing replacement voice remain unresolved.

The full-screen checkpoint replaces the three map sub-windows with viewport-filling world canvases and overlaid instruments. Flight HUD hides underneath. Galaxy wheel zoom anchors to the cursor; right-drag pans; Frame sector restores the overview. Escape stays above maps. A surface-dock typed-array exception found through actual approach testing is fixed. Survey costs, fog, routes, economy and save format remain intact.

Evidence: 69 focused checks cover 1080p/1440p/ultrawide bounds, zoom/pan, modal ordering and actual docking. Existing planet-map 34, system 41, interstellar 45, HUD 50, transition 12 and diplomacy 45 checks pass. Actual 1080p/1440p planet, system, sector and menu renders inspected. This establishes the layout correction, not final art or fun.

The unshipped eight-lesson guide was set aside after the playtest. Files remain only in ignored `artifacts/paused-flight-guide`; no v19 save change was retained. Responsive play precedes more tutorial production.

## Next production order

1. **Flight and travel feel:** predictable wheel/scale changes, short purposeful system transitions, smooth movement and responsive targeting. Profile real input and scene construction. Keep fuel costs and danger; no long empty countdowns or new cheap synthesized sounds.
2. **Inhabited Morrow:** coherent city districts, roads, landmarks and spaceport, visible arrivals/departures, real services, useful destinations and obvious communications. Derive presentation from aggregate population/production; cap traffic. Decorative traffic is not real freight. Reusing the rejected old city unchanged is not an art solution.
3. **Whole-planet exploration:** shared seeded geography across orbit and ground; terrain/vegetation streaming, persistent positions and changes, long-distance flight and no basin wall. Verify coastlines agree, region boundaries traverse continuously, returns preserve changes, and memory/frame time stay bounded. Civilizations, resources, discoveries and hazards must give regions meaning.
4. **Expressive contact and guidance:** visible incoming calls, animated original representatives, clear response controls and consequential choices. Moving pointers and short contextual captions/approved speech teach actions without a mandatory checklist. Preserve the well-received Explorer feedback.
5. **Combat and audio quality:** playtest movement, aiming, attack timing and effects; acquire approved AI sound candidates and listen to the mixed result. More catalog entries cannot substitute for these gates.

## Scale discussion — proposal

The user asks whether planet-sized planets relative to the ship move toward No Man's Sky. Its official [description](https://www.nomanssky.com/about/) emphasizes traversable destinations and seamless surface-to-space flight. Size supports that experience but does not supply geography, content or fluid travel.

Recommend testing complete, smaller-than-real planets with local flight and fast long-distance cruise. At 1,000 km/h, an approximately 40,000 km Earth-equator journey takes about 40 hours. No final radius is selected. Keep Spore-like expressive civilizations, ship tools and galactic consequences central.

Godot's [large-world documentation](https://docs.godotengine.org/en/stable/tutorials/physics/large_world_coordinates.html) explains precision loss and origin shifting/double precision. Stream detail in levels around the player; keep offscreen economy aggregate. Double precision alone supplies neither streaming nor content and has shader limitations. No engine migration or custom engine build is approved by this exploratory question.
