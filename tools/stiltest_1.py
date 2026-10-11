"""Stiltest Stufe 1: das Tutorial-Dorf als Gesamtbild in vier Stilrichtungen, je Modell einmal.

Dient nur der Stilwahl. Die spielbaren Ebenen (Untergrund, Objekte) entstehen in Stufe 2.
"""

import json
from concurrent.futures import ThreadPoolExecutor

from bild import google_bild, openai_bild
from stil import STIL_GEMALT
from umgebung import PROJEKT

ZIEL = PROJEKT / "stiltest" / "stufe1"

MOTIV = (
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

STILE = {
    "a_gouache": STIL_GEMALT,
    "b_tusche_aquarell": (
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


def auftrag(stil, modell):
    prompt = f"{MOTIV}\n\n{STILE[stil]}"
    ziel = ZIEL / f"{stil}_{modell}.png"
    try:
        if modell == "openai":
            verbrauch = openai_bild(prompt, ziel)
        else:
            verbrauch = google_bild(prompt, ziel)
        return f"OK   {ziel.name}  {json.dumps(verbrauch)}"
    except Exception as fehler:
        return f"FEHL {ziel.name}  {fehler}"


def main():
    auftraege = [(stil, modell) for stil in STILE for modell in ("openai", "google")]
    with ThreadPoolExecutor(max_workers=8) as pool:
        for zeile in pool.map(lambda a: auftrag(*a), auftraege):
            print(zeile, flush=True)


if __name__ == "__main__":
    main()
