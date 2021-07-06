local TableToJSON
TableToJSON = util.TableToJSON
local HTTP = HTTP
local AvatarServiceAddress = file.Read("cfc/avatar_service_address.txt", "DATA")
AvatarServiceAddress = string.Replace(AvatarServiceAddress, "\r", "")
AvatarServiceAddress = string.Replace(AvatarServiceAddress, "\n", "")
local AvatarService
do
  local _class_0
  local _base_0 = {
    processAvatar = function(self, avatarUrl, outlineColor, success, failed)
      local body = TableToJSON({
        avatarUrl = avatarUrl,
        outlineColor = outlineColor
      })
      self.Logger:debug("Sending data to outliner: ", body)
      return HTTP({
        success = success,
        failed = failed,
        body = body,
        url = self.outlinerUrl,
        method = "POST",
        type = "application/json"
      })
    end,
    setOutlinedAvatar = function(self, ply, avatarUrl)
      local data = ply.PlayerSummary.response.players[1]
      data.originalAvatarFull = data.originalAvatarFull or data.avatarfull
      data.avatarfull = avatarUrl
    end,
    outlineAvatar = function(self, ply, data)
      self.Logger:debug("Received request to outline avatar for ply: " .. tostring(ply:Nick()))
      local avatar = data.response.players[1].avatarfull
      local outlineColor = ChatTransit:GetTeamColor(ply:Team())
      local success
      success = function(code, body)
        self.Logger:debug("Avatar request succeeded with code: " .. tostring(code) .. " | Body: " .. tostring(body))
        return self:setOutlinedAvatar(ply, body)
      end
      local failed
      failed = function(err)
        return self.Logger:error(err)
      end
      return self:processAvatar(avatar, outlineColor, success, failed)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, logger)
      self.Logger = logger
      self.outlinerUrl = "http://" .. tostring(AvatarServiceAddress) .. "/outline"
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
ChatTransit.AvatarService = AvatarService(ChatTransit.Logger)
return hook.Add("CFC_SteamLookup_SuccessfulPlayerData", "CFC_ChatTransit_AvatarService", function(dataName, ply, data)
  if not (dataName == "PlayerSummary") then
    return 
  end
  ChatTransit.AvatarService:outlineAvatar(ply, data)
  return nil
end)
