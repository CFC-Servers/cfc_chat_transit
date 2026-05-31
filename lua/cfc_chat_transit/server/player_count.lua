ChatTransit.playerCount = 0

local increment = function() ChatTransit.playerCount = ChatTransit.playerCount + 1 end
local decrement = function() ChatTransit.playerCount = ChatTransit.playerCount - 1 end

hook.Add("ClientSignOnStateChanged", "ChatTransit_PlayerCount", function(_, oldstate)
    if oldstate ~= 7 then return end
    increment()
end)

gameevent.Listen("player_connect")
hook.Add("player_connect", "ChatTransit_PlayerCount", increment)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "ChatTransit_PlayerCount", decrement)
