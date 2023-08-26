local TableToJSON
TableToJSON = util.TableToJSON
local HTTP = HTTP
local avatarServiceAddress = CreateConVar("cfc_avatar_service_address", "", FCVAR_ARCHIVE + FCVAR_PROTECTED)
local AvatarService
do
  local _class_0
  local _base_0 = {
    getAvatar = function(self, steamID64)
      local url = steamID64 and "https://avatarservice.cfcservers.org/avatars/" .. tostring(steamID64) .. ".png" or nil
      if self.processedIds[steamID64] then
        url = url and tostring(url) .. "?processed=true"
      end
      return url
    end,
    processAvatar = function(self, avatarUrl, outlineColor, steamID64)
      local body = TableToJSON({
        avatarUrl = avatarUrl,
        outlineColor = outlineColor,
        steamID = steamID64
      })
      self.logger:debug("Sending data to outliner: ", body)
      local failed
      do
        local _base_1 = self.logger
        local _fn_0 = _base_1.error
        failed = function(...)
          return _fn_0(_base_1, ...)
        end
      end
      local success
      success = function(code, body)
        self.logger:debug("Avatar request succeeded with code: " .. tostring(code) .. " | Body: " .. tostring(body))
        self.processedIds[steamID64] = true
      end
      return HTTP({
        success = success,
        failed = failed,
        body = body,
        url = self.outlinerUrl,
        method = "POST",
        type = "application/json"
      })
    end,
    outlineAvatar = function(self, ply, data)
      self.logger:debug("Received request to outline avatar for ply: " .. tostring(ply:Nick()))
      local avatar = data.response.players[1].avatarfull
      local outlineColor = ChatTransit:GetTeamColor(ply:Team())
      local steamID64 = ply:SteamID64()
      return self:processAvatar(avatar, outlineColor, steamID64)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, logger)
      self.logger = logger:scope("AvatarService")
      self.outlinerUrl = tostring(avatarServiceAddress:GetString()) .. "/outline"
      self.processedIds = { }
    end,
    __base = _base_0,
    __name = "AvatarService"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  AvatarService = _class_0
end
hook.Add("InitPostEntity", "CFC_ChatTrahsit_AvatarServiceInit", function()
  ChatTransit.AvatarService = AvatarService(ChatTransit.Logger)
end)
return hook.Add("CFC_SteamLookup_SuccessfulPlayerData", "CFC_ChatTransit_AvatarService", function(dataName, ply, data)
  if not (dataName == "PlayerSummary") then
    return 
  end
  if not (data) then
    return 
  end
  local success, err = pcall(function()
    return ChatTransit.AvatarService:outlineAvatar(ply, data)
  end)
  if not (success) then
    ErrorNoHaltWithStack(err, dataName, ply)
  end
  return nil
end)
