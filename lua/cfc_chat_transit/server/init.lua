require("gwsockets")
require("logger")

ChatTransit = { Logger = Logger("ChatTransit") }
include("cfc_chat_transit/server/avatar_service.lua")
include("cfc_chat_transit/server/player_count.lua")
ChatTransit.AvatarService = AvatarService(ChatTransit.Logger)

local Read = file.Read
local GetColor = team.GetColor
local TableToJSON = util.TableToJSON

local logger = ChatTransit.Logger
local relayHost = CreateConVar("cfc_relay_host", "", FCVAR_NONE)
local secret = CreateConVar("cfc_relay_secret", "", FCVAR_NONE)

local loadHook = "ChatTransit_WebsocketLoad"
hook.Add("Think", loadHook, function()
    hook.Remove("Think", loadHook)

    ChatTransit.Realm = CreateConVar("cfc_realm", "unknown", FCVAR_REPLICATED + FCVAR_ARCHIVE, "The Realm Name")

    local address = "wss://" .. relayHost:GetString() .. "/relay/" .. ChatTransit.Realm:GetString() .. "/" .. secret:GetString()
    ChatTransit.WebSocket = GWSockets.createWebSocket(address, false)

    local ws = ChatTransit.WebSocket
    ws.reconnectTimerName = "CFC_ChatTransit_WebsocketReconnect"

    ws.onMessage = function(self, msg)
        if msg == "keepalive" then
            self:write("keepalive")
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

        logger:info("Received unknown message type: msg")
    end

    ws.onConnected = function(self)
        logger:info("Established websocket connection")
        timer.Remove(self.reconnectTimerName)
    end

    ws.onDisconnected = function(self)
        logger:warn("Lost websocket connection!")

        if timer.Exists(self.reconnectTimerName) then
            return logger:warn("Will retry " .. tostring(timer.RepsLeft(self.reconnectTimerName)) .. " more times")
        end

        timer.Create(self.reconnectTimerName, 2, 30, function()
            ws:open()
        end)
    end

    ws.onError = function(self, message)
        ErrorNoHalt("[ChatTransit] Websocket Error: " .. tostring(message))
        logger:warn("Websocket Error!", message)
    end

    ws:open()

    return nil
end)

ChatTransit.Send = function(self, data)
    hook.Run("CFC_ChatTransit_SendMessage", data)

    logger:debug("Sending '" .. tostring(data.Type) .. "'")
    local steamID64 = data.Data.SteamId

    data.Data.Avatar = data.Data.Avatar or ChatTransit.AvatarService:getAvatar(steamID64)
    data.Realm = self.Realm:GetString()
    data.Data.SteamId = data.Data.SteamId or ""

    self.WebSocket:write(TableToJSON(data))
end

ChatTransit.GetRankColor = function(self, steamID, steamID64)
    local override = hook.Run("CFC_ChatTransit_GetPlayerColor", steamID, steamID64)
    if override then
        return override.r .. " " .. override.g .. " " .. override.b .. " 255"
    end

    local user = ULib.ucl.users[steamID]
    local groupName = user and user.group or "user"

    local team = ULib.ucl.groups[groupName].team

    if team then
        return team.color_red .. " " .. team.color_green .. " " .. team.color_blue .. " 255"
    end
    return "255 255 0 255"
end

ChatTransit.guard = function(f, delay)
    return function(...)
        local args = {...}

        local action = function()
            local success, err = pcall(function() f(unpack(args)) end)
            if not success then
                ErrorNoHaltWithStack(err)
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
    ProtectedCall(function() ChatTransit.WebSocket:closeNow() end)
    return nil
end)

logger:info("Loading modules...")
for _, f in ipairs(file.Find("cfc_chat_transit/server/modules/*.lua", "LUA")) do
    logger:info("Loading modules/" .. f)
    include("modules/" .. f)
end
