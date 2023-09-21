local Start, Receive, ReadBool, ReadColor, ReadString, WriteBool, SendToServer
do
  local _obj_0 = net
  Start, Receive, ReadBool, ReadColor, ReadString, WriteBool, SendToServer = _obj_0.Start, _obj_0.Receive, _obj_0.ReadBool, _obj_0.ReadColor, _obj_0.ReadString, _obj_0.WriteBool, _obj_0.SendToServer
end
local AddToolCategory, AddToolMenuOption
do
  local _obj_0 = spawnmenu
  AddToolCategory, AddToolMenuOption = _obj_0.AddToolCategory, _obj_0.AddToolMenuOption
end
local shouldReceiveRemoteMessages = CreateConVar("cfc_chat_transit_remote_messages", 1, FCVAR_ARCHIVE, "Should receive remote messges in chat", 0, 1)
local colors = {
  white = Color(255, 255, 255),
  blurple = Color(142, 163, 247)
}
Receive("CFC_ChatTransit_RemoteMessageReceive", function()
  if not (shouldReceiveRemoteMessages:GetBool()) then
    return 
  end
  local author = ReadString()
  local authorColor = ReadColor()
  local message = ReadString()
  if not (author) then
    return 
  end
  if not (authorColor) then
    return 
  end
  if not (message) then
    return 
  end
  local addTextParams = {
    colors.blurple,
    "[Discord] ",
    authorColor,
    author,
    colors.white,
    ": " .. tostring(message)
  }
  hook.Run("CFC_ChatTransit_RemoteMessageReceive", addTextParams)
  return chat.AddText(unpack(addTextParams))
end)
local alertPreference
alertPreference = function(val)
  Start("CFC_ChatTransit_RemoteMessagePreference")
  WriteBool(val)
  return SendToServer()
end
local initHookName = "CFC_ChatTransit_AlertRemoteMessagePreference"
hook.Add("Think", initHookName, function()
  hook.Remove("Think", initHookName)
  alertPreference(shouldReceiveRemoteMessages:GetBool())
  return nil
end)
local populatePanel
populatePanel = function(panel)
  local label = "Should show remote messages"
  do
    local _with_0 = panel:CheckBox(label, "cfc_chat_transit_remote_messages")
    _with_0.OnChange = function(_, val)
      return alertPreference(val)
    end
    return _with_0
  end
end
hook.Add("AddToolMenuCategories", "CFC_ChatTransit_MenuCategory", function()
  return AddToolCategory("Options", "CFC", "CFC")
end)
return hook.Add("PopulateToolMenu", "CFC_ChatTransit_MenuOption", function()
  return AddToolMenuOption("Options", "CFC", "should_receive_remote_messages", "Remote Messages", "", "", function(panel)
    return populatePanel(panel)
  end)
end)
