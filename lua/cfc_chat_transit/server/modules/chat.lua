local guard = ChatTransit.guard

ChatTransit.ReceiveMessage = function(self, data)
    local userid = data.userid
    local text = data.text
    local teamonly = data.teamonly
    local ply = Player(userid)

    if teamonly == 1 then return end
    if not text then return end
    if text == "" then return end

    local shouldRelay = hook.Run("CFC_ChatTransit_ShouldRelayChatMessage", ply, text, teamonly)
    if shouldRelay == false then return end

    self:Send({
        Type = "message",
        Data = {
            Type = "message",
            Content = text,
            SteamName = ply:Nick(),
            SteamId = ply:SteamID64(),
            IrisId = "none",
        },
    })
end

gameevent.Listen("player_say")
hook.Add("player_say", "CFC_ChatTransit_MessageListener", guard(function(...) return ChatTransit:ReceiveMessage(...) end))
