import TableToJSON from util
HTTP = HTTP

AvatarServiceAddress = file.Read "cfc/avatar_service_address.txt", "DATA"
AvatarServiceAddress = string.Replace AvatarServiceAddress, "\r", ""
AvatarServiceAddress = string.Replace AvatarServiceAddress, "\n", ""

class AvatarService
    new: (logger) =>
        @Logger = logger
        @outlinerUrl = "http://#{AvatarServiceAddress}/outline"

    processAvatar: (avatarUrl, outlineColor, success, failed) =>
        body = TableToJSON { :avatarUrl, :outlineColor }

        @Logger\debug "Sending data to outliner: ", body

        HTTP
            :success
            :failed
            :body
            url: @outlinerUrl
            method: "POST"
            type: "application/json"

    setOutlinedAvatar: (ply, avatarUrl) =>
        data = ply.PlayerSummary.response.players[1]

        data.originalAvatarFull or= data.avatarfull
        data.avatarfull = avatarUrl

    outlineAvatar: (ply, data) =>
        @Logger\debug "Received request to outline avatar for ply: #{ply\Nick!}"
        avatar = data.response.players[1].avatarfull
        outlineColor = ChatTransit\GetTeamColor ply\Team!

        success = (code, body) ->
            @Logger\debug "Avatar request succeeded with code: #{code} | Body: #{body}"
            @setOutlinedAvatar ply, body

        failed = (err) -> @Logger\error err

        @processAvatar avatar, outlineColor, success, failed

ChatTransit.AvatarService = AvatarService ChatTransit.Logger

hook.Add "CFC_SteamLookup_SuccessfulPlayerData", "CFC_ChatTransit_AvatarService", (dataName, ply, data) ->
    return unless dataName == "PlayerSummary"
    return unless data

    ChatTransit.AvatarService\outlineAvatar ply, data

    return nil
