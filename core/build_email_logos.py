#!/usr/bin/env python3
"""Cut the brand marks down to something an inbox can carry.

    python3 core/build_email_logos.py

Reads brand/logo-{thayi,asha,care}.png and writes brand/email/{key}.png.
Run it whenever a logo in brand/ changes, then re-run upload_email_logos.sh.

Two things happen here, and both matter:

Size. The sources are 1254px and about 1.5MB each. That is a print asset. It
goes to a woman on a metered 2G connection who wants a six digit number, so it
comes down to a 128px disc of roughly 20KB - 2x for a 64px slot, and no more.

Shape. Each mark is a square tile with its own baked cream ground, and the
three creams differ (#EFE2BF, #F4EDD2, #F6E2C3) - none of them the email's
#F7F2EA. Dropped in square they read as three mismatched patches on the card.
Cropped to a disc they read as one app icon each. The area outside the disc is
transparent, which composites onto the white card; Outlook flattens alpha onto
white anyway, so it lands the same there.

Needs Pillow:  pip3 install Pillow
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "brand"
OUT = SRC / "email"

# 64px display slot at 2x.
SIZE = 128
# The mask is drawn this many times oversized and scaled down, because PIL's
# ellipse has no antialiasing of its own and a hard-edged disc looks cheap.
SUPERSAMPLE = 8

# Keys match Brand.key in the send-email function and the object names in the
# storage bucket. Adding an app means adding a line here.
LOGOS = {
    "thayi": "logo-thayi.png",
    "asha": "logo-asha.png",
    "care": "logo-care.png",
}


def build(src: Path, dest: Path) -> None:
    image = Image.open(src).convert("RGB").resize((SIZE, SIZE), Image.LANCZOS)

    big = SIZE * SUPERSAMPLE
    mask = Image.new("L", (big, big), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, big - 1, big - 1), fill=255)
    image.putalpha(mask.resize((SIZE, SIZE), Image.LANCZOS))

    image.save(dest, optimize=True)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for key, filename in LOGOS.items():
        src = SRC / filename
        if not src.exists():
            raise SystemExit(f"missing {src}")
        dest = OUT / f"{key}.png"
        build(src, dest)
        print(f"{key:6} {dest.relative_to(ROOT)}  {dest.stat().st_size // 1024}KB")


if __name__ == "__main__":
    main()
