local delay, guard
do
  local _obj_0 = ChatTransit
  delay, guard = _obj_0.delay, _obj_0.guard
end
local GetBySteamID
GetBySteamID = player.GetBySteamID
local SteamIDTo64
SteamIDTo64 = util.SteamIDTo64
ChatTransit.PlayerDisconnected = function(self, data)
  local name, reason, steamId
  name, reason, steamId = data.name, data.reason, data.networkid
  local ply = GetBySteamID(steamId)
  return self:Send({
    Type = "disconnect",
    Data = {
      SteamName = ply and ply:Nick() or name,
      SteamId = ply and ply:SteamID64() or SteamIDTo64(steamId),
      PlayerCountCurrent = ChatTransit.playerCount,
      PlayerCountMax = game:MaxPlayers(),
      Content = reason
    }
  })
end
gameevent.Listen("player_disconnect")
return hook.Add("player_disconnect", "CFC_ChatTransit_DisconnectListener", guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.PlayerDisconnected
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)(), 0))
