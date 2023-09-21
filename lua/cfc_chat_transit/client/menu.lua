local alertPreference
alertPreference = function(val)
  net.Start("CFC_ChatTransit_RemoteMessagePreference")
  net.WriteBool(val)
  return net.SendToServer()
end
local initHookName = "CFC_ChatTransit_AlertRemoteMessagePreference"
hook.Add("Think", initHookName, function()
  hook.Remove("Think", initHookName)
  alertPreference(ChatTransit.shouldReceiveRemoteMessages:GetBool())
  return nil
end)
local populatePanel
populatePanel = function(panel)
  local label = "Should show remote messages"
  do
    local _with_0 = panel:CheckBox(label, "cfc_chat_transit_remote_messages")
    _with_0.OnChange = function(_, val)
      return ChatTransit.alertPreference(val)
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
