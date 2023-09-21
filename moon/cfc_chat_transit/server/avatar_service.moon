import TableToJSON from util

avatarServiceAPIAddress = CreateConVar "cfc_avatar_service_address", "", FCVAR_ARCHIVE + FCVAR_PROTECTED
avatarServiceImageAddress = CreateConVar "cfc_avatar_service_image_address", "", FCVAR_ARCHIVE + FCVAR_PROTECTED

class AvatarService
    new: (logger) =>
        @logger = logger\scope "AvatarService"
        @outlinerUrl = "#{avatarServiceAPIAddress\GetString!}/outline"
        @processedIDs = {}

    getAvatar: (steamID64) =>
        imageAddress = avatarServiceImageAddress\GetString!
        realm = ChatTransit.Realm\GetString!
        baseURL = "https://#{imageAddress}/avatars/#{realm}"

        url = steamID64 and "#{baseURL}/#{steamID64}.png" or nil
        url and= "#{url}?processed=true" if @processedIDs[steamID64]

        return url

    processAvatar: (avatarUrl, outlineColor, steamID64) =>
        realm = ChatTransit.Realm\GetString!
        body = TableToJSON { :avatarUrl, :outlineColor, :realm, steamID: steamID64 }
        @logger\debug "Sending data to outliner: ", body

        failed = @logger\error
        success = (code, body) ->
            @logger\debug "Avatar request succeeded with code: #{code} | Body: #{body}"
            @processedIDs[steamID64] = true

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

    ProtectedCall -> ChatTransit.AvatarService\outlineAvatar ply, data

    return nil

hook.Add "PlayerDisconnected", "CFC_ChatTransit_AvatarServiceReset", (ply) ->
    steamID64 = ply\SteamID64!
    if not steamID64
        ErrorNoHalt "[ChatTransit] Failed to get player's SteamID64 in PlayerDisconnected"
        return

    AvatarService.processedIDs[steamID64] = nil

    return nil
