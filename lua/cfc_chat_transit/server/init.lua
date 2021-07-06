require("gwsockets")
require("cfclogger")
local lshift
lshift = bit.lshift
local Read
Read = file.Read
local GetColor
GetColor = team.GetColor
local TableToJSON
TableToJSON = util.TableToJSON
local Create, Exists, Remove, RepsLeft
do
  local _obj_0 = timer
  Create, Exists, Remove, RepsLeft = _obj_0.Create, _obj_0.Exists, _obj_0.Remove, _obj_0.RepsLeft
end
ChatTransit = { }
local readClean
readClean = function(fileName)
  local data = Read(fileName, "DATA")
  return string.gsub(data, "%s", "")
end
local RelayPort = readClean("cfc/cfc_relay_port.txt")
local RelayPassword = readClean("cfc/cfc_relay_password.txt")
local Realm = CreateConVar("cfc_realm", "", FCVAR_NONE, "CFC Realm Name")
ChatTransit.Logger = CFCLogger("CFC_ChatTransit")
ChatTransit.TeamColorCache = { }
ChatTransit.WebSocket = GWSockets.createWebSocket("ws://127.0.0.1:" .. tostring(RelayPort) .. "/relay")
do
  local _with_0 = ChatTransit.WebSocket
  local Logger = ChatTransit.Logger
  _with_0.reconnectTimerName = "CFC_ChatTransit_WebsocketReconnect"
  _with_0.onConnected = function(self)
    Logger:info("Established websocket connection")
    return Remove(_with_0.reconnectTimerName)
  end
  _with_0.onDisconnected = function(self)
    Logger:warn("Lost websocket connection!")
    if Exists(_with_0.reconnectTimerName) then
      return Logger:warn("Will retry " .. tostring(RepsLeft(_with_0.reconnectTimerName)) .. " more times")
    end
    return Create(_with_0.reconnectTimerName, 2, 30, function()
      return _with_0:open()
    end)
  end
  _with_0.onError = function(self, message)
    return Logger:error("Websocket Error!", message)
  end
  _with_0:open()
end
ChatTransit.GetTeamColor = function(self, teamName)
  if self.TeamColorCache[teamName] then
    return self.TeamColorCache[teamName]
  end
  local teamColor = tostring(GetColor(teamName))
  self.TeamColorCache[teamName] = teamColor
  return teamColor
end
ChatTransit.ReceiveMessage = function(self, ply, text, teamChat)
  if teamChat then
    return 
  end
  if not (text) then
    return 
  end
  if text == "" then
    return 
  end
  self.Logger:debug("Received message for " .. tostring(ply:Nick()) .. ", '" .. tostring(text) .. "'")
  local avatar = ply.PlayerSummary.response.players[1].avatarfull
  local steamName = ply:Nick()
  local steamId = ply:SteamID64()
  local irisId = "none"
  local struct = {
    Type = "message",
    Data = {
      Realm = Realm:GetString(),
      Type = "message",
      Content = text,
      Avatar = avatar,
      SteamName = steamName,
      SteamId = steamId,
      IrisId = irisId
    }
  }
  local message = TableToJSON(struct)
  self.WebSocket:write(message)
  return self.Logger:debug("Sent message '" .. tostring(text) .. "' to websocket")
end
ChatTransit.PlayerInitialSpawn = function(self, ply)
  local sendMessage
  sendMessage = function(attempts)
    if attempts == nil then
      attempts = 1
    end
    local avatar
    if attempts >= 5 then
      self.Logger:warn("PlayerSummary didn't exist in time to send an on-spawn message")
    else
      if ply.PlayerSummary then
        avatar = ply.PlayerSummary.response.players[1].avatarfull
      else
        return timer.Simple(2, function()
          return sendMessage(attempts + 1)
        end)
      end
    end
    local steamName = ply:Nick()
    local steamId = ply:SteamID64()
    local struct = {
      Type = "connect",
      Data = {
        Realm = Realm:GetString(),
        Avatar = avatar,
        SteamName = steamName,
        SteamId = steamId
      }
    }
    local message = TableToJSON(struct)
    return self.WebSocket:write(message)
  end
  return sendMessage()
end
ChatTransit.PlayerDisconnected = function(self, ply)
  local avatar = ply.PlayerSummary.response.players[1].avatarfull
  local steamName = ply:Nick()
  local steamId = ply:SteamID64()
  local struct = {
    Type = "disconnect",
    Data = {
      Realm = Realm:GetString(),
      Avatar = avatar,
      SteamName = steamName,
      SteamId = steamId
    }
  }
  local message = TableToJSON(struct)
  return self.WebSocket:write(message)
end
hook.Add("PlayerSay", "CFC_ChatTransit_MessageListener", (function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.ReceiveMessage
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)(), HOOK_MONITOR_LOW)
hook.Add("PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", (function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.PlayerInitialSpawn
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())
return hook.Add("PlayerDisconnected", "CFC_ChatTransit_DisconnectListener", (function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.PlayerDisconnected
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())
