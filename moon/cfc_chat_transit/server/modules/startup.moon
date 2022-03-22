import guard from ChatTransit
import GetMap from game

ChatTransit.Initialize = (data) =>
    eventText = ""
    map = GetMap!

    if SysTime() > 500 -- If systime is over 500, the server switched maps. Else it's a hard restart
        eventText = "Map switched to " .. map
    else
        eventText = "Server restarted! Current map is " .. map

    @Send
        Type: "map_init"
        Data:
            eventText: GetMap!

hook.Add "Initialize", "CFC_ChatTransit_StartListener", guard ChatTransit\Initialize
