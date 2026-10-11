"""Prepares generated images for the game.

    python tools/crop_sprites.py [overview.jpg]

Objects are cropped to their visible content so the game can align them by the image border
(foot point as a fraction of the content). The ground image is taken over unchanged.
Optionally an overview of all objects on grass colour is written for a visual check.
"""

import shutil
import sys

from PIL import Image

from env import PROJECT

VILLAGE = PROJECT / "styletest" / "village"
ROOM = PROJECT / "styletest" / "room"
OBJECTS = PROJECT / "assets" / "objects"
WORLDS = PROJECT / "assets" / "worlds"
MUSIC = PROJECT / "assets" / "music"
# Name of each sprite and the folder its raw image lies in.
SOURCES = {
    "house": VILLAGE, "tree": VILLAGE, "rock": VILLAGE, "lantern": VILLAGE, "bridge": VILLAGE,
    "player_front": ROOM, "player_back": ROOM, "old_man": ROOM, "woman": ROOM,
    "table": ROOM, "cupboard": ROOM,
}
# Below this opacity a pixel counts as empty. Hides faint haze around the object.
THRESHOLD = 24
# Margin per side as a fraction of the content width. Has to match MARGIN in src/view/object_view.gd.
MARGIN = 0.12


# The bridge comes from a shape template (bridge_image.py), but the model painted it larger than
# the template. Measured in the raw image: the centre of the deck's top face, and how many raw
# pixels one world pixel is, taken from the length of the deck (560 pixels for 1.4 cells).
RAW_NAMES = {"bridge": "bridge_flat"}
BRIDGE_CENTRE = (515, 525)
BRIDGE_SCALE = 6.25

def crop(name):
    image = Image.open(SOURCES[name] / f"{RAW_NAMES.get(name, name)}.png").convert("RGBA")
    alpha = image.getchannel("A")
    # The model does not deliver full opacity even inside the object. Stretch to the full range.
    peak = alpha.getextrema()[1]
    alpha = alpha.point(lambda a: 0 if a < THRESHOLD else min(255, round(a * 255 / peak)))
    image.putalpha(alpha)
    box = alpha.getbbox()
    image = image.crop(box)
    if name == "bridge":
        # Values for ObjectView.IMAGES.
        print(
            "bridge: width %.1f, foot (%.3f, %.3f)"
            % (
                (box[2] - box[0]) / BRIDGE_SCALE,
                (BRIDGE_CENTRE[0] - box[0]) / (box[2] - box[0]),
                (BRIDGE_CENTRE[1] - box[1]) / (box[3] - box[1]),
            )
        )
    # In the game objects are at most about 300 world pixels wide. Half the resolution is enough
    # for that and avoids shimmering when scaling down a lot.
    image = image.resize((image.width // 2, image.height // 2), Image.LANCZOS)

    # Transparent margin on the left and right so the object can lean in the wind.
    margin = round(image.width * MARGIN)
    padded = Image.new("RGBA", (image.width + 2 * margin, image.height), (0, 0, 0, 0))
    padded.paste(image, (margin, 0))
    OBJECTS.mkdir(parents=True, exist_ok=True)
    padded.save(OBJECTS / f"{name}.png")
    return padded


def main():
    images = [crop(name) for name in SOURCES]
    for name, image in zip(SOURCES, images):
        print(name, image.size)

    WORLDS.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(VILLAGE / "ground.png", WORLDS / "village_ground.png")
    shutil.copyfile(ROOM / "ground.png", WORLDS / "house_inside_ground.png")
    shutil.copyfile(ROOM / "room_theme.mp3", MUSIC / "room_theme.mp3")

    if len(sys.argv) > 1:
        height = 600
        small = [i.resize((max(1, i.width * height // i.height), height), Image.LANCZOS) for i in images]
        small = [i if i.width <= 900 else i.resize((900, i.height * 900 // i.width), Image.LANCZOS) for i in small]
        sheet = Image.new("RGBA", (sum(i.width for i in small) + 40 * (len(small) + 1), height + 80), "#7fae6b")
        x = 40
        for i in small:
            sheet.alpha_composite(i, (x, 40 + height - i.height))
            x += i.width + 40
        sheet.convert("RGB").save(sys.argv[1], quality=88)


if __name__ == "__main__":
    main()
