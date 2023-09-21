local guard
guard = ChatTransit.guard
ChatTransit.ReceiveMessage = function(self, ply, text, teamChat)
  local shouldRelay = hook.Run("CFC_ChatTransit_ShouldRelayChatMessage", ply, text, teamChat)
  if shouldRelay == false then
    return 
  end
  if teamChat then
    return 
  end
  if not (text) then
    return 
  end
  if text == "" then
    return 
  end
  return self:Send({
    Type = "message",
    Data = {
      Type = "message",
      Content = text,
      SteamName = ply:Nick(),
      SteamId = ply:SteamID64(),
      IrisId = "none"
    }
  })
end
return hook.Add("PlayerSay", "CFC_ChatTransit_MessageListener", guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.ReceiveMessage
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)()), HOOK_MONITOR_LOW)
