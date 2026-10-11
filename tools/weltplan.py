"""Zeichnet aus einer Weltdatei einen flachen Lageplan des Bodens als Vorlage für das Bildmodell.

Der Plan nutzt dieselbe Projektion wie das Spiel (src/logik/iso.gd). Zusätzlich liefert er die
Lage des Bildes in der Welt, damit das gemalte Bodenbild später passgenau unter dem Raster liegt.
"""

import json
from pathlib import Path

from PIL import Image, ImageDraw

ZELLE = (128, 64)
KANTE = 90
LAND = ".=~#"
FARBEN = {".": "#7fae6b", "=": "#d8c394", "~": "#74b6cc", "#": "#74b6cc"}
ERDE_HELL, ERDE_DUNKEL = "#8a6a4f", "#6e533f"


def zu_punkt(x, y):
    return ((x - y) * ZELLE[0] / 2, (x + y) * ZELLE[1] / 2)


def ecken(x, y):
    mx, my = zu_punkt(x, y)
    hx, hy = ZELLE[0] / 2, ZELLE[1] / 2
    return [(mx, my - hy), (mx + hx, my), (mx, my + hy), (mx - hx, my)]


def lies_boden(weltdatei):
    return json.loads(Path(weltdatei).read_text(encoding="utf-8"))["boden"]


def lage(boden, bildgroesse, rand_oben=0.05, rand_unten=0.2):
    """Maßstab (Bildpixel pro Weltpixel) und Weltpunkt der linken oberen Bildecke."""
    punkte = [p for y, zeile in enumerate(boden) for x, z in enumerate(zeile) if z in LAND for p in ecken(x, y)]
    links, rechts = min(p[0] for p in punkte), max(p[0] for p in punkte)
    oben, unten = min(p[1] for p in punkte), max(p[1] for p in punkte)
    breite, hoehe = bildgroesse
    massstab = hoehe * (1 - rand_oben - rand_unten) / (unten - oben)
    massstab = min(massstab, breite * 0.9 / (rechts - links))
    massstab = round(massstab, 3)
    ursprung = (
        round((links + rechts) / 2 - breite / 2 / massstab, 2),
        round(oben - hoehe * rand_oben / massstab, 2),
    )
    return massstab, ursprung


def zeichne(boden, bildgroesse, massstab, ursprung, raster=False, grund=None):
    """Lageplan auf Weiß. Mit grund wird stattdessen nur das Raster über ein vorhandenes Bild gelegt."""
    bild = grund.convert("RGBA") if grund else Image.new("RGBA", bildgroesse, "white")
    stift = ImageDraw.Draw(bild)

    def ins_bild(punkte, versatz=0):
        return [((px - ursprung[0]) * massstab, (py + versatz - ursprung[1]) * massstab) for px, py in punkte]

    def zeichen(x, y):
        return boden[y][x] if 0 <= y < len(boden) and 0 <= x < len(boden[y]) else " "

    zellen = [(x, y) for y, zeile in enumerate(boden) for x, z in enumerate(zeile) if z in LAND]
    if not grund:
        for x, y in zellen:
            e = ecken(x, y)
            if zeichen(x + 1, y) == " ":
                stift.polygon(ins_bild([e[1], e[2]]) + ins_bild([e[2], e[1]], KANTE), fill=ERDE_HELL)
            if zeichen(x, y + 1) == " ":
                stift.polygon(ins_bild([e[2], e[3]]) + ins_bild([e[3], e[2]], KANTE), fill=ERDE_DUNKEL)
        for x, y in zellen:
            stift.polygon(ins_bild(ecken(x, y)), fill=FARBEN[zeichen(x, y)])
    if raster or grund:
        for x, y in zellen:
            e = ins_bild(ecken(x, y))
            farbe = {"~": "#0040ff", "#": "#ff00ff", "=": "#ff8000"}.get(zeichen(x, y), "#ffffff")
            stift.line(e + [e[0]], fill=farbe, width=2)
    return bild
