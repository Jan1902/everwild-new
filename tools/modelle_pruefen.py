"""Prüft, ob die API-Keys aus .env funktionieren, und listet die Bildmodelle."""

import json
import urllib.error
import urllib.request

from umgebung import lade_env


def hole(url, header):
    anfrage = urllib.request.Request(url, headers=header)
    try:
        with urllib.request.urlopen(anfrage, timeout=60) as antwort:
            return json.load(antwort)
    except urllib.error.HTTPError as fehler:
        return {"fehler": fehler.code, "text": fehler.read().decode("utf-8", "replace")[:500]}


def main():
    env = lade_env()

    openai = hole("https://api.openai.com/v1/models", {"Authorization": f"Bearer {env['OPENAI_API_KEY']}"})
    if "fehler" in openai:
        print("OpenAI:", openai)
    else:
        namen = sorted(m["id"] for m in openai["data"] if "image" in m["id"])
        print("OpenAI Bildmodelle:", namen)

    google = hole(
        "https://generativelanguage.googleapis.com/v1beta/models?pageSize=1000",
        {"x-goog-api-key": env["GOOGLE_API_KEY"]},
    )
    if "fehler" in google:
        print("Google:", google)
    else:
        namen = sorted(
            m["name"] for m in google["models"] if "image" in m["name"] or "banana" in m["name"]
        )
        print("Google Bildmodelle:", namen)


if __name__ == "__main__":
    main()
