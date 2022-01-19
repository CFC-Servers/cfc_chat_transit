ChatTransit.PlayerAuthed = (ply, steamId) =>
    @Send
        Type: "connect"
        Data:
            SteamName: ply\Nick!
            SteamId: steamId

ChatTransit.PlayerInitialSpawn = (ply) =>
    sendMessage = (attempts=1) ->
        local avatar

        if attempts >= 5
            @Logger\warn "PlayerSummary didn't exist in time to send an on-spawn message"
        else
            summary = ply.SteamLookup and ply.SteamLookup.PlayerSummary

            if summary
                avatar = summary.response.players[1].avatarfull
            else
                return timer.Simple 2 + attempts, -> sendMessage(attempts + 1)

        @Send
            Type: "spawn"
            Data:
                Avatar: avatar
                SteamName: ply\Nick!
                SteamId: ply\SteamID64!

    sendMessage!

hook.Add "PlayerAuthed", "CFC_ChatTransit_SpawnListener", ChatTransit\PlayerAuthed
hook.Add "PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", ChatTransit\PlayerInitialSpawn
