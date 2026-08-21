#!/usr/bin/env python3
"""Generate GlassWave's notification sound.

Synthesizes a "glass chime" with a watery shimmer, matching the app's
glassmorphism + wave identity:

  * a short, bright strike transient (the "tap" on glass),
  * inharmonic glass-bowl partials (1 : 2.32 : 4.43 : 7.10 ...) that decay
    at different rates, like a struck wine glass,
  * a gentle low-frequency "wave" swell and slightly detuned partial pairs
    (chorus/beating) for a liquid, underwater-glass shimmer.

Only the Python standard library is used (wave + math), so the sound is fully
reproducible without numpy/ffmpeg. Output is a 16-bit stereo WAV.
"""

import math
import struct
import sys
import wave

SAMPLE_RATE = 44100
DURATION = 1.15  # seconds
FUNDAMENTAL = 1567.98  # G6 — bright but not piercing

# (frequency ratio, amplitude, decay time constant s, stereo pan -1..+1)
# Ratios approximate a struck glass bowl's inharmonic overtone series.
PARTIALS = [
    (1.00, 1.00, 0.95, -0.25),
    (2.32, 0.55, 0.45, 0.20),
    (4.43, 0.30, 0.22, -0.15),
    (7.10, 0.16, 0.12, 0.10),
    (10.50, 0.08, 0.07, -0.05),
]

DETUNE = 0.0016  # +/-0.16% detuned pairs -> slow beating "shimmer"
ATTACK = 0.004  # seconds, the striker hitting the glass


def constant_power(pan: float) -> tuple[float, float]:
    """Map pan in [-1, 1] to (left, right) gains with constant power."""
    theta = (pan + 1.0) * math.pi / 4.0
    return math.cos(theta), math.sin(theta)


def synthesize() -> tuple[list[float], list[float]]:
    total = int(SAMPLE_RATE * DURATION)
    left = [0.0] * total
    right = [0.0] * total

    for i in range(total):
        t = i / SAMPLE_RATE
        attack = min(1.0, t / ATTACK)
        # Low, undulating "wave" swells.
        swell = (
            1.0
            + 0.10 * math.sin(2 * math.pi * 4.6 * t)
            + 0.06 * math.sin(2 * math.pi * 2.3 * t + 1.0)
        )

        mono = 0.0
        l_acc = 0.0
        r_acc = 0.0
        for ratio, amp, tau, pan in PARTIALS:
            freq = FUNDAMENTAL * ratio
            env = amp * math.exp(-t / tau) * attack * swell
            # Two detuned copies beat against each other -> liquid shimmer.
            comp = 0.5 * (
                math.sin(2 * math.pi * freq * (1 + DETUNE) * t)
                + math.sin(2 * math.pi * freq * (1 - DETUNE) * t)
            )
            gl, gr = constant_power(pan)
            l_acc += env * comp * gl
            r_acc += env * comp * gr
            mono += env * comp

        # Strike transient — a very short, high-frequency "tap".
        tap = 0.22 * math.sin(2 * math.pi * FUNDAMENTAL * 3.0 * t) * math.exp(-t / 0.006)
        l_acc += tap
        r_acc += tap
        mono += tap

        left[i] = l_acc
        right[i] = r_acc

    # Normalize so the loudest sample sits comfortably below full scale.
    peak = max(max(abs(x) for x in left), max(abs(x) for x in right)) or 1.0
    gain = 0.68 / peak
    left = [x * gain for x in left]
    right = [x * gain for x in right]
    return left, right


def write_wav(path: str, left: list[float], right: list[float]) -> None:
    total = len(left)
    with wave.open(path, "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)  # 16-bit
        wav.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for i in range(total):
            l = max(-1.0, min(1.0, left[i]))
            r = max(-1.0, min(1.0, right[i]))
            frames += struct.pack("<hh", int(l * 32767), int(r * 32767))
        wav.writeframes(bytes(frames))


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <output.wav>", file=sys.stderr)
        return 2
    left, right = synthesize()
    write_wav(sys.argv[1], left, right)
    print(f"wrote {sys.argv[1]} ({len(left)} samples @ {SAMPLE_RATE} Hz, stereo)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
