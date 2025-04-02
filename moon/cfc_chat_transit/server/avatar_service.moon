import TableToJSON from util

avatarServiceAPIAddress = CreateConVar "cfc_avatar_service_address", "", FCVAR_ARCHIVE + FCVAR_PROTECTED
avatarServiceImageAddress = CreateConVar "cfc_avatar_service_image_address", "", FCVAR_ARCHIVE + FCVAR_PROTECTED

export class AvatarService
    new: (logger) =>
        @logger = logger\scope "AvatarService"
        @outlinerUrl = "#{avatarServiceAPIAddress\GetString!}/outline"
        @processedIDs = {}

    getAvatar: (steamID64) =>
        return unless steamID64
        imageAddress = avatarServiceImageAddress\GetString!
        realm = ChatTransit.Realm\GetString!
        baseURL = "https://#{imageAddress}/avatars/#{realm}"

        url = "#{baseURL}/#{steamID64}.png"

        processed = @processedIDs[steamID64]
        url = "#{url}?hash=#{processed}" if processed

        return url

    processAvatar: (avatarUrl, outlineColor, steamID64) =>
        realm = ChatTransit.Realm\GetString!
        body = TableToJSON { :avatarUrl, :outlineColor, :realm, steamID: steamID64 }
        @logger\debug "Sending data to outliner: ", body

        failed = @logger\error
        success = (code, body) ->
            @logger\debug "Avatar request succeeded with code: #{code} | Body: #{body}"
            @processedIDs[steamID64] = util.CRC( tostring( outlineColor ) )

        HTTP
            :success
            :failed
            :body
            url: @outlinerUrl
            method: "POST"
            type: "application/json"

    outlineAvatar: (steamID, steamID64, url) =>
        @logger\debug "Received request to outline avatar for ply: #{steamID}"
        outlineColor = ChatTransit\GetRankColor steamID, steamID64

        @processAvatar url, outlineColor, steamID64

gameevent.Listen "player_connect"
hook.Add "player_connect", "CFC_ChatTransit_AvatarSetup", (data) ->
    return if data.bot == 1

    steamID = data.networkid
    steamID64 = util.SteamIDTo64 steamID

    success = (body) ->
        data = util.JSONToTable body
        assert data, "Failed to parse JSON from steamid.gay"

        print "Got avatar data for #{steamID64}: ", data.Avatar
        ChatTransit.AvatarService\outlineAvatar steamID, steamID64, data.Avatar

    failed = (message) ->
        error "Failed to get Avatar for #{steamID64}: #{message}"

    http.Fetch "https://steamid.gay/api/user/#{steamID64}", success, failed

    return nil

hook.Add "PlayerDisconnected", "CFC_ChatTransit_AvatarServiceReset", (ply) ->
    steamID64 = ply\SteamID64!
    if not steamID64
        ErrorNoHalt "[ChatTransit] Failed to get player's SteamID64 in PlayerDisconnected"
        return

    ChatTransit.AvatarService.processedIDs[steamID64] = nil

    return nil
