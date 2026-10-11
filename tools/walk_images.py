"""Tries out a walk animation for the player: one sprite sheet per view, cut into frames.

    python tools/walk_images.py generate   generate the two sprite sheets (2 calls)
    python tools/walk_images.py cut [overview.jpg]
                                           cut the sheets into aligned frames for the game (free)

Each sheet is generated at most once: existing files are never overwritten and failed calls are
not repeated.
"""

import json
import sys
from concurrent.futures import ThreadPoolExecutor

from PIL import Image

from env import PROJECT
from image_gen import openai_image
from style import PAINTED_STYLE, VIEW

RAW = PROJECT / "styletest" / "walk"
STANDING = PROJECT / "styletest" / "room"
OBJECTS = PROJECT / "assets" / "objects"
FRAMES = 4
THRESHOLD = 24
# Has to match MARGIN in src/view/object_view.gd.
MARGIN = 0.12
# Width of a frame as a multiple of the standing figure, to leave room for the stride. Has to
# match WALK_WIDTH in src/view/player.gd.
WIDTH_FACTOR = 1.4

SHEET = (
    "A sprite sheet for a game: exactly four frames side by side in one row, evenly spaced, with "
    "a clear empty gap between them. The four frames show the walk cycle of the person in the "
    "second attached image, walking on the spot towards the {direction}, {seen}. "
    "Frame 1: the left leg steps forward, the right arm swings forward. "
    "Frame 2: both legs under the body, passing each other, the body slightly higher. "
    "Frame 3: the right leg steps forward, the left arm swings forward. "
    "Frame 4: both legs under the body again, passing each other. "
    "In every frame it is the same person with the same clothes, colours, proportions, size and "
    "viewing angle as in the second attached image; only legs and arms move. All four figures "
    "stand on the same baseline. "
    "Fully transparent background. No ground, no cast shadow, no frame borders, no numbers, no "
    "text."
)
STYLE_NOTE = (
    "The first attached image is the painted ground of the game world. Use it only as a reference "
    "for painting style, brushwork and colour palette."
)
VIEWS = {
    "player_front": {"direction": "lower right", "seen": "seen from the front"},
    "player_back": {"direction": "upper right", "seen": "seen from behind"},
}


def generate():
    reference = PROJECT / "styletest" / "village" / "ground_small.png"

    def one(name):
        target = RAW / f"{name}_walk.png"
        if target.exists():
            return f"{name}: already exists, no call."
        prompt = "\n\n".join([SHEET.format(**VIEWS[name]), VIEW, PAINTED_STYLE, STYLE_NOTE])
        try:
            usage = openai_image(
                prompt, target, size="1536x1024", transparent=True, references=[reference, STANDING / f"{name}.png"]
            )
            return f"{name}: OK {json.dumps(usage)}"
        except Exception as error:
            return f"{name}: ERROR {error}"

    with ThreadPoolExecutor(max_workers=2) as pool:
        for line in pool.map(one, VIEWS):
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


def cut():
    sheets = []
    for name in VIEWS:
        standing = Image.open(OBJECTS / f"{name}.png")
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

    if len(sys.argv) > 2 and sheets:
        cell = (max(i.width for s in sheets for i in s), max(i.height for s in sheets for i in s))
        overview = Image.new("RGBA", (cell[0] * (FRAMES + 1), cell[1] * len(sheets)), "#7fae6b")
        for y, images in enumerate(sheets):
            for x, image in enumerate(images):
                overview.alpha_composite(image, (x * cell[0], y * cell[1] + cell[1] - image.height))
        overview.convert("RGB").save(sys.argv[2], quality=90)


if __name__ == "__main__":
    {"generate": generate, "cut": cut}[sys.argv[1]]()