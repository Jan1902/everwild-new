"""Checks whether the API keys from .env work, and lists the image models."""

import json
import urllib.error
import urllib.request

from env import load_env


def fetch(url, headers):
    request = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        return {"error": error.code, "text": error.read().decode("utf-8", "replace")[:500]}


def main():
    env = load_env()

    openai = fetch("https://api.openai.com/v1/models", {"Authorization": f"Bearer {env['OPENAI_API_KEY']}"})
    if "error" in openai:
        print("OpenAI:", openai)
    else:
        names = sorted(m["id"] for m in openai["data"] if "image" in m["id"])
        print("OpenAI image models:", names)

    google = fetch(
        "https://generativelanguage.googleapis.com/v1beta/models?pageSize=1000",
        {"x-goog-api-key": env["GOOGLE_API_KEY"]},
    )
    if "error" in google:
        print("Google:", google)
    else:
        names = sorted(m["name"] for m in google["models"] if "image" in m["name"] or "banana" in m["name"])
        print("Google image models:", names)


if __name__ == "__main__":
    main()
