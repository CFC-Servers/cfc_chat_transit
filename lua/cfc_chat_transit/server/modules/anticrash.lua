local guard
guard = ChatTransit.guard
local isstring
isstring = _G.isstring
ChatTransit.AnticrashEvent = function(self, eventText)
  if not (isstring(eventText)) then
    eventText = "Heavy lag detected!"
  end
  return self:Send({
    Type = "anticrash_event",
    Data = {
      Content = eventText,
      SteamName = "CFC Anticrash"
    }
  })
end
hook.Add("z_anticrash_LagStuck", "CFC_ChatTransit_AnticrashEventListener", guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.AnticrashEvent
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)()))
return hook.Add("z_anticrash_CrashPrevented", "CFC_ChatTransit_AnticrashEventListener", guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.AnticrashEvent
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)()))
