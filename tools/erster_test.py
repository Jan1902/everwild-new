"""Erster Generierungstest: genau ein Sprite und genau ein Musikstück. Keine Wiederholungen."""

import json
import sys

from bild import openai_bild
from musik import lyria_stueck
from stil import sprite_prompt
from umgebung import PROJEKT

ZIEL = PROJEKT / "stiltest" / "erster_test"

SPRITE = sprite_prompt(
    "An old village street lantern: a wooden post with a small dark metal lantern hanging from a "
    "curved arm, a warm yellow light inside the lantern."
)

MUSIK = (
    "Instrumental only, no vocals. A calm, warm theme for a small peaceful village in a quiet "
    "exploration game. A simple, memorable eight-note melody on a soft felt piano, repeated and "
    "gently varied, joined by a mellow clarinet, light plucked harp and a quiet string pad. "
    "Slow tempo around 70 bpm, major key with a hint of wistfulness, lots of space and air, "
    "no drums, no percussion. About two minutes long, ending softly on an unresolved note."
)


def main():
    was = sys.argv[1]
    if was == "sprite":
        ziel = ZIEL / "laterne.png"
        verbrauch = openai_bild(SPRITE, ziel, groesse="1024x1024", transparent=True)
        print("Sprite:", ziel, json.dumps(verbrauch))
    elif was == "musik":
        ziel, text = lyria_stueck(MUSIK, ZIEL / "dorf_thema")
        print("Musik:", ziel)
        print(text)


if __name__ == "__main__":
    main()
