"""Original flight sound candidates. Python 3 + NumPy; no sampled/third-party audio.

Run from any directory. Reproduces the WAV masters committed under assets/audio.
Music is a 48-second, 80-BPM ambient cue; loops use sample-aligned periodic tones.
"""
from pathlib import Path
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "audio"
RATE = 24000
rng = np.random.default_rng(9023)


def write(name, samples):
    samples = np.asarray(samples)
    if samples.ndim == 1:
        samples = np.column_stack((samples, samples))
    peak = np.max(np.abs(samples))
    if peak > .9:
        samples *= .9 / peak
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / (name + ".wav")), "wb") as f:
        f.setnchannels(2)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes((samples * 32767).astype("<i2").tobytes())


def cue(name, frequencies, duration=.18, noise=.04, body=.45):
    t = np.arange(round(duration * RATE)) / RATE
    positions = np.linspace(0, duration, len(frequencies))
    freq = np.interp(t, positions, frequencies)
    phase = np.cumsum(freq) * (2 * np.pi / RATE)
    env = (1 - np.exp(-t * 1400)) * np.exp(-t * 6 / duration)
    tone = np.sin(phase) + .22 * np.sin(phase * 2.01)
    click = rng.uniform(-1, 1, len(t)) * np.exp(-t * 330)
    result = (tone * body * env + click * noise)
    result[-100:] *= np.linspace(1, 0, 100)
    write(name, result)


for name, freq, duration in [
    ("ui_hover", [950, 850], .045), ("ui_confirm", [450, 680], .10),
    ("ui_open", [360, 540, 720], .22), ("ui_close", [700, 500, 300], .16),
    ("equip_scan", [540, 810, 1080], .25), ("equip_collect", [180, 270, 405], .27),
    ("equip_warm", [110, 165, 220], .30), ("equip_seed", [720, 960, 1200], .23),
    ("target_lock", [880, 880, 1320], .20), ("navigation", [300, 450], .15),
    ("cancel", [550, 330], .13), ("scan_complete", [540, 675, 810, 1080], .65),
    ("cargo", [180, 180, 360], .40), ("departure", [65, 120, 440], 1.6),
    ("entry", [440, 180, 65], 1.5), ("saved", [480, 720], .28),
    ("achievement", [360, 450, 540, 720, 900], 1.4),
]:
    cue(name, freq, duration)

# Continuous cockpit thrust: low fundamental, restrained mechanical harmonics,
# periodic amplitude modulation. Exact integer cycles avoid a loop boundary click.
t = np.arange(2 * RATE) / RATE
engine = (.20*np.sin(2*np.pi*55*t) + .07*np.sin(2*np.pi*110*t)
          + .025*np.sin(2*np.pi*330*t)) * (.82 + .18*np.sin(2*np.pi*3*t))
write("engine", engine)

# Planetary air: low-passed noise with an equal-power seam crossfade.
t = np.arange(8 * RATE) / RATE
noise = rng.normal(0, 1, len(t))
spectrum = np.fft.rfft(noise)
freq = np.fft.rfftfreq(len(noise), 1/RATE)
spectrum *= 1 / (1 + (freq / 420)**4)
air = np.fft.irfft(spectrum, len(t))
air *= .14 / max(.01, np.max(np.abs(air)))
air *= .8 + .2*np.sin(2*np.pi*t/8)
write("surface_air", air)

# Four harmonic regions with spacious glass tones. This is a candidate composition,
# not a substitute for the requested professional music/art direction review.
length = 48
music = np.zeros((length * RATE, 2))
chords = [[50,57,60,64,69], [46,53,57,60,65], [53,60,64,67,72], [48,55,58,62,67]]


def note(midi, start, duration, gain, pan, glass=False):
    n = int(duration * RATE)
    time = np.arange(n) / RATE
    frequency = 440 * 2 ** ((midi - 69) / 12)
    if glass:
        env = (1-np.exp(-time*80))*np.exp(-time*1.8)
        sound = np.sin(2*np.pi*frequency*time) + .3*np.sin(2*np.pi*frequency*2.004*time)*np.exp(-time*3)
    else:
        env = np.minimum(time/1.2, 1)*np.minimum((duration-time)/2, 1)
        sound = (np.sin(2*np.pi*frequency*time)*.55
                 + np.sin(2*np.pi*frequency*1.0018*time)*.3
                 + np.sin(2*np.pi*frequency*2*time)*.08)
    sound *= np.maximum(0,env)*gain
    stereo = np.column_stack((sound*np.sqrt((1-pan)/2),sound*np.sqrt((1+pan)/2)))
    # Wrap release tails into the start: the score itself forms a continuous loop.
    idx = (np.arange(n) + int(start*RATE)) % len(music)
    music[idx] += stereo


for region, chord in enumerate(chords):
    for j, midi in enumerate(chord):
        note(midi, region*12, 14, .042, (j-2)*.3)
    note(chord[0]-12, region*12, 13.5, .06, 0)
    for step, degree in enumerate([2,4,3,1,4,2]):
        note(chord[degree]+12, region*12+step*1.5+1.5, 4, .048, (-1)**step*.5, True)
write("morrow_drift", music)
print(f"Authored {len(list(OUT.glob('*.wav')))} original WAV candidates in {OUT}")
