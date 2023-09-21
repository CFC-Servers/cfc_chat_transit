import guard from ChatTransit

ChatTransit.RoundModifierEvent = (modifier) =>
    @Send
        Type: "round_modifier_enabled"
        Data:
            Content:  "Enabled Modifier #{modifier\PrintName!}: #{modifier\ShortDesription!}"

hook.Add "RoundModifiers_ModifierEnabled", "CFC_ChatTransit_Relay", guard (name, modifier) -> ChatTransit\RoundModifierEvent name, modifier
