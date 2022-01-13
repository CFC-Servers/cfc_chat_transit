import AddToolCategory, AddToolMenuOption from spawnmenu

shouldReceiveRemoteMessages = CreateConVar "cfc_chat_transit_remote_messages", 1, FCVAR_ARCHIVE, "Should receive remote messges in chat", 0, 1

colors =
    white: Color 255, 255, 255
    blurple: Color 142, 163, 247

net.Receive "CFC_ChatTransit_RemoteMessageReceive", ->
    return unless shouldReceiveRemoteMessages\GetBool!

    author = net.ReadString!
    authorColor = net.ReadColor!
    message = net.ReadString!

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
