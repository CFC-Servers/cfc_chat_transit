ChatTransit.ReceiveMessage = (ply, text, teamChat) =>
    return if teamChat
    return unless text
    return if text == ""

    avatar = ply.PlayerSummary.response.players[1].avatarfull

    @Send
        Type: "message"
        Data:
            Type: "message"
            Content: text
            Avatar: avatar
            SteamName: ply\Nick!
            SteamId: ply\SteamID64!
            IrisId: "none"

hook.Add "PlayerSay", "CFC_ChatTransit_MessageListener", ChatTransit\ReceiveMessage, HOOK_MONITOR_LOW
