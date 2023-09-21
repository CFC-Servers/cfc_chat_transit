import IsValid from _G

util.AddNetworkString "CFC_ChatTransit_RemoteMessagePreference"
util.AddNetworkString "CFC_ChatTransit_RemoteMessageReceive"

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
    authorColor = rawget args, 2
    message = rawget args, 3

    return unless author
    return unless authorColor
    return unless message

    authorColor = string.ToColor authorColor
    sendingTo = adminOnly\GetBool! and adminRecipients or recipients

    net.Start "CFC_ChatTransit_RemoteMessageReceive"
    net.WriteString author
    net.WriteColor authorColor
    net.WriteString message
    net.Send sendingTo

concommand.Add "chat_transit", broadcastMessage
