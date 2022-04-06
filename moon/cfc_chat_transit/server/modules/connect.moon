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
    @Send
        Type: "spawn"
        Data:
            SteamName: ply\Nick!
            SteamId: ply\SteamID64!
            PlayerCountCurrent: player\GetCount!
            PlayerCountMax: game\MaxPlayers!

gameevent.Listen "player_connect"
hook.Add "player_connect", "CFC_ChatTransit_SpawnListener", guard ChatTransit\PlayerConnect
hook.Add "PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", guard ChatTransit\PlayerInitialSpawn
