"""Generates the first real images for the village: a ground image and five objects.

    python tools/village_images.py plan      draw the layout plan (free)
    python tools/village_images.py ground    generate the ground image (1 call)
    python tools/village_images.py objects   generate the objects (5 calls)
    python tools/village_images.py grid      lay the grid over the ground image as a check (free)

Each image is generated at most once: existing files are never overwritten and failed calls
are not repeated.
"""

import json
import sys
from concurrent.futures import ThreadPoolExecutor

from PIL import Image

import world_plan
from env import PROJECT
from image_gen import openai_image
from style import ground_prompt, sprite_prompt

WORLD = PROJECT / "data" / "worlds" / "village.json"
RAW = PROJECT / "styletest" / "village"
GROUND_SIZE = (2560, 1440)

OBJECTS = {
    "house": (
        "A small village cottage with a square footprint: pale plastered walls, a red tiled "
        "pyramid-shaped roof with a small chimney, a plain wooden door in the wall facing lower "
        "right and one small window in the wall facing lower left."
    ),
    "tree": "A leafy deciduous tree with a short brown trunk and a full, rounded green crown.",
    "rock": "A single grey boulder, about knee-high, with a flat top.",
    "lantern": (
        "An old village street lantern: a wooden post with a small dark metal lantern hanging from "
        "a curved arm, a warm yellow light inside the lantern."
    ),
    "bridge": (
        "A short, flat wooden plank footbridge without railings, just wide enough for one person. "
        "It lies flat on the ground plane and runs diagonally from the upper left to the lower "
        "right, following the isometric ground axis."
    ),
}


def plan():
    ground = world_plan.read_ground(WORLD)
    scale, origin = world_plan.placement(ground, GROUND_SIZE)
    RAW.mkdir(parents=True, exist_ok=True)
    world_plan.draw(ground, GROUND_SIZE, scale, origin).convert("RGB").save(RAW / "plan.png")
    (RAW / "plan.json").write_text(json.dumps({"scale": scale, "origin": origin}), encoding="utf-8")
    print("Plan:", RAW / "plan.png", "scale", scale, "origin", origin)


def ground():
    target = RAW / "ground.png"
    if target.exists():
        print("Ground image already exists, no call.")
        return
    usage = openai_image(
        ground_prompt(),
        target,
        size="%dx%d" % GROUND_SIZE,
        transparent=True,
        references=[RAW / "plan.png"],
    )
    print("Ground:", target, json.dumps(usage))


def objects():
    reference = RAW / "ground_small.png"
    if not reference.exists():
        Image.open(RAW / "ground.png").resize((1280, 720), Image.LANCZOS).save(reference)

    def generate(name):
        target = RAW / f"{name}.png"
        if target.exists():
            return f"{name}: already exists, no call."
        try:
            usage = openai_image(
                sprite_prompt(OBJECTS[name], with_reference=True), target, transparent=True, references=[reference]
            )
            return f"{name}: OK {json.dumps(usage)}"
        except Exception as error:
            return f"{name}: ERROR {error}"

    with ThreadPoolExecutor(max_workers=len(OBJECTS)) as pool:
        for line in pool.map(generate, OBJECTS):
            print(line, flush=True)


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
    {"plan": plan, "ground": ground, "objects": objects, "grid": grid}[sys.argv[1]]()
