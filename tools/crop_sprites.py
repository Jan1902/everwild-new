"""Prepares generated images for the game.

    python tools/crop_sprites.py [overview.jpg]

Objects are cropped to their visible content so the game can align them by the image border
(foot point as a fraction of the content). The ground image is taken over unchanged.
Optionally an overview of all objects on grass colour is written for a visual check.
"""

import shutil
import sys

from PIL import Image

from env import PROJECT, SPRITES

VILLAGE = PROJECT / "styletest" / "village"
ROOM = PROJECT / "styletest" / "room"
FRAGMENTS = PROJECT / "styletest" / "fragments"
VALLEY = PROJECT / "styletest" / "valley"
OBJECTS = PROJECT / "assets" / "objects"
WORLDS = PROJECT / "assets" / "worlds"
MUSIC = PROJECT / "assets" / "music"
# Name of each sprite and the folder its raw image lies in.
SOURCES = {
    "house": VILLAGE, "tree": VILLAGE, "rock": VILLAGE, "lantern": VILLAGE, "bridge": VILLAGE,
    "player_front": ROOM, "player_back": ROOM, "old_man": ROOM, "woman": ROOM,
    "table": ROOM, "cupboard": ROOM,
    "mill": FRAGMENTS, "sails": FRAGMENTS, "arch": FRAGMENTS, "miller": FRAGMENTS,
    "sluice": FRAGMENTS, "sluice_open": FRAGMENTS,
    "child": VALLEY, "fisher": VALLEY, "vane": VALLEY, "vane_arrow": VALLEY,
    "music_box": VALLEY, "music_box_playing": VALLEY, "field": VALLEY, "field_withered": VALLEY,
    "steps": VALLEY, "boat": VALLEY, "stepping_stones": VALLEY,
    "big_light": VALLEY, "big_light_lit": VALLEY, "beacon": VALLEY, "cart": VALLEY,
}
# Images that turn around their centre in the game. They keep their frame, so the centre stays
# the centre.
UNCROPPED = ["vane_arrow"]
# Images of the same object in different states are cut to the same frame, so the object does
# not jump when its state changes.
SAME_FRAME = [
    ("sluice", "sluice_open"), ("music_box", "music_box_playing"), ("field", "field_withered"),
    ("big_light", "big_light_lit"),
]
# Worlds whose ground image and music are taken over as they are.
GROUNDS = {
    "village": VILLAGE, "house_inside": ROOM, "mill_hill": PROJECT / "styletest" / "mill_hill",
    "spring": PROJECT / "styletest" / "spring", "pond": PROJECT / "styletest" / "pond",
    "watch": PROJECT / "styletest" / "watch",
}
TRACKS = {
    "room_theme": ROOM, "mill_theme": FRAGMENTS, "spring_theme": FRAGMENTS, "pond_theme": VALLEY,
    "watch_theme": VALLEY,
}
# Below this opacity a pixel counts as empty. Hides faint haze around the object.
THRESHOLD = 24
# Margin per side as a fraction of the content width.
MARGIN = SPRITES["margin"]


# The bridge comes from a shape template (bridge_image.py), but the model painted it larger than
# the template. Measured in the raw image: the centre of the deck's top face, and how many raw
# pixels one world pixel is, taken from the length of the deck (560 pixels for 1.4 cells).
RAW_NAMES = {"bridge": "bridge_flat"}
BRIDGE_CENTRE = (515, 525)
BRIDGE_SCALE = 6.25

def _shared_box(names):
    boxes = []
    for name in names:
        alpha = Image.open(SOURCES[name] / f"{name}.png").convert("RGBA").getchannel("A")
        boxes.append(alpha.point(lambda a: 255 if a >= THRESHOLD else 0).getbbox())
    return (min(b[0] for b in boxes), min(b[1] for b in boxes), max(b[2] for b in boxes), max(b[3] for b in boxes))


def crop(name):
    image = Image.open(SOURCES[name] / f"{RAW_NAMES.get(name, name)}.png").convert("RGBA")
    alpha = image.getchannel("A")
    # The model does not deliver full opacity even inside the object. Stretch to the full range.
    peak = alpha.getextrema()[1]
    alpha = alpha.point(lambda a: 0 if a < THRESHOLD else min(255, round(a * 255 / peak)))
    image.putalpha(alpha)
    box = alpha.getbbox()
    if name in UNCROPPED:
        box = (0, 0) + image.size
    for group in SAME_FRAME:
        if name in group:
            box = _shared_box(group)
    image = image.crop(box)
    if name == "bridge":
        # Values for data/sprites.json.
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
    for world, folder in GROUNDS.items():
        shutil.copyfile(folder / "ground.png", WORLDS / f"{world}_ground.png")
    for track, folder in TRACKS.items():
        shutil.copyfile(folder / f"{track}.mp3", MUSIC / f"{track}.mp3")

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
