"""Reads the credentials from the .env file in the project folder."""

import json
from pathlib import Path

PROJECT = Path(__file__).resolve().parent.parent
# How the images sit in the world. The game reads the same file (src/view/sprites.gd).
SPRITES = json.loads((PROJECT / "data" / "sprites.json").read_text(encoding="utf-8"))


def load_env():
    values = {}
    for line in (PROJECT / ".env").read_text(encoding="utf-8-sig").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        name, value = line.split("=", 1)
        values[name.strip()] = value.strip().strip('"').strip("'")
    return values
