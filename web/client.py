import asyncio
import websockets
import json

message = json.dumps({
    "content": "Message content",
    "realm": "CFC3",
    "rankColor": "16711680",
    "avatar": "https://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/c3/c3364b63359c0c8d0c1b3cca74eb5768e533b366_full.jpg",
    "steamName": "Phatso",
    "steamId": "1234567890",
    "irisId": "09876"
})

async def hello():
    uri = "ws://0.0.0.0:5050/relay"

    async with websockets.connect(uri) as websocket:
        await websocket.send(message)
        print(f"> {message}")

        greeting = await websocket.recv()
        print(f"< {greeting}")

asyncio.get_event_loop().run_until_complete(hello())
