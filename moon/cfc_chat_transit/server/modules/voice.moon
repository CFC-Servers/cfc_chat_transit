import IsValid from _G
import guard from ChatTransit

ChatTransit.ReceiveVoiceTranscript = (steamID64, transcript) =>
    ply = player.GetBySteamID64 steamID64
    return unless IsValid ply

    shouldRelay = hook.Run "CFC_ChatTransit_ShouldRelayTranscript", ply, transcript
    return if shouldRelay == false
    
    @Send
        Type: "voice_transcript"
        Data:
            Type: "voice_transcript"
            Content: transcript
            SteamName: ply\Nick!
            SteamId: ply\SteamID64!
            IrisId: "none"
