"""Генерация реалистичной руки через OpenRouter для VasoLog.

Prompt оптимизирован под медицинское назначение:
- чёткая анатомия, palm-up
- чистый белый фон для вырезания
- без теней (чтобы легко сегментировать)
"""

import base64
import json
import sys
from pathlib import Path
from urllib import request, error

KEY_PATH = Path(
    r"C:/Users/Alex/Documents/Projects/ai-projects/aiassistpro/seller-assistant/.env.local"
)
API_URL = "https://openrouter.ai/api/v1/chat/completions"
OUT_DIR = Path(r"D:/dev/vasolog/assets/images")


def load_key() -> str:
    for line in KEY_PATH.read_text(encoding="utf-8").splitlines():
        if line.strip().startswith("OPENROUTER_API_KEY"):
            return line.split("=", 1)[1].strip().strip('"').strip("'")
    raise SystemExit("OPENROUTER_API_KEY not found")


def generate(model: str, prompt: str, out_name: str) -> Path | None:
    key = load_key()
    body = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "modalities": ["image", "text"],
    }
    req = request.Request(
        API_URL,
        data=json.dumps(body).encode(),
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://vasolog.app",
            "X-Title": "VasoLog",
        },
    )
    try:
        with request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read())
    except error.HTTPError as e:
        print(f"[{model}] HTTP {e.code}: {e.read().decode()[:500]}")
        return None
    except Exception as e:
        print(f"[{model}] err: {e}")
        return None

    # Новый формат OpenRouter для image output: messages[0].images[]
    msg = data.get("choices", [{}])[0].get("message", {})
    images = msg.get("images") or []
    if not images:
        # fallback: проверим content
        content = msg.get("content", "")
        print(f"[{model}] no images returned. text content: {content[:200]}")
        print(f"full response keys: {list(data.keys())}")
        print(f"message keys: {list(msg.keys())}")
        return None

    img_entry = images[0]
    # формат: {'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,...'}}
    url = img_entry.get("image_url", {}).get("url", "")
    if not url.startswith("data:image"):
        print(f"[{model}] unexpected url format: {url[:100]}")
        return None

    b64 = url.split(",", 1)[1]
    img_bytes = base64.b64decode(b64)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / out_name
    out.write_bytes(img_bytes)
    print(f"[{model}] OK: {out} ({len(img_bytes)} bytes)")
    return out


PROMPT = (
    "Professional medical anatomical illustration of a human right hand. "
    "View: palm facing the viewer, fingers spread apart and pointing straight up, "
    "thumb extended to the left. Clean flat vector line-art style, neutral tan skin tone, "
    "clean dark outline strokes, minimal shading. Pure white background, no shadows. "
    "Front view only, no wrist or arm visible below. Symmetric anatomy, realistic "
    "finger proportions (middle finger longest, pinky shortest). Medical textbook style. "
    "Isolated on white, centered, entire hand visible with small margin."
)


if __name__ == "__main__":
    model = sys.argv[1] if len(sys.argv) > 1 else "google/gemini-2.5-flash-image"
    name = sys.argv[2] if len(sys.argv) > 2 else "hand_right.png"
    result = generate(model, PROMPT, name)
    sys.exit(0 if result else 1)
