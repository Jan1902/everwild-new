"""Gemeinsame Stilvorgaben für alle Bild-Prompts.

Motivbeschreibungen bleiben schlicht und nennen nur, was zu sehen ist. Wie es gemalt ist,
steht ausschließlich hier, damit alle Bilder denselben Stil bekommen.
"""

# Der erste Test (Laterne) wurde zu detailliert und zu realistisch: Holzmaserung, Nieten, Rost.
# Deshalb benennt der Stil ausdrücklich, was wegbleiben soll.
STIL_GEMALT = (
    "Style: simple hand-painted gouache illustration, like a quiet picture book. "
    "Big, clear, slightly rounded shapes built from a few flat colour areas, each with only a soft "
    "hint of brush texture. Two or three tones per material: a base colour, one shadow tone, one "
    "light tone. No outlines. A small muted warm palette with one or two saturated accents. "
    "Low to medium level of detail: suggest materials with colour and shape, not with texture. "
    "No wood grain, no rivets, no scratches, no rust speckles, no tiny highlights, no realistic "
    "rendering, no photographic lighting. It must read clearly when shown small on a phone screen."
)

# Projektion und Licht müssen bei allen Bildern gleich sein, sonst passen sie nicht zusammen.
ANSICHT = (
    "View: classic 2:1 isometric game projection seen from above, where a square on the ground "
    "appears as a diamond twice as wide as it is tall. Soft daylight coming from the upper left."
)

SPRITE_REGELN = (
    "A single object as a game sprite, fully visible and centred with empty margin around it. "
    "Fully transparent background. No ground, no grass, no cast shadow, no glow or light halo "
    "around the object, no other objects, no text."
)

STILREFERENZ = (
    "The attached image is the painted ground of the game world. Use it only as a reference for "
    "painting style, brushwork and colour palette. Do not copy anything from its content."
)

BODEN = (
    "Repaint the attached flat-coloured map as a finished painted ground for a game world: a small "
    "island floating in the air. "
    "Keep the layout exactly: every shape stays at the same position, with the same size, outline "
    "and angles as in the map. Do not move, add, remove, widen or straighten anything. "
    "Meaning of the colours: green is a grass meadow, sand is a trodden dirt path, blue is a "
    "shallow brook of clear water, brown is the broken-off earth at the island's edge. "
    "Paint the grass, paths and water as calm, flat areas with gentle colour variation. Let the "
    "paths blend softly into the grass and give the brook soft grassy banks. "
    "Below the brown edge, continue the island downwards as a rough underside of earth and rock "
    "that tapers and breaks off, with a few hanging roots. "
    "Everything white in the map becomes fully transparent background. "
    "Paint only ground: no houses, no trees, no bushes, no stones, no bridge, no fences, no "
    "people, no shadows of objects, no clouds, no text."
)


def sprite_prompt(motiv, mit_referenz=False):
    teile = [motiv, SPRITE_REGELN, ANSICHT, STIL_GEMALT]
    if mit_referenz:
        teile.append(STILREFERENZ)
    return "\n\n".join(teile)


def boden_prompt():
    return "\n\n".join([BODEN, ANSICHT, STIL_GEMALT])
