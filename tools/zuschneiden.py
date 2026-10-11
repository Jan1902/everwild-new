"""Bereitet generierte Bilder für das Spiel auf.

    python tools/zuschneiden.py [uebersicht.jpg]

Objekte werden auf ihren sichtbaren Inhalt beschnitten, damit das Spiel sie am Bildrand
ausrichten kann (unten Mitte = Fußpunkt). Das Bodenbild wird unverändert übernommen.
Optional entsteht eine Übersicht aller Objekte auf Grasfarbe zur Sichtkontrolle.
"""

import shutil
import sys

from PIL import Image

from umgebung import PROJEKT

ROH = PROJEKT / "stiltest" / "dorf"
OBJEKTE = PROJEKT / "assets" / "objekte"
WELTEN = PROJEKT / "assets" / "welten"
NAMEN = ["haus", "baum", "stein", "laterne", "bruecke"]
# Unterhalb dieser Deckkraft gilt ein Pixel als leer. Blendet schwache Schleier um das Objekt aus.
SCHWELLE = 24


def beschneide(name):
    bild = Image.open(ROH / f"{name}.png").convert("RGBA")
    alpha = bild.getchannel("A")
    # Das Modell liefert auch im Objekt keine volle Deckkraft. Auf den vollen Bereich strecken.
    hoechst = alpha.getextrema()[1]
    alpha = alpha.point(lambda a: 0 if a < SCHWELLE else min(255, round(a * 255 / hoechst)))
    bild.putalpha(alpha)
    bild = bild.crop(alpha.getbbox())
    # Im Spiel sind Objekte höchstens rund 300 Weltpixel breit. Die halbe Auflösung reicht dafür
    # und vermeidet Flimmern beim starken Verkleinern.
    bild = bild.resize((bild.width // 2, bild.height // 2), Image.LANCZOS)
    OBJEKTE.mkdir(parents=True, exist_ok=True)
    bild.save(OBJEKTE / f"{name}.png")
    return bild


def main():
    bilder = [beschneide(name) for name in NAMEN]
    for name, bild in zip(NAMEN, bilder):
        print(name, bild.size)

    WELTEN.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(ROH / "boden.png", WELTEN / "dorf_boden.png")

    if len(sys.argv) > 1:
        hoehe = 600
        klein = [b.resize((max(1, b.width * hoehe // b.height), hoehe), Image.LANCZOS) for b in bilder]
        klein = [b if b.width <= 900 else b.resize((900, b.height * 900 // b.width), Image.LANCZOS) for b in klein]
        blatt = Image.new("RGBA", (sum(b.width for b in klein) + 40 * (len(klein) + 1), hoehe + 80), "#7fae6b")
        x = 40
        for b in klein:
            blatt.alpha_composite(b, (x, 40 + hoehe - b.height))
            x += b.width + 40
        blatt.convert("RGB").save(sys.argv[1], quality=88)


if __name__ == "__main__":
    main()
