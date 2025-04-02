local guard
guard = ChatTransit.guard
ChatTransit.RoundModifierEvent = function(self, _, modifier)
  return self:Send({
    Type = "round_modifier_enabled",
    Data = {
      Content = "Enabled Modifier " .. tostring(modifier:PrintName()) .. ": " .. tostring(modifier:ShortDescription())
    }
  })
end
return hook.Add("RoundModifiers_ModifierEnabled", "CFC_ChatTransit_Relay", guard((function()
  local _base_0 = ChatTransit
  local _fn_0 = _base_0.RoundModifierEvent
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)()))
