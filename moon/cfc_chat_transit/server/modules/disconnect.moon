ChatTransit.PlayerDisconnected = (ply) =>
    avatar = ply.PlayerSummary.response.players[1].avatarfull

    @Send
        Type: "disconnect"
        Data:
            Avatar: avatar
            SteamName: ply\Nick!
            SteamId: ply\SteamID64!

hook.Add "PlayerDisconnected", "CFC_ChatTransit_DisconnectListener", ChatTransit\PlayerDisconnected
