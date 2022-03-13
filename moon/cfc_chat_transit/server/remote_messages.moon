import IsValid from _G
import AddNetworkString from util
import ToColor from string

AddNetworkString "CFC_ChatTransit_RemoteMessagePreference"
AddNetworkString "CFC_ChatTransit_RemoteMessageReceive"

recipients = RecipientFilter!
adminRecipients = RecipientFilter!

shouldTransmit = CreateConVar "cfc_chat_transit_should_transmit_remote", 1, FCVAR_ARCHIVE, "Should transmit remote messages", 0, 1
adminOnly = CreateConVar "cfc_chat_transit_transmit_admin_only", 1, FCVAR_ARCHIVE, "Should only transmit to Admins?", 0, 1

-- TODO: Handle rank changes (to/from Admin)
net.Receive "CFC_ChatTransit_RemoteMessagePreference", (_, ply) ->
    shouldReceive = net.ReadBool!

    if shouldReceive
        recipients\AddPlayer ply

        if adminOnly\GetBool! and ply\IsAdmin!
            adminRecipients\AddPlayer ply

        return

    recipients\RemovePlayer ply
    adminRecipients\RemovePlayer ply

broadcastMessage = (ply, cmd, args, argStr) ->
    return unless shouldTransmit\GetBool!

    return if IsValid ply

    author = rawget args, 1
    return unless author

    authorColor = rawget args, 2
    return unless authorColor

    message = rawget args, 3
    return unless message

    data = {
        :author,
        :message,
        authorColor: ToColor authorColor
        sendingTo: adminOnly\GetBool! and adminRecipients or recipients
    }

    result = hook.Run "CFC_ChatTransit_PreRelayRemoteMessage", data
    return if result == false

    net.Start "CFC_ChatTransit_RemoteMessageReceive"
    net.WriteString data.author
    net.WriteColor data.authorColor
    net.WriteString data.message
    net.Send data.sendingTo

concommand.Add "chat_transit", broadcastMessage
