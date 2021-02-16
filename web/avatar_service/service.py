from PIL import Image, ImageDraw
from flask import Flask, request

import requests

app = Flask(__name__)

transparent = (255, 255, 255, 0)

@app.route("/outline", methods=["POST"])
def outline():

    # TODO:
    #  - Convert received image to RGBA
    #  - Figure out the circle drawing
    #  - Place image in directory with a uuid or something, respond with full link to that file

    content = request.json
    image_url = content["avatarUrl"]

    outline_color = content["outlineColor"] # "255 255 255 255"
    outline_color = outline_color.split(" ") # [255, 255, 255, 255]
    outline_color = tuple(outline_color) # (255, 255, 255, 255)

    avatar = Image.open(requests.get(image_url, stream=True).raw)

    x, y =  avatar.size
    eX, eY = 30, 60 #Size of Bounding Box for ellipse

    bbox = (x/2 - eX/2, y/2 - eY/2, x/2 + eX/2, y/2 + eY/2)
    draw = ImageDraw.Draw(avatar)
    draw.ellipse(bbox, fill=transparent, outline=outline_color, width=25)
    del draw
