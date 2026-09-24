# First-person flight: stack assessment

> Reference research; observations, proposals and evidence gaps are not implementation status. [Documentation map](../README.md).

Recommendation: retain Godot 4.7.2 and typed GDScript for the present project; validate a small flight scene early. First-person piloting is now part of the desired long-term direction. The current build has neither a flight controller nor combat AI, and its performance tests do not validate either.

## What stays, what gets tested

- Godot owns 3D rendering, input, audio and physics. We author ship handling, targeting, weapons, avoidance, squadron commands and combat rules. Choosing an engine does not supply those game systems automatically.
- Keep GDScript for gameplay/state orchestration. Profile before considering native code for specific high-volume work; do not rewrite the whole simulation in another language on speculation.
- Continue authored 3D sources and GLB exports. Pilotable craft need all-angle exterior geometry and a separate close-view cockpit. A city sprite technique does not have to dictate the combat presentation.
- Current `project.godot` uses Compatibility/OpenGL. Test Forward+ for the desktop flight/art pilot, including shader, lighting and asset compatibility. Forward+ offers more rendering features, but its higher baseline cost means it is not automatically faster. Leave the working project configuration unchanged until measured comparison justifies a switch. [Godot renderer documentation](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html).

## Scale boundaries

Represent galaxy/system locations as strategic IDs and graph edges. Instantiate a local flight scene centered near its origin for an encounter, orbit or landmark. The galaxy graph is not a single physics scene spanning light-years. Persistent ship records create local combat bodies and receive bounded outcome updates when the encounter ends; apply results exactly once, including on save/load or retry.

First-person flight does not require seamless planet-to-planet traversal. If seamless physical travel becomes a requirement, reassess coordinate precision, origin shifting, streaming, high-speed collisions and terrain LOD before committing. Godot documents precision limits and the additional cost of large-world coordinates. Separate local levels can avoid much of that requirement. [Large-world coordinates](https://docs.godotengine.org/en/stable/tutorials/physics/large_world_coordinates.html).

Strategic economy runs on slow ticks; flight movement runs on fixed physics ticks with independently rendered camera motion. Start testing at 60 physics ticks/second, not as an immutable promise. Tune input latency and interpolation rather than enabling smoothing blindly. Use swept collision queries or appropriate continuous collision handling for fast projectiles. Deterministic strategy replay is not a promise of bit-identical 3D physics on different machines. [Godot interpolation guidance](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/using_physics_interpolation.html).

## Early proof, before expensive ship production

Provisional test scope: one piloted ship with cockpit and chase cameras; pitch/yaw/roll and translation; assist/brake controls; one weapon; target drones; then up to six wingmates and eight enemies with bounded projectiles. Counts are test fixtures, not promised maximum battle size. Avoid an empty black void: nearby debris, a large landmark, engine audio and stable reference cues make speed readable.

Measure input feel, targeting, high-speed collision, wingmate avoidance, camera jitter, frame-time spikes and legibility under effects. Start with fixed test hardware/resolution and record a 60 FPS target as a measured gate. Test keyboard/mouse and controller separately. A good frame average does not excuse judder or laggy aim.

Flight model is still a design choice: assisted six-axis space flight, stronger inertial handling, or a more demanding simulator. First-person describes the view, not the realism level. Choose through the controller prototype; do not promise orbital mechanics, atmospheric aerodynamics or full cockpit instrumentation unless they improve the intended game.

If this bounded slice cannot meet control and performance goals after profiling, compare a small equivalent prototype in another engine before producing a large asset library. Do not migrate merely because the existing city art is weak; that is not evidence of an engine limit. Conversely, do not dismiss a measured technical limit to protect sunk work.

## Fit with the core game

The main loop remains exploration, ecology, logistics and diplomacy. Combat allows the player to lead personally while wingmates execute orders. Strategic production equips ships; training consumes colony capacity; damage and losses create repair/replacement demand. The flight test is an early risk check; broad combat production follows the three-world trade loop. Single-player remains the scope.
