export Msg
export _Msg = Msg

import guard from ChatTransit
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

M = (...) ->
    _Msg ...
    ChatTransit\ReceiveULXAction ...

hook.Add "InitPostEntity", "ChatTransit_WrapUlxLog", guard ->
    return unless ulx

    ulx._ChatTransit_fancyLogAdmin or= ulx.fancyLogAdmin
    ulx.fancyLogAdmin = (...) ->
        args = { ... }

        -- If second param is a string, then it's safe to send to everyone
        return ulx._ChatTransit_fancyLogAdmin(...) unless isstring args[2]

        Msg = M

        ulx._ChatTransit_fancyLogAdmin ...

        Msg = _Msg
