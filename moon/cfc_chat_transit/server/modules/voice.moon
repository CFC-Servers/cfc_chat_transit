import IsValid from _G
import guard from ChatTransit

local proxVoice

proxVoiceEnabled = ->
    proxVoice or= GetConVar "force_proximity_voice"
    return proxVoice\GetBool!

ChatTransit.ReceiveVoiceTranscript = (steamID64, data) =>
    return if proxVoiceEnabled!

    ply = player.GetBySteamID64 steamID64
    return unless IsValid ply

    return if ply.ulx_gagged
    return if ply\GetInfoNum("proximity_voice_enabled", 0) ~= 0

    shouldRelay = hook.Run "CFC_ChatTransit_ShouldRelayTranscript", ply, transcript
    return if shouldRelay == false
    
    @Send
        Type: "voice_transcript"
        Data:
            Type: "voice_transcript"
            Content: data
            SteamName: ply\Nick!
            SteamId: ply\SteamID64!
            IrisId: "none"
