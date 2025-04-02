local delay, guard
do
  local _obj_0 = ChatTransit
  delay, guard = _obj_0.delay, _obj_0.guard
end
local SteamIDTo64
SteamIDTo64 = util.SteamIDTo64
ChatTransit.PlayerConnect = function(self, data)
  local bot, name, steamId
  bot, name, steamId = data.bot, data.name, data.networkid
  bot = tobool(bot)
  if bot then
    steamId = nil
  end
  return self:Send({
    Type = "connect",
    Data = {
      SteamName = name,
      SteamId = steamId and SteamIDTo64(steamId),
      PlayerCountCurrent = ChatTransit.playerCount,
      PlayerCountMax = game:MaxPlayers()
    }
  })
end
ChatTransit.PlayerInitialSpawn = function(self, ply)
  return self:Send({
    Type = "spawn",
    Data = {
      SteamName = ply:Nick(),
      SteamId = ply:SteamID64()
    }
  })
end
gameevent.Listen("player_connect")
hook.Add("player_connect", "CFC_ChatTransit_SpawnListener", guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.PlayerConnect
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)(), 0))
return hook.Add("PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.PlayerInitialSpawn
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)()))
