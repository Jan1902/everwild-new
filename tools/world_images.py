"""Generates the painted ground of an outdoor world from its world file.

    python tools/world_images.py <world> plan     draw the layout plan (free)
    python tools/world_images.py <world> ground   generate the ground image (1 call)
    python tools/world_images.py <world> grid     lay the grid over the ground image as a check (free)

Raw images go to styletest/<world>/. The ground image is generated at most once: an existing
file is never overwritten and a failed call is not repeated.
"""

import json
import sys

from PIL import Image

import world_plan
from env import PROJECT
from image_gen import openai_image
from style import ground_prompt

GROUND_SIZE = (2560, 1440)
# What is special about the ground of a world, added to the prompt.
PLACES = {
    "pond": (
        "About this place: the large blue area in the middle is a still, shallow pond with soft "
        "reedy banks, fed by a narrow brook that enters at the upper right edge and leaves at the lower left edge. The "
        "small green patch inside the blue area is a tiny grassy island. Keep the water one calm "
        "flat surface; do not paint stones, planks or a bridge in it."
    ),
    "watch": (
        "About this place: this small island is the highest point of a valley, a bare windswept "
        "hilltop. Paint the green area as short, pale mountain grass with a few flat patches of "
        "grey rock showing through and a faint ring of worn flagstones in the middle."
    ),
}


def main(world, command):
    world_file = PROJECT / "data" / "worlds" / f"{world}.json"
    raw = PROJECT / "styletest" / world
    ground = world_plan.read_ground(world_file)
    if command == "plan":
        scale, origin = world_plan.placement(ground, GROUND_SIZE)
        raw.mkdir(parents=True, exist_ok=True)
        world_plan.draw(ground, GROUND_SIZE, scale, origin).convert("RGB").save(raw / "plan.png")
        (raw / "plan.json").write_text(json.dumps({"scale": scale, "origin": origin}), encoding="utf-8")
        print("Plan:", raw / "plan.png", "scale", scale, "origin", origin)
    elif command == "ground":
        target = raw / "ground.png"
        if target.exists():
            print("Ground image already exists, no call.")
            return
        usage = openai_image(
            ground_prompt(PLACES.get(world, "")), target, size="%dx%d" % GROUND_SIZE, transparent=True, references=[raw / "plan.png"]
        )
        print("Ground:", target, json.dumps(usage))
    elif command == "grid":
        placement = json.loads((raw / "plan.json").read_text(encoding="utf-8"))
        backdrop = Image.new("RGBA", GROUND_SIZE, "#c8d8e4")
        backdrop.alpha_composite(Image.open(raw / "ground.png").convert("RGBA"))
        image = world_plan.draw(ground, GROUND_SIZE, placement["scale"], placement["origin"], backdrop=backdrop)
        image.convert("RGB").save(raw / "ground_with_grid.jpg", quality=88)
        print("Check:", raw / "ground_with_grid.jpg")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])