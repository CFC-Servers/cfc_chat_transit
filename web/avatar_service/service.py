from PIL import Image, ImageDraw
from flask import Flask, request
import os

import requests

app = Flask(__name__)

TRANSPARENT = (0, 0, 0, 0)
base_url = os.getenv("AVATAR_SERVICE_URL")


@app.route("/outline", methods=["POST"])
def outline() -> str:
    content = request.json
    realm = content["realm"]
    steam_id = content["steamID"]

    avatar_path = f"/avatars/{realm}/{steam_id}.png"

    if os.path.isfile(avatar_path):
        os.remove(avatar_path)

    outline_color = content["outlineColor"]  # "255 255 255 255"
    outline_color = outline_color.split(" ")  # ["255", "255", "255", "255"]
    outline_color = [int(c) for c in outline_color]  # [255, 255, 255, 255]
    outline_color = tuple(outline_color)  # (255, 255, 255, 255)

    image_url = content["avatarUrl"]
    raw_image = requests.get(image_url, stream=True).raw
    avatar = Image.open(raw_image).convert("RGB")

    x, y = avatar.size
    bbox = (0, 0, x, y)
    draw = ImageDraw.Draw(avatar, "RGBA")
    draw.ellipse(bbox, fill=TRANSPARENT, outline=outline_color, width=12)
    del draw

    avatar.save(avatar_path, "PNG")

    return f"{base_url}{avatar_path}"
