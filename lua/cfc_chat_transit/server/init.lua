require("gwsockets")
require("logger")
ChatTransit = {
  Logger = Logger("ChatTransit")
}
include("cfc_chat_transit/server/avatar_service.lua")
include("cfc_chat_transit/server/player_count.lua")
ChatTransit.AvatarService = AvatarService(ChatTransit.Logger)
local Read
Read = file.Read
local GetColor
GetColor = team.GetColor
local TableToJSON
TableToJSON = util.TableToJSON
local logger = ChatTransit.Logger
local relayHost = CreateConVar("cfc_relay_host", "", FCVAR_NONE)
local secret = CreateConVar("cfc_relay_secret", "", FCVAR_NONE)
local loadHook = "ChatTransit_WebsocketLoad"
hook.Add("Think", loadHook, function()
  hook.Remove("Think", loadHook)
  ChatTransit.Realm = CreateConVar("cfc_realm", "unknown", FCVAR_REPLICATED + FCVAR_ARCHIVE, "The Realm Name")
  local address = "wss://" .. tostring(relayHost:GetString()) .. "/relay/" .. tostring(ChatTransit.Realm:GetString()) .. "/" .. tostring(secret:GetString())
  ChatTransit.WebSocket = GWSockets.createWebSocket(address, false)
  do
    local _with_0 = ChatTransit.WebSocket
    _with_0.reconnectTimerName = "CFC_ChatTransit_WebsocketReconnect"
    _with_0.onMessage = function(self, msg)
      if msg == "keepalive" then
        _with_0:write("keepalive")
        return 
      end
      local data = util.JSONToTable(msg)
      local messageType = data["message_type"]
      if messageType == "chat" then
        local author = data["sender_name"]
        local authorColor = data["color_rgb"]
        local content = data["content"]
        print("Broadcasting message", author, authorColor, content)
        ChatTransit.BroadcastMessage(author, authorColor, content)
      end
      return logger:info("Received unknown message type: msg")
    end
    _with_0.onConnected = function(self)
      logger:info("Established websocket connection")
      return timer.Remove(_with_0.reconnectTimerName)
    end
    _with_0.onDisconnected = function(self)
      logger:warn("Lost websocket connection!")
      if timer.Exists(_with_0.reconnectTimerName) then
        return logger:warn("Will retry " .. tostring(timer.RepsLeft(_with_0.reconnectTimerName)) .. " more times")
      end
      return timer.Create(_with_0.reconnectTimerName, 2, 30, function()
        return _with_0:open()
      end)
    end
    _with_0.onError = function(self, message)
      ErrorNoHalt("[ChatTransit] Websocket Error: " .. tostring(message))
      return logger:warn("Websocket Error!", message)
    end
    _with_0:open()
  end
  return nil
end)
ChatTransit.Send = function(self, data)
  hook.Run("CFC_ChatTransit_SendMessage", data)
  logger:debug("Sending '" .. tostring(data.Type) .. "'")
  local steamID64 = data.Data.SteamId
  data.Data.Avatar = data.Data.Avatar or ChatTransit.AvatarService:getAvatar(steamID64)
  data.Realm = self.Realm:GetString()
  data.Data.SteamId = data.Data.SteamId or ""
  return self.WebSocket:write(TableToJSON(data))
end
ChatTransit.GetRankColor = function(self, steamID, steamID64)
  local override = hook.Run("CFC_ChatTransit_GetPlayerColor", steamID, steamID64)
  if override then
    return tostring(override.r) .. " " .. tostring(override.g) .. " " .. tostring(override.b) .. " 255"
  end
  local user = ULib.ucl.users[steamID]
  local groupName = user and user.group or "user"
  local team = ULib.ucl.groups[groupName].team
  if team then
    return tostring(team.color_red) .. " " .. tostring(team.color_green) .. " " .. tostring(team.color_blue) .. " 255"
  end
  return "255 255 0 255"
end
ChatTransit.guard = function(f, delay)
  return function(...)
    local args = {
      ...
    }
    local action
    action = function()
      local success, err = pcall(function()
        return f(unpack(args))
      end)
      if not (success) then
        return ErrorNoHaltWithStack(err)
      end
    end
    if delay then
      timer.Simple(delay, action)
    else
      action()
    end
    return nil
  end
end
hook.Add("ShutDown", "CFC_ChatTransit_WebsocketDisconnect", function()
  logger:info("Gracefully closing websocket..")
  ProtectedCall(function()
    return ChatTransit.WebSocket:closeNow()
  end)
  return nil
end)
logger:info("Loading modules...")
local _list_0 = file.Find("cfc_chat_transit/server/modules/*.lua", "LUA")
for _index_0 = 1, #_list_0 do
  local f = _list_0[_index_0]
  logger:info("Loading modules/" .. tostring(f))
  include("modules/" .. tostring(f))
end
