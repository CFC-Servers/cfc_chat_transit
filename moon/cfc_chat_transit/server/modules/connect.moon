import guard from ChatTransit
import SteamIDTo64 from util
-- TODO: Send a preliminary avatarservice link that will be backfilled when they fully connect

ChatTransit.PlayerConnect = (data) =>
    :bot, :name, networkid: steamId = data

    bot = tobool bot
    steamId = nil if bot

    @Send
        Type: "connect"
        Data:
            SteamName: name
            SteamId: SteamIDTo64 steamId if steamId

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
                delay = 2 + ( attempts * 2 )
                return timer.Simple delay, -> sendMessage attempts + 1

        @Send
            Type: "spawn"
            Data:
                Avatar: avatar
                SteamName: ply\Nick!
                SteamId: ply\SteamID64!

    sendMessage!

gameevent.Listen "player_connect"
hook.Add "player_connect", "CFC_ChatTransit_SpawnListener", guard ChatTransit\PlayerConnect
hook.Add "PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", guard ChatTransit\PlayerInitialSpawn
