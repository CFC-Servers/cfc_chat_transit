import TableToJSON from util
HTTP = HTTP

avatarServiceAddress = CreateConVar "cfc_avatar_service_address", "", FCVAR_ARCHIVE + FCVAR_PROTECTED

class AvatarService

    new: (logger) =>
        @logger = logger\scope "AvatarService"
        @outlinerUrl = "#{avatarServiceAddress\GetString!}/outline"
        @processedIds = {}

    getAvatar: (steamID64) =>
        url = steamID64 and "https://avatarservice.cfcservers.org/avatars/#{steamID64}.png" or nil
        url and= "#{url}?processed=true" if @processedIds[steamID64]

        return url

    processAvatar: (avatarUrl, outlineColor, steamID64) =>
        body = TableToJSON { :avatarUrl, :outlineColor, steamID: steamID64 }
        @logger\debug "Sending data to outliner: ", body

        failed = @logger\error
        success = (code, body) ->
            @logger\debug "Avatar request succeeded with code: #{code} | Body: #{body}"
            @processedIds[steamID64] = true

        HTTP
            :success
            :failed
            :body
            url: @outlinerUrl
            method: "POST"
            type: "application/json"

    outlineAvatar: (ply, data) =>
        @logger\debug "Received request to outline avatar for ply: #{ply\Nick!}"
        avatar = data.response.players[1].avatarfull
        outlineColor = ChatTransit\GetTeamColor ply\Team!
        steamID64 = ply\SteamID64!

        @processAvatar avatar, outlineColor, steamID64

hook.Add "InitPostEntity", "CFC_ChatTrahsit_AvatarServiceInit", ->
    ChatTransit.AvatarService = AvatarService ChatTransit.Logger

hook.Add "CFC_SteamLookup_SuccessfulPlayerData", "CFC_ChatTransit_AvatarService", (dataName, ply, data) ->
    return unless dataName == "PlayerSummary"
    return unless data

    success, err = pcall -> ChatTransit.AvatarService\outlineAvatar ply, data
    ErrorNoHaltWithStack err, dataName, ply unless success

    return nil
