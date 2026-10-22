"""Wallet Elite marka görsellerini üretir (altın para + taç logosu).

Kaynak geometri assets/icon/logo.svg ile aynıdır (512 birimlik kanvas).
Çıktılar: launcher ikonları ve Play simgesi. Öne çıkan grafikler ve ekran
görüntüleri test/tools/store_screens_test.dart ile çizilir.

    python tool/gen_brand_assets.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
ICON = ROOT / "assets" / "icon"

GOLD_A = (0xFF, 0xE0, 0x8A)
GOLD_B = (0xE3, 0x9A, 0x1C)
SS = 4  # süper örnekleme

RING_R, RING_W = 150, 34
CROWN = [(186, 300), (186, 214), (221, 244), (256, 196), (291, 244), (326, 214), (326, 300)]
CROWN_W = 16


def glyph_mask(size: int, scale: float = 1.0) -> Image.Image:
    """Logonun alfa maskesi; scale=1 iken para 512 kanvasta olduğu gibi durur."""
    s = size * SS
    k = s / 512 * scale
    off = s / 2 - 256 * k
    p = lambda x, y: (off + x * k, off + y * k)
    m = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(m)
    cx, cy = p(256, 256)
    ro, ri = (RING_R + RING_W / 2) * k, (RING_R - RING_W / 2) * k
    d.ellipse([cx - ro, cy - ro, cx + ro, cy + ro], fill=255)
    d.ellipse([cx - ri, cy - ri, cx + ri, cy + ri], fill=0)
    pts = [p(*q) for q in CROWN]
    d.polygon(pts, fill=255)
    w = CROWN_W * k
    for a, b in zip(pts, pts[1:] + pts[:1]):
        d.line([a, b], fill=255, width=round(w))
    for x, y in pts:
        d.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2], fill=255)
    return m.resize((size, size), Image.LANCZOS)


def gold(size: int) -> Image.Image:
    """Sol üstten sağ alta altın gradyan."""
    g = Image.new("RGB", (size, size))
    px = g.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(GOLD_A, GOLD_B))
    return g


def icon(size: int, scale: float = 1.0, bg=(0, 0, 0)) -> Image.Image:
    base = Image.new("RGBA", (size, size), bg + (255,) if bg else (0, 0, 0, 0))
    base.paste(gold(size), (0, 0), glyph_mask(size, scale))
    return base


def main() -> None:
    icon(1024).convert("RGB").save(ICON / "logo.png")
    # Adaptive ikon: 108dp kanvasın ortadaki 66dp'lik güvenli dairesine sığsın.
    icon(1024, scale=0.74, bg=None).save(ICON / "logo_foreground.png")
    mono = Image.new("RGBA", (1024, 1024), (255, 255, 255, 0))
    mono.putalpha(glyph_mask(1024, 0.74))
    mono.save(ICON / "logo_monochrome.png")
    icon(512).convert("RGB").save(ICON / "play_store_512.png")


if __name__ == "__main__":
    main()
