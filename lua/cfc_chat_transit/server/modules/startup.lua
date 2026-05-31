local guard = ChatTransit.guard
local GetMap = game.GetMap

ChatTransit.MapStartup = function(self, data)
    local eventText = ""
    local map = GetMap()

    if SysTime() > 500 then -- If systime is over 500, the server switched maps. Else it's a hard restart
        eventText = "Map switched to " .. map
    else
        eventText = "Server restarted! Current map is " .. map
    end

    self:Send({
        Type = "map_init",
        Data = {
            Content = eventText,
        },
    })
end

hook.Add("InitPostEntity", "CFC_ChatTransit_StartListener", function()
    timer.Simple(1, guard(function(...) return ChatTransit:MapStartup(...) end))
end)
