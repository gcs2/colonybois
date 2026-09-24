# A conversation with somebody

> Design intent; task status and execution order live in the task board. [Documentation map](../README.md).

24 September 2026. Proposed Field Instruments encounter specification, informed by the independent critic. This is a design and production gate, not implemented or user-accepted presentation. Owning production tasks remain D01, V01/V02 and A01–A03 in TASK_BOARD.md.

## Evidence and correction

The inspected Spore contact/shop frames at [2:00:12](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7212s) and [2:00:23](https://www.youtube.com/watch?v=0NN5fBVEHcA&t=7223s) show a representative beside greeting/actions, retained beside equipment and cargo in commerce. They support composition and different visible poses, not exact reaction timing or sound. See SPORE_EXTENDED_VIDEO_EVIDENCE.md for resolution limits.

Our actual `artifacts/contact_consortium.png` buries choices in a scrolling generic inspector. The original implementation destroyed/recreated AlienPortrait on every popup refresh and repeated `respond()` while `contact_reply` was nonempty. The 24 September lifecycle correction retains the actor across contact drawers and triggers responses only from actual diplomatic command results; closing, changing representative or leaving communications clears it. The subsequent local-shop checkpoint extends that same actor into commerce when its faction owns the dock. `scripts/alien_portrait.gd` still supplies texture bobbing, blink/gaze and a procedural mouth. This is scaffolding, not authored acting. `expedition_diplomacy.gd::greeting` now distinguishes first/repeat, trade, alliance, embargo and war; answering persists acknowledgment. Authored acting remains absent.

All inspection panels currently pause authoritative campaign time. Keep that contract until deliberately redesigned; a pretty alarm must not secretly run combat under a modal. Existing danger should remain visible, with immediate return to flight. Closing a conversation never waits for goodbye animation.

## Persistent encounter composition

24 September implementation update: contact drawers and local alien shop drawers now retain the representative; purchases trigger command-result state once. The user authorized existing generated concepts as portraits, and Tavi uses a static extracted illustration without procedural facial overlays. See [current contact checkpoint](../systems/EXPEDITION_CONTACT.md) for exact evidence and open presentation gates. The remaining requirements below are targets, not a claim of delivered acting.

Retain one representative instance and one encounter identity through greeting, relations, commerce and fleet drawers. Drawer changes must not reset gaze, breathing or an in-progress gesture. A response is triggered once by a command result, never merely because a response string exists. A failed action cannot animate a successful transaction. Closing and reopening must not replay an old acceptance.

Normal contact: a compact character stage, identity, one short greeting, current attitude and four recognizable choices; fixed close/goodbye. All fit at 1080p without scrolling. Species and role are available as identity details; government and philosophy remain separate. Large commerce drawers may use more area because they display real goods. Ordinary world HUD remains compact and consistent.

Remote conversation does not confer docking access. When within the proper dock context, show **Dock services**. Otherwise show **Approach dock** for a reachable local service, or an unavailable state with a clear location/access reason. The generated greeting candidate's unqualified Dock services label is a known limitation, not a rule change.

The current actor should persist when Trade replaces choices with equipment/commodities, carried cargo and transaction detail. Selected item detail owns description, unit price, quantity, total, stock/demand, capacity and resulting Marks. Do not expand every item into a paragraph. Commit uses existing validated commerce commands atomically; cancellation does nothing.

## Performance states

| State | Visible performance | Input and consequence |
|---|---|---|
| Incoming | Compact shutter/signal with a glimpse of the representative | Answer or defer; never hijack steering |
| First greeting | Eye contact, one identifying gesture; brief identity reveal | Skip reaches stable choices immediately; preserve encounter/read state |
| Repeat greeting | Short contextual acknowledgment | Trade is immediately available where access permits; no repeated ceremony |
| Listening | Restrained breathing/blink, motivated glance at a prop | No constant talking mouth; choices stay stable |
| Considering | Short hesitation attached to a submitted proposal | Do not add a fake network-like wait to a synchronous command |
| Acceptance | Distinct posture/gesture, then settle | Show the actual agreement, Marks, goods or access change once |
| Refusal | Different gaze/posture and concise reason | No resource mutation; enough explanation to choose differently |
| Commerce | Same actor remains, quieter than the goods | Item selection does not restart greeting or speech |
| Existing danger | Alert stays visible inside the paused encounter | Return to flight closes immediately; no hidden ticking threat |
| Goodbye | Small acknowledgment, optional short tail | Never delays closing or captures input |

Tavi Rill is an individual exchange delegate, not a species-wide merchant joke. Preserve the lavender mantle, throat folds, teal feelers/collar, unusual grasping limbs and amber trade flask. Give the eyes a deliberate shared target with subtle asymmetry. Waiting can involve inspecting the flask; acceptance might raise it, refusal draw it close. These are proposed authored gestures, not new simulation actions or a promise of a finished rig. Avoid adding more sine waves to imitate acting.

## Reusable art and audio specification

Start with a reusable layered portrait or a modest 3D bust in a SubViewport; choose after a bounded visual prototype. Neither method requires a new renderer. Deliver separate eye/lid/mouth controls, mantle and two gesture limbs, a prop grip, and stable portrait framing. The backdrop needs only enough original modular set dressing to suggest a place. Keep source layers/rig and exported animation clips, not just a flattened concept image. Pose silhouettes must still read in a small incoming-call window.

Initial authored clips: listening loop, greeting, acceptance, refusal and alarm. Gaze/eye motion supports the pose rather than replacing it. Retargeting across species may share state names and event timing, but not identical body gestures. Reduced motion suppresses housing travel, bounce and camera movement; expressions can switch directly without concealing mood or consequences.

Audio is not approved. No browser playback has been heard by this agent; listening coverage is zero. Prepare original auditions, then listen before integration. No voice imitation or reuse of Spore's sound bank. No purchase without a concrete approved price and license.

| Cue | Audition brief | Integration contract |
|---|---|---|
| Connection | Brief soft relay latch and gentle carrier opening; avoid musical keyboard bounce | One opening cue; no retrigger on drawer refresh |
| Tavi greeting | Expressive nonverbal alien phrase with curious rising inflection, warm breath and subtle liquid resonance; not infant babble | Caption carries meaning; gesture accents follow a reviewed recording |
| Acceptance / refusal | Two clearly distinct short performances: satisfied exhale vs restrained doubtful inflection | Actual command result chooses one; never random polarity |
| Transaction | Quiet physical transfer/receipt punctuation | Once after committed stock/cargo/Marks update; avoid stacking with loud reward cues |
| Alarm | Short intelligible warning hierarchy over ambient sound | Higher priority than idle chatter; stops/reduces competing voice |
| Milestone | Original brief musical recognition phrase, anchored to Explorer's well-received feedback | Does not play for routine trades or every button |

Record file, generator/performer, prompt, license, duration, edits, reviewer and listening verdict for each audition. A waveform or file existing is not approval. Do not fabricate lip sync from arbitrary periodic mouth motion: use authored syllable envelopes after audition, or keep expressive vocalization nonliteral with a few intentional mouth shapes. Separate voice, UI, ship/world effects and music buses; captions and volume controls remain available. Scene loading/saving must not trigger overlapping greetings.

## Acceptance before calling the encounter polished

- Native 1080p and 1440p review: primary choices, exit, hover/focus names, selected and unavailable states readable; no main-choice scrolling.
- One uncut capture: first contact → choices → transaction → relations → repeat trade → close. Representative persists; responses do not repeat from tab switches.
- Successful and rejected commands show actual changes exactly once; distance, embargo, affordability, stock and cargo limits remain enforced.
- First contact, repeat greeting, refusal, embargo, existing danger and reduced-motion states each have a mock and actual implementation evidence.
- Character gestures, original voice, music and cue layering receive listening/motion review. Static mocks alone cannot pass this gate.
- Independent critic compares actual captures against Spore evidence and the original target. User acceptance remains a separate open gate.

## User review supersedes candidate dialogue and face

The user endorses the contact window and interaction choices, but rejects the face and the transmission-delay joke. Preserve the composition. Use direct dialogue; do not write further jokes for this project. Personality should come through purposeful performance and clear individual concerns. Source greeting: “I’m Tavi Rill. If you’re here to trade, let’s see what you’ve brought.” v2/v3 bitmaps contain obsolete dialogue. v3 face remains unapproved and is too human/sleepy; do not promote it to production art.

Follow-up: the user softened the criticism of the joke. Do not interpret that as approval of the line or as a failure of the user's understanding. Keep the direct replacement. The explicit request for a more alien face stands: explore nonhuman eye placement, sensory organs and mouth anatomy rather than human facial features on purple skin.

Latest direction: write lines an actor could naturally speak in an adventure film. Give each line a clear immediate intention, conversational rhythm and playable subtext. Avoid clever-sounding maxims, explanatory job-title introductions and forced quips. Example active greeting: “I’m Tavi Rill. If you’re here to trade, let’s see what you’ve brought.” Personality comes through delivery and the encounter, not an obscure punchline.

## Immediate tooltips (24 September 2026)

The user supplied an EU4 menu screenshot: compact pictorial navigation, immediate hover identification and a shortcut line. Adopt that interaction principle within Field Instruments. Native Control tooltips now have zero configured delay. Lead with the name and a real bound shortcut when one exists, then concise effects or unavailable reasons. Remaining text-only navigation and tooltip styling need conversion; a synthetic pointer over the actual contact action now confirms a visible native tooltip within three frames (51.218 ms observed), without clicking. Human timing acceptance remains open.
