local guard
guard = ChatTransit.guard
ChatTransit.PvPEvent = function(self, ply, newMode)
  local eventText = tostring(ply:Nick()) .. " has entered " .. tostring(newMode) .. " mode"
  return self:Send({
    Type = "pvp_status_change",
    Data = {
      Content = eventText
    }
  })
end
hook.Add("CFC_PvP_PlayerEnterPvp", "CFC_ChatTransit_Relay", guard(function(ply)
  return ChatTransit:PvPEvent(ply, "PvP")
end))
return hook.Add("CFC_PvP_PlayerExitPvp", "CFC_ChatTransit_Relay", guard(function(ply)
  return ChatTransit:PvPEvent(ply, "Build")
end))
