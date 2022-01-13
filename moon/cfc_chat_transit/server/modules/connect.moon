ChatTransit.PlayerAuthed = (ply, steamid) =>
    steamName = ply\Nick!
    struct =
        Type: "connect"
        Data:
            SteamName: steamName
            SteamId: steamid

    message = TableToJSON struct
    @WebSocket\write message

ChatTransit.PlayerInitialSpawn = (ply) =>
    sendMessage = (attempts=1) ->
        local avatar

        if attempts >= 5
            @Logger\warn "PlayerSummary didn't exist in time to send an on-spawn message"
        else
            if ply.PlayerSummary
                avatar = ply.PlayerSummary.response.players[1].avatarfull
            else
                return timer.Simple 2, -> sendMessage(attempts + 1)

        steamName = ply\Nick!
        steamId = ply\SteamID64!

        struct =
            Type: "spawn"
            Data:
                Realm: Realm\GetString!
                Avatar: avatar
                SteamName: steamName
                SteamId: steamId

        message = TableToJSON struct
        @WebSocket\write message

    sendMessage!

hook.Add "PlayerAuthed", "CFC_ChatTransit_SpawnListener", ChatTransit\PlayerAuthed
hook.Add "PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", ChatTransit\PlayerInitialSpawn
