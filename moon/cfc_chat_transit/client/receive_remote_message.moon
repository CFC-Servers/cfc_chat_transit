import Start, Receive, ReadBool, ReadString, WriteBool, Send from net
import AddToolCategory, AddToolMenuOption from spawnmenu

shouldReceiveRemoteMessages = CreateConVar "cfc_chat_transit_remote_messages", true, FCVAR_ARCHIVE, "Should receive remote messges in chat", 0, 1

colors =
    white: Color 255, 255, 255
    blurple: Color 114, 137, 218

Receive "CFC_ChatTransit_RemoteMessageReceive", ->
    return unless shouldReceiveRemoteMessages\GetBool!

    author = ReadString!
    message = ReadString!

    return unless author
    return unless message

    -- "@#{author}: #{message}"
    chat.AddText
        colors.blurple
        "@#{author}"

        colors.white
        ": #{message}"

alertPreference = (val) ->
    Start "CFC_ChatTransit_RemoteMessagePreference"
    WriteBool val
    Send!

hook.Add "InitPostEntity", "CFC_ChatTransit_AlertRemoteMessagePreference", ->
    alertPreference shouldReceiveRemoteMessages\GetBool!

populatePanel = (panel) ->
    label = "Should show remote messages (i.e. from Discord)"

    with panel\CheckBox label, "cfc_chat_transit_remote_messages"
        .OnChange = (_, val) -> alertPreference val

hook.Add "AddToolMenuCategories", "CFC_ChatTransit_MenuCategory",  ->
    AddToolCategory "Options", "ChatTransit", "Chat Transit"

hook.Add "PopulateToolMenu", "CFC_ChatTransit_MenuOption", ->
    AddToolMenuOption "Options", "ChatTransit", "should_receive_remote_messages", "Remote Messages", "", "", (panel) ->
        populatePanel panel

