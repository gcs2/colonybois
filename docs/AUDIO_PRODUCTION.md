# Flight audio production

**Rejected, 23 September:** the user rejected the first synthesized one-shot audition as keyboard-like. Passing routing tests was not artistic acceptance. The replacement must use an AI sound-generation model, with whirring/humming ship equipment and synchronized particles. See `art/specs/audio_ai_v2.json`. The public ElevenLabs page returned four hum candidates; no purchase/signup took place and none are integrated. The library shortlist below is historical research, not an approved shopping task. The previous runtime bank is pending replacement; do not present it as accepted.

23 September 2026. The user explicitly wants sound for meaningful interaction, especially selecting hotbar tools, and is open to paying for higher-quality music and voice performances. These are **candidate sounds**, not a claim of final AAA audio quality.

## Implemented first pass

`tools/AuthorAudio.py` reproducibly generates twenty original stereo WAVs under `assets/audio/`. It uses oscillators, filtered noise and a small authored harmonic/melodic score; no extracted Spore sounds, reference recordings, paid samples or external generation service. The generator requires Python 3 and NumPy. All candidate WAVs are 24 kHz, 16-bit stereo. The music is a 48-second, 80-BPM ambient loop titled **Morrow Drift**. Composition, sound selection and mix still require listening review.

`scripts/flight_audio.gd` keeps audio outside the simulation. Four short voices handle events; independent players handle thrust, planetary air, music and recorded dialogue. Thrust follows actual movement speed, and stops on pause. Planetary air disappears in orbit. Music ducks beneath speech. Effects, music and guide voice have independent sliders saved in `user://flight_audio.cfg`. Voice level zero stops speech; instructions and captions remain visible. Rapid hover events are rate limited.

| Event | Cue / behavior |
| --- | --- |
| Hover an enabled button | Quiet, rate-limited tick |
| Select any of four tools, via button or number key | Distinct `equip_*` cue; no stacked generic click |
| Open / close panel | Rising / falling UI cue |
| Other buttons | Short confirmation |
| Click terrain | Navigation confirmation |
| Acquire a valid tool target | Target lock |
| Stop / cancel | Descending cancel cue |
| Tool running | Existing scan / tractor / thermal / deployment audio |
| Scan completes | Scan-complete interval |
| Other tool succeeds | Cargo/operation response |
| Invalid action | Error cue |
| Actual ship motion | Smoothed thrust loop with changing pitch/gain |
| Depart / begin return approach | Opposing departure/entry sweeps |
| Save / restore | Save confirmation or error |
| Surface environment | Quiet air bed |
| Background music | Morrow Drift loop, ducked under dialogue |
| Spoken tutorial | Four concise contextual lines and on-screen captions |

The achievement cue exists but is not yet bound to a complete achievement presentation. Weapons, impacts, incoming-fire warnings, hull alarms, destruction, real station communications, species vocalizations, spatial environmental audio, city audio coverage and event-specific scoring remain required as those systems are implemented. The current bank is **not** full-game audio coverage.

## Dialogue and replacement contract

The guide currently uses the installed Windows voice through Godot's text-to-speech interface. This is scratch narration for timing/accessibility, **not final voice acting**. There is no uploaded voice clone or paid service call. If no English system voice is available, captions and visual instructions still work. Godot's [TTS documentation](https://docs.godotengine.org/en/4.6/tutorials/audio/text_to_speech.html) documents the enabled project setting and system dependency.

Licensed recordings can replace speech by adding `assets/audio/voice/{id}.wav`; the controller prefers a recording. Export lossless source masters, then choose runtime compression after audition. Keep each line separate, normalize consistently, preserve a little lead-in, and avoid long silence. Required IDs and current exact script:

| ID | Script |
| --- | --- |
| survey | Captain, that relay is still transmitting. Click it and we'll approach for a scan. |
| ascend | The signal leads off-world. Pull the view back to ascend, or select Leave atmosphere. |
| orbit | We're clear of the atmosphere. Click Morrow when you're ready to descend. |
| return | Back in the basin. Your surveys are secure. You're free to explore. |
| preview | Flight systems ready. Let's see what's beyond those clouds. |

Performance brief: competent expedition crewmate, dry warmth, restrained wonder, concise radio delivery. Avoid a theatrical tutorial announcer, babyish alien squeaks, relentless chatter or imitation of a recognizable actor. Character and casting approval remain open. The human Sol start should have its own diegetic context rather than reuse Morrow's relay line blindly.

## Paid sourcing: shortlist, not a purchase

Research date: 23 September 2026. Verify the live quote and intended game-distribution license before buying; no account/signup/subscription/purchase has been performed.

- **ElevenLabs for voice auditions and bespoke SFX:** the [current pricing page](https://elevenlabs.io/pricing) lists paid commercial plans, and its [publication guidance](https://help.elevenlabs.io/hc/en-us/articles/13313564601361-Can-I-publish-the-content-I-generate-on-the-platform) distinguishes free from paid generation. Audition the actual five lines before selecting a voice or plan. Do not assume a free-generated audition becomes commercially licensed after upgrading.
- **BOOM for authored sound libraries:** compare the actual [technology/UI collections](https://www.boomlibrary.com/product-category/technology/) against our sound palette. Use a specific package and its license, not a generic assumption about the entire catalog. Avoid buying a massive library before hearing whether it fits these instruments.
- **Music needs separate checking:** ElevenLabs' [music page](https://elevenlabs.io/music) currently distinguishes studio-game use in its plan restrictions. A generic commercial-voice subscription is not proof of game-music rights. Commissioned original music or a specifically licensed indie-game library is also a viable route. Obtain a concrete quote, distribution rights, stems and loopable deliveries.

Do not put restricted paid source libraries in the public repository. Track license/provenance and approved game-ready derivatives as permitted. Original generated-by-code candidate WAVs here have no third-party sample dependencies.

## Verification and remaining listening gate

`tests/test_audio.gd` verifies that each actual hotbar button emits exactly one equip event, the four assets differ, hover cannot chatter, valid targets/navigation/cancel have cues, loops respond to movement/pause/orbit/mute, settings persist and the three volume sliders are available. These checks prove routing and state, not that it sounds satisfying. Waveform inspection checks peaks and loop boundaries; rendered smoke checks asset loading and runtime errors. Listening through the real game and external speakers/headphones remains necessary before accepting the mix.

## Latest guide-voice decision — 23 September

User rejected the Windows scratch voice. The fallback is now removed entirely. Contextual captions remain, and the recorded-line playback path remains available. No replacement voice is supplied yet. Next: short AI auditions for an understated, expressive alien expedition guide; review delivery in the actual flight mix before committing to casting. No paid voice service or license has been purchased or authorized.
