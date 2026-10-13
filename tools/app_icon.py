"""Puts the app icon together from images the game already has and writes it to assets/icon/.

    python tools/app_icon.py

Nothing is generated: the icon is the floating piece of the watch with a stone arch on it, its
way open and shining, under an evening sky. Written are
    icon.png                 the whole icon, for the project and for old Android launchers
    adaptive_foreground.png  island and arch alone, inside the safe middle of an adaptive icon
    adaptive_background.png  the sky alone
"""

from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "assets" / "icon"
ISLAND = ROOT / "assets" / "worlds" / "watch_ground.png"
ARCH = ROOT / "assets" / "objects" / "arch.png"

# Everything is drawn at this size and scaled down at the end.
SIZE = 1024
SKY = [(0.0, (30, 38, 74)), (0.55, (96, 104, 148)), (1.0, (243, 190, 140))]
GLOW = (255, 214, 140)
# Spot of the arch image that stands on the ground, as in data/sprites.json.
ARCH_FOOT = (0.516, 0.827)
# Middle of the stone circle in the island image, as a fraction of its painted part.
CIRCLE = (0.49, 0.36)


def sky(size: int) -> Image.Image:
    image = Image.new("RGBA", (size, size))
    draw = ImageDraw.Draw(image)
    for y in range(size):
        at = y / (size - 1)
        for (start, low), (end, high) in zip(SKY, SKY[1:]):
            if start <= at <= end:
                weight = (at - start) / (end - start)
                draw.line([(0, y), (size, y)], fill=tuple(round(a + (b - a) * weight) for a, b in zip(low, high)) + (255,))
    return image


def blob(size: int, radius: float, centre: tuple[float, float], strength: float) -> Image.Image:
    """A soft round light on black, to be added to a picture."""
    mask = Image.new("L", (size, size), 0)
    box = [centre[0] - radius, centre[1] - radius, centre[0] + radius, centre[1] + radius]
    ImageDraw.Draw(mask).ellipse(box, fill=round(255 * strength))
    mask = mask.filter(ImageFilter.GaussianBlur(radius * 0.45))
    light = Image.new("RGB", (size, size), GLOW)
    return Image.composite(light, Image.new("RGB", (size, size), 0), mask)


def scene(size: int, width: float) -> Image.Image:
    """Island and arch on a transparent ground; the island is the given fraction of the size wide."""
    picture = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    island = Image.open(ISLAND).convert("RGBA")
    island = island.crop(island.getchannel("A").point(lambda a: 255 if a > 40 else 0).getbbox())
    scale = size * width / island.width
    island = island.resize((round(island.width * scale), round(island.height * scale)), Image.LANCZOS)
    left = (size - island.width) // 2
    top = round(size * 0.56 - island.height * 0.42)
    picture.alpha_composite(island, (left, top))
    foot = (left + island.width * CIRCLE[0], top + island.height * CIRCLE[1])

    arch = Image.open(ARCH).convert("RGBA")
    arch_scale = island.width * 0.44 / arch.width
    arch = arch.resize((round(arch.width * arch_scale), round(arch.height * arch_scale)), Image.LANCZOS)
    corner = (round(foot[0] - arch.width * ARCH_FOOT[0]), round(foot[1] - arch.height * ARCH_FOOT[1]))

    # A soft shadow at the foot, so the arch stands on the grass.
    shadow = Image.new("L", (size, size), 0)
    ImageDraw.Draw(shadow).ellipse(
        [foot[0] - arch.width * 0.5, foot[1] - arch.width * 0.14, foot[0] + arch.width * 0.5, foot[1] + arch.width * 0.2], fill=110
    )
    shadow = ImageChops.multiply(shadow.filter(ImageFilter.GaussianBlur(size * 0.012)), picture.getchannel("A"))
    picture.alpha_composite(Image.merge("RGBA", [Image.new("L", (size, size), 20)] * 3 + [shadow]))

    # The light in the open way: on the grass behind the arch, then again over the arch itself.
    heart = (foot[0], foot[1] - arch.height * 0.42)
    colours = ImageChops.add(picture.convert("RGB"), blob(size, arch.width * 0.75, heart, 0.75))
    picture = Image.merge("RGBA", (*colours.split(), picture.getchannel("A")))
    picture.alpha_composite(arch, corner)
    halo = blob(size, arch.width * 0.34, heart, 0.6)
    colours = ImageChops.add(picture.convert("RGB"), halo)
    # Where there was nothing, the light itself becomes visible.
    alpha = ImageChops.lighter(picture.getchannel("A"), halo.convert("L").point(lambda v: min(255, v * 2)))
    return Image.merge("RGBA", (*colours.split(), alpha))


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    background = sky(SIZE)

    whole = background.copy()
    # A wide, faint light in the sky behind the island lifts it off the dusk.
    whole = Image.merge("RGBA", (*ImageChops.add(whole.convert("RGB"), blob(SIZE, SIZE * 0.42, (SIZE * 0.5, SIZE * 0.4), 0.22)).split(), whole.getchannel("A")))
    whole.alpha_composite(scene(SIZE, 0.9))
    whole.resize((512, 512), Image.LANCZOS).save(OUTPUT / "icon.png")

    # A launcher shows only the middle two thirds of an adaptive icon for certain.
    scene(SIZE, 0.52).resize((432, 432), Image.LANCZOS).save(OUTPUT / "adaptive_foreground.png")
    background.resize((432, 432), Image.LANCZOS).save(OUTPUT / "adaptive_background.png")
    print("written to", OUTPUT.relative_to(ROOT))


if __name__ == "__main__":
    main()
