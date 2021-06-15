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
    gsub data, "%s", ""

RelayPort = readClean "cfc/cfc_relay_port.txt"
RelayPassword = readClean "cfc/cfc_relay_password.txt"
Realm = readClean "cfc/realm.txt"

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

    teamName = ply\Team!
    avatar = ply.PlayerSummary.response.players[1].avatarfull
    steamName = ply\Nick!
    steamId = ply\SteamID64!
    irisId = "none"

    struct =
        Type: "message"
        data:
            Realm: Realm
            Type: "message"
            Content: text
            Avatar: avatar
            SteamName: steamName
            SteamId: steamId
            IrisId: irisId

    message = TableToJSON struct

    @WebSocket\write message

    @Logger\debug "Sent message '#{text}' to websocket"

ChatTransit.PlayerConnected = (data) =>
    steamName = data.name
    steamId = data.networkid

    struct =
        Type: "connect"
        data:
            Realm: Realm
            SteamName: steamName
            SteamId: steamId

    message = TableToJSON struct

    @WebSocket\write message

ChatTransit.PlayerDisconnected = (ply) =>
    steamName = data.name
    steamId = data.networkid

    struct =
        Type: "disconnect"
        data:
            Realm: Realm
            SteamName: steamName
            SteamId: steamId

    message = TableToJSON struct

    @WebSocket\write message

gameevent.Listen "player_connect"
gameevent.Listen "player_disconnect"

hook.Add "PlayerSay", "CFC_ChatTransit_MessageListener", ChatTransit\ReceiveMessage, HOOK_MONITOR_LOW
hook.Add "player_connect", "CFC_ChatTransit_ConnectListener", ChatTransit\PlayerConnected
hook.Add "player_disconnect", "CFC_ChatTransit_DisconnectListener", ChatTransit\PlayerDisconnected
