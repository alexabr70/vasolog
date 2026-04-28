#!/usr/bin/env python3
"""AppGallery Connect Publishing API v2 - деплой APK."""

import os
import sys
import hashlib
import argparse
import requests
from pathlib import Path

# Загрузка credentials из .env.agc
def load_env():
    """Загрузить credentials: сначала из окружения (CI), потом из .env.agc (локально)."""
    # Если переменные уже в окружении (Codemagic/GitHub Actions) - не трогаем
    if all(os.environ.get(k) for k in ("AGC_CLIENT_ID", "AGC_CLIENT_SECRET", "AGC_APP_ID")):
        print("Credentials из переменных окружения (CI mode)")
        return

    # Локальный .env.agc для разработки
    env_path = Path(__file__).parent.parent / ".env.agc"
    if not env_path.exists():
        print("Ошибка: переменные AGC_CLIENT_ID/AGC_CLIENT_SECRET/AGC_APP_ID не заданы")
        print(f"Локально: создай {env_path}")
        print("  AGC_CLIENT_ID=...")
        print("  AGC_CLIENT_SECRET=...")
        print("  AGC_APP_ID=117440803")
        print("В CI (Codemagic): задай переменные в группе appgallery")
        sys.exit(1)
    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                key, _, val = line.partition("=")
                os.environ[key.strip()] = val.strip()
    print(f"Credentials загружены из {env_path}")

BASE_URL = "https://connect-api.cloud.huawei.com"

def get_token(client_id: str, client_secret: str) -> str:
    resp = requests.post(
        f"{BASE_URL}/api/oauth2/v1/token",
        json={"grant_type": "client_credentials", "client_id": client_id, "client_secret": client_secret},
    )
    resp.raise_for_status()
    data = resp.json()
    if data.get("ret", {}).get("code") != 0:
        raise RuntimeError(f"Token error: {data}")
    token = data["access_token"]
    print(f"Token получен (expires in {data.get('expires_in', '?')}s)")
    return token

def get_upload_url(token: str, client_id: str, app_id: str, apk_name: str) -> dict:
    resp = requests.get(
        f"{BASE_URL}/api/publish/v2/upload-url",
        params={"appId": app_id, "suffix": "apk"},
        headers={"client_id": client_id, "Authorization": f"Bearer {token}"},
    )
    resp.raise_for_status()
    data = resp.json()
    if data.get("ret", {}).get("code") != 0:
        raise RuntimeError(f"Upload URL error: {data}")
    print("Upload URL получен")
    return data

def upload_apk(upload_url: str, apk_path: Path) -> dict:
    apk_size = apk_path.stat().st_size
    with open(apk_path, "rb") as f:
        apk_bytes = f.read()
    md5 = hashlib.md5(apk_bytes).hexdigest()
    print(f"Загружаю {apk_path.name} ({apk_size / 1024 / 1024:.1f} MB)...")
    resp = requests.put(
        upload_url,
        data=apk_bytes,
        headers={"Content-Type": "application/octet-stream", "Content-MD5": md5},
    )
    resp.raise_for_status()
    result = resp.json()
    print(f"APK загружен: {result.get('result', {}).get('UploadFileRsp', {}).get('fileDestUlr', '?')[:60]}...")
    return result

def update_file_info(token: str, client_id: str, app_id: str, file_dest_url: str, apk_name: str, apk_size: int) -> None:
    payload = {
        "fileType": 5,
        "files": [{"fileName": apk_name, "fileDestUrl": file_dest_url, "size": apk_size}],
    }
    resp = requests.put(
        f"{BASE_URL}/api/publish/v2/app-file-info",
        params={"appId": app_id},
        json=payload,
        headers={"client_id": client_id, "Authorization": f"Bearer {token}"},
    )
    resp.raise_for_status()
    data = resp.json()
    if data.get("ret", {}).get("code") != 0:
        raise RuntimeError(f"File info update error: {data}")
    print("Файл привязан к версии")

def submit_for_review(token: str, client_id: str, app_id: str) -> None:
    resp = requests.post(
        f"{BASE_URL}/api/publish/v2/app-submit",
        params={"appId": app_id},
        headers={"client_id": client_id, "Authorization": f"Bearer {token}"},
    )
    resp.raise_for_status()
    data = resp.json()
    if data.get("ret", {}).get("code") != 0:
        raise RuntimeError(f"Submit error: {data}")
    print("Отправлено на ревью!")

def main():
    parser = argparse.ArgumentParser(description="Деплой APK в AppGallery Connect")
    parser.add_argument(
        "apk",
        nargs="?",
        default=str(Path(__file__).parent.parent / "build/app/outputs/flutter-apk/app-release.apk"),
        help="Путь к APK файлу (default: build/app/outputs/flutter-apk/app-release.apk)",
    )
    parser.add_argument("--submit", action="store_true", help="Отправить на ревью после загрузки")
    parser.add_argument("--client-id", help="AGC Client ID (переопределяет env)")
    parser.add_argument("--client-secret", help="AGC Client Secret (переопределяет env)")
    parser.add_argument("--app-id", default="117440803", help="AGC App ID (default: 117440803)")
    parser.add_argument("--apk", dest="apk_flag", help="Путь к APK (альтернатива позиционному)")
    args = parser.parse_args()

    # CLI аргументы перекрывают env
    if args.client_id:
        os.environ["AGC_CLIENT_ID"] = args.client_id
    if args.client_secret:
        os.environ["AGC_CLIENT_SECRET"] = args.client_secret
    os.environ.setdefault("AGC_APP_ID", args.app_id)

    load_env()
    client_id = os.environ["AGC_CLIENT_ID"]
    client_secret = os.environ["AGC_CLIENT_SECRET"]
    app_id = os.environ["AGC_APP_ID"]

    # --apk флаг перекрывает позиционный аргумент
    if args.apk_flag:
        args.apk = args.apk_flag

    apk_path = Path(args.apk)
    if not apk_path.exists():
        print(f"Ошибка: APK не найден: {apk_path}")
        print("Сначала собери: flutter build apk --release")
        sys.exit(1)

    print(f"APK: {apk_path} ({apk_path.stat().st_size / 1024 / 1024:.1f} MB)")

    token = get_token(client_id, client_secret)
    upload_data = get_upload_url(token, client_id, app_id, apk_path.name)

    upload_url = upload_data["uploadUrl"]
    upload_result = upload_apk(upload_url, apk_path)

    file_dest_url = upload_result["result"]["UploadFileRsp"]["fileDestUlr"]
    update_file_info(token, client_id, app_id, file_dest_url, apk_path.name, apk_path.stat().st_size)

    if args.submit:
        submit_for_review(token, client_id, app_id)
        print("\nГотово! APK загружен и отправлен на ревью.")
    else:
        print("\nAPK загружен. Проверь версию в AGC консоли, внеси правки и отправляй на ревью вручную.")
        print("Для автоматической отправки: python scripts/deploy_agc.py --submit")

if __name__ == "__main__":
    main()
