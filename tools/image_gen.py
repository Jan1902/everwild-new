"""Image generation through OpenAI (GPT Image) and Google (Nano Banana)."""

import base64
import mimetypes
from pathlib import Path

import requests

from env import load_env

OPENAI_MODEL = "gpt-image-2.5-sunburst"
GOOGLE_MODEL = "gemini-nano-banana-2.1"
TIMEOUT = 600


def openai_image(prompt, target, size="1536x1024", quality="high", transparent=False, references=()):
    """Generates an image with GPT Image. With reference images it goes through the edit endpoint."""
    headers = {"Authorization": f"Bearer {load_env()['OPENAI_API_KEY']}"}
    fields = {
        "model": OPENAI_MODEL,
        "prompt": prompt,
        "size": size,
        "quality": quality,
        "output_format": "png",
        "background": "transparent" if transparent else "opaque",
    }
    if references:
        files = [
            ("image[]", (Path(p).name, Path(p).read_bytes(), mimetypes.guess_type(p)[0] or "image/png"))
            for p in references
        ]
        response = requests.post(
            "https://api.openai.com/v1/images/edits", headers=headers, data=fields, files=files, timeout=TIMEOUT
        )
    else:
        response = requests.post(
            "https://api.openai.com/v1/images/generations", headers=headers, json=fields, timeout=TIMEOUT
        )
    if response.status_code != 200:
        raise RuntimeError(f"OpenAI {response.status_code}: {response.text[:800]}")
    data = response.json()
    _write(target, base64.b64decode(data["data"][0]["b64_json"]))
    return data.get("usage", {})


def google_image(prompt, target, aspect_ratio="16:9", size="2K", references=()):
    """Generates an image with Nano Banana. Reference images are placed before the prompt."""
    parts = [
        {
            "inlineData": {
                "mimeType": mimetypes.guess_type(p)[0] or "image/png",
                "data": base64.b64encode(Path(p).read_bytes()).decode("ascii"),
            }
        }
        for p in references
    ]
    parts.append({"text": prompt})
    response = requests.post(
        f"https://generativelanguage.googleapis.com/v1beta/models/{GOOGLE_MODEL}:generateContent",
        headers={"x-goog-api-key": load_env()["GOOGLE_API_KEY"]},
        json={
            "contents": [{"parts": parts}],
            "generationConfig": {
                "responseModalities": ["IMAGE"],
                "imageConfig": {"aspectRatio": aspect_ratio, "imageSize": size},
            },
        },
        timeout=TIMEOUT,
    )
    if response.status_code != 200:
        raise RuntimeError(f"Google {response.status_code}: {response.text[:800]}")
    data = response.json()
    for part in data["candidates"][0]["content"]["parts"]:
        if "inlineData" in part:
            _write(target, base64.b64decode(part["inlineData"]["data"]))
            return data.get("usageMetadata", {})
    raise RuntimeError(f"Google returned no image: {str(data)[:800]}")


def _write(target, content):
    target = Path(target)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(content)
