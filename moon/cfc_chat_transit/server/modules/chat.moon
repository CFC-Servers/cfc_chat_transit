import guard from ChatTransit

ChatTransit.ReceiveMessage = (data) =>
    :userid, :text, :teamonly = data
    ply = Player userid

    return if teamonly == 1
    return unless text
    return if text == ""

    shouldRelay = hook.Run "CFC_ChatTransit_ShouldRelayChatMessage", ply, text, teamonly
    return if shouldRelay == false

    @Send
        Type: "message"
        Data:
            Type: "message"
            Content: text
            SteamName: ply\Nick!
            SteamId: ply\SteamID64!
            IrisId: "none"

gameevent.Listen "player_say"
hook.Add "player_say", "CFC_ChatTransit_MessageListener", guard(ChatTransit\ReceiveMessage)
