"""Generates the figures, the room inside the house and its music.

    python tools/room_images.py plan       draw the layout plan of the room (free)
    python tools/room_images.py ground     generate the painted room (1 call)
    python tools/room_images.py sprites    generate figures and furniture (1 call per image)
    python tools/room_images.py back       generate the player seen from behind (1 call)
    python tools/room_images.py music      generate the music of the room (1 call)
    python tools/room_images.py grid       lay the grid over the painted room as a check (free)

The model painted the floor about 3 % larger and a little higher than the plan. The placement
in the world file ("ground_image" in house_inside.json) is therefore fitted to the corners of
the painted floor and differs from plan.json. The grid check uses plan.json.

Each file is generated at most once: existing files are never overwritten and failed calls are
not repeated.
"""

import json
import sys
from concurrent.futures import ThreadPoolExecutor

from PIL import Image

import world_plan
from env import PROJECT
from image_gen import openai_image
from music_gen import lyria_track
from style import FIGURE, room_prompt, sprite_prompt

WORLD = PROJECT / "data" / "worlds" / "house_inside.json"
RAW = PROJECT / "styletest" / "room"
STYLE_REFERENCE = PROJECT / "styletest" / "village" / "ground_small.png"
GROUND_SIZE = (1536, 1024)
WALL_HEIGHT = 220

PLAYER = (
    "A young traveller in a rust-red hooded cloak that reaches down to the knees, the hood down, "
    "short dark hair, a small brown satchel on a strap across the body, simple brown boots."
)

SPRITES = {
    "player_front": FIGURE + " " + PLAYER + " The figure faces the lower right, seen from the front.",
    "old_man": (
        FIGURE + " An old man with white hair and a short white beard, in a long grey-blue coat, "
        "leaning slightly on a wooden walking stick. He faces the lower left, seen from the front."
    ),
    "woman": (
        FIGURE + " A middle-aged woman with her brown hair in a bun, in a long moss-green dress "
        "with a cream-coloured shawl around the shoulders, hands folded in front. She faces the "
        "lower left, seen from the front."
    ),
    "table": (
        "A small square wooden table with four legs. On it stand a clay jug and one burning "
        "candle in a holder."
    ),
    "cupboard": (
        "A tall, narrow wooden cupboard with two doors and a square footprint, its front facing "
        "the lower right."
    ),
}

BACK = (
    FIGURE + " " + PLAYER + " The figure faces the upper right, away from the viewer, seen from "
    "behind: the back of the head, the back of the cloak with the hood hanging down, and the "
    "strap of the satchel. The second attached image shows the same person from the front. Keep "
    "the same person, clothes, colours, proportions and size."
)

MUSIC = (
    "Instrumental only, no vocals. Quiet music for the inside of a small cottage in a calm "
    "exploration game, a close relative of a gentle village theme. A slow, simple melody on a "
    "soft felt piano, close and intimate, with a warm cello holding long notes underneath and a "
    "few sparse harp notes. Around 60 bpm, major key with a hint of wistfulness, very sparse, "
    "lots of silence between the phrases, no drums, no percussion. About two minutes long, "
    "ending softly on an unresolved note."
)


def plan():
    ground = world_plan.read_ground(WORLD)
    scale, origin = world_plan.placement(ground, GROUND_SIZE, margin_top=0.45, margin_bottom=0.17)
    RAW.mkdir(parents=True, exist_ok=True)
    world_plan.draw(ground, GROUND_SIZE, scale, origin, walls=WALL_HEIGHT).convert("RGB").save(RAW / "plan.png")
    (RAW / "plan.json").write_text(json.dumps({"scale": scale, "origin": origin}), encoding="utf-8")
    print("Plan:", RAW / "plan.png", "scale", scale, "origin", origin)


def ground():
    target = RAW / "ground.png"
    if target.exists():
        print("Room already exists, no call.")
        return
    usage = openai_image(
        room_prompt(), target, size="%dx%d" % GROUND_SIZE, transparent=True, references=[RAW / "plan.png"]
    )
    print("Room:", target, json.dumps(usage))


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
    def generate(name):
        return _sprite(name, sprite_prompt(SPRITES[name], with_reference=True), [STYLE_REFERENCE])

    with ThreadPoolExecutor(max_workers=len(SPRITES)) as pool:
        for line in pool.map(generate, SPRITES):
            print(line, flush=True)


def back():
    front = RAW / "player_front.png"
    if not front.exists():
        print("The front view has to exist first.")
        return
    print(_sprite("player_back", sprite_prompt(BACK, with_reference=True), [STYLE_REFERENCE, front]))


def music():
    if list(RAW.glob("room_theme.*")):
        print("Music already exists, no call.")
        return
    target, text = lyria_track(MUSIC, RAW / "room_theme")
    print("Music:", target)
    print(text)


def grid():
    placement = json.loads((RAW / "plan.json").read_text(encoding="utf-8"))
    backdrop = Image.new("RGBA", GROUND_SIZE, "#c8d8e4")
    backdrop.alpha_composite(Image.open(RAW / "ground.png").convert("RGBA"))
    image = world_plan.draw(
        world_plan.read_ground(WORLD), GROUND_SIZE, placement["scale"], placement["origin"], backdrop=backdrop
    )
    image.convert("RGB").save(RAW / "ground_with_grid.jpg", quality=88)
    print("Check:", RAW / "ground_with_grid.jpg")


if __name__ == "__main__":
    {"plan": plan, "ground": ground, "sprites": sprites, "back": back, "music": music, "grid": grid}[sys.argv[1]]()