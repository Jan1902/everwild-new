"""Bildgenerierung über OpenAI (GPT Image) und Google (Nano Banana)."""

import base64
import mimetypes
from pathlib import Path

import requests

from umgebung import lade_env

OPENAI_MODELL = "gpt-image-2.5-sunburst"
GOOGLE_MODELL = "gemini-nano-banana-2.1"
ZEITLIMIT = 600


def openai_bild(prompt, ziel, groesse="1536x1024", qualitaet="high", transparent=False, referenzen=()):
    """Erzeugt ein Bild mit GPT Image. Mit Referenzbildern läuft es über den Edit-Endpunkt."""
    kopf = {"Authorization": f"Bearer {lade_env()['OPENAI_API_KEY']}"}
    felder = {
        "model": OPENAI_MODELL,
        "prompt": prompt,
        "size": groesse,
        "quality": qualitaet,
        "output_format": "png",
        "background": "transparent" if transparent else "opaque",
    }
    if referenzen:
        dateien = [
            ("image[]", (Path(p).name, Path(p).read_bytes(), mimetypes.guess_type(p)[0] or "image/png"))
            for p in referenzen
        ]
        antwort = requests.post(
            "https://api.openai.com/v1/images/edits", headers=kopf, data=felder, files=dateien, timeout=ZEITLIMIT
        )
    else:
        antwort = requests.post(
            "https://api.openai.com/v1/images/generations", headers=kopf, json=felder, timeout=ZEITLIMIT
        )
    if antwort.status_code != 200:
        raise RuntimeError(f"OpenAI {antwort.status_code}: {antwort.text[:800]}")
    daten = antwort.json()
    _schreibe(ziel, base64.b64decode(daten["data"][0]["b64_json"]))
    return daten.get("usage", {})


def google_bild(prompt, ziel, seitenverhaeltnis="16:9", groesse="2K", referenzen=()):
    """Erzeugt ein Bild mit Nano Banana. Referenzbilder werden dem Prompt vorangestellt."""
    teile = [
        {
            "inlineData": {
                "mimeType": mimetypes.guess_type(p)[0] or "image/png",
                "data": base64.b64encode(Path(p).read_bytes()).decode("ascii"),
            }
        }
        for p in referenzen
    ]
    teile.append({"text": prompt})
    antwort = requests.post(
        f"https://generativelanguage.googleapis.com/v1beta/models/{GOOGLE_MODELL}:generateContent",
        headers={"x-goog-api-key": lade_env()["GOOGLE_API_KEY"]},
        json={
            "contents": [{"parts": teile}],
            "generationConfig": {
                "responseModalities": ["IMAGE"],
                "imageConfig": {"aspectRatio": seitenverhaeltnis, "imageSize": groesse},
            },
        },
        timeout=ZEITLIMIT,
    )
    if antwort.status_code != 200:
        raise RuntimeError(f"Google {antwort.status_code}: {antwort.text[:800]}")
    daten = antwort.json()
    for teil in daten["candidates"][0]["content"]["parts"]:
        if "inlineData" in teil:
            _schreibe(ziel, base64.b64decode(teil["inlineData"]["data"]))
            return daten.get("usageMetadata", {})
    raise RuntimeError(f"Google lieferte kein Bild: {str(daten)[:800]}")


def _schreibe(ziel, inhalt):
    ziel = Path(ziel)
    ziel.parent.mkdir(parents=True, exist_ok=True)
    ziel.write_bytes(inhalt)
