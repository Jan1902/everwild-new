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

SPRITE_REGELN = (
    "A single object as a game sprite, seen from a fixed isometric three-quarter view from above, "
    "fully visible and centred with empty margin around it. "
    "Fully transparent background. No ground, no cast shadow, no glow or light halo around the "
    "object, no other objects, no text."
)


def sprite_prompt(motiv):
    return f"{motiv}\n\n{SPRITE_REGELN}\n\n{STIL_GEMALT}"
