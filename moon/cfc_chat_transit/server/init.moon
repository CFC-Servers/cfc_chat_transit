require "gwsockets"
require "logger"

export ChatTransit = { Logger: Logger "ChatTransit" }
include "cfc_chat_transit/server/avatar_service.lua"
include "cfc_chat_transit/server/player_count.lua"

import Read from file
import GetColor from team
import TableToJSON from util

logger = ChatTransit.Logger

loadHook = "ChatTransit_WebsocketLoad"
hook.Add "Think", loadHook, ->
    hook.Remove "Think", loadHook

    ChatTransit.WebSocket = GWSockets.createWebSocket "wss://cfc3_relay.cfcservers.org/relay"
    ChatTransit.Realm = CreateConVar "cfc_realm", "unknown", FCVAR_REPLICATED + FCVAR_ARCHIVE, "The Realm Name"

    with ChatTransit.WebSocket
        .reconnectTimerName = "CFC_ChatTransit_WebsocketReconnect"

        .onConnected = =>
            logger\info "Established websocket connection"
            timer.Remove .reconnectTimerName

        .onDisconnected = =>
            logger\warn "Lost websocket connection!"

            if timer.Exists .reconnectTimerName
                return logger\warn "Will retry #{timer.RepsLeft .reconnectTimerName} more times"

            timer.Create .reconnectTimerName, 2, 30, -> \open!

        .onError = (message) => logger\error "Websocket Error!", message

        \open!

    return nil

ChatTransit.Send = (data) =>
    logger\debug "Sending '#{data.Type}'"
    steamID64 = data.Data.SteamId

    data.Data.Avatar or= ChatTransit.AvatarService\getAvatar steamID64
    data.Realm = @Realm\GetString!
    data.Data.SteamId or= ""

    @WebSocket\write TableToJSON data

ChatTransit.TeamColorCache = {}
ChatTransit.GetTeamColor = (teamName) =>
    return @TeamColorCache[teamName] if @TeamColorCache[teamName]

    teamColor = tostring GetColor teamName

    @TeamColorCache[teamName] = teamColor

    teamColor

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

logger\info "Loading modules..."
for f in *file.Find "cfc_chat_transit/server/modules/*.lua", "LUA"
    logger\info "Loading modules/#{f}"
    include "modules/#{f}"
