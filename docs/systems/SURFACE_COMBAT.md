# Surface weapons and persistent defenses

> Implementation checkpoint; statements of verification apply to its recorded scope, not final player acceptance. Consult source/tests for later changes. [Documentation map](../README.md).

23 September 2026. C01/P01 implementation checkpoint. The same expedition ship now fights on Nacre I and Kestrel I without entering a separate combat demo. Each has one pursuing flyer and two fixed defenses. Morrow remains a safe starting surface.

## Player decisions

| Weapon | Behavior | Cost and access |
| --- | --- | --- |
| Surveyor defense laser | Precise immediate hit against a selected ground or flying hostile; 26 m 3D reach | Starting equipment; 16 damage, 5 energy, one-second cycle |
| Seeker missile | Homing projectile against a flying target; 40 m reach; impact after two simulation seconds | 220 Marks; Defender 1 or Explorer 2; 45 damage, 14 energy, four-second cycle |
| Ground bomb | Click terrain to choose a fixed impact area; two-second delay; 7 m radius affects ground targets | 240 Marks; Defender 1 or Merchant 2; 50 damage, 18 energy, four-second cycle |

Select a weapon icon, then click the target. An out-of-range ship flies into range; Stop or manual steering cancels the order. Laser/missile orders continue until cancelled, energy runs out or the target is disabled. Bombs launch once per ground click. Switching weapons retains a shared surface cooldown. Projectile impacts use the authoritative simulation clock and continue after ascent; saving in flight preserves the eventual outcome. A missed ground aim still costs energy.

These are original scenario values and an initial role implementation, not a complete reference weapon catalog. Reference family research: [Laser](https://spore.fandom.com/wiki/Laser), [Missile](https://spore.fandom.com/wiki/Missile), [Bomb](https://spore.fandom.com/wiki/Bomb_%28ship_tool%29). Indexed excerpts establish family context; our target restrictions, tuning and local encounters are explicit adaptations. Continuous laser behavior, multiple weapon tiers, auto-defense, pulse/antimatter/support/extreme tools remain open.

## Challenge, rewards and persistence

Defenses mark a fixed 3D strike volume for two or three seconds before resolving damage. Move horizontally or vertically outside it to evade. Flyers pursue within a bounded home area; grounded sentries do not follow the ship. Their aim clears after departure. Off-screen defenses never attack a ship on another planet. Defeat returns the surface ship to the local port with 35 hull and at most 15 energy; it does not refill it.

Neutralized targets stay disabled. Click a wreck separately to approach and transfer its one-unit salvage into real available cargo space. Flyer wrecks settle to terrain. Cleared targets and recovered cargo cannot be farmed by re-entering the view or reloading. Defeats count as distinct Defender accomplishments and enter the chronicle. There are now nine available hostile contacts across orbit and surfaces, so Defender 3 is reachable; tiers requiring ten and twenty remain out of reach until later encounter breadth.

Session snapshot v10 adds validated combat records: per-world units, health, position, aim, projectiles, cooldown and salvage. Earlier campaigns start with no surface defeats or reward cargo. Cosmetics and scene nodes are excluded from saves. Explicit deterministic commands reproduce the same outcome. These are unaffiliated local threats; empire war, conquest and civilian/ecological collateral are not implemented by this checkpoint.

## Visuals and verification

The original modular kit is specified in [surface_defenses.json](../../art/specs/surface_defenses.json). Maximum visible combat presentation: three units/aim volumes, two projectile slots, two ground markers and four short-lived impact meshes. Selected targets show hull/wreck status. The initial overlapping filled aim spheres obscured the ship; thin outlines and reduced fill keep it visible. Decorative rocks leave clear defense footprints. Models, icons and reused audio remain provisional, not approved AAA production assets.

The full suite passes with **989 assertions plus UI checks**, including 37 new checks for mouse-ordered flight approach, target classes, energy/range/cooldowns, delayed and area hits, altitude evasion, recoverable defeat, salvage conservation, mid-projectile saves, legacy migration, corrupt-load atomicity and deterministic replay. Final placement/outline changes passed the 37 combat checks again. Native renderer captures at 1080p/1440p show warning/impact states. Native player combat feel, balance, dedicated weapon audio and final art remain open.

Next: connect allied fleet assistance to the existing diplomatic alliance, persistent ship records and losses. Continue weapon-family breadth and global planet manipulation; do not treat three surface roles as completed C01 or force empire conquest into this local encounter implementation.
