import Start, Receive, ReadBool, ReadColor, ReadString, WriteBool, SendToServer from net
import AddToolCategory, AddToolMenuOption from spawnmenu

shouldReceiveRemoteMessages = CreateConVar "cfc_chat_transit_remote_messages", 1, FCVAR_ARCHIVE, "Should receive remote messges in chat", 0, 1

colors =
    white: Color 255, 255, 255
    blurple: Color 142, 163, 247

Receive "CFC_ChatTransit_RemoteMessageReceive", ->
    return unless shouldReceiveRemoteMessages\GetBool!

    author = ReadString!
    authorColor = ReadColor!
    message = ReadString!

    return unless author
    return unless authorColor
    return unless message

    -- [Discord] @Phatso#2327: Henlop
    addTextParams = {
        colors.blurple, "[Discord] "
        authorColor, author
        colors.white, ": #{message}"
    }

    hook.Run "CFC_ChatTransit_RemoteMessageReceive", addTextParams

    chat.AddText unpack addTextParams

alertPreference = (val) ->
    Start "CFC_ChatTransit_RemoteMessagePreference"
    WriteBool val
    SendToServer!

initHookName = "CFC_ChatTransit_AlertRemoteMessagePreference"

hook.Add "Think", initHookName, ->
    hook.Remove "Think", initHookName
    alertPreference shouldReceiveRemoteMessages\GetBool!

    return nil

populatePanel = (panel) ->
    --label = "Should show remote messages (i.e. from Discord)"
    label = "Should show remote messages"

    with panel\CheckBox label, "cfc_chat_transit_remote_messages"
        .OnChange = (_, val) -> alertPreference val

hook.Add "AddToolMenuCategories", "CFC_ChatTransit_MenuCategory",  ->
    AddToolCategory "Options", "CFC", "CFC"

hook.Add "PopulateToolMenu", "CFC_ChatTransit_MenuOption", ->
    AddToolMenuOption "Options", "CFC", "should_receive_remote_messages", "Remote Messages", "", "", (panel) ->
        populatePanel panel
