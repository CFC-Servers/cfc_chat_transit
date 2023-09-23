require "gwsockets"
require "logger"

export ChatTransit = { Logger: Logger "ChatTransit" }
include "cfc_chat_transit/server/avatar_service.lua"
include "cfc_chat_transit/server/player_count.lua"

import Read from file
import GetColor from team
import TableToJSON from util

logger = ChatTransit.Logger
relayHost = CreateConVar "cfc_relay_host", "", FCVAR_NONE

loadHook = "ChatTransit_WebsocketLoad"
hook.Add "Think", loadHook, ->
    hook.Remove "Think", loadHook

    ChatTransit.WebSocket = GWSockets.createWebSocket "wss://#{relayHost\GetString!}/relay", false
    ChatTransit.Realm = CreateConVar "cfc_realm", "unknown", FCVAR_REPLICATED + FCVAR_ARCHIVE, "The Realm Name"

    with ChatTransit.WebSocket
        .reconnectTimerName = "CFC_ChatTransit_WebsocketReconnect"

        .onMessage = (msg) =>
            if msg ~= "keepalive"
                logger\info "Received a not-keepalive message from the server:", msg
                return

            \write "keepalive"

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
    logger\debug "Sending '#{data.Type}'"
    steamID64 = data.Data.SteamId

    data.Data.Avatar or= ChatTransit.AvatarService\getAvatar steamID64
    data.Realm = @Realm\GetString!
    data.Data.SteamId or= ""

    @WebSocket\write TableToJSON data

ChatTransit.GetRankColor = (ply) =>
    override = hook.Run "CFC_ChatTransit_GetPlayerColor", ply
    if override
        return "#{override.r} #{override.g} #{override.b} 255"

    user = ULib.ucl.users[ply\SteamID!]
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
