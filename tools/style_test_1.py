"""Style test stage 1: the tutorial village as one picture in four style directions, once per model.

Only serves to choose a style. The playable layers (ground, objects) are made separately.
"""

import json
from concurrent.futures import ThreadPoolExecutor

from env import PROJECT
from image_gen import google_image, openai_image
from style import PAINTED_STYLE

TARGET = PROJECT / "styletest" / "stage1"

SUBJECT = (
    "A small, peaceful village on a floating island fragment drifting in a soft, empty sky, "
    "seen from a fixed isometric three-quarter view from above, wide landscape composition. "
    "The island is a chunk of land with broken, crumbling edges and hanging roots underneath. "
    "On it: three small cottages with chimneys, an old stone well in a little square, "
    "a brook crossed by a short wooden footbridge, one large old tree, a small windmill on a rise, "
    "a few lanterns along a dirt path, some boulders, a vegetable patch with a low fence. "
    "One tiny figure, an old man with a walking stick, stands by the well. "
    "Calm late-afternoon light, gentle long shadows, a quiet and slightly melancholic mood. "
    "Every object is clearly readable as its own shape, with clear space between objects. "
    "No text, no letters, no user interface, no border, no frame."
)

STYLES = {
    "a_gouache": PAINTED_STYLE,
    "b_ink_watercolour": (
        "Style: storybook illustration with fine dark ink linework and loose watercolour washes on "
        "textured paper. Rich small details such as roof shingles, planks, stones and leaves, "
        "gentle colour bleeding, a delicate hand-drawn feeling."
    ),
    "c_diorama_3d": (
        "Style: stylised 3D miniature diorama render. Soft clay-like and matte painted materials, "
        "chunky simplified geometry, soft global illumination with ambient occlusion, a subtle "
        "tilt-shift depth of field, like a handmade scale model photographed in a studio."
    ),
    "d_pixel_art": (
        "Style: detailed isometric pixel art with a 2:1 dimetric projection. Crisp square pixels, "
        "no anti-aliasing, no blur, a limited palette of about 32 colours, careful dithering, "
        "like a modern high-quality pixel art adventure game."
    ),
}


def job(style, model):
    prompt = f"{SUBJECT}\n\n{STYLES[style]}"
    target = TARGET / f"{style}_{model}.png"
    try:
        if model == "openai":
            usage = openai_image(prompt, target)
        else:
            usage = google_image(prompt, target)
        return f"OK    {target.name}  {json.dumps(usage)}"
    except Exception as error:
        return f"ERROR {target.name}  {error}"


def main():
    jobs = [(style, model) for style in STYLES for model in ("openai", "google")]
    with ThreadPoolExecutor(max_workers=8) as pool:
        for line in pool.map(lambda j: job(*j), jobs):
            print(line, flush=True)


if __name__ == "__main__":
    main()
