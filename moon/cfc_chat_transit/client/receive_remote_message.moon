export ChatTransit
import AddToolCategory, AddToolMenuOption from spawnmenu

flags = FCVAR_ARCHIVE + FCVAR_USERINFO
convarName = "cfc_chat_transit_remote_messages"
convarDesc = "Should receive remote messages in chat"
ChatTransit.shouldReceiveRemoteMessages = CreateConVar convarName, 1, flags, convarDesc, 0, 1

colors =
    white: Color 255, 255, 255
    blurple: Color 142, 163, 247

net.Receive "CFC_ChatTransit_RemoteMessageReceive", ->
    return unless ChatTransit.shouldReceiveRemoteMessages\GetBool!

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

print "Loaded receive remote messages"
