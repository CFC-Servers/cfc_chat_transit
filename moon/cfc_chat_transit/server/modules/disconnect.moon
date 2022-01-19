import guard from ChatTransit
import GetBySteamID from player
import SteamIDTo64 from util

ChatTransit.PlayerDisconnected = (data) =>
    :name, :reason, networkid: steamId = data

    ply = GetBySteamID steamId

    summary = ply and ply.SteamLookup and ply.SteamLookup.PlayerSummary
    avatar = summary and summary.response.players[1].avatarfull

    @Send
        Type: "disconnect"
        Data:
            Avatar: avatar
            SteamName: ply and ply\Nick! or name
            SteamId: ply and ply\SteamID64! or SteamIDTo64 steamId
            Content: reason

gameevent.Listen "player_disconnect"
hook.Add "player_disconnect", "CFC_ChatTransit_DisconnectListener", guard ChatTransit\PlayerDisconnected
