"""First generation test: exactly one sprite and exactly one music track. No retries."""

import json
import sys

from env import PROJECT
from image_gen import openai_image
from music_gen import lyria_track
from style import sprite_prompt

TARGET = PROJECT / "styletest" / "first_test"

SPRITE = sprite_prompt(
    "An old village street lantern: a wooden post with a small dark metal lantern hanging from a "
    "curved arm, a warm yellow light inside the lantern."
)

MUSIC = (
    "Instrumental only, no vocals. A calm, warm theme for a small peaceful village in a quiet "
    "exploration game. A simple, memorable eight-note melody on a soft felt piano, repeated and "
    "gently varied, joined by a mellow clarinet, light plucked harp and a quiet string pad. "
    "Slow tempo around 70 bpm, major key with a hint of wistfulness, lots of space and air, "
    "no drums, no percussion. About two minutes long, ending softly on an unresolved note."
)


def main():
    what = sys.argv[1]
    if what == "sprite":
        target = TARGET / "lantern.png"
        usage = openai_image(SPRITE, target, size="1024x1024", transparent=True)
        print("Sprite:", target, json.dumps(usage))
    elif what == "music":
        target, text = lyria_track(MUSIC, TARGET / "village_theme")
        print("Music:", target)
        print(text)


if __name__ == "__main__":
    main()
