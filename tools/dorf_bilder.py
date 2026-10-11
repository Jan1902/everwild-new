"""Erzeugt die ersten echten Bilder für das Dorf: ein Bodenbild und fünf Objekte.

    python tools/dorf_bilder.py plan       Lageplan zeichnen (kostenlos)
    python tools/dorf_bilder.py boden      Bodenbild generieren (1 Aufruf)
    python tools/dorf_bilder.py objekte    Objekte generieren (5 Aufrufe)
    python tools/dorf_bilder.py raster     Raster zur Kontrolle über das Bodenbild legen (kostenlos)

Jedes Bild wird höchstens einmal erzeugt: vorhandene Dateien werden nie überschrieben und
fehlgeschlagene Aufrufe nicht wiederholt.
"""

import json
import sys
from concurrent.futures import ThreadPoolExecutor

from PIL import Image

import weltplan
from bild import openai_bild
from stil import boden_prompt, sprite_prompt
from umgebung import PROJEKT

WELT = PROJEKT / "data" / "welten" / "dorf.json"
ROH = PROJEKT / "stiltest" / "dorf"
BODENGROESSE = (2560, 1440)

OBJEKTE = {
    "haus": (
        "A small village cottage with a square footprint: pale plastered walls, a red tiled "
        "pyramid-shaped roof with a small chimney, a plain wooden door in the wall facing lower "
        "right and one small window in the wall facing lower left."
    ),
    "baum": "A leafy deciduous tree with a short brown trunk and a full, rounded green crown.",
    "stein": "A single grey boulder, about knee-high, with a flat top.",
    "laterne": (
        "An old village street lantern: a wooden post with a small dark metal lantern hanging from "
        "a curved arm, a warm yellow light inside the lantern."
    ),
    "bruecke": (
        "A short, flat wooden plank footbridge without railings, just wide enough for one person. "
        "It lies flat on the ground plane and runs diagonally from the upper left to the lower "
        "right, following the isometric ground axis."
    ),
}


def plan():
    boden = weltplan.lies_boden(WELT)
    massstab, ursprung = weltplan.lage(boden, BODENGROESSE)
    ROH.mkdir(parents=True, exist_ok=True)
    weltplan.zeichne(boden, BODENGROESSE, massstab, ursprung).convert("RGB").save(ROH / "plan.png")
    (ROH / "plan.json").write_text(json.dumps({"massstab": massstab, "ursprung": ursprung}), encoding="utf-8")
    print("Plan:", ROH / "plan.png", "Maßstab", massstab, "Ursprung", ursprung)


def boden():
    ziel = ROH / "boden.png"
    if ziel.exists():
        print("Bodenbild existiert schon, kein Aufruf.")
        return
    verbrauch = openai_bild(
        boden_prompt(),
        ziel,
        groesse="%dx%d" % BODENGROESSE,
        transparent=True,
        referenzen=[ROH / "plan.png"],
    )
    print("Boden:", ziel, json.dumps(verbrauch))


def objekte():
    referenz = ROH / "boden_klein.png"
    if not referenz.exists():
        Image.open(ROH / "boden.png").resize((1280, 720), Image.LANCZOS).save(referenz)

    def erzeuge(name):
        ziel = ROH / f"{name}.png"
        if ziel.exists():
            return f"{name}: existiert schon, kein Aufruf."
        try:
            verbrauch = openai_bild(
                sprite_prompt(OBJEKTE[name], mit_referenz=True), ziel, transparent=True, referenzen=[referenz]
            )
            return f"{name}: OK {json.dumps(verbrauch)}"
        except Exception as fehler:
            return f"{name}: FEHLER {fehler}"

    with ThreadPoolExecutor(max_workers=len(OBJEKTE)) as pool:
        for zeile in pool.map(erzeuge, OBJEKTE):
            print(zeile, flush=True)


def raster():
    lage = json.loads((ROH / "plan.json").read_text(encoding="utf-8"))
    grund = Image.new("RGBA", BODENGROESSE, "#c8d8e4")
    grund.alpha_composite(Image.open(ROH / "boden.png").convert("RGBA"))
    bild = weltplan.zeichne(weltplan.lies_boden(WELT), BODENGROESSE, lage["massstab"], lage["ursprung"], grund=grund)
    bild.convert("RGB").save(ROH / "boden_mit_raster.jpg", quality=88)
    print("Kontrolle:", ROH / "boden_mit_raster.jpg")


if __name__ == "__main__":
    {"plan": plan, "boden": boden, "objekte": objekte, "raster": raster}[sys.argv[1]]()
