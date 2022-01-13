require "gwsockets"
require "logger"

import Read from file
import GetColor from team
import TableToJSON from util
export ChatTransit = {}

readClean = (fileName) ->
    data = Read fileName, "DATA"
    string.gsub data, "%s", ""

RelayPort = readClean "cfc/cfc_relay_port.txt"
RelayPassword = readClean "cfc/cfc_relay_password.txt"

ChatTransit.Logger = Logger "CFC_ChatTransit"
ChatTransit.WebSocket = GWSockets.createWebSocket "ws://127.0.0.1:#{RelayPort}/relay"
ChatTransit.Realm = CreateConVar "cfc_realm", "", FCVAR_NONE, "CFC Realm Name"

logger = ChatTransit.Logger

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

ChatTransit.Send = (data) =>
    @logger\info "Sending '#{data.Type}'"
    data.Realm = @Realm\GetString!

    @WebSocket\write TableToJSON data

ChatTransit.TeamColorCache = {}
ChatTransit.GetTeamColor = (teamName) =>
    return @TeamColorCache[teamName] if @TeamColorCache[teamName]

    teamColor = tostring GetColor teamName

    @TeamColorCache[teamName] = teamColor

    teamColor

logger\info "Loading modules..."
for f in *file.Find "cfc_chat_transit/server/modules/*.lua", "LUA"
    logger\info "Loading #{f}"
    include f
