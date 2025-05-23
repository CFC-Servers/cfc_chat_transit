require "gwsockets"
require "logger"

export ChatTransit = { Logger: Logger "ChatTransit" }
include "cfc_chat_transit/server/avatar_service.lua"
include "cfc_chat_transit/server/player_count.lua"
ChatTransit.AvatarService = AvatarService ChatTransit.Logger

import Read from file
import GetColor from team
import TableToJSON from util

logger = ChatTransit.Logger
relayHost = CreateConVar "cfc_relay_host", "", FCVAR_NONE
secret = CreateConVar "cfc_relay_secret", "", FCVAR_NONE

loadHook = "ChatTransit_WebsocketLoad"
hook.Add "Think", loadHook, ->
    hook.Remove "Think", loadHook

    ChatTransit.Realm = CreateConVar "cfc_realm", "unknown", FCVAR_REPLICATED + FCVAR_ARCHIVE, "The Realm Name"

    address = "wss://#{relayHost\GetString!}/relay/#{ChatTransit.Realm\GetString!}/#{secret\GetString!}"
    ChatTransit.WebSocket = GWSockets.createWebSocket address, false

    with ChatTransit.WebSocket
        .reconnectTimerName = "CFC_ChatTransit_WebsocketReconnect"

        .onMessage = (msg) =>
            if msg == "keepalive"
                \write "keepalive"
                return

            data = util.JSONToTable msg
            messageType = data["message_type"]

            if messageType == "chat"
                author = data["sender_name"]
                authorColor = data["color_rgb"]
                content = data["content"]

                print "Broadcasting message", author, authorColor, content
                ChatTransit.BroadcastMessage author, authorColor, content

            logger\info "Received unknown message type: msg"

        .onConnected = =>
            logger\info "Established websocket connection"
            timer.Remove .reconnectTimerName

        .onDisconnected = =>
            logger\warn "Lost websocket connection!"

            if timer.Exists .reconnectTimerName
                return logger\warn "Will retry #{timer.RepsLeft .reconnectTimerName} more times"

            timer.Create .reconnectTimerName, 2, 30, -> \open!

        .onError = (message) =>
            ErrorNoHalt "[ChatTransit] Websocket Error: #{message}"
            logger\warn "Websocket Error!", message

        \open!

    return nil

ChatTransit.Send = (data) =>
    hook.Run "CFC_ChatTransit_SendMessage", data

    logger\debug "Sending '#{data.Type}'"
    steamID64 = data.Data.SteamId

    data.Data.Avatar or= ChatTransit.AvatarService\getAvatar steamID64
    data.Realm = @Realm\GetString!
    data.Data.SteamId or= ""

    @WebSocket\write TableToJSON data

ChatTransit.GetRankColor = (steamID, steamID64) =>
    override = hook.Run "CFC_ChatTransit_GetPlayerColor", steamID, steamID64
    if override
        return "#{override.r} #{override.g} #{override.b} 255"

    user = ULib.ucl.users[steamID]
    groupName = user and user.group or "user"

    team = ULib.ucl.groups[groupName].team

    return "#{team.color_red} #{team.color_green} #{team.color_blue} 255" if team
    return "255 255 0 255"

ChatTransit.guard = (f, delay) -> (...) ->
    args = {...}

    action = ->
        success, err = pcall -> f unpack args
        ErrorNoHaltWithStack err unless success

    if delay
        timer.Simple delay, action
    else
        action!

    return nil

hook.Add "ShutDown", "CFC_ChatTransit_WebsocketDisconnect", ->
    logger\info "Gracefully closing websocket.."
    ProtectedCall -> ChatTransit.WebSocket\closeNow!
    return nil

logger\info "Loading modules..."
for f in *file.Find "cfc_chat_transit/server/modules/*.lua", "LUA"
    logger\info "Loading modules/#{f}"
    include "modules/#{f}"
