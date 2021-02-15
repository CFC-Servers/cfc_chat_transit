require "gwsockets"
require "cfclogger"

import lshift from bit

Logger = CFCLogger "CFC_ChatTransit"

RelayPort = file.Read "cfc/cfc_relay_port.txt", "DATA"
RelayPort = string.Replace RelayPort, "\r", ""
RelayPort = string.Replace RelayPort, "\n", ""

RelayPassword = file.Read "cfc/cfc_relay_password.txt", "DATA"
RelayPassword = string.Replace RelayPassword, "\r", ""
RelayPassword = string.Replace RelayPassword, "\n", ""

Realm = file.Read "cfc/realm.txt", "DATA"
Realm = string.Replace Realm, "\r", ""
Realm = string.Replace Realm, "\n", ""

local WebSocket

hook.Add "PostEntityInit", "CFC_ChatTransit_WSInit", ->
    with WebSocket = GWSockets.createWebSocket "ws://127.0.0.1#{RelayPort}"
        \setHeader "Authorization", "Bearer #{RelayPassword}"
        \onConnected -> Logger\info "Established websocket connection"
        \onDisconnected -> Logger\warn "Lost websocket connection!"
        \onError (message) -> Logger\error "Websocket Error!", message
        \open!

TeamColorCache = {}

getTeamColorCode = (team) ->
    return TeamColorCache[team] if TeamColorCache[team]

    color = GetColor team
    r, g, b = color\Unpack!

    calculated = lshift(r, 16) + lshift(g, 8) + b
    TeamColorCache[team] = calculated

    calculated

receiveMessage = (ply, text, teamChat) ->
    return if teamChat
    return unless text
    return if text == ""

    team = ply\Team!
    rankColor = getTeamColorCode team
    avatar = ply.response.players[1].avatar
    steamName = ply\Nick!
    steamId = ply\SteamID64!
    irisId = "none"

    struct =
        Realm: Realm
        Content: text
        RankColor: rankColor
        Avatar: avatar
        SteamName: steamName
        SteamId: steamId
        IrisId: irisId

    message = TableToJSON struct

    WebSocket\write message

hook.Add "PlayerSay", "CFC_ChatTransit_MessageListener", receiveMessage, HOOK_MONITOR_LOW

Logger\info "Loaded!"
