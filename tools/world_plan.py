"""Draws a flat layout plan of the ground from a world file, as a template for the image model.

The plan uses the same projection as the game (src/logic/iso.gd). It also yields the placement
of the image in the world, so the painted ground image later lies exactly under the grid.
"""

import json
from pathlib import Path

from PIL import Image, ImageDraw

CELL = (128, 64)
EDGE = 90
LAND = ".=~#"
COLORS = {".": "#7fae6b", "=": "#d8c394", "~": "#74b6cc", "#": "#74b6cc"}
EARTH_LIGHT, EARTH_DARK = "#8a6a4f", "#6e533f"


def to_point(x, y):
    return ((x - y) * CELL[0] / 2, (x + y) * CELL[1] / 2)


def corners(x, y):
    cx, cy = to_point(x, y)
    hx, hy = CELL[0] / 2, CELL[1] / 2
    return [(cx, cy - hy), (cx + hx, cy), (cx, cy + hy), (cx - hx, cy)]


def read_ground(world_file):
    return json.loads(Path(world_file).read_text(encoding="utf-8"))["ground"]


def placement(ground, image_size, margin_top=0.05, margin_bottom=0.2):
    """Scale (image pixels per world pixel) and world point of the image's top left corner."""
    points = [p for y, row in enumerate(ground) for x, s in enumerate(row) if s in LAND for p in corners(x, y)]
    left, right = min(p[0] for p in points), max(p[0] for p in points)
    top, bottom = min(p[1] for p in points), max(p[1] for p in points)
    width, height = image_size
    scale = height * (1 - margin_top - margin_bottom) / (bottom - top)
    scale = min(scale, width * 0.9 / (right - left))
    scale = round(scale, 3)
    origin = (
        round((left + right) / 2 - width / 2 / scale, 2),
        round(top - height * margin_top / scale, 2),
    )
    return scale, origin


def draw(ground, image_size, scale, origin, grid=False, backdrop=None):
    """Layout plan on white. With backdrop, only the grid is laid over an existing image instead."""
    image = backdrop.convert("RGBA") if backdrop else Image.new("RGBA", image_size, "white")
    pen = ImageDraw.Draw(image)

    def to_image(points, shift=0):
        return [((px - origin[0]) * scale, (py + shift - origin[1]) * scale) for px, py in points]

    def symbol(x, y):
        return ground[y][x] if 0 <= y < len(ground) and 0 <= x < len(ground[y]) else " "

    cells = [(x, y) for y, row in enumerate(ground) for x, s in enumerate(row) if s in LAND]
    if not backdrop:
        for x, y in cells:
            c = corners(x, y)
            if symbol(x + 1, y) == " ":
                pen.polygon(to_image([c[1], c[2]]) + to_image([c[2], c[1]], EDGE), fill=EARTH_LIGHT)
            if symbol(x, y + 1) == " ":
                pen.polygon(to_image([c[2], c[3]]) + to_image([c[3], c[2]], EDGE), fill=EARTH_DARK)
        for x, y in cells:
            pen.polygon(to_image(corners(x, y)), fill=COLORS[symbol(x, y)])
    if grid or backdrop:
        for x, y in cells:
            c = to_image(corners(x, y))
            color = {"~": "#0040ff", "#": "#ff00ff", "=": "#ff8000"}.get(symbol(x, y), "#ffffff")
            pen.line(c + [c[0]], fill=color, width=2)
    return image
