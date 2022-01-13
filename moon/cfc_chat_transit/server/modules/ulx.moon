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

        -- fancyLogAdmin only checks 'IsDedicated' when it's ready to make its final print
        game._IsDedicated or= game.IsDedicated
        game.IsDedicated = ->
            game.IsDedicated = game._IsDedicated

            -- When we're sure it's ready to print, we'll capture the next Msg call and use it for our webhook
            _G["_Msg"] or= Msg

            Msg = (msg) ->
                _G.Msg = _G._Msg
                Msg msg
                ChatTransit\ReceiveULXAction msg

            return game.IsDedicated!

        ulx._fancyLogAdmin ...

        -- In case it didn't run as expected, return the wrapped functions to normal so we don't print something unrelated
        game.IsDedicated = game._IsDedicated if game._IsDedicated
        Msg = _G["_Msg"] if _G["_Msg"]
