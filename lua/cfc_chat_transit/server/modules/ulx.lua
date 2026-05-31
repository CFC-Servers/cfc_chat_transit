local guard = ChatTransit.guard
local isstring = isstring
local Replace = string.Replace

ChatTransit.ReceiveULXAction = function(self, msg)
    msg = Replace(msg, "\n", "")
    self.Logger:debug("Received global ULX message", msg)

    self:Send({
        Type = "ulx_action",
        Data = {
            Type = "ulx_action",
            Content = msg,
        },
    })
end

hook.Add("InitPostEntity", "ChatTransit_WrapUlxLog", guard(function()
    if not ulx then return end

    ulx._ChatTransit_logString = ulx._ChatTransit_logString or ulx.logString

    local logString = function(msg, logToMain)
        ulx.logString = ulx._ChatTransit_logString

        ProtectedCall(function() ChatTransit:ReceiveULXAction(msg) end)
        return ulx._ChatTransit_logString(msg, logToMain)
    end

    ulx._ChatTransit_fancyLogAdmin = ulx._ChatTransit_fancyLogAdmin or ulx.fancyLogAdmin
    ulx.fancyLogAdmin = function(...)
        local args = { ... }

        -- If second param is not a string, it's a "hide_echo" - if it's not false, we shouldn't relay it
        if (not isstring(args[2])) and (args[2] ~= false) then
            return ulx._ChatTransit_fancyLogAdmin(...)
        end

        ulx.logString = logString

        ulx._ChatTransit_fancyLogAdmin(...)

        ulx.logString = ulx._ChatTransit_logString
    end
end))
