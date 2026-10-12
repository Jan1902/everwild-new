"""Generates the objects, figures and music the valley chapter adds: pond, watch and what is new
in the village, the house and on the mill hill.

    python tools/valley_images.py sprites    generate the objects and figures (11 calls)
    python tools/valley_images.py variants   generate second states from the first ones (3 calls)
    python tools/valley_images.py music      generate the two music tracks (2 calls)

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

RAW = PROJECT / "styletest" / "valley"
REFERENCE = PROJECT / "styletest" / "village" / "ground_small.png"

SPRITES = {
    "child": (
        FIGURE + " A small child of about seven, clearly shorter and rounder than an adult, with "
        "short tousled brown hair, a plain ochre tunic over dark trousers and bare feet, hands "
        "clasped behind the back, head tilted slightly upwards. The child faces the lower left, "
        "seen from the front."
    ),
    "fisher": (
        FIGURE + " A fisherwoman in her fifties with grey hair under a dark teal headscarf, a long "
        "weathered teal coat, tall brown boots and a coiled rope over one shoulder. She faces the "
        "lower left, seen from the front."
    ),
    "vane": (
        "The post of a weather vane: a tall slender wooden pole, about twice as tall as a person, "
        "standing on a small round base of grey stones, with a short iron spindle and a small "
        "iron ball at the very top. Nothing is mounted on the spindle: no arrow, no rooster, no "
        "letters. They are added separately."
    ),
    "music_box": (
        "A small music box standing on a low three-legged wooden stool: a little dark wooden box "
        "with brass corners, its lid closed, with a small brass crank handle sticking out of its "
        "right side."
    ),
    "field": (
        "A small square wheat field: a square plot of tilled earth, lying flat on the ground so "
        "that it appears as a diamond twice as wide as it is tall, densely planted with ripe "
        "golden wheat about knee-high in neat rows. A narrow rim of brown earth around the wheat."
    ),
    "steps": (
        "A short flight of five rough grey stone steps leading downwards towards the lower left, "
        "as if descending over the bank of a brook, flanked by two low rough stone edges with a "
        "little moss."
    ),
    "boat": (
        "A small empty wooden rowing boat with a rounded hull, seen from the side and slightly "
        "from above, its bow pointing to the lower right, with one plank seat and two oars laid "
        "inside. Warm brown wood with a dark red stripe along the rim."
    ),
    "stepping_stones": (
        "A row of five flat round grey stepping stones lying on the ground in a straight line "
        "that runs from the upper left to the lower right along the isometric axis. The stones "
        "differ a little in size, their flat tops are dry and lighter than their sides. Only the "
        "stones: no water around them."
    ),
    "big_light": (
        "A great fire beacon for a hilltop: a wide shallow bowl of dark iron resting on a stout "
        "round pillar of rough grey stone blocks, the whole about one and a half times as tall as "
        "a person. The bowl is empty and cold: no fire, no embers, no smoke."
    ),
    "beacon": (
        "A small way marker: a knee-high rough grey stone with a little iron-framed glass lantern "
        "set on top of it. The glass of the lantern is a warm pale yellow."
    ),
}

# The arrow is painted flat from above. The game lays it into the ground plane and turns it.
VANE_ARROW = (
    "The arrow of a weather vane as a game sprite, seen exactly from above, flat like a paper "
    "cut-out, not in perspective. A long thin dark iron rod lies exactly horizontal, with a broad "
    "red arrowhead at its right end and a small red tail fin at its left end, so it points exactly "
    "to the right. A small round iron hub sits in the exact centre of the image, on the rod. The "
    "arrow is centred and spans most of the width of the square image. Nothing else: no pole."
)

# Second states, each painted from the first one so that nothing but the state differs.
VARIANTS = {
    "music_box_playing": (
        "music_box",
        SPRITES["music_box"].replace(
            "its lid closed", "its lid standing open, showing a shiny brass cylinder inside"
        )
        + " The second attached image shows the same music box closed. Keep exactly the same box, "
        "stool, crank, colours, size, position and viewing angle; only the lid has opened.",
    ),
    "field_withered": (
        "field",
        SPRITES["field"].replace(
            "densely planted with ripe golden wheat about knee-high in neat rows",
            "where the wheat has withered: only sparse dry grey-brown stubble stands in the rows "
            "on bare cracked earth",
        )
        + " The second attached image shows the same field with ripe wheat. Keep exactly the same "
        "plot, outline, size, position and viewing angle; only the wheat has withered.",
    ),
    "big_light_lit": (
        "big_light",
        SPRITES["big_light"].replace(
            "The bowl is empty and cold: no fire, no embers, no smoke.",
            "A strong warm orange fire burns in the bowl, its flames about as tall as the bowl is wide.",
        )
        + " The second attached image shows the same beacon unlit. Keep exactly the same pillar, "
        "bowl, colours, size, position and viewing angle; only the fire has been added.",
    ),
}

MUSIC = {
    "pond_theme": (
        "Instrumental only, no vocals. A hushed theme for a misty pond at dusk in a calm "
        "exploration game, a quieter, lower relative of a clear spring theme. Slow harp arpeggios "
        "and a few soft notes on a bowed vibraphone over a very quiet low string pad, with a "
        "low clarinet that plays a short, simple melody now and then. Around 54 bpm, major key "
        "with a wistful turn, lots of space and silence, no drums, no percussion. About two "
        "minutes long, ending softly on an unresolved note."
    ),
    "watch_theme": (
        "Instrumental only, no vocals. A wide, solemn theme for a lonely lookout high above a "
        "valley in a calm exploration game. A single french horn plays a slow, simple, hopeful "
        "melody over long sustained strings, answered by a wooden flute, with a softly plucked "
        "acoustic guitar entering late. Around 62 bpm, major key, open and airy, a little lonely, "
        "no drums, no percussion. About two minutes long, ending softly on an unresolved note."
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
    jobs["vane_arrow"] = "\n\n".join([VANE_ARROW, SPRITE_RULES, PAINTED_STYLE, STYLE_REFERENCE])
    with ThreadPoolExecutor(max_workers=6) as pool:
        for line in pool.map(lambda name: _sprite(name, jobs[name], [REFERENCE]), jobs):
            print(line, flush=True)


def variants():
    def one(name):
        first, subject = VARIANTS[name]
        if not (RAW / f"{first}.png").exists():
            return f"{name}: '{first}' has to exist first."
        return _sprite(name, sprite_prompt(subject, with_reference=True), [REFERENCE, RAW / f"{first}.png"])

    with ThreadPoolExecutor(max_workers=len(VARIANTS)) as pool:
        for line in pool.map(one, VARIANTS):
            print(line, flush=True)


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
    {"sprites": sprites, "variants": variants, "music": music}[sys.argv[1]]()
