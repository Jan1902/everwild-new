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


# The generated bridge is six planks long, which is more than the one cell the brook is wide.
# Its first and last plank are cut off along the gaps between the planks. Given in pixels of the
# cropped image at half resolution: centre of the deck, half the deck along its length, and the
# direction of the gaps. KEEP is the stretch that stays, in half lengths from the centre: from
# the first gap to the last one, which leaves the four planks in the middle.
BRIDGE_CENTRE = (254, 145)
BRIDGE_ALONG = (165, 100)
BRIDGE_GAP = (86, -56)
BRIDGE_KEEP = (-0.845, 0.775)


def shorten_bridge(image):
    (cx, cy), (ux, uy), (gx, gy) = BRIDGE_CENTRE, BRIDGE_ALONG, BRIDGE_GAP
    det = ux * gy - uy * gx
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            # Position along the deck, measured parallel to the gaps.
            along = ((x - cx) * gy - (y - cy) * gx) / det
            if not BRIDGE_KEEP[0] <= along <= BRIDGE_KEEP[1]:
                pixels[x, y] = (0, 0, 0, 0)
    box = image.getchannel("A").getbbox()
    middle = sum(BRIDGE_KEEP) / 2
    print("bridge: deck centre in the cut image", cx + middle * ux - box[0], cy + middle * uy - box[1])
    return image.crop(box)


def crop(name):
    image = Image.open(SOURCES[name] / f"{name}.png").convert("RGBA")
    alpha = image.getchannel("A")
    # The model does not deliver full opacity even inside the object. Stretch to the full range.
    peak = alpha.getextrema()[1]
    alpha = alpha.point(lambda a: 0 if a < THRESHOLD else min(255, round(a * 255 / peak)))
    image.putalpha(alpha)
    image = image.crop(alpha.getbbox())
    # In the game objects are at most about 300 world pixels wide. Half the resolution is enough
    # for that and avoids shimmering when scaling down a lot.
    image = image.resize((image.width // 2, image.height // 2), Image.LANCZOS)
    if name == "bridge":
        image = shorten_bridge(image)
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
