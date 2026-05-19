local IsValid
IsValid = _G.IsValid
local guard
guard = ChatTransit.guard
local proxVoice
local proxVoiceEnabled
proxVoiceEnabled = function()
  proxVoice = proxVoice or GetConVar("force_proximity_voice")
  if not (proxVoice) then
    return false
  end
  return proxVoice:GetBool()
end
ChatTransit.ReceiveVoiceTranscript = function(self, steamID64, data)
  if proxVoiceEnabled() then
    return 
  end
  local ply = player.GetBySteamID64(steamID64)
  if not (IsValid(ply)) then
    return 
  end
  if ply.ulx_gagged then
    return 
  end
  if ply:GetInfoNum("proximity_voice_enabled", 0) ~= 0 then
    return 
  end
  local shouldRelay = hook.Run("CFC_ChatTransit_ShouldRelayTranscript", ply, transcript)
  if shouldRelay == false then
    return 
  end
  return self:Send({
    Type = "voice_transcript",
    Data = {
      Type = "voice_transcript",
      Content = data,
      SteamName = ply:Nick(),
      SteamId = ply:SteamID64(),
      IrisId = "none"
    }
  })
end
