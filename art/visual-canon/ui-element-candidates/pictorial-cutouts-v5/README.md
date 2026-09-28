# Surface exploration tool cutouts — v5

Generated with built-in ImageGen on 28 September 2026 as three separate, transparent item illustrations, using the earlier approved scanner candidate as a material/style reference. These are focused tool pictures, not crops from a mock. The scanner candidate had its baked checkerboard removed before alpha was validated. Each source was trimmed to its visible silhouette and downsampled to a 384×384 RGBA game icon with transparent padding.

| File | Live action | Runtime state |
|---|---|---|
| [field-survey-scanner-v1.png](field-survey-scanner-v1.png) | scan | Picture only; selection, target and result remain live. |
| [field-sampling-cradle-v1.png](field-sampling-cradle-v1.png) | collect | Picture only; scan eligibility and collection result remain live. |
| [ore-seam-cutter-v1.png](ore-seam-cutter-v1.png) | mine | Picture only; deposit selection, depletion and yields remain live. |

The three files are mapped in scripts/flight_cargo_icon.gd. Their transparent source images remain in the generated-image workspace; the prompt and source identifiers are recorded in [PROMPTS.md](PROMPTS.md). This is a narrow pictorial-slot improvement, not HUD or game-wide visual acceptance. Runtime rendering and icon recognition at both supported review sizes remain to be checked when it is safe to launch Godot.
