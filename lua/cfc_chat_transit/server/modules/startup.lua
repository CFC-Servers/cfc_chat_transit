local guard
guard = ChatTransit.guard
local GetMap
GetMap = game.GetMap
ChatTransit.MapStartup = function(self, data)
  local eventText = ""
  local map = GetMap()
  if SysTime() > 500 then
    eventText = "Map switched to " .. map
  else
    eventText = "Server restarted! Current map is " .. map
  end
  return self:Send({
    Type = "map_init",
    Data = {
      Content = eventText
    }
  })
end
return hook.Add("InitPostEntity", "CFC_ChatTransit_StartListener", timer.Simple(1, guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.MapStartup
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())))
