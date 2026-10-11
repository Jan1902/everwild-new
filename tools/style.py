"""Shared style rules for all image prompts.

Subject descriptions stay plain and only name what is to be seen. How it is painted is defined
here and nowhere else, so that all images get the same style.
"""

# The first test (lantern) came out too detailed and too realistic: wood grain, rivets, rust.
# That is why the style names explicitly what to leave out.
PAINTED_STYLE = (
    "Style: simple hand-painted gouache illustration, like a quiet picture book. "
    "Big, clear, slightly rounded shapes built from a few flat colour areas, each with only a soft "
    "hint of brush texture. Two or three tones per material: a base colour, one shadow tone, one "
    "light tone. No outlines. A small muted warm palette with one or two saturated accents. "
    "Low to medium level of detail: suggest materials with colour and shape, not with texture. "
    "No wood grain, no rivets, no scratches, no rust speckles, no tiny highlights, no realistic "
    "rendering, no photographic lighting. It must read clearly when shown small on a phone screen."
)

# Projection and light have to be the same in all images, otherwise they do not fit together.
VIEW = (
    "View: classic 2:1 isometric game projection seen from above, where a square on the ground "
    "appears as a diamond twice as wide as it is tall. Soft daylight coming from the upper left."
)

SPRITE_RULES = (
    "A single object as a game sprite, fully visible and centred with empty margin around it. "
    "Fully transparent background. No ground, no grass, no cast shadow, no glow or light halo "
    "around the object, no other objects, no text."
)

STYLE_REFERENCE = (
    "The attached image is the painted ground of the game world. Use it only as a reference for "
    "painting style, brushwork and colour palette. Do not copy anything from its content."
)

GROUND = (
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


def sprite_prompt(subject, with_reference=False):
    parts = [subject, SPRITE_RULES, VIEW, PAINTED_STYLE]
    if with_reference:
        parts.append(STYLE_REFERENCE)
    return "\n\n".join(parts)


def ground_prompt():
    return "\n\n".join([GROUND, VIEW, PAINTED_STYLE])
