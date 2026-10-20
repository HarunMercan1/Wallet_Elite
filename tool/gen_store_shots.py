"""Mağaza ekran görüntülerini çerçeveler: üstte başlık, altta telefon ekranı.

Önce ham ekranlar (1080x2280) üretilir:
    flutter test test/tools/store_screens_test.dart --dart-define=SHOTS=<repo>/store_assets/raw
Sonra:
    python tool/gen_store_shots.py
Çıktı: store_assets/screenshots/<dil>/NN_ad.png (1080x1920)
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "store_assets" / "raw"
OUT = ROOT / "store_assets" / "screenshots"
FONTS = Path("C:/Windows/Fonts")

W, H = 1080, 1920
GOLD = (0xE3, 0x9A, 0x1C)
GOLD_LIGHT = (0xFF, 0xE0, 0x8A)

CAPTIONS = {
    "en": {
        "01_home": ("All your money", "in one place"),
        "02_transactions": ("Every transaction,", "neatly organised"),
        "03_statistics": ("See where", "your money goes"),
        "04_budgets": ("Budgets that", "keep you on track"),
        "05_debts": ("Never forget", "who owes what"),
    },
    "tr": {
        "01_home": ("Tüm paran", "tek bir yerde"),
        "02_transactions": ("Her işlem", "düzenli ve net"),
        "03_statistics": ("Paranın nereye", "gittiğini gör"),
        "04_budgets": ("Bütçeni koy,", "hedefte kal"),
        "05_debts": ("Kimin kime ne kadar", "borcu var, unutma"),
    },
}


def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size[0] - 1, size[1] + radius], radius=radius, fill=255)
    return m


def frame(raw: Path, lines, out: Path) -> None:
    img = Image.new("RGB", (W, H), (0, 0, 0))
    glow = Image.new("L", (W, H), 0)
    ImageDraw.Draw(glow).ellipse([-200, -260, W + 200, 520], fill=70)
    glow = glow.filter(ImageFilter.GaussianBlur(120))
    img.paste(Image.new("RGB", (W, H), GOLD), (0, 0), glow)

    d = ImageDraw.Draw(img)
    bold = ImageFont.truetype(str(FONTS / "segoeuib.ttf"), 84)
    top, second = lines
    d.text((W / 2, 150), top, font=bold, fill=(255, 255, 255), anchor="ms")
    d.text((W / 2, 250), second, font=bold, fill=GOLD_LIGHT, anchor="ms")

    # Telefon: ekranın üst kısmı, alttan taşan çerçeveli görünüm.
    phone_w = 860
    shot = Image.open(raw).convert("RGB")
    shot = shot.resize((phone_w, round(shot.height * phone_w / shot.width)), Image.LANCZOS)
    y0 = 340
    visible = H - y0
    bezel = 18
    body = Image.new("RGB", (phone_w + 2 * bezel, visible), (0x2A, 0x2A, 0x2E))
    body.paste(shot.crop((0, 0, phone_w, visible - bezel)), (bezel, bezel))
    x0 = (W - body.width) // 2
    img.paste(body, (x0, y0), rounded_mask(body.size, 72))
    # Ekranın kendi köşeleri
    inner = Image.new("L", body.size, 0)
    ImageDraw.Draw(inner).rounded_rectangle(
        [bezel, bezel, body.width - bezel - 1, body.height + 60], radius=56, fill=255)
    edge = Image.new("L", body.size, 0)
    ImageDraw.Draw(edge).rectangle([0, 0, body.width, body.height], fill=255)
    corners = Image.composite(Image.new("L", body.size, 0), edge, inner)
    img.paste(Image.new("RGB", body.size, (0x2A, 0x2A, 0x2E)), (x0, y0),
              Image.composite(corners, Image.new("L", body.size, 0), rounded_mask(body.size, 72)))
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)


def main() -> None:
    for lang, caps in CAPTIONS.items():
        for name, lines in caps.items():
            frame(RAW / lang / f"{name}.png", lines, OUT / lang / f"{name}.png")


if __name__ == "__main__":
    main()
