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

hook.Add "InitPostEntity", "ChatTransit_WrapUlxLog", guard ->
    return unless ulx

    ulx._ChatTransit_logString or= ulx.logString

    logString = (msg, logToMain) ->
        ulx.logString = ulx._ChatTransit_logString

        ProtectedCall -> ChatTransit\ReceiveULXAction msg
        return ulx._ChatTransit_logString msg, logToMain

    ulx._ChatTransit_fancyLogAdmin or= ulx.fancyLogAdmin
    ulx.fancyLogAdmin = (...) ->
        args = { ... }

        -- If second param is not a string, it's a "hide_echo" - if it's not false, we shouldn't relay it
        if (not isstring(args[2])) and (args[2] ~= false)
            return ulx._ChatTransit_fancyLogAdmin(...)

        ulx.logString = logString

        ulx._ChatTransit_fancyLogAdmin ...

        ulx.logString = ulx._ChatTransit_logString
