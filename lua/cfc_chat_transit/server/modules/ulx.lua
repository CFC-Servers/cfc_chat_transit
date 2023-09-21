_Msg = Msg
local guard
guard = ChatTransit.guard
local isstring
isstring = _G.isstring
local Replace
Replace = string.Replace
ChatTransit.ReceiveULXAction = function(self, msg)
  msg = Replace(msg, "\n", "")
  self.Logger:debug("Received global ULX message", msg)
  return self:Send({
    Type = "ulx_action",
    Data = {
      Type = "ulx_action",
      Content = msg
    }
  })
end
local M
M = function(...)
  _Msg(...)
  return ChatTransit:ReceiveULXAction(...)
end
return hook.Add("InitPostEntity", "ChatTransit_WrapUlxLog", guard(function()
  if not (ulx) then
    return 
  end
  ulx._ChatTransit_fancyLogAdmin = ulx._ChatTransit_fancyLogAdmin or ulx.fancyLogAdmin
  ulx.fancyLogAdmin = function(...)
    local args = {
      ...
    }
    if not (isstring(args[2])) then
      return ulx._ChatTransit_fancyLogAdmin(...)
    end
    Msg = M
    ulx._ChatTransit_fancyLogAdmin(...)
    Msg = _Msg
  end
end))
