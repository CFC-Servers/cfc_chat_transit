import guard from ChatTransit

ChatTransit.ReceiveMessage = (ply, text, teamChat) =>
    return if teamChat
    return unless text
    return if text == ""

    @Send
        Type: "message"
        Data:
            Type: "message"
            Content: text
            SteamName: ply\Nick!
            SteamId: ply\SteamID64!
            IrisId: "none"

hook.Add "PlayerSay", "CFC_ChatTransit_MessageListener", guard(ChatTransit\ReceiveMessage), HOOK_MONITOR_LOW
