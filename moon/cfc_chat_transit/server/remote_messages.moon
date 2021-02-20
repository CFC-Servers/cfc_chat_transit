import AddNetworkString from util
import Start, Receive, ReadBool, WriteColor, WriteString, Send from net
import ToColor from string

AddNetworkString "CFC_ChatTransit_RemoteMessagePreference"
AddNetworkString "CFC_ChatTransit_RemoteMessageReceive"

IsValid = IsValid

recipients = RecipientFilter!
adminRecipients = RecipientFilter!

shouldTransmit = CreateConVar "cfc_chat_transit_should_transmit_remote", 1, FCVAR_ARCHIVE, "Should transmit remote messages", 0, 1
adminOnly = CreateConVar "cfc_chat_transit_transmit_admin_only", 1, FCVAR_ARCHIVE, "Should only transmit to Admins?", 0, 1

-- TODO: Handle rank changes (to/from Admin)
Receive "CFC_ChatTransit_RemoteMessagePreference", (_, ply) ->
    shouldReceive = ReadBool!

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
    authorColor = rawget args, 2
    message = rawget args, 3

    return unless author
    return unless authorColor
    return unless message

    authorColor = ToColor authorColor
    sendingTo = adminOnly\GetBool! and adminRecipients or recipients

    Start "CFC_ChatTransit_RemoteMessageReceive"
    WriteString author
    WriteColor authorColor
    WriteString message
    Send sendingTo

concommand.Add "chat_transit", broadcastMessage
