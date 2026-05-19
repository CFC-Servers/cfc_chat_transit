ChatTransit.playerCount = 0
local increment
increment = function()
  ChatTransit.playerCount = ChatTransit.playerCount + 1
end
local decrement
decrement = function()
  ChatTransit.playerCount = ChatTransit.playerCount - 1
end
hook.Add("ClientSignOnStateChanged", "ChatTransit_PlayerCount", function(_, oldstate)
  if not (oldstate == 7) then
    return 
  end
  return increment()
end)
gameevent.Listen("player_connect")
hook.Add("player_connect", "ChatTransit_PlayerCount", increment)
gameevent.Listen("player_disconnect")
return hook.Add("player_disconnect", "ChatTransit_PlayerCount", decrement)
