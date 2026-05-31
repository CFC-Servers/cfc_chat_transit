local guard = ChatTransit.guard
local isstring = isstring

ChatTransit.AnticrashEvent = function(self, eventText)
    if not isstring(eventText) then
        eventText = "Heavy lag detected!"
    end

    self:Send({
        Type = "anticrash_event",
        Data = {
            Content = eventText,
            SteamName = "CFC Anticrash",
        },
    })
end

hook.Add("z_anticrash_LagStuck", "CFC_ChatTransit_AnticrashEventListener", guard(function(...) return ChatTransit:AnticrashEvent(...) end))
hook.Add("z_anticrash_CrashPrevented", "CFC_ChatTransit_AnticrashEventListener", guard(function(...) return ChatTransit:AnticrashEvent(...) end))
