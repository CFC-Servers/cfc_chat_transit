import isstring from _G
import Replace from string

ChatTransit.ReceiveULXAction = (msg) =>
    msg = Replace msg, "\n", ""
    @Logger\debug "Received global ULX message", msg

    @Send
        Type: "ulx_action"
        Data:
            Type: "ulx_action"
            Content: msg

hook.Add "InitPostEntity", "ChatTransit_WrapUlxLog", ->
    return unless ulx

    ulx._fancyLogAdmin or= ulx.fancyLogAdmin
    ulx.fancyLogAdmin = (...) ->
        args = { ... }

        -- If second param is a string, then it's safe to send to everyone
        return ulx._fancyLogAdmin(...) unless isstring args[2]

        _G["_Msg"] or= Msg
        Msg = (msg) ->
            _G.Msg = _G._Msg
            Msg msg
            ChatTransit\ReceiveULXAction msg

        ulx._fancyLogAdmin ...

        Msg = _G["_Msg"] if _G["_Msg"]
