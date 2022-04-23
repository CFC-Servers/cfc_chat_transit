ChatTransit.PlayerCount = 0

gameevent.Listen "player_connect"
gameevent.Listen "player_disconnect"

ChatTransit.TrackPlayerCountConnected = () =>
    ChatTransit.PlayerCount = ChatTransit.PlayerCount + 1

ChatTransit.TrackPlayerCountDisconnected = () =>
    ChatTransit.PlayerCount = ChatTransit.PlayerCount - 1

hook.Add "player_connect", "CFC_ChatTransit_PlayerCountTracker", ChatTransit.TrackPlayerCountConnected
hook.Add "player_disconnect", "CFC_ChatTransit_PlayerCountTracker", ChatTransit.TrackPlayerCountDisconnected
diff --git a/moon/cfc_chat_transit/server/modules/disconnect.moon b/moon/cfc_chat_transit/server/modules/disconnect.moon
