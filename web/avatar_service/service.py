from PIL import Image, ImageDraw
from flask import Flask, request, send_file
import os.path

import requests

app = Flask(__name__)

transparent = (0, 0, 0, 0)

base_url = "https://avatarservice.cfcservers.org"

@app.route("/outline", methods=["POST"])
def outline():
    content = request.json
    image_url = content["avatarUrl"]

    image_name = image_url.split("/")[-1] #"example.jpg"
    image_name = image_name.split(".")[0] #"example"

    avatar_path = f"/avatars/{image_name}.png"

    if os.path.isfile(avatar_path):
        return f"{base_url}{avatar_path}"

    outline_color = content["outlineColor"] # "255 255 255 255"
    outline_color = outline_color.split(" ") # ["255", "255", "255", "255"]
    outline_color = [int(c) for c in outline_color] # [255, 255, 255, 255]
    outline_color = tuple(outline_color) # (255, 255, 255, 255)

    avatar = Image.open(requests.get(image_url, stream=True).raw)

    x, y =  avatar.size
    bbox = (0, 0, x, y)
    draw = ImageDraw.Draw(avatar, "RGBA")
    draw.ellipse(bbox, fill=transparent, outline=outline_color, width=8)
    del draw

    avatar.save(avatar_path, "PNG")

    return f"{base_url}{avatar_path}"
