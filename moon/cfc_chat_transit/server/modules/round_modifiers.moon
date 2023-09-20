import guard from ChatTransit

ChatTransit.RoundModifierEvent = (modifier) =>
    eventText =

    @Send
        Type: "round_modifier_enabled"
        Data:
            Content:  "Enabled Modifier #{modifier\PrintName!}: #{modifier\ShortDesription!}"

hook.Add "TTTRoundModifiers_ModifierEnabled", "CFC_ChatTransit_Relay", guard (modifier) -> ChatTransit\RoundModifierEvent modifier
