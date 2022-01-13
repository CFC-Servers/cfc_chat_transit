ChatTransit.AnticrashEvent = (eventText) =>
    argType = type eventText

    if argType ~= "string"
        eventText = "Heavy lag detected!"

    struct =
        Type: "anticrash_event"
        Data:
            Realm: Realm\GetString!
            Content: eventText
            SteamName: "CFC Anticrash"
            Avatar: ""

    message = TableToJSON struct

    @WebSocket\write message

hook.Add "z_anticrash_LagDetect", "CFC_ChatTransit_AnticrashEventListener", ChatTransit\AnticrashEvent
hook.Add "z_anticrash_LagStuck", "CFC_ChatTransit_AnticrashEventListener", ChatTransit\AnticrashEvent
hook.Add "z_anticrash_CrashPrevented", "CFC_ChatTransit_AnticrashEventListener", ChatTransit\AnticrashEvent
