"""Music generation through Google Lyria."""

import base64
from pathlib import Path

import requests

from env import load_env

LYRIA_MODEL = "lyria-3.5"
TIMEOUT = 900


def lyria_track(prompt, target_without_suffix):
    """Generates a music track. Returns the path of the audio file and the model's accompanying text."""
    response = requests.post(
        "https://generativelanguage.googleapis.com/v1beta/interactions",
        headers={"x-goog-api-key": load_env()["GOOGLE_API_KEY"]},
        json={"model": LYRIA_MODEL, "input": prompt},
        timeout=TIMEOUT,
    )
    target_without_suffix = Path(target_without_suffix)
    target_without_suffix.parent.mkdir(parents=True, exist_ok=True)
    if response.status_code != 200:
        raise RuntimeError(f"Lyria {response.status_code}: {response.text[:800]}")

    # Keep the raw response so an unexpected format does not cost a second call.
    raw = target_without_suffix.with_suffix(".response.json")
    raw.write_bytes(response.content)

    audio, texts = None, []
    for step in response.json().get("steps", []):
        if step.get("type") != "model_output":
            continue
        for block in step.get("content", []):
            if block.get("type") == "audio" and audio is None:
                audio = base64.b64decode(block["data"])
            elif block.get("type") == "text":
                texts.append(block.get("text", ""))
    if audio is None:
        raise RuntimeError(f"No audio in the response, raw data is in {raw}")

    suffix = ".wav" if audio[:4] == b"RIFF" else ".mp3"
    target = target_without_suffix.with_suffix(suffix)
    target.write_bytes(audio)
    raw.unlink()
    return target, "\n".join(texts)
