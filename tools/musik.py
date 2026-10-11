"""Musikgenerierung über Google Lyria."""

import base64
from pathlib import Path

import requests

from umgebung import lade_env

LYRIA_MODELL = "lyria-3.5"
ZEITLIMIT = 900


def lyria_stueck(prompt, ziel_ohne_endung):
    """Erzeugt ein Musikstück. Gibt den Pfad der Audiodatei und den Begleittext des Modells zurück."""
    antwort = requests.post(
        "https://generativelanguage.googleapis.com/v1beta/interactions",
        headers={"x-goog-api-key": lade_env()["GOOGLE_API_KEY"]},
        json={"model": LYRIA_MODELL, "input": prompt},
        timeout=ZEITLIMIT,
    )
    ziel_ohne_endung = Path(ziel_ohne_endung)
    ziel_ohne_endung.parent.mkdir(parents=True, exist_ok=True)
    if antwort.status_code != 200:
        raise RuntimeError(f"Lyria {antwort.status_code}: {antwort.text[:800]}")

    # Rohantwort sichern, damit ein unerwartetes Format keinen zweiten Aufruf kostet.
    roh = ziel_ohne_endung.with_suffix(".antwort.json")
    roh.write_bytes(antwort.content)

    audio, texte = None, []
    for schritt in antwort.json().get("steps", []):
        if schritt.get("type") != "model_output":
            continue
        for block in schritt.get("content", []):
            if block.get("type") == "audio" and audio is None:
                audio = base64.b64decode(block["data"])
            elif block.get("type") == "text":
                texte.append(block.get("text", ""))
    if audio is None:
        raise RuntimeError(f"Kein Audio in der Antwort, Rohdaten liegen in {roh}")

    endung = ".wav" if audio[:4] == b"RIFF" else ".mp3"
    ziel = ziel_ohne_endung.with_suffix(endung)
    ziel.write_bytes(audio)
    roh.unlink()
    return ziel, "\n".join(texte)
