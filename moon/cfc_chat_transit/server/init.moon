require "gwsockets"
require "cfclogger"

import lshift from bit
import Read from file
import GetColor from team
import TableToJSON from util
import Create, Exists, Remove, RepsLeft from timer
export ChatTransit = {}

readClean = (fileName) ->
    data = Read fileName, "DATA"
    string.gsub data, "%s", ""

RelayPort = readClean "cfc/cfc_relay_port.txt"
RelayPassword = readClean "cfc/cfc_relay_password.txt"
Realm = CreateConVar "cfc_realm", "", FCVAR_NONE, "CFC Realm Name"

ChatTransit.Logger = CFCLogger "CFC_ChatTransit"
ChatTransit.TeamColorCache = {}
ChatTransit.WebSocket = GWSockets.createWebSocket "ws://127.0.0.1:#{RelayPort}/relay"

with ChatTransit.WebSocket
    Logger = ChatTransit.Logger
    .reconnectTimerName = "CFC_ChatTransit_WebsocketReconnect"

    .onConnected = =>
        Logger\info "Established websocket connection"
        Remove .reconnectTimerName

    .onDisconnected = =>
        Logger\warn "Lost websocket connection!"

        if Exists .reconnectTimerName
            return Logger\warn "Will retry #{RepsLeft .reconnectTimerName} more times"

        Create .reconnectTimerName, 2, 30, -> \open!

    .onError = (message) => Logger\error "Websocket Error!", message

    \open!

ChatTransit.GetTeamColor = (teamName) =>
    return @TeamColorCache[teamName] if @TeamColorCache[teamName]

    teamColor = tostring GetColor teamName

    @TeamColorCache[teamName] = teamColor

    teamColor

ChatTransit.ReceiveMessage = (ply, text, teamChat) =>
    return if teamChat
    return unless text
    return if text == ""

    @Logger\debug "Received message for #{ply\Nick!}, '#{text}'"

    avatar = ply.PlayerSummary.response.players[1].avatarfull
    steamName = ply\Nick!
    steamId = ply\SteamID64!
    irisId = "none"

    struct =
        Type: "message"
        Data:
            Realm: Realm\GetString!
            Type: "message"
            Content: text
            Avatar: avatar
            SteamName: steamName
            SteamId: steamId
            IrisId: irisId

    message = TableToJSON struct

    @WebSocket\write message

    @Logger\debug "Sent message '#{text}' to websocket"

ChatTransit.PlayerInitialSpawn = (ply) =>
    sendMessage = (attempts=1) ->
        if attempts >= 5
            @Logger\warn "PlayerSummary didn't exist in time to send an on-spawn message"
        else
            if not ply.PlayerSummary
                return timer.Simple 2, -> sendMessage(attempts + 1)

        avatar = ply.PlayerSummary.response.players[1].avatarfull
        steamName = ply\Nick!
        steamId = ply\SteamID64!

        struct =
            Type: "connect"
            Data:
                Realm: Realm\GetString!
                Avatar: avatar
                SteamName: steamName
                SteamId: steamId

        message = TableToJSON struct

        @WebSocket\write message

ChatTransit.PlayerDisconnected = (data) =>
    avatar = ply.PlayerSummary.response.players[1].avatarfull
    steamName = ply\Nick!
    steamId = ply\SteamID64!

    struct =
        Type: "disconnect"
        Data:
            Realm: Realm\GetString!
            Avatar: avatar
            SteamName: steamName
            SteamId: steamId

    message = TableToJSON struct

    @WebSocket\write message

hook.Add "PlayerSay", "CFC_ChatTransit_MessageListener", ChatTransit\ReceiveMessage, HOOK_MONITOR_LOW
hook.Add "PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", ChatTransit\PlayerInitialSpawn
hook.Add "PlayerDisconnected", "CFC_ChatTransit_DisconnectListener", ChatTransit\PlayerDisconnected
