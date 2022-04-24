gameevent.Listen "player_connect"
gameevent.Listen "player_disconnect"

with ChatTransit
    .PlayerCount = 0
    .TrackPlayerCountConnected = () =>
        .PlayerCount = .PlayerCount + 1

    .TrackPlayerCountDisconnected = () =>
        .PlayerCount = .PlayerCount - 1

    hook.Add "player_connect", "CFC_ChatTransit_PlayerCountTracker", .TrackPlayerCountConnected
    hook.Add "player_disconnect", "CFC_ChatTransit_PlayerCountTracker", .TrackPlayerCountDisconnected
