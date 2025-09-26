local guard
guard = ChatTransit.guard
ChatTransit.ReceiveMessage = function(self, data)
  local userid, text, teamonly
  userid, text, teamonly = data.userid, data.text, data.teamonly
  local ply = Player(userid)
  if teamonly == 1 then
    return 
  end
  if not (text) then
    return 
  end
  if text == "" then
    return 
  end
  local shouldRelay = hook.Run("CFC_ChatTransit_ShouldRelayChatMessage", ply, text, teamonly)
  if shouldRelay == false then
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
gameevent.Listen("player_say")
return hook.Add("player_say", "CFC_ChatTransit_MessageListener", guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.ReceiveMessage
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)()))
