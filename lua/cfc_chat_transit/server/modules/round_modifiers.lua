local guard = ChatTransit.guard

ChatTransit.RoundModifierEvent = function(self, _, modifier)
    self:Send({
        Type = "round_modifier_enabled",
        Data = {
            Content = "Enabled Modifier " .. modifier:PrintName() .. ": " .. modifier:ShortDescription(),
        },
    })
end

hook.Add("RoundModifiers_ModifierEnabled", "CFC_ChatTransit_Relay", guard(function(...) return ChatTransit:RoundModifierEvent(...) end))
