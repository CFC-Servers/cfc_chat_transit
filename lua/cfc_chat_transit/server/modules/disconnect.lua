local guard = ChatTransit.guard
local GetBySteamID = player.GetBySteamID
local SteamIDTo64 = util.SteamIDTo64

ChatTransit.PlayerDisconnected = function(self, data)
    local name = data.name
    local reason = data.reason
    local steamId = data.networkid

    local ply = GetBySteamID(steamId)

    self:Send({
        Type = "disconnect",
        Data = {
            SteamName = ply and ply:Nick() or name,
            SteamId = ply and ply:SteamID64() or SteamIDTo64(steamId),
            PlayerCountCurrent = ChatTransit.playerCount,
            PlayerCountMax = game.MaxPlayers(),
            Content = reason,
        },
    })
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "CFC_ChatTransit_DisconnectListener", guard(function(...) return ChatTransit:PlayerDisconnected(...) end, 0))
