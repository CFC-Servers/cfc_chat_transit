local TableToJSON = util.TableToJSON

local avatarServiceAPIAddress = CreateConVar("cfc_avatar_service_address", "", FCVAR_ARCHIVE + FCVAR_PROTECTED)
local avatarServiceImageAddress = CreateConVar("cfc_avatar_service_image_address", "", FCVAR_ARCHIVE + FCVAR_PROTECTED)

AvatarService = {}
AvatarService.__index = AvatarService

setmetatable(AvatarService, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

function AvatarService.new(logger)
    local self = setmetatable({}, AvatarService)
    self.logger = logger:scope("AvatarService")
    self.outlinerUrl = avatarServiceAPIAddress:GetString() .. "/outline"
    self.processedIDs = {}
    return self
end

function AvatarService:getAvatar(steamID64)
    if not steamID64 then return end
    local imageAddress = avatarServiceImageAddress:GetString()
    local realm = ChatTransit.Realm:GetString()
    local baseURL = "https://" .. imageAddress .. "/avatars/" .. realm

    local url = baseURL .. "/" .. steamID64 .. ".png"

    local processed = self.processedIDs[steamID64]
    if processed then
        url = url .. "?hash=" .. processed
    end

    return url
end

function AvatarService:processAvatar(avatarUrl, outlineColor, steamID64)
    local realm = ChatTransit.Realm:GetString()
    local body = TableToJSON({ avatarUrl = avatarUrl, outlineColor = outlineColor, realm = realm, steamID = steamID64 })
    self.logger:debug("Sending data to outliner: ", body)

    local failed = self.logger:error()
    local success = function(code, body)
        self.logger:debug("Avatar request succeeded with code: " .. tostring(code) .. " | Body: " .. tostring(body))
        self.processedIDs[steamID64] = util.CRC(tostring(outlineColor))
    end

    HTTP({
        success = success,
        failed = failed,
        body = body,
        url = self.outlinerUrl,
        method = "POST",
        type = "application/json",
    })
end

function AvatarService:outlineAvatar(steamID, steamID64, url)
    self.logger:debug("Received request to outline avatar for ply: " .. tostring(steamID))
    local outlineColor = ChatTransit:GetRankColor(steamID, steamID64)

    self:processAvatar(url, outlineColor, steamID64)
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "CFC_ChatTransit_AvatarSetup", function(data)
    if data.bot == 1 then return end

    local steamID = data.networkid
    local steamID64 = util.SteamIDTo64(steamID)

    local success = function(body)
        data = util.JSONToTable(body)
        assert(data, "Failed to parse JSON from steamid.gay")

        print("Got avatar data for " .. tostring(steamID64) .. ": ", data.Avatar)
        ChatTransit.AvatarService:outlineAvatar(steamID, steamID64, data.Avatar)
    end

    local failed = function(message)
        error("Failed to get Avatar for " .. tostring(steamID64) .. ": " .. tostring(message))
    end

    http.Fetch("https://steamid.gay/api/user/" .. tostring(steamID64), success, failed)

    return nil
end)

hook.Add("PlayerDisconnected", "CFC_ChatTransit_AvatarServiceReset", function(ply)
    local steamID64 = ply:SteamID64()
    if not steamID64 then
        ErrorNoHalt("[ChatTransit] Failed to get player's SteamID64 in PlayerDisconnected")
        return
    end

    ChatTransit.AvatarService.processedIDs[steamID64] = nil

    return nil
end)
