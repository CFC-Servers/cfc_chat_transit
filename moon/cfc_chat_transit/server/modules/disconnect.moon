ChatTransit.PlayerDisconnected = (ply) =>
    avatar = ply.PlayerSummary.response.players[1].avatarfull
    steamName = ply\Nick!
    steamId = ply\SteamID64!

    struct =
        Type: "disconnect"
        Data:
            Realm: Realm\GetString!
            Avatar: avatar
            SteamName: steamName
            SteamId: steamId

    message = TableToJSON struct

    @WebSocket\write message

hook.Add "PlayerDisconnected", "CFC_ChatTransit_DisconnectListener", ChatTransit\PlayerDisconnected
