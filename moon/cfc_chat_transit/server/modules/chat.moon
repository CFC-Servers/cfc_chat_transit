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

hook.Add "PlayerSay", "CFC_ChatTransit_MessageListener", ChatTransit\ReceiveMessage, HOOK_MONITOR_LOW
