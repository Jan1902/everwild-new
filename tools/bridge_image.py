"""Generates the bridge from a shape template, so it has exactly the size of its place in the world.

    python tools/bridge_image.py plan       draw the template (free)
    python tools/bridge_image.py generate   generate the bridge (1 call)

The image is generated at most once: an existing file is never overwritten and a failed call
is not repeated.
"""

import json
import sys

from PIL import Image, ImageDraw

from env import PROJECT
from image_gen import openai_image
from style import PAINTED_STYLE, VIEW

RAW = PROJECT / "styletest" / "village"
SIZE = 1024
# Template pixels per world pixel. crop_sprites.py needs it to tell the game how wide the
# bridge is.
SCALE = 5.0
# The deck in cells: a little longer than the one cell the brook is wide, so both ends rest on
# the banks, and narrow enough to leave water visible on both sides.
LENGTH = 1.4
WIDTH = 0.62
ALONG = (64, 32)
ACROSS = (-64, 32)

PROMPT = (
    "Repaint the first attached image, a flat brown shape on white, as a finished game sprite: a "
    "low wooden plank footbridge without railings. "
    "Keep the outline exactly: the bridge has the same position, size and angles as the brown "
    "shape. Do not make it longer, shorter, wider or steeper. "
    "The deck is made of about six wide planks lying side by side, each plank running across the "
    "bridge, parallel to its two short ends. The deck is only as thick as a plank and lies almost "
    "directly on the ground; along the long edge facing the viewer a low supporting beam is "
    "visible beneath the planks. Both short ends finish with a whole plank. No posts, no railings. "
    "Everything white becomes fully transparent background. No ground, no water, no cast shadow, "
    "no other objects, no text. "
    "The second attached image is the painted ground of the game world. Use it only as a "
    "reference for painting style, brushwork and colour palette."
)


def corners():
    half_l, half_w = LENGTH / 2, WIDTH / 2
    points = []
    for l, w in [(-1, -1), (1, -1), (1, 1), (-1, 1)]:
        x = l * half_l * ALONG[0] + w * half_w * ACROSS[0]
        y = l * half_l * ALONG[1] + w * half_w * ACROSS[1]
        points.append((SIZE / 2 + x * SCALE, SIZE / 2 + y * SCALE))
    return points


def plan():
    image = Image.new("RGB", (SIZE, SIZE), "white")
    ImageDraw.Draw(image).polygon(corners(), fill="#a97c52")
    image.save(RAW / "bridge_plan.png")
    print("Plan:", RAW / "bridge_plan.png")


def generate():
    target = RAW / "bridge_flat.png"
    if target.exists():
        print("Bridge already exists, no call.")
        return
    usage = openai_image(
        "\n\n".join([PROMPT, VIEW, PAINTED_STYLE]),
        target,
        size="%dx%d" % (SIZE, SIZE),
        transparent=True,
        references=[RAW / "bridge_plan.png", RAW / "ground_small.png"],
    )
    print("Bridge:", target, json.dumps(usage))


if __name__ == "__main__":
    {"plan": plan, "generate": generate}[sys.argv[1]]()