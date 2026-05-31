local guard = ChatTransit.guard

ChatTransit.PvPEvent = function(self, ply, newMode)
    local eventText = ply:Nick() .. " has entered " .. newMode .. " mode"

    self:Send({
        Type = "pvp_status_change",
        Data = {
            Content = eventText,
        },
    })
end

hook.Add("CFC_PvP_PlayerEnterPvp", "CFC_ChatTransit_Relay", guard(function(ply) return ChatTransit:PvPEvent(ply, "PvP") end))
hook.Add("CFC_PvP_PlayerExitPvp", "CFC_ChatTransit_Relay", guard(function(ply) return ChatTransit:PvPEvent(ply, "Build") end))
