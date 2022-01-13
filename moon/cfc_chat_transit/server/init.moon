require "gwsockets"
require "logger"

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

ChatTransit.Logger = Logger "CFC_ChatTransit"
ChatTransit.WebSocket = GWSockets.createWebSocket "ws://127.0.0.1:#{RelayPort}/relay"

logger = ChatTransit.Logger

with ChatTransit.WebSocket
    .reconnectTimerName = "CFC_ChatTransit_WebsocketReconnect"

    .onConnected = =>
        logger\info "Established websocket connection"
        Remove .reconnectTimerName

    .onDisconnected = =>
        logger\warn "Lost websocket connection!"

        if Exists .reconnectTimerName
            return logger\warn "Will retry #{RepsLeft .reconnectTimerName} more times"

        Create .reconnectTimerName, 2, 30, -> \open!

    .onError = (message) => logger\error "Websocket Error!", message

    \open!

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
