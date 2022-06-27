ChatTransit.playerCount = 0

increment = -> ChatTransit.playerCount += 1
decrement = -> ChatTransit.playerCount -= 1

hook.Add "ClientSignOnStateChanged", "ChatTransit_PlayerCount", (_, _, newstate) ->
    return unless newstate == 7
    increment!

gameevent.Listen "player_connect"
hook.Add "player_connect", "ChatTransit_PlayerCount", increment

gameevent.Listen "player_disconnect"
hook.Add "player_disconnect", "ChatTransit_PlayerCount", decrement
