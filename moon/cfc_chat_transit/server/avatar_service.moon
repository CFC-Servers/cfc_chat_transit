import TableToJSON from util
HTTP = HTTP

avatarServiceAddress = CreateConVar "cfc_avatar_service_address", "", FCVAR_NONE

class AvatarService
    new: (logger) =>
        @logger = logger\scope "AvatarService"
        @outlinerUrl = "http://#{avatarServiceAddress\GetString!}/outline"

    processAvatar: (avatarUrl, outlineColor, success, failed) =>
        body = TableToJSON { :avatarUrl, :outlineColor }

        @logger\debug "Sending data to outliner: ", body

        HTTP
            :success
            :failed
            :body
            url: @outlinerUrl
            method: "POST"
            type: "application/json"

    setOutlinedAvatar: (ply, avatarUrl) =>
        data = ply.SteamLookup.PlayerSummary.response.players[1]

        data.originalAvatarFull or= data.avatarfull
        data.avatarfull = avatarUrl

    outlineAvatar: (ply, data) =>
        @logger\debug "Received request to outline avatar for ply: #{ply\Nick!}"
        avatar = data.response.players[1].avatarfull
        outlineColor = ChatTransit\GetTeamColor ply\Team!

        success = (code, body) ->
            @logger\debug "Avatar request succeeded with code: #{code} | Body: #{body}"
            @setOutlinedAvatar ply, body

        failed = (err) -> @logger\error err

        @processAvatar avatar, outlineColor, success, failed

ChatTransit.AvatarService = AvatarService ChatTransit.Logger

hook.Add "CFC_SteamLookup_SuccessfulPlayerData", "CFC_ChatTransit_AvatarService", (dataName, ply, data) ->
    return unless dataName == "PlayerSummary"
    return unless data

    success, err pcall -> ChatTransit.AvatarService\outlineAvatar ply, data
    ErrorNoHaltWithStack err, dataName, ply unless success

    return nil
