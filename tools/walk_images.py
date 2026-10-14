"""Walk animations for figures: one sprite sheet per view, cut into frames.

    python tools/walk_images.py generate <sheet> [<sheet> ...]
                                           generate the sprite sheets (one call each)
    python tools/walk_images.py cut <sheet> [<sheet> ...] [--overview overview.jpg]
                                           cut the sheets into aligned frames for the game (free)

The sheets are the keys of SHEETS, for example player_front or old_man_back. The frames are
written as assets/objects/<sheet>_walk_<n>.png.

Each sheet is generated at most once: existing files are never overwritten and failed calls are
not repeated.
"""

import json
import sys
from concurrent.futures import ThreadPoolExecutor

from PIL import Image

from env import PROJECT, SPRITES
from image_gen import openai_image
from style import PAINTED_STYLE, VIEW

RAW = PROJECT / "styletest" / "walk"
STYLETEST = PROJECT / "styletest"
OBJECTS = PROJECT / "assets" / "objects"
FRAMES = SPRITES["walk_frames"]
THRESHOLD = 24
MARGIN = SPRITES["margin"]
# Width of a frame as a multiple of the standing figure, to leave room for the stride.
WIDTH_FACTOR = SPRITES["walk_width"]

SHEET = (
    "A sprite sheet for a game: exactly four frames side by side in one row, evenly spaced, with "
    "a clear empty gap between them. The four frames show the walk cycle of the person in the "
    "second attached image, walking on the spot towards the {direction}, {seen}. "
    "Frame 1: the left leg steps forward, the right arm swings forward. "
    "Frame 2: both legs under the body, passing each other, the body slightly higher. "
    "Frame 3: the right leg steps forward, the left arm swings forward. "
    "Frame 4: both legs under the body again, passing each other. "
    "In every frame it is the same person with the same clothes, colours, proportions, size and "
    "viewing angle as in the second attached image; only legs and arms move.{extra} All four "
    "figures stand on the same baseline. "
    "Fully transparent background. No ground, no cast shadow, no frame borders, no numbers, no "
    "text."
)
STYLE_NOTE = (
    "The first attached image is the painted ground of the game world. Use it only as a reference "
    "for painting style, brushwork and colour palette."
)
BEHIND = (
    " The second attached image shows the person from the front; here they are turned around, so "
    "we see their back, the back of the head and no face."
)
OLD = " The person is old and walks slowly, slightly bent, with small steps."
CHILD = " The person is a small child and walks with light, quick little steps."
# reference: the standing figure the sheet is drawn after (in styletest/, with its folder).
# standing: the standing image in assets/objects whose height the frames get.
SHEETS = {
    "player_front": {"direction": "lower right", "seen": "seen from the front", "extra": "",
                     "reference": "room/player_front", "standing": "player_front"},
    "player_back": {"direction": "upper right", "seen": "seen from behind", "extra": "",
                    "reference": "room/player_back", "standing": "player_back"},
    "old_man_front": {"direction": "lower right", "seen": "seen from the front", "extra": OLD,
                      "reference": "room/old_man", "standing": "old_man"},
    "old_man_back": {"direction": "upper right", "seen": "seen from behind", "extra": BEHIND + OLD,
                     "reference": "room/old_man", "standing": "old_man"},
    "woman_front": {"direction": "lower right", "seen": "seen from the front", "extra": "",
                    "reference": "room/woman", "standing": "woman"},
    "woman_back": {"direction": "upper right", "seen": "seen from behind", "extra": BEHIND,
                   "reference": "room/woman", "standing": "woman"},
    "child_front": {"direction": "lower right", "seen": "seen from the front", "extra": CHILD,
                    "reference": "valley/child", "standing": "child"},
    "child_back": {"direction": "upper right", "seen": "seen from behind", "extra": BEHIND + CHILD,
                   "reference": "valley/child", "standing": "child"},
}


def generate(names):
    reference = PROJECT / "styletest" / "village" / "ground_small.png"

    def one(name):
        target = RAW / f"{name}_walk.png"
        if target.exists():
            return f"{name}: already exists, no call."
        sheet = SHEETS[name]
        prompt = "\n\n".join([SHEET.format(**sheet), VIEW, PAINTED_STYLE, STYLE_NOTE])
        try:
            usage = openai_image(
                prompt, target, size="1536x1024", transparent=True,
                references=[reference, STYLETEST / f"{sheet['reference']}.png"],
            )
            return f"{name}: OK {json.dumps(usage)}"
        except Exception as error:
            return f"{name}: ERROR {error}"

    with ThreadPoolExecutor(max_workers=len(names)) as pool:
        for line in pool.map(one, names):
            print(line, flush=True)


def _figures(sheet):
    """Cuts the sheet at its empty columns. Returns the figures from left to right."""
    alpha = sheet.getchannel("A").point(lambda a: 255 if a >= THRESHOLD else 0)
    filled = [alpha.crop((x, 0, x + 1, sheet.height)).getbbox() is not None for x in range(sheet.width)]
    runs, start = [], None
    for x, on in enumerate(filled + [False]):
        if on and start is None:
            start = x
        elif not on and start is not None:
            runs.append((start, x))
            start = None
    # Specks are not figures.
    runs = [run for run in runs if run[1] - run[0] > 40]
    figures = []
    for left, right in runs:
        part = sheet.crop((left, 0, right, sheet.height))
        figures.append(part.crop(part.getchannel("A").point(lambda a: 255 if a >= THRESHOLD else 0).getbbox()))
    return figures


def _head_centre(figure):
    """Horizontal centre of the top third, which is the head: it barely moves while walking."""
    alpha = figure.crop((0, 0, figure.width, figure.height // 3)).getchannel("A")
    box = alpha.point(lambda a: 255 if a >= THRESHOLD else 0).getbbox()
    return (box[0] + box[2]) / 2


def cut(names, overview_path=None):
    sheets = []
    for name in names:
        standing = Image.open(OBJECTS / f"{SHEETS[name]['standing']}.png")
        content_width = round(standing.width / (1 + 2 * MARGIN))
        figures = _figures(Image.open(RAW / f"{name}_walk.png").convert("RGBA"))
        print(name, "figures found:", len(figures), [f.size for f in figures])
        if len(figures) != FRAMES:
            print("  not usable: expected", FRAMES)
            continue
        # All frames get the scale that brings the tallest one to the height of the standing figure.
        scale = standing.height / max(f.height for f in figures)
        width = round(content_width * WIDTH_FACTOR)
        margin = round(width * MARGIN)
        row = []
        for number, figure in enumerate(figures, 1):
            alpha = figure.getchannel("A")
            peak = alpha.getextrema()[1]
            figure.putalpha(alpha.point(lambda a: 0 if a < THRESHOLD else min(255, round(a * 255 / peak))))
            head = _head_centre(figure) * scale
            figure = figure.resize((round(figure.width * scale), round(figure.height * scale)), Image.LANCZOS)
            frame = Image.new("RGBA", (width + 2 * margin, standing.height), (0, 0, 0, 0))
            frame.alpha_composite(figure, (max(0, round(margin + width / 2 - head)), standing.height - figure.height))
            frame.save(OBJECTS / f"{name}_walk_{number}.png")
            row.append(frame)
        sheets.append([standing] + row)

    if overview_path and sheets:
        cell = (max(i.width for s in sheets for i in s), max(i.height for s in sheets for i in s))
        overview = Image.new("RGBA", (cell[0] * (FRAMES + 1), cell[1] * len(sheets)), "#7fae6b")
        for y, images in enumerate(sheets):
            for x, image in enumerate(images):
                overview.alpha_composite(image, (x * cell[0], y * cell[1] + cell[1] - image.height))
        overview.convert("RGB").save(overview_path, quality=90)


if __name__ == "__main__":
    arguments = sys.argv[2:]
    overview = None
    if "--overview" in arguments:
        overview = arguments[arguments.index("--overview") + 1]
        arguments = arguments[: arguments.index("--overview")]
    if sys.argv[1] == "generate":
        generate(arguments)
    else:
        cut(arguments, overview)
