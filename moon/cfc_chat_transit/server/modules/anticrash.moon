import guard from ChatTransit
import isstring from _G

ChatTransit.AnticrashEvent = (eventText) =>
    eventText = "Heavy lag detected!" unless isstring eventText

    @Send
        Type: "anticrash_event"
        Data:
            Content: eventText
            SteamName: "CFC Anticrash"

hook.Add "z_anticrash_LagStuck", "CFC_ChatTransit_AnticrashEventListener", guard ChatTransit\AnticrashEvent
hook.Add "z_anticrash_CrashPrevented", "CFC_ChatTransit_AnticrashEventListener", guard ChatTransit\AnticrashEvent
