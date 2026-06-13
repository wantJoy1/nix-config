"""Pixiv 作品をブックマーク (private + R-18 タグ)"""

import hashlib
import json
import os
import sys
import urllib.request
import urllib.parse
from datetime import datetime, timedelta, timezone
from pathlib import Path

import gallery_dl.config

CLIENT_ID = "MOBrBDS8blbauoSck0ZfDbtuzpyT"
CLIENT_SECRET = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj"
HASH_SECRET = (
    "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c"
)
TOKEN_CACHE = Path.home() / ".cache" / "gallery-dl" / "access_token.json"
TAG = os.environ.get("PIXIV_BOOKMARK_TAG", "")

HEADERS = {
    "App-OS": "ios",
    "App-OS-Version": "16.7.2",
    "App-Version": "7.19.1",
    "User-Agent": "PixivIOSApp/7.19.1 (iOS 16.7.2; iPhone12,8)",
    "Referer": "https://app-api.pixiv.net/",
}


def get_refresh_token() -> str:
    gallery_dl.config.load()
    token = gallery_dl.config.get(("extractor", "pixiv"), "refresh-token")
    if not token:
        raise RuntimeError("'refresh-token' not found in gallery-dl config")
    return token


def get_access_token() -> str:
    if TOKEN_CACHE.exists():
        with open(TOKEN_CACHE) as f:
            cached = json.load(f)
        expires_at = datetime.fromisoformat(cached["expires_at"])
        if expires_at > datetime.now(timezone.utc):
            return cached["access_token"]

    refresh_token = get_refresh_token()
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S+00:00")
    client_hash = hashlib.md5(f"{now}{HASH_SECRET}".encode()).hexdigest()

    body = urllib.parse.urlencode({
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "refresh_token",
        "refresh_token": refresh_token,
        "get_secure_url": "1",
    }).encode()

    headers = {
        **HEADERS,
        "X-Client-Time": now,
        "X-Client-Hash": client_hash,
        "Content-Type": "application/x-www-form-urlencoded",
    }

    req = urllib.request.Request(
        "https://oauth.secure.pixiv.net/auth/token",
        data=body,
        headers=headers,
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read())

    access_token = data["response"]["access_token"]
    expires_at = (
        datetime.now(timezone.utc) + timedelta(minutes=50)
    ).isoformat()

    TOKEN_CACHE.parent.mkdir(parents=True, exist_ok=True)
    with open(TOKEN_CACHE, "w") as f:
        json.dump({"access_token": access_token, "expires_at": expires_at}, f)

    return access_token


def bookmark(illust_id: int) -> dict:
    access_token = get_access_token()

    body = urllib.parse.urlencode({
        "illust_id": str(illust_id),
        "restrict": "private",
        "tags[]": TAG,
    }).encode()

    headers = {
        **HEADERS,
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/x-www-form-urlencoded",
    }

    req = urllib.request.Request(
        "https://app-api.pixiv.net/v2/illust/bookmark/add",
        data=body,
        headers=headers,
        method="POST",
    )
    try:
        with urllib.request.urlopen(req) as resp:
            status = resp.status
    except urllib.error.HTTPError as e:
        status = e.code

    return {"illust_id": illust_id, "status": status, "ok": status == 200}


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <illust_id>", file=sys.stderr)
        sys.exit(1)
    result = bookmark(int(sys.argv[1]))
    print(json.dumps(result))
    sys.exit(0 if result["ok"] else 1)
