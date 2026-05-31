local alertPreference = function(val)
    net.Start("CFC_ChatTransit_RemoteMessagePreference")
    net.WriteBool(val)
    net.SendToServer()
end

local initHookName = "CFC_ChatTransit_AlertRemoteMessagePreference"
hook.Add("Think", initHookName, function()
    hook.Remove("Think", initHookName)
    alertPreference(ChatTransit.shouldReceiveRemoteMessages:GetBool())
    return nil
end)

local populatePanel = function(panel)
    local label = "Should show remote messages"
    local checkbox = panel:CheckBox(label, "cfc_chat_transit_remote_messages")
    checkbox.OnChange = function(_, val)
        ChatTransit.alertPreference(val)
    end
end

hook.Add("AddToolMenuCategories", "CFC_ChatTransit_MenuCategory", function()
    AddToolCategory("Options", "CFC", "CFC")
end)

hook.Add("PopulateToolMenu", "CFC_ChatTransit_MenuOption", function()
    AddToolMenuOption("Options", "CFC", "should_receive_remote_messages", "Remote Messages", "", "", function(panel)
        populatePanel(panel)
    end)
end)
