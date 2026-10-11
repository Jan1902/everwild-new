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
            ground_prompt(), target, size="%dx%d" % GROUND_SIZE, transparent=True, references=[raw / "plan.png"]
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