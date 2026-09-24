# Orbital custodian pilot

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

Superseded scope note: [Multi-world orbital encounters](ORBITAL_ENCOUNTERS.md) now adds Nacre/Kestrel threats, dodgable warning volumes, paid emitter progression and persistent salvage. The Morrow behavior described below remains the baseline; its old assertion count and priority notes are historical.

A single old skiff guards the Morrow wreck. It warns for two simulation ticks, fires after the third, chases within a bounded region and disengages when the scout retreats. Entry and emergency-tow positions are outside its alert radius. Its ownership remains unknown.

Click its contact or the Arc lance control (top-row 5) to approach and fire. Stop, manual steering, pause, or another command cancels. Three hits disable the skiff without destroying it. Each shot costs 10 energy, reaches 24 local units, and recovers for two ticks. Incoming shots cost 10 hull, reduced to 3 by the recovered phase shroud. The separate wreck pulse field remains dangerous after disable.

Model version 5 persists target position, hull, alert, cooldowns and shots, and migrates version 4 saves. Tests cover warning, safe spawn, retreat, cooldown, energy, shield, disabling, persistence, deterministic continuation, invalid state, command replacement and cancellation. Full suite: 440 assertions plus UI checks.

This is one local combat pilot, not fleet combat or a weapon corpus. Primitive ship geometry, the reused scan cue for firing, and final balance need production work and native playtesting. Latest user priorities are voice, zoom/descent and planets before further combat expansion.
