local shouldReceiveRemoteMessages = CreateConVar("cfc_chat_transit_remote_messages", 1, FCVAR_ARCHIVE, "Should receive remote messges in chat", 0, 1)

local colors = {
    white = Color(255, 255, 255),
    blurple = Color(142, 163, 247),
}

net.Receive("CFC_ChatTransit_RemoteMessageReceive", function()
    if not shouldReceiveRemoteMessages:GetBool() then return end

    local author = net.ReadString()
    local authorColor = net.ReadColor()
    local message = net.ReadString()

    if not author then return end
    if not authorColor then return end
    if not message then return end

    -- [Discord] @Phatso#2327: Henlop
    local addTextParams = {
        colors.blurple, "[Discord] ",
        authorColor, author,
        colors.white, ": " .. message,
    }

    hook.Run("CFC_ChatTransit_RemoteMessageReceive", { author = author, authorColor = authorColor, message = message })

    chat.AddText(unpack(addTextParams))
end)

local alertPreference = function(val)
    net.Start("CFC_ChatTransit_RemoteMessagePreference")
    net.WriteBool(val)
    net.SendToServer()
end

local initHookName = "CFC_ChatTransit_AlertRemoteMessagePreference"

hook.Add("Think", initHookName, function()
    hook.Remove("Think", initHookName)
    alertPreference(shouldReceiveRemoteMessages:GetBool())
    return nil
end)

local populatePanel = function(panel)
    --label = "Should show remote messages (i.e. from Discord)"
    local label = "Should show remote messages"
    local checkbox = panel:CheckBox(label, "cfc_chat_transit_remote_messages")
    checkbox.OnChange = function(_, val)
        alertPreference(val)
    end
end

hook.Add("AddToolMenuCategories", "CFC_ChatTransit_MenuCategory", function()
    spawnmenu.AddToolCategory("Options", "CFC", "CFC")
end)

hook.Add("PopulateToolMenu", "CFC_ChatTransit_MenuOption", function()
    spawnmenu.AddToolMenuOption("Options", "CFC", "should_receive_remote_messages", "Remote Messages", "", "", function(panel)
        populatePanel(panel)
    end)
end)
