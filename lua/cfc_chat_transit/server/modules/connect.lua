local guard = ChatTransit.guard
local SteamIDTo64 = util.SteamIDTo64
-- TODO: Send a preliminary avatarservice link that will be backfilled when they fully connect

ChatTransit.PlayerConnect = function(self, data)
    local bot = data.bot
    local name = data.name
    local steamId = data.networkid

    bot = tobool(bot)
    if bot then steamId = nil end

    self:Send({
        Type = "connect",
        Data = {
            SteamName = name,
            SteamId = steamId and SteamIDTo64(steamId),
            PlayerCountCurrent = ChatTransit.playerCount,
            PlayerCountMax = game.MaxPlayers(),
        },
    })
end

ChatTransit.PlayerInitialSpawn = function(self, ply)
    self:Send({
        Type = "spawn",
        Data = {
            SteamName = ply:Nick(),
            SteamId = ply:SteamID64(),
        },
    })
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "CFC_ChatTransit_SpawnListener", guard(function(...) return ChatTransit:PlayerConnect(...) end, 0))
hook.Add("PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", guard(function(...) return ChatTransit:PlayerInitialSpawn(...) end))
