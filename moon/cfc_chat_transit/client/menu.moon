alertPreference = (val) ->
    net.Start "CFC_ChatTransit_RemoteMessagePreference"
    net.WriteBool val
    net.SendToServer!

initHookName = "CFC_ChatTransit_AlertRemoteMessagePreference"

hook.Add "Think", initHookName, ->
    hook.Remove "Think", initHookName
    alertPreference shouldReceiveRemoteMessages\GetBool!

    return nil

populatePanel = (panel) ->
    label = "Should show remote messages"

    with panel\CheckBox label, "cfc_chat_transit_remote_messages"
        .OnChange = (_, val) -> ChatTransit.alertPreference val

hook.Add "AddToolMenuCategories", "CFC_ChatTransit_MenuCategory",  ->
    AddToolCategory "Options", "CFC", "CFC"

hook.Add "PopulateToolMenu", "CFC_ChatTransit_MenuOption", ->
    AddToolMenuOption "Options", "CFC", "should_receive_remote_messages", "Remote Messages", "", "", (panel) ->
        populatePanel panel
