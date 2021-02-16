from PIL import Image, ImageDraw
from flask import Flask, request

import requests

app = Flask(__name__)

@app.route("/outline", methods=["POST"])
def outline():

    # TODO:
    #  - Convert received image to RGBA
    #  - Figure out the circle drawing
    #  - Figure out how to convert the color to R,G,B,A
    #  - Place image in directory with a uuid or something, respond with full link to that file

    content = request.json
    image_url = content["avatarUrl"]
    outline_color = content["outlineColor"]

    avatar = Image.open(requests.get(image_url, stream=True).raw)

    x, y =  avatar.size
    eX, eY = 30, 60 #Size of Bounding Box for ellipse

    bbox =  (x/2 - eX/2, y/2 - eY/2, x/2 + eX/2, y/2 + eY/2)
    draw = ImageDraw.Draw(avatar)
    draw.ellipse(bbox, fill=(255,255,255,0), outline=(255,0,0,255), width=25)
    del draw
