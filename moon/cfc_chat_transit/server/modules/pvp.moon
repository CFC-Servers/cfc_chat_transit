import guard from ChatTransit

ChatTransit.PvPEvent = (ply, newMode) =>
    eventText = "#{ply\Nick!} has entered #{newMode} mode"

    @Send
        Type: "pvp_status_change"
        Data:
            Content: eventText

hook.Add "CFC_PvP_PlayerEnterPvp", "CFC_ChatTransit_Relay", guard (ply) -> ChatTransit\PvPEvent ply, "PvP"
hook.Add "CFC_PvP_PlayerExitPvp", "CFC_ChatTransit_Relay", guard (ply) -> ChatTransit\PvPEvent ply, "Build"
