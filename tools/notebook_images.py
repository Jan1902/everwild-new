"""The paper of the notebook: an open book seen from above, its two pages empty.

    python tools/notebook_images.py generate   generate the spread (1 call)
    python tools/notebook_images.py crop       crop it to the book and write assets/ui/notebook.png (free)

The image is generated at most once: an existing file is never overwritten and a failed call is
not repeated.
"""

import json
import sys

from PIL import Image

from env import PROJECT
from image_gen import openai_image
from style import PAINTED_STYLE

RAW = PROJECT / "styletest" / "notebook" / "spread.png"
TARGET = PROJECT / "assets" / "ui" / "notebook.png"
THRESHOLD = 24

SPREAD = (
    "An open notebook lying flat, seen straight from above, filling most of the image: two empty "
    "pages of warm cream paper side by side with a soft fold in the middle, a few faint stains "
    "and slightly worn edges, and a dark red-brown cloth cover showing a narrow rim around the "
    "pages. The pages are completely blank: no ruled lines, no writing, no drawings. "
    "Fully transparent background around the book. No table, no shadow, no other objects, no text."
)


def generate():
    if RAW.exists():
        print("spread: already exists, no call.")
        return
    try:
        usage = openai_image("\n\n".join([SPREAD, PAINTED_STYLE]), RAW, size="1536x1024", transparent=True)
        print("spread: OK", json.dumps(usage))
    except Exception as error:
        print("spread: ERROR", error)


def crop():
    image = Image.open(RAW).convert("RGBA")
    alpha = image.getchannel("A")
    peak = alpha.getextrema()[1]
    image.putalpha(alpha.point(lambda a: 0 if a < THRESHOLD else min(255, round(a * 255 / peak))))
    image = image.crop(image.getchannel("A").getbbox())
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    image.save(TARGET)
    print("written", TARGET.name, image.size)


if __name__ == "__main__":
    {"generate": generate, "crop": crop}[sys.argv[1]]()
