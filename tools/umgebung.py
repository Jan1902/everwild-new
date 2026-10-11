"""Liest die Zugangsdaten aus der .env im Projektordner."""

from pathlib import Path

PROJEKT = Path(__file__).resolve().parent.parent


def lade_env():
    werte = {}
    for zeile in (PROJEKT / ".env").read_text(encoding="utf-8-sig").splitlines():
        zeile = zeile.strip()
        if not zeile or zeile.startswith("#") or "=" not in zeile:
            continue
        name, wert = zeile.split("=", 1)
        werte[name.strip()] = wert.strip().strip('"').strip("'")
    return werte
