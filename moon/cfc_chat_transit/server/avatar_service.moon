import TableToJSON from util
HTTP = HTTP

AvatarServiceAddress = file.Read "cfc/avatar_service_address.txt", "DATA"
AvatarServiceAddress = string.Replace AvatarServiceAddress, "\r", ""
AvatarServiceAddress = string.Replace AvatarServiceAddress, "\n", ""

class AvatarService
    new: (logger) =>
        @Logger = logger

    processAvatar: (avatarUrl, outlineColor, success, failed) =>
        HTTP
            :success
            :failed
            url: "http://#{AvatarServiceAddress}/outline"
            method: "POST"
            type: "application/json"
            body: TableToJSON :avatarUrl

    setOutlinedAvatar: (ply, avatarUrl) =>
        data = ply.response.players[1]

        data.originalAvatarFull or= data.avatarfull
        data.avatarfull = avatarUrl

    outlineAvatar: (ply, data) =>
        avatar = data.response.players[1].avatarfull
        outlineColor = ChatTransit\GetTeamColorCode ply\Team!

        success = (code, body) -> setOutlinedAvatar ply, response
        failed = (err) -> @Logger\error err

        @processAvatar avatar, success, failed

ChatTransit.AvatarService = AvatarService ChatTransit.Logger

hook.Add "CFC_SteamLookup_SuccessfulPlayerData", "CFC_ChatTransit_AvatarService", (dataName, ply, data) ->
    return unless dataName == "PlayerSummary"

    ChatTransit.AvatarService\outlineAvatar ply, data

    return nil
