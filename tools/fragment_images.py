"""Generates the objects, the figure and the music of the mill hill and the spring.

    python tools/fragment_images.py sprites       generate mill, sails, arch, sluice and miller (5 calls)
    python tools/fragment_images.py sluice_open   generate the open sluice from the closed one (1 call)
    python tools/fragment_images.py music         generate the two music tracks (2 calls)

Each file is generated at most once: existing files are never overwritten and failed calls are
not repeated.
"""

import json
import sys
from concurrent.futures import ThreadPoolExecutor

from env import PROJECT
from image_gen import openai_image
from music_gen import lyria_track
from style import FIGURE, PAINTED_STYLE, SPRITE_RULES, STYLE_REFERENCE, sprite_prompt

RAW = PROJECT / "styletest" / "fragments"
REFERENCE = PROJECT / "styletest" / "village" / "ground_small.png"

SPRITES = {
    "mill": (
        "An old windmill tower with a square footprint: a stout, slightly tapering tower of pale "
        "plastered stone, about twice as tall as wide, with a pointed red tiled cap. A plain "
        "wooden door at the bottom of the wall facing lower right. High up on that same wall a "
        "short round wooden axle stub sticks out, where the sails would be mounted. The windmill "
        "has no sails and no blades at all: they are added separately."
    ),
    "arch": (
        "A free-standing old stone archway: two pillars of rough grey stone blocks joined by a "
        "round arch on top, about twice as tall as a person, a little moss on the stones. The "
        "opening is empty and faces the lower left."
    ),
    "sluice": (
        "A small wooden sluice gate as used on a mill brook: two stout upright wooden posts joined "
        "by a crossbeam on top, with a small iron hand wheel on the crossbeam. Between the posts "
        "hangs a wooden gate board, lowered all the way down to the ground: the sluice is closed. "
        "It stands across the isometric axis running from the upper left to the lower right."
    ),
    "miller": (
        FIGURE + " A stout miller with a round face and a grey moustache, a flat cap, rolled-up "
        "sleeves and a long flour-dusted white apron over brown clothes, hands on his hips. He "
        "faces the lower left, seen from the front."
    ),
}

# The sails are painted flat from the front. The game lays them into the wall plane and turns them.
SAILS = (
    "The four sails of a windmill as a game sprite, seen exactly from the front, flat like a paper "
    "cut-out, not in perspective. Four identical long sails form a symmetrical cross like the "
    "letter X, each one a wooden lattice frame partly covered with pale cream cloth. A small round "
    "wooden hub sits in the exact centre of the image. The cross is centred and fills most of the "
    "square image. Nothing else: no tower, no building."
)

SLUICE_OPEN = (
    SPRITES["sluice"].replace(
        "lowered all the way down to the ground: the sluice is closed",
        "pulled all the way up to the crossbeam, leaving a wide open gap beneath it: the sluice is open",
    )
    + " The second attached image shows the same sluice closed. Keep exactly the same posts, "
    "crossbeam, hand wheel, colours, size, position and viewing angle; only the gate board has moved up."
)

MUSIC = {
    "mill_theme": (
        "Instrumental only, no vocals. A light, airy theme for a windmill on a hill in a calm "
        "exploration game, a close relative of a gentle village theme. A simple lilting melody in "
        "three-four time on a wooden flute, over softly plucked acoustic guitar and a warm "
        "accordion holding long chords. Around 80 bpm, major key, open and breezy, a little "
        "wistful, no drums, no percussion. About two minutes long, ending softly on an unresolved note."
    ),
    "spring_theme": (
        "Instrumental only, no vocals. A still, clear theme for a hidden pond where a brook rises, "
        "in a calm exploration game. Slow rippling harp arpeggios and single notes on a celesta, "
        "like drops on water, over a very quiet string pad, with a soft clarinet that enters late "
        "with a short melody. Around 60 bpm, major key with a hint of wistfulness, lots of space "
        "and silence, no drums, no percussion. About two minutes long, ending softly on an "
        "unresolved note."
    ),
}


def _sprite(name, prompt, references):
    target = RAW / f"{name}.png"
    if target.exists():
        return f"{name}: already exists, no call."
    try:
        usage = openai_image(prompt, target, size="1024x1024", transparent=True, references=references)
        return f"{name}: OK {json.dumps(usage)}"
    except Exception as error:
        return f"{name}: ERROR {error}"


def sprites():
    jobs = {name: sprite_prompt(subject, with_reference=True) for name, subject in SPRITES.items()}
    jobs["sails"] = "\n\n".join([SAILS, SPRITE_RULES, PAINTED_STYLE, STYLE_REFERENCE])
    with ThreadPoolExecutor(max_workers=len(jobs)) as pool:
        for line in pool.map(lambda name: _sprite(name, jobs[name], [REFERENCE]), jobs):
            print(line, flush=True)


def sluice_open():
    closed = RAW / "sluice.png"
    if not closed.exists():
        print("The closed sluice has to exist first.")
        return
    print(_sprite("sluice_open", sprite_prompt(SLUICE_OPEN, with_reference=True), [REFERENCE, closed]))


def music():
    def one(name):
        if list(RAW.glob(f"{name}.*")):
            return f"{name}: already exists, no call."
        try:
            target, _ = lyria_track(MUSIC[name], RAW / name)
            return f"{name}: OK {target}"
        except Exception as error:
            return f"{name}: ERROR {error}"

    with ThreadPoolExecutor(max_workers=2) as pool:
        for line in pool.map(one, MUSIC):
            print(line, flush=True)


if __name__ == "__main__":
    {"sprites": sprites, "sluice_open": sluice_open, "music": music}[sys.argv[1]]()