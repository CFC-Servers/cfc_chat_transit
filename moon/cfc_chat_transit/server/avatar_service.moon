import TableToJSON from util
HTTP = HTTP

avatarServiceAddress = CreateConVar "cfc_avatar_service_address", "", FCVAR_NONE

class AvatarService
    new: (logger) =>
        @logger = logger\scope "AvatarService"
        @outlinerUrl = "http://#{avatarServiceAddress\GetString!}/outline"

    getAvatar: (steamID64) ->
        steamID64 and "https://avatarservice.cfcservers.org/avatars/#{steamID64}.png" or nil

    processAvatar: (avatarUrl, outlineColor, steamID) =>
        body = TableToJSON { :avatarUrl, :outlineColor, :steamID }
        @logger\info "Sending data to outliner: ", body

        failed = @logger\error
        success = (code, body) ->
            @logger\info "Avatar request succeeded with code: #{code} | Body: #{body}"

        HTTP
            :success
            :failed
            :body
            url: @outlinerUrl
            method: "POST"
            type: "application/json"

    outlineAvatar: (ply, data) =>
        @logger\info "Received request to outline avatar for ply: #{ply\Nick!}"
        avatar = data.response.players[1].avatarfull
        outlineColor = ChatTransit\GetTeamColor ply\Team!
        steamID = ply\SteamID64!

        @processAvatar avatar, outlineColor, steamID

ChatTransit.AvatarService = AvatarService ChatTransit.Logger

hook.Add "CFC_SteamLookup_SuccessfulPlayerData", "CFC_ChatTransit_AvatarService", (dataName, ply, data) ->
    return unless dataName == "PlayerSummary"
    return unless data

    success, err = pcall -> ChatTransit.AvatarService\outlineAvatar ply, data
    ErrorNoHaltWithStack err, dataName, ply unless success

    return nil
