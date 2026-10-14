"""The voices of the figures: a few short sounds without words, one of which the dialogue plays
when a figure begins a line (src/view/sounds.gd).

    python tools/voice_sounds.py generate <who>   generate the raw sounds (one call each)
    python tools/voice_sounds.py cut <who>        trim and level them for the game (free)

Raw sounds go to styletest/voices/<who>_<n>.wav, the game's to assets/sounds/voices/. Each raw
sound is generated at most once: existing files are never overwritten and failed calls are not
repeated.
"""

import json
import struct
import sys
import wave
from pathlib import Path

import requests

from env import PROJECT, load_env

MODEL = "gpt-4o-mini-tts"
RAW = PROJECT / "styletest" / "voices"
OUTPUT = PROJECT / "assets" / "sounds" / "voices"
# Samples below this share of the loudest one count as silence at the ends.
QUIET = 0.04
LEVEL = 0.6

FIGURES = {
    "old_man": {
        "voice": "onyx",
        "instructions": (
            "You are a very old, gentle man who is tired and a little forgetful. You do not speak "
            "words; you only make a small, quiet sound to yourself, the way old people murmur when "
            "they begin to say something. Soft, warm, slightly breathy and slow, close to the "
            "microphone. No laughter, no drama."
        ),
        "sounds": ["Hm.", "Hmm…", "Ah…", "Mhm.", "Ach…", "Oh."],
    },
}


def generate(who):
    figure = FIGURES[who]
    key = load_env()["OPENAI_API_KEY"]
    for number, sound in enumerate(figure["sounds"], 1):
        target = RAW / f"{who}_{number}.wav"
        if target.exists():
            print(f"{target.name}: already exists, no call.")
            continue
        try:
            response = requests.post(
                "https://api.openai.com/v1/audio/speech",
                headers={"Authorization": f"Bearer {key}"},
                json={
                    "model": MODEL,
                    "voice": figure["voice"],
                    "input": sound,
                    "instructions": figure["instructions"],
                    "response_format": "wav",
                },
                timeout=120,
            )
        except requests.RequestException as error:
            print(f"{target.name}: ERROR {error}")
            continue
        if response.status_code != 200:
            print(f"{target.name}: ERROR {response.status_code} {response.text[:300]}")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(response.content)
        print(f"{target.name}: OK {len(response.content)} bytes")


def _read(path):
    with wave.open(str(path), "rb") as file:
        rate, width, channels = file.getframerate(), file.getsampwidth(), file.getnchannels()
        frames = file.readframes(file.getnframes())
    if width != 2:
        raise ValueError(f"{path.name}: expected 16-bit samples")
    samples = struct.unpack(f"<{len(frames) // 2}h", frames)
    if channels > 1:
        samples = samples[::channels]
    return rate, [sample / 32768 for sample in samples]


def cut(who):
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for raw in sorted(RAW.glob(f"{who}_*.wav")):
        rate, samples = _read(raw)
        peak = max(abs(sample) for sample in samples) or 1.0
        loud = [number for number, sample in enumerate(samples) if abs(sample) > peak * QUIET]
        # A little air before and after, and soft edges so nothing clicks.
        start = max(0, loud[0] - int(0.02 * rate))
        end = min(len(samples), loud[-1] + int(0.08 * rate))
        part = samples[start:end]
        fade = int(0.015 * rate)
        for number in range(min(fade, len(part))):
            part[number] *= number / fade
            part[-1 - number] *= number / fade
        with wave.open(str(OUTPUT / raw.name), "wb") as file:
            file.setnchannels(1)
            file.setsampwidth(2)
            file.setframerate(rate)
            file.writeframes(b"".join(struct.pack("<h", int(sample / peak * LEVEL * 32767)) for sample in part))
        print(json.dumps({"file": raw.name, "seconds": round(len(part) / rate, 2)}))


if __name__ == "__main__":
    {"generate": generate, "cut": cut}[sys.argv[1]](sys.argv[2])
